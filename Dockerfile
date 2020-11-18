# https://hub.docker.com/r/library/postgres/tags/
FROM postgres:12.5

RUN export TERM=dumb ; \
  apt-get update && apt-get install -y \
    haproxy=1.8.19-1+deb10u2 \
    pgloader \
    supervisor=3.3.5-1 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY assets /
CMD chmod 755 /*.sh

CMD /bin/bash
