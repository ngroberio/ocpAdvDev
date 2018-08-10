#!/bin/bash
# Setup Development Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Parks Development Environment in project ${GUID}-parks-dev"

# Code to set up the parks development project.

# To be Implemented by Student
PROJECT_NAME=${GUID}-parks-dev
MONGO_TMPL=./Infrastructure/templates/mongodb_template.yaml
APPS_TMPL=./Infrastructure/templates/dev_setup_template.yaml

echo ">>> STEP #1 > CREATE MONGODB"
oc create -f $MONGO_TMPL -n $PROJECT_NAME

./Infrastructure/bin/podLivenessCheck.sh mongodb $PROJECT_NAME

echo ">>> STEP #2 > CREATE APPS"
oc create -f $APPS_TMPL -n $PROJECT_NAME

echo ">>> STEP #3 > ADD PERMISSIONS"
oc policy add-role-to-user view --serviceaccount=default -n $PROJECT_NAME

sleep 20
