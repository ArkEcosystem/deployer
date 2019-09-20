#!/usr/bin/env bash

get_ip()
{
if AWS_IP=$(curl -f -s --connect-timeout 5 http://169.254.169.254/2009-04-04/meta-data/public-ipv4); then
    echo "$AWS_IP"
else
    IP=$(sudo ifconfig | fgrep "inet " | egrep -v "inet (addr:)?(127|192)\." | egrep -o "inet (addr:)?([0-9]+\.?){4}" | egrep -o "([0-9]+\.?){4}" | head -n 1)

    if [ ! -z "$IP" ]; then
        echo "$IP"
    else
        get_local_ip
    fi
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
