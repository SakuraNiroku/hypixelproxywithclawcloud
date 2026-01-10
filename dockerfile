FROM ubuntu:24.04

ENV GOST_AUTH=admin:admin

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    tar \
    python3 \
    python3-pip \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# 下载并安装 gost
RUN wget https://github.com/go-gost/gost/releases/download/v3.2.6/gost_3.2.6_linux_amd64.tar.gz && \
    tar -zxvf gost_3.2.6_linux_amd64.tar.gz && \
    mv gost /usr/bin/gost && \
    chmod +x /usr/bin/gost && \
    rm gost_3.2.6_linux_amd64.tar.gz

WORKDIR /app
COPY . .

RUN chmod +x start.sh && chmod +x _download/main.sh && ./_download/main.sh

EXPOSE 80

CMD ["./start.sh"]