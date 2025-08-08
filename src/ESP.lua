local Services = require(script.Parent.Services)
local State = require(script.Parent.State)

local ESP = {}

local Players = Services.Players
local RunService = Services.RunService
local LocalPlayer = Players.LocalPlayer

local prototypes = {
    nameBillboard = nil,
    boxBillboard = nil,
}

local function createPrototypes()
    if prototypes.nameBillboard and prototypes.boxBillboard then
        return
    end

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
    name.TextSize = 9
    name.TextStrokeTransparency = 0
    name.TextWrapped = true
    name.TextTransparency = 1

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

    prototypes.nameBillboard = esp
    prototypes.boxBillboard = mainesp
end

local function ensureESPForCharacter(character)
    if not character then
        return
    end
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then
        return
    end

    if not head:FindFirstChild("esp") then
        local nameClone = prototypes.nameBillboard:Clone()
        nameClone.Parent = head
        nameClone:FindFirstChild("name").Text = character.Parent and character.Parent.Name or "Player"
    end
    if not hrp:FindFirstChild("mainesp") then
        local boxClone = prototypes.boxBillboard:Clone()
        boxClone.Parent = hrp
    end
end

local function removeESP(character)
    if not character then
        return
    end
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if head and head:FindFirstChild("esp") then
        head.esp:Destroy()
    end
    if hrp and hrp:FindFirstChild("mainesp") then
        hrp.mainesp:Destroy()
    end
end

function ESP.start()
    createPrototypes()

    RunService:BindToRenderStep("ValorHub_ESP_Attach", Enum.RenderPriority.Camera.Value + 1, function()
        if not State.get("espEnabled") then
            return
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if State.get("teamCheck") and player.Team == LocalPlayer.Team then
                    removeESP(player.Character)
                else
                    ensureESPForCharacter(player.Character)
                end
            end
        end
    end)

    RunService:BindToRenderStep("ValorHub_ESP_Visibility", Enum.RenderPriority.Camera.Value + 2, function()
        local show = State.get("espShow")
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            if character then
                local head = character:FindFirstChild("Head")
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if head and head:FindFirstChild("esp") then
                    head.esp.name.TextTransparency = show and 0 or 1
                end
                if hrp and hrp:FindFirstChild("mainesp") then
                    hrp.mainesp.box.ImageTransparency = show and 0.43 or 1
                end
            end
        end
    end)

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            task.wait(1)
            if not State.get("espEnabled") then
                return
            end
            if State.get("teamCheck") and player.Team == LocalPlayer.Team then
                removeESP(character)
            else
                ensureESPForCharacter(character)
            end
        end)
    end)
end

function ESP.stop()
    RunService:UnbindFromRenderStep("ValorHub_ESP_Attach")
    RunService:UnbindFromRenderStep("ValorHub_ESP_Visibility")
    for _, player in ipairs(Players:GetPlayers()) do
        removeESP(player.Character)
    end
end

return ESP 