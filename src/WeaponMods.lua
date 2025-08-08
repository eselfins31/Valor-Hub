local Services = require(script.Parent.Services)
local State = require(script.Parent.State)

local WeaponMods = {}

local ReplicatedStorage = Services.ReplicatedStorage
local Players = Services.Players

local runningTasks = {}

local function startTask(key, fn)
    WeaponMods.stopTask(key)
    local alive = true
    runningTasks[key] = function()
        alive = false
    end
    task.spawn(function()
        while runningTasks[key] do
            local ok, err = pcall(fn)
            if not ok then
                warn("WeaponMods task error:", err)
            end
            task.wait(5)
        end
    end)
end

function WeaponMods.stopTask(key)
    if runningTasks[key] then
        runningTasks[key]()
        runningTasks[key] = nil
    end
end

-- Recoil/Spread
local function applyRecoilMods()
    local weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if not weapons then
        return
    end
    for _, v in ipairs(weapons:GetDescendants()) do
        if v.Name == "RecoilControl" and v:IsA("ValueBase") then
            v.Value = 0
        elseif v.Name == "MaxSpread" and v:IsA("ValueBase") then
            v.Value = 0
        end
    end
end

-- Fire rate / Auto
local function applyFireRateMods()
    local weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if not weapons then
        return
    end
    for _, v in ipairs(weapons:GetDescendants()) do
        if v.Name == "Auto" and v:IsA("ValueBase") then
            v.Value = true
        elseif v.Name == "FireRate" and v:IsA("ValueBase") then
            v.Value = 0.02
        end
    end
end

-- Ammo GUI variables
local function applyAmmoMod()
    local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then
        return
    end
    local gui = pg:FindFirstChild("GUI")
    if not gui then
        return
    end
    local client = gui:FindFirstChild("Client")
    if not client then
        return
    end
    local vars = client:FindFirstChild("Variables")
    if not vars then
        return
    end
    local a1 = vars:FindFirstChild("ammocount")
    local a2 = vars:FindFirstChild("ammocount2")
    if a1 and a1:IsA("ValueBase") then
        a1.Value = 999
    end
    if a2 and a2:IsA("ValueBase") then
        a2.Value = 999
    end
end

function WeaponMods.update()
    if State.get("recoilMod") then
        startTask("recoil", applyRecoilMods)
    else
        WeaponMods.stopTask("recoil")
    end

    if State.get("fireRateMod") then
        startTask("firerate", applyFireRateMods)
    else
        WeaponMods.stopTask("firerate")
    end

    if State.get("ammoMod") then
        WeaponMods.stopTask("ammo")
        runningTasks["ammo"] = true
        task.spawn(function()
            while runningTasks["ammo"] do
                pcall(applyAmmoMod)
                task.wait(1)
            end
        end)
    else
        WeaponMods.stopTask("ammo")
    end
end

function WeaponMods.stopAll()
    for k in pairs(runningTasks) do
        WeaponMods.stopTask(k)
    end
end

return WeaponMods 