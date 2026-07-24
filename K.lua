-- Gravel.cc Legacy (Fixed & Optimized Monolithic Script with Script 2 ESP, SkinChanger, Config System, Menu Button Resizer, Bhop & Long Jump)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")

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
    maxExpansion = 4.5,
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
            Content = "SilentAim & Drawing ESP & SkinChanger loaded safely",
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
                pcall(callback, "Enemies")
            end
        end
        function lib:AddInputBox(_, callback, _, default)
            if callback then
                pcall(callback, tostring(default))
            end
        end
        function lib:AddButton(_, callback)
            if callback then
                pcall(callback)
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
            return localPlayer.Team == p.Team
        elseif p:GetAttribute("Team") and localPlayer:GetAttribute("Team") then
            return p:GetAttribute("Team") == localPlayer:GetAttribute("Team")
        elseif localPlayer.TeamColor and p.TeamColor then
            return localPlayer.TeamColor == p.TeamColor
        end
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

local function saveOriginalPartInfo(targetPlayer, part)
    if not targetPlayer or not part then return end
    if not config.originalSizes[targetPlayer] then
        config.originalSizes[targetPlayer] = {
            partName = part.Name or "Head",
            size = part.Size,
        }
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
    config.centerLocked[targetPlayer] = nil
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

    config.currentTarget = best and best.player

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

--------------------------------------------------------------------------------
-- SCRIPT 2 VISUALS / ESP / CHAMS / TRACERS / EFFECTS / SKINCHANGER
--------------------------------------------------------------------------------

local EspEnabled = false
local EspBox = true
local EspName = true
local EspHealth = true
local EspDistance = true
local EspSkeleton = false
local EspHeadDot = false
local EspTracers = false
local EspMaxDistance = 0

local RainbowESP = false
local RainbowESP_Speed = 2.0
local RainbowChams = false
local RainbowChams_Speed = 2.0

local BoxColor = Color3.fromRGB(255, 50, 50)
local TextColor = Color3.fromRGB(255, 255, 255)
local SkeletonColor = Color3.fromRGB(255, 255, 255)
local TracerColor = Color3.fromRGB(255, 50, 50)
local HeadDotColor = Color3.fromRGB(255, 255, 255)
local EspTextSize = 15
local BoxThickness = 1.5

local ChamsEnabled = false
local ChamsColor = Color3.fromRGB(255, 0, 255)
local ChamsFillTransparency = 0.7
local ChamsOutlineTransparency = 0

local WeaponChamsEnabled = false
local WeaponChamsColor = Color3.fromRGB(0, 255, 255)
local WeaponChamsFillTransparency = 0.5
local WeaponChamsOutlineTransparency = 0.0

local espCache = {}
local chamsCache = {}
local weaponChamsCache = {}

local function getRainbowColor(speed)
    local time = tick() * speed
    return Color3.fromHSV(time % 1, 1, 1)
end

local function createESP()
    local esp = {
        boxOutline = Drawing.new("Square"),
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        distance = Drawing.new("Text"),
        healthOutline = Drawing.new("Line"),
        healthBackground = Drawing.new("Line"),
        healthBar = Drawing.new("Line"),
        headDot = Drawing.new("Circle"),
        tracer = Drawing.new("Line"),
        skeleton = {
            headToNeck = Drawing.new("Line"),
            neckToTorso = Drawing.new("Line"),
            torsoToLeftUpper = Drawing.new("Line"),
            torsoToRightUpper = Drawing.new("Line"),
            leftUpperToLower = Drawing.new("Line"),
            rightUpperToLower = Drawing.new("Line"),
            leftLowerToFoot = Drawing.new("Line"),
            rightLowerToFoot = Drawing.new("Line")
        }
    }

    esp.boxOutline.Thickness = 3
    esp.boxOutline.Filled = false
    esp.boxOutline.Color = Color3.new(0, 0, 0)

    esp.box.Thickness = BoxThickness
    esp.box.Filled = false

    esp.name.Center = true
    esp.name.Outline = true
    esp.name.Size = EspTextSize

    esp.distance.Center = true
    esp.distance.Outline = true
    esp.distance.Size = EspTextSize - 2

    esp.healthOutline.Thickness = 3
    esp.healthOutline.Color = Color3.new(0, 0, 0)

    esp.healthBackground.Thickness = 4
    esp.healthBackground.Color = Color3.new(0, 0, 0)
    esp.healthBackground.Transparency = 0.7

    esp.healthBar.Thickness = 2

    esp.headDot.Radius = 3
    esp.headDot.Filled = true
    esp.headDot.Transparency = 1

    esp.tracer.Thickness = 1.5
    esp.tracer.Transparency = 0.8

    for _, line in pairs(esp.skeleton) do
        line.Thickness = 1.5
        line.Transparency = 0.9
    end

    return esp
end

