[ip2location](https://lite.ip2location.com/)

[How to use IP2Location GeoLocation with Nginx](https://blog.ip2location.com/knowledge-base/how-to-use-ip2location-geolocation-with-nginx/)

## CI

CI running on Prow https://prow.theplant.dev/?repo=theplant%2Fip2location-nginx

### Periodic job:

- Run at UTC 19:00 every Monday (`cron: "0 19 * * MON"`, at CST 03:00 every Tuesday)
- Download new DB file
- Build app with latest base image
- Image tag: date (`date "+%Y%m%d"`)
- Deploy to test cluster and validate
- Deploy to prod cluster and validate

### Postsubmit job:

#### Branch `release-test`

- Run on branch `release-test`
- Build base image
- Download new DB file
- Build app with latest base image
- Image tag: git-hash (`git rev-parse HEAD | cut -c 1-7`)
- Deploy to test cluster and validate

#### Branch `release-prod`

- Run on branch `release-prod`
- Image tag: value from file `plantbuild/prod/ip2location.jsonnet`
- Deploy to prod cluster and validate

## Services

- Test: https://ip2location-test.theplant-dev.com

```
curl -I -H 'IP2Location-IP: 1.1.1.1' -i 'https://ip2location-test.theplant-dev.com'
```

- Prod: https://ip2location-prod.theplant-dev.com

```
curl -I -H 'IP2Location-IP: 1.1.1.1' -i 'https://ip2location-prod.theplant-dev.com'
```

- Result

```
HTTP/1.1 200 Connection established
Connection: close

HTTP/2 200
date: Wed, 01 Sep 2021 04:37:54 GMT
content-type: application/octet-stream
content-length: 2
ip2location-country-code: US
ip2location-country-name: United States of America
ip2location-region: California
ip2location-city: Los Angeles
ip2location-latitude: 34.052231
ip2location-longitude: -118.243683
ip2location-zipcode: 90001
ip2location-timezone: -07:00
strict-transport-security: max-age=15724800; includeSubDomains
```

## Client Usage

```
$ curl -H 'IP2Location-IP: 47.244.37.128' -v localhost:8080
* Rebuilt URL to: localhost:8080/
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8080 (#0)
> GET / HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.54.0
> Accept: */*
> IP2Location-IP: 47.244.37.128
>
< HTTP/1.1 200 OK
< Server: nginx/1.14.2
< Date: Mon, 14 Sep 2020 09:21:33 GMT
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
