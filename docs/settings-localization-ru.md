# Русская локализация настроек Mono Brow: исследование и реестр

Статус: локальная реализация завершена; каталог, модели и изменённые SwiftUI-вызовы проверены, независимый обзор не выявил блокирующих дефектов. Полная сборка перенесена в GitHub Actions по запросу пользователя; результаты нужно проверять для коммита локализации. Визуальная проверка остаётся открытой. Приложение не устанавливалось.

Дата: 12 октября 2026 года. Исходный коммит: `4649d1b60c2469a11273544e9c2609cff69f9673`. До исследования рабочее дерево Git было чистым.

## Цель и границы

Подготовить полный реестр собственных текстов окна настроек, которые ещё не переведены на русский или не подключены к локализации, с источниками и предлагаемыми формулировками. Сначала перепроверить реестр и терминологию, затем отдельно переходить к реализации.

Основной охват: десять доступных разделов настроек, боковая панель, заголовок окна, подсказки, зависимые компоненты, варианты списков и вход в настройки из меню. Видимые отключённые элементы включены: пользователь всё равно читает их подписи. Отдельно отмечены соседние системные диалоги, собственные тексты вне настроек и неиспользуемый код.

В охват не входят перевод README, переработка дизайна, добавление выбора языка, удаление старого кода, включение незавершённых функций или изменение поведения обновлений. Названия приложений, URLs, технические идентификаторы, названия экранов, календарей и пользовательских анимаций сохраняются.

## Что изучено и насколько надёжны сведения

Все выводы об устройстве проекта получены из текущих файлов этого checkout. Это первичные источники для исходного кода; они не доказывают поведение установленной сборки.

| Источник | Что проверено |
|---|---|
| [README.md](../README.md) | Назначение личного форка, macOS, сборка, ограничения автообновлений |
| [SettingsView.swift](../boringNotch/components/Settings/SettingsView.swift) | Весь файл: навигация, десять разделов, условные ветки, формы, вспомогательные подписи |
| [SettingsWindowController.swift](../boringNotch/components/Settings/SettingsWindowController.swift) | AppKit-заголовок и создание окна |
| [MusicSlotConfigurationView.swift](../boringNotch/components/Settings/MusicSlotConfigurationView.swift) | Палитра кнопок, предпросмотр, очистка слота, сброс, протокол перетаскивания |
| [SoftwareUpdater.swift](../boringNotch/components/Settings/SoftwareUpdater.swift) | Видимые подписи обновлений; поведение не меняется |
| [EditPanelView.swift](../boringNotch/components/Settings/EditPanelView.swift), [ListItemPopover.swift](../boringNotch/components/Settings/ListItemPopover.swift) | Соседние компоненты, достижимость и отсутствие текстовых подписей в поповере |
| [Localizable.xcstrings](../boringNotch/Localizable.xcstrings) | Все 236 ключей, значения `ru`, состояния перевода и `stale` |
| [Constants.swift](../boringNotch/models/Constants.swift), [generic.swift](../boringNotch/enums/generic.swift), [MusicControlButton.swift](../boringNotch/models/MusicControlButton.swift) | Варианты списков, подписи кнопок, связь с сохранёнными настройками |
| [boringNotchApp.swift](../boringNotch/boringNotchApp.swift), [ContentView.swift](../boringNotch/ContentView.swift), [BoringHeader.swift](../boringNotch/components/Notch/BoringHeader.swift) | Точки открытия настроек и контекстное меню |
| [QuickShareService.swift](../boringNotch/components/Shelf/Services/QuickShareService.swift) | Названия системных сервисов, собственный fallback, подписи выбора файлов |
| [BoringViewModel.swift](../boringNotch/models/BoringViewModel.swift), [LottieView.swift](../boringNotch/components/LottieView.swift), [SystemEventIndicatorModifier.swift](../boringNotch/components/Live%20activities/SystemEventIndicatorModifier.swift) | Диалог камеры, смысл скорости анимации и оформления шкалы |
| [MusicManager.swift](../boringNotch/managers/MusicManager.swift), [NotchHomeView.swift](../boringNotch/components/Notch/NotchHomeView.swift) | Контекст задержки скрытия и скругления углов |
| [project.pbxproj](../boringNotch.xcodeproj/project.pbxproj), [Info.plist](../boringNotch/Info.plist), [Package.resolved](../boringNotch.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved) | Включение каталога в ресурсы, настройки извлечения строк, регионы, privacy-тексты, версии зависимостей |
| [CONTRIBUTING.md](../CONTRIBUTING.md), [crowdin.yml](../crowdin.yml), [workflow Crowdin](../.github/workflows/crowdin.yml), [шаблон PR](../.github/PULL_REQUEST.md) | Унаследованные правила апстрима о Crowdin; текущий workflow содержит только запуск вручную и пустой job без steps |

Изучены также Git status и последние четыре коммита. Поиск `locale`, `AppleLanguages`, `String(localized:)` и `NSLocalizedString` не выявил собственного переключателя языка или общей системы локализованных подписей настроек. Найденный `en_US_POSIX` в `BoringViewCoordinator.swift:194` относится к разбору числового значения события, а не к выбору языка интерфейса.

Уверенность высокая для перечня текстов, маршрутов отображения и проверенных API. При перепроверке прочитаны русские ресурсы установленного приложения и исходники закреплённых зависимостей. Для итоговой компоновки, выбора языка внутри процесса приложения и внутренних диалогов уверенность остаётся ограниченной: окно настроек через UI-инструмент не открыто. Проверка bundle и изолированный разбор SwiftUI не заменяют визуальную проверку будущей сборки.

## Устройство настроек и локализации до изменений

Проект — нативное приложение macOS на Swift/SwiftUI с AppKit-окнами и XPC-помощником. Оно называется Boring Notch внутри личного форка Mono Brow. Настройки создаёт `SettingsWindowController`, содержимое — `SettingsView` с `NavigationSplitView`. Сохранение большинства параметров идёт через `Defaults`; часть состояния принадлежит `BoringViewCoordinator`.

| Раздел | Представление | Дополнительные источники текста |
|---|---|---|
| Основные | `GeneralSettings` | Названия экранов macOS, `LaunchAtLogin.Toggle`, чувствительность жестов, бейдж Beta |
| Внешний вид | `Appearance` | `SliderColorEnum.rawValue`, названия пользовательских визуализаторов, форма добавления |
| Медиа | `Media` | `MediaControllerType.rawValue`, `SneakPeekStyle.rawValue`, палитра `MusicControlButton.label` |
| Календарь | `CalendarSettings` | Названия календарей/списков EventKit, ветки запрета доступа |
| Индикаторы | `HUD` | `OptionKeyAction.rawValue`, разрешение Accessibility, открытый/закрытый режим |
| Батарея | `Charge` | Собственные статические подписи |
| Полка | `Shelf` | `QuickShareProvider.id` из `NSSharingService.title` или собственного fallback |
| Сочетания клавиш | `Shortcuts` | `KeyboardShortcuts.Recorder` и его внутренний интерфейс |
| Дополнительно | `Advanced` | Выбор акцентного цвета, условная подсказка, отключённый выбор иконки |
| О программе | `About` | Версия/release name, компоненты Sparkle, атрибуция |

Английские значения `selectedTab`, `NavigationLink(value:)` и `switch` — внутренние ключи навигации. Русскими должны стать отображаемые `Label` и заголовки, а не эти ключи.

`Localizable.xcstrings` включён в Resources основного target; `sourceLanguage` и `developmentRegion` равны `en`. В каталоге есть 16 локалей, включая `ru`. `SWIFT_EMIT_LOC_STRINGS = YES` присутствует в настройках сборки. При этом `knownRegions` содержит только `en` и `Base`; отсутствие `ru` здесь зафиксировано как пункт проверки, а не как доказанная причина английского интерфейса. В установленной версии 2.7.3 (271) русский `ru.lproj` присутствует; все 236 значений совпадают с текущим checkout. Перепроверка не выявила необходимости менять `knownRegions` ради существующего русского каталога. Наличие ресурсов и фактический выбор языка нужно подтвердить также для будущей сборки.

### Исходная статистика до реализации

| Срез | Результат |
|---|---|
| Все ключи каталога приложения | 236 |
| Ключи с веткой `ru` | 236 |
| Состояние русских `stringUnit` | Все 236 имеют `needs_review`; это не означает отсутствие значения или автоматическое отключение перевода |
| Русское значение совпадает с ключом | 207, включая пустую строку, форматы чисел, бренды, английские тексты и старые ключи |
| Русское значение отличается от ключа | 29; качество не следует из одного отличия |
| Ключи с `extractionState: stale` | 14 |
| Уникальные буквальные UI-ключи реестра ниже | 163: 140 совпадают с оригиналом, 20 отличаются, 3 отсутствуют в каталоге |

163 — срез активных подпунктов настроек, нормализованных интерполяций и строк, передаваемых в хелперы. В него не включены пустые/чисто числовые подписи, закомментированный код, неиспользуемые функции, значение версии и бренды музыкальных источников. Из 140 совпадений одно — `GitHub`, которое переводить не нужно. Динамические подписи и пункты меню разобраны отдельно; пересечения между таблицами нельзя суммировать как независимые строки.

Ключи `Launch at login`, `Player tinting` и `Beta` используются в настройках, но отсутствуют в каталоге. У `LaunchAtLogin.Toggle` подтверждена перегрузка с `LocalizedStringKey`; текущему вызову нужен недостающий ключ. У `Defaults.Toggle` строковая перегрузка принимает `StringProtocol` и выводит его через `Text(title)`: для Player tinting нужна форма с блоком `label` и буквальным `Text`. `Beta` идёт через собственный `String`-хелпер и требует подключения локализации.

## Почему одного заполнения каталога недостаточно

1. `Text("literal")` и локализуемые подписи SwiftUI могут искать перевод в каталоге. `Text(variableString)` отображает уже готовое строковое значение. В исходном коде до реализации это различие затрагивало `rawValue`, `control.label`, `customBadge(text:)` и строковый вызов `Defaults.Toggle`. Чувствительность жестов — исключение: литералы в тернарном выражении здесь выводятся как `LocalizedStringKey`, что подтверждено изолированной проверкой компилятора; достаточно перевести High/Medium/Low.
2. `window.title` в AppKit получает обычную английскую строку. Её необходимо явно локализовать перед присваиванием.
3. Перевод `rawValue` изменит сохраняемое значение enum или идентификатор, а не только текст на экране. Для вариантов списков требуется отдельная локализуемая подпись; `.tag`, `id`, Defaults и протокол `control:<rawValue>` остаются прежними.
4. Системные имена экранов, календарей, сервисов и пользовательские названия должны отображаться как данные. Принудительно искать их в нашем каталоге нельзя.

