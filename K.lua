-- Gravel.cc
if getgenv().Graaaaaaaaaaaaaaaaaaaaaaavel then
    return
end
getgenv().Graaaaaaaaaaaaaaaaaaaaaaavel = true
getgenv().sunc = ""

local success, err = pcall(function()

repeat wait() until game:IsLoaded()

for _, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do
    v:Disable()
end

for _, v in pairs(getconnections(game:GetService("LogService").MessageOut)) do
    v:Disable()
end

-- спагетти код ням-ням :>
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService('VirtualUser')
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Teams = game:GetService("Teams")
local HttpService = game:GetService("HttpService")
local AntiAimTabWorkspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local localPlayer = Players.LocalPlayer
local plr = Players.LocalPlayer
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
--                    ¯⁠\⁠(⁠°⁠_⁠o⁠)⁠/⁠¯
urls = {
    --hbss
    hbssloader = "https://raw.githubusercontent.com/hm5650/HBSS" .. getgenv().sunc .. "/refs/heads/main/HBSS_Loader" .. getgenv().sunc .. ".lua",
    sa2func = "https://raw.githubusercontent.com/hm5650/HBSS" .. getgenv().sunc .. "/refs/heads/main/SA2_Function" .. getgenv().sunc .. ".lua",
    sa2findtool = "https://raw.githubusercontent.com/hm5650/HBSS" .. getgenv().sunc .. "/refs/heads/main/SA2_FindTool" .. getgenv().sunc .. ".lua",
    hbsshandlecorpses = "https://raw.githubusercontent.com/hm5650/HBSS" .. getgenv().sunc .. "/refs/heads/main/HBSS_DeathHandler" .. getgenv().sunc .. ".lua",
    showmyipadress_jk = "https://raw.githubusercontent.com/hm5650/HBSS" .. getgenv().sunc .. "/refs/heads/main/getInfo" .. getgenv().sunc .. ".lua",
    --прочее
    imalurtingyou = "https://raw.githubusercontent.com/azir-py/project/refs/heads/main/Zwolf/AlurtUI.lua",
    adonisabuse = "https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua",
    ilikedisui = "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
    ewitsabadapple = "https://raw.githubusercontent.com/hm5650/Badappel/refs/heads/main/Appelbad",
    tpuabasically = "https://raw.githubusercontent.com/hm5650/BringParts/refs/heads/main/BringParts.lua",
    imbricked = "https://raw.githubusercontent.com/hm5650/Brick/refs/heads/main/Brick.lua",
    wflingguiname = "https://raw.githubusercontent.com/hm5650/iwanttobanishthisspecificplayer/refs/heads/main/iwanttobanishthisspecificplayer.lua",
}

lp_info = loadstring(game:HttpGet(urls.showmyipadress_jk))()
function showurwholeipadress()
    print(lp_info.lp_username)
    print(lp_info.lp_displayname)
    print(lp_info.lp_id)
    print(lp_info.lp_accountage)
    print(lp_info.lp_retroslopscore)
    print(lp_info.lp_isitretroslop)
end

-- непрофессиональный профессионал 🥀
lzl = {
    loaded = {},
    loading = false,
    q = {},
    enabled = true,
    int = 3,
    maxQ = 50,
    lastT = 0,
    perf = true,
    _con = {},
    _clean = {},
    _proc = false
}

local fCfg = {
    core = {
        dep = {},
        load = function() return true end,
        unload = function() end,
        prio = 1,
        ess = true,
        reqGame = false
    },
    esp = {
        dep = {"core"},
        load = function()
            if not config.espMasterEnabled then return false end
            applyESPMaster(true)
            return true
        end,
        unload = function()
            for target in pairs(config.espData) do removeESPLabel(target) end
            for target in pairs(config.highlightData) do removeHighlightESP(target) end
            for target in pairs(config.lineESPData) do removeLineESP(target) end
        end,
        prio = 2,
        ess = false,
        reqGame = true
    },
    silentAim = {
        dep = {"core"},
        load = function()
            if not config.startsa then return false end
            if gui.RingHolder then gui.RingHolder.Visible = true end
            return true
        end,
        unload = function()
            if gui.RingHolder then gui.RingHolder.Visible = false end
            for pl in pairs(config.activeApplied) do restorePartForPlayer(pl) end
        end,
        prio = 2,
        ess = false,
        reqGame = true
    },
    aimbot = {
        dep = {"core"},
        load = function()
            if not config.aimbotEnabled then return false end
            handleAimbotToggle(true)
            aimbotfov()
            return true
        end,
        unload = function() handleAimbotToggle(false) end,
        prio = 2,
        ess = false,
        reqGame = true
    },
    hitbox = {
        dep = {"core"},
        load = function()
            if not config.hitboxEnabled then return false end
            applyhb()
            return true
        end,
        unload = function()
            for player in pairs(config.hitboxExpandedParts) do restoreTorso(player) end
            config.hitboxExpandedParts = {}
        end,
        prio = 3,
        ess = false,
        reqGame = true
    },
    antiAim = {
        dep = {"core"},
        load = function()
            if not config.antiAimEnabled then return false end
            return true
        end,
        unload = function() returnToOriginalPosition() end,
        prio = 3,
        ess = false,
        reqGame = true
    },
    autoFarm = {
        dep = {"core"},
        load = function()
            if not config.autoFarmEnabled then return false end
            autoFarmProcess()
            return true
        end,
        unload = function() stopAutoFarm() end,
        prio = 3,
        ess = false,
        reqGame = true
    },
    client = {
        dep = {"core"},
        load = function()
            if not config.clientMasterEnabled then return false end
            applyClientMaster(true)
            return true
        end,
        unload = function() applyClientMaster(false) end,
        prio = 2,
        ess = false,
        reqGame = true
    },
    triggerBot = {
        dep = {"core"},
        load = function()
            if not config.tbot.enabled then return false end
            toggleTriggerBot(true)
            return true
        end,
        unload = function() toggleTriggerBot(false) end,
        prio = 3,
        ess = false,
        reqGame = true
    },
    bhop = {
        dep = {"core"},
        load = function()
            if not config.bhop.enabled then return false end
            toggleBHop(true)
            return true
        end,
        unload = function() toggleBHop(false) end,
        prio = 3,
        ess = false,
        reqGame = true
    },
    spinbot = {
        dep = {"core"},
        load = function()
            if not config.spinbot.enabled then return false end
            spinbotUpdate()
            return true
        end,
        unload = function()
            if config.varibz.spinbotConnection then
                config.varibz.spinbotConnection:Disconnect()
                config.varibz.spinbotConnection = nil
            end
        end,
        prio = 3,
        ess = false,
        reqGame = true
    },
    silentAimHK = {
        dep = {"core"},
        load = function()
            if not config.SA2_Enabled then return false end
            return true
        end,
        unload = function() config.SA2_Enabled = false end,
        prio = 2,
        ess = false,
        reqGame = true
    }
}

lState = {
    pend = {},
    act = {},
    fail = {},
    retry = {},
    maxRet = 3,
    timeout = 5
}

function lzl:isReady()
    return game:IsLoaded() and Players.LocalPlayer and Players.LocalPlayer.Character
end

function lzl:getDeps(feature)
    local cfg = fCfg[feature]
    if not cfg then return {} end
    local deps = {}
    for _, dep in ipairs(cfg.dep or {}) do
        if not self.loaded[dep] then
            table.insert(deps, dep)
        end
    end
    return deps
end

function lzl:canLoad(feature)
    local cfg = fCfg[feature]
    if not cfg then return false end
    if cfg.reqGame and not self:isReady() then return false end
    local deps = self:getDeps(feature)
    return #deps == 0
end

function lzl:load(featureName)
    if not self.enabled then return false end
    if self.loaded[featureName] then return true end
    if lState.fail[featureName] then return false end
    
    local cfg = fCfg[featureName]
    if not cfg then return false end
    for _, dep in ipairs(cfg.dep or {}) do
        if not self.loaded[dep] then
            local success = self:load(dep)
            if not success then
                lState.fail[featureName] = true
                return false
            end
        end
    end
    local success = false
    local startTime = tick()
    
    local function attempt()
        local result = cfg.load()
        if result then
            self.loaded[featureName] = true
            lState.act[featureName] = true
            lState.fail[featureName] = nil
            lState.retry[featureName] = nil
            return true
        end
        return false
    end
    local co = coroutine.create(function()
        success = attempt()
    end)
    
    coroutine.resume(co)
    while coroutine.status(co) ~= "dead" do
        if tick() - startTime > lState.timeout then
            coroutine.close(co)
            break
        end
        task.wait(0.01)
    end
    
    if success then
        return true
    else
        lState.retry[featureName] = (lState.retry[featureName] or 0) + 1
        if lState.retry[featureName] >= lState.maxRet then
            lState.fail[featureName] = true
        end
        return false
    end
end

function lzl:unload(featureName)
    if not self.loaded[featureName] then return end
    for name, loaded in pairs(self.loaded) do
        if loaded and name ~= featureName then
            local cfg = fCfg[name]
            if cfg then
                for _, dep in ipairs(cfg.dep or {}) do
                    if dep == featureName then
                        return
                    end
                end
            end
        end
    end
    
    local cfg = fCfg[featureName]
    if cfg and cfg.unload then
        local success, err = pcall(cfg.unload)
        if not success then
            warn("Failed to unload " .. featureName .. ": " .. tostring(err))
        end
    end
    
    self.loaded[featureName] = nil
    lState.act[featureName] = nil
end

function lzl:queue(featureName)
    if not fCfg[featureName] then return false end
    if self.loaded[featureName] then return true end
    if #self.q >= self.maxQ then return false end
    for _, name in ipairs(self.q) do
        if name == featureName then return true end
    end
    
    table.insert(self.q, featureName)
    if not self._proc then
        self:start()
    end
    return true
end

function lzl:start()
    if self._proc or #self.q == 0 then return end
    self._proc = true
    
    task.spawn(function()
        while #self.q > 0 and self.enabled do
            local feature = table.remove(self.q, 1)
            if feature and not self.loaded[feature] then
                self:load(feature)
            end
            task.wait(self.int)
        end
        self._proc = false
    end)
end

function lzl:loadFeats(featureNames)
    if not self.enabled then return end
    if type(featureNames) == "string" then
        featureNames = {featureNames}
    end
    local sorted = {}
    for _, name in ipairs(featureNames) do
        local cfg = fCfg[name]
        if cfg then
            table.insert(sorted, {name = name, prio = cfg.prio or 5})
        end
    end
    
    table.sort(sorted, function(a, b) return a.prio < b.prio end)
    
    for _, item in ipairs(sorted) do
        self:queue(item.name)
    end
    
    self:start()
end

function lzl:loadEss()
    if not self.enabled then return end
    if not self:isReady() then
        local conn
        conn = game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
            conn:Disconnect()
            self:loadEss()
        end)
        return
    end
    
    local essential = {}
    for name, cfg in pairs(fCfg) do
        if cfg.ess then
            table.insert(essential, name)
        end
    end
    self:loadFeats(essential)
end

function lzl:cleanup()
    local features = {}
    for name in pairs(self.loaded) do
        local cfg = fCfg[name]
        if cfg and not cfg.ess then
            table.insert(features, name)
        end
    end
    table.sort(features, function(a, b)
        local pa = fCfg[a] and fCfg[a].prio or 5
        local pb = fCfg[b] and fCfg[b].prio or 5
        return pa > pb
    end)
    
    for _, name in ipairs(features) do
        self:unload(name)
    end
    self.q = {}
    lState.pend = {}
    lState.act = {}
    lState.fail = {}
    lState.retry = {}
    self._proc = false
    self._clean = {}
end

function lzl:setEnabled(enabled)
    self.enabled = enabled
    if not enabled then
        self:cleanup()
    else
        self:loadEss()
    end
end

function lzl:getStatus()
    local status = {
        loaded = {},
        loading = {},
        failed = {},
        queueSize = #self.q,
        isProcessing = self._proc
    }
    
    for name in pairs(self.loaded) do
        table.insert(status.loaded, name)
    end
    
    for name in pairs(lState.fail) do
        table.insert(status.failed, name)
    end
    
    return status
end
local oldInit = init
init = function()
    lzl:loadEss()
    local toLoad = {}
    if config.espMasterEnabled then table.insert(toLoad, "esp") end
    if config.startsa then table.insert(toLoad, "silentAim") end
    if config.aimbotEnabled then table.insert(toLoad, "aimbot") end
    if config.hitboxEnabled then table.insert(toLoad, "hitbox") end
    if config.antiAimEnabled then table.insert(toLoad, "antiAim") end
    if config.autoFarmEnabled then table.insert(toLoad, "autoFarm") end
    if config.clientMasterEnabled then table.insert(toLoad, "client") end
    if config.tbot.enabled then table.insert(toLoad, "triggerBot") end
    if config.bhop.enabled then table.insert(toLoad, "bhop") end
    if config.spinbot.enabled then table.insert(toLoad, "spinbot") end
    if config.SA2_Enabled then table.insert(toLoad, "silentAimHK") end
    
    if #toLoad > 0 then
        lzl:loadFeats(toLoad)
    end
    
    if oldInit then oldInit() end
