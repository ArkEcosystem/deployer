#!/usr/bin/env bash

app_install_explorer()
{
    parse_explorer_args "$@"
    install_dependencies
    app_uninstall_explorer "$@"

    heading "Installing Explorer to '$EXPLORER_PATH'..."

    rm -rf "$EXPLORER_PATH"
    git clone https://github.com/ArkEcosystem/ark-explorer.git "$EXPLORER_PATH" && cd "$EXPLORER_PATH"
    yarn
    yarn add connect-history-api-fallback express

    for NETWORK_FILE in $(ls "$EXPLORER_PATH/networks/"); do
        local NETWORK_PATH="$EXPLORER_PATH/networks/$NETWORK_FILE"
        local NETWORK_TYPE=$(echo "$NETWORK_FILE" | sed s/\.json$//g | sed 's/./\U&/')
        local NETWORK_LOWER=$(echo "$NETWORK_TYPE" | awk '{print tolower($0)}')
        local CONFIG=$(cat "$NETWORK_PATH" | jq ".title = \"$CHAIN_NAME $NETWORK_TYPE Explorer\"")
        local CONFIG=$(echo "$CONFIG" | jq ".server = \"http://$CORE_IP:$API_PORT/api/v2\"")
        local CONFIG=$(echo "$CONFIG" | jq ".activeDelegates = \"$FORGERS\"")
        local CONFIG=$(echo "$CONFIG" | jq ".rewardOffset = \"$REWARD_HEIGHT_START\"")
        local CONFIG=$(echo "$CONFIG" | jq ".currencies = []")
        local CONFIG=$(echo "$CONFIG" | jq ".knownWallets = {}")
        local CONFIG=$(echo "$CONFIG" | jq ".defaults.currency = null")
        local CONFIG=$(echo "$CONFIG" | jq ".defaults.token = \"$TOKEN\"")
        local CONFIG=$(echo "$CONFIG" | jq ".defaults.symbol = \"$SYMBOL\"")
        local CONFIG=$(echo "$CONFIG" | jq ".defaults.priceChart = false")
        rm "$NETWORK_PATH"
        echo "$CONFIG" > "$NETWORK_PATH"
    done

    cat > "$EXPLORER_PATH/start-explorer.sh" <<- EOF
NETWORK="\$1"
if [ -z "\$NETWORK" ]; then
    NETWORK="testnet"
fi
HOST="$EXPLORER_IP" PORT="$EXPLORER_PORT" yarn build:"\$NETWORK"
EXPLORER_HOST="$EXPLORER_IP" EXPLORER_PORT="$EXPLORER_PORT" pm2 start $EXPLORER_PATH/express-server.js --name explorer
EOF

    chmod u+x "$EXPLORER_PATH/start-explorer.sh"

    if [ ! -z "$LICENSE_NAME" ]; then
        local YEAR=$(date +"%-Y")
        local LICENSE="Copyright (c) $YEAR $LICENSE_NAME"
        if [ ! -z "$LICENSE_EMAIL" ]; then
            local LICENSE="$LICENSE <$LICENSE_EMAIL>"
        fi
        sed -i -E "s/^(Copyright.+Ark Ecosystem.*)$/\1\n$LICENSE/g" "$EXPLORER_PATH/LICENSE"
    fi

    if [[ "$GIT_EXPLORER_COMMIT" == "Y" ]]; then
        echo "Committing changes..."
        cd "$EXPLORER_PATH"
        if [[ "$GIT_USE_SSH" == "Y" ]]; then
            git config url."git@github.com:".insteadOf "https://github.com/"
        fi
        git config --global user.email "support@ark.io"
        git config --global user.name "ARK Deployer"
        git checkout -b chore/bridgechain-changes
        git add .
        git commit -m "chore: prepare new network config 🎉"
        if [[ "$GIT_EXPLORER_ORIGIN" != "" ]]; then
            git remote set-url origin "$GIT_EXPLORER_ORIGIN"
            git push --set-upstream origin chore/bridgechain-changes || local CANT_PUSH="Y"
            if [[ "$CANT_PUSH" == "Y" ]]; then
                echo "Could not push Git changes to '$GIT_EXPLORER_ORIGIN'"
            fi
        fi
    fi

    success "Explorer Installed!"
}

app_uninstall_explorer()
{
    heading "Uninstalling Explorer..."
    parse_explorer_args "$@"
    process_explorer_stop
    rm -rf "$EXPLORER_PATH"
    pm2 del explorer &>/dev/null || true
    success "Uninstall OK!"
}
