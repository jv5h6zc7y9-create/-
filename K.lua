-- Gravel.cc Legacy (Fixed & Optimized)
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
    hotkeyConnection = nil,
    maxExpansion = math.huge,
    aimbotEnabled = false,
    aimbotFOVSize = 100,
    aimbotStrength = 0.5,
    aimbotWallCheck = false,
    aimbotTargetPart = "Head",
    aimbotTeamTarget = "Enemies",
    aimbotCurrentTarget = nil,
    aimbotFOVRing = nil,
    hitboxEnabled = false,
    hitboxSize = 10,
    hitboxTeamTarget = "Enemies",
    hitboxExpandedParts = {},
    hitboxOriginalSizes = {},
    hitboxLastSize = {},
    antiAimEnabled = false,
    raycastAntiAim = false,
    antiAimTPDistance = 3,
    antiAimAbovePlayer = false,
    antiAimAboveHeight = 10,
    antiAimBehindPlayer = false,
    antiAimBehindDistance = 5,
    originalPosition = nil,
    isTeleported = false,
    currentAntiAimTarget = nil,
    antiAimOrbitEnabled = false,
    antiAimOrbitSpeed = 5,
    antiAimOrbitRadius = 5,
    antiAimOrbitHeight = 0,
    masterTeamTarget = "Enemies",
    autoFarmEnabled = false,
    autoFarmDistance = 10,
    autoFarmSpeed = 1,
    autoFarmTargets = {},
    currentAutoFarmTarget = nil,
    autoFarmLoop = nil,
    autoFarmIndex = 1,
    autoFarmCompleted = {},
    autoFarmTargetPart = "Head",
    autoFarmAlignToCrosshair = true,
    autoFarmVerticalOffset = 0,
    autoFarmOriginalPositions = {}, 
    aimbot360Enabled = false,
    aimbot360OriginalFOV = 100,
    gp = 200,
    aimbot360Omnidirectional = true,
    aimbot360BehindRange = 180,
    masterTarget = "Players",
    clientMasterEnabled = false,
    clientWalkSpeed = 16,
    clientJumpPower = 50,
    clientNoclip = false,
    clientCFrameWalkEnabled = false,
    clientCFrameSpeed = 1,
    clientConnections = {},
    clientOriginals = {},
    _tpwalking = false,
    clientWalkEnabled = false,
    clientJumpEnabled = false,
    clientNoclipEnabled = false,
    clientCFrameWalkToggle = false,
    masterGetTarget = "Closest",
    aimbotGetTarget = "Closest",
    silentGetTarget = "Closest",
    antiAimGetTarget = "Closest",
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
            Content = "May be unstable/dont work on some games",
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

local function isTeammate(p)
    if not (localPlayer and p) then return false end
    if typeof(p) == "Instance" and p:IsA("Player") then
        if p == localPlayer then return true end
        if localPlayer.Team and p.Team then
            if localPlayer.Team == p.Team then
                return true
            end
        end
        local localTeamAttr = localPlayer:GetAttribute("Team")
        local targetTeamAttr = p:GetAttribute("Team")
        if localTeamAttr and targetTeamAttr then
            if localTeamAttr == targetTeamAttr then
                return true
            end
        end
        local localSideAttr = localPlayer:GetAttribute("Side")
        local targetSideAttr = p:GetAttribute("Side")
        if localSideAttr and targetSideAttr then
            if localSideAttr == targetSideAttr then
                return true
            end
        end
        local teamValueObj = p:FindFirstChild("Team")
        local localTeamValueObj = localPlayer:FindFirstChild("Team")
        if teamValueObj and localTeamValueObj then
            if teamValueObj.Value == localTeamValueObj.Value then
                return true
            end
        end
        if localPlayer.TeamColor and p.TeamColor then
            if localPlayer.TeamColor == p.TeamColor and localPlayer.TeamColor ~= Color3.fromRGB(255, 255, 255) then
                return true
            end
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

local function updateTeamTargetModes()
    local masterSelection = config.masterTeamTarget or config.targetMode
    
    if masterSelection == "All" then
        config.targetMode = "All"
        config.aimbotTeamTarget = "All"
        config.hitboxTeamTarget = "All"
    else
        config.targetMode = masterSelection
        config.aimbotTeamTarget = masterSelection
        config.hitboxTeamTarget = masterSelection
    end
    
    if config.masterGetTarget then
        config.aimbotGetTarget = config.masterGetTarget
        config.silentGetTarget = config.masterGetTarget
        config.antiAimGetTarget = config.masterGetTarget
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
    applyhb()
    config.aimbotCurrentTarget = nil
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
            if pl ~= localPlayer and not isTeammate(pl) then
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

local function plralive(target)
    if not target then return false end

    if typeof(target) == "Instance" and target:IsA("Player") then
        if isTeammate(target) then return false end
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

local function saveTargetOriginalPosition(target)
    local targetChar = getTargetCharacter(target)
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    config.autoFarmOriginalPositions[target] = {
        position = targetRoot.Position,
        cframe = targetRoot.CFrame,
        timestamp = tick()
    }
end

local function restoreTargetOriginalPosition(target)
    local targetChar = getTargetCharacter(target)
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    local savedData = config.autoFarmOriginalPositions[target]
    if savedData then
        pcall(function()
            targetRoot.CFrame = savedData.cframe
        end)
        config.autoFarmOriginalPositions[target] = nil
    end
