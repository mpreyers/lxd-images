#!/usr/bin/env bash
set -e

if [[ -z "$(ls -A /var/lib/pgsql/data)" ]]; then
  postgresql-setup --initdb --unit postgresql
fi
