#!/usr/bin/env bash

app_install_explorer()
{
    parse_explorer_args "$@"

    if [[ "$SKIP_DEPS" != "Y" ]]; then
        heading "Checking Dependencies..."
        check_program_dependencies "${DEPENDENCIES_PROGRAMS[@]}"
        check_nodejs_dependencies "${DEPENDENCIES_NODEJS[@]}"
    fi

    app_uninstall_explorer "$@"

    heading "Installing Explorer to '$EXPLORER_PATH'..."

    rm -rf "$EXPLORER_PATH"
    git clone https://github.com/ArkEcosystem/ark-explorer.git "$EXPLORER_PATH" && cd "$EXPLORER_PATH"
    npm install
    echo "{\"title\": \"$CHAIN_NAME Explorer\", \"server\": \"http:\/\/$NODE_IP:$NODE_PORT\/api\", \"alias\": \"Bridgechain\", \"activeDelegates\": \"$FORGERS\", \"rewardOffset\": 0, \"currencies\": [], \"knownWallets\": {}, \"defaults\": {\"currency\": null}, \"config\": {\"priceChart\": false}}" > "$EXPLORER_PATH/networks/bridgechain.json"
    mv "$EXPLORER_PATH/package.json" "$EXPLORER_PATH/package.orig.json"
    jq ".scripts.bridgechain = \"npm run dev -- --env.network=\"bridgechain\" --env.host=$EXPLORER_IP --env.port=$EXPLORER_PORT\"" "$EXPLORER_PATH/package.orig.json" > "$EXPLORER_PATH/package.json"

    success "Explorer Installed!"
}

app_uninstall_explorer()
{
    heading "Uninstalling Explorer..."
    parse_explorer_args "$@"
    killall npm || true
    rm -rf "$EXPLORER_PATH"
    success "Uninstall OK!"
}
