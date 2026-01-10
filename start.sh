#!/bin/bash

./wgcf register --accept-tos
./wgcf generate

cat <<EOF >> wgcf-profile.conf
[Socks5]
BindAddress = 127.0.0.1:25344
EOF

./wireproxy -c wgcf-profile.conf >> /dev/null &

echo "Waiting for WireProxy to start..."
sleep 10

echo "Testing connection through WireProxy..."

curl -s -x socks5h://127.0.0.1:25344 https://www.cloudflare.com/cdn-cgi/trace
curl -s -x socks5h://127.0.0.1:25344 https://api.ipify.org

python -m gunicorn -b 0.0.0.0:8080 app:app &

echo "Starting Caddy on port 80..."
caddy run --config Caddyfile --adapter caddyfile &

exec gost -L "ws://${GOST_AUTH}@:7861?path=/ws"