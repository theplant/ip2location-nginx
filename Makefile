SHELL = /bin/bash

basebuild:
	@docker build -t theplant/ip2location-nginx-base:latest -f Base.Dockerfile .

basepush: basebuild
	@docker push theplant/ip2location-nginx-base:latest

DB11.BIN:
	@curl -fSL -o DB11.ZIP "http://www.ip2location.com/download/?token=${DOWNLOAD_TOKEN}&file=DB11LITEBINIPV6"
	@unzip DB11.ZIP -d DB11
	@mv DB11/IP2LOCATION-LITE-DB11.IPV6.BIN DB11.BIN
	@rm -rf DB11.ZIP DB11

build: DB11.BIN
	@docker build -t theplant/ip2location-nginx:$$(date "+%Y%m%d") .

push: build
	@docker push theplant/ip2location-nginx:$$(date "+%Y%m%d")
