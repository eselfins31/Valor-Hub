local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield", true))()

local BASE = "https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/CryptoFarm"
local function notify(msg)
    pcall(function() Rayfield:Notify({ Title = "Valor Hub - CryptoFarm", Content = msg, Duration = 6 }) end)
end
local function fetch(path)
    local ok, res = pcall(function() return game:HttpGet(BASE .. "/" .. path, true) end)
    if not ok or not res or #res == 0 then notify("Fetch failed: " .. tostring(path)) return nil end
    return res
end
local function loadChunk(source, name)
    if not source then return nil end
    local fn, err = loadstring(source)
    if not fn then notify("Load error: " .. tostring(name) .. ": " .. tostring(err)) return nil end
    local ok, rv = pcall(fn)
    if not ok then notify("Run error: " .. tostring(name) .. ": " .. tostring(rv)) return nil end
    return rv
end

local State = loadChunk(fetch("src/State.lua"), "State") or { settings = {}, update=function() end, get=function() end }
local Services = loadChunk(fetch("src/Services.lua"), "Services") or { Players=game:GetService("Players"), RunService=game:GetService("RunService"), UserInputService=game:GetService("UserInputService"), TweenService=game:GetService("TweenService"), Lighting=game:GetService("Lighting"), ReplicatedStorage=game:GetService("ReplicatedStorage"), CollectionService=game:GetService("CollectionService"), HttpService=game:GetService("HttpService") }

local TeleportInit = loadChunk(fetch("src/Teleport.lua"), "Teleport")
local AutomationInit = loadChunk(fetch("src/Automation.lua"), "Automation")
local Teleport = TeleportInit and TeleportInit(Services, State) or nil
local Automation = AutomationInit and AutomationInit(Services, State) or nil

local Window = Rayfield:CreateWindow({
    Name = "Valor Hub - CryptoFarm",
    LoadingTitle = "Valor Hub - CryptoFarm",
    LoadingSubtitle = "Roblox-friendly UI",
    ConfigurationSaving = { Enabled = false, FolderName = "ValorHub", FileName = "UserConfig" },
    Discord = { Enabled = false, Invite = "", RememberJoins = true },
    KeySystem = false,
    KeySettings = { Title = "Valor Hub - CryptoFarm", Subtitle = "Authentication", Note = "", FileName = "ValorHubKey", SaveKey = true, GrabKeyFromSite = false, Key = "" }
})

local TeleTab = Window:CreateTab("Teleport", 4483362458)
local AutoTab = Window:CreateTab("Auto", 4483362458)
local InfoTab = Window:CreateTab("Info", 4483362458)
local KeybindsTab = Window:CreateTab("Keybinds", 4483362458)

-- Teleport features
TeleTab:CreateSection("Click Teleport")
TeleTab:CreateToggle({
    Name = "Enable Click TP",
    CurrentValue = State.get and State.get("clickTp") or false,
    Callback = function(on)
        if Teleport and Teleport.enableClickTp then Teleport.enableClickTp(on) end
        if State.update then State.update({ clickTp = on }) end
    end
})
TeleTab:CreateSection("Saved Points")
TeleTab:CreateInput({
    Name = "Save Current Position As",
    PlaceholderText = "Point name",
    RemoveTextAfterFocusLost = false,
    Callback = function(name)
        if Teleport and Teleport.savePoint then Teleport.savePoint(name) end
    end
})
TeleTab:CreateDropdown({
    Name = "Teleport To Saved",
    Options = {},
    CurrentOption = "",
    Flag = "tpSaved",
    Callback = function(name)
        if Teleport and Teleport.teleportToSaved then Teleport.teleportToSaved(name) end
    end
})
TeleTab:CreateButton({
    Name = "Refresh Points",
    Callback = function()
        if Teleport and Teleport.getSavedNames and Rayfield and Rayfield.UpdateDropdown then
            local names = Teleport.getSavedNames()
            Rayfield:UpdateDropdown("tpSaved", names)
        end
    end
})

