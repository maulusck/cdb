# from latest alpine
FROM alpine:latest
# update and install
RUN apk update && apk upgrade && apk add qbittorrent-nox
# create user
RUN adduser -D -h /home/qbtnox qbtnox
# init script
RUN echo "echo y | exec qbittorrent-nox --profile=/data" > /usr/local/bin/qbtnox && chmod 750 /usr/local/bin/qbtnox && chown root:qbtnox /usr/local/bin/qbtnox
# cleanup
RUN rm -rf /var/cache/apk/* && mkdir -p /data
# set priv | run with --user root if you want to mount directories
USER qbtnox
# set init
ENTRYPOINT "/usr/local/bin/qbtnox"
