#!/bin/bash

# set region server hostname
sed -i -e "s|HOSTNAME|$(hostname)|g" /usr/local/hbase/conf/hbase-site.xml 
sed -i -e "s|ZOOKEEPER_QUORUM|$ZOOKEEPER_QUORUM|g" /usr/local/hbase/conf/hbase-site.xml 
sed -i -e "s|HADOOP_MASTER|$HADOOP_MASTER|g" /usr/local/hbase/conf/hbase-site.xml 
sed -i -e "s|HBASE_MASTER|$HBASE_MASTER|g" /usr/local/hbase/conf/hbase-site.xml 

REGION_SERVERS_CONFIG="$HBASE_HOME/conf/regionservers"
if [ ! -z "$REGIONSERVERS" ]; then
    echo $REGIONSERVERS | tr , '\n' > $REGION_SERVERS_CONFIG
fi

BACKUP_MASTERS_CONFIG="$HBASE_HOME/conf/backup-masters"
if [ ! -z "$MASTER_BACKUPS" ]  && [ ! -f "$BACKUP_MASTERS_CONFIG" ]; then
    CONFIG="$HBASE_HOME/conf/backup-masters"
    echo $MASTER_BACKUPS | tr , '\n' > $BACKUP_MASTERS_CONFIG
fi

service ssh start

while true; do sleep 1000; done