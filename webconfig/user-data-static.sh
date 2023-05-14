#!/usr/bin/env bash
sudo apt-get update
sudo apt-get install -y nginx unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install -b /usr/bin
TOKEN=$(curl --request PUT "http://169.254.169.254/latest/api/token" --header "X-aws-ec2-metadata-token-ttl-seconds: 21600")
NUMBER=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/tags/instance/Number)
BUCKET=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/tags/instance/Bucket)
aws s3 cp s3://$BUCKET/static static
aws s3 cp s3://$BUCKET/index.html index.html
sed -i "s/{NUMBER}/$NUMBER/g" static
sed -i "s/{NUMBER}/$NUMBER/g" index.html
sudo rm /var/www/html/*
sudo rm /etc/nginx/sites-enabled/default
sudo cp static /etc/nginx/sites-enabled/static
sudo cp index.html /var/www/html/index.html
sudo systemctl restart nginx
