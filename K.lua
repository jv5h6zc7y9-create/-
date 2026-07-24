-- Gravel.cc Legacy (Fully Fixed & Anti-Cheat Bypassed Monolithic Script)
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
    maxExpansion = 3.5,
    masterTeamTarget = "Enemies",
    masterTarget = "Players",
    masterGetTarget = "Closest",
    silentGetTarget = "Closest",
}

local Alurt = loadstring(game:HttpGet("https://raw.githubusercontent.com/azir-py/project/refs/heads/main/Zwolf/AlurtUI.lua"))()

local function safeNotify(opts)
    if typeof(Alurt) == "table" and type(Alurt.CreateNode) == "function" then
        pcall(function()
            Alurt.CreateNode(opts)
        end)
    end
end

pcall(function()
    safeNotify({
        Title = "Script started!",
        Content = "SilentAim & Visuals loaded safely (Fixed)",
        Audio = "rbxassetid://17208361335",
        Length = 3,
        Image = "rbxassetid://4483362458",
        BarColor = Color3.fromRGB(0, 170, 255)
    })
end)

local lib
do
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/hm5650/ACXUI/refs/heads/main/ACXUI"))()
    end)
    if success and result then
        lib = result
    else
        lib = {}
        function lib:SetTitle() end
        function lib:SetIcon() end
        function lib:SetBackgroundColor() end
        function lib:SetCloseBtnColor() end
        function lib:SetTitleColor() end
        function lib:SetButtonsColor() end
        function lib:SetTheme() end
        function lib:AddToggle(_, callback, default)
            if callback then pcall(callback, default) end
        end
        function lib:AddComboBox(_, _, callback)
            if callback then pcall(callback, "Enemies") end
        end
        function lib:AddInputBox(_, callback, _, default)
            if callback then pcall(callback, tostring(default)) end
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

-- Строгая проверка на тиммейта (исправлена ошибка работы ВХ/Аима по своим)
local function isTeammate(p)
    if not (localPlayer and p) then return false end
    if p == localPlayer then return true end
    
    if localPlayer.Team and p.Team then
        return localPlayer.Team == p.Team
    elseif localPlayer.TeamColor and p.TeamColor then
        return localPlayer.TeamColor == p.TeamColor
    elseif localPlayer:GetAttribute("Team") and p:GetAttribute("Team") then
        return localPlayer:GetAttribute("Team") == p:GetAttribute("Team")
    end
    
    return false
end

local function updateTeamTargetModes()
    local masterSelection = config.masterTeamTarget or config.targetMode
    if masterSelection == "All" then
        config.targetMode = "All"
    else
        config.targetMode = masterSelection
    end
    config.currentTarget = nil
end

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

