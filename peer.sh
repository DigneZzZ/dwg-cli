#!/bin/bash

# Проверить, установлена ли утилита qrencode
if ! command -v qrencode &> /dev/null; then
    echo "Утилита qrencode не установлена. Устанавливаю..."
    sudo apt-get update
    sudo apt-get install qrencode
fi

# Путь к файлу конфигурации
wg_conf_path="wireguard/wg0.conf"

# Получаем список пиров из файла конфигурации
peers=$(grep -oP '(?<=#).*$' $wg_conf_path)

# Выводим список пиров
echo "Список пиров в файле конфигурации $wg_conf_path:"
echo "$peers"

# Запрашиваем у пользователя имя пира
read -p "Введите имя пира, для которого нужно вывести информацию: " peer

# Путь к файлу конфигурации пира
peer_conf_path="wireguard/$peer/$peer.conf"

# Проверяем, что файл конфигурации пира существует
if [ -f $peer_conf_path ]; then
    # Выводим содержимое файла конфигурации пира
    echo "Содержимое файла конфигурации $peer_conf_path:"
    cat $peer_conf_path
else
    # Выводим сообщение об ошибке, если файл конфигурации пира не найден
    echo "Файл конфигурации $peer_conf_path не найден"
fi

# Сгенерировать QR-код на основе выбранного файла конфигурации
qrencode -t ansiutf8 < "$peer_conf_path"

