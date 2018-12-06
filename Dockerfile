FROM theplant/ip2location-nginx-base:latest

COPY nginx.conf /etc/nginx/nginx.conf
COPY DB11.BIN /etc/ip2location/DB11.BIN
EXPOSE 8080
STOPSIGNAL SIGTERM
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
