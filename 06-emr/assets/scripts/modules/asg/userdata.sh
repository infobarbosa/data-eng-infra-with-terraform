#!/bin/bash
apt-get update
apt-get install -y apache2
echo "<h1>Welcome to the Apache server!</h1>" > /var/www/html/index.html
echo "<p>Server IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) </p>" >> /var/www/html/index.html
systemctl restart apache2
