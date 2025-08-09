return function(Services, State)
    local Auto = {}

    local Players = Services.Players
    local ProximityPromptService = game:GetService("ProximityPromptService")
    local ReplicatedStorage = Services.ReplicatedStorage

    -- Movement helpers
    local Movement = {}
    local speedConn
    local originalWalkSpeed
    local function getHumanoid()
        local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        return char:FindFirstChildOfClass("Humanoid")
    end
    function Movement.startSpeed(target)
        local hum = getHumanoid()
        if not hum then return end
        if originalWalkSpeed == nil then originalWalkSpeed = hum.WalkSpeed end
        hum.WalkSpeed = target or 100
        if speedConn then speedConn:Disconnect() end
        speedConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            hum.WalkSpeed = target or 100
        end)
    end
    function Movement.stopSpeed()
        if speedConn then speedConn:Disconnect(); speedConn = nil end
        local hum = getHumanoid()
        if hum and originalWalkSpeed then hum.WalkSpeed = originalWalkSpeed end
        originalWalkSpeed = nil
    end
    function Movement.applySpeed(target)
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = target or hum.WalkSpeed end
    end
    Auto.Movement = Movement

    -- Flags/threads
    Auto.__collecting = false
    Auto.__selling = false
    Auto.__instantCollect = false
    Auto.__instantSell = false
    local collectThread, sellThread, instantCollectThread, instantSellThread

    -- Prompt registry (lightweight fallback when instant remotes not available)
    local collectPrompts, sellPrompts = {}, {}

    local function isCollectPrompt(prompt)
        local a = (prompt.ActionText or ""):lower()
        local o = (prompt.ObjectText or ""):lower()
        return a:find("collect") or a:find("harvest") or a:find("farm") or o:find("computer") or o:find("pc") or o:find("miner")
    end
    local function isSellPrompt(prompt)
        local a = (prompt.ActionText or ""):lower()
        local o = (prompt.ObjectText or ""):lower()
        return a:find("sell") or o:find("sell")
    end

    local function trackPrompt(p)
        if not p:IsA("ProximityPrompt") then return end
        if isCollectPrompt(p) then table.insert(collectPrompts, p) end
        if isSellPrompt(p) then table.insert(sellPrompts, p) end
        p.Destroying:Once(function()
            for i, v in ipairs(collectPrompts) do if v == p then table.remove(collectPrompts, i) break end end
            for i, v in ipairs(sellPrompts) do if v == p then table.remove(sellPrompts, i) break end end
        end)
    end
    for _, d in ipairs(workspace:GetDescendants()) do if d:IsA("ProximityPrompt") then trackPrompt(d) end end
    workspace.DescendantAdded:Connect(function(inst) if inst:IsA("ProximityPrompt") then trackPrompt(inst) end end)
    ProximityPromptService.PromptShown:Connect(function(p) trackPrompt(p) end)

    -- Instant remotes discovery
    local remoteCollectAll, remoteSellAll

    local function scanForRemotes()
        local function matchCollect(n)
            n = n:lower()
            return n:find("collectall") or (n:find("collect") and n:find("all")) or n:find("harvestall") or n:find("pickupall")
        end
        local function matchSell(n)
            n = n:lower()
            return n:find("sellall") or (n:find("sell") and n:find("all")) or n:find("autosell") or n:find("sellcrypto") or n:find("sellinventory")
        end
        for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do
            if inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") then
                local n = inst.Name
                if (not remoteCollectAll) and matchCollect(n) then remoteCollectAll = inst end
                if (not remoteSellAll) and matchSell(n) then remoteSellAll = inst end
            end
        end
    end
    scanForRemotes()

    -- Hook __namecall to learn remotes when user interacts (or our fallback fires prompts)
    do
        local mt = getrawmetatable(game)
        if mt and setreadonly then
            local old = mt.__namecall
            local readonly = isreadonly and isreadonly(mt)
            local okSet = true
            pcall(function() if readonly then setreadonly(mt, false) end end)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod and getnamecallmethod()
                if method == "FireServer" or method == "InvokeServer" then
                    local n = tostring(self):lower()
                    if not remoteCollectAll and n:find("collect") and n:find("all") then remoteCollectAll = self end
                    if not remoteSellAll and n:find("sell") and (n:find("all") or n:find("crypto") or n:find("inventory")) then remoteSellAll = self end
                end
                return old(self, ...)
            end)
            pcall(function() if readonly then setreadonly(mt, true) end end)
        end
    end

    local function safeFire(remote)
        if not remote then return end
        pcall(function()
            if remote.FireServer then remote:FireServer() else remote:InvokeServer() end
        end)
    end

    function Auto.instantCollect(on)
        Auto.__instantCollect = on
        if instantCollectThread then instantCollectThread = nil end
        if not on then return end
        instantCollectThread = task.spawn(function()
            while Auto.__instantCollect do
                if not remoteCollectAll then scanForRemotes() end
                safeFire(remoteCollectAll)
                task.wait(0.25)
            end
        end)
    end

    function Auto.instantSell(on)
        Auto.__instantSell = on
        if instantSellThread then instantSellThread = nil end
        if not on then return end
        instantSellThread = task.spawn(function()
            while Auto.__instantSell do
                if not remoteSellAll then scanForRemotes() end
                safeFire(remoteSellAll)
                task.wait(0.4)
            end
        end)
    end

    -- Fallback proximity-based (nearby only) to avoid FPS drops
    local function distanceToPrompt(p)
        local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return math.huge end
        local base = p and p.Parent
        for _ = 1, 4 do
            if not base then break end
            if base:IsA("BasePart") then return (base.Position - hrp.Position).Magnitude end
            base = base.Parent
        end
        return math.huge
    end

    local function firePrompt(prompt)
        if not prompt or not prompt:IsDescendantOf(workspace) then return end
        if distanceToPrompt(prompt) > 30 then return end
        local ok = pcall(function() if fireproximityprompt then fireproximityprompt(prompt) end end)
        if ok then return end
        local oldHold, oldRange = prompt.HoldDuration, prompt.MaxActivationDistance
        prompt.MaxActivationDistance = math.max(oldRange, 20)
        prompt.HoldDuration = 0
        pcall(function() prompt:InputHoldBegin() end)
        task.wait(0.02)
        pcall(function() prompt:InputHoldEnd() end)
        prompt.HoldDuration = oldHold
        prompt.MaxActivationDistance = oldRange
    end

    local lastFired = setmetatable({}, { __mode = "k" })
    local colIndex = 1

    function Auto.autoCollect(on)
        Auto.__collecting = on
        if collectThread then collectThread = nil end
        if not on then return end
        collectThread = task.spawn(function()
            while Auto.__collecting do
                for i = #collectPrompts, 1, -1 do if not collectPrompts[i] or not collectPrompts[i]:IsDescendantOf(workspace) then table.remove(collectPrompts, i) end end
                local fired = 0
                for _ = 1, 3 do
                    if #collectPrompts == 0 then break end
                    if colIndex > #collectPrompts then colIndex = 1 end
                    local p = collectPrompts[colIndex]
                    colIndex += 1
                    if p and p.Enabled then
                        local t = lastFired[p] or 0
                        if (tick() - t) > 0.7 then
                            firePrompt(p)
                            lastFired[p] = tick()
                            fired += 1
                            task.wait(0.06)
                        end
                    end
                end
                task.wait(0.25)
            end
        end)
    end

    local sellIndex = 1
    function Auto.autoSell(on)
        Auto.__selling = on
        if sellThread then sellThread = nil end
        if not on then return end
        sellThread = task.spawn(function()
            while Auto.__selling do
                for i = #sellPrompts, 1, -1 do if not sellPrompts[i] or not sellPrompts[i]:IsDescendantOf(workspace) then table.remove(sellPrompts, i) end end
                if #sellPrompts > 0 then
                    if sellIndex > #sellPrompts then sellIndex = 1 end
                    local p = sellPrompts[sellIndex]
                    sellIndex += 1
                    if p and p.Enabled then firePrompt(p) end
                end
                task.wait(0.5)
            end
        end)
    end

    return Auto
end
