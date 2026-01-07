# FROM ubuntu:22.04
# RUN apt-get update && apt-get install -y curl
# WORKDIR /app
# COPY . .
# RUN chmod +x init.sh && ./init.sh
# ENV TOKEN=your_token_here
# EXPOSE 25566
# CMD ["./start.sh"]

FROM alpine:latest

# 安装必要工具
RUN apk add --no-cache ca-certificates wireguard-tools curl

# 安装 wgcf (用于管理 WARP 配置)
RUN curl -L https://github.com/ViRb3/wgcf/releases/download/v2.2.22/wgcf_2.2.22_linux_amd64 -o /usr/local/bin/wgcf \
    && chmod +x /usr/local/bin/wgcf

# 安装 wireproxy (核心：实现无 TUN 运行 SOCKS5)
RUN curl -L https://github.com/octeep/wireproxy/releases/download/v1.0.5/wireproxy_linux_amd64.tar.gz | tar xz -C /usr/local/bin \
    && chmod +x /usr/local/bin/wireproxy

# 设置工作目录
WORKDIR /app

# 拷贝启动脚本
COPY . .
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]