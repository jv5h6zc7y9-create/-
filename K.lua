local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/twistedk1d/BloxStrike/refs/heads/main/Source/UI/source.lua"))()

--// Window creation
local Window = Rayfield:CreateWindow({
    Name = "Sqilss",
    Icon = 0,
    LoadingTitle = "loading Sqilss (Blox Strike)",
    LoadingSubtitle = "by Sqilss",
    ShowText = "Menu",
    Theme = "Bloom",
    ToggleUIKeybind = Enum.KeyCode.RightShift,
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Sqilss",
        FileName = "Sqilss_config"
    }
})

--// Services & Globals
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CAS = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local CharactersFolder = Workspace:WaitForChild("Characters", 10)

--// TABS
local Tab_Combat = Window:CreateTab("Combat", "crosshair")
local Tab_Skins = Window:CreateTab("Skins", "swords")
local Tab_Visuals = Window:CreateTab("Visuals", "eye")

Tab_Skins:CreateLabel("skin changerby twistedk1d (not made by me)", "code", Color3.fromRGB(80,80,80), false)

--// SHARED LOGIC
local function getTFolder() return CharactersFolder:FindFirstChild("Terrorists") end
local function getCTFolder() return CharactersFolder:FindFirstChild("Counter-Terrorists") end
local function isAlive()
    local t, ct = getTFolder(), getCTFolder()
    return (t and t:FindFirstChild(player.Name)) or (ct and ct:FindFirstChild(player.Name))
end
local function getEnemyFolder()
    if not isAlive() then return nil end
    local t, ct = getTFolder(), getCTFolder()
    if t and t:FindFirstChild(player.Name) then return ct end
    if ct and ct:FindFirstChild(player.Name) then return t end
    return nil
end

--// SILENT AIM / HITBOX CONFIG & LOGIC (from script 2)
local silentConfig = {
    Enabled = false,
    fovsize = 120,
    wallc = false,
    bodypart = "Head",
    targetMode = "Enemies",
    maxExpansion = 4.5,
    originalSizes = {},
    targethbSizes = {},
    activeApplied = {},
    currentTarget = nil,
    fovc = Color3.fromRGB(100, 0, 0),
    fovct = Color3.fromRGB(255, 255, 0),
}

local guiFOV = {}

local function isTeammate(p)
    if not (localPlayer and p) then return false end
    if typeof(p) == "Instance" and p:IsA("Player") then
        if p == localPlayer then return true end
        if localPlayer.Team and p.Team then
            return localPlayer.Team == p.Team
        end
    end
    return false
end

local function updateTeamTargetModes()
    silentConfig.currentTarget = nil
end

local function getAllTargets()
    local targets = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= localPlayer then
            table.insert(targets, pl)
        end
    end
    return targets
end

local function getTargetCharacter(target)
    if not target then return nil end
    if typeof(target) == "Instance" and target:IsA("Player") then
        return target.Character
    end
    return nil
end

local function getTargetName(target)
    if not target then return "Unknown" end
    if typeof(target) == "Instance" then return target.Name end
    return tostring(target)
end

local function addesp_silent(targetPlayer)
    if not targetPlayer or targetPlayer == localPlayer then return false end
    local mode = silentConfig.targetMode or "Enemies"
    if mode == "Enemies" then
        return not isTeammate(targetPlayer)
    elseif mode == "Teams" then
        return isTeammate(targetPlayer)
    elseif mode == "All" then
        return true
    end
    return not isTeammate(targetPlayer)
end

local function plralive(target)
    local char = getTargetCharacter(target)
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end

local function RFD(targetPlayer)
    local char = getTargetCharacter(targetPlayer)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("Decal") then
                pcall(function() child:Destroy() end)
            end
        end
    end
end

local function wallCheck(targetPos, sourcePos)
    if not silentConfig.wallc then return true end
    if (targetPos - sourcePos).Magnitude <= 0 then return true end

    local rayDirection = (targetPos - sourcePos)
    local ray = Ray.new(sourcePos, rayDirection.Unit * rayDirection.Magnitude)
    local ignoreList = {camera}
    if localPlayer.Character then table.insert(ignoreList, localPlayer.Character) end

    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    if hit and position then
        local distanceToTarget = (targetPos - sourcePos).Magnitude
        local distanceToHit = (position - sourcePos).Magnitude
        return distanceToHit >= (distanceToTarget - 2)
    end
    return true
end

local function chooseBodyPartInstance(target)
    local char = getTargetCharacter(target)
    if not char then return nil, "Head" end
    local bp = silentConfig.bodypart or "Head"
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
    if not silentConfig.originalSizes[targetPlayer] then
        silentConfig.originalSizes[targetPlayer] = {
            partName = part.Name or "Head",
            size = part.Size,
        }
    end
end

local function applySizeToPart(targetPlayer, targetDiameter, chosenPart)
    if not addesp_silent(targetPlayer) then return end
    local char = getTargetCharacter(targetPlayer)
    if not char or targetPlayer == localPlayer or not plralive(targetPlayer) then return end

    local part = chosenPart or select(1, chooseBodyPartInstance(targetPlayer))
    if not part then return end

    if not silentConfig.originalSizes[targetPlayer] then
        saveOriginalPartInfo(targetPlayer, part)
    end

    targetDiameter = math.clamp(targetDiameter, 0.1, silentConfig.maxExpansion)
    silentConfig.targethbSizes[targetPlayer] = Vector3.new(targetDiameter, targetDiameter, targetDiameter)
    silentConfig.activeApplied[targetPlayer] = true
end

local function restorePartForPlayer(targetPlayer)
    if not targetPlayer or targetPlayer == localPlayer then return end
    local char = getTargetCharacter(targetPlayer)
    local original = silentConfig.originalSizes[targetPlayer]
    if not original then
        silentConfig.activeApplied[targetPlayer] = nil
        silentConfig.targethbSizes[targetPlayer] = nil
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

    silentConfig.activeApplied[targetPlayer] = nil
    silentConfig.originalSizes[targetPlayer] = nil
    silentConfig.targethbSizes[targetPlayer] = nil
end

