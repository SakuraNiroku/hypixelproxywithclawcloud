FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl
WORKDIR /app
COPY . .
RUN chmod +x init.sh && ./init.sh
ENV TOKEN=your_token_here
EXPOSE 25566
CMD ["./start.sh"]