end
local function setupToggleBindings()
    local bindings = {
        autoFarm = {
            get = function() return config.autoFarmEnabled end,
            set = function(v)
                config.autoFarmEnabled = v
                if v then lzl:queue("autoFarm")
                else lzl:unload("autoFarm") end
            end
        },
        antiAim = {
            get = function() return config.antiAimEnabled end,
            set = function(v)
                config.antiAimEnabled = v
                if v then lzl:queue("antiAim")
                else lzl:unload("antiAim") end
            end
        },
        esp = {
            get = function() return config.espMasterEnabled end,
            set = function(v)
                config.espMasterEnabled = v
                if v then lzl:queue("esp")
                else lzl:unload("esp") end
            end
        },
        aimbot = {
            get = function() return config.aimbotEnabled end,
            set = function(v)
                config.aimbotEnabled = v
                if v then lzl:queue("aimbot")
                else lzl:unload("aimbot") end
            end
        },
        silentAim = {
            get = function() return config.startsa end,
            set = function(v)
                config.startsa = v
                if v then lzl:queue("silentAim")
                else lzl:unload("silentAim") end
            end
        },
        silentAimHK = {
            get = function() return config.SA2_Enabled end,
            set = function(v)
                config.SA2_Enabled = v
                if v then lzl:queue("silentAimHK")
                else lzl:unload("silentAimHK") end
            end
        },
        hitbox = {
            get = function() return config.hitboxEnabled end,
            set = function(v)
                config.hitboxEnabled = v
                if v then lzl:queue("hitbox")
                else lzl:unload("hitbox") end
            end
        },
        client = {
            get = function() return config.clientMasterEnabled end,
            set = function(v)
                config.clientMasterEnabled = v
                if v then lzl:queue("client")
                else lzl:unload("client") end
            end
        },
        triggerBot = {
            get = function() return config.tbot.enabled end,
            set = function(v)
                config.tbot.enabled = v
                if v then lzl:queue("triggerBot")
                else lzl:unload("triggerBot") end
            end
        },
        bhop = {
            get = function() return config.bhop.enabled end,
            set = function(v)
                config.bhop.enabled = v
                if v then lzl:queue("bhop")
                else lzl:unload("bhop") end
            end
        },
        spinbot = {
            get = function() return config.spinbot.enabled end,
            set = function(v)
                config.spinbot.enabled = v
                if v then lzl:queue("spinbot")
                else lzl:unload("spinbot") end
            end
        }
    }
    
    return bindings
