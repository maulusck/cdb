FROM localhost/debian-s6-init:latest
LABEL maintainer="Maulusck Fringueley (maulusck at pm dot me)"
LABEL creator="Dave Conroy (dave at tiredofit dot ca)"

### Set defaults
#ENV	ASTERISK_VERSION=17.9.4 \
ENV	ASTERISK_VERSION=18.15.0 \
	BCG729_VERSION=1.1.1 \
	DONGLE_VERSION=20200610 \
	G72X_CPUHOST=penryn \
	G72X_VERSION=0.1 \
	MONGODB_VERSION=4.2 \
	PHP_VERSION=7.4 \
	SPANDSP_VERSION=20180108 \
	RTP_START=18000 \
	RTP_FINISH=20000
# ASTERISK_VERSION=20.0.0 apparently is not supported by FreePBX yet!


### Pin libxml2 packages to Debian repositories
#RUN echo "Package: libxml2*" > /etc/apt/preferences.d/libxml2 && \
#echo "Pin: release o=Debian,n=buster" >> /etc/apt/preferences.d/libxml2 && \
#echo "Pin-Priority: 501" >> /etc/apt/preferences.d/libxml2 && \
#APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=TRUE && \
#\
### set up timezone
ARG	TIMEZONE="Europe/Rome"
ARG	DEBIAN_FRONTEND=noninteractive
ARG	DEBCONF_NONINTERACTIVE_SEEN=true
RUN	ln -sfv /usr/share/zoneinfo/$TIMEZONE /etc/localtime
RUN	dpkg-reconfigure --frontend noninteractive tzdata

### Install dependencies

# set up base system
RUN	apt update && apt full-upgrade -y && apt install -y gnupg curl wget sudo
  
## configure repos
RUN \

# nodejs
curl -sSL https://deb.nodesource.com/setup_18.x | bash - && \
# mongodb
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - && \
#echo "deb http://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list && \
export $(cat /etc/os-release | grep VERSION_CODENAME) && \
echo "deb http://repo.mongodb.org/apt/debian $VERSION_CODENAME/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list && \
# sync repos
apt update

### Install development dependencies
ARG	ASTERISK_BUILD_DEPS='\
	autoconf \
	automake \
	bison \
	binutils-dev \
	build-essential \
	doxygen \
	flex \
	graphviz \
	libasound2-dev \
	libbluetooth-dev \
	libc-client2007e-dev \
	libcfg-dev \
	libcodec2-dev \
	libcorosync-common-dev \
	libcpg-dev \
	libcurl4-openssl-dev \
	libedit-dev \
	libfftw3-dev \
	libgmime-3.0-dev \
	libgsm1-dev \
	libical-dev \
	libiksemel-dev \
	libjansson-dev \
	libldap2-dev \
	liblua5.2-dev \
	libmariadb-dev \
	libmp3lame-dev \
	libncurses5-dev \
	libneon27-dev \
	libnewt-dev \
	libogg-dev \
	libopus-dev \
	libosptk-dev \
	libpopt-dev \
	libradcli-dev \
	libresample1-dev \
	libsndfile1-dev \
	libsnmp-dev \
	libspeex-dev \
	libspeexdsp-dev \
	libsqlite3-dev \
	libsrtp2-dev \
	libssl-dev \
	libtiff-dev \
	libtool-bin \
	libunbound-dev \
	liburiparser-dev \
	libvorbis-dev \
	libvpb-dev \
	libxml2-dev \
	libxslt1-dev \
	portaudio19-dev \
	python-dev \
	subversion \
	unixodbc-dev \
	uuid-dev \
	zlib1g-dev'

