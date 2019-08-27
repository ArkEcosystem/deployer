#!/usr/bin/env bash

TARGET_BRANCH="update/2.5.19"
BRIDGECHAIN_BIN=$(jq -r '.oclif.bin' "./packages/core/package.json")

update_bridgechain()
{
	run_checks

	info "Stopping core..."
	pm2 stop all

	info "Updating files..."
	merge_core_update || error_setting_target_branch

	check_for_target_branch

	info "Building Core..."
	YARN_SETUP="N"
	while [ "$YARN_SETUP" == "N" ]; do
	  YARN_SETUP="Y"
	  yarn setup || YARN_SETUP="N"
	done

	reset_plugins_js

	success "Done."
}

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
lila=$(tput setaf 4)
pink=$(tput setaf 5)
blue=$(tput setaf 6)
bold=$(tput bold)
reset=$(tput sgr0)
timestamp=$(date +%Y-%m-%d_%H-%M-%S)

heading()
{
    echo "${lila}==>${reset}${bold} $1${reset}"
}

success()
{
    echo "${green}==>${reset}${bold} $1${reset}"
}

info()
{
    echo "${blue}==>${reset}${bold} $1${reset}"
}

warning()
{
    echo "${yellow}==>${reset}${bold} $1${reset}"
}

error()
{
    echo "${red}==>${reset}${bold} $1${reset}"
}

check_for_core_directory()
{
	test -f "./packages/core/package.json" || FAILED="Y"
	if [ "$FAILED" == "Y" ]; then
	    error "You must run this script from inside of the Core directory."
	    exit 1
	fi
}

check_for_dirty_directory()
{
	if output=$(git status --untracked-files=no --porcelain) && [ -n "$output" ]; then
		git status
		warning "Please commit changes in this repository before continuing. If you'd like to discard them, run ${reset}${bold}${pink}git reset --hard${reset}"
		exit 1
	fi
}

merge_core_update()
{
	git reset --hard
	git branch --set-upstream-to=origin/"$TARGET_BRANCH" "$TARGET_BRANCH"
	git pull origin "$TARGET_BRANCH"
}

check_for_target_branch()
{
	local HAS_REMOTE=$(git branch -a | fgrep -o "remotes/origin/$TARGET_BRANCH")
	if [ -n "$HAS_REMOTE" ]; then
	    git checkout "$TARGET_BRANCH"
	else
		error "The target branch $TARGET_BRANCH doesn't exist. Please verify your TARGET_BRANCH and remote."
		exit 1
	fi
}

error_setting_target_branch()
{
	error "Something went wrong. Make sure that the branch $TARGET_BRANCH exists in the remote repository, and try again."
	exit 1
}

run_checks()
{
	check_for_core_directory
	check_for_dirty_directory
}

reset_plugins_js()
{
	local CONFIG_PATH="./packages/core/bin/config"
	local PUBLISHED_CONFIG_PATH="$HOME/.config/$BRIDGECHAIN_BIN-core"

	if [[ -f "$PUBLISHED_CONFIG_PATH/mainnet/plugins.js" ]]; then
	    mv "$PUBLISHED_CONFIG_PATH/mainnet/plugins.js" "$PUBLISHED_CONFIG_PATH/mainnet/plugins_2.3_$timestamp.js"
	    cp "$CONFIG_PATH/mainnet/plugins.js" "$PUBLISHED_CONFIG_PATH/mainnet/plugins.js"
	fi

	if [[ -f "$PUBLISHED_CONFIG_PATH/devnet/plugins.js" ]]; then
	    mv "$PUBLISHED_CONFIG_PATH/devnet/plugins.js" "$PUBLISHED_CONFIG_PATH/devnet/plugins_2.3_$timestamp.js"
	    cp "$CONFIG_PATH/devnet/plugins.js" "$PUBLISHED_CONFIG_PATH/devnet/plugins.js"
	fi

	if [[ -f "$PUBLISHED_CONFIG_PATH/testnet/plugins.js" ]]; then
	    mv "$PUBLISHED_CONFIG_PATH/testnet/plugins.js" "$PUBLISHED_CONFIG_PATH/testnet/plugins_2.3_$timestamp.js"
	    cp "$CONFIG_PATH/testnet/plugins.js" "$PUBLISHED_CONFIG_PATH/testnet/plugins.js"
	fi
}

read -p "This script will update Core to $TARGET_BRANCH. Would you like to continue? [y/N]: " choice
if [[ "$choice" =~ ^(yes|y|Y) ]]; then
	update_bridgechain
fi
