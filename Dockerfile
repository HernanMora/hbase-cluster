FROM ubuntu:16.04

USER root

# Prerequisites
RUN apt-get update && apt-get install -y openssh-server openjdk-8-jdk wget vim \
    libsnappy1v5 libsnappy-dev iputils-ping telnetd net-tools whois

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
ENV PATH $PATH:$JAVA_HOME/bin

# Passwordless SSH
RUN ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -P "" ; \
    cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys

ADD conf/ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

# Add Hadoop 2.9.2 native lib
ENV LD_LIBRARY_PATH /usr/local/hadoop/lib/native
ADD hadoop /usr/local/hadoop

# Install Apche HBase
ENV HBASE_VER 2.2.3

RUN wget -O apache-hbase.tar.gz https://archive.apache.org/dist/hbase/$HBASE_VER/hbase-$HBASE_VER-bin.tar.gz && \
	tar xzvf apache-hbase.tar.gz -C /usr/local/ && rm apache-hbase.tar.gz

# Create a soft link to make future upgrade transparent
RUN ln -s /usr/local/hbase-$HBASE_VER /usr/local/hbase

ENV HBASE_HOME /usr/local/hbase
ENV PATH $PATH:$HBASE_HOME/bin
ENV HBASE_CONF_DIR $HBASE_HOME/conf

ADD conf/hbase-site.xml $HBASE_HOME/conf
ADD conf/hbase-env.sh $HBASE_HOME/conf
ADD conf/hdfs-site.xml $HBASE_HOME/conf

RUN mkdir -p /var/hbase/pids; chmod -R 755 /var/hbase/pids;

RUN ulimit -n 8192

WORKDIR $HBASE_HOME

ADD bootstrap.sh /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh"]