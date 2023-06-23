#!/bin/bash

if grep -q "VERSION_ID=\"10\"" /etc/os-release; then
  echo "Этот скрипт не может быть выполнен на Debian 10."
  exit 1
fi

# Здесь идет код скрипта, который должен быть выполнен на всех системах, кроме Debian 10

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Проверяем, выполняется ли скрипт от имени пользователя root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Запустите скрипт с правами root${NC}"
  exit
fi

# Проверяем, установлен ли Docker
if [ -x "$(command -v docker)" ]; then
  echo -e "${GREEN}Docker уже установлен${NC}"
else
  # Проверяем, какое распределение используется, и устанавливаем необходимые зависимости
  if [ -f /etc/debian_version ]; then
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
  elif [ -f /etc/redhat-release ]; then
    dnf install -y dnf-plugins-core
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    dnf install -y curl
  else
    echo -e "${RED}Неподдерживаемое распределение${NC}"
    exit
  fi

  # Устанавливаем Docker
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh

  # Запускаем и включаем службу Docker
  systemctl start docker
  systemctl enable docker

  echo -e "${GREEN}Docker успешно установлен${NC}"
fi

# Проверка наличия docker-compose
if command -v docker-compose &> /dev/null
then
    printf "${GREEN}Docker Compose уже установлен\n${NC}"
else
    # Установка docker-compose
    curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose &&
    chmod +x /usr/local/bin/docker-compose  

    # Проверка успешности установки
    if [ $? -eq 0 ]; then
        printf "${GREEN}Установка Docker Compose завершена успешно\n${NC}"
    else
        printf "${GREEN}Ошибка при установке Docker Compose\n${NC}"
        printf "${YELLOW}Хотите продолжить выполнение скрипта? (y/n): ${NC}"
        read choice
        case "$choice" in
            y|Y )
                printf "${GREEN}Продолжение выполнения скрипта\n${NC}"
                ;;
            n|N )
                printf "${RED}Завершение выполнения скрипта\n${NC}"
                exit 1
                ;;
            * )
                printf "${RED}Неверный выбор. Завершение выполнения скрипта\n${NC}"
                exit 1
                ;;
        esac
    fi
fi

# Проверка актуальности версии docker-compose
#LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "tag_name" | cut -d\" -f4)
#INSTALLED_VERSION=$(docker-compose version --short 2>/dev/null)

#if [ "$LATEST_VERSION" = "$INSTALLED_VERSION" ]; then
#    printf "${GREEN}Установленная версия Docker Compose (%s) является актуальной\n" "$INSTALLED_VERSION${NC}"
##else
#    printf "${YELLOW}Установленная версия Docker Compose (%s) не является актуальной. Последняя версия: %s\n" "$INSTALLED_VERSION" "$LATEST_VERSION${NC}"
#    
#fi


# Устанавливаем редактор Nano
if ! command -v nano &> /dev/null
then
    read -p "Хотите установить текстовый редактор Nano? (y/n) " INSTALL_NANO
    if [ "$INSTALL_NANO" == "y" ]; then
        apt-get update
        apt-get install -y nano
    fi
else
    echo "Текстовый редактор Nano уже установлен."
fi

# Проверяем есть ли контейнер с именем wireguard

printf "${BLUE} Сейчас проверим свободен ли порт 51821 и не установлен ли другой wireguard.\n${NC}"

if [[ $(docker ps -q --filter "name=wireguard") ]]; then
    printf "!!!!>>> Другой Wireguard контейнер уже запущен, и вероятно занимает порт 51820. Пожалуйста удалите его и запустите скрипт заново\n "
    printf "${RED} !!!!>>> Завершаю скрипт! \n${NC}"
    exit 1
else
    printf "Wireguard контейнер не запущен в докер. Можно продолжать\n"
    # Проверка, запущен ли контейнер, использующий порт 51821
    if lsof -Pi :51820 -sTCP:LISTEN -t >/dev/null ; then
        printf "${RED}!!!!>>> Порт 51820 уже используется контейнером.!\n ${NC}"
        if docker ps --format '{{.Names}} {{.Ports}}' | grep -q "wireguard.*:51820->" ; then
            printf "WireGuard контейнер использует порт 51820. Хотите продолжить установку? (y/n): "
            read -r choice
            case "$choice" in 
              y|Y ) printf "Продолжаем установку...\n" ;;
              n|N ) printf "${RED} ******* Завершаю скрипт!\n ${NC}" ; exit 1;;
              * ) printf "${RED}Некорректный ввод. Установка остановлена.${NC}" ; exit 1;;
            esac
        else
            printf "${RED} ******* Завершаю скрипт!\n ${NC}"
            exit 1
        fi
    else
        printf "Порт 51820 свободен.\n"
        printf "Хотите продолжить установку? (y/n): "
        read -r choice
        case "$choice" in 
          y|Y ) printf "Продолжаем установку...\n" ;;
          n|N ) printf "Установка остановлена.${NC}" ; exit 1;;
          * ) printf "${RED}Некорректный ввод. Установка остановлена.${NC}" ; exit 1;;
        esac
    fi
fi

printf "${GREEN} Этап проверки докера закончен, можно продолжить установку\n${NC}"