RunService.Heartbeat:Connect(function()
    for playerObj, targetSize in pairs(silentConfig.targethbSizes) do
        if playerObj and playerObj ~= localPlayer and addesp_silent(playerObj) and plralive(playerObj) then
            local original = silentConfig.originalSizes[playerObj]
            local char = getTargetCharacter(playerObj)
            local part = char and char:FindFirstChild(original and original.partName or silentConfig.bodypart)
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
    ringHolder.Size = UDim2.new(0, silentConfig.fovsize * 2, 0, silentConfig.fovsize * 2)
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
    ringStroke.Color = silentConfig.fovc
    ringStroke.Transparency = 0.3
    ringStroke.Parent = ringHolder

    guiFOV.ScreenGui = screenGui
    guiFOV.RingHolder = ringHolder
    guiFOV.RingStroke = ringStroke
end

initFOV()

RunService.RenderStepped:Connect(function()
    if not guiFOV.RingHolder then return end
    if not silentConfig.Enabled then
        guiFOV.RingHolder.Visible = false
        return
    else
        guiFOV.RingHolder.Visible = true
    end

    local viewportSize = camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local radiusPx = silentConfig.fovsize
    local candidates = {}

    for _, pl in ipairs(getAllTargets()) do
        if addesp_silent(pl) then
            local bodyPart, chosenName = chooseBodyPartInstance(pl)
            local char = getTargetCharacter(pl)
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            if bodyPart and humanoid and humanoid.Health > 0 then
                local screenPos3, onScreen = camera:WorldToViewportPoint(bodyPart.Position)
                if onScreen then
                    local screenVec = Vector2.new(screenPos3.X, screenPos3.Y)
                    local distPx = (screenVec - center).Magnitude
                    if distPx <= radiusPx then
                        if wallCheck(bodyPart.Position, camera.CFrame.Position) then
                            table.insert(candidates, {
                                player = pl,
                                part = bodyPart,
                                screenDist = distPx,
                            })
                        end
                    end
                end
            end
        end
    end

    table.sort(candidates, function(a, b) return a.screenDist < b.screenDist end)
    local best = candidates[1]

    if best then
        guiFOV.RingStroke.Color = silentConfig.fovct
    else
        guiFOV.RingStroke.Color = silentConfig.fovc
    end

    silentConfig.currentTarget = best and best.player

    for pl, _ in pairs(silentConfig.activeApplied) do
        if not best or pl ~= best.player or not plralive(pl) or not addesp_silent(pl) then
            restorePartForPlayer(pl)
        end
    end

    if best and plralive(best.player) and addesp_silent(best.player) then
        applySizeToPart(best.player, 2.5, best.part)
    end
end)

--// TriggerBot, Bhop
local TriggerBotEnabled = false
local TriggerBotDelay = 0
Tab_Combat:CreateSection("Silent Aim Settings")
Tab_Combat:CreateToggle({Name = "Enable Silent Aim", CurrentValue = false, Flag = "SilentAimToggle", Callback = function(Value) 
    silentConfig.Enabled = Value
    if not Value and guiFOV.RingHolder then guiFOV.RingHolder.Visible = false end
end})
Tab_Combat:CreateToggle({Name = "WallCheck SA", CurrentValue = false, Flag = "SilentAimWallCheck", Callback = function(Value) silentConfig.wallc = Value end})
Tab_Combat:CreateDropdown({Name = "Team Target", Options = {"Enemies", "Teams", "All"}, CurrentOption = {"Enemies"}, Flag = "SilentAimTeamTarget", Callback = function(Option)
    silentConfig.targetMode = Option[1]
    updateTeamTargetModes()
end})
Tab_Combat:CreateDropdown({Name = "Target Part", Options = {"Head", "HumanoidRootPart", "Both"}, CurrentOption = {"Head"}, Flag = "SilentAimTargetPart", Callback = function(Option)
    for pl, _ in pairs(silentConfig.activeApplied) do restorePartForPlayer(pl) end
    silentConfig.bodypart = Option[1]
end})
Tab_Combat:CreateSlider({Name = "FOV Size", Range = {10, 500}, Increment = 5, Suffix = "px", CurrentValue = 120, Flag = "SilentAimFOVSize", Callback = function(Value)
    silentConfig.fovsize = Value
    if guiFOV.RingHolder then
        guiFOV.RingHolder.Size = UDim2.new(0, silentConfig.fovsize * 2, 0, silentConfig.fovsize * 2)
    end
end})

Tab_Combat:CreateSection("TriggerBot Settings")
Tab_Combat:CreateToggle({Name = "Enable TriggerBot", CurrentValue = false, Flag = "TriggerBotToggle", Callback = function(Value) TriggerBotEnabled = Value end})
Tab_Combat:CreateSlider({Name = "Shot Delay", Range = {0, 500}, Increment = 10, Suffix = "ms", CurrentValue = 0, Flag = "TriggerBotDelay", Callback = function(Value) TriggerBotDelay = Value end})

task.spawn(function()
    while task.wait(0.01) do
        if TriggerBotEnabled and isAlive() then
            local viewportSize = camera.ViewportSize
            local ray = camera:ViewportPointToRay(viewportSize.X / 2, viewportSize.Y / 2)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            local ignoreList = {camera}
            if player.Character then table.insert(ignoreList, player.Character) end
            raycastParams.FilterDescendantsInstances = ignoreList
            local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            if result and result.Instance then
                local hitPart = result.Instance
                local model = hitPart:FindFirstAncestorOfClass("Model")
                if model and model:FindFirstChildOfClass("Humanoid") then
                    local enemyFolder = getEnemyFolder()
                    if enemyFolder and model.Parent == enemyFolder then
                        local hum = model:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            if TriggerBotDelay > 0 then task.wait(TriggerBotDelay / 1000) end
                            if mouse1click then mouse1click() end
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end
end)

local BhopEnabled = false
Tab_Combat:CreateSection("Movement Settings")
Tab_Combat:CreateToggle({Name = "Enable Bunny Hop (Hold Space)", CurrentValue = false, Flag = "BhopToggle", Callback = function(Value) BhopEnabled = Value end})

RunService.RenderStepped:Connect(function()
    if BhopEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) and isAlive() then
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                hum.Jump = true
            end
        end
    end
end)

