#!/bin/bash
echo ">>> NEXUS LIVENESS CHECK FOR PROJECT ${1}"
sleep 20

while : ; do
  echo ">>> NEXUS LIVENESS CHECK:"
  oc get pod -n $1 | grep -v deploy |grep "1/1.*Running"
  [[ "$?" == "1" ]] || break
  echo "<<< NOT YET :( >>>>> WAITING MORE 1O SECONDS AND TRY AGAIN."
  sleep 10
done
