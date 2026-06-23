# Server Configuration Notes For RockyLinux 10

# Setting Up Firewall settings for WireGuard

# These commands create a new firewall policy that creates an ingress and egress zone to to forward client internal network connection ports to the external facing ports and allows the client to "masquerade" using the server's IP address. This can be useful to bypass location based censorship by tunneling your data to the location of your virtual private server.
firewall-cmd --permanent --new-policy int_to_ext_fwd
firewall-cmd --permanent --policy int_to_ext_fwd --add-ingress-zone internal
firewall-cmd --permanent --policy int_to_ext_fwd --add-egress-zone external
firewall-cmd --permanent --policy int_to_ext_fwd --set-priority 100
firewall-cmd --permanent --policy int_to_ext_fwd --set-target ACCEPT
firewall-cmd --permanent --zone=external --add-masquerade
firewall-cmd --permanent --zone=internal --add-forward

#  Enable IP forwarding to Route Traffic from the client, through the server, and into the internet.
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-wireguard.conf
sudo sysctl --system

# Restart the firewall service
systemctl restart firewalld.service

# Install the repository to install wireguard
sudo dnf install elrepo-release epel-release -y

#Install the wireguard tools package
sudo dnf install wireguard-tools -y

# This is just here in case you need to list the installed packages on the server
# dnf list installed

#Create a public and private key for your wireguard server.
wg genkey | sudo tee /etc/wireguard/private.key
sudo cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key

#Repeat for each of your clients, as you'll need them for each of your configurations.
wg genkey | sudo tee /etc/wireguard/client1_private.key
sudo cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/client1_public.key

#Initiate the file by touching it
sudo touch /etc/wireguard/wg01.conf

#Assign your newly created private and public keys to variables to create the configuration files.
SERVER_PRIVATEKEY=$(</etc/wireguard/private.key)
SERVER_PUBLICKEY=$(</etc/wireguard/public.key)
CLIENT1_PRIVATEKEY=$(</etc/wireguard/client1_private.key)
CLENT1_PUBLICKEY=$(</etc/wireguard/client1_public.key)

#Assign your default interface to the SERVER_INTERFACENAME variable
SERVER_INTERFACENAME=$(ip route show default | awk '/default/ {print $5}')
SERVER_IPADDRESS=$(hostname -I | awk '{print $1}')

#Create the server's configuration file
cat << EOF > wg01.conf
[Interface]
PrivateKey = $SERVER_PRIVATEKEY
Address = 10.10.10.1/24
ListenPort = 51820
SaveConfig = true
## The PostUp will run when the WireGuard Server starts the virtual VPN tunnel.
## The PostDown rules run when the WireGuard Server stops the virtual VPN tunnel.

# Appends (-A) this rule to the end of the FORWARD chain over the (-i wg0) wireguard interface and tells the firewall to jump (-j) to the ACCEPT target
PostUp = iptables -A FORWARD -i wg01 -j ACCEPT

# Selects the (-t nat) Network Translation Table and (-a) appends the rule to the POSTROUTING chain (-o) outgoing over the (ens3) interface 
# to jump the firewall and allow the client to MASQUERADE using the server's IP Address.
PostUp = iptables -t nat -A POSTROUTING -o $SERVER_INTERFACENAME -j MASQUERADE

# Deletes (-D) the (FORWARD) rule over (-i) interface (wg0) created earlier when the connection is turned off
PostDown = iptables -D FORWARD -i wg01 -j ACCEPT

# Deletes the (-t nat) Network Translation Table POSTROUTING rule created earlier when the connection is turned off.
PostDown = iptables -t nat -D POSTROUTING -o $SERVER_INTERFACENAME -j MASQUERADE

[Peer]
# Sets up one client which will be setup to use 10.10.10.2 IP
PublicKey = $CLENT1_PUBLICKEY
AllowedIPs = 10.10.10.2/24
EOF

# Secure the configuration file so only ROOT has access to read and modify the configuration.
sudo chmod 600 /etc/wireguard/wg01.conf

cat << EOF > client1.conf
[Interface]
Address = 10.10.10.11/32
DNS = 1.1.1.1
PrivateKey = $CLIENT1_PRIVATEKEY

[Peer]
PublicKey = $SERVER_PUBLICKEY
endpoint = $SERVER_IPADDRESS:51820
AllowedIPs = 0.0.0.0/1, 128.0.0.0/1
EOF

unset SERVER_PRIVATEKEY
unset SERVER_PUBLICKEY
unset CLIENT1_PRIVATEKEY
unset CLENT1_PUBLICKEY
unset SERVER_INTERFACENAME
unset SERVER_IPADDRESS

#Create a QR Code to quickly add your device. OR download a copy of your client configuration file to your computer.
qrencode -t ansiutf8 < client1.conf

# Wireguard Startup
# If using cockpit on your virtual private server, you can also setup wireguard via the network configuration page by adding a new interface and manually entering the configurations from the config file.
# Start the wireguard service
sudo systemctl start wg-quick@wg01.service

# Enable the service to automatically launch at system boot
sudo systemctl enable wg-quick@wg01.service

#In the event that you need to take down wireguard and disable the service you can use the following commands.
#sudo systemctl stop wg-quick@wg1.servce
#sudo systemctl disable wg-quick@wg01.service
