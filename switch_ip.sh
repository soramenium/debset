#!/bin/bash

switch_ip() {
    # Znajdź pierwszy aktywny interfejs fizyczny (pomijamy lo)
    local iface
    iface=$(ip -o link show | awk -F': ' '/enp/ {print $2; exit}')

    if [ -z "$iface" ]; then
        echo "Nie znaleziono interfejsu enp*"
        return 1
    fi

    local mode=$1

    if [ "$mode" == "dhcp" ]; then
        echo "Przełączanie $iface na DHCP..."
        sudo dhclient -r $iface
        sudo dhclient $iface
        echo "DHCP włączone na $iface."

    elif [ "$mode" == "static" ]; then
        local ip=$2
        local netmask=$3
        local gateway=$4

        if [ -z "$ip" ] || [ -z "$netmask" ] || [ -z "$gateway" ]; then
            echo "Użycie: switch_ip static <IP> <NETMASK> <GATEWAY>"
            return 1
        fi

        echo "Ustawianie statycznego IP $ip na $iface..."
        sudo ip addr flush dev $iface
        sudo ip addr add $ip/$netmask dev $iface
        sudo ip route add default via $gateway dev $iface
        echo "Statyczne IP ustawione na $iface."

    else
        echo "Nieznany tryb. Użyj: dhcp lub static"
        return 1
    fi
}