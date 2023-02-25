# from latest alpine
FROM alpine:latest
# update and install
RUN apk update && apk upgrade && apk add lighttpd
# init script
RUN echo -e '#!/bin/sh\nexec lighttpd -f /etc/lighttpd/lighttpd.conf &\nsleep 1 && tail -f /var/log/lighttpd/*.log' > /init && chmod 700 /init
# cleanup
RUN rm -rf /var/cache/apk/
# expose ports
EXPOSE 80/tcp
# set init
ENTRYPOINT "/init"
