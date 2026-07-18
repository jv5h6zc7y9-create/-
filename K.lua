--[[
    УНИВЕРСАЛЬНЫЙ ГИБРИДНЫЙ ИГРОВОЙ КОНТРОЛЛЕР (SERVER & CLIENT COMBINED)
    
    Особенности архитектуры:
    - Развернут в одном файле с разделением сред через RunService.
    - Полное отсутствие сокращений в именах переменных и функций.
    - Динамическая генерация сетевой инфраструктуры и пользовательского интерфейса.
--]]

-- =============================================================================
-- БЛОК ГЛОБАЛЬНЫХ СЛУЖБ ДВИЖКА ROBLOX (GLOBAL SERVICES)
-- =============================================================================
local WorkspaceService = game:GetService("Workspace")
local PlayersService = game:GetService("Players")
local ReplicatedStorageService = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGuiService = game:GetService("CoreGui")

-- =============================================================================
-- ЕДИНАЯ ГЛОБАЛЬНАЯ НАСТРОЙКА ИГРЫ (CONFIGURATION CONFIG)
-- =============================================================================
local GLOBAL_GAME_SETTINGS = {
	TELEPORT_HEIGHT_OFFSET = Vector3.new(0, 4, 0),
	DEFAULT_LOBBY_COORDINATES = Vector3.new(0, 10, 0),
	
	VISUAL_THEME = {
		COLOR_KIRA = Color3.fromRGB(255, 30, 30),
		COLOR_DETECTIVE_L = Color3.fromRGB(30, 130, 255),
		COLOR_SHINIGAMI = Color3.fromRGB(150, 30, 220),
		COLOR_SPECTATOR = Color3.fromRGB(120, 120, 125),
		
		BACKGROUND_MAIN_PANEL = Color3.fromRGB(25, 25, 30),
		BACKGROUND_SUB_PANEL = Color3.fromRGB(40, 40, 45),
		TEXT_PRIMARY_COLOR = Color3.fromRGB(245, 245, 245),
		BUTTON_ACTION_COLOR = Color3.fromRGB(0, 160, 220)
	}
}

