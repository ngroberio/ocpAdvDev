#!/bin/bash
echo ">> Liveness Check for Pod ${1} from Project ${2}"
sleep 5
while : ; do
  echo ">> Check Pod ${1} is Ready..."
  oc get pod -n $2 | grep $1 | grep -v build | grep -v deploy |grep "1/1.*Running"
  [[ "$?" == "1" ]] || break
  echo "...no. Sleeping 15 seconds."
  sleep 15
done