-- ====================================================================
-- IPAD FLING THINGS AND PEOPLE SUPREMACY V15 (ABSOLUTE PERFECT)
-- NO SHORTCUTS - FULL EXPANDED SOURCE CODE FOR DELTA EXECUTOR iOS
-- ====================================================================

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AimButton = Instance.new("TextButton")
local HoleButton = Instance.new("TextButton")
local AntiGrabButton = Instance.new("TextButton")
local DropdownButton = Instance.new("TextButton")
local DropdownScroll = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "iPadDeltaMenuFinalV15"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 430)
MainFrame.Active = true
MainFrame.Draggable = true 

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Title.Text = "FT&P HARDCORE SUPREMACY V15"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local function styleButton(btn, text, posY)
    btn.Parent = MainFrame
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansBold
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = btn
end

styleButton(AimButton, "1. Сверх-Аим за Целью [ВЫКЛ]", 60)
styleButton(HoleButton, "2. Истинная Черная Дыра [ВЫКЛ]", 115)
styleButton(AntiGrabButton, "3. Рабочий Анти-Взятие [ВЫКЛ]", 170)

DropdownButton.Parent = MainFrame
DropdownButton.Size = UDim2.new(0.9, 0, 0, 40)
DropdownButton.Position = UDim2.new(0.05, 0, 0, 225)
DropdownButton.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
DropdownButton.Text = "Выбрать жертву: [НИКОГО]"
DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 0)
DropdownButton.TextSize = 13
DropdownButton.Font = Enum.Font.SourceSansBold

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 8)
DropdownCorner.Parent = DropdownButton

DropdownScroll.Parent = MainFrame
DropdownScroll.Size = UDim2.new(0.9, 0, 0, 140)
DropdownScroll.Position = UDim2.new(0.05, 0, 0, 270)
DropdownScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
DropdownScroll.Visible = false
DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownScroll.ScrollBarThickness = 4

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 8)
ScrollCorner.Parent = DropdownScroll

UIListLayout.Parent = DropdownScroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local States = { SilentAim = false, BlackHole = false, AntiGrab = false }
local Config = { SilentAimFov = 260, ThrowForce = 25000000, HoleRadius = 22, OrbitSpeed = 5, PredictionIntensity = 0.13 }
local SelectedPlayerTarget = nil
local ActiveBlackHoleForces = {}
local GlobalTrackedGrab = { ActiveItem = nil, WasGrabbed = false }

local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Thickness = 2
FovCircle.Color = Color3.fromRGB(255, 200, 0)
FovCircle.Radius = Config.SilentAimFov
FovCircle.Filled = false
FovCircle.NumSides = 64

local AimSnapLine = Drawing.new("Line")
AimSnapLine.Visible = false
AimSnapLine.Thickness = 2.5
AimSnapLine.Color = Color3.fromRGB(255, 0, 50)

local function RefreshPlayerDropdown()
    for _, child in pairs(DropdownScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, 0, 0, 30)
            pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
            pBtn.Text = player.Name
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.TextSize = 13
            pBtn.Font = Enum.Font.SourceSans
            pBtn.Parent = DropdownScroll
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = pBtn
            
            pBtn.MouseButton1Click:Connect(function()
                SelectedPlayerTarget = player
                DropdownButton.Text = "Цель: " .. player.Name
                DropdownScroll.Visible = false
            end)
        end
    end
    DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

task.spawn(function()
    while task.wait(60) do
        RefreshPlayerDropdown()
    end
end)