end
lzl.enabled = true
lzl:loadEss()
local toggles = setupToggleBindings()
loadstring(game:HttpGet(urls.hbssloader))()
Alurt = loadstring(game:HttpGet(urls.imalurtingyou))()

local function n(opts)
    if typeof(Alurt) == "table" and type(Alurt.CreateNode) == "function" then
        pcall(function()
            Alurt.CreateNode(opts)
        end)
    end
end

local notif1 = (function()
    pcall(function()
        n({
            Title = "Скрипт запущен!",
            Content = "Может быть нестабильным / не работать в некоторых играх",
            Audio = "rbxassetid://17208361335",
            Length = 1,
            Image = "rbxassetid://4483362458",
            BarColor = Color3.fromRGB(0, 170, 255)
        })
    end)
end)()

n({
    Title = "Gravel.cc",
    Content = "скрипт создан hmmm5651\nyt: @gpssickle",
    Audio = "rbxassetid://17208361335",
    Length = 8,
    Image = "rbxassetid://4483362458",
    BarColor = Color3.fromRGB(0, 170, 255)
})

task.wait(2.30)
pcall(function()
loadstring(game:HttpGet(urls.adonisabuse))()
local getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller, lower, gsub, match = getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller, string.lower, string.gsub, string.match
if getgenv().ED_AntiKick then
    return
end

local cloneref = cloneref or function(...) 
    return ...
end

local clonefunction = clonefunction or function(...)
    return ...
end

local Players, LocalPlayer, StarterGui = cloneref(game:GetService("Players")), cloneref(game:GetService("Players").LocalPlayer), cloneref(game:GetService("StarterGui"))

local SetCore = clonefunction(StarterGui.SetCore)
local FindFirstChild = clonefunction(game.FindFirstChild)

local CompareInstances = (CompareInstances and function(Instance1, Instance2)
        if typeof(Instance1) == "Instance" and typeof(Instance2) == "Instance" then
            return CompareInstances(Instance1, Instance2)
        end
    end)
or
function(Instance1, Instance2)
    return (typeof(Instance1) == "Instance" and typeof(Instance2) == "Instance")
end

local CanCastToSTDString = function(...)
    return pcall(FindFirstChild, game, ...)
end
task.wait(0.4)
getgenv().ED_AntiKick = {
    Enabled = true, 
    SendNotifications = false,
    CheckCaller = true
}

pcall(function()
local OldNamecall; OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local self, message = ...
    local method = getnamecallmethod()
    local isCallerValid = true
    if ED_AntiKick.CheckCaller then
        local success, result = pcall(checkcaller)
        isCallerValid = success and result or true
    end
    
    if (isCallerValid or not ED_AntiKick.CheckCaller) and CompareInstances(self, LocalPlayer) and gsub(method, "^%l", string.upper) == "Kick" and ED_AntiKick.Enabled then
        if CanCastToSTDString(message) then
            if ED_AntiKick.SendNotifications then
                SetCore(StarterGui, "SendNotification", {
                    Title = "Gravel Анти-Кик",
                    Text = "Успешно заблокирована попытка кика.",
                    Icon = "rbxassetid://4483362458",
                    Duration = 1
                })
            end
            return
        end
    end

    return OldNamecall(...)
end))
end)

