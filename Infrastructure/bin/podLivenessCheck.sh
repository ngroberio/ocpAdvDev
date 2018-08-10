#!/bin/bash
echo ">>> LIVENESS CHECK FOR POD ${1} TO PROJECT ${2}"
sleep 20
while : ; do
  echo ">>> CHECK IF POD: ${1} IS ALIVE."
  oc get pod -n $2 | grep $1 | grep -v build | grep -v deploy |grep "1/1.*Running"
  [[ "$?" == "1" ]] || break
  echo "<<< NOT YET :( >>>>> WAITING MORE 1O SECONDS AND TRY AGAIN."
  sleep 10
done
