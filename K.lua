-- ============================================
-- GRAVEL.CC LEGACY — FULL RECOVERY
-- ИНТЕГРИРОВАНЫ: Silent Aim, Aimbot, WH, FOV Circle
-- УПРАВЛЕНИЕ ЧЕРЕЗ МЕНЮ (iPad friendly)
-- ============================================

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
    -- Silent Aim
    Enabled = false,
    fovsize = 120,
    predic = 1,
    wallc = false,
    bodypart = "Head",
    hitchance = 100,
    targetMode = "Enemies",
    silentGetTarget = "Closest",
    fovc = Color3.fromRGB(255, 0, 0),
    fovct = Color3.fromRGB(255, 255, 0),
    
    -- Aimbot
    aimbotEnabled = false,
    aimbotFOVSize = 100,
    aimbotStrength = 0.5,
    aimbotWallCheck = false,
    aimbotTargetPart = "Head",
    aimbotTeamTarget = "Enemies",
    aimbotCurrentTarget = nil,
    aimbotFOVRing = nil,
    aimbotGetTarget = "Closest",
    aimbot360Enabled = false,
    aimbot360OriginalFOV = 100,
    aimbot360Omnidirectional = true,
    aimbot360BehindRange = 180,
    
    -- Shared
    masterTarget = "Players",
    masterTeamTarget = "Enemies",
    masterGetTarget = "Closest",
    currentTarget = nil,
    activeApplied = {},
    originalSizes = {},
    targethbSizes = {},
    centerLocked = {},
    maxExpansion = math.huge,
    rfd = false,
    looprfd = false,
    
    -- ESP (оставляю как есть)
    espc = Color3.fromRGB(255, 182, 193),
    esptargetc = Color3.fromRGB(255, 255, 0),
    espteamc = Color3.fromRGB(0, 255, 0),
    espEnabled = false,
    prefTextESP = false,
    highlightesp = false,
    prefHighlightESP = false,
    prefBoxESP = false,
    prefHealthESP = false,
    prefColorByHealth = false,
    espMasterEnabled = false,
    prefHeadDotESP = false,
    espData = {},
    highlightData = {},
    playerConnections = {},
    characterConnections = {},
    
    -- Остальное
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
    antiAimGetTarget = "Closest",
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
    gp = 200,
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
    hotkeyConnection = nil,
}

-- ========== NOTIFICATION SYSTEM ==========
local Alurt = loadstring(game:HttpGet("https://raw.githubusercontent.com/azir-py/project/refs/heads/main/Zwolf/AlurtUI.lua"))()

local function safeNotify(opts)
    if typeof(Alurt) == "table" and type(Alurt.CreateNode) == "function" then
        pcall(function()
            Alurt.CreateNode(opts)
        end)
    end
end

safeNotify({
    Title = "Script started!",
    Content = "Gravel.cc Legacy + AIM/SILENT/WH",
    Audio = "rbxassetid://17208361335",
    Length = 3,
    Image = "rbxassetid://4483362458",
    BarColor = Color3.fromRGB(0, 170, 255)
})

-- ========== UI LIBRARY ==========
local lib
do
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/hm5650/ACXUI/refs/heads/main/ACXUI"))()
    end)
    if success and result then
        lib = result
    else
        warn("UI lib failed to load")
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

-- ========== TARGET HELPERS ==========
local function isTeammate(p)
    if not (localPlayer and p) then return false end
    if typeof(p) == "Instance" and p:IsA("Player") then
        if localPlayer.Team and p.Team then
            return localPlayer.Team == p.Team
        end
    end
    return false
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

local function getTargetCharacter(target)
    if not target then return nil end
    if typeof(target) == "Instance" then
        if target:IsA("Player") then return target.Character
        elseif target:IsA("Model") then return target end
    end
    return nil
end

local function getTargetName(target)
    if not target then return "Unknown" end
    if typeof(target) == "Instance" then return target.Name end
    return tostring(target)
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
            if pl ~= localPlayer then table.insert(targets, pl) end
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

