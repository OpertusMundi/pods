#!/bin/bash 
set -e -u -o pipefail

username=opertusmundi
password=$(cat /secrets/${username}-password | tr -d '[:space:]')
quotestring='$q$'
echo "CREATE USER ${username} WITH PASSWORD ${quotestring}${password}${quotestring} LOGIN;" |\
   psql -v ON_ERROR_STOP=1 -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" 

