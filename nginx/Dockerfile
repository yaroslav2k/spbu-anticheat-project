FROM nginx:1.25.0

EXPOSE 443

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY static /var/www

COPY certificates/ca.crt /etc/ssl/certs/ca.crt
COPY certificates/ca.key /etc/ssl/certs/ca.key

CMD ["nginx", "-g", "daemon off;"]
