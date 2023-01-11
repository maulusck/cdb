FROM alpine:latest
# system up-to-date
RUN apk update && apk upgrade && apk add python3 py3-pip py3-vlc
# install streamlink && prepare plugins dir
RUN pip3 install streamlink && mkdir -p /root/.local/share/streamlink/plugins
# install custom plugins
COPY plugins/* /root/.local/share/streamlink/plugins
# set entrypoint
ENTRYPOINT ["streamlink"]
