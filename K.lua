-- Gravel.cc Legacy (SilentAim & Visuals Only)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local gui = {}

local config = {
    Enabled = false,
    fovsize = 120,
    predic = 1,
    espc = Color3.fromRGB(255, 182, 193),
    esptargetc = Color3.fromRGB(255, 255, 0),
    espteamc = Color3.fromRGB(0, 255, 0),
    rfd = false,
    eme = true,
    wallc = false,
    bodypart = "Head",
    espEnabled = false,
    prefTextESP = false,
    highlightesp = false,
    prefHighlightESP = false,
    prefBoxESP = false,
    prefHealthESP = false,
    prefColorByHealth = false,
    espMasterEnabled = false,
    prefHeadDotESP = false,
    originalSizes = {},
    activeApplied = {},
    espData = {},
    highlightData = {},
    currentTarget = nil,
    targethbSizes = {},
    fovc = Color3.fromRGB(100, 0, 0),
    fovct = Color3.fromRGB(255, 255, 0),
    playerConnections = {},
    characterConnections = {},
    looprfd = false,
    targetMode = "Enemies",
    centerLocked = {},
    hitchance = 100,
    maxExpansion = math.huge,
    masterTeamTarget = "Enemies",
    masterTarget = "Players",
    masterGetTarget = "Closest",
    silentGetTarget = "Closest",
    gp = 200,
}

local Alurt = loadstring(game:HttpGet("https://raw.githubusercontent.com/azir-py/project/refs/heads/main/Zwolf/AlurtUI.lua"))()

local function safeNotify(opts)
    if typeof(Alurt) == "table" and type(Alurt.CreateNode) == "function" then
        pcall(function()
            Alurt.CreateNode(opts)
        end)
    end
end

local notif1 = (function()
    pcall(function()
        safeNotify({
            Title = "Script started!",
            Content = "SilentAim & Visuals loaded",
            Audio = "rbxassetid://17208361335",
            Length = 3,
            Image = "rbxassetid://4483362458",
            BarColor = Color3.fromRGB(0, 170, 255)
        })
    end)
end)()

local lib
do
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/hm5650/ACXUI/refs/heads/main/ACXUI"))()
    end)
    if success and result then
        lib = result
    else
        warn("SilentAim: failed to load external UI library, using fallback stub. Error:", result)
        lib = {}
        function lib:SetTitle() end
        function lib:SetIcon() end
        function lib:SetBackgroundColor() end
        function lib:SetCloseBtnColor() end
        function lib:SetTitleColor() end
        function lib:SetButtonsColor() end
        function lib:SetTheme() end
        function lib:AddToggle(_, callback, default)
            if callback then
                pcall(callback, default)
            end
        end
        function lib:AddComboBox(_, _, callback)
            if callback then
                pcall(callback, "Only enemies")
            end
        end
        function lib:AddInputBox(_, callback, _, default)
            if callback then
                pcall(callback, tostring(default))
            end
        end
        function lib:CreateTab() return {} end
        function lib:Tab() end
    end
end

if not math.clamp then
    function math.clamp(x, a, b)
        if x < a then return a end
        if x > b then return b end
        return x
    end
end

local function updateTeamTargetModes()
    local masterSelection = config.masterTeamTarget or config.targetMode
    
    if masterSelection == "All" then
        config.targetMode = "All"
    else
        config.targetMode = masterSelection
    end

    if config.espMasterEnabled then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= localPlayer then
                removeESPLabel(pl)
                if addesp(pl) then
                    makeesp(pl)
                end
            end
        end
    end
    
    if config.espMasterEnabled and config.prefHighlightESP then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= localPlayer then
                removeHighlightESP(pl)
                if addesp(pl) and pl.Character then
                    high(pl)
                end
            end
        end
    end
    
    config.currentTarget = nil
    updateESPColors()
end

local function pc()
local plr = game.Players.LocalPlayer
task.spawn(function()
    while true do
        pcall(function()
            plr.ReplicationFocus = workspace
            plr.MaximumSimulationRadius = math.huge
            plr.SimulationRadius = config.gp
        end)
        task.wait(0.1)
    end
end)
end

pc()

local function isNPCModel(model)
    if not model or not model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health ~= nil then
        if model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") then
            return true
        end
    end
    return false
end

local function getAllTargets()
    local targets = {}

    if config.masterTarget == "Players" or config.masterTarget == "Both" then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= localPlayer then
                table.insert(targets, pl)
            end
        end
    end

    if config.masterTarget == "NPCs" or config.masterTarget == "Both" then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and isNPCModel(obj) then
                if not Players:GetPlayerFromCharacter(obj) then
                    table.insert(targets, obj)
                end
            end
        end
    end

    return targets
end

local function getTargetCharacter(target)
    if not target then return nil end
    if typeof(target) == "Instance" then
        if target:IsA("Player") then
            return target.Character
        elseif target:IsA("Model") then
            return target
        end
    end
    return nil
end

local function getTargetName(target)
    if not target then return "Unknown" end
    if typeof(target) == "Instance" then
        return target.Name
    end
    return tostring(target)
end

local function isTeammate(p)
    if not (localPlayer and p) then return false end
    if typeof(p) == "Instance" and p:IsA("Player") then
        if localPlayer.Team and p.Team then
            return localPlayer.Team == p.Team
        end
    end
    return false
end

local function addesp(targetPlayer)
    if not targetPlayer then return false end
    if typeof(targetPlayer) == "Instance" and targetPlayer:IsA("Player") and targetPlayer == localPlayer then return false end

    local mode = config.targetMode or "Enemies"
    if mode == "Enemies" then
        if typeof(targetPlayer) == "Instance" and targetPlayer:IsA("Player") then
            if isTeammate(targetPlayer) then
                return false
            else
                return true
            end
        else
            return true
        end
    elseif mode == "Teams" then
        if typeof(targetPlayer) == "Instance" and targetPlayer:IsA("Player") then
            return isTeammate(targetPlayer)
        else
            return false
        end
    elseif mode == "All" then
        return true
    else
        if typeof(targetPlayer) == "Instance" and targetPlayer:IsA("Player") then
            if isTeammate(targetPlayer) then
                return false
            else
                return true
            end
        else
            return true
        end
    end
