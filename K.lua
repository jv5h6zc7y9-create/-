--[[
    ЦЕНТРАЛЬНЫЙ ИГРОВОЙ КОНТРОЛЛЕР: СИСТЕМАРАУНДОВ, РОЛЕЙ И ПОДСВЕТКИ ОБЪЕКТОВ
    Разработчик: Шаблон для Roblox Studio
    Описание: Полная серверная система для управления механиками распределения ролей,
    генерации игровых предметов (записок), их подсветки и безопасного перемещения игроков.
--]]

-- =============================================================================
-- БЛОК ПОДКЛЮЧЕНИЯ СИСТЕМНЫХ СЛУЖБ ROBLOX (SERVICES)
-- =============================================================================
local WorkspaceService = game:GetService("Workspace")
local PlayersService = game:GetService("Players")
local ReplicatedStorageService = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- =============================================================================
-- НАСТРОЙКИ И КОНФИГУРАЦИЯ ИГРЫ (CONFIGURATION)
-- =============================================================================
local GAME_SETTINGS = {
	-- Время ожидания перед началом нового раунда (в секундах)
	INTERMISSION_DURATION = 15,
	
	-- Минимальное количество игроков для старта матча
	MINIMUM_PLAYERS_REQUIRED = 2,
	
	-- Длительность одного игрового раунда (в секундах)
	ROUND_DURATION = 180,
	
	-- Координаты для различных игровых зон
	SPAWN_LOCATIONS = {
		LOBBY = Vector3.new(0, 10, 0),
		GAME_ZONE_A = Vector3.new(50, 5, 50),
		GAME_ZONE_B = Vector3.new(-50, 5, -50),
	},
	
	-- Настройки отображения контуров подсветки (Colors)
	HIGHLIGHT_COLORS = {
		KIRA = Color3.fromRGB(255, 0, 0),         -- Красный для Киры
		DETECTIVE_L = Color3.fromRGB(0, 120, 255), -- Синий для Детектива L
		SHINIGAMI = Color3.fromRGB(180, 0, 255)   -- Фиолетовый для Бога Смерти
	}
}

-- =============================================================================
-- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ СОСТОЯНИЯ ИГРЫ (GAME STATE)
-- =============================================================================
local currentRoundActive = false
local timeRemainingInRound = 0
local playerRolesRepository = {} -- Таблица формата [PlayerInstance] = "ИмяРоли"
local activeGameNotesList = {}    -- Список всех созданных в раунде записок

-- =============================================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ И УТИЛИТЫ (UTILITY FUNCTIONS)
-- =============================================================================

--[[
    Функция для безопасного перемещения игрока в пространстве.
    Предотвращает проваливание сквозь текстуры и проверяет целостность персонажа.
--]]
local function safelyTeleportPlayer(playerInstance, targetPosition)
	if not playerInstance or not playerInstance:IsA("Player") then
		warn("Попытка телепортации некорректного объекта игрока.")
		return false
	end

	local characterModel = playerInstance.Character
	if not characterModel then
		warn("Персонаж игрока " .. playerInstance.Name .. " не найден для телепортации.")
		return false
	end

	local humanoidRootPart = characterModel:WaitForChild("HumanoidRootPart", 5)
	local humanoidInstance = characterModel:FindFirstChildOfClass("Humanoid")

	if humanoidRootPart and humanoidInstance and humanoidInstance.Health > 0 then
		-- Смещение по оси Y вверх на 3 единицы для исключения застревания в полу
		local safeVectorPosition = targetPosition + Vector3.new(0, 3, 0)
		humanoidRootPart.CFrame = CFrame.new(safeVectorPosition)
		return true
	else
		warn("Не удалось выполнить телепортацию: персонаж мертв или отсутствует HumanoidRootPart.")
		return false
	end
end

--[[
    Функция очистки всех созданных объектов подсветки (Highlights) с карт
--]]
local function removeAllHighlightsFromObject(targetInstance)
	local existingHighlights = targetInstance:GetChildren()
	for index = 1, #existingHighlights do
		local individualChild = existingHighlights[index]
		if individualChild:IsA("Highlight") then
			individualChild:Destroy()
		end
	end
