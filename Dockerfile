FROM ubuntu
MAINTAINER tutrung.leo@gmail.com

RUN apt update && apt install -y openjdk-8-jdk openssh-server openssh-client 
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 0600 ~/.ssh/authorized_keys

RUN echo "root:123" | chpasswd
RUN echo "root   ALL=(ALL)       ALL" >> /etc/sudoers


ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
ENV PATH=$JAVA_HOME/bin:$PATH

RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz
RUN tar xzf hadoop-3.2.1.tar.gz
RUN mv hadoop-3.2.1 usr/local/hadoop

ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH=$HADOOP_HOME/sbin:$PATH

RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

ADD config/core-site.xml $HADOOP_CONF_DIR/core-site.xml
ADD config/hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml
ADD config/mapred-site.xml $HADOOP_CONF_DIR/mapred-site.xml
ADD config/yarn-site.xml $HADOOP_CONF_DIR/yarn-site.xml
ADD config/slaves $HADOOP_CONF_DIR/slaves
ADD config/start-dfs.sh $HADOOP_HOME/sbin
ADD config/stop-dfs.sh $HADOOP_HOME/sbin
ADD config/start-yarn.sh $HADOOP_HOME/sbin
ADD config/stop-yarn.sh $HADOOP_HOME/sbin

ARG FORMAT_NAMENODE_COMMAND
RUN $FORMAT_NAMENODE_COMMAND
RUN mkdir -p /run/sshd
RUN /usr/sbin/sshd
EXPOSE 22
