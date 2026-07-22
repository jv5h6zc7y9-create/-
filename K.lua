local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalAimbotAndEspSystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FOVCircle.BackgroundTransparency = 0.85
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = true
FOVCircle.Parent = ScreenGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 2
FOVStroke.Color = Color3.fromRGB(255, 0, 0)
FOVStroke.Parent = FOVCircle

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Size = UDim2.new(0, 55, 0, 55)
MenuButton.AnchorPoint = Vector2.new(0.5, 0.5)
MenuButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MenuButton.Text = "⚙️"
MenuButton.TextSize = 28
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.Parent = ScreenGui

local MenuButtonCorner = Instance.new("UICorner")
MenuButtonCorner.CornerRadius = UDim.new(0.3, 0)
MenuButtonCorner.Parent = MenuButton

local MenuButtonStroke = Instance.new("UIStroke")
MenuButtonStroke.Thickness = 2
MenuButtonStroke.Color = Color3.fromRGB(120, 120, 120)
MenuButtonStroke.Parent = MenuButton

local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 340, 0, 420)
MainMenu.Position = UDim2.new(0.5, -170, 0.5, -210)
MainMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

local MainMenuCorner = Instance.new("UICorner")
MainMenuCorner.CornerRadius = UDim.new(0.04, 0)
MainMenuCorner.Parent = MainMenu

local MainMenuStroke = Instance.new("UIStroke")
MainMenuStroke.Thickness = 2
MainMenuStroke.Color = Color3.fromRGB(70, 70, 70)
MainMenuStroke.Parent = MainMenu

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleLabel.Text = "iPad Pro 11 Premium Menu"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainMenu

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0.15, 0)
TitleCorner.Parent = TitleLabel

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -38, 0, 6)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
CloseButton.Text = "❌"
CloseButton.TextSize = 14
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = MainMenu

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0.3, 0)
CloseCorner.Parent = CloseButton

local ModeButton = Instance.new("TextButton")
ModeButton.Name = "ModeButton"
ModeButton.Size = UDim2.new(0, 300, 0, 45)
ModeButton.Position = UDim2.new(0.5, -150, 0, 65)
ModeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ModeButton.Text = "Режим: Выкл"
ModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeButton.TextSize = 16
ModeButton.Font = Enum.Font.SourceSansBold
ModeButton.Parent = MainMenu

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0.2, 0)
ModeCorner.Parent = ModeButton

local ModeStroke = Instance.new("UIStroke")
ModeStroke.Thickness = 1
ModeStroke.Color = Color3.fromRGB(90, 90, 90)
ModeStroke.Parent = ModeButton

local TargetButton = Instance.new("TextButton")
TargetButton.Name = "TargetButton"
TargetButton.Size = UDim2.new(0, 300, 0, 45)
TargetButton.Position = UDim2.new(0.5, -150, 0, 125)
TargetButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TargetButton.Text = "Цель: Head"
TargetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetButton.TextSize = 16
TargetButton.Font = Enum.Font.SourceSansBold
TargetButton.Parent = MainMenu

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(0.2, 0)
TargetCorner.Parent = TargetButton

local TargetStroke = Instance.new("UIStroke")
TargetStroke.Thickness = 1
TargetStroke.Color = Color3.fromRGB(90, 90, 90)
TargetStroke.Parent = TargetButton

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Name = "SliderLabel"
SliderLabel.Size = UDim2.new(0, 300, 0, 25)
SliderLabel.Position = UDim2.new(0.5, -150, 0, 190)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Радиус FOV: 100 px"
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.TextSize = 16
SliderLabel.Font = Enum.Font.SourceSansBold
SliderLabel.Parent = MainMenu

local SliderBar = Instance.new("Frame")
SliderBar.Name = "SliderBar"
SliderBar.Size = UDim2.new(0, 300, 0, 12)
SliderBar.Position = UDim2.new(0.5, -150, 0, 225)
SliderBar.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
SliderBar.BorderSizePixel = 0
SliderBar.Parent = MainMenu

