local k8s = import 'k8s.jsonnet';

k8s.list([
  k8s.namespace(
    name='ip2location-test',
  ),
  import './ip2location.jsonnet',
])
