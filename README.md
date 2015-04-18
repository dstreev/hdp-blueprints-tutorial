# Cluster Building via Blueprints.

## Reset your cluster.

This script is meant to run from a pdsh host configured with a host group to apply all these settings to.  Modify the [Data and Log Dirs](./strip_hdp/data_log_dirs.txt) text file to loop through all the directories to delete, post yum erase.  Modify the [Yum Packages](./strip_hdp/yum_packages.txt) text file to loop through all the HDP packages to remove.

## Cluster Buildout via Blueprint

### Assumptions BEFORE attempting Blueprint Installation.

- All the cluster [pre-requisites](http://docs.hortonworks.com/HDPDocuments/Ambari-2.0.0.0/Ambari_Doc_Suite/index.html#Item2) are complete.
- The database you'll use for Ambari, Hive, Oozie and Ranger has been configured for this environment.
    - Create the databases for Ambari, Hive, Ranger and Oozie.
    - Create the databases user (AND HOST combinations for MySql) with rights to the appropriate database.

## Home-HA Cluster

This is a 7 node cluster (2 masters, 5 Workers).  1 Worker Station supports the third ZooKeeper and Journal Nodes.  The other 4 Workers split roles with 2 Storm Supervisors and 2 Region Servers.

Considerable post Blueprint "Extraction" edits were applied to the Blueprint to get it to work.  See my [notes](./home-ha/README.md) for details.

[HOME-HA](./home-ha)

