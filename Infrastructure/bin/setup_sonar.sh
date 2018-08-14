#!/bin/bash
# Setup Sonarqube Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo ">> Setting up Sonarqube in project $GUID-sonarqube"

# Code to set up the SonarQube project.
# Ideally just calls a template
# oc new-app -f ../templates/sonarqube.yaml --param .....

# To be Implemented by Student
TEMPLATE=../templates/sonar_setup_template.yaml
PROJ_NAME=$GUID-sonarqube

oc create -f $TEMPLATE -n $PROJ_NAME

echo ">> Sonarqube liveness check"
sleep 50
../bin/podLivenessCheck.sh sonarqube ${PROJ_NAME}