Источники: [варианты Option](../boringNotch/components/Settings/SettingsView.swift#L431), [музыкальные источники](../boringNotch/components/Settings/SettingsView.swift#L526), [стиль обзора](../boringNotch/components/Settings/SettingsView.swift#L567), [цвет ползунка](../boringNotch/components/Settings/SettingsView.swift#L977), [подписи палитры](../boringNotch/components/Settings/MusicSlotConfigurationView.swift#L152), [хелпер бейджа](../boringNotch/components/Settings/SettingsView.swift#L1551), [заголовок окна](../boringNotch/components/Settings/SettingsWindowController.swift#L43).

## Предлагаемая терминология для перепроверки

| Термин | Предложение | Причина / ограничение |
|---|---|---|
| Notch | Вырез | Один термин для физического выреза и интерфейса приложения; контекст уточняется подписью |
| HUD / HUDs | Индикатор / Индикаторы | В описаниях перечислять громкость, яркость экрана и подсветку клавиатуры |
| Sneak Peek | Краткий обзор | Одно название в настройках медиа, подсказке и сочетаниях клавиш |
| Live activity | Воспроизведение в вырезе | Для музыкального раздела описывает функцию; не подразумевает системную технологию iOS |
| Shelf | Полка | Совпадает с русским README |
| Quick Share | Быстрая отправка | Название функции; AirDrop и названия сервисов сохраняются |
| Accent color | Акцентный цвет | Уточнить существующее «Основной цвет» и применять одинаково во всех разделах |
| Default | По умолчанию | Общий ключ используется для разных стилей и иконки; нейтральная форма избегает разных родов |
| Inline | Встроенный | Проверить визуально в обоих контекстах: HUD и краткий обзор |
| Accessibility | Универсальный доступ | В объяснении разрешения назвать конкретный раздел macOS |
| Option | Option | Сохраняется имя клавиши; при необходимости добавить символ ⌥ |
| Lottie, JSON, URL, GitHub | Сохраняются | Названия технологий и сервиса |

Формулировки являются редакционными предложениями. Особенно требуют просмотра в приложении «Встроенный», «Предпочтительный экран», «Текст в цвет обложки», «Пуск/пауза», атрибуция авторов и длинные пояснения.

## Реестр буквальных строк настроек

В таблицах «До изменения в `ru`» — точное исходное значение каталога на HEAD `4649d1b`, а не нынешнее значение и не результат запуска приложения. Реализация использует столбец «Предлагаемый текст»; текущие итоги приведены в разделе реализации ниже. «Нет ключа» означает отсутствие всего ключа. Статус «Сохранить перевод» означает предварительно приемлемую текущую формулировку, а не утверждение её проверки в интерфейсе. Для интерполяций показан уже существующий ключ каталога; корректность извлечения после изменений нужно подтвердить сборкой.

Каждый уникальный ключ приведён один раз, в разделе первого использования; ссылки перечисляют повторные места. Общие `General`, `Media`, `Default`, `Coming soon`, `Accent color`, `%.1fs` используются в нескольких разделах.


### Навигация

| Ключ / исходный текст | До изменения в `ru` | Предлагаемый текст | Действие | Источник |
|---|---|---|---|---|
| `General` | General | Основные | Перевести | [SettingsView.swift:30](../boringNotch/components/Settings/SettingsView.swift#L30), [SettingsView.swift:272](../boringNotch/components/Settings/SettingsView.swift#L272), [SettingsView.swift:361](../boringNotch/components/Settings/SettingsView.swift#L361), [SettingsView.swift:450](../boringNotch/components/Settings/SettingsView.swift#L450), [SettingsView.swift:873](../boringNotch/components/Settings/SettingsView.swift#L873), [SettingsView.swift:964](../boringNotch/components/Settings/SettingsView.swift#L964) |
| `Appearance` | Внешний вид | Внешний вид | Сохранить перевод | [SettingsView.swift:33](../boringNotch/components/Settings/SettingsView.swift#L33), [SettingsView.swift:1181](../boringNotch/components/Settings/SettingsView.swift#L1181) |
| `Media` | Media | Медиа | Перевести | [SettingsView.swift:36](../boringNotch/components/Settings/SettingsView.swift#L36), [SettingsView.swift:616](../boringNotch/components/Settings/SettingsView.swift#L616), [SettingsView.swift:983](../boringNotch/components/Settings/SettingsView.swift#L983), [SettingsView.swift:1512](../boringNotch/components/Settings/SettingsView.swift#L1512) |
| `Calendar` | Календарь | Календарь | Сохранить перевод | [SettingsView.swift:39](../boringNotch/components/Settings/SettingsView.swift#L39), [SettingsView.swift:727](../boringNotch/components/Settings/SettingsView.swift#L727) |
| `HUDs` | HUDs | Индикаторы | Перевести | [SettingsView.swift:42](../boringNotch/components/Settings/SettingsView.swift#L42), [SettingsView.swift:495](../boringNotch/components/Settings/SettingsView.swift#L495) |
| `Battery` | Батарея | Батарея | Сохранить перевод | [SettingsView.swift:45](../boringNotch/components/Settings/SettingsView.swift#L45), [SettingsView.swift:380](../boringNotch/components/Settings/SettingsView.swift#L380) |
| `Shelf` | Shelf | Полка | Перевести | [SettingsView.swift:51](../boringNotch/components/Settings/SettingsView.swift#L51), [SettingsView.swift:936](../boringNotch/components/Settings/SettingsView.swift#L936) |
| `Shortcuts` | Shortcuts | Сочетания клавиш | Перевести | [SettingsView.swift:54](../boringNotch/components/Settings/SettingsView.swift#L54), [SettingsView.swift:1526](../boringNotch/components/Settings/SettingsView.swift#L1526) |
| `Advanced` | Advanced | Дополнительно | Перевести | [SettingsView.swift:60](../boringNotch/components/Settings/SettingsView.swift#L60), [SettingsView.swift:1414](../boringNotch/components/Settings/SettingsView.swift#L1414) |
| `About` | О программе | О программе | Сохранить перевод | [SettingsView.swift:63](../boringNotch/components/Settings/SettingsView.swift#L63), [SettingsView.swift:827](../boringNotch/components/Settings/SettingsView.swift#L827) |

### Основные

| Ключ / исходный текст | До изменения в `ru` | Предлагаемый текст | Действие | Источник |
|---|---|---|---|---|
| `Show menu bar icon` | Show menu bar icon | Показывать значок в строке меню | Перевести | [SettingsView.swift:158](../boringNotch/components/Settings/SettingsView.swift#L158) |
| `Launch at login` | Нет ключа | Запускать при входе в систему | Добавить ключ | [SettingsView.swift:161](../boringNotch/components/Settings/SettingsView.swift#L161) |
| `Show on all displays` | Show on all displays | Показывать на всех экранах | Перевести | [SettingsView.swift:163](../boringNotch/components/Settings/SettingsView.swift#L163) |
| `Preferred display` | Preferred display | Предпочтительный экран | Перевести | [SettingsView.swift:169](../boringNotch/components/Settings/SettingsView.swift#L169) |
| `Automatically switch displays` | Автоматически переключать экраны | Автоматически переключать экраны | Сохранить перевод | [SettingsView.swift:183](../boringNotch/components/Settings/SettingsView.swift#L183) |
| `System features` | System features | Системные функции | Перевести | [SettingsView.swift:191](../boringNotch/components/Settings/SettingsView.swift#L191) |
| `Notch height on notch displays` | Notch height on notch displays | Высота на экранах с вырезом | Перевести | [SettingsView.swift:198](../boringNotch/components/Settings/SettingsView.swift#L198) |
| `Match real notch height` | Match real notch height | По высоте выреза | Перевести | [SettingsView.swift:200](../boringNotch/components/Settings/SettingsView.swift#L200), [SettingsView.swift:231](../boringNotch/components/Settings/SettingsView.swift#L231) |
| `Match menu bar height` | Match menu bar height | По высоте строки меню | Перевести | [SettingsView.swift:202](../boringNotch/components/Settings/SettingsView.swift#L202) |
| `Custom height` | Custom height | Своя высота | Перевести | [SettingsView.swift:204](../boringNotch/components/Settings/SettingsView.swift#L204), [SettingsView.swift:233](../boringNotch/components/Settings/SettingsView.swift#L233) |
| `Notch height on non-notch displays` | Notch height on non-notch displays | Высота на экранах без выреза | Перевести | [SettingsView.swift:228](../boringNotch/components/Settings/SettingsView.swift#L228) |
| `Match menubar height` | Match menubar height | По высоте строки меню | Перевести | [SettingsView.swift:229](../boringNotch/components/Settings/SettingsView.swift#L229) |
| `Notch sizing` | Notch sizing | Размер выреза | Перевести | [SettingsView.swift:258](../boringNotch/components/Settings/SettingsView.swift#L258) |
| `Quit app` | Quit app | Завершить приложение | Перевести | [SettingsView.swift:266](../boringNotch/components/Settings/SettingsView.swift#L266) |
| `Enable gestures` | Enable gestures | Включить жесты | Перевести | [SettingsView.swift:284](../boringNotch/components/Settings/SettingsView.swift#L284) |
| `Change media with horizontal gestures` | Change media with horizontal gestures | Переключать треки горизонтальными жестами | Перевести; видимый отключённый элемент | [SettingsView.swift:288](../boringNotch/components/Settings/SettingsView.swift#L288) |
| `Close gesture` | Close gesture | Закрывать жестом | Перевести | [SettingsView.swift:291](../boringNotch/components/Settings/SettingsView.swift#L291) |
| `Gesture sensitivity` | Gesture sensitivity | Чувствительность жестов | Перевести | [SettingsView.swift:295](../boringNotch/components/Settings/SettingsView.swift#L295) |
| `Gesture control` | Gesture control | Управление жестами | Перевести | [SettingsView.swift:307](../boringNotch/components/Settings/SettingsView.swift#L307) |
| `Beta` | Нет ключа | Бета | Добавить ключ; подключить локализацию | [SettingsView.swift:308](../boringNotch/components/Settings/SettingsView.swift#L308), [SettingsView.swift:465](../boringNotch/components/Settings/SettingsView.swift#L465), [SettingsView.swift:587](../boringNotch/components/Settings/SettingsView.swift#L587), [SettingsView.swift:604](../boringNotch/components/Settings/SettingsView.swift#L604) |
| `Two-finger swipe up on notch to close, two-finger swipe down on notch to open when **Open notch on hover** option is disabled` | Two-finger swipe up on notch to close, two-finger swipe down on notch to open when \*\*Open notch on hover\*\* option is disabled | Проведите двумя пальцами вверх по вырезу, чтобы закрыть его. Проведите вниз, чтобы открыть, если параметр \*\*Открывать при наведении\*\* выключен. | Перевести | [SettingsView.swift:311](../boringNotch/components/Settings/SettingsView.swift#L311) |
| `Open notch on hover` | Open notch on hover | Открывать при наведении | Перевести | [SettingsView.swift:324](../boringNotch/components/Settings/SettingsView.swift#L324) |
| `Enable haptic feedback` | Enable haptic feedback | Включить тактильный отклик | Перевести | [SettingsView.swift:327](../boringNotch/components/Settings/SettingsView.swift#L327) |
| `Remember last tab` | Remember last tab | Запоминать последнюю вкладку | Перевести | [SettingsView.swift:329](../boringNotch/components/Settings/SettingsView.swift#L329) |
| `Hover delay` | Hover delay | Задержка при наведении | Перевести | [SettingsView.swift:333](../boringNotch/components/Settings/SettingsView.swift#L333) |
| `Notch behavior` | Notch behavior | Поведение выреза | Перевести | [SettingsView.swift:345](../boringNotch/components/Settings/SettingsView.swift#L345) |
| `Custom notch size - %.0f` | Custom notch size - %.0f | Своя высота — %.0f | Перевести | [SettingsView.swift:221](../boringNotch/components/Settings/SettingsView.swift#L221), [SettingsView.swift:250](../boringNotch/components/Settings/SettingsView.swift#L250) |
| `%.1fs` | %.1fs | %.1f с | Перевести; разделить время и скорость | [SettingsView.swift:335](../boringNotch/components/Settings/SettingsView.swift#L335), [SettingsView.swift:1112](../boringNotch/components/Settings/SettingsView.swift#L1112) |
| `High` | High | Высокая | Перевести; путь локализации уже есть | [SettingsView.swift:299](../boringNotch/components/Settings/SettingsView.swift#L299) |
| `Medium` | Medium | Средняя | Перевести; путь локализации уже есть | [SettingsView.swift:299](../boringNotch/components/Settings/SettingsView.swift#L299) |
| `Low` | Low | Низкая | Перевести; путь локализации уже есть | [SettingsView.swift:299](../boringNotch/components/Settings/SettingsView.swift#L299) |

### Батарея

| Ключ / исходный текст | До изменения в `ru` | Предлагаемый текст | Действие | Источник |
|---|---|---|---|---|
| `Show battery indicator` | Show battery indicator | Показывать индикатор батареи | Перевести | [SettingsView.swift:355](../boringNotch/components/Settings/SettingsView.swift#L355) |
| `Show power status notifications` | Show power status notifications | Показывать уведомления о состоянии питания | Перевести | [SettingsView.swift:358](../boringNotch/components/Settings/SettingsView.swift#L358) |
| `Show battery percentage` | Show battery percentage | Показывать заряд в процентах | Перевести | [SettingsView.swift:365](../boringNotch/components/Settings/SettingsView.swift#L365) |
| `Show power status icons` | Show power status icons | Показывать значки состояния питания | Перевести | [SettingsView.swift:368](../boringNotch/components/Settings/SettingsView.swift#L368) |
| `Battery Information` | Информация о батарее | Информация о батарее | Сохранить перевод | [SettingsView.swift:371](../boringNotch/components/Settings/SettingsView.swift#L371) |

### Индикаторы

| Ключ / исходный текст | До изменения в `ru` | Предлагаемый текст | Действие | Источник |
|---|---|---|---|---|
| `Replace system HUD` | Replace system HUD | Заменять системные индикаторы | Перевести | [SettingsView.swift:398](../boringNotch/components/Settings/SettingsView.swift#L398) |
| `Replaces the standard macOS volume, display brightness, and keyboard brightness HUDs with a custom design.` | Replaces the standard macOS volume, display brightness, and keyboard brightness HUDs with a custom design. | Заменяет стандартные индикаторы громкости, яркости экрана и подсветки клавиатуры macOS. | Перевести | [SettingsView.swift:400](../boringNotch/components/Settings/SettingsView.swift#L400) |
| `Accessibility access is required to replace the system HUD.` | Accessibility access is required to replace the system HUD. | Для замены системных индикаторов требуется разрешение в разделе «Универсальный доступ». | Перевести | [SettingsView.swift:415](../boringNotch/components/Settings/SettingsView.swift#L415) |
| `Request Accessibility` | Request Accessibility | Запросить разрешение | Перевести | [SettingsView.swift:420](../boringNotch/components/Settings/SettingsView.swift#L420) |
| `Option key behaviour` | Option key behaviour | Действие с клавишей Option | Перевести | [SettingsView.swift:431](../boringNotch/components/Settings/SettingsView.swift#L431) |
| `Progress bar style` | Progress bar style | Стиль шкалы | Перевести | [SettingsView.swift:437](../boringNotch/components/Settings/SettingsView.swift#L437) |
| `Hierarchical` | Hierarchical | Однотонная | Перевести | [SettingsView.swift:438](../boringNotch/components/Settings/SettingsView.swift#L438) |
| `Gradient` | Gradient | Градиентная | Перевести | [SettingsView.swift:440](../boringNotch/components/Settings/SettingsView.swift#L440) |
| `Enable glowing effect` | Enable glowing effect | Включить свечение | Перевести | [SettingsView.swift:444](../boringNotch/components/Settings/SettingsView.swift#L444) |
| `Tint progress bar with accent color` | Tint progress bar with accent color | Использовать акцентный цвет для шкалы | Перевести | [SettingsView.swift:447](../boringNotch/components/Settings/SettingsView.swift#L447) |
| `Show HUD in open notch` | Show HUD in open notch | Показывать индикаторы в открытом вырезе | Перевести | [SettingsView.swift:456](../boringNotch/components/Settings/SettingsView.swift#L456) |
| `Show percentage` | Show percentage | Показывать проценты | Перевести | [SettingsView.swift:459](../boringNotch/components/Settings/SettingsView.swift#L459), [SettingsView.swift:487](../boringNotch/components/Settings/SettingsView.swift#L487) |
| `Open Notch` | Open Notch | Открытый вырез | Перевести | [SettingsView.swift:464](../boringNotch/components/Settings/SettingsView.swift#L464) |
| `HUD style` | HUD style | Стиль индикаторов | Перевести | [SettingsView.swift:471](../boringNotch/components/Settings/SettingsView.swift#L471) |
| `Default` | Default | По умолчанию | Перевести; также используется через rawValue | [SettingsView.swift:472](../boringNotch/components/Settings/SettingsView.swift#L472), [SettingsView.swift:1368](../boringNotch/components/Settings/SettingsView.swift#L1368) |
| `Inline` | Inline | Встроенный | Перевести; также используется через rawValue | [SettingsView.swift:474](../boringNotch/components/Settings/SettingsView.swift#L474) |
| `Closed Notch` | Closed Notch | Закрытый вырез | Перевести | [SettingsView.swift:490](../boringNotch/components/Settings/SettingsView.swift#L490) |

### Медиа

| Ключ / исходный текст | До изменения в `ru` | Предлагаемый текст | Действие | Источник |
|---|---|---|---|---|
| `Music Source` | Music Source | Источник музыки | Перевести | [SettingsView.swift:526](../boringNotch/components/Settings/SettingsView.swift#L526) |
| `Media Source` | Media Source | Источник медиа | Перевести | [SettingsView.swift:538](../boringNotch/components/Settings/SettingsView.swift#L538) |
| `YouTube Music requires this third-party app to be installed: ` | YouTube Music requires this third-party app to be installed:  | Для YouTube Music необходимо установить стороннее приложение:  | Перевести | [SettingsView.swift:542](../boringNotch/components/Settings/SettingsView.swift#L542) |
| `'Now Playing' was the only option on previous versions and works with all media apps.` | 'Сейчас играть' была единственной опцией в предыдущих версиях и работает со всеми медиа-приложениями. | «Сейчас играет» был единственным вариантом в предыдущих версиях и работает со всеми медиаприложениями. | Исправить перевод | [SettingsView.swift:553](../boringNotch/components/Settings/SettingsView.swift#L553) |
| `Show music live activity` | Show music live activity | Показывать воспроизведение в вырезе | Перевести | [SettingsView.swift:562](../boringNotch/components/Settings/SettingsView.swift#L562) |
| `Show sneak peek on playback changes` | Show sneak peek on playback changes | Показывать краткий обзор при изменении воспроизведения | Перевести | [SettingsView.swift:566](../boringNotch/components/Settings/SettingsView.swift#L566) |
| `Sneak Peek Style` | Sneak Peek Style | Стиль краткого обзора | Перевести | [SettingsView.swift:567](../boringNotch/components/Settings/SettingsView.swift#L567) |
| `Media inactivity timeout` | Media inactivity timeout | Задержка скрытия музыкального индикатора | Перевести | [SettingsView.swift:575](../boringNotch/components/Settings/SettingsView.swift#L575) |
| `Full screen behavior` | Full screen behavior | Поведение в полноэкранном режиме | Перевести | [SettingsView.swift:586](../boringNotch/components/Settings/SettingsView.swift#L586) |
| `Hide for all apps` | Hide for all apps | Скрывать для всех приложений | Перевести | [SettingsView.swift:590](../boringNotch/components/Settings/SettingsView.swift#L590) |
| `Hide for media app only` | Hide for media app only | Скрывать только для медиаприложения | Перевести | [SettingsView.swift:591](../boringNotch/components/Settings/SettingsView.swift#L591) |
| `Never hide` | Never hide | Никогда не скрывать | Перевести | [SettingsView.swift:593](../boringNotch/components/Settings/SettingsView.swift#L593) |
| `Media playback live activity` | Media playback live activity | Воспроизведение в вырезе | Перевести | [SettingsView.swift:596](../boringNotch/components/Settings/SettingsView.swift#L596) |
| `Show lyrics below artist name` | Show lyrics below artist name | Показывать текст песни под именем исполнителя | Перевести | [SettingsView.swift:603](../boringNotch/components/Settings/SettingsView.swift#L603) |
| `Media controls` | Media controls | Управление плеером | Перевести | [SettingsView.swift:608](../boringNotch/components/Settings/SettingsView.swift#L608) |
| `Customize which controls appear in the music player. Volume expands when active.` | Customize which controls appear in the music player. Volume expands when active. | Выберите элементы управления плеером. Регулятор громкости разворачивается при использовании. | Перевести | [SettingsView.swift:610](../boringNotch/components/Settings/SettingsView.swift#L610) |
| `Reset to Defaults` | Reset to Defaults | Сбросить расположение | Перевести | [MusicSlotConfigurationView.swift:27](../boringNotch/components/Settings/MusicSlotConfigurationView.swift#L27) |
| `Clear slot` | Clear slot | Очистить слот | Перевести | [MusicSlotConfigurationView.swift:93](../boringNotch/components/Settings/MusicSlotConfigurationView.swift#L93) |
| `Layout Preview` | Layout Preview | Предпросмотр расположения | Перевести | [MusicSlotConfigurationView.swift:106](../boringNotch/components/Settings/MusicSlotConfigurationView.swift#L106) |
| `Drag items in the preview to reorder or drop from the palette` | Drag items in the preview to reorder or drop from the palette | Перетаскивайте элементы в предпросмотре, чтобы изменить порядок, или добавляйте их из палитры | Перевести | [MusicSlotConfigurationView.swift:110](../boringNotch/components/Settings/MusicSlotConfigurationView.swift#L110) |
| `Drag a control onto a slot` | Drag a control onto a slot | Перетащите элемент управления в слот | Перевести | [MusicSlotConfigurationView.swift:119](../boringNotch/components/Settings/MusicSlotConfigurationView.swift#L119) |
| `%.0f seconds` | %.0f секунды | %.0f с | Исправить перевод | [SettingsView.swift:577](../boringNotch/components/Settings/SettingsView.swift#L577) |

### Календарь

| Ключ / исходный текст | До изменения в `ru` | Предлагаемый текст | Действие | Источник |
|---|---|---|---|---|
| `Show calendar` | Show calendar | Показывать календарь | Перевести | [SettingsView.swift:639](../boringNotch/components/Settings/SettingsView.swift#L639) |
| `Hide completed reminders` | Hide completed reminders | Скрывать выполненные напоминания | Перевести | [SettingsView.swift:642](../boringNotch/components/Settings/SettingsView.swift#L642) |
| `Hide all-day events` | Hide all-day events | Скрывать события на весь день | Перевести | [SettingsView.swift:645](../boringNotch/components/Settings/SettingsView.swift#L645) |
| `Auto-scroll to next event` | Auto-scroll to next event | Автоматически прокручивать к следующему событию | Перевести | [SettingsView.swift:648](../boringNotch/components/Settings/SettingsView.swift#L648) |
| `Always show full event titles` | Always show full event titles | Всегда показывать названия событий целиком | Перевести | [SettingsView.swift:651](../boringNotch/components/Settings/SettingsView.swift#L651) |
| `Calendars` | Календари | Календари | Сохранить перевод | [SettingsView.swift:653](../boringNotch/components/Settings/SettingsView.swift#L653) |
| `Calendar access is denied. Please enable it in System Settings.` | Доступ к календарю запрещен. Пожалуйста, включите его в Системных настройках. | Доступ к календарю запрещен. Пожалуйста, включите его в Системных настройках. | Сохранить перевод | [SettingsView.swift:655](../boringNotch/components/Settings/SettingsView.swift#L655) |
| `Open Calendar Settings` | Open Calendar Settings | Открыть настройки доступа к календарю | Перевести | [SettingsView.swift:659](../boringNotch/components/Settings/SettingsView.swift#L659) |
| `Reminders` | Reminders | Напоминания | Перевести | [SettingsView.swift:689](../boringNotch/components/Settings/SettingsView.swift#L689) |
| `Reminder access is denied. Please enable it in System Settings.` | Reminder access is denied. Please enable it in System Settings. | Доступ к напоминаниям запрещён. Разрешите его в настройках системы. | Перевести | [SettingsView.swift:691](../boringNotch/components/Settings/SettingsView.swift#L691) |
| `Open Reminder Settings` | Open Reminder Settings | Открыть настройки доступа к напоминаниям | Перевести | [SettingsView.swift:695](../boringNotch/components/Settings/SettingsView.swift#L695) |

### О программе

| Ключ / исходный текст | До изменения в `ru` | Предлагаемый текст | Действие | Источник |
|---|---|---|---|---|
| `Release name` | Release name | Название выпуска | Перевести | [SettingsView.swift:763](../boringNotch/components/Settings/SettingsView.swift#L763) |
| `Version` | Version | Версия | Перевести | [SettingsView.swift:769](../boringNotch/components/Settings/SettingsView.swift#L769) |
| `Version info` | Version info | Информация о версии | Перевести | [SettingsView.swift:784](../boringNotch/components/Settings/SettingsView.swift#L784) |
| `GitHub` | GitHub | GitHub | Сохранить название | [SettingsView.swift:801](../boringNotch/components/Settings/SettingsView.swift#L801) |
| `Made with 🫶🏻 by not so boring not.people` | Made with 🫶🏻 by not so boring not.people | Создано с 🫶🏻 командой not so boring not.people | Перевести | [SettingsView.swift:811](../boringNotch/components/Settings/SettingsView.swift#L811) |
| `Check for Updates…` | Проверить обновления… | Проверить обновления… | Сохранить перевод | [SoftwareUpdater.swift:32](../boringNotch/components/Settings/SoftwareUpdater.swift#L32) |
| `Automatically check for updates` | Автоматически проверять наличие обновлений | Автоматически проверять наличие обновлений | Сохранить перевод | [SoftwareUpdater.swift:51](../boringNotch/components/Settings/SoftwareUpdater.swift#L51) |
| `Automatically download updates` | Автоматически скачивать обновления | Автоматически скачивать обновления | Сохранить перевод | [SoftwareUpdater.swift:56](../boringNotch/components/Settings/SoftwareUpdater.swift#L56) |
| `Software updates` | Software updates | Обновления приложения | Перевести | [SoftwareUpdater.swift:63](../boringNotch/components/Settings/SoftwareUpdater.swift#L63) |

### Полка

| Ключ / исходный текст | До изменения в `ru` | Предлагаемый текст | Действие | Источник |
|---|---|---|---|---|
| `Enable shelf` | Enable shelf | Включить полку | Перевести | [SettingsView.swift:850](../boringNotch/components/Settings/SettingsView.swift#L850) |
| `Open shelf by default if items are present` | Open shelf by default if items are present | Открывать полку по умолчанию, если на ней есть элементы | Перевести | [SettingsView.swift:853](../boringNotch/components/Settings/SettingsView.swift#L853) |
| `Expanded drag detection area` | Expanded drag detection area | Расширенная область обнаружения перетаскивания | Перевести | [SettingsView.swift:856](../boringNotch/components/Settings/SettingsView.swift#L856) |
| `Copy items on drag` | Copy items on drag | Копировать при перетаскивании | Перевести | [SettingsView.swift:865](../boringNotch/components/Settings/SettingsView.swift#L865) |
| `Remove from shelf after dragging` | Remove from shelf after dragging | Убирать с полки после перетаскивания | Перевести | [SettingsView.swift:868](../boringNotch/components/Settings/SettingsView.swift#L868) |
| `Quick Share Service` | Quick Share Service | Сервис быстрой отправки | Перевести | [SettingsView.swift:878](../boringNotch/components/Settings/SettingsView.swift#L878) |
| `Files dropped on the shelf will be shared via this service` | Files dropped on the shelf will be shared via this service | Файлы, перетащенные на полку, будут отправлены через этот сервис | Перевести | [SettingsView.swift:916](../boringNotch/components/Settings/SettingsView.swift#L916) |
| `Quick Share` | Quick Share | Быстрая отправка | Перевести | [SettingsView.swift:927](../boringNotch/components/Settings/SettingsView.swift#L927) |
| `Choose which service to use when sharing files from the shelf. Click the shelf button to select files, or drag files onto it to share immediately.` | Choose which service to use when sharing files from the shelf. Click the shelf button to select files, or drag files onto it to share immediately. | Выберите сервис для отправки файлов с полки. Нажмите кнопку полки, чтобы выбрать файлы, или перетащите их на неё для немедленной отправки. | Перевести | [SettingsView.swift:930](../boringNotch/components/Settings/SettingsView.swift#L930) |
| `Currently selected: %@` | Currently selected: %@ | Выбран сервис: %@ | Перевести | [SettingsView.swift:913](../boringNotch/components/Settings/SettingsView.swift#L913) |

### Внешний вид

| Ключ / исходный текст | До изменения в `ru` | Предлагаемый текст | Действие | Источник |
|---|---|---|---|---|
| `Always show tabs` | Всегда показывать вкладки | Всегда показывать вкладки | Сохранить перевод | [SettingsView.swift:958](../boringNotch/components/Settings/SettingsView.swift#L958) |
| `Show settings icon in notch` | Show settings icon in notch | Показывать значок настроек в вырезе | Перевести | [SettingsView.swift:960](../boringNotch/components/Settings/SettingsView.swift#L960) |
| `Colored spectrogram` | Colored spectrogram | Цветная спектрограмма | Перевести | [SettingsView.swift:969](../boringNotch/components/Settings/SettingsView.swift#L969) |
| `Player tinting` | Нет ключа | Текст в цвет обложки | Добавить ключ; использовать label с Text | [SettingsView.swift:972](../boringNotch/components/Settings/SettingsView.swift#L972) |
| `Enable blur effect behind album art` | Enable blur effect behind album art | Включить размытие за обложкой альбома | Перевести | [SettingsView.swift:975](../boringNotch/components/Settings/SettingsView.swift#L975) |
| `Slider color` | Slider color | Цвет ползунка | Перевести | [SettingsView.swift:977](../boringNotch/components/Settings/SettingsView.swift#L977) |
| `Use music visualizer spectrogram` | Use music visualizer spectrogram | Использовать спектрограмму музыкального визуализатора | Перевести; видимый отключённый элемент | [SettingsView.swift:987](../boringNotch/components/Settings/SettingsView.swift#L987) |
| `Selected animation` | Selected animation | Выбранная анимация | Перевести | [SettingsView.swift:994](../boringNotch/components/Settings/SettingsView.swift#L994), [SettingsView.swift:1008](../boringNotch/components/Settings/SettingsView.swift#L1008) |
| `No custom animation available` | No custom animation available | Пользовательских анимаций нет | Перевести | [SettingsView.swift:1010](../boringNotch/components/Settings/SettingsView.swift#L1010) |
| `Custom music live activity animation` | Custom music live activity animation | Своя анимация воспроизведения | Перевести | [SettingsView.swift:1017](../boringNotch/components/Settings/SettingsView.swift#L1017) |
| `Coming soon` | Coming soon | Скоро | Перевести; подключить локализацию | [SettingsView.swift:1018](../boringNotch/components/Settings/SettingsView.swift#L1018), [SettingsView.swift:1392](../boringNotch/components/Settings/SettingsView.swift#L1392) |
| `selected` | selected | выбрано | Перевести | [SettingsView.swift:1034](../boringNotch/components/Settings/SettingsView.swift#L1034) |
| `No custom visualizer` | No custom visualizer | Пользовательских визуализаторов нет | Перевести | [SettingsView.swift:1097](../boringNotch/components/Settings/SettingsView.swift#L1097) |
| `Add new visualizer` | Добавить визуализатор | Добавить визуализатор | Сохранить перевод | [SettingsView.swift:1104](../boringNotch/components/Settings/SettingsView.swift#L1104) |
| `Name` | Name | Название | Перевести | [SettingsView.swift:1107](../boringNotch/components/Settings/SettingsView.swift#L1107) |
| `Lottie JSON URL` | Lottie JSON URL | URL JSON-анимации Lottie | Перевести | [SettingsView.swift:1108](../boringNotch/components/Settings/SettingsView.swift#L1108) |
| `Speed` | Speed | Скорость | Перевести | [SettingsView.swift:1110](../boringNotch/components/Settings/SettingsView.swift#L1110) |
| `Cancel` | Отмена | Отмена | Сохранить перевод | [SettingsView.swift:1122](../boringNotch/components/Settings/SettingsView.swift#L1122) |
| `Add` | Добавить | Добавить | Сохранить перевод | [SettingsView.swift:1140](../boringNotch/components/Settings/SettingsView.swift#L1140) |
| `Custom vizualizers (Lottie)` | Custom vizualizers (Lottie) | Пользовательские визуализаторы (Lottie) | Перевести | [SettingsView.swift:1152](../boringNotch/components/Settings/SettingsView.swift#L1152) |
| `Enable boring mirror` | Enable boring mirror | Включить зеркало | Перевести | [SettingsView.swift:1162](../boringNotch/components/Settings/SettingsView.swift#L1162) |
| `Mirror shape` | Mirror shape | Форма зеркала | Перевести | [SettingsView.swift:1165](../boringNotch/components/Settings/SettingsView.swift#L1165) |
| `Circle` | Circle | Круг | Перевести | [SettingsView.swift:1166](../boringNotch/components/Settings/SettingsView.swift#L1166) |
| `Square` | Square | Квадрат | Перевести | [SettingsView.swift:1168](../boringNotch/components/Settings/SettingsView.swift#L1168) |
| `Show cool face animation while inactive` | Show cool face animation while inactive | Показывать анимацию лица в неактивном состоянии | Перевести | [SettingsView.swift:1172](../boringNotch/components/Settings/SettingsView.swift#L1172) |
| `Additional features` | Дополнительные возможности | Дополнительные возможности | Сохранить перевод | [SettingsView.swift:1176](../boringNotch/components/Settings/SettingsView.swift#L1176) |

### Дополнительно

| Ключ / исходный текст | До изменения в `ru` | Предлагаемый текст | Действие | Источник |
|---|---|---|---|---|
| `Accent color` | Основной цвет | Акцентный цвет | Исправить перевод | [SettingsView.swift:1237](../boringNotch/components/Settings/SettingsView.swift#L1237), [SettingsView.swift:1330](../boringNotch/components/Settings/SettingsView.swift#L1330) |
| `System` | System | Системный | Перевести | [SettingsView.swift:1238](../boringNotch/components/Settings/SettingsView.swift#L1238) |
| `Custom` | Custom | Свой | Перевести | [SettingsView.swift:1239](../boringNotch/components/Settings/SettingsView.swift#L1239) |
| `Using System Accent` | Using System Accent | Используется системный акцентный цвет | Перевести | [SettingsView.swift:1254](../boringNotch/components/Settings/SettingsView.swift#L1254) |
| `Your macOS system accent color` | Your macOS system accent color | Акцентный цвет из настроек macOS | Перевести | [SettingsView.swift:1256](../boringNotch/components/Settings/SettingsView.swift#L1256) |
| `Color Presets` | Color Presets | Готовые цвета | Перевести | [SettingsView.swift:1266](../boringNotch/components/Settings/SettingsView.swift#L1266) |
| `Pick a Color` | Pick a Color | Выбор цвета | Перевести | [SettingsView.swift:1293](../boringNotch/components/Settings/SettingsView.swift#L1293) |
| `Choose any color` | Choose any color | Выберите любой цвет | Перевести | [SettingsView.swift:1295](../boringNotch/components/Settings/SettingsView.swift#L1295) |
| `Choose between your system accent color or customize it with your own selection.` | Choose between your system accent color or customize it with your own selection. | Используйте системный акцентный цвет или выберите свой. | Перевести | [SettingsView.swift:1332](../boringNotch/components/Settings/SettingsView.swift#L1332) |
| `Enable window shadow` | Enable window shadow | Включить тень окна | Перевести | [SettingsView.swift:1343](../boringNotch/components/Settings/SettingsView.swift#L1343) |
| `Corner radius scaling` | Corner radius scaling | Изменять скругление углов при раскрытии | Перевести | [SettingsView.swift:1346](../boringNotch/components/Settings/SettingsView.swift#L1346) |
| `Window Appearance` | Window Appearance | Внешний вид окна | Перевести | [SettingsView.swift:1349](../boringNotch/components/Settings/SettingsView.swift#L1349) |
| `App icon` | Значок приложения | Значок приложения | Сохранить перевод | [SettingsView.swift:1391](../boringNotch/components/Settings/SettingsView.swift#L1391) |
| `Extend hover area` | Extend hover area | Расширить область наведения | Перевести | [SettingsView.swift:1398](../boringNotch/components/Settings/SettingsView.swift#L1398) |
| `Hide title bar` | Hide title bar | Скрывать заголовок окна | Перевести | [SettingsView.swift:1401](../boringNotch/components/Settings/SettingsView.swift#L1401) |
| `Show notch on lock screen` | Show notch on lock screen | Показывать вырез на экране блокировки | Перевести | [SettingsView.swift:1404](../boringNotch/components/Settings/SettingsView.swift#L1404) |
| `Hide from screen recording` | Hide from screen recording | Скрывать при записи экрана | Перевести | [SettingsView.swift:1407](../boringNotch/components/Settings/SettingsView.swift#L1407) |
| `Window Behavior` | Window Behavior | Поведение окна | Перевести | [SettingsView.swift:1410](../boringNotch/components/Settings/SettingsView.swift#L1410) |
| `Use your macOS system accent color` | Use your macOS system accent color | Использовать системный акцентный цвет macOS | Перевести; LocalizedStringKey подтверждён | [SettingsView.swift:1502](../boringNotch/components/Settings/SettingsView.swift#L1502) |

### Сочетания клавиш

| Ключ / исходный текст | До изменения в `ru` | Предлагаемый текст | Действие | Источник |
|---|---|---|---|---|
| `Toggle Sneak Peek:` | Toggle Sneak Peek: | Показать или скрыть краткий обзор: | Перевести | [SettingsView.swift:1510](../boringNotch/components/Settings/SettingsView.swift#L1510) |
| `Sneak Peek shows the media title and artist under the notch for a few seconds.` | Sneak Peek shows the media title and artist under the notch for a few seconds. | Краткий обзор на несколько секунд показывает название трека и исполнителя под вырезом. | Перевести | [SettingsView.swift:1514](../boringNotch/components/Settings/SettingsView.swift#L1514) |
| `Toggle Notch Open:` | Toggle Notch Open: | Открыть или закрыть вырез: | Перевести | [SettingsView.swift:1522](../boringNotch/components/Settings/SettingsView.swift#L1522) |

## Динамические подписи и AppKit

Этот раздел фиксирует обнаруженные до реализации динамические подписи. Переводы и пути отображения уже подключены; исходные пометки «Ключ отсутствует» описывают состояние на HEAD `4649d1b`. Значения `rawValue`, `.tag`, `id`, сериализацию и сохраняемые ключи менять нельзя.

| Источник значения | Сейчас | Предложение | Каталог / действие |
|---|---|---|---|
| [OptionKeyAction](../boringNotch/models/Constants.swift#L81), отображение `SettingsView.swift:433` | Open System Settings | Открыть настройки системы | Ключ отсутствует; отдельная локализованная подпись |
| Там же | Show HUD | Показать индикатор | Ключ отсутствует; отдельная локализованная подпись |
| Там же | No Action | Ничего не делать | Ключ отсутствует; отдельная локализованная подпись |
| [MediaControllerType](../boringNotch/models/Constants.swift#L45), отображение `SettingsView.swift:528` | Now Playing | Сейчас играет | Ключ отсутствует; отдельная подпись для системного источника |
| Там же | Apple Music, Spotify, YouTube Music | Сохранить | Бренды; не переводить |
| [SneakPeekStyle](../boringNotch/models/Constants.swift#L64), отображение `SettingsView.swift:569` | Default | По умолчанию | Уже есть английское значение в `ru`; дополнительно подключить отображение |
| Там же | Inline | Встроенный | Уже есть английское значение в `ru`; дополнительно подключить отображение |
| [SliderColorEnum](../boringNotch/enums/generic.swift#L43), отображение `SettingsView.swift:978` | White | Белый | Ключ отсутствует; отдельная локализованная подпись |
| Там же | Match album art | Как на обложке альбома | Ключ отсутствует; отдельная локализованная подпись |
| Там же | Accent color | Акцентный цвет | До изменения в `ru` «Основной цвет», но `Text(option.rawValue)` не использует его |
| [MusicControlButton.label](../boringNotch/models/MusicControlButton.swift#L48), палитра `MusicSlotConfigurationView.swift:152` | Shuffle | Перемешать | Ключ отсутствует; локализовать вычисляемую подпись |
| Там же | Previous | Предыдущий | Ключ отсутствует |
| Там же | Play/Pause | Пуск/пауза | Ключ отсутствует; проверить длину в палитре |
| Там же | Next | Следующий | Ключ отсутствует |
| Там же | Repeat | Повтор | Ключ отсутствует |
| Там же | Volume | Громкость | Ключ отсутствует |
| Там же | Favorite | Избранное | Ключ отсутствует |
| Там же | Backward 15s | Назад на 15 с | Ключ отсутствует |
| Там же | Forward 15s | Вперёд на 15 с | Ключ отсутствует |
| Там же | Empty slot | Пустой слот | Ключ отсутствует; `.none` не входит в текущую палитру, его подпись не отображается в активном предпросмотре; резерв, не обязательная видимая строка |
| [SettingsWindowController.swift:43](../boringNotch/components/Settings/SettingsWindowController.swift#L43) | Boring Notch Settings | Настройки Boring Notch | Ключ отсутствует; явно локализовать `window.title` |
| [QuickShareService.swift:73](../boringNotch/components/Shelf/Services/QuickShareService.swift#L73) и fallback в конце файла | System Share Menu | Системное меню отправки | Ключ отсутствует; локализовать отображение собственного fallback, сохранив его `id` |
| [SettingsView.swift:775](../boringNotch/components/Settings/SettingsView.swift#L775) | unkown | Неизвестно | Ключ отсутствует; опечатка в fallback при отсутствии версии; лучше отдельный корректный исходный ключ, фактическую версию не переводить |

У названий системных сервисов `QuickShareProvider.id` сейчас одновременно служит подписью, ключом `cachedServices` и значением Defaults. Источник обычных сервисов — `NSSharingService.title`. Для собственного `System Share Menu` нужна отдельная подпись без замены идентификатора. Перепроектирование всей системы идентификаторов сервисов не требуется для этой задачи.

`MirrorShapeEnum` и `WindowHeightMode` хранят английские raw values, но в настройках их варианты представлены отдельными буквальными `Text`. Их сохранённые значения переводить не нужно. `PresetAccentColor` содержит Blue, Purple, Pink, Red, Orange, Yellow, Green, Graphite, но текущие кнопки цвета не выводят эти имена. Добавление русских accessibility labels этим кнопкам можно рассмотреть отдельно; это не обнаруженные видимые английские подписи.

## Вход в настройки и связанные меню

| Ключ | До изменения в `ru` | Предложение | Источник |
|---|---|---|---|
| Settings | Settings | Настройки | [boringNotchApp.swift:33](../boringNotch/boringNotchApp.swift#L33), [ContentView.swift:185](../boringNotch/ContentView.swift#L185) |
| Restart Boring Notch | Restart Boring Notch | Перезапустить Boring Notch | [boringNotchApp.swift:41](../boringNotch/boringNotchApp.swift#L41) |
| Quit | Quit | Завершить | [boringNotchApp.swift:44](../boringNotch/boringNotchApp.swift#L44) |
| Check for Updates… | Проверить обновления… | Сохранить | [SoftwareUpdater.swift:32](../boringNotch/components/Settings/SoftwareUpdater.swift#L32), вызывается также в строке меню |

Кнопка-шестерёнка в `BoringHeader` не имеет видимого английского текста. Добавлять ей локализованную подсказку или accessibility label — возможная отдельная задача, а не исправление найденной английской строки.

## Числа, форматы и смысл подписи

### Время и скорость нельзя переводить одним ключом

`%.1fs` используется для задержки наведения (`SettingsView.swift:335`) и скорости анимации (`SettingsView.swift:1111`). В первом случае предложение — `%.1f с`. Во втором `speed` передаётся в `LottieAnimationView.animationSpeed` ([LottieView.swift:40](../boringNotch/components/LottieView.swift#L40)); это множитель, а не длительность в секундах. Нужен отдельный ключ с отображением вроде `%.1f×`. Менять значение `speed`, диапазон 0…2 или поведение анимации не требуется.

Таблица буквальных строк фиксирует текущий общий ключ; её предложение «с» относится только к задержке. Применять его к скорости нельзя. Это единственное предлагаемое разделение форматного ключа в данном исследовании; подтверждение в форме Lottie обязательно.

`%.0f seconds` сейчас переведено как `%.0f секунды`. Для диапазона 0…10 это даёт неправильную форму, например «1 секунды» и «5 секунды». Предлагается компактное `%.0f с`, без новых правил склонения и изменения типа значения.

`Custom notch size - %.0f` уже существует в каталоге; числовой placeholder сохраняется. Чистые форматы ` – %lld`, `(%@)` и подписи индексов/номеров версий не требуют перевода. В `Currently selected: %@` переводится только оболочка, значение имени сервиса сохраняется.

### Смысл подписей после технической перепроверки

- `Hierarchical` управляет отсутствием градиента у шкалы: при `enableGradient == false` применяется однотонная заливка в `SystemEventIndicatorModifier.swift:114`. Поэтому предложение — «Однотонная», а не буквальное «Иерархическая».
- Для `Preferred display` предложено «Предпочтительный экран». Альтернатива — «Экран для выреза». Формулировка «Основной экран» не подходит: код меняет только выбор приложения, а не основной дисплей macOS.
- `Media inactivity timeout` связан с установкой `isPlayerIdle` после `Task.sleep` в [MusicManager.swift:539](../boringNotch/managers/MusicManager.swift#L539). В `ContentView.swift:289` это состояние скрывает `MusicLiveActivity`, а не закрывает всё окно. Уточнённая подпись — «Задержка скрытия музыкального индикатора»; проверить её длину в интерфейсе.
- `Square` помечает `MirrorShapeEnum.rectangle`. В `WebcamView.swift:26` ширина и высота берутся из одного `geometry.size.width`, поэтому подпись «Квадрат» подтверждена геометрией исходного кода. Скругление углов не меняется.
- `Reset to Defaults` сбрасывает только `musicControlSlots`, а не все настройки. Поэтому в реестре предложено «Сбросить расположение».
- Полка хранит не только файлы, но и другие элементы. Поэтому для `Open shelf by default if items are present` предложено «Открывать полку по умолчанию, если на ней есть элементы».
- Player tinting меняет цвет имени исполнителя, временных отметок и строки краткого обзора по цвету обложки (`NotchHomeView.swift:150,504`, `ContentView.swift:329`). Поэтому выбрано «Текст в цвет обложки»: прежнее «Тонировать плеер» могло подразумевать окрашивание всего окна.
- Для `Request Accessibility` важно проверить фактический системный диалог и его расположение. Переводить нужно подпись и объяснение, а не менять логику получения разрешения XPC.
- Атрибуция `not so boring not.people` содержит игру слов. Предложение сохраняет имя авторов; окончательную формулировку стоит согласовать отдельно.

## Сторонние элементы, соседние диалоги и исключения

### Требуют проверки в собранном приложении

Закреплённые версии: Defaults 9.0.6, LaunchAtLogin-Modern 1.1.0, KeyboardShortcuts 2.4.0 и Sparkle 2.9.1. При перепроверке прочитаны исходники первых трёх по точным commit SHA из `Package.resolved`; API и ссылки зафиксированы ниже. В установленном bundle обнаружены русские ресурсы KeyboardShortcuts и Sparkle. Внутренние тексты Recorder, конфликтов сочетаний и стандартного выбора цвета всё ещё требуют визуальной проверки. Правка собственного каталога не гарантирует изменение внутренних ресурсов зависимостей.

Sparkle создаётся с `startingUpdater: false` в `boringNotchApp.swift:24`. При этом элементы обновлений остаются в меню и разделе «О программе». Их видимые подписи входят в реестр. Включать updater, возвращать feed или менять доступность кнопок ради локализации нельзя.

### Дополнительный охват, который пока не включён в реализацию

| Область | Что обнаружено | Предлагаемая граница |
|---|---|---|
| Диалог доступа к камере | `Camera Access Required`, `Please allow camera access in System Settings.`, `Open Settings`, `Cancel` задаются обычными строками в `BoringViewModel.swift:152–155` | Это действие зеркала в вырезе, а не текст окна настроек. Возможные переводы: «Требуется доступ к камере», «Разрешите доступ к камере в настройках системы», «Открыть настройки», «Отмена». Если включать, явно локализовать все AppKit-подписи, включая Cancel, уже имеющий перевод в каталоге |
| Выбор файлов для отправки | `Select Files for <provider>`, `Choose files to share via <provider>` в `QuickShareService.swift` | Соседний поток полки. Предложения: «Выбор файлов для %@», «Выберите файлы для отправки через %@». Сохранить имя сервиса как данные |
| Privacy-пояснения приложения | Английские `NSAppleEventsUsageDescription`, `NSCalendarsUsageDescription`, `NSCameraUsageDescription`, `NSRemindersUsageDescription` в Debug/Release `project.pbxproj:1201–1205,1255–1259` | Отдельные системные запросы. В checkout нет `InfoPlist.strings`/`InfoPlist.xcstrings`. Возможная отдельная локализация ресурсов InfoPlist; сначала проверить реальные запросы и итоговый Info.plist |
| Онбординг и What's New | Собственные английские тексты в `components/Onboarding` и окне новых возможностей | Не относятся к текущему охвату; их перевод нужен для полной локализации всего приложения |
| Календарь/батарея/полка вне настроек | Например All-day, No events, Charging, Drop files here остаются английскими в `ru` | Отдельная следующая задача; текущий документ не объявляет приложение целиком русифицированным |

### Не включать в список обязательных исправлений настроек

- `EditPanelView`: тексты Edit layout и Close присутствуют в файле, но активного вызова в приложении нет; найден вызов в `#Preview` и закомментированная ссылка в `ContentView.swift:192`.
- `proFeatureBadge()`, `comingSoonTag()`, `warningBadge(...)`: активных вызовов не найдено. Строка Coming soon из используемого `customBadge` включена в основной реестр; Upgrade to Pro не включается как видимая настройка.
- `slotConfigRow(for:)`: не вызывается из активного layout; его числовая подпись не требует перевода.
- Downloads и Extensions: навигационные ссылки закомментированы. Ветка `case "Extensions"` существует, но из текущей боковой панели не выбирается.
- `PresetAccentColor.rawValue`: названия не отображаются текущими цветными кнопками.
- Бренды Boring Notch, boring.notch, Apple Music, Spotify, YouTube Music, AirDrop, GitHub, Lottie и URL pear-desktop не переводятся.
- Release name `Flying Rabbit 🐇🪽`, номер версии, название дисплея, календаря, списка напоминаний, визуализатора и сервиса — данные, а не собственные UI-ключи.

14 ключей `stale`: Add manually; Description; Disable; Disabled; Downloads; Enable colored spectrograms; Extensions; Installed extensions; No extension installed; Restart; Running; Stopped; Support Us; Uninstall. Не удалять и не переводить их автоматически только ради этой задачи. `stale` — метаданные каталога, а не самостоятельная проверка достижимости.

## Приоритеты и предполагаемые изменения после перепроверки

| Приоритет | Охват | Что потребуется |
|---|---|---|
| P1 | Активные разделы, заголовок окна, меню, варианты списков, музыкальная палитра, бейджи, чувствительность и пояснения разрешений | Переводы `ru`, недостающие ключи, явная локализация rawValue-подписей, музыкальной палитры, бейджей, Player tinting и AppKit-заголовка |
| P2 | Уже видимые отключённые функции, языковая правка существующих переводов, форматы времени/скорости, fallback неизвестной версии | Не менять доступность функций; согласовать уточнения, разделить ключ времени и скорости |
| P3 | Соседние системные диалоги, privacy-тексты, онбординг и весь остальной интерфейс, новые accessibility labels, старые ключи | Отдельное решение об охвате; не расширять текущую реализацию автоматически |

Ожидаемые файлы реализации: `Localizable.xcstrings`, `SettingsView.swift`, `SettingsWindowController.swift`, `Constants.swift`, `generic.swift`, `MusicControlButton.swift`. Для подписи System Share Menu достаточно отдельного отображаемого текста в месте использования; если потребуется изменить модель подписи, возможен `QuickShareService.swift`. Изменение `project.pbxproj` допустимо только при доказанной необходимости для ресурсов/регионов. Сигнатуры собственных вызовов библиотек проверены; конкретные рекомендации приведены ниже.

Не требуется менять Defaults keys, значения enum, shortcut names, идентификаторы навигации, названия SF Symbols, URL, данные пользователя, схему перетаскивания или сетевые/защитные настройки форка. Переводы остальных 15 локалей должны сохраниться. Новые исходные ключи остаются английскими; отсутствие перевода в других локалях проверяется отдельно без их массового заполнения.

## Результаты технической перепроверки

Перепроверка проведена 12 октября 2026 года на том же HEAD `4649d1b`. Исходный код и каталог не изменялись. Сведения о сторонних библиотеках получены из официальных репозиториев по закреплённым commit SHA, а не из документации последней версии.

### Проверенные API

| Вызов | Подтверждённое поведение | Решение для реализации | Первичный источник |
|---|---|---|---|
| `Defaults.Toggle("Player tinting", key: ...)` | Инициализатор принимает `some StringProtocol`, внутри вызывает `Text(title)` | Использовать существующую форму `Defaults.Toggle(key: ...) { Text("Player tinting") }`; добавить ключ в каталог | [Defaults 9.0.6, SwiftUI.swift:236–244](https://github.com/sindresorhus/Defaults/blob/8192b0986611e105355a9433e99bf5c79469fbbd/Sources/Defaults/SwiftUI.swift#L236) |
| `LaunchAtLogin.Toggle("Launch at login")` | Есть конкретная перегрузка `LocalizedStringKey` с `Text(titleKey)` и отдельная generic-перегрузка для готовой строки | Текущая буквальная подпись подходит; добавить недостающий ключ, не менять запуск при входе | [LaunchAtLogin-Modern 1.1.0:101–123](https://github.com/sindresorhus/LaunchAtLogin-Modern/blob/a04ec1c363be3627734f6dad757d82f5d4fa8fcc/Sources/LaunchAtLogin/LaunchAtLogin.swift#L101) |
| `KeyboardShortcuts.Recorder("...", name: ...)` | Есть перегрузка `LocalizedStringKey`; перегрузка `String` отмечена `@_disfavoredOverload` | Сохранить текущие вызовы с литералами, перевести собственные ключи; shortcut names не менять | [KeyboardShortcuts 2.4.0, Recorder.swift:109–147](https://github.com/sindresorhus/KeyboardShortcuts/blob/1aef85578fdd4f9eaeeb8d53b7b4fc31bf08fe27/Sources/KeyboardShortcuts/Recorder.swift#L109) |
| `Text(condition ? "High" : ... "Medium" : "Low")` | Изолированный разбор AST выводит все три литерала как `LocalizedStringKey` в Swift 5 mode | Только перевод каталога; дополнительный хелпер не нужен | Локальный SwiftUI SDK и команда проверки ниже |
| `.help(condition ? "Use your macOS system accent color" : "")` | В AST выбран `help(LocalizedStringKey)` | Только перевод каталога; текущую условную подсказку сохранить | Локальный SwiftUI SDK и команда проверки ниже |
| `Text(stringVariable)` | В AST выбран generic `Text.init` с `StringProtocol`, конкретный тип `String` | Готовые пользовательские данные сохранять; собственные enum-подписи и бейджи локализовать отдельно | Локальная проверка AST |

Для проверки выбора перегрузок использован Apple Swift 6.4 с параметром `-swift-version 5`, совпадающим с `SWIFT_VERSION = 5.0` проекта. Короткий изолированный файл находился в `/tmp`; код проекта и настройки сборки не изменялись. Это проверяет типизацию аналогичных выражений на доступном SDK, а не сборку проекта или поведение ранее установленного бинарника.

Минимальный воспроизводимый фрагмент:

```swift
import SwiftUI

@MainActor
func localizationProbe(_ flag: Bool, _ number: Int, _ label: String) -> some View {
    VStack {
        Text(flag ? "High" : number == 200 ? "Medium" : "Low")
        Text(label)
        Text("Beta")
        Color.clear.help(flag ? "Use your macOS system accent color" : "")
    }
}
```

```bash
xcrun swiftc -swift-version 5 -typecheck -dump-ast \
  -module-cache-path /tmp/mono-brow-localization-review-cache \
  /tmp/mono-brow-localization-probe.swift \
  > /tmp/mono-brow-localization-probe-swift5.ast
```

Важное исправление первоначального реестра: High/Medium/Low были ошибочно отнесены к подписям, которым обязательно требуется изменение пути локализации. Проверка перегрузки это опровергла; строки и рекомендации исправлены. Для Player tinting, напротив, подтверждена необходимость изменения вызова.

### Установленный bundle и язык

Проверен `/Applications/Boring Notch.app`, версия 2.7.3, build 271, bundle ID `theboringteam.boringnotch`. Полное совпадение русских ресурсов с checkout не подтверждает происхождение или полное совпадение исполняемого кода с текущим HEAD.

- В `Contents/Resources` есть все 16 локалей каталога, включая `ru.lproj`.
- В `ru.lproj/Localizable.strings` ровно 236 ключей; каждый ключ и значение совпадает с `ru` текущего `Localizable.xcstrings`. Непереведённый текст уже попал в установленный русский ресурс, а не потерялся при упаковке.
- `Bundle(path: ...).localizations` возвращает `ru`; `Bundle.preferredLocalizations(from: ..., forPreferences: ["ru"])` возвращает `["ru"]`, для `["en"]` — `["en"]`. Этого достаточно, чтобы исключить отсутствие русских ресурсов в проверенном bundle.
- Глобальный `AppleLanguages` прочитан как `ru-RU`, `en-RU`, `ar-RU`. Чтение отдельного `AppleLanguages` для домена приложения вернуло отсутствие ключа. Эти сведения не доказывают фактический язык процесса приложения.
- `bundle.preferredLocalizations` внутри отдельного Swift CLI-процесса вернул `["en"]`. Этот результат относится к окружению проверочного процесса; использовать его как доказательство английского языка Boring Notch нельзя.
- В `KeyboardShortcuts_KeyboardShortcuts.bundle` есть русский ресурс. Прочитаны тексты «Добавить», «Запись…», конфликта с системным сочетанием и конфликта с пунктом меню. Для собственных заголовков Recorder используется каталог приложения; внутренний каталог библиотеки менять не требуется.
- В Sparkle framework есть `ru.lproj/Sparkle.strings`. Его наличие не означает, что updater запущен; состояние обновлений не меняется.

Ресурс `.strings` прочитан через `plutil -convert json -o /tmp/...`: прямое чтение `plistlib` столкнулось с XML-кодировкой, поэтому статистика рассчитана по корректно преобразованному JSON. Оригинальные файлы приложения не изменялись.

### Редакционные решения

| Подпись | Выбранное предложение | Обоснование |
|---|---|---|
| Preferred display | Предпочтительный экран | Выбор приложения, без обещания сменить основной дисплей системы |
| Player tinting | Текст в цвет обложки | Проверены все три использования параметра: имя исполнителя, временные отметки и краткий обзор |
| Media inactivity timeout | Задержка скрытия музыкального индикатора | Связь `isPlayerIdle` с `MusicLiveActivity` подтверждена; не обещает закрытие окна |
| Reset to Defaults | Сбросить расположение | Сбрасывается только раскладка музыкальных кнопок |
| Square | Квадрат | Исходный код задаёт одинаковые ширину и высоту зеркала |
| Inline | Встроенный | HUD и музыкальный обзор встраиваются в закрытый вырез; сохранить общий ключ, окончательную понятность проверить визуально |
| Default | По умолчанию | Подходит для стиля HUD, обзора и иконки без согласования рода |
| `%.1fs` | `%.1f с` для задержки; отдельный ключ с `%.1f×` для скорости | Время и множитель скорости имеют разный смысл |

Остальные термины из таблицы выше сохранены как рабочий вариант. Атрибуция авторов остаётся предложением с сохранением их имени. Выбранные формулировки не объявляются отдельно утверждёнными пользователем; их можно изменить при просмотре документа или будущей сборки.

### Граница и открытые проверки

Меню входа в настройки и собственная подпись System Share Menu остаются в текущем охвате. Камера, выбор файлов, InfoPlist, онбординг, весь остальной интерфейс и новые accessibility labels остаются отдельным охватом. При повторном чтении `WebcamView.swift` обнаружен ещё один вариант AppKit-диалога камеры с пояснением `Please allow camera access in System Settings to use the mirror feature.` и кнопкой `Open System Settings`; при расширении задачи нужно учесть оба варианта диалога, а не только `BoringViewModel`.

Через `cua.getApp` выполнены две попытки получить приложение по имени и полному пути; обе вернули `Running application not found: theboringteam.boringnotch`. Настройки и разрешения приложения не менялись. Поэтому утверждать, что десять вкладок визуально просмотрены, нельзя. Просмотр условных состояний и проверка русской компоновки перенесены в проверку реализации; менять пользовательские параметры ради просмотра сейчас не требуется.

Окружение сборки также проверено: активен `/Library/Developer/CommandLineTools`; `xcodebuild -version` сообщает, что требуется Xcode. В `/Applications` не найдено `Xcode*.app`. Для полноценной сборки по README нужен установленный Xcode 26+; это ограничение сборочной проверки, а не основание менять проект или устанавливать инструменты без отдельной задачи.

### Чек-лист перепроверки

- [x] Повторно сверены источник и HEAD, каталог, русские значения и ссылки основного реестра.
- [x] Проверены API Defaults.Toggle, LaunchAtLogin.Toggle, KeyboardShortcuts.Recorder и help; исправлена классификация High/Medium/Low.
- [x] Уточнены смысловые подписи Preferred display, Player tinting, Media inactivity timeout, Reset to Defaults и Square.
- [x] Проверены русские ресурсы установленного приложения и выбор `ru` при явном предпочтении; необходимость менять knownRegions не подтверждена.
- [x] Зафиксированы граница задачи и отдельный охват соседних диалогов.
- [ ] Визуально проверить десять разделов, длинные переводы, Inline и атрибуцию в будущей сборке. Причина переноса: UI-инструмент не получил приложение; полного изменённого app bundle ещё нет.
- [ ] Полностью собрать и проверить приложение после реализации. Причина переноса: изменения сделаны, но в проверенном окружении нет доступного Xcode.

### Минимальная схема реализации

1. Заполнить согласованные `ru`-значения существующих активных ключей и добавить недостающие собственные ключи; сохранять данные остальных локалей и не удалять stale.
2. Добавить локализованные отображаемые подписи enum и музыкальных кнопок отдельно от raw values; использовать их только там, где сейчас выводятся собственные английские значения.
3. Сделать `customBadge` локализуемым, заменить только строковый вызов Player tinting на вариант с `Text` и явно локализовать заголовок окна. High/Medium/Low, help, Recorder и существующий вызов LaunchAtLogin не требуют нового хелпера.
4. Локализовать отображение собственного System Share Menu без замены `provider.id`; не переводить имена системных сервисов как ключи приложения.
5. Разделить отображаемые форматы задержки и скорости анимации; локализовать fallback отсутствующей версии отдельным корректным исходным ключом.
6. Выполнить проверки каталога, placeholder-типов, сохранённых идентификаторов и границы diff. Полную сборку и визуальную проверку выполнить в окружении с Xcode; до этого не объявлять перевод проверенным в работающем приложении.

## Проверки после будущей реализации

1. Проверить JSON каталога, сохранность всех чужих локалей и placeholder-типов. У новых форматных ключей сверить фактическое извлечение строк Xcode.
2. Убедиться, что динамические подписи ищут перевод, а пользовательские и системные названия продолжают отображаться как данные. Проверить неизменность `.tag`, raw values, идентификаторов и Defaults keys.
3. Собрать по существующему процессу проекта. Проверить русские ресурсы итогового bundle. Сборку и изменения каталога от извлечения строк просмотреть отдельно; не принимать неожиданный diff автоматически.
4. Открыть все десять разделов на русском. Проверить обычные и условные состояния: свои размеры; жесты; отсутствие/наличие Accessibility; открытый/закрытый HUD; оба доступных варианта источников медиа; отсутствие/наличие календарных разрешений; пустые/заполненные визуализаторы и форму добавления; системный/свой акцентный цвет; выбранный системный/обычный сервис отправки.
5. Проверить длинные подписи и пояснения в окне шириной 700, музыкальную палитру шириной 60 и ограничением в две строки, Sidebar шириной 200, подсказки, бейджи и Recorder. Зафиксировать обрезание и ошибки смысла.
6. Проверить значения задержек 0, 1, 2, 5, 10 секунд и множитель скорости Lottie. Переведённые значения не должны менять диапазоны или поведение.
7. Сравнить сохранённые настройки до/после перезапуска; выбранные enum, сервис, сочетания и расположение музыкальных кнопок должны сохраниться. Проверить английскую локаль на отсутствие русского текста и технических ключей.
8. Просмотреть полный diff: изменения ограничены согласованной локализацией, автообновления и защитные настройки не изменились. Удаление старых ключей и расширение охвата вынести отдельно.

В рамках реализации выполнены проверки каталога, моделей, инвариантов сохранения и изменённых SwiftUI-вызовов; результаты зафиксированы ниже. Полная сборка приложения, проверка нового app bundle и визуальная проверка десяти разделов ещё не выполнялись. Установленное приложение остаётся прежним.

## Как повторить сбор сведений

```bash
git status --short
git rev-parse HEAD
rg --files -g '*.xcstrings' -g '*.strings' -g '*.stringsdict'
rg -n 'Text\(|Label\(|Picker\(|Toggle\(|Recorder\(|navigationTitle|customBadge|\.help\(' boringNotch/components/Settings
rg -n 'rawValue|var label|System Share Menu|window.title' boringNotch/models boringNotch/enums boringNotch/components/Settings boringNotch/components/Shelf/Services/QuickShareService.swift
```

Статистику можно повторить без сборки:

```python
import json
from collections import Counter
from pathlib import Path

catalog = json.loads(Path("boringNotch/Localizable.xcstrings").read_text())
strings = catalog["strings"]
ru = {key: item["localizations"]["ru"]["stringUnit"]
      for key, item in strings.items()}
print("keys:", len(strings))
print("ru:", len(ru))
print("same:", sum(unit["value"] == key for key, unit in ru.items()))
print("different:", sum(unit["value"] != key for key, unit in ru.items()))
print("states:", Counter(unit["state"] for unit in ru.values()))
print("stale:", sum(item.get("extractionState") == "stale"
                    for item in strings.values()))
```

Поиск регулярными выражениями — средство навигации, а не доказательство полноты. Реестр составлен со сверкой форм, вспомогательных компонентов, динамических значений, комментариев и условных веток. Таблицы исходных значений относятся к зафиксированному коммиту `4649d1b`. Ссылки на изменённые Swift-файлы перенумерованы для текущего рабочего дерева; сведения об установленном bundle относятся к прежней сборке.

## Реализация и проверка

Реализация выполнена 12 октября 2026 года в текущем checkout на `main`, без коммита, push, установки или изменения приложения в `/Applications`. Перед изменениями проверены корень Git, единственное рабочее дерево и dirty state. Единственный ранее изменённый путь — `docs/`, созданный в рамках этой же задачи. Все семь изменённых файлов приложения до реализации были чистыми.

| Файл | Изменение |
|---|---|
| `boringNotch/Localizable.xcstrings` | 145 существующих русских значений обновлены, 23 собственных ключа добавлены; итог — 259 ключей. Новые ключи имеют явные `en`/`ru` и `extractionState: manual`; обновлённые переводы помечены `translated`. Существующие ключи и их порядок сохранены |
| `boringNotch/models/Constants.swift` | Добавлены `displayName` для MediaControllerType, SneakPeekStyle и OptionKeyAction. Бренды музыкальных приложений возвращают исходный raw value |
| `boringNotch/enums/generic.swift` | Добавлена отображаемая подпись SliderColorEnum |
| `boringNotch/models/MusicControlButton.swift` | Вычисляемая `label` локализуется через буквальные ключи Foundation; raw values, Codable и раскладка не меняются |
| `boringNotch/components/Shelf/Services/QuickShareService.swift` | `QuickShareProvider.displayName` переводит только собственный System Share Menu; `id`, системные названия, кеш и отправка не меняются |
| `boringNotch/components/Settings/SettingsView.swift` | Списки используют displayName; Player tinting использует label с Text; customBadge принимает LocalizedStringKey; скорость отображается как множитель; fallback версии — локализованный Unknown |
| `boringNotch/components/Settings/SettingsWindowController.swift` | Заголовок окна локализуется явно |

Результат для меню, десяти вкладок, переключателей, пояснений и музыкальной палитры задан уточнённым реестром. Существующие приемлемые переводы сохранены. Резервная подпись Empty slot также переведена при локализации общей `MusicControlButton.label`, хотя активная палитра её не показывает. Скорость и задержка используют разные ключи `%.1f×` и `%.1fs`.

### Выполненные проверки

| Проверка | Результат и граница доказательства |
|---|---|
| Целевой каталог до изменения | FAIL: 168 несовпадений из 186 требуемых ключей; выявлялись английские значения и отсутствующие ключи |
| Целевой каталог после изменения | PASS: все 186 значений соответствуют реестру; исходные ключи, 15 других локалей, подстановки и записи вне охвата сохранены |
| Исходная музыкальная подпись | Изолированный Swift host с исходным MusicControlButton воспроизводит FAIL: ожидается «Перемешать», получено Shuffle |
| Изменённые модели, русский язык | PASS: 53 поведенческие проверки, включая enum-подписи, бренды, пользовательские названия сервисов, fallback, заголовок, единицы времени/скорости и сериализацию |
| Те же модели, английский язык | PASS: 53 проверки; русские значения не попадают в английское отображение |
| Совместимость сохранения | Настоящий Defaults.bridge выполняет serialize/deserialize всех 22 случаев пяти enum; Codable-раскладка музыкальных кнопок проходит JSON round trip. Проверки не записывают настройки установленного приложения |
| SwiftUI-вызовы | Компилируется изолированный фрагмент с настоящим Defaults.Toggle, отображаемыми подписями и customBadge, извлечённой из изменённого исходника. Компилятор извлекает 26 ключей; все есть в каталоге, включая Beta, Coming soon, Player tinting и отдельные форматы времени/скорости |
| Синтаксис | Все шесть изменённых Swift-файлов проходят `swiftc -frontend -parse` |
| Инварианты исходников | Enum declarations, Defaults keys, selection tags, navigation IDs и drag payload не изменены |
| Diff | `git diff --check` проходит; защитные настройки, updater, project.pbxproj, ресурсы других языков и соседние P3-потоки не изменены |

Для проверки моделей использованы настоящие исходники Defaults 9.0.6 по закреплённому SHA. Библиотека скомпилирована во временном каталоге через Command Line Tools с SDK `MacOSX26.sdk`, target `arm64-apple-macosx14.0` и Swift 5 mode. При использовании активного SDK 27 отсутствовал плагин SwiftUIMacros; переключение SDK только в проверочной команде решило это ограничение. Зависимости и настройки проекта не менялись. В зависимости остаётся предупреждение об устаревшем `onChange(of:perform:)`; оно не относится к изменениям локализации.

Изолированный host включает реальные объявления трёх enum из Constants, полный generic.swift и MusicControlButton.swift, объявление QuickShareProvider и ресурсы, сформированные из текущего каталога. Он проверяет Foundation-локализацию и модели, но не запускает Boring Notch, не включает всё дерево SettingsView и не заменяет сборку Xcode.

В текущей сессии проверки доступны во временных файлах:

```bash
python3 /tmp/mono-brow-verify-localization.py
python3 /tmp/mono-brow-build-localization-probe.py after
/tmp/mono-brow-localization-after/LocalizationProbe.app/Contents/MacOS/LocalizationProbe ru -AppleLanguages '(ru)'
/tmp/mono-brow-localization-after/LocalizationProbe.app/Contents/MacOS/LocalizationProbe en -AppleLanguages '(en)'
python3 /tmp/mono-brow-ui-localization-probe.py
git diff --check
```

Эти вспомогательные файлы не добавлены в проект; `/tmp` может очищаться. Проверочная `.strings`-упаковка создана для изолированного host и не является результатом штатной компиляции `xcstrings` Xcode.

### Независимый обзор

Read-only reviewer: агент `localization_review`, 12 октября 2026 года. Вердикт **Caution**, подтверждённых P0/P1/P2/P3 нет, Review Gate **PASS** для локальных изменений. Reviewer независимо проверил каталог, исходные и изменённые данные, оба прогона по 31 проверке, пути displayName к Text, идентификаторы сервисов, палитру/drag payload, бейджи, заголовок и форматы. Дополнительные 22 проверки Defaults.bridge на язык и извлечение 26 ключей выполнены основным агентом; код приложения после независимого обзора не менялся.

Ограничение обзора: полный app build и визуальный просмотр десяти вкладок не выполнены. Нужно проверить длину подписей при ширине окна 700, боковой панели 200 и палитре 60 с двумя строками, а также реальные условные состояния. Отсутствие этих проверок не доказывает дефект, но не позволяет объявить приложение готовым к установке или релизу.

## Проверка через CI

По запросу пользователя локальная сборка не выполняется; изменения отправляются в `origin/main` для проверки в GitHub Actions. Push в main запускает [Build for macOS](../.github/workflows/cicd.yml) и [CodeQL Advanced](../.github/workflows/codeql.yml). Второй workflow включает отдельную сборку Swift в Release без подписи. Оба workflow необходимо проверять по точному SHA коммита локализации, а не по последнему зелёному запуску вообще.

Fork build запускается тегом и публикует релиз; для текущей проверки достаточно push-triggered CI. Запрос пользователя разрешает commit, push и проверку CI; установка приложения и выпуск релиза в этот этап не входят. Визуальная проверка русской компоновки остаётся отдельной задачей после получения новой сборки.

Откат исходников возможен обычным revert коммита локализации; миграций данных и изменения сохраняемых идентификаторов нет. Текущий документ хранит результаты исследования и локальных проверок до CI; фактический статус сборки доступен в Actions соответствующего коммита.

## Контрольная точка

Текущая последовательность: исследование, документирование, техническая перепроверка, `implementation`, независимый `change-review`. Пройдены: изоляция; failing/green проверки каталога; воспроизведение исходной подписи; 53 проверки моделей на каждом языке; компиляция изменённых SwiftUI-вызовов и извлечение строк; инварианты, diff и независимый обзор. Делегирование использовалось только для read-only review.

Действие: `shipping` для явно запрошенных commit и push в origin/main с последующей проверкой GitHub Actions. Доказательства до отправки: каталог, модели, SwiftUI-фрагменты, инварианты и независимый обзор. Полная сборка будет проверена через CI; визуальный просмотр нового bundle на русском и английском остаётся открытым. Локальную сборку пользователь исключил из текущего этапа.