local function chooseBodyPartInstance(target)
    local char = getTargetCharacter(target)
    if not char then return nil, "Head" end
    local bp = config.bodypart or "Head"
    if bp == "Head" then return char:FindFirstChild("Head"), "Head"
    elseif bp == "HumanoidRootPart" then return char:FindFirstChild("HumanoidRootPart"), "HumanoidRootPart"
    elseif bp == "Both" then
        local roll = math.random(1, 100)
        if roll <= 85 then
            return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"), "HumanoidRootPart"
        else
            return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"), "Head"
        end
    else
        local found = char:FindFirstChild(bp) or char:FindFirstChild("Head")
        return found, (found and found.Name) or "Head"
    end
end

-- ========== WALL CHECK ==========
local function wallCheck(targetPos, sourcePos)
    if not config.wallc then return true end
    if (targetPos - sourcePos).Magnitude <= 0 then return true end
    local rayDirection = (targetPos - sourcePos)
    local ray = Ray.new(sourcePos, rayDirection.Unit * rayDirection.Magnitude)
    local ignoreList = {}
    if localPlayer and localPlayer.Character then table.insert(ignoreList, localPlayer.Character) end
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer.Character then table.insert(ignoreList, otherPlayer.Character) end
    end
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    if hit and position then
        local distanceToTarget = (targetPos - sourcePos).Magnitude
        local distanceToHit = (position - sourcePos).Magnitude
        return distanceToHit >= (distanceToTarget - 2)
    end
    return true
end

local function aimbotWallCheck(targetPos, sourcePos)
    if not config.aimbotWallCheck then return true end
    return wallCheck(targetPos, sourcePos)
end

-- ========== SILENT AIM HOOK ==========
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    
    if config.Enabled and Method == "FindPartOnRayWithIgnoreList" then
        -- Ищем цель через RenderStep
        local target = config.currentTarget
        if target and plralive(target) then
            local part, _ = chooseBodyPartInstance(target)
            if part and math.random(1, 100) <= config.hitchance then
                local OriginalRay = Args[1]
                if OriginalRay then
                    local Origin = OriginalRay.Origin
                    local NewDirection = (part.Position - Origin).Unit * OriginalRay.Direction.Magnitude
                    Args[1] = Ray.new(Origin, NewDirection)
                    return OldNamecall(self, table.unpack(Args))
                end
            end
        end
    end
    
    return OldNamecall(self, ...)
end)

-- ========== SILENT AIM RENDER ==========
local function onRenderStep()
    if not camera or not camera.Parent then
        camera = workspace.CurrentCamera
        if not camera then return end
    end

    -- FOV Circle visibility
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

    local candidates = {}
    for _, pl in ipairs(getAllTargets()) do
        local bodyPart, chosenName = chooseBodyPartInstance(pl)
        local humanoid = nil
        local char = getTargetCharacter(pl)
        if char then humanoid = char:FindFirstChildOfClass("Humanoid") end

        if bodyPart and humanoid and humanoid.Health > 0 then
            local mode = config.targetMode or "Enemies"
            local skip = false
            if mode == "Enemies" then
                if typeof(pl) == "Instance" and pl:IsA("Player") and isTeammate(pl) then skip = true end
            elseif mode == "Teams" then
                if typeof(pl) == "Instance" and pl:IsA("Player") and not isTeammate(pl) then skip = true end
            end

            if not skip then
                local screenPos3, onScreen = camera:WorldToViewportPoint(bodyPart.Position)
                if onScreen then
                    local screenVec = Vector2.new(screenPos3.X, screenPos3.Y)
                    local distPx = (screenVec - center).Magnitude
                    if distPx <= radiusPx then
                        local cameraPos = camera.CFrame.Position
                        if wallCheck(bodyPart.Position, cameraPos) then
                            local worldDist = (cameraPos - bodyPart.Position).Magnitude
                            table.insert(candidates, {
                                player = pl,
                                part = bodyPart,
                                partName = chosenName,
                                screenDist = distPx,
                                worldDist = worldDist,
                                screenPos = screenVec,
                                humanoid = humanoid
                            })
                        end
                    end
                end
            end
        end
    end

    -- Выбор цели
    local best = nil
    local selectionMode = config.silentGetTarget or "Closest"
    if #candidates > 0 then
        if selectionMode == "Lowest Health" then
            local bestHealth = math.huge
            for _, c in ipairs(candidates) do
                local h = c.humanoid and c.humanoid.Health or math.huge
                if best == nil or h < bestHealth then bestHealth = h; best = c end
            end
        else
            local bestWorldDist = math.huge
            for _, c in ipairs(candidates) do
                if c.worldDist < bestWorldDist then bestWorldDist = c.worldDist; best = c end
            end
        end
    end

    -- Цвет FOV кольца
    if best then
        gui.RingStroke.Color = config.fovct
    else
        gui.RingStroke.Color = config.fovc
    end

    config.currentTarget = best and best.player or nil