--// SKINS TAB (from script 1)
local scriptRunning = false
local selectedKnife = "Butterfly Knife"
local spawned = false
local inspecting = false
local swinging = false
local lastAttackTime = 0
local ATTACK_COOLDOWN = 1
local ACTION_INSPECT = "InspectKnifeAction"
local ACTION_ATTACK = "AttackKnifeAction"

pcall(function() RS.Assets.Weapons.Karambit.Camera.ViewmodelLight.Transparency = 1 end)

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
    local weaponSounds = RS.Sounds:FindFirstChild(selectedKnife)
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
    if inputState ~= Enum.UserInputState.Begin or not spawned or not animator or not isAlive() then return Enum.ContextActionResult.Pass end
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
    CAS:UnbindAction(ACTION_INSPECT)
    CAS:UnbindAction(ACTION_ATTACK)
    if vm then vm:Destroy() vm = nil end
    animator, inspecting, swinging = nil, false, false
end

local function spawnViewmodel(knife)
    if spawned or not scriptRunning then return end
    local myModel = isAlive()
    if not myModel then return end
    spawned = true
    local knifeTemplate = RS.Assets.Weapons:WaitForChild(selectedKnife)
    local knifeOffset = knives[selectedKnife].Offset
    vm = knifeTemplate:WaitForChild("Camera"):Clone()
    vm.Name, vm.Parent = selectedKnife, camera
    disableCollisions(vm)
    hideOriginalKnife(knife)
    if myModel.Parent.Name == "Terrorists" then
        local tGloves = RS.Assets.Weapons:WaitForChild("T Glove")
        attachAsset(tGloves, "Left Arm", "Left Arm", "Glove", CFrame.new(0, 0, -1.5))
        attachAsset(tGloves, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
    else
        local sleeves = RS.Assets.Sleeves:WaitForChild("IDF")
        local ctGloves = RS.Assets.Weapons:WaitForChild("CT Glove")
        attachAsset(sleeves, "Left Arm", "Left Arm", "Sleeve", CFrame.new(0, 0, 0.5))
        attachAsset(ctGloves, "Left Arm", "Left Arm", "Glove", CFrame.new(0, 0, -1.5))
        attachAsset(sleeves, "Right Arm", "Right Arm", "Sleeve", CFrame.new(0, 0, 0.5))
        attachAsset(ctGloves, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
    end
    local animController = vm:FindFirstChildOfClass("AnimationController") or vm:FindFirstChildOfClass("Animator")
    animator = animController:FindFirstChildWhichIsA("Animator") or animController
    local animFolder = RS.Assets.WeaponAnimations:WaitForChild(selectedKnife):WaitForChild("CameraAnimations")
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
    CAS:BindAction(ACTION_INSPECT, handleAction, false, Enum.KeyCode.F)
    CAS:BindAction(ACTION_ATTACK, handleAction, false, Enum.UserInputType.MouseButton1)
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
        local living = isAlive()
        local currentKnife = getKnifeInCamera()
        if scriptRunning and living and currentKnife and not spawned then
            spawnViewmodel(currentKnife)
        elseif (not scriptRunning or not currentKnife or not living) and spawned then
            removeViewmodel()
        end
    end
end)

local SkinChangerEnabled = false
local SelectedSkins = {}
local DropdownObjects = {}
local SkinOptions = {}
local COOLDOWN = 0.1
local WEAR = "Factory New"
local CT_ONLY = {["USP-S"]=true, ["Five-SeveN"]=true, ["MP9"]=true, ["FAMAS"]=true, ["M4A1-S"]=true, ["M4A4"]=true, ["AUG"]=true}
local SHARED = {["P250"]=true, ["Desert Eagle"]=true, ["Dual Berettas"]=true, ["Negev"]=true, ["P90"]=true, ["Nova"]=true, ["XM1014"]=true, ["AWP"]=true, ["SSG 08"]=true}
local KNIVES = {["Karambit"]=true, ["Butterfly Knife"]=true, ["M9 Bayonet"]=true, ["Flip Knife"]=true, ["Gut Knife"]=true, ["T Knife"]=true, ["CT Knife"]=true}
local GLOVES = {["Sports Gloves"]=true}
local SkinsFolder = RS:WaitForChild("Assets"):WaitForChild("Skins")
local IgnoreFolders = {["HE Grenade"]=true, ["Incendiary Grenade"]=true, ["Molotov"]=true, ["Smoke Grenade"]=true, ["Flashbang"]=true, ["Decoy Grenade"]=true, ["C4"]=true, ["CT Glove"]=true, ["T Glove"]=true}

local function applyWeaponSkin(model)
    if not model or not SkinChangerEnabled or not isAlive() then return end
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

Tab_Skins:CreateToggle({Name = "Enable Skin Changer", CurrentValue = false, Flag = "SkinChangerToggle", Callback = function(Value) SkinChangerEnabled = Value; if not Value then for _, obj in camera:GetChildren() do obj:SetAttribute("SkinApplied", nil) end end end})
Tab_Skins:CreateButton({Name = "🎲 Randomize All Skins", Callback = function()
    for weaponName, optionsList in pairs(SkinOptions) do
        if #optionsList > 0 then
            local randomSkin = optionsList[math.random(1, #optionsList)]
            if DropdownObjects[weaponName] then
                for _, dropdown in ipairs(DropdownObjects[weaponName]) do dropdown:Set({randomSkin}) end
            end
        end
    end
end})

local function CreateSkinDropdown(weaponName)
    local folder = SkinsFolder:FindFirstChild(weaponName)
    if not folder then return end
    local options = {}
    for _, skin in folder:GetChildren() do table.insert(options, skin.Name) end
    SkinOptions[weaponName] = options
    if not SelectedSkins[weaponName] then SelectedSkins[weaponName] = options[1] end
    local dp = Tab_Skins:CreateDropdown({
        Name = weaponName,
        Options = options,
        CurrentOption = {SelectedSkins[weaponName]},
        Flag = "Skin_" .. weaponName,
        Callback = function(opt)
            local newSkin = opt[1]
            SelectedSkins[weaponName] = newSkin
            if DropdownObjects[weaponName] then
                for _, other in DropdownObjects[weaponName] do
                    if other.CurrentOption[1] ~= newSkin then other:Set({newSkin}) end
                end
            end
            for _, obj in camera:GetChildren() do obj:SetAttribute("SkinApplied", nil); applyWeaponSkin(obj) end
        end
    })
    DropdownObjects[weaponName] = DropdownObjects[weaponName] or {}
    table.insert(DropdownObjects[weaponName], dp)
end

Tab_Skins:CreateToggle({Name = "Enable Custom Knife", CurrentValue = false, Flag = "KnifeToggle", Callback = function(Value) scriptRunning = Value; if not Value then removeViewmodel() end end})
Tab_Skins:CreateDropdown({Name = "Selected Custom Knife", Options = {"Butterfly Knife", "Karambit", "M9 Bayonet", "Flip Knife", "Gut Knife"}, CurrentOption = {"Butterfly Knife"}, MultipleOptions = false, Flag = "KnifeDropdown", Callback = function(Options) selectedKnife = Options[1]; if spawned then removeViewmodel() end end})

Tab_Skins:CreateSection("Knives Skins")
for name in pairs(KNIVES) do CreateSkinDropdown(name) end
Tab_Skins:CreateSection("Gloves")
for name in pairs(GLOVES) do CreateSkinDropdown(name) end
Tab_Skins:CreateSection("CT Weapons")
for name in pairs(CT_ONLY) do CreateSkinDropdown(name) end
Tab_Skins:CreateSection("T Weapons")
for name in pairs(SHARED) do CreateSkinDropdown(name) end
for _, folder in SkinsFolder:GetChildren() do
    local n = folder.Name
    if not IgnoreFolders[n] and not KNIVES[n] and not GLOVES[n] and not CT_ONLY[n] and not SHARED[n] then CreateSkinDropdown(n) end
end

camera.ChildAdded:Connect(function(obj)
    if not SkinChangerEnabled or not isAlive() then return end
    task.wait(COOLDOWN); applyWeaponSkin(obj)
end)

task.spawn(function()
    while task.wait(0.5) do
        if SkinChangerEnabled and isAlive() then
            for _, obj in camera:GetChildren() do
                if SelectedSkins[obj.Name] and obj:GetAttribute("SkinApplied") ~= SelectedSkins[obj.Name] then applyWeaponSkin(obj) end
            end
        end
    end
end)

--// ESP + CHAMS + WH (from script 1)
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
    if not EspEnabled or not isAlive() then
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

    local enemyFolder = getEnemyFolder()
    if not enemyFolder then return end

    local currentAlive = {}
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    local rainbowColor = RainbowESP and getRainbowColor(RainbowESP_Speed) or nil

    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        local root = enemy:FindFirstChild("HumanoidRootPart")
        local head = enemy:FindFirstChild("Head")

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
                    esp.name.Text = enemy.Name
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
                    local neck = enemy:FindFirstChild("Neck") or head
                    local torso = enemy:FindFirstChild("UpperTorso") or enemy:FindFirstChild("Torso")
                    local leftUpper = enemy:FindFirstChild("LeftUpperArm")
                    local rightUpper = enemy:FindFirstChild("RightUpperArm")
                    local leftLower = enemy:FindFirstChild("LeftLowerArm")
                    local rightLower = enemy:FindFirstChild("RightLowerArm")
                    local leftFoot = enemy:FindFirstChild("LeftFoot") or enemy:FindFirstChild("Left Leg")
                    local rightFoot = enemy:FindFirstChild("RightFoot") or enemy:FindFirstChild("Right Leg")

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
    local enemyFolder = getEnemyFolder()
    if not enemyFolder then return end
    local rainbowColor = RainbowChams and getRainbowColor(RainbowChams_Speed) or ChamsColor

    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            if not chamsCache[enemy] then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = enemy
                highlight.Parent = enemy
                highlight.FillTransparency = ChamsFillTransparency
                highlight.OutlineTransparency = ChamsOutlineTransparency
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                chamsCache[enemy] = highlight
            end
            local hl = chamsCache[enemy]
            hl.FillColor = rainbowColor
            hl.OutlineColor = rainbowColor
            hl.FillTransparency = ChamsFillTransparency
            hl.OutlineTransparency = ChamsOutlineTransparency
        end
    end

    for model, hl in pairs(chamsCache) do
        if not model.Parent or (model:FindFirstChildOfClass("Humanoid") and model:FindFirstChildOfClass("Humanoid").Health <= 0) then
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
            hl.FillColor = rainbowColor
            hl.OutlineColor = rainbowColor
            hl.FillTransparency = WeaponChamsFillTransparency
            hl.OutlineTransparency = WeaponChamsOutlineTransparency
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

--// Bullet Tracers, Particle Effects, Kill Effects
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
    task.delay(BulletTracerDuration, function() if tracer and tracer.Parent then tracer:Destroy() end end)
    table.insert(tracerParts, tracer)
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and BulletTracersEnabled and isAlive() then
        local origin = camera.CFrame.Position
        local direction = camera.CFrame.LookVector * 300
        createAdvancedTracer(origin, direction)
    end
end)

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
    particle.Speed = NumberRange.new(8, 18)
    particle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.1)})
    particle.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
    particle.Parent = attachment
    particle:Emit(ParticleAmount)

    task.delay(ParticleLifetime + 0.5, function()
        if attachment then attachment:Destroy() end
    end)
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and ParticleEffectsEnabled and isAlive() then
        local ray = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {camera, player.Character or {}}
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
        if result and result.Position then
            createParticleEffect(result.Position)
        end
    end
