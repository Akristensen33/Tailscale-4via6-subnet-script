#!/bin/bash

# Get the first IP address assigned to this device.
ip_address=$(hostname -I | awk '{print $1}')

# Check if an IP address was found.
if [[ -z "$ip_address" ]]; then
  echo "No IP address found."
  exit 1
fi

echo "Original IP address: $ip_address"

# Split the IP address at dots and change the last number to 0.
IFS='.' read -r -a ip_parts <<< "$ip_address"
ip_parts[3]=0
modified_ip_address="${ip_parts[0]}.${ip_parts[1]}.${ip_parts[2]}.0"

echo "Modified IP address: $modified_ip_address"

# Get the ID number from the user.
get_id() {
  read -p "Please enter the ID number: " id_num
  echo $id_num
}

# Execute tailscale debug command with the ID number and modified IP address.
debug_output=$(tailscale debug "$id_num" "$modified_ip_address"/24)
echo "Debug output: $debug_output"
# Assume that debug_output contains the necessary address directly.
route=$debug_output

echo "Announcing route: $route"

# Use the extracted route in the tailscale up command.
tailscale up --advertise-routes="$route"

#done.
