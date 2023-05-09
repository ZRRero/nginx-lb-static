#!/usr/bin/env bash
sudo apt-get update
sudo apt-get install -y nginx
TOKEN=$(curl --request PUT "http://169.254.169.254/latest/api/token" --header "X-aws-ec2-metadata-token-ttl-seconds: 21600")
NUMBER=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/tags/instance/Number)
aws s3 cp s3://technical-screening/static static
aws s3 cp s3://technical-screening/index.html index.html
sed -i "s/{NUMBER}/$NUMBER/g" static
sed -i "s/{NUMBER}/$NUMBER/g" index.html
sudo rm /var/www/html/*
sudo rm /etc/nginx/sites-enabled/default
sudo cp static /etc/nginx/sites-enabled/static
sudo cp index.html /var/www/html/index.html
sudo systemctl restart nginx