end)

local KillEffectsEnabled = false
local KillEffectColor = Color3.fromRGB(255, 0, 100)
local KillEffectDuration = 0.8
local killFlashGui = nil

local function createKillEffects()
    if not KillEffectsEnabled then return end
    if not killFlashGui then
        killFlashGui = Instance.new("ScreenGui")
        killFlashGui.ResetOnSpawn = false
        killFlashGui.Parent = player:WaitForChild("PlayerGui")
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
end

task.spawn(function()
    local lastHealth = {}
    while task.wait(0.1) do
        if not KillEffectsEnabled then continue end
        local enemyFolder = getEnemyFolder()
        if not enemyFolder then continue end
        for _, enemy in ipairs(enemyFolder:GetChildren()) do
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            if hum then
                local currentHealth = hum.Health
                if lastHealth[enemy] and lastHealth[enemy] > 0 and currentHealth <= 0 then
                    createKillEffects()
                end
                lastHealth[enemy] = currentHealth
            end
        end
    end
end)

--// Visuals Tab UI
Tab_Visuals:CreateSection("ESP Master Switch")
Tab_Visuals:CreateToggle({Name = "Enable Player ESP", CurrentValue = false, Flag = "ESPToggle", Callback = function(Value) EspEnabled = Value end})

Tab_Visuals:CreateSection("ESP Visual Settings")
Tab_Visuals:CreateToggle({Name = "Show Box", CurrentValue = true, Flag = "EspBoxToggle", Callback = function(Value) EspBox = Value end})
Tab_Visuals:CreateToggle({Name = "Show Health Bar", CurrentValue = true, Flag = "EspHealthToggle", Callback = function(Value) EspHealth = Value end})
Tab_Visuals:CreateToggle({Name = "Show Name", CurrentValue = true, Flag = "EspNameToggle", Callback = function(Value) EspName = Value end})
Tab_Visuals:CreateToggle({Name = "Show Distance", CurrentValue = true, Flag = "EspDistanceToggle", Callback = function(Value) EspDistance = Value end})
Tab_Visuals:CreateToggle({Name = "Show Skeleton", CurrentValue = false, Flag = "EspSkeletonToggle", Callback = function(Value) EspSkeleton = Value end})
Tab_Visuals:CreateToggle({Name = "Show Head Dot", CurrentValue = false, Flag = "EspHeadDotToggle", Callback = function(Value) EspHeadDot = Value end})
Tab_Visuals:CreateToggle({Name = "Show Tracers", CurrentValue = false, Flag = "EspTracersToggle", Callback = function(Value) EspTracers = Value end})