end

local function plralive(target)
    if not target then return false end

    if typeof(target) == "Instance" and target:IsA("Player") then
        local character = target.Character
        if not character then return false end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return false end
        return humanoid.Health > 0
    end

    if typeof(target) == "Instance" and target:IsA("Model") then
        local humanoid = target:FindFirstChildOfClass("Humanoid")
        if not humanoid then return false end
        return humanoid.Health > 0
    end

    return false
end

local function RFD(targetPlayer)
    local char = getTargetCharacter(targetPlayer)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("Decal") then
                local ok, t = pcall(function() return child.Texture end)
                local nameLower = tostring(child.Name):lower()
                local texLower = tostring(t or ""):lower()
                if nameLower == "face" or string.find(nameLower, "face") or string.find(texLower, "face") then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end

local function wallCheck(targetPos, sourcePos)
    if not config.wallc then
        return true
    end

    if (targetPos - sourcePos).Magnitude <= 0 then return true end

    local rayDirection = (targetPos - sourcePos)
    local ray = Ray.new(sourcePos, rayDirection.Unit * rayDirection.Magnitude)
    local ignoreList = {}

    if localPlayer and localPlayer.Character then
        table.insert(ignoreList, localPlayer.Character)
    end

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer.Character then
            table.insert(ignoreList, otherPlayer.Character)
        end
    end

    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    if hit and position then
        local distanceToTarget = (targetPos - sourcePos).Magnitude
        local distanceToHit = (position - sourcePos).Magnitude
        return distanceToHit >= (distanceToTarget - 2)
    end

    return true
end

