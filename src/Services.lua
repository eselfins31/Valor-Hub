local Services = {}

local function get(service)
    return game:GetService(service)
end

Services.RunService = get("RunService")
Services.Players = get("Players")
Services.UserInputService = get("UserInputService")
Services.TweenService = get("TweenService")
Services.Lighting = get("Lighting")
Services.ReplicatedStorage = get("ReplicatedStorage")

return Services 