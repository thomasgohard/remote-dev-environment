#!/bin/bash

# id -u || $EUID
if [[ $EUID -ne 0 ]]; then
	echo "$0 is not running as root. Try using sudo."
	exit 2
fi

mkdir -p /etc/systemd/logind.conf.d
tee /etc/systemd/logind.conf.d/lid-close-action.conf > /dev/null <<EOF
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF

apt update && apt install -y nginx ufw git vim
snap install docker
sudo -u $USER sh -c "curl -fsSL https://code-server.dev/install.sh | sh"

systemctl enable --now code-server@$USER

tee /etc/nginx/sites-available/code-server > /dev/null <<EOF
server {
	listen 80;
	listen [::]:80;
	server_name $(ip route show default | grep -oP "src \K[\d\.]+");

	location / {
		proxy_pass http://localhost:8080/;
		proxy_set_header Host $host;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection upgrade;
		proxy_set_header Accept-Encoding gzip;
	}
}
EOF
ln -s /etc/nginx/sites-available/code-server /etc/nginx/sites-enabled/code-server
systemctl restart nginx code-server

ufw allow ssh
ufw allow http
ufw enable
