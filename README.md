# Русская локализация Autodesk Fusion 360

Полный русский перевод интерфейса Fusion 360 для **macOS** и **Windows**. Проверено на версии **2704.1.36** (июль 2026), на macOS — также на **2706.1.14** (октябрь 2026): новый дизайн, эскиз, выдавливание, сохранение.

> ✅ **macOS: снова всё работает (октябрь 2026).** Исправлен вылет Fusion с «критической ошибкой» при создании проекта / нового дизайна на версиях 2706.x. Если у вас Fusion падал — скачайте репозиторий заново и запустите `install-macos.command` ещё раз (подробнее — в разделе [«Fusion падает при создании проекта»](#fusion-падает-при-создании-проекта--нового-дизайна)).

> Перевод изначально собран сообществом [RusFus](https://github.com/RusFus/fusion360-rus-files) для Windows. Этот репозиторий содержит:
> - те же файлы перевода;
> - **рабочую инструкцию для macOS** (раньше её не было);
> - актуальные пути и обходной путь для проблемы с code-signature на новых версиях Fusion;
> - автоматические установочные скрипты для обеих ОС.

---

## Содержимое

```
files/
├── ru-RU/              ← 115 XML-файлов перевода UI Fusion (Neutron StringTable)
├── ru-html/            ← 2538 HTML-файлов справки модуля CAM
├── ru-html.html        ← фреймсет-обёртка для CAM-справки
└── russian_ru.xml      ← перевод строк CAM360 (1.8 МБ)

install-macos.command       ← двойной клик для установки на macOS
sanitize-placeholders.pl    ← защита от краша: сверяет плейсхолдеры %1% с установленной версией Fusion (вызывается установщиком mac### macOS

1. **Полностью закройте Fusion 360** — ⌘Q (просто закрыть окно недостаточно).
2. **Скачайте репозиторий** — один из вариантов:
   - на GitHub зелёная кнопка **Code → Download ZIP**, затем распакуйте архив двойным кликом;
   - или в Терминале:
     ```bash
     git clone https://github.com/kiryxabykiryxaby/fusion360-russian-localization.git
     ```
   > Если ставили перевод раньше — скачайте **заново**: в старой версии были строки, из‑за которых Fusion 2706.x падал.
3. **Запустите установщик.** Самый надёжный способ — через Терминал (Программы → Утилиты → Терминал):
   ```bash
   cd ~/Downloads/fusion360-russian-localization-main   # путь к распакованной папке
   xattr -dr com.apple.quarantine .                    # снять «карантин» скачанных файлов
   chmod +x install-macos.command
   ./install-macos.command
   ```
   Или дважды кликните `install-macos.command` в Finder. Если macOS напишет «не удаётся открыть, разработчик не проверен» — откройте **Системные настройки → Конфиденциальность и безопасность**, внизу нажмите **«Всё равно открыть»**, затем снова дважды кликните файл.
4. **Проверьте вывод.** При успешной установке скрипт пишет примерно так:
   ```
   → Fusion build: b9041698…
   ✓ ru-RU StringTable: 115 files
   Placeholder check: 0 string(s) reset to English
   ✓ CAM Help: 2538 files
   ✓ CAM Translations: russian_ru.xml installed
   🎉 Готово!
   ```
   `Placeholder check` — защита от вылетов: если после обновления Fusion какие‑то строки перевода перестали совпадать с новой версией, они вернутся на английский (число будет больше 0), а Fusion при этом падать не будет.
5. **Запустите Fusion 360.** Если язык системы русский, Fusion сам переключится на русский. Если нет — **Preferences → General → User Language → Russian → Restart**.

**После каждого обновления Fusion** русский пропадает (Fusion ставит новую сборку в другую папку) — закройте Fusion (⌘Q) и снова запустите `install-macos.command`.

ик не проверен» → ПКМ по файлу → **Открыть** → подтвердить. Либо в Терминале выполнить:
     ```bash
     cd путь/до/распакованной-папки
     chmod +x install-macos.command
     ./install-macos.command
     ```
4. Запустите Fusion 360. Он сам подхватит русский, если системная локаль = русская. Если нет — **Preferences → General → User Language → Russian → Restart**.

### Windows

1. Полностью закройте Fusion 360.
2. Скачайте/клонируйте этот репозиторий.
3. Дважды кликните **`install-windows.bat`**.
4. Запустите Fusion. Откройте **Preferences → General → User Language → Russian → Restart**.

Скрипт сам находит **именно ту сборку, которую Fusion реально запускает** — читает указатель в `FusionLauncher.exe.ini` (а если его нет — берёт сборку с самой новой версией `Fusion360.exe`). Он сознательно **не ориентируется на время папки**: копирование в старую сборку меняет её дату, и выбор «по свежести папки» ошибся бы. Файлы кладутся в правильную папку, в конце проверяется, что встали все 115 файлов перевода. Запускать можно сколько угодно раз.

> Вся логика вынесена в `install-windows.ps1`; `install-windows.bat` — тонкая обёртка над ним (двойной клик по `.bat` запускает `.ps1`).

---

## После обновления Fusion — один клик

Fusion при каждом крупном апдейте создаёт новую папку сборки, и файлы перевода в неё не переносятся — поэтому после обновления русский пропадает. Возврат — в один клик:

1. **Один раз** дважды кликните **`create-shortcut-windows.bat`** — на рабочем столе появится ярлык **«Вернуть русский в Fusion»**.
2. После **каждого** обновления Fusion: закройте Fusion, дважды кликните этот ярлык, запустите Fusion → **Preferences → User Language → Russian**.

Искать репозиторий заново не нужно — ярлык всегда указывает на актуальный `install-windows.bat`.

---

## Ручная установка

Если автоматический скрипт по какой-то причине не сработал, файлы можно положить руками. Ниже целевые пути для обеих ОС.

> ⚠️ `<HASH>` — папка из 40 hex-символов с именем актуальной сборки. У всех она своя. Найдите её внутри `webdeploy/production/`.

### macOS

Корень установки:
```
~/Library/Application Support/Autodesk/webdeploy/production/<HASH>/Autodesk Fusion.app/Contents/Libraries/
```

| Из репозитория | Куда копировать |
|---|---|
| `files/ru-RU/` | `Libraries/Neutron/StringTable/ru-RU/` |
| `files/ru-html/` | `Libraries/Applications/CAM360/NeuCAM/UI/NeuCAMUI/Resources/Help/ru-html/` |
| `files/ru-html.html` | `Libraries/Applications/CAM360/NeuCAM/UI/NeuCAMUI/Resources/Help/ru-html.html` |
| `files/russian_ru.xml` | `Libraries/Applications/CAM360/Data/Translations/russian_ru.xml` |

**❗ КРИТИЧЕСКИ ВАЖНО для macOS: НЕ ПЕРЕПОДПИСЫВАЙТЕ бандл.**
Не запускайте `codesign --remove-signature`, не пересохраняйте через Xcode и т.п. Если переподписать ad-hoc, сломается IPC-handshake между Fusion и Identity Manager → ошибка входа в аккаунт. Просто скопируйте файлы — оригинальная подпись Autodesk останется валидной для исполняемого Mach-O, а изменения ресурсов IDSDK не проверяет.

После ручного копирования обязательно запустите проверку плейсхолдеров (иначе Fusion может падать, см. «Fusion падает при создании проекта»):
```bash
C="$HOME/Library/Application Support/Autodesk/webdeploy/production/Autodesk Fusion.app/Contents/Libraries/Neutron/StringTable"
perl sanitize-placeholders.pl "$C/en-US" "$C/ru-RU"
```

### Windows

Корень установки:
```
C:\Users\ИМЯ\AppData\Local\Autodesk\webdeploy\production\<HASH>\
```

| Из репозитория | Куда копировать |
|---|---|
| `files/ru-RU/` | `<HASH>\StringTable\ru-RU\` |
| `files/ru-html/` | `<HASH>\NeuCAM\UI\NeuCAMUI\Resources\Help\ru-html\` |
| `files/russian_ru.xml` | `<HASH>\Applications\CAM360\Data\Translations\russian_ru.xml` |

(На Windows wrapper-файл `ru-html.html` не нужен — структура справки CAM там немного другая.)

---

## После установки

1. Запустите Fusion 360.
2. Откройте **Preferences (⌘, на Mac / Ctrl+, на Windows)**.
3. Раздел **General** → пункт **User Language**.
4. Выберите **Russian**.
5. Согласитесь на перезапуск — Fusion перезапустится уже на русском.

Если в выпадающем списке **нет** «Russian», но русский должен быть (например, для macOS русская локаль системы автоматически подхватывается) — проверьте что папка `ru-RU` действительно лежит в `StringTable/` (см. раздел «Диагностика»).

---

## Что переведено и что нет

✅ **Переведено:**
- Весь UI Fusion 360 (вкладки, меню, команды, диалоги, тултипы)
- Браузер компонентов
- Среды Sketch, Solid, Surface, Form, Sheet Metal
- Модуль Drawing
- Модуль Simulation
- Модуль Animation
- CAM (Manufacture) — основные команды и операции
- HTML-справка по командам CAM (~2500 страниц)

⚠️ **Частично переведено / на английском:**
- Несколько новых файлов из последнего обновления Fusion, которых нет в архиве (`NsFCDR10.xml` и пара других). На таких страницах будет английский — это не ошибка, просто пробел в переводе.
- Облачные диалоги (Hub/Team) — рендерятся через веб-движок, перевод там зашит на серверной стороне.
- Marketplace, Forge-сервисы.

---

## Известные проблемы и обновления

### Fusion падает при создании проекта / нового дизайна

Симптом: сразу после установки перевода Fusion вылетает с «критической ошибкой», как только открывается новый дизайн (вкладка Untitled). В отчёте о сбое:
```
boost::io::too_many_args
  Na::EIP::BeginEditInPlaceCmdDef::onIsApplicable
```

**Причина:** Fusion подставляет значения в строки через `boost::format` (`%1%`, `%2%`, …). Autodesk в обновлениях меняет английские строки — добавляет или убирает плейсхолдеры. Если в русском переводе их набор не совпадает с английским, `boost::format` бросает исключение и Fusion падает. В 2706.x в строку `BeginEIPBlockedDueToPermissions` добавили `%1%` (имя дизайна), а старый перевод его не содержал.

**Решение:**
- в репозитории исправлены все строки с несовпадающими плейсхолдерами для 2706.1.14 (26 шт.);
- `install-macos.command` после копирования запускает `sanitize-placeholders.pl`: он сверяет каждую русскую строку с английской из **установленной** версии Fusion и строки с несовпадающими плейсхолдерами возвращает на английский. Поэтому после очередного обновления Fusion отдельные строки могут стать английскими, но Fusion падать не будет. Скрипт пишет, сколько строк сброшено.

Если Fusion уже падает — обновите репозиторий и запустите `install-macos.command` ещё раз.

### Fusion обновился — русский пропал

Fusion 360 обновляется через webdeploy и при каждом крупном апдейте создаёт **новую папку** с другим `<HASH>` в `webdeploy/production/`. Старая папка с нашими файлами больше не используется.

**Решение:** просто запустите установочный скрипт снова — он сам найдёт новый `<HASH>` и положит файлы туда.

### Скрипт написал «Done», но русский не появился (несколько папок сборки)

В `webdeploy/production/` часто лежит **несколько** папок сборки: активная (её и запускает Fusion) плюс старые версии и остаточные/недокачанные сборки. После обновления там нередко оказываются сразу две папки с `Fusion360.exe` — старая и новая версии. Ранние версии установщика выбирали папку «по свежести», а время папки **ненадёжно** (копирование файлов в старую сборку обновляет её дату), поэтому файлы могли уйти в неактивную папку: скрипт писал `Done`, но Fusion перевод не видел.

**Как это решено:** актуальный `install-windows.ps1` определяет активную сборку по прямому указателю Autodesk — строке `cmd = ...\<HASH>\Fusion360.exe` в `FusionLauncher.exe.ini`. Если ini недоступен — берёт сборку с самой новой версией `Fusion360.exe`. Время папки не используется вовсе. Просто обновите скрипты из репозитория и запустите снова.

**Как проверить**, какую сборку Fusion реально запускает и куда должен лечь перевод:
```powershell
$prod = "$env:LOCALAPPDATA\Autodesk\webdeploy\production"
# активная сборка = та, что указана в FusionLauncher.exe.ini
(Get-Content (Get-ChildItem "$prod\*\FusionLauncher.exe.ini" | Select -First 1) |
  Where-Object { $_ -match 'cmd\s*=' })
# версия и наличие ru-RU в каждой папке
Get-ChildItem $prod -Directory | ForEach-Object {
  $exe = "$($_.FullName)\Fusion360.exe"
  if (Test-Path $exe) {
    "{0} | ver {1} | ru-RU: {2}" -f $_.Name,
      (Get-Item $exe).VersionInfo.ProductVersion,
      (Test-Path "$($_.FullName)\StringTable\ru-RU")
  }
}
```

### macOS: «Ошибка входа» / ошибка авторизации после установки

Это значит, что бандл был **переподписан**. Симптомы:
```
IDSDKAuth: idsdk_init failed with error IDSDK_E_IDSDK_CLIENT_OBJECT_INVALID
```

**Решение:** удалите Fusion полностью, переустановите с сайта Autodesk, и в этот раз **только копируйте файлы**, не выполняя `codesign` ни с какими ключами.

### Windows: SmartScreen ругается на .bat

При первом запуске `install-windows.bat` Windows может показать предупреждение SmartScreen. Нажмите **«Подробнее»** → **«Выполнить в любом случае»**, либо запустите шаги вручную (см. раздел «Ручная установка»).

### Удаление перевода

Если хотите вернуться к английскому:

**macOS:**
```bash
APP="$HOME/Library/Application Support/Autodesk/webdeploy/production"
HASH=$(readlink "$APP/Autodesk Fusion.app" | grep -oE '[a-f0-9]{40}')
rm -rf "$APP/$HASH/Autodesk Fusion.app/Contents/Libraries/Neutron/StringTable/ru-RU"
rm -rf "$APP/$HASH/Autodesk Fusion.app/Contents/Libraries/Applications/CAM360/NeuCAM/UI/NeuCAMUI/Resources/Help/ru-html"
rm    "$APP/$HASH/Autodesk Fusion.app/Contents/Libraries/Applications/CAM360/NeuCAM/UI/NeuCAMUI/Resources/Help/ru-html.html"
rm    "$APP/$HASH/Autodesk Fusion.app/Contents/Libraries/Applications/CAM360/Data/Translations/russian_ru.xml"
```

**Windows (PowerShell):**
```powershell
$Hash = (Get-ChildItem "$env:LOCALAPPDATA\Autodesk\webdeploy\production" -Directory | Where-Object Name -Match '^[a-f0-9]{40}$' | Select -First 1).Name
$Root = "$env:LOCALAPPDATA\Autodesk\webdeploy\production\$Hash"
Remove-Item -Recurse "$Root\StringTable\ru-RU"
Remove-Item -Recurse "$Root\NeuCAM\UI\NeuCAMUI\Resources\Help\ru-html"
Remove-Item "$Root\Applications\CAM360\Data\Translations\russian_ru.xml"
```

После этого в настройках Fusion переключитесь обратно на English и перезапустите.

---

## Диагностика

### Найти текущий путь установки

**macOS:**
```bash
ls "$HOME/Library/Application Support/Autodesk/webdeploy/production/"
```

**Windows (cmd):**
```cmd
dir "%LOCALAPPDATA%\Autodesk\webdeploy\production\"
```

### Проверить, что файлы на месте

**macOS:**
```bash
APP="$HOME/Library/Application Support/Autodesk/webdeploy/production"
HASH=$(ls "$APP" | grep -E '^[a-f0-9]{40}$' | head -1)
ls "$APP/$HASH/Autodesk Fusion.app/Contents/Libraries/Neutron/StringTable/ru-RU/" | wc -l
# Должно быть 115
```

**Windows (PowerShell):** — проверяет активную сборку из `FusionLauncher.exe.ini`
```powershell
$prod = "$env:LOCALAPPDATA\Autodesk\webdeploy\production"
$cmd  = Get-Content (Get-ChildItem "$prod\*\FusionLauncher.exe.ini" | Select -First 1) | Where-Object { $_ -match 'cmd\s*=' }
if ($cmd -match '([0-9a-fA-F]{40})') {
  (Get-ChildItem "$prod\$($matches[1])\StringTable\ru-RU" -Filter *.xml).Count
}
# Должно быть 115
```

### Логи Fusion

Если что-то странное — лог можно посмотреть здесь:

**macOS:** `~/Library/Application Support/Autodesk/Neutron Platform/logs/AppLogFile*.log`

**Windows:** `%LOCALAPPDATA%\Autodesk\Neutron Platform\logs\AppLogFile*.log`

---

## Как это работает (тех.детали)

Fusion 360 хранит локализованные строки в формате XML, по одному файлу на модуль (например `NaFusionUI10.xml` для основного UI, `NaSketchUI10.xml` для эскизов и т.д.). При запуске Fusion ищет папку с кодом текущей локали в `Libraries/Neutron/StringTable/<lang-code>/` и подгружает оттуда переводы. Если папки `ru-RU` нет — fallback на `en-US`.

Все 15 поддерживаемых локалей (`cs-CZ, en-US, de-DE, es-ES, fr-FR, hu-HU, it-IT, ja-JP, ko-KR, pl-PL, pt-BR, ru-RU, zh-CN, zh-TW, tr-TR`) уже зашиты в `libAdUICore-16.dylib` и в опции `UserLanguageValueRussian` в `NsBaseCore10.xml`. То есть **русский Autodesk сам по себе поддерживает**, просто файлов перевода в дистрибутиве не поставляет.

На macOS установка усложняется тем, что приложение подписано Autodesk и использует hardened runtime. **Ключевое открытие**: подпись Mach-O самого исполняемого файла НЕ ломается при добавлении ресурсов в бандл. Sealed Resources формально становится «недействительным», но macOS hardened runtime не валидирует ресурсы при запуске, а IDSDK (Identity Manager) использует cdhash самого Mach-O для IPC-trust, не ресурсов. Поэтому **просто скопировать файлы — достаточно**, и логин в Autodesk-аккаунт продолжает работать.

❌ Что **сломает** логин: переподпись бандла (`codesign --force --sign -`, `codesign --remove-signature`). Это меняет cdhash → IDSDK теряет доверие → ошибка входа.

---

## Лицензия

Файлы перевода — собственность сообщества [RusFus](https://github.com/RusFus/fusion360-rus-files), используются согласно их условиям.

Скрипты установки и инструкция в этом репозитории — MIT.

---

## Благодарности

- **RusFus** — за исходный перевод 117 файлов и Windows-инструкцию.
- Сообществу за тестирование на разных версиях Fusion.
