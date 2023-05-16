#!/usr/bin/env bash
set -x -e
# redirect the output of this script to a file and console
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
sudo apt-get update
sudo apt-get install -y nginx unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install -b /usr/bin
TOKEN=$(curl --request PUT "http://169.254.169.254/latest/api/token" --header "X-aws-ec2-metadata-token-ttl-seconds: 21600")
NAME=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/tags/instance/Name)
BUCKET=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/tags/instance/Bucket)
aws s3 cp s3://$BUCKET/load_balancer load_balancer
sudo rm /var/www/html/*
sudo rm /etc/nginx/sites-enabled/default
IPS=$(aws ec2 describe-instances --filters Name=tag:Owner,Values=$NAME --query "Reservations[].Instances[].PublicIpAddress" --output text)
echo $IPS
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