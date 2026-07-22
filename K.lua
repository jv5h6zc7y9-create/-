-- Roblox LocalScript - Complete UI, Tracking, and Simulation System
-- Tailored for Mobile/iPad Pro Environment
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Local Configuration State
local config = {
	fovRadius = 150,
	aimMode = "OFF", -- "Normal Aim Simulation", "Silent Aim Simulation", "OFF"
	aimTargetPart = "Head", -- "Head", "HumanoidRootPart"
	currentSkin = "Standard"
}

local skinList = {"Standard", "M9 Bayonet", "Butterfly Knife", "Karambit", "Huntsman Knife"}

-- Root Container Configuration (Ensures persistent regeneration)
local rootGuiName = "iPadPro_Simulation_Suite"
local coreGui = localPlayer:WaitForChild("PlayerGui")

local function getCenterScreen()
	local viewportSize = camera.ViewportSize
	local insetTop, insetBottom = GuiService:GetGuiInset()
	local cleanX = viewportSize.X
	local cleanY = viewportSize.Y - (insetTop + insetBottom)
	return Vector2.new(cleanX / 2, cleanY / 2)
end

local function checkLineOfSight(targetPart, character)
	if not targetPart or not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return false
	end
	
	local origin = camera.CFrame.Position
	local direction = targetPart.Position - origin
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {localPlayer.Character, character}
	raycastParams.IgnoreWater = true
	
	local result = Workspace:Raycast(origin, direction, raycastParams)
	if result then
		return false
	end
	return true
end

local function getClosestPlayerToCenter()
	if config.aimMode == "OFF" then return nil, nil, false end
	
	local center = getCenterScreen()
	local shortestDistance = math.huge
	local closestTarget = nil
	local targetPartInstance = nil
	local isVisible = false
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Team ~= localPlayer.Team then
			local character = player.Character
			if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
				local partName = "Head"
				if config.aimMode == "Normal Aim Simulation" then
					partName = config.aimTargetPart
				end
				
				local part = character:FindFirstChild(partName)
				if part then
					local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
					if onScreen then
						local screenPos2D = Vector2.new(screenPos.X, screenPos.Y)
						local distanceToCenter = (screenPos2D - center).Magnitude
						if distanceToCenter <= config.fovRadius and distanceToCenter < shortestDistance then
							shortestDistance = distanceToCenter
							closestTarget = character
							targetPartInstance = part
						end
					end
				end
			end
		end
	end
	
	if closestTarget and targetPartInstance then
		isVisible = checkLineOfSight(targetPartInstance, closestTarget)
		return closestTarget, targetPartInstance, isVisible
	end
	
	return nil, nil, false
end

