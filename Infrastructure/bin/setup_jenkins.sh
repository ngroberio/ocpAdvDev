#!/bin/bash
# Setup Jenkins Project
if [ "$#" -ne 3 ]; then
    echo "Usage:"
    echo "  $0 GUID REPO CLUSTER"
    echo "  Example: $0 wkha https://github.com/wkulhanek/ParksMap na39.openshift.opentlc.com"
    exit 1
fi

GUID=$1
REPO=$2
CLUSTER=$3
echo "Setting up Jenkins in project ${GUID}-jenkins from Git Repo ${REPO} for Cluster ${CLUSTER}"

# Code to set up the Jenkins project to execute the
# three pipelines.
# This will need to also build the custom Maven Slave Pod
# Image to be used in the pipelines.
# Finally the script needs to create three OpenShift Build
# Configurations in the Jenkins Project to build the
# three micro services. Expected name of the build configs:
# * mlbparks-pipeline
# * nationalparks-pipeline
# * parksmap-pipeline
# The build configurations need to have two environment variables to be passed to the Pipeline:
# * GUID: the GUID used in all the projects
# * CLUSTER: the base url of the cluster used (e.g. na39.openshift.opentlc.com)

# To be Implemented by Student
PROJECT_NAME=${GUID}-jenkins
SKOPEO_DOCKERFILE=./Infrastructure/skopeo/Dockerfile
JENKINS=./Infrastructure/templates/jenkins_setup_template.yaml

echo ">>> STEP #2 -- CREATE IMAGE FOR SKOPEO"

cat $SKOPEO_DOCKERFILE |  oc new-build --strategy=docker --to=jenkins-slave-appdev --name=skopeo -n ${PROJECT_NAME} -D -
echo ">> CONFIG CREATED. WAIT FOR IMAGE BUILD"
sleep 10
oc logs -f bc/skopeo -n ${PROJECT_NAME}

echo ">>> STEP #3 -- PIPELINES CREATION"

function newPipelineBuild {
    echo ">>> SETUP PIPELINES: ${1} -- DIR: ${2}"
    oc new-build -e GUID=${GUID} -e CLUSTER=${CLUSTER} --strategy=pipeline ${REPO} --context-dir=${2} -n ${PROJECT_NAME} --name=${1}
    oc env bc/${1} GUID=$GUID CLUSTER=$CLUSTER -n ${PROJECT_NAME}
}
newPipelineBuild mlbparks-pipeline MLBParks
newPipelineBuild nationalparks-pipeline Nationalparks
newPipelineBuild parksmap-pipeline ParksMap

echo ">>> STEP #4 -- +ADD PERMISSIONS TO JENKINS"
oc policy add-role-to-user edit system:serviceaccount:${GUID}-jenkins:default -n ${GUID}-parks-dev
oc policy add-role-to-user edit system:serviceaccount:${GUID}-jenkins:default -n ${GUID}-parks-prod
oc policy add-role-to-user edit system:serviceaccount:${GUID}-jenkins:jenkins -n ${GUID}-parks-dev
oc policy add-role-to-user edit system:serviceaccount:${GUID}-jenkins:jenkins -n ${GUID}-parks-prod

echo ">>> STEP #5 -- JENKINS LIVENESS CHECK FOR PROJECT_NAME: ${PROJECT_NAME}"
oc set resources dc/jenkins --requests=cpu=2,memory=2Gi --limits=cpu=3,memory=3Gi -n ${PROJECT_NAME}
./Infrastructure/bin/podLivenessCheck.sh jenkins ${PROJECT_NAME}
oc cancel-build -n $PROJECT_NAME bc/mlbparks-pipeline
oc cancel-build -n $PROJECT_NAME bc/nationalparks-pipeline
oc cancel-build -n $PROJECT_NAME bc/parksmap-pipeline

sleep 20