end

local function getValidAutoFarmTargets()
    local validTargets = {}
    
    local candidates = getAllTargets()
    for _, t in ipairs(candidates) do
        if t ~= localPlayer and plralive(t) and not isTeammate(t) then
            local shouldTarget = false
            if config.masterTarget == "NPCs" then
                if typeof(t) == "Instance" and t:IsA("Model") then
                    shouldTarget = true
                else
                    shouldTarget = false
                end
            elseif config.masterTarget == "Players" then
                if typeof(t) == "Instance" and t:IsA("Player") then
                    if not isTeammate(t) or config.masterTeamTarget == "All" then
                        shouldTarget = true
                    else
                        shouldTarget = false
                    end
                else
                    shouldTarget = false
                end
            elseif config.masterTarget == "Both" then
                shouldTarget = true
            end

            if shouldTarget then
                local humanoid = nil
                local char = getTargetCharacter(t)
                if char then
                    humanoid = char:FindFirstChildOfClass("Humanoid")
                end
                if humanoid and humanoid.Health > 0 then
                    if not config.autoFarmCompleted[t] then
                        table.insert(validTargets, t)
                    end
                end
            end
        end
    end

    table.sort(validTargets, function(a, b)
        local charA = getTargetCharacter(a)
        local charB = getTargetCharacter(b)
        local rootA = charA and (charA:FindFirstChild("HumanoidRootPart") or charA:FindFirstChild("Head"))
        local rootB = charB and (charB:FindFirstChild("HumanoidRootPart") or charB:FindFirstChild("Head"))
        local localRoot = localPlayer.Character and (localPlayer.Character:FindFirstChild("HumanoidRootPart") or localPlayer.Character:FindFirstChild("Head"))
        
        if not localRoot then return false end
        if not rootA then return false end
        if not rootB then return true end
        
        local distA = (localRoot.Position - rootA.Position).Magnitude
        local distB = (localRoot.Position - rootB.Position).Magnitude
        
        return distA < distB
    end)
    
    return validTargets
end

local function tptocross(target)
    local targetChar = getTargetCharacter(target)
    if not targetChar or not localPlayer.Character or not camera then 
        return false 
    end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHead = targetChar:FindFirstChild("Head")
    if not targetRoot then return false end
    local targetPart = nil
    if config.autoFarmTargetPart == "Head" and targetHead then
        targetPart = targetHead
    else
        targetPart = targetRoot
    end
    
    if not targetPart then return false end
    local cameraPos = camera.CFrame.Position
    local cameraLook = camera.CFrame.LookVector
    local crosshairWorldPos = cameraPos + (cameraLook * config.autoFarmDistance)
    crosshairWorldPos = crosshairWorldPos + Vector3.new(0, config.autoFarmVerticalOffset, 0)
    local partOffset = targetPart.Position - targetRoot.Position
    local newRootPosition = crosshairWorldPos - partOffset
    pcall(function()
        targetRoot.CFrame = CFrame.new(newRootPosition)
        local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:MoveTo(cameraPos)
        end
    end)
    
    return true
end

local function tptocrossExact(target)
    local targetChar = getTargetCharacter(target)
    if not targetChar or not localPlayer.Character or not camera then 
        return false 
    end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHead = targetChar:FindFirstChild("Head")
    if not targetRoot then return false end
    
    local targetPart = nil
    if config.autoFarmTargetPart == "Head" and targetHead then
        targetPart = targetHead
    else
        targetPart = targetRoot
    end
    
    if not targetPart then return false end
    
    local viewportSize = camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local ray = camera:ScreenPointToRay(screenCenter.X, screenCenter.Y)
    local crosshairWorldPos = ray.Origin + (ray.Direction * config.autoFarmDistance)
    crosshairWorldPos = crosshairWorldPos + Vector3.new(0, config.autoFarmVerticalOffset, 0)
    local partOffset = targetPart.Position - targetRoot.Position
    local newRootPosition = crosshairWorldPos - partOffset
    pcall(function()
        targetRoot.CFrame = CFrame.new(newRootPosition)
        
        local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local lookAt = CFrame.new(targetRoot.Position, camera.CFrame.Position)
            targetRoot.CFrame = lookAt
        end
    end)
    
    return true
end
local function tptocrossWithAlignment(target)
    local targetChar = getTargetCharacter(target)
    if not targetChar or not localPlayer.Character or not camera then 
        return false 
    end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHead = targetChar:FindFirstChild("Head")
    if not targetRoot then return false end
    
    if not config.autoFarmOriginalPositions[target] then
        saveTargetOriginalPosition(target)
    end

    local cameraCFrame = camera.CFrame
    local forward = cameraCFrame.LookVector
    local cameraPos = cameraCFrame.Position
    local targetPos = cameraPos + (forward * config.autoFarmDistance)
    targetPos = targetPos + Vector3.new(0, config.autoFarmVerticalOffset, 0)
    local alignPart = nil
    if config.autoFarmTargetPart == "Head" and targetHead then
        alignPart = targetHead
    else
        alignPart = targetRoot
    end
    
    if not alignPart then return false end
    local offsetFromRoot = alignPart.Position - targetRoot.Position
    local newRootPos = targetPos - offsetFromRoot

    pcall(function()
        local directionToCamera = (cameraPos - newRootPos).Unit
        local lookAt = CFrame.new(newRootPos, newRootPos + directionToCamera)
        targetRoot.CFrame = lookAt
    end)
    
    return true
