FROM 562055475000.dkr.ecr.ap-northeast-1.amazonaws.com/public/ip2location-nginx-base:latest

COPY nginx.conf /etc/nginx/nginx.conf
COPY DB11.BIN /etc/ip2location/DB11.BIN
EXPOSE 9080
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
