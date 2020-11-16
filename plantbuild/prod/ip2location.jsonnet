local k8s = import 'k8s.jsonnet';

k8s.image_to_url(
  namespace='ip2location',
  name='ip2location',
  host='ip2location.qorpersonalization.com',
  path='/',
  port=8080,
  targetPort=8080,
  imagePullSecrets='',
  image='theplant/ip2location-nginx',
  ingressTLSEnabled=true,
  ingressAnnotations={
    'kubernetes.io/ingress.class': 'nginx',
    'kubernetes.io/tls-acme': 'true',
    'cert-manager.io/cluster-issuer': 'letsencrypt',
  },
)