### Install runtime dependencies
RUN	apt install --no-install-recommends --reinstall -y \
	$ASTERISK_BUILD_DEPS \
	apache2 \
	cmake \
	composer \
	cron \
	fail2ban \
	ffmpeg \
	flite \
	freetds-dev \
	git \
	g++ \
	iptables \
	lame \
	libavahi-client3 \
	libbluetooth3 \
	libc-client2007e \
	libcfg7 \
	libcpg4 \
	libgmime-3.0-0 \
	libical3 \
	libiodbc2 \
	libiksemel3 \
	libicu67 \
	libicu-dev \
	libneon27 \
	libosptk4 \
	libresample1 \
	libsnmp40 \
	libspeexdsp1 \
	libsrtp2-1 \
	libunbound8 \
	liburiparser1 \
	libvpb1 \
	locales \
	locales-all \
	make \
	mariadb-client \
	mariadb-server \
	mongodb-org \
	mpg123 \
	nodejs \
	odbc-mariadb \
	php${PHP_VERSION} \
	php${PHP_VERSION}-curl \
	php${PHP_VERSION}-cli \
	php${PHP_VERSION}-mysql \
	php${PHP_VERSION}-gd \
	php${PHP_VERSION}-mbstring \
	php${PHP_VERSION}-intl \
	php${PHP_VERSION}-bcmath \
	php${PHP_VERSION}-ldap \
	php${PHP_VERSION}-xml \
	php${PHP_VERSION}-zip \
	php${PHP_VERSION}-sqlite3 \
	php-pear \
	pkg-config \
	sipsak \
	sngrep \
	socat \
	sox \
	sqlite3 \
	tcpdump \
	tcpflow \
	unixodbc \
	uuid \
	wget \
	whois \
	xmlstarlet

### Add users
RUN	addgroup --gid 2600 asterisk && \
	adduser --uid 2600 --gid 2600 --gecos "Asterisk User" --disabled-password asterisk

### Build SpanDSP
RUN	mkdir -p /usr/src/spandsp && \
	curl -ssLk http://sources.buildroot.net/spandsp/spandsp-${SPANDSP_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr/src/spandsp && \
	cd /usr/src/spandsp && \
	./configure --prefix=/usr && \
	make && \
	make install

