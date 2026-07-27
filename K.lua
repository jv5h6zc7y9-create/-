local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileExecutorHub"
ScreenGui.ResetOnSpawn = false
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 50, 0.4, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "GUI"
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = ScreenGui

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(1, 0)
UICornerBtn.Parent = ToggleButton

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 12)
UICornerMain.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "Mobile Executor Hub"
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainFrame

local UICornerTitle = Instance.new("UICorner")
UICornerTitle.CornerRadius = UDim.new(0, 12)
UICornerTitle.Parent = TitleLabel

local FOVRadius = 150

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(1, -20, 0, 30)
FOVLabel.Position = UDim2.new(0, 10, 0, 60)
FOVLabel.BackgroundTransparency = 1
FOVLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVLabel.TextSize = 14
FOVLabel.Font = Enum.Font.SourceSansBold
FOVLabel.Text = "FOV Radius: " .. FOVRadius
FOVLabel.Parent = MainFrame

local FOVMinusBtn = Instance.new("TextButton")
FOVMinusBtn.Size = UDim2.new(0, 40, 0, 30)
FOVMinusBtn.Position = UDim2.new(0, 10, 0, 100)
FOVMinusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FOVMinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVMinusBtn.Text = "-"
FOVMinusBtn.TextSize = 16
FOVMinusBtn.Font = Enum.Font.SourceSansBold
FOVMinusBtn.Parent = MainFrame

local UICornerM = Instance.new("UICorner")
UICornerM.CornerRadius = UDim.new(0, 6)
UICornerM.Parent = FOVMinusBtn

local FOVPlusBtn = Instance.new("TextButton")
FOVPlusBtn.Size = UDim2.new(0, 40, 0, 30)
FOVPlusBtn.Position = UDim2.new(0, 60, 0, 100)
FOVPlusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FOVPlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVPlusBtn.Text = "+"
FOVPlusBtn.TextSize = 16
FOVPlusBtn.Font = Enum.Font.SourceSansBold
FOVPlusBtn.Parent = MainFrame

local UICornerP = Instance.new("UICorner")
UICornerP.CornerRadius = UDim.new(0, 6)
UICornerP.Parent = FOVPlusBtn

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = true
FOVCircle.Parent = ScreenGui

local UICornerFOV = Instance.new("UICorner")
UICornerFOV.CornerRadius = UDim.new(1, 0)
UICornerFOV.Parent = FOVCircle

local UIStrokeFOV = Instance.new("UIStroke")
UIStrokeFOV.Color = Color3.fromRGB(0, 255, 128)
UIStrokeFOV.Thickness = 2
UIStrokeFOV.Parent = FOVCircle

FOVMinusBtn.MouseButton1Click:Connect(function()
    FOVRadius = math.clamp(FOVRadius - 10, 30, 400)
    FOVCircle.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
    FOVLabel.Text = "FOV Radius: " .. FOVRadius
end)

FOVPlusBtn.MouseButton1Click:Connect(function()
    FOVRadius = math.clamp(FOVRadius + 10, 30, 400)
    FOVCircle.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
    FOVLabel.Text = "FOV Radius: " .. FOVRadius
end)

local draggingBtn, dragInputBtn, dragStartBtn, startPosBtn
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = true
        dragStartBtn = input.Position
        startPosBtn = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingBtn = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInputBtn = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInputBtn and draggingBtn then
        local delta = input.Position - dragStartBtn
        ToggleButton.Position = UDim2.new(startPosBtn.X.Scale, startPosBtn.X.Offset + delta.X, startPosBtn.Y.Scale, startPosBtn.Y.Offset + delta.Y)
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local draggingMain, dragInputMain, dragStartMain, startPosMain
TitleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = true
        dragStartMain = input.Position
        startPosMain = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingMain = false
            end
        end)
    end
end)

TitleLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInputMain = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInputMain and draggingMain then
        local delta = input.Position - dragStartMain
        MainFrame.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
    end
end)

local ParticleContainer = Instance.new("Folder")
ParticleContainer.Name = "ParticleContainer"
ParticleContainer.Parent = ScreenGui

local particles = {}
local maxParticles = 20

for i = 1, maxParticles do
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, math.random(2, 4), 0, math.random(8, 15))
    p.Position = UDim2.new(math.random(), 0, -0.1, 0)
    p.BackgroundColor3 = Color3.fromRGB(200, 220, 255)
    p.BackgroundTransparency = 0.5
    p.BorderSizePixel = 0
    p.Parent = ParticleContainer
    
    table.insert(particles, {
        object = p,
        speed = math.random(80, 150) / 100
    })
end

RunService.RenderStepped:Connect(function(dt)
    for _, pData in ipairs(particles) do
        local p = pData.object
        local currentPos = p.Position
        local newY = currentPos.Y.Scale + (pData.speed * dt * 0.2)
        if newY > 1.1 then
            newY = -0.1
            p.Position = UDim2.new(math.random(), 0, newY, 0)
        else
            p.Position = UDim2.new(currentPos.X.Scale, 0, newY, 0)
        end
    end
end)

