#!/bin/bash
#
#
# PARAMETERS => $1=Nexus UserID , $2=Nexus Password, $3=Nexus URL

nexusUser=$1
nexusPassword=$2
nexusUrl=$3

function setupNexus3Full() {

local repoId=npm
local rUrl=https://registry.npmjs.org/

echo ">>> ADD NEXUS3 NPM PROXY REPO REPO_ID:${repoId}, REPO_URL:${rUrl}, NEXUS_USER:${nexusUser}, NEXUS_PWD:${nexusPassword}, NEXUS_URL:${nexusUrl}"

read -r -d '' repJson << EOM
{
  "name": "$repoId",
  "type": "groovy",
  "content": "repository.createNpmProxy('$repoId','$rUrl')"
}
EOM

curl -v -H "Accept: application/json" -H "Content-Type: application/json" -d "$repJson" -u "$nexusUser:$nexusPassword" "${nexusUrl}/service/rest/v1/script/"
curl -v -X POST -H "Content-Type: text/plain" -u "$nexusUser:$nexusPassword" "${nexusUrl}/service/rest/v1/script/$repoId/run"

sleep 15

repoId=redhat-ga
rUrl=https://maven.repository.redhat.com/ga/

echo ">>> ADD NEXUS3 PROXY REPO REPO_ID:${repoId}, REPO_URL:${rUrl}, NEXUS_USER:${nexusUser}, NEXUS_PWD:${nexusPassword}, NEXUS_URL:${nexusUrl}"

  read -r -d '' repJson << EOM
{
  "name": "$repoId",
  "type": "groovy",
  "content": "repository.createMavenProxy('$repoId','$rUrl')"
}
EOM

curl -v -H "Accept: application/json" -H "Content-Type: application/json" -d "$repJson" -u "$nexusUser:$nexusPassword" "${nexusUrl}/service/rest/v1/script/"
curl -v -X POST -H "Content-Type: text/plain" -u "$nexusUser:$nexusPassword" "${nexusUrl}/service/rest/v1/script/$repoId/run"

sleep 15

repoId=releases

echo ">>> ADD NEXUS3 RELEASE REPO REPO_ID:${repoId}, NEXUS_USER:${nexusUser}, NEXUS_PWD:${nexusPassword}, NEXUS_URL:${nexusUrl}"

read -r -d '' repJson << EOM
{
  "name": "$repoId",
  "type": "groovy",
  "content": "import org.sonatype.nexus.blobstore.api.BlobStoreManager\nimport org.sonatype.nexus.repository.storage.WritePolicy\nimport org.sonatype.nexus.repository.maven.VersionPolicy\nimport org.sonatype.nexus.repository.maven.LayoutPolicy\nrepository.createMavenHosted('$repoId',BlobStoreManager.DEFAULT_BLOBSTORE_NAME, false, VersionPolicy.RELEASE, WritePolicy.ALLOW, LayoutPolicy.PERMISSIVE)"
}
EOM

curl -v -H "Accept: application/json" -H "Content-Type: application/json" -d "$repJson" -u "$nexusUser:$nexusPassword" "${nexusUrl}/service/rest/v1/script/"
curl -v -X POST -H "Content-Type: text/plain" -u "$nexusUser:$nexusPassword" "${nexusUrl}/service/rest/v1/script/$repoId/run"

sleep 15

repoIds=redhat-ga,maven-central,maven-releases,maven-snapshots
local grpId=maven-all-public

echo ">>> ADD NEXUS3 GROUP PROXY REPO REPOSITORY IDS:${repoIds}, GROUP ID:${grpId}, NEXUS USER:${nexusUser}, NEXUS PWD:${nexusPassword}, NEXUS URL:${nexusUrl}"

read -r -d '' repJson << EOM

{
  "name": "$grpId",
  "type": "groovy",
  "content": "repository.createMavenGroup('$grpId', '$repoIdS'.split(',').toList())"
}
EOM

curl -v -H "Accept: application/json" -H "Content-Type: application/json" -d "$repJson" -u "$nexusUser:$nexusPassword" "${nexusUrl}/service/rest/v1/script/"
curl -v -X POST -H "Content-Type: text/plain" -u "$nexusUser:$nexusPassword" "${nexusUrl}/service/rest/v1/script/$grpId/run"

sleep 15

repoId=docker
local repPort=5000

echo ">>> ADD NEXUS3 DOCKER REPO REPOSITORY ID:${repoId}, REPO PORT:${repPort}, NEXUS USER:${nexusUser}, NEXUS PWD:${nexusPassword}, NEXUS URL:${nexusUrl}"

read -r -d '' repJson << EOM
{
  "name": "$repoId",
  "type": "groovy",
  "content": "repository.createDockerHosted('$repoId',$repPort,null)"
}
EOM

curl -v -H "Accept: application/json" -H "Content-Type: application/json" -d "$repJson" -u "$nexusUser:$nexusPassword" "${nexusUrl}/service/rest/v1/script/"
curl -v -X POST -H "Content-Type: text/plain" -u "$nexusUser:$nexusPassword" "${nexusUrl}/service/rest/v1/script/$repoId/run"

}

# SETUP ALL NEXUS CONFIGURATION
setupNexus3Full
sleep 15