local function addesp(targetPlayer)
    if not targetPlayer then return false end
    if typeof(targetPlayer) == "Instance" and targetPlayer:IsA("Player") and targetPlayer == localPlayer then return false end

    local mode = config.targetMode or "Enemies"
    if mode == "Enemies" then
        if typeof(targetPlayer) == "Instance" and targetPlayer:IsA("Player") then
            return not isTeammate(targetPlayer)
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
            return not isTeammate(targetPlayer)
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
    if not config.wallc then return true end
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
    pcall(function() highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
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
        if oldData.connection then pcall(function() oldData.connection:Disconnect() end) end
        if oldData.screenGui and oldData.screenGui.Parent then pcall(function() oldData.screenGui:Destroy() end) end
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESP_" .. getTargetName(targetPlayer)
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    
    local parent = localPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
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

    local function startUpdater()
        if config.espData[targetPlayer] and config.espData[targetPlayer].connection then
            pcall(function() config.espData[targetPlayer].connection:Disconnect() end)
        end
        
        local conn = RunService.RenderStepped:Connect(function()
            if not addesp(targetPlayer) then
                label.Visible = false
                boxFrame.Visible = false
                healthBg.Visible = false
                headDot.Visible = false
                return
            end

            local tchar = getTargetCharacter(targetPlayer)
            local charExists = tchar and tchar.Parent
            
            if not charExists then
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

            local hpColor = humanoid and healthColor(humanoid) or Color3.new(1,1,1)

            if config.espMasterEnabled and config.prefTextESP then
                local text = string.format("%s [%d]", getTargetName(targetPlayer), humanoid and math.floor(humanoid.Health) or 0)
                label.Text = text
                label.Size = UDim2.new(0, 200, 0, 18)
                label.Position = UDim2.new(0, centerX, 0, topScreenY - 4)
                label.Visible = onScreen
                label.TextColor3 = config.prefColorByHealth and hpColor or ((targetPlayer == config.currentTarget) and config.esptargetc or config.espc)
            else
                label.Visible = false
            end

            if config.espMasterEnabled and config.prefBoxESP then
                boxFrame.Size = UDim2.new(0, widthPx, 0, math.max(2, heightPx))
                boxFrame.Position = UDim2.new(0, centerX - widthPx / 2, 0, topScreenY)
                boxFrame.Visible = onScreen
                boxFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                boxFrame.BackgroundTransparency = 0.7
                boxOutline.Color = config.prefColorByHealth and hpColor or ((targetPlayer == config.currentTarget) and config.esptargetc or config.espc)
            else
                boxFrame.Visible = false
            end

            if config.espMasterEnabled and config.prefHealthESP and humanoid then
                healthBg.Size = UDim2.new(0, 4, 0, math.max(2, heightPx))
                healthBg.Position = UDim2.new(0, centerX + widthPx / 2 + 4, 0, topScreenY)
                healthBg.Visible = onScreen
                healthFill.Size = UDim2.new(1, 0, hpRatio, 0)
                healthFill.BackgroundColor3 = healthColor(humanoid)
            else
                healthBg.Visible = false
            end

            if config.espMasterEnabled and config.prefHeadDotESP and head then
                local headV3, onHead = camera:WorldToViewportPoint(head.Position)
                if onHead and headV3.Z > 0 then
                    headDot.Position = UDim2.new(0, headV3.X, 0, headV3.Y)
                    headDot.Visible = true
                    headDot.BackgroundColor3 = config.prefColorByHealth and hpColor or ((targetPlayer == config.currentTarget) and config.esptargetc or config.espc)
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

    startUpdater()
end

local function updateESPColors()
    for targetPlayer, data in pairs(config.espData) do
        if not targetPlayer or not data or not addesp(targetPlayer) then
            removeESPLabel(targetPlayer)
        end
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
            if addesp(target) and not config.espData[target] then
                makeesp(target)
            end
        end
    end
end

local function toggleHealthESP(enabled)
    config.prefHealthESP = enabled
    if config.espMasterEnabled then
        for _, target in ipairs(getAllTargets()) do
            if addesp(target) and not config.espData[target] then
                makeesp(target)
            end
        end
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
    else
        for _, target in ipairs(getAllTargets()) do
            if addesp(target) then
                makeesp(target)
                if config.prefHighlightESP and target.Character then
                    high(target)
                end
            end
        end
    end
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
        local primary = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        return primary, primary and primary.Name or "Head"
    else
        local found = char:FindFirstChild(bp) or char:FindFirstChild("Head")
        return found, found and found.Name or "Head"
    end
end

local function saveOriginalPartInfo(targetPlayer, part)
    if not targetPlayer or not part then return end
    if not config.originalSizes[targetPlayer] then
        config.originalSizes[targetPlayer] = {
            partName = part.Name or "Head",
            size = part.Size,
        }
    end
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

    local part = char and char:FindFirstChild(original.partName)
    if part and original.size then
        pcall(function()
            part.Size = original.size
            part.Transparency = 1
            part.CanCollide = false
            part.Massless = false
        end)
    end

    config.activeApplied[targetPlayer] = nil
    config.originalSizes[targetPlayer] = nil
    config.targethbSizes[targetPlayer] = nil
end

local function applySizeToPart(targetPlayer, targetDiameter, chosenPart)
    if not addesp(targetPlayer) then return end
    local char = getTargetCharacter(targetPlayer)
    if not char or targetPlayer == localPlayer then return end
    if not plralive(targetPlayer) then return end

    local part = chosenPart or select(1, chooseBodyPartInstance(targetPlayer))
    if not part then return end

    if not config.originalSizes[targetPlayer] then
        saveOriginalPartInfo(targetPlayer, part)
    end

    targetDiameter = math.clamp(targetDiameter, 0.1, config.maxExpansion)

    local expansionSize = Vector3.new(targetDiameter, targetDiameter, targetDiameter)
    config.targethbSizes[targetPlayer] = expansionSize
    config.activeApplied[targetPlayer] = true
end

local function hb()
    for playerObj, targetSize in pairs(config.targethbSizes) do
        if playerObj and playerObj ~= localPlayer and addesp(playerObj) and plralive(playerObj) then
            local original = config.originalSizes[playerObj]
            local char = getTargetCharacter(playerObj)
            local part = char and char:FindFirstChild(original and original.partName or config.bodypart)
            
            if part then
                pcall(function()
                    part.Size = targetSize
                    part.Transparency = 1
                    part.CanCollide = false
                    part.Massless = true
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

    if not gui.RingHolder then return end

    if not config.Enabled then
        gui.RingHolder.Visible = false
        return
    else
        gui.RingHolder.Visible = true
    end

    local viewportSize = camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local radiusPx = config.fovsize

    local candidates = {}

    for _, pl in ipairs(getAllTargets()) do
        if addesp(pl) then
            local bodyPart, chosenName = chooseBodyPartInstance(pl)
            local char = getTargetCharacter(pl)
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            if bodyPart and humanoid and humanoid.Health > 0 then
                local topPos = bodyPart.Position
                local screenPos3, onScreen = camera:WorldToViewportPoint(topPos)
                if onScreen then
                    local screenVec = Vector2.new(screenPos3.X, screenPos3.Y)
                    local distPx = (screenVec - center).Magnitude
                    if distPx <= radiusPx then
                        if wallCheck(bodyPart.Position, camera.CFrame.Position) then
                            table.insert(candidates, {
                                player = pl,
                                part = bodyPart,
                                screenDist = distPx,
                                worldDist = (camera.CFrame.Position - bodyPart.Position).Magnitude,
                                screenPos = screenVec,
                                humanoid = humanoid
                            })
                        end
                    end
                end
            end
        end
    end

    local best = nil
    if #candidates > 0 then
        table.sort(candidates, function(a, b)
            return a.screenDist < b.screenDist
        end)
        best = candidates[1]
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
        if not best or pl ~= best.player or not plralive(pl) or not addesp(pl) then
            restorePartForPlayer(pl)
        end
    end

    if best and plralive(best.player) and addesp(best.player) then
        local diameter = 2.5
        applySizeToPart(best.player, diameter, best.part)
        if config.rfd then
            RFD(best.player)
        end
    end
end

RunService.RenderStepped:Connect(onRenderStep)

local function setupPlayerListeners(pl)
    if pl == localPlayer then return end
    
    local function updatePlrESP()
        if config.espMasterEnabled and addesp(pl) then
            removeESPLabel(pl)
            makeesp(pl)
        else
            removeESPLabel(pl)
            removeHighlightESP(pl)
        end
    end

    pl:GetPropertyChangedSignal("Team"):Connect(function()
        updatePlrESP()
        if not addesp(pl) then
            restorePartForPlayer(pl)
            removeESPLabel(pl)
            removeHighlightESP(pl)
        end
    end)
end

for _, pl in ipairs(Players:GetPlayers()) do
    setupPlayerListeners(pl)
end

Players.PlayerAdded:Connect(function(pl)
    setupPlayerListeners(pl)
end)

Players.PlayerRemoving:Connect(function(pl)
    restorePartForPlayer(pl)
    removeESPLabel(pl)
    removeHighlightESP(pl)
end)

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
    lib:SetTitle("Gravel.cc (Fixed TeamCheck & AntiCheat)")
    lib:SetIcon("http://www.roblox.com/asset/?id=132214308111067")
    lib:SetTheme("HighContrast")
    
    lib:CreateTab("Visuals")
    lib:CreateTab("SilentAim")

    lib:Tab("Visuals")
    lib:AddToggle("Enable ESP", function(state)
        applyESPMaster(state)
    end, false)

    lib:AddToggle("Toggle Highlight ESP", function(state)
        toggleHighlightESP(state)
    end, false)
    
    lib:AddToggle("Toggle Text ESP", function(state)
        toggleTextESP(state)
    end, false)

    lib:AddToggle("Toggle Box ESP", function(state)
        toggleBoxESP(state)
    end, false)

    lib:AddToggle("Toggle Health ESP", function(state)
        toggleHealthESP(state)
    end, false)

    lib:AddToggle("ESP Colour Based On Health", function(state)
        config.prefColorByHealth = state
        updateESPColors()
    end, false)

    lib:Tab("SilentAim")
    lib:AddToggle("Toggle SilentAim", function(state)
        config.Enabled = state
        if not config.Enabled then
            if gui.RingHolder then gui.RingHolder.Visible = false end
            for pl, _ in pairs(config.activeApplied) do
                restorePartForPlayer(pl)
            end
        else
            if gui.RingHolder then gui.RingHolder.Visible = true end
        end
    end, false)
    
    lib:AddToggle("WallCheck SA", function(state)
        config.wallc = state
    end, false)

    lib:AddComboBox("Team Target", {"Enemies", "Teams", "All"}, function(selection)
        config.targetMode = selection
        updateTeamTargetModes()
        updateESPColors()
    end)

    lib:AddComboBox("Target Part", {"Head", "HumanoidRootPart", "Both"}, function(selection)
        for pl, _ in pairs(config.activeApplied) do
            restorePartForPlayer(pl)
        end
        config.bodypart = selection
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
    end, "0-100", tostring(config.hitchance), {min = 0, max = 100, isNumber = true})
    
    lib:AddInputBox("FovSize", function(text)
        local n = tonumber(text)
        if n and n >= 1 then
            config.fovsize = n
            if gui.RingHolder then
                gui.RingHolder.Size = UDim2.new(0, config.fovsize * 2, 0, config.fovsize * 2)
            end
        end
        return tostring(config.fovsize)
    end, "Enter Value...", tostring(config.fovsize), {min = 0, max = math.huge, isNumber = true})
end

makeui()