end

local function checkTargetHealth(target)
    if not target then return false end
    local char = getTargetCharacter(target)
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    return humanoid.Health > 0
end

local function autoFarmProcess()
    if config.autoFarmLoop then
        config.autoFarmLoop:Disconnect()
        config.autoFarmLoop = nil
    end
    
    config.autoFarmLoop = RunService.Heartbeat:Connect(function()
        if not config.autoFarmEnabled or not localPlayer.Character or not camera then
            if config.autoFarmLoop then
                config.autoFarmLoop:Disconnect()
                config.autoFarmLoop = nil
            end
            return
        end

        local validTargets = getValidAutoFarmTargets()
        if #validTargets == 0 then
            config.currentAutoFarmTarget = nil
            config.autoFarmIndex = 1
            config.autoFarmCompleted = {}
            return
        end
        
        if not config.currentAutoFarmTarget or config.autoFarmCompleted[config.currentAutoFarmTarget] then
            for i = config.autoFarmIndex, #validTargets do
                local target = validTargets[i]
                if not config.autoFarmCompleted[target] then
                    config.currentAutoFarmTarget = target
                    config.autoFarmIndex = i
                    break
                end
            end
            
            if not config.currentAutoFarmTarget then
                config.autoFarmIndex = 1
                config.currentAutoFarmTarget = validTargets[1]
            end
        end
        
        if config.currentAutoFarmTarget and getTargetCharacter(config.currentAutoFarmTarget) then
            if not checkTargetHealth(config.currentAutoFarmTarget) then
                restoreTargetOriginalPosition(config.currentAutoFarmTarget)
                config.autoFarmCompleted[config.currentAutoFarmTarget] = true
                config.currentAutoFarmTarget = nil
                return
            end
            
            if not config.autoFarmOriginalPositions[config.currentAutoFarmTarget] then
                saveTargetOriginalPosition(config.currentAutoFarmTarget)
            end

            local success = tptocrossWithAlignment(config.currentAutoFarmTarget)
            if not success then
                teleportTargetToLocalPlayerFront(config.currentAutoFarmTarget)
            end
        end
    end)
end

local function stopAutoFarm()
    if config.autoFarmLoop then
        config.autoFarmLoop:Disconnect()
        config.autoFarmLoop = nil
    end
    
    for target, _ in pairs(config.autoFarmOriginalPositions) do
        if target and getTargetCharacter(target) then
            restoreTargetOriginalPosition(target)
        end
    end
    
    config.currentAutoFarmTarget = nil
    config.autoFarmIndex = 1
    config.autoFarmCompleted = {}
    config.autoFarmOriginalPositions = {}
    config.autoFarmEnabled = false
end

local function teleportTargetToLocalPlayerFront(target)
    local targetChar = getTargetCharacter(target)
    if not targetChar or not localPlayer.Character then 
        return false 
    end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not localRoot then return false end
    
    local localCFrame = localRoot.CFrame
    local frontOffset = localCFrame.LookVector * config.autoFarmDistance
    local frontPos = localRoot.Position + frontOffset
    frontPos = Vector3.new(frontPos.X, targetRoot.Position.Y, frontPos.Z)
    
    pcall(function()
        targetRoot.CFrame = CFrame.new(frontPos, localRoot.Position)
    end)
    
    return true
end

local function raycastFromPlayer(player)
    if not player or not player.Character then return false end
    local character = player.Character
    local head = character:FindFirstChild("Head")
    if not head then return false end
    
    local lookVector = head.CFrame.LookVector
    local rayOrigin = head.Position
    local rayDirection = lookVector * 1000
    local ray = Ray.new(rayOrigin, rayDirection)
    
    local ignoreList = {character}
    
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    if hit then
        local hitParent = hit.Parent
        if hitParent and hitParent:IsA("Model") then
            local hitPlayer = Players:GetPlayerFromCharacter(hitParent)
            if hitPlayer == localPlayer then
                return true, position, lookVector
            end
        end
    end
    
    return false, nil, nil
end

local function teleportLocalPlayer(direction, distance)
    if not localPlayer.Character then return end
    local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local currentPos = humanoidRootPart.Position
    local newPos = currentPos + (direction * distance)
    
    if not config.originalPosition then
        config.originalPosition = currentPos
    end
    
    pcall(function()
        humanoidRootPart.CFrame = CFrame.new(newPos)
    end)
    
    config.isTeleported = true
end

local function returnToOriginalPosition()
    if not config.originalPosition or not localPlayer.Character then return end
    local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    pcall(function()
        humanoidRootPart.CFrame = CFrame.new(config.originalPosition)
    end)
    
    config.originalPosition = nil
    config.isTeleported = false
    config.currentAntiAimTarget = nil
end

local function teleportAboveTarget(target)
    local targetChar = getTargetCharacter(target)
    if not targetChar or not localPlayer.Character then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not localRoot then return end
    
    local targetPos = targetRoot.Position
    local abovePos = targetPos + Vector3.new(0, config.antiAimAboveHeight, 0)
    
    if not config.originalPosition then
        config.originalPosition = localRoot.Position
    end
    
    pcall(function()
        localRoot.CFrame = CFrame.new(abovePos)
    end)
    
    config.currentAntiAimTarget = target
    config.isTeleported = true
