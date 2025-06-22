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

echo "🌐 Updating Ghost host to 0.0.0.0..."
sudo -u ghost HOME=/var/www/ghost ghost config set server.host 0.0.0.0

echo "🌍 Detecting public IP and setting Ghost URL..."
IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
sudo -u ghost HOME=/var/www/ghost ghost config set url http://$IP:2368

echo "🔄 Restarting Ghost with new configuration..."
sudo -u ghost HOME=/var/www/ghost ghost restart

echo "🧪 Verifying Ghost is up and running..."
sudo -u ghost HOME=/var/www/ghost ghost ls

echo "✅ Ghost CMS is now running at: http://$IP:2368"