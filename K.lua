local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local currentRadius = 100
local aimMode = "Обычный"
local colorVisible = Color3.fromRGB(0, 255, 0)
local colorHidden = Color3.fromRGB(255, 0, 0)

local ScreenGui = nil
local StatsPanel = nil
local StatsText = nil
local FovCircle = nil
local MenuButton = nil
local MainMenu = nil

local buttonSavedPosition = nil

local function updateCirclePosition()
	if not FovCircle or not Camera then return end
	
	local viewportSize = Camera.ViewportSize
	local insetTop, insetBottom = GuiService:GetGuiInset()
	
	local centerX = viewportSize.X / 2
	local centerY = (viewportSize.Y + insetTop) / 2
	
	FovCircle.Size = UDim2.new(0, currentRadius * 2, 0, currentRadius * 2)
	FovCircle.Position = UDim2.new(0, centerX - currentRadius, 0, centerY - currentRadius)
end

local function createAndProtectGui()
	if ScreenGui and ScreenGui.Parent == PlayerGui then return end
	
	ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "CorePerfectCenterEspHud"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true 
	ScreenGui.DisplayOrder = 999999
	
	StatsPanel = Instance.new("Frame")
	StatsPanel.Name = "StatsPanel"
	StatsPanel.Size = UDim2.new(0, 360, 0, 45)
	StatsPanel.Position = UDim2.new(0.5, -180, 0, 20)
	StatsPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	StatsPanel.BackgroundTransparency = 0.3
	StatsPanel.BorderSizePixel = 0
	StatsPanel.Parent = ScreenGui

	local StatsCorner = Instance.new("UICorner")
	StatsCorner.CornerRadius = UDim.new(0, 8)
	StatsCorner.Parent = StatsPanel

	StatsText = Instance.new("TextLabel")
	StatsText.Name = "StatsText"
	StatsText.Size = UDim2.new(1, 0, 1, 0)
	StatsText.BackgroundTransparency = 1
	StatsText.Text = "Врагов видно: 0  |  За стеной: 0  |  Всего: 0"
	StatsText.TextColor3 = Color3.fromRGB(255, 255, 255)
	StatsText.TextSize = 14
	StatsText.Font = Enum.Font.SourceSansBold
	StatsText.Parent = StatsPanel

	FovCircle = Instance.new("Frame")
	FovCircle.Name = "FovCircle"
	FovCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	FovCircle.BackgroundTransparency = 0.88
	FovCircle.BorderSizePixel = 0
	FovCircle.Parent = ScreenGui

	local CircleCorner = Instance.new("UICorner")
	CircleCorner.CornerRadius = UDim.new(1, 0)
	CircleCorner.Parent = FovCircle
	
	updateCirclePosition()

	MenuButton = Instance.new("TextButton")
	MenuButton.Name = "ToggleMenuButton"
	MenuButton.Size = UDim2.new(0, 55, 0, 55)
	
	if buttonSavedPosition then
		MenuButton.Position = buttonSavedPosition
	else
		MenuButton.Position = UDim2.new(0.5, -27, 0.5, -27)
	end
	
	MenuButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	MenuButton.Text = "⚙️"
	MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	MenuButton.TextSize = 24
	MenuButton.ZIndex = 10
	MenuButton.Parent = ScreenGui

	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0.3, 0)
	ButtonCorner.Parent = MenuButton

	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	local function updateDrag(input)
		local delta = input.Position - dragStart
		local newPosition = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X, 
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
		MenuButton.Position = newPosition
		buttonSavedPosition = newPosition
	end

	MenuButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = MenuButton.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	MenuButton.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			updateDrag(input)
		end
	end)

	MainMenu = Instance.new("Frame")
	MainMenu.Name = "MainMenu"
	MainMenu.Size = UDim2.new(0, 300, 0, 240)
	MainMenu.Position = UDim2.new(0.5, -150, 0.5, -120)
	MainMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	MainMenu.Visible = false
	MainMenu.ZIndex = 10
	MainMenu.Parent = ScreenGui

	local MenuCorner = Instance.new("UICorner")
	MenuCorner.CornerRadius = UDim.new(0, 12)
	MenuCorner.Parent = MainMenu

	local MenuTitle = Instance.new("TextLabel")
	MenuTitle.Name = "MenuTitle"
	MenuTitle.Size = UDim2.new(1, 0, 0, 40)
	MenuTitle.BackgroundTransparency = 1
	MenuTitle.Text = "Панель Разработчика HUD"
	MenuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	MenuTitle.TextSize = 16
	MenuTitle.Font = Enum.Font.SourceSansBold
	MenuTitle.ZIndex = 11
	MenuTitle.Parent = MainMenu

	local CloseButton = Instance.new("TextButton")
	CloseButton.Name = "CloseButton"
	CloseButton.Size = UDim2.new(0, 30, 0, 30)
	CloseButton.Position = UDim2.new(1, -35, 0, 5)
	CloseButton.BackgroundTransparency = 1
	CloseButton.Text = "❌"
	CloseButton.TextColor3 = Color3.fromRGB(255, 90, 90)
	CloseButton.TextSize = 16
	CloseButton.ZIndex = 11
	CloseButton.Parent = MainMenu

	CloseButton.MouseButton1Click:Connect(function()
		MainMenu.Visible = false
	end)

	MenuButton.MouseButton1Click:Connect(function()
		MainMenu.Visible = not MainMenu.Visible
	end)

	local ModeButton = Instance.new("TextButton")
	ModeButton.Name = "ModeButton"
	ModeButton.Size = UDim2.new(0.9, 0, 0, 40)
	ModeButton.Position = UDim2.new(0.05, 0, 0, 50)
	
	if aimMode == "Сайлент" then
		ModeButton.BackgroundColor3 = Color3.fromRGB(130, 40, 40)
		ModeButton.Text = "Режим: Сайлент Аим (Только Голова)"
	elseif aimMode == "Выкл" then
		ModeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		ModeButton.Text = "Режим Аима: ОТКЛЮЧЕН"
	else
		ModeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		ModeButton.Text = "Режим: Обычный Аим (Голова/Тело)"
	end
	
	ModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	ModeButton.TextSize = 13
	ModeButton.Font = Enum.Font.SourceSansBold
	ModeButton.ZIndex = 11
	ModeButton.Parent = MainMenu
	Instance.new("UICorner", ModeButton).CornerRadius = UDim.new(0, 6)

	ModeButton.MouseButton1Click:Connect(function()
		if aimMode == "Обычный" then
			aimMode = "Сайлент"
			ModeButton.Text = "Режим: Сайлент Аим (Только Голова)"
			ModeButton.BackgroundColor3 = Color3.fromRGB(130, 40, 40)
		elseif aimMode == "Сайлент" then
			aimMode = "Выкл"
			ModeButton.Text = "Режим Аима: ОТКЛЮЧЕН"
			ModeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		else
			aimMode = "Обычный"
			ModeButton.Text = "Режим: Обычный Аим (Голова/Тело)"
			ModeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		end
	end)

	local SliderLabel = Instance.new("TextLabel")
	SliderLabel.Name = "SliderLabel"
	SliderLabel.Size = UDim2.new(1, 0, 0, 20)
	SliderLabel.Position = UDim2.new(0, 0, 0, 110)
	SliderLabel.BackgroundTransparency = 1
	SliderLabel.Text = "Радиус FOV круга: " .. currentRadius .. "px"
	SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	SliderLabel.TextSize = 13
	SliderLabel.ZIndex = 11
	SliderLabel.Parent = MainMenu

	local SliderBar = Instance.new("Frame")
	SliderBar.Name = "SliderBar"
	SliderBar.Size = UDim2.new(0.8, 0, 0, 6)
	SliderBar.Position = UDim2.new(0.1, 0, 0, 140)
	SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	SliderBar.BorderSizePixel = 0
	SliderBar.ZIndex = 11
	SliderBar.Parent = MainMenu
	Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)

	local SliderBtn = Instance.new("TextButton")
	SliderBtn.Name = "SliderBtn"
	SliderBtn.Size = UDim2.new(0, 18, 0, 18)
	local initialRelativeX = (currentRadius - 30) / 220
	SliderBtn.Position = UDim2.new(initialRelativeX, -9, -1, 0)
	SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	SliderBtn.Text = ""
	SliderBtn.ZIndex = 12
	SliderBtn.Parent = SliderBar
	Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)

	local sliderDragging = false

	SliderBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliderDragging = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliderDragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local barAbsPos = SliderBar.AbsolutePosition.X
			local barAbsSize = SliderBar.AbsoluteSize.X
			local touchX = input.Position.X
			
			local relativeX = math.clamp((touchX - barAbsPos) / barAbsSize, 0, 1)
			SliderBtn.Position = UDim2.new(relativeX, -9, -1, 0)
			
			currentRadius = math.floor(30 + (relativeX * 220))
			SliderLabel.Text = "Радиус FOV круга: " .. currentRadius .. "px"
			updateCirclePosition()
		end
	end)

	local FooterLabel = Instance.new("TextLabel")
	FooterLabel.Name = "FooterLabel"
	FooterLabel.Size = UDim2.new(0.9, 0, 0, 50)
	FooterLabel.Position = UDim2.new(0.05, 0, 0, 175)
	FooterLabel.BackgroundTransparency = 1
	FooterLabel.Text = "Перетащите кнопку-шестерёнку из центра экрана в любое удобное место. Тиммейты автоматически фильтруются."
	FooterLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
	FooterLabel.TextSize = 11
	FooterLabel.TextWrapped = true
	FooterLabel.Font = Enum.Font.SourceSansItalic
	FooterLabel.ZIndex = 11
	FooterLabel.Parent = MainMenu

	ScreenGui.Parent = PlayerGui
