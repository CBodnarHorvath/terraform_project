#!/bin/bash
yum update -y
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo Hello World from Charles and Tin! > /var/www/html/index.html