#!/bin/bash

printf 'Select the Interface to perform the Attack:\n'

# Get interfaces (improved column parsing)
mapfile -t interfaces < <(ip -br link | grep -v -e docker0 -e lo | awk '{print $1}')

# List interfaces with numbers
for i in "${!interfaces[@]}"; do  # Use array indices
    printf '%d:\t%s\n' "$i"    "${interfaces[i]}"
done

# Get user selection
read -p "Enter interface number: " selection

# Validate input
if [[ "$selection" =~ ^[0-${!interfaces[@]}]+$ ]] && [ "$selection" -lt "${#interfaces[@]}" ]; then
    selected_iface="${interfaces[selection]}"
    echo "Selected interface: $selected_iface"
    ./changeIfaceMode.sh $selected_iface 
    # Add your attack logic here
else
    echo "Invalid selection!" >&2
    exit 1
fi
