#!/bin/bash
sudo yum -y update && sudo yum -y install httpd
sudo wget http://g.oswego.edu/dl/csc241/sample.html -O /var/www/html/index.html
sudo service httpd start && sudo chkconfig httpd on