local function isEnemy(targetPlayer)
    if targetPlayer == LocalPlayer then return false end
    
    if targetPlayer.Team and LocalPlayer.Team then
        if targetPlayer.Team ~= LocalPlayer.Team then
            return true
        else
            return false
        end
    end

    local localTeamAttr = LocalPlayer:GetAttribute("Team")
    local targetTeamAttr = targetPlayer:GetAttribute("Team")
    if localTeamAttr and targetTeamAttr then
        if localTeamAttr ~= targetTeamAttr then return true else return false end
    end
    
    local localSideAttr = LocalPlayer:GetAttribute("Side")
    local targetSideAttr = targetPlayer:GetAttribute("Side")
    if localSideAttr and targetSideAttr then
        if localSideAttr ~= targetSideAttr then return true else return false end
    end

    local teamValueObj = targetPlayer:FindFirstChild("Team")
    local localTeamValueObj = LocalPlayer:FindFirstChild("Team")
    if teamValueObj and localTeamValueObj then
        if teamValueObj.Value ~= localTeamValueObj.Value then
            return true
        else
            return false
        end
    end

    if targetPlayer.TeamColor ~= LocalPlayer.TeamColor and targetPlayer.TeamColor ~= Color3.fromRGB(255, 255, 255) then
        return true
    end

    return true
end

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESPFolder"
ESPFolder.Parent = ScreenGui

local espCache = {}

local function createESP(player)
    if espCache[player] then return end
    
    local holder = Instance.new("Folder")
    holder.Name = player.Name .. "_ESP"
    holder.Parent = ESPFolder
    
    local box = Instance.new("Highlight")
    box.Name = "Highlight"
    box.Adornee = nil
    box.FillTransparency = 0.5
    box.OutlineTransparency = 0
    box.Parent = holder
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "Info"
    infoLabel.Size = UDim2.new(0, 150, 0, 30)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.TextStrokeTransparency = 0
    infoLabel.TextSize = 12
    infoLabel.Font = Enum.Font.SourceSansBold
    infoLabel.Visible = false
    infoLabel.Parent = holder
    
    espCache[player] = {holder = holder, box = box, label = infoLabel}
end

local function removeESP(player)
    if espCache[player] then
        espCache[player].holder:Destroy()
        espCache[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

local isFiring = false
local targetLockedHead = nil

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isFiring = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isFiring = false
    end
end)

pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, idx)
        if not checkcaller() and self == Camera and idx == "CFrame" then
            if isFiring and targetLockedHead then
                return CFrame.new(Camera.CFrame.Position, targetLockedHead.Position)
            end
        end
        return oldIndex(self, idx)
    end)
end)

local cachedWeaponValues = {}

local function updateWeaponValues(char)
    cachedWeaponValues = {}
    if char then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("NumberValue") or obj:IsA("Vector3Value") then
                local name = obj.Name:lower()
                if name:find("recoil") or name:find("spread") or name:find("kick") then
                    table.insert(cachedWeaponValues, obj)
                end
            end
        end
    end
end

if LocalPlayer.Character then
    updateWeaponValues(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(updateWeaponValues)

local espTimer = 0
local espUpdateInterval = 0.05

RunService.RenderStepped:Connect(function(dt)
    espTimer = espTimer + dt
    local updateESPNow = false
    if espTimer >= espUpdateInterval then
        espTimer = 0
        updateESPNow = true
    end

    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closestTargetHead = nil
    local shortestDistance = math.huge
    
    for player, data in pairs(espCache) do
        local enemyCheck = isEnemy(player)
        if enemyCheck == true then
            local character = player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local head = character and character:FindFirstChild("Head")
            
            if character and humanoidRootPart and humanoid and humanoid.Health > 0 and head then
                if updateESPNow then
                    data.box.Adornee = character
                    local screenPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                    if onScreen then
                        local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        
                        data.box.FillColor = Color3.fromRGB(0, 255, 0)
                        data.box.OutlineColor = Color3.fromRGB(0, 255, 0)
                        data.label.TextColor3 = Color3.fromRGB(0, 255, 0)
                        
                        data.label.Position = UDim2.new(0, screenPos.X - 75, 0, screenPos.Y - 40)
                        data.label.Text = player.Name .. "\nHP: " .. math.floor(humanoid.Health)
                        data.label.Visible = true
                        
                        if isFiring and distToCenter <= FOVRadius then
                            if distToCenter < shortestDistance then
                                shortestDistance = distToCenter
                                closestTargetHead = head
                            end
                        end
                    else
                        data.label.Visible = false
                        data.box.Adornee = nil
                    end
                else
                    if isFiring then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                        if onScreen then
                            local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if distToCenter <= FOVRadius then
                                if distToCenter < shortestDistance then
                                    shortestDistance = distToCenter
                                    closestTargetHead = head
                                end
                            end
                        end
                    end
                end
            else
                data.box.Adornee = nil
                data.label.Visible = false
            end
        else
            data.box.Adornee = nil
            data.label.Visible = false
        end
    end
    
    if isFiring and closestTargetHead then
        targetLockedHead = closestTargetHead
    else
        targetLockedHead = nil
    end
    
    for _, obj in ipairs(cachedWeaponValues) do
        if obj and obj.Parent then
            obj.Value = 0
        end
    end
end)
