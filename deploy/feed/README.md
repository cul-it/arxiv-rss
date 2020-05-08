# Deployment Instructions for feed service

To install `feed` to the development namespace in the kubernetes cluster:

```bash
helm install ./ --set=image.tag=0.0 \
  --tiller-namespace=development --namespace=development  \
  --set=ingress.host=development.arxiv.org \
  --set=elasticsearch.host=vpc-arxiv-es-ouzkxhljg5enjwygjjtxmtqymq.us-east-1.es.amazonaws.com \
  --set=elasticsearch.index=arxiv0.5.1 \
  --set=redis.host=arxiv-feed-dev.vekyzh.ng.0001.use1.cache.amazonaws.com \
  --set=scaling.replicas=1
```
