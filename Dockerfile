# https://hub.docker.com/r/library/postgres/tags/
FROM postgres:11.1

RUN export TERM=dumb ; \
  apt-get update && apt-get install -y \
    haproxy=1.7.5-2 \
    supervisor=3.3.1-1+deb9u1 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY assets /
CMD chmod 755 /*.sh

CMD /bin/bash