DropdownButton.MouseButton1Click:Connect(function()
    RefreshPlayerDropdown()
    DropdownScroll.Visible = not DropdownScroll.Visible
end)

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if States.SilentAim and not checkcaller() and (key == "Hit" or key == "Target") then
        if SelectedPlayerTarget and SelectedPlayerTarget.Character and SelectedPlayerTarget.Character:FindFirstChild("HumanoidRootPart") then
            local tRoot = SelectedPlayerTarget.Character.HumanoidRootPart
            local centerScreen = Camera.ViewportSize / 2
            
            local predictedAimPos = tRoot.Position + (tRoot.AssemblyLinearVelocity * Config.PredictionIntensity)
            local screenPos, onScreen = Camera:WorldToViewportPoint(predictedAimPos)
            
            if onScreen then
                local distance = (Vector2.new(centerScreen.X, centerScreen.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if distance <= Config.SilentAimFov then
                    return key == "Hit" and CFrame.new(predictedAimPos) or tRoot
                end
            end
        end
    end
    return oldIndex(self, key)
end)

local function ApplyAntiGrabLogic(character)
    if not character then return end
    character.DescendantAdded:Connect(function(desc)
        if States.AntiGrab then
            if desc:IsA("Weld") or desc:IsA("ManualWeld") or desc:IsA("Constraint") or desc:IsA("MoverConstraint") then
                task.wait()
                if desc.Part0 and desc.Part1 then
                    local p0Char = desc.Part0.Parent
                    local p1Char = desc.Part1.Parent
                    
                    if p0Char and p0Char:FindFirstChild("Humanoid") and p0Char.Name ~= LocalPlayer.Name then
                        p0Char:BreakJoints()
                        desc:Destroy()
                    elseif p1Char and p1Char:FindFirstChild("Humanoid") and p1Char.Name ~= LocalPlayer.Name then
                        p1Char:BreakJoints()
                        desc:Destroy()
                    end
                else
                    desc:Destroy()
                end
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    ApplyAntiGrabLogic(newChar)
end)

if LocalPlayer.Character then ApplyAntiGrabLogic(LocalPlayer.Character) end

local OrbitAngle = 0

RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local centerScreen = Camera.ViewportSize / 2
    
    if States.SilentAim then
        FovCircle.Position = centerScreen
        FovCircle.Radius = Config.SilentAimFov
        FovCircle.Visible = true
        
        if SelectedPlayerTarget and SelectedPlayerTarget.Character and SelectedPlayerTarget.Character:FindFirstChild("HumanoidRootPart") then
            local tRoot = SelectedPlayerTarget.Character.HumanoidRootPart
            local predPos = tRoot.Position + (tRoot.AssemblyLinearVelocity * Config.PredictionIntensity)
            local sPos, onScreen = Camera:WorldToViewportPoint(predPos)
            if onScreen then
                AimSnapLine.From = centerScreen
                AimSnapLine.To = Vector2.new(sPos.X, sPos.Y)
                AimSnapLine.Visible = true
            else
                AimSnapLine.Visible = false
            end
        else
            AimSnapLine.Visible = false
        end
    else
        FovCircle.Visible = false
        AimSnapLine.Visible = false
    end

    if myChar then
        if States.AntiGrab and myHrp then
            for _, f in pairs(myHrp:GetChildren()) do
                if f:IsA("BodyPosition") or f:IsA("BodyVelocity") or f:IsA("LinearVelocity") or f:IsA("AlignPosition") then
                    f:Destroy()
                end
            end
        end

        local currentFrameObject = nil
        for _, object in pairs(myChar:GetDescendants()) do
            if object:IsA("Weld") or object:IsA("Constraint") or object:IsA("MoverConstraint") then
                if object.Part1 and not object.Part1:IsDescendantOf(myChar) then
                    currentFrameObject = object.Part1.Parent
                elseif object.Part0 and not object.Part0:IsDescendantOf(myChar) then
                    currentFrameObject = object.Part0.Parent
                end
            end
        end

        if currentFrameObject then
            GlobalTrackedGrab.ActiveItem = currentFrameObject
            GlobalTrackedGrab.WasGrabbed = true
            for _, part in pairs(currentFrameObject:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    -- Силовое выдавливание под текстуры пола вниз
                    part.AssemblyLinearVelocity = Vector3.new(part.AssemblyLinearVelocity.X, -140, part.AssemblyLinearVelocity.Z)
                end
            end
        else
            -- НАСТОЯЩИЙ ИСПРАВЛЕННЫЙ СУПЕР-БРОСОК V15
            if GlobalTrackedGrab.WasGrabbed and GlobalTrackedGrab.ActiveItem then
                local tHrp = GlobalTrackedGrab.ActiveItem:FindFirstChild("HumanoidRootPart") or GlobalTrackedGrab.ActiveItem:FindFirstChildOfClass("BasePart")
                if tHrp then
                    local throwVector = Camera.CFrame.LookVector
                    local inFovLimits = false
                    if States.SilentAim and SelectedPlayerTarget and SelectedPlayerTarget.Character and SelectedPlayerTarget.Character:FindFirstChild("HumanoidRootPart") then
                        local enemyRoot = SelectedPlayerTarget.Character.HumanoidRootPart
                        local predPos = enemyRoot.Position + (enemyRoot.AssemblyLinearVelocity * Config.PredictionIntensity)
                        local _, onScreen = Camera:WorldToViewportPoint(predPos)
                        if onScreen then
                            local screenPos = Camera:WorldToViewportPoint(predPos)
                            local dist = (centerScreen - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                            if dist <= Config.SilentAimFov then
                                inFovLimits = true
                                throwVector = (predPos - tHrp.Position).Unit
                            end
                        end
                    end
                    if not inFovLimits then
                        -- Траектория в небо сквозь любые потолки карты
                        throwVector = (Camera.CFrame.LookVector + Vector3.new(0, 3.8, 0)).Unit
                    end
                    -- Тотальное стирание физического сопротивления и массы перед импульсом броска
                    for _, p in pairs(GlobalTrackedGrab.ActiveItem:GetChildren()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = false
                            p.Massless = true
                            -- Принудительный сетевой пинок на уровне движка
                            p:ApplyImpulse(throwVector * Config.ThrowForce)
                            p.AssemblyLinearVelocity = throwVector * Config.ThrowForce
                        end
                    end
                    local velocityInstance = Instance.new("LinearVelocity")
                    local attachmentInstance = Instance.new("Attachment")
                    attachmentInstance.Parent = tHrp
                    velocityInstance.MaxForce = math.huge
                    velocityInstance.VectorVelocity = throwVector * Config.ThrowForce
                    velocityInstance.Attachment0 = attachmentInstance
                    velocityInstance.Parent = tHrp
                    game:GetService("Debris"):AddItem(velocityInstance, 0.3)
                    game:GetService("Debris"):AddItem(attachmentInstance, 0.3)
                end
                GlobalTrackedGrab.ActiveItem = nil
                GlobalTrackedGrab.WasGrabbed = false
            end
        end
        
        -- ИСТИННАЯ ЧЕРНАЯ ДЫРА (СТЯГИВАНИЕ ВСЕХ)
        if States.BlackHole and myHrp then
            OrbitAngle = OrbitAngle + math.rad(Config.OrbitSpeed)
            local totalElements = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(totalElements, p.Character.HumanoidRootPart)
                end
            end
            for _, item in pairs(workspace:GetChildren()) do
                if item:IsA("BasePart") and item.Anchored == false and item.Name ~= "Baseplate" then
                    table.insert(totalElements, item)
                end
            end
            if #totalElements > 0 then
                for index, element in pairs(totalElements) do
                    local spacing = (math.pi * 2) / #totalElements
                    local elementAngle = OrbitAngle + (index * spacing)
                    local offsetX = math.cos(elementAngle) * Config.HoleRadius
                    local offsetZ = math.sin(elementAngle) * Config.HoleRadius
                    element.CanCollide = false
                    if not ActiveBlackHoleForces[element] then
                        local centerAtt = Instance.new("Attachment")
                        centerAtt.Parent = myHrp
                        local targetAtt = Instance.new("Attachment")
                        targetAtt.Parent = element
                        local alignPos = Instance.new("AlignPosition")
                        alignPos.MaxForce = math.huge
                        alignPos.MaxVelocity = math.huge
                        alignPos.Responsiveness = 250
                        alignPos.Attachment0 = targetAtt
                        alignPos.Attachment1 = centerAtt
                        alignPos.Parent = element
                        ActiveBlackHoleForces[element] = { AlignPos = alignPos, Attachment = targetAtt, CenterAttachment = centerAtt }
                    end
                    local data = ActiveBlackHoleForces[element]
                    if data and data.CenterAttachment then
                        data.CenterAttachment.Position = Vector3.new(offsetX, -3.5, offsetZ)
                    end
                end
            end
        else
            if next(ActiveBlackHoleForces) ~= nil then
                for part, data in pairs(ActiveBlackHoleForces) do
                    if data.AlignPos then data.AlignPos:Destroy() end
                    if data.Attachment then data.Attachment:Destroy() end
                    if data.CenterAttachment then data.CenterAttachment:Destroy() end
                end
                table.clear(ActiveBlackHoleForces)
            end
        end
    end
end)

AimButton.MouseButton1Click:Connect(function()
    States.SilentAim = not States.SilentAim
    AimButton.Text = "1. Сверх-Аим за Целью " .. (States.SilentAim and "[ВКЛ]" or "[ВЫКЛ]")
    AimButton.BackgroundColor3 = States.SilentAim and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(45, 45, 52)
end)

HoleButton.MouseButton1Click:Connect(function()
    States.BlackHole = not States.BlackHole
    HoleButton.Text = "2. Истинная Черная Дыра " .. (States.BlackHole and "[ВКЛ]" or "[ВЫКЛ]")
    HoleButton.BackgroundColor3 = States.BlackHole and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(45, 45, 52)
end)

AntiGrabButton.MouseButton1Click:Connect(function()
    States.AntiGrab = not States.AntiGrab
    AntiGrabButton.Text = "3. Рабочий Анти-Взятие " .. (States.AntiGrab and "[ВКЛ]" or "[ВЫКЛ]")
    AntiGrabButton.BackgroundColor3 = States.AntiGrab and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(45, 45, 52)
end)

print("[Delta iOS Setup Complete V15]")
