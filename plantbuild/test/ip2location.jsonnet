local k8s = import 'k8s.jsonnet';

k8s.image_to_url(
  namespace='ip2location-test',
  name='ip2location',
  host='ip2location-test.theplant-dev.com',
  path='/',
  port=9080,
  targetPort=9080,
  imagePullSecrets='',
  image='562055475000.dkr.ecr.ap-northeast-1.amazonaws.com/public/ip2location-nginx',
  memoryRequest='256Mi',
  memoryLimit='384Mi',
  ingressTLSEnabled=true,
  container={
    imagePullPolicy: 'Always',
  },
  ingressAnnotations={
    'kubernetes.io/ingress.class': 'nginx',
    'kubernetes.io/tls-acme': 'true',
    'cert-manager.io/cluster-issuer': 'letsencrypt',
  },
)
