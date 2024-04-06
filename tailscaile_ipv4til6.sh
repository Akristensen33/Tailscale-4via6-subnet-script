#!/bin/bash


# Få den første IP-adresse tildelt til denne enhed.
ip_address=$(hostname -I | awk '{print $1}')

# Kontroller om en IP-adresse blev fundet.
if [[ -z "$ip_address" ]]; then
  echo "Ingen IP-adresse fundet."
  exit 1
fi

echo "Original IP-adresse: $ip_address"

# Opdel IP-adressen ved punktummer og ændre det sidste tal til 0.
IFS='.' read -r -a ip_parts <<< "$ip_address"
ip_parts[3]=0
modified_ip_address="${ip_parts[0]}.${ip_parts[1]}.${ip_parts[2]}.0"

echo "Ændret IP-adresse: $modified_ip_address"

# Få ID-nummeret fra brugeren.
id_num=$(get_id)

# Eksekverer tailscale debug-kommando med ID-nummeret og ændret IP-adresse.
debug_output=$(tailscale debug "$id_num" "$modified_ip_address"/24)
echo "Debug output: $debug_output"
# Antager at debug_output indeholder den nødvendige adresse direkte.
route=$debug_output

echo "Annoncerer rute: $route"

# Brug den ekstraherede rute i tailscale up-kommandoen.
tailscale up --advertise-routes="$route"