-- =============================================================================
-- РАЗДЕЛЕНИЕ СРЕДЫ ВЫПОЛНЕНИЯ: СЕРВЕРНАЯ ЧАСТЬ (SERVER EXECUTING CONTEXT)
-- =============================================================================
if RunService:IsServer() then
	print("[СЕРВЕР]: Инициализация серверного модуля управления...")

	-- Автоматическое создание сетевой папки в ReplicatedStorage для связи с клиентами
	local networkFolder = ReplicatedStorageService:FindFirstChild("GameNetworkChannels")
	if not networkFolder then
		networkFolder = Instance.new("Folder")
		networkFolder.Name = "GameNetworkChannels"
		networkFolder.Parent = ReplicatedStorageService
	end

	-- Генерация сетевых событий (RemoteEvents)
	local roleUpdateEvent = networkFolder:FindFirstChild("RoleUpdateEvent") or Instance.new("RemoteEvent", networkFolder)
	roleUpdateEvent.Name = "RoleUpdateEvent"

	local teleportRequestEvent = networkFolder:FindFirstChild("TeleportRequestEvent") or Instance.new("RemoteEvent", networkFolder)
	teleportRequestEvent.Name = "TeleportRequestEvent"

	local eliminationRequestEvent = networkFolder:FindFirstChild("EliminationRequestEvent") or Instance.new("RemoteEvent", networkFolder)
	eliminationRequestEvent.Name = "EliminationRequestEvent"

	-- Функция безопасного перемещения
	local function processSafeTeleportation(playerInstance, targetCoordinates)
		if not playerInstance or not playerInstance.Character then return end
		
		local humanoidRootPart = playerInstance.Character:WaitForChild("HumanoidRootPart", 5)
		local humanoidInstance = playerInstance.Character:FindFirstChildOfClass("Humanoid")
		
		if humanoidRootPart and humanoidInstance and humanoidInstance.Health > 0 then
			local calculatedLocation = targetCoordinates + GLOBAL_GAME_SETTINGS.TELEPORT_HEIGHT_OFFSET
			humanoidRootPart.CFrame = CFrame.new(calculatedLocation)
		end
	end

	-- Слушатель запросов на изменение роли
	roleUpdateEvent.OnServerEvent:Connect(function(senderPlayerInstance, chosenRoleName)
		if not senderPlayerInstance then return end
		
		if chosenRoleName == "Kira" or chosenRoleName == "L" or chosenRoleName == "Shinigami" or chosenRoleName == "Spectator" then
			senderPlayerInstance:SetAttribute("CurrentGameRole", chosenRoleName)
			print(string.format("[СЕРВЕР]: Игрок %s выбрал роль %s", senderPlayerInstance.Name, chosenRoleName))
			
			-- Перерождаем персонажа для сброса и обновления локальных эффектов
			if senderPlayerInstance.Character then
				local humanoid = senderPlayerInstance.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.Health = 0
				end
			end
		end
	end)

	-- Слушатель запросов на мгновенную телепортацию к цели
	teleportRequestEvent.OnServerEvent:Connect(function(senderPlayerInstance, targetPlayerName)
		if not senderPlayerInstance or not senderPlayerInstance.Character then return end
		
		local currentRole = senderPlayerInstance:GetAttribute("CurrentGameRole")
		if currentRole == "Spectator" or currentRole == nil then
			return -- Наблюдатели не могут телепортироваться
		end

		local targetPlayerInstance = PlayersService:FindFirstChild(targetPlayerName)
		if targetPlayerInstance and targetPlayerInstance.Character then
			local targetRoot = targetPlayerInstance.Character:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				processSafeTeleportation(senderPlayerInstance, targetRoot.Position)
			end
		end
	end)

	-- Слушатель запросов на ликвидацию ("Записать имя в тетрадь")
	eliminationRequestEvent.OnServerEvent:Connect(function(senderPlayerInstance, targetPlayerName)
		if not senderPlayerInstance then return end
		
		local currentRole = senderPlayerInstance:GetAttribute("CurrentGameRole")
		if currentRole ~= "Kira" and currentRole ~= "Shinigami" then
			warn(senderPlayerInstance.Name .. " попытался использовать устранение без прав Киры/Бога Смерти.")
			return
		end

		local targetPlayerInstance = PlayersService:FindFirstChild(targetPlayerName)
		if targetPlayerInstance and targetPlayerInstance.Character then
			local targetHumanoid = targetPlayerInstance.Character:FindFirstChildOfClass("Humanoid")
			if targetHumanoid and targetHumanoid.Health > 0 then
				targetHumanoid.Health = 0
				print(string.format("[ЛИКВИДАЦИЯ]: Кира/Бог Смерти (%s) уничтожил цель: %s", senderPlayerInstance.Name, targetPlayerName))
			end
		end
	end)

	-- Первичная обработка подключения игроков на сервере
	PlayersService.PlayerAdded:Connect(function(newPlayer)
		newPlayer:SetAttribute("CurrentGameRole", "Spectator")
		newPlayer.CharacterAdded:Connect(function(character)
			task.wait(1)
			processSafeTeleportation(newPlayer, GLOBAL_GAME_SETTINGS.DEFAULT_LOBBY_COORDINATES)
		end)
	end)

