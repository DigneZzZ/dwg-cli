#!/bin/bash

# Проверить, установлена ли утилита qrencode
if ! command -v qrencode &> /dev/null; then
    echo "Утилита qrencode не установлена. Устанавливаю..."
    sudo apt-get update
    sudo apt-get install qrencode
fi

# Получить список пиров из файла конфигурации
peers=$(awk '/^\[Peer\]/{print $0}' wireguard/wg0.conf)

# Вывести список пиров на экран
echo "Выберите пир для генерации QR-кода:"
echo "$peers"

# Запросить у пользователя, какой пир должен быть использован
read -p "Введите номер пира: " choice

# Определить, какой конфигурационный файл должен быть использован
config_file=$(echo "$peers" | sed -n "${choice}p" | awk '{print $2}')

# Проверить, существует ли файл конфигурации
if [ ! -f "$config_file" ]; then
  echo "Файл конфигурации $config_file не найден."
  exit 1
fi

# Сгенерировать QR-код на основе выбранного файла конфигурации
qrencode -t ansiutf8 < "$config_file"

# Вывести информацию из файла конфигурации для выбранного пира
echo "Информация для выбранного пира ($config_file):"
cat "$config_file"