end

local function teleportBehindTarget(target)
    local targetChar = getTargetCharacter(target)
    if not targetChar or not localPlayer.Character then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not localRoot then return end
    
    local targetCFrame = targetRoot.CFrame
    local behindOffset = -targetCFrame.LookVector * config.antiAimBehindDistance
    local behindPos = targetRoot.Position + behindOffset
    
    if not config.originalPosition then
        config.originalPosition = localRoot.Position
    end
    
    pcall(function()
        localRoot.CFrame = CFrame.new(behindPos)
    end)
    
    config.currentAntiAimTarget = target
    config.isTeleported = true
end

local function findClosestEnemy()
    if not localPlayer.Character then return nil end
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    local best = nil
    local bestMetric = nil
    local mode = config.antiAimGetTarget or config.masterGetTarget or "Closest"

    for _, t in ipairs(getAllTargets()) do
        if t ~= localPlayer and plralive(t) and not isTeammate(t) then
            local shouldTarget = false
            if config.masterTarget == "NPCs" then
                if typeof(t) == "Instance" and t:IsA("Model") then
                    shouldTarget = true
                end
            elseif config.masterTarget == "Players" then
                if typeof(t) == "Instance" and t:IsA("Player") then
                    if config.targetMode == "Enemies" then
                        shouldTarget = not isTeammate(t)
                    elseif config.targetMode == "Teams" then
                        shouldTarget = isTeammate(t)
                    elseif config.targetMode == "All" then
                        shouldTarget = true
                    end
                end
            elseif config.masterTarget == "Both" then
                if typeof(t) == "Instance" and t:IsA("Player") then
                    if config.targetMode == "Enemies" then
                        shouldTarget = not isTeammate(t)
                    elseif config.targetMode == "Teams" then
                        shouldTarget = isTeammate(t)
                    elseif config.targetMode == "All" then
                        shouldTarget = true
                    end
                else
                    shouldTarget = true
                end
            end
            
            if shouldTarget then
                local tgtChar = getTargetCharacter(t)
                local playerRoot = tgtChar and (tgtChar:FindFirstChild("HumanoidRootPart") or tgtChar:FindFirstChild("Head"))
                local humanoid = tgtChar and tgtChar:FindFirstChildOfClass("Humanoid")
                if playerRoot then
                    local distance = (localRoot.Position - playerRoot.Position).Magnitude
                    if mode == "Closest" then
                        if best == nil or distance < bestMetric then
                            bestMetric = distance
                            best = t
                        end
                    else
                        local healthVal = 1e6
                        if humanoid then
                            healthVal = humanoid.Health
                        end
                        if best == nil or healthVal < bestMetric then
                            bestMetric = healthVal
                            best = t
                        end
                    end
                end
            end
        end
    end
    
    return best
end

