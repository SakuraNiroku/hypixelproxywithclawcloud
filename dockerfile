FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    tar \
    python3 \
    python3-pip \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN chmod +x start.sh && chmod +x _download/main.sh && ./_download/main.sh

CMD ["./start.sh"]