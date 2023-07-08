#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

virtualization=$(dmidecode -s system-manufacturer)
if [[ $virtualization == "OpenVZ" ||  $virtualization == "LXC"]]; then
  echo "* Pterodactyl does not support OpenVZ or LXC virtualization" 1>&2
  exit 1
fi

echo "* Updating system files"
sudo apt -y update

echo "* Installing Docker"
curl -sSL https://get.docker.com/ | CHANNEL=stable bash

echo "* Enabled Docker service on startup"
systemctl enable --now docker

echo "* Downloading Pterodactyl"
mkdir -p /etc/pterodactyl
curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
chmod u+x /usr/local/bin/wings

echo "* Creating wings.service for enabling on startup"
cd /etc/systemd/system
curl https://raw.githubusercontent.com/Russhvith/floramc-other/main/pteroinstaller/files/wings.service >> wings.service
cd /etc/pterodactyl

echo "* Installing certbot for SSL"
apt install -y certbot
sudo apt install -y python3-certbot-nginx

echo "* Stopping nginx for SSL"
systemctl stop nginx

echo "* Please enter your domain name (example.com)"
read domain

echo "* Installing SSL"
certbot certonly --standalone --agree-tos --no-eff-email --register-unsafely-without-email -d $domain

echo "* Adding Auto renewal for SSL using crontab"
(crontab -l 2>/dev/null; echo "0 23 * * * certbot renew --quiet --deploy-hook "systemctl restart nginx"") | crontab -  

echo "---------------------------------------------------"
echo "** Please go to your panel and follow the instructions below"
echo ""
echo "** Ignore this if you have made Locations"
echo ""
echo "* 1. Go To Admin Panel"
echo "* 2. Go To Locations"
echo "* 3. Click Create New (Right Hand Top Side)"
echo "* 4. Short Code : Any short code you want"
echo "* 5. Description : Any description you want"
echo "* 6. Click Create"
echo ""
echo "**          DOING THIS IS A MUST"
echo ""
echo "* 1. Go To Admin Panel"
echo "* 2. Go To Nodes"
echo "* 3. Click Create New (Right Hand Top Side)"
echo "* 4. Name : Any name you want"
echo "* 5. Description : Any description you want"
echo "* 6. Location : Any location you want"
echo "** 7. FQDN : $domain"
echo "* 8. Communicate Over SSL : Use SSL Connection"
echo "* 9. Behind Proxy : Do not use proxy"
echo "* 10. Total Memory : Your server memory in MB"
echo "* 11. Memory Over-Allocation : 0"
echo "* 12. Disk Space : Your server disk space in MB"
echo "* 13. Disk Over-Allocation : 0" 
echo "* 14. Daemon Port : 8080"
echo "* 15. Daemon SSL Port : 2022"
echo "* 16. Click Create Node"
echo "---------------------------------------------------"
echo ""
echo "Please type Y to continue...."
read -r input
if [ "$input" = "Y" ]; then
    clear
    echo "---------------------------------------------------"
    echo "* Please follow the instructions below"
    echo ""
    echo "* 1. On the node page, click the Configuration button"
    echo "* 2. Please click the Generate Token button"
    echo "* 3. Copy the token and paste it below (Starts with cd /etc/pterodactyl)"
    echo "---------------------------------------------------"
    echo ""
    echo "Please enter the token to continue...."
    read -r token
    outputtoken = $token
    clear
    echo "* Enabling wings on startup"
    systemctl enable --now wings
    clear
    ip = $(hostname -I | awk '{print $1}')
    echo "---------------------------------------------------"
    echo "* Installation completed"
    echo "* Please go to your panel and follow the instructions below"
    echo ""
    echo "* 1. Go To Admin Panel"
    echo "* 2. Go To Nodes"
    echo "* 3. Click on the node you created"
    echo "* 4. Click on Allocation"
    echo "* 5. Look on the right side"
    echo "* 6. IP Address: $ip"
    echo "* 7. IP Alias: $domain"
    echo "* 8. Ports : How many ever you want (Tip: You can add multiple via using a - in between ports (eg: 25565-25570). MAX IS 1000)"
    echo "* 9. Click Submit"
    echo "---------------------------------------------------"
    echo ""
    echo "* Thank you for using my script"
    echo "* If you have any issues please contact me on discord"
    echo "* Discord : @russhvith"
    echo "* Thank you for using my script"
    echo "* Have a nice day"
    exit 0
else
    echo "* Installation cancelled"
    echo "* If you have any issues please contact me on discord"
    echo "* Discord : @russhvith"
    echo "* Thank you for using my script"
    echo "* Have a nice day"
    exit 0
fi
