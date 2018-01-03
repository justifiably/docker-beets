FROM alpine:edge

RUN echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \ 
    apk update && apk upgrade && apk add --no-cache python3 && \
    pip3 install beets[fetchart,lastgenre,web] pyacoustid && \
    apk add --no-cache flac chromaprint gstreamer && \ # chromaprint needs testing repo
    rm -r /root/.cache

ARG PUID=1001
ARG PGID=1001
RUN addgroup -g ${PGID} beets && \
    adduser -D -u ${PUID} -G beets beets

USER beets
WORKDIR /home/beets
VOLUME ["/home/beets"]

CMD ["/usr/bin/beet"]
