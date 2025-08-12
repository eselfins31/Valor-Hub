## Valor Hub

Modern multi-game Roblox hub with modular Rayfield UI, protected loaders, and external module hosting.

### English

- What it includes
  - Dungeon Heroes: Kill Aura, Auto Start/Play Again, Auto Farm (tween speed/Y offset), Dungeon presets, Auto Sell (items/pets with rarity filters), Open Pet Chests, Anti-AFK, Utility GUI, Daily quest auto-claim, FPS profiles, Status HUD.
  - Hypershot V2: Silent Aim (FOV, line, team/visibility checks with Raycast hook), external ESP bridge, FullBright, FPS Boost, Aspect Ratio, Arms/Weapon Chams.
  - Arsenal Advanced: Hitbox expander (team-check, size/alpha, no-collision), Gun Mods (infinite ammo, fast reload/fire rate, always auto, no spread/recoil), AutoFarm (soft TP + camera snap + TimeScale), Player (Fly, custom Walk/Jump, Infinite Jump, NoClip, FOV, TimeScale).
  - Grow a Garden: Auto Collector (optional TP loop), Seed/Gear/Easter auto-buy, Auto Sell (threshold with sale focus), Event helpers (gold plants submission, dup-buy supers).

- How to run (protected loaders)
  - Arsenal Advanced:
    ```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/Arsenal%20Advanced/UIFramework_protected.lua"))()
    ```
  - Hypershot V2:
    ```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/Hypershot%20V2/UIFramework_protected.lua"))()
    ```
  - Dungeon Heroes:
    ```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/Dungeon%20Heroes/UIFramework_protected.lua"))()
    ```
  - Grow a Garden:
    ```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/Grow%20a%20Garden/UIFramework_protected.lua"))()
    ```

- Requirements
  - Executor with queue_on_teleport and Drawing support (Tested on Ronix, Solara, JJSploit)
  - HTTP requests enabled to fetch modules from server

- Security model
  - Only _protected loaders are public here to protect source code
  - Functional modules are hosted externally on randomized paths via internal mapping
  - No secrets in the client; soft anti-tamper checks and throttling
  - No backdoors/loggers embedded into loader/modules (Rayfield has its own optional error-report logger)
  - Universal approach is used to maximize compatibility across executors and devices

- Disclaimer
  - For educational purposes only. Use at your own risk. We are not responsible for your actions or accounts.

---

## Valor Hub (RU)

Современный мульти-игровой Roblox-хаб с модульным Rayfield UI, защищенными лоадерами и внешним хостингом модулей.

- Что внутри
  - Dungeon Heroes: Kill Aura, Auto Start/Play Again, Auto Farm (скорость/Y-отступ), пресеты данжей, Auto Sell (вещи/петы + фильтры редкости), Open Pet Chests, Anti-AFK, утилиты GUI, авто-клейм дейликов, FPS-профили, статусный HUD.
  - Hypershot V2: Silent Aim (FOV, линия, тим-/видимость + Raycast-хук), внешняя ESP-либа, FullBright, FPS Boost, Aspect Ratio, чамсы рук/оружия.
  - Arsenal Advanced: Расширение хитбоксов (тим-чек, размер/прозрачность, no-collision), моды оружия (бесконечные патроны, быстрые перезарядка/скорострельность, auto, без разброса/отдачи), AutoFarm (мягкий ТП + камера + TimeScale), игрок (Fly, кастом Walk/Jump, Infinite Jump, NoClip, FOV, TimeScale).
  - Grow a Garden: Авто-сбор (опц. TP-обход), авто-покупка семян/инвентаря/пасхальных, авто-продажа (порог + удержание у продавца), ивент-хелперы (сдача gold-растений, dup-buy).

- Запуск (защищенные лоадеры)
  - Arsenal Advanced:
    ```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/Arsenal%20Advanced/UIFramework_protected.lua"))()
    ```
  - Hypershot V2:
    ```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/Hypershot%20V2/UIFramework_protected.lua"))()
    ```
  - Dungeon Heroes:
    ```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/Dungeon%20Heroes/UIFramework_protected.lua"))()
    ```
  - Grow a Garden:
    ```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/Grow%20a%20Garden/UIFramework_protected.lua"))()
    ```

- Требования
  - Экзекьютор с доступом к queue_on_teleport и Drawing (Протестировали на Ronix, Solara, JJSploit)
  - Разрешенные HTTP-запросы для подгрузки модулей с сервера

- Безопасность
  - Публичны только _protected лоадеры, ради защиты исходного кода
  - Модули хостятся внешне на рандомных путях по внутренней карте
  - Секретов на клиенте нет; мягкие анти-тампер и троттлинг
  - В сам лоадер и модули не вшито никаких бекдоров/логгеров и т.д (У Rayfield есть своей логгер отчетности ошибок их библиотеки, но только по желанию пользователя)
  - Используются универсальные подходы, что по идеи должно дать использовать наши скрипты с любыми инжекторами и на любых устройствах

- Дисклеймер
  - Только для ознакомительных целей. Использование на свой риск. Мы не несем ответственности за ваши действия и аккаунты.



 
