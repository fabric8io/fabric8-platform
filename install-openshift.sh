#!/usr/bin/env bash

LATEST="latest"
FABRIC8_VERSION=${1:-$LATEST}

if [ "$FABRIC8_VERSION" == "$LATEST" ] || [ "$FABRIC8_VERSION" == "" ] ; then
  FABRIC8_VERSION=$(curl -sL http://central.maven.org/maven2/io/fabric8/platform/packages/fabric8-system/maven-metadata.xml | grep '<latest' | cut -f2 -d">"|cut -f1 -d"<")
fi

TEMPLATE="packages/fabric8-system/target/classes/META-INF/fabric8/openshift.yml"

if [ "$FABRIC8_VERSION" == "local" ] ; then
  echo "Installing using a local build"
else
  echo "Installing fabric8 version: ${FABRIC8_VERSION}"
  TEMPLATE="http://central.maven.org/maven2/io/fabric8/platform/packages/fabric8-system/${FABRIC8_VERSION}/fabric8-system-${FABRIC8_VERSION}-openshift.yml"
fi
echo "Using the fabric8 template: ${TEMPLATE}"


APISERVER=$(oc version | grep Server | sed -e 's/.*http:\/\///g' -e 's/.*https:\/\///g')
NODE_IP=$(echo "${APISERVER}" | sed -e 's/:.*//g')
#EXPOSER="NodePort"
EXPOSER="Route"

echo "Connecting to the API Server at: https://${APISERVER}"
echo "Using Node IP ${NODE_IP} and Exposer strategy: ${EXPOSER}"
echo "Using github client ID: ${GITHUB_OAUTH_CLIENT_ID} and secret: ${GITHUB_OAUTH_CLIENT_SECRET}"


GITHUB_ID="${GITHUB_OAUTH_CLIENT_ID}"
GITHUB_SECRET="${GITHUB_OAUTH_CLIENT_SECRET}"

echo "Applying the fabric8 template ${TEMPLATE}"
oc process -f ${TEMPLATE} -p APISERVER_HOSTPORT=${APISERVER} -p NODE_IP=${NODE_IP} -p EXPOSER=${EXPOSER} -p GITHUB_OAUTH_CLIENT_SECRET=${GITHUB_SECRET} -p GITHUB_OAUTH_CLIENT_ID=${GITHUB_ID} | oc apply -f -

echo "Now adding the OAuthClient and cluster-admin role to the init-tenant service account"
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
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:$(oc project -q):init-tenant

echo "Please wait while the pods all startup!"
echo
echo "To watch this happening you can type:"
echo "  oc get pod -l provider=fabric8 -w"
echo
echo "Or you can watch in the OpenShift console"
echo
echo "When the pods are all running please click on the following URLs in your browser, then ADVANCED, then click the URL at the bottom"
echo "To approve the certs"
echo
echo "  https://`oc get route keycloak --template={{.spec.host}}`/"
echo "  https://`oc get route wit --template={{.spec.host}}`/api/status"
echo "  https://`oc get route forge --template={{.spec.host}}`/forge/version"
echo "  https://`oc get route fabric8 --template={{.spec.host}}`/"
echo
echo
echo "Then you should be able the open the fabric8 console here:"
echo "  https://`oc get route fabric8 --template={{.spec.host}}`/"








