local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield", true))()

local BASE = "https://raw.githubusercontent.com/eselfins31/Valor-Hub/main"
local function fetch(path)
    return game:HttpGet(BASE .. "/" .. path, true)
end

local State = loadstring(fetch("src/State.lua"))()
local Services = loadstring(fetch("src/Services.lua"))()

local ESP = loadstring(fetch("src/ESP.lua"))()(Services, State)
local Rage = loadstring(fetch("src/Rage.lua"))()(Services, State)
local FOV = loadstring(fetch("src/FOV.lua"))()(Services, State)
local Movement = loadstring(fetch("src/Movement.lua"))()(Services, State)
local WeaponMods = loadstring(fetch("src/WeaponMods.lua"))()(Services, State)
local SilentAim = loadstring(fetch("src/SilentAim.lua"))()(Services, State)
local HUD = loadstring(fetch("src/HUD.lua"))()(Services, State)

local Window = Rayfield:CreateWindow({
    Name = "Valor Hub - Arsenal",
    LoadingTitle = "Valor Hub - Arsenal",
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
        Title = "Valor Hub - Arsenal",
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

local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local kc = input.KeyCode
    if kc == Enum.KeyCode[State.get("bindEspToggle")] then
        State.update({ espEnabled = not State.get("espEnabled") })
        if State.get("espEnabled") then ESP.start() else ESP.stop() end
    elseif kc == Enum.KeyCode[State.get("bindAimbotToggle")] then
        State.update({ aimbotEnabled = not State.get("aimbotEnabled") })
        if State.get("aimbotEnabled") then Aimbot.start() else Aimbot.stop() end
    elseif kc == Enum.KeyCode[State.get("bindInfJumpToggle")] then
        State.update({ infiniteJump = not State.get("infiniteJump") })
        if State.get("infiniteJump") then Movement.startInfiniteJump() else Movement.stopInfiniteJump() end
    elseif kc == Enum.KeyCode[State.get("bindSpeedToggle")] then
        State.update({ speedEnabled = not State.get("speedEnabled") })
        if State.get("speedEnabled") then Movement.startSpeed() else Movement.stopSpeed() end
    elseif kc == Enum.KeyCode[State.get("bindNoclipToggle")] then
        State.update({ noclipEnabled = not State.get("noclipEnabled") })
        if State.get("noclipEnabled") then Movement.startNoclip() else Movement.stopNoclip() end
    elseif kc == Enum.KeyCode[State.get("bindFlyToggle")] then
        State.update({ flyEnabled = not State.get("flyEnabled") })
        if State.get("flyEnabled") then Movement.startFly() else Movement.stopFly() end
    elseif kc == Enum.KeyCode[State.get("bindSilentAimToggle")] then
        State.update({ silentAim = not State.get("silentAim") })
        if State.get("silentAim") then SilentAim.start() else SilentAim.stop() end
    elseif kc == Enum.KeyCode[State.get("bindWeaponModsApply")] then
        WeaponMods.update()
        Rayfield:Notify({ Title = "Valor Hub - Arsenal", Content = "Applied weapon mods", Duration = 3 })
    end
end)

HomeTab:CreateSection("Quick Actions")
HomeTab:CreateButton({
    Name = "Start All",
    Callback = function()
        ESP.start(); Rage.start(); FOV.start(); Movement.startInfiniteJump(); Movement.startSpeed(); SilentAim.start(); WeaponMods.update()
        Rayfield:Notify({ Title = "Valor Hub - Arsenal", Content = "Modules started", Duration = 4 })
    end
})
HomeTab:CreateButton({
    Name = "Stop All",
    Callback = function()
        ESP.stop(); Rage.stop(); FOV.stop(); Movement.stopInfiniteJump(); Movement.stopSpeed(); SilentAim.stop(); WeaponMods.stopAll()
        Rayfield:Notify({ Title = "Valor Hub - Arsenal", Content = "Modules stopped", Duration = 4 })
    end
})

VisualsTab:CreateSection("ESP (On test)")
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
        Rayfield:Notify({ Title = "Valor Hub - Arsenal", Content = "Attempted to apply all weapon mods.", Duration = 4 })
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

CombatTab:CreateSection("Silent Aim")
CombatTab:CreateToggle({
    Name = "Enable Silent Aim (hitbox expand)",
    CurrentValue = State.get("silentAim"),
    Flag = "silentAim",
    Callback = function(on)
        State.update({ silentAim = on })
        if on then SilentAim.start() else SilentAim.stop() end
    end
})
CombatTab:CreateSlider({
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
        Rayfield:Notify({ Title = "Valor Hub - Arsenal", Content = "Config saved.", Duration = 3 })
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
    Title = "Valor Hub - Arsenal",
    Content = "A modern Rayfield UI for Arsenal, featuring ESP, Aimbot, SilentAim, Movement, Weapon Mods, and more."
})
InfoTab:CreateParagraph({
    Title = "Key Features",
    Content = "ESP (names/boxes/health/tracers), Aimbot with FOV + smoothing, Silent Aim hitbox, Infinite Jump v2, FLY, NOCLIP v2, Spider climb, Session HUD."
})
InfoTab:CreateParagraph({
    Title = "Credits",
    Content = "Owner: Eselfin31. UI powered by Rayfield."
})

Rayfield:LoadConfiguration()

if State.get("hudEnabled") then HUD.start() end

FOV.start()

Rayfield:Notify({
    Title = "Valor Hub - Arsenal",
    Content = "UI loaded successfully",
    Duration = 6
})