RunService.RenderStepped:Connect(function()
    if not EspEnabled then
        for _, e in pairs(espCache) do
            for _, drawing in pairs(e) do
                if typeof(drawing) == "table" then
                    for _, line in pairs(drawing) do line.Visible = false end
                else
                    drawing.Visible = false
                end
            end
        end
        return
    end

    local currentAlive = {}
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    local rainbowColor = RainbowESP and getRainbowColor(RainbowESP_Speed) or nil

    for _, enemy in ipairs(getAllTargets()) do
        if addesp(enemy) then
            local char = getTargetCharacter(enemy)
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
            local head = char and char:FindFirstChild("Head")

            if hum and hum.Health > 0 and root and head then
                currentAlive[enemy] = true
                if not espCache[enemy] then espCache[enemy] = createESP() end

                local esp = espCache[enemy]
                local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
                local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.4, 0))
                local legPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.2, 0))

                local distance = (camera.CFrame.Position - root.Position).Magnitude

                if EspMaxDistance > 0 and distance > EspMaxDistance then
                    for _, d in pairs(esp) do
                        if typeof(d) == "table" then
                            for _, l in pairs(d) do l.Visible = false end
                        else
                            d.Visible = false
                        end
                    end
                    continue
                end

                if onScreen then
                    local boxHeight = math.abs(headPos.Y - legPos.Y) * 1.05
                    local boxWidth = boxHeight * 0.55
                    local boxX = rootPos.X - boxWidth / 2
                    local boxY = headPos.Y

                    local currentBoxColor = RainbowESP and rainbowColor or BoxColor
                    local currentTextColor = RainbowESP and rainbowColor or TextColor
                    local currentSkeletonColor = RainbowESP and rainbowColor or SkeletonColor
                    local currentTracerColor = RainbowESP and rainbowColor or TracerColor
                    local currentHeadDotColor = RainbowESP and rainbowColor or HeadDotColor

                    if EspBox then
                        esp.boxOutline.Size = Vector2.new(boxWidth, boxHeight)
                        esp.boxOutline.Position = Vector2.new(boxX, boxY)
                        esp.boxOutline.Visible = true

                        esp.box.Size = Vector2.new(boxWidth, boxHeight)
                        esp.box.Position = Vector2.new(boxX, boxY)
                        esp.box.Color = currentBoxColor
                        esp.box.Thickness = BoxThickness
                        esp.box.Visible = true
                    else
                        esp.boxOutline.Visible = false
                        esp.box.Visible = false
                    end

                    if EspHealth then
                        local hpPct = hum.Health / hum.MaxHealth
                        local barX = boxX - 7
                        local barTop = boxY
                        local barBottom = boxY + boxHeight

                        esp.healthBackground.From = Vector2.new(barX, barTop)
                        esp.healthBackground.To = Vector2.new(barX, barBottom)
                        esp.healthBackground.Visible = true

                        esp.healthOutline.From = Vector2.new(barX - 1, barTop - 1)
                        esp.healthOutline.To = Vector2.new(barX + 1, barBottom + 1)
                        esp.healthOutline.Visible = true

                        esp.healthBar.From = Vector2.new(barX, barBottom)
                        esp.healthBar.To = Vector2.new(barX, barBottom - (boxHeight * hpPct))
                        esp.healthBar.Color = Color3.fromHSV(hpPct * 0.33, 1, 1)
                        esp.healthBar.Visible = true
                    else
                        esp.healthBackground.Visible = false
                        esp.healthOutline.Visible = false
                        esp.healthBar.Visible = false
                    end

                    if EspName then
                        esp.name.Text = getTargetName(enemy)
                        esp.name.Position = Vector2.new(rootPos.X, headPos.Y - 22)
                        esp.name.Color = currentTextColor
                        esp.name.Size = EspTextSize
                        esp.name.Visible = true
                    else
                        esp.name.Visible = false
                    end

                    if EspDistance then
                        esp.distance.Text = string.format("[%d studs]", math.floor(distance))
                        esp.distance.Position = Vector2.new(rootPos.X, boxY + boxHeight + 4)
                        esp.distance.Color = currentTextColor
                        esp.distance.Size = EspTextSize - 2
                        esp.distance.Visible = true
                    else
                        esp.distance.Visible = false
                    end

                    if EspHeadDot then
                        esp.headDot.Position = Vector2.new(headPos.X, headPos.Y)
                        esp.headDot.Color = currentHeadDotColor
                        esp.headDot.Visible = true
                    else
                        esp.headDot.Visible = false
                    end

                    if EspTracers then
                        esp.tracer.From = screenCenter
                        esp.tracer.To = Vector2.new(rootPos.X, rootPos.Y + boxHeight / 2)
                        esp.tracer.Color = currentTracerColor
                        esp.tracer.Visible = true
                    else
                        esp.tracer.Visible = false
                    end

                    if EspSkeleton then
                        local neck = char:FindFirstChild("Neck") or head
                        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                        local leftUpper = char:FindFirstChild("LeftUpperArm")
                        local rightUpper = char:FindFirstChild("RightUpperArm")
                        local leftLower = char:FindFirstChild("LeftLowerArm")
                        local rightLower = char:FindFirstChild("RightLowerArm")
                        local leftFoot = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg")
                        local rightFoot = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")

                        local function w2s(pos)
                            local p = camera:WorldToViewportPoint(pos)
                            return Vector2.new(p.X, p.Y)
                        end

                        local lines = esp.skeleton
                        for _, line in pairs(lines) do
                            line.Color = currentSkeletonColor
                            line.Visible = true
                        end

                        lines.headToNeck.From = Vector2.new(headPos.X, headPos.Y)
                        lines.headToNeck.To = w2s(neck.Position)

                        lines.neckToTorso.From = w2s(neck.Position)
                        lines.neckToTorso.To = w2s(torso and torso.Position or root.Position)

                        lines.torsoToLeftUpper.From = w2s(torso and torso.Position or root.Position)
                        lines.torsoToLeftUpper.To = w2s(leftUpper and leftUpper.Position or root.Position)

                        lines.torsoToRightUpper.From = w2s(torso and torso.Position or root.Position)
                        lines.torsoToRightUpper.To = w2s(rightUpper and rightUpper.Position or root.Position)

                        lines.leftUpperToLower.From = w2s(leftUpper and leftUpper.Position or root.Position)
                        lines.leftUpperToLower.To = w2s(leftLower and leftLower.Position or root.Position)

                        lines.rightUpperToLower.From = w2s(rightUpper and rightUpper.Position or root.Position)
                        lines.rightUpperToLower.To = w2s(rightLower and rightLower.Position or root.Position)

                        lines.leftLowerToFoot.From = w2s(leftLower and leftLower.Position or root.Position)
                        lines.leftLowerToFoot.To = w2s(leftFoot and leftFoot.Position or root.Position)

                        lines.rightLowerToFoot.From = w2s(rightLower and rightLower.Position or root.Position)
                        lines.rightLowerToFoot.To = w2s(rightFoot and rightFoot.Position or root.Position)
                    else
                        for _, line in pairs(esp.skeleton) do line.Visible = false end
                    end
                else
                    for _, d in pairs(esp) do
                        if typeof(d) == "table" then
                            for _, l in pairs(d) do l.Visible = false end
                        else
                            d.Visible = false
                        end
                    end
                end
            end
        end
    end

    for cEnemy, e in pairs(espCache) do
        if not currentAlive[cEnemy] then
            for _, d in pairs(e) do
                if typeof(d) == "table" then
                    for _, l in pairs(d) do l:Remove() end
                else
                    d:Remove()
                end
            end
            espCache[cEnemy] = nil
        end
    end
