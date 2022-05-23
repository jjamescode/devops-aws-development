#!/bin/bash
sleep 120
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd 