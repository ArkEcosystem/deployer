#!/usr/bin/env bash

EXPLORER_PATH="/home/$USER/ark-explorer"
CHAIN_NAME="explorer"
NODE_IP="localhost"
TOKEN="MINE"

app_process_explorer_args()
{
    while getopts p:n:i:t: option; do
        case "$option" in
            p)
                EXPLORER_PATH=$OPTARG
            ;;
            n)
                CHAIN_NAME=$OPTARG
            ;;
            i)
                NODE_UP=$OPTARG
            ;;
            t)
                TOKEN=$OPTARG
            ;;
        esac
    done
}

app_install_explorer()
{
    heading "Checking Dependencies..."

    check_program_dependencies "${DEPENDENCIES_PROGRAMS[@]}"
    check_nodejs_dependencies "${DEPENDENCIES_NODEJS[@]}"

    heading "Installing Explorer..."

    app_process_explorer_args

    rm -rf "$EXPLORER_PATH"
    git clone https://github.com/ArkEcosystem/ark-explorer.git "$EXPLORER_PATH"
    cd "$EXPLORER_PATH"
    npm install
    sed -i -e "s/NETWORK: 'DEVNET'/NETWORK: '$CHAIN_NAME'/g" src/app/app.config.ts
    sed -i -e "s/DEVNET: {/$CHAIN_NAME: {/g" src/app/app.config.ts
    sed -i -e "s/NODE: 'https:\/\/dexplorer.ark.io:8443/NODE: 'http:\/\/$NODE_IP:4100/g" src/app/app.config.ts
    sed -i -e "s/CURRENCIES: ['DARK']/CURRENCIES: ['$TOKEN']/g" src/app/app.config.ts

    success "Explorer Installed!"
}

app_uninstall_explorer()
{
    heading "Uninstalling Explorer..."

    app_process_explorer_args

    DB=$(sudo -u postgres psql -t -c "\l $DATABASE_NAME" | awk '{$1=$1};1' | awk '{print $1}')
    if [[ "$DB" == "$DATABASE_NAME" ]]; then
        dropdb "$DATABASE_NAME"
    fi
    rm -rf "$EXPLORER_PATH"

    success "Uninstall OK!"
}
