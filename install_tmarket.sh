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

# Thêm tên miền tmarket.edu.vn vào cấu hình Nginx
echo "Thêm tên miền tmarket.edu.vn vào cấu hình Nginx..."
cat > /etc/nginx/sites-available/tmarket-edu <<EOF
server {
    listen 80;
    server_name tmarket.edu.vn;

    location / {
        root /home/tmarket/dist;
        index index.html;
        try_files \$uri \$uri/ =404;
    }
}
EOF

ln -s /etc/nginx/sites-available/tmarket-edu /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Thêm tên miền tmarket.haiphong.online vào cấu hình Nginx
echo "Thêm tên miền tmarket.haiphong.online vào cấu hình Nginx..."
cat > /etc/nginx/sites-available/tmarket-hp <<EOF
server {
    listen 80;
    server_name tmarket.haiphong.online;

    location / {
        root /home/tmarket/dist;
        index index.html;
        try_files \$uri \$uri/ =404;
    }

    location = /robots.txt {
        add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
        return 200 "User-agent: *\nDisallow: /";
    }
}
EOF

ln -s /etc/nginx/sites-available/tmarket-hp /etc/nginx/sites-enabled/

# Tạo thư mục chứa các tệp tin website
echo "Tạo thư mục chứa các tệp tin website..."
mkdir -p /home/tmarket/dist

# Cài đặt Certbot
echo "Cài đặt Certbot..."
apt-get install -y certbot python3-certbot-nginx

# Cấu hình Let's Encrypt cho tmarket.edu.vn và tmarket.haiphong.online
echo "Cấu hình Let's Encrypt cho tmarket.edu.vn và tmarket.haiphong.online..."
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

echo "Hoàn thành cài đặt và cấu hình!"
