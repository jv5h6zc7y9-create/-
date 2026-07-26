-- Block Strike iPad | Delta iOS | Performance Build
-- Object pooling, throttled raycasts, simplified skeleton, distance culling
-- Target: 60 FPS on iPad Air / Pro

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

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
        HealthBar = true,
        Name = true,
        Distance = true,
        Skeleton = true,
        MaxDistance = 500,
        BoxColor = Color3.fromRGB(255, 50, 50),
        BoxVisibleColor = Color3.fromRGB(50, 255, 50),
        SkeletonColor = Color3.fromRGB(180, 180, 180),
        SkeletonVisibleColor = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        UpdateRate = 2, -- update ESP every N frames (2 = 30Hz)
        RaycastRate = 6  -- wallcheck every N frames (6 = 10Hz)
    }
}

-- OBJECT POOL
local DrawingPool = {}
local function GetDrawing(type)
    for i, d in ipairs(DrawingPool) do
        if not d._inUse and d._type == type then
            d._inUse = true
            d.Visible = false
            return d
        end
    end
    local d = Drawing.new(type)
    d._type = type
    d._inUse = true
    table.insert(DrawingPool, d)
    return d
end

local function ReleaseDrawing(d)
    if d then
        d.Visible = false
        d._inUse = false
    end
end

-- SIMPLIFIED SKELETON (7 lines vs 13)
local SkeletonBones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LowerTorso", "HumanoidRootPart"}
}

-- PER-PLAYER OBJECT CACHE
local PlayerCache = {}

local function GetCache(plr)
    if not PlayerCache[plr] then
        PlayerCache[plr] = {
            Box = GetDrawing("Square"),
            BoxOutline = GetDrawing("Square"),
            HealthBar = GetDrawing("Square"),
            HealthOutline = GetDrawing("Square"),
            Name = GetDrawing("Text"),
            Dist = GetDrawing("Text"),
            Bones = {},
            LastRaycast = 0,
            IsVisible = true,
            Char = nil,
            Hum = nil,
            HRP = nil,
            Head = nil
        }
        for _ = 1, #SkeletonBones do
            table.insert(PlayerCache[plr].Bones, GetDrawing("Line"))
        end
    end
    return PlayerCache[plr]
end

local function ClearCache(plr)
    local c = PlayerCache[plr]
    if not c then return end
    ReleaseDrawing(c.Box)
    ReleaseDrawing(c.BoxOutline)
    ReleaseDrawing(c.HealthBar)
    ReleaseDrawing(c.HealthOutline)
    ReleaseDrawing(c.Name)
    ReleaseDrawing(c.Dist)
    for _, b in ipairs(c.Bones) do ReleaseDrawing(b) end
    PlayerCache[plr] = nil
end

-- FAST UTILS
local function W2S(pos)
    local s = Camera:WorldToViewportPoint(pos)
    return Vector2.new(s.X, s.Y), s.Z
end

local function IsAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function IsTeammate(p)
    return CFG.TeamCheck and p.Team == LocalPlayer.Team
end

local FrameCount = 0
local CenterScreen = Vector2.zero

-- SILENT AIM
local CurrentTarget = nil

