local dc0 = import 'dc.jsonnet';

local dc = dc0 {
  dockerRegistry: '562055475000.dkr.ecr.ap-northeast-1.amazonaws.com',
};

dc.build_apps_image('public/ip2location-nginx', [
  { name: 'ip2location-nginx', context: './', dockerfile: './Dockerfile' },
])
