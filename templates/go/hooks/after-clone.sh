#!/usr/bin/env bash

cd "$SVC_PATH"

echo -e "\e[34mSet git hooks\e[0m"
elc set-hooks .git_hooks

echo -e "\e[34mInstall dependencies\e[0m"
elc run go mod tidy

echo -e "\e[34mInstall project tools\e[0m"
elc run mise trust
elc run mise run tools:install

echo -e "\e[34mPreconfigure\e[0m"
cp .env.example .env
elc run /var/www/artisan key:generate

elc restart