end

-- ========== AIMBOT RENDER ==========
local function getAimbotTargetPart(target)
    if not target then return nil end
    local partName = config.aimbotTargetPart or "Head"
    local char = getTargetCharacter(target)
    if not char then return nil end
    if partName == "Head" then return char:FindFirstChild("Head")
    elseif partName == "HumanoidRootPart" then return char:FindFirstChild("HumanoidRootPart")
    elseif partName == "Torso" then return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    else return char:FindFirstChild("Head") end
end

local function aimbotUpdate()
    if not config.aimbotEnabled then
        config.aimbotCurrentTarget = nil
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
        if target ~= localPlayer and plralive(target) then
            local shouldTarget = false
            local mode = config.aimbotTeamTarget or "Enemies"
            if typeof(target) == "Instance" and target:IsA("Model") then
                if config.masterTarget == "NPCs" or config.masterTarget == "Both" then shouldTarget = true end
            else
                if mode == "Enemies" then shouldTarget = not isTeammate(target)
                elseif mode == "Teams" then shouldTarget = isTeammate(target)
                elseif mode == "All" then shouldTarget = true end
            end
            
            if shouldTarget then
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
                                humanoid = humanoid
                            })
                        end
                    end
                end
            end
        end
    end

    local bestCandidate = nil
    local selectionMode = config.aimbotGetTarget or "Closest"
    if #candidates > 0 then
        if selectionMode == "Lowest Health" then
            local bestHealth = math.huge
            for _, c in ipairs(candidates) do
                local h = c.humanoid and c.humanoid.Health or math.huge
                if bestCandidate == nil or h < bestHealth then bestHealth = h; bestCandidate = c end
            end
        else
            local bestDist = math.huge
            for _, c in ipairs(candidates) do
                if c.worldDist < bestDist then bestDist = c.worldDist; bestCandidate = c end
            end
        end
    end

    config.aimbotCurrentTarget = bestCandidate and bestCandidate.target or nil
    
    if bestCandidate and bestCandidate.part and localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local targetCFrame = CFrame.lookAt(camera.CFrame.Position, bestCandidate.part.Position)
            local strength = math.clamp(config.aimbotStrength, 0, 1)
            if strength < 1 then
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, strength)
            else
                camera.CFrame = targetCFrame
            end
        end
    end
end