local function high(targetPlayer)
    if not targetPlayer or not getTargetCharacter(targetPlayer) then return end
    if not addesp(targetPlayer) then return end

    if config.highlightData[targetPlayer] then
        local existing = config.highlightData[targetPlayer]
        if existing and existing.Parent then
            if targetPlayer == config.currentTarget then
                existing.FillColor = config.esptargetc
            else
                existing.FillColor = config.espc
            end
            return
        else
            config.highlightData[targetPlayer] = nil
        end
    end

    local character = getTargetCharacter(targetPlayer)
    if not character then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.FillColor = config.espc
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    local okDepth, _ = pcall(function() highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
    if not okDepth then
    end
    highlight.Parent = character

    if targetPlayer == config.currentTarget then
        highlight.FillColor = config.esptargetc
    else
        highlight.FillColor = config.espc
    end

    config.highlightData[targetPlayer] = highlight
end

local function removeHighlightESP(targetPlayer)
    if not targetPlayer then return end
    local h = config.highlightData[targetPlayer]
    if h and h.Parent then
        pcall(function() h:Destroy() end)
    end
    config.highlightData[targetPlayer] = nil
end

local function removeESPLabel(targetPlayer)
    if not targetPlayer then return end
    local data = config.espData[targetPlayer]
    if not data then return end
    if data.connection then
        pcall(function() data.connection:Disconnect() end)
        data.connection = nil
    end
    
    if data.screenGui and data.screenGui.Parent then
        pcall(function() data.screenGui:Destroy() end)
    end
    
    config.espData[targetPlayer] = nil
end

local function healthColor(humanoid)
    if not humanoid then return config.espc end
    local maxH = humanoid.MaxHealth or 100
    local health = math.clamp(humanoid.Health / maxH, 0, 1)
    local r = 1 - health
    local g = health
    return Color3.new(r, g, 0)
end

local function makeesp(targetPlayer)
    if not targetPlayer then return end
    if not addesp(targetPlayer) then return end
    
    if config.espData[targetPlayer] then
        local oldData = config.espData[targetPlayer]
        if oldData.connection then
            pcall(function() oldData.connection:Disconnect() end)
        end
        if oldData.screenGui and oldData.screenGui.Parent then
            pcall(function() oldData.screenGui:Destroy() end)
        end
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESP_" .. getTargetName(targetPlayer) .. "_" .. tostring(math.random(10000, 99999))
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    
    local parent = localPlayer:FindFirstChild("PlayerGui")
    if not parent then
        parent = game:GetService("CoreGui")
    end
    screenGui.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = "ESPLabel"
    label.BackgroundTransparency = 1
    label.Text = getTargetName(targetPlayer)
    label.TextSize = 6
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Visible = false
    label.Size = UDim2.new(0, 200, 0, 20)
    label.AnchorPoint = Vector2.new(0.5, 1)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = screenGui

    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "ESPBox"
    boxFrame.AnchorPoint = Vector2.new(0, 0)
    boxFrame.Size = UDim2.new(0, 0, 0, 0)
    boxFrame.Position = UDim2.new(0, 0, 0, 0)
    boxFrame.BackgroundTransparency = 0.6
    boxFrame.BorderSizePixel = 0
    boxFrame.Visible = false
    boxFrame.Parent = screenGui

    local boxOutline = Instance.new("UIStroke")
    boxOutline.Thickness = 1
    boxOutline.LineJoinMode = Enum.LineJoinMode.Round
    boxOutline.Color = config.espc
    boxOutline.Transparency = 0.1
    boxOutline.Parent = boxFrame

    local healthBg = Instance.new("Frame")
    healthBg.Name = "HealthBG"
    healthBg.AnchorPoint = Vector2.new(0, 0)
    healthBg.Size = UDim2.new(0, 4, 0, 0)
    healthBg.Position = UDim2.new(0, 0, 0, 0)
    healthBg.BackgroundTransparency = 0.6
    healthBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    healthBg.BorderSizePixel = 0
    healthBg.Visible = false
    healthBg.Parent = screenGui

    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.AnchorPoint = Vector2.new(0, 1)
    healthFill.Size = UDim2.new(1, 0, 0, 0)
    healthFill.Position = UDim2.new(0, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0,255,0)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBg

    local headDot = Instance.new("Frame")
    headDot.Name = "HeadDot"
    headDot.Size = UDim2.new(0, 6, 0, 6)
    headDot.AnchorPoint = Vector2.new(0.5, 0.5)
    headDot.BackgroundColor3 = config.espc
    headDot.BorderSizePixel = 0
    headDot.Visible = false
    headDot.Parent = screenGui

    label.TextColor3 = config.espc
    if targetPlayer == config.currentTarget then
        label.TextColor3 = config.esptargetc
    end

    local function startUpdater()
        if config.espData[targetPlayer] and config.espData[targetPlayer].connection then
            pcall(function() config.espData[targetPlayer].connection:Disconnect() end)
        end
        
        local conn = RunService.RenderStepped:Connect(function()
            local tchar = getTargetCharacter(targetPlayer)
            local charExists = tchar and tchar.Parent
            
            if not charExists then
                if label then label.Visible = false end
                if boxFrame then boxFrame.Visible = false end
                if healthBg then healthBg.Visible = false end
                if headDot then headDot.Visible = false end
                return
            end

            if not addesp(targetPlayer) then
                label.Visible = false
                boxFrame.Visible = false
                healthBg.Visible = false
                headDot.Visible = false
                return
            end

            local head = tchar:FindFirstChild("Head")
            local root = tchar:FindFirstChild("HumanoidRootPart") or tchar:FindFirstChild("Torso") or tchar:FindFirstChild("UpperTorso")
            if not head or not root then
                label.Visible = false
                boxFrame.Visible = false
                healthBg.Visible = false
                headDot.Visible = false
                return
            end

            local topPos = head.Position + Vector3.new(0, 0.4, 0)
            local bottomPos = root.Position - Vector3.new(0, 1.0, 0)
            local midPos = (topPos + bottomPos) * 0.5
            local topV3, onTop = camera:WorldToViewportPoint(topPos)
            local bottomV3, onBottom = camera:WorldToViewportPoint(bottomPos)
            local midV3, onMid = camera:WorldToViewportPoint(midPos)
            local onScreen = onTop and onBottom and onMid and topV3.Z > 0 and bottomV3.Z > 0 and midV3.Z > 0
            local topScreenY = topV3.Y
            local bottomScreenY = bottomV3.Y
            local centerX = midV3.X
            local heightPx = math.abs(bottomScreenY - topScreenY)
            if heightPx <= 2 then heightPx = 2 end
            local widthPx = math.clamp(heightPx * 0.45, 4, 400)

            local humanoid = tchar:FindFirstChildOfClass("Humanoid")
            local hpRatio = 1
            if humanoid then
                local maxH = humanoid.MaxHealth or 100
                if maxH > 0 then
                    hpRatio = math.clamp(humanoid.Health / maxH, 0, 1)
                end
            end

            local hpColor = Color3.new(1,1,1)
            if humanoid then
                hpColor = healthColor(humanoid)
            end

            if config.espMasterEnabled and config.prefTextESP then
                local text = string.format("%s [%d]", getTargetName(targetPlayer), humanoid and math.floor(humanoid.Health) or 0)
                label.Text = text

                local absWidth = 200
                pcall(function()
                    if label.TextBounds and label.TextBounds.X and label.TextBounds.X > 0 then
                        absWidth = label.TextBounds.X + 8
                    elseif label.AbsoluteSize and label.AbsoluteSize.X and label.AbsoluteSize.X > 0 then
                        absWidth = label.AbsoluteSize.X
                    end
                end)

                label.Size = UDim2.new(0, absWidth, 0, 18)
                label.Position = UDim2.new(0, centerX, 0, topScreenY - 4)
                label.Visible = onScreen
                if config.prefColorByHealth and humanoid then
                    label.TextColor3 = hpColor
                else
                    label.TextColor3 = (targetPlayer == config.currentTarget) and config.esptargetc or config.espc
                end
            else
                label.Visible = false
            end

            if config.espMasterEnabled and config.prefBoxESP then
                boxFrame.Size = UDim2.new(0, widthPx, 0, math.max(2, heightPx))
                boxFrame.Position = UDim2.new(0, centerX - widthPx / 2, 0, topScreenY)
                boxFrame.Visible = onScreen
                boxFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                boxFrame.BackgroundTransparency = 0.7

                if config.prefColorByHealth and humanoid then
                    boxOutline.Color = hpColor
                else
                    boxOutline.Color = (targetPlayer == config.currentTarget) and config.esptargetc or config.espc
                end
            else
                boxFrame.Visible = false
            end

            if config.espMasterEnabled and config.prefHealthESP and humanoid then
                healthBg.Size = UDim2.new(0, 4, 0, math.max(2, heightPx))
                healthBg.Position = UDim2.new(0, centerX + widthPx / 2 + 4, 0, topScreenY)
                healthBg.Visible = onScreen
                healthFill.Size = UDim2.new(1, 0, hpRatio, 0)
                healthFill.Position = UDim2.new(0, 0, 1, 0)
                healthFill.BackgroundColor3 = healthColor(humanoid)
            else
                healthBg.Visible = false
            end

            if config.espMasterEnabled and config.prefHeadDotESP and head then
                local headV3, onHead = camera:WorldToViewportPoint(head.Position)
                if onHead and headV3.Z > 0 then
                    headDot.Position = UDim2.new(0, headV3.X, 0, headV3.Y)
                    headDot.Visible = true
                    if config.prefColorByHealth and humanoid then
                        headDot.BackgroundColor3 = hpColor
                    else
                        headDot.BackgroundColor3 = (targetPlayer == config.currentTarget) and config.esptargetc or config.espc
                    end
                else
                    headDot.Visible = false
                end
            else
                headDot.Visible = false
            end
        end)

        config.espData[targetPlayer] = {
            label = label,
            screenGui = screenGui,
            connection = conn,
            box = boxFrame,
            boxOutline = boxOutline,
            healthBG = healthBg,
            healthFill = healthFill,
            headDot = headDot
        }
    end

    local char = getTargetCharacter(targetPlayer)
    if char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")) then
        startUpdater()
    else
        task.spawn(function()
            local c = getTargetCharacter(targetPlayer)
            if c then
                local okHead = c:WaitForChild("Head", 2)
                local okRoot = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
                if okHead or okRoot then
                    startUpdater()
                end
            end
        end)
    end
end

local function updateESPColors()
    local toRemove = {}
    for targetPlayer, data in pairs(config.espData) do
        if (not targetPlayer) or (not data) or (not data.label) then
            toRemove[#toRemove+1] = targetPlayer
        else
            if not addesp(targetPlayer) then
                toRemove[#toRemove+1] = targetPlayer
            else
                local tchar = getTargetCharacter(targetPlayer)
                local humanoid = tchar and tchar:FindFirstChildOfClass("Humanoid")
                local hpColor = (humanoid and config.prefColorByHealth) and healthColor(humanoid) or nil

                if data.label then
                    if config.espMasterEnabled and config.prefTextESP then
                        if hpColor then
                            data.label.TextColor3 = hpColor
                        else
                            data.label.TextColor3 = (targetPlayer == config.currentTarget) and config.esptargetc or config.espc
                        end
                        data.label.Visible = true
                    else
                        data.label.Visible = false
                    end
                end

                if data.box then
                    if config.espMasterEnabled and config.prefBoxESP then
                        data.box.Visible = true
                        if data.boxOutline then
                            data.boxOutline.Color = hpColor or ((targetPlayer == config.currentTarget) and config.esptargetc or config.espc)
                        end
                    else
                        data.box.Visible = false
                    end
                end

                if data.healthBG then
                    if config.espMasterEnabled and config.prefHealthESP and humanoid then
                        data.healthBG.Visible = true
                        local maxH = humanoid.MaxHealth or 100
                        local hRatio = math.clamp(humanoid.Health / maxH, 0, 1)
                        data.healthFill.Size = UDim2.new(1, 0, hRatio, 0)
                        data.healthFill.BackgroundColor3 = healthColor(humanoid)
                    else
                        data.healthBG.Visible = false
                    end
                end

                if data.headDot then
                    if config.espMasterEnabled and config.prefHeadDotESP then
                        data.headDot.Visible = true
                        if hpColor then
                            data.headDot.BackgroundColor3 = hpColor
                        else
                            data.headDot.BackgroundColor3 = (targetPlayer == config.currentTarget) and config.esptargetc or config.espc
                        end
                    else
                        data.headDot.Visible = false
                    end
                end
            end
        end
    end

    for _, targetPlayer in ipairs(toRemove) do
        config.espData[targetPlayer] = nil
    end

    local toRemoveHighlights = {}
    for targetPlayer, highlight in pairs(config.highlightData) do
        if not targetPlayer or not highlight or not highlight.Parent then
            toRemoveHighlights[#toRemoveHighlights+1] = targetPlayer
        else
            if not addesp(targetPlayer) then
                toRemoveHighlights[#toRemoveHighlights+1] = targetPlayer
            else
                if targetPlayer == config.currentTarget then
                    highlight.FillColor = config.esptargetc
                else
                    highlight.FillColor = config.espc
                end
            end
        end
    end

    for _, targetPlayer in ipairs(toRemoveHighlights) do
        config.highlightData[targetPlayer] = nil
    end
end

local function toggleHighlightESP(enabled)
    config.prefHighlightESP = enabled
    config.highlightesp = enabled and config.espMasterEnabled or false

    if config.espMasterEnabled and enabled then
        for _, target in ipairs(getAllTargets()) do
            if addesp(target) and target.Character then
                high(target)
            end
        end
    else
        for targetPlayer, _ in pairs(config.highlightData) do
            removeHighlightESP(targetPlayer)
        end
        config.highlightData = {}
    end
end

local function toggleTextESP(enabled)
    config.prefTextESP = enabled
    config.espEnabled = enabled and config.espMasterEnabled or false

    if config.espMasterEnabled and enabled then
        for _, target in ipairs(getAllTargets()) do
            if addesp(target) then
                makeesp(target)
            end
        end
    else
        for targetPlayer, _ in pairs(config.espData) do
            removeESPLabel(targetPlayer)
        end
        config.espData = {}
    end
end

local function toggleBoxESP(enabled)
    config.prefBoxESP = enabled
    if config.espMasterEnabled then
        for _, target in ipairs(getAllTargets()) do
            if addesp(target) then
                if not config.espData[target] then
                    makeesp(target)
                end
            end
        end
        updateESPColors()
    else
        for targetPlayer, _ in pairs(config.espData) do
            removeESPLabel(targetPlayer)
        end
        config.espData = {}
    end
end

local function toggleHealthESP(enabled)
    config.prefHealthESP = enabled
    if config.espMasterEnabled then
        for _, target in ipairs(getAllTargets()) do
            if addesp(target) then
                if not config.espData[target] then
                    makeesp(target)
                end
            end
        end
        updateESPColors()
    end
end

local function applyESPMaster(state)
    config.espMasterEnabled = state

    if not state then
        for targetPlayer, _ in pairs(config.espData) do
            removeESPLabel(targetPlayer)
        end
        config.espData = {}

        for targetPlayer, _ in pairs(config.highlightData) do
            removeHighlightESP(targetPlayer)
        end
        config.highlightData = {}
        config.espEnabled = false
        config.highlightesp = false
    else
        if config.prefHighlightESP then
            for _, target in ipairs(getAllTargets()) do
                if addesp(target) and target.Character then
                    high(target)
                end
            end
        end
        if config.prefTextESP or config.prefBoxESP or config.prefHealthESP or config.prefHeadDotESP then
            for _, target in ipairs(getAllTargets()) do
                if addesp(target) then
                    makeesp(target)
                end
            end
            config.espEnabled = config.prefTextESP
            config.highlightesp = config.prefHighlightESP
        end
    end

    updateESPColors()
end

local function toggleESP(enabled)
    toggleTextESP(enabled)
end

local function removeAllFaceDecals()
    for _, target in ipairs(getAllTargets()) do
        RFD(target)
    end
end

local function saveOriginalPartInfo(targetPlayer, part)
    if not targetPlayer or not part then return end
    config.originalSizes[targetPlayer] = {
        partName = part.Name or "Head",
        size = part.Size,
    }
end

local function chooseBodyPartInstance(target)
    local char = getTargetCharacter(target)
    if not char then return nil, "Head" end

    local bp = config.bodypart or "Head"

    if bp == "Head" then
        return char:FindFirstChild("Head"), "Head"
    elseif bp == "HumanoidRootPart" then
        return char:FindFirstChild("HumanoidRootPart"), "HumanoidRootPart"
    elseif bp == "Both" then
        local roll = math.random(1, 100)
        local primaryName, secondaryName
        if roll <= 85 then
            primaryName = "HumanoidRootPart"
            secondaryName = "Head"
        else
            primaryName = "Head"
            secondaryName = "HumanoidRootPart"
        end
        local primaryPart = char:FindFirstChild(primaryName)
        if primaryPart then
            return primaryPart, primaryName
        else
            local fallback = char:FindFirstChild(secondaryName)
            return fallback, secondaryName
        end
    else
        local found = char:FindFirstChild(bp) or char:FindFirstChild("Head")
        return found, (found and found.Name) or "Head"
    end
end

local function applySizeToPart(targetPlayer, targetDiameter, chosenPart)
    local char = getTargetCharacter(targetPlayer)
    if not char or targetPlayer == localPlayer then return end
    if not plralive(targetPlayer) then return end

    local part = chosenPart
    local partName = nil
    if not part then
        part, partName = chooseBodyPartInstance(targetPlayer)
    else
        partName = part.Name
    end
    if not part then return end

    if not config.originalSizes[targetPlayer] then
        saveOriginalPartInfo(targetPlayer, part)
    end

    local expansionSize = Vector3.new(
        targetDiameter,
        targetDiameter,
        targetDiameter
    )

    local useExpanded = true
    local chance = math.clamp(tonumber(config.hitchance) or 100, 0, 100)
    if chance <= 0 then
        useExpanded = false
    elseif chance < 100 then
        if math.random(1, 100) <= chance then
            useExpanded = true
        else
            useExpanded = false
        end
    else
        useExpanded = true
    end

    if useExpanded then
        config.targethbSizes[targetPlayer] = expansionSize
    else
        local original = config.originalSizes[targetPlayer]
        if original and original.size then
            config.targethbSizes[targetPlayer] = original.size
        else
            config.targethbSizes[targetPlayer] = Vector3.new(0.05, 0.05, 0.05)
        end
    end

    config.activeApplied[targetPlayer] = true
end

local function restorePartForPlayer(targetPlayer)
    if not targetPlayer or targetPlayer == localPlayer then return end

    local char = getTargetCharacter(targetPlayer)
    local original = config.originalSizes[targetPlayer]
    if not original then
        config.activeApplied[targetPlayer] = nil
        config.targethbSizes[targetPlayer] = nil
        return
    end

    local part = nil
    if char then
        part = char:FindFirstChild(original.partName) or char:FindFirstChild(config.bodypart) or char:FindFirstChild("Head")
    end

    if part and original.size then
        pcall(function()
            part.Size = original.size
            part.Transparency = 1
            part.CanCollide = false
            part.Massless = false
            if part:IsA("BasePart") then
                part.Velocity = Vector3.new(0, 0, 0)
                part.RotVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end

    config.activeApplied[targetPlayer] = nil
    config.originalSizes[targetPlayer] = nil
    config.targethbSizes[targetPlayer] = nil
    config.centerLocked[targetPlayer] = nil
end

local function hb()
    for playerObj, targetSize in pairs(config.targethbSizes) do
        if playerObj and playerObj ~= localPlayer and getTargetCharacter(playerObj) and plralive(playerObj) then
            local part = getTargetCharacter(playerObj):FindFirstChild(config.originalSizes[playerObj] and config.originalSizes[playerObj].partName) 
                         or getTargetCharacter(playerObj):FindFirstChild(config.bodypart) 
                         or getTargetCharacter(playerObj):FindFirstChild("Head")
            if not part then
                local p1 = getTargetCharacter(playerObj):FindFirstChild("HumanoidRootPart")
                local p2 = getTargetCharacter(playerObj):FindFirstChild("Head")
                part = p1 or p2
            end

            if part then
                local currentSize = part.Size
                local lerpAlpha = math.clamp(tonumber(config.predic) or 1, 0, 1)
                local newSize = currentSize:Lerp(targetSize, lerpAlpha)

                pcall(function()
                    part.Size = newSize
                    part.Transparency = 1
                    part.CanCollide = false
                    part.Massless = (part.Name ~= "HumanoidRootPart")
                end)
            end
        else
            if playerObj ~= localPlayer then
                restorePartForPlayer(playerObj)
            end
        end
    end
end

RunService.Heartbeat:Connect(hb)

local function onRenderStep()
    if not camera or not camera.Parent then
        camera = workspace.CurrentCamera
        if not camera then return end
    end

    if not gui.RingHolder or not gui.RingStroke then return end

    if not config.Enabled then
        gui.RingHolder.Visible = false
        return
    else
        gui.RingHolder.Visible = true
    end

    local viewportSize = camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local radiusPx = config.fovsize

    if gui.RingHolder then
        local currentSize = gui.RingHolder.AbsoluteSize and gui.RingHolder.AbsoluteSize.X or (config.fovsize * 2)
        radiusPx = currentSize / 2
    end

    local candidates = {}

    for _, pl in ipairs(getAllTargets()) do
        local bodyPart, chosenName = chooseBodyPartInstance(pl)
        local humanoid = nil
        local char = getTargetCharacter(pl)
        if char then
            humanoid = char:FindFirstChildOfClass("Humanoid")
        end

        if bodyPart and humanoid and humanoid.Health > 0 then
            local mode = config.targetMode or "Enemies"
            local skip = false
            if mode == "Enemies" then
                if typeof(pl) == "Instance" and pl:IsA("Player") and isTeammate(pl) then
                    skip = true
                end
            elseif mode == "Teams" then
                if typeof(pl) == "Instance" and pl:IsA("Player") and not isTeammate(pl) then
                    skip = true
                end
            elseif mode == "All" then
                skip = false
            end

            if not skip then
                local topPos = bodyPart.Position
                local screenPos3, onScreen = camera:WorldToViewportPoint(topPos)
                if onScreen then
                    local screenVec = Vector2.new(screenPos3.X, screenPos3.Y)
                    local distPx = (screenVec - center).Magnitude
                    if distPx <= radiusPx then
                        local cameraPos = camera.CFrame.Position
                        local targetPos = bodyPart.Position
                        if wallCheck(targetPos, cameraPos) then
                            local worldDist = (cameraPos - targetPos).Magnitude
                            table.insert(candidates, {
                                player = pl,
                                part = bodyPart,
                                partName = chosenName,
                                screenDist = distPx,
                                worldDist = worldDist,
                                screenPos = screenVec,
                                screenPos3 = screenPos3,
                                humanoid = humanoid
                            })
                        end
                    end
                end
            end
        else
            if config.activeApplied[pl] then
                restorePartForPlayer(pl)
            end
        end
    end

    local best = nil
    local selectionMode = config.silentGetTarget or config.masterGetTarget or "Closest"
    if #candidates > 0 then
        if selectionMode == "Lowest Health" then
            local bestHealth = math.huge
            for _, c in ipairs(candidates) do
                local h = c.humanoid and c.humanoid.Health or math.huge
                if best == nil or h < bestHealth then
                    bestHealth = h
                    best = c
                end
            end
        else 
            local bestWorldDist = math.huge
            for _, c in ipairs(candidates) do
                if c.worldDist < bestWorldDist then
                    bestWorldDist = c.worldDist
                    best = c
                end
            end
        end
    end

    if best then
        gui.RingStroke.Color = config.fovct
    else
        gui.RingStroke.Color = config.fovc
    end

    if config.currentTarget ~= (best and best.player) then
        config.currentTarget = best and best.player
        updateESPColors()
    end

    for pl, _ in pairs(config.activeApplied) do
        if (not best) or pl ~= best.player or not plralive(pl) then
            restorePartForPlayer(pl)
        end
    end

    if best and plralive(best.player) then
        local diameter = (function()
            local viewportSize = camera.ViewportSize
            local H = viewportSize.Y
            local vFovDeg = camera.FieldOfView
            local vFovRad = math.rad(vFovDeg)
            local halfVFov = vFovRad / 2
            local alpha = (radiusPx / (H / 2)) * halfVFov
            local worldHalf = best.worldDist * math.tan(alpha)
            local worldFull = worldHalf * 2
            return worldFull
        end)()

        diameter = math.max(0.01, diameter)

        local localChar = localPlayer.Character
        local targetChar = getTargetCharacter(best.player)
        local distance = math.huge

        if localChar and targetChar then
            local localRoot = localChar:FindFirstChild("HumanoidRootPart") or localChar:FindFirstChild("Head")
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")

            if localRoot and targetRoot then
                distance = (localRoot.Position - targetRoot.Position).Magnitude
            end
        end

        local studz = 5 
        if distance <= studz then
            diameter = math.max(0.05, math.min(0.1, diameter))
        else
            local ok, pixelRadius = pcall(function()
                local rightWorld = camera.CFrame:VectorToWorldSpace(Vector3.new(1, 0, 0)).Unit
                local upWorld = camera.CFrame:VectorToWorldSpace(Vector3.new(0, 1, 0)).Unit
                local worldHalf = diameter / 2
                local maxPixel = 0
                local samples = 16
                for i = 0, samples - 1 do
                    local angle = (i / samples) * 2 * math.pi
                    local offsetWorld = rightWorld * math.cos(angle) * worldHalf + upWorld * math.sin(angle) * worldHalf
                    local samplePointWorld = best.part.Position + offsetWorld
                    local sp, onScreenSample = camera:WorldToViewportPoint(samplePointWorld)
                    if onScreenSample then
                        local sampleScreen = Vector2.new(sp.X, sp.Y)
                        local d = (sampleScreen - best.screenPos).Magnitude
                        if d > maxPixel then
                            maxPixel = d
                        end
                    end
                end

                if maxPixel <= 0 then
                    return nil
                end

                return maxPixel
            end)

            if ok and pixelRadius and pixelRadius > 0 then
                local scale = best.screenDist / pixelRadius
                scale = math.clamp(scale, 1 / config.maxExpansion, config.maxExpansion)
                diameter = math.max(0.01, diameter * scale)
            end
        end

        diameter = math.max(0.01, diameter)
        if best.screenDist <= 1 then
            if not config.centerLocked[best.player] then
                config.centerLocked[best.player] = true
                applySizeToPart(best.player, diameter, best.part)
            else
                local prevSize = config.targethbSizes[best.player]
                if prevSize then
                    diameter = prevSize.X
                end
                applySizeToPart(best.player, diameter, best.part)
            end
        else
            config.centerLocked[best.player] = nil
            applySizeToPart(best.player, diameter, best.part)
        end

        if config.rfd then
            RFD(best.player)
        end
    end
end

RunService.RenderStepped:Connect(onRenderStep)

local function setupDeathListener(targetPlayer)
    local char = getTargetCharacter(targetPlayer)
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if config.characterConnections[targetPlayer] then
        pcall(function() config.characterConnections[targetPlayer]:Disconnect() end)
        config.characterConnections[targetPlayer] = nil
    end

    config.characterConnections[targetPlayer] = humanoid.HealthChanged:Connect(function(health)
        if health <= 0 then
            restorePartForPlayer(targetPlayer)
            if config.currentTarget == targetPlayer then
                config.currentTarget = nil
                updateESPColors()
            end
        end
    end)
end

local function cleanplrdata(targetPlayer)
    if not targetPlayer then return end

    restorePartForPlayer(targetPlayer)
    removeESPLabel(targetPlayer)
    removeHighlightESP(targetPlayer)

    if config.playerConnections[targetPlayer] then
        for _, conn in ipairs(config.playerConnections[targetPlayer]) do
            pcall(function() conn:Disconnect() end)
        end
        config.playerConnections[targetPlayer] = nil
    end

    if config.characterConnections[targetPlayer] then
        pcall(function() config.characterConnections[targetPlayer]:Disconnect() end)
        config.characterConnections[targetPlayer] = nil
    end

    config.activeApplied[targetPlayer] = nil
    config.originalSizes[targetPlayer] = nil
    config.targethbSizes[targetPlayer] = nil

    if config.currentTarget == targetPlayer then
        config.currentTarget = nil
        updateESPColors()
    end
end

local function setupPlayerListeners(pl)
    if pl == localPlayer then return end
    if config.playerConnections[pl] then
        for _, conn in ipairs(config.playerConnections[pl]) do
            pcall(function() conn:Disconnect() end)
        end
    end
    
    config.playerConnections[pl] = {}
    
    local function updateESPForPlayer()
        if config.espMasterEnabled then
            removeESPLabel(pl)
            removeHighlightESP(pl)
            
            if config.prefTextESP or config.prefBoxESP or config.prefHealthESP or config.prefHeadDotESP then
                if addesp(pl) then
                    makeesp(pl)
                end
            end
            
            if config.prefHighlightESP and pl.Character then
                if addesp(pl) then
                    high(pl)
                end
            end
        end
    end
    updateESPForPlayer()
    
    local charAddedConn = pl.CharacterAdded:Connect(function(char)
        task.wait(0.25)
        setupDeathListener(pl)
        removeESPLabel(pl)
        removeHighlightESP(pl)
        task.wait(0.1)
        
        if config.espMasterEnabled then
            if config.prefTextESP or config.prefBoxESP or config.prefHealthESP or config.prefHeadDotESP then
                if addesp(pl) then
                    makeesp(pl)
                end
            end
            
            if config.prefHighlightESP then
                if addesp(pl) and pl.Character then
                    high(pl)
                end
            end
        end
    end)
    table.insert(config.playerConnections[pl], charAddedConn)
    
    local charRemovingConn = pl.CharacterRemoving:Connect(function(char)
        if config.espData[pl] then
            local data = config.espData[pl]
            if data.label then data.label.Visible = false end
            if data.box then data.box.Visible = false end
            if data.healthBG then data.healthBG.Visible = false end
            if data.headDot then data.headDot.Visible = false end
        end
        removeHighlightESP(pl)
    end)
    table.insert(config.playerConnections[pl], charRemovingConn)
    
    local teamChangedConn = pl:GetPropertyChangedSignal("Team"):Connect(function()
        task.wait(0.05)
        updateESPForPlayer()
    end)
    table.insert(config.playerConnections[pl], teamChangedConn)
    
    if pl.Character then
        setupDeathListener(pl)
    end
end

Players.PlayerAdded:Connect(function(pl)
    setupPlayerListeners(pl)
end)

Players.PlayerRemoving:Connect(function(pl)
    cleanplrdata(pl)
end)

for _, pl in ipairs(Players:GetPlayers()) do
    if pl ~= localPlayer then
        setupPlayerListeners(pl)
    end
end

local function lrfd()
    if config.looprfd then return end
    config.looprfd = true

    task.spawn(function()
        while config.Enabled do
            removeAllFaceDecals()
            task.wait(0.5)
        end
        config.looprfd = false
    end)
end

local function initFOV()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GravelSilentAimFOV"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

    local ringHolder = Instance.new("Frame")
    ringHolder.Name = "RingHolder"
    ringHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    ringHolder.Size = UDim2.new(0, config.fovsize * 2, 0, config.fovsize * 2)
    ringHolder.Position = UDim2.new(0.5, 0, 0.5, -28)
    ringHolder.BackgroundTransparency = 1
    ringHolder.Visible = false
    ringHolder.Parent = screenGui

    local ringCorner = Instance.new("UICorner")
    ringCorner.CornerRadius = UDim.new(1, 0)
    ringCorner.Parent = ringHolder

    local ringStroke = Instance.new("UIStroke")
    ringStroke.Thickness = 1
    ringStroke.LineJoinMode = Enum.LineJoinMode.Round
    ringStroke.Color = config.fovc
    ringStroke.Transparency = 0.3
    ringStroke.Parent = ringHolder

    gui.ScreenGui = screenGui
    gui.RingHolder = ringHolder
    gui.RingStroke = ringStroke
end

initFOV()

local function makeui()
    lib:SetTitle("Gravel.cc (Legacy - SilentAim & Visuals)")
    lib:SetIcon("http://www.roblox.com/asset/?id=132214308111067")
    lib:SetTheme("HighContrast")
    
    local T1 = lib:CreateTab("Visuals")
    local T2 = lib:CreateTab("SilentAim")

    lib:Tab("Visuals")
    lib:AddToggle("Enable ESP (Ctrl+'Z')", function(state)
        applyESPMaster(state)
        if state then
            safeNotify({
                Title = "ESP Master",
                Content = "ESP Enabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(0, 170, 255)
            })
        else
            safeNotify({
                Title = "ESP Master",
                Content = "ESP Disabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        end
    end, false)

    lib:AddToggle("Toggle Highlight ESP", function(state)
        toggleHighlightESP(state)
        if state then
            safeNotify({
                Title = "Highlight ESP",
                Content = "Enabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(0, 170, 255)
            })
        else
            safeNotify({
                Title = "Highlight ESP",
                Content = "Disabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        end
    end, false)
    
    lib:AddToggle("Toggle Text ESP", function(state)
        toggleTextESP(state)
        if state then
            safeNotify({
                Title = "Text ESP",
                Content = "Enabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(0, 170, 255)
            })
        else
            safeNotify({
                Title = "Text ESP",
                Content = "Disabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        end
    end, false)

    lib:AddToggle("Toggle Box ESP", function(state)
        toggleBoxESP(state)
        if state then
            safeNotify({
                Title = "Box ESP",
                Content = "Enabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(0, 170, 255)
            })
        else
            safeNotify({
                Title = "Box ESP",
                Content = "Disabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        end
    end, false)

    lib:AddToggle("Toggle Health ESP", function(state)
        toggleHealthESP(state)
        if state then
            safeNotify({
                Title = "Health ESP",
                Content = "Enabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(0, 170, 255)
            })
        else
            safeNotify({
                Title = "Health ESP",
                Content = "Disabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        end
    end, false)

    lib:AddToggle("Toggle Head Dot ESP", function(state)
        config.prefHeadDotESP = state
        if config.espMasterEnabled then
            for _, target in ipairs(getAllTargets()) do
                if addesp(target) then
                    if not config.espData[target] then
                        makeesp(target)
                    end
                end
            end
            updateESPColors()
        end

        if state then
            safeNotify({
                Title = "HeadDot ESP",
                Content = "Enabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(0, 200, 255)
            })
        else
            safeNotify({
                Title = "HeadDot ESP",
                Content = "Disabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        end
    end, false)

    lib:AddToggle("ESP Colour Based On Health", function(state)
        config.prefColorByHealth = state
        updateESPColors()
        if state then
            safeNotify({
                Title = "ESP Color By Health",
                Content = "Enabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(0, 200, 0)
            })
        else
            safeNotify({
                Title = "ESP Color By Health",
                Content = "Disabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(200, 0, 0)
            })
        end
    end, false)

    lib:Tab("SilentAim")
    lib:AddToggle("Toggle SilentAim (Ctrl+'E')", function(state)
        config.Enabled = state

        if not config.Enabled then
            if gui.RingHolder then
                gui.RingHolder.Visible = false
            end
            for pl, _ in pairs(config.activeApplied) do
                restorePartForPlayer(pl)
            end
            safeNotify({
                Title = "SilentAim",
                Content = "Disabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        else
            safeNotify({
                Title = "SilentAim",
                Content = "Enabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://255",
                BarColor = Color3.fromRGB(255, 100, 0)
            })
            if gui.RingHolder then
                gui.RingHolder.Visible = true
            end
            lrfd()
        end
    end, false)
    
    lib:AddToggle("WallCheck SA (B)", function(state)
        config.wallc = state
        if state then
            safeNotify({
                Title = "Wall Check",
                Content = "Enabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(0, 170, 255)
            })
        else
            safeNotify({
                Title = "Wall Check",
                Content = "Disabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        end
    end, false)

    lib:AddComboBox("Team Target", {"Enemies", "Teams", "All"}, function(selection)
        if selection == "Enemies" then
            config.targetMode = "Enemies"
        elseif selection == "Teams" then
            config.targetMode = "Teams"
        elseif selection == "All" then
            config.targetMode = "All"
        else
            config.targetMode = "Enemies"
        end
        updateTeamTargetModes()
    end)

    lib:AddComboBox("Target Part", {"Head", "HumanoidRootPart", "Both"}, function(selection)
        for pl, _ in pairs(config.activeApplied) do
            restorePartForPlayer(pl)
        end
        if selection == "Head" then
            config.bodypart = "Head"
        elseif selection == "HumanoidRootPart" then
            config.bodypart = "HumanoidRootPart"
        elseif selection == "Both" then
            config.bodypart = "Both"
        else
            config.bodypart = "Head"
        end
    end)
    
    lib:AddComboBox("GetTarget", {"Closest", "Lowest Health"}, function(selection)
        config.silentGetTarget = selection
    end)
    
    lib:AddInputBox("HitChance", function(text)
        local n = tonumber(text)
        if n and n >= 0 and n <= 100 then
            config.hitchance = n
        end
        return tostring(config.hitchance)
    end, "0-100", tostring(config.hitchance), {
        min = 0,
        max = 100,
        isNumber = true
    })
    
    lib:AddInputBox("FovSize", function(text)
        local n = tonumber(text)
        if n and n >= 1 then
            config.fovsize = n
            if gui.RingHolder then
                gui.RingHolder.Size = UDim2.new(0, math.max(8, config.fovsize * 2), 0, math.max(8, config.fovsize * 2))
            end
            return tostring(config.fovsize)
        else
            return tostring(config.fovsize)
        end
    end, "Enter Value...", tostring(config.fovsize), {
        min = 0,
        max = math.huge,
        isNumber = true
    })
end

makeui()