local function antiAimUpdate()
    if not config.antiAimEnabled then
        if config.isTeleported then
            returnToOriginalPosition()
        end
        return
    end
    
    if config.antiAimOrbitEnabled then
        local closestEnemy = findClosestEnemy()
        if closestEnemy and getTargetCharacter(closestEnemy) then
            local targetChar = getTargetCharacter(closestEnemy)
            local targetPart = targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")
            if targetPart and localPlayer.Character then
                config.currentAntiAimTarget = closestEnemy
                if not config.originalPosition then
                    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if localRoot then
                        config.originalPosition = localRoot.Position
                    end
                end
                local tpos = targetPart.Position
                local angle = tick() * (config.antiAimOrbitSpeed or 8)
                local radius = config.antiAimOrbitRadius or 5
                local height = config.antiAimOrbitHeight or 0
                local offset = Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius)
                local newPos = tpos + offset
                pcall(function()
                    local localRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if localRoot then
                        localRoot.CFrame = CFrame.new(newPos, tpos)
                    end
                    if camera and targetPart then
                        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPart.Position)
                    end
                end)
                config.isTeleported = true
            end
        else
            if config.isTeleported then
                returnToOriginalPosition()
            end
            config.currentAntiAimTarget = nil
        end
        return
    end

    if config.antiAimAbovePlayer then
        local closestEnemy = findClosestEnemy()
        if closestEnemy then
            teleportAboveTarget(closestEnemy)
        end
        return
    end
    
    if config.antiAimBehindPlayer then
        local closestEnemy = findClosestEnemy()
        if closestEnemy then
            teleportBehindTarget(closestEnemy)
        end
        return
    end
    if config.autoFarmEnabled then
        if config.isTeleported then
            returnToOriginalPosition()
        end
        return
    end
    
    if not config.antiAimEnabled then
        if config.isTeleported then
            returnToOriginalPosition()
        end
        return
    end
    if config.raycastAntiAim then
        local wasTargeted = false
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and plralive(player) and not isTeammate(player) then
                local isLooking, hitPosition, lookVector = raycastFromPlayer(player)
                if isLooking then
                    wasTargeted = true
                    config.currentAntiAimTarget = player
                    
                    local teleportDirection = Vector3.new(-lookVector.Z, 0, lookVector.X)
                    
                    if math.random(1, 2) == 1 then
                        teleportDirection = -teleportDirection
                    end
                    
                    teleportLocalPlayer(teleportDirection.Unit, config.antiAimTPDistance)
                    break
                end
            end
        end
        
        if not wasTargeted and config.isTeleported then
            returnToOriginalPosition()
        end
    end
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
    if not addesp(targetPlayer) or isTeammate(targetPlayer) then return end

    if config.highlightData[targetPlayer] then
        local existing = config.highlightData[targetPlayer]
        if existing and existing.Parent then
            if targetPlayer == config.currentTarget or targetPlayer == config.aimbotCurrentTarget then
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
    highlight.Parent = character

    if targetPlayer == config.currentTarget or targetPlayer == config.aimbotCurrentTarget then
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
    if not addesp(targetPlayer) or isTeammate(targetPlayer) then return end
    
    if config.espData[targetPlayer] then
        local oldData = config.espData[targetPlayer]
        if oldData.connection then
            pcall(function() oldData.connection:Disconnect() end)
        end
        if oldData.screenGui and oldData.screenGui.Parent then
            pcall(function() oldData.screenGui:Destroy() end)
        end
    end

    local parent = localPlayer:FindFirstChild("PlayerGui")
    if not parent then
        parent = game:GetService("CoreGui")
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESP_" .. getTargetName(targetPlayer)
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
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
    if targetPlayer == config.currentTarget or targetPlayer == config.aimbotCurrentTarget then
        label.TextColor3 = config.esptargetc
    end
    
    local function startUpdater()
        if config.espData[targetPlayer] and config.espData[targetPlayer].connection then
            pcall(function() config.espData[targetPlayer].connection:Disconnect() end)
        end
        
        local conn = RunService.RenderStepped:Connect(function()
            if isTeammate(targetPlayer) then
                if label then label.Visible = false end
                if boxFrame then boxFrame.Visible = false end
                if healthBg then healthBg.Visible = false end
                if headDot then headDot.Visible = false end
                return
            end

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
                    label.TextColor3 = ((targetPlayer == config.currentTarget) or (targetPlayer == config.aimbotCurrentTarget)) and config.esptargetc or config.espc
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
                    boxOutline.Color = ((targetPlayer == config.currentTarget) or (targetPlayer == config.aimbotCurrentTarget)) and config.esptargetc or config.espc
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
                        headDot.BackgroundColor3 = ((targetPlayer == config.currentTarget) or (targetPlayer == config.aimbotCurrentTarget)) and config.esptargetc or config.espc
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
        if (not targetPlayer) or (not data) or (not data.label) or isTeammate(targetPlayer) then
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
                            data.label.TextColor3 = ((targetPlayer == config.currentTarget) or (targetPlayer == config.aimbotCurrentTarget)) and config.esptargetc or config.espc
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
                            data.boxOutline.Color = hpColor or ((targetPlayer == config.currentTarget or targetPlayer == config.aimbotCurrentTarget) and config.esptargetc or config.espc)
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
                            data.headDot.BackgroundColor3 = ((targetPlayer == config.currentTarget or targetPlayer == config.aimbotCurrentTarget) and config.esptargetc or config.espc)
                        end
                    else
                        data.headDot.Visible = false
                    end
                end
            end
        end
    end

    for _, targetPlayer in ipairs(toRemove) do
        removeESPLabel(targetPlayer)
    end

    local toRemoveHighlights = {}
    for targetPlayer, highlight in pairs(config.highlightData) do
        if not targetPlayer or not highlight or not highlight.Parent or isTeammate(targetPlayer) then
            toRemoveHighlights[#toRemoveHighlights+1] = targetPlayer
        else
            if not addesp(targetPlayer) then
                toRemoveHighlights[#toRemoveHighlights+1] = targetPlayer
            else
                if targetPlayer == config.currentTarget or targetPlayer == config.aimbotCurrentTarget then
                    highlight.FillColor = config.esptargetc
                else
                    highlight.FillColor = config.espc
                end
            end
        end
    end

    for _, targetPlayer in ipairs(toRemoveHighlights) do
        removeHighlightESP(targetPlayer)
    end
end

local function toggleHighlightESP(enabled)
    config.prefHighlightESP = enabled
    config.highlightesp = enabled and config.espMasterEnabled or false

    if config.espMasterEnabled and enabled then
        for _, target in ipairs(getAllTargets()) do
            if addesp(target) and not isTeammate(target) and target.Character then
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
            if addesp(target) and not isTeammate(target) then
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
            if addesp(target) and not isTeammate(target) then
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
            if addesp(target) and not isTeammate(target) then
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
                if addesp(target) and not isTeammate(target) and target.Character then
                    high(target)
                end
            end
        end
        if config.prefTextESP or config.prefBoxESP or config.prefHealthESP or config.prefHeadDotESP then
            for _, target in ipairs(getAllTargets()) do
                if addesp(target) and not isTeammate(target) then
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
        if not isTeammate(target) then
            RFD(target)
        end
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

    return char:FindFirstChild("Head"), "Head"
end

local function applySizeToPart(targetPlayer, targetDiameter, chosenPart)
    local char = getTargetCharacter(targetPlayer)
    if not char or targetPlayer == localPlayer or isTeammate(targetPlayer) then return end
    if not plralive(targetPlayer) then return end

    local part = chosenPart or char:FindFirstChild("Head")
    if not part then return end

    if not config.originalSizes[targetPlayer] then
        saveOriginalPartInfo(targetPlayer, part)
    end

    config.targethbSizes[targetPlayer] = Vector3.new(0.01, 0.01, 0.01)
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
        part = char:FindFirstChild(original.partName) or char:FindFirstChild("Head")
    end

    if part and original.size then
        pcall(function()
            part.Size = original.size
            part.Transparency = 0
            part.CanCollide = true
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

local function tnormalsize(targetPlayer)
    local char = getTargetCharacter(targetPlayer)
    if not char then return end  

    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")

    if torso and not config.hitboxOriginalSizes[targetPlayer] then
        config.hitboxOriginalSizes[targetPlayer] = {
            part = torso,
            size = torso.Size
        }
    end
end

local function expandhb(targetPlayer, size)
    if not targetPlayer or isTeammate(targetPlayer) then return end
    if targetPlayer == localPlayer then return end
    if not plralive(targetPlayer) then return end  

    local char = getTargetCharacter(targetPlayer)
    if not char then return end
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")  
    if not torso then return end  

    tnormalsize(targetPlayer)
    local expansionSize = Vector3.new(size, size, size)
    config.hitboxLastSize[targetPlayer] = size

    config.hitboxExpandedParts[targetPlayer] = {
        part = torso,
        targetSize = expansionSize
    }
    
    if config.hitboxEnabled then
        pcall(function()
            torso.Size = expansionSize
            torso.Transparency = 0.9
            torso.CanCollide = false
            torso.Massless = true
        end)
    end
end

local function restoreTorso(targetPlayer)
    if not targetPlayer then return end  

    local original = config.hitboxOriginalSizes[targetPlayer]
    if original and original.part and original.part.Parent then
        pcall(function()
            original.part.Size = original.size
            original.part.Transparency = 0
            original.part.CanCollide = true
        end)
    end

    config.hitboxExpandedParts[targetPlayer] = nil
    config.hitboxOriginalSizes[targetPlayer] = nil
end

local function updateHitboxes()
    if not config.hitboxEnabled then  
        for player, _ in pairs(config.hitboxExpandedParts) do  
            restoreTorso(player)  
        end  
        return  
    end

    for player, data in pairs(config.hitboxExpandedParts) do
        if not player or not plralive(player) or not getTargetCharacter(player) or isTeammate(player) then
            restoreTorso(player)
        else
            local torso = getTargetCharacter(player):FindFirstChild("Torso") or getTargetCharacter(player):FindFirstChild("UpperTorso")
            if torso and data.targetSize then
                pcall(function()
                    torso.Size = data.targetSize
                    torso.Transparency = 0.9
                    torso.CanCollide = false
                    torso.Massless = true
                end)
            end
        end
    end
end

local function targethb(player)
    if not player or player == localPlayer or isTeammate(player) then return false end  
    if not plralive(player) then return false end  

    local mode = config.hitboxTeamTarget or "Enemies"
    if typeof(player) == "Instance" and player:IsA("Model") then
        return true
    end

    if mode == "Enemies" then
        return not isTeammate(player)
    elseif mode == "Teams" then
        return isTeammate(player)
    elseif mode == "All" then
        return true
    end

    return false
end

local function applyhb()
    if not config.hitboxEnabled then return end  

    for _, target in ipairs(getAllTargets()) do  
        if targethb(target) and not isTeammate(target) then
            local size = config.hitboxSize
            config.hitboxLastSize[target] = size
            expandhb(target, size)
        else
            restoreTorso(target)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.3)

        if config.hitboxEnabled and targethb(player) and not isTeammate(player) then
            local size = config.hitboxSize
            config.hitboxLastSize[player] = size
            expandhb(player, size)
        end
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function()
        task.wait(0.3)

        if config.hitboxEnabled and targethb(player) and not isTeammate(player) then
            local size = config.hitboxSize
            config.hitboxLastSize[player] = size
            expandhb(player, size)
        end
    end)
end

RunService.Heartbeat:Connect(updateHitboxes)

local function hb()
    for playerObj, targetSize in pairs(config.targethbSizes) do
        if playerObj and playerObj ~= localPlayer and not isTeammate(playerObj) and getTargetCharacter(playerObj) and plralive(playerObj) then
            local part = getTargetCharacter(playerObj):FindFirstChild("Head")
            if part then
                pcall(function()
                    part.Transparency = 0
                    part.CanCollide = true
                    part.Massless = false
                end)
            end
        else
            if playerObj ~= localPlayer then
                restorePartForPlayer(playerObj)
            end
        end
    end
    
    updateHitboxes()
end

local function shouldTargetAimbot(target)
    if not target or isTeammate(target) then return false end
    if target == localPlayer then return false end
    if not plralive(target) then return false end
    
    if typeof(target) == "Instance" and target:IsA("Model") then
        if config.masterTarget == "NPCs" or config.masterTarget == "Both" then
            return true
        else
            return false
        end
    end

    local mode = config.aimbotTeamTarget or "Enemies"
    if mode == "Enemies" then
        return not isTeammate(target)
    elseif mode == "Teams" then
        return isTeammate(target)
    elseif mode == "All" then
        return true
    end
    return false
end

local function aimbotWallCheck(targetPos, sourcePos)
    if not config.aimbotWallCheck then return true end
    
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

local function getAimbotTargetPart(target)
    if not target or isTeammate(target) then return nil end
    local char = getTargetCharacter(target)
    if not char then return nil end
    return char:FindFirstChild("Head")
end

local function smoothAim(currentCFrame, targetCFrame, strength)
    strength = math.clamp(strength or 0.5, 0, 1)
    return currentCFrame:Lerp(targetCFrame, strength)
end

local function aimbotUpdate()
    if not config.aimbotEnabled then
        if config.aimbotCurrentTarget then
            config.aimbotCurrentTarget = nil
            updateESPColors()
        end
        return
    end
    
    if not camera then camera = workspace.CurrentCamera end
    if not camera then return end
    
    local viewportSize = camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local radiusPx = config.aimbot360Enabled and math.huge or config.aimbotFOVSize

    local candidates = {}
    local cameraCFrame = camera.CFrame
    local cameraPos = cameraCFrame.Position

    for _, target in ipairs(getAllTargets()) do
        if shouldTargetAimbot(target) and not isTeammate(target) then
            local targetPart = getAimbotTargetPart(target)
            if targetPart then
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                local distPx = (screenVec - center).Magnitude
                if config.aimbot360Enabled or (onScreen and distPx <= radiusPx) then
                    local worldDist = (targetPart.Position - cameraPos).Magnitude
                    if aimbotWallCheck(targetPart.Position, cameraPos) then
                        local humanoid = getTargetCharacter(target) and getTargetCharacter(target):FindFirstChildOfClass("Humanoid")
                        table.insert(candidates, {
                            target = target,
                            part = targetPart,
                            worldDist = worldDist,
                            screenDist = distPx,
                            humanoid = humanoid
                        })
                    end
                end
            end
        end
    end

    local bestCandidate = nil
    local selectionMode = config.aimbotGetTarget or config.masterGetTarget or "Closest"
    if #candidates > 0 then
        if selectionMode == "Lowest Health" then
            local bestHealth = math.huge
            for _, c in ipairs(candidates) do
                local h = math.huge
                if c.humanoid then
                    h = c.humanoid.Health
                end
                if bestCandidate == nil or h < bestHealth then
                    bestHealth = h
                    bestCandidate = c
                end
            end
        else
            local bestDist = math.huge
            for _, c in ipairs(candidates) do
                if c.worldDist < bestDist then
                    bestDist = c.worldDist
                    bestCandidate = c
                end
            end
        end
    end

    local bestTarget = bestCandidate and bestCandidate.target or nil
    local bestPart = bestCandidate and bestCandidate.part or nil

    if config.aimbotCurrentTarget ~= bestTarget then
        config.aimbotCurrentTarget = bestTarget
        updateESPColors()
    end
    
    if bestTarget and bestPart and localPlayer.Character and not isTeammate(bestTarget) then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local targetPosition = bestPart.Position
            local currentCFrame = camera.CFrame
            local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPosition)
            
            local strength = math.clamp(config.aimbotStrength, 0, 1)
            if strength < 1 then
                targetCFrame = smoothAim(currentCFrame, targetCFrame, strength)
            end
            
            camera.CFrame = targetCFrame
        end
    end
end

local function aimbotfov()
    if config.aimbotFOVRing and config.aimbotFOVRing.Parent then
        config.aimbotFOVRing:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimbotFOVRing"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    local ringFrame = Instance.new("Frame")
    ringFrame.Name = "RingFrame"
    ringFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ringFrame.Size = UDim2.new(0, config.aimbotFOVSize * 2, 0, config.aimbotFOVSize * 2)
    ringFrame.Position = UDim2.new(0.5, 0, 0.5, -28)
    ringFrame.BackgroundTransparency = 1
    ringFrame.Visible = config.aimbotEnabled
    ringFrame.Parent = screenGui
    
    local ringCorner = Instance.new("UICorner")
    ringCorner.CornerRadius = UDim.new(1, 0)
    ringCorner.Parent = ringFrame
    
    local ringStroke = Instance.new("UIStroke")
    ringStroke.Thickness = 1
    ringStroke.LineJoinMode = Enum.LineJoinMode.Round
    ringStroke.Color = Color3.fromRGB(255, 0, 0)
    ringStroke.Transparency = 0.3
    ringStroke.Parent = ringFrame
    
    config.aimbotFOVRing = {
        ScreenGui = screenGui,
        RingFrame = ringFrame,
        RingStroke = ringStroke
    }
    
    return config.aimbotFOVRing
end

local function updateAimbotFOVRing()
    if config.aimbotFOVRing and config.aimbotFOVRing.RingFrame then
        if config.aimbot360Enabled then
            config.aimbotFOVRing.RingFrame.Visible = false
        else
            config.aimbotFOVRing.RingFrame.Size = UDim2.new(0, config.aimbotFOVSize * 2, 0, config.aimbotFOVSize * 2)
            config.aimbotFOVRing.RingFrame.Position = UDim2.new(0.5, 0, 0.5, -28)
            config.aimbotFOVRing.RingFrame.Visible = config.aimbotEnabled
        end
    end
end

local function toggle360Aimbot(state)
    config.aimbot360Enabled = state
    
    if state then
        config.aimbot360OriginalFOV = config.aimbotFOVSize
        if not config.aimbotEnabled then
            config.aimbotEnabled = true
        end
        
        safeNotify({
            Title = "360° Aimbot",
            Content = "Enabled - Targeting in all directions",
            Audio = "rbxassetid://17208361335",
            Length = 2,
            Image = "rbxassetid://4483362458",
            BarColor = Color3.fromRGB(255, 165, 0)
        })
    else
        if config.aimbot360OriginalFOV then
            config.aimbotFOVSize = config.aimbot360OriginalFOV
        end
        
        safeNotify({
            Title = "360° Aimbot",
            Content = "Disabled",
            Audio = "rbxassetid://17208361335",
            Length = 1,
            Image = "rbxassetid://4483362458",
            BarColor = Color3.fromRGB(255, 0, 0)
        })
    end
    
    updateAimbotFOVRing()
end

RunService.Heartbeat:Connect(hb)
RunService.RenderStepped:Connect(aimbotUpdate)
RunService.Heartbeat:Connect(antiAimUpdate)

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
        if isTeammate(pl) then continue end
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

            if not skip and not isTeammate(pl) then
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
        if (not best) or pl ~= best.player or not plralive(pl) or isTeammate(pl) then
            restorePartForPlayer(pl)
        end
    end

    if best and plralive(best.player) and not isTeammate(best.player) then
        if config.rfd then
            RFD(best.player)
        end
    end
end

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
            restoreTorso(targetPlayer)
            if config.currentTarget == targetPlayer then
                config.currentTarget = nil
                updateESPColors()
            end
            if config.aimbotCurrentTarget == targetPlayer then
                config.aimbotCurrentTarget = nil
                updateESPColors()
            end
        end
    end)
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
        if config.espMasterEnabled and not isTeammate(pl) then
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
        
        if config.espMasterEnabled and not isTeammate(pl) then
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
        if isTeammate(pl) then
            removeESPLabel(pl)
            removeHighlightESP(pl)
            restorePartForPlayer(pl)
            restoreTorso(pl)
        else
            updateESPForPlayer()
        end
    end)
    table.insert(config.playerConnections[pl], teamChangedConn)
    
    if pl.Character then
        setupDeathListener(pl)
    end