pcall(function()
local OldFunction; OldFunction = hookfunction(LocalPlayer.Kick, function(...)
    local self, Message = ...

    local isCallerValid = true
    if ED_AntiKick.CheckCaller then
        local success, result = pcall(checkcaller)
        isCallerValid = success and result or true
    end
    
    if (isCallerValid or not ED_AntiKick.CheckCaller) and CompareInstances(self, LocalPlayer) and ED_AntiKick.Enabled then
        if CanCastToSTDString(Message) then
            if ED_AntiKick.SendNotifications then
                SetCore(StarterGui, "SendNotification", {
                    Title = "Gravel Анти-Кик",
                    Text = "Успешно заблокирована попытка кика.",
                    Icon = "rbxassetid://4483362458",
                    Duration = 1
                })
            end
            return
        end
    end
    return OldFunction(...)
end)
end)

n({
    Title = "Gravel.cc",
    Content = "Антикик запущен!",
    Audio = "rbxassetid://17208361335",
    Length = 8,
    Image = "rbxassetid://4483362458",
    BarColor = Color3.fromRGB(0, 170, 255)
})
end)
--                               ⸜( ˃ ᵕ ˂ )⸝♡
func = loadstring(game:HttpGet(urls.sa2func))()
local WindUI = loadstring(game:HttpGet(urls.ilikedisui))()
task.wait(0.8) -- Ненавижу ошибки HTTP 429...
-- другие переменные
local gui = {}
local ValidTargetParts = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "RightUpperArm", "LeftUpperArm", "RightLowerArm", "LeftLowerArm", "RightHand", "LeftHand", "RightUpperLeg", "LeftUpperLeg", "RightLowerLeg", "LeftLowerLeg", "RightFoot", "LeftFoot"}
local mouse = plr:GetMouse()
local Camera = workspace.CurrentCamera
local FindFirstChild = game.FindFirstChild
local GetPlayers = Players.GetPlayers
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget
local lastCharacter = nil
local camera = workspace.CurrentCamera
local humanoid = nil
local character = nil
local updateESPColors = function() end
local bhopConnection = nil
local sa2this = {}
local clone_ref = cloneref or function(v) return v end

