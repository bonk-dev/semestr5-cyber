#!/bin/bash

sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

ADMIN_PASS=$(openssl rand -hex 24)

cp .env.example .env
sed -i \
  -e "s|^WP_DB_NAME=.*|WP_DB_NAME=my_db|" \
  -e "s|^WP_DB_USER=.*|WP_DB_USER=my_user|" \
  -e "s|^WP_DB_PASSWORD=.*|WP_DB_PASSWORD=$(openssl rand -hex 24)|" \
  -e "s|^WP_DB_ROOT_PASSWORD=.*|WP_DB_ROOT_PASSWORD=$(openssl rand -hex 24)|" \
  -e "s|^WP_ADMIN_PASSWORD=.*|WP_ADMIN_PASSWORD=$ADMIN_PASS|" \
  -e "s|^BOUNCER_KEY=.*|BOUNCER_KEY=$(openssl rand -hex 32)|" \
  .env

mkdir -p nginx/logs
touch nginx/logs/access.log

sudo docker compose up -d
echo "kontenery uruchomione, inicjalizacja bazy może troche zajac. wordpress dostępny pod: http://adres_maszyny"
echo "dane do wordpressa: "
echo "login=admin"
echo "haslo=$ADMIN_PASS"
