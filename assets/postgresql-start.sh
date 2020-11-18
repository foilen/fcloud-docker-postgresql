#!/bin/bash

# Get last and new passwords
LAST_PASS=$(cat /var/lib/postgresql/data/lastPass)

set -e
NEW_PASS=$(cat /newPass)

# Default auth method if not in the environment
if [ -z "$AUTH_METHOD" ]; then
	export AUTH_METHOD=scram-sha-256
fi
echo Using AUTH_METHOD: $AUTH_METHOD

# Initializing if not done
if [ ! -f /var/lib/postgresql/data/postgresql.conf ]; then
  echo Initializing the DB
  /usr/lib/postgresql/12/bin/initdb -D /var/lib/postgresql/data/ --auth=$AUTH_METHOD --pwfile=/newPass
  LAST_PASS=$NEW_PASS
  echo "*:*:*:*:$NEW_PASS" > /var/lib/postgresql/data/pgpass
  chown postgres:postgres /var/lib/postgresql/data/pgpass
  chmod 600 /var/lib/postgresql/data/pgpass
fi

# Whitelist hosts
cat > /var/lib/postgresql/data/pg_hba.conf << _EOF
local   all             all                                     $AUTH_METHOD
host    all             all             127.0.0.1/32            $AUTH_METHOD
host    all             all             ::1/128                 $AUTH_METHOD
host    all             all             172.16.0.0/12           $AUTH_METHOD
local   replication     all                                     $AUTH_METHOD
host    replication     all             127.0.0.1/32            $AUTH_METHOD
host    replication     all             ::1/128                 $AUTH_METHOD
_EOF

# Start
echo Starting
chmod 750 /var/lib/postgresql/data
/usr/lib/postgresql/12/bin/postgres -D /var/lib/postgresql/data/ &
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
