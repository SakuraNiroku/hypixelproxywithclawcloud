#!/bin/bash

./wgcf register --accept-tos
./wgcf generate

cat <<EOF >> wgcf-profile.conf
[Socks5]
BindAddress = 127.0.0.1:25344
EOF

./wireproxy -c wgcf-profile.conf &

sleep 10

curl -x socks5h://127.0.0.1:25344 https://www.cloudflare.com/cdn-cgi/trace
curl -x socks5h://127.0.0.1:25344 https://ip.sb/

./zbproxy