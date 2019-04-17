#!/usr/bin/env bash

app_install_core_configuration()
{
    parse_core_args "$@"

    cd ~

    local CONFIG_PATH_MAINNET="$(cd ~ && pwd)/.bridgechain/mainnet/$CHAIN_NAME"
    local CONFIG_PATH_DEVNET="$(cd ~ && pwd)/.bridgechain/devnet/$CHAIN_NAME"
    local CONFIG_PATH_TESTNET="$(cd ~ && pwd)/.bridgechain/testnet/$CHAIN_NAME"
    local CONFIG_PATH_CORE="$HOME/.config/${CHAIN_NAME}-core"

    # Production
    if [ -d "$CONFIG_PATH_MAINNET" ]; then
        heading "Installing [mainnet] configuration to ${CONFIG_PATH_CORE}/mainnet..."

        ./bin/run config:publish --network "mainnet" &>/dev/null || true

        if [[ ! -f "${CONFIG_PATH_CORE}/mainnet/delegates.json" ]]; then
            cp "$CONFIG_PATH_MAINNET/delegates.json" "${CONFIG_PATH_CORE}/mainnet/delegates.json"
        fi

        success "[mainnet] configuration Installed!"
    fi

    # Development
    if [ -d "$CONFIG_PATH_DEVNET" ]; then
        heading "Installing [devnet] configuration to ${CONFIG_PATH_CORE}/devnet..."

        ./bin/run config:publish --network "devnet" &>/dev/null || true

        if [[ ! -f "${CONFIG_PATH_CORE}/devnet/delegates.json" ]]; then
            cp "$CONFIG_PATH_DEVNET/delegates.json" "${CONFIG_PATH_CORE}/devnet/delegates.json"
        fi

        success "[devnet] configuration Installed!"
    fi

    # Test
    if [ -d "$CONFIG_PATH_TESTNET" ]; then
        heading "Installing [testnet] configuration to ${CONFIG_PATH_CORE}/testnet..."

        ./bin/run config:publish --network "testnet" &>/dev/null || true

        if [[ ! -f "${CONFIG_PATH_CORE}/testnet/delegates.json" ]]; then
            cp "$CONFIG_PATH_TESTNET/delegates.json" "${CONFIG_PATH_CORE}/testnet/delegates.json"
        fi

        success "[testnet] configuration Installed!"
    fi
}
