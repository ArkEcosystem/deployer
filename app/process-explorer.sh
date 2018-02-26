#!/usr/bin/env bash

process_explorer_start()
{
    process_explorer_stop

    heading "Starting Explorer..."
    parse_explorer_args "$@"
    cd $EXPLORER_PATH
    nohup npm run bridgechain &
    success "Start OK!"
}

process_explorer_stop()
{
    heading "Stopping..."
    killall npm || true
    success "Stop OK!"
}

process_explorer_restart()
{
    heading "Restarting..."
    process_explorer_stop "$@"
    process_explorer_start "$@"
    success "Restart OK!"
}
