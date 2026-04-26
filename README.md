# Русская локализация Autodesk Fusion 360

Полный русский перевод интерфейса Fusion 360 для **macOS** и **Windows**, рабочий на актуальной версии (2026.x, проверено в апреле 2026).

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

install-macos.command   ← двойной клик для установки на macOS
install-windows.bat     ← двойной клик для установки на Windows
```

---

## Быстрый старт

### macOS

1. Полностью закройте Fusion 360 (⌘Q, не просто закрыть окно).
2. Скачайте/клонируйте этот репозиторий (зелёная кнопка **Code → Download ZIP** на GitHub, потом распакуйте).
3. **Дважды кликните `install-macos.command`** в распакованной папке.
   - Откроется Терминал, скрипт сам найдёт установленный Fusion и скопирует файлы.
   - Если macOS скажет «не удаётся открыть, потому что разработчик не проверен» → ПКМ по файлу → **Открыть** → подтвердить. Либо в Терминале выполнить:
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

### Fusion обновился — русский пропал

Fusion 360 обновляется через webdeploy и при каждом крупном апдейте создаёт **новую папку** с другим `<HASH>` в `webdeploy/production/`. Старая папка с нашими файлами больше не используется.

**Решение:** просто запустите установочный скрипт снова — он сам найдёт новый `<HASH>` и положит файлы туда.

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
HASH=$(ls "$APP" | grep -E '^[a-f0-9]{40}$' | head -1)
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
