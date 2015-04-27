Repositories Updates to Ambari to Support Local Repos for BluePrint Installation:

## Pre-requisites

- I recommend using an existing cluster to build your blueprint from.  Get a cluster setup just the way like, then using the API, extract a blueprint. [Ambari Blueprints Documentation](https://cwiki.apache.org/confluence/display/AMBARI/Blueprints#Blueprints-BlueprintUsageOverview)
- Before you can use the templates, you'll need to install the *Ambari Server and Agents* on the hosts in the cluster.  The agents need to be manually registered with the server.  Do this by simply configuring the ambari-agent.ini with the Ambari-Server's hostname and starting them.  Use the Ambari Server REST API to ensure the hosts have registered.
    - `-GET http://m1.hdp.local:8080/api/v1/hosts

## More things to know before you start.

The Blueprint installation will fail if ALL of your pre-requisites aren't aligned.

- Database users and passwords should be aligned with your blueprint.  Especially for Ranger Admin, which during installation, needs 'root' access to the database to create the user databases and accounts.

#### PATCHES
I had to add: `"db_root_password" : "hadoop",` to the [Blueprint](../HOME/home-ha-blueprint.json).  This was not inserted during the extraction of the Blueprint from the original cluster.
-There JDBC URL for the Metastore doesn't resolve to a HOST.  Leaves the TEMPLATE Parameter in place. IE: `"javax.jdo.option.ConnectionURL" : "jdbc:mysql://%HOSTGROUP::host_group_m1%/hive_db?createDatabaseIfNotExist=true"`
- hive-site Added: `"javax.jdo.option.ConnectionPassword" : "hive"`
- The blueprint extract doesn't build the correct `"hive.metastore.uris"` when multiple metastores exist in original cluster.
- Seems to be a bit of confusion about how to use parameters like: `%HOSTGROUP::host_group_m1%` . Some times the values are resolved to a single host, while other aren't resolved.  With the current structures, I don't see how multiple Host values are resolved, when the only possible solution is a Host Group.  Host Groups CAN contain more than one host.  BUT, maybe they are treating MASTER HOST GROUPS as only having a SINGLE HOST.
- Blueprint extract for Oozie doesn't honor a MySQL instance.  Looks like it's pulling in a Derby reference.  Looking at the Blueprint extract, the `"oozie.service.JPAService.jdbc.url"` is missing. 
- Oozie Blueprint extract missing jdbc password:           `"oozie.service.JPAService.jdbc.password" : "oozie"`
- ranger-hive-plugin-properties - It's not pulling the target systems values for: `XAAUDIT.HDFS.DESTINATION_DIRECTORY,XAAUDIT.HDFS.LOCAL_ARCHIVE_DIRECTORY,XAAUDIT.HDFS.LOCAL_BUFFER_DIRECTORY`.  Instead it looks like it's pulling the default values.
- I didn't install the Ranger plugin for HBase, so I can't verify, but would suspect the same issue as the hive-plugin.
- Storm - The ZooKeeper references built for storm are referencing the Storm Supervisors and not the ZooKeeper Servers.

## Tooling

I use GraphicalHTTPClient (Mac App Store) to interface with the Ambari REST API to make this easier for illustrative purposes.  The script [cluster_via_blueprint.sh](./../cluster_via_blueprint.sh) will do the same thing, but with CURL.

HOST_URL=http://m1.hdp.local:8080

HEADERS to Add:
Authentication: admin:admin
X-Requested-By: Ambari

## Repo update to use a local repo for the blueprint install.

Get a list of Repos for Centos6/RHEL6

`-GET http://m1.hdp.local:8080/api/v1/stacks/HDP/versions/2.2/operating_systems/redhat6/repositories

### HDP-2.2 Repo Adjustments
Check the details.
`-GET http://m1.hdp.local:8080/api/v1/stacks/HDP/versions/2.2/operating_systems/redhat6/repositories/HDP-2.2

Update the locations
`-PUT http://m1.hdp.local:8080/api/v1/stacks/HDP/versions/2.2/operating_systems/redhat6/repositories/HDP-2.2
[Message Body](repos/HDP-REPO-BODY.json)

### HDP-UTILS-1.1.0.20 Repo Adjustments
Check the details
`-GET http://m1.hdp.local:8080/api/v1/stacks/HDP/versions/2.2/operating_systems/redhat6/repositories/HDP-UTILS-1.1.0.20
Update the locations
`-PUT http://m1.hdp.local:8080/api/v1/stacks/HDP/versions/2.2/operating_systems/redhat6/repositories/HDP-UTILS-1.1.0.20
[Message Body](repos/HDP-UTIL-REPO-BODY.json)

####Validate the new repo locations.
`-GET http://m1.hdp.local:8080/api/v1/stacks/HDP/versions/2.2/operating_systems/redhat6/repositories

## Register your BluePrint
`-POST http://m1.hdp.local:8080/api/v1/blueprints/home-ha
*The Message body is the Blueprint you created or extracted from another cluster.*
I used this blue print extracted from another cluster and tuned for my purposes.
[Home HA Blueprint](../HOME/home-ha-blueprint.json)

## Verify the Hosts have been registered in Ambari (via the manually installed agents)

`-GET http://m1.hdp.local:8080/api/v1/hosts

## Cluster Creation
Now create the cluster (My cluster name is HOME)

* NOTE: The "name" in the template (message body) needs to match the name of the blueprint you registered above.*

`-POST http://m1.hdp.local:8080/api/v1/clusters/HOME
*The message body is the Environment Template that associates fqdn nodes to a Blueprint Role*
I used this environment template to build my cluster, base on the Blueprint above.
[Home HA Environment Template](../HOME/home-ha-template.json)


