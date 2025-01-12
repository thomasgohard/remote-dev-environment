# Setting up a remote development environment

These instructions will set up a server as a remote development environment running Visual Studio Code that can be accessed via any web browser.

First, install Ubuntu server using the minimal install. If you intend to use devcontainers, also check the Docker option during the installation process.

Once the installation is complete, make sure your install is up-to-date:

`sudo apt update && sudo apt upgrade -y`

Install nginx:

`sudo apt install -y nginx`

Configure your user to use Docker:

`sudo groupadd docker`

`sudo usermod -aG docker $USER`

Install Visual Studio Code server:

`curl -fsSL https://code-server.dev/install.sh | sh`

Configure Visual Studio Code server to run as a service and start it:

`sudo systemctl enable --now code-server@$USER`

Configure nginx as a reverse proxy for Visual Studio Code server:

```bash
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

`sudo ln -s /etc/nginx/sites-available/code-server /etc/nginx/sites-enabled/code-server`

`sudo systemctl restart nginx code-server`

Configure the firewall:

`sudo ufw enable`

`sudo ufw allow http`
