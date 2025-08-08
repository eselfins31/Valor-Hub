return function(Services, State)
    local ESP = {}

    local Players = Services.Players
    local RunService = Services.RunService
    local LocalPlayer = Players.LocalPlayer

    local drawings = {} -- [player] = { line = DrawingLine }

    local prototypes = {
        nameBillboard = nil,
        boxBillboard = nil,
    }

    local function createPrototypes()
        if prototypes.nameBillboard and prototypes.boxBillboard then return end

        local esp = Instance.new("BillboardGui")
        esp.Name = "esp"
        esp.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        esp.Active = true
        esp.AlwaysOnTop = true
        esp.LightInfluence = 1
        esp.Size = UDim2.new(0, 300, 0, 30)
        esp.StudsOffset = Vector3.new(0, 3, 0)

        local name = Instance.new("TextLabel")
        name.Name = "name"
        name.Parent = esp
        name.BackgroundTransparency = 1
        name.Size = UDim2.new(1, 0, 1, 0)
        name.Font = Enum.Font.Ubuntu
        name.TextColor3 = Color3.fromRGB(255, 255, 255)
        name.TextSize = State.get("espTextSize")
        name.TextStrokeTransparency = 0
        name.TextWrapped = true
        name.TextTransparency = 0

        local mainesp = Instance.new("BillboardGui")
        mainesp.Name = "mainesp"
        mainesp.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        mainesp.Active = true
        mainesp.AlwaysOnTop = true
        mainesp.LightInfluence = 1
        mainesp.MaxDistance = 999999
        mainesp.Size = UDim2.new(4, 0, 6, 0)

        local box = Instance.new("ImageLabel")
        box.Name = "box"
        box.Parent = mainesp
        box.BackgroundTransparency = 1
        box.Size = UDim2.new(1, 0, 1, 0)
        box.Image = "rbxassetid://16946608585" -- default box
        box.ImageTransparency = 0.6

        prototypes.nameBillboard = esp
        prototypes.boxBillboard = mainesp
    end

    local function ensureESPFor(player)
        local character = player.Character
        if not character then return end
        local head = character:FindFirstChild("Head")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not head or not hrp then return end

        if not head:FindFirstChild("esp") then
            local nameClone = prototypes.nameBillboard:Clone()
            nameClone.Parent = head
        end
        if not hrp:FindFirstChild("mainesp") then
            local boxClone = prototypes.boxBillboard:Clone()
            boxClone.Parent = hrp
        end

        if not drawings[player] then
            local ok, _ = pcall(function() return Drawing end)
            if ok then
                local line = Drawing.new("Line")
                line.Thickness = State.get("espThickness")
                line.Transparency = 1
                line.Visible = false
                drawings[player] = { line = line }
            end
        end
    end

    local function removeESP(player)
        local character = player and player.Character
        if character then
            local head = character:FindFirstChild("Head")
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if head and head:FindFirstChild("esp") then head.esp:Destroy() end
            if hrp and hrp:FindFirstChild("mainesp") then hrp.mainesp:Destroy() end
        end
        if drawings[player] then
            pcall(function()
                if drawings[player].line then drawings[player].line:Remove() end
            end)
            drawings[player] = nil
        end
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

    local function updateVisuals()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character
                local head = character and character:FindFirstChild("Head")
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local color = colorFor(player)
                if character and head and hrp then
                    ensureESPFor(player)
                    -- name label
                    if head:FindFirstChild("esp") and head.esp:FindFirstChild("name") then
                        head.esp.name.Visible = State.get("espShow") and State.get("espShowNames")
                        head.esp.name.Text = player.Name
                        head.esp.name.TextSize = State.get("espTextSize")
                        head.esp.name.TextColor3 = color
                    end
                    -- box
                    if hrp:FindFirstChild("mainesp") and hrp.mainesp:FindFirstChild("box") then
                        local boxImg = hrp.mainesp.box
                        boxImg.ImageTransparency = State.get("espShow") and 0.3 or 1
                        boxImg.Image = State.get("espMode") == "Corner" and "rbxassetid://14519771515" or "rbxassetid://16946608585"
                    end
                    -- tracer line (screen space)
                    if drawings[player] and drawings[player].line then
                        local line = drawings[player].line
                        local cam = workspace.CurrentCamera
                        local headScreen = cam:WorldToViewportPoint(hrp.Position)
                        local originY = cam.ViewportSize.Y
                        local origin
                        -- Bottom origin as default
                        origin = Vector2.new(cam.ViewportSize.X / 2, originY)
                        line.From = origin
                        line.To = Vector2.new(headScreen.X, headScreen.Y)
                        line.Color = color
                        line.Thickness = State.get("espThickness")
                        line.Visible = State.get("espShow") and State.get("espShowTracers")
                    end
                else
                    removeESP(player)
                end
            end
        end
    end

    function ESP.start()
        createPrototypes()
        RunService:BindToRenderStep("ValorHub_ESP_Attach", Enum.RenderPriority.Camera.Value + 1, function()
            if not State.get("espEnabled") then return end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    if State.get("teamCheck") and player.Team == LocalPlayer.Team then
                        removeESP(player)
                    else
                        ensureESPFor(player)
                    end
                end
            end
        end)
        RunService:BindToRenderStep("ValorHub_ESP_Style", Enum.RenderPriority.Camera.Value + 2, function()
            if not State.get("espEnabled") then
                for _, p in ipairs(Players:GetPlayers()) do removeESP(p) end
                return
            end
            updateVisuals()
        end)
        Players.PlayerRemoving:Connect(function(player)
            removeESP(player)
        end)
    end

    function ESP.stop()
        RunService:UnbindFromRenderStep("ValorHub_ESP_Attach")
        RunService:UnbindFromRenderStep("ValorHub_ESP_Style")
        for _, player in ipairs(Players:GetPlayers()) do
            removeESP(player)
        end
    end

    return ESP
end 