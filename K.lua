--[[
    УНИВЕРСАЛЬНЫЙ ГИБРИДНЫЙ ИГРОВОЙ ФРЕЙМВОРК (ОДИН СКРИПТ В WORKSPACE)
    
    ТРЕБОВАНИЯ К УСТАНОВКЕ:
    - Разместить данный Script внутри папки Workspace.
    - Изменить свойство RunContext скрипта на: Enum.RunContext.Shared
    
    ФУНКЦИОНАЛ:
    - Полная рентген-подсветка (ESP) сквозь любые препятствия (Кира = Красный, L = Синий, Бог Смерти = Фиолетовый).
    - Передвижная (Draggable) кнопка открытия главного хаба.
    - Главное меню идеально по центру экрана независимо от разрешения устройства.
--]]

-- =============================================================================
-- БЛОК СИСТЕМНЫХ СЛУЖБ ДВИЖКА ROBLOX
-- =============================================================================
local WorkspaceService = game:GetService("Workspace")
local PlayersService = game:GetService("Players")
local ReplicatedStorageService = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- =============================================================================
-- ГЛОБАЛЬНАЯ НАСТРОЙКА ЦВЕТОВ И ПАРАМЕТРОВ СИСТЕМЫ
-- =============================================================================
local SYSTEM_CONFIGURATION = {
	TELEPORTATION_HEIGHT_OFFSET = Vector3.new(0, 4, 0),
	LOBBY_RESPAWN_COORDINATES = Vector3.new(0, 15, 0),
	
	VISUAL_THEME = {
		COLOR_KIRA_TEAM = Color3.fromRGB(255, 35, 35),
		COLOR_DETECTIVE_L_TEAM = Color3.fromRGB(35, 145, 255),
		COLOR_SHINIGAMI_TEAM = Color3.fromRGB(165, 35, 235),
		COLOR_SPECTATOR_TEAM = Color3.fromRGB(130, 130, 135),
		
		BACKGROUND_MAIN_PANEL = Color3.fromRGB(20, 20, 25),
		BACKGROUND_SUB_PANEL = Color3.fromRGB(35, 35, 40),
		TEXT_PRIMARY_COLOR = Color3.fromRGB(250, 250, 250),
		BUTTON_ACTION_COLOR = Color3.fromRGB(0, 150, 220)
	}
}