local SliderBarCorner = Instance.new("UICorner")
SliderBarCorner.CornerRadius = UDim.new(1, 0)
SliderBarCorner.Parent = SliderBar

local SliderBtn = Instance.new("TextButton")
SliderBtn.Name = "SliderBtn"
SliderBtn.Size = UDim2.new(0, 22, 0, 22)
SliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
SliderBtn.Position = UDim2.new(0.318, 0, 0.5, 0)
SliderBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
SliderBtn.Text = ""
SliderBtn.Parent = SliderBar

local SliderBtnCorner = Instance.new("UICorner")
SliderBtnCorner.CornerRadius = UDim.new(1, 0)
SliderBtnCorner.Parent = SliderBtn

local SliderBtnStroke = Instance.new("UIStroke")
SliderBtnStroke.Thickness = 1
SliderBtnStroke.Color = Color3.fromRGB(0, 0, 0)
SliderBtnStroke.Parent = SliderBtn

local ESPToggle = Instance.new("TextButton")
ESPToggle.Name = "ESPToggle"
ESPToggle.Size = UDim2.new(0, 300, 0, 45)
ESPToggle.Position = UDim2.new(0.5, -150, 0, 265)
ESPToggle.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
ESPToggle.Text = "ESP: ВЫКЛ"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.TextSize = 16
ESPToggle.Font = Enum.Font.SourceSansBold
ESPToggle.Parent = MainMenu

local ESPToggleCorner = Instance.new("UICorner")
ESPToggleCorner.CornerRadius = UDim.new(0.2, 0)
ESPToggleCorner.Parent = ESPToggle

local ESPToggleStroke = Instance.new("UIStroke")
ESPToggleStroke.Thickness = 1
ESPToggleStroke.Color = Color3.fromRGB(90, 90, 90)
ESPToggleStroke.Parent = ESPToggle

local CreditLabel = Instance.new("TextLabel")
CreditLabel.Name = "CreditLabel"
CreditLabel.Size = UDim2.new(1, 0, 0, 30)
CreditLabel.Position = UDim2.new(0, 0, 1, -35)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "iPad Pro 11 Anti-Aliased Engine Active"
CreditLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
CreditLabel.TextSize = 13
CreditLabel.Font = Enum.Font.SourceSansItalic
CreditLabel.Parent = MainMenu

local ESPContainer = Instance.new("Folder")
ESPContainer.Name = "ESPContainer"
ESPContainer.Parent = ScreenGui

local fovRadius = 100
local aimMode = "Выкл"
local aimTarget = "Head"
local espEnabled = false

local screenCenter = Vector2.new(0, 0)
local menuButtonPosition = nil

local function updateCenter()
	local viewportSize = Camera.ViewportSize
	local guiInset = GuiService:GetGuiInset()
	screenCenter = Vector2.new(viewportSize.X / 2, (viewportSize.Y + guiInset.Y) / 2)
	FOVCircle.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
	if not menuButtonPosition then
		MenuButton.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
	end
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCenter)
updateCenter()

task.spawn(function()
	while task.wait(0.5) do
		updateCenter()
	end
end)

local draggingButton = false
local dragInputButton = nil
local dragStartButton = nil
local startPosButton = nil

MenuButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingButton = true
		dragStartButton = input.Position
		startPosButton = MenuButton.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				draggingButton = false
			end
		end)
	end
end)

MenuButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInputButton = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInputButton and draggingButton then
		local delta = input.Position - dragStartButton
		local newPos = UDim2.new(startPosButton.X.Scale, startPosButton.X.Offset + delta.X, startPosButton.Y.Scale, startPosButton.Y.Offset + delta.Y)
		MenuButton.Position = newPos
		menuButtonPosition = newPos
	end
end)

MenuButton.MouseButton1Click:Connect(function()
	if not draggingButton then
		MainMenu.Visible = not MainMenu.Visible
	end
end)

CloseButton.MouseButton1Click:Connect(function()
	MainMenu.Visible = false
end)

