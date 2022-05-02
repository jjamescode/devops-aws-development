#!/bin/bash
yum update -y
yum install -y httpd.x86_64
systemctl install httpd.service
systemctl enable httpd.service 