#!/bin/bash

echo "==============================="
echo "🌐 Cloudflare Zero Trust Setup"
echo "==============================="

# Install cloudflared
echo "Installing cloudflared..."
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Verify install
cloudflared --version

echo ""
echo "Paste your Cloudflare Tunnel command below:"
echo "(Example: sudo cloudflared service install eyJhIjoi......)"
echo ""

read -p "Command: " tunnelcmd

# Execute command
eval "$tunnelcmd"

echo ""
echo "✅ Cloudflared Installed & Tunnel Connected!"
