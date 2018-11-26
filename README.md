# Description

A PostgreSQL docker image for Foilen Cloud.

# Usage

- Environment:
	- AUTH_METHOD: scram-sha-256 (default) / md5 / password
- User: postgres
- Volume to mount with data: /var/lib/postgresql/data
- Put the desired root password in the file: /newPass
- Command to run: /postgresql-start.sh

