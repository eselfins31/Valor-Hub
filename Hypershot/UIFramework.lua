local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield", true))()

-- Point BASE at Hypershot folder so we can use src/*.lua paths
local BASE = "https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/Hypershot"

local function notifyErr(msg)
    pcall(function()
        Rayfield:Notify({ Title = "Valor Hub - Hypershot", Content = msg, Duration = 6 })
    end)
end

local function fetch(path)
    local ok, res = pcall(function()
        return game:HttpGet(BASE .. "/" .. path, true)
    end)
    if not ok or not res or #res == 0 then
        notifyErr("Fetch failed: " .. tostring(path))
        return nil
    end
    return res
end

local function loadChunk(source, name)
    if not source then return nil end
    local fn, err = loadstring(source)
    if not fn then
        notifyErr("Load error: " .. tostring(name) .. " -> " .. tostring(err))
        return nil
    end
    local ok, rv = pcall(fn)
    if not ok then
        notifyErr("Run error: " .. tostring(name) .. " -> " .. tostring(rv))
        return nil
    end
    return rv
end

-- Load modules from Hypershot/src with safe fallbacks
local State = loadChunk(fetch("src/State.lua"), "State") or { settings = {}, update = function() end, get = function() return nil end }
local Services = loadChunk(fetch("src/Services.lua"), "Services") or { Players = game:GetService("Players"), RunService = game:GetService("RunService"), UserInputService = game:GetService("UserInputService"), TweenService = game:GetService("TweenService"), Lighting = game:GetService("Lighting"), ReplicatedStorage = game:GetService("ReplicatedStorage") }

local function loadInitModule(path, name)
    local init = loadChunk(fetch(path), name)
    if not init then
        notifyErr(name .. " init missing; using stub")
        return { start = function() end, stop = function() end }
    end
    local ok, mod = pcall(function() return init(Services, State) end)
    if not ok or not mod then
        notifyErr(name .. " init failed; using stub")
        return { start = function() end, stop = function() end }
    end
    return mod
end

local ESP       = loadInitModule("src/ESP.lua", "ESP")
local Rage      = loadInitModule("src/Rage.lua", "Rage")
local FOV       = loadInitModule("src/FOV.lua", "FOV")
local Movement  = loadInitModule("src/Movement.lua", "Movement")
local WeaponMods= loadInitModule("src/WeaponMods.lua", "WeaponMods")
local SilentAim = loadInitModule("src/SilentAim.lua", "SilentAim")
local HUD       = loadInitModule("src/HUD.lua", "HUD")

local Window = Rayfield:CreateWindow({
    Name = "Valor Hub - Hypershot",
    LoadingTitle = "Valor Hub - Hypershot",
    LoadingSubtitle = "Roblox-friendly UI",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "ValorHub",
        FileName = "UserConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Valor Hub - Hypershot",
        Subtitle = "Authentication",
        Note = "",
        FileName = "ValorHubKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = ""
    }
})

local HomeTab   = Window:CreateTab("Home", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local RageTab = Window:CreateTab("Rage", 13014552420)
local WeaponsTab = Window:CreateTab("Weapons", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local UITab     = Window:CreateTab("UI & Config", 4483362458)
local InfoTab   = Window:CreateTab("Info", 4483362458)
local KeybindsTab = Window:CreateTab("Keybinds", 4483362458)

local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local kc = input.KeyCode
    if kc == Enum.KeyCode[State.get("bindEspToggle") or "Unknown"] then
        State.update({ espEnabled = not State.get("espEnabled") })
        if State.get("espEnabled") then ESP.start() else ESP.stop() end
    elseif kc == Enum.KeyCode[State.get("bindInfJumpToggle") or "Unknown"] then
        State.update({ infiniteJump = not State.get("infiniteJump") })
        if State.get("infiniteJump") then Movement.startInfiniteJump() else Movement.stopInfiniteJump() end
    elseif kc == Enum.KeyCode[State.get("bindSpeedToggle") or "Unknown"] then
        State.update({ speedEnabled = not State.get("speedEnabled") })
        if State.get("speedEnabled") then Movement.startSpeed() else Movement.stopSpeed() end
    elseif kc == Enum.KeyCode[State.get("bindNoclipToggle") or "Unknown"] then
        State.update({ noclipEnabled = not State.get("noclipEnabled") })
        if State.get("noclipEnabled") then Movement.startNoclip() else Movement.stopNoclip() end
    elseif kc == Enum.KeyCode[State.get("bindFlyToggle") or "Unknown"] then
        State.update({ flyEnabled = not State.get("flyEnabled") })
        if State.get("flyEnabled") then Movement.startFly() else Movement.stopFly() end
    elseif kc == Enum.KeyCode[State.get("bindSilentAimToggle") or "Unknown"] then
        State.update({ silentAim = not State.get("silentAim") })
        if State.get("silentAim") then SilentAim.start() else SilentAim.stop() end
    elseif kc == Enum.KeyCode[State.get("bindWeaponModsApply") or "Unknown"] then
        WeaponMods.update()
        Rayfield:Notify({ Title = "Valor Hub - Hypershot", Content = "Applied weapon mods", Duration = 3 })
    end
end)

HomeTab:CreateSection("Quick Actions")

VisualsTab:CreateSection("ESP")
VisualsTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = State.get("espEnabled"),
    Flag = "espEnabled",
    Callback = function(on)
        State.update({ espEnabled = on })
        if on then ESP.start() else ESP.stop() end
    end
})
VisualsTab:CreateToggle({
    Name = "Show ESP",
    CurrentValue = State.get("espShow"),
    Flag = "espShow",
    Callback = function(on)
        State.update({ espShow = on })
    end
})
VisualsTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = State.get("teamCheck"),
    Flag = "teamCheck",
    Callback = function(on)
        State.update({ teamCheck = on })
    end
})
VisualsTab:CreateDropdown({
    Name = "Box Style",
    Options = {"Box","Corner"},
    CurrentOption = State.get("espMode"),
    Flag = "espMode",
    Callback = function(opt)
        State.update({ espMode = opt })
    end
})
VisualsTab:CreateToggle({
    Name = "Names",
    CurrentValue = State.get("espShowNames"),
    Flag = "espShowNames",
    Callback = function(on)
        State.update({ espShowNames = on })
    end
})
VisualsTab:CreateToggle({
    Name = "Health",
    CurrentValue = State.get("espShowHealth"),
    Flag = "espShowHealth",
    Callback = function(on)
        State.update({ espShowHealth = on })
    end
})
VisualsTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = State.get("espShowTracers"),
    Flag = "espShowTracers",
    Callback = function(on)
        State.update({ espShowTracers = on })
    end
})
VisualsTab:CreateToggle({
    Name = "Use Team Colors",
    CurrentValue = State.get("espUseTeamColor"),
    Flag = "espUseTeamColor",
    Callback = function(on)
        State.update({ espUseTeamColor = on })
    end
})
VisualsTab:CreateSlider({
    Name = "ESP Thickness",
    Range = {1, 5},
    Increment = 0.5,
    Suffix = "px",
    CurrentValue = State.get("espThickness"),
    Flag = "espThickness",
    Callback = function(v)
        State.update({ espThickness = v })
    end
})
VisualsTab:CreateSlider({
    Name = "ESP Text Size",
    Range = {10, 24},
    Increment = 1,
    Suffix = "pt",
    CurrentValue = State.get("espTextSize"),
    Flag = "espTextSize",
    Callback = function(v)
        State.update({ espTextSize = v })
    end
})

RageTab:CreateSection("Ragebot")
RageTab:CreateSlider({
    Name = "Rage FOV Radius",
    Range = {10, 600},
    Increment = 1,
    Suffix = "px",
    CurrentValue = State.get("rageFovRadius"),
    Flag = "rageFovRadius",
    Callback = function(v)
        State.update({ rageFovRadius = v })
    end
})
RageTab:CreateToggle({
    Name = "Draw FOV",
    CurrentValue = State.get("drawRageFov"),
    Flag = "drawRageFov",
    Callback = function(on)
        State.update({ drawRageFov = on })
    end
})
RageTab:CreateToggle({
    Name = "Filled FOV",
    CurrentValue = State.get("rageFovFilled"),
    Flag = "rageFovFilled",
    Callback = function(on)
        State.update({ rageFovFilled = on })
    end
})
RageTab:CreateSlider({
    Name = "FOV Thickness",
    Range = {1, 5},
    Increment = 0.5,
    Suffix = "px",
    CurrentValue = State.get("rageFovThickness"),
    Flag = "rageFovThickness",
    Callback = function(v)
        State.update({ rageFovThickness = v })
    end
})
RageTab:CreateSlider({
    Name = "Hitchance Angle (deg)",
    Range = {1, 20},
    Increment = 0.5,
    Suffix = "deg",
    CurrentValue = State.get("rageHitchanceAngleDeg"),
    Flag = "rageHitchanceAngleDeg",
    Callback = function(v)
        State.update({ rageHitchanceAngleDeg = v })
    end
})
RageTab:CreateDropdown({
    Name = "Hitbox",
    Options = {"Head","HumanoidRootPart"},
    CurrentOption = State.get("rageHitbox"),
    Flag = "rageHitbox",
    Callback = function(opt)
        State.update({ rageHitbox = opt })
    end
})
RageTab:CreateToggle({
    Name = "Auto Shoot",
    CurrentValue = State.get("rageAutoShoot"),
    Flag = "rageAutoShoot",
    Callback = function(on)
        State.update({ rageAutoShoot = on })
    end
})
RageTab:CreateToggle({
    Name = "Triggerbot",
    CurrentValue = State.get("rageTriggerbot"),
    Flag = "rageTriggerbot",
    Callback = function(on)
        State.update({ rageTriggerbot = on })
    end
})
RageTab:CreateToggle({
    Name = "Quick Stop",
    CurrentValue = State.get("rageQuickStop"),
    Flag = "rageQuickStop",
    Callback = function(on)
        State.update({ rageQuickStop = on })
    end
})

RageTab:CreateSection("Silent Aim")
RageTab:CreateToggle({
    Name = "Enable Silent Aim (hitbox expand)",
    CurrentValue = State.get("silentAim"),
    Flag = "silentAim",
    Callback = function(on)
        State.update({ silentAim = on })
        if on then SilentAim.start() else SilentAim.stop() end
    end
})
RageTab:CreateSlider({
    Name = "Silent Aim Hitbox Size",
    Range = {5, 30},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = State.get("silentAimSize"),
    Flag = "silentAimSize",
    Callback = function(v)
        State.update({ silentAimSize = v })
    end
})

WeaponsTab:CreateSection("Weapon Mods")
WeaponsTab:CreateToggle({
    Name = "Ammo Mod (999)",
    CurrentValue = State.get("ammoMod"),
    Flag = "ammoMod",
    Callback = function(on)
        State.update({ ammoMod = on })
        WeaponMods.update()
    end
})
WeaponsTab:CreateToggle({
    Name = "FireRate Mod (Auto + 0.02)",
    CurrentValue = State.get("fireRateMod"),
    Flag = "fireRateMod",
    Callback = function(on)
        State.update({ fireRateMod = on })
        WeaponMods.update()
    end
})
WeaponsTab:CreateToggle({
    Name = "No Recoil / No Spread",
    CurrentValue = State.get("recoilMod"),
    Flag = "recoilMod",
    Callback = function(on)
        State.update({ recoilMod = on })
        WeaponMods.update()
    end
})
WeaponsTab:CreateButton({
    Name = "Force Apply All (debug)",
    Callback = function()
        WeaponMods.update()
        Rayfield:Notify({ Title = "Valor Hub - Hypershot", Content = "Attempted to apply all weapon mods.", Duration = 4 })
    end
})

MovementTab:CreateSection("Player")
MovementTab:CreateToggle({
    Name = "Infinite Jump v2 (With Air Strafe Exploit)",
    CurrentValue = State.get("infiniteJump"),
    Flag = "infiniteJump",
    Callback = function(on)
        State.update({ infiniteJump = on })
        if on then Movement.startInfiniteJump() else Movement.stopInfiniteJump() end
    end
})
MovementTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = State.get("speedEnabled"),
    Flag = "speedEnabled",
    Callback = function(on)
        State.update({ speedEnabled = on })
        if on then Movement.startSpeed() else Movement.stopSpeed() end
    end
})
MovementTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    Suffix = "ws",
    CurrentValue = State.get("walkSpeed"),
    Flag = "walkSpeed",
    Callback = function(v)
        State.update({ walkSpeed = v })
        Movement.applySpeed(v)
    end
})
MovementTab:CreateSlider({
    Name = "Air Strafe Speed",
    Range = {0, 200},
    Increment = 5,
    Suffix = "u/s",
    CurrentValue = State.get("airStrafeSpeed"),
    Flag = "airStrafeSpeed",
    Callback = function(v)
        State.update({ airStrafeSpeed = v })
    end
})

MovementTab:CreateSection("Advanced Movement")
MovementTab:CreateToggle({
    Name = "NOCLIP v2 (With floor check)",
    CurrentValue = State.get("noclipEnabled"),
    Flag = "noclipEnabled",
    Callback = function(on)
        State.update({ noclipEnabled = on })
        if on then Movement.startNoclip() else Movement.stopNoclip() end
    end
})
MovementTab:CreateToggle({
    Name = "FLY (W/A/S/D + Space/Shift)",
    CurrentValue = State.get("flyEnabled"),
    Flag = "flyEnabled",
    Callback = function(on)
        State.update({ flyEnabled = on })
        if on then Movement.startFly() else Movement.stopFly() end
    end
})
MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = "u/s",
    CurrentValue = State.get("flySpeed"),
    Flag = "flySpeed",
    Callback = function(v)
        State.update({ flySpeed = v })
    end
})
MovementTab:CreateToggle({
    Name = "Spider (jump to climb walls)",
    CurrentValue = State.get("spiderEnabled"),
    Flag = "spiderEnabled",
    Callback = function(on)
        State.update({ spiderEnabled = on })
        if on then Movement.startSpider() else Movement.stopSpider() end
    end
})

-- UI & Config
UITab:CreateSection("Interface")
UITab:CreateToggle({
    Name = "UI Blur",
    CurrentValue = false,
    Flag = "UIBlur",
    Callback = function(on)
        local Lighting = Services.Lighting
        local blur = Lighting:FindFirstChild("ValorHubBlur") or Instance.new("BlurEffect")
        blur.Name = "ValorHubBlur"
        blur.Parent = Lighting
        blur.Size = on and 12 or 0
    end
})
UITab:CreateToggle({
    Name = "Session HUD",
    CurrentValue = State.get("hudEnabled"),
    Flag = "hudEnabled",
    Callback = function(on)
        State.update({ hudEnabled = on })
        if on then HUD.start() else HUD.stop() end
    end
})
UITab:CreateButton({
    Name = "Save Configuration",
    Callback = function()
        Rayfield:SaveConfiguration()
        Rayfield:Notify({ Title = "Valor Hub - Hypershot", Content = "Config saved.", Duration = 3 })
    end
})
UITab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Rayfield:Destroy()
    end
})
UITab:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightShift",
    HoldToInteract = false,
    Flag = "UIToggleKey",
    Callback = function()
        if Rayfield.Toggle then Rayfield:Toggle() end
    end
})

InfoTab:CreateSection("About")
InfoTab:CreateParagraph({
    Title = "Valor Hub - Hypershot",
    Content = "A modern Rayfield UI for NEW! Hypershot (Gunfight), featuring ESP, Rage (autoshoot/trigger), SilentAim, Movement, Weapon Mods, HUD."
})
InfoTab:CreateParagraph({
    Title = "Key Features",
    Content = "ESP (names/boxes/health/tracers), Rage FOV + autoshoot/trigger, Silent Aim hitbox, Infinite Jump v2, FLY, NOCLIP v2, Spider climb, Session HUD."
})
InfoTab:CreateParagraph({
    Title = "Credits",
    Content = "Owner: eselfins31. UI powered by Rayfield."
})

Rayfield:LoadConfiguration()

if State.get("hudEnabled") then HUD.start() end

FOV.start()

Rayfield:Notify({
    Title = "Valor Hub - Hypershot",
    Content = "UI loaded successfully",
    Duration = 6
})

-- Utilities: Rejoin and Server Hop on Home
HomeTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
        end)
        if not ok then
            Rayfield:Notify({ Title = "Valor Hub - Hypershot", Content = "Rejoin failed: " .. tostring(err), Duration = 6 })
        end
    end
})
HomeTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local ok, res = pcall(function()
            local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100", game.PlaceId)
            return HttpService:GetAsync(url)
        end)
        if not ok or not res then
            Rayfield:Notify({ Title = "Valor Hub - Hypershot", Content = "Server list fetch failed", Duration = 6 })
            return
        end
        local data = nil
        pcall(function() data = HttpService:JSONDecode(res) end)
        if not data or not data.data then
            Rayfield:Notify({ Title = "Valor Hub - Hypershot", Content = "Server list decode failed", Duration = 6 })
            return
        end
        local target = nil
        for _, srv in ipairs(data.data) do
            if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                target = srv.id; break
            end
        end
        if target then
            local ok2, err2 = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, target, Players.LocalPlayer)
            end)
            if not ok2 then
                Rayfield:Notify({ Title = "Valor Hub - Hypershot", Content = "Server hop failed: " .. tostring(err2), Duration = 6 })
            end
        else
            Rayfield:Notify({ Title = "Valor Hub - Hypershot", Content = "No suitable server found", Duration = 6 })
        end
    end
})

-- Keybinds configuration
local keyOptions = {"Q","E","R","T","Y","U","I","O","P","G","H","J","K","L","Z","X","C","V","B","N","M","LeftAlt","RightAlt","LeftShift","RightShift","F","MouseButton2"}

local function bindDropdown(tab, label, stateKey)
    tab:CreateDropdown({
        Name = label,
        Options = keyOptions,
        CurrentOption = State.get(stateKey) or "",
        Flag = stateKey,
        Callback = function(opt)
            State.update({ [stateKey] = opt })
            Rayfield:Notify({ Title = "Valor Hub - Hypershot", Content = label .. " set to " .. tostring(opt), Duration = 3 })
        end
    })
end

KeybindsTab:CreateSection("Toggle Binds")
bindDropdown(KeybindsTab, "Toggle ESP", "bindEspToggle")
bindDropdown(KeybindsTab, "Toggle Infinite Jump", "bindInfJumpToggle")
bindDropdown(KeybindsTab, "Toggle Speed", "bindSpeedToggle")
bindDropdown(KeybindsTab, "Toggle NOCLIP", "bindNoclipToggle")
bindDropdown(KeybindsTab, "Toggle FLY", "bindFlyToggle")
bindDropdown(KeybindsTab, "Toggle Silent Aim", "bindSilentAimToggle")
bindDropdown(KeybindsTab, "Apply Weapon Mods", "bindWeaponModsApply")

-- Auto re-inject on teleport (queue_on_teleport)
local function setupAutoReinject()
    local TeleportService = game:GetService("TeleportService")
    local src = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/Hypershot/UIFramework.lua", true))()]]
    local q = rawget(getfenv(), "queue_on_teleport") or (syn and syn.queue_on_teleport)
    if q then
        local ok = pcall(function() q(src) end)
        if not ok then
            Rayfield:Notify({ Title = "Valor Hub - Hypershot", Content = "queue_on_teleport failed", Duration = 6 })
        end
        TeleportService.TeleportInitFailed:Connect(function()
            local ok2 = pcall(function() q(src) end)
            if not ok2 then Rayfield:Notify({ Title = "Valor Hub - Hypershot", Content = "Re-queue failed", Duration = 6 }) end
        end)
    else
        Rayfield:Notify({ Title = "Valor Hub - Hypershot", Content = "queue_on_teleport not supported by executor", Duration = 6 })
    end
end
setupAutoReinject()