Tab_Visuals:CreateSection("Rainbow Settings")
Tab_Visuals:CreateToggle({Name = "🌈 Rainbow ESP", CurrentValue = false, Flag = "RainbowESPToggle", Callback = function(Value) RainbowESP = Value end})
Tab_Visuals:CreateSlider({Name = "Rainbow ESP Speed", Range = {0.1, 10}, Increment = 0.1, Suffix = "", CurrentValue = 2.0, Flag = "RainbowESPSpeed", Callback = function(Value) RainbowESP_Speed = Value end})
Tab_Visuals:CreateToggle({Name = "🌈 Rainbow Chams", CurrentValue = false, Flag = "RainbowChamsToggle", Callback = function(Value) RainbowChams = Value end})
Tab_Visuals:CreateSlider({Name = "Rainbow Chams Speed", Range = {0.1, 10}, Increment = 0.1, Suffix = "", CurrentValue = 2.0, Flag = "RainbowChamsSpeed", Callback = function(Value) RainbowChams_Speed = Value end})

Tab_Visuals:CreateSection("Player Chams (See Through Walls)")
Tab_Visuals:CreateToggle({Name = "Enable Player Chams", CurrentValue = false, Flag = "ChamsToggle", Callback = function(Value) ChamsEnabled = Value; if not Value then for _, hl in pairs(chamsCache) do hl:Destroy() end chamsCache = {} end end})
Tab_Visuals:CreateColorPicker({Name = "Player Chams Color", Color = Color3.fromRGB(255, 0, 255), Flag = "ChamsColorPicker", Callback = function(Value) ChamsColor = Value end})
Tab_Visuals:CreateSlider({Name = "Player Chams Fill Transparency", Range = {0, 1}, Increment = 0.05, Suffix = "", CurrentValue = 0.7, Flag = "ChamsFillTrans", Callback = function(Value) ChamsFillTransparency = Value end})
Tab_Visuals:CreateSlider({Name = "Player Chams Outline Transparency", Range = {0, 1}, Increment = 0.05, Suffix = "", CurrentValue = 0, Flag = "ChamsOutlineTrans", Callback = function(Value) ChamsOutlineTransparency = Value end})

