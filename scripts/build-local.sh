#!/bin/bash
# Release-сборка, подписанная самоподписанным сертификатом (локально и в .github/workflows/fork-build.yml).
# Разрешения macOS (Accessibility, камера, календарь) привязаны к сертификату и переживают пересборку.
# Использование: scripts/build-local.sh ["Имя сертификата"]
set -euo pipefail

IDENTITY="${1:-Mono Brow Local}"
APP="build/Build/Products/Release/Boring Notch.app"
cd "$(dirname "$0")/.."

xcodebuild -project boringNotch.xcodeproj -scheme boringNotch -configuration Release \
  -derivedDataPath build \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="$IDENTITY" \
  DEVELOPMENT_TEAM="" PROVISIONING_PROFILE_SPECIFIER="" \
  CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
  build

codesign --verify --deep --strict "$APP"
codesign -dvv "$APP" 2>&1 | grep -F "Authority=$IDENTITY" > /dev/null || {
  echo "Приложение подписано не сертификатом \"$IDENTITY\"." >&2
  exit 1
}
# get-task-allow позволяет подключаться к процессу отладчиком и внедрять код
for bundle in "$APP" "$APP"/Contents/XPCServices/*.xpc; do
  if codesign -d --entitlements - "$bundle" 2>/dev/null | grep -F get-task-allow > /dev/null; then
    echo "В подписи $bundle осталось отладочное entitlement get-task-allow." >&2
    exit 1
  fi
done

echo "Готово: $APP"
