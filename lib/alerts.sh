#!/usr/bin/env bash

readonly red=$(tput setaf 1)
readonly green=$(tput setaf 2)
readonly yellow=$(tput setaf 3)
readonly lila=$(tput setaf 4)
readonly pink=$(tput setaf 5)
readonly blue=$(tput setaf 6)
readonly white=$(tput setaf 7)
readonly black=$(tput setaf 8)

readonly bgRed=$(tput setab 1)
readonly bgGreen=$(tput setab 2)
readonly bgYellow=$(tput setab 3)
readonly bgLila=$(tput setab 4)
readonly bgPink=$(tput setab 5)
readonly bgBlue=$(tput setab 6)
readonly bgWhite=$(tput setab 7)
readonly bgBlack=$(tput setab 8)

readonly bold=$(tput bold)
readonly reset=$(tput sgr0)

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

heading_solid()
{
    echo "${bgBlack}${lila}==>${bold} $1${reset}"
}

success_solid()
{
    echo "${bgBlack}${green}==>${bold} $1${reset}"
}

info_solid()
{
    echo "${bgBlack}${blue}==>${bold} $1${reset}"
}

warning_solid()
{
    echo "${bgBlack}${yellow}==>${bold} $1${reset}"
}

error_solid()
{
    echo "${bgBlack}${red}==>${bold} $1${reset}"
}