-- =============================================================================
-- СЕРВЕРНАЯ СРЕДА ВЫПОЛНЕНИЯ (SERVER SIDE CONTEXT)
-- =============================================================================
if RunService:IsServer() then
	print("[СЕРВЕР]: Запуск инициализации сетевой структуры фреймворка...")

	-- Автоматическое создание изолированной папки обмена данными
	local networkFolder = ReplicatedStorageService:FindFirstChild("CoreNetworkCommunicationFolder")
	if not networkFolder then
		networkFolder = Instance.new("Folder")
		networkFolder.Name = "CoreNetworkCommunicationFolder"
		networkFolder.Parent = ReplicatedStorageService
	end

	-- Генерация удаленных событий для связи между компонентами матча
	local remoteEventRoleChange = networkFolder:FindFirstChild("RemoteEventRoleChange") or Instance.new("RemoteEvent", networkFolder)
	remoteEventRoleChange.Name = "RemoteEventRoleChange"

	local remoteEventTeleport = networkFolder:FindFirstChild("RemoteEventTeleport") or Instance.new("RemoteEvent", networkFolder)
	remoteEventTeleport.Name = "RemoteEventTeleport"

	local remoteEventEliminate = networkFolder:FindFirstChild("RemoteEventEliminate") or Instance.new("RemoteEvent", networkFolder)
	remoteEventEliminate.Name = "RemoteEventEliminate"

	-- Функция безопасной смены позиции игрока
	local function executeServerCharacterTeleport(playerInstance, targetVectorPosition)
		if not playerInstance or not playerInstance.Character then return end
		
		local humanoidRootPart = playerInstance.Character:WaitForChild("HumanoidRootPart", 6)
		local humanoidInstance = playerInstance.Character:FindFirstChildOfClass("Humanoid")
		
		if humanoidRootPart and humanoidInstance and humanoidInstance.Health > 0 then
			local finalSafePosition = targetVectorPosition + SYSTEM_CONFIGURATION.TELEPORTATION_HEIGHT_OFFSET
			humanoidRootPart.CFrame = CFrame.new(finalSafePosition)
		end
	end

	-- Обработка запросов игроков на выбор роли Киры, L или Бога Смерти
	remoteEventRoleChange.OnServerEvent:Connect(function(clientPlayerInstance, requestedRoleIdentifier)
		if not clientPlayerInstance then return end
		
		if requestedRoleIdentifier == "Kira" or requestedRoleIdentifier == "L" or requestedRoleIdentifier == "Shinigami" or requestedRoleIdentifier == "Spectator" then
			clientPlayerInstance:SetAttribute("CurrentGameRole", requestedRoleIdentifier)
			print(string.format("[СЕРВЕР]: Игрок %s переключился на роль %s", clientPlayerInstance.Name, requestedRoleIdentifier))
			
			-- Перерождаем персонажа, чтобы мгновенно применились новые правила
			if clientPlayerInstance.Character then
				local humanoid = clientPlayerInstance.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.Health = 0
				end
			end
		end
	end)

	-- Обработка запросов на телепортацию к выбранному ID человека
	remoteEventTeleport.OnServerEvent:Connect(function(clientPlayerInstance, targetedPlayerName)
		if not clientPlayerInstance or not clientPlayerInstance.Character then return end
		
		local playerCurrentRole = clientPlayerInstance:GetAttribute("CurrentGameRole")
		if playerCurrentRole == "Spectator" or playerCurrentRole == nil then
			return -- Обычные наблюдатели без ролей не могут перемещаться
		end

		local targetPlayerObject = PlayersService:FindFirstChild(targetedPlayerName)
		if targetPlayerObject and targetPlayerObject.Character then
			local targetRootPart = targetPlayerObject.Character:FindFirstChild("HumanoidRootPart")
			if targetRootPart then
				executeServerCharacterTeleport(clientPlayerInstance, targetRootPart.Position)
			end
		end
	end)

	-- Обработка серверных запросов на уничтожение (Запись в тетрадь)
	remoteEventEliminate.OnServerEvent:Connect(function(clientPlayerInstance, targetedPlayerName)
		if not clientPlayerInstance then return end
		
		local playerCurrentRole = clientPlayerInstance:GetAttribute("CurrentGameRole")
		if playerCurrentRole ~= "Kira" and playerCurrentRole ~= "Shinigami" then
			warn(clientPlayerInstance.Name .. " попытался устранить цель без наличия прав Киры или Бога Смерти.")
			return
		end

		local targetPlayerObject = PlayersService:FindFirstChild(targetedPlayerName)
		if targetPlayerObject and targetPlayerObject.Character then
			local targetHumanoid = targetPlayerObject.Character:FindFirstChildOfClass("Humanoid")
			if targetHumanoid and targetHumanoid.Health > 0 then
				targetHumanoid.Health = 0
				print(string.format("[ЛИКВИДАЦИЯ]: Игрок %s применил силы на уничтожение игрока %s", clientPlayerInstance.Name, targetedPlayerName))
			end
		end
	end)

	-- Настройка параметров при заходе новых участников в игру
	PlayersService.PlayerAdded:Connect(function(connectedPlayer)
		connectedPlayer:SetAttribute("CurrentGameRole", "Spectator")
		connectedPlayer.CharacterAdded:Connect(function(newCharacter)
			task.wait(1.5)
			executeServerCharacterTeleport(connectedPlayer, SYSTEM_CONFIGURATION.LOBBY_RESPAWN_COORDINATES)
		end)
	end)

