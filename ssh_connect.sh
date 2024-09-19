#!/bin/bash


# Function to find the SSH key pair file
find_key_pair_file() {
  local search_dir="$1"
  local key_name="$2"

  find "$search_dir" -type f -name "$key_name" 2>/dev/null
}

# Prompt user for the public IP address of the EC2 instance
read -p "Enter the public IP address of the EC2 instance: " ec2_ip
[ -z "$ec2_ip" ] && error_exit "Error: Public IP address cannot be empty."

# Ask the user whether to search for the SSH key pair file or provide the path manually
read -p "Do you want to search for the SSH key pair file automatically? (yes/no): " auto_search

if [[ "$auto_search" == "yes" ]]; then
  # Prompt user for the directory to search for the SSH key pair file
  read -p "Enter the directory to search for the SSH key pair file (e.g., /path/to/search): " search_dir
  [ -z "$search_dir" ] && error_exit "Error: Directory to search cannot be empty."

  # Prompt user for the name of the SSH key pair file
  read -p "Enter the name of the SSH key pair file (e.g., keypair.pem): " key_name
  [ -z "$key_name" ] && error_exit "Error: Key pair file name cannot be empty."

  # Search for the SSH key pair file
  key_path=$(find_key_pair_file "$search_dir" "$key_name")

  # Check if the key file was found
  if [ -z "$key_path" ]; then
    error_exit "Error: SSH key file not found in $search_dir"
  fi

  echo "Found SSH key file at: $key_path"

else
  # Prompt user for the path to the SSH key pair file directly
  read -p "Enter the path to the SSH key pair file (e.g., /path/to/keypair.pem): " key_path
  [ -z "$key_path" ] && error_exit "Error: Path to SSH key pair file cannot be empty."

  # Check if the SSH key file exists
  if [ ! -f "$key_path" ]; then
    error_exit "Error: SSH key file not found at $key_path"
  fi
fi

# Prompt user for the username for the EC2 instance
read -p "Enter the username for the EC2 instance (e.g., ubuntu): " username
[ -z "$username" ] && error_exit "Error: Username cannot be empty."

# Attempt to connect to the EC2 instance via SSH
echo "Connecting to $ec2_ip as $username..."
ssh -i "$key_path" "$username@$ec2_ip"

# Check if the SSH connection was successful
if [ $? -eq 0 ]; then
  echo "SSH connection successful."
else
  echo "SSH connection failed."
fi

