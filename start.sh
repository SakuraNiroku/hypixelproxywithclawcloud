#!/bin/bash

./wgcf register --accept-tos
./wgcf generate

cat <<EOF >> wgcf-profile.conf
[Socks5]
BindAddress = 127.0.0.1:25344
EOF

./wireproxy -c wgcf-profile.conf -d -s

echo "Waiting for WireProxy to start..."
sleep 10

echo "Testing connection through WireProxy..."

curl -x socks5h://127.0.0.1:25344 https://www.cloudflare.com/cdn-cgi/trace
curl -x socks5h://127.0.0.1:25344 https://api.ip.sb/geoip

echo "Starting ZBProxy..."

./zbproxy &

exec gost -L "ws://${GOST_AUTH}:80?path=/ws"