FROM alpine:edge as build-mp3val

# unreliable:
# RUN wget -q "https://downloads.sourceforge.net/mp3val/mp3val-0.1.8-src.tar.gz" 
ADD mp3val-0.1.8-src.tar.gz /tmp

# Recipe from fortes/docker-alpine-mp3val
RUN apk add --no-cache g++ make
RUN cd /tmp/mp3val-0.1.8-src && make -f Makefile.linux

FROM alpine:edge
COPY --from=build-mp3val /tmp/mp3val-0.1.8-src/mp3val /usr/bin/mp3val

# chromaprint needs testing repo.  TODO: cleanup build here
RUN echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk update && apk upgrade \
    && apk add --no-cache python3 flac chromaprint libmad libmad-dev python3-dev musl-dev zlib-dev gcc g++ make jpeg-dev  git \
    && pip3 install beets[fetchart,embedart,lastgenre,web] requests discogs-client pyacoustid BeautifulSoup4 beets-copyartifacts pymad pylast requests Pillow beetzbox \
    && pip3 install git+git://github.com/igordertigor/beets-usertag.git \
    && apk del --no-cache gcc g++ make libmad-dev python3-dev musl-dev zlib-dev jpeg-dev git

ARG PUID=1001
ARG PGID=1001
RUN addgroup -g ${PGID} beets && \
    adduser -D -u ${PUID} -G beets beets

USER beets
WORKDIR /music
VOLUME ["/music","/home/beets"]

CMD ["/usr/bin/beet"]
