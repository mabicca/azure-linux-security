# Cipher-Check - version 1.1
# This script will check available ciphers enabled in a host
# Script can be executed using:
# sudo chmod +x cipher-check.sh
# sudo ./cipher-check host port (eg: sudo ./cipher-check example.com 443)
# Updated to use some parallel processing to speed it up on Jan 2025
#!/bin/bash

# Define the protocols and ciphers
protocols=("ssl2" "ssl3" "tls1" "tls1_1" "tls1_2" "tls1_3")
ciphers=($(openssl ciphers 'ALL:eNULL' | tr ':' ' '))

# Function to check ciphers for a given protocol
check_ciphers() {
  local protocol=$1
  for cipher in "${ciphers[@]}"; do
    openssl s_client -connect "$2:$3" -cipher "$cipher" -"$protocol" < /dev/null > /dev/null 2>&1 && echo -e "$protocol:\t$cipher" &
  done
  wait
}

# Loop through the protocols and check ciphers
for protocol in "${protocols[@]}"; do
  check_ciphers "$protocol" "$1" "$2"
done
