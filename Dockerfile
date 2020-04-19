FROM alpine:3.11 as build-mp3val

# unreliable:
# RUN wget -q "https://downloads.sourceforge.net/mp3val/mp3val-0.1.8-src.tar.gz" 
ADD mp3val-0.1.8-src.tar.gz /tmp

# Recipe from fortes/docker-alpine-mp3val
RUN apk add --no-cache g++ make
RUN cd /tmp/mp3val-0.1.8-src && make -f Makefile.linux

FROM alpine:3.11
COPY --from=build-mp3val /tmp/mp3val-0.1.8-src/mp3val /usr/bin/mp3val

# Much copied Python 3 pip3 install hacks
RUN apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    echo "**** install pip ****" && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi

RUN echo "http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories 
RUN apk update && apk upgrade && apk add --no-cache flac libmad chromaprint
    
RUN apk add --no-cache git gcc musl-dev python3-dev zlib-dev jpeg-dev libmad-dev && \
    pip install beets[fetchart,embedart,lastgenre,web] \
     requests discogs-client pyacoustid BeautifulSoup4 \
     beets-copyartifacts \
     pymad pylast requests Pillow beetzbox \
     beets-artistcountry \
     beets-alternatives \
     beets-popularity \
     git+git://github.com/geigerzaehler/beets-check.git@master \
     git+git://github.com/igordertigor/beets-usertag.git && \
    apk del --no-cache git gcc g++ make libmad-dev python3-dev musl-dev zlib-dev jpeg-dev git

ARG PUID=1001
ARG PGID=1001
RUN addgroup -g ${PGID} beets && \
    adduser -D -u ${PUID} -G beets beets

USER beets
WORKDIR /music
VOLUME ["/music","/home/beets"]

CMD ["/usr/bin/beet"]
