# Конфигурация виртуальной машины devops-vm

## 1. Параметры машины
- ОЗУ: 2048 МБ
- Ядра: 2
- Диск: 25 ГБ

## 2. Сетевые интерфейсы
- enp0s3 (NAT): 10.0.2.15, доступ в интернет
- enp0s8 (Host-only): 192.168.56.101, доступ с хоста

## 3. Правило проброса портов
- Хост: 2222 -> Гость: 2222 (SSH)
- Хост: 80 -> Гость: 80 (HTTP)
- Хост: 443 -> Гость: 443 (HTTPS)

## 4. Учётные записи
- student (sudo)
- devops (sudo, аутентификация по ключу)

## 5. Служба SSH
- Порт: 2222
- Файл конфигурации: /etc/ssh/sshd_config.d/99-hardening.conf
- Изменения: PermitRootLogin no, PasswordAuthentication no, MaxAuthTries 3, AllowUsers devops

## 6. Правила межсетевого экрана
- Политика по умолчанию: deny incoming, allow outgoing
- Разрешённые порты: 2222/tcp (LIMIT), 80/tcp (ALLOW), 443/tcp (ALLOW)

## 7. Снимки состояния
- 01-clean-install
- 02-keys-configured
- 03-ssh-hardened
- 04-nginx-https

## 8. Веб-сервер
- Устанавливаемый пакет: nginx
- Путь к конфигурации ресурса: /etc/nginx/sites-available/devops-site
- Каталог ресурса: /var/www/devops-site, владелец devops:devops, права 755
- Путь к сертификату: /etc/ssl/certs/devops.crt, права 644
- Путь к ключу: /etc/ssl/private/devops.key, права 600, владелец root
- Команда формирования сертификата: sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/devops.key -out /etc/ssl/certs/devops.crt -subj "/CN=devops.local" -addext "subjectAltName=DNS:devops.local"
- Срок действия сертификата: 365 дней
