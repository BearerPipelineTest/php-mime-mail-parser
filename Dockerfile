FROM debian:latest

RUN apt-get update && apt-get install -y \
		ca-certificates \
		curl \
    php \