Tab_Visuals:CreateSection("Weapon Chams")
Tab_Visuals:CreateToggle({Name = "Enable Weapon Chams", CurrentValue = false, Flag = "WeaponChamsToggle", Callback = function(Value) WeaponChamsEnabled = Value end})
Tab_Visuals:CreateColorPicker({Name = "Weapon Chams Color", Color = Color3.fromRGB(0, 255, 255), Flag = "WeaponChamsColorPicker", Callback = function(Value) WeaponChamsColor = Value end})
Tab_Visuals:CreateSlider({Name = "Weapon Chams Fill Transparency", Range = {0, 1}, Increment = 0.05, Suffix = "", CurrentValue = 0.5, Flag = "WeaponChamsFillTrans", Callback = function(Value) WeaponChamsFillTransparency = Value end})

Tab_Visuals:CreateSection("Advanced Bullet Tracers")
Tab_Visuals:CreateToggle({Name = "Enable Bullet Tracers", CurrentValue = false, Flag = "BulletTracersToggle", Callback = function(Value) BulletTracersEnabled = Value end})
Tab_Visuals:CreateColorPicker({Name = "Tracer Color", Color = Color3.fromRGB(0, 255, 255), Flag = "BulletTracerColorPicker", Callback = function(Value) BulletTracerColor = Value end})

