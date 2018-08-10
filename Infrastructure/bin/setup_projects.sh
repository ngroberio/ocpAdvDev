#!/bin/bash
# Create all Homework Projects
if [ "$#" -ne 2 ]; then
    echo "Usage:"
    echo "  $0 GUID USER"
    exit 1
fi

GUID=$1
USER=$2

echo ">>> CLEANUP ALL GUID $1 PROJECTS BEFORE START"
./Infrastructure/bin/cleanup.sh $1

sleep 30

echo ">>> CREATING ALL HOMEWORK PROJECTS FOR GUID=${GUID} AND USER=${USER}"
oc new-project ${GUID}-parks-prod --display-name="${GUID} AdvDev Homework Parks Production"
oc new-project ${GUID}-parks-dev  --display-name="${GUID} AdvDev Homework Parks Development"
oc new-project ${GUID}-nexus        --display-name="${GUID} AdvDev Homework Nexus"
oc new-project ${GUID}-sonarqube    --display-name="${GUID} AdvDev Homework Sonarqube"
oc new-project ${GUID}-jenkins    --display-name="${GUID} AdvDev Homework Jenkins"

sleep 10

echo ">>> ADD ADMIN POLICIES FOR USER=${USER}"
oc policy add-role-to-user admin ${USER} -n ${GUID}-parks-prod
oc policy add-role-to-user admin ${USER} -n ${GUID}-parks-dev
oc policy add-role-to-user admin ${USER} -n ${GUID}-jenkins
oc policy add-role-to-user admin ${USER} -n ${GUID}-nexus
oc policy add-role-to-user admin ${USER} -n ${GUID}-sonarqube

echo ">>> ANOTATE NAMESPACES FOR USER=${USER}"
oc annotate namespace ${GUID}-parks-prod openshift.io/requester=${USER} --overwrite
oc annotate namespace ${GUID}-parks-dev  openshift.io/requester=${USER} --overwrite
oc annotate namespace ${GUID}-jenkins    openshift.io/requester=${USER} --overwrite
oc annotate namespace ${GUID}-nexus      openshift.io/requester=${USER} --overwrite
oc annotate namespace ${GUID}-sonarqube  openshift.io/requester=${USER} --overwrite

sleep 20
