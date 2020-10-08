#!/bin/bash
sudo su
apt-get update
apt install libnss3-tools jq -y
wget https://github.com/caddyserver/caddy/releases/download/v2.0.0/caddy_2.0.0_linux_amd64.tar.gz
tar xvzf caddy_2.0.0_linux_amd64.tar.gz
mv caddy /bin/

wget https://github.com/go-acme/lego/releases/download/v3.7.0/lego_v3.7.0_linux_amd64.tar.gz
tar xvzf lego_v3.7.0_linux_amd64.tar.gz
mv lego /bin/

HOST="www"
DOMAIN="example.com"
lego --accept-tos --email="giuliocalzolari@example.com" --domains="$HOST.$DOMAIN" --path /etc/ssl --dns="route53" --dns.disable-cp run

aws_instance=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
aws_region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
mkdir /etc/caddy
cat << EOF > /etc/caddy/Caddyfile
:80 {
  redir https://$HOST.$DOMAIN{uri}
}

:443 {
    tls /etc/ssl/certificates/$HOST.$DOMAIN.crt /etc/ssl/certificates/$HOST.$DOMAIN.key {
        protocols tls1.2
    }
    header x-powered-by "caddy"
    respond "AWS Instance $aws_instance on $aws_region region"
}
EOF
caddy start -config /etc/caddy/Caddyfile