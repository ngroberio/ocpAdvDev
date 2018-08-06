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
TMPL=./Infrastructure/templates/sonar.yaml
PROJ=$GUID-sonarqube
# PROJ=ngroberio-test
oc create -f $TMPL -n $PROJ

echo ">> Sonarqube liveness check"
./Infrastructure/bin/podLivenessCheck.sh sonarqube ${PROJ}