end)

local function updatePlayerChams()
    local rainbowColor = RainbowChams and getRainbowColor(RainbowChams_Speed) or ChamsColor

    for _, enemy in ipairs(getAllTargets()) do
        if addesp(enemy) then
            local char = getTargetCharacter(enemy)
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if char and hum and hum.Health > 0 then
                if not chamsCache[enemy] then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = char
                    highlight.Parent = char
                    highlight.FillTransparency = ChamsFillTransparency
                    highlight.OutlineTransparency = ChamsOutlineTransparency
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    chamsCache[enemy] = highlight
                end
                local hl = chamsCache[enemy]
                if hl and hl.Parent then
                    hl.FillColor = rainbowColor
                    hl.OutlineColor = rainbowColor
                    hl.FillTransparency = ChamsFillTransparency
                    hl.OutlineTransparency = ChamsOutlineTransparency
                end
            end
        end
    end

    for model, hl in pairs(chamsCache) do
        local char = getTargetCharacter(model)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not model or not char or not char.Parent or (hum and hum.Health <= 0) then
            if hl then hl:Destroy() end
            chamsCache[model] = nil
        end
    end
end

local function updateWeaponChams()
    if not WeaponChamsEnabled then 
        for _, hl in pairs(weaponChamsCache) do
            if hl then hl:Destroy() end
        end
        weaponChamsCache = {}
        return 
    end

    local rainbowColor = RainbowChams and getRainbowColor(RainbowChams_Speed) or WeaponChamsColor

    for _, obj in ipairs(camera:GetChildren()) do
        if obj:IsA("Model") and (obj.Name:find("Knife") or obj:FindFirstChild("Weapon")) then
            if not weaponChamsCache[obj] then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = obj
                highlight.Parent = obj
                highlight.FillTransparency = WeaponChamsFillTransparency
                highlight.OutlineTransparency = WeaponChamsOutlineTransparency
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                weaponChamsCache[obj] = highlight
            end
            local hl = weaponChamsCache[obj]
            if hl and hl.Parent then
                hl.FillColor = rainbowColor
                hl.OutlineColor = rainbowColor
                hl.FillTransparency = WeaponChamsFillTransparency
                hl.OutlineTransparency = WeaponChamsOutlineTransparency
            end
        end
    end

    for obj, hl in pairs(weaponChamsCache) do
        if not obj.Parent then
            if hl then hl:Destroy() end
            weaponChamsCache[obj] = nil
        end
    end
end

task.spawn(function()
    while task.wait(0.05) do
        if ChamsEnabled then
            updatePlayerChams()
        end
        updateWeaponChams()
    end
end)

-- Advanced Bullet Tracers
local BulletTracersEnabled = false
local BulletTracerColor = Color3.fromRGB(0, 255, 255)
local BulletTracerTransparency = 0.3
local BulletTracerDuration = 0.6
local BulletTracerThickness = 0.2
local BulletTracerPattern = "Straight"

local tracerParts = {}

local function createAdvancedTracer(origin, direction)
    local tracer = Instance.new("Part")
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.Transparency = BulletTracerTransparency
    tracer.Color = BulletTracerColor
    tracer.Material = Enum.Material.Neon
    tracer.Size = Vector3.new(BulletTracerThickness, BulletTracerThickness, 300)
    tracer.CFrame = CFrame.new(origin, origin + direction) * CFrame.new(0, 0, -150)
    tracer.Parent = Workspace

    if BulletTracerPattern == "Wave" then
        task.spawn(function()
            local startTime = tick()
            while tracer.Parent and (tick() - startTime) < BulletTracerDuration do
                local t = (tick() - startTime) * 15
                local offset = Vector3.new(math.sin(t) * 2, 0, 0)
                tracer.CFrame = CFrame.new(origin + offset, origin + direction + offset) * CFrame.new(0, 0, -150)
                RunService.Heartbeat:Wait()
            end
            if tracer.Parent then tracer:Destroy() end
        end)
    elseif BulletTracerPattern == "Spiral" then
        task.spawn(function()
            local startTime = tick()
            while tracer.Parent and (tick() - startTime) < BulletTracerDuration do
                local t = (tick() - startTime) * 20
                local offset = Vector3.new(math.cos(t) * 1.5, math.sin(t) * 1.5, 0)
                tracer.CFrame = CFrame.new(origin + offset, origin + direction + offset) * CFrame.new(0, 0, -150)
                RunService.Heartbeat:Wait()
            end
            if tracer.Parent then tracer:Destroy() end
        end)
    elseif BulletTracerPattern == "Dashed" then
        task.spawn(function()
            local startTime = tick()
            while tracer.Parent and (tick() - startTime) < BulletTracerDuration do
                tracer.Transparency = (math.sin(tick() * 30) > 0) and BulletTracerTransparency or 1
                RunService.Heartbeat:Wait()
            end
            if tracer.Parent then tracer:Destroy() end
        end)
    else
        task.delay(BulletTracerDuration, function()
            if tracer and tracer.Parent then tracer:Destroy() end
        end)
    end

    table.insert(tracerParts, tracer)
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and BulletTracersEnabled then
        local origin = camera.CFrame.Position
        local direction = camera.CFrame.LookVector * 300
        createAdvancedTracer(origin, direction)
    end
end)

RunService.Heartbeat:Connect(function()
    for i = #tracerParts, 1, -1 do
        if not tracerParts[i].Parent then
            table.remove(tracerParts, i)
        end
    end
end)

-- Particle Effects
local ParticleEffectsEnabled = false
local ParticleColor = Color3.fromRGB(255, 100, 0)
local ParticleAmount = 25
local ParticleLifetime = 1.2
local ParticleStyle = "Spark"

