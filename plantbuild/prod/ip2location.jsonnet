local k8s = import 'k8s.jsonnet';

k8s.image_to_url(
  namespace='ip2location-prod',
  name='ip2location',
  host='ip2location-prod.theplant-dev.com',
  path='/',
  port=9080,
  targetPort=9080,
  imagePullSecrets='',
  image='562055475000.dkr.ecr.ap-northeast-1.amazonaws.com/public/ip2location-nginx',
  ingressTLSEnabled=true,
  ingressAnnotations={
    'kubernetes.io/ingress.class': 'nginx',
    'kubernetes.io/tls-acme': 'true',
    'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
  },
)
