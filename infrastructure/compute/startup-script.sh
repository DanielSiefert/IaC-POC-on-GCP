#!/bin/bash
yum check-updates
yum -y update
yum install -y httpd
systemctl enable httpd
systemctl start httpd
