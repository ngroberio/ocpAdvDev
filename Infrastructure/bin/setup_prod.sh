#!/bin/bash
# Setup Production Project (initial active services: Green)
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Parks Production Environment in project ${GUID}-parks-prod"

# Code to set up the parks production project. It will need a StatefulSet MongoDB, and two applications each (Blue/Green) for NationalParks, MLBParks and Parksmap.
# The Green services/routes need to be active initially to guarantee a successful grading pipeline run.

# To be Implemented by Studentls

# Code to set up the parks production project. It will need a StatefulSet MongoDB, and two applications each (Blue/Green) for NationalParks, MLBParks and Parksmap.
# The Green services/routes need to be active initially to guarantee a successful grading pipeline run.

PROJECT_NAME=${GUID}-parks-prod
MONGO_TMPL=./Infrastructure/templates/mongors_setup_template.yaml
APPS_TMPL=./Infrastructure/templates/prod_setup_template.yaml

echo ">>> STEP #1 > SET MONGODB REPLICAS"
oc create -f $MONGO_TMPL -n $PROJECT_NAME

./Infrastructure/bin/podLivenessCheck.sh mongodb-0 $PROJECT_NAME
./Infrastructure/bin/podLivenessCheck.sh mongodb-1 $PROJECT_NAME
./Infrastructure/bin/podLivenessCheck.sh mongodb-2 $PROJECT_NAME

echo ">>> STEP #2 > SET APPS FOR PROD"

oc create -f $APPS_TMPL -n $PROJECT_NAME

echo ">>> STEP #3 > ADD VIEW PERMISSIONS"
oc policy add-role-to-group view system:serviceaccount:${GUID}-parks-prod -n ${GUID}-parks-dev
oc policy add-role-to-user view --serviceaccount=default -n $PROJECT_NAME

sleep 20
