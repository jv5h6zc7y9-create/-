-- Block Strike iPad | Delta iOS
-- Center-screen silent aim + CS2-style ESP (box behind walls, skeleton, health)
-- Auto-runs on load

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- CONFIG
local CFG = {
    SilentAim = true,
    FOV = 120,
    TeamCheck = true,
    WallCheck = true,
    HitPart = "Head",
    Prediction = 0.12,
    
    ESP = {
        Enabled = true,
        Boxes = true,
        CornerBoxes = true, -- CS2 style corners
        Skeleton = true,
        HealthBar = true,
        Name = true,
        Distance = true,
        Tracers = false,
        
        BoxColor = Color3.fromRGB(255, 50, 50),
        BoxVisibleColor = Color3.fromRGB(50, 255, 50),
        SkeletonColor = Color3.fromRGB(200, 200, 200),
        SkeletonVisibleColor = Color3.fromRGB(255, 255, 255),
        BehindWallColor = Color3.fromRGB(255, 50, 50),
        
        MaxDistance = 1000,
        TextSize = 13,
        BoxThickness = 1,
        SkeletonThickness = 1.5
    }
}

-- DRAWING POOL
local Drawings = {}
local function NewDrawing(type, props)
    local d = Drawing.new(type)
    for k, v in pairs(props or {}) do d[k] = v end
    table.insert(Drawings, d)
    return d
end

local function ClearDrawings()
    for _, d in ipairs(Drawings) do d.Visible = false end
end

-- LIMB MAP FOR SKELETON
local SkeletonMap = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"}
}

-- UTILS
local function IsAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function IsTeammate(p)
    if not CFG.TeamCheck then return false end
    return p.Team == LocalPlayer.Team
end

local function WorldToScreen(pos)
    local s, vis = Camera:WorldToViewportPoint(pos)
    return Vector2.new(s.X, s.Y), vis, s.Z
end

local function RaycastVisible(origin, target)
    local dir = (target - origin)
    local dist = dir.Magnitude
    dir = dir.Unit * dist
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {LocalPlayer.Character}
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    local res = Workspace:Raycast(origin, dir, rp)
    if not res then return true end
    return false
end

local function GetCenterScreen()
    local vp = Camera.ViewportSize
    return Vector2.new(vp.X / 2, vp.Y / 2)
end

-- TARGET SELECTION (center screen, not mouse)
local CurrentTarget = nil

local function GetBestTarget()
    local center = GetCenterScreen()
    local closest, bestDist = nil, CFG.FOV
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if IsTeammate(plr) then continue end
        
        local char = plr.Character
        if not IsAlive(char) then continue end
        
        local part = char:FindFirstChild(CFG.HitPart)
        if not part then continue end
        
        local spos, onScreen, depth = WorldToScreen(part.Position)
        if not onScreen or depth < 0 then continue end
        
        local dist = (spos - center).Magnitude
        if dist < bestDist then
            if not CFG.WallCheck or RaycastVisible(Camera.CFrame.Position, part.Position) then
                bestDist = dist
                closest = part
            end
        end
    end
    
    return closest
end

-- FOV CIRCLE (center screen)
local FovCircle = NewDrawing("Circle", {
    Visible = true,
    Thickness = 1,
    Color = Color3.fromRGB(255, 255, 255),
    Transparency = 0.5,
    NumSides = 64,
    Filled = false,
    Position = GetCenterScreen(),
    Radius = CFG.FOV
})

-- ESP PER-PLAYER STORAGE
local EspStorage = {}

local function GetEsp(player)
    if not EspStorage[player] then
        EspStorage[player] = {
            Box = NewDrawing("Square", {Thickness = CFG.ESP.BoxThickness, Transparency = 1, Filled = false}),
            BoxOutline = NewDrawing("Square", {Thickness = CFG.ESP.BoxThickness + 2, Transparency = 1, Filled = false, Color = Color3.new(0,0,0)}),
            CornerTL = NewDrawing("Line", {Thickness = CFG.ESP.BoxThickness}),
            CornerTR = NewDrawing("Line", {Thickness = CFG.ESP.BoxThickness}),
            CornerBL = NewDrawing("Line", {Thickness = CFG.ESP.BoxThickness}),
            CornerBR = NewDrawing("Line", {Thickness = CFG.ESP.BoxThickness}),
            HealthBar = NewDrawing("Square", {Filled = true, Thickness = 1}),
            HealthBarOutline = NewDrawing("Square", {Filled = false, Thickness = 1, Color = Color3.new(0,0,0)}),
            Name = NewDrawing("Text", {Size = CFG.ESP.TextSize, Center = true, Outline = true, OutlineColor = Color3.new(0,0,0)}),
            Distance = NewDrawing("Text", {Size = CFG.ESP.TextSize, Center = true, Outline = true, OutlineColor = Color3.new(0,0,0)}),
            SkeletonLines = {}
        }
        for _ = 1, #SkeletonMap do
            table.insert(EspStorage[player].SkeletonLines, NewDrawing("Line", {Thickness = CFG.ESP.SkeletonThickness}))
        end
    end
    return EspStorage[player]
