#!/usr/bin/env bash

update_core_handle()
{
	update_core_resolve_vars

	if [ "$CHAIN_VERSION" == "$TARGET_VERSION" ]; then
		info "This chain is already up to date."
	else
		heading "Bridgechain version: $CHAIN_VERSION"
		read -p "Would you like to update Core to version $TARGET_VERSION? [y/N]: " choice

		if [[ "$choice" =~ ^(yes|y|Y) ]]; then

			process_core_stop

			update_core_add_upstream_remote

			update_core_merge_from_upstream

			update_core_resolve_conflicts

			heading "Applying migration updates..."

			update_core_change_block_reward_from_number_to_string

			update_core_update_package_json

			update_core_make_update_relay_script

			update_core_commit_changes

			heading "Done"

			heading "Building Core..."

			yarn setup

			update_core_reset_plugins_js

			update_core_prompt_to_push_changes

			success "Finished."

		fi
	fi
}

update_core_resolve_vars()
{
	TARGET_VERSION="2.5.19"
	BRIDGECHAIN_BIN=$(jq -r '.oclif.bin' "$BRIDGECHAIN_PATH/packages/core/package.json")
	CHAIN_VERSION=$(jq -r '.version' "$BRIDGECHAIN_PATH/packages/core/package.json")
	NETWORKS_PATH="$BRIDGECHAIN_PATH/packages/crypto/src/networks"
}

update_core_add_upstream_remote()
{
	heading "Fetching from upstream..."
	cd "$BRIDGECHAIN_PATH"
	git remote add upstream https://github.com/ArkEcosystem/core.git > /dev/null 2>&1 || true
	git fetch --tags upstream
}

update_core_merge_from_upstream()
{
	local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
	heading "Merging from upstream..."
	git checkout -b update/"$TARGET_VERSION" || git checkout -b update/"${TARGET_VERSION}_${timestamp}"
	git merge "$TARGET_VERSION" || true
	info "Done"
}


update_core_resolve_conflicts()
{
	heading "Resolving merge conflicts..."
	git checkout --ours "$NETWORKS_PATH/devnet/genesisBlock.json"
	git checkout --ours "$NETWORKS_PATH/devnet/milestones.json"
	git checkout --ours "$NETWORKS_PATH/mainnet/exceptions.json"
	git checkout --ours "$NETWORKS_PATH/mainnet/genesisBlock.json"
	git checkout --ours "$NETWORKS_PATH/mainnet/milestones.json"
	git checkout --ours "$NETWORKS_PATH/testnet/genesisBlock.json"
	git checkout --ours "$NETWORKS_PATH/testnet/milestones.json"
	git checkout --theirs packages/core/bin/config/mainnet/plugins.js
	git checkout --theirs packages/core/bin/config/devnet/plugins.js
	git checkout --theirs packages/core/bin/config/testnet/plugins.js
	git checkout --ours install.sh
	info "Done"
}

update_core_change_block_reward_from_number_to_string()
{
	jq '.reward = "0"' "$NETWORKS_PATH/mainnet/genesisBlock.json" \
	> "$NETWORKS_PATH/mainnet/genesisBlock.json.tmp" \
	&& mv "$NETWORKS_PATH/mainnet/genesisBlock.json.tmp" \
	"$NETWORKS_PATH/mainnet/genesisBlock.json"

	jq '.reward = "0"' "$NETWORKS_PATH/devnet/genesisBlock.json" \
	> "$NETWORKS_PATH/devnet/genesisBlock.json.tmp" \
	&& mv "$NETWORKS_PATH/devnet/genesisBlock.json.tmp" \
	"$NETWORKS_PATH/devnet/genesisBlock.json"

	jq '.reward = "0"' "$NETWORKS_PATH/testnet/genesisBlock.json" \
	> "$NETWORKS_PATH/testnet/genesisBlock.json.tmp" \
	&& mv "$NETWORKS_PATH/testnet/genesisBlock.json.tmp" \
	"$NETWORKS_PATH/testnet/genesisBlock.json"
}

