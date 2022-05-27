#!/bin/bash
sleep 120
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd 
#sudo echo '<h1>Welcome to Website- APP1</h1>' | sudo tee /var/www/html/index.html
#sudo mkdir /var/www/html/app1
#sudo echo '<!DOCTYPE html> <html> <body style="background-color:green;"> <h1>Welcome to Website - App1</h1> <p>Application: V1</p> </body></html>' | sudo tee /var/www/html/app1/index.html
#sudo curl http://169.254.169.254/latest/dynamic/instance-identity/document -0 /var/www/html/app1/metadata.html