end

-- =============================================================================
-- СИСТЕМА УПРАВЛЕНИЯ РОЛЯМИ (ROLE MANAGEMENT SYSTEM)
-- =============================================================================

--[[
    Функция сброса всех ролей игроков в исходное состояние
--]]
local function clearAllPlayerRoles()
	local allConnectedPlayers = PlayersService:GetPlayers()
	for index = 1, #allConnectedPlayers do
		local playerInstance = allConnectedPlayers[index]
		playerInstance:SetAttribute("CurrentRole", "Spectator")
		
		-- Удаляем старые контуры подсветки с персонажей, если они были
		if playerInstance.Character then
			removeAllHighlightsFromObject(playerInstance.Character)
		end
	end
	playerRolesRepository = {}
end

--[[
    Функция случайного распределения ключевых ролей среди участников матча
--]]
local function assignGameRolesToPlayers()
	clearAllPlayerRoles()
	
	local availablePlayersList = PlayersService:GetPlayers()
	if #availablePlayersList < GAME_SETTINGS.MINIMUM_PLAYERS_REQUIRED then
		return false
	end

	-- Перемешиваем список игроков с использованием генератора случайных чисел
	local randomGenerator = Random.new()
	for currentPosition = #availablePlayersList, 2, -1 do
		local targetPosition = randomGenerator:NextInteger(1, currentPosition)
		availablePlayersList[currentPosition], availablePlayersList[targetPosition] = availablePlayersList[targetPosition], availablePlayersList[currentPosition]
	end

	-- Назначение роли Киры (Первый игрок в перемешанном списке)
	local kiraPlayerInstance = availablePlayersList[1]
	playerRolesRepository[kiraPlayerInstance] = "Kira"
	kiraPlayerInstance:SetAttribute("CurrentRole", "Kira")

	-- Назначение роли Детектива L (Второй игрок в списке)
	local detectiveLPlayerInstance = availablePlayersList[2]
	playerRolesRepository[detectiveLPlayerInstance] = "L"
	detectiveLPlayerInstance:SetAttribute("CurrentRole", "L")

	-- Если игроков больше двух, третий становится Богом Смерти (Shinigami)
	if #availablePlayersList >= 3 then
		local shinigamiPlayerInstance = availablePlayersList[3]
		playerRolesRepository[shinigamiPlayerInstance] = "Shinigami"
		shinigamiPlayerInstance:SetAttribute("CurrentRole", "Shinigami")
	end

	-- Все оставшиеся игроки получают роль Гражданских/Свидетелей
	for index = 4, #availablePlayersList do
		local citizenPlayerInstance = availablePlayersList[index]
		playerRolesRepository[citizenPlayerInstance] = "Citizen"
		citizenPlayerInstance:SetAttribute("CurrentRole", "Citizen")
	end

	return true
end

-- =============================================================================
-- МЕХАНИКА ИГРОВЫХ ПРЕДМЕТОВ И ПОДСВЕТКИ (ITEMS AND VISUAL ESP)
-- =============================================================================

--[[
    Функция создания физического объекта записки на карте раунда
--]]
local function createImportantNoteInstance(targetPosition, targetRoleOwner)
	local folderContainer = WorkspaceService:FindFirstChild("GameRoundActiveNotes")
	if not folderContainer then
		folderContainer = Instance.new("Folder")
		folderContainer.Name = "GameRoundActiveNotes"
		folderContainer.Parent = WorkspaceService
	end

	-- Создаем сам блок записки/тетради
	local notePart = Instance.new("Part")
	notePart.Name = "ImportantNotebook_" .. targetRoleOwner
	notePart.Size = Vector3.new(2, 0.5, 3)
	notePart.Position = targetPosition
	notePart.Anchored = true
	notePart.CanCollide = true
	notePart.Material = Enum.Material.SmoothPlastic
	
	-- Установка метаданных через атрибуты движка Roblox
	notePart:SetAttribute("AssociatedRole", targetRoleOwner)
	notePart:SetAttribute("IsInteractive", true)

	-- Первичный визуальный цвет объекта на карте
	if targetRoleOwner == "Kira" then
		notePart.Color = Color3.fromRGB(50, 0, 0)
	elseif targetRoleOwner == "L" then
		notePart.Color = Color3.fromRGB(0, 0, 50)
	else
		notePart.Color = Color3.fromRGB(30, 30, 30)
	end

	notePart.Parent = folderContainer
	table.insert(activeGameNotesList, notePart)
	
	return notePart
end

--[[
    Функция применения эффекта Highlight к записке.
    Определяет, кто имеет право видеть обводку сквозь стены.
--]]
local function applyVisualHighlightToNote(noteInstance)
	local noteAssociatedRole = noteInstance:GetAttribute("AssociatedRole")
	if not noteAssociatedRole then return end

	-- Создаем серверный компонент подсветки
	local highlightComponent = Instance.new("Highlight")
	highlightComponent.Name = "ServerRoleVisualHighlight"
	highlightComponent.DepthMode = Enum.HighlightDepthMode.Always
	highlightComponent.FillTransparency = 0.4
	highlightComponent.OutlineTransparency = 0

	-- Выставляем цвета на основе глобальной конфигурации настроек
	if noteAssociatedRole == "Kira" then
		highlightComponent.FillColor = GAME_SETTINGS.HIGHLIGHT_COLORS.KIRA
		highlightComponent.OutlineColor = Color3.fromRGB(255, 255, 255)
	elseif noteAssociatedRole == "L" then
		highlightComponent.FillColor = GAME_SETTINGS.HIGHLIGHT_COLORS.DETECTIVE_L
		highlightComponent.OutlineColor = Color3.fromRGB(200, 200, 200)
	elseif noteAssociatedRole == "Shinigami" then
		highlightComponent.FillColor = GAME_SETTINGS.HIGHLIGHT_COLORS.SHINIGAMI
		highlightComponent.OutlineColor = Color3.fromRGB(0, 0, 0)
	end

	highlightComponent.Parent = noteInstance
end

--[[
    Функция полной очистки игрового поля от созданных записок прошлых раундов
--]]
local function clearActiveGameNotes()
	for index = 1, #activeGameNotesList do
		local noteInstance = activeGameNotesList[index]
		if noteInstance and noteInstance.Parent then
			noteInstance:Destroy()
		end
	end
	activeGameNotesList = {}
	
	local folderContainer = WorkspaceService:FindFirstChild("GameRoundActiveNotes")
	if folderContainer then
		folderContainer:Destroy()
	end
end

-- =============================================================================
-- ОСНОВНОЙ ЖИЗНЕННЫЙ ЦИКЛ ИГРЫ (ROUND LIFECYCLE MANAGEMENT)
-- =============================================================================

--[[
    Инициализация старта активного игрового процесса
--]]
local function startNewGameRound()
	print("Инициализация запуска игрового раунда...")
	
	-- Распределяем роли участников. Если игроков мало, прерываем цикл.
	local roleAssignmentSuccess = assignGameRolesToPlayers()
	if not roleAssignmentSuccess then
		warn("Недостаточно активных игроков на сервере для старта матча!")
		return
	end

	clearActiveGameNotes()
	currentRoundActive = true
	timeRemainingInRound = GAME_SETTINGS.ROUND_DURATION

	-- Создаем тестовые записки для Киры и L в разных зонах игрового пространства
	local kiraNote = createImportantNoteInstance(GAME_SETTINGS.SPAWN_LOCATIONS.GAME_ZONE_A, "Kira")
	local detectiveLNote = createImportantNoteInstance(GAME_SETTINGS.SPAWN_LOCATIONS.GAME_ZONE_B, "L")
	
	-- Применяем подсветку к объектам
	applyVisualHighlightToNote(kiraNote)
	applyVisualHighlightToNote(detectiveLNote)

	-- Телепортируем всех участников раунда на карту
	local allConnectedPlayers = PlayersService:GetPlayers()
	for index = 1, #allConnectedPlayers do
		local playerInstance = allConnectedPlayers[index]
		local assignedRole = playerRolesRepository[playerInstance]
		
		if assignedRole == "Kira" then
			safelyTeleportPlayer(playerInstance, GAME_SETTINGS.SPAWN_LOCATIONS.GAME_ZONE_A)
		elseif assignedRole == "L" then
			safelyTeleportPlayer(playerInstance, GAME_SETTINGS.SPAWN_LOCATIONS.GAME_ZONE_B)
		else
			-- Свидетели появляются посередине зон
			local midPointLocation = (GAME_SETTINGS.SPAWN_LOCATIONS.GAME_ZONE_A + GAME_SETTINGS.SPAWN_LOCATIONS.GAME_ZONE_B) / 2
			safelyTeleportPlayer(playerInstance, midPointLocation)
		end
	end

	print("Раунд успешно запущен. Записки сгенерированы и подсвечены.")