update_core_update_package_json()
{
	git checkout --ours packages/core/package.json && cat packages/core/package.json \
	>| packages/core/package.json.old && git checkout --theirs packages/core/package.json

	package_temp="packages/core/package.json.old"

	jq --arg var "$(jq -r '.name' "$package_temp")" '.name = $var' packages/core/package.json \
	>| packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json

	jq --argjson var "$(jq -r '.bin' "$package_temp")" '.bin = $var' packages/core/package.json \
	>| packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json

	jq --argjson var "$(jq -r '.bin' "$package_temp")" '.scripts += $var' packages/core/package.json \
	>| packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json

	jq --arg var "$(jq -r '.description' "$package_temp")" '.description = $var' packages/core/package.json \
	>| packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json

	jq --arg var "$BRIDGECHAIN_BIN" '.oclif.bin = $var' packages/core/package.json \
	>| packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json

	rm "$package_temp"
}

update_core_make_update_relay_script()
{
	local current_branch=$(git rev-parse --abbrev-ref HEAD)

	mkdir -p "$BRIDGECHAIN_PATH/upgrade/$TARGET_VERSION/"

	sed "s@REPLACE_WITH_TARGET_BRANCH@$current_branch@g" "$ROOT_PATH/app/update-core-relay.sh" \
	> "$BRIDGECHAIN_PATH/upgrade/$TARGET_VERSION/update.sh"
	
	git add "$BRIDGECHAIN_PATH/upgrade/$TARGET_VERSION/update.sh"
}

update_core_commit_changes()
{
	git add install.sh
	git add packages/core/bin/config/mainnet/plugins.js
	git add packages/core/bin/config/testnet/plugins.js
	git add packages/core/bin/config/devnet/plugins.js
	git add packages/core/package.json
	git add packages/crypto/src/networks/devnet/genesisBlock.json
	git add packages/crypto/src/networks/devnet/milestones.json
	git add packages/crypto/src/networks/mainnet/exceptions.json
	git add packages/crypto/src/networks/mainnet/genesisBlock.json
	git add packages/crypto/src/networks/mainnet/milestones.json
	git add packages/crypto/src/networks/testnet/genesisBlock.json
	git add packages/crypto/src/networks/testnet/milestones.json

	git commit --no-verify -m "chore: upgrade to core v$TARGET_VERSION"
}

update_core_reset_plugins_js()
{
	local CONFIG_PATH="$BRIDGECHAIN_PATH/packages/core/bin/config"
	local PUBLISHED_CONFIG_PATH="$HOME/.config/$BRIDGECHAIN_BIN-core"

	mv "$PUBLISHED_CONFIG_PATH"/mainnet/plugins.js "$PUBLISHED_CONFIG_PATH"/mainnet/plugins.js.bkp
	mv "$PUBLISHED_CONFIG_PATH"/devnet/plugins.js "$PUBLISHED_CONFIG_PATH"/devnet/plugins.js.bkp
	mv "$PUBLISHED_CONFIG_PATH"/testnet/plugins.js "$PUBLISHED_CONFIG_PATH"/testnet/plugins.js.bkp

	cp "$CONFIG_PATH"/mainnet/plugins.js "$PUBLISHED_CONFIG_PATH"/mainnet/plugins.js
	cp "$CONFIG_PATH"/devnet/plugins.js "$PUBLISHED_CONFIG_PATH"/devnet/plugins.js
	cp "$CONFIG_PATH"/testnet/plugins.js "$PUBLISHED_CONFIG_PATH"/testnet/plugins.js
}

update_core_prompt_to_push_changes()
{
	read -p "Your bridgechain has been updated! Wou like to push it to your git repository? [y/N]: " choice

	if [[ "$choice" =~ ^(yes|y|Y) ]]; then
		git push --no-verify --set-upstream origin update/"$TARGET_VERSION"
	fi
}
