#!/bin/bash

printf 'Select the Interface to perform the Attack:\n'

mapfile -t interfaces < <(ip -br link | grep -v -e docker0 -e lo | awk '{print $1}')

for i in "${!interfaces[@]}"; do  # Use array indices
    printf '%d:\t%s\n' "$i"    "${interfaces[i]}"
done

read -p "Enter interface number: " selection

if [[ "$selection" =~ ^[0-${!interfaces[@]}]+$ ]] && [ "$selection" -lt "${#interfaces[@]}" ]; then
    selected_iface="${interfaces[selection]}"
    echo "Selected interface: $selected_iface"

    bash changeIfaceMode.sh $selected_iface 

else
    echo "Invalid selection!" >&2
    exit 1
fi
