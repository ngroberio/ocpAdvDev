#!/bin/bash
# Delete all Homework Projects
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo ">>> REMOVE ALL HOMEWORK PROJECTS FOR GUID=$GUID"

projects=$(oc get projects --output=jsonpath={.items..metadata.name})
for project in $projects; do
  if [[ $project == $GUID* ]]; then
    echo ">>>> DELETING PROJECT $project"
      oc delete project $project
    echo "<<<< PROJECT $project DELETED"
  fi
done

sleep 20