Tab_Visuals:CreateSection("Particle Effects")
Tab_Visuals:CreateToggle({Name = "Enable Particle Effects", CurrentValue = false, Flag = "ParticleEffectsToggle", Callback = function(Value) ParticleEffectsEnabled = Value end})

Tab_Visuals:CreateSection("Kill Effects")
Tab_Visuals:CreateToggle({Name = "Enable Kill Effects", CurrentValue = false, Flag = "KillEffectsToggle", Callback = function(Value) KillEffectsEnabled = Value end})

Tab_Visuals:CreateSection("ESP Customization")
Tab_Visuals:CreateColorPicker({Name = "Box Color", Color = Color3.fromRGB(255, 50, 50), Flag = "BoxColorPicker", Callback = function(Value) BoxColor = Value end})
Tab_Visuals:CreateColorPicker({Name = "Text Color", Color = Color3.fromRGB(255, 255, 255), Flag = "TextColorPicker", Callback = function(Value) TextColor = Value end})
Tab_Visuals:CreateSlider({Name = "Max ESP Distance", Range = {0, 500}, Increment = 10, Suffix = " studs (0 = unlimited)", CurrentValue = 0, Flag = "EspDistanceLimit", Callback = function(Value) EspMaxDistance = Value end})

--// World & Effects (Anti-Flash / Anti-Smoke)
local AntiFlashEnabled, AntiSmokeEnabled = false, false
Tab_Visuals:CreateSection("World & Effects")
Tab_Visuals:CreateToggle({Name = "Anti-Flashbang", CurrentValue = false, Flag = "AntiFlashToggle", Callback = function(Value) AntiFlashEnabled = Value end})
Tab_Visuals:CreateToggle({Name = "Anti-Smoke", CurrentValue = false, Flag = "AntiSmokeToggle", Callback = function(Value) AntiSmokeEnabled = Value end})

task.spawn(function()
    while task.wait(0.2) do
        if AntiFlashEnabled then
            local gui = player.PlayerGui:FindFirstChild("FlashbangEffect")
            local effect = game:GetService("Lighting"):FindFirstChild("FlashbangColorCorrection")
            if gui then gui:Destroy() end
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

Rayfield:LoadConfiguration()
