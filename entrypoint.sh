#!/bin/bash

XFF_NUM_HOPS=${XFF_NUM_TRUSTED_HOPS:-1}

echo '
static_resources:
  listeners:
  - name: "ingress listener"
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 10000
    filter_chains:
      filters:
      - name: envoy.http_connection_manager
        config:
          codec_type: auto
          stat_prefix: ingress_http
          route_config:
            name: ip_whitelist
            virtual_hosts:
            - name: all_hosts
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/"  
                direct_response:
                  status: 200
          http_filters:
          - name: envoy.filters.http.rbac 
            config: 
              rules: 
                action: ALLOW
                policies:
                  "general-rules":
                    permissions:
                    - any: true
                    principals:
                    - or_ids:
                        ids:
' > envoy.yaml.tmp

for cidr in $(cat /etc/cidrs/cidrs)
do
  IP=$(cut -d '/' -f 1 <<< $cidr)
  MASK=$(cut -d '/' -f 2 <<< $cidr)
  echo "
                          - remote_ip:
                              address_prefix: $IP
                              prefix_len: 
                                value: $MASK
  " >> envoy.yaml.tmp
done
echo "
          - name: envoy.router
            config: {}
          access_log:
            name: envoy.file_access_log
            config: {path: /dev/stdout}
          xff_num_trusted_hops: $XFF_NUM_HOPS
          use_remote_address: true

admin:
  access_log_path: '/dev/stdout'
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 8080
" >> envoy.yaml.tmp

cp envoy.yaml.tmp /etc/envoy/envoy.yaml

envoy -c /etc/envoy/envoy.yaml