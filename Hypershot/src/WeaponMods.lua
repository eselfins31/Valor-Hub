return function(Services, State)
    local WeaponMods = {}

    local ReplicatedStorage = Services.ReplicatedStorage
    local Players = Services.Players
    local UserInputService = Services.UserInputService

    local runningTasks = {}

    local function startTask(key, fn)
        WeaponMods.stopTask(key)
        runningTasks[key] = true
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
        runningTasks[key] = nil
    end

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

    local function applyFireRateMods()
        -- ReplicatedStorage-side (if authoritative)
        local weapons = ReplicatedStorage:FindFirstChild("Weapons")
        if weapons then
            for _, v in ipairs(weapons:GetDescendants()) do
                if v:IsA("ValueBase") then
                    local lname = string.lower(v.Name)
                    if lname == "auto" and v:IsA("BoolValue") then
                        v.Value = true
                    elseif lname == "firerate" and v:IsA("NumberValue") then
                        v.Value = 0.02
                    elseif lname == "rpm" and v:IsA("NumberValue") then
                        v.Value = 1200
                    elseif (lname == "cooldown" or lname == "timebetweenshots" or lname == "shootcooldown" or lname == "refire") then
                        if v:IsA("NumberValue") then v.Value = 0.02 end
                        if v:IsA("IntValue") then v.Value = 0 end
                    elseif lname == "semiauto" and v:IsA("BoolValue") then
                        v.Value = false
                    end
                end
            end
        end

        -- Client GUI-side (often real source of fire constraints in Hypershot)
        local function applyClient(container)
            if not container then return end
            for _, v in ipairs(container:GetDescendants()) do
                if v:IsA("ValueBase") then
                    local lname = string.lower(v.Name)
                    if lname == "auto" and v:IsA("BoolValue") then
                        v.Value = true
                    elseif lname == "firerate" and v:IsA("NumberValue") then
                        v.Value = 0.02
                    elseif lname == "rpm" and v:IsA("NumberValue") then
                        v.Value = 1200
                    elseif (lname == "cooldown" or lname == "timebetweenshots" or lname == "shootcooldown" or lname == "refire") then
                        if v:IsA("NumberValue") then v.Value = 0.02 end
                        if v:IsA("IntValue") then v.Value = 0 end
                    elseif lname == "semiauto" and v:IsA("BoolValue") then
                        v.Value = false
                    end
                end
            end
        end

        local pg = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
        if pg then applyClient(pg) end
        local cam = workspace.CurrentCamera
        if cam then applyClient(cam) end
    end

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
            WeaponMods._startRapidClicker()
        else
            WeaponMods.stopTask("firerate")
            WeaponMods._stopRapidClicker()
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

    -- Rapid-fire clicker for semi-auto fallback
    local rfConnections = {}
    local rfRunning = false
    local leftDown = false
    local function disconnectRF()
        for _, c in ipairs(rfConnections) do pcall(function() c:Disconnect() end) end
        rfConnections = {}
    end
    function WeaponMods._startRapidClicker()
        if rfRunning then return end
        rfRunning = true
        disconnectRF()
        table.insert(rfConnections, UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then leftDown = true end
        end))
        table.insert(rfConnections, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then leftDown = false end
        end))
        runningTasks["rapid_clicker_loop"] = true
        task.spawn(function()
            local LocalPlayer = Players.LocalPlayer
            while runningTasks["rapid_clicker_loop"] do
                if not State.get("fireRateMod") then break end
                if leftDown then
                    -- Only spam if a tool/weapon is equipped
                    local char = LocalPlayer and LocalPlayer.Character
                    local hasTool = char and char:FindFirstChildOfClass("Tool") ~= nil
                    if hasTool then
                        local cps = State.get("rapidFireCPS") or 12
                        local pressDur = 0.01
                        local waitGap = math.max(0.01, (1 / cps) - pressDur)
                        pcall(function() mouse1press() end)
                        task.wait(pressDur)
                        pcall(function() mouse1release() end)
                        task.wait(waitGap)
                    else
                        task.wait(0.03)
                    end
                else
                    task.wait(0.03)
                end
            end
            rfRunning = false
        end)
    end
    function WeaponMods._stopRapidClicker()
        runningTasks["rapid_clicker_loop"] = nil
        leftDown = false
        disconnectRF()
        rfRunning = false
    end

    function WeaponMods.stopAll()
        for k in pairs(runningTasks) do
            WeaponMods.stopTask(k)
        end
        WeaponMods._stopRapidClicker()
    end

    return WeaponMods
end 