-- =============================================================================
-- РАЗДЕЛЕНИЕ СРЕДЫ ВЫПОЛНЕНИЯ: КЛИЕНТСКАЯ ЧАСТЬ (CLIENT EXECUTING CONTEXT)
-- =============================================================================
elseif RunService:IsClient() then
	print("[КЛИЕНТ]: Инициализация клиентского модуля графики и интерфейса...")

	local localPlayer = PlayersService.LocalPlayer
	
	-- Ссылки на каналы связи (ожидание репликации с сервера)
	local networkFolder = ReplicatedStorageService:WaitForChild("GameNetworkChannels", 15)
	local roleUpdateEvent = networkFolder:WaitForChild("RoleUpdateEvent")
	local teleportRequestEvent = networkFolder:WaitForChild("TeleportRequestEvent")
	local eliminationRequestEvent = networkFolder:WaitForChild("EliminationRequestEvent")

	--=============================================================================
	-- ДИНАМИЧЕСКИЙ СБОРКА ИНТЕРФЕЙСА МЕНЮ ИЗ КОДА (GUI ASSEMBLY)
	--=============================================================================
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CombinedUniversalSystemGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

	-- Основная кнопка-триггер вызова меню
	local interfaceToggleButton = Instance.new("TextButton")
	interfaceToggleButton.Name = "InterfaceToggleButton"
	interfaceToggleButton.Size = UDim2.new(0, 180, 0, 45)
	interfaceToggleButton.Position = UDim2.new(0, 25, 0, 25)
	interfaceToggleButton.BackgroundColor3 = GLOBAL_GAME_SETTINGS.VISUAL_THEME.BACKGROUND_MAIN_PANEL
	interfaceToggleButton.TextColor3 = GLOBAL_GAME_SETTINGS.VISUAL_THEME.TEXT_PRIMARY_COLOR
	interfaceToggleButton.Font = Enum.Font.GothamBold
	interfaceToggleButton.TextSize = 13
	interfaceToggleButton.Text = "ОТКРЫТЬ МЕНЮ УПРАВЛЕНИЯ"
	interfaceToggleButton.Parent = screenGui

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = interfaceToggleButton

	-- Главный фрейм панели управления
	local centralControlFrame = Instance.new("Frame")
	centralControlFrame.Name = "CentralControlFrame"
	centralControlFrame.Size = UDim2.new(0, 560, 0, 380)
	centralControlFrame.Position = UDim2.new(0.5, -280, 0.5, -190)
	centralControlFrame.BackgroundColor3 = GLOBAL_GAME_SETTINGS.VISUAL_THEME.BACKGROUND_MAIN_PANEL
	centralControlFrame.Visible = false
	centralControlFrame.Active = true
	centralControlFrame.Draggable = true
	centralControlFrame.Parent = screenGui

	local mainFrameCorner = Instance.new("UICorner")
	mainFrameCorner.CornerRadius = UDim.new(0, 10)
	mainFrameCorner.Parent = centralControlFrame

	-- Шапка меню
	local titleTextLabel = Instance.new("TextLabel")
	titleTextLabel.Name = "TitleTextLabel"
	titleTextLabel.Size = UDim2.new(1, 0, 0, 40)
	titleTextLabel.BackgroundColor3 = GLOBAL_GAME_SETTINGS.VISUAL_THEME.BACKGROUND_SUB_PANEL
	titleTextLabel.Text = "   ХАБ УПРАВЛЕНИЯ: РОЛИ, МЕНЮ, ТЕЛЕПОРТАЦИЯ, ESP"
	titleTextLabel.TextColor3 = GLOBAL_GAME_SETTINGS.VISUAL_THEME.TEXT_PRIMARY_COLOR
	titleTextLabel.Font = Enum.Font.GothamBold
	titleTextLabel.TextSize = 14
	titleTextLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleTextLabel.Parent = centralControlFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 10)
	titleCorner.Parent = titleTextLabel

	-- Контейнер выбора роли (Левая сторона)
	local leftRoleContainer = Instance.new("Frame")
	leftRoleContainer.Name = "LeftRoleContainer"
	leftRoleContainer.Size = UDim2.new(0, 210, 1, -60)
	leftRoleContainer.Position = UDim2.new(0, 15, 0, 50)
	leftRoleContainer.BackgroundColor3 = GLOBAL_GAME_SETTINGS.VISUAL_THEME.BACKGROUND_SUB_PANEL
	leftRoleContainer.Parent = centralControlFrame

	local leftCorner = Instance.new("UICorner")
	leftCorner.CornerRadius = UDim.new(0, 8)
	leftCorner.Parent = leftRoleContainer

	local leftLayout = Instance.new("UIListLayout")
	leftLayout.Padding = UDim.new(0, 10)
	leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	leftLayout.Parent = leftRoleContainer

	local leftPadding = Instance.new("UIPadding")
	leftPadding.PaddingTop = UDim.new(0, 15)
	leftPadding.Parent = leftRoleContainer

	-- Контейнер действий над игроками (Правая сторона)
	local rightPlayersContainer = Instance.new("Frame")
	rightPlayersContainer.Name = "RightPlayersContainer"
	rightPlayersContainer.Size = UDim2.new(0, 305, 1, -60)
	rightPlayersContainer.Position = UDim2.new(0, 240, 0, 50)
	rightPlayersContainer.BackgroundColor3 = GLOBAL_GAME_SETTINGS.VISUAL_THEME.BACKGROUND_SUB_PANEL
	rightPlayersContainer.Parent = centralControlFrame

	local rightCorner = Instance.new("UICorner")
	rightCorner.CornerRadius = UDim.new(0, 8)
	rightCorner.Parent = rightPlayersContainer

	local listScrollFrame = Instance.new("ScrollingFrame")
	listScrollFrame.Size = UDim2.new(1, -10, 1, -20)
	listScrollFrame.Position = UDim2.new(0, 5, 0, 10)
	listScrollFrame.BackgroundTransparency = 1
	listScrollFrame.ScrollBarThickness = 6
	listScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	listScrollFrame.Parent = rightPlayersContainer

	local scrollLayout = Instance.new("UIListLayout")
	scrollLayout.Padding = UDim.new(0, 5)
	scrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	scrollLayout.Parent = listScrollFrame

	-- Обработка клика по главной кнопке открытия
	interfaceToggleButton.MouseButton1Click:Connect(function()
		centralControlFrame.Visible = not centralControlFrame.Visible
		if centralControlFrame.Visible then
			interfaceToggleButton.Text = "ЗАКРЫТЬ МЕНЮ УПРАВЛЕНИЯ"
		else
			interfaceToggleButton.Text = "ОТКРЫТЬ МЕНЮ УПРАВЛЕНИЯ"
		end
	end)

	-- ГЕНЕРАЦИЯ КНОПОК РОЛЕЙ
	local function createFunctionalRoleButton(roleKey, uiLabelText, colorTheme)
		local roleButton = Instance.new("TextButton")
		roleButton.Size = UDim2.new(0, 180, 0, 40)
		roleButton.BackgroundColor3 = colorTheme
		roleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		roleButton.Font = Enum.Font.GothamBold
		roleButton.TextSize = 12
		roleButton.Text = uiLabelText
		roleButton.Parent = leftRoleContainer
		
		local rCorner = Instance.new("UICorner")
		rCorner.CornerRadius = UDim.new(0, 6)
		rCorner.Parent = roleButton
		
		roleButton.MouseButton1Click:Connect(function()
			roleUpdateEvent:FireServer(roleKey)
		end)
	end

	createFunctionalRoleButton("Kira", "ВЫБРАТЬ: КИРА", GLOBAL_GAME_SETTINGS.VISUAL_THEME.COLOR_KIRA)
	createFunctionalRoleButton("L", "ВЫБРАТЬ: ДЕТЕКТИВ L", GLOBAL_GAME_SETTINGS.VISUAL_THEME.COLOR_DETECTIVE_L)
	createFunctionalRoleButton("Shinigami", "ВЫБРАТЬ: БОГ СМЕРТИ", GLOBAL_GAME_SETTINGS.VISUAL_THEME.COLOR_SHINIGAMI)
	createFunctionalRoleButton("Spectator", "ОЧИСТИТЬ ВСЕ РОЛИ", GLOBAL_GAME_SETTINGS.VISUAL_THEME.COLOR_SPECTATOR)

	-- ОБНОВЛЕНИЕ СПИСКА ИГРОКОВ В СПИСКЕ ДЕЙСТВИЙ
	local function clearListScrollFrame()
		local children = listScrollFrame:GetChildren()
		for index = 1, #children do
			local child = children[index]
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
	end

	local function rebuildPlayersInterfaceList()
		clearListScrollFrame()
		
		local allActivePlayers = PlayersService:GetPlayers()
		local rowCounter = 0
		
		for index = 1, #allActivePlayers do
			local loopPlayer = allActivePlayers[index]
			
			if loopPlayer ~= localPlayer then
				rowCounter = rowCounter + 1
				
				local playerRowFrame = Instance.new("Frame")
				playerRowFrame.Size = UDim2.new(0, 280, 0, 40)
				playerRowFrame.BackgroundColor3 = GLOBAL_GAME_SETTINGS.VISUAL_THEME.BACKGROUND_MAIN_PANEL
				playerRowFrame.Parent = listScrollFrame
				
				local elementCorner = Instance.new("UICorner")
				elementCorner.CornerRadius = UDim.new(0, 4)
				elementCorner.Parent = playerRowFrame
				
				local nameLabel = Instance.new("TextLabel")
				nameLabel.Size = UDim2.new(0, 110, 1, 0)
				nameLabel.Position = UDim2.new(0, 8, 0, 0)
				nameLabel.BackgroundTransparency = 1
				nameLabel.Text = loopPlayer.Name
				nameLabel.TextColor3 = GLOBAL_GAME_SETTINGS.VISUAL_THEME.TEXT_PRIMARY_COLOR
				nameLabel.Font = Enum.Font.Gotham
				nameLabel.TextSize = 11
				nameLabel.TextXAlignment = Enum.TextXAlignment.Left
				nameLabel.Parent = playerRowFrame
				
				-- ТЕЛЕПОРТ
				local tpButton = Instance.new("TextButton")
				tpButton.Size = UDim2.new(0, 70, 0, 26)
				tpButton.Position = UDim2.new(0, 125, 0.5, -13)
				tpButton.BackgroundColor3 = GLOBAL_GAME_SETTINGS.VISUAL_THEME.BUTTON_ACTION_COLOR
				tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				tpButton.Font = Enum.Font.GothamBold
				tpButton.TextSize = 9
				tpButton.Text = "ТЕЛЕПОРТ"
				tpButton.Parent = playerRowFrame
				
				local tpc = Instance.new("UICorner")
				tpc.CornerRadius = UDim.new(0, 4)
				tpc.Parent = tpButton
				
				tpButton.MouseButton1Click:Connect(function()
					teleportRequestEvent:FireServer(loopPlayer.Name)
				end)
				
				-- ЗАПИСАТЬ ИМЯ (Убить)
				local killButton = Instance.new("TextButton")
				killButton.Size = UDim2.new(0, 70, 0, 26)
				killButton.Position = UDim2.new(0, 202, 0.5, -13)
				killButton.BackgroundColor3 = Color3.fromRGB(150, 25, 25)
				killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				killButton.Font = Enum.Font.GothamBold
				killButton.TextSize = 9
				killButton.Text = "ЗАПИСАТЬ ID"
				killButton.Parent = playerRowFrame
				
				local kbc = Instance.new("UICorner")
				kbc.CornerRadius = UDim.new(0, 4)
				kbc.Parent = killButton
				
				killButton.MouseButton1Click:Connect(function()
					eliminationRequestEvent:FireServer(loopPlayer.Name)
				end)
			end
		end
		
		listScrollFrame.CanvasSize = UDim2.new(0, 0, 0, rowCounter * 45)
	end

	PlayersService.PlayerAdded:Connect(rebuildPlayersInterfaceList)
	PlayersService.PlayerRemoving:Connect(rebuildPlayersInterfaceList)
	rebuildPlayersInterfaceList()

	--=============================================================================
	-- ЦИКЛ РЕНДЕРИНГА ESP-ПОДСВЕТКИ ДЛЯ КИРЫ, L И БОГА СМЕРТИ
	--=============================================================================
	local function clearPlayerHighlightComponents(characterModel)
		local elements = characterModel:GetChildren()
		for index = 1, #elements do
			local currentElement = elements[index]
			if currentElement:IsA("Highlight") and currentElement.Name == "SharedEngineEspHighlight" then
				currentElement:Destroy()
			end
		end
	end

	local function processRealtimeCharacterHighlighting(targetPlayer)
		if targetPlayer == localPlayer then return end -- Себя подсвечивать не нужно

		local character = targetPlayer.Character
		if not character then return end

		local targetRole = targetPlayer:GetAttribute("CurrentGameRole") or "Spectator"

		-- Если игрок без роли/наблюдатель — удаляем подсветку
		if targetRole == "Spectator" then
			clearPlayerHighlightComponents(character)
			return
		end

		-- Ищем или создаем элемент подсветки
		local highlight = character:FindFirstChild("SharedEngineEspHighlight")
		if not highlight then
			clearPlayerHighlightComponents(character)
			highlight = Instance.new("Highlight")
			highlight.Name = "SharedEngineEspHighlight"
			highlight.DepthMode = Enum.HighlightDepthMode.Always
			highlight.FillTransparency = 0.5
			highlight.OutlineTransparency = 0
			highlight.Parent = character
		end

		-- Применение цветовых схем в зависимости от роли игрока
		if targetRole == "Kira" then
			highlight.FillColor = GLOBAL_GAME_SETTINGS.VISUAL_THEME.COLOR_KIRA
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		elseif targetRole == "L" then
			highlight.FillColor = GLOBAL_GAME_SETTINGS.VISUAL_THEME.COLOR_DETECTIVE_L
			highlight.OutlineColor = Color3.fromRGB(200, 240, 255)
		elseif targetRole == "Shinigami" then
			highlight.FillColor = GLOBAL_GAME_SETTINGS.VISUAL_THEME.COLOR_SHINIGAMI
			highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
		else
			highlight:Destroy()
		end
	end

	-- Непрерывное обновление подсветки каждый кадр
	RunService.RenderStepped:Connect(function()
		local internalPlayersList = PlayersService:GetPlayers()
		for index = 1, #internalPlayersList do
			local iteratedPlayer = internalPlayersList[index]
			if iteratedPlayer and iteratedPlayer.Character then
				processRealtimeCharacterHighlighting(iteratedPlayer)
			end
		end
	end)
end
