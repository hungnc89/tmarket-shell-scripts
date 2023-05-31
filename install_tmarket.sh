#!/bin/bash

# Cài đặt Nginx
echo "Cài đặt Nginx..."
apt-get update
apt-get install -y nginx

# Cài đặt Git
echo "Cài đặt Git..."
apt-get install -y git

# Cài đặt Node.js version 16
echo "Cài đặt Node.js version 16..."
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs

# Cài đặt npm phù hợp với Node.js
echo "Cài đặt npm phù hợp với Node.js..."
npm install -g npm@latest

# Thêm tên miền tmarket.edu.vn vào tệp hosts
echo "Thêm tên miền tmarket.edu.vn vào tệp hosts..."
echo "127.0.0.1 tmarket.edu.vn" >> /etc/hosts

# Thêm tên miền tmarket.haiphong.online vào tệp hosts
echo "Thêm tên miền tmarket.haiphong.online vào tệp hosts..."
echo "127.0.0.1 tmarket.haiphong.online" >> /etc/hosts

# Tạo thư mục chứa các tệp tin website
echo "Tạo thư mục chứa các tệp tin website..."
mkdir -p /home/tmarket/dist

# Cấu hình Nginx cho tmarket.edu.vn và tmarket.haiphong.online
echo "Cấu hình Nginx cho tmarket.edu.vn và tmarket.haiphong.online..."
cat > /etc/nginx/sites-available/tmarket <<EOF
server {
    listen 80;
    server_name tmarket.edu.vn tmarket.haiphong.online;

    root /home/tmarket/dist;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        add_header Content-Type text/plain;
        echo "User-agent: *\nDisallow: /";
    }
}

server {
    listen 443 ssl;
    server_name tmarket.edu.vn tmarket.haiphong.online;

    root /home/tmarket/dist;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        add_header Content-Type text/plain;
        echo "User-agent: *\nDisallow: /";
    }

    ssl_certificate /etc/letsencrypt/live/tmarket.edu.vn/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/tmarket.edu.vn/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}
EOF

ln -s /etc/nginx/sites-available/tmarket /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Cấu hình header cho tmarket.haiphong.online
echo "Cấu hình header cho tmarket.haiphong.online..."
cat > /etc/nginx/conf.d/tmarket
