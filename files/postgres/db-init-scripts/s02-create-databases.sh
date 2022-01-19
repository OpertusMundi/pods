#!/bin/bash 
set -e -u -o pipefail

for db_name in "camunda" "pid" "opertusmundi" "catalogueapi" "profile" "ingest"; do
    echo "CREATE DATABASE ${db_name} OWNER opertusmundi;" |\
        psql -a -v ON_ERROR_STOP=1 -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"
done

for db_name in "opertusmundi" "catalogueapi" "profile" "ingest"; do
    echo "CREATE EXTENSION postgis;" |\
        psql -a -v ON_ERROR_STOP=1 -U "${POSTGRES_USER}" -d ${db_name}
done

for db_name in "opertusmundi"; do
    echo "CREATE EXTENSION \"uuid-ossp\";" |\
        psql -a -v ON_ERROR_STOP=1 -U "${POSTGRES_USER}" -d ${db_name}
done

