#!/bin/bash

# Function to handle script termination
function cleanup {
    echo "Goodbye!"
    exit 0
}

# Register the cleanup function to be called on script exit
trap cleanup SIGINT

if command -v brew &> /dev/null; then
    echo "Homebrew установлен!"
else
    echo "Homebrew не установлен!"
    echo "Вот их оф сайт - https://brew.sh/"
    exit 1
fi

error_message=$(ss-local 2>&1)
if [[ $error_message == *"path"* ]]; then
    echo "shadowsocks-libev установлен!"
else
    echo "shadowsocks-libev не установлен!"
    echo "Чтобы установить вводи в терминал команду:"
    echo "brew install shadowsocks-libev"
    exit 1
fi






# Prompt the user to enter an IP address
# read -p "Enter an IP address to ping: " ip_address

# Start pinging the IP address continuously
# while true; do
#     ping -c 1 $ip_address > /dev/null
#     if [[ $? -eq 0 ]]; then
#         echo "Ping successful!"
#     else
#         echo "Ping failed!"
#     fi
# done





