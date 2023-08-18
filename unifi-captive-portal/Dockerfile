FROM debian:bullseye

MAINTAINER MTF <maulusck at pm dot me>
# Dockerfile to build a working Unifi captive controller.
#
# About the network: the container has to expose many ports, this may or may not
# fuck up things with rootless configuration (which is strongly suggested, since this
# is running on Java 8), so you either run it with --network host or, if you feel like it,
# run the container with the ./run.sh script, which has the preconfigured list of ports needed.
#
# Also, you will need to set the unprivileged ports minimum to 443 via sysctl or to set up some kind of proxy
# to run the 443 service on an unprivileged port (8443 is busy! another one) and proxy 443 to that

# set up timezone
ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true
RUN ln -sfv /usr/share/zoneinfo/Europe/Rome /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

# set up base system
RUN apt update && apt full-upgrade -y && apt autoremove -y && apt install -y \
		htop bmon tmux iotop curl wget procps ca-certificates gnupg gnupg2 ca-certificates apt-transport-https

# install software
COPY scripts /scripts
RUN chmod 755 /scripts/*.sh && cp -v /scripts/start-daemon.sh /usr/local/bin/start-daemon

# Java 8
RUN /scripts/install-java8.sh

# MongoDB 3.6
RUN /scripts/install-mongo36.sh

# Unifi
RUN /scripts/install-unifi.sh

# sync updates and cleanup
RUN apt update && apt full-upgrade -y && apt autoremove && apt clean && apt autoclean && rm -rf rm -rf /var/lib/apt/lists/* && rm -rfv /scripts

# expose ports
# TCP
EXPOSE 443/tcp
EXPOSE 6789/tcp
EXPOSE 8080/tcp
EXPOSE 8443/tcp
EXPOSE 27117/tcp
# UDP
EXPOSE 1900/udp
EXPOSE 3478/udp
EXPOSE 5514/udp
EXPOSE 5656-5699/udp
EXPOSE 10001/udp

# start
ENTRYPOINT [ "/usr/local/bin/start-daemon" ]
