#!/usr/bin/env bash

get_ip()
{
    # Specific to AWS EC2 instances. It uses AWS's Instance Metadata service to retrive the external IP. It falls back to using ifconfig on non EC2 machines.
    # More info: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html
    if AWS_IP=$(curl -f -s --connect-timeout 5 http://169.254.169.254/latest/meta-data/public-ipv4); then
        echo "$AWS_IP"
    elif IP=$(sudo ifconfig | fgrep "inet " | egrep -v "inet (addr:)?(127|192)\." | egrep -o "inet (addr:)?([0-9]+\.?){4}" | egrep -o "([0-9]+\.?){4}" | head -n 1); then
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
