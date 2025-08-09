return function(Services, State)
    local ESP = {}

    local Players = Services.Players
    local RunService = Services.RunService
    local LocalPlayer = Players.LocalPlayer

    local nameBillboardPrototype
    local boxBillboardPrototype
    local drawings = {}

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

    private = {}

    local function removeTracer(player)
        if drawings[player] then
            pcall(function()
                if drawings[player].line then drawings[player].line:Remove() end
            end)
            drawings[player] = nil
        end
    end

    local function createPrototypes()
        if nameBillboardPrototype and boxBillboardPrototype then return end

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
        name.TextScaled = false
        name.TextSize = 9
        name.TextStrokeTransparency = 0
        name.TextWrapped = true
        name.TextTransparency = 1

        nameBillboardPrototype = esp

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
        box.Image = "rbxassetid://16946608585"
        box.ImageTransparency = 1

        local hb = Instance.new("Frame")
        hb.Name = "healthbar"
        hb.Parent = mainesp
        hb.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
        hb.BorderSizePixel = 0
        hb.BackgroundTransparency = 0.3
        hb.AnchorPoint = Vector2.new(0, 1)
        hb.Position = UDim2.new(0, 0, 1, 0)
        hb.Size = UDim2.new(0, 3, 0, 0)

        boxBillboardPrototype = mainesp
    end

    local function getHead(character)
        if not character then return nil end
        return character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    end

    local function getHRP(character)
        if not character then return nil end
        return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart or getHead(character)
    end

    local function ensureForPlayer(player)
        local character = player.Character
        if not character then return end
        local head = getHead(character)
        local hrp = getHRP(character)
        if not head or not hrp then return end

        if not head:FindFirstChild("esp") then
            local nameClone = nameBillboardPrototype:Clone()
            nameClone.Parent = head
            local lbl = nameClone:FindFirstChild("name")
            if lbl then lbl.Text = player.Name end
        end
        if not hrp:FindFirstChild("mainesp") then
            local boxClone = boxBillboardPrototype:Clone()
            boxClone.Parent = hrp
        end
        if State.get("espShowTracers") then ensureTracer(player) end
    end

    local function removeForPlayer(player)
        local character = player and player.Character
        if not character then return end
        local head = getHead(character)
        local hrp = getHRP(character)
        if head and head:FindFirstChild("esp") then head.esp:Destroy() end
        if hrp and hrp:FindFirstChild("mainesp") then hrp.mainesp:Destroy() end
        removeTracer(player)
    end

    function ESP.start()
        createPrototypes()

        RunService.RenderStepped:Connect(function()
            if not State.get("espEnabled") then
                for _, v in ipairs(Players:GetPlayers()) do if v ~= LocalPlayer then removeForPlayer(v) end end
                return
            end

            local show = State.get("espShow")
            local teamCheck = State.get("teamCheck")

            for _, v in ipairs(Players:GetPlayers()) do
                if v ~= LocalPlayer then
                    local char = v.Character
                    local head = char and getHead(char)
                    local hrp = char and getHRP(char)
                    if char and head and hrp then
                        ensureForPlayer(v)

                        local enemy = (not teamCheck) or (v.Team ~= LocalPlayer.Team)
                        local headGui = head:FindFirstChild("esp")
                        if headGui and headGui:FindFirstChild("name") then
                            local nameLbl = headGui.name
                            if State.get("espShowHealth") then
                                local hum = char:FindFirstChildOfClass("Humanoid")
                                if hum then
                                    nameLbl.Text = string.format("%s | %d", v.Name, math.floor(hum.Health))
                                else
                                    nameLbl.Text = v.Name
                                end
                            else
                                nameLbl.Text = v.Name
                            end
                            nameLbl.TextTransparency = (show and enemy and State.get("espShowNames")) and 0 or 1
                            nameLbl.TextSize = State.get("espTextSize")
                            nameLbl.TextColor3 = colorFor(v)
                        end
                        local bodyGui = hrp:FindFirstChild("mainesp")
                        if bodyGui then
                            if bodyGui:FindFirstChild("box") then
                                bodyGui.box.Image = (State.get("espMode") == "Corner") and "rbxassetid://14519771515" or "rbxassetid://16946608585"
                                bodyGui.box.ImageTransparency = (show and enemy) and 0.43 or 1
                            end
                            local hb = bodyGui:FindFirstChild("healthbar")
                            if hb then
                                local hum = char:FindFirstChildOfClass("Humanoid")
                                local frac = 1
                                if hum and hum.MaxHealth > 0 then frac = math.clamp(hum.Health / hum.MaxHealth, 0, 1) end
                                hb.Visible = State.get("espShowHealth") and show and enemy
                                hb.Size = UDim2.new(0, 3, frac, 0)
                                hb.BackgroundColor3 = Color3.fromRGB(255 * (1-frac), 255 * frac, 0)
                            end
                        end
                        local rec = drawings[v]
                        if rec and rec.line then
                            local cam = workspace.CurrentCamera
                            local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                            if onScreen and show and enemy and State.get("espShowTracers") then
                                local origin
                                local cx, cy = cam.ViewportSize.X/2, cam.ViewportSize.Y/2
                                local originMode = State.get("espTracerOrigin")
                                if originMode == "Top" then
                                    origin = Vector2.new(cx, 0)
                                elseif originMode == "Center" then
                                    origin = Vector2.new(cx, cy)
                                else
                                    origin = Vector2.new(cx, cam.ViewportSize.Y)
                                end
                                rec.line.From = origin
                                rec.line.To = Vector2.new(pos.X, pos.Y)
                                rec.line.Color = colorFor(v)
                                rec.line.Thickness = State.get("espThickness")
                                rec.line.Visible = true
                            else
                                rec.line.Visible = false
                            end
                        end
                    else
                        removeForPlayer(v)
                    end
                end
            end
        end)
    end

    function ESP.stop()
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LocalPlayer then removeForPlayer(v) end
        end
    end

    return ESP
end 