end

local function ClearPlayerEsp(player)
    local esp = EspStorage[player]
    if not esp then return end
    esp.Box.Visible = false
    esp.BoxOutline.Visible = false
    esp.CornerTL.Visible = false
    esp.CornerTR.Visible = false
    esp.CornerBL.Visible = false
    esp.CornerBR.Visible = false
    esp.HealthBar.Visible = false
    esp.HealthBarOutline.Visible = false
    esp.Name.Visible = false
    esp.Distance.Visible = false
    for _, line in ipairs(esp.SkeletonLines) do line.Visible = false end
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    ClearDrawings()
    
    -- Update FOV circle to center screen (iPad dynamic)
    local center = GetCenterScreen()
    FovCircle.Position = center
    FovCircle.Radius = CFG.FOV
    FovCircle.Visible = CFG.SilentAim
    
    -- Silent Aim Target
    CurrentTarget = GetBestTarget()
    if CurrentTarget then
        FovCircle.Color = Color3.fromRGB(0, 255, 100)
    else
        FovCircle.Color = Color3.fromRGB(255, 255, 255)
    end
    
    -- ESP
    if not CFG.ESP.Enabled then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if IsTeammate(plr) then continue end
        
        local char = plr.Character
        if not IsAlive(char) then
            ClearPlayerEsp(plr)
            continue
        end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then
            ClearPlayerEsp(plr)
            continue
        end
        
        -- Build bbox from all limb screen positions
        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        local anyVisible = false
        
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local spos, onScreen, depth = WorldToScreen(part.Position)
                if onScreen and depth > 0 then
                    anyVisible = true
                    minX = math.min(minX, spos.X)
                    minY = math.min(minY, spos.Y)
                    maxX = math.max(maxX, spos.X)
                    maxY = math.max(maxY, spos.Y)
                end
            end
        end
        
        if not anyVisible then
            ClearPlayerEsp(plr)
            continue
        end
        
        local boxW = maxX - minX
        local boxH = maxY - minY
        local boxPos = Vector2.new(minX, minY)
        
        -- Wall check for color
        local isVisible = RaycastVisible(Camera.CFrame.Position, hrp.Position)
        local boxColor = isVisible and CFG.ESP.BoxVisibleColor or CFG.ESP.BehindWallColor
        local skelColor = isVisible and CFG.ESP.SkeletonVisibleColor or CFG.ESP.SkeletonColor
        
        local esp = GetEsp(plr)
        
        -- Full Box
        if CFG.ESP.Boxes then
            esp.BoxOutline.Visible = true
            esp.BoxOutline.Position = boxPos
            esp.BoxOutline.Size = Vector2.new(boxW, boxH)
            
            esp.Box.Visible = true
            esp.Box.Position = boxPos
            esp.Box.Size = Vector2.new(boxW, boxH)
            esp.Box.Color = boxColor
        end
        
        -- Corner Boxes (CS2 style)
        if CFG.ESP.CornerBoxes then
            local cornerLen = math.min(boxW, boxH) * 0.25
            
            esp.CornerTL.Visible = true
            esp.CornerTL.From = boxPos
            esp.CornerTL.To = boxPos + Vector2.new(cornerLen, 0)
            esp.CornerTL.Color = boxColor
            
            esp.CornerTR.Visible = true
            esp.CornerTR.From = boxPos + Vector2.new(boxW, 0)
            esp.CornerTR.To = boxPos + Vector2.new(boxW - cornerLen, 0)
            esp.CornerTR.Color = boxColor
            
            esp.CornerBL.Visible = true
            esp.CornerBL.From = boxPos + Vector2.new(0, boxH)
            esp.CornerBL.To = boxPos + Vector2.new(cornerLen, boxH)
            esp.CornerBL.Color = boxColor
            
            esp.CornerBR.Visible = true
            esp.CornerBR.From = boxPos + Vector2.new(boxW, boxH)
            esp.CornerBR.To = boxPos + Vector2.new(boxW - cornerLen, boxH)
            esp.CornerBR.Color = boxColor
        end
        
        -- Health Bar
        if CFG.ESP.HealthBar then
            local hpPercent = hum.Health / hum.MaxHealth
            local barH = boxH * hpPercent
            local barW = 3
            local barX = minX - 6
            local barY = minY + (boxH - barH)
            
            esp.HealthBarOutline.Visible = true
            esp.HealthBarOutline.Position = Vector2.new(barX - 1, minY - 1)
            esp.HealthBarOutline.Size = Vector2.new(barW + 2, boxH + 2)
            
            esp.HealthBar.Visible = true
            esp.HealthBar.Position = Vector2.new(barX, barY)
            esp.HealthBar.Size = Vector2.new(barW, barH)
            esp.HealthBar.Color = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
        end
        
        -- Name
        if CFG.ESP.Name then
            esp.Name.Visible = true
            esp.Name.Position = Vector2.new(minX + boxW / 2, minY - 16)
            esp.Name.Text = plr.Name
            esp.Name.Color = boxColor
        end
        
        -- Distance
        if CFG.ESP.Distance then
            local dist = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
            esp.Distance.Visible = true
            esp.Distance.Position = Vector2.new(minX + boxW / 2, maxY + 4)
            esp.Distance.Text = tostring(dist) .. "m"
            esp.Distance.Color = Color3.fromRGB(200, 200, 200)
        end
        
        -- Skeleton
        if CFG.ESP.Skeleton then
            for i, conn in ipairs(SkeletonMap) do
                local p1 = char:FindFirstChild(conn[1])
                local p2 = char:FindFirstChild(conn[2])
                local line = esp.SkeletonLines[i]
                
                if p1 and p2 and line then
                    local s1, v1, d1 = WorldToScreen(p1.Position)
                    local s2, v2, d2 = WorldToScreen(p2.Position)
                    
                    if v1 and v2 and d1 > 0 and d2 > 0 then
                        line.Visible = true
                        line.From = s1
                        line.To = s2
                        line.Color = skelColor
                    else
                        line.Visible = false
                    end
                elseif line then
                    line.Visible = false
                end
            end
        end
    end