local function createParticleEffect(position)
    if not ParticleEffectsEnabled then return end

    local attachment = Instance.new("Attachment")
    attachment.Position = position
    attachment.Parent = Workspace.Terrain

    local particle = Instance.new("ParticleEmitter")
    particle.Color = ColorSequence.new(ParticleColor)
    particle.Texture = "rbxassetid://243660364"
    particle.Lifetime = NumberRange.new(ParticleLifetime * 0.6, ParticleLifetime)
    particle.Rate = 0
    particle.EmissionDirection = Enum.NormalId.Front
    particle.SpreadAngle = Vector2.new(35, 35)
    particle.Speed = NumberRange.new(8, 18)
    particle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.1)})
    particle.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
    particle.Parent = attachment

    if ParticleStyle == "Smoke" then
        particle.Texture = "rbxassetid://243098098"
        particle.Speed = NumberRange.new(2, 6)
    elseif ParticleStyle == "Fire" then
        particle.Texture = "rbxassetid://241650934"
        particle.Speed = NumberRange.new(5, 12)
    elseif ParticleStyle == "Explosion" then
        particle.Lifetime = NumberRange.new(0.4, 0.8)
        particle.Speed = NumberRange.new(15, 30)
        particle.SpreadAngle = Vector2.new(80, 80)
        particle.Amount = ParticleAmount * 2
    elseif ParticleStyle == "Magic" then
        particle.Texture = "rbxassetid://243098098"
        particle.RotSpeed = NumberRange.new(-200, 200)
    end

    particle:Emit(ParticleAmount)

    task.delay(ParticleLifetime + 0.5, function()
        if attachment then attachment:Destroy() end
    end)
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and ParticleEffectsEnabled then
        local ray = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {camera, localPlayer.Character or {}}
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)

        if result and result.Position then
            createParticleEffect(result.Position)
        else
            local muzzlePos = camera.CFrame.Position + camera.CFrame.LookVector * 3
            createParticleEffect(muzzlePos)
        end
    end
end)

-- Kill Effects
local KillEffectsEnabled = false
local KillEffectColor = Color3.fromRGB(255, 0, 100)
local KillEffectDuration = 0.8
local KillEffectIntensity = 0.6

local killFlashGui = nil

local function createKillEffects()
    if not KillEffectsEnabled then return end

    if not killFlashGui then
        killFlashGui = Instance.new("ScreenGui")
        killFlashGui.ResetOnSpawn = false
        killFlashGui.Parent = localPlayer:WaitForChild("PlayerGui")

        local flashFrame = Instance.new("Frame")
        flashFrame.Size = UDim2.new(1, 0, 1, 0)
        flashFrame.BackgroundColor3 = KillEffectColor
        flashFrame.BackgroundTransparency = 1
        flashFrame.BorderSizePixel = 0
        flashFrame.Parent = killFlashGui
        killFlashGui.Frame = flashFrame
    end

    local flash = killFlashGui.Frame
    flash.BackgroundTransparency = 0.2
    TweenService:Create(flash, TweenInfo.new(KillEffectDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0, 300, 0, 100)
    text.Position = UDim2.new(0.5, -150, 0.4, 0)
    text.BackgroundTransparency = 1
    text.Text = "KILL"
    text.TextColor3 = KillEffectColor
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.Parent = localPlayer.PlayerGui

    TweenService:Create(text, TweenInfo.new(KillEffectDuration * 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -150, 0.25, 0), TextTransparency = 1}):Play()

    task.delay(KillEffectDuration, function()
        if text and text.Parent then text:Destroy() end
    end)
end

task.spawn(function()
    local lastHealth = {}
    while task.wait(0.1) do
        if not KillEffectsEnabled then continue end
        for _, enemy in ipairs(getAllTargets()) do
            if addesp(enemy) then
                local char = getTargetCharacter(enemy)
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local currentHealth = hum.Health
                    if lastHealth[enemy] and lastHealth[enemy] > 0 and currentHealth <= 0 then
                        createKillEffects()
                    end
                    lastHealth[enemy] = currentHealth
                end
            end
        end
    end
end)

-- World & Effects (Anti-Flash / Anti-Smoke)
local AntiFlashEnabled, AntiSmokeEnabled = false, false
task.spawn(function()
    while task.wait(0.2) do
        if AntiFlashEnabled then
            local flashGui = localPlayer.PlayerGui:FindFirstChild("FlashbangEffect")
            local effect = game:GetService("Lighting"):FindFirstChild("FlashbangColorCorrection")
            if flashGui then flashGui:Destroy() end
            if effect then effect:Destroy() end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if AntiSmokeEnabled then
            local debris = Workspace:FindFirstChild("Debris")
            if debris then
                for _, folder in ipairs(debris:GetChildren()) do
                    if string.match(folder.Name, "Voxel") then folder:ClearAllChildren(); folder:Destroy() end
                end
            end
        end
    end
end)

-- Bunny Hop & Long Jump Functions
local BhopEnabled = false
local LongJumpEnabled = false
local LongJumpPower = 60