-- ========== FOV RING CREATION ==========
local function createFOVRing()
    local fovScreenGui = Instance.new("ScreenGui")
    fovScreenGui.Name = "FOVToggleGui_Modern"
    fovScreenGui.ResetOnSpawn = false
    fovScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    fovScreenGui.Parent = game:GetService("CoreGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = fovScreenGui

    local ringHolder = Instance.new("Frame")
    ringHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    ringHolder.Size = UDim2.new(0, config.fovsize * 2, 0, config.fovsize * 2)
    ringHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    ringHolder.BackgroundTransparency = 1
    ringHolder.Parent = mainFrame

    local ringCorner = Instance.new("UICorner")
    ringCorner.CornerRadius = UDim.new(1, 0)
    ringCorner.Parent = ringHolder

    local ringStroke = Instance.new("UIStroke")
    ringStroke.Thickness = 2
    ringStroke.LineJoinMode = Enum.LineJoinMode.Round
    ringStroke.Color = config.fovc
    ringStroke.Transparency = 0
    ringStroke.Parent = ringHolder

    gui.ScreenGui = fovScreenGui
    gui.RingHolder = ringHolder
    gui.RingStroke = ringStroke
end

local function updateFOVRingSize()
    if gui.RingHolder then
        gui.RingHolder.Size = UDim2.new(0, config.fovsize * 2, 0, config.fovsize * 2)
    end
end

-- ========== AIMBOT FOV RING ==========
local function aimbotfov()
    if config.aimbotFOVRing and config.aimbotFOVRing.RingFrame then
        config.aimbotFOVRing.RingFrame:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimbotFOVRing"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    
    local ringFrame = Instance.new("Frame")
    ringFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ringFrame.Size = UDim2.new(0, config.aimbotFOVSize * 2, 0, config.aimbotFOVSize * 2)
    ringFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    ringFrame.BackgroundTransparency = 1
    ringFrame.Visible = config.aimbotEnabled
    ringFrame.Parent = screenGui
    
    local ringCorner = Instance.new("UICorner")
    ringCorner.CornerRadius = UDim.new(1, 0)
    ringCorner.Parent = ringFrame
    
    local ringStroke = Instance.new("UIStroke")
    ringStroke.Thickness = 2
    ringStroke.LineJoinMode = Enum.LineJoinMode.Round
    ringStroke.Color = Color3.fromRGB(255, 100, 100)
    ringStroke.Transparency = 0.3
    ringStroke.Parent = ringFrame
    
    config.aimbotFOVRing = { ScreenGui = screenGui, RingFrame = ringFrame, RingStroke = ringStroke }
end

local function updateAimbotFOVRing()
    if config.aimbotFOVRing and config.aimbotFOVRing.RingFrame then
        if config.aimbot360Enabled then
            config.aimbotFOVRing.RingFrame.Visible = false
        else
            config.aimbotFOVRing.RingFrame.Size = UDim2.new(0, config.aimbotFOVSize * 2, 0, config.aimbotFOVSize * 2)
            config.aimbotFOVRing.RingFrame.Visible = config.aimbotEnabled
        end
    end
end

local function toggle360Aimbot(state)
    config.aimbot360Enabled = state
    if state then
        config.aimbot360OriginalFOV = config.aimbotFOVSize
        if not config.aimbotEnabled then config.aimbotEnabled = true end
    else
        if config.aimbot360OriginalFOV then config.aimbotFOVSize = config.aimbot360OriginalFOV end
    end
    updateAimbotFOVRing()
end

-- ========== INIT ==========
local function init()
    createFOVRing()
    aimbotfov()
    
    -- Bind render steps
    RunService:BindToRenderStep("SilentAimRender", Enum.RenderPriority.First.Value, onRenderStep)
    RunService:BindToRenderStep("AimbotRender", Enum.RenderPriority.First.Value + 1, aimbotUpdate)
end

-- ========== BUILD UI ==========
local function makeui()
    lib:SetTitle("Gravel.cc (Legacy)")
    lib:SetIcon("http://www.roblox.com/asset/?id=132214308111067")
    lib:SetTheme("HighContrast")
    
    -- TABS
    lib:CreateTab("SilentAim")
    lib:CreateTab("Aimbot")
    lib:CreateTab("Visuals")
    lib:CreateTab("Client")
    lib:CreateTab("Main")
    lib:CreateTab("Hitbox")
    lib:CreateTab("AntiAim")

    -- ==================== SILENT AIM TAB ====================
    lib:Tab("SilentAim")
    lib:AddToggle("Toggle SilentAim", function(state)
        config.Enabled = state
        if not state then
            gui.RingHolder.Visible = false
        else
            gui.RingHolder.Visible = true
        end
        safeNotify({ Title = "SilentAim", Content = state and "ON" or "OFF", Length = 1, BarColor = state and Color3.fromRGB(255,100,0) or Color3.fromRGB(255,0,0) })
    end, false)
    
    lib:AddToggle("WallCheck", function(state)
        config.wallc = state
        safeNotify({ Title = "WH", Content = state and "ON" or "OFF", Length = 1, BarColor = state and Color3.fromRGB(0,170,255) or Color3.fromRGB(255,0,0) })
    end, false)

    lib:AddComboBox("Team Target", {"Enemies", "Teams", "All"}, function(sel)
        config.targetMode = sel
    end)

    lib:AddComboBox("Target Part", {"Head", "HumanoidRootPart", "Both"}, function(sel)
        config.bodypart = sel
    end)
    
    lib:AddComboBox("GetTarget", {"Closest", "Lowest Health"}, function(sel)
        config.silentGetTarget = sel
    end)
    
    lib:AddInputBox("HitChance", function(text)
        local n = tonumber(text)
        if n and n >= 0 and n <= 100 then config.hitchance = n end
        return tostring(config.hitchance)
    end, "0-100", "100", { min = 0, max = 100, isNumber = true })
    
    lib:AddInputBox("FovSize", function(text)
        local n = tonumber(text)
        if n and n >= 1 then
            config.fovsize = n
            updateFOVRingSize()
            return tostring(config.fovsize)
        end
        return tostring(config.fovsize)
    end, "Enter Value...", "120", { min = 1, max = 500, isNumber = true })

    -- ==================== AIMBOT TAB ====================
    lib:Tab("Aimbot")
    lib:AddToggle("Toggle Aimbot", function(state)
        config.aimbotEnabled = state
        if config.aimbotFOVRing and config.aimbotFOVRing.RingFrame then
            config.aimbotFOVRing.RingFrame.Visible = state
        end
        safeNotify({ Title = "Aimbot", Content = state and "ON" or "OFF", Length = 1, BarColor = state and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0) })
    end, false)
    
    lib:AddToggle("WallCheck", function(state)
        config.aimbotWallCheck = state
    end, false)
    
    lib:AddToggle("360° Aimbot", function(state)
        toggle360Aimbot(state)
    end, false)
    
    lib:AddComboBox("Team Target", {"Enemies", "Teams", "All"}, function(sel)
        config.aimbotTeamTarget = sel
    end)
    
    lib:AddComboBox("Target Part", {"Head", "HumanoidRootPart", "Torso"}, function(sel)
        config.aimbotTargetPart = sel
    end)
    
    lib:AddComboBox("GetTarget", {"Closest", "Lowest Health"}, function(sel)
        config.aimbotGetTarget = sel
    end)
    
    lib:AddInputBox("Aim Strength", function(text)
        local n = tonumber(text)
        if n and n >= 0 and n <= 1 then config.aimbotStrength = n end
        return tostring(config.aimbotStrength)
    end, "0-1", "0.5", { min = 0, max = 1, isNumber = true })
    
    lib:AddInputBox("FOV Size", function(text)
        local n = tonumber(text)
        if n and n >= 1 then
            config.aimbotFOVSize = n
            updateAimbotFOVRing()
            return tostring(config.aimbotFOVSize)
        end
        return tostring(config.aimbotFOVSize)
    end, "Enter Value...", "100", { min = 1, max = 500, isNumber = true })

    -- ==================== VISUALS TAB ====================
    lib:Tab("Visuals")
    lib:AddToggle("Enable ESP", function(state)
        config.espMasterEnabled = state
    end, false)
    lib:AddToggle("Text ESP", function(state)
        config.prefTextESP = state
    end, false)
    lib:AddToggle("Box ESP", function(state)
        config.prefBoxESP = state
    end, false)

    -- ==================== CLIENT TAB ====================
    lib:Tab("Client")
    lib:AddToggle("Noclip", function(state)
        config.clientNoclip = state
    end, false)
    lib:AddInputBox("WalkSpeed", function(text)
        local n = tonumber(text)
        if n then config.clientWalkSpeed = n end
        return tostring(config.clientWalkSpeed)
    end, "Speed", "16", { min = 1, max = 9999, isNumber = true })

    -- ==================== MAIN TAB ====================
    lib:Tab("Main")
    lib:AddComboBox("Target", {"Players", "NPCs", "Both"}, function(sel)
        config.masterTarget = sel
    end)
    lib:AddComboBox("Master Team Target", {"Enemies", "Teams", "All"}, function(sel)
        config.masterTeamTarget = sel
        config.targetMode = sel
        config.aimbotTeamTarget = sel
    end)
    lib:AddComboBox("Master GetTarget", {"Closest", "Lowest Health"}, function(sel)
        config.masterGetTarget = sel
        config.silentGetTarget = sel
        config.aimbotGetTarget = sel
    end)

    return lib
end

makeui()
init()

safeNotify({
    Title = "Gravel.cc + AIM/WH",
    Content = "Loaded! SilentAim + Aimbot ready",
    Audio = "rbxassetid://17208361335",
    Length = 5,
    Image = "rbxassetid://4483362458",
    BarColor = Color3.fromRGB(0, 170, 255)
})

return { cleanup = function()
    pcall(function() RunService:UnbindFromRenderStep("SilentAimRender") end)
    pcall(function() RunService:UnbindFromRenderStep("AimbotRender") end)
end }
