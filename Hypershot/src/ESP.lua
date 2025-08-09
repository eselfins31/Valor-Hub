return function(Services, State)
    local ESP = {}

    local Players = Services.Players
    local RunService = Services.RunService
    local LocalPlayer = Players.LocalPlayer

    local drawings = {}

    local function areTeammates(a, b)
        if a.Team and b.Team then
            if a.Team == b.Team then return true end
        end
        if a.TeamColor and b.TeamColor and a.TeamColor == b.TeamColor then
            return true
        end
        local function readTeamVal(p)
            local v = p:FindFirstChild("Team")
            if v and v.Value then return tostring(v.Value) end
            local ls = p:FindFirstChild("leaderstats")
            if ls then
                local tv = ls:FindFirstChild("Team") or ls:FindFirstChild("team")
                if tv and tv.Value then return tostring(tv.Value) end
            end
            return nil
        end
        local ta = readTeamVal(a)
        local tb = readTeamVal(b)
        if ta and tb and ta == tb then return true end
        return false
    end

    local function colorFor(player)
        if State.get("espUseTeamColor") and player.Team and player.Team.TeamColor then
            return player.Team.TeamColor.Color
        end
        if areTeammates(player, LocalPlayer) then
            return State.get("espTeamColor")
        else
            return State.get("espEnemyColor")
        end
    end

    local function ensureGuiRoot()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return nil end
        local root = pg:FindFirstChild("ValorHubESP")
        if not root then
            root = Instance.new("Folder")
            root.Name = "ValorHubESP"
            root.Parent = pg
        end
        return root
    end

    local function getHead(character)
        if not character then return nil end
        return character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    end

    private = {}

    local function getHRP(character)
        if not character then return nil end
        return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart or getHead(character)
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

    local function removeTracer(player)
        if drawings[player] then
            pcall(function()
                if drawings[player].line then drawings[player].line:Remove() end
            end)
            drawings[player] = nil
        end
    end

    local function ensureForPlayer(player)
        local character = player.Character
        if not character then return end
        local head = getHead(character)
        local hrp = getHRP(character)
        if not head or not hrp then return end

        local root = ensureGuiRoot()
        if not root then return end

        local nameId = "VESP_name_" .. tostring(player.UserId)
        local boxId = "VESP_box_" .. tostring(player.UserId)

        local nameGui = root:FindFirstChild(nameId)
        if not nameGui then
            nameGui = Instance.new("BillboardGui")
            nameGui.Name = nameId
            nameGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            nameGui.Active = true
            nameGui.AlwaysOnTop = true
            nameGui.LightInfluence = 1
            nameGui.Size = UDim2.new(0, 300, 0, 30)
            nameGui.StudsOffset = Vector3.new(0, 3, 0)
            nameGui.Parent = root

            local name = Instance.new("TextLabel")
            name.Name = "name"
            name.Parent = nameGui
            name.BackgroundTransparency = 1
            name.Size = UDim2.new(1, 0, 1, 0)
            name.Font = Enum.Font.Ubuntu
            name.TextColor3 = Color3.fromRGB(255, 255, 255)
            name.TextScaled = false
            name.TextSize = 9
            name.TextStrokeTransparency = 0
            name.TextWrapped = true
        end
        nameGui.Adornee = head

        local bodyGui = root:FindFirstChild(boxId)
        if not bodyGui then
            bodyGui = Instance.new("BillboardGui")
            bodyGui.Name = boxId
            bodyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            bodyGui.Active = true
            bodyGui.AlwaysOnTop = true
            bodyGui.LightInfluence = 1
            bodyGui.MaxDistance = 999999
            bodyGui.Size = UDim2.new(4, 0, 6, 0)
            bodyGui.Parent = root

            local box = Instance.new("ImageLabel")
            box.Name = "box"
            box.Parent = bodyGui
            box.BackgroundTransparency = 1
            box.Size = UDim2.new(1, 0, 1, 0)
            box.Image = "rbxassetid://16946608585"

            local hb = Instance.new("Frame")
            hb.Name = "healthbar"
            hb.Parent = bodyGui
            hb.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
            hb.BorderSizePixel = 0
            hb.BackgroundTransparency = 0.3
            hb.AnchorPoint = Vector2.new(0, 1)
            hb.Position = UDim2.new(0, 0, 1, 0)
            hb.Size = UDim2.new(0, 3, 0, 0)
        end
        bodyGui.Adornee = hrp

        if State.get("espShowTracers") then ensureTracer(player) end
    end

    local function removeForPlayer(player)
        local root = ensureGuiRoot()
        if root then
            local nameId = "VESP_name_" .. tostring(player.UserId)
            local boxId = "VESP_box_" .. tostring(player.UserId)
            local a = root:FindFirstChild(nameId); if a then a:Destroy() end
            local b = root:FindFirstChild(boxId); if b then b:Destroy() end
        end
        removeTracer(player)
    end

    function ESP.start()
        RunService.RenderStepped:Connect(function()
            if not State.get("espEnabled") then
                local root = ensureGuiRoot()
                if root then root:ClearAllChildren() end
                for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then removeTracer(p) end end
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

                        local enemy = (not teamCheck) or (not areTeammates(v, LocalPlayer))

                        local root = ensureGuiRoot()
                        if not root then continue end
                        local nameGui = root:FindFirstChild("VESP_name_" .. tostring(v.UserId))
                        local bodyGui = root:FindFirstChild("VESP_box_" .. tostring(v.UserId))

                        if nameGui and nameGui:FindFirstChild("name") then
                            local lbl = nameGui.name
                            if State.get("espShowHealth") then
                                local hum = char:FindFirstChildOfClass("Humanoid")
                                if hum then lbl.Text = string.format("%s | %d", v.Name, math.floor(hum.Health)) else lbl.Text = v.Name end
                            else
                                lbl.Text = v.Name
                            end
                            lbl.TextTransparency = (show and enemy and State.get("espShowNames")) and 0 or 1
                            lbl.TextSize = State.get("espTextSize")
                            lbl.TextColor3 = colorFor(v)
                        end

                        if bodyGui then
                            local box = bodyGui:FindFirstChild("box")
                            if box then
                                box.Image = (State.get("espMode") == "Corner") and "rbxassetid://14519771515" or "rbxassetid://16946608585"
                                box.ImageTransparency = (show and enemy) and 0.43 or 1
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
                                if originMode == "Top" then origin = Vector2.new(cx, 0)
                                elseif originMode == "Center" then origin = Vector2.new(cx, cy)
                                else origin = Vector2.new(cx, cam.ViewportSize.Y) end
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
        local root = ensureGuiRoot()
        if root then root:ClearAllChildren() end
        for _, v in ipairs(Players:GetPlayers()) do if v ~= LocalPlayer then removeTracer(v) end end
    end

    return ESP
end 