FROM ubuntu:14.04
MAINTAINER Fabio Filippi <fabiofilippi1618@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

# no Upstart or DBus
# https://github.com/dotcloud/docker/issues/1724#issuecomment-26294856
RUN apt-mark hold initscripts udev plymouth mountall
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends supervisor \
        openssh-server pwgen sudo vim-tiny \
        net-tools \
        software-properties-common \
        python-software-properties \
        maven \
        vim \
        git \
        subversion \
        ant \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        libreoffice firefox \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*
    
## UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

## JAVA INSTALLATION
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/webupd8team-java-trusty.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
RUN apt-get update && apt-get install -y --force-yes --no-install-recommends oracle-java8-installer && apt-get clean all

## JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#Install kepler
RUN mkdir -p /home/kepler/kepler.modules
RUN cd /home/kepler/kepler.modules/; svn co https://code.kepler-project.org/code/kepler/trunk/modules/build-area
RUN cd /home/kepler/kepler.modules/build-area; ant change-to -Dsuite=biokepler
RUN cd /home/kepler/kepler.modules/build-area; ant jar

ADD noVNC /noVNC/
ADD startup.sh /
ADD supervisord.conf /
EXPOSE 6080
EXPOSE 5900
EXPOSE 22
WORKDIR /
ENTRYPOINT ["/startup.sh"]
