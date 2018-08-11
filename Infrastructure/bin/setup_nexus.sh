#!/bin/bash
# Setup Nexus Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Nexus in project $GUID-nexus"

# Code to set up the Nexus. It will need to
# * Create Nexus
# * Set the right options for the Nexus Deployment Config
# * Load Nexus with the right repos
# * Configure Nexus as a docker registry
# Hint: Make sure to wait until Nexus if fully up and running
#       before configuring nexus with repositories.
#       You could use the following code:
# while : ; do
#   echo "Checking if Nexus is Ready..."
#   oc get pod -n ${GUID}-nexus|grep '\-2\-'|grep -v deploy|grep "1/1"
#   [[ "$?" == "1" ]] || break
#   echo "...no. Sleeping 10 seconds."
#   sleep 10
# done

# Ideally just calls a template
# oc new-app -f ../templates/nexus.yaml --param .....

# To be Implemented by Student
TEMPLATE=./Infrastructure/templates/nexus_setup_template.yaml
PROJ_NAME=$GUID-nexus

echo ">> STETP 1 >>>> Setting up Nexus"
oc process -f $TEMPLATE | oc create -n $PROJ_NAME -f -

./Infrastructure/bin/nexusLivenessCheck.sh ${PROJ_NAME}

echo ">> STEP 2 >>>> Configuring Nexus"
ROUTE=$(oc get route nexus3 --template='{{ .spec.host }}' -n ${PROJ_NAME})
echo ">>> Route ${ROUTE}"
sleep 70
./Infrastructure/bin/cfg_nexus.sh admin admin123 http://${ROUTE}
