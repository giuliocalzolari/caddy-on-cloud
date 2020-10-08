#!/bin/bash
sudo su
apt-get update
apt install libnss3-tools jq -y
wget https://github.com/caddyserver/caddy/releases/download/v2.2.0/caddy_2.2.0_linux_amd64.tar.gz
tar -xvzf caddy_*_linux_amd64.tar.gz
mv caddy /bin/

openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
  -keyout example.key -out example.crt -subj "/CN=example.com" \
  -addext "subjectAltName=DNS:www.example.com"


aws_instance=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
aws_region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
mkdir /etc/caddy
cat << EOF > /etc/caddy/Caddyfile
:443 {
    tls /etc/caddy/example.crt /etc/caddy/example.key {
        protocols tls1.2
    }
    header x-powered-by "caddy"
    respond "AWS Instance $aws_instance on $aws_region region"
}
EOF
caddy start -config /etc/caddy/Caddyfile