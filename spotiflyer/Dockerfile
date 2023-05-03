#FROM debian:bullseye
FROM debian:latest

# set up base system
ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true
RUN apt update && apt full-upgrade -y && apt install -y wget curl git tigervnc-standalone-server tigervnc-xorg-extension jq git python3 procps ffmpeg python3-numpy

# get package
ARG AUTHOR=Shabinder
ARG REPO=SpotiFlyer
RUN wget -q $(curl -s https://api.github.com/repos/$AUTHOR/$REPO/releases/latest | jq -r ".assets[].browser_download_url" | grep deb)

# install package - fix for xdg-desktop-menu
RUN	mkdir /usr/share/desktop-directories && \
	apt install -y ./$(curl -s https://api.github.com/repos/$AUTHOR/$REPO/releases/latest | jq -r ".assets[].name" | grep deb) && \
	ln -sfv /opt/spotiflyer/bin/SpotiFlyer /usr/local/bin/SpotiFlyer

# setup VNC
ARG VNC_PASSWD=test
RUN	useradd -s /bin/sh -m -d /home/spotiflyer spotiflyer && \
	mkdir -p /home/spotiflyer/.vnc && \
	echo $VNC_PASSWD | vncpasswd -f > /home/spotiflyer/.vnc/passwd && \
	chmod 400 /home/spotiflyer/.vnc/passwd  && \
	echo "xsetroot -solid grey && exec /usr/local/bin/SpotiFlyer" > /home/spotiflyer/.vnc/xstartup && \
	chmod 700 /home/spotiflyer/.vnc/xstartup

# setup noVNC
RUN	git clone https://github.com/novnc/noVNC /usr/local/bin/noVNC && \
	git clone https://github.com/novnc/websockify /usr/local/bin/noVNC/utils/websockify && \
        ln -sfv /usr/local/bin/noVNC/vnc.html /usr/local/bin/noVNC/index.html && \
	mkdir -p /home/spotiflyer/certs && \
        openssl req -new -x509 -days 3650 -nodes -out /home/spotiflyer/certs/self.pem -keyout /home/spotiflyer/certs/self.pem \
                -subj "/C=XX/ST=Nowhere/L=Nothing/O=None. /OU=Nothing Department/CN=localhost"
COPY scripts/novnc_start /usr/local/bin/novnc_start
RUN chmod 755 /usr/local/bin/novnc_start && chown root:spotiflyer /usr/local/bin/noVNC/utils && chmod 775 /usr/local/bin/noVNC/utils

# fix permissions
RUN chown -R spotiflyer:spotiflyer /home/spotiflyer

# open ports
EXPOSE 8443

# set up launcher
COPY scripts/spoti_start /usr/local/bin/spoti_start
RUN chmod 755 /usr/local/bin/spoti_start

# cleanup
RUN rm -rf /var/lib/apt/lists/* && rm -rf /scripts && rm -rf /usr/share/{icons,doc,man}

# start
ENTRYPOINT ["/usr/local/bin/spoti_start"]
