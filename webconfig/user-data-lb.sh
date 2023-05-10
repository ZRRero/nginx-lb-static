#!/usr/bin/env bash
sudo apt-get update
sudo apt-get install -y nginx
TOKEN=$(curl --request PUT "http://169.254.169.254/latest/api/token" --header "X-aws-ec2-metadata-token-ttl-seconds: 21600")
NAME=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/tags/instance/Name)
aws s3 cp s3://technical-screening/load_balancer load_balancer
sudo rm /var/www/html/*
sudo rm /etc/nginx/sites-enabled/default
IPS=$(aws ec2 describe-instances --filters Name=tag:load-balancer,Values=$NAME --query "Reservations[0].Instances[].PublicIpAddress" --output text)
SERVERS=''
SERVERS_BASE='server {SERVER};\n'
for IP in ${IPS[@]}
do
    SERVER=$(sed "s/{SERVER}/$IP/" <<< $SERVERS_BASE)
    SERVERS="$SERVERS$SERVER"
done
sed -i "s/{SERVERS}/$SERVERS/g" load_balancer
sudo cp load_balancer /etc/nginx/sites-enabled/load_balancer
sudo systemctl restart nginx