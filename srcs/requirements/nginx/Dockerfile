FROM debian:bookworm

EXPOSE 443

RUN apt-get update -y && apt-get install -y nginx openssl \
		&& rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/nginx/ssl && \
	openssl req -x509 \
	-newkey rsa:2048 -nodes -sha256 \
	-out /etc/nginx/ssl/cert.pem \
	-keyout /etc/nginx/ssl/key.pem \
  	-subj "/C=PT/ST=Porto/L=Porto/O=42/CN=lmaes.42.fr" \
	&& chmod 600 /etc/nginx/ssl/key.pem && chmod 644 /etc/nginx/ssl/cert.pem

# Remove default config
RUN rm -f /etc/nginx/sites-enabled/default

# Copy nginx config
COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY tools/nginx.sh /nginx.sh

RUN chmod +x /nginx.sh

CMD [ "/nginx.sh" ]