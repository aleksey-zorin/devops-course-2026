#!/usr/bin/env bash
# Доставка статического ресурса на devops-vm
# Использование: scripts/deploy.sh [--dry-run]
set -euo pipefail

REMOTE="devops"
REMOTE_DIR="/var/www/devops-site"
SITE_URL="https://devops.local"
CA_CERT="${HOME}/devops.crt"
LOCAL_DIR="$(git rev-parse --show-toplevel)/site/"

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

# 2. Проверки по требованиям 4 и 5
if [[ ! -f "${LOCAL_DIR}index.html" ]]; then
  echo "Ошибка: файл site/index.html отсутствует" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Ошибка: в репозитории есть незафиксированные изменения" >&2
  exit 1
fi

# 3. Синхронизация каталога
RSYNC_OPTS="-avz --delete --chmod=D755,F644"
if [[ "${DRY_RUN}" == "true" ]]; then
  RSYNC_OPTS+=" --dry-run"
  # 4. При --dry-run — завершение с кодом 0
  rsync $RSYNC_OPTS "${LOCAL_DIR}" "${REMOTE}:${REMOTE_DIR}"
  echo "Dry-run завершен."
  exit 0
fi

# 9. Сценарий не запрашивает пароль (BatchMode=yes)
rsync $RSYNC_OPTS -e "ssh -o BatchMode=yes -o ConnectTimeout=5" "${LOCAL_DIR}" "${REMOTE}:${REMOTE_DIR}"

# 5. Проверка доступности
echo "Проверка доступности ${SITE_URL}..."
if ! curl -sf --cacert "${CA_CERT}" -I "${SITE_URL}" > /dev/null; then
  echo "Ошибка: ресурс недоступен" >&2
  exit 1
fi

echo "Успешно доставлен коммит: $(git rev-parse --short HEAD)"
exit 0
