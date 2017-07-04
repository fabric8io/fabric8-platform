#!/usr/bin/env bash

LATEST="latest"
FABRIC8_VERSION=${1:-$LATEST}

if [ "$FABRIC8_VERSION" == "$LATEST" ] || [ "$FABRIC8_VERSION" == "" ] ; then
  FABRIC8_VERSION=$(curl -sL http://central.maven.org/maven2/io/fabric8/platform/packages/fabric8-system/maven-metadata.xml | grep '<latest' | cut -f2 -d">"|cut -f1 -d"<")
fi

TEMPLATE="packages/fabric8-system/target/classes/META-INF/fabric8/k8s-template.yml"

if [ "$FABRIC8_VERSION" == "local" ] ; then
  echo "Installing using a local build"
else
  echo "Installing fabric8 version: ${FABRIC8_VERSION}"
  TEMPLATE="http://central.maven.org/maven2/io/fabric8/platform/packages/fabric8-system/${FABRIC8_VERSION}/fabric8-system-${FABRIC8_VERSION}-k8s-template.yml"
fi
echo "Using the fabric8 template: ${TEMPLATE}"


# to disable ANSI color output
export TERM=dumb
PARTS=$(kubectl cluster-info | grep master |sed -e 's/.*http:\/\///g' -e 's/.*https:\/\///g')

IFS=':' read KUBERNETES_SERVICE_HOST KUBERNETES_SERVICE_PORT <<< "$PARTS"


#echo "enabling CORS in minikube"
#minishift openshift config set --patch '{"corsAllowedOrigins": [".*"]}'
#sleep 5

#oc login -u developer -p developer


APISERVER="${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}"
NODE_IP="${KUBERNETES_SERVICE_HOST}"
EXPOSER="Ingress"
DOMAIN=$(minikube ip).nip.io

echo "Connecting to the API Server at: https://${APISERVER}"
echo "Using Node IP ${NODE_IP} and Exposer strategy: ${EXPOSER}"
echo "Using github client ID: ${GITHUB_OAUTH_CLIENT_ID} and secret: ${GITHUB_OAUTH_CLIENT_SECRET}"


GITHUB_ID="${GITHUB_OAUTH_CLIENT_ID}"
GITHUB_SECRET="${GITHUB_OAUTH_CLIENT_SECRET}"

ROUTE_USE_PATH="true"
ROUTE_HOST="fabric8.${NODE_IP}.nic.io"

kubectl create namespace developer
kubectl create namespace fabric8
kubectl label node minikube fabric8.io/externalIP=true --overwrite

echo "Applying the fabric8 template ${TEMPLATE}"
oc process --local -f ${TEMPLATE} -p APISERVER_HOSTPORT=${APISERVER} -p NODE_IP=${NODE_IP} -p EXPOSER=${EXPOSER} -p GITHUB_OAUTH_CLIENT_SECRET=${GITHUB_SECRET} -p GITHUB_OAUTH_CLIENT_ID=${GITHUB_ID} -p DOMAIN=${DOMAIN} | kubectl apply -n fabric8 -f -

#oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:fabric8:init-tenant
#oc login -u developer -p developer

echo "Please wait while the pods all startup!"
echo
echo "To watch this happening you can type:"
echo "  kubectl get pod -l provider=fabric8 -w"
echo
echo "Or you can watch in the OpenShift console via:"
echo "  minikube dashboard"
echo
echo "When the pods are all running please click on the following URLs in your browser, then ADVANCED, then click the URL at the bottom"
echo "To approve the certs"
echo
echo "  https://`minikube service --url keycloak`/"
echo "  https://`minikube service --url wit`/api/status"
echo "  https://`minikube service --url forge`/forge/version"
echo "  https://`minikube service --url fabric8`/"
echo
echo
echo "Then you should be able the open the fabric8 console here:"
echo "  https://`minikube service --url fabric8`/"








