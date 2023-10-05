local k8s = import 'k8s.jsonnet';

k8s.image_to_url(
  namespace='ip2location-prod',
  name='ip2location',
  host='ip2location-prod.theplant-dev.com',
  path='/',
  port=9080,
  targetPort=9080,
  imagePullSecrets='',

  // We omit the image tag here because a periodic job rebuilds and rotates the deployment weekly.
  // If we pin it to a fixed image tag, Plantbuild will always deploy a specific image and ignore the image tag passed from the periodic job.
  // Image tag mechanism in Plantbuild: https://github.com/theplant/plantbuild/blob/master/jsonnetlib/k8s.jsonnet#L6-L11
  // Prow periodic job: https://github.com/theplant/test-infra/blob/master/prow/jobs/theplant/public/ip2location-nginx.yaml#L134
  // Slack thread: https://theplant.slack.com/archives/C011SF22G4S/p1695867636797289
  image='562055475000.dkr.ecr.ap-northeast-1.amazonaws.com/public/ip2location-nginx',

  memoryLimit='200Mi',
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