local function FindTarget()
    local best, bestDist = nil, CFG.FOV
    local camPos = Camera.CFrame.Position
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if IsTeammate(plr) then continue end
        
        local char = plr.Character
        if not char then continue end
        local head = char:FindFirstChild(CFG.HitPart)
        if not head then continue end
        
        local spos, depth = W2S(head.Position)
        if depth <= 0 then continue end
        
        local dist = (spos - CenterScreen).Magnitude
        if dist >= bestDist then continue end
        
        if CFG.WallCheck then
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {LocalPlayer.Character, char}
            rp.FilterType = Enum.RaycastFilterType.Blacklist
            if Workspace:Raycast(camPos, (head.Position - camPos).Unit * 1000, rp) then
                continue
            end
        end
        
        bestDist = dist
        best = head
    end
    
    return best
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    FrameCount += 1
    local vp = Camera.ViewportSize
    CenterScreen = Vector2.new(vp.X / 2, vp.Y / 2)
    
    -- Silent aim every frame (lightweight)
    CurrentTarget = CFG.SilentAim and FindTarget() or nil
    
    -- ESP throttled
    if FrameCount % CFG.ESP.UpdateRate ~= 0 then return end
    
    local camPos = Camera.CFrame.Position
    local shouldRaycast = FrameCount % CFG.ESP.RaycastRate == 0
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if IsTeammate(plr) then continue end
        
        local char = plr.Character
        if not IsAlive(char) then
            ClearCache(plr)
            continue
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not head or not hum then
            ClearCache(plr)
            continue
        end
        
        -- Distance cull
        local dist3d = (hrp.Position - camPos).Magnitude
        if dist3d > CFG.ESP.MaxDistance then
            ClearCache(plr)
            continue
        end
        
        -- Fast bbox from 6 points (head, hrp, 4 limbs)
        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        local anyOnScreen = false
        
        local function AddPoint(part)
            if not part then return end
            local spos, depth = W2S(part.Position)
            if depth > 0 then
                anyOnScreen = true
                minX = math.min(minX, spos.X)
                minY = math.min(minY, spos.Y)
                maxX = math.max(maxX, spos.X)
                maxY = math.max(maxY, spos.Y)
            end
        end
        
        AddPoint(head)
        AddPoint(hrp)
        AddPoint(char:FindFirstChild("RightUpperArm"))
        AddPoint(char:FindFirstChild("LeftUpperArm"))
        AddPoint(char:FindFirstChild("RightUpperLeg"))
        AddPoint(char:FindFirstChild("LeftUpperLeg"))
        
        if not anyOnScreen then
            ClearCache(plr)
            continue
        end
        
        local boxW = maxX - minX
        local boxH = maxY - minY
        if boxW < 5 or boxH < 5 then
            ClearCache(plr)
            continue
        end
        
        -- Throttled wall check
        local c = GetCache(plr)
        if shouldRaycast then
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {LocalPlayer.Character, char}
            rp.FilterType = Enum.RaycastFilterType.Blacklist
            local res = Workspace:Raycast(camPos, (head.Position - camPos).Unit * 1000, rp)
            c.IsVisible = res == nil
        end
        
        local boxColor = c.IsVisible and CFG.ESP.BoxVisibleColor or CFG.ESP.BoxColor
        local skelColor = c.IsVisible and CFG.ESP.SkeletonVisibleColor or CFG.ESP.SkeletonColor
        
        -- Box
        if CFG.ESP.Boxes then
            c.BoxOutline.Visible = true
            c.BoxOutline.Position = Vector2.new(minX, minY)
            c.BoxOutline.Size = Vector2.new(boxW, boxH)
            c.BoxOutline.Color = Color3.new(0, 0, 0)
            c.BoxOutline.Thickness = 2
            c.BoxOutline.Filled = false
            
            c.Box.Visible = true
            c.Box.Position = Vector2.new(minX, minY)
            c.Box.Size = Vector2.new(boxW, boxH)
            c.Box.Color = boxColor
            c.Box.Thickness = 1
            c.Box.Filled = false
        else
            c.Box.Visible = false
            c.BoxOutline.Visible = false
        end
        
        -- Health bar
        if CFG.ESP.HealthBar then
            local hp = hum.Health / hum.MaxHealth
            local barH = boxH * hp
            local barX = minX - 5
            local barY = minY + boxH - barH
            
            c.HealthOutline.Visible = true
            c.HealthOutline.Position = Vector2.new(barX - 1, minY - 1)
            c.HealthOutline.Size = Vector2.new(4, boxH + 2)
            c.HealthOutline.Color = Color3.new(0, 0, 0)
            c.HealthOutline.Filled = true
            
            c.HealthBar.Visible = true
            c.HealthBar.Position = Vector2.new(barX, barY)
            c.HealthBar.Size = Vector2.new(2, barH)
            c.HealthBar.Color = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
            c.HealthBar.Filled = true
        else
            c.HealthBar.Visible = false
            c.HealthOutline.Visible = false
        end
        
        -- Name
        if CFG.ESP.Name then
            c.Name.Visible = true
            c.Name.Position = Vector2.new(minX + boxW / 2, minY - 14)
            c.Name.Text = plr.Name
            c.Name.Size = CFG.ESP.TextSize
            c.Name.Center = true
            c.Name.Outline = true
            c.Name.Color = boxColor
        else
            c.Name.Visible = false
        end
        
        -- Distance
        if CFG.ESP.Distance then
            c.Dist.Visible = true
            c.Dist.Position = Vector2.new(minX + boxW / 2, maxY + 2)
            c.Dist.Text = math.floor(dist3d) .. "m"
            c.Dist.Size = CFG.ESP.TextSize
            c.Dist.Center = true
            c.Dist.Outline = true
            c.Dist.Color = Color3.fromRGB(200, 200, 200)
        else
            c.Dist.Visible = false
        end
        
        -- Skeleton (simplified, 7 bones)
        if CFG.ESP.Skeleton then
            for i, bone in ipairs(SkeletonBones) do
                local p1 = char:FindFirstChild(bone[1])
                local p2 = char:FindFirstChild(bone[2])
                local line = c.Bones[i]
                
                if p1 and p2 then
                    local s1, d1 = W2S(p1.Position)
                    local s2, d2 = W2S(p2.Position)
                    
                    if d1 > 0 and d2 > 0 then
                        line.Visible = true
                        line.From = s1
                        line.To = s2
                        line.Color = skelColor
                        line.Thickness = 1
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            end
        else
            for _, line in ipairs(c.Bones) do line.Visible = false end
        end
    end
