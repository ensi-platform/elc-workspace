#!/usr/bin/env bash

cd "$SVC_PATH"

echo -e "\e[34mSet git hooks\e[0m"
elc set-hooks .git_hooks

echo -e "\e[34mInstall dependencies\e[0m"
elc compose run --rm -u$(id -u):$(id -g) --entrypoint="" app npm install
elc compose run --rm -u$(id -u):$(id -g) --entrypoint="" app composer install

echo -e "\e[34mPreconfigure\e[0m"
cp .env.example .env
elc compose run --rm -u$(id -u):$(id -g) --entrypoint="" app php artisan key:generate

cp .env .env.testing

sed -E 's/(DB_DATABASE=.*)/\1_test/' -i .env.testing
sed -E 's/(CACHE_DRIVER=).*/CACHE_DRIVER=array/' -i .env.testing
sed -E 's/(QUEUE_CONNECTION=).*/QUEUE_CONNECTION=sync/' -i .env.testing

sed -E 's/(MAIL_HOST=).*/\1/' -i .env.testing
sed -E 's/(ELASTICSEARCH_HOST=).*/\1/' -i .env.testing
sed -E 's/(.*_SERVICE_HOST=).*/\1/' -i .env.testing
sed -E 's/(.*_DOMAIN=).*/\1/' -i .env.testing
sed -E 's/(.*_BROKER_LIST=).*/\1/' -i .env.testing
sed -E 's/(.*_URL=).*/\1/' -i .env.testing

elc restart
elc php artisan migrate
elc php artisan migrate --env=testing