### Build Asterisk
RUN	cd /usr/src && \
	mkdir -p asterisk && \
	curl -sSLk http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${ASTERISK_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr/src/asterisk && \
	cd /usr/src/asterisk/ && \
	make distclean && \
	contrib/scripts/get_mp3_source.sh && \
	cd /usr/src/asterisk && \
	./configure \
	--with-jansson-bundled \
	--with-pjproject-bundled \
	--with-bluetooth \
	--with-codec2 \
	--with-crypto \
	--with-gmime \
	--with-iconv \
	--with-iksemel \
	--with-inotify \
	--with-ldap \
	--with-libxml2 \
	--with-libxslt \
	--with-lua \
	--with-ogg \
	--with-opus \
	--with-resample \
	--with-spandsp \
	--with-speex \
	--with-sqlite3 \
	--with-srtp \
	--with-unixodbc \
	--with-uriparser \
	--with-vorbis \
	--with-vpb \
	&& \
	\
	make menuselect/menuselect menuselect-tree menuselect.makeopts && \
	menuselect/menuselect --disable BUILD_NATIVE \
	--enable-category MENUSELECT_ADDONS \
	--enable-category MENUSELECT_APPS \
	--enable-category MENUSELECT_CHANNELS \
	--enable-category MENUSELECT_CODECS \
	--enable-category MENUSELECT_FORMATS \
	--enable-category MENUSELECT_FUNCS \
	--enable-category MENUSELECT_RES \
	--enable BETTER_BACKTRACES \
	--disable MOH-OPSOUND-WAV \
	--enable MOH-OPSOUND-GSM \
	--disable app_voicemail_imap \
	--disable app_voicemail_odbc \
	--disable res_digium_phone \
	--disable codec_g729a && \
	make && \
	make install && \
	make install-headers && \
	make config

#### Add G729 codecs
RUN	git clone https://github.com/BelledonneCommunications/bcg729 /usr/src/bcg729 && \
	cd /usr/src/bcg729 && \
	git checkout tags/$BCG729_VERSION && \
#	./autogen.sh && \
#	./configure --prefix=/usr --libdir=/lib && \
#	using cmake since autotools are deprecated
	cmake . -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_PREFIX_PATH=/usr && \
	make && \
	make install
#
RUN	mkdir -p /usr/src/asterisk-g72x && \
	curl -sSLk https://bitbucket.org/arkadi/asterisk-g72x/get/master.tar.gz | tar xvfz - --strip 1 -C /usr/src/asterisk-g72x && \
	cd /usr/src/asterisk-g72x && \
	./autogen.sh && \
	./configure --prefix=/usr --with-bcg729 --enable-$G72X_CPUHOST && \
	make && \
	make install

#### Add USB Dongle support
#RUN	git clone https://github.com/rusxakep/asterisk-chan-dongle /usr/src/asterisk-chan-dongle && \
RUN	git clone https://github.com/wdoekes/asterisk-chan-dongle /usr/src/asterisk-chan-dongle && \
	cd /usr/src/asterisk-chan-dongle && \
#	git checkout tags/$DONGLE_VERSION && \
	git checkout master && \
	./bootstrap && \
	./configure --with-astversion=$ASTERISK_VERSION && \
	make && \
	make install && \
	\
	ldconfig

### Cleanup
RUN	mkdir -p /var/run/fail2ban && \
	cd / && \
	rm -rf /usr/src/* /tmp/* /etc/cron* && \
	apt purge -y $ASTERISK_BUILD_DEPS && \
	apt -y autoremove && \
	apt clean && \
	rm -rf /var/lib/apt/lists/*

### FreePBX hacks
RUN	sed -i -e "s/memory_limit = 128M/memory_limit = 256M/g" /etc/php/${PHP_VERSION}/apache2/php.ini && \
	sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php/${PHP_VERSION}/apache2/php.ini && \
	a2disconf other-vhosts-access-log.conf && \
	a2enmod rewrite && \
	a2enmod headers && \
	rm -rf /var/log/* && \
	mkdir -p /var/log/asterisk && \
	mkdir -p /var/log/apache2 && \
	mkdir -p /var/log/httpd && \
	update-alternatives --set php /usr/bin/php${PHP_VERSION}

### Zabbix setup
RUN	echo '%zabbix ALL=(asterisk) NOPASSWD:/usr/sbin/asterisk' >> /etc/sudoers

### Setup for data persistence
RUN	mkdir -p /assets/config/var/lib/ /assets/config/home/ && \
	mv /home/asterisk /assets/config/home/ && \
	ln -sfv /data/home/asterisk /home/asterisk && \
	mv /var/lib/asterisk /assets/config/var/lib/ && \
	ln -sfv /data/var/lib/asterisk /var/lib/asterisk && \
	ln -sfv /data/usr/local/fop2 /usr/local/fop2 && \
	mkdir -p /assets/config/var/run/ && \
	mv /var/run/asterisk /assets/config/var/run/ && \
	mv /var/lib/mysql /assets/config/var/lib/ && \
	mkdir -p /assets/config/var/spool && \
	mv /var/spool/cron /assets/config/var/spool/ && \
	ln -sfv /data/var/spool/cron /var/spool/cron && \
	mkdir -p /var/run/mongodb && \
	rm -rf /var/lib/mongodb && \
	ln -sfv /data/var/lib/mongodb /var/lib/mongodb && \
	ln -sfv /data/var/run/asterisk /var/run/asterisk && \
	rm -rf /var/spool/asterisk && \
	ln -sfv /data/var/spool/asterisk /var/spool/asterisk && \
	rm -rf /etc/asterisk && \
	ln -sfv /data/etc/asterisk /etc/asterisk && \
	ln -sfv /usr/bin/crontab /usr/sbin/crontab

### Networking configuration
EXPOSE	80 443 4445 4569 5060/udp 5160/udp 5061 5161 8001 8003 8008 8009 8025 ${RTP_START}-${RTP_FINISH}/udp

### Files add
ADD	install /
