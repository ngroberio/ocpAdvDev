#!/bin/bash
# Create all Homework Projects
if [ "$#" -ne 2 ]; then
    echo "Usage:"
    echo "  $0 GUID USER"
    exit 1
fi

GUID=$1
USER=$2

echo ">>> ADD ADMIN POLICIES FOR GPTE"
oc policy add-role-to-user admin system:serviceaccount:gpte-jenkins:jenkins -n ${GUID}-parks-prod
oc policy add-role-to-user admin system:serviceaccount:gpte-jenkins:jenkins -n ${GUID}-parks-dev
oc policy add-role-to-user admin system:serviceaccount:gpte-jenkins:jenkins -n ${GUID}-jenkins
oc policy add-role-to-user admin system:serviceaccount:gpte-jenkins:jenkins -n ${GUID}-nexus
oc policy add-role-to-user admin system:serviceaccount:gpte-jenkins:jenkins -n ${GUID}-sonarqube

echo ">>> ANOTATE NAMESPACES FOR GPTE"
oc annotate namespace ${GUID}-parks-prod openshift.io/requester=system:serviceaccount:gpte-jenkins:jenkins --overwrite
oc annotate namespace ${GUID}-parks-dev  openshift.io/requester=system:serviceaccount:gpte-jenkins:jenkins --overwrite
oc annotate namespace ${GUID}-jenkins    openshift.io/requester=system:serviceaccount:gpte-jenkins:jenkins --overwrite
oc annotate namespace ${GUID}-nexus      openshift.io/requester=system:serviceaccount:gpte-jenkins:jenkins --overwrite
oc annotate namespace ${GUID}-sonarqube  openshift.io/requester=system:serviceaccount:gpte-jenkins:jenkins --overwrite

echo "CleanUp all Homework Projects for GUID=$GUID and USER=${USER}"
oc delete project $GUID-nexus
oc delete project $GUID-sonarqube
oc delete project $GUID-jenkins
oc delete project $GUID-parks-dev
oc delete project $GUID-parks-prod
sleep 50

echo "Creating all Homework Projects for GUID=${GUID} and USER=${USER}"
oc new-project ${GUID}-parks-prod --display-name="${GUID} AdvDev Homework Parks Production"
oc new-project ${GUID}-parks-dev  --display-name="${GUID} AdvDev Homework Parks Development"
oc new-project ${GUID}-nexus        --display-name="${GUID} AdvDev Homework Nexus"
oc new-project ${GUID}-sonarqube    --display-name="${GUID} AdvDev Homework Sonarqube"
oc new-project ${GUID}-jenkins    --display-name="${GUID} AdvDev Homework Jenkins"
oc project $GUID-parks-dev

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
