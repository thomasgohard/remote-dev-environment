# Setting up a remote development environment

1. Install Ubuntu server using minimal install with Docker option checked
1. `sudo apt update && sudo apt upgrade -y`
1. `sudo apt install -y nginx`
1. `sudo groupadd docker`
1. `sudo usermod -aG docker $USER`
1. `curl -fsSL https://code-server.dev/install.sh | sh`
1. `sudo systemctl enable --now code-server@$USER`
1. ```bash
sudo tee /etc/nginx/sites-available/code-server >/dev/null <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $(ip route show default | grep -oP "src \K[\d\.]+");
    location / {
        proxy_pass http://localhost:8080/;
        proxy_set_header Host \$host;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
    }
}
EOF
```
1. `sudo ln -s /etc/nginx/sites-available/code-server /etc/nginx/sites-enabled/code-server`
1. `sudo systemctl restart nginx code-server`
1. `sudo ufw enable`
1. `sudo ufw allow http`
