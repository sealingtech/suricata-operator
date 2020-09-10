#!/bin/bash
# Suricata rules update script

set -e

#Don't need this on the update container
#mkdir -p /data/suricata /logs/suricata

sleep 10

# Update rules, testing takes too long and will be done when Suricata loads anyway
suricata-update --no-test --no-reload

# Get list of Suricata Pods - REQUIRES RBAC
echo "Getting list of Suricata Pods..."
SURICATA_PODS=`kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -l app=suricata | grep $CHART_PREFIX`

# Try 10 times before giving up 
COUNTER=0
until [ "SURICATA_PODS" != "" ]; do
  if [ $COUNTER -ge 10 ]; then
    echo "Too many tries, exiting... "
    exit 1
  fi
  SURICATA_PODS=`kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -l app=suricata | grep $CHART_PREFIX`
  if [ "$SURICATA_PODS" == "" ]; then
    echo "Didn't find any Suricata pods, trying again... (x$COUNTER)"
  fi 
  let COUNTER++
  sleep 5
done

echo 
echo "Found Suricata pods:"
echo "$SURICATA_PODS"
echo 

# Reload Suricata rules - REQUIRES RBAC
for pod in $SURICATA_PODS
do
  echo "Reloading rules in $pod"
  if kubectl exec $pod -c suricata -- suricatasc -c reload-rules; then
    echo "Successfully reloaded rules in pod $pod"
  else
    echo "First time loading, reload not needed in pod $pod"
  fi
  sleep 10 
done
 
