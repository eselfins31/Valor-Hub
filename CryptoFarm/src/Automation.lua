return function(Services, State)
    local Auto = {}

    local Players = Services.Players
    local CollectionService = Services.CollectionService

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

    -- Internal flags/threads
    Auto.__collecting = false
    Auto.__selling = false
    local collectThread, sellThread

    -- Utilities
    local function getHRP()
        local plr = Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        return char:FindFirstChild("HumanoidRootPart")
    end

    local function tpNear(pos)
        local hrp = getHRP()
        if hrp and pos then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
    end

    local function getPromptWorldPos(prompt)
        if not prompt then return nil end
        local parent = prompt.Parent
        for _ = 1, 4 do
            if not parent then break end
            if parent:IsA("BasePart") then return parent.Position end
            parent = parent.Parent
        end
        return nil
    end

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

    -- Prompt cache with timed refresh
    local cache = { collects = {}, sells = {}, nextRefresh = 0 }
    local function refreshPrompts()
        if tick() < cache.nextRefresh then return cache.collects, cache.sells end
        cache.collects, cache.sells = {}, {}
        -- Prefer tagged parts first
        for _, inst in ipairs(CollectionService:GetTagged("Collectible")) do
            for _, p in ipairs(inst:GetDescendants()) do
                if p:IsA("ProximityPrompt") then table.insert(cache.collects, p) end
            end
        end
        -- Fallback: scan selectively (not every frame)
        if #cache.collects == 0 then
            for _, p in ipairs(workspace:GetDescendants()) do
                if p:IsA("ProximityPrompt") then
                    if isCollectPrompt(p) then table.insert(cache.collects, p)
                    elseif isSellPrompt(p) then table.insert(cache.sells, p) end
                end
            end
        else
            for _, p in ipairs(workspace:GetDescendants()) do
                if p:IsA("ProximityPrompt") and isSellPrompt(p) then table.insert(cache.sells, p) end
            end
        end
        cache.nextRefresh = tick() + 2.0 -- refresh every 2 seconds
        return cache.collects, cache.sells
    end

    local function firePrompt(prompt)
        if not prompt or not prompt:IsDescendantOf(workspace) then return end
        -- Try executor helper first
        local ok = pcall(function() if fireproximityprompt then fireproximityprompt(prompt) end end)
        if ok then return end
        -- Fallback: simulate hold
        local oldHold, oldRange = prompt.HoldDuration, prompt.MaxActivationDistance
        prompt.MaxActivationDistance = math.max(oldRange, 18)
        prompt.HoldDuration = 0
        pcall(function() prompt:InputHoldBegin() end)
        task.wait(0.025)
        pcall(function() prompt:InputHoldEnd() end)
        prompt.HoldDuration = oldHold
        prompt.MaxActivationDistance = oldRange
    end

    local lastFired = setmetatable({}, { __mode = "k" })

    function Auto.autoCollect(on)
        Auto.__collecting = on
        if collectThread then collectThread = nil end
        if not on then return end
        collectThread = task.spawn(function()
            while Auto.__collecting do
                local collects = refreshPrompts()
                collects = collects -- no-op (kept for clarity)
                local fired = 0
                for _, prompt in ipairs(cache.collects) do
                    if fired >= 2 then break end -- throttle: 2 prompts per cycle
                    if prompt.Enabled then
                        local t = lastFired[prompt] or 0
                        if (tick() - t) > 0.7 then
                            local pos = getPromptWorldPos(prompt)
                            if pos then tpNear(pos) end
                            firePrompt(prompt)
                            lastFired[prompt] = tick()
                            fired += 1
                            task.wait(0.08)
                        end
                    end
                end
                task.wait(0.35)
            end
        end)
    end

    function Auto.autoSell(on)
        Auto.__selling = on
        if sellThread then sellThread = nil end
        if not on then return end
        sellThread = task.spawn(function()
            while Auto.__selling do
                local _, sells = refreshPrompts()
                local nearest, nd
                local hrp = getHRP()
                local origin = hrp and hrp.Position
                for _, p in ipairs(sells) do
                    if p.Enabled then
                        local pos = getPromptWorldPos(p)
                        if pos and origin then
                            local d = (pos - origin).Magnitude
                            if not nd or d < nd then nd = d; nearest = p end
                        end
                    end
                end
                if nearest then
                    local pos = getPromptWorldPos(nearest)
                    if pos then tpNear(pos) end
                    firePrompt(nearest)
                end
                task.wait(0.5)
            end
        end)
    end

    return Auto
end
