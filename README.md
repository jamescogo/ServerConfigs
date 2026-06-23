# Server Configuration Notes For RockyLinux 10

## [SSH Setup](https://github.com/jamescogo/ServerConfigs/blob/main/SetupInitialSSH.sh)
  * Create SSH Keys using ssh-keygen and the elliptical Edwards Curve Signing Algorithm
  * Secure the keys
  * Copy and convert the OpenSSH keys into puTTY.ppk Keys

## [InitialSetup Script](https://github.com/jamescogo/ServerConfigs/blob/main/SetupSoftware.sh)
  * Install updates to software packages
  * Install Cockpit
  * Install and configure NGINX
  * Install Let's Encrypt certificates for HTTPS
  * Install Grafana

## [Wireguard Configuration](https://github.com/jamescogo/ServerConfigs/blob/main/SetupWireguard.sh)
  * Install the epel-release repositories
  * Install the wireguard tools
  * Create key pairs for a server and device
  * Create the configuration files for the server and client
  * Print a QR code to quickly add the client with a camera
