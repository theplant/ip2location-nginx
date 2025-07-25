FROM nginx:1.29.0 as builder
RUN nginx -V 2> $$ \
    && NGINX_VERSION=$(cat $$ | grep 'nginx version:' | awk -F'/' '{print $2}') \
    && echo "Extracted nginx version: $NGINX_VERSION"
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y build-essential dh-autoreconf unzip wget libpcre3 libpcre3-dev zlib1g zlib1g.dev libssl-dev && \
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
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar xvfz nginx-*.tar.gz && rm nginx-*.tar.gz
RUN nginx -V 2> $$ \
    && nginx_configure_arguments="`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'` --add-module=/nginx-dev/ip2location-nginx-master" \
    && rm -rf $$ \
    && cd /nginx-dev/nginx-${NGINX_VERSION} \
    && eval ./configure $nginx_configure_arguments \
    && make

FROM nginx:1.29.0
RUN nginx -V 2> $$ \
    && NGINX_VERSION=$(cat $$ | grep 'nginx version:' | awk -F'/' '{print $2}') \
    && echo "Extracted nginx version: $NGINX_VERSION"
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y libpcre3 && apt-get clean
ENV LD_LIBRARY_PATH /usr/local/lib
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /nginx-dev/nginx-${NGINX_VERSION}/objs/nginx /usr/sbin/nginx
CMD ["nginx", "-g", "daemon off;"]
