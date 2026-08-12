#!/bin/bash

elc list --tag=app | sort | fzf --multi -e | while IFS= read -r svc; do
    elc start $svc
done