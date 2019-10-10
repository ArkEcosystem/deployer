#!/usr/bin/env bash

source "${__dir}/app/var.sh"
source "${__dir}/app/args.sh"
source "${__dir}/app/config-core.sh"
source "${__dir}/app/app-core.sh"
source "${__dir}/app/app-explorer.sh"
source "${__dir}/app/process-core.sh"
source "${__dir}/app/process-explorer.sh"
source "${__dir}/app/update-core.sh"

if [ -z "$XDG_CONFIG_HOME" ]; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi
