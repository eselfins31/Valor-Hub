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
local Services = loadChunk(fetch("src/Services.lua"), "Services") or { Players=game:GetService("Players"), RunService=game:GetService("RunService"), UserInputService=game:GetService("UserInputService"), TweenService=game:GetService("TweenService"), Lighting=game:GetService("Lighting"), ReplicatedStorage=game:GetService("ReplicatedStorage") }

local Teleport = loadChunk(fetch("src/Teleport.lua"), "Teleport")
local Automation = loadChunk(fetch("src/Automation.lua"), "Automation")

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

-- Info
InfoTab:CreateSection("About")
InfoTab:CreateParagraph({ Title = "Valor Hub - CryptoFarm", Content = "Grow A Crypto Farm utility: click TP, saved TP points, auto-collect, auto-sell." })

Rayfield:Notify({ Title = "Valor Hub - CryptoFarm", Content = "UI loaded", Duration = 4 })
