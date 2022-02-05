#!/bin/bash

"${psql[@]}" <<- 'EOSQL'
CREATE EXTENSION IF NOT EXISTS citext;
\c template1
CREATE EXTENSION IF NOT EXISTS citext;
EOSQL
