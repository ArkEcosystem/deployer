#!/usr/bin/env bash

process_core_start()
{
    process_core_stop "$@"

    heading "Starting..."
    parse_core_args "$@"
    if [ ! -d "$BRIDGECHAIN_PATH/packages/core" ]; then
        error "Bridgechain path could not be found. Use '--path' to specify the location it was installed."

        return
    fi

    cd "$BRIDGECHAIN_PATH/packages/core"
    local NETWORK=$(echo "$NETWORK" | awk '{print tolower($0)}')

    if [ -z "$NETWORK" ]; then
        abort 1 "Network must be specified"
    elif [ ! -d "$BRIDGECHAIN_PATH/packages/core/bin/config/$NETWORK" ]; then
        abort 1 "Network '$NETWORK' does not exist"
    fi

    if [[ "$AUTO_FORGER" == "Y" ]]; then
        local LAST_HEIGHT=$(__core_check_last_height "$CONFIG_PATH")
        if [[ "$LAST_HEIGHT" > "0" ]]; then
            __core_start
        else
            CORE_ENV=test CORE_PATH_CONFIG=./bin/config/$NETWORK/ ./bin/run relay:start --network="$NETWORK" --networkStart
            if [ $(sh -c "jq '.secrets | length' ./bin/config/$NETWORK/delegates.json") <> "0" ]; then
                CORE_ENV=test CORE_PATH_CONFIG=./bin/config/$NETWORK/ ./bin/run forger:start --network="$NETWORK"
            else
                warning "No forging delegates found in 'delegates.json' config"
            fi
        fi
    else
        __core_start
    fi
    success "Start OK!"

    local WATCH_LOGS="N"
    if [[ "$INTERACTIVE" == "Y" ]]; then
        read -p "Watch Logs? [y/N]: " WATCH_LOGS
    fi
    if [[ "$WATCH_LOGS" =~ ^(yes|y|Y) ]]; then
        process_core_logs
    fi
}

__core_start() {
    if [[ "$FORCE_NETWORK_START" == "Y" ]]; then
        CORE_PATH_CONFIG=./bin/config/$NETWORK/ ./bin/run relay:start --network="$NETWORK" --networkStart --ignoreMinimumNetworkReach
    else
        CORE_PATH_CONFIG=./bin/config/$NETWORK/ ./bin/run relay:start --network="$NETWORK" --ignoreMinimumNetworkReach
    fi

    if [ $(sh -c "jq '.secrets | length' ./bin/config/$NETWORK/delegates.json") <> "0" ]; then
        CORE_PATH_CONFIG=./bin/config/$NETWORK/ ./bin/run forger:start --network="$NETWORK"
    else
        warning "No forging delegates found in 'delegates.json' config"
    fi
}

__core_check_last_height() {
    local CONFIG_PATH="$1"
    local DATABASE_NAME=$(cat "$BRIDGECHAIN_PATH/packages/core/bin/config/$NETWORK/.env" | fgrep 'CORE_DB_DATABASE=' | awk -F'=' '{print $2}')
    psql -qtAX -d "$DATABASE_NAME" -c "SELECT height FROM blocks ORDER BY height DESC LIMIT 1" 2>/dev/null || echo 0
}

process_core_stop()
{
    heading "Stopping..."
    parse_core_args "$@"

    local NETWORK=$(echo "$NETWORK" | awk '{print tolower($0)}')
    if [[ -d "$BRIDGECHAIN_PATH/packages/core" && ! -z "$NETWORK" ]]; then
        cd "$BRIDGECHAIN_PATH/packages/core"

        if [ ! -d "$BRIDGECHAIN_PATH/packages/core/bin/config/$NETWORK" ]; then
            abort 1 "Network '$NETWORK' does not exist"
        fi

        CORE_PATH_CONFIG=./bin/config/$NETWORK/ ./bin/run relay:stop &>/dev/null || true
        CORE_PATH_CONFIG=./bin/config/$NETWORK/ ./bin/run forger:stop &>/dev/null || true
    else
        for PROCESS in $(pm2 list | fgrep "online" | egrep -v "explorer|────|^│ App nam" | awk '{print $2}'); do
            pm2 stop "$PROCESS" &>/dev/null || true
        done
    fi

    success "Stop OK!"
}

process_core_restart()
{
    heading "Restarting..."
    process_core_stop "$@"
    process_core_start "$@"
    success "Restart OK!"
}

process_core_logs()
{
    pm2 logs
}
