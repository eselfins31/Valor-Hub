-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield", true))()

-- Raw GitHub loader: fetch modules via http and inject Services/State
local BASE = "https://raw.githubusercontent.com/eselfins31/Valor-Hub/main"
local function fetch(path)
    return game:HttpGet(BASE .. "/" .. path, true)
end

local State = loadstring(fetch("src/State.lua"))()
local Services = loadstring(fetch("src/Services.lua"))()

-- Modules are initializer functions that accept (Services, State)
local ESP = loadstring(fetch("src/ESP.lua"))()(Services, State)
local Aimbot = loadstring(fetch("src/Aimbot.lua"))()(Services, State)
local Movement = loadstring(fetch("src/Movement.lua"))()(Services, State)
local WeaponMods = loadstring(fetch("src/WeaponMods.lua"))()(Services, State)
local SilentAim = loadstring(fetch("src/SilentAim.lua"))()(Services, State)

-- Window
local Window = Rayfield:CreateWindow({
    Name = "Valor Hub",
    LoadingTitle = "Valor Hub",
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
        Title = "Valor Hub",
        Subtitle = "Authentication",
        Note = "",
        FileName = "ValorHubKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = ""
    }
})

-- Tabs
local HomeTab   = Window:CreateTab("Home", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local CombatTab = Window:CreateTab("Combat", 13014552420)
local WeaponsTab = Window:CreateTab("Weapons", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local UITab     = Window:CreateTab("UI & Config", 4483362458)

-- Keybinds Listener
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
        Rayfield:Notify({ Title = "Valor Hub", Content = "Applied weapon mods", Duration = 3 })
    end
end)

-- Home
HomeTab:CreateSection("Quick Actions")
HomeTab:CreateButton({
    Name = "Start All",
    Callback = function()
        ESP.start(); Aimbot.start(); Movement.startInfiniteJump(); Movement.startSpeed(); SilentAim.start(); WeaponMods.update()
        Rayfield:Notify({ Title = "Valor Hub", Content = "Modules started", Duration = 4 })
    end
})
HomeTab:CreateButton({
    Name = "Stop All",
    Callback = function()
        ESP.stop(); Aimbot.stop(); Movement.stopInfiniteJump(); Movement.stopSpeed(); SilentAim.stop(); WeaponMods.stopAll()
        Rayfield:Notify({ Title = "Valor Hub", Content = "Modules stopped", Duration = 4 })
    end
})

-- Visuals / ESP
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

-- Combat
CombatTab:CreateSection("Aimbot")
CombatTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = State.get("aimbotEnabled"),
    Flag = "aimbotEnabled",
    Callback = function(on)
        State.update({ aimbotEnabled = on })
        if on then Aimbot.start() else Aimbot.stop() end
    end
})
CombatTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "HumanoidRootPart"},
    CurrentOption = State.get("aimPart"),
    Flag = "aimPart",
    Callback = function(opt)
        State.update({ aimPart = opt })
    end
})
CombatTab:CreateSlider({
    Name = "FOV Radius",
    Range = {10, 500},
    Increment = 1,
    Suffix = "px",
    CurrentValue = State.get("fovRadius"),
    Flag = "fovRadius",
    Callback = function(v)
        State.update({ fovRadius = v })
    end
})
CombatTab:CreateToggle({
    Name = "Draw FOV",
    CurrentValue = State.get("drawFov"),
    Flag = "drawFov",
    Callback = function(on)
        State.update({ drawFov = on })
    end
})
CombatTab:CreateToggle({
    Name = "Filled FOV",
    CurrentValue = State.get("fovFilled"),
    Flag = "fovFilled",
    Callback = function(on)
        State.update({ fovFilled = on })
    end
})
CombatTab:CreateSlider({
    Name = "FOV Thickness",
    Range = {1, 5},
    Increment = 0.5,
    Suffix = "px",
    CurrentValue = State.get("fovThickness"),
    Flag = "fovThickness",
    Callback = function(v)
        State.update({ fovThickness = v })
    end
})
CombatTab:CreateDropdown({
    Name = "Activation Mode",
    Options = {"Hold","Toggle"},
    CurrentOption = State.get("aimActivation"),
    Flag = "aimActivation",
    Callback = function(opt)
        State.update({ aimActivation = opt })
    end
})
CombatTab:CreateDropdown({
    Name = "Activation Key",
    Options = {"MouseButton2","Q","E","R","LeftAlt","RightShift"},
    CurrentOption = State.get("aimKey"),
    Flag = "aimKey",
    Callback = function(opt)
        State.update({ aimKey = opt })
    end
})
CombatTab:CreateSlider({
    Name = "Smoothing (seconds)",
    Range = {0, 0.3},
    Increment = 0.005,
    Suffix = "s",
    CurrentValue = State.get("aimSmoothing"),
    Flag = "aimSmoothing",
    Callback = function(v)
        State.update({ aimSmoothing = v })
    end
})
CombatTab:CreateToggle({
    Name = "Visible Check",
    CurrentValue = State.get("visibleCheck"),
    Flag = "visibleCheck",
    Callback = function(on)
        State.update({ visibleCheck = on })
    end
})
CombatTab:CreateDropdown({
    Name = "Priority",
    Options = {"CursorProximity","Distance"},
    CurrentOption = State.get("targetPriority"),
    Flag = "targetPriority",
    Callback = function(opt)
        State.update({ targetPriority = opt })
    end
})

-- Weapons
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
        Rayfield:Notify({ Title = "Valor Hub", Content = "Attempted to apply all weapon mods.", Duration = 4 })
    end
})

-- Movement
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

-- Extras
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
UITab:CreateButton({
    Name = "Save Configuration",
    Callback = function()
        Rayfield:SaveConfiguration()
        Rayfield:Notify({ Title = "Valor Hub", Content = "Config saved.", Duration = 3 })
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

-- Load saved config
Rayfield:LoadConfiguration()

-- Initial notification
Rayfield:Notify({
    Title = "Valor Hub",
    Content = "UI loaded successfully",
    Duration = 6
})