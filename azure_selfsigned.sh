
#!/bin/bash
sudo su
apt-get update
apt install libnss3-tools jq -y
mkdir /etc/caddy
cd /etc/caddy

wget https://github.com/caddyserver/caddy/releases/download/v2.2.0/caddy_2.2.0_linux_amd64.tar.gz
tar -xvzf caddy_*_linux_amd64.tar.gz
mv caddy /bin/

metadata=$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2020-06-01")
location=$( echo $metadata | jq .compute.location -r)
vmname=$( echo $metadata | jq .compute.name -r)


openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
  -keyout example.key -out example.crt -subj "/CN=example.com" \
  -addext "subjectAltName=DNS:www.example.com"

cat << EOF > /etc/caddy/Caddyfile

:443 {
    tls /etc/caddy/example.crt /etc/caddy/example.key {
        protocols tls1.2
    }
    header x-powered-by "caddy"
    respond "Azure Virtual Machine $vmname on $location region"
}
EOF
caddy start -config /etc/caddy/Caddyfile