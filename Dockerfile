FROM envoyproxy/envoy-alpine:v1.14-latest

RUN apk add bash

COPY envoy.yaml /etc/envoy/envoy.yaml

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