local function updateFOV(radius)
	fovRadius = radius
	FOVCircle.Size = UDim2.new(0, radius * 2, 0, radius * 2)
	SliderLabel.Text = "Радиус FOV: " .. tostring(math.round(radius)) .. " px"
end

updateFOV(fovRadius)

local draggingSlider = false

local function moveSlider(input)
	local rX = input.Position.X - SliderBar.AbsolutePosition.X
	local percentage = math.clamp(rX / SliderBar.AbsoluteSize.X, 0, 1)
	SliderBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
	local newRadius = 30 + (percentage * 220)
	updateFOV(newRadius)
end

SliderBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
		moveSlider(input)
	end
end)

ModeButton.MouseButton1Click:Connect(function()
	if aimMode == "Выкл" then
		aimMode = "Обычный Аим"
		ModeButton.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
	elseif aimMode == "Обычный Аим" then
		aimMode = "Сайлент Аим"
		ModeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 140)
	else
		aimMode = "Выкл"
		ModeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	end
	ModeButton.Text = "Режим: " .. aimMode
end)

TargetButton.MouseButton1Click:Connect(function()
	if aimTarget == "Head" then
		aimTarget = "HumanoidRootPart"
	else
		aimTarget = "Head"
	end
	TargetButton.Text = "Цель: " .. aimTarget
end)

ESPToggle.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	if espEnabled then
		ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
		ESPToggle.Text = "ESP: ВКЛ"
	else
		ESPToggle.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
		ESPToggle.Text = "ESP: ВЫКЛ"
		ESPContainer:ClearAllChildren()
	end
end)

local function isVisible(targetPart)
	local character = LocalPlayer.Character
	if not character then return false end
	local originPart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
	if not originPart then return false end
	local origin = originPart.Position
	local direction = targetPart.Position - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character, targetPart.Parent}
	params.IgnoreWater = true
	local result = workspace:Raycast(origin, direction, params)
	return result == nil
end

local function getClosestVisibleEnemy()
	local closestPlayer = nil
	local shortestDistance = math.huge
	local currentTargetPartName = aimTarget
	if aimMode == "Сайлент Аим" then
		currentTargetPartName = "Head"
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if not player.Team or player.Team ~= LocalPlayer.Team then
				local char = player.Character
				if char then
					local humanoid = char:FindFirstChildOfClass("Humanoid")
					local targetPart = char:FindFirstChild(currentTargetPartName)
					if humanoid and humanoid.Health > 0 and targetPart then
						local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
						if onScreen then
							local mousePos = Vector2.new(screenPos.X, screenPos.Y)
							local distance = (mousePos - screenCenter).Magnitude
							if distance <= fovRadius and distance < shortestDistance then
								if isVisible(targetPart) then
									shortestDistance = distance
									closestPlayer = player
								end
							end
						end
					end
				end
			end
		end
	end
	return closestPlayer
end

local function createESPBoxes(player)
	local name = player.Name
	local box = ESPContainer:FindFirstChild(name .. "_Box") or Instance.new("Frame")
	local stroke = box:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	local hpBar = ESPContainer:FindFirstChild(name .. "_HPBar") or Instance.new("Frame")
	local hpFill = hpBar:FindFirstChild("Fill") or Instance.new("Frame")
	local distLabel = ESPContainer:FindFirstChild(name .. "_Dist") or Instance.new("TextLabel")
	
	if not box.Parent then
		box.Name = name .. "_Box"
		box.BackgroundTransparency = 1
		box.Parent = ESPContainer
		
		stroke.Thickness = 1.5
		stroke.Color = Color3.fromRGB(255, 0, 0)
		stroke.Parent = box
		
		hpBar.Name = name .. "_HPBar"
		hpBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		hpBar.BorderSizePixel = 0
		hpBar.Parent = ESPContainer
		
		hpFill.Name = "Fill"
		hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		hpFill.BorderSizePixel = 0
		hpFill.Parent = hpBar
		
		distLabel.Name = name .. "_Dist"
		distLabel.BackgroundTransparency = 1
		distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		distLabel.TextSize = 13
		distLabel.Font = Enum.Font.SourceSansBold
		distLabel.TextStrokeTransparency = 0
		distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		distLabel.Parent = ESPContainer
	end
	
	return box, stroke, hpBar, hpFill, distLabel
