FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	php8.2-fpm \
	php8.2-mysql \
	php8.2-curl \
	php8.2-gd \
	php8.2-intl \
	php8.2-mbstring \
	php8.2-xml \
	php8.2-zip \
	mariadb-client \
	wget \
	unzip \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/inception

# Copia pool customizado
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Script de setup
COPY tools/setup_wp.sh /setup_wp.sh
RUN chmod +x /setup_wp.sh

EXPOSE 9000

CMD ["/setup_wp.sh"]
