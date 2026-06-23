sudo dnf update
sudo dnf upgrade

#Install Cockpit - Useful for http based server administration but... it is an attack vector.
sudo dnf install cockpit -y
sudo systemctl enable --now cockpit.socket
sudo firewall-cmd --add-service=cockpit --permanent
sudo firewall-cmd --reload

#If you installed cockpit on accident and you want to remove it, run the following commands.
  #sudo systemctl stop cockpit
  #sudo systemctl disable cockpit
  #sudo dnf remove cockpit
  #sudo systemctl daemon-reload
#Remove firewall rules
  #sudo firewall-cmd --permanent --remove-service=cockpit

#Install NGINX
sudo dnf install nginx -y
sudo systemctl enable --now nginx

#Add Firewall Rules for NGINX
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

#Configure NGINX
server {
    server_name yourwebsite.com;

    listen 80;
    listen [::]:80;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}

#Install Lets Encrypt
dnf install epel-release
dnf install certbot python3-certbot-nginx -y



#Install Grafana
sudo dnf install grafana -y

# vi /etc/grafana/grafana.ini
  # line 36 : uncoment and specify protocol ⇒ possible to change to [https], [h2], [socket]
    #;protocol = http
  
  # line 42 : if you limit access to Grafana, uncomment and set specific IP address Grafana listens
  # listen all [0.0.0.0] by default
    # ;http_addr =
  
  # line 45 : specify port ⇒ possible to change to other port
    #;http_port = 3000
  
  # line 48 : specify domain name ⇒ possible to change to your domain name
    #;domain = localhost
  
  # line 71,72 : specify your certificate if you set [https] or [h2] for protocol
  # * it needs [grafana] user can read certificate and key
    #cert_file = /etc/letsencrypt/live/dlp.srv.world/fullchain.pem
    #cert_key = /etc/letsencrypt/live/dlp.srv.world/privkey.pem

# systemctl enable --now grafana-server
# Add Firewall Rules for Grafana
firewall-cmd --add-port=3000/tcp
firewall-cmd --runtime-to-permanent
