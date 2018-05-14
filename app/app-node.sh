#!/usr/bin/env bash

app_install_node()
{
    parse_node_args "$@"

    if [[ "$SKIP_DEPS" != "Y" ]]; then
        heading "Checking Dependencies..."
        check_program_dependencies "${DEPENDENCIES_PROGRAMS[@]}"
        check_nodejs_dependencies "${DEPENDENCIES_NODEJS[@]}"
    fi

    app_uninstall_node "$@"

    heading "Installing Core to $BRIDGECHAIN_PATH..."

    PREFIX=$(sh -c "jq '.$PREFIX' $__dir/prefixes.json")
    if [[ -z "$PREFIX" ]]; then
        PREFIX=$(sh -c "jq '.M' $__dir/prefixes.json")
    fi

    DB=$(sudo -u postgres psql -t -c "\l $DATABASE_NAME" | awk '{$1=$1};1' | awk '{print $1}')
    if [[ "$DB" == "$DATABASE_NAME" ]]; then
        RECREATE_DATABASE="Y"
        if [[ "$INTERACTIVE" == "Y" ]]; then
            read -p "Database $DATABASE_NAME already exists. Recreate? [y/N]: " RECREATE_DATABASE
        fi
        if [[ "$RECREATE_DATABASE" =~ ^(yes|y) ]]; then
            dropdb "$DATABASE_NAME"
        else
            abort 1 "Database $DATABASE_NAME already exists."
        fi
    fi
    DB_USER="node"
    PQ_USER=$(sudo -u postgres psql -t -c "SELECT usename FROM pg_catalog.pg_user WHERE usename = '$DB_USER'" | awk '{$1=$1};1')
    if [[ "$PQ_USER" == "$DB_USER" ]]; then
        RECREATE_USER="N"
        if [[ "$INTERACTIVE" == "Y" ]]; then
            read -p "User $DB_USER already exists. Recreate? [y/N]: " RECREATE_USER
        fi
        if [[ "$RECREATE_USER" =~ ^(yes|y) ]]; then
            sudo -u postgres psql -c "DROP USER $DB_USER"
            sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD 'password' CREATEDB;"
        else
            echo "Skipping User Creation for $DB_USER"
        fi
    else
        sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD 'password' CREATEDB;"
    fi

    createdb "$DATABASE_NAME"

    local CONFIG_PATH="$BRIDGECHAIN_PATH/deployer-$CHAIN_NAME"

    rm -rf "$CONFIG_PATH" "$BRIDGECHAIN_PATH"
    git clone git@github.com:alexbarnsley/ark-core.git -b deployer "$BRIDGECHAIN_PATH"
    cd "$BRIDGECHAIN_PATH"

    npm install
    lerna bootstrap

    local YEAR=$(date +"%-Y")
    local MONTH=$(printf "%02d" $(expr $(date +"%-m") - 1))
    local DAY=$(printf "%02d" $(date +"%-d"))
    local HOUR=$(printf "%02d" $(date +"%-H"))
    local MINUTE=$(printf "%02d" $(date +"%-M"))
    local SECOND=$(printf "%02d" $(date +"%-S"))

    ./packages/core-deployer/bin/deployer --configPath "$CONFIG_PATH" \
                                          --overwriteConfig \
                                          --name "$CHAIN_NAME" \
                                          --nodeIp "$NODE_IP" \
                                          --p2pPort "$P2P_PORT" \
                                          --apiPort "$API_PORT"  \
                                          --dbHost "$DATABASE_HOST"  \
                                          --dbPort "$DATABASE_PORT"  \
                                          --dbUsername "$DB_USER"  \
                                          --dbPassword "password"  \
                                          --dbDatabase "$DATABASE_NAME"  \
                                          --explorerUrl "http://$EXPLORER_IP:$EXPLORER_PORT"  \
                                          --activeDelegates "$FORGERS"  \
                                          --feeSend "$FEE_SEND"  \
                                          --feeVote "$FEE_VOTE"  \
                                          --feeSecondSignature "$FEE_SECOND_PASSPHRASE"  \
                                          --feeDelegate "$FEE_DELEGATE"  \
                                          --feeMultisignature "$FEE_MULTISIG"  \
                                          --epoch "${YEAR}-${MONTH}-${DAY}T${HOUR}:${MINUTE}:${SECOND}.000Z"  \
                                          --rewardHeight "$REWARD_HEIGHT_START"  \
                                          --rewardPerBlock "$REWARD_PER_BLOCK"  \
                                          --blocktime "$BLOCK_TIME"  \
                                          --token "$TOKEN"  \
                                          --symbol "$SYMBOL"  \
                                          --prefixHash "$PREFIX"  \
                                          --transactionsPerBlock "$TXS_PER_BLOCK"

    local PASSPHRASE=$(sh -c "jq '.passphrase' $CONFIG_PATH/genesisWallet.json")
    local ADDRESS=$(sh -c "jq '.address' $CONFIG_PATH/genesisWallet.json")

    echo "Your Genesis Details are:"
    echo "  Passphrase: $PASSPHRASE"
    echo "  Address: $ADDRESS"

    success "Bridgechain Installed!"
}

app_uninstall_node()
{
    process_node_stop "$@"

    heading "Uninstalling..."

    DB=$(sudo -u postgres psql -t -c "\l $DATABASE_NAME" | awk '{$1=$1};1' | awk '{print $1}')
    if [[ "$DB" == "$DATABASE_NAME" ]]; then
        dropdb "$DATABASE_NAME"
    fi
    rm -rf "$BRIDGECHAIN_PATH"

    success "Uninstall OK!"
}
