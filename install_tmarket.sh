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
        add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
        return 200 "User-agent: *\nDisallow: /";
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
        add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
        return 200 "User-agent: *\nDisallow: /";
    }

    ssl_certificate /etc/letsencrypt/live/tmarket.edu.vn/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/tmarket.edu.vn/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}
EOF

ln -s /etc/nginx/sites-available/tmarket /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Cài đặt Certbot
echo "Cài đặt Certbot..."
apt-get install -y certbot python3-certbot-nginx

# Cài đặt Let's Encrypt cho tmarket.edu.vn và tmarket.haiphong.online
echo "Cài đặt Let's Encrypt cho tmarket.edu.vn và tmarket.haiphong.online..."
certbot --nginx -d tmarket.edu.vn -d tmarket.haiphong.online

# Chuyển hướng các yêu cầu từ cổng 80 sang cổng 443
echo "Chuyển hướng tất cả các yêu cầu từ cổng 80 sang cổng 443..."
cat > /etc/nginx/conf.d/redirect.conf <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    return 301 https://\$host\$request_uri;
}
EOF

# Khởi động lại dịch vụ Nginx
echo "Khởi động lại dịch vụ Nginx..."
systemctl restart nginx
echo "Done!"
