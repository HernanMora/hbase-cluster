FROM alpine:3.8

USER root

# Prerequisites
RUN apk add --no-cache openssh openssl openjdk8-jre rsync bash procps nss

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:$JAVA_HOME/bin

# Passwordless SSH
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

ADD config/ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

# unlock root
RUN passwd -u root

# Install Apche HBase
ENV HBASE_VER 1.3.1

RUN wget -O apache-hbase.tar.gz https://archive.apache.org/dist/hbase/$HBASE_VER/hbase-$HBASE_VER-bin.tar.gz && \
	tar xzvf apache-hbase.tar.gz -C /usr/local/ && rm apache-hbase.tar.gz

# Create a soft link to make future upgrade transparent
RUN ln -s /usr/local/hbase-$HBASE_VER /usr/local/hbase

ENV HBASE_HOME /usr/local/hbase
ENV PATH $PATH:$HBASE_HOME/bin
ENV HBASE_CONF_DIR $HBASE_HOME/conf

# Add default conf files of 1 master, 2 back server, 3 engionserver
ADD conf/hbase-site.xml $HBASE_HOME/conf
ADD conf/hbase-env.sh $HBASE_HOME/conf

RUN mkdir -p /var/hbase/pids; chmod -R 755 /var/hbase/pids;

WORKDIR $HBASE_HOME

ADD bootstrap.sh /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh"]