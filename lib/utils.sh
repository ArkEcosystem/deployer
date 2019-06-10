#!/usr/bin/env bash

get_ip()
{
    IP=$(sudo ifconfig | fgrep "inet " | egrep -v "inet (addr:)?(127|192)\." | egrep -o "inet (addr:)?([0-9]+\.?){4}" | egrep -o "([0-9]+\.?){4}" | head -n 1)

    if [ ! -z "$IP" ]; then
        echo "$IP"
    else
        get_local_ip
    fi
}

get_local_ip()
{
    IP=$(sudo ifconfig | fgrep "inet " | egrep -v "inet (addr:)?(127)\." | egrep -o "inet (addr:)?([0-9]+\.?){4}" | egrep -o "([0-9]+\.?){4}" | head -n 1)

    if [ ! -z "$IP" ]; then
        echo "$IP"
    else
        echo "127.0.0.1"
    fi
}