-- Automation
AutoTab:CreateSection("Auto Actions")
AutoTab:CreateToggle({
    Name = "Auto Collect",
    CurrentValue = false,
    Callback = function(on)
        if Automation and Automation.autoCollect then Automation.autoCollect(on) end
    end
})
AutoTab:CreateToggle({
    Name = "Auto Sell Inventory",
    CurrentValue = false,
    Callback = function(on)
        if Automation and Automation.autoSell then Automation.autoSell(on) end
    end
})

AutoTab:CreateSection("Movement")
AutoTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = State.get and State.get("speedEnabled") or false,
    Callback = function(on)
        if State.update then State.update({ speedEnabled = on }) end
        if Automation and Automation.Movement then
            if on then Automation.Movement.startSpeed(State.get and State.get("walkSpeed") or 100)
            else Automation.Movement.stopSpeed() end
        end
    end
})
AutoTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    Suffix = "ws",
    CurrentValue = State.get and State.get("walkSpeed") or 100,
    Callback = function(v)
        if State.update then State.update({ walkSpeed = v }) end
        if State.get and State.get("speedEnabled") and Automation and Automation.Movement then
            Automation.Movement.applySpeed(v)
        end
    end
})

-- Info
InfoTab:CreateSection("About")
InfoTab:CreateParagraph({ Title = "Valor Hub - CryptoFarm", Content = "Grow A Crypto Farm utility: click TP, saved TP points, auto-collect, auto-sell." })

-- Keybind listener
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local kc = input.KeyCode
    if State.get and kc == Enum.KeyCode[State.get("bindClickTpToggle") or "Unknown"] then
        local cur = State.get("clickTp")
        if State.update then State.update({ clickTp = not cur }) end
        if Teleport and Teleport.enableClickTp then Teleport.enableClickTp(not cur) end
        notify("Click TP: " .. tostring(not cur))
    elseif State.get and kc == Enum.KeyCode[State.get("bindAutoCollectToggle") or "Unknown"] then
        if Automation and Automation.autoCollect then
            local flip = not (Automation.__collecting or false)
            Automation.autoCollect(flip)
            notify("Auto Collect: " .. tostring(flip))
        end
    elseif State.get and kc == Enum.KeyCode[State.get("bindAutoSellToggle") or "Unknown"] then
        if Automation and Automation.autoSell then
            local flip = not (Automation.__selling or false)
            Automation.autoSell(flip)
            notify("Auto Sell: " .. tostring(flip))
        end
    elseif State.get and kc == Enum.KeyCode[State.get("bindSpeedToggle") or "Unknown"] then
        local flip = not (State.get("speedEnabled") or false)
        if State.update then State.update({ speedEnabled = flip }) end
        if Automation and Automation.Movement then
            if flip then Automation.Movement.startSpeed(State.get and State.get("walkSpeed") or 100)
            else Automation.Movement.stopSpeed() end
        end
        notify("Speed: " .. tostring(flip))
    end
end)

-- Keybinds tab controls
local keyOptions = {"Q","E","R","T","Y","U","I","O","P","G","H","J","K","L","Z","X","C","V","B","N","M","LeftAlt","RightAlt","LeftShift","RightShift","F"}
local function bindDropdown(tab, label, stateKey)
    tab:CreateDropdown({
        Name = label,
        Options = keyOptions,
        CurrentOption = State.get and State.get(stateKey) or "",
        Flag = stateKey,
        Callback = function(opt)
            if State.update then State.update({ [stateKey] = opt }) end
            notify(label .. " set to " .. tostring(opt))
        end
    })
end
KeybindsTab:CreateSection("Toggle Binds")
bindDropdown(KeybindsTab, "Toggle Click TP", "bindClickTpToggle")
bindDropdown(KeybindsTab, "Toggle Auto Collect", "bindAutoCollectToggle")
bindDropdown(KeybindsTab, "Toggle Auto Sell", "bindAutoSellToggle")
bindDropdown(KeybindsTab, "Toggle Speed", "bindSpeedToggle")

Rayfield:Notify({ Title = "Valor Hub - CryptoFarm", Content = "UI loaded", Duration = 4 })
