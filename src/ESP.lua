return function(Services, State)
    local ESP = {}

    local Players = Services.Players
    local RunService = Services.RunService
    local LocalPlayer = Players.LocalPlayer

    local drawings = {} -- [player] = { line = DrawingLine }

    local function getCharacterParts(character)
        if not character then return nil, nil end
        local head = character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        local hrp = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart or head
        return head, hrp
    end

    local function ensureHighlight(player)
        local character = player.Character
        if not character then return end
        local hl = character:FindFirstChild("ValorHubHighlight")
        if not hl then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ValorHubHighlight"
            highlight.Adornee = character
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillTransparency = 1 -- outline only for less obtrusive look
            highlight.OutlineTransparency = 0
            highlight.Parent = character
        end
    end

    local function ensureBillboard(player)
        local character = player.Character
        if not character then return end
        local head, _ = getCharacterParts(character)
        if not head then return end
        local gui = head:FindFirstChild("esp")
        if not gui then
            local esp = Instance.new("BillboardGui")
            esp.Name = "esp"
            esp.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            esp.Active = true
            esp.AlwaysOnTop = true
            esp.LightInfluence = 1
            esp.Size = UDim2.new(0, 200, 0, 24)
            esp.StudsOffset = Vector3.new(0, 3, 0)
            esp.Parent = head

            local name = Instance.new("TextLabel")
            name.Name = "name"
            name.Parent = esp
            name.BackgroundTransparency = 1
            name.Size = UDim2.new(1, 0, 1, 0)
            name.Font = Enum.Font.Ubuntu
            name.TextStrokeTransparency = 0.5
            name.TextScaled = false
            name.TextWrapped = false
        end
    end

    local function ensureTracer(player)
        if drawings[player] then return end
        local ok = pcall(function() return Drawing end)
        if not ok then return end
        local line = Drawing.new("Line")
        line.Thickness = State.get("espThickness")
        line.Transparency = 1
        line.Visible = false
        drawings[player] = { line = line }
    end

    local function colorFor(player)
        if State.get("espUseTeamColor") and player.Team and player.Team.TeamColor then
            return player.Team.TeamColor.Color
        end
        if player.Team == LocalPlayer.Team then
            return State.get("espTeamColor")
        else
            return State.get("espEnemyColor")
        end
    end

    local function removeFor(player)
        local character = player and player.Character
        if character then
            local head, _ = getCharacterParts(character)
            local hl = character:FindFirstChild("ValorHubHighlight")
            if hl then hl:Destroy() end
            if head and head:FindFirstChild("esp") then head.esp:Destroy() end
        end
        if drawings[player] then
            pcall(function()
                if drawings[player].line then drawings[player].line:Remove() end
            end)
            drawings[player] = nil
        end
    end

    local function updateOne(player)
        local character = player.Character
        if not character then removeFor(player) return end
        local head, hrp = getCharacterParts(character)
        if not head or not hrp then removeFor(player) return end

        ensureHighlight(player)
        ensureBillboard(player)
        if State.get("espShowTracers") then ensureTracer(player) end

        local enemy = (not State.get("teamCheck")) or (player.Team ~= LocalPlayer.Team)
        local visible = State.get("espEnabled") and State.get("espShow") and enemy
        local color = colorFor(player)

        -- Highlight
        local hl = character:FindFirstChild("ValorHubHighlight")
        if hl then
            hl.Enabled = visible
            hl.OutlineColor = color
        end

        -- Name / Health label
        if head:FindFirstChild("esp") and head.esp:FindFirstChild("name") then
            local nameLbl = head.esp.name
            nameLbl.Visible = State.get("espShowNames") and visible
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if State.get("espShowHealth") and humanoid then
                nameLbl.Text = string.format("%s | %d", player.Name, math.floor(humanoid.Health))
            else
                nameLbl.Text = player.Name
            end
            nameLbl.TextSize = State.get("espTextSize")
            nameLbl.TextColor3 = color
        end

        -- Tracer (Drawing)
        local record = drawings[player]
        if record and record.line then
            local line = record.line
            local cam = workspace.CurrentCamera
            local projected, onScreen = cam:WorldToViewportPoint(hrp.Position)
            if onScreen and State.get("espShowTracers") and visible then
                local origin = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                line.From = origin
                line.To = Vector2.new(projected.X, projected.Y)
                line.Color = color
                line.Thickness = State.get("espThickness")
                line.Visible = true
            else
                line.Visible = false
            end
        end
    end

    function ESP.start()
        RunService:BindToRenderStep("ValorHub_ESP_Update", Enum.RenderPriority.Camera.Value + 2, function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    updateOne(player)
                end
            end
        end)
        Players.PlayerRemoving:Connect(function(p)
            removeFor(p)
        end)
    end

    function ESP.stop()
        RunService:UnbindFromRenderStep("ValorHub_ESP_Update")
        for _, p in ipairs(Players:GetPlayers()) do removeFor(p) end
    end

    return ESP
end 