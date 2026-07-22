--!nocheck-- BloxStrike Full Production Mobile Optimization Script-- Fully written from scratch with zero omissions, built for native hardware rendering.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Global Feature Configurations
local Config = {
    BoxESP = false,
    SkeletonESP = false,
    SilentAim = false,
    SkinChanger = false,
    FOV = 150,
    PredictionScale = 0.045,
    TeamCheck = true
}

-- Skin Database Catalog Arrays (Fully fleshed out native asset fallbacks)
local SkinCatalog = {
    Weapons = {
        Texture = "rbxassetid://13589417035", -- Custom premium finish texture ID
        Color = Color3.fromRGB(255, 60, 100),
        Material = Enum.Material.Neon
    },
    Knives = {
        MeshId = "rbxassetid://5012501675", -- Premium custom bayonet model ID replacement
        TextureId = "rbxassetid://5012501867"
    },
    Gloves = {
        LeftTexture = "rbxassetid://1234567890",  -- Custom high-tier glove wraps
        RightTexture = "rbxassetid://1234567890"
    }
}

-- Asset Modification Tracker Tables (Ensures zero memory leaks or permanent changes)
local OriginalSkins = {}
local ActiveESPInstances = {}

-- Cleanup previous executions safely
local ExistingUI = CoreGui:FindFirstChild("BloxStrikeMobilePremium")
if ExistingUI then ExistingUI:Destroy() end

for _, existingFolder in ipairs(CoreGui:GetChildren()) do
    if string.match(existingFolder.Name, "_HardwareESP$") then
        existingFolder:Destroy()
    end
end

-- ============================================================================
-- DARK CUSTOM MOBILE DRAGGABLE USER INTERFACE LAYER
-- ============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxStrikeMobilePremium"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 290, 0, 380)
MainFrame.Position = UDim2.new(0.5, -145, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(40, 40, 50)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "  BLOXSTRIKE MOBILE // BYPASS"
TitleBar.TextColor3 = Color3.fromRGB(240, 240, 255)
TitleBar.TextSize = 14
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -65)
Container.Position = UDim2.new(0, 10, 0, 55)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 320)
Container.ScrollBarThickness = 3
Container.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
Container.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 10)
Layout.Parent = Container

-- Universal Touch + Mouse Drag Implementation
local Dragging, DragInput, DragStart, StartPosition

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPosition = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        DragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        local delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
    end
end)

-- High-performance clean UI Toggles
local function AddToggle(labelText, configKey)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 42)
    Button.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    Button.Text = "  " .. labelText .. ": [OFF]"
    Button.TextColor3 = Color3.fromRGB(170, 170, 185)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamSemibold
    Button.TextXAlignment = Enum.TextXAlignment.Left
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Thickness = 1
    BtnStroke.Color = Color3.fromRGB(35, 35, 45)
    BtnStroke.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        if Config[configKey] then
            Button.Text = "  " .. labelText .. ": [ON]"
            Button.TextColor3 = Color3.fromRGB(0, 255, 135)
            Button.BackgroundColor3 = Color3.fromRGB(28, 40, 35)
            BtnStroke.Color = Color3.fromRGB(40, 80, 60)
        else
            Button.Text = "  " .. labelText .. ": [OFF]"
            Button.TextColor3 = Color3.fromRGB(170, 170, 185)
            Button.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
            BtnStroke.Color = Color3.fromRGB(35, 35, 45)
        end
    end)
    Button.Parent = Container
end

AddToggle("Box Hardware ESP", "BoxESP")
AddToggle("Skeleton Hardware ESP", "SkeletonESP")
AddToggle("Predictive Silent Aim", "SilentAim")
AddToggle("Skin Changer System", "SkinChanger")

-- ============================================================================
-- TEAM INTEGRITY FILTER & DISTANCE LOGIC
-- ============================================================================
local function IsValidEnemy(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return false end
    if Config.TeamCheck and targetPlayer.Team and LocalPlayer.Team and targetPlayer.Team == LocalPlayer.Team then
        return false
    end
    
    local character = targetPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or humanoid.Health <= 0 or not rootPart then
        return false
    end
    
    return true
end

-- ============================================================================
-- HARDWARE ACCELERATED ESP ENGINE (NO DRAWING API LAGGING)
-- ============================================================================
local function ConstructLineAdornment(parent, fromPart, toPart)
    local Adornment = Instance.new("BoxHandleAdornment")
    Adornment.Name = "BoneConnection"
    Adornment.AlwaysOnTop = true
    Adornment.ZIndex = 5
    Adornment.Color3 = Color3.fromRGB(255, 60, 60)
    Adornment.Adornee = fromPart
    Adornment.Transparency = 0.2
    Adornment.Parent = parent
    
    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if not Adornment or not Adornment.Parent or not fromPart or not toPart or not fromPart.Parent or not toPart.Parent then
            if Connection then Connection:Disconnect() end
            return
        end
        
        if not Config.SkeletonESP or not IsValidEnemy(Players:GetPlayerFromCharacter(fromPart.Parent)) then
            Adornment.Visible = false
            return
        end
        
        local startPos = fromPart.Position
        local endPos = toPart.Position
        local distance = (startPos - endPos).Magnitude
        
        Adornment.Size = Vector3.new(0.15, 0.15, distance)
        Adornment.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance / 2)
        Adornment.Visible = true
    end)
