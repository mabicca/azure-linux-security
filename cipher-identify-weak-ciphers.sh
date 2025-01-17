#!/bin/bash

# Define the protocols and ciphers
protocols=("ssl2" "ssl3" "tls1" "tls1_1" "tls1_2" "tls1_3")
ciphers=($(openssl ciphers 'ALL:eNULL' | tr ':' ' '))

# Array to store weak ciphers
weak_ciphers=()

# Function to check ciphers for a given protocol
check_ciphers() {
  local protocol=$1
  for cipher in "${ciphers[@]}"; do
    if openssl s_client -connect "$2:$3" -cipher "$cipher" -"$protocol" < /dev/null > /dev/null 2>&1; then
      echo -e "$protocol:\t$cipher"
      identify_weak_ciphers "$protocol" "$cipher"
    fi
  done
}

# Function to identify weak ciphers
identify_weak_ciphers() {
  local protocol=$1
  local cipher=$2
  if [[ "$protocol" == "ssl2" || "$protocol" == "ssl3" || "$cipher" == *"RC4"* || "$cipher" == *"DES"* || "$cipher" == *"3DES"* || "$cipher" == *"NULL"* || "$cipher" == *"EXPORT"* ]]; then
    weak_ciphers+=("$protocol\t$cipher")
  fi
}

# Loop through the protocols and check ciphers
for protocol in "${protocols[@]}"; do
  check_ciphers "$protocol" "$1" "$2"
done

# Print summary of weak ciphers
if [ ${#weak_ciphers[@]} -gt 0 ]; then
  echo -e "\nSummary of Weak Ciphers Detected:"
  for weak_cipher in "${weak_ciphers[@]}"; do
    echo -e "$weak_cipher"
  done

  echo -e "\nSteps to Disable Weak Ciphers:"
  echo -e "1. Open the OpenSSL configuration file (usually located at /etc/ssl/openssl.cnf)."
  echo -e "2. Find the section for the protocol you want to configure (e.g., [ssl_defaults])."
  echo -e "3. Add or modify the CipherString directive to exclude weak ciphers. For example:"
  echo -e "   CipherString = DEFAULT:!RC4:!DES:!3DES:!NULL:!EXPORT"
  echo -e "4. Save the configuration file and restart the OpenSSL service."
else
  echo -e "\nNo weak ciphers detected."
fi
