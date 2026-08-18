#!/usr/bin/env bash

cd "$SVC_PATH"

echo -e "\e[34mPreconfigure\e[0m"
if [ ! -f .env ] && [ -f .env.example ]; then
  cp .env.example .env
fi

elc compose build
elc compose run --rm -u$(id -u):$(id -g) --entrypoint="" app yarn install