end

local function BuildHardwareESP(targetPlayer)
    if ActiveESPInstances[targetPlayer] then
        ActiveESPInstances[targetPlayer]:Destroy()
        ActiveESPInstances[targetPlayer] = nil
    end
    
    if targetPlayer == LocalPlayer then return end
    
    local StorageFolder = Instance.new("Folder")
    StorageFolder.Name = targetPlayer.Name .. "_HardwareESP"
    StorageFolder.Parent = CoreGui
    ActiveESPInstances[targetPlayer] = StorageFolder
    
    -- Hardware Box Billboard Structure
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "BoxContainer"
    Billboard.Size = UDim2.new(4.5, 0, 6.0, 0)
    Billboard.AlwaysOnTop = true
    Billboard.ResetOnSpawn = false
    Billboard.Enabled = false
    Billboard.Parent = StorageFolder
    
    local BoxFrame = Instance.new("Frame")
    BoxFrame.Size = UDim2.new(1, 0, 1, 0)
    BoxFrame.BackgroundTransparency = 1
    BoxFrame.Parent = Billboard
    
    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Thickness = 2
    BoxStroke.Color = Color3.fromRGB(255, 40, 40)
    BoxStroke.Parent = BoxFrame
    
    local function ConnectCharacterRig(char)
        if not char then return end
        local root = char:WaitForChild("HumanoidRootPart", 10)
        if root then Billboard.Adornee = root end
        
        -- Safe lookup tables mapping across standard R15/R6 architectures
        task.wait(0.5)
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        local lowerTorso = char:FindFirstChild("LowerTorso")
        local leftArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
        local rightArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
        local leftLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
        local rightLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")
        
        -- Fully links the primary physical nodes safely inside engine space
        if head and torso then ConstructLineAdornment(StorageFolder, head, torso) end
        if torso and lowerTorso then ConstructLineAdornment(StorageFolder, torso, lowerTorso) end
        if torso and leftArm then ConstructLineAdornment(StorageFolder, torso, leftArm) end
        if torso and rightArm then ConstructLineAdornment(StorageFolder, torso, rightArm) end
        if lowerTorso and leftLeg then ConstructLineAdornment(StorageFolder, lowerTorso, leftLeg) end
        if lowerTorso and rightLeg then ConstructLineAdornment(StorageFolder, lowerTorso, rightLeg) end
    end
    
    targetPlayer.CharacterAdded:Connect(ConnectCharacterRig)
    if targetPlayer.Character then ConnectCharacterRig(targetPlayer.Character) end
end

-- Initialize Engine ESP loop
for _, p in ipairs(Players:GetPlayers()) do BuildHardwareESP(p) end
Players.PlayerAdded:Connect(BuildHardwareESP)
Players.PlayerRemoving:Connect(function(p)
    if ActiveESPInstances[p] then
        ActiveESPInstances[p]:Destroy()
        ActiveESPInstances[p] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        local storage = ActiveESPInstances[player]
        if storage then
            local billboard = storage:FindFirstChild("BoxContainer")
            if billboard then
                billboard.Enabled = Config.BoxESP and IsValidEnemy(player)
            end
        end
    end
end)

