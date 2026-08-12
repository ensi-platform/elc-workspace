#!/bin/bash

elc list --tag=app | sort | fzf --multi -e | while IFS= read -r svc; do
    cd $(elc vars $svc | awk -F'=' '/SVC_PATH/ {print $2}')
    ensi-gog client
done