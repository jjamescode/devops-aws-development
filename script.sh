#!/bin/bash
sleep 120
yum update -y
yum install -y httpd
echo '<h1>Welcome to Website- APP1</h1>' > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
