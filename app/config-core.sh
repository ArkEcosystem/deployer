#!/usr/bin/env bash

app_install_core_configuration()
{
    parse_core_args "$@"

    cd ~

    local CONFIG_PATH_MAINNET="$(cd ~ && pwd)/.bridgechain/mainnet/$CHAIN_NAME"
    local CONFIG_PATH_DEVNET="$(cd ~ && pwd)/.bridgechain/devnet/$CHAIN_NAME"
    local CONFIG_PATH_TESTNET="$(cd ~ && pwd)/.bridgechain/testnet/$CHAIN_NAME"

    # Production
    heading "Installing [mainnet] configuration to $BRIDGECHAIN_PATH..."

    ./bin/run config:publish --network "mainnet" &>/dev/null || true

    if [[ ! -f "$HOME/.config/{$CHAIN_NAME}-core/mainnet/delegates.json" ]]; then
        cp "$CONFIG_PATH_MAINNET/delegates.json" "$HOME/.config/{$CHAIN_NAME}-core/mainnet/delegates.json"
    fi

    success "[mainnet] configuration Installed!"

    # Development
    heading "Installing [devnet] configuration to $BRIDGECHAIN_PATH..."

    ./bin/run config:publish --network "devnet" &>/dev/null || true

    if [[ ! -f "$HOME/.config/{$CHAIN_NAME}-core/devnet/delegates.json" ]]; then
        cp "$CONFIG_PATH_DEVNET/delegates.json" "$HOME/.config/{$CHAIN_NAME}-core/devnet/delegates.json"
    fi

    success "[devnet] configuration Installed!"

    # Test
    heading "Installing [testnet] configuration to $BRIDGECHAIN_PATH..."

    ./bin/run config:publish --network "testnet" &>/dev/null || true

    if [[ ! -f "$HOME/.config/{$CHAIN_NAME}-core/testnet/delegates.json" ]]; then
        cp "$CONFIG_PATH_TESTNET/delegates.json" "$HOME/.config/{$CHAIN_NAME}-core/testnet/delegates.json"
    fi

    success "[testnet] configuration Installed!"
}