end)

-- CLEANUP DISCONNECTED PLAYERS
Players.PlayerRemoving:Connect(function(plr)
    ClearCache(plr)
end)

-- SILENT AIM HOOK
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if CFG.SilentAim and CurrentTarget and method == "FireServer" then
        local name = tostring(self):lower()
        if name:find("shoot") or name:find("fire") or name:find("bullet") or name:find("hit") or name:find("damage") or name:find("gun") then
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

-- MINIMAL TOGGLE UI
local Gui = Instance.new("ScreenGui")
Gui.Parent = CoreGui
Gui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 180, 0, 220)
Frame.Position = UDim2.new(1, -190, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BorderSizePixel = 0
Frame.Parent = Gui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 26)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "4080 | iPad"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = Frame

local function MakeBtn(text, y, flag)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 26)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Text = text .. ": " .. (CFG[flag] and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.Parent = Frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        CFG[flag] = not CFG[flag]
        btn.Text = text .. ": " .. (CFG[flag] and "ON" or "OFF")
    end)
end

MakeBtn("Silent Aim", 32, "SilentAim")
MakeBtn("ESP", 64, "Enabled")
MakeBtn("ESP", 64, "Enabled")
MakeBtn("Boxes", 96, "Boxes")
MakeBtn("Skeleton", 128, "Skeleton")
MakeBtn("Wall Check", 160, "WallCheck")

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.9, 0, 0, 26)
CloseBtn.Position = UDim2.new(0.05, 0, 0, 192)
CloseBtn.Text = "Close UI"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.TextSize = 11
CloseBtn.Parent = Frame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
CloseBtn.MouseButton1Click:Connect(function() Gui:Destroy() end)

print("4080 Block Strike iPad | Optimized | Pool: " .. #DrawingPool .. " objects | Rate: " .. CFG.ESP.UpdateRate .. "f")
