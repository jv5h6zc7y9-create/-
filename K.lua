-- Silent Aim Script for Roblox (Mobile/iPad)
-- Place in AutoExecute or execute via exploit

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Enabled = true
local ToggleKey = Enum.KeyCode.RightControl -- Works with keyboard connected to iPad

-- Settings
local Settings = {
    FOV = 120, -- Field of view radius
    Smoothness = 0.5, -- 0 to 1, higher = smoother
    TargetPart = "Head", -- "Head", "HumanoidRootPart", or "Torso"
    TeamCheck = false,
    WallCheck = false,
    VisibilityCheck = true,
}

-- FOV Circle Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Radius = Settings.FOV
FOVCircle.Visible = true

local function GetClosestPlayer()
    local ClosestPlayer = nil
    local ShortestDistance = Settings.FOV
    
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Character = Player.Character
            local TargetPart = Character:FindFirstChild(Settings.TargetPart)
            local Humanoid = Character:FindFirstChild("Humanoid")
            
            if TargetPart and Humanoid and Humanoid.Health > 0 then
                -- Team check
                if Settings.TeamCheck and Player.Team == LocalPlayer.Team then
                    continue
                end
                
                -- Visibility check
                if Settings.VisibilityCheck then
                    local RayParams = RaycastParams.new()
                    RayParams.FilterType = Enum.RaycastFilterType.Exclude
                    RayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    
                    local Origin = Camera.CFrame.Position
                    local Direction = (TargetPart.Position - Origin)
                    local RayResult = workspace:Raycast(Origin, Direction, RayParams)
                    
                    if RayResult and RayResult.Instance then
                        if not RayResult.Instance:IsDescendantOf(Character) then
                            continue
                        end
                    end
                end
                
                -- Wall check
                if Settings.WallCheck then
                    local RayParams = RaycastParams.new()
                    RayParams.FilterType = Enum.RaycastFilterType.Exclude
                    RayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    
                    local Origin = Camera.CFrame.Position
                    local Direction = (TargetPart.Position - Origin)
                    local RayResult = workspace:Raycast(Origin, Direction, RayParams)
                    
                    if RayResult and not RayResult.Instance:IsDescendantOf(Character) then
                        continue
                    end
                end
                
                -- Screen position calculation
                local ScreenPos, OnScreen = Camera:WorldToScreenPoint(TargetPart.Position)
                
                if OnScreen then
                    local ViewportSize = Camera.ViewportSize
                    local Center = ViewportSize / 2
                    local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                    
                    if Distance < ShortestDistance then
                        ShortestDistance = Distance
                        ClosestPlayer = Player
                    end
                end
            end
        end
    end
    
    return ClosestPlayer
end

-- Main silent aim hook
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Arguments = {...}
    
    if Enabled and Method == "FindPartOnRayWithWhitelist" or Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRay" then
        local Target = GetClosestPlayer()
        
        if Target and Target.Character then
            local TargetPart = Target.Character:FindFirstChild(Settings.TargetPart)
            if TargetPart then
                -- Modify the ray direction to hit the target
                if typeof(Arguments[1]) == "Instance" then
                    local Ray = Arguments[1]
                    if Ray and Ray.Origin then
                        local NewDirection = (TargetPart.Position - Ray.Origin).Unit * Ray.Direction.Magnitude
                        Arguments[1] = Ray.new(Ray.Origin, NewDirection)
                    end
                end
            end
        end
    end
    
    return OldNamecall(self, unpack(Arguments))
end)

-- Camera modification for mobile
local function ModifyCamera()
    if not Enabled then return end
    
    local Target = GetClosestPlayer()
    if Target and Target.Character then
        local TargetPart = Target.Character:FindFirstChild(Settings.TargetPart)
        if TargetPart then
            -- This is the silent part - we don't actually move the camera
            -- We just modify where the hits register
            -- For actual aim assist on mobile, you'd modify touch input
        end
    end
end

-- Update loop
RunService.RenderStepped:Connect(function()
    -- Update FOV circle position
    local Center = Camera.ViewportSize / 2
    FOVCircle.Position = Center
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Enabled
    
    ModifyCamera()
end)

-- Toggle functionality
UserInputService.InputBegan:Connect(function(Input, Processed)
    if not Processed then
        if Input.KeyCode == ToggleKey then
            Enabled = not Enabled
        end
    end
end)

-- Mobile toggle button (for iPad without keyboard)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SilentAimToggle"
ScreenGui.Parent = game.CoreGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 100, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0.5, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "SA: ON"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Parent = ScreenGui

ToggleButton.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    ToggleButton.Text = Enabled and "SA: ON" or "SA: OFF"
    ToggleButton.BackgroundColor3 = Enabled and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(120, 40, 40)
end)

-- Cleanup on player leaving
Players.LocalPlayer.OnTeleport:Connect(function()
    FOVCircle:Remove()
    ScreenGui:Remove()
end)

print("Silent Aim loaded - iPad compatible")
