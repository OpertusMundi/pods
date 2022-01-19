#!/bin/bash 
set -e -u -o pipefail


for db_name in "catalogueapi"; do
    echo "CREATE DATABASE ${db_name} OWNER opertusmundi;" |\
        psql -v ON_ERROR_STOP=1 -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"
    echo "CREATE EXTENSION postgis;" |\
        psql -v ON_ERROR_STOP=1 -U "${POSTGRES_USER}" -d ${db_name}
done