end

createAndProtectGui()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCirclePosition)

local function getTargetPart(character, targetMode)
	if targetMode == "Сайлент" then
		return character:FindFirstChild("Head")
	else
		return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
	end
end

local function checkWallVisibility(targetCharacter, targetPart)
	if not targetPart or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then
		return false
	end
	
	local rayOrigin = Camera.CFrame.Position
	local rayDirection = (targetPart.Position - rayOrigin)
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
	
	local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	return result == nil
end

local function updatePlayerEsp(player, character, isVisible)
	local head = character:FindFirstChild("Head")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not head or not humanoid then return end
	
	local billboardGui = head:FindFirstChild("BlockStrikeEspGui")
	if not billboardGui then
		billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "BlockStrikeEspGui"
		billboardGui.Size = UDim2.new(0, 140, 0, 45)
		billboardGui.StudsOffset = Vector3.new(0, 3, 0)
		billboardGui.AlwaysOnTop = true
		
		local infoLabel = Instance.new("TextLabel")
		infoLabel.Name = "InfoLabel"
		infoLabel.Size = UDim2.new(1, 0, 0, 20)
		infoLabel.BackgroundTransparency = 1
		infoLabel.Font = Enum.Font.SourceSansBold
		infoLabel.TextSize = 13
		infoLabel.Parent = billboardGui
		
		local hpBackground = Instance.new("Frame")
		hpBackground.Name = "HpBackground"
		hpBackground.Size = UDim2.new(0.8, 0, 0, 4)
		hpBackground.Position = UDim2.new(0.1, 0, 0, 22)
		hpBackground.BackgroundColor3 = Color3.fromRGB(60, 10, 10)
		hpBackground.BorderSizePixel = 0
		hpBackground.Parent = billboardGui
		
		local hpBar = Instance.new("Frame")
		hpBar.Name = "HpBar"
		hpBar.Size = UDim2.new(1, 0, 1, 0)
		hpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		hpBar.BorderSizePixel = 0
		hpBar.Parent = hpBackground
		
		billboardGui.Parent = head
	end
	
	local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local targetHrp = character:FindFirstChild("HumanoidRootPart")
	local distanceStuds = 0
	if myHrp and targetHrp then
		distanceStuds = (targetHrp.Position - myHrp.Position).Magnitude
	end
	
	billboardGui.InfoLabel.Text = string.format("%s [%dм]", player.Name, math.floor(distanceStuds))
	billboardGui.InfoLabel.TextColor3 = isVisible and colorVisible or colorHidden
	
	local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
	billboardGui.HpBackground.HpBar.Size = UDim2.new(healthRatio, 0, 1, 0)
	billboardGui.HpBackground.HpBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0)
	
	local highlight = character:FindFirstChild("EspPlayerHighlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "EspPlayerHighlight"
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 0
		highlight.Parent = character
	end
	highlight.OutlineColor = isVisible and colorVisible or colorHidden
end

local function removePlayerEsp(character)
	if character:FindFirstChild("EspPlayerHighlight") then
		character.EspPlayerHighlight:Destroy()
	end
	
	local head = character:FindFirstChild("Head")
	if head and head:FindFirstChild("BlockStrikeEspGui") then
		head.BlockStrikeEspGui:Destroy()
	end
end

RunService.RenderStepped:Connect(function()
	createAndProtectGui()
	
	local currentViewportSize = Camera.ViewportSize
	local systemInsetTop, _ = GuiService:GetGuiInset()
	local absoluteCenter = Vector2.new(currentViewportSize.X / 2, (currentViewportSize.Y + systemInsetTop) / 2)
	
	local visibleEnemiesCount = 0
	local hiddenEnemiesCount = 0
	local totalEnemiesInGame = 0
	local anyTargetInsideFovCircle = false
	
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= LocalPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local targetCharacter = targetPlayer.Character
			
			if targetPlayer.Team == LocalPlayer.Team and LocalPlayer.Team ~= nil then
				removePlayerEsp(targetCharacter)
			else
				totalEnemiesInGame = totalEnemiesInGame + 1
				local targetAimPart = getTargetPart(targetCharacter, aimMode)
				local isTargetVisible = checkWallVisibility(targetCharacter, targetAimPart)
				
				if isTargetVisible then
					visibleEnemiesCount = visibleEnemiesCount + 1
				else
					hiddenEnemiesCount = hiddenEnemiesCount + 1
				end
				
				updatePlayerEsp(targetPlayer, targetCharacter, isTargetVisible)
				
				if targetAimPart and aimMode ~= "Выкл" then
					local screenPosition, isOnScreen = Camera:WorldToViewportPoint(targetAimPart.Position)
					if isOnScreen then
						local screenPos2D = Vector2.new(screenPosition.X, screenPosition.Y)
						local deltaDistanceFromCenter = (screenPos2D - absoluteCenter).Magnitude
						if deltaDistanceFromCenter <= currentRadius and isTargetVisible then
							anyTargetInsideFovCircle = true
						end
					end
				end
			end
		end
	end
	
	if StatsText then
		StatsText.Text = string.format(
			"Врагов видно: %d | За стеной: %d | Всего: %d",
			visibleEnemiesCount,
			hiddenEnemiesCount,
			totalEnemiesInGame
		)
	end
	
	if FovCircle then
		if anyTargetInsideFovCircle then
			FovCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		else
			FovCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		end
	end
end)
