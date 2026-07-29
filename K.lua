local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Состояние функций
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

local function createButton(name, posY, settingKey)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 35)
	btn.Position = UDim2.new(0, 10, 0, posY)
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

createButton("ESP (Box, HP, Skeleton)", 45, "ESPEnabled")
createButton("Triggerbot", 85, "TriggerbotEnabled")

---------------------------------------------------------
--- 2. ИМИТАЦИЯ КЛИКА ДЛЯ ТРИГГЕРБОТА
---------------------------------------------------------
local VirtualInputManager = game:GetService("VirtualInputManager")

local function triggerClick()
	-- Имитируем нажатие левой кнопки мыши (клик)
	local x, y = camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
	task.wait(0.02)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

---------------------------------------------------------
--- 3. РАСШИРЕННЫЙ ESP (Box, Head, HP Bar слева, Skeleton)
---------------------------------------------------------
local function createEsp(character)
	local rootPart = character:WaitForChild("HumanoidRootPart", 5)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not rootPart or not humanoid then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "EnemyESP"
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(0, 120, 0, 100)
	billboard.StudsOffset = Vector3.new(0, 0, 0)
	billboard.Adornee = rootPart

	-- Общий бокс (рамка вокруг персонажа)
	local box = Instance.new("Frame")
	box.Name = "Box"
	box.Size = UDim2.new(0, 60, 0, 90)
	box.Position = UDim2.new(0.5, -30, 0.5, -45)
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 1
	box.BorderColor3 = Color3.fromRGB(255, 255, 255)
	box.Parent = billboard

	-- Полоска здоровья (слева от бокса)
	local bgBar = Instance.new("Frame")
	bgBar.Name = "HealthBackground"
	bgBar.Size = UDim2.new(0, 4, 1, 0)
	bgBar.Position = UDim2.new(0, -7, 0, 0)
	bgBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	bgBar.BorderSizePixel = 0
	bgBar.Parent = box

	local healthBar = Instance.new("Frame")
	healthBar.Name = "HealthBar"
	healthBar.Size = UDim2.new(1, 0, 1, 0)
	healthBar.Position = UDim2.new(0, 0, 1, 0)
	healthBar.AnchorPoint = Vector2.new(0, 1)
	healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	healthBar.BorderSizePixel = 0
	healthBar.Parent = bgBar

	-- Голова (индикатор точки головы внутри ESP)
	local headDot = Instance.new("Frame")
	headDot.Name = "HeadDot"
	headDot.Size = UDim2.new(0, 8, 0, 8)
	headDot.AnchorPoint = Vector2.new(0.5, 0.5)
	headDot.Position = UDim2.new(0.5, 0, 0.15, 0)
	headDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	headDot.BorderSizePixel = 0
	headDot.Parent = box

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
--- 4. ГЛАВНЫЙ ЦИКЛ ОБРАБОТКИ (RENDERSTEPPED)
---------------------------------------------------------
local MAX_DISTANCE = 150

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

-- Переменная для задержки кликов триггербота, чтобы не спамить слишком быстро
local lastTriggerTick = 0

RunService.RenderStepped:Connect(function()
	-- 1. Обновление ESP и Полоски здоровья
	for char, data in pairs(activeEsp) do
		local humanoid = data.Humanoid
		local billboard = data.Billboard
		local healthBar = data.HealthBar
		
		if humanoid and humanoid.Parent and billboard and healthBar then
			billboard.Enabled = settings.ESPEnabled
			if settings.ESPEnabled then
				local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
				healthBar.Size = UDim2.new(1, 0, hpPercent, 0)
				healthBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
			end
		end
	end

	-- 2. Исправленный и улучшенный Триггербот
	if settings.TriggerbotEnabled then
		local screenCenter = camera.ViewportSize / 2
		local unitRay = camera:ScreenPointToRay(screenCenter.X, screenCenter.Y)
		
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		
		local filterList = {localPlayer.Character}
		if localPlayer.Character and localPlayer.Character:FindFirstChild("Head") then
			table.insert(filterList, localPlayer.Character.Head)
		end
		raycastParams.FilterDescendantsInstances = filterList
		
		-- Выпускаем луч с запасом расстояния
		local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * MAX_DISTANCE, raycastParams)
		
		if result and result.Instance then
			if isValidTarget(result.Instance) then
				-- Проверяем задержку (интервал между выстрелами ~0.1 сек), чтобы триггер стабильно срабатывал
				if tick() - lastTriggerTick > 0.1 then
					lastTriggerTick = tick()
					task.spawn(triggerClick)
				end
			end
		end
	end
end)
