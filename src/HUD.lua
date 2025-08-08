return function(Services, State)
    local HUD = {}

    local Players = Services.Players

    local gui
    local label

    local counters = {
        kills = 0,
        deaths = 0,
        shots = 0,
        hits = 0,
        headshots = 0,
        startTime = tick(),
    }

    local function ensureGui()
        if gui and label then return end
        gui = Instance.new("ScreenGui")
        gui.Name = "ValorHubHUD"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

        label = Instance.new("TextLabel")
        label.Name = "Stats"
        label.Parent = gui
        label.BackgroundTransparency = 0.35
        label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        label.BorderSizePixel = 0
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.Ubuntu
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.Position = UDim2.new(0, 10, 0, 10)
        label.Size = UDim2.new(0, 200, 0, 80)
    end

    local function fmt()
        local kd = counters.deaths > 0 and (counters.kills / counters.deaths) or counters.kills
        local acc = counters.shots > 0 and (counters.hits / counters.shots * 100) or 0
        local hs = counters.hits > 0 and (counters.headshots / counters.hits * 100) or 0
        local elapsed = math.max(1, math.floor(tick() - counters.startTime))
        return string.format("K/D: %.2f\nHS: %.1f%%\nACC: %.1f%%\nTime: %ds", kd, hs, acc, elapsed)
    end

    function HUD.addKill()
        counters.kills += 1
    end

    function HUD.addDeath()
        counters.deaths += 1
    end

    function HUD.addShot()
        counters.shots += 1
    end

    function HUD.addHit(isHead)
        counters.hits += 1
        if isHead then counters.headshots += 1 end
    end

    function HUD.start()
        ensureGui()
        game:GetService("RunService").RenderStepped:Connect(function()
            if not State.get("hudEnabled") then
                if gui then gui.Enabled = false end
                return
            end
            gui.Enabled = true
            label.Text = fmt()
        end)
    end

    function HUD.stop()
        if gui then gui.Enabled = false end
    end

    return HUD
end 