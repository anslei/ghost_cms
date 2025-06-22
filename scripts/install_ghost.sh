#!/bin/bash
set -euxo pipefail

echo "🚀 Updating system and removing conflicting Node.js versions..."
sudo apt remove -y nodejs libnode-dev nodejs-doc || true
sudo apt autoremove -y
sudo rm -rf /var/cache/apt/archives/nodejs_*

echo "📦 Installing Node.js 18 LTS from NodeSource..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs unzip curl nginx

echo "🔧 Installing Ghost CLI..."
sudo npm install -g ghost-cli

echo "👤 Creating 'ghost' system user and home directory..."
sudo useradd --system --user-group ghost || true
sudo mkdir -p /var/www/ghost
sudo chown ghost:ghost /var/www/ghost

echo "📁 Installing Ghost CMS in /var/www/ghost..."
cd /var/www/ghost
sudo -u ghost HOME=/var/www/ghost ghost install local --no-prompt --no-stack

echo "🌐 Updating Ghost host to 0.0.0.0 and port to 2368"
sudo -u ghost HOME=/var/www/ghost ghost config set server.host 0.0.0.0
sudo -u ghost HOME=/var/www/ghost ghost config set server.port 2368


echo "🌍 Detecting public IP and setting Ghost URL..."
IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
sudo -u ghost HOME=/var/www/ghost ghost config set url http://$IP:2368

echo "🔄 Restarting Ghost with new configuration..."
sudo -u ghost HOME=/var/www/ghost ghost restart

echo "🧪 Verifying Ghost is up and running..."
sudo -u ghost HOME=/var/www/ghost ghost ls

echo "📝 Creating systemd service for Ghost CMS..."
sudo tee /etc/systemd/system/ghost-local.service > /dev/null <<EOF
[Unit]
Description=Ghost systemd service for blog: ghost-local
Documentation=https://ghost.org/docs/

[Service]
Type=simple
WorkingDirectory=/var/www/ghost
User=998
Environment="NODE_ENV=development"
Environment="HOME=/var/www/ghost"
ExecStart=/usr/bin/env HOME=/var/www/ghost ghost run
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Enabling and starting Ghost systemd service..."
sudo systemctl daemon-reload
sudo systemctl enable ghost-local
sudo systemctl start ghost-local

echo "✅ Ghost CMS is now running at: http://$IP:2368"