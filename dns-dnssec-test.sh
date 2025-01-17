# v1.0
# Script to test if DNSSEC is working using dig and a local DNS resolver in the box, you can always change the resolver manually here as well
# Simply run the script and the DNS server you want to test by specifying its ip address
#!/bin/bash
DNS=$1
dig sigok.verteiltesysteme.net @$1 -p 53
dig sigfail.verteiltesysteme.net @$1 -p 53
