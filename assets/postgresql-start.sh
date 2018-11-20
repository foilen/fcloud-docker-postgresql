#!/bin/bash

# Get last and new passwords
LAST_PASS=$(cat /var/lib/postgresql/data/lastPass)

set -e
NEW_PASS=$(cat /newPass)

# Initializing if not done
if [ ! -f /var/lib/postgresql/data/postgresql.conf ]; then
  echo Initializing the DB
  /usr/lib/postgresql/11/bin/initdb -D /var/lib/postgresql/data/ --auth=scram-sha-256 --pwfile=/newPass
  LAST_PASS=$NEW_PASS
  echo "*:*:*:*:$NEW_PASS" > /var/lib/postgresql/data/pgpass
  chown postgres:postgres /var/lib/postgresql/data/pgpass
  chmod 600 /var/lib/postgresql/data/pgpass
fi

# Start
echo Starting
chmod 750 /var/lib/postgresql/data
/usr/lib/postgresql/11/bin/postgres -D /var/lib/postgresql/data/ &
APP_PID=$!
echo Started

# Update password if not the same
if [ "$LAST_PASS" != "$NEW_PASS" ]; then
  sleep 5
  echo Update the password
  export PGPASSFILE=/var/lib/postgresql/data/pgpass
  /usr/bin/psql -U postgres -h 127.0.0.1 -c "ALTER USER postgres WITH PASSWORD '$NEW_PASS';"
  echo "*:*:*:*:$NEW_PASS" > /var/lib/postgresql/data/pgpass
  chown postgres:postgres /var/lib/postgresql/data/pgpass
  chmod 600 /var/lib/postgresql/data/pgpass
fi

wait $APP_PID