end

for _, pl in ipairs(Players:GetPlayers()) do
    setupPlayerListeners(pl)
end

Players.PlayerAdded:Connect(setupPlayerListeners)
Players.PlayerRemoving:Connect(function(pl)
    removeESPLabel(pl)
    removeHighlightESP(pl)
    restorePartForPlayer(pl)
    restoreTorso(pl)
end)

local function makeui()
    lib:SetTitle("Gravel.cc (Legacy)")
    lib:SetIcon("http://www.roblox.com/asset/?id=132214308111067")
    lib:SetTheme("HighContrast")
    local T0 = lib:CreateTab("Client")
    local T1 = lib:CreateTab("Main")
    local T2 = lib:CreateTab("SilentAim")
    local T3 = lib:CreateTab("Visuals")
    local T4 = lib:CreateTab("Aimbot")
    local T5 = lib:CreateTab("Hitbox")
    local T6 = lib:CreateTab("AntiAim")

    lib:Tab("Visuals")
    lib:AddToggle("Enable ESP (Ctrl+'Z')", function(state)
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
    
    lib:AddToggle("Toggle Head Dot ESP", function(state)
        config.prefHeadDotESP = state
        if config.espMasterEnabled then
            for _, target in ipairs(getAllTargets()) do
                if addesp(target) and not isTeammate(target) then
                    if not config.espData[target] then
                        makeesp(target)
                    end
                end
            end
            updateESPColors()
        end
    end, false)
    
    lib:AddToggle("ESP Colour Based On Health", function(state)
        config.prefColorByHealth = state
        updateESPColors()
    end, false)

    lib:Tab("AntiAim")
    lib:AddToggle("Toggle AntiAim (Ctrl+'L')", function(state)
        config.antiAimEnabled = state
        if not state then
            returnToOriginalPosition()
        end
    end, false)

    lib:Tab("Aimbot")
    lib:AddToggle("Toggle Aimbot (Crtl+'Q')", function(state)
        config.aimbotEnabled = state
        if not state and config.aimbot360Enabled then
            toggle360Aimbot(false)
        end
        if config.aimbotFOVRing and config.aimbotFOVRing.RingFrame then
            config.aimbotFOVRing.RingFrame.Visible = state
        end
        if state and not config.aimbotFOVRing then
            aimbotfov()
        end
    end, false)

    lib:Tab("Hitbox")
    lib:AddToggle("Toggle Hitbox (Ctrl+'G')", function(state)
        config.hitboxEnabled = state
        if state then
            applyhb()
        else
            for player, _ in pairs(config.hitboxExpandedParts) do
                restoreTorso(player)
            end
        end
    end, false)

    lib:Tab("SilentAim")
    lib:AddToggle("Toggle SilentAim (Ctrl+'E')", function(state)
        config.Enabled = state
        if not config.Enabled then
            for pl, _ in pairs(config.activeApplied) do
                restorePartForPlayer(pl)
            end
        end
    end, false)
end

pcall(makeui)
