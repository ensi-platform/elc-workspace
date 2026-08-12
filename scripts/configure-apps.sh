#!/bin/bash

function createOauthClient() {
    local DB_NAME=$(elc vars $1 | sed -En 's/DB_NAME=(.*)/\1/p')
    elc --svc=database psql -Upostgres ${DB_NAME} -c "INSERT INTO oauth_clients (id, user_id, name, secret, provider, redirect, personal_access_client, password_client, revoked, created_at, updated_at) VALUES ('571818dc-b73d-4013-b87c-1ba3c68b4bdc', null, 'Default Oauth2 client', 'c0f8146b-6fcb-426b-8041-e20018f6ac9c', 'users', 'http://localhost', false, true, false, '2026-06-18 00:00:00', '2026-06-18 00:00:00') ON CONFLICT (id) DO NOTHING;"
}

elc start database kafka redis &> /dev/null
elc start units-admin-auth &> /dev/null

createOauthClient customers-customer-auth
createOauthClient units-admin-auth
createOauthClient units-seller-auth

elc -c units-admin-auth php artisan user:create-with-role admin@example.com example