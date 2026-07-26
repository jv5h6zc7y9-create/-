-- Block Strike iPad | Delta iOS
-- Tap-to-fire headshot: remembers aim → redirects to nearest head → no recoil/spread → restores on kill
-- Lightweight, no ESP, pure combat

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- CONFIG
local CFG = {
    Enabled = true,
    FOV = 140,              -- degrees from center screen
    TeamCheck = true,
    HitPart = "Head",
    Prediction = 0.08,      -- bullet travel compensation
    RestoreDelay = 0.35,    -- seconds to wait for kill before force restore
    RestoreSpeed = 0.15,    -- tween time for smooth return
    MaxDistance = 400,
    WallCheck = false       -- set true if you want LOS check (costs FPS)
}

-- STATE
local OriginalCF = nil
local IsAiming = false
local LastTarget = nil
local LastFireTime = 0

-- UTILS
local function W2S(pos)
    local s = Camera:WorldToViewportPoint(pos)
    return Vector2.new(s.X, s.Y), s.Z
end

local function GetCenter()
    local vp = Camera.ViewportSize
    return Vector2.new(vp.X / 2, vp.Y / 2)
end

local function IsAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function IsTeammate(p)
    return CFG.TeamCheck and p.Team == LocalPlayer.Team
end

-- FIND NEAREST HEAD TO CENTER SCREEN
local function GetTarget()
    local center = GetCenter()
    local camPos = Camera.CFrame.Position
    local best, bestDist = nil, CFG.FOV

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if IsTeammate(plr) then continue end

        local char = plr.Character
        if not IsAlive(char) then continue end

        local head = char:FindFirstChild(CFG.HitPart)
        if not head then continue end

        local spos, depth = W2S(head.Position)
        if depth <= 0 then continue end

        local dist2d = (spos - center).Magnitude
        if dist2d >= bestDist then continue end

        if CFG.WallCheck then
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {LocalPlayer.Character, char}
            rp.FilterType = Enum.RaycastFilterType.Blacklist
            if Workspace:Raycast(camPos, (head.Position - camPos).Unit * 1000, rp) then
                continue
            end
        end

        local dist3d = (head.Position - camPos).Magnitude
        if dist3d > CFG.MaxDistance then continue end

        bestDist = dist2d
        best = head
    end

    return best
end

-- RESTORE CAMERA
local function RestoreCamera()
    if not OriginalCF then return end
    IsAiming = false

    local tween = TweenService:Create(Camera, TweenInfo.new(CFG.RestoreSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = OriginalCF
    })
    tween:Play()

    OriginalCF = nil
    LastTarget = nil
end

local function ForceRestore()
    if not IsAiming then return end
    RestoreCamera()
end

-- KILL DETECTION
local function WatchForKill(targetHead)
    if not targetHead or not targetHead.Parent then
        task.delay(CFG.RestoreDelay, ForceRestore)
        return
    end

    local hum = targetHead.Parent:FindFirstChildOfClass("Humanoid")
    if not hum then
        task.delay(CFG.RestoreDelay, ForceRestore)
        return
    end

    local conn
    conn = hum.HealthChanged:Connect(function(health)
        if health <= 0 then
            conn:Disconnect()
            RestoreCamera()
        end
    end)

    -- Fallback timeout
    task.delay(CFG.RestoreDelay + 0.2, function()
        if conn.Connected then
            conn:Disconnect()
            ForceRestore()
        end
    end)
end

-- FIRE INTERCEPT
local function OnFire()
    if not CFG.Enabled then return end
    if IsAiming then return end -- already handling a shot

    local target = GetTarget()
    if not target then return end

    IsAiming = true
    OriginalCF = Camera.CFrame
    LastTarget = target
    LastFireTime = tick()

    -- Calculate aim CFrame at target head
    local vel = target.Parent:FindFirstChild("HumanoidRootPart") and target.Parent.HumanoidRootPart.Velocity or Vector3.zero
    local aimPos = target.Position + (vel * CFG.Prediction)

    -- Snap camera to target (game calculates shot from camera)
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPos)

    -- Start kill watcher
    WatchForKill(target)
end

-- INPUT HOOK (touch + mouse)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        OnFire()
    end
end)

