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

---------------------------------------------------------
--- 1. ГРАФИЧЕСКОЕ МЕНЮ
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatMenu"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = localPlayer:WaitForChild("PlayerGui") end

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
--- 2. УТИЛИТА ПРОВЕРКИ ВРАГА (Team Check)
---------------------------------------------------------
local function isEnemy(player)
	if player == localPlayer then return false end
	-- Если в игре есть команды, проверяем их
	if player.Team and localPlayer.Team then
		if player.Team == localPlayer.Team then
			return false
		end
	end
	return true
end

---------------------------------------------------------
--- 3. 2D РИСОВАНИЕ ЧЕРЕЗ DRAWING / GUI НА КАЖДЫЙ КАДР
---------------------------------------------------------
-- Создаем контейнер для 2D элементов поверх экрана
local espContainer = Instance.new("Folder")
espContainer.Name = "ESP_Container"
espContainer.Parent = screenGui

local drawingsCache = {}

local function removeDrawingESP(character)
	if drawingsCache[character] then
		for _, obj in pairs(drawingsCache[character]) do
			obj:Destroy()
		end
		drawingsCache[character] = nil
	end
end

local function updateESPDrawing()
	-- Очистка старых или удаленных персонажей
	for char, items in pairs(drawingsCache) do
		if not char or not char.Parent or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
			removeDrawingESP(char)
		end
	end

	if not settings.ESPEnabled then
		for _, items in pairs(drawingsCache) do
			for _, obj in pairs(items) do obj.Visible = false end
		end
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if isEnemy(player) and player.Character then
			local char = player.Character
			local root = char:FindFirstChild("HumanoidRootPart")
			local head = char:FindFirstChild("Head")
			local humanoid = char:FindFirstChild("Humanoid")
			
			if root and head and humanoid and humanoid.Health > 0 then
				if not drawingsCache[char] then
					-- Создаем элементы один раз для игрока
					local folder = Instance.new("Folder")
					folder.Parent = espContainer
					
					local box = Instance.new("Frame")
					box.BackgroundTransparency = 1
					box.BorderSizePixel = 1
					box.BorderColor3 = Color3.fromRGB(255, 255, 255)
					box.Parent = folder
					
					local headCircle = Instance.new("Frame")
					headCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
					headCircle.BorderSizePixel = 0
					-- Круглая голова (делаем UICorner)
					local corner = Instance.new("UICorner")
					corner.CornerRadius = UDim.new(1, 0)
					corner.Parent = headCircle
					headCircle.Parent = folder
					
					local hpBg = Instance.new("Frame")
					hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
					hpBg.BorderSizePixel = 0
					hpBg.Parent = folder
					
					local hpFill = Instance.new("Frame")
					hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
					hpFill.BorderSizePixel = 0
					hpFill.Parent = hpBg
					
					-- Кости скелета (линии)
					local function createBone()
						local line = Instance.new("Frame")
						line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						line.BorderSizePixel = 0
						line.Size = UDim2.new(0, 1, 0, 0)
						line.Parent = folder
						return line
					end
					
					drawingsCache[char] = {
						Box = box, Head = headCircle, HpBg = hpBg, HpFill = hpFill,
						Bone1 = createBone(), Bone2 = createBone(), Bone3 = createBone(), Bone4 = createBone()
					}
				end
				
				local ui = drawingsCache[char]
				local cHead, onScreen1 = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
				local cRoot, onScreen2 = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
				
				if onScreen1 or onScreen2 then
					local topPos = Vector2.new(cHead.X, cHead.Y)
					local botPos = Vector2.new(cRoot.X, cRoot.Y)
					local height = math.abs(botPos.Y - topPos.Y)
					local width = height / 2
					
					-- 1. Бокс
					ui.Box.Visible = true
					ui.Box.Size = UDim2.new(0, width, 0, height)
					ui.Box.Position = UDim2.new(0, topPos.X - width/2, 0, topPos.Y)
					
					-- 2. Круглая голова
					local headSize = height / 5
					ui.Head.Visible = true
					ui.Head.Size = UDim2.new(0, headSize, 0, headSize)
					ui.Head.Position = UDim2.new(0, topPos.X - headSize/2, 0, topPos.Y - headSize/2)
					
					-- 3. HP Бар слева от бокса
					ui.HpBg.Visible = true
					ui.HpBg.Size = UDim2.new(0, 4, 0, height)
					ui.HpBg.Position = UDim2.new(0, topPos.X - width/2 - 7, 0, topPos.Y)
					
					local hpRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
					ui.HpFill.Size = UDim2.new(1, 0, hpRatio, 0)
					ui.HpFill.Position = UDim2.new(0, 0, 1 - hpRatio, 0)
					ui.HpFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpRatio), 255 * hpRatio, 0)
					
					-- 4. Скелет (упрощенные линии от головы к центру и конечностям)
					local lArm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftHand")
					local rArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
					local lLeg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftFoot")
					local rLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightFoot")
					
					local function drawLine(boneFrame, pA, pB)
						if pA and pB then
							local sA, visA = camera:WorldToViewportPoint(pA.Position)
							local sB, visB = camera:WorldToViewportPoint(pB.Position)
							if visA or visB then
								local posA = Vector2.new(sA.X, sA.Y)
								local posB = Vector2.new(sB.X, sB.Y)
								local dist = (posA - posB).Magnitude
								local center = (posA + posB) / 2
								local angle = math.atan2(posB.Y - posA.Y, posB.X - posA.X)
								
								boneFrame.Visible = true
								boneFrame.Size = UDim2.new(0, 1, 0, dist)
								boneFrame.Position = UDim2.new(0, center.X, 0, center.Y)
								boneFrame.AnchorPoint = Vector2.new(0.5, 0.5)
								boneFrame.Rotation = math.deg(angle) - 90
								return
							end
						end
						boneFrame.Visible = false
					end
					
					drawLine(ui.Bone1, head, root, ui.Box)
					drawLine(ui.Bone2, head, lArm, ui.Box)
					drawLine(ui.Bone3, head, rArm, ui.Box)
					drawLine(ui.Bone4, root, lLeg, ui.Box)
				else
					ui.Box.Visible = false
					ui.Head.Visible = false
					ui.HpBg.Visible = false
					ui.Bone1.Visible = false
					ui.Bone2.Visible = false
					ui.Bone3.Visible = false
					ui.Bone4.Visible = false
				end
			else
				removeDrawingESP(char)
			end
		end
	end
