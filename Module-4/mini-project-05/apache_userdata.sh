#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Updating yum packages"
sudo yum update -y

if ! sudo yum install -y httpd; then
    echo "httpd installation failed" >&2
    exit 1
fi

sudo systemctl start httpd
if ! sudo systemctl is-active --quiet httpd; then
    echo "httpd failed to start" >&2
    exit 1
fi

sudo systemctl enable httpd

echo "<h1>Hello World from $(hostname -f)</h1>" | sudo tee /var/www/html/index.html