end

local isHooked = false
local originalHook

local function applySilentAimHook(targetPart)
	if isHooked then return end
	isHooked = true
	originalHook = hookmetamethod(game, "__index", function(self, key)
		if not select(2, pcall(function() return self.ClassName end)) then
			return originalHook(self, key)
		end
		if self == UserInputService and key == "GetMouseLocation" and aimMode == "Сайлент Аим" and targetPart and targetPart.Parent then
			local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
			if onScreen then
				return Vector2.new(screenPos.X, screenPos.Y)
			end
		end
		return originalHook(self, key)
	end)
end

RunService.RenderStepped:Connect(function()
	local targetPlayer = getClosestVisibleEnemy()
	
	if aimMode ~= "Выкл" and targetPlayer then
		FOVStroke.Color = Color3.fromRGB(0, 255, 0)
		FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		
		local currentTargetPartName = aimTarget
		if aimMode == "Сайлент Аим" then
			currentTargetPartName = "Head"
		end
		
		local targetPart = targetPlayer.Character:FindFirstChild(currentTargetPartName)
		if targetPart then
			if aimMode == "Обычный Аим" then
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
			elseif aimMode == "Сайлент Аим" then
				if pcall(function() return hookmetamethod end) then
					applySilentAimHook(targetPart)
				else
					Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
				end
			end
		end
	else
		FOVStroke.Color = Color3.fromRGB(255, 0, 0)
		FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	end
	
	if espEnabled then
		local currentEnemies = {}
		
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and (not player.Team or player.Team ~= LocalPlayer.Team) then
				local char = player.Character
				if char then
					local humanoid = char:FindFirstChildOfClass("Humanoid")
					local root = char:FindFirstChild("HumanoidRootPart")
					if humanoid and humanoid.Health > 0 and root then
						local rPos, onScreen = Camera:WorldToViewportPoint(root.Position)
						if onScreen then
							currentEnemies[player.Name] = true
							
							local box, stroke, hpBar, hpFill, distLabel = createESPBoxes(player)
							local head = char:FindFirstChild("Head")
							local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.2, 0)) or Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.5, 0))
							local footPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
							
							local height = math.abs(headPos.Y - footPos.Y)
							local width = height * 0.55
							
							box.Visible = true
							box.Size = UDim2.new(0, width, 0, height)
							box.Position = UDim2.new(0, rPos.X - width / 2, 0, headPos.Y)
							
							if targetPlayer == player then
								stroke.Color = Color3.fromRGB(0, 255, 0)
							else
								if isVisible(root) then
									stroke.Color = Color3.fromRGB(255, 255, 0)
								else
									stroke.Color = Color3.fromRGB(255, 0, 0)
								end
							end
							
							hpBar.Visible = true
							hpBar.Size = UDim2.new(0, 4, 0, height)
							hpBar.Position = UDim2.new(0, rPos.X - width / 2 - 7, 0, headPos.Y)
							
							local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
							hpFill.Size = UDim2.new(1, 0, hpPercent, 0)
							hpFill.Position = UDim2.new(0, 0, 1 - hpPercent, 0)
							hpFill.BackgroundColor3 = Color3.fromHSV(hpPercent * 0.33, 1, 1)
							
							local distance = (Camera.CFrame.Position - root.Position).Magnitude
							distLabel.Visible = true
							distLabel.Text = tostring(math.round(distance)) .. " studs"
							distLabel.Position = UDim2.new(0, rPos.X - 50, 0, footPos.Y + 3)
							distLabel.Size = UDim2.new(0, 100, 0, 15)
						end
					end
				end
			end
		end
		
		for _, child in ipairs(ESPContainer:GetChildren()) do
			local parts = string.split(child.Name, "_")
			local pName = parts[1]
			if pName and not currentEnemies[pName] then
				child.Visible = false
			end
		end
	else
		ESPContainer:ClearAllChildren()
	end
end)