##### ЗДЕСЬ БУДЕТ КОД ДЛЯ КОРРЕКТИРОВКИ COMPOSE
# Получаем внешний IP-адрес
MYHOST_IP=$(curl -s https://checkip.amazonaws.com/) 

# Записываем IP-адрес в файл docker-compose.yml с меткой MYHOSTIP
sed -i -E  "s/- SERVERURL=.*/- SERVERURL=$MYHOST_IP/g" docker-compose.yml


echo "Выберите способ настройки PEERS:"
echo "1. Установить количество пиров"
echo "2. Задать имена пиров через запятую"
read -p "Введите номер способа: " choice

if [ $choice -eq 1 ]
then
    read -p "Введите количество пиров: " peers
    sed -i "s/- PEERS=1/- PEERS=$peers/g" docker-compose.yml
    echo "Количество пиров изменено на $peers"
elif [ $choice -eq 2 ]
then
    read -p "Введите имена пиров через запятую: " peers
    # Проверяем, используются ли имена
    if [[ "$peers" == *[!a-zA-Z0-9,]* ]]
    then
        echo "Ошибка: имена пиров могут содержать только латинские буквы и цифры"
        exit 1
    fi
    # Проверяем, существует ли уже переменная среды PEERS
    if grep -q "PEERS=" docker-compose.yml
    then
        # Если переменная уже существует
        # Спрашиваем пользователя, заменить ли текущие имена на новые
        echo "Переменная PEERS уже существует"
        echo "1. Заменить текущие имена на новые"
        echo "2. Добавить новые имена к текущим"
        read -p "Введите номер способа: " add_choice
        if [ $add_choice -eq 1 ]
        then
            sed -i "s/- PEERS=.*/- PEERS=$peers/g" docker-compose.yml
        elif [ $add_choice -eq 2 ]
        then
            current_peers=$(grep PEERS docker-compose.yml | cut -d '=' -f 2 | tr -d '"')
            new_peers=$(echo "$current_peers,$peers")
            sed -i "s/- PEERS=.*/- PEERS=$new_peers/g" docker-compose.yml
        else
            echo "Ошибка: неверный выбор"
            exit 1
        fi
    else
        # Если переменная не существует, добавляем ее с новыми именами
        sed -i "s/- PEERS=1/- PEERS=\"$peers\"/g" docker-compose.yml
    fi
    echo "Имена пиров изменены на $peers"
else
    echo "Ошибка: неверный выбор"
    exit 1
fi


# Устанавливаем apache2-utils, если она не установлена
if ! [ -x "$(command -v htpasswd)" ]; then
  echo -e "${RED}Установка apache2-utils...${NC}" >&2
   apt-get update
   apt-get install apache2-utils -y
fi


# Если логин не введен, устанавливаем логин по умолчанию "admin"
while true; do
  printf "${YELLOW} Теперь необходимо задать параметры для AdGuard HOME \n${NC}"
  echo -e "${YELLOW}Введите логин (только латинские буквы и цифры), если пропустить шаг будет задан логин admin:${NC}"  
  read username
  if [ -z "$username" ]; then
    username="admin"
    break
  fi
  if ! [[ "$username" =~ [^a-zA-Z0-9] ]]; then
    break
  else
    echo -e "${RED}Логин должен содержать только латинские буквы и цифры.${NC}"
  fi
done

# Запрашиваем у пользователя пароль
while true; do
  echo -e "${YELLOW}Введите пароль (если нажать Enter, пароль будет задан по умолчанию admin):${NC}"  
  read password
  if [ -z "$password" ]; then
    password="admin"
    break
  fi
  if ! [[ "$password" =~ [^a-zA-Z0-9] ]]; then
    break
  else
    echo -e "${RED}Пароль должен содержать латинские буквы верхнего и нижнего регистра, цифры.${NC}"
  fi
done

# Генерируем хеш пароля с помощью htpasswd из пакета apache2-utils
hashed_password=$(htpasswd -nbB $username "$password" | cut -d ":" -f 2)

# Экранируем символы / и & в hashed_password
hashed_password=$(echo "$hashed_password" | sed -e 's/[\/&]/\\&/g')

# Проверяем наличие файла AdGuardHome.yaml и его доступность для записи
if [ ! -w "conf/AdGuardHome.yaml" ]; then
  echo -e "${RED}Файл conf/AdGuardHome.yaml не существует или не доступен для записи.${NC}" >&2
  exit 1
fi

# Записываем связку логина и зашифрованного пароля в файл conf/AdGuardHome.yaml
if 
#  sed -i "s/\(name: $username\).*\(password: \).*/\1\n\2$hashed_password/" conf/AdGuardHome.yaml 
  sed -i -E "s/- name: .*/- name: $username/g" conf/AdGuardHome.yaml
  sed -i -E "s/password: .*/password: $hashed_password/g" conf/AdGuardHome.yaml
then
  # Выводим сообщение об успешной записи связки логина и пароля в файл
  echo -e "${GREEN}Связка логина и пароля успешно записана в файл conf/AdGuardHome.yaml${NC}"
else
  echo -e "${RED}Не удалось записать связку логина и пароля в файл conf/AdGuardHome.yaml.${NC}" >&2
  exit 1
fi


# Выводим связку логина и пароля в консоль
echo "Ниже представлены логин и пароль для входа в AdGuardHome"
echo -e "${GREEN}Логин: $username${NC}"
echo -e "${GREEN}Пароль: $password${NC}"

# Запускаем docker-compose
docker-compose up -d


echo ""
echo -e "Адрес входа в веб-интерфейс AdGuardHome после установки (только когда подключитесь к сети WireGuard!!!): ${BLUE}http://agh.local${NC}"
echo "Ниже представлены логин и пароль для входа в AdGuardHome"
echo -e "Логин:${BLUE} $username${NC}"
echo -e "Пароль:${BLUE} $password${NC}"
echo ""
echo -e "${GREEN}Заходите на мой форум: https://openode.ru${NC}"

