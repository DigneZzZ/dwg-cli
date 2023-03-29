# dwg-cli

## DWG Project - Docker WireGuard - CLI (DWG-CLI) - Проект одного скрипта 
### Представляю вам лучшую сборку для самой быстрой настройки VPN сервера на WireGuard
### **Ad-WireGuard** = AdGuard with DoH DNS +  Wireguard with UI (wg-easy) + Unbound 


## Требования
* Чистый пустой сервер.
* Поддерживаемые операционные системы: **Ubuntu 20.04, 22.04; Debian 11, Centos 8,9**

Скрипт устанавливает все автоматически.
Все комментарии по скрипту внутри в комментариях


### [VDSina.ru](https://vdsina.ru/?partner=rwmhc7jbcg) Рекомендую VPS хостинг - по рефералке скидка 10%!!!: 	
1. Очень хорошая скорость (до 1гб/с)
2. Посуточные тарифы
3. Доступные тарифы мощных сборок.
4. Лояльность к VPN использованию серверов.
5. Очень приятный интерфейс,  ISP отдыхает.
### [Melbicom](https://melbicom.ru/?from=44619)
Достаточно хорошая стабильность и связь в 1гб/с (причем с гарантиями не менее 100мбит\с)
### [Pq.Hosting](https://pq.hosting/?from=45709)
Все критерии закрыты и 1Гб/с
### [Fornex](https://fornex.com/code/jwo1cg/)
Базовый вариант на котором хотел бы отметить своё внимание. Претензий нет, кроме как скорость 100мбит/сек. (но хочется отметить, что скорость эта достаточно стабильная!)

# Самая быстрая установка - 1 минута

Запусти команду на чистом сервере

```bash
apt update && apt install curl sudo git -y && curl -Of https://raw.githubusercontent.com/DigneZzZ/dwg-cli/main/setup.sh && chmod +x setup.sh && ./setup.sh
```

## Что установится:

0. Сначала установится Git, чтобы можно было скопировать мой репозиторий
1. Docker - последняя версия
2. Docker-compose - последняя версия
3. Wireguard - интерактивный режим введения количества пользователей (имена\количество)
4. AdGuard Home - интерактивный режим создания пользователя и пароля (можно оставить стандартным)
5. Unbound - все в стоке
6. apache2-utils - необходим для генерации хэш-паролей
7. ssh.sh - скрипт для смены порта SSH подключения
8. ufw.sh - скрипт для установки UFW Firewall.


## Автор:

👤 ** Alexey **
* Git: [DigneZzZ](https://github.com/DigneZzZ)
* Site: [OpeNode.RU](https://openode.ru)

## Скриншоты

### Adguard Web-UI
![image](https://user-images.githubusercontent.com/50312583/206703207-f3bd39f1-72c7-458c-9893-ad2126a0d47b.png)



## После установки

### WG-Easy web-ui:
yo.ur.ip.xx:51821 
И останется ввести пароль который задавали на момент установки


### AdGuard HOME 
#### Заходим после установки:
http://10.2.0.100/  

### Login: **admin** 
### Password: **admin**


# Предустановленный Adlists для Рунета в том числе:
### RU-Adlist
https://easylist-downloads.adblockplus.org/advblock.txt
### BitBlock
https://easylist-downloads.adblockplus.org/bitblock.txt
### Cntblock
https://easylist-downloads.adblockplus.org/cntblock.txt
### EasyList
https://easylist-downloads.adblockplus.org/easylist.txt
### Доп список от Шакала
https://schakal.ru/hosts/alive_hosts_ru_com.txt
### файл с разблокированными r.mail.ru и graph.facebook.com
https://schakal.ru/hosts/hosts_mail_fb.txt

### All DNS Servers
https://adguard-dns.io/kb/general/dns-providers/#cloudflare-dns

### DNS Perfomance list:
https://www.dnsperf.com/#!dns-resolvers
