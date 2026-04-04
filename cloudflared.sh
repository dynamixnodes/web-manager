#!/bin/bash

echo "==============================="
echo "🌐 Cloudflare Zero Trust Setup"
echo "==============================="

# Install cloudflared
echo "Installing cloudflared..."
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Verify install
cloudflared --version

echo ""
echo "How do you want to connect your tunnel?"
echo "1) Token"
echo "2) Command"
echo ""

read -p "Enter choice (1 or 2): " choice

echo ""

# OPTION 1: TOKEN
if [ "$choice" == "1" ]; then
    echo "Enter your Cloudflare Tunnel Token:"
    read -p "Token: " token

    echo ""
    echo "Connecting using token..."

    sudo cloudflared service install "$token"

# OPTION 2: COMMAND
elif [ "$choice" == "2" ]; then
    echo "Paste your Cloudflare Tunnel command:"
    echo "(Example: sudo cloudflared service install eyJhIjoi......)"
    echo ""

    read -p "Command: " tunnelcmd

    echo ""
    echo "Executing command..."

    eval "$tunnelcmd"

# INVALID INPUT
else
    echo "❌ Invalid choice. Please run the script again."
    exit 1
fi

echo ""
echo "✅ Cloudflared Installed & Tunnel Connected!"
