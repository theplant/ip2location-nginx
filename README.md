[ip2location](https://lite.ip2location.com/)

[How to use IP2Location GeoLocation with Nginx](https://blog.ip2location.com/knowledge-base/how-to-use-ip2location-geolocation-with-nginx/)

## Client Usage

```
$ curl -H 'X-Forwarded-For: 47.244.37.128' -v localhost:8080
* Rebuilt URL to: localhost:8080/
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8080 (#0)
> GET / HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.54.0
> Accept: */*
> X-Forwarded-For: 47.244.37.128
>
< HTTP/1.1 200 OK
< Server: nginx/1.14.1
< Date: Thu, 06 Dec 2018 07:13:46 GMT
< Content-Type: application/octet-stream
< Content-Length: 2
< Connection: keep-alive
< IP2Location-Country-Code: HK
< IP2Location-Country-Name: Hong Kong
< IP2Location-Region: Hong Kong
< IP2Location-City: Hong Kong
< IP2Location-Latitude: 22.285521
< IP2Location-Longitude: 114.157692
< IP2Location-Zipcode: -
< IP2Location-Timezone: +08:00
<
* Connection #0 to host localhost left intact

```
