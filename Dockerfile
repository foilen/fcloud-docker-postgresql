# https://hub.docker.com/r/library/postgres/tags/
FROM postgres:13.1

RUN export TERM=dumb ; \
  apt-get update && apt-get install -y \
    pgloader \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY assets /
CMD chmod 755 /*.sh

CMD /bin/bash
