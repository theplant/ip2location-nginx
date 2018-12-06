FROM debian:jessie as builder
# FROM debian:jessie
RUN apt-get update -y && \
    apt-get install -y build-essential dh-autoreconf unzip wget libpcre3 libpcre3-dev zlib1g zlib1g.dev && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir /nginx-dev && \
    cd /nginx-dev \
    && wget https://github.com/chrislim2888/IP2Location-C-Library/archive/master.zip \
    && unzip master.zip && rm master.zip \
    && cd IP2Location-C-Library-master \
    && autoreconf -i -v --force \
    && ./configure \
    && make \
    && make install \
    && ldconfig \
    && cd /nginx-dev \
    && wget https://github.com/ip2location/ip2location-nginx/archive/master.zip \
    && unzip master.zip && rm master.zip \
    && cd /nginx-dev \
    && wget http://nginx.org/download/nginx-1.14.1.tar.gz \
    && tar xvfz nginx-*.tar.gz && rm nginx-*.tar.gz \
    && cd /nginx-dev/nginx-1.14.1 \
    && ./configure \
        --conf-path=/etc/nginx/nginx.conf \
        --add-module=/nginx-dev/ip2location-nginx-master \
        --with-http_realip_module \
    && make \
    && make install \
    && rm -rf /nginx-dev

FROM debian:jessie
ENV LD_LIBRARY_PATH /usr/local/lib
COPY --from=builder /usr/local/nginx /usr/local/nginx
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /etc/nginx /etc/nginx
RUN  ln -sf /dev/stdout /usr/local/nginx/logs/access.log \
     && ln -sf /dev/stderr /usr/local/nginx/logs/error.log
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
