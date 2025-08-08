-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield", true))()

-- Require modules from a Folder named `src` next to this script
local srcFolder = script:FindFirstChild("src") or (script.Parent and script.Parent:FindFirstChild("src"))
if not srcFolder then
    error("Missing `src` Folder with ModuleScripts (State, Services, ESP, Aimbot, Movement, WeaponMods, SilentAim)")
end

local State = require(srcFolder:WaitForChild("State"))
local Services = require(srcFolder:WaitForChild("Services"))
local ESP = require(srcFolder:WaitForChild("ESP"))
local Aimbot = require(srcFolder:WaitForChild("Aimbot"))
local Movement = require(srcFolder:WaitForChild("Movement"))
local WeaponMods = require(srcFolder:WaitForChild("WeaponMods"))
local SilentAim = require(srcFolder:WaitForChild("SilentAim"))

-- Window
local Window = Rayfield:CreateWindow({
    Name = "Valor Hub",
    LoadingTitle = "Valor Hub",
    LoadingSubtitle = "Roblox-friendly UI",
    ConfigurationSaving = {
        Enabled = true,
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

-- Home
HomeTab:CreateSection("Quick Actions")
HomeTab:CreateButton({
    Name = "Start All",
    Callback = function()
        ESP.start()
        Aimbot.start()
        Movement.startInfiniteJump()
        Movement.startSpeed()
        SilentAim.start()
        WeaponMods.update()
        Rayfield:Notify({ Title = "Valor Hub", Content = "Modules started", Duration = 4 })
    end
})
HomeTab:CreateButton({
    Name = "Stop All",
    Callback = function()
        ESP.stop()
        Aimbot.stop()
        Movement.stopInfiniteJump()
        Movement.stopSpeed()
        SilentAim.stop()
        WeaponMods.stopAll()
        Rayfield:Notify({ Title = "Valor Hub", Content = "Modules stopped", Duration = 4 })
    end
})

-- Visuals / ESP
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
    Name = "Show Labels/Boxes",
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

-- Combat
CombatTab:CreateSection("Aimbot")
CombatTab:CreateToggle({
    Name = "Enable Aimbot (RMB)",
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
    Range = {10, 250},
    Increment = 1,
    Suffix = "px",
    CurrentValue = State.get("fovRadius"),
    Flag = "fovRadius",
    Callback = function(v)
        State.update({ fovRadius = v })
    end
})
CombatTab:CreateSlider({
    Name = "Sensitivity",
    Range = {0, 0.2},
    Increment = 0.005,
    Suffix = "s",
    CurrentValue = State.get("sensitivity"),
    Flag = "sensitivity",
    Callback = function(v)
        State.update({ sensitivity = v })
    end
})
CombatTab:CreateToggle({
    Name = "Draw FOV Circle",
    CurrentValue = State.get("drawFov"),
    Flag = "drawFov",
    Callback = function(on)
        State.update({ drawFov = on })
    end
})
CombatTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = State.get("teamCheck"),
    Flag = "teamCheckCombat",
    Callback = function(on)
        State.update({ teamCheck = on })
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

-- Movement
MovementTab:CreateSection("Player")
MovementTab:CreateToggle({
    Name = "Infinite Jump",
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