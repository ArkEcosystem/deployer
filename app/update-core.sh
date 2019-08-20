#!/usr/bin/env bash

update_core_handle()
{
	update_core_resolve_vars

	update_core_add_upstream_remote || true

	update_core_merge_from_upstream || true

	update_core_resolve_conflicts

	heading "Applying migration updates..."

	update_core_change_block_reward_from_number_to_string

	update_core_update_package_json

	update_core_commit_changes

	heading "Done"

	heading "Building Core..."

	yarn setup

}

update_core_resolve_vars()
{
	UPSTREAM_VERSION=$(curl -s https://raw.githubusercontent.com/ArkEcosystem/core/master/packages/core/package.json | jq -r '.version')
	BRIDGECHAIN_BIN=$(jq -r '.oclif.bin' "$BRIDGECHAIN_PATH/packages/core/package.json")
	CHAIN_VERSION=$(jq -r '.version' "$BRIDGECHAIN_PATH/packages/core/package.json")
	NETWORKS_PATH="$BRIDGECHAIN_PATH/packages/crypto/src/networks"
}

update_core_check_bridgechain_version()
{
	heading "Bridgechain version: $CHAIN_VERSION"
	read -p "Would you like to update Core to version "$UPSTREAM_VERSION"? [y/N]: " choice

	if [[ "$choice" =~ ^(yes|y|Y) ]]; then
	    choice=""
	    while [[ ! "$choice" =~ ^(yes|y|Y) ]] ; do
	    	#
	        read -p "Proceed? [y/N]: " choice
	    done
	fi
	info "Done"
}

update_core_add_upstream_remote()
{
	heading "Fetching from upstream..."
	cd "$BRIDGECHAIN_PATH"
	git remote add upstream https://github.com/ArkEcosystem/core.git > /dev/null 2>&1
	git fetch upstream
}

update_core_merge_from_upstream()
{
	heading "Merging from upstream..."
	git checkout -b update/"$UPSTREAM_VERSION"
	git merge upstream/master > /dev/null 2>&1
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

	oldPackageJson="packages/core/package.json.old"

	jq --arg var "$(jq -r '.name' "$oldPackageJson")" '.name = $var' packages/core/package.json \
	>| packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json

	jq --argjson var "$(jq -r '.bin' "$oldPackageJson")" '.bin = $var' packages/core/package.json \
	>| packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json

	jq --argjson var "$(jq -r '.bin' "$oldPackageJson")" '.scripts += $var' packages/core/package.json \
	>| packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json

	jq --arg var "$(jq -r '.description' "$oldPackageJson")" '.description = $var' packages/core/package.json \
	>| packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json

	jq --arg var "$BRIDGECHAIN_BIN" '.oclif.bin = $var' packages/core/package.json \
	>| packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json

	# do we need this step?
	# sed "s/@arkecosystem/@$BRIDGECHAIN_BIN/g" packages/core/package.json > packages/core/package.json.tmp \
	# && mv packages/core/package.json.tmp packages/core/package.json
}

update_core_commit_changes()
{
	git add install.sh
	git add packages/core/bin/config/mainnet/plugins.js
	git add packages/core/bin/config/testnet/plugins.js
	git add packages/core/package.json
	git add packages/crypto/src/networks/devnet/genesisBlock.json
	git add packages/crypto/src/networks/devnet/milestones.json
	git add packages/crypto/src/networks/mainnet/exceptions.json
	git add packages/crypto/src/networks/mainnet/genesisBlock.json
	git add packages/crypto/src/networks/mainnet/milestones.json
	git add packages/crypto/src/networks/testnet/genesisBlock.json
	git add packages/crypto/src/networks/testnet/milestones.json

	git commit --no-verify -m "chore: upgrade to core v$UPSTREAM_VERSION"

	# git push --no-verify
}
