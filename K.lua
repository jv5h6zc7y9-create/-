local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

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
--- 2. МГНОВЕННЫЙ КЛИК ТРИГГЕРБОТА
---------------------------------------------------------
local function triggerClick()
	local x, y = camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

---------------------------------------------------------
--- 3. ESP С БОКСОМ, ХП СЛЕВА, ГОЛОВОЙ И ЛИНИЯМИ СКЕЛЕТА
---------------------------------------------------------
local function createEsp(character)
	local rootPart = character:WaitForChild("HumanoidRootPart", 5)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not rootPart or not humanoid then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "EnemyESP"
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(0, 200, 0, 200)
	billboard.StudsOffset = Vector3.new(0, 0, 0)
	billboard.Adornee = rootPart

	-- Главный холст для элементов
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.Parent = billboard

	-- Бокс (рамка)
	local box = Instance.new("Frame")
	box.Name = "Box"
	box.Size = UDim2.new(0, 70, 0, 110)
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.Position = UDim2.new(0.5, 0, 0.5, 0)
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 1
	box.BorderColor3 = Color3.fromRGB(255, 255, 255)
	box.Parent = container

	-- Полоска здоровья СЛЕВА от бокса
	local bgBar = Instance.new("Frame")
	bgBar.Size = UDim2.new(0, 4, 1, 0)
	bgBar.Position = UDim2.new(0, -7, 0, 0)
	bgBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	bgBar.BorderSizePixel = 0
	bgBar.Parent = box

	local healthBar = Instance.new("Frame")
	healthBar.Size = UDim2.new(1, 0, 1, 0)
	healthBar.Position = UDim2.new(0, 0, 1, 0)
	healthBar.AnchorPoint = Vector2.new(0, 1)
	healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	healthBar.BorderSizePixel = 0
	healthBar.Parent = bgBar

	-- Голова (отметка)
	local headDot = Instance.new("Frame")
	headDot.Size = UDim2.new(0, 6, 0, 6)
	headDot.AnchorPoint = Vector2.new(0.5, 0.5)
	headDot.Position = UDim2.new(0.5, 0, 0.1, 0)
	headDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	headDot.BorderSizePixel = 0
	headDot.Parent = box

	-- Функция для создания палок скелета (соединений между частями тела)
	local function createBoneLine(name)
		local line = Instance.new("Frame")
		line.Name = name
		line.AnchorPoint = Vector2.new(0.5, 0.5)
		line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		line.BorderSizePixel = 0
		line.Size = UDim2.new(0, 2, 0, 10) -- Начальный размер
		line.Parent = container
		return line
	end

	local bones = {
		HeadToChest = createBoneLine("HeadToChest"),
		ChestToLeftArm = createBoneLine("ChestToLeftArm"),
		ChestToRightArm = createBoneLine("ChestToRightArm"),
		ChestToPelvis = createBoneLine("ChestToPelvis"),
		PelvisToLeftLeg = createBoneLine("PelvisToLeftLeg"),
		PelvisToRightLeg = createBoneLine("PelvisToRightLeg"),
	}

	billboard.Parent = character
	activeEsp[character] = { 
		Billboard = billboard, 
		HealthBar = healthBar, 
		Humanoid = humanoid, 
		Character = character,
		Bones = bones
	}
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
--- 4. ВСПОМОГАТЕЛЬНАЯ ФУНКЦИЯ ДЛЯ ОТРИСОВКИ ЛИНИЙ СМЕЖНЫХ ЧАСТЕЙ
---------------------------------------------------------
local function updateBone(lineFrame, part1, part2, rootPart)
	if not part1 or not part2 or not rootPart then 
		lineFrame.Visible = false
		return 
	end
	
	local p1Pos = part1.Position
	local p2Pos = part2.Position
	local rootPos = rootPart.Position
	
	-- Переводим мировые координаты в относительные позиции для BillboardGui
	local c1 = camera:WorldToViewportPoint(p1Pos)
	local c2 = camera:WorldToViewportPoint(p2Pos)
	local r = camera:WorldToViewportPoint(rootPos)
	
	if c1 and c2 and r then
		local screenP1 = Vector2.new(c1.X, c1.Y)
		local screenP2 = Vector2.new(c2.X, c2.Y)
		local centerScreen = Vector2.new(r.X, r.Y)
		
		-- Масштаб палки скелета
		local distance = (screenP1 - screenP2).Magnitude
		local midpoint = (screenP1 + screenP2) / 2
		local angle = math.atan2(screenP2.Y - screenP1.Y, screenP2.X - screenP1.X)
		
		lineFrame.Size = UDim2.new(0, 2, 0, distance)
		-- Позиционируем относительно центра персонажа
		lineFrame.Position = UDim2.new(0, midpoint.X - centerScreen.X + 100, 0, midpoint.Y - centerScreen.Y + 100)
		lineFrame.Rotation = math.deg(angle) + 90
		lineFrame.Visible = true
	else
		lineFrame.Visible = false
	end
end

---------------------------------------------------------
--- 5. ГЛАВНЫЙ ЦИКЛ ОБРАБОТКИ (RENDERSTEPPED)
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

RunService.RenderStepped:Connect(function()
	-- 1. Обновление ESP, ХП и Скелета
	for char, data in pairs(activeEsp) do
		local humanoid = data.Humanoid
		local billboard = data.Billboard
		local healthBar = data.HealthBar
		local bones = data.Bones
		local root = char:FindFirstChild("HumanoidRootPart")
		
		if humanoid and humanoid.Parent and billboard and healthBar and root then
			billboard.Enabled = settings.ESPEnabled
			if settings.ESPEnabled then
				local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
				healthBar.Size = UDim2.new(1, 0, hpPercent, 0)
				healthBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
				
				-- Обновление линий костей скелета (палки между суставами)
				local head = char:FindFirstChild("Head")
				local upperTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
				local lowerTorso = char:FindFirstChild("LowerTorso") or upperTorso
				local leftArm = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
				local rightArm = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
				local leftLeg = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg")
				local rightLeg = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")
				
				if head and upperTorso then updateBone(bones.HeadToChest, head, upperTorso, root) end
				if upperTorso and leftArm then updateBone(bones.ChestToLeftArm, upperTorso, leftArm, root) end
				if upperTorso and rightArm then updateBone(bones.ChestToRightArm, upperTorso, rightArm, root) end
				if upperTorso and lowerTorso then updateBone(bones.ChestToPelvis, upperTorso, lowerTorso, root) end
				if lowerTorso and leftLeg then updateBone(bones.PelvisToLeftLeg, lowerTorso, leftLeg, root) end
				if lowerTorso and rightLeg then updateBone(bones.PelvisToRightLeg, lowerTorso, rightLeg, root) end
			end
		end
	end

	-- 2. Исправленный Мгновенный Триггербот (без задержек, проверка каждой части цели)
	if settings.TriggerbotEnabled then
		local screenCenter = camera.ViewportSize / 2
		local unitRay = camera:ScreenPointToRay(screenCenter.X, screenCenter.Y)
		
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		
		local filterList = {localPlayer.Character}
		if localPlayer.Character then
			for _, part in ipairs(localPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					table.insert(filterList, part)
				end
			end
		end
		raycastParams.FilterDescendantsInstances = filterList
		
		local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * MAX_DISTANCE, raycastParams)
		
		if result and result.Instance then
			if isValidTarget(result.Instance) then
				-- Кликает немедленно при наведении на любую часть тела или хитбокс противника
				task.spawn(triggerClick)
			end
		end
	end
end)
