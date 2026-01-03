#!/bin/sh

ip=$(curl -s https://api.ip.sb/ip -A Mozilla)
echo "Now IP address is: $ip"
echo "Please make sure the IP address is different from the previous one. If not, restart the container."

TOKEN=${TOKEN}
echo "Starting proxy with token: $TOKEN"

./proxy-linux -mode ws2tcp -l :25566 -t 127.0.0.1:25577 -token "$TOKEN" &
./zbproxy