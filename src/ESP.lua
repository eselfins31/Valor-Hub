return function(Services, State)
    local ESP = {}

    local Players = Services.Players
    local RunService = Services.RunService
    local LocalPlayer = Players.LocalPlayer

    -- Prototypes copied from workingesphere.lua mechanics
    local nameBillboardPrototype
    local boxBillboardPrototype

    local function createPrototypes()
        if nameBillboardPrototype and boxBillboardPrototype then return end

        -- Name Billboard on Head
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
        name.TextTransparency = 1 -- default hidden like working script

        nameBillboardPrototype = esp

        -- Box Billboard on HumanoidRootPart
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
        box.ImageTransparency = 1 -- default hidden like working script

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
    end

    local function removeForPlayer(player)
        local character = player and player.Character
        if not character then return end
        local head = getHead(character)
        local hrp = getHRP(character)
        if head and head:FindFirstChild("esp") then head.esp:Destroy() end
        if hrp and hrp:FindFirstChild("mainesp") then hrp.mainesp:Destroy() end
    end

    function ESP.start()
        createPrototypes()

        RunService.RenderStepped:Connect(function()
            if not State.get("espEnabled") then
                -- Clean all if disabled
                for _, v in ipairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer then removeForPlayer(v) end
                end
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
                        -- Create if missing
                        ensureForPlayer(v)

                        -- Team filtering like working script
                        if teamCheck and v.Team == LocalPlayer.Team then
                            removeForPlayer(v)
                        else
                            -- Apply visibility via transparency like working script
                            local headGui = head:FindFirstChild("esp")
                            local bodyGui = hrp:FindFirstChild("mainesp")
                            if headGui and headGui:FindFirstChild("name") then
                                headGui.name.TextTransparency = show and 0 or 1
                                headGui.name.Text = v.Name
                            end
                            if bodyGui and bodyGui:FindFirstChild("box") then
                                bodyGui.box.ImageTransparency = show and 0.43 or 1
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