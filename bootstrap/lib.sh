#!/usr/bin/env bash

source "${__dir}/lib/utils.sh"
source "${__dir}/lib/alerts.sh"
source "${__dir}/lib/errors.sh"

if [[ "$BASH_VERSINFO" < 4 ]]; then
    abort 1 'You need at least bash-4.0 to run this script.'
fi

if [ "$(id -u)" = "0" ]; then
    abort 1 'This script should NOT be started using sudo or as the root user!'
fi

if [[ -z "${HOME}" ]]; then
    abort 1 "\$HOME is not defined. Please set it first."
fi

source "${__dir}/lib/rtfm.sh"
source "${__dir}/lib/dependencies.sh"
source "${__dir}/lib/manifest.sh"
source "${__dir}/lib/args.sh"
