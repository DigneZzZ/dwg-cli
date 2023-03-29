#!/bin/bash

# Проверить, установлена ли утилита qrencode
if ! command -v qrencode &> /dev/null; then
    echo "Утилита qrencode не установлена. Устанавливаю..."
    sudo apt-get update
    sudo apt-get install qrencode
fi

# Путь к файлу конфигурации
wg_conf_path="wireguard/wg0.conf"

# Получаем список пиров из файла конфигурации и присваиваем им порядковые номера
peers=$(grep -oP '(?<=#).*$' $wg_conf_path | nl)

# Выводим список пиров с порядковыми номерами
printf "Список пиров в файле конфигурации %s:\n%s\n" "$wg_conf_path" "$peers"

# Запрашиваем у пользователя номер пира
printf "Введите номер пира, для которого нужно вывести информацию: "
read peer_number

# Получаем имя пира по номеру
peer=$(echo "$peers" | awk -v n=$peer_number '$1 == n {print $2}')

# Путь к файлу конфигурации пира
peer_conf_path="wireguard/$peer/$peer.conf"

# Проверяем, что файл конфигурации пира существует
if [ -f $peer_conf_path ]; then
    # Выводим содержимое файла конфигурации пира
    printf "Содержимое файла конфигурации %s:\n" "$peer_conf_path"
    printf "Чтобы подключиться по файлу, создайте файл peer.conf со следующим содержимым и импортируйте его в WireGuard"
    printf "========================================="
    cat $peer_conf_path
     printf "========================================="
    # Сгенерировать QR-код на основе выбранного файла конфигурации
qrencode -t ansiutf8 < "$peer_conf_path"
else
    # Выводим сообщение об ошибке, если файл конфигурации пира не найден
    printf "Файл конфигурации %s не найден\n" "$peer_conf_path"
fi



