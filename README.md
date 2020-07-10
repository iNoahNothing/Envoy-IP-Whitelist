# Enovy Proxy with IP Whitelisting

Envoy can support whitelisting IPs and blocking requests that are not in that white list.

This simple service deploys and Envoy that responds 200 if the IP is allowed and 403 otherwise.

**Note:** This is a hack and is meant as a POC of how you could accomplish it.

## Deploy

This container is meant to be deployed in Kubernetes.

The container uses `k8s/cidr-cm.yaml` `ConfigMap` to build a list of CIDRs to white list.

1. Update `cidr-cm.yaml` with the list of CIDRs you would like to whitelist

2. Deploy the `ConfigMap`

   ```
   kubectl apply -f k8s/cidr-cm.yaml
   ```

3. Update the `k8s/envoy-whitelist.yaml` `Deployment` to use the image you pushed below

4. Deploy `k8s/envoy-whitelist.yaml`

   ```
   kubectl apply -f k8s/envoy-whitelist.yaml
   ```

## Ambassador `External` `Filter`

The purpose of this service is to provide a simple way to add a whitelist for [Ambassador](https://getambassador.io).

We will use an `External` `Filter` to connect it to the Ambassador Edge Stack

1. Install Ambassador using [`helm`](https://helm.sh)

   ```
   helm repo add datawire https://getambassador.io/
   kubectl create ns ambassador && helm install -n ambassador ambassador datawire/ambassador
   ```

2. Apply `envoy-whitelist` `Filter` and `FilterPolicy`

   ```
   kubectl apply -f k8s/ambassador/whitelist-filter.yaml
   ```


## Build 

This is just a simple extension of `docker.io/envoyproxy/envoy-alpine:1.14-latest` container.

Simply build and push the container with `docker`

```sh
DOCKER_REG=""
DOCKER_TAG=""

docker build -t $DOCKER_REG/envoy:$DOCKER_TAG

docker push $DOCKER_REG/envoy:$DOCKER_TAG
```

