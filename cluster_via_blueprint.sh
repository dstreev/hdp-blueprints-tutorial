#

cd `dirname $0`

# Which Cluster?  <sub-directory> that has the cluster details.
CLUSTER_REF=$1

cd ${CLUSTER_REF}

# Change as needed for your target Ambari Server
AMBARI_HOST=http://m1.hdp.local:8080
AMBARI_ADMIN_USER=admin
AMBARI_ADMIN_PASSWORD=admin

# Check that the Hosts have registered.
echo "Checking the Registered Hosts"
API_REF=/api/v1/hosts
curl -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -H 'X-Requested-By: ambari' -X GET ${AMBARI_HOST}${API_REF}

# Get the current Repo Setting and Setting it to Local Repos.
echo "Setting HDP Repos"
API_REF=/api/v1/stacks/HDP/versions/2.2/operating_systems/redhat6/repositories/HDP-2.2
curl -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -H 'X-Requested-By: ambari' -X PUT -d @repos/HDP-REPO-BODY.json ${AMBARI_HOST}${API_REF}
curl -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -H 'X-Requested-By: ambari' -X GET ${AMBARI_HOST}${API_REF}

echo "Setting HDP-UTIL Repos"
API_REF=/api/v1/stacks/HDP/versions/2.2/operating_systems/redhat6/repositories/HDP-UTILS-1.1.0.20
curl -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -H 'X-Requested-By: ambari' -X PUT -d @repos/HDP-UTIL-REPO-BODY.json ${AMBARI_HOST}${API_REF}
curl -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -H 'X-Requested-By: ambari' -X GET ${AMBARI_HOST}${API_REF}


# Post the Template to Ambari.
echo "Posting Blueprint to Ambari"
API_REF=/api/v1/blueprints/${CLUSTER_REF}
curl -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -H 'X-Requested-By: ambari' -X POST -d @${CLUSTER_REF}-blueprint.json ${AMBARI_HOST}${API_REF}

echo "Posting Template, this will buildout the cluster"
API_REF=/api/v1/clusters/${CLUSTER_REF}
curl -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -H 'X-Requested-By: ambari' -X POST -d @${CLUSTER_REF}-template.json ${AMBARI_HOST}${API_REF}