-- REMOTE HOOK (catches Block Strike fire remotes, redirects args to snapped target)
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" then
        local name = tostring(self):lower()

        -- Detect fire/shoot remotes
        if name:find("shoot") or name:find("fire") or name:find("bullet") or name:find("hit") or name:find("damage") or name:find("gun") or name:find("weapon") then

            -- If we have a target from OnFire, inject head position into args
            if IsAiming and LastTarget and LastTarget.Parent then
                local vel = LastTarget.Parent:FindFirstChild("HumanoidRootPart") and LastTarget.Parent.HumanoidRootPart.Velocity or Vector3.zero
                local aimPos = LastTarget.Position + (vel * CFG.Prediction)

                for i, arg in ipairs(args) do
                    if typeof(arg) == "Vector3" then
                        args[i] = aimPos
                        break
                    elseif typeof(arg) == "CFrame" then
                        args[i] = CFrame.new(aimPos)
                        break
                    elseif typeof(arg) == "Ray" then
                        args[i] = Ray.new(Camera.CFrame.Position, (aimPos - Camera.CFrame.Position).Unit * 1000)
                        break
                    end
                end
            end
        end
    end

    return oldNamecall(self, unpack(args))
end)

setreadonly(mt, true)

-- NO RECOIL / NO SPREAD
-- Zero out weapon recoil tables found in memory
task.spawn(function()
    task.wait(2) -- let game load modules

    for _, v in pairs(getgc()) do
        if typeof(v) == "table" then
            -- Common recoil/spread field names
            local fields = {"Recoil", "Spread", "CameraRecoil", "MaxSpread", "MinSpread", "RecoilX", "RecoilY", "Kick", "KickUp", "KickSide", "Bloom", "Accuracy"}
            for _, f in ipairs(fields) do
                if v[f] ~= nil and typeof(v[f]) == "number" then
                    v[f] = 0
                elseif v[f] ~= nil and typeof(v[f]) == "table" then
                    for k, _ in pairs(v[f]) do
                        if typeof(v[f][k]) == "number" then
                            v[f][k] = 0
                        end
                    end
                end
            end

            -- Some games store recoil as Vector3
            if v.Recoil and typeof(v.Recoil) == "Vector3" then
                v.Recoil = Vector3.zero
            end
            if v.Spread and typeof(v.Spread) == "Vector3" then
                v.Spread = Vector3.zero
            end
        end
    end

    -- Hook any camera shaker/recoil functions
    for _, v in pairs(getgc()) do
        if typeof(v) == "function" and islclosure(v) then
            local info = debug.getinfo(v)
            if info and info.name then
                local n = info.name:lower()
                if n:find("recoil") or n:find("spread") or n:find("kick") or n:find("shake") or n:find("bloom") then
                    local old = v
                    -- Can't replace gc function directly, but we can hook if it's in a table
                end
            end
        end
    end
end)

-- CONTINUOUS RECOIL WIPE (keeps zeroing every frame in case game resets)
RunService.Heartbeat:Connect(function()
    if not CFG.Enabled then return end

    for _, v in pairs(getgc()) do
        if typeof(v) == "table" then
            if v.CurrentRecoil and typeof(v.CurrentRecoil) == "Vector3" then
                v.CurrentRecoil = Vector3.zero
            end
            if v.CurrentSpread and typeof(v.CurrentSpread) == "number" then
                v.CurrentSpread = 0
            end
            if v.RecoilTimer and typeof(v.RecoilTimer) == "number" then
                v.RecoilTimer = 0
            end
        end
    end
end)

-- TOGGLE UI
local Gui = Instance.new("ScreenGui")
Gui.Parent = game:GetService("CoreGui")
Gui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 160, 0, 140)
Frame.Position = UDim2.new(1, -170, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BorderSizePixel = 0
Frame.Parent = Gui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 24)
Title.Text = "4080 | Trigger"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = Frame

local function Btn(text, y, var)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 26)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Text = text .. ": " .. (CFG[var] and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.Parent = Frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        CFG[var] = not CFG[var]
        btn.Text = text .. ": " .. (CFG[var] and "ON" or "OFF")
    end)
    return btn
end

Btn("Aim", 30, "Enabled")
Btn("Team Check", 62, "TeamCheck")
Btn("Wall Check", 94, "WallCheck")

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0.9, 0, 0, 24)
Close.Position = UDim2.new(0.05, 0, 0, 126)
Close.Text = "Close"
Close.TextColor3 = Color3.fromRGB(255, 80, 80)
Close.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Close.Font = Enum.Font.Gotham
Close.TextSize = 11
Close.Parent = Frame
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 4)
Close.MouseButton1Click:Connect(function() Gui:Destroy() end)

-- FOV CIRCLE (lightweight, just 1 drawing)
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = true
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Transparency = 0.4
FovCircle.NumSides = 32
FovCircle.Filled = false

RunService.RenderStepped:Connect(function()
    local vp = Camera.ViewportSize
    FovCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)
    FovCircle.Radius = CFG.FOV
    FovCircle.Color = IsAiming and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 255, 255)
end)

print("4080 Trigger Aim loaded | Tap to snap | No recoil | Auto-restore on kill")
