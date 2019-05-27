#!/usr/bin/env bash

get_ip()
{
    sudo ifconfig | fgrep "inet " | egrep -v "inet (127|192)\." | egrep -o "inet ([0-9]+\.?){4}" | awk '{print $2}' | head -n 1
}