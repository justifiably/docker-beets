FROM alpine:edge as build-mp3val

# Recipe from fortes/docker-alpine-mp3val (NB: download from sf is flakey, need to repeat)
RUN apk add --no-cache g++ make
RUN mkdir -p /tmp/mp3val && cd /tmp/mp3val && \
    wget --no-check-certificate -q "https://downloads.sourceforge.net/mp3val/mp3val-0.1.8-src.tar.gz" && \
    tar zxf *.tar.gz -C /tmp/mp3val && \
    cd /tmp/mp3val/mp3val-0.1.8-src && \
    make -f Makefile.linux

FROM alpine:edge
COPY --from=build-mp3val /tmp/mp3val/mp3val-0.1.8-src/mp3val /usr/bin/mp3val

# chromaprint needs testing repo
RUN echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \ 
    apk update && apk upgrade
RUN apk add --no-cache python3 flac chromaprint libmad libmad-dev python3-dev musl-dev zlib-dev gcc g++ make jpeg-dev 
RUN pip3 install beets[fetchart,lastgenre,web] discogs-client pyacoustid BeautifulSoup4 beets-copyartifacts pymad pylast requests Pillow https://github.com/MrDOS/python-itunes/archive/master.zip
RUN apk del gcc g++ make libmad-dev python3-dev musl-dev zlib-dev jpeg-dev && \
    rm -r /root/.cache

ARG PUID=1001
ARG PGID=1001
RUN addgroup -g ${PGID} beets && \
    adduser -D -u ${PUID} -G beets beets

USER beets
WORKDIR /music
VOLUME ["/music","/home/beets"]

CMD ["/usr/bin/beet"]
