# Should be run on the MySQL Server as the root db user.

# Adjust values to match your cluster configuration.
MYSQL_ROOT_USER=root
MYSQL_ROOT_PASSWORD=

HIVE_DB=hive
HIVE_USER=hive
HIVE_USER_PASSWORD=hive

AMBARI_DB=ambari
AMBARI_USER=ambari
AMBARI_USER_PASSWORD=ambari

OOZIE_DB=oozie
OOZIE_USER=oozie
OOZIE_USER_PASSWORD=oozie

RANGER_DB=ranger
RANGER_USER=ranger
RANGER_USER_PASSWORD=ranger

RANGER_AUDIT_DB=ranger_audit
RANGER_AUDIT_USER=ranger_logger
RANGER_AUDIT_USER_PASSWORD=ranger

# ALL HOSTS SHOULD contain localhost
AMBARI_HOSTS="localhost m1.hdp.local"
HIVE_HOSTS="localhost m1.hdp.local m2.hdp.local"
RANGER_HOSTS="localhost m1.hdp.local m2.hdp.local d1.hdp.local d2.hdp.local d3.hdp.local d4.hdp.local d5.hdp.local"
OOZIE_HOSTS="localhost m2.hdp.local"

#--user=user_name --password=your_password db_name
if [ "${MYSQL_ROOT_PASSWORD}" == "" ]; then
    CONN="-u ${MYSQL_ROOT_USER}"
else
    CONN="--user=${MYSQL_ROOT_USER} --password=${MYSQL_ROOT_PASSWORD}"
fi

if [ "$1" == "drop" ]; then
  for i in $(eval echo ${AMBARI_HOSTS}); do
    echo "Drop Ambari User from: ${i}"
    eval "${MYSQL} ${CONN} -e 'DROP USER ''${AMBARI_USER}''@''${i}'''"
  done
  for i in $(eval echo ${HIVE_HOSTS}); do
    echo "Drop Hive User from: ${i}"
    eval "${MYSQL} ${CONN} -e 'DROP USER ''${HIVE_USER}''@''${i}'''"
  done
  for i in $(eval echo ${OOZIE_HOSTS}); do
    echo "Drop Oozie User from: ${i}"
    eval "${MYSQL} ${CONN} -e 'DROP USER ''${OOZIE_USER}''@''${i}'''"
  done
  for i in $(eval echo ${RANGER_HOSTS}); do
    echo "Drop Ranger users from: ${i}"
    eval "${MYSQL} ${CONN} -e 'DROP USER ''${RANGER_USER}''@''${i}'''"
    eval "${MYSQL} ${CONN} -e 'DROP USER ''${RANGER_AUDIT_USER}''@''${i}'''"
  done
  exit
fi

MYSQL=mysql

# Ambari DB
eval "${MYSQL} ${CONN} -e 'CREATE DATABASE IF NOT EXISTS ${AMBARI_DB}'"
for i in $(eval echo ${AMBARI_HOSTS}); do
echo "Ambari Create: ${i}"
eval "${MYSQL} ${CONN} -e 'CREATE USER ''${AMBARI_USER}''@''${i}'' IDENTIFIED BY ''${AMBARI_USER_PASSWORD}'''"
echo "Ambari Grant: ${i}"
eval "${MYSQL} ${CONN} -e 'GRANT ALL PRIVILEGES ON ${AMBARI_DB}.* TO ''${AMBARI_USER}''@''${i}'''"
done

# Hive DB
eval "${MYSQL} ${CONN} -e 'CREATE DATABASE IF NOT EXISTS ${HIVE_DB}'"
for i in $(eval echo ${HIVE_HOSTS}); do
echo "Hive Host: ${i}"
eval "${MYSQL} ${CONN} -e 'CREATE USER ''${HIVE_USER}''@''${i}'' IDENTIFIED BY ''${HIVE_USER_PASSWORD}'''"
eval "${MYSQL} ${CONN} -e 'GRANT ALL PRIVILEGES ON ${HIVE_DB}.* TO ''${HIVE_USER}''@''${i}'''"
done

# Oozie DB
eval "${MYSQL} ${CONN} -e 'CREATE DATABASE IF NOT EXISTS ${OOZIE_DB}'"
for i in $(eval echo ${OOZIE_HOSTS}); do
echo "OOZIE Host: ${i}"
eval "${MYSQL} ${CONN} -e 'CREATE USER ''${OOZIE_USER}''@''${i}'' IDENTIFIED BY ''${OOZIE_USER_PASSWORD}'''"
eval "${MYSQL} ${CONN} -e 'GRANT ALL PRIVILEGES ON ${OOZIE_DB}.* TO ''${OOZIE_USER}''@''${i}'''"
done

# Ranger DB
eval "${MYSQL}" "${CONN} -e 'CREATE DATABASE IF NOT EXISTS ${RANGER_DB}'"
for i in $(eval echo ${RANGER_HOSTS}); do
echo "RANGER Host: ${i}"
eval "${MYSQL} ${CONN} -e 'CREATE USER ''${RANGER_USER}''@''${i}'' IDENTIFIED BY ''${RANGER_USER_PASSWORD}'''"
eval "${MYSQL} ${CONN} -e 'GRANT ALL PRIVILEGES ON ${RANGER_DB}.* TO ''${RANGER_USER}''@''${i}'''"
done

# Ranger Audit DB
eval "${MYSQL}" "${CONN} -e 'CREATE DATABASE IF NOT EXISTS ${RANGER_AUDIT_DB}'"
for i in $(eval echo ${RANGER_HOSTS}); do
echo "RANGER_AUDIT Host: ${i}"
eval "${MYSQL} ${CONN} -e 'CREATE USER ''${RANGER_AUDIT_USER}''@''${i}'' IDENTIFIED BY ''${RANGER_AUDIT_USER_PASSWORD}'''"
eval "${MYSQL} ${CONN} -e 'GRANT ALL PRIVILEGES ON ${RANGER_AUDIT_DB}.* TO ''${RANGER_AUDIT_USER}''@''${i}'''"
done

