FROM phusion/baseimage:0.9.12

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

# Some Environment Variables
ENV DEBIAN_FRONTEND noninteractive

ENV DOWNLOAD_URL https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-6.3.15.tar.gz

# https://confluence.atlassian.com/display/STASH/Stash+home+directory
ENV JIRA_HOME /var/atlassian/application-data/jira

# Install Atlassian Stash to the following location
ENV JIRA_INSTALL_DIR /opt/atlassian/jira

RUN apt-get update
RUN apt-get install -y wget git default-jre

RUN sudo /bin/sh -c 'echo JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/jre/bin/java::") >> /etc/environment'
RUN sudo /bin/sh -c 'echo JIRA_HOME=${JIRA_HOME} >> /etc/environment'

RUN mkdir -p /opt/atlassian
RUN mkdir -p ${JIRA_HOME}

RUN wget -P /tmp ${DOWNLOAD_URL}
RUN tar zxf /tmp/atlassian-jira-6.3.15.tar.gz -C /tmp
RUN mv /tmp/atlassian-jira-6.3.15-standalone /tmp/jira
RUN mv /tmp/jira /opt/atlassian/

RUN wget -P /tmp http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.34.tar.gz
RUN tar zxf /tmp/mysql-connector-java-5.1.34.tar.gz -C /tmp
RUN mv /tmp/mysql-connector-java-5.1.34/mysql-connector-java-5.1.34-bin.jar ${JIRA_INSTALL_DIR}/lib/

RUN mkdir /etc/service/jira
ADD runit/jira.sh /etc/service/jira/run
RUN chmod +x /etc/service/jira/run

EXPOSE 8080

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
