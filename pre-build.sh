#!/bin/bash
set -e
BASE_DIR="$( cd -P "$( dirname "$BASH_SOURCE" )" && pwd -P )"
cd "${BASE_DIR}"

if [[ ! -z "${TRUST_ACCOUNT}" ]]; then
    tmpVars=$(mktemp vars_XXXXXX.json)
    jq ".trust_account=\"${TRUST_ACCOUNT}\"" IaC/.auto.tfvars.json > ${tmpVars}

    mv ${tmpVars} IaC/.auto.tfvars.json
fi