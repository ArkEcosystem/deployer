#!/usr/bin/env bash

app_install_explorer()
{
    process_explorer_args "$@"

    if [[ "$SKIP_DEPS" != "Y" ]]; then
        heading "Checking Dependencies..."
        check_program_dependencies "${DEPENDENCIES_PROGRAMS[@]}"
        check_nodejs_dependencies "${DEPENDENCIES_NODEJS[@]}"
    fi

    app_uninstall_explorer "$@"

    heading "Installing Explorer to '$EXPLORER_PATH'..."

    rm -rf "$EXPLORER_PATH"
    git clone https://github.com/ArkEcosystem/ark-explorer.git "$EXPLORER_PATH"
    cd "$EXPLORER_PATH"
    npm install
    sed -i -e "s/\"start\": \"ng serve\"/\"start\": \"ng serve --host $NODE_IP\"/g" package.json
    sed -i -e "s/NETWORK: 'DEVNET'/NETWORK: '$CHAIN_NAME'/g" src/app/app.config.ts
    sed -i -e "s/DEVNET: {/$CHAIN_NAME: {/g" src/app/app.config.ts
    sed -i -e "s/NODE: 'https:\/\/dexplorer.ark.io:8443/NODE: 'http:\/\/$NODE_IP:4100/g" src/app/app.config.ts
    sed -i -e "s/CURRENCIES: \['DARK'\]/CURRENCIES: \['$TOKEN'\]/g" src/app/app.config.ts

    success "Explorer Installed!"
}

app_uninstall_explorer()
{
    heading "Uninstalling Explorer..."
    process_explorer_args "$@"
    rm -rf "$EXPLORER_PATH"
    success "Uninstall OK!"
}
