# lab wordpress & crowdsec

## quick start (debian 13 trixie):

```
$ sudo apt update && sudo apt install -y git
$ git clone https://github.com/bonk-dev/semestr5-cyber.git
$ cd semestr5-cyber/wordpress-lab
$ ./setup.sh
```

po zakończeniu skryptu cały lab jest uruchomiony. 
W terminalu powinny się wyświetlić dane logowania do wordpressa, który jest automatycznie konfigurowany.

żeby sie zalogowac najlepiej wchodzić prosto na:
`http://adres_maszyny/wp-login.php`

## uruchomienie ataków z poziomu kontenera attacker

katalog `attacker` jest zamontowany w kontenerze attacker pod ścieżką `/tools/`.

kontener attacker pozwala na łatwe korzystanie z wielu adresów IP.
Ataki można przeprowadzać z hosta, ale wtedy crowdsec zablokuje adres hosta i kaplica

### atak bruteforce z jednego adresu IP:

```
$ sudo docker compose exec attacker /tools/bruteforce-single-ip.sh
1: 200
2: 200
3: 200
4: 200
5: 200
6: 200
7: 200
8: 200
9: 200
10: 200
11: 200
12: 200
13: 200
14: 200
15: 403
16: 403
[...]
```

od okolo 15 żądania odpowiedź jest odrzucana. Weryfikacja:

```
$ sudo docker compose exec crowdsec cscli alerts list
╭────┬────────────────┬────────────────────────────────────┬─────────┬────┬───────────┬──────────────────────┬──────────╮
│ ID │      value     │               reason               │ country │ as │ decisions │      created_at      │   kind   │
├────┼────────────────┼────────────────────────────────────┼─────────┼────┼───────────┼──────────────────────┼──────────┤
│ 2  │ Ip:10.11.4.254 │ LePresidente/http-generic-403-bf   │         │    │ ban:1     │ 2026-11-24T20:44:26Z │ crowdsec │
│ 1  │ Ip:10.11.4.254 │ crowdsecurity/http-bf-wordpress_bf │         │    │ ban:1     │ 2026-11-24T20:44:25Z │ crowdsec │
```

### atak sqli

```
$ sudo docker compose exec attacker /tools/sqli-attempt.sh
403
403
403
403
403
403
403
403
403
403
koniec ataku
```

od pierwszego ataku poiwnno być 403 i alert:

```
$ sudo docker compose exec crowdsec cscli alerts list
╭────┬────────────────┬───────────────────────────────────────────────────────┬─────────┬────┬───────────┬──────────────────────┬──────────╮
│ ID │      value     │                         reason                        │ country │ as │ decisions │      created_at      │   kind   │
├────┼────────────────┼───────────────────────────────────────────────────────┼─────────┼────┼───────────┼──────────────────────┼──────────┤
│ 22 │ Ip:10.11.4.253 │ anomaly score block: sql_injection: 10, anomaly: 10,  │         │    │           │ 2026-11-24T21:17:51Z │ waf      │
│ 21 │ Ip:10.11.4.253 │ anomaly score block: sql_injection: 10, anomaly: 10,  │         │    │           │ 2026-11-24T21:17:51Z │ waf      │
│ 20 │ Ip:10.11.4.253 │ anomaly score block: sql_injection: 10, anomaly: 10,  │         │    │           │ 2026-11-24T21:17:51Z │ waf      │
│ 19 │ Ip:10.11.4.253 │ anomaly score block: sql_injection: 10, anomaly: 10,  │         │    │           │ 2026-11-24T21:17:51Z │ waf      │
│ 18 │ Ip:10.11.4.253 │ anomaly score block: sql_injection: 10, anomaly: 10,  │         │    │           │ 2026-11-24T21:17:51Z │ waf      │
│ 17 │ Ip:10.11.4.253 │ anomaly score block: sql_injection: 10, anomaly: 10,  │         │    │           │ 2026-11-24T21:17:51Z │ waf      │
│ 16 │ Ip:10.11.4.253 │ crowdsecurity/appsec-native                           │         │    │ ban:1     │ 2026-11-24T21:16:13Z │ crowdsec │
│ 15 │ Ip:10.11.4.253 │ anomaly score block: sql_injection: 10, anomaly: 10,  │         │    │           │ 2026-11-24T21:17:51Z │ waf      │
│ 14 │ Ip:10.11.4.253 │ anomaly score block: sql_injection: 10, anomaly: 10,  │         │    │           │ 2026-11-24T21:17:51Z │ waf      │
│ 13 │ Ip:10.11.4.253 │ anomaly score block: sql_injection: 10, anomaly: 10,  │         │    │           │ 2026-11-24T21:17:51Z │ waf      │
│ 12 │ Ip:10.11.4.253 │ anomaly score block: sql_injection: 10, anomaly: 10,  │         │    │           │ 2026-11-24T21:17:51Z │ waf      │
╰────┴────────────────┴───────────────────────────────────────────────────────┴─────────┴────┴───────────┴──────────────────────┴──────────╯
```

oraz decyzja (ban):

```
$ sudo docker compose exec crowdsec cscli decisions list
╭────┬──────────┬────────────────┬─────────────────────────────┬────────┬─────────┬────┬────────┬────────────┬──────────╮
│ ID │  Source  │   Scope:Value  │            Reason           │ Action │ Country │ AS │ Events │ expiration │ Alert ID │
├────┼──────────┼────────────────┼─────────────────────────────┼────────┼─────────┼────┼────────┼────────────┼──────────┤
│ 2  │ crowdsec │ Ip:10.11.4.253 │ crowdsecurity/appsec-native │ ban    │         │    │ 6      │ 3h59m10s   │ 16       │
╰────┴──────────┴────────────────┴─────────────────────────────┴────────┴─────────┴────┴────────┴────────────┴──────────╯
```

## tryb bypass

żeby wyłączyć ochronę crowdsec wystarczy zabic kontener:

```
$ sudo docker compose stop crowdsec
[+] stop 1/1
 ✔ Container wordpress-lab-crowdsec-1 Stopped   
```

wtedy dowolny atak powinien przechodzić i zwracać kod `200`.

żeby wznowić ochronę wystarczy podnieść kontroler:
```
$ sudo docker compose start crowdsec
[+] start 1/1
 ✔ Container wordpress-lab-crowdsec-1 Started 
```

po chwili ataki powinny być znowu blokowane

## czyszczenie alertów i decyzji

alerty i decyzje (bany) można wyczyścić:

```
$ sudo docker compose exec crowdsec cscli decisions delete --all
$ sudo docker compose exec crowdsec cscli alerts delete --all
```
