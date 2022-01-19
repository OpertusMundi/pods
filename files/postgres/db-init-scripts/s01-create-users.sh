#!/bin/bash 
set -e -u -o pipefail

user=opertusmundi
pass=${OPERTUSMUNDI_PASSWORD}
quotestring='$q$'
echo "CREATE USER ${user} WITH PASSWORD ${quotestring}${pass}${quotestring} LOGIN;" |\
   psql -v ON_ERROR_STOP=1 -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" 