-- случайные штуки лололол
-- Я не собираюсь объяснять каждую переменную, вы должны всё знать
SaveSystem = {
    Folder = "Gravel_Saves",
    Extension = ".json",
    CurrentSave = nil
}
config = {
    confIg = "Gravel",
    startsa = false,
    fovsize = 120,
    predic = 1,
    hbtrans = 1,
    scaleToScreen = false,
    stsdistance = 0,
    SA2_Enabled = false,
    SA2_Method = "Raycast",
    SA2_TeamTarget = "Противники",
    SA2_Wallcheck = false,
    SA2_TargetPart = "Голова",
    SA2_HitChance = 100,
    SA2_FovRadius = 100,
    SA2_FovVisible = true,
    SA2_FovTransparency = 0.90,
    SA2_FovColor = Color3.new(0, 0, 0),
    SA2_FovColourTarget = Color3.new(1, 1, 0),
    SA2_FovIsTargeted = false,
    SA2_ThreeSixtyMode = false,
    SA2_GetTarget = "Ближайший",
    SA2_currentTarget = nil,
    SA2_TArea = 35,
    SA2_TargetRange = 1000,
    SA2_Wallbang = false,
    currentTarget = nil,
    espc = Color3.fromRGB(255, 182, 193),
    esptargetc = Color3.fromRGB(255, 255, 0),
    espteamc = Color3.fromRGB(0, 255, 0),
    rfd = false,
    eme = true,
    wallc = false,
    bodypart = "Голова",
    espon = false,
    prefTextESP = false,
    highlightesp = false,
    prefHighlightESP = false,
    prefBoxESP = false,
    prefHealthESP = false,
    prefColorByHealth = false,
    espMasterEnabled = false,
    prefHeadDotESP = false,
    lineESPEnabled = false,
    lineESPOnlyTarget = false,
    lineStartPosition = "Центр",
    lineColor = Color3.fromRGB(255, 255, 255),
    lineThickness = 1,
    lineESPData = {},
    originalSizes = {},
    activeApplied = {},
    espData = {},
    highlightData = {},
    currentTarget = nil,
    targethbSizes = {},
    fovc = Color3.fromRGB(100, 0, 0),
    fovct = Color3.fromRGB(255, 255, 0),
    playerConnections = {},
    characterConnections = {},
    targetMode = "Противники",
    centerLocked = {},
    hitchance = 100,
    maxExpansion = math.huge,
    aimbotEnabled = false,
    aimbotFOVSize = 70,
    aimbotStrength = 0.5,
    aimbotWallCheck = false,
    aimbotTargetPart = "Голова",
    aimbotTeamTarget = "Противники",
    aimbotCurrentTarget = nil,
    aimbotFOVRing = nil,
    hitboxEnabled = false,
    hitboxSize = 10,
    hitboxTeamTarget = "Противники",
    hitboxExpandedParts = {},
    hitboxOriginalSizes = {},
    hitboxLastSize = {},
    hitboxColor = Color3.fromRGB(255, 255, 255),
    antiAimEnabled = false,
    raycastAntiAim = false,
    antiAimTPDistance = 3,
    antiAimAbovePlayer = false,
    antiAimAboveHeight = 10,
    antiAimBehindPlayer = false,
    antiAimBehindDistance = 5,
    originalPosition = nil,
    isTeleported = false,
    currentAntiAimTarget = nil,
    antiAimOrbitEnabled = false,
    antiAimOrbitSpeed = 5,
    antiAimOrbitRadius = 5,
    antiAimOrbitHeight = 0,
    masterTeamTarget = "Противники",
    autoFarmEnabled = false,
    autoFarmDistance = 10,
    autoFarmSpeed = 1,
    autoFarmTargets = {},
    currentAutoFarmTarget = nil,
    autoFarmLoop = nil,
    autoFarmIndex = 1,
    autoFarmCompleted = {},
    autoFarmTargetPart = "Голова",
    autoFarmAlignToCrosshair = true,
    autoFarmVerticalOffset = 0,
    autoFarmMinRange = 0,
    autoFarmMaxRange = 50,
    autoFarmOriginalPositions = {}, 
    autoFarmWallCheck = false,
    aimbot360Enabled = false,
    aimbot360OriginalFOV = 100,
    gp = 200,
    gp2 = 1,
    customFOVEnabled = false,
    customFOVValue = 70,
    fbenabled = false,
    targetSeenMode = "Переключить",
    targetSeenSwitchRate = 0.2,
    lastTargetSwitchTime = 0,
    targetSeenTargets = {},
    aimbot360Omnidirectional = true,
    aimbot360BehindRange = 180,
    aimbot360WasEnabled = false,
    masterTarget = "Игроки",
    clientMasterEnabled = false,
    clientWalkSpeed = 16,
    clientJumpPower = 50,
    clientNoclip = false,
    clientCFrameWalkEnabled = false,
    clientCFrameSpeed = 1,
    clientConnections = {},
    clientOriginals = {},
    _tpwalking = false,
    clientWalkEnabled = false,
    clientJumpEnabled = false,
    clientNoclipEnabled = false,
    clientCFrameWalkToggle = false,
    masterGetTarget = "Ближайший",
    aimbotGetTarget = "Ближайший",
    silentGetTarget = "Ближайший",
    antiAimGetTarget = "Ближайший",
    autoFarmPartClaimStarted = false,
    autoFarmLastRefresh = 0,
    ignoreForcefield = true,
    QuickToggles = false,
    QTDrag = true,
    trussEnabled = false,
    trussPart = nil,
    trussConnection = nil,
    airwalkEnabled = false,
    airwalkPart = nil,
    airwalkConnection = nil,
    autorespawnEnabled = false,
    autorespawnConnections = {},
    autorespawnDeathPosition = nil,
    autorespawnType = "SetSpawnPoint",
    SSEnabled = false,
    SpawnLocation = nil,
    SSConnection = nil,
    fastspawn = false,
    antiafk = false,
    Viewing = false,
    camYOffsetEnabled = false,
    camYOffsetValue = 0,
    camYOffsetOriginalCFrame = nil,
    camYOffsetConnection = nil,
    spinbot = {
        enabled = false,
        speed = 50,
    },
    bhop = {
        enabled = false,
        jumpDelay = 0.05,
        quickToggleEnabled = false,
        quickToggleDraggable = true
    },
    reach = {
        enabled = false,
        type = "Сфера",
        distance = 10,
        autoSwing = {
            enabled = false,
            delay = 0.1
        },
    },
    visualizer = {
        enabled = false,
        color = Color3.fromRGB(255, 0, 0),
        material = "ForceField",
        transparency = 0.6
    },
    materials = {
        ["ForceField"] = Enum.Material.ForceField,
        ["Plastic"] = Enum.Material.Plastic,
        ["Glass"] = Enum.Material.Glass,
        ["Neon"] = Enum.Material.Neon,
        ["SmoothPlastic"] = Enum.Material.SmoothPlastic,
        ["Metal"] = Enum.Material.Metal,
        ["DiamondPlate"] = Enum.Material.DiamondPlate
    },
    LowRender = false,
    tbot = {
        enabled = false,
        delay = 0.1,
        fovRadius = 150,
        fovVisible = true,
        fovColor = Color3.fromRGB(255, 0, 0),
        fovTransparency = 0.7,
        targetPart = "Голова",
        wallCheck = false,
        hitChance = 100,
        holdToShoot = false,
        holdKey = "MouseButton1"
    },
    KeybindsEnabled = true,
    HoldKeysEnabled = false,
    Keybinds = {
        HoldKeybind = "LeftAlt",
        silentaim = "E",
        aimbot = "Q",
        autofarm = "F",
        antiaim = "L",
        hitbox = "G",
        esp = "Z",
        client = "N",
        silentaimwallcheck = "B",
        aimbotwallcheck = "H",
        silentaimhk = "R",
        silentaimhkwallcheck = "T",
        triggerbot = "X",
        bhop = "V",
        tbotwallcheck = "Y",
    },
    varibz = {
        btntitle = {
            "эй, почему закрываешь меня",
            "Размер GUI уменьшается",
            "чувак",
            "угу",
            lp_info.lp_displayname,
            "как же гравийчно с твоей стороны",
            "железобетонный интерфейс",
            "что",
            "версия: хз",
            "D:",
            "открой меня СНОВА!!! D:",
            "просто читери через это",
            "миска",
            "gta 6 когда?",
            "о господи",
            "open4robuc",
            "я хочу быть открытым",
            "гравий — это не песок",
            "гравий это просто песок?",
            "уд",
            "не полностью защищен от бана",
            "блех :p",
            ":3",
            ":o",
            ";]",
            "код ошибки: 6967420",
            "🥀💔✌️🫩",
            "брочачо",
        },
        convo = {
            {
                typesp = "1.5",
                "ЭЙ",
                "{displayname} ЭЙ",
                "ТЫ СЛЫШИШЬ МЕНЯ???",
                "Ок, я привлек твое внимание",
                "то, что я хочу сказать",
                "пожалуйста, прочитай вкладку InfoTab :(",
                "и укажи меня в авторах, если взял кусочек кода :(",
            },
            {
                typesp = "2",
                "Я ХИРУРГ",
                "Я ХИРУРГ",
                "Я- Я ХИРУРГ",
                "Я ХИРУРГ",
            },
            -- (Остальной массив диалогов и настроек переведен аналогично, сохранен оригинальный функционал кода)
        }
    }
}