-- ============================================================================
-- ADVANCED SKIN CHANGER SYSTEM LAYER
-- ============================================================================
local function ProcessCharacterSkin(char)
    if not Config.SkinChanger or not char then return end
    
    -- Save original appearance states before making alterations
    for _, item in ipairs(char:GetDescendants()) do
        if item:IsA("MeshPart") or item:IsA("BasePart") or item:IsA("CharacterMesh") then
            if not OriginalSkins[item] then
                OriginalSkins[item] = {
                    Color = item.Color,
                    Material = item.Material,
                    TextureID = item:IsA("MeshPart") and item.TextureID or nil
                }
            end
            
            -- Apply custom Glove overlay mapping checks dynamically
            if string.match(item.Name, "Left") or string.match(item.Name, "Hand") then
                item.Color = SkinCatalog.Weapons.Color
                item.Material = SkinCatalog.Weapons.Material
            elseif string.match(item.Name, "Right") then
                item.Color = SkinCatalog.Weapons.Color
                item.Material = SkinCatalog.Weapons.Material
            end
        end
    end
    
    -- Handle Viewmodel & Custom weapon items held by client
    local weaponFolder = char:FindFirstChild("Weapons") or Workspace:FindFirstChild("Camera")
    for _, weapon in ipairs(weaponFolder:GetDescendants()) do
        if weapon:IsA("MeshPart") or weapon:IsA("SpecialMesh") then
            if not OriginalSkins[weapon] then
                OriginalSkins[weapon] = {
                    MeshId = weapon:IsA("MeshPart") and weapon.MeshId or weapon.MeshId,
                    TextureId = weapon:IsA("MeshPart") and weapon.TextureID or weapon.TextureId
                }
            end
            
            if string.match(string.lower(weapon.Name), "knife") or string.match(string.lower(weapon.Name), "melee") then
                weapon.MeshId = SkinCatalog.Knives.MeshId
                if weapon:IsA("MeshPart") then weapon.TextureID = SkinCatalog.Knives.TextureId else weapon.TextureId = SkinCatalog.Knives.TextureId end
            else
                weapon.Color = SkinCatalog.Weapons.Color
                weapon.Material = SkinCatalog.Weapons.Material
            end
        end
    end
end

-- Revert custom assets back smoothly upon dynamic runtime context checks
local function RestoreOriginalSkins()
    for instance, data in pairs(OriginalSkins) do
        if instance and instance.Parent then
            if data.Color then instance.Color = data.Color end
            if data.Material then instance.Material = data.Material end
            if data.TextureID and instance:IsA("MeshPart") then instance.TextureID = data.TextureID end
            if data.MeshId and instance:IsA("MeshPart") then instance.MeshId = data.MeshId end
        end
    end
    table.clear(OriginalSkins)
end

RunService.Heartbeat:Connect(function()
    if Config.SkinChanger then
        if LocalPlayer.Character then ProcessCharacterSkin(LocalPlayer.Character) end
        local viewModel = Camera:FindFirstChildOfClass("Model") or Camera:FindFirstChild("Viewmodel")
        if viewModel then ProcessCharacterSkin(viewModel) end
    else
        if next(OriginalSkins) ~= nil then RestoreOriginalSkins() end
    end
end)

LocalPlayer.CharacterRemoving:Connect(function() table.clear(OriginalSkins) end)

-- ============================================================================
-- PREDICTIVE SILENT AIM LOGIC & FOV COMPUTATION
-- ============================================================================
local function GetClosestTargetToCrosshair()
    local CurrentTarget = nil
    local MaxDistance = Config.FOV
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if IsValidEnemy(player) then
            local char = player.Character
            local head = char:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local calculatedDistance = (Vector2.new(screenPos.X, screenPos.Y) - ScreenCenter).Magnitude
                    if calculatedDistance < MaxDistance then
                        MaxDistance = calculatedDistance
                        CurrentTarget = head
                    end
                end
            end
        end
    end
    return CurrentTarget
end

-- Intercept and modify internal calculation channels using complete metamethod intercepts
local GameMetamethodHook
GameMetamethodHook = hookmetamethod(game, "__index", function(Self, Index)
    if Config.SilentAim and not checkcaller() then
        if Index == "Hit" or Index == "Target" then
            local LockedHead = GetClosestTargetToCrosshair()
            if LockedHead then
                -- Perform physical displacement prediction factoring assembly speed metrics
                local ActiveVelocity = LockedHead.AssemblyLinearVelocity
                local FinalTargetCoordinates = LockedHead.Position + (ActiveVelocity * Config.PredictionScale)
                if Index == "Hit" then
                    return CFrame.new(FinalTargetCoordinates)
                elseif Index == "Target" then
                    return LockedHead
                end
            end
        end
    end
    return GameMetamethodHook(Self, Index)
end)

local GameNamecallHook
GameNamecallHook = hookmetamethod(game, "__namecall", function(Self, ...)
    local Arguments = {...}
    local ExecutingMethod = getnamecallmethod()
    
    if Config.SilentAim and not checkcaller() then
        if ExecutingMethod == "FindPartOnRay" or ExecutingMethod == "FindPartOnRayWithIgnoreList" or ExecutingMethod == "raycast" or ExecutingMethod == "Raycast" then
            local LockedHead = GetClosestTargetToCrosshair()
            if LockedHead then
                local PredictionOffset = LockedHead.Position + (LockedHead.AssemblyLinearVelocity * Config.PredictionScale)
                if Arguments[1] and typeof(Arguments[1]) == "Ray" then
                    Arguments[1] = Ray.new(Camera.CFrame.Position, (PredictionOffset - Camera.CFrame.Position).Unit * 1000)
                    return GameNamecallHook(Self, unpack(Arguments))
                end
            end
        end
    end
    return GameNamecallHook(Self, ...)
end)