end

---------------------------------------------------------
--- 4. МОМЕНТАЛЬНЫЙ ТРИГГЕРБОТ
---------------------------------------------------------
local function triggerClick()
	local x, y = camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function runTriggerbot()
	if not settings.TriggerbotEnabled then return end
	
	local screenCenter = camera.ViewportSize / 2
	local unitRay = camera:ScreenPointToRay(screenCenter.X, screenCenter.Y)
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local filterList = {localPlayer.Character}
	if localPlayer.Character then
		for _, p in ipairs(localPlayer.Character:GetDescendants()) do
			if p:IsA("BasePart") then table.insert(filterList, p) end
		end
	end
	raycastParams.FilterDescendantsInstances = filterList
	
	local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 200, raycastParams)
	if result and result.Instance then
		local model = result.Instance:FindFirstAncestorOfClass("Model")
		if model then
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			local targetPlayer = Players:GetPlayerFromCharacter(model)
			
			if humanoid and humanoid.Health > 0 and targetPlayer and isEnemy(targetPlayer) then
				triggerClick()
			end
		end
	end
end

---------------------------------------------------------
--- 5. ГЛАВНЫЙ ЦИКЛ
---------------------------------------------------------
RunService.RenderStepped:Connect(function()
	updateESPDrawing()
	runTriggerbot()
end)
