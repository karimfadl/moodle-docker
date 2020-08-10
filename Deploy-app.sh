#!/bin/bash

# Create Domain Name for Moodle App
echo Hello, What is your Moodle LMS App Domain?
read vardomain
sed -i 's/moodle.domain.com/$vardomain/g; s/moodle.key/$vardomain.key/g; s/moodle.crt/$vardomain.crt/g' ./config/nginx/app_moodle.conf

# Create Self Signed Certificate for Moodle Domain
DOMAIN="$vardomain"
if [ -z "$DOMAIN" ]; then
  echo "Usage: $(basename $0) <domain>"
  exit 11
fi

fail_if_error() {
  [ $1 != 0 ] && {
    unset PASSPHRASE
    exit 10
  }
}

# Generate a passphrase
export PASSPHRASE=$(head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 128; echo)

subj="
C=EG
ST=Cairo
O=karimlabs
localityName=Sohag
commonName=$DOMAIN
organizationalUnitName=IT
emailAddress=karim.fadl@$DOMAIN
"

# Generate the server private key
openssl genrsa -des3 -out ./config/ssl/$DOMAIN.key -passout env:PASSPHRASE 2048
fail_if_error $?

# Generate the CSR
openssl req \
    -new \
    -batch \
    -subj "$(echo -n "$subj" | tr "\n" "/")" \
    -key ./config/ssl/$DOMAIN.key \
    -out ./config/ssl/$DOMAIN.csr \
    -passin env:PASSPHRASE
fail_if_error $?
cp ./config/ssl/$DOMAIN.key ./config/ssl/$DOMAIN.key.org
fail_if_error $?

# Strip the password so we don't have to type it every time we restart Apache
openssl rsa -in ./config/ssl/$DOMAIN.key.org -out ./config/ssl/$DOMAIN.key -passin env:PASSPHRASE
fail_if_error $?

# Generate the cert (good for 10 years)
openssl x509 -req -days 3650 -in ./config/ssl/$DOMAIN.csr -signkey ./config/ssl/$DOMAIN.key -out $DOMAIN.crt
fail_if_error $?

# Download Moodle LMS Files
wget https://download.moodle.org/download.php/direct/stable39/moodle-3.9.1.tgz
tar xvf moodle-*.tgz
rm -rf moodle-*.tgz

#Deploy all Containers through Docker Compose 
docker-compose up -d

#Note
echo "PLEASE Dont' Forget to add the following to /etc/hosts: 127.0.0.1	$vardomain"
echo "Open Your Browser Now to Check The app through this Link: https://$vardomain"
