#!/usr/bin/env bash

process_node_start()
{
    process_node_stop "$@"

    heading "Starting..."
    parse_node_args "$@"
    cd "$BRIDGECHAIN_PATH"
    local CONFIG_PATH="$BRIDGECHAIN_PATH/deployer-$CHAIN_NAME"
    if [[ "$AUTO_FORGER" == "Y" ]]; then
        ARK_ENV=test pm2 start ./packages/core/bin/ark -- start --config "$CONFIG_PATH" --network-start
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
