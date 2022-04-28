#!/usr/bin/env bash

app_install_core()
{
    parse_core_args "$@"
    install_dependencies
    app_uninstall_core "$@"

    heading "Installing Core to $BRIDGECHAIN_PATH..."
    cd ~

    local CONFIG_PATH_MAINNET="$HOME/.bridgechain/mainnet/$CHAIN_NAME"
    local CONFIG_PATH_DEVNET="$HOME/.bridgechain/devnet/$CHAIN_NAME"
    local CONFIG_PATH_TESTNET="$HOME/.bridgechain/testnet/$CHAIN_NAME"

    rm -rf "$HOME/.config/@${CORE_ALIAS}"
    rm -rf "$HOME/.config/@${CHAIN_NAME}"
    rm -rf "$HOME/.config/${CORE_ALIAS}-core"

    local MAINNET_PREFIX=$(sh -c "jq '.[\"$MAINNET_PREFIX\"]' $__dir/prefixes.json")
    if [[ -z "$MAINNET_PREFIX" ]]; then
        MAINNET_PREFIX=$(sh -c "jq '.M' $__dir/prefixes.json")
    fi
    local DEVNET_PREFIX=$(sh -c "jq '.[\"$DEVNET_PREFIX\"]' $__dir/prefixes.json")
    if [[ -z "$DEVNET_PREFIX" ]]; then
        DEVNET_PREFIX=$(sh -c "jq '.M' $__dir/prefixes.json")
    fi
    local TESTNET_PREFIX=$(sh -c "jq '.[\"$TESTNET_PREFIX\"]' $__dir/prefixes.json")
    if [[ -z "$TESTNET_PREFIX" ]]; then
        TESTNET_PREFIX=$(sh -c "jq '.M' $__dir/prefixes.json")
    fi

    ## Create local user for psql, remove if already exists
    OWNED_DATABASES=$(sudo -u postgres psql -c "\l" | fgrep " | $USER " | awk '{print $1}' | egrep "_(main|dev|test)net$") || true
    for OWNED_DATABASE in $OWNED_DATABASES; do
        sudo -u postgres dropdb "$OWNED_DATABASE"
    done
    sudo -u postgres psql -c "DROP OWNED BY $USER; DROP USER $USER" || true
    sudo -u postgres psql -c "CREATE USER $USER;"
    sudo -u postgres psql -c "ALTER USER $USER WITH SUPERUSER;"
    echo "Created local postgres user"

    local DATABASE_NAME_MAINNET="${DATABASE_NAME}_mainnet"
    local DATABASE_NAME_DEVNET="${DATABASE_NAME}_devnet"
    local DATABASE_NAME_TESTNET="${DATABASE_NAME}_testnet"

    local DB_EXISTS_MAINNET=$(psql -t -c "\l" postgres | fgrep "$DATABASE_NAME_MAINNET" | fgrep "|" | awk '{$1=$1};1' | awk '{print $1}')
    local DB_EXISTS_DEVNET=$(psql -t -c "\l" postgres | fgrep "$DATABASE_NAME_DEVNET" | fgrep "|" | awk '{$1=$1};1' | awk '{print $1}')
    local DB_EXISTS_TESTNET=$(psql -t -c "\l" postgres | fgrep "$DATABASE_NAME_TESTNET" | fgrep "|" | awk '{$1=$1};1' | awk '{print $1}')

    local DB_EXISTS="$DB_EXISTS_MAINNET $DB_EXISTS_DEVNET $DB_EXISTS_TESTNET"
    local DB_EXISTS=$(echo "$DB_EXISTS" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    if [ ! -z "$DB_EXISTS" ]; then
        local RECREATE_DATABASES="Y"
        if [[ "$INTERACTIVE" == "Y" ]]; then
            read -p "Database(s) ($DB_EXISTS) already exists. Recreate? [Y/n]: " RECREATE_DATABASES
        fi
        if [[ "$RECREATE_DATABASES" =~ ^(no|n|N) ]]; then
            echo "Skipping database re-creation"
        else
            if [ ! -z "$DB_EXISTS_MAINNET" ]; then
                dropdb "$DATABASE_NAME_MAINNET"
                createdb "$DATABASE_NAME_MAINNET"
            fi
            if [ ! -z "$DB_EXISTS_DEVNET" ]; then
                dropdb "$DATABASE_NAME_DEVNET"
                createdb "$DATABASE_NAME_DEVNET"
            fi
            if [ ! -z "$DB_EXISTS_TESTNET" ]; then
                dropdb "$DATABASE_NAME_TESTNET"
                createdb "$DATABASE_NAME_TESTNET"
            fi
            echo "Created databases"
        fi
    else
        createdb "$DATABASE_NAME_MAINNET"
        createdb "$DATABASE_NAME_DEVNET"
        createdb "$DATABASE_NAME_TESTNET"
        echo "Created databases"
    fi

    local DB_USER="core"
    local PQ_USER=$(sudo -u postgres psql -t -c "SELECT usename FROM pg_catalog.pg_user WHERE usename = '$DB_USER'" | awk '{$1=$1};1')
    if [[ "$PQ_USER" == "$DB_USER" ]]; then
        local RECREATE_USER="N"
        if [[ "$INTERACTIVE" == "Y" ]]; then
            read -p "User $DB_USER already exists. Recreate? [y/N]: " RECREATE_USER
        fi
        if [[ "$RECREATE_USER" =~ ^(yes|y|Y) ]]; then
            sudo -u postgres psql -c "DROP USER $DB_USER"
            sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD 'password' CREATEDB;"
        else
            echo "Skipping User Creation for $DB_USER"
        fi
    else
        sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD 'password' CREATEDB;"
    fi

    cd "$ROOT_PATH"
    if [ ! -d "$ROOT_PATH/packages/js-deployer/node_modules" ]; then
        cd "$ROOT_PATH/packages/js-deployer"
        yarn
    fi

    rm -rf "$CONFIG_PATH_MAINNET" "$CONFIG_PATH_DEVNET" "$CONFIG_PATH_TESTNET" "$BRIDGECHAIN_PATH"

    git clone https://github.com/ArkEcosystem/core.git --branch 2.6.57 --single-branch "$BRIDGECHAIN_PATH"

    local DYNAMIC_FEE_ENABLED="false"
    if [[ "$FEE_DYNAMIC_ENABLED" == "Y" ]]; then
        local DYNAMIC_FEE_ENABLED="true"
    fi

    ## Build Mainnet
    node "$ROOT_PATH/packages/js-deployer/bin/deployer" --configPath "$CONFIG_PATH_MAINNET" \
                                          --corePath "$BRIDGECHAIN_PATH" \
                                          --overwriteConfig \
                                          --network "mainnet" \
                                          --name "$CHAIN_NAME" \
                                          --p2pPort "$P2P_PORT" \
                                          --apiPort "$API_PORT" \
                                          --webhookPort "$WEBHOOK_PORT" \
                                          --jsonRpcPort "$JSON_RPC_PORT" \
                                          --dbHost "$DATABASE_HOST" \
                                          --dbPort "$DATABASE_PORT" \
                                          --dbUsername "$DB_USER" \
                                          --dbPassword "password" \
                                          --dbDatabase "$DATABASE_NAME_MAINNET" \
                                          --explorerUrl "$EXPLORER_URL" \
                                          --forgers "$FORGERS" \
                                          --feeStaticTransfer "$FEE_STATIC_TRANSFER" \
                                          --feeStaticVote "$FEE_STATIC_VOTE" \
                                          --feeStaticSecondSignature "$FEE_STATIC_SECOND_SIGNATURE" \
                                          --feeStaticDelegateRegistration "$FEE_STATIC_DELEGATE_REGISTRATION" \
                                          --feeStaticMultiSignature "$FEE_STATIC_MULTISIG_REGISTRATION" \
                                          --feeStaticIpfs "$FEE_STATIC_IPFS" \
                                          --feeStaticMultiPayment "$FEE_STATIC_MULTIPAYMENT" \
                                          --feeStaticDelegateResignation "$FEE_STATIC_DELEGATE_RESIGNATION" \
                                          --feeDynamicEnabled "$DYNAMIC_FEE_ENABLED" \
                                          --feeDynamicPoolMinFee "$FEE_DYNAMIC_POOL_MIN_FEE" \
                                          --feeDynamicBroadcastMinFee "$FEE_DYNAMIC_BROADCAST_MIN_FEE" \
                                          --feeDynamicBytesTransfer "$FEE_DYNAMIC_BYTES_TRANSFER" \
                                          --feeDynamicBytesSecondSignature "$FEE_DYNAMIC_BYTES_SECOND_SIGNATURE" \
                                          --feeDynamicBytesDelegateRegistration "$FEE_DYNAMIC_BYTES_DELEGATE_REGISTRATION" \
                                          --feeDynamicBytesVote "$FEE_DYNAMIC_BYTES_VOTE" \
                                          --feeDynamicBytesMultiSignature "$FEE_DYNAMIC_BYTES_MULTISIG_REGISTRATION" \
                                          --feeDynamicBytesIpfs "$FEE_DYNAMIC_BYTES_IPFS" \
                                          --feeDynamicBytesMultiPayment "$FEE_DYNAMIC_BYTES_MULTIPAYMENT" \
                                          --feeDynamicBytesDelegateResignation "$FEE_DYNAMIC_BYTES_DELEGATE_RESIGNATION" \
                                          --rewardHeight "$REWARD_HEIGHT_START" \
                                          --rewardPerBlock "$REWARD_PER_BLOCK" \
                                          --vendorFieldLength "$VENDORFIELD_LENGTH" \
                                          --blocktime "$BLOCK_TIME" \
                                          --token "$TOKEN" \
                                          --symbol "$SYMBOL" \
                                          --peers "$MAINNET_PEERS" \
                                          --prefixHash "$MAINNET_PREFIX" \
                                          --transactionsPerBlock "$TXS_PER_BLOCK" \
                                          --totalPremine "$TOTAL_PREMINE"

    ## Build Devnet
    node "$ROOT_PATH/packages/js-deployer/bin/deployer" --configPath "$CONFIG_PATH_DEVNET" \
                                          --corePath "$BRIDGECHAIN_PATH" \
                                          --overwriteConfig \
                                          --network "devnet" \
                                          --name "$CHAIN_NAME" \
                                          --p2pPort "$P2P_PORT" \
                                          --apiPort "$API_PORT" \
                                          --webhookPort "$WEBHOOK_PORT" \
                                          --jsonRpcPort "$JSON_RPC_PORT" \
                                          --dbHost "$DATABASE_HOST" \
                                          --dbPort "$DATABASE_PORT" \
                                          --dbUsername "$DB_USER" \
                                          --dbPassword "password" \
                                          --dbDatabase "$DATABASE_NAME_DEVNET" \
                                          --explorerUrl "$EXPLORER_URL" \
                                          --forgers "$FORGERS" \
                                          --feeStaticTransfer "$FEE_STATIC_TRANSFER" \
                                          --feeStaticVote "$FEE_STATIC_VOTE" \
                                          --feeStaticSecondSignature "$FEE_STATIC_SECOND_SIGNATURE" \
                                          --feeStaticDelegateRegistration "$FEE_STATIC_DELEGATE_REGISTRATION" \
                                          --feeStaticMultiSignature "$FEE_STATIC_MULTISIG_REGISTRATION" \
                                          --feeStaticIpfs "$FEE_STATIC_IPFS" \
                                          --feeStaticMultiPayment "$FEE_STATIC_MULTIPAYMENT" \
                                          --feeStaticDelegateResignation "$FEE_STATIC_DELEGATE_RESIGNATION" \
                                          --feeDynamicEnabled "$DYNAMIC_FEE_ENABLED" \
                                          --feeDynamicPoolMinFee "$FEE_DYNAMIC_POOL_MIN_FEE" \
                                          --feeDynamicBroadcastMinFee "$FEE_DYNAMIC_BROADCAST_MIN_FEE" \
                                          --feeDynamicBytesTransfer "$FEE_DYNAMIC_BYTES_TRANSFER" \
                                          --feeDynamicBytesSecondSignature "$FEE_DYNAMIC_BYTES_SECOND_SIGNATURE" \
                                          --feeDynamicBytesDelegateRegistration "$FEE_DYNAMIC_BYTES_DELEGATE_REGISTRATION" \
                                          --feeDynamicBytesVote "$FEE_DYNAMIC_BYTES_VOTE" \
                                          --feeDynamicBytesMultiSignature "$FEE_DYNAMIC_BYTES_MULTISIG_REGISTRATION" \
                                          --feeDynamicBytesIpfs "$FEE_DYNAMIC_BYTES_IPFS" \
                                          --feeDynamicBytesMultiPayment "$FEE_DYNAMIC_BYTES_MULTIPAYMENT" \
                                          --feeDynamicBytesDelegateResignation "$FEE_DYNAMIC_BYTES_DELEGATE_RESIGNATION" \
                                          --rewardHeight "$REWARD_HEIGHT_START" \
                                          --rewardPerBlock "$REWARD_PER_BLOCK" \
                                          --vendorFieldLength "$VENDORFIELD_LENGTH" \
                                          --blocktime "$BLOCK_TIME" \
                                          --token "$TOKEN" \
                                          --symbol "$SYMBOL" \
                                          --peers "$DEVNET_PEERS" \
                                          --prefixHash "$DEVNET_PREFIX" \
                                          --transactionsPerBlock "$TXS_PER_BLOCK" \
                                          --totalPremine "$TOTAL_PREMINE"

    ## Build Testnet
    node "$ROOT_PATH/packages/js-deployer/bin/deployer" --configPath "$CONFIG_PATH_TESTNET" \
                                          --corePath "$BRIDGECHAIN_PATH" \
                                          --overwriteConfig \
                                          --network "testnet" \
                                          --name "$CHAIN_NAME" \
                                          --p2pPort "$P2P_PORT" \
                                          --apiPort "$API_PORT" \
                                          --webhookPort "$WEBHOOK_PORT" \
                                          --jsonRpcPort "$JSON_RPC_PORT" \
                                          --dbHost "$DATABASE_HOST" \
                                          --dbPort "$DATABASE_PORT" \
                                          --dbUsername "$DB_USER" \
                                          --dbPassword "password" \
                                          --dbDatabase "$DATABASE_NAME_TESTNET" \
                                          --explorerUrl "$EXPLORER_URL" \
                                          --forgers "$FORGERS" \
                                          --feeStaticTransfer "$FEE_STATIC_TRANSFER" \
                                          --feeStaticVote "$FEE_STATIC_VOTE" \
                                          --feeStaticSecondSignature "$FEE_STATIC_SECOND_SIGNATURE" \
                                          --feeStaticDelegateRegistration "$FEE_STATIC_DELEGATE_REGISTRATION" \
                                          --feeStaticMultiSignature "$FEE_STATIC_MULTISIG_REGISTRATION" \
                                          --feeStaticIpfs "$FEE_STATIC_IPFS" \
                                          --feeStaticMultiPayment "$FEE_STATIC_MULTIPAYMENT" \
                                          --feeStaticDelegateResignation "$FEE_STATIC_DELEGATE_RESIGNATION" \
                                          --feeDynamicEnabled "$DYNAMIC_FEE_ENABLED" \
                                          --feeDynamicPoolMinFee "$FEE_DYNAMIC_POOL_MIN_FEE" \
                                          --feeDynamicBroadcastMinFee "$FEE_DYNAMIC_BROADCAST_MIN_FEE" \
                                          --feeDynamicBytesTransfer "$FEE_DYNAMIC_BYTES_TRANSFER" \
                                          --feeDynamicBytesSecondSignature "$FEE_DYNAMIC_BYTES_SECOND_SIGNATURE" \
                                          --feeDynamicBytesDelegateRegistration "$FEE_DYNAMIC_BYTES_DELEGATE_REGISTRATION" \
                                          --feeDynamicBytesVote "$FEE_DYNAMIC_BYTES_VOTE" \
                                          --feeDynamicBytesMultiSignature "$FEE_DYNAMIC_BYTES_MULTISIG_REGISTRATION" \
                                          --feeDynamicBytesIpfs "$FEE_DYNAMIC_BYTES_IPFS" \
                                          --feeDynamicBytesMultiPayment "$FEE_DYNAMIC_BYTES_MULTIPAYMENT" \
                                          --feeDynamicBytesDelegateResignation "$FEE_DYNAMIC_BYTES_DELEGATE_RESIGNATION" \
                                          --rewardPerBlock "$REWARD_PER_BLOCK" \
                                          --vendorFieldLength "$VENDORFIELD_LENGTH" \
                                          --blocktime "$BLOCK_TIME" \
                                          --token "$TOKEN" \
                                          --symbol "$SYMBOL" \
                                          --prefixHash "$TESTNET_PREFIX" \
                                          --transactionsPerBlock "$TXS_PER_BLOCK" \
                                          --totalPremine "$TOTAL_PREMINE"

    rm -rf "$BRIDGECHAIN_PATH"/packages/core/bin/config/{mainnet,devnet,testnet}/
    rm -rf "$BRIDGECHAIN_PATH"/packages/crypto/src/networks/{mainnet,devnet,testnet}/

    cp -R "$CONFIG_PATH_MAINNET/core" "$BRIDGECHAIN_PATH/packages/core/bin/config/mainnet"
    cp -R "$CONFIG_PATH_MAINNET/crypto" "$BRIDGECHAIN_PATH/packages/crypto/src/networks/mainnet"
    cp -R "$CONFIG_PATH_DEVNET/core" "$BRIDGECHAIN_PATH/packages/core/bin/config/devnet"
    cp -R "$CONFIG_PATH_DEVNET/crypto" "$BRIDGECHAIN_PATH/packages/crypto/src/networks/devnet"
    cp -R "$CONFIG_PATH_TESTNET/core" "$BRIDGECHAIN_PATH/packages/core/bin/config/testnet"
    cp -R "$CONFIG_PATH_TESTNET/crypto" "$BRIDGECHAIN_PATH/packages/crypto/src/networks/testnet"
    cp "$CONFIG_PATH_TESTNET/delegates.json" "$BRIDGECHAIN_PATH/packages/core/bin/config/testnet/"

    ## Update core properties
    local PACKAGE_JSON_PATH="$BRIDGECHAIN_PATH/packages/core/package.json"
    local PACKAGE_JSON=$(cat "$PACKAGE_JSON_PATH" | jq ".name = \"@${CORE_ALIAS}/core\"")
    local PACKAGE_JSON=$(echo "$PACKAGE_JSON" | jq ".description = \"Core of the ${CHAIN_NAME} Blockchain\"")
    local PACKAGE_JSON=$(echo "$PACKAGE_JSON" | jq ".bin[\"${CORE_ALIAS}\"] = \"./bin/run\"")
    local PACKAGE_JSON=$(echo "$PACKAGE_JSON" | jq "del(.bin.ark)")
    local PACKAGE_JSON=$(echo "$PACKAGE_JSON" | jq ".scripts[\"${CORE_ALIAS}\"] = \"./bin/run\"")
    local PACKAGE_JSON=$(echo "$PACKAGE_JSON" | jq "del(.scripts.ark)")
    local PACKAGE_JSON=$(echo "$PACKAGE_JSON" | jq ".oclif.bin = \"${CORE_ALIAS}\"")
    echo $PACKAGE_JSON
    rm "$PACKAGE_JSON_PATH"
    echo "$PACKAGE_JSON" > "$PACKAGE_JSON_PATH"

    if [ ! -z "$LICENSE_NAME" ]; then
        local YEAR=$(date +"%-Y")
        local LICENSE="Copyright (c) $YEAR $LICENSE_NAME"
        if [ ! -z "$LICENSE_EMAIL" ]; then
            local LICENSE="$LICENSE <$LICENSE_EMAIL>"
        fi
        sed -i -E "s/^(Copyright.+Ark Ecosystem.*)$/\1\n$LICENSE/g" "$BRIDGECHAIN_PATH/LICENSE"
    fi

    if [[ "$GIT_CORE_COMMIT" == "Y" ]]; then
        echo "Committing changes..."
        cd "$BRIDGECHAIN_PATH"
        if [[ "$GIT_USE_SSH" == "Y" ]]; then
            git config url."git@github.com:".insteadOf "https://github.com/"
        fi
        git config --global user.email "support@ark.io"
        git config --global user.name "ARK Deployer"
        git checkout -b chore/bridgechain-changes
        if [[ "$GIT_CORE_ORIGIN" != "" ]]; then
            local ALIAS=$(echo $CORE_ALIAS | tr -cs '[:alnum:]\r\n' '-' | tr '[:upper:]' '[:lower:]')
            read -r -d '' COMMANDS << EOM || true
shopt -s expand_aliases
alias ark="$BRIDGECHAIN_PATH_RAW/packages/core/bin/run"
echo 'alias $ALIAS="$BRIDGECHAIN_PATH_RAW/packages/core/bin/run"' >> ~/.bashrc

rm -rf "$BRIDGECHAIN_PATH_RAW"
git clone "$GIT_CORE_ORIGIN" "$BRIDGECHAIN_PATH_RAW" || FAILED="Y"
if [ "\$FAILED" == "Y" ]; then
    echo "Failed to fetch core repo with origin '$GIT_CORE_ORIGIN'"

    exit 1
fi

cd "$BRIDGECHAIN_PATH_RAW"
HAS_REMOTE=\$(git branch -a | fgrep -o "remotes/origin/chore/bridgechain-changes")
if [ ! -z "\$HAS_REMOTE" ]; then
    git checkout chore/bridgechain-changes
fi

YARN_SETUP="N"
while [ "$YARN_SETUP" == "N" ]; do
    YARN_SETUP="Y"
    rm -rf "\$HOME/.cache/yarn"
    yarn setup || YARN_SETUP="N"
    if [[ "$YARN_SETUP" == "N" ]]; then
        read -p "Failed to setup core. Retry? [Y/n]: " RETRY_SETUP
    fi
    if [[ "$RETRY_SETUP" =~ ^(no|n|N) ]]; then
        exit 1
    fi
done

rm -rf "\$HOME/.config/@${CORE_ALIAS}"
rm -rf "\$HOME/.config/@${CHAIN_NAME}"
rm -rf "\$HOME/.config/${CORE_ALIAS}-core"
EOM
            COMMANDS=$(echo "$COMMANDS" | tr '\n' '\r')
            sed -i "s/ARK Core/Core/gi" "$BRIDGECHAIN_PATH/install.sh"
            LINE_NO_START=$(($(egrep -hn "^while.+yarn global add @arkecosystem/core.+do" "$BRIDGECHAIN_PATH/install.sh" | cut -f1 -d:)+1))
            LINE_NO_END=$(($LINE_NO_START+4))
            sed -i "${LINE_NO_START},${LINE_NO_END}d" "$BRIDGECHAIN_PATH/install.sh"

            INSTALL_SH=$(sed -E "s#^while.+yarn global add @arkecosystem\/core.+do\$#$COMMANDS#gi" "$BRIDGECHAIN_PATH/install.sh" | tr '\r' '\n')
            rm "$BRIDGECHAIN_PATH/install.sh" && echo "$INSTALL_SH" > "$BRIDGECHAIN_PATH/install.sh"
        fi
        git add .
        git commit -m "chore: prepare new network config 🎉"
        if [[ "$GIT_CORE_ORIGIN" != "" ]]; then
            git remote set-url origin "$GIT_CORE_ORIGIN"
            git push --set-upstream origin chore/bridgechain-changes || local CANT_PUSH="Y"
            if [[ "$CANT_PUSH" == "Y" ]]; then
                error "Could not push Git changes to '$GIT_CORE_ORIGIN'"
            fi
        fi
    fi

    __core_setup

    app_output_passphrases "$@"

    app_install_core_configuration

    success "Bridgechain Installed!"
}

app_uninstall_core()
{
    process_core_stop "$@"

    heading "Uninstalling..."
    if [ ! -z "$CHAIN_NAME" ]; then
        pm2 delete "$CHAIN_NAME-relay" &>/dev/null || true
        pm2 delete "$CHAIN_NAME-forger" &>/dev/null || true
    fi

    rm -rf "$BRIDGECHAIN_PATH"

    success "Uninstall OK!"
}

app_output_passphrases()
{
    parse_core_args "$@"

    local CONFIG_PATH_MAINNET="$HOME/.bridgechain/mainnet/$CHAIN_NAME"
    local CONFIG_PATH_DEVNET="$HOME/.bridgechain/devnet/$CHAIN_NAME"
    local CONFIG_PATH_TESTNET="$HOME/.bridgechain/testnet/$CHAIN_NAME"

    echo "------------------------------------"
    echo "Passphrase Details"
    echo "------------------------------------"
    if [ -d "$CONFIG_PATH_MAINNET" ]; then
        local PASSPHRASE=$(sh -c "jq '.passphrase' $CONFIG_PATH_MAINNET/genesisWallet.json")
        local ADDRESS=$(sh -c "jq '.address' $CONFIG_PATH_MAINNET/genesisWallet.json")

        echo "Your MAINNET Genesis Details are:"
        echo "  Passphrase: $PASSPHRASE"
        echo "  Address: $ADDRESS"
        echo ""
        echo "You can find the genesis wallet passphrase in '$CONFIG_PATH_MAINNET/genesisWallet.json'"
        echo "You can find the delegates.json passphrase file at '$CONFIG_PATH_MAINNET/delegates.json'"
    else
        echo "Could not find your MAINNET config"
    fi
    echo "------------------------------------"

    if [ -d "$CONFIG_PATH_DEVNET" ]; then
        local PASSPHRASE=$(sh -c "jq '.passphrase' $CONFIG_PATH_DEVNET/genesisWallet.json")
        local ADDRESS=$(sh -c "jq '.address' $CONFIG_PATH_DEVNET/genesisWallet.json")

        echo "Your DEVNET Genesis Details are:"
        echo "  Passphrase: $PASSPHRASE"
        echo "  Address: $ADDRESS"
        echo ""
        echo "You can find the genesis wallet passphrase in '$CONFIG_PATH_DEVNET/genesisWallet.json'"
        echo "You can find the delegates.json passphrase file at '$CONFIG_PATH_DEVNET/delegates.json'"
    else
        echo "Could not find your DEVNET config"
    fi
    echo "------------------------------------"

    if [ -d "$CONFIG_PATH_TESTNET" ]; then
        local PASSPHRASE=$(sh -c "jq '.passphrase' $CONFIG_PATH_TESTNET/genesisWallet.json")
        local ADDRESS=$(sh -c "jq '.address' $CONFIG_PATH_TESTNET/genesisWallet.json")

        echo "Your TESTNET Genesis Details are:"
        echo "  Passphrase: $PASSPHRASE"
        echo "  Address: $ADDRESS"
        echo ""
        echo "You can find the genesis wallet passphrase in '$CONFIG_PATH_TESTNET/genesisWallet.json'"
        echo "You can find the delegates.json passphrase file at '$CONFIG_PATH_TESTNET/delegates.json'"
        echo "or '$BRIDGECHAIN_PATH/packages/core/bin/config/testnet/delegates.json'"
    else
        echo "Could not find your TESTNET config"
    fi
    echo "------------------------------------"
}

__core_setup()
{
    echo "Setting up Core..."

    __yarn_setup

    cd "$BRIDGECHAIN_PATH/packages/core/"
    ./bin/run config:cli --token "$CORE_ALIAS"
}

__yarn_setup()
{
    if [[ "$1" != "1" ]]; then
        cd "$BRIDGECHAIN_PATH"
    else
        error "Yarn setup failed. Trying again..."
        rm -rf "$HOME/.cache/yarn"
    fi
    yarn setup || __yarn_setup 1
}
