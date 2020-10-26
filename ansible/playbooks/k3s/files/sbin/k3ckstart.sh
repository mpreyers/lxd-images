#!/usr/bin/env bash

# Link /dev/kmsq
if [[ ! -f /dev/kmsg ]]; then
  ln -sf /dev/console /dev/kmsg
fi

# Prepare postgresql
if grep ^Success /var/lib/pgsql/initdb_postgresql.log; then

  _rand() {
    < /dev/urandom tr -dc "$1" | head -c32
    echo
  }

  # Generate k3s db and user
  K3DB_USER="$(_rand 'a-z')"
  K3DB_PASSWORD="$(_rand 'a-zA-Z0-9')"
  K3DB_DATABASE="$(_rand 'a-z')"

  # Set k3s.service env
  chmod 0600 /etc/systemd/system/k3s.service.env
  echo "K3DB_USER=$K3DB_USER" > /etc/systemd/system/k3s.service.env
  echo "K3DB_PASSWORD=$K3DB_PASSWORD" >> /etc/systemd/system/k3s.service.env
  echo "K3DB_DATABASE=$K3DB_DATABASE" >> /etc/systemd/system/k3s.service.env
  chmod 0400 /etc/systemd/system/k3s.service.env

  # Create k3s db and user
  PG_CREATE_ROLE="CREATE ROLE $K3DB_USER LOGIN PASSWORD '$K3DB_PASSWORD';"
  PG_CREATE_DB="CREATE DATABASE $K3DB_DATABASE OWNER $K3DB_USER;"
  echo "${PG_CREATE_ROLE}; ${PG_CREATE_DB}" | runuser -l postgres -c psql

  # Limit to localhost
  PG_LOOPBACK="host $K3DB_DATABASE $K3DB_USER ::1/128 trust"
  PG_SOCKET="local $K3DB_DATABASE $K3DB_USER trust"
  echo -e "${PG_LOOPBACK}\n${PG_SOCKET}" > /var/lib/pgsql/data/pg_hba.conf
  echo "listen_addresses = 'localhost'" > /var/lib/pgsql/data/postgresql.conf

  # Reload postgresql
  kill -HUP $(pidof /usr/bin/postmaster)

  # Disable k3ckstart
  echo "#!/usr/bin/env sh" > /usr/local/sbin/k3ckstart.sh
  echo "ln -sf /dev/console /dev/kmsg" >> /usr/local/sbin/k3ckstart.sh
  rm -f /etc/systemd/system/postgresql-setup.service
  rm -f /etc/systemd/system/multi-user.target.wants/postgresql-setup.service
  rm -f /usr/local/bin/postgresql-setup.sh
fi
