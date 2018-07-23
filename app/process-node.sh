#!/usr/bin/env bash

process_node_start()
{
    process_node_stop "$@"

    heading "Starting..."
    parse_node_args "$@"
    cd "$BRIDGECHAIN_PATH"
    local CONFIG_PATH="$BRIDGECHAIN_PATH/deployer-$CHAIN_NAME"
    if [[ ! -d "$CONFIG_PATH" ]]; then
        abort 1 "Config path '$CONFIG_PATH' not found."
    fi

    if [[ "$AUTO_FORGER" == "Y" ]]; then
        __node_check_last_height "$CONFIG_PATH"
        LAST_HEIGHT=$(__node_check_last_height "$CONFIG_PATH")
        if [[ "$LAST_HEIGHT" > "0" ]]; then
            ARK_ENV=test pm2 start ./packages/core/bin/ark -- start --config "$CONFIG_PATH"
        else
            ARK_ENV=test pm2 start ./packages/core/bin/ark -- start --config "$CONFIG_PATH" --network-start
        fi
    else
        pm2 start ./packages/core/bin/ark -- start --config "$CONFIG_PATH"
    fi
    success "Start OK!"

    WATCH_LOGS="N"
    if [[ "$INTERACTIVE" == "Y" ]]; then
        read -p "Watch Logs? [y/N]: " WATCH_LOGS
    fi
    if [[ "$WATCH_LOGS" =~ ^(yes|y) ]]; then
        process_node_logs
    fi
}

__node_check_last_height() {
    local CONFIG_PATH="$1"
    local DATABASE_NAME=$(cat "$CONFIG_PATH/plugins.json" | jq -r '."@arkecosystem/core-database-sequelize".database // empty')
    sudo -u postgres psql -qtAX -d ark_mytest -c "SELECT height FROM blocks ORDER BY height DESC LIMIT 1"
}

process_node_stop()
{
    heading "Stopping..."
    parse_node_args "$@"
    pm2 stop ark &>/dev/null || true
    success "Stop OK!"
}

process_node_restart()
{
    heading "Restarting..."
    process_node_stop "$@"
    process_node_start "$@"
    success "Restart OK!"
}

process_node_logs()
{
    cd $BRIDGECHAIN_PATH
    pm2 logs ark
}
