#!/usr/bin/env bash

SIDECHAIN_PATH="/home/$USER/ark-sidechain"
CHAIN_NAME="wut"

process_deploy()
{
    local DATABASE_NAME="ark_$CHAIN_NAME"

    while getopts p:d:n: option; do
        case "$option" in
            p)
                SIDECHAIN_PATH=$OPTARG
            ;;
            d)
                local DATABASE_NAME=$OPTARG
            ;;
            n)
                CHAIN_NAME=$OPTARG
            ;;
        esac
    done

    heading "Deploying..."

    DB=$(sudo -u postgres psql -t -c "\l $DATABASE_NAME" | awk '{$1=$1};1' | awk '{print $1}')
    if [[ "$DB" == "$DATABASE_NAME" ]]; then
        read -p "Database $DATABASE_NAME already exists. Recreate? [y/N] :" choice
        if [[ "$choice" =~ ^(yes|y) ]]; then
            dropdb "$DATABASE_NAME"
        else
            abort 1 "Database $DATABASE_NAME already exists."
        fi
    fi
    PQ_USER=$(sudo -u postgres psql -t -c "SELECT usename FROM pg_catalog.pg_user WHERE usename = '$USER'" | awk '{$1=$1};1')
    if [[ "$PQ_USER" == "$USER" ]]; then
        read -p "User $USER already exists. Recreate? [y/N] :" choice
        if [[ "$choice" =~ ^(yes|y) ]]; then
            sudo -u postgres psql -c "DROP USER $USER"
            sudo -u postgres psql -c "CREATE USER $USER WITH PASSWORD 'password' CREATEDB;"
        else
            abort 1 "Database $DATABASE_NAME already exists."
        fi
    else
        sudo -u postgres psql -c "CREATE USER $USER WITH PASSWORD 'password' CREATEDB;"
    fi

    createdb "$DATABASE_NAME"

    rm -rf "$SIDECHAIN_PATH"
    git clone https://github.com/ArkEcosystem/ark-node.git "$SIDECHAIN_PATH"
    cd "$SIDECHAIN_PATH"

    npm install libpq
    npm install secp256k1
    npm install bindings
    npm install

    mv "$SIDECHAIN_PATH/networks.json" "$SIDECHAIN_PATH/networks.json.orig"
    jq ".$CHAIN_NAME = {\"messagePrefix\": \"wut\", \"bip32\": {\"public\": 70617039, \"private\": 70615956}, \"pubKeyHash\": 30, \"wif\": 187, \"client\": {\"token\": \"MINE\", \"symbol\": \"M\", \"explorer\": \"http://google.com\"}}" "$SIDECHAIN_PATH/networks.json.orig" > "$SIDECHAIN_PATH/networks.json"
    cd "$SIDECHAIN_PATH/tasks"
    mkdir demo
    sed -i -e "s/bitcoin/$CHAIN_NAME/g" createGenesisBlock.js
    node createGenesisBlock.js
    cp "$SIDECHAIN_PATH/tasks/demo/config.$CHAIN_NAME.autoforging.json" "$SIDECHAIN_PATH"
    cp "$SIDECHAIN_PATH/tasks/demo/config.$CHAIN_NAME.json" "$SIDECHAIN_PATH"
    cp "$SIDECHAIN_PATH/tasks/demo/genesisBlock.$CHAIN_NAME.json" "$SIDECHAIN_PATH"

    success "Sidechain Deployed!"
}

process_start()
{
    heading "Starting..."

    while getopts n: option; do
        case "$option" in
            n)
                local CHAIN_NAME=$OPTARG
            ;;
        esac
    done

    cd $SIDECHAIN_PATH
    node ./app.js --config "config.$CHAIN_NAME.autoforging.json" --genesis "genesisBlock.$CHAIN_NAME.json"

    success "Start OK!"
}

process_stop()
{
    heading "Stopping..."
    pm2 stop "${__daemon}"
    success "Stop OK!"
}

process_restart()
{
    heading "Restarting..."
    pm2 restart "${__daemon}"
    success "Restart OK!"
}

process_reload()
{
    heading "Reloading..."
    pm2 reload "${__daemon}"
    success "Reload OK!"
}

process_kill()
{
    heading "Reloading..."
    pm2 delete "${__daemon}"
    success "Reload OK!"
}

process_kill()
{
    heading "Killing..."
    pm2 delete "${__daemon}"
    success "Kill OK!"
}

process_info()
{
    pm2 show "${__daemon}"
}

process_logs()
{
    pm2 logs "${__daemon}"
}
