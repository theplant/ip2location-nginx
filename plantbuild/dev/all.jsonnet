local k8s = import 'k8s.jsonnet';

k8s.list([
  k8s.namespace(
    name='dev-ip2location',
  ),
  import './ip2location.jsonnet',
])