-- Safely creates or returns the structured screen layout components
local function buildInterfaceLayout()
	local screenGui = coreGui:FindFirstChild(rootGuiName)
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = rootGuiName
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = false
		screenGui.Parent = coreGui
	end
	
	-- FOV UI Initialization
	local fovCircle = screenGui:FindFirstChild("FOVCircle")
	if not fovCircle then
		fovCircle = Instance.new("Frame")
		fovCircle.Name = "FOVCircle"
		fovCircle.BackgroundTransparency = 1
		fovCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
		fovCircle.BorderSizePixel = 0
		fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
		
		local stroke = Instance.new("UIStroke")
		stroke.Name = "CircleStroke"
		stroke.Thickness = 2
		stroke.Color = Color3.fromRGB(255, 0, 0)
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = fovCircle
		
		local corner = Instance.new("UICorner")
		corner.Name = "CircleCorner"
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = fovCircle
		
		fovCircle.Parent = screenGui
	end
	
	-- Statistics Board Initialization
	local statsPanel = screenGui:FindFirstChild("StatsPanel")
	if not statsPanel then
		statsPanel = Instance.new("Frame")
		statsPanel.Name = "StatsPanel"
		statsPanel.Size = UDim2.new(0, 420, 0, 35)
		statsPanel.Position = UDim2.new(0.5, -210, 0, 10)
		statsPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		statsPanel.BackgroundTransparency = 0.3
		statsPanel.BorderSizePixel = 0
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = statsPanel
		
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "StatText"
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
		textLabel.TextSize = 16
		textLabel.Text = "Enemies Visible: 0 | Behind Walls: 0 | Total: 0"
		textLabel.Parent = statsPanel
		
		statsPanel.Parent = screenGui
	end
	
	-- Master Floating Settings Window Activation Trigger
	local gearButton = screenGui:FindFirstChild("GearButton")
	if not gearButton then
		gearButton = Instance.new("TextButton")
		gearButton.Name = "GearButton"
		gearButton.Size = UDim2.new(0, 50, 0, 50)
		gearButton.Position = UDim2.new(0.5, -25, 0.5, -25)
		gearButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		gearButton.BorderSizePixel = 0
		gearButton.Text = "⚙️"
		gearButton.TextSize = 24
		gearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = gearButton
		
		-- Mobile Interactive Positioning Physics Engine
		local dragging = false
		local dragInput, dragStart, startPos
		
		gearButton.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gearButton.Position
				
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		
		gearButton.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				gearButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
		
		gearButton.Parent = screenGui
	end
	
	-- Configuration System Modular Dashboard Panel Window
	local configMenu = screenGui:FindFirstChild("ConfigMenu")
	if not configMenu then
		configMenu = Instance.new("Frame")
		configMenu.Name = "ConfigMenu"
		configMenu.Size = UDim2.new(0, 320, 0, 380)
		configMenu.Position = UDim2.new(0.5, -160, 0.5, 40)
		configMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		configMenu.BorderSizePixel = 0
		configMenu.Visible = false
		
		local menuCorner = Instance.new("UICorner")
		menuCorner.CornerRadius = UDim.new(0, 10)
		menuCorner.Parent = configMenu
		
		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.Size = UDim2.new(1, 0, 0, 40)
		title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		title.Text = "iPad Pro Tactical Suite"
		title.Font = Enum.Font.SourceSansBold
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		title.TextSize = 18
		
		local titleCorner = Instance.new("UICorner")
		titleCorner.CornerRadius = UDim.new(0, 10)
		titleCorner.Parent = title
		title.Parent = configMenu
		
		-- Toggle System Architecture Component
		local modeBtn = Instance.new("TextButton")
		modeBtn.Name = "ModeBtn"
		modeBtn.Size = UDim2.new(0, 280, 0, 40)
		modeBtn.Position = UDim2.new(0, 20, 0, 60)
		modeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		modeBtn.Font = Enum.Font.SourceSansBold
		modeBtn.TextSize = 14
		modeBtn.Text = "Aim Mode: OFF"
		
		local btnCorner1 = Instance.new("UICorner")
		btnCorner1.CornerRadius = UDim.new(0, 6)
		btnCorner1.Parent = modeBtn
		
		modeBtn.MouseButton1Click:Connect(function()
			if config.aimMode == "OFF" then
				config.aimMode = "Normal Aim Simulation"
			elseif config.aimMode == "Normal Aim Simulation" then
				config.aimMode = "Silent Aim Simulation"
			else
				config.aimMode = "OFF"
			end
			modeBtn.Text = "Aim Mode: " .. config.aimMode
		end)
		modeBtn.Parent = configMenu
		
		-- Target Dynamic Instance Target Switch Button Module
		local targetBtn = Instance.new("TextButton")
		targetBtn.Name = "TargetBtn"
		targetBtn.Size = UDim2.new(0, 280, 0, 40)
		targetBtn.Position = UDim2.new(0, 20, 0, 115)
		targetBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		targetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		targetBtn.Font = Enum.Font.SourceSansBold
		targetBtn.TextSize = 14
		targetBtn.Text = "Target Component: Head"
		
		local btnCorner2 = Instance.new("UICorner")
		btnCorner2.CornerRadius = UDim.new(0, 6)
		btnCorner2.Parent = targetBtn
		
		targetBtn.MouseButton1Click:Connect(function()
			if config.aimTargetPart == "Head" then
				config.aimTargetPart = "HumanoidRootPart"
			else
				config.aimTargetPart = "Head"
			end
			targetBtn.Text = "Target Component: " .. config.aimTargetPart
		end)
		targetBtn.Parent = configMenu
		
		-- Linear Continuous Field of View Size Modification Slider Layout
		local sliderLabel = Instance.new("TextLabel")
		sliderLabel.Name = "SliderLabel"
		sliderLabel.Size = UDim2.new(0, 280, 0, 20)
		sliderLabel.Position = UDim2.new(0, 20, 0, 170)
		sliderLabel.BackgroundTransparency = 1
		sliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		sliderLabel.Font = Enum.Font.SourceSans
		sliderLabel.TextSize = 14
		sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
		sliderLabel.Text = "Field of View Radius: " .. config.fovRadius
		sliderLabel.Parent = configMenu
		
		local sliderTrack = Instance.new("Frame")
		sliderTrack.Name = "SliderTrack"
		sliderTrack.Size = UDim2.new(0, 280, 0, 10)
		sliderTrack.Position = UDim2.new(0, 20, 0, 195)
		sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		
		local trackCorner = Instance.new("UICorner")
		trackCorner.CornerRadius = UDim.new(0, 4)
		trackCorner.Parent = sliderTrack
		
		local sliderHandle = Instance.new("TextButton")
		sliderHandle.Name = "SliderHandle"
		sliderHandle.Size = UDim2.new(0, 20, 0, 20)
		sliderHandle.Position = UDim2.new(0, (config.fovRadius / 400) * 260, -0.5, 0)
		sliderHandle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
		sliderHandle.Text = ""
		
		local handleCorner = Instance.new("UICorner")
		handleCorner.CornerRadius = UDim.new(1, 0)
		handleCorner.Parent = sliderHandle
		
		local sliderActive = false
		
		sliderHandle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliderActive = true
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if sliderActive and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local locationX = input.Position.X
				local trackOriginX = sliderTrack.AbsolutePosition.X
				local trackWidth = sliderTrack.AbsoluteSize.X
				local scaleFactor = math.clamp((locationX - trackOriginX) / trackWidth, 0, 1)
				config.fovRadius = math.floor(50 + (scaleFactor * 350))
				sliderHandle.Position = UDim2.new(0, scaleFactor * (trackWidth - 20), -0.5, 0)
				sliderLabel.Text = "Field of View Radius: " .. config.fovRadius
			end
		end)
		
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliderActive = false
			end
		end)
		
		sliderHandle.Parent = sliderTrack
		sliderTrack.Parent = configMenu
		
		-- Visual Core Model System Layer Divider Separation Line
		local separator = Instance.new("Frame")
		separator.Name = "Separator"
		separator.Size = UDim2.new(0, 280, 0, 2)
		separator.Position = UDim2.new(0, 20, 0, 230)
		separator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		separator.BorderSizePixel = 0
		separator.Parent = configMenu
		
		local subTitle = Instance.new("TextLabel")
		subTitle.Name = "SubTitle"
		subTitle.Size = UDim2.new(0, 280, 0, 25)
		subTitle.Position = UDim2.new(0, 20, 0, 245)
		subTitle.BackgroundTransparency = 1
		subTitle.Text = "Weapon Model Customization"
		subTitle.Font = Enum.Font.SourceSansBold
		subTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
		subTitle.TextSize = 15
		subTitle.TextXAlignment = Enum.TextXAlignment.Left
		subTitle.Parent = configMenu
		
		-- Custom Local Object Simulation Visual Configuration Array Interface
		local skinBtn = Instance.new("TextButton")
		skinBtn.Name = "SkinBtn"
		skinBtn.Size = UDim2.new(0, 280, 0, 40)
		skinBtn.Position = UDim2.new(0, 20, 0, 280)
		skinBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		skinBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
		skinBtn.Font = Enum.Font.SourceSansBold
		skinBtn.TextSize = 14
		skinBtn.Text = "Active Asset Modification: Standard"
		
		local btnCorner3 = Instance.new("UICorner")
		btnCorner3.CornerRadius = UDim.new(0, 6)
		btnCorner3.Parent = skinBtn
		
		skinBtn.MouseButton1Click:Connect(function()
			local currentIdx = table.find(skinList, config.currentSkin) or 1
			local nextIdx = currentIdx + 1
			if nextIdx > #skinList then nextIdx = 1 end
			config.currentSkin = skinList[nextIdx]
			skinBtn.Text = "Active Asset Modification: " .. config.currentSkin
		end)
		skinBtn.Parent = configMenu
		
		configMenu.Parent = screenGui
	end
	
	-- Open / Close Action Engine Link for Gear Switch Controller Button
	local gearButtonElement = screenGui:FindFirstChild("GearButton")
	local configMenuElement = screenGui:FindFirstChild("ConfigMenu")
	if gearButtonElement and configMenuElement then
		gearButtonElement.MouseButton1Click:Connect(function()
			configMenuElement.Visible = not configMenuElement.Visible
		end)
	end
