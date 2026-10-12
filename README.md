# Mono Brow

Личный форк [**Boring Notch**](https://github.com/TheBoredTeam/boring.notch) от [TheBoredTeam](https://github.com/TheBoredTeam): тот же «живой» вырез MacBook (плеер с визуализатором, календарь и напоминания, полка файлов с AirDrop, замена системных HUD), но с урезанной поверхностью атаки и собственной сборкой вместо готовых бинарников апстрима.

> [!NOTE]
> Это не официальный репозиторий. Баги и фичи оригинального приложения — в [апстрим](https://github.com/TheBoredTeam/boring.notch/issues). Приложение внутри по-прежнему называется **Boring Notch**.

<p align="center">
  <img src="https://github.com/user-attachments/assets/2d5f69c1-6e7b-4bc2-a6f1-bb9e27cf88a8" alt="Demo GIF" />
</p>

## Чем отличается от апстрима

**Безопасность и сеть**
- Отключены автообновления Sparkle: удалены `SUFeedURL`, публичный ключ и `SUEnable*`, updater не запускается. Приложение не скачивает и не ставит сборки апстрима.
- ATS-исключение `NSAllowsArbitraryLoads` заменено на `NSAllowsLocalNetworking`.
- Удалено entitlement `com.apple.security.network.server`.
- Из подписанных сборок убирается `get-task-allow`, сборка падает, если оно осталось в приложении или XPC-сервисе.

**Чистка кода**
- Удалены неиспользуемые файлы, типы, протоколы и закомментированные экраны настроек.
- Убраны зависимости `Pow`, `swift-collections` и `SwiftUIIntrospect`.

**Сборка и сопровождение**
- [`scripts/build-local.sh`](scripts/build-local.sh) — Release-сборка, подписанная самоподписанным сертификатом. Разрешения macOS (Accessibility, камера, календарь) привязаны к сертификату и не слетают после пересборки.
- [`fork-build.yml`](.github/workflows/fork-build.yml) — на тег `v*` собирает приложение, публикует в Releases и прикладывает build provenance attestation.
- [`upstream-watch.yml`](.github/workflows/upstream-watch.yml) — раз в день проверяет релизы апстрима и открывает issue со списком коммитов, изменённых чувствительных файлов (entitlements, `Info.plist`, зависимости, CI, хелперы) и подозрительных добавленных строк (сеть, запуск процессов, keychain и т.п.).

## Установка

Требуется macOS **14 Sonoma** или новее, Apple Silicon или Intel.

### Из Releases

Скачайте `BoringNotch.zip` из [Releases](https://github.com/True-Ruslan/mono-brow/releases), распакуйте и перенесите **Boring Notch.app** в `/Applications`. Происхождение архива можно проверить:

```bash
gh attestation verify BoringNotch.zip -R True-Ruslan/mono-brow
```

Сборка подписана самоподписанным сертификатом, поэтому при первом запуске macOS ругнётся. Снимите карантин:

```bash
xattr -dr com.apple.quarantine "/Applications/Boring Notch.app"
```

> [!WARNING]
> Не ставьте DMG или Homebrew-cask апстрима поверх форка: это будет оригинальная сборка со включёнными автообновлениями.

### Сборка из исходников

Нужны macOS 15.6+ и Xcode 26+.

1. Создайте в «Связке ключей» сертификат для подписи кода (Ассистент сертификации → Создать сертификат, тип «Подписывание кода»). По умолчанию скрипт ждёт имя `Mono Brow Local`.
2. Соберите:
   ```bash
   git clone https://github.com/True-Ruslan/mono-brow.git
   cd mono-brow
   scripts/build-local.sh            # или scripts/build-local.sh "Имя сертификата"
   ```
3. Готовое приложение: `build/Build/Products/Release/Boring Notch.app`.

Для разработки можно просто открыть `boringNotch.xcodeproj` в Xcode и запустить (`Cmd + R`).

### Релиз форка

В секретах репозитория должны лежать `SIGNING_CERT_P12` (сертификат в base64) и `SIGNING_CERT_PASSWORD`. Затем:

```bash
git tag v2.7.3-mono.1 && git push origin v2.7.3-mono.1
```

## Использование

- Наведите курсор на вырез — он развернётся.
- Управляйте музыкой, смотрите календарь, перетаскивайте файлы на полку.
- Настройки — через звёздочку в строке меню.

## Синхронизация с апстримом

```bash
git remote add upstream https://github.com/TheBoredTeam/boring.notch.git
git fetch upstream --tags
git merge <тег>
```

Перед слиянием просмотрите issue от `upstream-watch` по этому релизу и убедитесь, что слияние не вернуло Sparkle, `NSAllowsArbitraryLoads` и удалённые entitlements.

## Благодарности

Всё основное приложение — работа [TheBoredTeam](https://github.com/TheBoredTeam) и [контрибьюторов Boring Notch](https://github.com/TheBoredTeam/boring.notch/graphs/contributors). Поддержать авторов: [Ko-fi](https://www.ko-fi.com/alexander5015).

- **[MediaRemoteAdapter](https://github.com/ungive/mediaremote-adapter)** — источник Now Playing на macOS 15.4+.
- **[NotchDrop](https://github.com/Lakr233/NotchDrop)** — основа первой версии полки.
- Иконка: [@maxtron95](https://github.com/maxtron95).

Полный список лицензий и атрибуций — в [THIRD_PARTY_LICENSES](./THIRD_PARTY_LICENSES).

## Лицензия

[GPL-3.0](LICENSE), как и у оригинального проекта.
