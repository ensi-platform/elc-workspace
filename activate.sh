#!/bin/bash

export REPO_ROOT=$(realpath $(dirname ${BASH_SOURCE[0]}))
export ACTIVE_ENV_ROOT=$(realpath ${REPO_ROOT}/../)
export ACTIVE_ENV=ensi-elc-workspace
export PATH=$REPO_ROOT/scripts:$PATH
export AI_STABLE_CONTEXT=${REPO_ROOT}/ai/plans

if ! echo $PS1 | grep $ACTIVE_ENV 2>&1 > /dev/null; then
    export PS1="[${ACTIVE_ENV}] $PS1"
fi

function reactivate() {
    echo 'source REPO_ROOT/activate.sh'
    source REPO_ROOT/activate.sh
}
