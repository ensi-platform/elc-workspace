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

echo -e "\e[34mRestart\e[0m"
elc restart