-- =============================================================================
-- КЛИЕНТСКАЯ СРЕДА ВЫПОЛНЕНИЯ (CLIENT SIDE CONTEXT)
-- =============================================================================
elseif RunService:IsClient() then
	print("[КЛИЕНТ]: Запуск сборки интерфейсов, систем перетаскивания кнопок и ESP-модулей...")

	local localPlayerInstance = PlayersService.LocalPlayer
	
	-- Подключение к созданным сервером каналам связи
	local networkFolder = ReplicatedStorageService:WaitForChild("CoreNetworkCommunicationFolder", 15)
	local remoteEventRoleChange = networkFolder:WaitForChild("RemoteEventRoleChange")
	local remoteEventTeleport = networkFolder:WaitForChild("RemoteEventTeleport")
	local remoteEventEliminate = networkFolder:WaitForChild("RemoteEventEliminate")

	--=============================================================================
	-- СОЗДАНИЕ ГРАФИЧЕСКОГО ИНТЕРФЕЙСА ХАБА И ДВИГАЮЩЕЙСЯ КНОПКИ
	--=============================================================================
	local mainScreenGui = Instance.new("ScreenGui")
	mainScreenGui.Name = "DynamicUniversalSystemGuiHub"
	mainScreenGui.ResetOnSpawn = false
	mainScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	mainScreenGui.Parent = localPlayerInstance:WaitForChild("PlayerGui")

	-- ПЕРЕДВИЖНАЯ КНОПКА ОТКРЫТИЯ МЕНЮ
	local movableToggleButton = Instance.new("TextButton")
	movableToggleButton.Name = "MovableToggleButton"
	movableToggleButton.Size = UDim2.new(0, 190, 0, 45)
	movableToggleButton.Position = UDim2.new(0, 30, 0, 100) -- Начальная позиция
	movableToggleButton.BackgroundColor3 = SYSTEM_CONFIGURATION.VISUAL_THEME.BACKGROUND_MAIN_PANEL
	movableToggleButton.TextColor3 = SYSTEM_CONFIGURATION.VISUAL_THEME.TEXT_PRIMARY_COLOR
	movableToggleButton.Font = Enum.Font.GothamBold
	movableToggleButton.TextSize = 12
	movableToggleButton.Text = "ЗАЖМИ И ТАЩИ: МЕНЮ"
	movableToggleButton.Active = true
	movableToggleButton.Parent = mainScreenGui

	local toggleButtonCorner = Instance.new("UICorner")
	toggleButtonCorner.CornerRadius = UDim.new(0, 8)
	toggleButtonCorner.Parent = movableToggleButton
	
	local toggleButtonStroke = Instance.new("UIStroke")
	toggleButtonStroke.Color = Color3.fromRGB(100, 100, 110)
	toggleButtonStroke.Thickness = 1.5
	toggleButtonStroke.Parent = movableToggleButton

	-- ЦЕНТРАЛЬНОЕ ОКНО УПРАВЛЕНИЯ (ИДЕАЛЬНО ПО ЦЕНТРУ ЭКРАНА)
	local centeredControlFrame = Instance.new("Frame")
	centeredControlFrame.Name = "CenteredControlFrame"
	centeredControlFrame.Size = UDim2.new(0, 580, 0, 400)
	
	-- Центрирование с использованием AnchorPoint
	centeredControlFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	centeredControlFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	
	centeredControlFrame.BackgroundColor3 = SYSTEM_CONFIGURATION.VISUAL_THEME.BACKGROUND_MAIN_PANEL
	centeredControlFrame.Visible = false
	centeredControlFrame.Active = true
	centeredControlFrame.Parent = mainScreenGui

	local mainFrameCorner = Instance.new("UICorner")
	mainFrameCorner.CornerRadius = UDim.new(0, 12)
	mainFrameCorner.Parent = centeredControlFrame

	-- Заголовок хаба
	local headerTextLabel = Instance.new("TextLabel")
	headerTextLabel.Name = "HeaderTextLabel"
	headerTextLabel.Size = UDim2.new(1, 0, 0, 45)
	headerTextLabel.BackgroundColor3 = SYSTEM_CONFIGURATION.VISUAL_THEME.BACKGROUND_SUB_PANEL
	headerTextLabel.Text = "    ХАБ УПРАВЛЕНИЯ: ТЕТРАДЬ СМЕРТИ (КИРА / L / ШИНИГАМИ)"
	headerTextLabel.TextColor3 = SYSTEM_CONFIGURATION.VISUAL_THEME.TEXT_PRIMARY_COLOR
	headerTextLabel.Font = Enum.Font.GothamBold
	headerTextLabel.TextSize = 13
	headerTextLabel.TextXAlignment = Enum.TextXAlignment.Left
	headerTextLabel.Parent = centeredControlFrame

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = headerTextLabel

	-- Контейнер выбора роли (Левая сторона панели)
	local roleSelectionContainer = Instance.new("Frame")
	roleSelectionContainer.Name = "RoleSelectionContainer"
	roleSelectionContainer.Size = UDim2.new(0, 220, 1, -65)
	roleSelectionContainer.Position = UDim2.new(0, 15, 0, 55)
	roleSelectionContainer.BackgroundColor3 = SYSTEM_CONFIGURATION.VISUAL_THEME.BACKGROUND_SUB_PANEL
	roleSelectionContainer.Parent = centeredControlFrame

	local rolePanelCorner = Instance.new("UICorner")
	rolePanelCorner.CornerRadius = UDim.new(0, 8)
	rolePanelCorner.Parent = roleSelectionContainer

	local roleListLayout = Instance.new("UIListLayout")
	roleListLayout.Padding = UDim.new(0, 12)
	roleListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	roleListLayout.Parent = roleSelectionContainer

	local rolePadding = Instance.new("UIPadding")
	rolePadding.PaddingTop = UDim.new(0, 15)
	rolePadding.Parent = roleSelectionContainer

	-- Контейнер списка игроков и ID (Правая сторона панели)
	local playersListContainer = Instance.new("Frame")
	playersListContainer.Name = "PlayersListContainer"
	playersListContainer.Size = UDim2.new(0, 315, 1, -65)
	playersListContainer.Position = UDim2.new(0, 250, 0, 55)
	playersListContainer.BackgroundColor3 = SYSTEM_CONFIGURATION.VISUAL_THEME.BACKGROUND_SUB_PANEL
	playersListContainer.Parent = centeredControlFrame

	local playersPanelCorner = Instance.new("UICorner")
	playersPanelCorner.CornerRadius = UDim.new(0, 8)
	playersPanelCorner.Parent = playersListContainer

	local mainScrollingFrame = Instance.new("ScrollingFrame")
	mainScrollingFrame.Size = UDim2.new(1, -10, 1, -20)
	mainScrollingFrame.Position = UDim2.new(0, 5, 0, 10)
	mainScrollingFrame.BackgroundTransparency = 1
	mainScrollingFrame.ScrollBarThickness = 6
	mainScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	mainScrollingFrame.Parent = playersListContainer

	local scrollListLayout = Instance.new("UIListLayout")
	scrollListLayout.Padding = UDim.new(0, 6)
	scrollListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	scrollListLayout.Parent = mainScrollingFrame

	--=============================================================================
	-- СИСТЕМА ДВИЖЕНИЯ (DRAG) ДЛЯ КНОПКИ ОТКРЫТИЯ МЕНЮ
	-- =============================================================================
	local isDragging = false
	local dragInputReference = nil
	local dragStartPosition = nil
	local elementStartPosition = nil

	movableToggleButton.InputBegan:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			dragStartPosition = inputObject.Position
			elementStartPosition = movableToggleButton.Position
			
			inputObject.Changed:Connect(function()
				if inputObject.UserInputState == Enum.UserInputState.End then
					isDragging = false
				end
			end)
		end
	end)

	movableToggleButton.InputChanged:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Touch then
			dragInputReference = inputObject
		end
	end)

	UserInputService.InputChanged:Connect(function(inputObject)
		if inputObject == dragInputReference and isDragging then
			local mouseDeltaPosition = inputObject.Position - dragStartPosition
			movableToggleButton.Position = UDim2.new(
				elementStartPosition.X.Scale, 
				elementStartPosition.X.Offset + mouseDeltaPosition.X, 
				elementStartPosition.Y.Scale, 
				elementStartPosition.Y.Offset + mouseDeltaPosition.Y
			)
		end
	end)

	-- Логика простого клика по кнопке (открытие / закрытие хаба)
	movableToggleButton.MouseButton1Click:Connect(function()
		if not isDragging then
			centeredControlFrame.Visible = not centeredControlFrame.Visible
		end
	end)

	--=============================================================================
	-- ИНИЦИАЛИЗАЦИЯ ФУНКЦИОНАЛЬНЫХ КНОПОК РОЛЕЙ
	--=============================================================================
	local function buildRoleTriggerButton(roleStringKey, buttonDisplayLabel, colorTemplate)
		local createdRoleButton = Instance.new("TextButton")
		createdRoleButton.Size = UDim2.new(0, 190, 0, 42)
		createdRoleButton.BackgroundColor3 = colorTemplate
		createdRoleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		createdRoleButton.Font = Enum.Font.GothamBold
		createdRoleButton.TextSize = 11
		createdRoleButton.Text = buttonDisplayLabel
		createdRoleButton.Parent = roleSelectionContainer
		
		local buttonCornerInstance = Instance.new("UICorner")
		buttonCornerInstance.CornerRadius = UDim.new(0, 6)
		buttonCornerInstance.Parent = createdRoleButton
		
		createdRoleButton.MouseButton1Click:Connect(function()
			remoteEventRoleChange:FireServer(roleStringKey)
		end)
	end

	buildRoleTriggerButton("Kira", "СТАТЬ: КИРА (KIRA)", SYSTEM_CONFIGURATION.VISUAL_THEME.COLOR_KIRA_TEAM)
	buildRoleTriggerButton("L", "СТАТЬ: ДЕТЕКТИВ L", SYSTEM_CONFIGURATION.VISUAL_THEME.COLOR_DETECTIVE_L_TEAM)
	buildRoleTriggerButton("Shinigami", "СТАТЬ: БОГ СМЕРТИ", SYSTEM_CONFIGURATION.VISUAL_THEME.COLOR_SHINIGAMI_TEAM)
	buildRoleTriggerButton("Spectator", "БЕЗ РОЛИ (СБРОСИТЬ)", SYSTEM_CONFIGURATION.VISUAL_THEME.COLOR_SPECTATOR_TEAM)

	--=============================================================================
	-- ДИНАМИЧЕСКИЙ ВЫВОД ИГРОКОВ В МЕНЮ ДЛЯ ТЕЛЕПОРТАЦИИ И КИЛЛА
	--=============================================================================
	local function clearScrollingInterfaceContainer()
		local allChildren = mainScrollingFrame:GetChildren()
		for index = 1, #allChildren do
			local childObject = allChildren[index]
			if childObject:IsA("Frame") then
				childObject:Destroy()
			end
		end
	end

	local function refreshTargetPlayerListUi()
		clearScrollingInterfaceContainer()
		
		local activePlayersInGame = PlayersService:GetPlayers()
		local activeRowsRendered = 0
		
		for index = 1, #activePlayersInGame do
			local targetedPlayer = activePlayersInGame[index]
			
			-- Исключаем локального игрока из списка целей для действий
			if targetedPlayer ~= localPlayerInstance then
				activeRowsRendered = activeRowsRendered + 1
				
				local listElementFrame = Instance.new("Frame")
				listElementFrame.Size = UDim2.new(0, 290, 0, 42)
				listElementFrame.BackgroundColor3 = SYSTEM_CONFIGURATION.VISUAL_THEME.BACKGROUND_MAIN_PANEL
				listElementFrame.Parent = mainScrollingFrame
				
				local frameCornerInstance = Instance.new("UICorner")
				frameCornerInstance.CornerRadius = UDim.new(0, 5)
				frameCornerInstance.Parent = listElementFrame
				
				local labelPlayerName = Instance.new("TextLabel")
				labelPlayerName.Size = UDim2.new(0, 115, 1, 0)
				labelPlayerName.Position = UDim2.new(0, 10, 0, 0)
				labelPlayerName.BackgroundTransparency = 1
				labelPlayerName.Text = targetedPlayer.Name
				labelPlayerName.TextColor3 = SYSTEM_CONFIGURATION.VISUAL_THEME.TEXT_PRIMARY_COLOR
				labelPlayerName.Font = Enum.Font.Gotham
				labelPlayerName.TextSize = 11
				labelPlayerName.TextXAlignment = Enum.TextXAlignment.Left
				labelPlayerName.Parent = listElementFrame
				
				-- Кнопка совершения автоматической телепортации к игроку
				local actionButtonTeleport = Instance.new("TextButton")
				actionButtonTeleport.Size = UDim2.new(0, 70, 0, 26)
				actionButtonTeleport.Position = UDim2.new(0, 130, 0.5, -13)
				actionButtonTeleport.BackgroundColor3 = SYSTEM_CONFIGURATION.VISUAL_THEME.BUTTON_ACTION_COLOR
				actionButtonTeleport.TextColor3 = Color3.fromRGB(255, 255, 255)
				actionButtonTeleport.Font = Enum.Font.GothamBold
				actionButtonTeleport.TextSize = 9
				actionButtonTeleport.Text = "ТЕЛЕПОРТ"
				actionButtonTeleport.Parent = listElementFrame
				
				local tpCorner = Instance.new("UICorner")
				tpCorner.CornerRadius = UDim.new(0, 4)
				tpCorner.Parent = actionButtonTeleport
				
				actionButtonTeleport.MouseButton1Click:Connect(function()
					remoteEventTeleport:FireServer(targetedPlayer.Name)
				end)
				
				-- Кнопка записи ID (Ликвидация)
				local actionButtonKill = Instance.new("TextButton")
				actionButtonKill.Size = UDim2.new(0, 75, 0, 26)
				actionButtonKill.Position = UDim2.new(0, 207, 0.5, -13)
				actionButtonKill.BackgroundColor3 = Color3.fromRGB(165, 20, 20)
				actionButtonKill.TextColor3 = Color3.fromRGB(255, 255, 255)
				actionButtonKill.Font = Enum.Font.GothamBold
				actionButtonKill.TextSize = 9
				actionButtonKill.Text = "ЗАПИСАТЬ ID"
				actionButtonKill.Parent = listElementFrame
				
				local killCorner = Instance.new("UICorner")
				killCorner.CornerRadius = UDim.new(0, 4)
				killCorner.Parent = actionButtonKill
				
				actionButtonKill.MouseButton1Click:Connect(function()
					remoteEventEliminate:FireServer(targetedPlayer.Name)
				end)
			end
		end
		
		mainScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, activeRowsRendered * 48)
	end

	PlayersService.PlayerAdded:Connect(refreshTargetPlayerListUi)
	PlayersService.PlayerRemoving:Connect(refreshTargetPlayerListUi)
	refreshTargetPlayerListUi()

	--=============================================================================
	-- РАБОТАЮЩАЯ ПОДСВЕТКА СКВОЗЬ СТЕНЫ (DYNAMIC CLIENT ESP HIGHLIGHTS)
	--=============================================================================
	local function eraseAllExistingCharacterHighlights(characterModel)
		local insideElements = characterModel:GetChildren()
		for index = 1, #insideElements do
			local element = insideElements[index]
			if element:IsA("Highlight") and element.Name == "ClientEngineRenderEspHighlight" then
				element:Destroy()
			end
		end
	end

	local function handlePlayerHighlightRendering(gamePlayerInstance)
		-- Не применяем подсветку на свой собственный персонаж
		if gamePlayerInstance == localPlayerInstance then return end

		local currentCharacter = gamePlayerInstance.Character
		if not currentCharacter then return end

		-- Чтение установленной роли игрока из атрибутов движка
		local currentTargetRole = gamePlayerInstance:GetAttribute("CurrentGameRole") or "Spectator"

		-- Если игрок не выбрал роль или сбросил её — убираем рентген-контур
		if currentTargetRole == "Spectator" then
			eraseAllExistingCharacterHighlights(currentCharacter)
			return
		end

		-- Ищем существующий контур или создаем новый на стороне клиента
		local targetHighlightInstance = currentCharacter:FindFirstChild("ClientEngineRenderEspHighlight")
		if not targetHighlightInstance then
			eraseAllExistingCharacterHighlights(currentCharacter)
			
			targetHighlightInstance = Instance.new("Highlight")
			targetHighlightInstance.Name = "ClientEngineRenderEspHighlight"
			
			-- Главная настройка видимости сквозь текстуры и стены
			targetHighlightInstance.DepthMode = Enum.HighlightDepthMode.Always
			
			targetHighlightInstance.FillTransparency = 0.45
			targetHighlightInstance.OutlineTransparency = 0
			targetHighlightInstance.Parent = currentCharacter
		end

		-- Изменение цвета подсветки в зависимости от текущей роли сущности
		if currentTargetRole == "Kira" then
			targetHighlightInstance.FillColor = SYSTEM_CONFIGURATION.VISUAL_THEME.COLOR_KIRA_TEAM
			targetHighlightInstance.OutlineColor = Color3.fromRGB(255, 255, 255)
		elseif currentTargetRole == "L" then
			targetHighlightInstance.FillColor = SYSTEM_CONFIGURATION.VISUAL_THEME.COLOR_DETECTIVE_L_TEAM
			targetHighlightInstance.OutlineColor = Color3.fromRGB(255, 255, 255)
		elseif currentTargetRole == "Shinigami" then
			targetHighlightInstance.FillColor = SYSTEM_CONFIGURATION.VISUAL_THEME.COLOR_SHINIGAMI_TEAM
			targetHighlightInstance.OutlineColor = Color3.fromRGB(20, 20, 20)
		else
			targetHighlightInstance:Destroy()
		end
	end

	-- Запуск непрерывного высокопроизводительного рендеринга рентген-подсветки
	RunService.RenderStepped:Connect(function()
		local currentPlayersArray = PlayersService:GetPlayers()
		for index = 1, #currentPlayersArray do
			local loopPlayer = currentPlayersArray[index]
			if loopPlayer and loopPlayer.Character then
				handlePlayerHighlightRendering(loopPlayer)
			end
		end
	end)
end
