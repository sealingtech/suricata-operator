# Suricata-Operator


## Building the Operator

operator-sdk build gcr.io/edcop-dev/suricata-operator:v1.2
docker push  gcr.io/edcop-dev/suricata-operator:v1.2
oc delete -f deploy/operator.yaml
oc delete -f deploy/crds/edcop.io_suricata_crd.yaml


## Deploying the operator

oc apply -f deploy/role.yaml
oc apply -f deploy/role_binding.yaml

oc create -f deploy/operator.yaml
oc create -f deploy/crds/edcop.io_suricata_crd.yaml

## Deploying Suricata

oc create -f edcop.io_v1_suricata_cr.yaml