end)

-- SILENT AIM HOOK
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if CFG.SilentAim and CurrentTarget and method == "FireServer" then
        local name = tostring(self)
        if name:lower():find("shoot") or name:lower():find("fire") or name:lower():find("bullet") or name:lower():find("hit") or name:lower():find("damage") then
            for i, arg in ipairs(args) do
                if typeof(arg) == "Vector3" then
                    local vel = CurrentTarget.Parent:FindFirstChild("HumanoidRootPart") and CurrentTarget.Parent.HumanoidRootPart.Velocity or Vector3.zero
                    args[i] = CurrentTarget.Position + (vel * CFG.Prediction)
                    break
                elseif typeof(arg) == "CFrame" then
                    local vel = CurrentTarget.Parent:FindFirstChild("HumanoidRootPart") and CurrentTarget.Parent.HumanoidRootPart.Velocity or Vector3.zero
                    args[i] = CFrame.new(CurrentTarget.Position + (vel * CFG.Prediction))
                    break
                end
            end
        end
    end
    
    return oldNamecall(self, unpack(args))
end)

setreadonly(mt, true)

-- TOGGLE UI (tap screen top-right for menu)
local Gui = Instance.new("ScreenGui")
Gui.Parent = game:GetService("CoreGui")
Gui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 280)
Frame.Position = UDim2.new(1, -210, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "4080 | Block Strike"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Frame

local function ToggleBtn(text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 28)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = Frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

ToggleBtn("Silent Aim: ON", 40, function(b)
    CFG.SilentAim = not CFG.SilentAim
    b.Text = "Silent Aim: " .. (CFG.SilentAim and "ON" or "OFF")
end)

ToggleBtn("ESP: ON", 75, function(b)
    CFG.ESP.Enabled = not CFG.ESP.Enabled
    b.Text = "ESP: " .. (CFG.ESP.Enabled and "ON" or "OFF")
end)

ToggleBtn("Boxes: ON", 110, function(b)
    CFG.ESP.Boxes = not CFG.ESP.Boxes
    b.Text = "Boxes: " .. (CFG.ESP.Boxes and "ON" or "OFF")
end)

ToggleBtn("Skeleton: ON", 145, function(b)
    CFG.ESP.Skeleton = not CFG.ESP.Skeleton
    b.Text = "Skeleton: " .. (CFG.ESP.Skeleton and "ON" or "OFF")
end)

ToggleBtn("Wall Check: ON", 180, function(b)
    CFG.WallCheck = not CFG.WallCheck
    b.Text = "Wall Check: " .. (CFG.WallCheck and "ON" or "OFF")
end)

ToggleBtn("Team Check: ON", 215, function(b)
    CFG.TeamCheck = not CFG.TeamCheck
    b.Text = "Team Check: " .. (CFG.TeamCheck and "ON" or "OFF")
end)

ToggleBtn("Destroy UI", 250, function()
    Gui:Destroy()
end)

print("4080 Block Strike iPad loaded | Center-screen aim | CS2 ESP | Tap top-right for menu")
