#!/bin/bash
# This readme is made with the purpose of automating the web server installation and save your time in future occasions

# Debian 11 (HOST) Essential Installations:
apt-get update
apt-get install sudo
apt-get install ufw
sudo apt install curl
sudo apt install git
curl -O https://downloads.rclone.org/rclone-current-linux-amd64.deb
sudo apt install ./rclone-current-linux-amd64.deb

# Create an rclone configuration file
cat > rclone_mega.conf << EOL
[mega]
type = mega
user = kernel.hardening@gmail.com
pass = 3g74pvBoMemz5ZqRJguuyecqSenMwNtKG1OC
EOL

sudo apt-get install net-tools
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 80.233.0.0/16 to any port 22 proto tcp
sudo ufw allow from 80.233.0.0/16 to 172.18.0.2 port 5432 proto tcp
sudo ufw enable

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker dockeruser

# Install Docker Compose
sudo apt-get update
sudo apt-get install -y curl
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create Docker user account. since using the root account it is a vulnerability issue 'dockeruser' will be used to manage all the containers.
sudo useradd -m -s /bin/bash dockeruser
echo "dockeruser:MYP@SSw0rd!" | sudo chpasswd

# Download the folder from MEGA
rclone copy mega:/IronPentest-WebServer ./IronPentest-WebServer --config rclone_mega.conf

# Installing Web Server
cd IronPentest-WebServer
docker-compose build --no-cache && docker-compose up -d --no-recreate