end

-- Core Engine Framework Update Implementation Runtime Event Processing
RunService.RenderStepped:Connect(function()
	-- Persistent UI Element Structure Verification Layer Loop
	buildInterfaceLayout()
	
	local screenGui = coreGui:FindFirstChild(rootGuiName)
	if not screenGui then return end
	
	-- Absolute True Coordinates Dynamic Realignment Vector Processing
	local calculatedCenter = getCenterScreen()
	local fovCircle = screenGui:FindFirstChild("FOVCircle")
	if fovCircle then
		fovCircle.Position = UDim2.new(0, calculatedCenter.X, 0, calculatedCenter.Y)
		fovCircle.Size = UDim2.new(0, config.fovRadius * 2, 0, config.fovRadius * 2)
	end
	
	-- Execution Target System Identification
	local currentTargetCharacter, targetPart, partIsVisible = getClosestPlayerToCenter()
	local stroke = fovCircle and fovCircle:FindFirstChild("CircleStroke")
	if stroke then
		if currentTargetCharacter and partIsVisible and config.aimMode == "Normal Aim Simulation" then
			stroke.Color = Color3.fromRGB(0, 255, 0)
		else
			stroke.Color = Color3.fromRGB(255, 0, 0)
		end
	end
	
	-- Matrix State Statistics Assembly Counters
	local visibleEnemiesCount = 0
	local obscuredEnemiesCount = 0
	local totalEnemiesCount = 0
	
	-- Complete Global 3D Space Environmental Tracking Infrastructure Simulation Engine Loop
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			local character = player.Character
			if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Head") and character:FindFirstChild("Humanoid") then
				local humanoid = character.Humanoid
				if humanoid.Health > 0 and player.Team ~= localPlayer.Team then
					totalEnemiesCount = totalEnemiesCount + 1
					
					-- 3D Workspace Rendering Projection Detection Engine
					local rootPart = character.HumanoidRootPart
					local isTargetVisible = checkLineOfSight(rootPart, character)
					
					if isTargetVisible then
						visibleEnemiesCount = visibleEnemiesCount + 1
					else
						obscuredEnemiesCount = obscuredEnemiesCount + 1
					end
					
					-- Local Part Highlights Framework Processing Node
					local highlight = character:FindFirstChild("TacticalHighlight")
					if not highlight then
						highlight = Instance.new("Highlight")
						highlight.Name = "TacticalHighlight"
						highlight.FillTransparency = 0.6
						highlight.OutlineTransparency = 0
						highlight.Parent = character
					end
					
					if isTargetVisible then
						highlight.FillColor = Color3.fromRGB(0, 255, 0)
						highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
					else
						highlight.FillColor = Color3.fromRGB(255, 0, 0)
						highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
					end
					
					-- High Resolution Overlay System Rendering Modules
					local billboard = character.Head:FindFirstChild("TacticalOverlay")
					if not billboard then
						billboard = Instance.new("BillboardGui")
						billboard.Name = "TacticalOverlay"
						billboard.Size = UDim2.new(0, 140, 0, 45)
						billboard.AlwaysOnTop = true
						billboard.ExtentsOffset = Vector3.new(0, 2.5, 0)
						
						local mainFrame = Instance.new("Frame")
						mainFrame.Name = "MainFrame"
						mainFrame.Size = UDim2.new(1, 0, 1, 0)
						mainFrame.BackgroundTransparency = 1
						mainFrame.Parent = billboard
						
						local label = Instance.new("TextLabel")
						label.Name = "InfoLabel"
						label.Size = UDim2.new(1, 0, 0, 30)
						label.BackgroundTransparency = 1
						label.Font = Enum.Font.SourceSansBold
						label.TextSize = 12
						label.TextColor3 = Color3.fromRGB(255, 255, 255)
						label.TextStrokeTransparency = 0
						label.Parent = mainFrame
						
						local hpBackground = Instance.new("Frame")
						hpBackground.Name = "HPBackground"
						hpBackground.Size = UDim2.new(1, 0, 0, 4)
						hpBackground.Position = UDim2.new(0, 0, 0, 32)
						hpBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
						hpBackground.BorderSizePixel = 0
						
						local hpBar = Instance.new("Frame")
						hpBar.Name = "HPBar"
						hpBar.Size = UDim2.new(1, 0, 1, 0)
						hpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
						hpBar.BorderSizePixel = 0
						hpBar.Parent = hpBackground
						
						hpBackground.Parent = mainFrame
						billboard.Parent = character.Head
					end
					
					-- Metric Translation Calculation Systems
					local distance = (camera.CFrame.Position - rootPart.Position).Magnitude
					local distanceInMeters = math.floor(distance * 0.28)
					
					local mainFrame = billboard:FindFirstChild("MainFrame")
					if mainFrame then
						local infoLabel = mainFrame:FindFirstChild("InfoLabel")
						if infoLabel then
							infoLabel.Text = player.Name .. " [" .. distanceInMeters .. "m]"
						end
						
						local hpBackground = mainFrame:FindFirstChild("HPBackground")
						if hpBackground then
							local hpBar = hpBackground:FindFirstChild("HPBar")
							if hpBar then
								local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
								hpBar.Size = UDim2.new(healthRatio, 0, 1, 0)
								hpBar.BackgroundColor3 = Color3.fromHSV((healthRatio * 120) / 360, 1, 1)
							end
						end
					end
				else
					-- Clean up modules if dead or unexpected team transition
					local oldHighlight = character:FindFirstChild("TacticalHighlight")
					if oldHighlight then oldHighlight:Destroy() end
					
					local oldBillboard = character.Head:FindFirstChild("TacticalOverlay")
					if oldBillboard then oldBillboard:Destroy() end
				end
			end
		end
	end
	
	-- Refresh Statistics Counter Panel Displays
	local statsPanel = screenGui:FindFirstChild("StatsPanel")
	if statsPanel then
		local statText = statsPanel:FindFirstChild("StatText")
		if statText then
			statText.Text = "Enemies Visible: " .. visibleEnemiesCount .. " | Behind Walls: " .. obscuredEnemiesCount .. " | Total: " .. totalEnemiesCount
		end
	end
end)
