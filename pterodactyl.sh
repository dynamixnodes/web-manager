#!/bin/bash

clear
echo "==============================="
echo "🐉 Pterodactyl Panel Installer"
echo "==============================="

# Ask for domain
read -p "Enter your domain (connected via Cloudflare Tunnel): " DOMAIN

# Update system
apt update && apt upgrade -y

# Install dependencies
apt install -y curl wget git unzip nginx mariadb-server redis-server php php-fpm php-cli php-mysql php-gd php-mbstring php-xml php-bcmath php-curl php-zip

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Download panel
cd /var/www/
mkdir pterodactyl
cd pterodactyl

curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/

# Install dependencies
cp .env.example .env
composer install --no-dev --optimize-autoloader

# Generate key
php artisan key:generate --force

# Setup DB
echo "Setting up database..."
mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE panel;
CREATE USER 'ptero'@'127.0.0.1' IDENTIFIED BY 'ptero123';
GRANT ALL PRIVILEGES ON panel.* TO 'ptero'@'127.0.0.1';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Configure environment
php artisan p:environment:setup <<EOF
$DOMAIN
http
true
Asia/Kolkata
redis
127.0.0.1
6379
session
EOF

php artisan p:environment:database <<EOF
127.0.0.1
3306
panel
ptero
ptero123
EOF

# Run migrations
php artisan migrate --seed --force

# Ask admin details
echo ""
echo "Create Admin User"
read -p "Is admin? (yes/no): " ADMIN
read -p "Email: " EMAIL
read -p "Username: " USERNAME
read -p "First Name: " FIRSTNAME
read -p "Last Name: " LASTNAME
read -sp "Password: " PASSWORD
echo ""

php artisan p:user:make <<EOF
$EMAIL
$USERNAME
$FIRSTNAME
$LASTNAME
$PASSWORD
$PASSWORD
$( [ "$ADMIN" = "yes" ] && echo "yes" || echo "no" )
EOF

# Permissions
chown -R www-data:www-data /var/www/pterodactyl/*

# NGINX config
cat > /etc/nginx/sites-available/pterodactyl <<EOL
server {
    listen 80;
    server_name $DOMAIN;

    root /var/www/pterodactyl/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

ln -s /etc/nginx/sites-available/pterodactyl /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx

echo ""
echo "==============================="
echo "✅ Pterodactyl Panel Installed!"
echo "🌐 URL: http://$DOMAIN"
echo "==============================="
