#!/usr/bin/env bash

process_explorer_start()
{
    process_explorer_stop

    heading "Starting Explorer..."

    parse_explorer_args "$@"

    if [ -z "$NETWORK" ]; then
        abort 1 "Network must be specified"
    elif [ ! -f "$EXPLORER_PATH/networks/$NETWORK.json" ]; then
        abort 1 "Network '$NETWORK' does not exist"
    fi

    cd $EXPLORER_PATH
    ./start-explorer.sh "$NETWORK"

    success "Start OK!"
}

process_explorer_stop()
{
    heading "Stopping..."
    pm2 stop explorer &>/dev/null || true
    success "Stop OK!"
}

process_explorer_restart()
{
    heading "Restarting..."
    process_explorer_stop "$@"
    process_explorer_start "$@"
    success "Restart OK!"
}
