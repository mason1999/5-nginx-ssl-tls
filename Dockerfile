FROM nginx:latest
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./certs /certs
