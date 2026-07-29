local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Состояние функций (включено/выключено)
local settings = {
	ESPEnabled = true,
	TriggerbotEnabled = true
}

local activeEsp = {}

---------------------------------------------------------
--- 1. СОЗДАНИЕ ГРАФИЧЕСКОГО МЕНЮ (GUI)
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatMenu"
screenGui.ResetOnSpawn = false
pcall(function()
	screenGui.Parent = CoreGui
end)
if not screenGui.Parent then
	screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
title.Text = "Control Menu"
title.Parent = frame

-- Функция создания чекбоксов в меню
local function createButton(name, posY, settingKey)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 35)
	btn.Position = UDim2.new(0, 10, 0, posY)
	-- По умолчанию кнопки включены, задаем зелёный цвет
	btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 14
	btn.Font = Enum.Font.SourceSans
	btn.Text = name .. ": ON"
	btn.Parent = frame
	
	btn.MouseButton1Click:Connect(function()
		settings[settingKey] = not settings[settingKey]
		if settings[settingKey] then
			btn.Text = name .. ": ON"
			btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		else
			btn.Text = name .. ": OFF"
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		end
	end)
end

createButton("ESP (HP Bar)", 45, "ESPEnabled")
createButton("Triggerbot", 85, "TriggerbotEnabled")

---------------------------------------------------------
--- 2. ЛОГИКА ESP И ПОЛОСКИ ЗДОРОВЬЯ
---------------------------------------------------------
local function createEsp(character)
	local rootPart = character:WaitForChild("HumanoidRootPart", 5)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not rootPart or not humanoid then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "EnemyESP"
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(0, 100, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.Adornee = rootPart

	local bgBar = Instance.new("Frame")
	bgBar.Size = UDim2.new(1, 0, 0, 6)
	bgBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	bgBar.BorderSizePixel = 0
	bgBar.Parent = billboard

	local healthBar = Instance.new("Frame")
	healthBar.Size = UDim2.new(1, 0, 1, 0)
	healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	healthBar.BorderSizePixel = 0
	healthBar.Parent = bgBar

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 0, 0, 8)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.TextSize = 13
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.Text = character.Name
	nameLabel.Parent = billboard

	billboard.Parent = character
	activeEsp[character] = { Billboard = billboard, HealthBar = healthBar, Humanoid = humanoid }
end

local function removeEsp(character)
	if activeEsp[character] then
		if activeEsp[character].Billboard then
			activeEsp[character].Billboard:Destroy()
		end
		activeEsp[character] = nil
	end
end

local function setupPlayer(player)
	if player == localPlayer then return end
	player.CharacterAdded:Connect(createEsp)
	player.CharacterRemoving:Connect(removeEsp)
	if player.Character then
		task.spawn(function() createEsp(player.Character) end)
	end
end

for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)

---------------------------------------------------------
--- 3. ГЛАВНЫЙ ЦИКЛ ОБРАБОТКИ (RENDERSTEPPED)
---------------------------------------------------------
local MAX_DISTANCE = 100

local function isValidTarget(hitPart)
	local model = hitPart:FindFirstAncestorOfClass("Model")
	if model then
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		local targetPlayer = Players:GetPlayerFromCharacter(model)
		if humanoid and humanoid.Health > 0 and targetPlayer and targetPlayer ~= localPlayer then
			return true
		end
	end
	return false
end

RunService.RenderStepped:Connect(function()
	-- 1. Управление видимостью ESP
	for char, data in pairs(activeEsp) do
		local humanoid = data.Humanoid
		local healthBar = data.HealthBar
		local billboard = data.Billboard
		
		if humanoid and humanoid.Parent and healthBar and billboard then
			billboard.Enabled = settings.ESPEnabled
			if settings.ESPEnabled then
				local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
				healthBar.Size = UDim2.new(hpPercent, 0, 1, 0)
				healthBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
			end
		end
	end

	-- 2. Триггербот
	if settings.TriggerbotEnabled then
		local screenCenter = camera.ViewportSize / 2
		local unitRay = camera:ScreenPointToRay(screenCenter.X, screenCenter.Y)
		
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		if localPlayer.Character then
			raycastParams.FilterDescendantsInstances = {localPlayer.Character}
		end
		
		local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * MAX_DISTANCE, raycastParams)
		if result and result.Instance and isValidTarget(result.Instance) then
			print("Триггер сработал на цели!")
		end
	end
end)
