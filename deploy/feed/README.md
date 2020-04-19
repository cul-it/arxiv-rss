# Deployment Instructions for feed service

To install `feed` to the development namespace in the kubernetes cluster:

```bash
helm install ./ --set=image.tag=some_tag \
  --tiller-namespace=development --namespace=development  \
  --set=ingress.host=development.arxiv.org \
  --set=elasticsearch.host=foo.es.amazonaws.com \
  --set=elasticsearch.index=arxiv0.3 \
  --set=scaling.replicas=1
```
