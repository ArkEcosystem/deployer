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
    sed -i -e "s/activeNetwork: devNet/activeNetwork: $CHAIN_NAME/g" src/app/app.config.ts
    sed -i -e "s/availableNetworks: \[mainNet, devNet\]/availableNetworks: \[mainNet, $CHAIN_NAME\]/g" src/app/app.config.ts
    sed -i -e "s/devNet: Network = {/$CHAIN_NAME: Network = {/g" src/app/app.config.ts
    sed -i -e "s/name: 'DEVNET'/name: '$CHAIN_NAME'/g" src/app/app.config.ts
    sed -i -e "s/node: 'https:\/\/dexplorer.ark.io:8443/node: 'http:\/\/$NODE_IP:4100/g" src/app/app.config.ts
    sed -i -e "s/currencies: \['DARK'\]/currencies: \['$TOKEN'\]/g" src/app/app.config.ts
    sed -i -e "s/delegates?offset=51/delegates?offset=$FORGERS/g" src/app/shared/services/explorer.service.ts
    sed -i -e "s/delegates\/?orderBy=rate:asc\&limit=51/delegates\/?orderBy=rate:asc\&limit=$FORGERS/g" src/app/shared/services/explorer.service.ts
    sed -i -e "s/delegates\/getNextForgers?limit=51/delegates\/getNextForgers?limit=$FORGERS/g" src/app/shared/services/explorer.service.ts
    sed -i -e "s/delegates?limit=51/delegates?limit=$FORGERS/g" src/app/shared/services/explorer.service.ts
    sed -i -e "s/index < Math.ceil(res.totalCount \/ 51);/index < Math.ceil(res.totalCount \/ $FORGERS);/g" src/app/shared/services/explorer.service.ts
    sed -i -e "s/delegates?limit=51&offset=\${index * 51}/delegates?limit=$FORGERS&offset=\${index * $FORGERS}/g" src/app/shared/services/explorer.service.ts

    success "Explorer Installed!"
}

app_uninstall_explorer()
{
    heading "Uninstalling Explorer..."
    process_explorer_args "$@"
    killall ng || true
    rm -rf "$EXPLORER_PATH"
    success "Uninstall OK!"
}
