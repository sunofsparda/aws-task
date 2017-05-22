#!/bin/bash
yum -y update && sudo yum -y install httpd
wget http://g.oswego.edu/dl/csc241/sample.html -O /var/www/html/index.html
service httpd start && sudo chkconfig httpd on