RunService.Heartbeat:Connect(function()
    if BhopEnabled then
        pcall(function()
            local char = localPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.FloorMaterial ~= Enum.Material.Air then
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if LongJumpEnabled and input.KeyCode == Enum.KeyCode.Space then
        pcall(function()
            local char = localPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.FloorMaterial ~= Enum.Material.Air then
                    local lookVec = camera.CFrame.LookVector
                    lookVec = Vector3.new(lookVec.X, 0, lookVec.Z).Unit
                    root.Velocity = Vector3.new(lookVec.X * LongJumpPower, root.Velocity.Y + 35, lookVec.Z * LongJumpPower)
                end
            end
        end)
    end
end)

-- Config System & Menu Button Resizer
local CONFIG_FOLDER = "Gravelcc_Configs"
if not pcall(function() return isfolder and isfolder(CONFIG_FOLDER) end) or (isfolder and not isfolder(CONFIG_FOLDER)) then
    pcall(function() makefolder(CONFIG_FOLDER) end)
end

local currentConfigName = "default"
local MenuButtonScale = 1.0

local function applyMenuButtonScale(scale)
    MenuButtonScale = scale
    pcall(function()
        local function checkAndResize(parent)
            for _, obj in ipairs(parent:GetDescendants()) do
                if obj:IsA("ImageButton") or obj:IsA("TextButton") then
                    local nameLower = obj.Name:lower()
                    if nameLower:find("toggle") or nameLower:find("open") or nameLower:find("button") or (obj.Size.X.Offset <= 65 and obj.Size.Y.Offset <= 65) then
                        obj.Size = UDim2.new(0, math.floor(35 * scale), 0, math.floor(35 * scale))
                    end
                end
            end
        end
        if game:GetService("CoreGui"):FindFirstChild("ACXUI") then
            checkAndResize(game:GetService("CoreGui").ACXUI)
        end
        if localPlayer.PlayerGui:FindFirstChild("ACXUI") then
            checkAndResize(localPlayer.PlayerGui.ACXUI)
        end
    end)
end

local function getSavedConfigs()
    local configs = {}
    pcall(function()
        if listfiles then
            for _, file in ipairs(listfiles(CONFIG_FOLDER)) do
                local name = file:match("([^/]+)$")
                if name and name:sub(-5) == ".json" then
                    table.insert(configs, name:sub(1, -6))
                end
            end
        end
    end)
    if #configs == 0 then
        table.insert(configs, "default")
    end
    return configs
end

local function saveConfig(name)
    if not name or name == "" then name = currentConfigName end
    local data = {
        config = {
            Enabled = config.Enabled,
            fovsize = config.fovsize,
            predic = config.predic,
            rfd = config.rfd,
            eme = config.eme,
            wallc = config.wallc,
            bodypart = config.bodypart,
            hitchance = config.hitchance,
            maxExpansion = config.maxExpansion,
            masterTeamTarget = config.masterTeamTarget,
            masterTarget = config.masterTarget,
            masterGetTarget = config.masterGetTarget,
            silentGetTarget = config.silentGetTarget,
            gp = config.gp,
        },
        visuals = {
            EspEnabled = EspEnabled,
            EspBox = EspBox,
            EspName = EspName,
            EspHealth = EspHealth,
            EspDistance = EspDistance,
            EspSkeleton = EspSkeleton,
            EspHeadDot = EspHeadDot,
            EspTracers = EspTracers,
            EspMaxDistance = EspMaxDistance,
            RainbowESP = RainbowESP,
            RainbowESP_Speed = RainbowESP_Speed,
            RainbowChams = RainbowChams,
            RainbowChams_Speed = RainbowChams_Speed,
            ChamsEnabled = ChamsEnabled,
            WeaponChamsEnabled = WeaponChamsEnabled,
            BulletTracersEnabled = BulletTracersEnabled,
            BulletTracerPattern = BulletTracerPattern,
            ParticleEffectsEnabled = ParticleEffectsEnabled,
            ParticleStyle = ParticleStyle,
            KillEffectsEnabled = KillEffectsEnabled,
            AntiFlashEnabled = AntiFlashEnabled,
            AntiSmokeEnabled = AntiSmokeEnabled,
        },
        skins = {
            SkinChangerEnabled = SkinChangerEnabled,
            scriptRunning = scriptRunning,
            selectedKnife = selectedKnife,
            SelectedSkins = SelectedSkins,
            WEAR = WEAR,
        },
        movement = {
            BhopEnabled = BhopEnabled,
            LongJumpEnabled = LongJumpEnabled,
            LongJumpPower = LongJumpPower,
        },
        ui = {
            ButtonScale = MenuButtonScale,
        }
    }
    pcall(function()
        if writefile then
            writefile(CONFIG_FOLDER .. "/" .. name .. ".json", HttpService:JSONEncode(data))
            safeNotify({Title = "Config Saved", Content = "Config '" .. name .. "' saved successfully!", Length = 2})
        end
    end)
end

local function loadConfig(name)
    if not name or name == "" then return end
    currentConfigName = name
    pcall(function()
        local path = CONFIG_FOLDER .. "/" .. name .. ".json"
        if readfile and isfile and isfile(path) then
            local content = readfile(path)
            local data = HttpService:JSONDecode(content)
            if data.config then
                for k, v in pairs(data.config) do
                    config[k] = v
                end
            end
            if data.visuals then
                EspEnabled = data.visuals.EspEnabled or false
                EspBox = data.visuals.EspBox ~= false
                EspName = data.visuals.EspName ~= false
                EspHealth = data.visuals.EspHealth ~= false
                EspDistance = data.visuals.EspDistance ~= false
                EspSkeleton = data.visuals.EspSkeleton or false
                EspHeadDot = data.visuals.EspHeadDot or false
                EspTracers = data.visuals.EspTracers or false
                EspMaxDistance = data.visuals.EspMaxDistance or 0
                RainbowESP = data.visuals.RainbowESP or false
                ChamsEnabled = data.visuals.ChamsEnabled or false
                WeaponChamsEnabled = data.visuals.WeaponChamsEnabled or false
                BulletTracersEnabled = data.visuals.BulletTracersEnabled or false
                ParticleEffectsEnabled = data.visuals.ParticleEffectsEnabled or false
                KillEffectsEnabled = data.visuals.KillEffectsEnabled or false
                AntiFlashEnabled = data.visuals.AntiFlashEnabled or false
                AntiSmokeEnabled = data.visuals.AntiSmokeEnabled or false
            end
            if data.skins then
                SkinChangerEnabled = data.skins.SkinChangerEnabled or false
                scriptRunning = data.skins.scriptRunning or false
                selectedKnife = data.skins.selectedKnife or "Butterfly Knife"
                if data.skins.SelectedSkins then
                    SelectedSkins = data.skins.SelectedSkins
                end
            end
            if data.movement then
                BhopEnabled = data.movement.BhopEnabled or false
                LongJumpEnabled = data.movement.LongJumpEnabled or false
                LongJumpPower = data.movement.LongJumpPower or 60
            end
            if data.ui and data.ui.ButtonScale then
                MenuButtonScale = data.ui.ButtonScale
                applyMenuButtonScale(MenuButtonScale)
            end
            safeNotify({Title = "Config Loaded", Content = "Config '" .. name .. "' loaded successfully!", Length = 2})
        end
    end)
end

-- SkinChanger & Custom Knife System
local scriptRunning = false
local selectedKnife = "Butterfly Knife"
local spawned = false
local inspecting = false
local swinging = false
local lastAttackTime = 0
local ATTACK_COOLDOWN = 1
local ACTION_INSPECT = "InspectKnifeAction"
local ACTION_ATTACK = "AttackKnifeAction"

pcall(function() ReplicatedStorage.Assets.Weapons.Karambit.Camera.ViewmodelLight.Transparency = 1 end)

local knives = {
    ["Karambit"] = {Offset = CFrame.new(0, -1.5, 1.5)},
    ["Butterfly Knife"] = {Offset = CFrame.new(0, -1.5, 1.5)},
    ["M9 Bayonet"] = {Offset = CFrame.new(0, -1.5, 1)},
    ["Flip Knife"] = {Offset = CFrame.new(0, -1.5, 1.25)},
    ["Gut Knife"] = {Offset = CFrame.new(0, -1.5, 0.5)},
}

local vm, animator
local equipAnim, idleAnim, inspectAnim, HeavySwingAnim, Swing1Anim, Swing2Anim

local function getKnifeInCamera() return camera:FindFirstChild("T Knife") or camera:FindFirstChild("CT Knife") end
local function cleanPart(part)
    if not part:IsA("BasePart") then return end
    part.CanCollide, part.Anchored, part.CastShadow, part.CanTouch, part.CanQuery = false, false, false, false, false
end
local function disableCollisions(model)
    for _, part in model:GetDescendants() do cleanPart(part) end
end
local function hideOriginalKnife(knife)
    for _, part in knife:GetDescendants() do
        if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("Texture") then part.Transparency = 1 end
    end
end
local function playSound(folder, name)
    local weaponSounds = ReplicatedStorage.Sounds:FindFirstChild(selectedKnife)
    if not weaponSounds then return end
    local sound = weaponSounds:WaitForChild(folder):WaitForChild(name):Clone()
    sound.Parent = camera
    sound:Play()
    sound.Ended:Once(function() sound:Destroy() end)
    return sound
end

local function attachAsset(folder, armPartName, assetModelName, finalName, offset)
    local targetArm = vm:FindFirstChild(armPartName)
    if not targetArm then return end
    local assetMesh = folder:WaitForChild(assetModelName):Clone()
    cleanPart(assetMesh)
    assetMesh.Name = finalName
    assetMesh.Parent = targetArm
    local motor = Instance.new("Motor6D")
    motor.Part0, motor.Part1, motor.C0, motor.Parent = targetArm, assetMesh, offset, targetArm
end

local function handleAction(actionName, inputState, inputObject)
    if inputState ~= Enum.UserInputState.Begin or not spawned or not animator then return Enum.ContextActionResult.Pass end
    if actionName == ACTION_INSPECT then
        if (equipAnim and equipAnim.IsPlaying) or inspecting or swinging then return Enum.ContextActionResult.Pass end
        inspecting = true
        if idleAnim then idleAnim:Stop() end
        inspectAnim:Play()
        inspectAnim.Stopped:Once(function() inspecting = false end)
    elseif actionName == ACTION_ATTACK then
        local currentTime = os.clock()
        if (equipAnim and equipAnim.IsPlaying) or (currentTime - lastAttackTime < ATTACK_COOLDOWN) then return Enum.ContextActionResult.Pass end
        lastAttackTime = currentTime
        if inspecting then inspecting = false; if inspectAnim then inspectAnim:Stop() end end
        swinging = true
        if idleAnim then idleAnim:Stop() end
        local anims = {HeavySwingAnim, Swing1Anim, Swing2Anim}
        local chosenAnim = anims[math.random(1, #anims)]
        local soundFolder = (chosenAnim == HeavySwingAnim and "HitOne") or (chosenAnim == Swing1Anim and "HitTwo") or "HitThree"
        chosenAnim:Play()
        local s = playSound(soundFolder, "1")
        if s then s.Volume = 5 end
        chosenAnim.Stopped:Once(function() swinging = false end)
    end
    return Enum.ContextActionResult.Pass
end

local function removeViewmodel()
    spawned = false
    ContextActionService:UnbindAction(ACTION_INSPECT)
    ContextActionService:UnbindAction(ACTION_ATTACK)
    if vm then vm:Destroy() vm = nil end
    animator, inspecting, swinging = nil, false, false
end

local function spawnViewmodel(knife)
    if spawned or not scriptRunning then return end
    spawned = true
    local knifeTemplate = ReplicatedStorage.Assets.Weapons:WaitForChild(selectedKnife)
    local knifeOffset = knives[selectedKnife].Offset
    vm = knifeTemplate:WaitForChild("Camera"):Clone()
    vm.Name, vm.Parent = selectedKnife, camera
    disableCollisions(vm)
    hideOriginalKnife(knife)
    pcall(function()
        local tGloves = ReplicatedStorage.Assets.Weapons:WaitForChild("T Glove")
        attachAsset(tGloves, "Left Arm", "Left Arm", "Glove", CFrame.new(0, 0, -1.5))
        attachAsset(tGloves, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
    end)
    local animController = vm:FindFirstChildOfClass("AnimationController") or vm:FindFirstChildOfClass("Animator")
    animator = animController:FindFirstChildWhichIsA("Animator") or animController
    local animFolder = ReplicatedStorage.Assets.WeaponAnimations:WaitForChild(selectedKnife):WaitForChild("CameraAnimations")
    equipAnim = animator:LoadAnimation(animFolder:WaitForChild("Equip"))
    idleAnim = animator:LoadAnimation(animFolder:WaitForChild("Idle"))
    inspectAnim = animator:LoadAnimation(animFolder:WaitForChild("Inspect"))
    HeavySwingAnim = animator:LoadAnimation(animFolder:WaitForChild("Heavy Swing"))
    Swing1Anim = animator:LoadAnimation(animFolder:WaitForChild("Swing1"))
    Swing2Anim = animator:LoadAnimation(animFolder:WaitForChild("Swing2"))
    vm:SetPrimaryPartCFrame(camera.CFrame * CFrame.new(0, -1.5, 5))
    TweenService:Create(vm.PrimaryPart, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = camera.CFrame * knifeOffset
    }):Play()
    equipAnim:Play()
    playSound("Equip", "1")
    ContextActionService:BindAction(ACTION_INSPECT, handleAction, false, Enum.KeyCode.F)
    ContextActionService:BindAction(ACTION_ATTACK, handleAction, false, Enum.UserInputType.MouseButton1)
end

RunService.RenderStepped:Connect(function()
    if not scriptRunning or not vm or not vm.PrimaryPart then return end
    vm.PrimaryPart.CFrame = camera.CFrame * knives[selectedKnife].Offset
    if not (equipAnim and equipAnim.IsPlaying) and not inspecting and not swinging then
        if idleAnim and not idleAnim.IsPlaying then idleAnim:Play() end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        local currentKnife = getKnifeInCamera()
        if scriptRunning and currentKnife and not spawned then
            spawnViewmodel(currentKnife)
        elseif (not scriptRunning or not currentKnife) and spawned then
            removeViewmodel()
        end
    end
end)

local SkinChangerEnabled = false
local SelectedSkins = {}
local SkinOptions = {}
local COOLDOWN = 0.1
local WEAR = "Factory New"
local CT_ONLY = {["USP-S"]=true, ["Five-SeveN"]=true, ["MP9"]=true, ["FAMAS"]=true, ["M4A1-S"]=true, ["M4A4"]=true, ["AUG"]=true}
local SHARED = {["P250"]=true, ["Desert Eagle"]=true, ["Dual Berettas"]=true, ["Negev"]=true, ["P90"]=true, ["Nova"]=true, ["XM1014"]=true, ["AWP"]=true, ["SSG 08"]=true}
local KNIVES = {["Karambit"]=true, ["Butterfly Knife"]=true, ["M9 Bayonet"]=true, ["Flip Knife"]=true, ["Gut Knife"]=true, ["T Knife"]=true, ["CT Knife"]=true}
local GLOVES = {["Sports Gloves"]=true}
local SkinsFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Skins")
local IgnoreFolders = {["HE Grenade"]=true, ["Incendiary Grenade"]=true, ["Molotov"]=true, ["Smoke Grenade"]=true, ["Flashbang"]=true, ["Decoy Grenade"]=true, ["C4"]=true, ["CT Glove"]=true, ["T Glove"]=true}

local function applyWeaponSkin(model)
    if not model or not SkinChangerEnabled then return end
    local skinName = SelectedSkins[model.Name]
    if not skinName then return end
    pcall(function()
        local skinFolder = SkinsFolder:FindFirstChild(model.Name)
        if not skinFolder then return end
        local skinType = skinFolder:FindFirstChild(skinName)
        local sourceFolder = skinType and skinType:FindFirstChild("Camera") and skinType.Camera:FindFirstChild(WEAR)
        if not sourceFolder then return end
        for _, obj in camera:GetChildren() do
            local left, right = obj:FindFirstChild("Left Arm"), obj:FindFirstChild("Right Arm")
            if left or right then
                local gloveFolder = SkinsFolder:FindFirstChild("Sports Gloves")
                local gloveSkin = gloveFolder and gloveFolder:FindFirstChild(SelectedSkins["Sports Gloves"])
                local gloveSource = gloveSkin and gloveSkin:FindFirstChild("Camera") and gloveSkin.Camera:FindFirstChild(WEAR)
                if gloveSource then
                    for _, side in {"Left Arm", "Right Arm"} do
                        local arm, src = obj:FindFirstChild(side), gloveSource:FindFirstChild(side)
                        if arm and src then
                            local gloveMesh = arm:FindFirstChild("Glove")
                            if gloveMesh then
                                local existing = gloveMesh:FindFirstChildOfClass("SurfaceAppearance")
                                if existing then existing:Destroy() end
                                local clone = src:Clone()
                                clone.Name, clone.Parent = "SurfaceAppearance", gloveMesh
                            end
                        end
                    end
                end
            end
        end
        if not GLOVES[model.Name] then
            local weaponFolder = model:FindFirstChild("Weapon")
            if weaponFolder then
                for _, part in weaponFolder:GetDescendants() do
                    if part:IsA("BasePart") then
                        local newSkin = sourceFolder:FindFirstChild(part.Name)
                        if newSkin then
                            local existing = part:FindFirstChildOfClass("SurfaceAppearance")
                            if existing then existing:Destroy() end
                            local clone = newSkin:Clone()
                            clone.Name, clone.Parent = "SurfaceAppearance", part
                        end
                    end
                end
            end
        end
        model:SetAttribute("SkinApplied", skinName)
    end)
end

camera.ChildAdded:Connect(function(obj)
    if not SkinChangerEnabled then return end
    task.wait(COOLDOWN); applyWeaponSkin(obj)
end)

task.spawn(function()
    while task.wait(0.5) do
        if SkinChangerEnabled then
            for _, obj in camera:GetChildren() do
                if SelectedSkins[obj.Name] and obj:GetAttribute("SkinApplied") ~= SelectedSkins[obj.Name] then applyWeaponSkin(obj) end
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- UI CONSTRUCTION (ACXUI Menu with Visuals, SilentAim, Skins, and Menu Settings tabs)
--------------------------------------------------------------------------------

local function makeui()
    lib:SetTitle("Gravel.cc (Fixed & Secured + Drawing ESP & Skins)")
    lib:SetIcon("http://www.roblox.com/asset/?id=132214308111067")
    lib:SetTheme("HighContrast")
    
    lib:CreateTab("Visuals")
    lib:CreateTab("SilentAim")
    lib:CreateTab("Skins")
    lib:CreateTab("Настройка меню")

    -- VISUALS TAB (Drawing ESP & Effects from Script 2)
    lib:Tab("Visuals")
    lib:AddToggle("Enable Player ESP", function(state)
        EspEnabled = state
    end, false)

    lib:AddToggle("Show Box", function(state)
        EspBox = state
    end, true)

    lib:AddToggle("Show Health Bar", function(state)
        EspHealth = state
    end, true)

    lib:AddToggle("Show Name", function(state)
        EspName = state
    end, true)

    lib:AddToggle("Show Distance", function(state)
        EspDistance = state
    end, true)

    lib:AddToggle("Show Skeleton", function(state)
        EspSkeleton = state
    end, false)

    lib:AddToggle("Show Head Dot", function(state)
        EspHeadDot = state
    end, false)

    lib:AddToggle("Show Tracers", function(state)
        EspTracers = state
    end, false)

    lib:AddToggle("Rainbow ESP", function(state)
        RainbowESP = state
    end, false)

    lib:AddToggle("Enable Player Chams", function(state)
        ChamsEnabled = state
        if not state then
            for _, hl in pairs(chamsCache) do
                if hl then hl:Destroy() end
            end
            chamsCache = {}
        end
    end, false)

    lib:AddToggle("Rainbow Chams", function(state)
        RainbowChams = state
    end, false)

    lib:AddToggle("Enable Weapon Chams", function(state)
        WeaponChamsEnabled = state
    end, false)

    lib:AddToggle("Enable Bullet Tracers", function(state)
        BulletTracersEnabled = state
    end, false)

    lib:AddComboBox("Tracer Pattern", {"Straight", "Wave", "Spiral", "Dashed"}, function(selection)
        BulletTracerPattern = selection
    end)

    lib:AddToggle("Enable Particle Effects", function(state)
        ParticleEffectsEnabled = state
    end, false)

    lib:AddComboBox("Particle Style", {"Spark", "Smoke", "Fire", "Explosion", "Magic"}, function(selection)
        ParticleStyle = selection
    end)

    lib:AddToggle("Enable Kill Effects", function(state)
        KillEffectsEnabled = state
    end, false)

    lib:AddToggle("Anti-Flashbang", function(state)
        AntiFlashEnabled = state
    end, false)

    lib:AddToggle("Anti-Smoke", function(state)
        AntiSmokeEnabled = state
    end, false)

    -- SILENT AIM TAB & MOVEMENT (Script 1)
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

    lib:AddToggle("Бани Хоп (Bhop)", function(state)
        BhopEnabled = state
    end, false)

    lib:AddToggle("Длинный Прыжок (Long Jump)", function(state)
        LongJumpEnabled = state
    end, false)

    lib:AddInputBox("Сила прыжка (Long Jump Power)", function(text)
        local n = tonumber(text)
        if n and n > 0 then
            LongJumpPower = n
        end
        return tostring(LongJumpPower)
    end, "60", tostring(LongJumpPower), {min = 10, max = 200, isNumber = true})

    -- SKINS TAB (SkinChanger & Custom Knives from Script 2)
    lib:Tab("Skins")
    lib:AddToggle("Enable Skin Changer", function(state)
        SkinChangerEnabled = state
        if not state then
            for _, obj in camera:GetChildren() do
                obj:SetAttribute("SkinApplied", nil)
            end
        end
    end, false)

    lib:AddToggle("Enable Custom Knife", function(state)
        scriptRunning = state
        if not state then removeViewmodel() end
    end, false)

    lib:AddComboBox("Selected Custom Knife", {"Butterfly Knife", "Karambit", "M9 Bayonet", "Flip Knife", "Gut Knife"}, function(selection)
        selectedKnife = selection
        if spawned then removeViewmodel() end
    end)

    local function setupDropdownForWeapon(weaponName)
        local folder = SkinsFolder:FindFirstChild(weaponName)
        if not folder then return end
        local options = {}
        for _, skin in ipairs(folder:GetChildren()) do
            table.insert(options, skin.Name)
        end
        SkinOptions[weaponName] = options
        if not SelectedSkins[weaponName] and #options > 0 then
            SelectedSkins[weaponName] = options[1]
        end
        if #options > 0 then
            lib:AddComboBox("Skin: " .. weaponName, options, function(selection)
                SelectedSkins[weaponName] = selection
                for _, obj in ipairs(camera:GetChildren()) do
                    obj:SetAttribute("SkinApplied", nil)
                    applyWeaponSkin(obj)
                end
            end)
        end
    end

    for name in pairs(KNIVES) do setupDropdownForWeapon(name) end
    for name in pairs(GLOVES) do setupDropdownForWeapon(name) end
    for name in pairs(CT_ONLY) do setupDropdownForWeapon(name) end
    for name in pairs(SHARED) do setupDropdownForWeapon(name) end
    for _, folder in ipairs(SkinsFolder:GetChildren()) do
        local n = folder.Name
        if not IgnoreFolders[n] and not KNIVES[n] and not GLOVES[n] and not CT_ONLY[n] and not SHARED[n] then
            setupDropdownForWeapon(n)
        end
    end

    -- НАСТРОЙКА МЕНЮ TAB (Menu Button Resizer & Config System)
    lib:Tab("Настройка меню")

    lib:AddInputBox("Масштаб кнопки меню", function(text)
        local n = tonumber(text)
        if n and n >= 0.3 and n <= 2.0 then
            applyMenuButtonScale(n)
        end
        return tostring(MenuButtonScale)
    end, "0.5 - 1.5", tostring(MenuButtonScale), {min = 0.3, max = 2.0, isNumber = true})

    lib:AddInputBox("Имя конфига", function(text)
        if text and text ~= "" then
            currentConfigName = text
        end
        return currentConfigName
    end, "Введите имя...", currentConfigName)

    lib:AddButton("Сохранить конфиг", function()
        saveConfig(currentConfigName)
    end)

    local savedConfigsList = getSavedConfigs()
    lib:AddComboBox("Выберите конфиг", savedConfigsList, function(selection)
        currentConfigName = selection
        loadConfig(selection)
    end)

    lib:AddButton("Загрузить конфиг", function()
        loadConfig(currentConfigName)
    end)
end

makeui()
