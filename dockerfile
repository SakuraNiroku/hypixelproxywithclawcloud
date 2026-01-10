FROM ubuntu:22.04
ENV GOST_AUTH=admin:admin
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ca-certificates \
    bash \
    python3 \
    python3-pip \
    python-is-python3 \
    gnupg \
    debian-keyring \
    debian-archive-keyring \
    apt-transport-https \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
RUN curl -fsSL 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
    && curl -fsSL 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list \
    && apt-get update \
    && apt-get install -y caddy \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 下载并安装 gost
RUN wget https://github.com/go-gost/gost/releases/download/v3.2.6/gost_3.2.6_linux_amd64.tar.gz && \
    tar -zxvf gost_3.2.6_linux_amd64.tar.gz && \
    mv gost /usr/bin/gost && \
    chmod +x /usr/bin/gost && \
    rm gost_3.2.6_linux_amd64.tar.gz

WORKDIR /app
COPY . .

RUN python -m pip install -r requirements.txt
RUN chmod +x start.sh && chmod +x _download/main.sh && ./_download/main.sh

EXPOSE 80

CMD ["./start.sh"]