local dc0 = import 'dc.jsonnet';

local dc = dc0 {
  dockerRegistry: 'registry.hub.docker.com',
};

dc.build_apps_image('/theplant', [
  { name: 'ip2location-nginx', context: './', dockerfile: './Dockerfile' },
])
