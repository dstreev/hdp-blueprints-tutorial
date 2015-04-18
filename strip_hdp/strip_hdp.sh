# Clean sweep.  Reset / Prep for Cluster Rebuild.

cd `dirname $0`

# Warning: This is a destructive process at some point because it will remove data directories and content.

PDSH_GROUP=nuc

# Directories to remove

CFG_DIRS=etc_dir.txt
YUM_PACKAGES=yum_packages.txt
DATA_LOG_DIRS=data_log_dirs.txt

pdcp -g ${PDSH_GROUP} ${CFG_DIRS} /tmp
pdcp -g ${PDSH_GROUP} ${YUM_PACKAGES} /tmp
pdcp -g ${PDSH_GROUP} ${DATA_LOG_DIRS} /tmp

pdsh -g ${PDSH_GROUP} 'for i in `cat /tmp/yum_packages.txt`;do yum -y erase "${i}";done'

pdsh -g ${PDSH_GROUP} 'for i in `cat /tmp/etc_dir.txt`;do rm -rf ${i};done'

pdsh -g ${PDSH_GROUP} 'for i in `cat /tmp/data_log_dirs.txt`;do rm -rf ${i};done'

pdsh -g ${PDSH_GROUP} 'yum clean all'