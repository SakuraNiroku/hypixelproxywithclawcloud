#!/bin/sh

# 1. 注册 WARP 账户并获取配置
echo "正在注册 WARP 账号..."
wgcf register --accept-tos
wgcf generate

# 2. 提取 WireGuard 配置信息
PRIVATE_KEY=$(grep PrivateKey wgcf-profile.conf | cut -d " " -f 3)
PUBLIC_KEY=$(grep PublicKey wgcf-profile.conf | cut -d " " -f 3)
# 提取 IPv6 或 IPv4 地址 (wireproxy 需要)
ADDRESS=$(grep Address wgcf-profile.conf | cut -d " " -f 3 | head -n 1)

# 3. 生成 wireproxy 配置文件
cat <<EOF > /app/proxy.conf
[WG]
SelfIP = $ADDRESS
PrivateKey = $PRIVATE_KEY
PeerPublicKey = $PUBLIC_KEY
Endpoint = engage.cloudflareclient.com:2408
KeepAlive = 25

[Socks5]
BindAddress = 0.0.0.0:40000
EOF

# 4. 启动 wireproxy (用户态 WireGuard 转 SOCKS5)
echo "正在启动 SOCKS5 代理..."
wireproxy -c /app/proxy.conf &

# 5. 等待代理就绪并验证 IP
sleep 5
echo "--- WARP 状态验证 ---"
# 使用代理访问 ifconfig.me
curl --socks5-hostname 127.0.0.1:40000 https://ifconfig.me
echo -e "\n--------------------"

# 保持进程运行
wait