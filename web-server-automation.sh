#!/bin/bash
# This readme is made with the purpose of automating the web server installation and save your time in future occasions

# Debian 11 (HOST) Essential Installations:
apt-get update
apt-get upgrade -y
sudo apt-get dist-upgrade -y
apt-get install sudo
apt-get install ufw
sudo apt install curl
sudo apt install git
curl -O https://downloads.rclone.org/rclone-current-linux-amd64.deb
sudo apt install ./rclone-current-linux-amd64.deb || { echo -e "\e[31mError installing rclone. Exiting.\e[0m"; exit 1; }

# Prompt the user for their MEGA email and password
echo -e "\e[33mDo you want to enter your Mega credentials? [Y/N]:\e[0m"
read mega_choice

if [[ $mega_choice =~ ^[Yy]$ ]]; then
echo -e "\e[33 Visit https://mega.nz/ and create and account to automatically backup the database(You can Ignore this step)\e[0m"
echo -e "\e[33mEnter your Mega email address:\e[0m"
read mega_email
echo -e "\e[33mEnter your Mega password:\e[0m"
password=""
while IFS= read -r -s -n1 char; do
  if [[ $char == $'\0' ]]; then
    break
  fi
  echo -n "*"
  password+="$char"
done
echo
fi

# Create an rclone configuration file
cat > rclone_mega.conf << EOL
[mega]
type = mega
user = $mega_email
pass = $password
EOL

sudo apt-get install net-tools
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 80.233.0.0/16 to any port 22 proto tcp
sudo ufw allow from 80.233.0.0/16 to 172.18.0.2 port 5432 proto tcp
sudo ufw enable

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh || { echo -e "\e[31mError installing Docker. Exiting.\e[0m"; exit 1; }



# Create Docker user account. since using the root account it is a vulnerability issue 'dockeruser' will be used to manage all the containers.
echo -e "\e[33m [Hardening] Please create the dockeruser account:\e[0m"
echo -e "\e[33m Enter your Username:\e[0m"
read username
echo -e "\e[33m Enter your Password:\e[0m"
docker_user_password=""
while IFS= read -r -s -n1 char; do
  if [[ $char == $'\0' ]]; then
    break
  fi
  echo -n "*"
  docker_user_password+="$char"
done
echo
sudo useradd -m -s /bin/bash $username
echo $username:$docker_user_password | sudo chpasswd
sudo usermod -aG docker $username
sudo usermod -aG sudo $username

# Install Docker Compose
sudo apt-get update
sudo apt-get install -y curl
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install megatools
sudo apt-get install -y megatools

# Download the folder from MEGA
mkdir IronPentest-WebServer
megadl "https://mega.nz/folder/OLJTlCwT#fZjlW2dqFuggpVUpgSaqRw" --path ./IronPentest-WebServer

# Installing Web Server
cd IronPentest-WebServer
docker-compose build --no-cache && docker-compose up -d --no-recreate
