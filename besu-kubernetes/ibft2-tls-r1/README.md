# Launch tls and r1 based config

 * Support for launching validators only for now.
 * Looks like the RBACs are not being applied properly, as the besu kubernetes NAT mode is failing to get list of services, it is not causing any issue for now, but need to debug
 * for local dev effeciency the besu config files (keys, config etc) are mounted as ConfigMap binary data, watch out for the max size limit. It should be avoided on prod envs.

## Start validators
```bash
# dry run validator nodes
helm install --debug --dry-run validator .
# start validator nodes
helm install --namespace validator --create-namespace validator .
helm install --namespace validator validator .
# watch pods
kubectl get pods -w --namespace validator
# check validator-0 logs
kubectl logs validator-0 -f --namespace validator
# verify secp256r1 enabled
kubectl logs validator-0 --namespace validator | grep secp256r1
# check tls enabled
kubectl logs validator-0 --namespace validator | grep TLS
# remove deployed validator nodes
helm uninstall validator --namespace validator
```
