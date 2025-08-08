return function(Services, State)
    local ESP = {}

    local Players = Services.Players
    local RunService = Services.RunService
    local LocalPlayer = Players.LocalPlayer

    local prototypes = {
        nameBillboard = nil,
        boxBillboard = nil,
        tracer = nil,
    }

    local function createPrototypes()
        if prototypes.nameBillboard and prototypes.boxBillboard then
            -- update dynamic properties below per player instead of prototype
        else
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
    end

    local function tracerFor(character)
        local tag = character:FindFirstChild("ValorHubTracer")
        if tag and tag:IsA("Folder") then return tag end
        tag = Instance.new("Folder")
        tag.Name = "ValorHubTracer"
        tag.Parent = character
        return tag
    end

    local function ensureESPForCharacter(player)
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
        tracerFor(character)
    end

    local function removeESP(character)
        if not character then return end
        local head = character:FindFirstChild("Head")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if head and head:FindFirstChild("esp") then head.esp:Destroy() end
        if hrp and hrp:FindFirstChild("mainesp") then hrp.mainesp:Destroy() end
        local tr = character:FindFirstChild("ValorHubTracer")
        if tr then tr:Destroy() end
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
            local character = player.Character
            local head = character and character:FindFirstChild("Head")
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if character and head and hrp then
                local color = colorFor(player)
                -- name label
                if head:FindFirstChild("esp") and head.esp:FindFirstChild("name") then
                    head.esp.name.Visible = State.get("espShow") and State.get("espShowNames")
                    head.esp.name.Text = player.Name
                    head.esp.name.TextSize = State.get("espTextSize")
                    head.esp.name.TextColor3 = color
                end
                -- box styling
                if hrp:FindFirstChild("mainesp") and hrp.mainesp:FindFirstChild("box") then
                    local box = hrp.mainesp.box
                    box.ImageTransparency = State.get("espShow") and 0.3 or 1
                    -- switch style
                    if State.get("espMode") == "Corner" then
                        box.Image = "rbxassetid://14519771515" -- a corner-ish box asset
                    else
                        box.Image = "rbxassetid://16946608585"
                    end
                end
                -- tracers
                local trFolder = tracerFor(character)
                trFolder:ClearAllChildren()
                if State.get("espShow") and State.get("espShowTracers") then
                    local line = Instance.new("Beam")
                    line.Color = ColorSequence.new(color)
                    line.Width0 = State.get("espThickness")
                    line.Width1 = State.get("espThickness")
                    -- attach points
                    local a0 = Instance.new("Attachment")
                    a0.Parent = workspace.CurrentCamera
                    local a1 = Instance.new("Attachment")
                    a1.Parent = hrp
                    line.Attachment0 = a0
                    line.Attachment1 = a1
                    line.Parent = trFolder
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
                        removeESP(player.Character)
                    else
                        ensureESPForCharacter(player)
                    end
                end
            end
        end)

        RunService:BindToRenderStep("ValorHub_ESP_Style", Enum.RenderPriority.Camera.Value + 2, function()
            updateVisuals()
        end)

        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                task.wait(1)
                if not State.get("espEnabled") then return end
                ensureESPForCharacter(player)
            end)
        end)
    end

    function ESP.stop()
        RunService:UnbindFromRenderStep("ValorHub_ESP_Attach")
        RunService:UnbindFromRenderStep("ValorHub_ESP_Style")
        for _, player in ipairs(Players:GetPlayers()) do
            removeESP(player.Character)
        end
    end

    return ESP
end 