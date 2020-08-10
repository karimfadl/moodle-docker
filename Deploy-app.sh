#!/bin/bash

# Create Domain Name for Moodle App
echo Hello, What is your Moodle LMS App Domain?
read vardomain
sed -i 's/moodle.domain.com/$vardomain/g; s/moodle.key/$vardomain.key/g; s/moodle.crt/$vardomain.crt/g' ./config/nginx/app_moodle.conf

# Create Self Signed Certificate for Moodle Domain
openssl req -new -x509 -days 365 -nodes \
  -out ./config/ssl/$vardomain.crt \
  -keyout ./config/ssl/$vardomain.key \
  -subj "/C=EG/ST=Cairo/L=Sohag/O=IT/CN=$vardomain"

# Download Moodle LMS Files
wget https://download.moodle.org/download.php/direct/stable39/moodle-3.9.1.tgz
tar xvf moodle-*.tgz
rm -rf moodle-*.tgz

#Deploy all Containers through Docker Compose 
docker-compose up -d

# Fix Moodle Dir Data Permission
chmod -R 777 ./moodledata

#Note
echo "PLEASE Dont' Forget to add the following to /etc/hosts: 127.0.0.1	$vardomain"
echo "Open Your Browser Now to Check The app through this Link: https://$vardomain"
