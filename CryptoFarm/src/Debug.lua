return function(Services, State)
    local Debug = {}

    local Players = Services.Players

    local enabled = false
    local filterText = ""
    local filterLower = nil
    local maxLines = 200
    local logs = {}

    local function append(line)
        table.insert(logs, line)
        if #logs > maxLines then table.remove(logs, 1) end
    end

    function Debug.setFilter(text)
        filterText = text or ""
        filterLower = filterText ~= "" and string.lower(filterText) or nil
    end

    function Debug.clear()
        logs = {}
    end

    function Debug.getLogText()
        return table.concat(logs, "\n")
    end

    local spyGui
    function Debug.showGui()
        if spyGui then spyGui.Enabled = true return end
        local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
        spyGui = Instance.new("ScreenGui")
        spyGui.Name = "ValorHubSpy"
        spyGui.ResetOnSpawn = false
        spyGui.IgnoreGuiInset = true
        spyGui.Enabled = true
        spyGui.Parent = pg

        local frame = Instance.new("Frame", spyGui)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Position = UDim2.new(1, -420, 0, 80)
        frame.Size = UDim2.new(0, 400, 0, 260)

        local title = Instance.new("TextLabel", frame)
        title.BackgroundTransparency = 1
        title.Text = "Valor Hub Remote Spy"
        title.Font = Enum.Font.Ubuntu
        title.TextSize = 18
        title.TextColor3 = Color3.fromRGB(255,255,255)
        title.Position = UDim2.new(0, 8, 0, 6)
        title.Size = UDim2.new(1, -16, 0, 24)
        title.TextXAlignment = Enum.TextXAlignment.Left

        local box = Instance.new("TextBox", frame)
        box.Name = "Log"
        box.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        box.TextColor3 = Color3.fromRGB(220,220,220)
        box.Font = Enum.Font.Code
        box.TextSize = 14
        box.MultiLine = true
        box.ClearTextOnFocus = false
        box.TextWrapped = false
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.TextYAlignment = Enum.TextYAlignment.Top
        box.Position = UDim2.new(0, 8, 0, 36)
        box.Size = UDim2.new(1, -16, 1, -44)
        box.Text = Debug.getLogText()
        box.RichText = false

        local function refresh()
            if not spyGui or not box then return end
            box.Text = Debug.getLogText()
        end
        Debug._refreshGui = refresh
    end

    function Debug.hideGui()
        if spyGui then spyGui.Enabled = false end
    end

    function Debug.copyLog()
        local txt = Debug.getLogText()
        pcall(function() if setclipboard then setclipboard(txt) end end)
    end

    function Debug.start()
        enabled = true
    end

    function Debug.stop()
        enabled = false
    end

    -- Install hook once
    do
        local mt = getrawmetatable(game)
        if mt and setreadonly then
            local old = mt.__namecall
            local readonly = isreadonly and isreadonly(mt)
            pcall(function() if readonly then setreadonly(mt, false) end end)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod and getnamecallmethod()
                if enabled and (method == "FireServer" or method == "InvokeServer") then
                    if self and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
                        local name = tostring(self)
                        local nlower = string.lower(name)
                        if not filterLower or string.find(nlower, filterLower, 1, true) then
                            local args = {...}
                            local argInfo = {}
                            for i = 1, math.min(#args, 5) do
                                local v = args[i]
                                local t = typeof(v)
                                if t == "string" then
                                    table.insert(argInfo, string.format("[%d]=\"%s\"", i, string.sub(v,1,80)))
                                elseif t == "number" or t == "boolean" then
                                    table.insert(argInfo, string.format("[%d]=%s", i, tostring(v)))
                                elseif t == "Vector3" then
                                    table.insert(argInfo, string.format("[%d]=Vector3(%.1f,%.1f,%.1f)", i, v.X, v.Y, v.Z))
                                else
                                    table.insert(argInfo, string.format("[%d]=%s", i, t))
                                end
                            end
                            local line = string.format("%s(%s)", name, table.concat(argInfo, ", "))
                            append(line)
                            if Debug._refreshGui then pcall(Debug._refreshGui) end
                        end
                    end
                end
                return old(self, ...)
            end)
            pcall(function() if readonly then setreadonly(mt, true) end end)
        end
    end

    return Debug
end
