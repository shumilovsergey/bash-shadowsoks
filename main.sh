#!/bin/bash

#сценарий ручного выхода
function cleanup {
    clear
    echo " "
    echo "До скорой встречи!"
    exit 0
}
trap cleanup SIGINT

#проверка софта
echo " "
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

#проверка файла конфигурации
echo " "
script_folder=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if [ -f "$script_folder/shadowsocks.json" ]; then
    echo "Файл конфигурации найден!"
else
    echo "Файл конфигурации отсутствует!"

    echo "Введите адрес сервера:"
    read server_address

    echo "Введите номер порта:"
    read server_port

    echo "Введите пароль:"
    read password

    echo "Введите метод шифрования:"
    read encryption_method

    json_data="{\"server\": \"$server_address\", \"server_port\": \"$server_port\", \"password\": \"$password\", \"method\": \"$encryption_method\", \"local_port\": 1080, \"timeout\": 600, \"fast_open\": false}"

    echo "$json_data" > "$script_folder/shadowsocks.json"
fi

#выбор сетевого интерфейса
echo " "
echo "Введите номер сетевого интерфейса на котором нужно запустить VPN"
echo " "
network_services=$(networksetup -listallnetworkservices)

line_number=1
while IFS= read -r line; do
    echo "$line_number: $line"
    ((line_number++))
done <<< "$network_services"

read user_choice

selected_element=$(echo "$network_services" | sed -n "${user_choice}p")
echo " "
echo "VPN запущен на: $selected_element"

#включаем VPN на выбранном интерфейсе
networksetup -setsocksfirewallproxy $selected_element 127.0.0.1 1080
networksetup -setsocksfirewallproxystate $selected_element on

ss-local -c $script_folder/shadowsocks.json &

# Store the process ID of the VPN
vpn_pid=$!

# Wait for user input to stop VPN
echo " "
read -p "Нажмите Enter чтобы отключить VPN..."

# Stop VPN by killing the process
kill "$vpn_pid" > /dev/null 2>&1

networksetup -setsocksfirewallproxystate $selected_element off
clear
echo " "
echo "VPN выключен!"

