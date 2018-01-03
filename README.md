# docker-beets

Alpine based Docker image for [Beets](http://beets.io), media manager for obsessive-compulsives.

With additional support for a goodly number of plugins.

I run a container with "beet web" executing using a 
`docker-compose.yml` file like this:

	beets:
	  container_name: "beets"
	  restart: unless-stopped
	  image: justifiably/beets
	  ports:
	    - 8337:8337
	  net: host
	  volumes:
	    - /srv/music:/srv/music
	    - /srv/music/beets/:/home/beets/
	  command: "/usr/bin/beet web"

and then I execute additional commands using an alias/script, for in example `/usr/local/bin/beet`:

    #!/bin/sh
    docker exec -ti beets beet "$@"
