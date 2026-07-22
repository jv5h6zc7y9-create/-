local tool = script.Parent

-- ================= НАСТРОЙКИ ДАЛЕКОГО БРОСКА =================
local THROW_FORCE_MULTIPLIER = 3.8 -- Сила броска (чем выше, тем быстрее летит на дистанцию)
local UPWARD_ARC = 30              -- Высота дуги полета (навес вверх)
local SEAT_PATH = workspace:FindFirstChildOfClass("Seat") -- Ищет сиденье на карте
-- =============================================================

-- Создание сетевого события, если его нет
local throwEvent = tool:FindFirstChild("RemoteEvent") or Instance.new("RemoteEvent")
throwEvent.Name = "RemoteEvent"
throwEvent.Parent = tool

-- Функция поиска вещей (деталей) на сиденье, если там нет человека
local function findItemOnSeat(seat)
	if not seat then return nil end
	
	-- Ищем любую неприанкеренную деталь, которая соприкасается с сиденьем
	local touchingParts = seat:GetTouchingParts()
	for _, part in ipairs(touchingParts) do
		if not part.Anchored and not part:IsDescendantOf(game.Players) then
			-- Возвращаем саму деталь или её модель
			if part.Parent:IsA("Model") and part.Parent ~= workspace then
				return part.Parent
			else
				return part
			end
		end
	end
	return nil
end

-- Универсальная функция запуска (для людей и для вещей)
local function launch(object, targetPosition)
	-- Находим главную физическую деталь объекта (для игрока, модели или одиночного блока)
	local root = nil
	if object:IsA("Model") then
		root = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
	elseif object:IsA("BasePart") then
		root = object
	end
	
	if not root or root.Anchored then return end

	-- Если это человек (игрок или NPC), отсоединяем от сиденья
	local humanoid = object:FindFirstChildOfClass("Humanoid") or (object.Parent and object.Parent:FindFirstChildOfClass("Humanoid"))
	if humanoid then
		humanoid.Sit = false
		task.wait(0.05) -- Пауза на отцепление физики
	end

	-- Считаем вектор направления и дистанцию
	local startPosition = root.Position
	local distance = (targetPosition - startPosition).Magnitude
	local direction = (targetPosition - startPosition).Unit

	-- Рассчитываем итоговую скорость: направление * дистанция * множитель + дуга вверх
	local velocity = (direction * distance * THROW_FORCE_MULTIPLIER) + Vector3.new(0, UPWARD_ARC, 0)

	-- Применяем импульс ко всей физической конструкции
	root.AssemblyLinearVelocity = velocity
end

-- Прием сигнала от клиента с прицелом на цель
throwEvent.OnServerEvent:Connect(function(player, targetCharacter)
	if not targetCharacter or not targetCharacter:FindFirstChild("HumanoidRootPart") then return end
	local targetPos = targetCharacter.HumanoidRootPart.Position

	-- Логика выбора: что именно бросаем?
	if SEAT_PATH then
		if SEAT_PATH.Occupant then
			-- 1. Если на сиденье сидит человек — бросаем его
			local victim = SEAT_PATH.Occupant.Parent
			launch(victim, targetPos)
		else
			-- 2. Если человека нет, ищем вещь/предмет на сиденье
			local item = findItemOnSeat(SEAT_PATH)
			if item then
				launch(item, targetPos)
			else
				-- 3. Если сиденье пустое, игрок бросает сам себя в цель
				if player.Character then launch(player.Character, targetPos) end
			end
		end
	else
		-- Если сиденья вообще нет на карте, просто кидаем себя в цель
		if player.Character then launch(player.Character, targetPos) end
	end
end)