end

--[[
    Завершение раунда, очистка данных и отправка игроков обратно в лобби матча
--]]
local function stopActiveGameRound()
	print("Завершение текущего раунда. Запуск процесса очистки данных.")
	currentRoundActive = false
	
	clearActiveGameNotes()
	clearAllPlayerRoles()

	-- Возвращаем всех выживших игроков в безопасную зону лобби
	local allConnectedPlayers = PlayersService:GetPlayers()
	for index = 1, #allConnectedPlayers do
		local playerInstance = allConnectedPlayers[index]
		safelyTeleportPlayer(playerInstance, GAME_SETTINGS.SPAWN_LOCATIONS.LOBBY)
	end
	
	print("Очистка завершена. Игроки возвращены в начальное лобби.")
end

-- =============================================================================
-- ДИСПЕТЧЕР ИГРОВЫХ ЦИКЛОВ И ОБРАБОТЧИКИ СОБЫТИЙ (LOOPS & EVENTS)
-- =============================================================================

-- Бесконечный цикл управления фазами игры на сервере
task.spawn(function()
	while true do
		task.wait(1)
		
		local currentActivePlayersCount = #PlayersService:GetPlayers()
		
		if not currentRoundActive then
			-- Фаза ожидания игроков (Intermission)
			if currentActivePlayersCount >= GAME_SETTINGS.MINIMUM_PLAYERS_REQUIRED then
				print("Игроки найдены. Перерыв до раунда...")
				for intermissionCounter = GAME_SETTINGS.INTERMISSION_DURATION, 1, -1 do
					task.wait(1)
					if #PlayersService:GetPlayers() < GAME_SETTINGS.MINIMUM_PLAYERS_REQUIRED then
						break
					end
				end
				
				if #PlayersService:GetPlayers() >= GAME_SETTINGS.MINIMUM_PLAYERS_REQUIRED then
					startNewGameRound()
				end
			else
				print("Ожидание игроков. Текущий онлайн на сервере: " .. currentActivePlayersCount)
				task.wait(4)
			end
		else
			-- Фаза активного боя/матча
			timeRemainingInRound = timeRemainingInRound - 1
			if timeRemainingInRound <= 0 or currentActivePlayersCount < GAME_SETTINGS.MINIMUM_PLAYERS_REQUIRED then
				stopActiveGameRound()
			end
		end
	end
end)

-- Обработка автоматических событий при ручном подключении/отключении пользователей
PlayersService.PlayerAdded:Connect(function(playerInstance)
	print("Игрок " .. playerInstance.Name .. " успешно вошел на игровой сервер.")
	playerInstance:SetAttribute("CurrentRole", "Spectator")
	
	playerInstance.CharacterAdded:Connect(function(characterModel)
		-- Если раунд уже идет, новый игрок просто ждет в лобби
		if not currentRoundActive then
			safelyTeleportPlayer(playerInstance, GAME_SETTINGS.SPAWN_LOCATIONS.LOBBY)
		else
			safelyTeleportPlayer(playerInstance, GAME_SETTINGS.SPAWN_LOCATIONS.LOBBY)
		end
	end)
end)

PlayersService.PlayerRemoving:Connect(function(playerInstance)
	print("Игрок " .. playerInstance.Name .. " покинул игровой сервер.")
	if playerRolesRepository[playerInstance] then
		playerRolesRepository[playerInstance] = nil
	end
end)

print("Центральный игровой контроллер раундов успешно запущен на сервере.")
