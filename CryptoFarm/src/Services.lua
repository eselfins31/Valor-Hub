local S = {}
local function g(n) return game:GetService(n) end
S.RunService = g("RunService")
S.Players = g("Players")
S.UserInputService = g("UserInputService")
S.HttpService = g("HttpService")
S.TeleportService = g("TeleportService")
S.ReplicatedStorage = g("ReplicatedStorage")
S.CollectionService = g("CollectionService")
return S
