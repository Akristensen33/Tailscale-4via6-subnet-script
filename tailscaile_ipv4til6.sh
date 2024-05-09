#!/bin/bash

# Function to get the ID number from the user.
get_id() {
  read -p "Please enter the ID number: " id_num
  echo $id_num
}

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
old_ifs=$IFS  # Save old IFS
IFS='.'       # Set IFS to dot for joining parts
ip_parts[3]=0
modified_ip_address="${ip_parts[0]}.${ip_parts[1]}.${ip_parts[2]}.0"
IFS=$old_ifs  # Restore original IFS

echo "Modified IP address: $modified_ip_address"

# Get ID number and execute tailscale debug command to generate IPv6 subnet route.
id_num=$(get_id)  # Call function to get ID number
if ! ipv6_route=$(tailscale debug via "$id_num" "$modified_ip_address"/24); then
  echo "Failed to generate IPv6 route."
  exit 1
fi

echo "IPv6 Subnet Route: $ipv6_route"

# Use the generated IPv6 route in the tailscale up command.
if ! tailscale up --advertise-routes="$ipv6_route"; then
  echo "Failed to advertise routes."
  exit 1
fi

echo "Configuration complete."
