#!/usr/bin/env bash

echo "enabling CORS in minishift"
minishift openshift config set --patch '{"corsAllowedOrigins": [".*"]}'
sleep 5

oc login -u developer -p developer

oc new-project developer
oc new-project fabric8


APISERVER=$(oc version | grep Server | sed -e 's/.*http:\/\///g' -e 's/.*https:\/\///g')
FABRIC8_VERSION=$(curl -sL http://central.maven.org/maven2/io/fabric8/online/packages/fabric8-online-team/maven-metadata.xml | grep '<latest' | cut -f2 -d">"|cut -f1 -d"<")

echo "Connecting to the API Server at: https://${APISERVER}"
echo "Installing fabric8 version ${FABRIC8_VERSION}"

# TODO use real released template!!!
TEMPLATE="packages/fabric8-platform/target/classes/META-INF/fabric8/openshift.yml"

echo "Applying the fabric8 template ${TEMPLATE}"
oc process -f ${TEMPLATE} -p APISERVER_HOSTPORT=${APISERVER} | oc apply -f -

echo "Now adding the OAuthClient and cluster-admin role to the init-tenant service account"
oc login -u system:admin
cat <<EOF | oc create -f -
kind: OAuthClient
apiVersion: v1
metadata:
  name: fabric8-online-platform
secret: fabric8
redirectURIs:
- "https://$(oc get route keycloak -o jsonpath="{.spec.host}")/auth/realms/fabric8/broker/openshift-v3/endpoint"
grantMethod: prompt
EOF
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:fabric8:init-tenant
oc login -u developer -p developer

echo "Please wait while the pods all startup!"
echo
echo "To watch this happening you can type:"
echo "  oc get pod -l provider=fabric8 -w"
echo
echo "Or you can watch in the OpenShift console via:"
echo "  minishift console"
echo
echo "When the pods are all running please click on the following URLs in your browser, then ADVANCED, then click the URL at the bottom"
echo "To approve the certs"
echo
echo "  https://`oc get route fabric8 --template={{.spec.host}}`/"
echo "  https://`oc get route keycloak --template={{.spec.host}}`/"
echo "  https://`oc get route wit --template={{.spec.host}}`/api/status"
echo "  https://`oc get route forge --template={{.spec.host}}`/forge/version"
echo
echo
echo "Then you should be able the open the fabric8 console here:"
echo "  https://`oc get route fabric8 --template={{.spec.host}}`/"








