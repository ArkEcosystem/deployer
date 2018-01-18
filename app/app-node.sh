#!/usr/bin/env bash

app_install_node()
{
    process_node_args "$@"

    if [[ "$SKIP_DEPS" != "Y" ]]; then
        heading "Checking Dependencies..."
        check_program_dependencies "${DEPENDENCIES_PROGRAMS[@]}"
        check_nodejs_dependencies "${DEPENDENCIES_NODEJS[@]}"
    fi

    app_uninstall_node "$@"

    heading "Installing Node to $SIDECHAIN_PATH..."

    DB=$(sudo -u postgres psql -t -c "\l $DATABASE_NAME" | awk '{$1=$1};1' | awk '{print $1}')
    if [[ "$DB" == "$DATABASE_NAME" ]]; then
        read -p "Database $DATABASE_NAME already exists. Recreate? [y/N]: " choice
        if [[ "$choice" =~ ^(yes|y) ]]; then
            dropdb "$DATABASE_NAME"
        else
            abort 1 "Database $DATABASE_NAME already exists."
        fi
    fi
    PQ_USER=$(sudo -u postgres psql -t -c "SELECT usename FROM pg_catalog.pg_user WHERE usename = '$USER'" | awk '{$1=$1};1')
    if [[ "$PQ_USER" == "$USER" ]]; then
        read -p "User $USER already exists. Recreate? [y/N]: " choice
        if [[ "$choice" =~ ^(yes|y) ]]; then
            sudo -u postgres psql -c "DROP USER $USER"
            sudo -u postgres psql -c "CREATE USER $USER WITH PASSWORD 'password' CREATEDB;"
        else
            echo "Skipping User Creation for $USER"
        fi
    else
        sudo -u postgres psql -c "CREATE USER $USER WITH PASSWORD 'password' CREATEDB;"
    fi

    createdb "$DATABASE_NAME"

    rm -rf "$SIDECHAIN_PATH"
    git clone https://github.com/ArkEcosystem/ark-node.git -b explorer "$SIDECHAIN_PATH"
    cd "$SIDECHAIN_PATH"

    npm install libpq
    npm install secp256k1
    npm install bindings
    npm install

    mv "$SIDECHAIN_PATH/networks.json" "$SIDECHAIN_PATH/networks.json.orig"
    jq ".$CHAIN_NAME = {\"messagePrefix\": \"$CHAIN_NAME\", \"bip32\": {\"public\": 70617039, \"private\": 70615956}, \"pubKeyHash\": 30, \"wif\": 187, \"client\": {\"token\": \"$TOKEN\", \"symbol\": \"$SYMBOL\", \"explorer\": \"http://$NODE_IP\"}}" "$SIDECHAIN_PATH/networks.json.orig" > "$SIDECHAIN_PATH/networks.json"
    cd "$SIDECHAIN_PATH/tasks"
    mkdir demo
    sed -i -e "s/bitcoin/$CHAIN_NAME/g" createGenesisBlock.js
    sed -i -e "s/var db_name = \"ark_\" + network_name;/var db_name = \"$DATABASE_NAME\";/g" createGenesisBlock.js
    node createGenesisBlock.js
    cp "$SIDECHAIN_PATH/tasks/demo/config.$CHAIN_NAME.autoforging.json" "$SIDECHAIN_PATH"
    cp "$SIDECHAIN_PATH/tasks/demo/config.$CHAIN_NAME.json" "$SIDECHAIN_PATH"
    cp "$SIDECHAIN_PATH/tasks/demo/genesisBlock.$CHAIN_NAME.json" "$SIDECHAIN_PATH"

    success "Sidechain Installed!"
}

app_uninstall_node()
{
    heading "Uninstalling..."

    process_node_args "$@"

    DB=$(sudo -u postgres psql -t -c "\l $DATABASE_NAME" | awk '{$1=$1};1' | awk '{print $1}')
    if [[ "$DB" == "$DATABASE_NAME" ]]; then
        dropdb "$DATABASE_NAME"
    fi
    rm -rf "$SIDECHAIN_PATH"

    success "Uninstall OK!"
}
