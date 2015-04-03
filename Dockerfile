FROM ubuntu:14.04.1

MAINTAINER Maksym Bilenko <sath891@gmail.com>

ADD chkconfig /sbin/chkconfig
ADD init.ora /
ADD initXETemp.ora /
ADD oracle-xe_11.2.0-1.0_amd64.debaa /
ADD oracle-xe_11.2.0-1.0_amd64.debab /
ADD oracle-xe_11.2.0-1.0_amd64.debac /
# ADD oracle-xe_11.2.0-1.0_amd64.deb /
RUN cat /oracle-xe_11.2.0-1.0_amd64.deba* > /oracle-xe_11.2.0-1.0_amd64.deb

# Prepare to install Oracle
RUN apt-get update && apt-get install -y libaio1 net-tools bc
RUN ln -s /usr/bin/awk /bin/awk
RUN mkdir /var/lock/subsys
RUN chmod 755 /sbin/chkconfig

# Install Oracle
RUN dpkg --install /oracle-xe_11.2.0-1.0_amd64.deb

RUN mv /init.ora /u01/app/oracle/product/11.2.0/xe/config/scripts
RUN mv /initXETemp.ora /u01/app/oracle/product/11.2.0/xe/config/scripts

RUN printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure

RUN echo 'export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe' >> /etc/bash.bashrc
RUN echo 'export PATH=$ORACLE_HOME/bin:$PATH' >> /etc/bash.bashrc
RUN echo 'export ORACLE_SID=XE' >> /etc/bash.bashrc

# Remove installation files
RUN rm /oracle-xe_11.2.0-1.0_amd64.deb*
RUN apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Move initial database to provide database data files be reuseable
RUN mv /u01/app/oracle/oradata /u01/app/oracle/oradata_initial
RUN mkdir /u01/app/oracle/oradata && chown oracle:dba /u01/app/oracle/oradata

ADD entrypoint.sh /

EXPOSE 22
EXPOSE 1521
EXPOSE 8080
VOLUME ["/u01/app/oracle/oradata"]

ENTRYPOINT ["/entrypoint.sh"]
