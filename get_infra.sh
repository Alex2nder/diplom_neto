#!/bin/bash

# Путь к vault.yml
VAULT_FILE="/home/alexander/diplom/inventory/production/vault.yml"

# Путь к inventory
INVENTORY="/home/alexander/diplom/inventory/production/"

# Извлечение OAuth-токена из vault.yml
echo "Извлечение OAuth-токена из vault.yml..."
OAUTH_TOKEN=$(ansible localhost -m ansible.builtin.debug -a "var=ya_token" --ask-vault-pass -i "$INVENTORY" -e@"$VAULT_FILE" 2>/dev/null | grep -oP '"ya_token": "\K[^"]+')

if [ -z "$OAUTH_TOKEN" ]; then
  echo "Ошибка: не удалось извлечь OAuth-токен из vault.yml"
  exit 1
fi

echo "Извлечённый OAuth-токен: $OAUTH_TOKEN"

# Проверка версии yc
echo "Проверка версии Yandex Cloud CLI..."
yc version

# Генерация IAM-токена на основе OAuth-токена
echo "Генерация IAM-токена..."
IAM_TOKEN=$(yc iam create-token --token "$OAUTH_TOKEN")

if [ -z "$IAM_TOKEN" ]; then
  echo "Ошибка: не удалось сгенерировать IAM-токен. Вывод команды yc iam create-token:"
  yc iam create-token --token "$OAUTH_TOKEN"
  exit 1
fi

echo "Сгенерированный IAM-токен: $IAM_TOKEN"

# Настройка yc с IAM-токеном
echo "Настройка Yandex Cloud CLI с IAM-токеном..."
yc config set token "$IAM_TOKEN"
yc config set cloud-id "b1g9h7cb32it31lj3lu1"
yc config set folder-id "b1gff74m5ladptv8subr"

# Проверка конфигурации yc
echo "Текущая конфигурация yc:"
yc config list

# Запрос инфраструктуры
echo "=== Compute Instances ==="
yc compute instance list

echo "=== VPC Networks ==="
yc vpc network list

echo "=== VPC Subnets ==="
yc vpc subnet list

echo "=== Security Groups ==="
yc vpc security-group list

echo "=== Application Load Balancers ==="
yc alb load-balancer list

echo "=== Target Groups ==="
yc alb target-group list

echo "=== Backend Groups ==="
yc alb backend-group list

echo "=== HTTP Routers ==="
yc alb http-router list

echo "=== NAT Gateways ==="
yc vpc gateway list

echo "=== Route Tables ==="
yc vpc route-table list

echo "=== Snapshots ==="
yc compute snapshot list

echo "=== Snapshot Schedules ==="
yc compute snapshot-schedule list

echo "=== Disks ==="
yc compute disk list

echo "Инфраструктура успешно выведена!"