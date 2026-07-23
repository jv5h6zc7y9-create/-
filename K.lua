print([[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⡿⣷⣄⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣧⣈⣻⣷
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠟⠉⠙⠛⠁
⠀⠀⢀⣴⣿⣦⡀⢀⣴⠿⠁⠀⠀⠀⠀⠀
⠀⣴⡿⠋⠀⢹⣿⣿⡁⠀⠀⠀⠀⠀⠀⠀
⢰⣿⠀⠀    ⠉⠙⣿⣦⠀⠀⠀⠀⠀⠀
⠸⣿⡀⠀⠀⠀⣠⣾⠟⠁⠀⠀⠀⠀⠀⠀
⠀⠙⠻⠿⠿⠟⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
           
           “I like this dastardly tomfoolery :D” 
                                           
                               - Gpssickle
]])

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

-- spaghetti code yummy :>
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
local LocalPlayer = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
local CircleFrame = Instance.new("Frame")
local UIStroke = Instance.new("UIStroke")
local UICorner = Instance.new("UICorner")
--                        ¯⁠\⁠(⁠°⁠_⁠o⁠)⁠/⁠¯
local urls = {
    --hbss completely random useless & useful modules :]
    hbssloader = "https://raw.githubusercontent.com/hm5650/HBSS" .. getgenv().sunc .. "/refs/heads/main/HBSS_Loader" .. getgenv().sunc .. ".lua",
    sa2func = "https://raw.githubusercontent.com/hm5650/HBSS" .. getgenv().sunc .. "/refs/heads/main/SA2_Function" .. getgenv().sunc .. ".lua",
    sa2findtool = "https://raw.githubusercontent.com/hm5650/HBSS" .. getgenv().sunc .. "/refs/heads/main/SA2_FindTool" .. getgenv().sunc .. ".lua",
    hbsshandlecorpses = "https://raw.githubusercontent.com/hm5650/HBSS" .. getgenv().sunc .. "/refs/heads/main/HBSS_DeathHandler" .. getgenv().sunc .. ".lua",
    showmyipadress_jk = "https://raw.githubusercontent.com/hm5650/HBSS" .. getgenv().sunc .. "/refs/heads/main/getInfo" .. getgenv().sunc .. ".lua",
    lzlzlzlzlzl = "https://raw.githubusercontent.com/hm5650/HBSS" .. getgenv().sunc .. "/refs/heads/main/HBSS_LazyLoader" .. getgenv().sunc .. ".lua",
    uithesavory = "https://raw.githubusercontent.com/hm5650/HBSS" .. getgenv().sunc .. "/refs/heads/main/HBSS_SaveUI" .. getgenv().sunc .. ".lua",
    --other
    imalurtingyou = "https://raw.githubusercontent.com/azir-py/project/refs/heads/main/Zwolf/AlurtUI.lua",
    adonisabuse = "https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua",
    ilikedisui = "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
    ewitsabadapple = "https://raw.githubusercontent.com/hm5650/Badappel/refs/heads/main/Appelbad",
    tpuabasically = "https://raw.githubusercontent.com/hm5650/BringParts/refs/heads/main/BringParts.lua",
    imbricked = "https://raw.githubusercontent.com/hm5650/Brick/refs/heads/main/Brick.lua",
    wflingguiname = "https://raw.githubusercontent.com/hm5650/iwanttobanishthisspecificplayer/refs/heads/main/iwanttobanishthisspecificplayer.lua",
}

local lp_info = loadstring(game:HttpGet(urls.showmyipadress_jk))()
function showurwholeipadress3827103828827273637()
    print(lp_info.lp_username)
    print(lp_info.lp_displayname)
    print(lp_info.lp_id)
    print(lp_info.lp_accountage)
    print(lp_info.lp_retroslopscore)
    print(lp_info.lp_isitretroslop)
end

-- unprofessionalism professionist 🥀
local lzl = loadstring(game:HttpGet(urls.lzlzlzlzlzl))()
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
    },
    viewing = {
        dep = {"core"},
        load = function()
            if not config.Viewing then return false end
            return true
        end,
        unload = function()
            config.Viewing = false
            if config.varibz.ViewConnection then
                config.varibz.ViewConnection:Disconnect()
                config.varibz.ViewConnection = nil
            end
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end,
        prio = 4,
        ess = false,
        reqGame = true
    },
    camYOffset = {
        dep = {"core"},
        load = function()
            if not config.camYOffsetEnabled then return false end
            if not config.camYOffsetConnection then
                config.camYOffsetConnection = game:GetService("RunService").RenderStepped:Connect(function()
                    if config.camYOffsetEnabled then
                        local cam = workspace.CurrentCamera
                        if cam then
                            if not config.camYOffsetOriginalCFrame then
                                config.camYOffsetOriginalCFrame = cam.CFrame
                            end
                            local offset = Vector3.new(0, config.camYOffsetValue, 0)
                            local newCFrame = CFrame.new(
                                cam.CFrame.Position + offset,
                                cam.CFrame.Position + offset + cam.CFrame.LookVector
                            )
                            cam.CFrame = newCFrame
                        end
                    end
                end)
            end
            return true
        end,
        unload = function()
            if config.camYOffsetConnection then
                config.camYOffsetConnection:Disconnect()
                config.camYOffsetConnection = nil
            end
            config.camYOffsetOriginalCFrame = nil
        end,
        prio = 4,
        ess = false,
        reqGame = true
    },
    truss = {
        dep = {"core"},
        load = function()
            if not config.trussEnabled then return false end
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    if config.trussPart then
                        config.trussPart:Destroy()
                        config.trussPart = nil
                    end
                    if config.trussConnection then
                        config.trussConnection:Disconnect()
                        config.trussConnection = nil
                    end
                    config.trussPart = Instance.new("TrussPart")
                    config.trussPart.Transparency = 1
                    config.trussPart.Size = Vector3.new(2, 10, 2)
                    config.trussPart.Parent = workspace
                    config.trussPart.CanCollide = true
                    config.trussPart.Name = "TrussPart_" .. tostring(math.random(10000, 99999))
                    config.trussConnection = game:GetService("RunService").Heartbeat:Connect(function()
                        if config.trussEnabled and config.trussPart and rootPart and rootPart.Parent then
                            config.trussPart.CFrame = rootPart.CFrame * CFrame.new(0, 0, -1.5)
                        else
                            if config.trussConnection then
                                config.trussConnection:Disconnect()
                                config.trussConnection = nil
                            end
                        end
                    end)
                end
            end
            return true
        end,
        unload = function()
            if config.trussPart then
                config.trussPart:Destroy()
                config.trussPart = nil
            end
            if config.trussConnection then
                config.trussConnection:Disconnect()
                config.trussConnection = nil
            end
        end,
        prio = 4,
        ess = false,
        reqGame = true
    },
    airwalk = {
        dep = {"core"},
        load = function()
            if not config.airwalkEnabled then return false end
            local character = game.Players.LocalPlayer.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    config.airwalkPart = Instance.new("Part")
                    config.airwalkPart.Transparency = 1
                    config.airwalkPart.Size = Vector3.new(7, 2, 3)
                    config.airwalkPart.Parent = workspace
                    config.airwalkPart.CanCollide = true
                    config.airwalkPart.Anchored = true
                    config.airwalkPart.Name = "AirwalkPlatform_" .. tostring(math.random(10000, 99999))
                    if config.airwalkConnection then
                        config.airwalkConnection:Disconnect()
                        config.airwalkConnection = nil
                    end
                    config.airwalkConnection = game:GetService("RunService").Heartbeat:Connect(function()
                        if config.airwalkEnabled and config.airwalkPart and rootPart and rootPart.Parent then
                            config.airwalkPart.CFrame = rootPart.CFrame + Vector3.new(0, -4, 0)
                        else
                            if config.airwalkConnection then
                                config.airwalkConnection:Disconnect()
                                config.airwalkConnection = nil
                            end
                        end
                    end)
                end
            end
            return true
        end,
        unload = function()
            if config.airwalkPart then
                config.airwalkPart:Destroy()
                config.airwalkPart = nil
            end
            if config.airwalkConnection then
                config.airwalkConnection:Disconnect()
                config.airwalkConnection = nil
            end
        end,
        prio = 4,
        ess = false,
        reqGame = true
    },
    autorespawn = {
        dep = {"core"},
        load = function()
            if not config.autorespawnEnabled then return false end
            config.autorespawnConnections = config.autorespawnConnections or {}
            config.autorespawnDeathPosition = nil
            local player = game.Players.LocalPlayer
            local function setupRespawn(character)
                local humanoid = character:WaitForChild("Humanoid")
                local rootPart = character:WaitForChild("HumanoidRootPart")
                if config.autorespawnConnections.died then
                    config.autorespawnConnections.died:Disconnect()
                end
                config.autorespawnConnections.died = humanoid.Died:Connect(function()
                    if config.autorespawnEnabled then
                        config.autorespawnDeathPosition = rootPart.CFrame
                    end
                end)
            end
            local function teleportToDeathPosition(newCharacter)
                if config.autorespawnEnabled and config.autorespawnDeathPosition then
                    local newRoot = newCharacter:WaitForChild("HumanoidRootPart")
                    newRoot.CFrame = config.autorespawnDeathPosition
                    config.autorespawnDeathPosition = nil
                end
            end
            if player.Character then
                setupRespawn(player.Character)
            end
            if config.autorespawnConnections.characterAdded then
                config.autorespawnConnections.characterAdded:Disconnect()
            end
            config.autorespawnConnections.characterAdded = player.CharacterAdded:Connect(function(character)
                if config.autorespawnEnabled then
                    character:WaitForChild("Humanoid")
                    character:WaitForChild("HumanoidRootPart")
                    teleportToDeathPosition(character)
                    setupRespawn(character)
                end
            end)
            return true
        end,
        unload = function()
            config.autorespawnDeathPosition = nil
            if config.autorespawnConnections then
                for _, connection in pairs(config.autorespawnConnections) do
                    if connection then
                        connection:Disconnect()
                    end
                end
                config.autorespawnConnections = {}
            end
        end,
        prio = 4,
        ess = false,
        reqGame = true
    },
    fullbright = {
        dep = {"core"},
        load = function()
            if not config.fbenabled then return false end
            local lighting = game:GetService("Lighting")
            fullBrightSettings = {
                Ambient = lighting.Ambient,
                Brightness = lighting.Brightness,
                ClockTime = lighting.ClockTime,
                FogEnd = lighting.FogEnd,
                GlobalShadows = lighting.GlobalShadows,
                OutdoorAmbient = lighting.OutdoorAmbient
            }
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
            lighting.Brightness = 2
            lighting.FogEnd = 100000
            lighting.GlobalShadows = false
            lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            lighting.ClockTime = 14
            return true
        end,
        unload = function()
            if fullBrightSettings then
                local lighting = game:GetService("Lighting")
                for property, value in pairs(fullBrightSettings) do
                    lighting[property] = value
                end
                fullBrightSettings = nil
            end
        end,
        prio = 4,
        ess = false,
        reqGame = true
    },
    quickToggles = {
        dep = {"core"},
        load = function()
            if not config.QuickToggles then return false end
            CreateQT()
            return true
        end,
        unload = function() KillQT() end,
        prio = 4,
        ess = false,
        reqGame = true
    },
    bhopQuickToggle = {
        dep = {"core"},
        load = function()
            if not config.bhop.quickToggleEnabled then return false end
            updateBHopQuickToggle()
            return true
        end,
        unload = function()
            if config.varibz.bhopQuickToggleUI and config.varibz.bhopQuickToggleUI.ScreenGui then
                config.varibz.bhopQuickToggleUI.ScreenGui:Destroy()
                config.varibz.bhopQuickToggleUI = nil
            end
        end,
        prio = 4,
        ess = false,
        reqGame = true
    },
    antiafk = {
        dep = {"core"},
        load = function()
            if not config.antiafk then return false end
            return true
        end,
        unload = function() config.antiafk = false end,
        prio = 4,
        ess = false,
        reqGame = true
    },
    fastspawn = {
        dep = {"core"},
        load = function()
            if not config.fastspawn then return false end
            return true
        end,
        unload = function() config.fastspawn = false end,
        prio = 4,
        ess = false,
        reqGame = true
    },
    reach = {
        dep = {"core"},
        load = function()
            if not config.reach.enabled then return false end
            return true
        end,
        unload = function()
            config.reach.enabled = false
            if visualizer then visualizer.Parent = nil end
            if autoSwingConnection then
                autoSwingConnection:Disconnect()
                autoSwingConnection = nil
            end
        end,
        prio = 3,
        ess = false,
        reqGame = true
    },
    visualizer = {
        dep = {"core", "reach"},
        load = function()
            if not config.visualizer.enabled then return false end
            return true
        end,
        unload = function()
            config.visualizer.enabled = false
            if visualizer then visualizer.Parent = nil end
        end,
        prio = 4,
        ess = false,
        reqGame = true
    }
}
for name, cfg in pairs(fCfg) do
    lzl:registerFeature(name, cfg)
end

lzl:setConfig(fCfg)
lzl:loadEss()
loadstring(game:HttpGet(urls.hbssloader))()
local Alurt = loadstring(game:HttpGet(urls.imalurtingyou))()

local function n(opts)
    if typeof(Alurt) == "table" and type(Alurt.CreateNode) == "function" then
        pcall(function()
            Alurt.CreateNode(opts)
        end)
    end
end

n({
    Title = "Gravel.cc",
    Content = "script made by hmmm5651\nyt: @gpssickle",
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
                    Title = "Gravel Anti-Kick",
                    Text = "Successfully blocked an attempted kick.",
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
                    Title = "Gravel Anti-Kick",
                    Text = "Successfully blocked an attempted kick.",
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
    Content = "Antikick started!",
    Audio = "rbxassetid://17208361335",
    Length = 8,
    Image = "rbxassetid://4483362458",
    BarColor = Color3.fromRGB(0, 170, 255)
})
end)
--                               ⸜( ˃ ᵕ ˂ )⸝♡
func = loadstring(game:HttpGet(urls.sa2func))()
local WindUI = loadstring(game:HttpGet(urls.ilikedisui))()
local SaveUI = loadstring(game:HttpGet(urls.uithesavory))()
task.wait(0.8) -- I hate http 429 errors...
-- other wallmart variables
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
local clone_ref = cloneref or function(v) return v end

-- random stuff lololol
-- I'm not gonna explain each variable U have to know allat
getgenv().blablablahblahblahhblahblahhGraaaaaaaaaaaaaaaaaaaaaaavel = {
    Folder = "Gravel_Saves",
    Extension = ".json",
    CurrentSave = nil
}
local config = {
    confIg = "Gravel",
    startsa = false,
    fovsize = 120,
    predic = 1,
    hbtrans = 1,
    scaleToScreen = false,
    stsdistance = 0,
    SA2_Enabled = false,
    SA2_Method = "Raycast",
    SA2_TeamTarget = "Enemies",
    SA2_Wallcheck = false,
    SA2_TargetPart = "Head",
    SA2_HitChance = 100,
    SA2_FovRadius = 100,
    SA2_FovVisible = true,
    SA2_FovTransparency = 0.90,
    SA2_FovColor = Color3.new(0, 0, 0),
    SA2_FovColourTarget = Color3.new(1, 1, 0),
    SA2_FovIsTargeted = false,
    SA2_ThreeSixtyMode = false,
    SA2_GetTarget = "Closest",
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
    bodypart = "Head",
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
    lineStartPosition = "Center",
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
    targetMode = "Enemies",
    centerLocked = {},
    hitchance = 100,
    maxExpansion = math.huge,
    aimbotEnabled = false,
    aimbotFOVSize = 70,
    aimbotStrength = 0.5,
    aimbotWallCheck = false,
    aimbotTargetPart = "Head",
    aimbotTeamTarget = "Enemies",
    aimbotCurrentTarget = nil,
    aimbotFOVRing = nil,
    hitboxEnabled = false,
    hitboxSize = 10,
    hitboxTeamTarget = "Enemies",
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
    masterTeamTarget = "Enemies",
    autoFarmEnabled = false,
    autoFarmDistance = 10,
    autoFarmSpeed = 1,
    autoFarmTargets = {},
    currentAutoFarmTarget = nil,
    autoFarmLoop = nil,
    autoFarmIndex = 1,
    autoFarmCompleted = {},
    autoFarmTargetPart = "Head",
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
    targetSeenMode = "Switch",
    targetSeenSwitchRate = 0.2,
    lastTargetSwitchTime = 0,
    targetSeenTargets = {},
    aimbot360Omnidirectional = true,
    aimbot360BehindRange = 180,
    aimbot360WasEnabled = false,
    masterTarget = "Players",
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
    masterGetTarget = "Closest",
    aimbotGetTarget = "Closest",
    silentGetTarget = "Closest",
    antiAimGetTarget = "Closest",
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
        type = "Sphere",
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
        targetPart = "Head",
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
            "hey y close me",
            "Gui size decreases",
            "dude",
            "yh",
            lp_info.lp_displayname,
            "how graveling of u",
            "rock solid ui",
            "what",
            "version: idk",
            "D:",
            "unclose me NOW!!! D:",
            "just simply cheat through it",
            "bowl",
            "gta 6 when?",
            "holy cow",
            "open4robuc",
            "me want to be open",
            "gravel is not sand",
            "is gravel just sand",
            "gl",
            "not full ban-proof",
            "bleh :p",
            ":3",
            ":o",
            ";]",
            "error code: 6967420",
            "🥀💔✌️🫩",
            "brochacho",
        },
--[[
            {
                "",
            },
]]
        convo = {
            {
                typesp = "1.5",
                "HEY",
                "{displayname} HEY",
                "CAN YOU HEAR ME???",
                "Ok Ive got ur attention",
                "what I'm gonna say is",
                "pls read the InfoTab :(",
                "and credit me if u did a snippet :(",
            },
            {
                typesp = "2",
                "I AM A SURGEON",
                "I AM A SURGEON",
                "I AM- IAM A SURGEON",
                "IAM A SURGEON",
            },
            {
                typesp = "2",
                "i am an fucking architect",
                "GOD DAMN IT, IM JUST STUCK",
                "SELLING SHIT FURNITURE",
                "BECAUSE SOMEONE WONT GET OFF",
                "THEIR FAT FUCKING ASS AND HELP ME.",
            },
            {
                typesp = "2",
                "Hikinuku kasetto, ohsi komu risetto",
                "Mayoi komu meiro",
                "Susume domo daruseenyo",
                "Doa no saki ni boku no senaka ga mieta\nfurimuita saki ni kibiu ga mieta",
                "Jigoku no hate nado doko ni aru no ka\nideguchi wa mada nano?",
                "Kuru, Kuru, Kuru,\nKurikaesu, Kurikaesu, Kurikaesu",
                "FuraFura, FuraFura,\nFurakutaru, Furakutaru, Furakutaru, Furakutaru",
                "looping the rooms\ntype shi 💔",
            },
            {
                "proto conversion",
                "tbh idk wat I'm saying",
            },
            {
                "alt+f4 = free robux",
                "trust me it works",
                "101% works I'm sure",
            },
            {
                "who are u",
                "yea like who r u",
                "r u a gravel user?",
                "hmmmmm ok then",
            },
            {
                typesp = "1.5",
                "My Rival,",
                "My Idol,",
                "You've got me suicidal",
                "My love, your rage",
                "Our dying claims to fame'",
                "Our battle legendary,",
                "Our fickle fraternizing,",
                "A war inside my heart.",
                "Until ###### it do us part",
                "Bang, Bang, Bang, Bang",
                "'Til I take you...",
                "Down, Down, Down, Down",
                "I want you in the ground!",
            },
            {
                "Ugh, this kitchen is\nso hard to clean",
                "If only there was a easier way!",
                "",
                "Hi, I'm DErek Baum,\nsay goodbye to daily stains & dirty surfaces",
                "with new KITCHEN GUN!!",
                "This sink is filthy",
                "but just 3 shots from KITCHEN GUN",
                "BANG!, BANG!, BANG!",
                "and it sparkles like new!",
            },
            {
                "This toilet is so hard to clean!",
                "There must be a easier way",
                "",
                "HI!, I'm DERek baum & i declare war\non toilets with new TOILET GRENADE",
                "just pull the pin, pop it in the bowl,\nput the lid down",
                "and let TOILET GRENADE do the rest!",
                "BAAAAANNNNGGG!!!!",
            },
            {
                typesp = "2",
                "My bread was\nburnt to a crisp",
                "It's not like it's inedible\nor anything, I guess...",
                "I wish it was fluffy like usual\nif only it didn't get burnt...",
                "I guess there's no use in wishing now...",
                "",
                "My bread was\nburnt to a crisp",
                "It's rock hard...",
                "Not that it's inedible\nor anything, I guess...",
                "I really hope its\nnot burnt tomorrow",
                "It's bound to be better, right?",
                "I guess there's no use in wishing now...",
            },
            {
                "ur retroslop score is {retroscore}",
                "ye I'm deaduzz",
                "tbh... idc lol ur fine {displayname}",
            },
            {
                "I'm lazier than lazytown",
                "that's literally how lazy iam",
                "it's true but also not true",
                "ok whatevski",
            },
            {
                typesp = "2.5",
                "Did you do your chores?",
                "Yessirski!",
                "Did you do your chores?",
                "Yessirski!",
                "Did you do your chores?",
                "Yessirski!",
                "When I get home it better be clean!",
                "Did you do your chores?",
                "Yessirski!",
                "Did you do your chores?",
                "Yessirski!",
                "Did you do your chores?",
                "Yessirski!",
                "BOI WHY DID YA LIE TO ME",
                "AHHHHHH",
            },
            {
                typesp = "1.5",
                "Y-YO, {displayname} come over here",
                "come over here,\ncome over here",
                "Check out my new shoes,",
                "Theyre the brand new-",
                "1-2, Buckle my shoeeee",
                "3-4, Buckle some moreeeee",
                "5-6, Nike-y Kicks",
                "OH-OH-OhHH THAT IS SO FIRE",
            },
            {
                typesp = "2.3",
                "I party like I'm 21! CX",
                "20?",
                "21!",
                "I party like I'm 21! :D",
                "20?",
                "21! :v",
                "20?",
                "20?",
                "21! :c",
                "20?",
                "20?",
                "21! D:",
                "20?",
                "20?",
                "21! D:",
                "2-2-2-2?",
                "21! o_O",
                "20?",
                "20?",
                "21! ^⁠_⁠^",
                "20?",
                "20?",
                "21! :3",
                "20?",
                "20?",
                "21? :p",
                "2-2-2-2?",
                "20?",
                "21?",
            },
            {
                typesp = "1.5",
                "Error: (can't find message)",
                "Error: (can't find message)",
                "Error: (can't find message)",
                "I'm not having errors actually",
                "or maybe I am, who knows??",
            },
            {
                "server authority",
                "is laggyyyy :c",
                "like bro??? y is it so laggy :(((",
            },
            {
                typesp = "2.5",
                ":o",
                ":)",
                ";)",
                ";D",
            },
            {
                "Mama, can I have cookie",
                "No diabeto, roll back to kitchen",
                "awwwwwwwww :(",
            },
            {
                typesp = "1.5",
                "I JUST HIT THE",
                "JACKPOTTTTTTT",
                "AY, AY, AY, AY, AY",
                "I JUST HIT THE JACKPOT",
            },
            {
                "I wouldn't say gravel is da best",
                "idk there might be other scripts",
                "that are hidden gems",
                "well maybe gravel is one of em :v",
            },
            {
                typesp = "2",
                "All your base are belong to us",
                "11113333777",
                "TEH EPIK DUCK IS COMING!!!",
                "GET OF MAH LAWN",
                "ROFL",
                "{userid}",
                "Muahahahaha!",
            },
            {
                "ur accountage is {accountage}",
                "idk even know why I'm saying ts",
            },
            {
                typesp = "1.5",
                "if you could listen closely",
                "you'll be a villain mostly",
                "you have to chase a hero",
                "and watch em' go from 1 to 0",
                "just follow my moves.",
                "and you'll be set-",
                "to go and sneak around",
                "just be careful",
                "to not make a single sound",
                "as this superhero will be going-",
                "on the around",
                "now let's go and chase him down!",
                "",
                "is that a sick song {displayname}?",
            },
            {
                "name me a fictional villian\nthat no-1 h8s",
                "it's Robbie Rotten",
            },
            {
                "du bist gut genug...",
                "Ich weiß nicht,",
                "was die welt die sagt",
                "bleib einfach nur du,",
                "du bist gut genug!",
                "du bist gut genug!",
                "du bist gut genug!",
                "du bist gut genug!",
                "*fire music*",
            },
            {
                typesp = "1.5",
                "shimmy ey, shimmy ey, yaaa~",
                "drake.. Swalalala.. drake",
                "swalalala.. swalalala *sick beat*",
                "*sick music*... keep streaking yah",
            },
            {
                "Bro ts code is 14000+ lines long :(",
                "I ''can't'' do dis shi :[",
                "plz heseelepp me {displayname}",
            },
            {
                "Cframe view is op",
                "pls try it out {displayname}",
                "you'll like it :3",
            },
            {
                "Aimware",
                "is this actually aimware??",
                "who knows",
                "maybe it is",
            },
            {
                typesp = "3",
                ":3",
                ">:3",
                ":3",
                ">:3",
                ":3",
                ">:3",
                ":3",
                ">:3",
                ":3",
                ">:3",
                ":3",
                ">:3",
                ":3",
                ">:3",
                "^w^",
            },
            {
                "gravel cute :3",
                ":3 :3",
                ":3:3:3:3:3:3:3:3:3:3:3",
            },
            {
                typesp = "1.5",
                "Didn't take that well.",
                "Didn't take that well.",
                "Felt like!",
                "Didn't take that well.",
                "Didn't take that well.",
                "Felt like!",
                "Didn't take that well.",
                "Didn't take that well.",
                "Felt like!",
            },
            {
                typesp = "1.5",
                "I somehow see what's beautiful,",
                "In things that are ephemeral",
                "Am I only friend of mine",
                "Love is just.. a piece of time\nin the world",
                "In the world",
                "And I couldn't help but fall\nin love again",
            },
            {
                "I'm not actually talking to u",
                "but i am talking to u",
                "does that make any sense :s",
                "probably not",
            },
            {
                "r u hacking??",
                "I think u hackin",
                "yea ur def hackin",
            },
            {
                "you got ratted.",
                "I'm serious",
                "you've got ratted",
                "I'm joking lol",
            },
            {
                "ur social security number\nis [{userid}]",
                "no but seriously it is",
                "I'm jk",
                "what even is {userid} :b",
                "oh wait that's ur userid mb",
            },
            {
                "is gravel js crushed rocks?",
                "like genuinely???",
                "gravel could be js crushed rocks",
            },
            {
                "hbss means:",
                "heybuddystopstealing",
                "ye dat what it means",
            },
            {
                "I'm 101% u'll like gravel :3",
                "like I'm dat sure",
                "(why am I self-glazing)",
            },
            {
                "I work best on generic shooters",
                "if it's not a generic shooter",
                "I might break",
            },
            {
                "why is http 429 my enemy",
                "I SWEAR TO GOD",
                "everytime i load gravel",
                "it hits me with 429",
                "like bro chill out",
            },
            {
                "renderstepped is for chuds",
                "heartbeat gang where u at",
                "renderstepped makes me lag",
                "heartbeat smooth like butter",
            },
            {
                "did someone say spaghetti",
                "my code is pasta",
                "al dente and tangled",
                "bon appetit",
            },
            {
                "synapse x users be like",
                "where my script at",
                "script got executed",
                "by a 2017 exploit",
                "those were the days",
            },
            {
                "nil errors are my passion",
                "attempt to index nil",
                "my favorite error",
                "gets me every time",
            },
            {
                "if u see a syntax error",
                "just run it again",
                "it'll fix itself",
                "trust me bro",
            },
            {
                "the 200 variable limit",
                "is my sleep paralysis demon",
                "i wake up screaming",
                "at 3am thinking about it",
            },
            {
                "when the ui library updates",
                "and everything breaks",
                "i ''love'' rewriting code",
                "said no one ever",
            },
            {
                "print() are too overrated",
                "like bro it's just... idk even know :/",
            },
            {
                "blox fruits players be like",
                "is this for blox fruits",
                "no it's for generic shooters",
                "please learn to read",
            },
            {
                "gaming chair diff fr",
                "i got the 4000$ chair",
                "that's why i never miss",
                "totally not aimbot",
                "or silentaim",
                "or hitbox",
                "or [insert feature here]",
            },
            {
                "csgo players malding",
                "when i hit a 360 no scope",
                "jokes on them",
                "i don't even play csgo",
                "I play Roblox shooters",
                "so as u {displayname}",
            },
            {
                "me and the boys",
                "running the script",
                "and getting banned",
                "worth it every time",
            },
            {
                "shoutout to the devs",
                "that make this possible",
                "we appreciate you",
                "oh wait that's me :v",
            },
            {
                "me debugging at 2am",
                "why isn't it working",
                "oh i forgot a comma",
                "i'm going to sleep",
            },
            {
                "half life 3 confirmed",
                "gravel confirmed it",
                "trust me bro",
                "my uncle works at valve",
            },
            {
                "the script is free",
                "and open source",
                "and has silent aim",
                "what more could you want",
            },
            {
                "i love when the script",
                "works on the first try",
                "that's a lie",
                "it never does",
            },
            {
                "200 variable limit is",
                "my arch nemesis",
                "we have beef",
                "it started in 2024",
            },
            {
                "the script is held together",
                "by pure spite",
                "and caffeine",
                "mostly caffeine",
            },
            {
                "Did you know",
                "Water contains oxygen",
                "so you could breath underwater",
            },
            {
                "is that a hack",
                "no it's a gaming chair",
                "my chair has aimbot",
                "you should get one",
            },
            {
                "Gravel has 0 calories 2 burn",
                "so yeh {displayname} dis is\nwhy gravel can do dis",
            },
            {
                "wait this isn't a virus",
                "i was told it was a virus",
                "it's open source",
                "you can literally read it",
            },
            {
                typesp = "1.5",
                "hey {displayname}",
                "yea u",
                "the one reading this",
                "how's ur day going?",
                "mine's gravely :p",
                "get it?",
                "gravely?",
                "like gravel?",
                "ok i'll stop",
            },
            {
                typesp = "1.5",
                "so uh",
                "{displayname} u ever just",
                "look at a rock",
                "and think 'wow'",
                "that's me",
                "i'm the rock",
                "gravel specifically",
                "nice 2 meet u :3",
            },
            {
                typesp = "2",
                "ur probably using this",
                "to destroy some kids",
                "in a roblox game",
                "i respect that",
                "get rekt nerd >:D",
                "haha i'm just joking",
                "or am i?",
                ";)",
            },
            {
                typesp = "1.5",
                "psst",
                "hey",
                "over here",
                "yea u",
                "wanna know a secret?",
                "gravel is made of",
                "crushed rocks",
                "mind blown :o",
            },
            {
                typesp = "1.5",
                "r u a hacker?",
                "cuz u seem sus",
                "wait i'm the script",
                "i'm literally hacking\nfor u",
                "i'm the sus one",
                "my bad :p",
            },
            {
                "mastermz plzzlz\nshowcase mAh script",
                "plzlzllzllzzzzz",
                "like super duper pleasszz",
            },
            {
                "u ever just",
                "open a script",
                "and it works",
                "first try?",
                "yea me neither",
                "this is like my 50th version",
                "we don't talk about v1\noh yea g.cc dont has versions...",
            },
            {
                typesp = "1.5",
                "if u get banned",
                "don't blame me",
                "i'm just a rock",
                "rocks can't be blamed",
                "it's the law",
                "i think",
                "i didn't read it",
            },
            {
                "what's ur favorite",
                "type of rock?",
                "mine's gravel obv",
                "but igneous is cool too",
                "pumice floats",
                "that's wild",
                "nature is crazy :o",
            },
            {
                typesp = "2",
                "u think ur ready",
                "for the gravel experience?",
                "u think ur ready",
                "for the SILENT AIM??",
                "u think ur ready",
                "for the HITBOX??",
                "probably not :P",
            },
            {
                "some people use aimbot",
                "some people use silent aim",
                "but real ones",
                "use gravel",
                "and a gaming chair",
                "obviously",
            },
            {
                typesp = "1.5",
                "warning:",
                "this script may cause",
                "excessive winning",
                "opponents crying",
                "and accusations",
                "of being a hacker",
                "u have been warned >:D",
            },
            {
                "what do u call",
                "a sad rock?",
                "a crying pebble :(",
                "what do u call",
                "a happy rock?",
                "a gravely boy :D",
            },
            {
                typesp = "1.5",
                "u ever think about",
                "how i'm talking to u",
                "through text",
                "on a screen",
                "in a game",
                "about rocks",
                "life is weird man",
            },
            {
                "if u read this far",
                "u deserve a medal",
                "or a rock",
                "here's a virtual rock",
                "🥔",
                "wait that's a potato",
                "close enough :p",
            },
            {
                typesp = "1.5",
                "gravel's motto:",
                "be rocky",
                "be rough",
                "be resilient",
                "and don't get kicked",
                "by the server",
                "or anticheat",
            },
            {
                "some people use",
                "expensive hacks",
                "we use free ones",
                "and they work better",
                "take that capitalism",
                ":v",
            },
            {
                typesp = "2",
                "u know what's underrated?",
                "the sound of gravel",
                "crunch crunch",
                "satisfying as heck",
                "u can't change my mind",
            },
            {
                "me: 'i'll make a clean script'",
                "also me:",
                "*14000+ lines later*",
                "what is organization?",
                "i don't know her",
                ":s",
            },
            {
                typesp = "1.5",
                "this script contains:",
                " - 100% pure gravel",
                " - premium aim",
                " - secret sauce",
                " - questionable code",
                " - the tears of enemies",
                "read the ingredients",
                "u won't :P",
            },
            {
                "the gravel community",
                "is small",
                "but we are mighty",
                "like a pebble",
                "with a grudge",
                "don't mess with us",
                ">:D",
            },
            {
                typesp = "3",
                "i'm not a robot",
                "i'm a gravel",
                "robots are metal",
                "gravel is rock",
                "big difference",
                "checkmate atheists",
                ":v",
            },
            {
                "u ever get so bored",
                "u read script messages",
                "like these?",
                "same tbh",
                "i wrote them",
                "i have no life",
                "respect the grind",
            },
            {
                typesp = "2",
                "u ever try to explain",
                "what gravel is",
                "to someone?",
                " 'it's a script' ",
                " 'for roblox' ",
                " 'with aimbot' ",
                "they never understand",
                "sadge :(",
            },
            {
                "me trying to decide",
                "what feature to add next:",
                "*spins wheel*",
                "it lands on 'more jokes'",
                "so here we are",
                "u're welcome :D",
            },
            {
                typesp = "1.5",
                "if u enjoy this script",
                "tell a friend",
                "if u don't enjoy it",
                "tell a da Robloz support",
                "either way",
                "gravel supports u",
            },
            {
                typesp = "1.5",
                "i love it when",
                "the script loads",
                "and nothing breaks",
                "that's the best feeling",
                "better than winning",
                "better than robux",
                "pure joy",
            },
            {
                "u ever just",
                "silent aim someone",
                "and they go",
                " '??? how' ",
                "and then u say ping diff",
                "well I did that",
            },
            {
                "i'm not saying",
                "gravel is the best",
                "but i'm also not saying",
                "it's NOT the best",
                "so it's the bes but not da best-est",
                "llikee does that make sense?",
            },
            {
                typesp = "1.5",
                "u ever just",
                "accidentally write",
                "a really good feature",
                "and not know how",
                "u did it?",
                "that's most of gravel",
                "happy accidents",
                ":D",
            },
            {
                "i should probably",
                "document this code",
                "but that's future me's",
                "problem",
                "present me wants",
                "to add more jokes",
                "priorities :v",
            },
            {
                typesp = "1.5",
                "if u see me in game",
                "no u didn't",
                "if u see me hacking",
                "no u didn't",
                "if u see me winning",
                "that's just skill",
                "gravel skill",
                ";D",
            },
        },
        defaults = {
            minDelay = 25,
            maxDelay = 85,
            spaceExtraMin = 40,
            spaceExtraMax = 90,
            punctExtraMin = 120,
            punctExtraMax = 250,
            breakChance = 0.05,
            breakExtraMin = 100,
            breakExtraMax = 300,
            messageWaitMin = 10,
            messageWaitMax = 30,
            convoWaitMin = 15,
            convoWaitMax = 35,
            eraseWaitMin = 2,
            eraseWaitMax = 6,
            eraseDelayMin = 15,
            eraseDelayMax = 40,
            cursorBlink = 0.45,
            shuffleWaitMin = 20,
            shuffleWaitMax = 40,
        },
        popz = {
            ":0",
            ":7",
            "my name is gravel what's yours?????",
            "my zodiac sign is a shovel :p",
            "gravel is rocky :o",
            "graveeeeeeeelll",
            ":p",
            ">:3",
            "Gravel is not Sentient idk wat ur talking about",
            "sigmasigmaboug",
            "I'm a rng pop-up that picks random messages 24/7",
            "would dis script work on every gaem\nyh & noe",
            "this script is 10000+ lines... oml :s",
            "the UI ts using is WindUi and the notification is Alurt btw I just found it from ballmart",
            "a free?! keyless?! script?! and open source?! that has silentaim?! wtf",
            "the script is randomly picking messages your not freaking out :p",
            "sorry xeno users or solarara I don't have the supporty support",
            "nononononoonono this script ain't a virus so dat why I made it open src",
            "Is that a gubby?\n\n- kreek",
            "Error ur roblxo isn't support",
            "ooh, nice computer you got their, Can I have it\n\n- Mario virus",
            "something is coming in 3 days\n\n- verity",
            "real",
            "tuff",
            "guhby this guhby that",
            "2 atoms touch = big explosion",
            "you can noclip when your atoms aligned\ntrust",
            "I don't have DC btw",
            "my code is used to be 8000+ now 9000+ and then 14000+ lines long, I canf do dis sh on mobile D:",
            "flatgrass",
            "search free robux to get free robux",
            "alt-f4 = free rboux",
            "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.\n>\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.",
            "^_^",
            "^u^",
            "^v^",
            "half life 3 when?",
            "it's a game called HELLO NEIGHBOR -HEL -HEL -HELHEL-HELLO NE-NEIGH-BOR",
            "FORTYNIGHTY LA PABAJI\npabaji\nPABAJI LA EKES BOKES SERES EKES\npabaji\nPABAJI LA BALESTHONFAIV\nbalesteshon... faiv...\nBALESTHONFAIV LA LUKITIK\nlukitik\nLUKITTIK LA HAYBAR EKES EKES EKES EKES\nhybar ekes ekes ekes ekes\nHYBAR EKES EKES EKES EKES LA GIRANDIFIFDORIGINI\ngirandififdorigini",
            "Did you do your chores?\nyessirski!\nDid you do your chores?\nyessirski\nDid you do your chores?\nyessirski!\nDid you do your chores?\nyessirski\nWhen I get home it better be clean!\nDid you do your chores?\nyessirski!\nOH! BOI WHY DID U LIE TO ME!!!\nAHHHHH",
            "Homework?\nNah!\nHomework?\nNah!\nHomework?\nNah!\nHomework?\ni did it at school\nNah!\nHomework?\nNah!\nHomework?\nNah!\nWHY ARE YOU CLASSES PHAILING\n AHHH D:",
            "Turkey in the Straw!",
            "du bist gut genug...\ndu bist gut genug...\ndu bist gut genug\ndu bist gut genug\n*fire music*",
            "本当に出口はないのか、くる、くる、くる、くる、繰り返し、繰り返し、繰り返し…\n\n\ni ain't writing allat",
            "*Stranger Things Intro*\ndustin lucas will mike...\nBURP",
            "robloz where classic faces :‹",
            "I'm not taking my sneakers off, I'm sneakers O'Toole",
            "Gpssickle is a gps with a sickle",
            "da script reached 8000 lines to 14000 o_o",
            "just simply cheat through it\n\n quite literally",
            "just simply go under it",
            "just simply go over it",
            "just simply script to it",
            "just simply walk around it\n\n- Electracy",
            "You die\n\n- StromBrew",
            "sonion\ni learned this from meme culture don't ask me",
            "I like trains",
            "welcome to McDonald's.",
            "you are my sunshine, my only sunshine",
            "IS THAT SONIC WITH GRAY SHOES D:",
            "Atoms never touch so dat means I didn't steal ur chocolate",
            "Yeah, come gets some you freakin' wuss\n\n- Scout (not Taunt form dod)",
            "sybau 🥀💔",
            "these are meme reference ok",
            "water + ice + melt = water",
            "3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679",
            "1.61803398874989484820458683436563811772030917980576",
            "print(''*prints cutely*'')\nerror(''*errors cutely*'')\nwarn(''*warns cutely*'')",
            "Gravel.cc 🥀",
            "my imagination has been powered",
            "YOU NEVER SEE IT COMIIIIIIINNNG,\nyou'll see that my mind\nis to fast for eyes\nYOUR DONE INNNNNN\nBY THE\ntime is hit you, YOUR LAST SURPRISE",
            "Gpssssssssssssssssssssssssssssssssssssssssickle",
            "global positioning system with a sickle",
            "The golden dandelion which is the golden dandelion",
            "can u remind me the golden ratio next time",
            "y'all think he look like; Steve Harvey?\n *Screams*",
            "/kill @p",
            "HBSS doesn't mean anything lolz\ni typed it randomly...",
            "rbxm",
            "why 'Gravel' ya know how sand gets in ur shoes..\ngravel does the same but it's for games",
            "people barely use the bottab",
            "I hate renderstepped...\n(probably because I keep misusing it)",
            "is it Roblox or roadblocks or robloz who knows",
            "''Does this work in Minecraft''",
            "www.gravel.com ... why does this website exists?",
            "imagine ur script getting mogged by a script made fully on a phone",
            "dere is no Terraria final update D:",
            "da cake isnt a lie... trust",
            "iS ThAt ga hÆcker?????!?!?!!!?!???!?!",
            "y is this drooling cat meme all over my fyp D:",
            "tbh bro I'd go; [insert metalpipefalling.gif]",
            "gravel vs sand vs rock vs thingamajang",
            "GTA 6 when?",
            "if they said ur a hacker say 'Ping Diff' and they'll believe u",
            "w wedgeey 🥺\nw junglescripts 🥺",
            "sand.cc when?",
            "what version is this? well I don't fking know lol",
            "scirpotjg iz hard :(",
            "Roblox plz collabl",
            "helloworld(''print'')",
            "Markiplier & Larpiplier collab when?",
            "61? 67?\nit's time for the letters to have fun\nabcdefghijklmnop\nL-M-N-O-P\nP\nP\nP\nP",
            "hello whoever you are :D\ni don't have the capacity to see your usernames yet because I'm too lazy to script dat in\noh wait ur name is " .. lp_info.lp_displayname .. "\n cool name!",
            "me is want chat roblox not age verif",
            "this script isn't full ban proof so if you get banned DON'T blame on us when your using risky features :/",
            "deres like idk amount of random messages I contains lolz",
        },
        popz2 = {
            "wth is ts",
            "hell nah",
            "OHHHH HELLL NAH",
            "pop-up goes bye bye",
            "isn't phonk just noise?",
            "guys it's a-a, a-a h-hacker!?!?!",
            "tiki tiki",
            "Nosirski!",
            "[Eminem Throwing Meme.png]",
            "why am I writing ts?",
            "idk, sterling?",
            "is that a toby?",
            "click here or ur gay",
            "lolzer-fying",
        },
        popz3 = {
            "helohi",
            "meeeeeoow :3 .... MAW >:3",
            "Bang, Bang, Bang",
            "20-20-20 Gugu Gaga dropkick",
            "portal above portal below *jumps in*",
            "Gugu Gaga Ultimated Flex Works",
            "can gravel run doom?",
            "ipad kid vs ipad, who would win?",
            "ifone 90 proe max",
            "image me missing one ',' on a large table..",
            "Gravel supports Android 5-",
            "your bluetooth device is ready to pair",
            "why is there ai slop on my TikTok fyp....",
            ":3 >:3 ›:3 :3",
        },
        tinf = {
            "bombastic side eye",
            "oh shiddings nott gud D:",
            "67 vs 67",
            "what's yer zodiac sign",
            "hi I'm a rng",
            "what's a brainfuck :s",
            "Gravel.cc says be gravel",
            "tag ur it",
            "shimmy ey shimmy yaaa",
            "so many references :o",
            "me wants grabel :(",
            "life never made lemons...",
            "01001000 01101001",
            "whoz dat",
            "roblox is no longer robloz",
            "user :3",
            "water",
            "GRAVEL-MAN",
            "IM SKYLER WHITE, YO",
            "my diet is gravel",
            "6761694203602048",
            "ur definitely using delta cuz idk",
            "dab me up :>",
            "how much saves do u has",
            "O rly",
            ":3",
            "lololololooloo",
        },
        tinf2 = {
            "rbxassetid://128670966889578",
            "rbxassetid://132214308111067",
            "rbxassetid://72509803293342",
            "rbxassetid://130435138559679",
            "rbxassetid://127155823074936",
            "rbxassetid://126485931781624",
        },
        tinf3 = {
    	    "rbxassetid://72298953503422",
    	    "rbxassetid://17608357332",
           "rbxassetid://130776885039264",
           "rbxassetid://6303045144",
           "rbxassetid://101513669346450",
           "rbxassetid://17748195478",
           "rbxassetid://17517499979",
           "rbxassetid://119888856502065",
        },
        descs = {
            Main = {
                "y u touching my brain",
                "brain goes brrr",
                "main stuffz",
                "da core settings",
                "trust me i know what im doing",
                "settings go here!",
                "don't touch unless you know what ur doing",
                "gravels shovel",
                "the real tab",
                "where da magic happens",
                "hehe settings go brr",
                "u have no idea what ur doing",
                "baaa",
                "it's big brain time.",
                "pls be careful D:",
                "yolo toggle it all",
                "main main main main",
                "core settings 4 core ppl",
                "don't blame me if u break stuff",
                "folk",
                "read da text vro :1",
            },
            Visuals = {
                "4 the blind ppl",
                "oooh shiny",
                "make game look cool",
                "ESP go brrrrrr",
                "seeing ppl through walls :o",
                "visuals for da win",
                "colorful stuff",
                "vision 1+",
                "walls are just suggestion",
                "make em glow",
                "I can see china from here!1!",
                "see everything",
                "game looks different now",
                "seekify",
                "your eyes will thank u",
                "wallhack energy",
                "highlight da enemies",
                "rainbow vibes",
                "visibility is key",
                "what walls?",
                "xray vision activated",
                "visuals go crazy"
            },
            AntiAim = {
                "I suck at dodging tab",
                "dodge master 3000",
                "u cant hit me >:3",
                "evasion tactics",
                "why can't I hit u",
                "they cant touch this",
                "pew = miss",
                "anti-getting-shot",
                "hit me if u can",
                "can't touch this",
                "matrix mode",
                "teleports behind u",
                "nothing personnel kid",
                "dodgeball champion",
                "good luck hitting me",
                "disappear",
                "now u see me, now u dont",
                "trust im legit dodging",
            },
            Aimbot = {
                "aimware-ing",
                "lock on target",
                "no mouse movement aim tab",
                "i legit never miss",
                "accuracy 1+",
                "headshot da kidz",
                "gaming chair mode",
                "crosshair magnet",
                "technically aim assist",
                "aimlabs? never heard of her",
                "perfect aim every time",
                "aim at thing",
                "precision inc",
                "never miss u again",
                "ur aim is insane",
                "holeh aimbot",
                "aimbot go crazy"
            },
            ["SilentAim (HB)"] = {
                "hitbox x aimbot x silentaim x bullet tracker",
                "Hitbox cousin",
                "SilentAim & Hitbox made a baby",
                "ssshhh its a secret",
                "unaim-ful",
                "where are you aiming at??",
                "secret sauce"
            },
            ["SilentAim (HK)"] = {
                "I'm the better option sonionster",
                "hook-based baby",
                "the true silent aim",
                "raycast torture",
                "the better silentsilentaim",
                "raycast go brrr",
                "uncatchable",
                "legit looking I think..",
                "aimbot 2.0",
                "aim-ster",
            },
            Hitbox = {
                "it's hitbox not HURTBOX D:<",
                "size matters",
                "make em bigger",
                "expansion pack",
                "hitbox go chud mode",
                "bigger is better",
                "easy mode",
                "bro what's that hitbox",
                "sizely",
                "bigger hitbox bigger fun",
                "they cant dodge",
                "hurtbox",
                "making targets fatter",
                "hurt big box",
                "big blob",
            },
            Reach = {
                "1+1= √4",
                "long arms",
                "stretchy arms",
                "extendo reach",
                "touch things far away",
                "long distance relationship",
                "can i touch u from here :3",
                "extendo mode",
                "range extender",
                "COME TO BRAZIL",
                "touchy touchy",
                "stretch armstrong",
                "big reach modeldh",
                "reach around",
                "long arms gng🥀",
                "kill aura for sowrds"
            },
            Client = {
                "I don't hold the serverside blud",
                "GOTTA GO FAST",
                "I'm in a sugar rush",
                "due to my gaming chair",
                "client the client of client",
            },
            Miscellaneous = {
                "random bs go!!!🔥🔥🔥🔥",
                "the leftovers",
                "extra stuff",
                "bruh stuff",
                "random stuff my brain made",
                "the rest of em",
                "thingamabob",
                "experimental features",
                "za-silly",
                "wha",
                "hidden gems",
                "ragebait here",
                "randomness",
                "kiss me misc :3",
                "extra goodies",
            },
            Info = {
                "show me da papperz",
                "the knowledge",
                "read me.txt",
                "info-man",
                "VRO HELP ME OUT",
                "what is this",
                "guide time",
                "ENLIGHTEN ME",
                "*monkeg vs lion meme*",
                "i can't understand ts 🥀😔",
                "credits and stuff",
                "dictionary",
                "how to use roadblocked",
                "info urself",
                "wtf is this script",
                "SPY???"
            }
        },
        easterTitles = {
            "Gravel.egg",
            "gravel.easteeeeerrr",
            "Gravel.eggcellent",
            "Gravel.ILikeEgg",
            "hunting 4 da gravel",
            "easter shovel",
        },
        defaultTitles = {
            "Gravel.cc", -- ts is da actual default 1 btw
            "G.cc", -- ts is also how u say gravel
            "HBSS.cc", -- again also gravel
            "Gravel-est",
            "Gravel-er",
            "Graaaavel.cc",
            "Gravelly.cc",
            "Gravel.com",
            "Hi! I'm Gravel.cc",
            "Gravel enjoyer",
            "GRAVEL.CC >:D",
            "holy gravel.cc",
            "GravelGravelGravel.cc",
            "I like gravel",
            "Gravel.cheatcheat",
            "Gravel.yes",
            "Gravel.no",
            "Gravel.lua", -- ts one makes sense
            "GRAVEL GRAVEL.CC",
        },
        aprilFools = { 
            -- BRO WHAT ARE U LOOKING AT DONT SPOIL THE APRIL FOOLS JOKE D:<
            "Sand.cc",
            "Aimware",
            "Neverlose",
            "RIBLOX MOD MENU 🔥🔥🔥",
            "u got pranked",
            "Gravel is sand",
            "not gravel",
            "Dirt.cc",
            "Flour.cc",
            "Brick.cc 2.0",
            "I'm quitting (I think....)",
            "CrushedStone.cc",
            "cc.levarG",
            "grvel",
            "Enrique.cc",
            "Adrian.cc",
        },
        savesParagraph = nil,
        wasEnabledBeforeDeath = false,
        wasESPEnabledBeforeDeath = false,
        respawnLock = false,
        aimbot360LoopRunning = false,
        aimbot360LoopTask = nil,
        lastTargetUpdate = 0,
        triggerBotConnection = nil,
        sa2thing = 0,
        sa2stuff = 0.5,
        spinbotConnection = nil,
        ViewConnection = nil,
        CameraDistance = 8,
        lowpatcherwait = 0.03,
        lowpatcher = true,
        patcherwait = 0.5,
        patcher = true,
        bhopQuickToggleUI = nil,
        lastJumpTime = 0,
        errors = true,
        Rng5stuff = nil,
        Rng3dis = {},
        orgfov = nil,
    },
    Gradow = {
        textcursor = "_",
        textcursor2 = "  ",
        uianimate = {
            connection = nil,
            basePosition = nil,
            lastPosition = Vector3.new(0, 0, 0),
            movementOffset = 0,
            smoothOffset = 0,
            pulseSpeed = 0.02,
            minThickness = 0.80,
            maxThickness = 2,
            targetRotation = 0,
            currentRotation = 0,
            windowTargetRotation = 0,
            windowCurrentRotation = 0,
            windowInitialThickness = nil,
            openButton = nil,
            windowFrame = nil,
            openStroke = nil,
            openGradient = nil,
            windowStroke = nil,
            windowGradient = nil
        },
        uiThemeSave = {
            Folder = "Gravel_Saves/assets",
            FileName = "SavedUI.json",
            CurrentTheme = "Dark",
            CurrentTransparency = 0.15,
        },
        uicolor = {
            lightGreen = Color3.fromRGB(144, 238, 144),
            darkGray = Color3.fromRGB(40, 40, 40),
            lightGray = Color3.fromRGB(200, 200, 200),
            Red = Color3.fromRGB(255, 0, 0),
            Blue = Color3.fromRGB(175, 221, 255),
            Black = Color3.fromRGB(0, 0, 0)
        },
        windowSize = {
            mobile = UDim2.fromOffset(650, 79),
            tablet = UDim2.fromOffset(600, 80),
            pc = UDim2.fromOffset(800, 70)
        }
    }
}
local lezzzgoo = config.varibz.btntitle[math.random(1, #config.varibz.btntitle)]
local function rng5()
    if config.varibz.Rng5stuff then return config.varibz.Rng5stuff end
    local currentDate = os.date("%m %d")
    local currentYear = tonumber(os.date("%Y"))
    local festiveTitles = {
        ["01 01"] = {
            "New Gravel.cc :>",
            "Happy new year!1!1!11",
            "A new year, a same Gravel.cc",
            "welcome 2 a new year buddy",
            "I haven't showered since last year- ok this one is overrated",
            "year of da shovel",
        },
        ["02 14"] = {
            "Gravel.<3",
            "will u be my gravel",
            "gravel iz love",
            "be my gravel",
        },
        ["03 17"] = {
            "Gravel.luck",
            "lucky gravel",
            "good luck or smth",
            "lucky shovel",
        },
        ["10 31"] = {
            "Gravel.cc :Q",
            "Gravel.cc :F",
            "gravel go boo",
            "BOO (I definitely scared u)",
            "trick or gravel",
            "da haunted gravel",
        },
        ["12 25"] = {
            "merry gravelmas",
            "gravel gifts for all",
            "Gravel.Feliz Navidad!",
            "gravel under da tree",
        },
    }
    local function getEasterDate(year)
        local A = math.floor(year/100)
        local B = math.floor((13+8*A)/25)
        local C = (15-B+A-math.floor(A/4))%30
        local D = (4+A-math.floor(A/4))%7
        local E = (19*(year%19)+C)%30
        local F = (2*(year%4)+4*(year%7)+6*E+D)%7
        local G = (22+E+F)
        if E == 29 and F == 6 then
            config.varibz.Rng5stuff = "04 19"
            return config.varibz.Rng5stuff
        elseif E == 28 and F == 6 then
            config.varibz.Rng5stuff = "04 18"
            return config.varibz.Rng5stuff
        elseif 31 < G then
            config.varibz.Rng5stuff = ("04 %02d"):format(G-31)
            return config.varibz.Rng5stuff
        end
        config.varibz.Rng5stuff = ("03 %02d"):format(G)
        return config.varibz.Rng5stuff
    end
    local easterDate = getEasterDate(currentYear)
    if currentDate == easterDate then
        config.varibz.Rng5stuff = config.varibz.easterTitles[math.random(1, #config.varibz.easterTitles)]
        return config.varibz.Rng5stuff
    end
    for datePattern, titles in pairs(festiveTitles) do
        if currentDate == datePattern then
            config.varibz.Rng5stuff = titles[math.random(1, #titles)]
            return config.varibz.Rng5stuff
        end
    end
    if currentDate == "04 01" then
        config.varibz.Rng5stuff = config.varibz.aprilFools[math.random(1, #config.varibz.aprilFools)]
        return config.varibz.Rng5stuff
    end
    config.varibz.Rng5stuff = config.varibz.defaultTitles[math.random(1, #config.varibz.defaultTitles)]
    return config.varibz.Rng5stuff
end

local function rng3(tabName)
    if config.varibz.Rng3dis[tabName] then return config.varibz.Rng3dis[tabName] end
    local tabDescs = config.varibz.descs[tabName]
    if tabDescs and #tabDescs > 0 then
        config.varibz.Rng3dis[tabName] = tabDescs[math.random(1, #tabDescs)]
        return config.varibz.Rng3dis[tabName]
    end
    config.varibz.Rng3dis[tabName] = "description missing D:"
    return config.varibz.Rng3dis[tabName]
end
function uianijsyevxusuuwkaoxidhehhwiaosldjbnmate()
    task.wait(0.1)
    config.Gradow.uianimate.openButton = Window.OpenButtonMain and Window.OpenButtonMain.Button
    if not config.Gradow.uianimate.openButton then return end
    config.Gradow.uianimate.windowFrame = Window.UIElements.Main
    if not config.Gradow.uianimate.windowFrame then return end
    
    config.Gradow.uianimate.openStroke = nil
    config.Gradow.uianimate.openGradient = nil
    for _, descendant in ipairs(config.Gradow.uianimate.openButton:GetDescendants()) do
        if descendant:IsA("UIStroke") then
            config.Gradow.uianimate.openStroke = descendant
        elseif descendant:IsA("UIGradient") then
            config.Gradow.uianimate.openGradient = descendant
        end
    end
    
    if not config.Gradow.uianimate.openStroke then return end
    
    config.Gradow.uianimate.windowStroke = nil
    config.Gradow.uianimate.windowGradient = nil
    for _, descendant in ipairs(config.Gradow.uianimate.windowFrame:GetDescendants()) do
        if descendant:IsA("UIStroke") then
            config.Gradow.uianimate.windowStroke = descendant
            for _, grad in ipairs(descendant:GetDescendants()) do
                if grad:IsA("UIGradient") then
                    config.Gradow.uianimate.windowGradient = grad
                    break
                end
            end
            break
        end
    end
    
    if not config.Gradow.uianimate.windowStroke then
        config.Gradow.uianimate.windowStroke = Instance.new("UIStroke")
        config.Gradow.uianimate.windowStroke.Thickness = 2
        config.Gradow.uianimate.windowStroke.Color = Color3.fromRGB(255, 255, 255)
        config.Gradow.uianimate.windowStroke.Transparency = 0.5
        config.Gradow.uianimate.windowStroke.LineJoinMode = Enum.LineJoinMode.Round
        config.Gradow.uianimate.windowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        config.Gradow.uianimate.windowStroke.Parent = config.Gradow.uianimate.windowFrame
        config.Gradow.uianimate.windowGradient = Instance.new("UIGradient")
        config.Gradow.uianimate.windowGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(144, 238, 144)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 200, 200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40))
        })
        config.Gradow.uianimate.windowGradient.Parent = config.Gradow.uianimate.windowStroke
    end
    
    if not config.Gradow.uianimate.windowGradient then
        config.Gradow.uianimate.windowGradient = Instance.new("UIGradient")
        config.Gradow.uianimate.windowGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(144, 238, 144)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 200, 200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40))
        })
        config.Gradow.uianimate.windowGradient.Parent = config.Gradow.uianimate.windowStroke
    end
    
    config.Gradow.uianimate.windowStroke.Thickness = config.Gradow.uianimate.openStroke.Thickness
    config.Gradow.uianimate.windowStroke.Transparency = config.Gradow.uianimate.openStroke.Transparency
    
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local character = lp.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local buttonFrame = config.Gradow.uianimate.openButton
    config.Gradow.uianimate.basePosition = buttonFrame.Position
    config.Gradow.uianimate.lastPosition = Vector3.new(0, 0, 0)
    config.Gradow.uianimate.movementOffset = 0
    config.Gradow.uianimate.smoothOffset = 0
    config.Gradow.uianimate.pulseSpeed = 0.02
    config.Gradow.uianimate.minThickness = 0.80
    config.Gradow.uianimate.maxThickness = 2
    config.Gradow.uianimate.targetRotation = 0
    config.Gradow.uianimate.currentRotation = 0
    config.Gradow.uianimate.windowTargetRotation = 0
    config.Gradow.uianimate.windowCurrentRotation = 0
    config.Gradow.uianimate.windowInitialThickness = config.Gradow.uianimate.windowStroke.Thickness
    
    local function getNearestEnemy()
        local nearest = nil
        local nearestDist = 677
        local lpos = character and character:FindFirstChild("HumanoidRootPart")
        if not lpos then return nil end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= lp and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - lpos.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = root
                    end
                end
            end
        end
        return nearest
    end

    if config.Gradow.uianimate.connection then
        config.Gradow.uianimate.connection:Disconnect()
    end
    
    config.Gradow.uianimate.connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not config.Gradow.uianimate.openStroke or not config.Gradow.uianimate.openStroke.Parent then
            if config.Gradow.uianimate.connection then config.Gradow.uianimate.connection:Disconnect() end
            return
        end
        if config.Gradow.uianimate.windowStroke and config.Gradow.uianimate.windowStroke.Parent then
            config.Gradow.uianimate.windowStroke.Thickness = config.Gradow.uianimate.openStroke.Thickness
            config.Gradow.uianimate.windowStroke.Transparency = config.Gradow.uianimate.openStroke.Transparency
        end
        
        character = lp.Character
        humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if character and humanoid then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local currentPos = rootPart.Position
                local velocity = rootPart.Velocity
                local moveSpeed = velocity.Magnitude
                local targetOffset = math.min(moveSpeed / 50, 8)
                config.Gradow.uianimate.smoothOffset = config.Gradow.uianimate.smoothOffset + (targetOffset - config.Gradow.uianimate.smoothOffset) * 0.1
                local moveX = -velocity.X * 0.02
                local moveY = -velocity.Y * 0.02
                local moveZ = -velocity.Z * 0.02
                local maxOffset = 6
                moveX = math.clamp(moveX, -maxOffset, maxOffset)
                moveY = math.clamp(moveY, -maxOffset, maxOffset)
                moveZ = math.clamp(moveZ, -maxOffset, maxOffset)
                local newPos = UDim2.new(
                    config.Gradow.uianimate.basePosition.X.Scale,
                    config.Gradow.uianimate.basePosition.X.Offset + moveX,
                    config.Gradow.uianimate.basePosition.Y.Scale,
                    config.Gradow.uianimate.basePosition.Y.Offset + moveY + config.Gradow.uianimate.smoothOffset * 0.3
                )
                buttonFrame.Position = newPos
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local healthFactor = 1 - healthPercent
                local baseSpeed = 0.5
                local minSpeed = 0.15
                local maxSpeed = 0.8
                config.Gradow.uianimate.pulseSpeed = maxSpeed - (healthFactor * (maxSpeed - minSpeed))
                local thicknessRange = config.Gradow.uianimate.maxThickness - config.Gradow.uianimate.minThickness
                local enemy = getNearestEnemy()
                if enemy and config.Gradow.uianimate.openGradient then
                    local enemyPos = enemy.Position
                    local rootPos = rootPart.Position
                    local direction = (enemyPos - rootPos).Unit
                    local angle = math.deg(math.atan2(direction.Z, direction.X))
                    config.Gradow.uianimate.targetRotation = angle
                end
                local rotDiff = (config.Gradow.uianimate.targetRotation - config.Gradow.uianimate.currentRotation) % 360
                if rotDiff > 180 then rotDiff = rotDiff - 360 end
                config.Gradow.uianimate.currentRotation = config.Gradow.uianimate.currentRotation + rotDiff * 0.05
                
                if config.Gradow.uianimate.openGradient then
                    config.Gradow.uianimate.openGradient.Rotation = config.Gradow.uianimate.currentRotation
                end
                
                if config.Gradow.uianimate.windowGradient then
                    local windowRotDiff = (config.Gradow.uianimate.targetRotation - config.Gradow.uianimate.windowCurrentRotation) % 360
                    if windowRotDiff > 180 then windowRotDiff = windowRotDiff - 360 end
                    config.Gradow.uianimate.windowCurrentRotation = config.Gradow.uianimate.windowCurrentRotation + windowRotDiff * 0.025
                    config.Gradow.uianimate.windowGradient.Rotation = config.Gradow.uianimate.windowCurrentRotation
                end
            end
        end
        
        local currentTime = tick()
        local pulseValue = (math.sin(currentTime * (1 / config.Gradow.uianimate.pulseSpeed) * math.pi * 2) + 1) / 2
        local thicknessRange = config.Gradow.uianimate.maxThickness - config.Gradow.uianimate.minThickness
        local currentThickness = config.Gradow.uianimate.minThickness + (pulseValue * thicknessRange)
        if config.Gradow.uianimate.openStroke then
            config.Gradow.uianimate.openStroke.Thickness = currentThickness
            local pulseTransparency = 0.1 + (pulseValue * 0.3)
            config.Gradow.uianimate.openStroke.Transparency = pulseTransparency
        end
        
        if config.Gradow.uianimate.windowStroke then
            local windowPulseValue = (math.sin(currentTime * (1 / (config.Gradow.uianimate.pulseSpeed * 0.9)) * math.pi * 2) + 1) / 2
            local windowThickness = config.Gradow.uianimate.minThickness + (windowPulseValue * thicknessRange)
            config.Gradow.uianimate.windowStroke.Thickness = windowThickness
            local windowTransparency = 0.1 + (windowPulseValue * 0.3)
            config.Gradow.uianimate.windowStroke.Transparency = windowTransparency
        end
    end)
    
    task.wait(0.1)
    if not config.Gradow.uianimate.connection or not config.Gradow.uianimate.connection.Connected then
        lo2l()
    end
end

local function getSavePath(saveName)
    return getgenv().blablablahblahblahhblahblahhGraaaaaaaaaaaaaaaaaaaaaaavel.Folder .. "/" .. saveName .. getgenv().blablablahblahblahhblahblahhGraaaaaaaaaaaaaaaaaaaaaaavel.Extension
end

local function getSaveList()
    local saves = {}
    if not isfolder(getgenv().blablablahblahblahhblahblahhGraaaaaaaaaaaaaaaaaaaaaaavel.Folder) then
        return saves
    end
    
    for _, file in ipairs(listfiles(getgenv().blablablahblahblahhblahblahhGraaaaaaaaaaaaaaaaaaaaaaavel.Folder)) do
        local fileName = file:match("([^/]+)" .. getgenv().blablablahblahblahhblahblahhGraaaaaaaaaaaaaaaaaaaaaaavel.Extension .. "$")
        if fileName then
            table.insert(saves, fileName)
        end
    end
    return saves
end

local function loadSaveData(saveName)
    local path = getSavePath(saveName)
    if not isfile(path) then
        return nil
    end
    
    local success, data = pcall(function()
        return readfile(path)
    end)
    
    if not success or not data then
        return nil
    end
    
    local success, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(data)
    end)
    
    return success and decoded or nil
end

local function saveConfig(saveName)
    if not saveName or saveName == "" then
        WindUI:Notify({
            Title = "Save System",
            Content = "Please enter a save name!",
            Icon = "x",
            Duration = 2
        })
        return false
    end
    
    local configToSave = {
        version = "2.0",
        timestamp = os.time(),
        config = {
            masterTeamTarget = config.masterTeamTarget,
            masterTarget = config.masterTarget,
            masterGetTarget = config.masterGetTarget,
            targetSeenSwitchRate = config.targetSeenSwitchRate,
            targetSeenMode = config.targetSeenMode,
            ignoreForcefield = config.ignoreForcefield,
            autoFarmEnabled = config.autoFarmEnabled,
            autoFarmWallCheck = config.autoFarmWallCheck,
            autoFarmDistance = config.autoFarmDistance,
            autoFarmMaxRange = config.autoFarmMaxRange,
            autoFarmVerticalOffset = config.autoFarmVerticalOffset,
            autoFarmTargetPart = config.autoFarmTargetPart,
            autoFarmMinRange = config.autoFarmMinRange,
            gp = config.gp,
            gp2 = config.gp2,
            QuickToggles = config.QuickToggles,
            QTDrag = config.QTDrag,
            espMasterEnabled = config.espMasterEnabled,
            prefHighlightESP = config.prefHighlightESP,
            prefTextESP = config.prefTextESP,
            prefBoxESP = config.prefBoxESP,
            prefHealthESP = config.prefHealthESP,
            prefHeadDotESP = config.prefHeadDotESP,
            lineESPEnabled = config.lineESPEnabled,
            lineESPOnlyTarget = config.lineESPOnlyTarget,
            lineStartPosition = config.lineStartPosition,
            prefColorByHealth = config.prefColorByHealth,
            espc = {
                R = config.espc.R,
                G = config.espc.G,
                B = config.espc.B
            },
            esptargetc = {
                R = config.esptargetc.R,
                G = config.esptargetc.G,
                B = config.esptargetc.B
            },
            espteamc = {
                R = config.espteamc.R,
                G = config.espteamc.G,
                B = config.espteamc.B
            },
            lineColor = {
                R = config.lineColor.R,
                G = config.lineColor.G,
                B = config.lineColor.B
            },
            fbenabled = config.fbenabled,
            fovc = {
                R = config.fovc.R,
                G = config.fovc.G,
                B = config.fovc.B
            },
            fovct = {
                R = config.fovct.R,
                G = config.fovct.G,
                B = config.fovct.B
            },
            SA2_FovColor = {
                R = config.SA2_FovColor.R,
                G = config.SA2_FovColor.G,
                B = config.SA2_FovColor.B
            },
            SA2_FovColourTarget = {
                R = config.SA2_FovColourTarget.R,
                G = config.SA2_FovColourTarget.G,
                B = config.SA2_FovColourTarget.B
            },
            SA2_FovTransparency = config.SA2_FovTransparency,
            tbot_fovColor = {
                R = config.tbot.fovColor.R,
                G = config.tbot.fovColor.G,
                B = config.tbot.fovColor.B
            },
            hitboxColor = {
                R = config.hitboxColor.R,
                G = config.hitboxColor.G,
                B = config.hitboxColor.B
            },
            visualizer_color = {
                R = config.visualizer.color.R,
                G = config.visualizer.color.G,
                B = config.visualizer.color.B
            },
            LowRender = config.LowRender,
            antiAimEnabled = config.antiAimEnabled,
            raycastAntiAim = config.raycastAntiAim,
            antiAimAbovePlayer = config.antiAimAbovePlayer,
            antiAimBehindPlayer = config.antiAimBehindPlayer,
            antiAimOrbitEnabled = config.antiAimOrbitEnabled,
            antiAimTPDistance = config.antiAimTPDistance,
            antiAimAboveHeight = config.antiAimAboveHeight,
            antiAimBehindDistance = config.antiAimBehindDistance,
            antiAimOrbitSpeed = config.antiAimOrbitSpeed,
            antiAimOrbitRadius = config.antiAimOrbitRadius,
            antiAimOrbitHeight = config.antiAimOrbitHeight,
            antiAimGetTarget = config.antiAimGetTarget,
            spinbot_enabled = config.spinbot.enabled,
            spinbot_speed = config.spinbot.speed,
            aimbotEnabled = config.aimbotEnabled,
            aimbotWallCheck = config.aimbotWallCheck,
            aimbot360Enabled = config.aimbot360Enabled,
            aimbotTargetPart = config.aimbotTargetPart,
            aimbotStrength = config.aimbotStrength,
            aimbotFOVSize = config.aimbotFOVSize,
            aimbotGetTarget = config.aimbotGetTarget,
            aimbotTeamTarget = config.aimbotTeamTarget,
            startsa = config.startsa,
            wallc = config.wallc,
            scaleToScreen = config.scaleToScreen,
            stsdistance = config.stsdistance,
            bodypart = config.bodypart,
            hitchance = config.hitchance,
            fovsize = config.fovsize,
            hbtrans = config.hbtrans,
            silentGetTarget = config.silentGetTarget,
            SA2_Enabled = config.SA2_Enabled,
            SA2_Wallcheck = config.SA2_Wallcheck,
            SA2_Wallbang = config.SA2_Wallbang,
            SA2_ThreeSixtyMode = config.SA2_ThreeSixtyMode,
            SA2_Method = config.SA2_Method,
            SA2_TargetPart = config.SA2_TargetPart,
            SA2_HitChance = config.SA2_HitChance,
            SA2_FovRadius = config.SA2_FovRadius,
            SA2_TargetRange = config.SA2_TargetRange,
            SA2_TeamTarget = config.SA2_TeamTarget,
            SA2_GetTarget = config.SA2_GetTarget,
            sa2stuff = config.varibz.sa2stuff,
            hitboxEnabled = config.hitboxEnabled,
            hitboxTeamTarget = config.hitboxTeamTarget,
            hitboxSize = config.hitboxSize,
            reach_enabled = config.reach.enabled,
            reach_type = config.reach.type,
            reach_distance = config.reach.distance,
            visualizer_enabled = config.visualizer.enabled,
            visualizer_material = config.visualizer.material,
            visualizer_transparency = config.visualizer.transparency,
            reach_autoSwing = config.reach.autoSwing.enabled,
            reach_autoSwing_delay = config.reach.autoSwing.delay,
            clientMasterEnabled = config.clientMasterEnabled,
            clientNoclipEnabled = config.clientNoclipEnabled,
            clientWalkEnabled = config.clientWalkEnabled,
            clientJumpEnabled = config.clientJumpEnabled,
            clientCFrameWalkToggle = config.clientCFrameWalkToggle,
            clientWalkSpeed = config.clientWalkSpeed,
            clientJumpPower = config.clientJumpPower,
            clientCFrameSpeed = config.clientCFrameSpeed,
            trussEnabled = config.trussEnabled,
            airwalkEnabled = config.airwalkEnabled,
            autorespawnEnabled = config.autorespawnEnabled,
            fastspawn = config.fastspawn,
            tbot_enabled = config.tbot.enabled,
            tbot_targetPart = config.tbot.targetPart,
            tbot_fovRadius = config.tbot.fovRadius,
            tbot_hitChance = config.tbot.hitChance,
            tbot_delay = config.tbot.delay,
            tbot_wallCheck = config.tbot.wallCheck,
            tbot_holdToShoot = config.tbot.holdToShoot,
            tbot_holdKey = config.tbot.holdKey,
            tbot_fovTransparency = config.tbot.fovTransparency,
            tbot_fovVisible = config.tbot.fovVisible,
            bhop_enabled = config.bhop.enabled,
            bhop_jumpDelay = config.bhop.jumpDelay,
            bhop_quickToggleEnabled = config.bhop.quickToggleEnabled,
            bhop_quickToggleDraggable = config.bhop.quickToggleDraggable,
            antiafk = config.antiafk,
            Viewing = config.Viewing,
            camYOffsetEnabled = config.camYOffsetEnabled,
            camYOffsetValue = config.camYOffsetValue,
            Keybinds = config.Keybinds,
            KeybindsEnabled = config.KeybindsEnabled,
            HoldKeysEnabled = config.HoldKeysEnabled,
            HoldKeybind = config.Keybinds.HoldKeybind,
            varibz_CameraDistance = config.varibz.CameraDistance,
            customFOVEnabled = config.customFOVEnabled,
            customFOVValue = config.customFOVValue,
            Gradow_textcursor = config.Gradow.textcursor,
            Gradow_textcursor2 = config.Gradow.textcursor2,
            varibz_patcherwait = config.varibz.patcherwait,
            varibz_lowpatcherwait = config.varibz.lowpatcherwait,
            varibz_patcher = config.varibz.patcher,
            varibz_lowpatcher = config.varibz.lowpatcher,
        }
    }
    
    local success, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(configToSave)
    end)
    
    if not success then
        WindUI:Notify({
            Title = "Save System",
            Content = "Failed to encode save data!",
            Icon = "x",
            Duration = 2
        })
        return false
    end
    
    if not isfolder(getgenv().blablablahblahblahhblahblahhGraaaaaaaaaaaaaaaaaaaaaaavel.Folder) then
        pcall(function() makefolder(getgenv().blablablahblahblahhblahblahhGraaaaaaaaaaaaaaaaaaaaaaavel.Folder) end)
    end
    
    local path = getSavePath(saveName)
    local success, err = pcall(function()
        writefile(path, encoded)
    end)
    
    if success then
        WindUI:Notify({
            Title = "Save System",
            Content = "Saved '" .. saveName .. "' successfully!",
            Icon = "check",
            Duration = 2
        })
        return true
    else
        WindUI:Notify({
            Title = "Save System",
            Content = "Failed to save: " .. tostring(err),
            Icon = "x",
            Duration = 2
        })
        return false
    end
end

local function deleteSave(saveName)
    if not saveName or saveName == "" then
        WindUI:Notify({
            Title = "Save System",
            Content = "Please enter a save name to delete!",
            Icon = "x",
            Duration = 2
        })
        return false
    end
    
    local path = getSavePath(saveName)
    if not isfile(path) then
        WindUI:Notify({
            Title = "Save System",
            Content = "Save '" .. saveName .. "' not found!",
            Icon = "x",
            Duration = 2
        })
        return false
    end
    
    local success, err = pcall(function()
        delfile(path)
    end)
    
    if success then
        WindUI:Notify({
            Title = "Save System",
            Content = "Deleted '" .. saveName .. "' successfully!",
            Icon = "check",
            Duration = 2
        })
        return true
    else
        WindUI:Notify({
            Title = "Save System",
            Content = "Failed to delete: " .. tostring(err),
            Icon = "x",
            Duration = 2
        })
        return false
    end
end

local function deleteAllSaves()
    local saves = getSaveList()
    if #saves == 0 then
        WindUI:Notify({
            Title = "Save System",
            Content = "No saves found to delete!",
            Icon = "x",
            Duration = 2
        })
        return false
    end
    
    local confirmCount = 0
    local maxConfirmations = 3
    local memeTitles = {
        "u sure bout dat??",
        "fr fr?",
        "ARE U RLY SUPER DUPER SURE???",
        "YOU ON GOD WHILE ON GOD???",
        "THINK ABOUT THE SAVES FAMILY",
        "SURE SURELY SUREY??",
        "YOU 1E60 SURE???",
    }
    
    local yesVariants = {
        "Yes",
        "Yeah",
        "Yessir",
        "YESSIRSKI!",
        "YAA",
        "HELL YA",
        "KILL ALL THE SAVES!!",
        "IM FR",
        "IM SUPER SURE",
        "IM SO SURE THAT IM SURE!!",
        "SAVES GO TO HELL!!",
    }
    
    local noVariants = {
        "Nah",
        "Pass",
        "HECK NAH",
        "WHAT RUE DOING USER???",
        "NOOO",
        "OH NOES",
        "DENIAL",
        "NO I LIKE MAH SAVES",
    }
    
    local function getRandomMemeTitle()
        return memeTitles[math.random(1, #memeTitles)]
    end
    
    local function getRandomYes()
        return yesVariants[math.random(1, #yesVariants)]
    end
    
    local function getRandomNo()
        return noVariants[math.random(1, #noVariants)]
    end
    
    local function showConfirmation()
        local currentTitle = getRandomMemeTitle()
        local currentYes = getRandomYes()
        local currentNo = getRandomNo()
        
        WindUI:Popup({
            Title = currentTitle,
            Icon = "trash",
            Content = string.format(
                "This will permanently delete ALL %d save files!\n\n" ..
                "This action cannot be undone.\n\n" ..
                "Confirmation %d/%d - Click '" .. currentYes .. "' to proceed",
                #saves,
                confirmCount + 1,
                maxConfirmations
            ),
            Buttons = {
                {
                    Title = currentYes,
                    Icon = "check",
                    Variant = "Danger",
                    Callback = function()
                        confirmCount = confirmCount + 1
                        
                        if confirmCount >= maxConfirmations then
                            local deletedCount = 0
                            local failedSaves = {}
                            
                            for _, save in ipairs(saves) do
                                local success = deleteSave(save)
                                if success then
                                    deletedCount = deletedCount + 1
                                else
                                    table.insert(failedSaves, save)
                                end
                            end
                            
                            if deletedCount > 0 then
                                WindUI:Notify({
                                    Title = "Save System :c",
                                    Content = string.format(
                                        "Deleted %d/%d saves successfully!",
                                        deletedCount,
                                        #saves
                                    ),
                                    Icon = "check",
                                    Duration = 3
                                })
                            end
                            
                            if #failedSaves > 0 then
                                WindUI:Notify({
                                    Title = "Save System",
                                    Content = "Failed to delete: " .. table.concat(failedSaves, ", "),
                                    Icon = "x",
                                    Duration = 3
                                })
                            end
                            
                            getgenv().blablablahblahblahhblahblahhGraaaaaaaaaaaaaaaaaaaaaaavel.CurrentSave = nil
                            confirmCount = 0
                        else
                            showConfirmation()
                        end
                    end
                },
                {
                    Title = currentNo,
                    Icon = "x",
                    Variant = "Secondary",
                    Callback = function()
                        confirmCount = 0
                        WindUI:Notify({
                            Title = "Save System",
                            Content = "ofc u picked no XD",
                            Icon = "info",
                            Duration = 2
                        })
                    end
                }
            }
        })
    end
    
    showConfirmation()
    return true
end

local function applyFeatureAfterLoad(featureName, state, ...)
    local args = {...}
    pcall(function()
        if featureName == "espMaster" then
            applyESPMaster(state)
        elseif featureName == "hitbox" then
            if state then
                applyhb()
            else
                for player, _ in pairs(config.hitboxExpandedParts) do
                    restoreTorso(player)
                end
                config.hitboxExpandedParts = {}
            end
        elseif featureName == "autoFarm" then
            if state then
                autoFarmProcess()
            else
                stopAutoFarm()
            end
        elseif featureName == "aimbot" then
            handleAimbotToggle(state)
        elseif featureName == "silentAim" then
            config.startsa = state
            if gui.RingHolder then
                gui.RingHolder.Visible = state
            end
            if not state then
                for pl, _ in pairs(config.activeApplied) do
                    restorePartForPlayer(pl)
                end
            end
        elseif featureName == "clientMaster" then
            applyClientMaster(state)
        elseif featureName == "antiAim" then
            config.antiAimEnabled = state
            if not state then
                returnToOriginalPosition()
            end
        elseif featureName == "triggerBot" then
            toggleTriggerBot(state)
        elseif featureName == "bhop" then
            toggleBHop(state)
        elseif featureName == "spinbot" then
            config.spinbot.enabled = state
            if state then
                spinbotUpdate()
            else
                if config.varibz.spinbotConnection then
                    config.varibz.spinbotConnection:Disconnect()
                    config.varibz.spinbotConnection = nil
                end
                if localPlayer.Character then
                    local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local pos = rootPart.Position
                        rootPart.CFrame = CFrame.new(pos)
                    end
                end
            end
        elseif featureName == "silentAimHK" then
            config.SA2_Enabled = state
        elseif featureName == "viewing" then
            config.Viewing = state
            if state then
                local tempState = config.Viewing
                config.Viewing = false
                task.wait(0.05)
                config.Viewing = tempState
                pcall(function()
                    local cb = MiscTab and MiscTab.Callbacks and MiscTab.Callbacks.viewing
                    if cb then cb(state) end
                end)
            end
        elseif featureName == "camYOffset" then
            config.camYOffsetEnabled = state
            if state then
                if not config.camYOffsetConnection then
                    config.camYOffsetConnection = game:GetService("RunService").RenderStepped:Connect(function()
                        if config.camYOffsetEnabled then
                            local cam = workspace.CurrentCamera
                            if cam then
                                if not config.camYOffsetOriginalCFrame then
                                    config.camYOffsetOriginalCFrame = cam.CFrame
                                end
                                local offset = Vector3.new(0, config.camYOffsetValue, 0)
                                local newCFrame = CFrame.new(
                                    cam.CFrame.Position + offset,
                                    cam.CFrame.Position + offset + cam.CFrame.LookVector
                                )
                                cam.CFrame = newCFrame
                            end
                        end
                    end)
                end
            else
                if config.camYOffsetConnection then
                    config.camYOffsetConnection:Disconnect()
                    config.camYOffsetConnection = nil
                end
                config.camYOffsetOriginalCFrame = nil
            end
        elseif featureName == "truss" then
            config.trussEnabled = state
            if state then
                local player = game.Players.LocalPlayer
                local character = player.Character
                if character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        if config.trussPart then
                            config.trussPart:Destroy()
                            config.trussPart = nil
                        end
                        if config.trussConnection then
                            config.trussConnection:Disconnect()
                            config.trussConnection = nil
                        end
                        config.trussPart = Instance.new("TrussPart")
                        config.trussPart.Transparency = 1
                        config.trussPart.Size = Vector3.new(2, 10, 2)
                        config.trussPart.Parent = workspace
                        config.trussPart.CanCollide = true
                        config.trussPart.Name = "TrussPart_" .. tostring(math.random(10000, 99999))
                        config.trussConnection = game:GetService("RunService").Heartbeat:Connect(function()
                            if config.trussEnabled and config.trussPart and rootPart and rootPart.Parent then
                                config.trussPart.CFrame = rootPart.CFrame * CFrame.new(0, 0, -1.5)
                            else
                                if config.trussConnection then
                                    config.trussConnection:Disconnect()
                                    config.trussConnection = nil
                                end
                            end
                        end)
                    end
                end
            else
                if config.trussPart then
                    config.trussPart:Destroy()
                    config.trussPart = nil
                end
                if config.trussConnection then
                    config.trussConnection:Disconnect()
                    config.trussConnection = nil
                end
            end
        elseif featureName == "airwalk" then
            config.airwalkEnabled = state
            if state then
                local character = game.Players.LocalPlayer.Character
                if character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        config.airwalkPart = Instance.new("Part")
                        config.airwalkPart.Transparency = 1
                        config.airwalkPart.Size = Vector3.new(7, 2, 3)
                        config.airwalkPart.Parent = workspace
                        config.airwalkPart.CanCollide = true
                        config.airwalkPart.Anchored = true
                        config.airwalkPart.Name = "AirwalkPlatform_" .. tostring(math.random(10000, 99999))
                        if config.airwalkConnection then
                            config.airwalkConnection:Disconnect()
                            config.airwalkConnection = nil
                        end
                        config.airwalkConnection = game:GetService("RunService").Heartbeat:Connect(function()
                            if config.airwalkEnabled and config.airwalkPart and rootPart and rootPart.Parent then
                                config.airwalkPart.CFrame = rootPart.CFrame + Vector3.new(0, -4, 0)
                            else
                                if config.airwalkConnection then
                                    config.airwalkConnection:Disconnect()
                                    config.airwalkConnection = nil
                                end
                            end
                        end)
                    end
                end
            else
                if config.airwalkPart then
                    config.airwalkPart:Destroy()
                    config.airwalkPart = nil
                end
                if config.airwalkConnection then
                    config.airwalkConnection:Disconnect()
                    config.airwalkConnection = nil
                end
            end
        elseif featureName == "autorespawn" then
            config.autorespawnEnabled = state
            if state then
                config.autorespawnConnections = config.autorespawnConnections or {}
                config.autorespawnDeathPosition = nil
                local player = game.Players.LocalPlayer
                local function setupRespawn(character)
                    local humanoid = character:WaitForChild("Humanoid")
                    local rootPart = character:WaitForChild("HumanoidRootPart")
                    if config.autorespawnConnections.died then
                        config.autorespawnConnections.died:Disconnect()
                    end
                    config.autorespawnConnections.died = humanoid.Died:Connect(function()
                        if config.autorespawnEnabled then
                            config.autorespawnDeathPosition = rootPart.CFrame
                        end
                    end)
                end
                local function teleportToDeathPosition(newCharacter)
                    if config.autorespawnEnabled and config.autorespawnDeathPosition then
                        local newRoot = newCharacter:WaitForChild("HumanoidRootPart")
                        newRoot.CFrame = config.autorespawnDeathPosition
                        config.autorespawnDeathPosition = nil
                    end
                end
                if player.Character then
                    setupRespawn(player.Character)
                end
                if config.autorespawnConnections.characterAdded then
                    config.autorespawnConnections.characterAdded:Disconnect()
                end
                config.autorespawnConnections.characterAdded = player.CharacterAdded:Connect(function(character)
                    if config.autorespawnEnabled then
                        character:WaitForChild("Humanoid")
                        character:WaitForChild("HumanoidRootPart")
                        teleportToDeathPosition(character)
                        setupRespawn(character)
                    end
                end)
            else
                config.autorespawnDeathPosition = nil
                if config.autorespawnConnections then
                    for _, connection in pairs(config.autorespawnConnections) do
                        if connection then
                            connection:Disconnect()
                        end
                    end
                    config.autorespawnConnections = {}
                end
            end
        elseif featureName == "fullbright" then
            config.fbenabled = state
            if state then
                local lighting = game:GetService("Lighting")
                fullBrightSettings = {
                    Ambient = lighting.Ambient,
                    Brightness = lighting.Brightness,
                    ClockTime = lighting.ClockTime,
                    FogEnd = lighting.FogEnd,
                    GlobalShadows = lighting.GlobalShadows,
                    OutdoorAmbient = lighting.OutdoorAmbient
                }
                lighting.Ambient = Color3.fromRGB(255, 255, 255)
                lighting.Brightness = 2
                lighting.FogEnd = 100000
                lighting.GlobalShadows = false
                lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                lighting.ClockTime = 14
            else
                if fullBrightSettings then
                    local lighting = game:GetService("Lighting")
                    for property, value in pairs(fullBrightSettings) do
                        lighting[property] = value
                    end
                    fullBrightSettings = nil
                end
            end
        elseif featureName == "quickToggles" then
            config.QuickToggles = state
            if state then
                CreateQT()
            else
                KillQT()
            end
        elseif featureName == "bhopQuickToggle" then
            config.bhop.quickToggleEnabled = state
            updateBHopQuickToggle()
        elseif featureName == "antiafk" then
            config.antiafk = state
        end
    end)
end

local function loadSave(saveName)
    if not saveName or saveName == "" then
        WindUI:Notify({
            Title = "Save System",
            Content = "Please enter a save name to load!",
            Icon = "x",
            Duration = 2
        })
        return false
    end
    
    local data = loadSaveData(saveName)
    if not data or not data.config then
        WindUI:Notify({
            Title = "Save System",
            Content = "Save '" .. saveName .. "' not found or corrupted!",
            Icon = "x",
            Duration = 2
        })
        return false
    end
    local cfg = data.config
    pcall(function()
        if config.autoFarmLoop then
            config.autoFarmLoop:Disconnect()
            config.autoFarmLoop = nil
        end
        config.autoFarmEnabled = false
        if config.varibz.spinbotConnection then
            config.varibz.spinbotConnection:Disconnect()
            config.varibz.spinbotConnection = nil
        end
        config.spinbot.enabled = false
        if config.isTeleported then
            returnToOriginalPosition()
        end
        config.antiAimEnabled = false
        config.antiAimAbovePlayer = false
        config.antiAimBehindPlayer = false
        config.antiAimOrbitEnabled = false
        config.raycastAntiAim = false
        if config.varibz.bhopConnection then
            config.varibz.bhopConnection:Disconnect()
            config.varibz.bhopConnection = nil
        end
        config.bhop.enabled = false
        if config.varibz.triggerBotConnection then
            config.varibz.triggerBotConnection:Disconnect()
            config.varibz.triggerBotConnection = nil
        end
        if config.tbot.fovCircle and config.tbot.fovCircle.ScreenGui then
            config.tbot.fovCircle.ScreenGui:Destroy()
            config.tbot.fovCircle = nil
        end
        config.tbot.enabled = false
        config.varibz.aimbot360LoopRunning = false
        if config.varibz.aimbot360LoopTask then
            config.varibz.aimbot360LoopTask = nil
        end
        config.aimbot360Enabled = false
        config.aimbotEnabled = false
        config.startsa = false
        if gui.RingHolder then
            gui.RingHolder.Visible = false
        end
        for pl, _ in pairs(config.activeApplied) do
            restorePartForPlayer(pl)
        end
        config.SA2_Enabled = false
        config.espMasterEnabled = false
        for target in pairs(config.espData) do
            removeESPLabel(target)
        end
        for target in pairs(config.highlightData) do
            removeHighlightESP(target)
        end
        for target in pairs(config.lineESPData) do
            removeLineESP(target)
        end
        config.espData = {}
        config.highlightData = {}
        config.lineESPData = {}
        config.hitboxEnabled = false
        for player, _ in pairs(config.hitboxExpandedParts) do
            restoreTorso(player)
        end
        config.hitboxExpandedParts = {}
        config.hitboxOriginalSizes = {}
        if config.clientMasterEnabled then
            restoreClientValues()
        end
        config.clientMasterEnabled = false
        config.clientNoclipEnabled = false
        config.clientWalkEnabled = false
        config.clientJumpEnabled = false
        config.clientCFrameWalkToggle = false
        if _noclipConn then
            _noclipConn:Disconnect()
            _noclipConn = nil
        end
        if config._tpwalking then
            TpWalkStop()
        end
        config.trussEnabled = false
        if config.trussPart then
            config.trussPart:Destroy()
            config.trussPart = nil
        end
        if config.trussConnection then
            config.trussConnection:Disconnect()
            config.trussConnection = nil
        end
        config.airwalkEnabled = false
        if config.airwalkPart then
            config.airwalkPart:Destroy()
            config.airwalkPart = nil
        end
        if config.airwalkConnection then
            config.airwalkConnection:Disconnect()
            config.airwalkConnection = nil
        end
        config.autorespawnEnabled = false
        config.autorespawnDeathPosition = nil
        if config.autorespawnConnections then
            for _, connection in pairs(config.autorespawnConnections) do
                if connection then
                    connection:Disconnect()
                end
            end
            config.autorespawnConnections = {}
        end
        config.Viewing = false
        if config.varibz.ViewConnection then
            config.varibz.ViewConnection:Disconnect()
            config.varibz.ViewConnection = nil
        end
        config.camYOffsetEnabled = false
        if config.camYOffsetConnection then
            config.camYOffsetConnection:Disconnect()
            config.camYOffsetConnection = nil
        end
        config.camYOffsetOriginalCFrame = nil
        config.fbenabled = false
        if fullBrightSettings then
            local lighting = game:GetService("Lighting")
            for property, value in pairs(fullBrightSettings) do
                lighting[property] = value
            end
            fullBrightSettings = nil
        end
        config.QuickToggles = false
        KillQT()
        config.bhop.quickToggleEnabled = false
        if config.varibz.bhopQuickToggleUI and config.varibz.bhopQuickToggleUI.ScreenGui then
            config.varibz.bhopQuickToggleUI.ScreenGui:Destroy()
            config.varibz.bhopQuickToggleUI = nil
        end
        config.antiafk = false
        config.currentTarget = nil
        config.aimbotCurrentTarget = nil
        config.SA2_currentTarget = nil
        config.currentAutoFarmTarget = nil
        config.currentAntiAimTarget = nil
        config.autoFarmCompleted = {}
        config.autoFarmOriginalPositions = {}
        config.activeApplied = {}
        config.originalSizes = {}
        config.targethbSizes = {}
        config.centerLocked = {}
    end)
    task.wait(0.2)
    if cfg.masterTeamTarget then config.masterTeamTarget = cfg.masterTeamTarget end
    if cfg.masterTarget then config.masterTarget = cfg.masterTarget end
    if cfg.masterGetTarget then config.masterGetTarget = cfg.masterGetTarget end
    if cfg.targetSeenSwitchRate then config.targetSeenSwitchRate = cfg.targetSeenSwitchRate end
    if cfg.targetSeenMode then config.targetSeenMode = cfg.targetSeenMode end
    if cfg.ignoreForcefield ~= nil then config.ignoreForcefield = cfg.ignoreForcefield end
    if cfg.autoFarmEnabled ~= nil then config.autoFarmEnabled = cfg.autoFarmEnabled end
    if cfg.autoFarmWallCheck ~= nil then config.autoFarmWallCheck = cfg.autoFarmWallCheck end
    if cfg.autoFarmDistance then config.autoFarmDistance = cfg.autoFarmDistance end
    if cfg.autoFarmMaxRange then config.autoFarmMaxRange = cfg.autoFarmMaxRange end
    if cfg.autoFarmVerticalOffset then config.autoFarmVerticalOffset = cfg.autoFarmVerticalOffset end
    if cfg.autoFarmTargetPart then config.autoFarmTargetPart = cfg.autoFarmTargetPart end
    if cfg.autoFarmMinRange then config.autoFarmMinRange = cfg.autoFarmMinRange end
    if cfg.gp then config.gp = cfg.gp end
    if cfg.gp2 then config.gp2 = cfg.gp2 end
    if cfg.QuickToggles ~= nil then config.QuickToggles = cfg.QuickToggles end
    if cfg.QTDrag ~= nil then config.QTDrag = cfg.QTDrag end
    if cfg.espMasterEnabled ~= nil then config.espMasterEnabled = cfg.espMasterEnabled end
    if cfg.prefHighlightESP ~= nil then config.prefHighlightESP = cfg.prefHighlightESP end
    if cfg.prefTextESP ~= nil then config.prefTextESP = cfg.prefTextESP end
    if cfg.prefBoxESP ~= nil then config.prefBoxESP = cfg.prefBoxESP end
    if cfg.prefHealthESP ~= nil then config.prefHealthESP = cfg.prefHealthESP end
    if cfg.prefHeadDotESP ~= nil then config.prefHeadDotESP = cfg.prefHeadDotESP end
    if cfg.lineESPEnabled ~= nil then config.lineESPEnabled = cfg.lineESPEnabled end
    if cfg.lineESPOnlyTarget ~= nil then config.lineESPOnlyTarget = cfg.lineESPOnlyTarget end
    if cfg.lineStartPosition then config.lineStartPosition = cfg.lineStartPosition end
    if cfg.prefColorByHealth ~= nil then config.prefColorByHealth = cfg.prefColorByHealth end
    if cfg.sa2stuff then config.varibz.sa2stuff = cfg.sa2stuff end
    if cfg.espc then
        config.espc = Color3.new(cfg.espc.R or 1, cfg.espc.G or 0.71, cfg.espc.B or 0.76)
    end
    if cfg.esptargetc then
        config.esptargetc = Color3.new(cfg.esptargetc.R or 1, cfg.esptargetc.G or 1, cfg.esptargetc.B or 0)
    end
    if cfg.espteamc then
        config.espteamc = Color3.new(cfg.espteamc.R or 0, cfg.espteamc.G or 1, cfg.espteamc.B or 0)
    end
    if cfg.lineColor then
        config.lineColor = Color3.new(cfg.lineColor.R or 1, cfg.lineColor.G or 1, cfg.lineColor.B or 1)
    end
    if cfg.fbenabled ~= nil then config.fbenabled = cfg.fbenabled end
    if cfg.fovc then
        config.fovc = Color3.new(cfg.fovc.R or 0.39, cfg.fovc.G or 0, cfg.fovc.B or 0)
    end
    if cfg.fovct then
        config.fovct = Color3.new(cfg.fovct.R or 1, cfg.fovct.G or 1, cfg.fovct.B or 0)
    end
    if cfg.SA2_FovColor then
        config.SA2_FovColor = Color3.new(cfg.SA2_FovColor.R or 0, cfg.SA2_FovColor.G or 0, cfg.SA2_FovColor.B or 0)
    end
    if cfg.SA2_FovColourTarget then
        config.SA2_FovColourTarget = Color3.new(cfg.SA2_FovColourTarget.R or 1, cfg.SA2_FovColourTarget.G or 1, cfg.SA2_FovColourTarget.B or 0)
    end
    if cfg.SA2_FovTransparency then config.SA2_FovTransparency = cfg.SA2_FovTransparency end
    if cfg.tbot_fovColor then
        config.tbot.fovColor = Color3.new(cfg.tbot_fovColor.R or 1, cfg.tbot_fovColor.G or 0, cfg.tbot_fovColor.B or 0)
    end
    if cfg.hitboxColor then
        config.hitboxColor = Color3.new(cfg.hitboxColor.R or 1, cfg.hitboxColor.G or 1, cfg.hitboxColor.B or 1)
    end
    if cfg.visualizer_color then
        config.visualizer.color = Color3.new(cfg.visualizer_color.R or 1, cfg.visualizer_color.G or 0, cfg.visualizer_color.B or 0)
    end
    if cfg.LowRender ~= nil then config.LowRender = cfg.LowRender end
    if cfg.antiAimEnabled ~= nil then config.antiAimEnabled = cfg.antiAimEnabled end
    if cfg.raycastAntiAim ~= nil then config.raycastAntiAim = cfg.raycastAntiAim end
    if cfg.antiAimAbovePlayer ~= nil then config.antiAimAbovePlayer = cfg.antiAimAbovePlayer end
    if cfg.antiAimBehindPlayer ~= nil then config.antiAimBehindPlayer = cfg.antiAimBehindPlayer end
    if cfg.antiAimOrbitEnabled ~= nil then config.antiAimOrbitEnabled = cfg.antiAimOrbitEnabled end
    if cfg.antiAimTPDistance then config.antiAimTPDistance = cfg.antiAimTPDistance end
    if cfg.antiAimAboveHeight then config.antiAimAboveHeight = cfg.antiAimAboveHeight end
    if cfg.antiAimBehindDistance then config.antiAimBehindDistance = cfg.antiAimBehindDistance end
    if cfg.antiAimOrbitSpeed then config.antiAimOrbitSpeed = cfg.antiAimOrbitSpeed end
    if cfg.antiAimOrbitRadius then config.antiAimOrbitRadius = cfg.antiAimOrbitRadius end
    if cfg.antiAimOrbitHeight then config.antiAimOrbitHeight = cfg.antiAimOrbitHeight end
    if cfg.antiAimGetTarget then config.antiAimGetTarget = cfg.antiAimGetTarget end
    if cfg.spinbot_enabled ~= nil then config.spinbot.enabled = cfg.spinbot_enabled end
    if cfg.spinbot_speed then config.spinbot.speed = cfg.spinbot_speed end
    if cfg.aimbotEnabled ~= nil then config.aimbotEnabled = cfg.aimbotEnabled end
    if cfg.aimbotWallCheck ~= nil then config.aimbotWallCheck = cfg.aimbotWallCheck end
    if cfg.aimbot360Enabled ~= nil then config.aimbot360Enabled = cfg.aimbot360Enabled end
    if cfg.aimbotTargetPart then config.aimbotTargetPart = cfg.aimbotTargetPart end
    if cfg.aimbotStrength then config.aimbotStrength = cfg.aimbotStrength end
    if cfg.aimbotFOVSize then config.aimbotFOVSize = cfg.aimbotFOVSize end
    if cfg.aimbotGetTarget then config.aimbotGetTarget = cfg.aimbotGetTarget end
    if cfg.aimbotTeamTarget then config.aimbotTeamTarget = cfg.aimbotTeamTarget end
    if cfg.startsa ~= nil then config.startsa = cfg.startsa end
    if cfg.wallc ~= nil then config.wallc = cfg.wallc end
    if cfg.scaleToScreen ~= nil then config.scaleToScreen = cfg.scaleToScreen end
    if cfg.stsdistance then config.stsdistance = cfg.stsdistance end
    if cfg.bodypart then config.bodypart = cfg.bodypart end
    if cfg.hitchance then config.hitchance = cfg.hitchance end
    if cfg.fovsize then config.fovsize = cfg.fovsize end
    if cfg.hbtrans then config.hbtrans = cfg.hbtrans end
    if cfg.silentGetTarget then config.silentGetTarget = cfg.silentGetTarget end
    if cfg.SA2_Enabled ~= nil then config.SA2_Enabled = cfg.SA2_Enabled end
    if cfg.SA2_Wallcheck ~= nil then config.SA2_Wallcheck = cfg.SA2_Wallcheck end
    if cfg.SA2_Wallbang ~= nil then config.SA2_Wallbang = cfg.SA2_Wallbang end
    if cfg.SA2_ThreeSixtyMode ~= nil then config.SA2_ThreeSixtyMode = cfg.SA2_ThreeSixtyMode end
    if cfg.SA2_Method then config.SA2_Method = cfg.SA2_Method end
    if cfg.SA2_TargetPart then config.SA2_TargetPart = cfg.SA2_TargetPart end
    if cfg.SA2_HitChance then config.SA2_HitChance = cfg.SA2_HitChance end
    if cfg.SA2_FovRadius then config.SA2_FovRadius = cfg.SA2_FovRadius end
    if cfg.SA2_TargetRange then config.SA2_TargetRange = cfg.SA2_TargetRange end
    if cfg.SA2_TeamTarget then config.SA2_TeamTarget = cfg.SA2_TeamTarget end
    if cfg.SA2_GetTarget then config.SA2_GetTarget = cfg.SA2_GetTarget end
    if cfg.hitboxEnabled ~= nil then config.hitboxEnabled = cfg.hitboxEnabled end
    if cfg.hitboxTeamTarget then config.hitboxTeamTarget = cfg.hitboxTeamTarget end
    if cfg.hitboxSize then config.hitboxSize = cfg.hitboxSize end
    if cfg.reach_enabled ~= nil then config.reach.enabled = cfg.reach_enabled end
    if cfg.reach_type then config.reach.type = cfg.reach_type end
    if cfg.reach_distance then config.reach.distance = cfg.reach_distance end
    if cfg.visualizer_enabled ~= nil then config.visualizer.enabled = cfg.visualizer_enabled end
    if cfg.visualizer_material then config.visualizer.material = cfg.visualizer_material end
    if cfg.visualizer_transparency then config.visualizer.transparency = cfg.visualizer_transparency end
    if cfg.reach_autoSwing ~= nil then config.reach.autoSwing.enabled = cfg.reach_autoSwing end
    if cfg.reach_autoSwing_delay then config.reach.autoSwing.delay = cfg.reach_autoSwing_delay end
    if cfg.clientMasterEnabled ~= nil then config.clientMasterEnabled = cfg.clientMasterEnabled end
    if cfg.clientNoclipEnabled ~= nil then config.clientNoclipEnabled = cfg.clientNoclipEnabled end
    if cfg.clientWalkEnabled ~= nil then config.clientWalkEnabled = cfg.clientWalkEnabled end
    if cfg.clientJumpEnabled ~= nil then config.clientJumpEnabled = cfg.clientJumpEnabled end
    if cfg.clientCFrameWalkToggle ~= nil then config.clientCFrameWalkToggle = cfg.clientCFrameWalkToggle end
    if cfg.clientWalkSpeed then config.clientWalkSpeed = cfg.clientWalkSpeed end
    if cfg.clientJumpPower then config.clientJumpPower = cfg.clientJumpPower end
    if cfg.clientCFrameSpeed then config.clientCFrameSpeed = cfg.clientCFrameSpeed end
    if cfg.trussEnabled ~= nil then config.trussEnabled = cfg.trussEnabled end
    if cfg.airwalkEnabled ~= nil then config.airwalkEnabled = cfg.airwalkEnabled end
    if cfg.autorespawnEnabled ~= nil then config.autorespawnEnabled = cfg.autorespawnEnabled end
    if cfg.fastspawn ~= nil then config.fastspawn = cfg.fastspawn end
    if cfg.tbot_enabled ~= nil then config.tbot.enabled = cfg.tbot_enabled end
    if cfg.tbot_targetPart then config.tbot.targetPart = cfg.tbot_targetPart end
    if cfg.tbot_fovRadius then config.tbot.fovRadius = cfg.tbot_fovRadius end
    if cfg.tbot_hitChance then config.tbot.hitChance = cfg.tbot_hitChance end
    if cfg.tbot_delay then config.tbot.delay = cfg.tbot_delay end
    if cfg.tbot_wallCheck ~= nil then config.tbot.wallCheck = cfg.tbot_wallCheck end
    if cfg.tbot_holdToShoot ~= nil then config.tbot.holdToShoot = cfg.tbot_holdToShoot end
    if cfg.tbot_holdKey then config.tbot.holdKey = cfg.tbot_holdKey end
    if cfg.tbot_fovTransparency then config.tbot.fovTransparency = cfg.tbot_fovTransparency end
    if cfg.tbot_fovVisible ~= nil then config.tbot.fovVisible = cfg.tbot_fovVisible end
    if cfg.bhop_enabled ~= nil then config.bhop.enabled = cfg.bhop_enabled end
    if cfg.bhop_jumpDelay then config.bhop.jumpDelay = cfg.bhop_jumpDelay end
    if cfg.bhop_quickToggleEnabled ~= nil then config.bhop.quickToggleEnabled = cfg.bhop_quickToggleEnabled end
    if cfg.bhop_quickToggleDraggable ~= nil then config.bhop.quickToggleDraggable = cfg.bhop_quickToggleDraggable end
    if cfg.antiafk ~= nil then config.antiafk = cfg.antiafk end
    if cfg.Viewing ~= nil then config.Viewing = cfg.Viewing end
    if cfg.camYOffsetEnabled ~= nil then config.camYOffsetEnabled = cfg.camYOffsetEnabled end
    if cfg.camYOffsetValue then config.camYOffsetValue = cfg.camYOffsetValue end
    if cfg.Keybinds then
        for key, value in pairs(cfg.Keybinds) do
            config.Keybinds[key] = value
        end
    end
    if cfg.KeybindsEnabled ~= nil then config.KeybindsEnabled = cfg.KeybindsEnabled end
    if cfg.HoldKeysEnabled ~= nil then config.HoldKeysEnabled = cfg.HoldKeysEnabled end
    if cfg.HoldKeybind then config.Keybinds.HoldKeybind = cfg.HoldKeybind end
    if cfg.varibz_CameraDistance then config.varibz.CameraDistance = cfg.varibz_CameraDistance end
    if cfg.customFOVEnabled ~= nil then config.customFOVEnabled = cfg.customFOVEnabled end
    if cfg.customFOVValue then config.customFOVValue = cfg.customFOVValue end
    if cfg.Gradow_textcursor then 
        config.Gradow.textcursor = cfg.Gradow_textcursor 
    end
    if cfg.Gradow_textcursor2 then 
        config.Gradow.textcursor2 = cfg.Gradow_textcursor2 
    end
    if cfg.varibz_patcherwait then config.varibz.patcherwait = cfg.varibz_patcherwait end
    if cfg.varibz_lowpatcherwait then config.varibz.lowpatcherwait = cfg.varibz_lowpatcherwait end
    if cfg.varibz_patcher ~= nil then config.varibz.patcher = cfg.varibz_patcher end
    if cfg.varibz_lowpatcher ~= nil then config.varibz.lowpatcher = cfg.varibz_lowpatcher end
    getgenv().blablablahblahblahhblahblahhGraaaaaaaaaaaaaaaaaaaaaaavel.CurrentSave = saveName
    pcall(function()
        updateTeamTargetModes()
        syncSilentAimWithMaster()
    end)
    pcall(function()
        if gui.RingHolder then
            gui.RingHolder.Size = UDim2.new(0, math.max(8, config.fovsize * 2), 0, math.max(8, config.fovsize * 2))
            gui.RingHolder.Visible = config.startsa
        end
        if gui.RingStroke then
            gui.RingStroke.Color = config.fovc
        end
    end)
    
    pcall(function()
        if config.aimbotFOVRing and config.aimbotFOVRing.RingFrame then
            config.aimbotFOVRing.RingFrame.Size = UDim2.new(0, config.aimbotFOVSize * 2, 0, config.aimbotFOVSize * 2)
            if config.aimbotEnabled and not config.aimbot360Enabled then
                config.aimbotFOVRing.RingFrame.Visible = true
            else
                config.aimbotFOVRing.RingFrame.Visible = false
            end
        end
    end)
    task.wait(0.1)
    pcall(function()
        if config.espMasterEnabled then
            applyESPMaster(true)
            for _, target in ipairs(getAllTargets()) do
                if addesp(target) then
                    if config.prefTextESP or config.prefBoxESP or config.prefHealthESP or config.prefHeadDotESP then
                        makeesp(target)
                    end
                    if config.prefHighlightESP and getTargetCharacter(target) then
                        high(target)
                    end
                end
            end
            updateESPColors()
        end
    end)
    pcall(function()
        if config.hitboxEnabled then
            applyhb()
        end
    end)
    pcall(function()
        if config.autoFarmEnabled then
            autoFarmProcess()
        end
    end)
    pcall(function()
        if config.aimbotEnabled then
            handleAimbotToggle(true)
            if config.aimbot360Enabled then
                toggle360Aimbot(true)
            end
            aimbotfov()
            updateAimbotFOVRing()
        end
    end)
    pcall(function()
        if config.startsa then
            if gui.RingHolder then
                gui.RingHolder.Visible = true
            end
        end
    end)
    pcall(function()
        if config.clientMasterEnabled then
            applyClientMaster(true)
        end
    end)
    pcall(function()
        if config.antiAimEnabled then
            if config.antiAimAbovePlayer then
                config.antiAimAbovePlayer = true
            elseif config.antiAimBehindPlayer then
                config.antiAimBehindPlayer = true
            elseif config.antiAimOrbitEnabled then
                config.antiAimOrbitEnabled = true
            elseif config.raycastAntiAim then
                config.raycastAntiAim = true
            end
        end
    end)
    pcall(function()
        if config.tbot.enabled then
            toggleTriggerBot(true)
        end
    end)
    pcall(function()
        if config.bhop.enabled then
            toggleBHop(true)
        end
    end)
    pcall(function()
        if config.spinbot.enabled then
            spinbotUpdate()
        end
    end)
    pcall(function()
        if config.SA2_Enabled then
            config.SA2_Enabled = true
        end
    end)
    pcall(function()
        if config.Viewing then
            local tempView = config.Viewing
            config.Viewing = false
            task.wait(0.05)
            config.Viewing = tempView
            local function startViewing()
                local Players = game:GetService("Players")
                local RunService = game:GetService("RunService")
                local Camera = workspace.CurrentCamera
                
                if config.varibz.ViewConnection then
                    config.varibz.ViewConnection:Disconnect()
                    config.varibz.ViewConnection = nil
                end
                
                local function isEnemy(player)
                    if not player or player == Players.LocalPlayer then return false end
                    local localTeam = Players.LocalPlayer.Team
                    local targetTeam = player.Team
                    
                    if config.masterTeamTarget == "All" then
                        return true
                    elseif config.masterTeamTarget == "Enemies" then
                        if localTeam and targetTeam then
                            return localTeam ~= targetTeam
                        end
                        return true
                    elseif config.masterTeamTarget == "Teams" then
                        if localTeam and targetTeam then
                            return localTeam == targetTeam
                        end
                        return false
                    end
                    return true
                end
                
                local function isNPCEnemy(model)
                    if not model or not model:IsA("Model") then return false end
                    if Players:GetPlayerFromCharacter(model) then return false end
                    local humanoid = model:FindFirstChildOfClass("Humanoid")
                    if not humanoid or humanoid.Health <= 0 then return false end
                    if not (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")) then return false end
                    if config.masterTeamTarget == "All" then
                        return true
                    elseif config.masterTeamTarget == "Enemies" then
                        local npcTeam = model:FindFirstChild("Team")
                        if npcTeam then
                            local localTeam = Players.LocalPlayer.Team
                            if localTeam and npcTeam:IsA("ObjectValue") and npcTeam.Value then
                                return localTeam ~= npcTeam.Value
                            end
                        end
                        return true
                    elseif config.masterTeamTarget == "Teams" then
                        local npcTeam = model:FindFirstChild("Team")
                        if npcTeam and npcTeam:IsA("ObjectValue") and npcTeam.Value then
                            local localTeam = Players.LocalPlayer.Team
                            if localTeam then
                                return localTeam == npcTeam.Value
                            end
                        end
                        return false
                    end
                    return true
                end
                
                local function GetRandomTarget()
                    local Valid = {}
                    local masterTarget = config.masterTarget or "Players"
                    if masterTarget == "Players" or masterTarget == "Both" then
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= Players.LocalPlayer
                                and plr.Character
                                and plr.Character:FindFirstChild("HumanoidRootPart")
                                and isEnemy(plr)
                            then
                                local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                                if humanoid and humanoid.Health > 0 then
                                    if not config.ignoreForcefield or not hasForcefield(plr.Character) then
                                        table.insert(Valid, {
                                            type = "player",
                                            instance = plr,
                                            character = plr.Character
                                        })
                                    end
                                end
                            end
                        end
                    end
                    if masterTarget == "NPCs" or masterTarget == "Both" then
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj:IsA("Model") and isNPCEnemy(obj) then
                                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                                if rootPart then
                                    local humanoid = obj:FindFirstChildOfClass("Humanoid")
                                    if humanoid and humanoid.Health > 0 then
                                        if not config.ignoreForcefield or not hasForcefield(obj) then
                                            table.insert(Valid, {
                                                type = "npc",
                                                instance = obj,
                                                character = obj,
                                                rootPart = rootPart
                                            })
                                        end
                                    end
                                end
                            end
                        end
                    end
                    return #Valid > 0 and Valid[math.random(1, #Valid)] or nil
                end
                
                local Target = GetRandomTarget()
                if not Target then
                    config.Viewing = false
                    return
                end
                
                Camera.CameraType = Enum.CameraType.Scriptable
                
                config.varibz.ViewConnection = RunService.Renderstepped:Connect(function()
                    if not config.Viewing then
                        return
                    end
                    local isValid = false
                    if Target.type == "player" then
                        isValid = Target.instance 
                            and Target.instance.Character 
                            and Target.instance.Character:FindFirstChild("HumanoidRootPart")
                            and isEnemy(Target.instance)
                            and Target.instance.Character:FindFirstChildOfClass("Humanoid") 
                            and Target.instance.Character:FindFirstChildOfClass("Humanoid").Health > 0
                    elseif Target.type == "npc" then
                        isValid = Target.instance 
                            and Target.instance.Parent 
                            and Target.instance:FindFirstChild("HumanoidRootPart")
                            and isNPCEnemy(Target.instance)
                            and Target.instance:FindFirstChildOfClass("Humanoid") 
                            and Target.instance:FindFirstChildOfClass("Humanoid").Health > 0
                    end
                    
                    if not isValid then
                        Target = GetRandomTarget()
                        if not Target then
                            config.Viewing = false
                            Camera.CameraType = Enum.CameraType.Custom
                            return
                        end
                        return
                    end
                    
                    local HRP = nil
                    if Target.type == "player" then
                        HRP = Target.instance.Character.HumanoidRootPart
                    elseif Target.type == "npc" then
                        HRP = Target.instance.HumanoidRootPart
                    end
                    
                    if not HRP then
                        Target = GetRandomTarget()
                        if not Target then
                            config.Viewing = false
                            Camera.CameraType = Enum.CameraType.Custom
                            return
                        end
                        return
                    end
                    
                    local CameraPos = HRP.Position - HRP.CFrame.LookVector * config.varibz.CameraDistance + Vector3.new(0, 3, 0)
                    Camera.CFrame = CFrame.lookAt(CameraPos, HRP.Position + Vector3.new(0, 2, 0))
                end)
            end
            startViewing()
        end
    end)
    pcall(function()
        if config.camYOffsetEnabled then
            if not config.camYOffsetConnection then
                config.camYOffsetConnection = game:GetService("RunService").RenderStepped:Connect(function()
                    if config.camYOffsetEnabled then
                        local cam = workspace.CurrentCamera
                        if cam then
                            if not config.camYOffsetOriginalCFrame then
                                config.camYOffsetOriginalCFrame = cam.CFrame
                            end
                            local offset = Vector3.new(0, config.camYOffsetValue, 0)
                            local newCFrame = CFrame.new(
                                cam.CFrame.Position + offset,
                                cam.CFrame.Position + offset + cam.CFrame.LookVector
                            )
                            cam.CFrame = newCFrame
                        end
                    end
                end)
            end
        end
    end)
    pcall(function()
        if config.trussEnabled then
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    if config.trussPart then
                        config.trussPart:Destroy()
                        config.trussPart = nil
                    end
                    if config.trussConnection then
                        config.trussConnection:Disconnect()
                        config.trussConnection = nil
                    end
                    config.trussPart = Instance.new("TrussPart")
                    config.trussPart.Transparency = 1
                    config.trussPart.Size = Vector3.new(2, 10, 2)
                    config.trussPart.Parent = workspace
                    config.trussPart.CanCollide = true
                    config.trussPart.Name = "TrussPart_" .. tostring(math.random(10000, 99999))
                    config.trussConnection = game:GetService("RunService").Heartbeat:Connect(function()
                        if config.trussEnabled and config.trussPart and rootPart and rootPart.Parent then
                            config.trussPart.CFrame = rootPart.CFrame * CFrame.new(0, 0, -1.5)
                        else
                            if config.trussConnection then
                                config.trussConnection:Disconnect()
                                config.trussConnection = nil
                            end
                        end
                    end)
                end
            end
        end
    end)
    pcall(function()
        if config.airwalkEnabled then
            local character = game.Players.LocalPlayer.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    config.airwalkPart = Instance.new("Part")
                    config.airwalkPart.Transparency = 1
                    config.airwalkPart.Size = Vector3.new(7, 2, 3)
                    config.airwalkPart.Parent = workspace
                    config.airwalkPart.CanCollide = true
                    config.airwalkPart.Anchored = true
                    config.airwalkPart.Name = "AirwalkPlatform_" .. tostring(math.random(10000, 99999))
                    if config.airwalkConnection then
                        config.airwalkConnection:Disconnect()
                        config.airwalkConnection = nil
                    end
                    config.airwalkConnection = game:GetService("RunService").Heartbeat:Connect(function()
                        if config.airwalkEnabled and config.airwalkPart and rootPart and rootPart.Parent then
                            config.airwalkPart.CFrame = rootPart.CFrame + Vector3.new(0, -4, 0)
                        else
                            if config.airwalkConnection then
                                config.airwalkConnection:Disconnect()
                                config.airwalkConnection = nil
                            end
                        end
                    end)
                end
            end
        end
    end)
    pcall(function()
        if config.autorespawnEnabled then
            config.autorespawnConnections = config.autorespawnConnections or {}
            config.autorespawnDeathPosition = nil
            local player = game.Players.LocalPlayer
            local function setupRespawn(character)
                local humanoid = character:WaitForChild("Humanoid")
                local rootPart = character:WaitForChild("HumanoidRootPart")
                if config.autorespawnConnections.died then
                    config.autorespawnConnections.died:Disconnect()
                end
                config.autorespawnConnections.died = humanoid.Died:Connect(function()
                    if config.autorespawnEnabled then
                        config.autorespawnDeathPosition = rootPart.CFrame
                    end
                end)
            end
            local function teleportToDeathPosition(newCharacter)
                if config.autorespawnEnabled and config.autorespawnDeathPosition then
                    local newRoot = newCharacter:WaitForChild("HumanoidRootPart")
                    newRoot.CFrame = config.autorespawnDeathPosition
                    config.autorespawnDeathPosition = nil
                end
            end
            if player.Character then
                setupRespawn(player.Character)
            end
            if config.autorespawnConnections.characterAdded then
                config.autorespawnConnections.characterAdded:Disconnect()
            end
            config.autorespawnConnections.characterAdded = player.CharacterAdded:Connect(function(character)
                if config.autorespawnEnabled then
                    character:WaitForChild("Humanoid")
                    character:WaitForChild("HumanoidRootPart")
                    teleportToDeathPosition(character)
                    setupRespawn(character)
                end
            end)
        end
    end)
    pcall(function()
        if config.fbenabled then
            local lighting = game:GetService("Lighting")
            fullBrightSettings = {
                Ambient = lighting.Ambient,
                Brightness = lighting.Brightness,
                ClockTime = lighting.ClockTime,
                FogEnd = lighting.FogEnd,
                GlobalShadows = lighting.GlobalShadows,
                OutdoorAmbient = lighting.OutdoorAmbient
            }
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
            lighting.Brightness = 2
            lighting.FogEnd = 100000
            lighting.GlobalShadows = false
            lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            lighting.ClockTime = 14
        end
    end)
    pcall(function()
        if config.QuickToggles then
            CreateQT()
        end
    end)
    pcall(function()
        if config.bhop.quickToggleEnabled then
            updateBHopQuickToggle()
        end
    end)
    pcall(function()
        if config.antiafk then
            config.antiafk = true
        end
    end)
    pcall(function()
        if config.fastspawn then
            config.fastspawn = true
        end
    end)
    pcall(function()
        for _, tab in ipairs(Window.Tabs or {}) do
            for _, element in ipairs(tab.Elements or {}) do
                if element.Type == "Dropdown" and element.Callback then
                    local currentValue = nil
                    if element.Title == "Team Target" then
                        currentValue = config.masterTeamTarget
                    elseif element.Title == "TargetType" then
                        currentValue = config.masterTarget
                    elseif element.Title == "GetTarget" then
                        currentValue = config.masterGetTarget
                    elseif element.Title == "Target Part" and element.Parent and element.Parent.Title == "Aimbot" then
                        currentValue = config.aimbotTargetPart
                    end
                    if currentValue then
                        pcall(function() element:SetValue(currentValue) end)
                    end
                end
            end
        end
    end)
    pcall(function()
        if config.QuickToggles and gui.mobileGui and gui.mobileGui.Buttons then
            UpdateQT()
        end
    end)
    
    WindUI:Notify({
        Title = "Save System",
        Content = "Loaded '" .. saveName .. "' successfully!",
        Icon = "check",
        Duration = 3
    })
    
    return true
end
local function savePara()
    local saves = getSaveList()
    local saveText = "Available Saves:\n"
    
    if #saves == 0 then
        saveText = saveText .. "  There isn't any saves 💔🥀"
    else
        for i, save in ipairs(saves) do
            local isCurrent = (save == getgenv().blablablahblahblahhblahblahhGraaaaaaaaaaaaaaaaaaaaaaavel.CurrentSave)
            saveText = saveText .. "  " .. (isCurrent and "✓ " or "> ") .. save .. (isCurrent and "!" or "") .. "\n"
        end
    end
    
    return saveText
end
SaveUI:init(WindUI, config)
local function loadUISettings()
    return SaveUI:autoLoad()
end
local function saveUISettings(theme, transparency)
    return SaveUI:save(theme, transparency)
end
function respawn(plr)
    if not config or not config.fastspawn then 
        return 
    end

    local char = plr.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local ogpos = hrp.CFrame
    local ogpos2 = workspace.CurrentCamera.CFrame
    local rejectDeletions = gethiddenproperty(workspace, "RejectCharacterDeletions") ~= Enum.RejectCharacterDeletions.Disabled

    if rejectDeletions and replicatesignal then
        replicatesignal(plr.ConnectDiedSignalBackend)
        task.wait(game:GetService("Players").RespawnTime - 0.01)
        replicatesignal(plr.Kill)
    else
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
        char:ClearAllChildren()

        local newgen = Instance.new("Model")
        newgen.Parent = workspace
        plr.Character = newgen
        task.wait()
        plr.Character = char
        newgen:Destroy()
    end

    task.spawn(function()
        local newChar = plr.CharacterAdded:Wait()
        local newHrp = newChar:WaitForChild("HumanoidRootPart", 5)
        if newHrp then
            newHrp.CFrame = ogpos
            workspace.CurrentCamera.CFrame = ogpos2
        end
    end)
end

local function hasForcefield(character)
    if not character then return false end
    
    if config.ignoreForcefield == false then
        return false
    end
    
    local forcefield = character:FindFirstChildOfClass("ForceField")
    if forcefield then return true end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("ForceField") then
            return true
        elseif child.Name:lower():find("shield") or 
               child.Name:lower():find("forcefield") or
               child.Name:lower():find("invincible") or
               child.Name:lower():find("invulnerable") then
            if child:IsA("BasePart") or child:IsA("Model") or child:IsA("Folder") then
                for _, descendant in ipairs(child:GetDescendants()) do
                    if descendant:IsA("ParticleEmitter") or 
                       descendant:IsA("Beam") or 
                       descendant:IsA("Trail") then
                        return true
                    end
                end
            end
            return true
        end
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if humanoid.MaxHealth == math.huge or humanoid.Health == math.huge then
            return true
        end
        
        if humanoid:GetState() == Enum.HumanoidStateType.Physics then
            return true
        end
    end
    
    return false
end

local function isPlayerBeingTargeted(targetPlayer)
    if config.SA2_Enabled and config.SA2_currentTarget == targetPlayer then
        return true, "silentaim_hk"
    end
    if config.currentTarget == targetPlayer then
        return true, "silentaim"
    end
    if config.aimbotCurrentTarget == targetPlayer then
        return true, "aimbot"
    end
    return false, nil
end

local function GetRandomTargetPart()
    return ValidTargetParts[math.random(1, #ValidTargetParts)]
end
local function GetActualTargetPart()
    if config.SA2_TargetPart == "Random" then
        return GetRandomTargetPart()
    end
    return config.SA2_TargetPart
end

local function ArePlayersSameTeam(player1, player2)
    if not player1 or not player2 then return false end
    
    local team1 = player1.Team
    local team2 = player2.Team
    if not team1 or not team2 then return false end
    
    return team1 == team2
end

local function ShouldTargetPlayer(targetPlayer)
    if targetPlayer == plr then return false end
    if config.ignoreForcefield and targetPlayer.Character and hasForcefield(targetPlayer.Character) then
        return false
    end
    
    if config.SA2_TeamTarget == "All" then
        return true
    elseif config.SA2_TeamTarget == "Enemies" then
        return not ArePlayersSameTeam(plr, targetPlayer)
    elseif config.SA2_TeamTarget == "Teams" then
        return ArePlayersSameTeam(plr, targetPlayer)
    end
    
    return false
end
local IsPlayerVisible = function(Player)
    local PlayerCharacter = Player.Character
    local LocalPlayerCharacter = plr.Character
    if not (PlayerCharacter and LocalPlayerCharacter) then return false end
    
    local actualTargetPart = GetActualTargetPart()
    local PlayerRoot = FindFirstChild(PlayerCharacter, actualTargetPart) or FindFirstChild(PlayerCharacter, "HumanoidRootPart")
    if not PlayerRoot then return false end
    local LocalRoot = FindFirstChild(LocalPlayerCharacter, "Head") or FindFirstChild(LocalPlayerCharacter, "HumanoidRootPart")
    if not LocalRoot then return false end
    local origin = LocalRoot.Position
    local targetPos = PlayerRoot.Position
    local direction = (targetPos - origin).Unit
    local distance = (targetPos - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayerCharacter, PlayerCharacter}
    local result = workspace:Raycast(origin, direction * distance, params)
    if not result then
        return true
    end
    local hitParent = result.Instance.Parent
    if hitParent == PlayerCharacter or (hitParent and hitParent.Parent == PlayerCharacter) then
        return true
    end
    
    return false
end

local function syncSilentAimWithMaster()
    if config.masterTeamTarget == "All" then
        config.SA2_TeamTarget = "All"
        config.targetMode = "All"
        config.aimbotTeamTarget = "All"
        config.hitboxTeamTarget = "All"
        config.antiAimTarget = "All"
    elseif config.SA2_TeamTarget ~= config.masterTeamTarget and 
           config.masterTeamTarget ~= nil then
        if not config.SA2_TeamTarget then
            config.SA2_TeamTarget = config.masterTeamTarget
        end
        config.targetMode = config.masterTeamTarget
        config.aimbotTeamTarget = config.masterTeamTarget
        config.hitboxTeamTarget = config.masterTeamTarget
        config.antiAimTarget = config.masterTeamTarget
    end
    
    if config.masterGetTarget then
        config.silentGetTarget = config.masterGetTarget
        config.SA2_GetTarget = config.masterGetTarget
        config.aimbotGetTarget = config.masterGetTarget
        config.antiAimGetTarget = config.masterGetTarget
    end
end

local function GetClosestPlayer()
    if config.varibz.respawnLock or not plr.Character then
        if config.SA2_currentTarget then
            config.SA2_currentTarget = nil
            updateESPColors()
        end
        return nil
    end
    
    local Closest = nil
    local ShortestDistance = math.huge
    local LowestHealth = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local allTargets = {}
    local cameraCFrame = Camera.CFrame
    local cameraPos = cameraCFrame.Position
    local maxTargetRange = config.SA2_TargetRange or 1000
    
    for _, Player in next, GetPlayers(Players) do
        if Player == plr then continue end
        if not ShouldTargetPlayer(Player) then continue end
        if config.ignoreForcefield and hasForcefield(Character) then
            continue
        end
        local Character = Player.Character
        if not Character then continue end
        local Humanoid = FindFirstChild(Character, "Humanoid")
        if not Humanoid or Humanoid.Health <= 0 then continue end

        if config.SA2_Wallcheck and not IsPlayerVisible(Player) then continue end
        
        local bodyPartsToCheck = {"HumanoidRootPart", "Head", "Torso", "UpperTorso"}
        local foundPart = nil
        
        for _, partName in ipairs(bodyPartsToCheck) do
            local bodyPart = FindFirstChild(Character, partName)
            if bodyPart then
                foundPart = bodyPart
                break
            end
        end
        
        if not foundPart then continue end
        
        local targetPos = foundPart.Position
        local worldDist = (cameraPos - targetPos).Magnitude
        if worldDist > maxTargetRange then continue end
        
        if config.SA2_ThreeSixtyMode then
            table.insert(allTargets, {
                player = Player,
                character = Character,
                part = foundPart,
                humanoid = Humanoid,
                health = Humanoid.Health,
                worldDist = worldDist,
                in360Mode = true,
                screenPos = nil,
                onScreen = true,
                distanceToCenter = 0
            })
        else
            local screenPos, onScreen = func.GetScreenPosition(targetPos)
            if not onScreen then continue end
            screenPos = screenPos + Vector2.new(0, config.SA2_TArea)
            
            local distToFov = (screenCenter - screenPos).Magnitude
            if distToFov > config.SA2_FovRadius then continue end
            
            table.insert(allTargets, {
                player = Player,
                character = Character,
                part = foundPart,
                humanoid = Humanoid,
                health = Humanoid.Health,
                screenPos = screenPos,
                onScreen = onScreen,
                distanceToCenter = distToFov,
                worldDist = worldDist,
                in360Mode = false
            })
        end
    end
    
    if #allTargets == 0 then
        if config.SA2_currentTarget then
            config.SA2_currentTarget = nil
            updateESPColors()
        end
        return nil
    end
    local aliveTargets = {}
    for _, target in ipairs(allTargets) do
        if target.humanoid and target.humanoid.Health > 0 then
            table.insert(aliveTargets, target)
        end
    end
    
    if #aliveTargets == 0 then
        if config.SA2_currentTarget then
            config.SA2_currentTarget = nil
            updateESPColors()
        end
        return nil
    end
    
    local newClosestPlayer = nil
    local getTargetMethod = config.masterGetTarget or config.SA2_GetTarget or "Closest"
    
    if config.SA2_ThreeSixtyMode then
        if getTargetMethod == "Lowest Health" then
            local bestTarget = nil
            local bestHealth = math.huge
            
            for _, target in ipairs(aliveTargets) do
                if target.in360Mode and target.health < bestHealth then
                    bestHealth = target.health
                    bestTarget = target
                end
            end
            
            if bestTarget then
                local actualTargetPart = GetActualTargetPart()
                Closest = bestTarget.character[actualTargetPart] or bestTarget.part
                newClosestPlayer = bestTarget.player
            end
        elseif getTargetMethod == "TargetSeen" then
            local sortedTargets = {}
            for _, target in ipairs(aliveTargets) do
                if target.in360Mode then
                    table.insert(sortedTargets, target)
                end
            end
            
            table.sort(sortedTargets, function(a, b)
                return a.worldDist < b.worldDist
            end)
            
            if #sortedTargets > 0 then
                if config.targetSeenMode == "Switch" then
                    local currentTime = tick()
                    if currentTime - config.lastTargetSwitchTime >= config.targetSeenSwitchRate then
                        config.lastTargetSwitchTime = currentTime
                        
                        if not config.SA2_currentTarget then
                            local closestTarget = sortedTargets[1]
                            local actualTargetPart = GetActualTargetPart()
                            Closest = closestTarget.character[actualTargetPart] or closestTarget.part
                            config.SA2_currentTarget = closestTarget.player
                            newClosestPlayer = closestTarget.player
                        else
                            local currentIndex = nil
                            for i, target in ipairs(sortedTargets) do
                                if target.player == config.SA2_currentTarget then
                                    currentIndex = i
                                    break
                                end
                            end
                            
                            if currentIndex then
                                local nextIndex = (currentIndex % #sortedTargets) + 1
                                local nextTarget = sortedTargets[nextIndex]
                                local actualTargetPart = GetActualTargetPart()
                                Closest = nextTarget.character[actualTargetPart] or nextTarget.part
                                config.SA2_currentTarget = nextTarget.player
                                newClosestPlayer = nextTarget.player
                            else
                                local closestTarget = sortedTargets[1]
                                local actualTargetPart = GetActualTargetPart()
                                Closest = closestTarget.character[actualTargetPart] or closestTarget.part
                                config.SA2_currentTarget = closestTarget.player
                                newClosestPlayer = closestTarget.player
                            end
                        end
                    else
                        if config.SA2_currentTarget then
                            for _, target in ipairs(sortedTargets) do
                                if target.player == config.SA2_currentTarget then
                                    local actualTargetPart = GetActualTargetPart()
                                    Closest = target.character[actualTargetPart] or target.part
                                    newClosestPlayer = target.player
                                    break
                                end
                            end
                        end
                    end
                elseif config.targetSeenMode == "All" then
                    local closestTarget = sortedTargets[1]
                    if closestTarget then
                        local actualTargetPart = GetActualTargetPart()
                        Closest = closestTarget.character[actualTargetPart] or closestTarget.part
                        config.SA2_currentTarget = closestTarget.player
                        newClosestPlayer = closestTarget.player
                    end
                end
            end
        else
            local bestTarget = nil
            local bestDist = math.huge
            
            for _, target in ipairs(aliveTargets) do
                if target.in360Mode and target.worldDist < bestDist then
                    bestDist = target.worldDist
                    bestTarget = target
                end
            end
            
            if bestTarget then
                local actualTargetPart = GetActualTargetPart()
                Closest = bestTarget.character[actualTargetPart] or bestTarget.part
                newClosestPlayer = bestTarget.player
            end
        end
    else
        if getTargetMethod == "Lowest Health" then
            for _, target in ipairs(aliveTargets) do
                if target.onScreen and target.health < LowestHealth then
                    LowestHealth = target.health
                    local actualTargetPart = GetActualTargetPart()
                    Closest = target.character[actualTargetPart] or target.part
                    newClosestPlayer = target.player
                end
            end
        elseif getTargetMethod == "TargetSeen" then
            local targetsInFOV = {}
            
            for _, target in ipairs(aliveTargets) do
                if target.onScreen and target.distanceToCenter <= config.SA2_FovRadius then
                    table.insert(targetsInFOV, target)
                end
            end
            
            if #targetsInFOV > 0 then
                if config.targetSeenMode == "Switch" then
                    local currentTime = tick()
                    if currentTime - config.lastTargetSwitchTime >= config.targetSeenSwitchRate then
                        config.lastTargetSwitchTime = currentTime
                        
                        if not config.SA2_currentTarget then
                            local closestInFOV = nil
                            local closestDist = math.huge
                            for _, target in ipairs(targetsInFOV) do
                                if target.distanceToCenter < closestDist then
                                    closestDist = target.distanceToCenter
                                    closestInFOV = target
                                end
                            end
                            if closestInFOV then
                                local actualTargetPart = GetActualTargetPart()
                                Closest = closestInFOV.character[actualTargetPart] or closestInFOV.part
                                config.SA2_currentTarget = closestInFOV.player
                                newClosestPlayer = closestInFOV.player
                            end
                        else
                            local currentIndex = nil
                            for i, target in ipairs(targetsInFOV) do
                                if target.player == config.SA2_currentTarget then
                                    currentIndex = i
                                    break
                                end
                            end
                            
                            if currentIndex then
                                local nextIndex = (currentIndex % #targetsInFOV) + 1
                                local nextTarget = targetsInFOV[nextIndex]
                                local actualTargetPart = GetActualTargetPart()
                                Closest = nextTarget.character[actualTargetPart] or nextTarget.part
                                config.SA2_currentTarget = nextTarget.player
                                newClosestPlayer = nextTarget.player
                            else
                                local closestInFOV = nil
                                local closestDist = math.huge
                                for _, target in ipairs(targetsInFOV) do
                                    if target.distanceToCenter < closestDist then
                                        closestDist = target.distanceToCenter
                                        closestInFOV = target
                                    end
                                end
                                if closestInFOV then
                                    local actualTargetPart = GetActualTargetPart()
                                    Closest = closestInFOV.character[actualTargetPart] or closestInFOV.part
                                    config.SA2_currentTarget = closestInFOV.player
                                    newClosestPlayer = closestInFOV.player
                                end
                            end
                        end
                    else
                        if config.SA2_currentTarget then
                            for _, target in ipairs(targetsInFOV) do
                                if target.player == config.SA2_currentTarget then
                                    local actualTargetPart = GetActualTargetPart()
                                    Closest = target.character[actualTargetPart] or target.part
                                    newClosestPlayer = target.player
                                    break
                                end
                            end
                        end
                    end
                elseif config.targetSeenMode == "All" then
                    local closestInFOV = nil
                    local closestDist = math.huge
                    for _, target in ipairs(targetsInFOV) do
                        if target.distanceToCenter < closestDist then
                            closestDist = target.distanceToCenter
                            closestInFOV = target
                        end
                    end
                    if closestInFOV then
                        local actualTargetPart = GetActualTargetPart()
                        Closest = closestInFOV.character[actualTargetPart] or closestInFOV.part
                        config.SA2_currentTarget = closestInFOV.player
                        newClosestPlayer = closestInFOV.player
                    end
                end
            else
                config.SA2_currentTarget = nil
                newClosestPlayer = nil
            end
        else
            for _, target in ipairs(aliveTargets) do
                if target.onScreen and target.distanceToCenter <= config.SA2_FovRadius and target.distanceToCenter < ShortestDistance then
                    local actualTargetPart = GetActualTargetPart()
                    Closest = target.character[actualTargetPart] or target.part
                    ShortestDistance = target.distanceToCenter
                    newClosestPlayer = target.player
                end
            end
        end
    end
    
    if newClosestPlayer ~= config.SA2_currentTarget then
        config.SA2_currentTarget = newClosestPlayer
        updateESPColors()
    end
    
    return Closest
end

local ExpectedArguments = {
    FindPartOnRay = {
        ArgCountRequired = 2,
        Args = {
            "Instance", "Ray", "Instance", "boolean", "boolean"
        }
    },
    Raycast = {
        ArgCountRequired = 3,
        Args = {
            "Instance", "Vector3", "Vector3", "RaycastParams"
        }
    }
}

local function validate_args(Args, RayMethod)
    if not RayMethod then return false end
    if not Args then return false end
    
    local Matches = 0
    if #Args < RayMethod.ArgCountRequired then
        return false
    end
    for Pos, Argument in next, Args do
        if typeof(Argument) == RayMethod.Args[Pos] then
            Matches = Matches + 1
        end
    end
    return Matches >= RayMethod.ArgCountRequired
end

if OldNamecall then
    hookmetamethod(game, "__namecall", OldNamecall)
    OldNamecall = nil
end

if OldIndex then
    hookmetamethod(game, "__index", OldIndex)
    OldIndex = nil
end

RunService.Heartbeat:Connect(function(deltaTime)
    config.varibz.sa2thing += deltaTime
    
    if config.varibz.sa2thing >= config.varibz.sa2stuff then
        config.varibz.sa2thing = 0
        if config.SA2_Enabled then
            cachedTarget = GetClosestPlayer()
        end
    end
end)

local function calc_chance(chance)
    if chance == 100 then
        return true
    elseif chance <= 0 then
        return false
    else
        return math.random(1, 100) <= chance
    end
end

pcall(function()
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    if config.varibz.respawnLock then
        return OldNamecall(...)
    end
    if not config.SA2_Enabled then
        return OldNamecall(...)
    end
    local Method = getnamecallmethod()
    local Arguments = {...}
    local self = Arguments[1]
    local chance = calc_chance(config.SA2_HitChance)
    
    if config.SA2_Enabled and self == workspace and not checkcaller() then
        if not config.SA2_ThreeSixtyMode and not chance then
            config.SA2_FovIsTargeted = false
            return OldNamecall(...)
        end
        
        local HitPart = cachedTarget
        if not HitPart then
            config.SA2_FovIsTargeted = false
            return OldNamecall(...)
        end
        
        config.SA2_FovIsTargeted = true
        
        if config.SA2_Wallbang then
            if Method == "FindPartOnRay" then
                local A_Ray = Arguments[2]
                local Origin = A_Ray.Origin
                local Distance = A_Ray.Direction.Magnitude
                local hitPosition = HitPart.Position
                local normal = (hitPosition - Origin).Unit
                local material = HitPart.Material
            elseif Method == "Raycast" then
                local hitPosition = HitPart.Position
                local normal = (hitPosition - Arguments[2]).Unit
                
                local fakeResult = {
                    Instance = HitPart,
                    Position = hitPosition,
                    Normal = normal,
                    Material = HitPart.Material
                }
                
                return fakeResult
            end
        end
        if (Method == "FindPartOnRay" or Method == "findPartOnRay") and config.SA2_Method == "FindPartOnRay" then
            if validate_args(Arguments, ExpectedArguments.FindPartOnRay) then
                local A_Ray = Arguments[2]
                local Origin = A_Ray.Origin
                local Direction = func.Direction(Origin, HitPart.Position)
                Arguments[2] = Ray.new(Origin, Direction)
                return OldNamecall(unpack(Arguments))
            end
        elseif Method == "Raycast" and config.SA2_Method == "Raycast" then
            if validate_args(Arguments, ExpectedArguments.Raycast) then
                local A_Origin = Arguments[2]
                Arguments[3] = func.Direction(A_Origin, HitPart.Position)
                return OldNamecall(unpack(Arguments))
            end
        end
    end
    
    return OldNamecall(...)
end))
end)


pcall(function()
local OldIndex
OldIndex = hookmetamethod(game, "__index", newcclosure(function(Self, Index)
    if config.varibz.respawnLock then
        return OldIndex(Self, Index)
    end
    
    if config.SA2_Enabled and config.SA2_Method == "Mouse.Hit" and not checkcaller() and Self == mouse then
        if Index == "Target" or Index == "target" then
            local HitPart = GetClosestPlayer()
            if HitPart then
                config.SA2_FovIsTargeted = true
                return HitPart
            else
                config.SA2_FovIsTargeted = false
            end
        elseif Index == "Hit" or Index == "hit" then
            local HitPart = GetClosestPlayer()
            if HitPart then
                config.SA2_FovIsTargeted = true
                return HitPart.CFrame
            else
                config.SA2_FovIsTargeted = false
            end
        elseif Index == "X" or Index == "x" then
            return mouse.X
        elseif Index == "Y" or Index == "y" then
            return mouse.Y
        elseif Index == "UnitRay" then
            local HitPart = GetClosestPlayer()
            if HitPart then
                config.SA2_FovIsTargeted = true
                return Ray.new(mouse.Origin, (HitPart.Position - mouse.Origin).Unit)
            else
                config.SA2_FovIsTargeted = false
            end
        end
    end
    
    return OldIndex(Self, Index)
end))
end)
ScreenGui.Name = "FOVSys"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.IgnoreGuiInset = true
CircleFrame.Name = "FOVCircle"
CircleFrame.Parent = ScreenGui
CircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
CircleFrame.BackgroundColor3 = config.SA2_FovColor
CircleFrame.BackgroundTransparency = 1
CircleFrame.BorderSizePixel = 0
CircleFrame.Visible = false
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = CircleFrame
UIStroke.Color = config.SA2_FovColor
UIStroke.Thickness = 1
UIStroke.Transparency = 1 - config.SA2_FovTransparency
UIStroke.Parent = CircleFrame

RunService.Heartbeat:Connect(function()
    local viewportSize = Camera.ViewportSize
    if viewportSize.X == 0 then return end
    
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    
    if config.varibz.respawnLock then
        CircleFrame.Visible = false
        return
    end
    if config.SA2_Enabled and config.SA2_FovVisible and not config.SA2_ThreeSixtyMode then
        local currentTarget = GetClosestPlayer()
        
        CircleFrame.Visible = true
        CircleFrame.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
        CircleFrame.Size = UDim2.new(0, config.SA2_FovRadius * 2, 0, config.SA2_FovRadius * 2)
        
        local targetColor = currentTarget and config.SA2_FovColourTarget or config.SA2_FovColor
        UIStroke.Color = targetColor
        UIStroke.Transparency = 1 - config.SA2_FovTransparency
    else
        CircleFrame.Visible = false
    end
end)

local function setSpawnLocation(positionCFrame)
    config.SSEnabled = true
    config.SpawnLocation = positionCFrame
    
    if config.SSConnection then
        config.SSConnection:Disconnect()
    end
    
    config.SSConnection = game.Players.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        if config.SSEnabled and config.SpawnLocation then
            local newRoot = newCharacter:WaitForChild("HumanoidRootPart", 5)
            if newRoot then
                newRoot.CFrame = config.SpawnLocation
            end
        end
    end)
end
local function unsetSpawnLocation()
    config.SSEnabled = false
    config.SpawnLocation = nil
    
    if config.SSConnection then
        config.SSConnection:Disconnect()
        config.SSConnection = nil
    end
end
game:GetService('Players').LocalPlayer.Idled:Connect(function()
    if config.antiafk then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

local function ineednextgenrep(state)
    if state then
        local char = LocalPlayer.Character
        if not char then 
            WindUI:Notify({
                Title = "Desync",
                Content = "folk where r u",
                Icon = "x",
                Duration = 2
            })
            return false
        end
        
        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        
        if not root or not torso then
            WindUI:Notify({
                Title = "Desync",
                Content = "Missing body parts :/",
                Icon = "x",
                Duration = 2
            })
            return false
        end
        config.desyncSavedCFrame = root.CFrame
        local hiddenPos = Vector3.new(root.Position.X, root.Position.Y + 50000, root.Position.Z)
        config.desyncHiddenPos = hiddenPos
        char:MoveTo(hiddenPos)
        task.wait()
        config.desyncSeat = Instance.new("Seat")
        config.desyncSeat.Name = "DesyncSeat_" .. math.random(10000, 99999)
        config.desyncSeat.Anchored = false
        config.desyncSeat.CanCollide = false
        config.desyncSeat.Transparency = 1
        config.desyncSeat.Size = Vector3.new(2, 1, 1)
        config.desyncSeat.Position = hiddenPos
        config.desyncSeat.Parent = workspace
        config.desyncWeld = Instance.new("Weld")
        config.desyncWeld.Name = "DesyncWeld"
        config.desyncWeld.Part0 = config.desyncSeat
        config.desyncWeld.Part1 = torso
        config.desyncWeld.Parent = config.desyncSeat
        task.wait()
        config.desyncSeat.CFrame = config.desyncSavedCFrame
        local trans = config.desyncTransparency or 0.5
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                pcall(function() part.Transparency = trans end)
            end
        end
        if config.desyncLoop then
            config.desyncLoop:Disconnect()
        end
        config.desyncLoop = RunService.Heartbeat:Connect(function()
            if not config.desyncActive then return end
            if config.desyncSeat and config.desyncSeat.Parent then
                local c = LocalPlayer.Character
                if c then
                    for _, part in pairs(c:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("Decal") then
                            if part.Transparency < (config.desyncTransparency or 0.5) - 0.05 then
                                pcall(function() part.Transparency = config.desyncTransparency or 0.5 end)
                            end
                        end
                    end
                end
            end
        end)
        if config.desyncCleanupLoop then
            config.desyncCleanupLoop:Disconnect()
        end
        config.desyncCleanupLoop = task.spawn(function()
            while config.desyncActive do
                task.wait(0.5)
                if config.desyncActive and (not config.desyncSeat or not config.desyncSeat.Parent) then
                    local char = LocalPlayer.Character
                    if not char then continue end
                    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                    if not root or not torso then continue end
                    
                    config.desyncSeat = Instance.new("Seat")
                    config.desyncSeat.Name = "DesyncSeat_" .. math.random(10000, 99999)
                    config.desyncSeat.Anchored = false
                    config.desyncSeat.CanCollide = false
                    config.desyncSeat.Transparency = 1
                    config.desyncSeat.Size = Vector3.new(2, 1, 1)
                    config.desyncSeat.Position = config.desyncHiddenPos or Vector3.new(0, 100000, 0)
                    config.desyncSeat.Parent = workspace
                    
                    config.desyncWeld = Instance.new("Weld")
                    config.desyncWeld.Name = "DesyncWeld"
                    config.desyncWeld.Part0 = config.desyncSeat
                    config.desyncWeld.Part1 = torso
                    config.desyncWeld.Parent = config.desyncSeat
                    
                    task.wait()
                    config.desyncSeat.CFrame = root.CFrame
                end
            end
        end)
        
        config.desyncActive = true
        return true
        
    else
        local char = LocalPlayer.Character
        local currentVisualPos = nil
        if char then
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            if root then
                currentVisualPos = root.CFrame
            end
        end
        if config.desyncLoop then
            config.desyncLoop:Disconnect()
            config.desyncLoop = nil
        end
        
        if config.desyncCleanupLoop then
            config.desyncCleanupLoop = nil
        end
        if config.desyncSeat and config.desyncSeat.Parent then
            config.desyncSeat:Destroy()
        end
        config.desyncSeat = nil
        config.desyncWeld = nil
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    pcall(function() part.Transparency = 0 end)
                end
            end
        end
        if currentVisualPos and char then
            task.wait(0.1)
            pcall(function()
                char:PivotTo(currentVisualPos)
            end)
            pcall(function()
                char:MoveTo(currentVisualPos.Position)
            end)
        end
        
        config.desyncActive = false
        config.desyncSavedCFrame = nil
        WindUI:Notify({
            Title = "Gravel.cc",
            Content = "TP'd to visual pos :v",
            Icon = "info",
            Duration = 2
        })
        return true
    end
end
local function gonextgenrep()
    if not config.desyncActive then return end
    task.wait(1.5)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not root or not torso then return end
    config.desyncSavedCFrame = root.CFrame
    local hiddenPos = Vector3.new(root.Position.X, root.Position.Y + 50000, root.Position.Z)
    config.desyncHiddenPos = hiddenPos
    char:MoveTo(hiddenPos)
    task.wait()
    config.desyncSeat = Instance.new("Seat")
    config.desyncSeat.Name = "DesyncSeat_" .. math.random(10000, 99999)
    config.desyncSeat.Anchored = false
    config.desyncSeat.CanCollide = false
    config.desyncSeat.Transparency = 1
    config.desyncSeat.Size = Vector3.new(2, 1, 1)
    config.desyncSeat.Position = hiddenPos
    config.desyncSeat.Parent = workspace
    config.desyncWeld = Instance.new("Weld")
    config.desyncWeld.Name = "DesyncWeld"
    config.desyncWeld.Part0 = config.desyncSeat
    config.desyncWeld.Part1 = torso
    config.desyncWeld.Parent = config.desyncSeat
    task.wait()
    config.desyncSeat.CFrame = config.desyncSavedCFrame
    local trans = config.desyncTransparency or 0.5
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            pcall(function() part.Transparency = trans end)
        end
    end
end
local function nextgenrepre()
    if config.desyncRespawnConnection then
        config.desyncRespawnConnection:Disconnect()
    end
    
    config.desyncRespawnConnection = LocalPlayer.CharacterAdded:Connect(function(char)
        if config.desyncActive then
            task.spawn(gonextgenrep)
        end
    end)
end

if not math.clamp then
    function math.clamp(x, a, b)
        if x < a then return a end
        if x > b then return b end
        return x
    end
end

local function updateTeamTargetModes()
    local masterTeamSelection = config.masterTeamTarget or "Enemies"
    
    if masterTeamSelection == "All" then
        config.targetMode = "All"
        config.aimbotTeamTarget = "All"
        config.hitboxTeamTarget = "All"
        config.SA2_TeamTarget = "All"
        config.antiAimTarget = "All"
    else
        config.targetMode = masterTeamSelection
        config.aimbotTeamTarget = masterTeamSelection
        config.hitboxTeamTarget = masterTeamSelection
        config.SA2_TeamTarget = masterTeamSelection
        config.antiAimTarget = masterTeamSelection
    end
    if config.masterGetTarget then
        config.aimbotGetTarget = config.masterGetTarget
        config.silentGetTarget = config.masterGetTarget
        config.antiAimGetTarget = config.masterGetTarget
        config.SA2_GetTarget = config.masterGetTarget
    end

    if config.espMasterEnabled then
        local targetsToRemove = {}
        for target, _ in pairs(config.espData) do
            table.insert(targetsToRemove, target)
        end
        for _, target in ipairs(targetsToRemove) do
            removeESPLabel(target)
        end
        
        local targetsToRemoveHigh = {}
        for target, _ in pairs(config.highlightData) do
            table.insert(targetsToRemoveHigh, target)
        end
        for _, target in ipairs(targetsToRemoveHigh) do
            removeHighlightESP(target)
        end
        
        local targets = getAllTargets()
        for _, target in ipairs(targets) do
            if addesp(target) then
                if config.prefTextESP or config.prefBoxESP or config.prefHealthESP or config.prefHeadDotESP then
                    makeesp(target)
                end
                if config.prefHighlightESP and getTargetCharacter(target) then
                    high(target)
                end
            end
        end
    end
    applyhb()
    config.aimbotCurrentTarget = nil
    config.currentTarget = nil
    config.SA2_currentTarget = nil
    updateESPColors()
end


local function applyESPMaster(state)
    config.espMasterEnabled = state

    if not state then
        for target in pairs(config.espData) do
            removeESPLabel(target)
        end

        for target in pairs(config.highlightData) do
            removeHighlightESP(target)
        end
        
        for target in pairs(config.lineESPData) do
            removeLineESP(target)
        end

        config.espon = false
        config.highlightesp = false
    else
        if config.prefHighlightESP then
            for _, target in ipairs(getAllTargets()) do
                if addesp(target) and getTargetCharacter(target) then
                    high(target)
                end
            end
        end

        if config.prefTextESP or config.prefBoxESP or
           config.prefHealthESP or config.prefHeadDotESP then
            for _, target in ipairs(getAllTargets()) do
                if addesp(target) then
                    makeesp(target)
                end
            end
        end
        
        task.spawn(function()
            task.wait(0.1)
            updateLineESP()
            updateESPColors()
        end)

        config.espon = config.prefTextESP
        config.highlightesp = config.prefHighlightESP
    end

    updateESPColors()
end

RunService.Heartbeat:Connect(function()
    local currentTime = tick()
    if currentTime - config.varibz.lastTargetUpdate > 0.6 then
        config.varibz.lastTargetUpdate = currentTime
        updateESPColors()
    end
end)

local function pc()
    local plr = game.Players.LocalPlayer
    task.spawn(function()
        while true do
            pcall(function()
                plr.ReplicationFocus = workspace
                plr.MaximumSimulationRadius = math.huge
                plr.SimulationRadius = config.gp
            end)
            task.wait(0.1)
        end
    end)
end

local function pc2()
    local plr = game.Players.LocalPlayer
    task.spawn(function()
        while true do
            pcall(function()
                plr.ReplicationFocus = workspace
                plr.MaximumSimulationRadius = math.huge
                plr.SimulationRadius = config.gp2
            end)
            task.wait(0.1)
        end
    end)
end

local function isNPCModel(model)
    if not model or not model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health ~= nil then
        if model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") then
            return true
        end
    end
    return false
end

local function getAllTargets(getTargetSeen)
    local targets = {}

    if config.masterTarget == "Players" or config.masterTarget == "Both" then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= localPlayer then
                if getTargetSeen then
                    local char = getTargetCharacter(pl)
                    if char then
                        local head = char:FindFirstChild("Head")
                        local root = char:FindFirstChild("HumanoidRootPart")
                        local targetPos = (head or root) and (head or root).Position
                        
                        if targetPos then
                            local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
                            if onScreen and screenPos.Z > 0 then
                                local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                                local distPx = (screenVec - center).Magnitude
                                
                                local fovSize = config.masterGetTarget == "TargetSeen" and config.fovsize or config.aimbotFOVSize
                                if distPx <= fovSize then
                                    table.insert(targets, pl)
                                end
                            end
                        end
                    end
                else
                    table.insert(targets, pl)
                end
            end
        end
    end

    if config.masterTarget == "NPCs" or config.masterTarget == "Both" then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and isNPCModel(obj) then
                if not Players:GetPlayerFromCharacter(obj) then
                    if getTargetSeen then
                        local head = obj:FindFirstChild("Head")
                        local root = obj:FindFirstChild("HumanoidRootPart")
                        local targetPos = (head or root) and (head or root).Position
                        
                        if targetPos then
                            local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
                            if onScreen and screenPos.Z > 0 then
                                local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                                local distPx = (screenVec - center).Magnitude
                                
                                local fovSize = config.masterGetTarget == "TargetSeen" and config.fovsize or config.aimbotFOVSize
                                if distPx <= fovSize then
                                    table.insert(targets, obj)
                                end
                            end
                        end
                    else
                        table.insert(targets, obj)
                    end
                end
            end
        end
    end

    return targets
end

local function getTargetCharacter(target)
    if not target then return nil end
    if typeof(target) == "Instance" then
        if target:IsA("Player") then
            return target.Character
        elseif target:IsA("Model") then
            return target
        end
    end
    return nil
end

local function getTargetName(target)
    if not target then return "Unknown" end
    if typeof(target) == "Instance" then
        return target.Name
    end
    return tostring(target)
end

local function isTeammate(p)
    if not (localPlayer and p) then return false end
    if typeof(p) == "Instance" and p:IsA("Player") then
        if localPlayer.Team and p.Team then
            return localPlayer.Team == p.Team
        end
    end
    return false
end
local function addesp(targetPlayer)
    if not targetPlayer then return false end
    
    if (config.masterTarget == "NPCs" or config.masterTarget == "Both") and 
       typeof(targetPlayer) == "Instance" and targetPlayer:IsA("Model") then
        return true
    end
    
    if typeof(targetPlayer) == "Instance" and targetPlayer:IsA("Player") then
        if targetPlayer == localPlayer then return false end
        
        local mode = config.masterTeamTarget or "Enemies"
        if mode == "Enemies" then
            return not isTeammate(targetPlayer)
        elseif mode == "Teams" then
            return isTeammate(targetPlayer)
        elseif mode == "All" then
            return true
        else
            return not isTeammate(targetPlayer)
        end
    end
    
    return false
end

local function plralive(target)
    if not target then return false end

    if typeof(target) == "Instance" and target:IsA("Player") then
        local character = target.Character
        if not character then return false end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return false end
        return humanoid.Health > 0
    end

    if typeof(target) == "Instance" and target:IsA("Model") then
        local humanoid = target:FindFirstChildOfClass("Humanoid")
        if not humanoid then return false end
        return humanoid.Health > 0
    end

    return false
end

local function saveTargetOriginalPosition(target)
    local targetChar = getTargetCharacter(target)
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    config.autoFarmOriginalPositions[target] = {
        position = targetRoot.Position,
        cframe = targetRoot.CFrame,
        timestamp = tick()
    }
end

local function restoreTargetOriginalPosition(target)
    local targetChar = getTargetCharacter(target)
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    local savedData = config.autoFarmOriginalPositions[target]
    if savedData then
        pcall(function()
            targetRoot.CFrame = savedData.cframe
        end)
        config.autoFarmOriginalPositions[target] = nil
    end
end

local function canSeeTarget(target)
    if not config.autoFarmWallCheck then
        return true
    end
    
    local targetChar = getTargetCharacter(target)
    if not targetChar or not localPlayer.Character then return false end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart") or localPlayer.Character:FindFirstChild("Head")
    
    if not targetRoot or not localRoot then return false end
    
    local sourcePos = localRoot.Position
    local targetPos = targetRoot.Position
    local distance = (sourcePos - targetPos).Magnitude
    local rayDirection = (targetPos - sourcePos)
    local ray = Ray.new(sourcePos, rayDirection.Unit * rayDirection.Magnitude)
    
    local ignoreList = {localPlayer.Character}
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            table.insert(ignoreList, player.Character)
        end
    end
    
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    if hit then
        local hitParent = hit.Parent
        local isTarget = hitParent == targetChar or hitParent.Parent == targetChar
        
        if not isTarget then
            local distanceToHit = (position - sourcePos).Magnitude
            local distanceToTarget = rayDirection.Magnitude
            
            if distanceToHit < distanceToTarget - 2 then
                return false
            end
        end
    end
    
    return true
end

local function getValidAutoFarmTargets()
    local validTargets = {}
    local localRoot = localPlayer.Character and (localPlayer.Character:FindFirstChild("HumanoidRootPart") or localPlayer.Character:FindFirstChild("Head"))
    
    if not localRoot then return validTargets end
    
    local candidates = getAllTargets()
    for _, t in ipairs(candidates) do
        if t ~= localPlayer and plralive(t) then
            local shouldTarget = false
            if config.masterTarget == "NPCs" then
                if typeof(t) == "Instance" and t:IsA("Model") then
                    shouldTarget = true
                else
                    shouldTarget = false
                end
            elseif config.masterTarget == "Players" then
                if typeof(t) == "Instance" and t:IsA("Player") then
                    if not isTeammate(t) or config.masterTeamTarget == "All" then
                        shouldTarget = true
                    else
                        shouldTarget = false
                    end
                else
                    shouldTarget = false
                end
            elseif config.masterTarget == "Both" then
                shouldTarget = true
            end

            if shouldTarget then
                local humanoid = nil
                local char = getTargetCharacter(t)
                if char then
                    humanoid = char:FindFirstChildOfClass("Humanoid")
                    
                    if config.ignoreForcefield and hasForcefield(char) then
                        shouldTarget = false
                    end
                end
                if shouldTarget and humanoid and humanoid.Health > 0 then
                    if not config.autoFarmCompleted[t] then
                        local targetRoot = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
                        if targetRoot then
                            local distance = (localRoot.Position - targetRoot.Position).Magnitude
                            local withinRange = true
                            if config.autoFarmMinRange > 0 and distance < config.autoFarmMinRange then
                                withinRange = false
                            end
                            if config.autoFarmMaxRange > 0 and distance > config.autoFarmMaxRange then
                                withinRange = false
                            end
                            local isVisible = true
                            if config.autoFarmWallCheck then
                                isVisible = canSeeTarget(t)
                            end
                            
                            if withinRange and isVisible then
                                table.insert(validTargets, t)
                            end
                        end
                    end
                end
            end
        end
    end

    table.sort(validTargets, function(a, b)
        local charA = getTargetCharacter(a)
        local charB = getTargetCharacter(b)
        local rootA = charA and (charA:FindFirstChild("HumanoidRootPart") or charA:FindFirstChild("Head"))
        local rootB = charB and (charB:FindFirstChild("HumanoidRootPart") or charB:FindFirstChild("Head"))
        
        if not localRoot then return false end
        if not rootA then return false end
        if not rootB then return true end
        
        local distA = (localRoot.Position - rootA.Position).Magnitude
        local distB = (localRoot.Position - rootB.Position).Magnitude
        
        return distA < distB
    end)
    
    return validTargets
end


local function tptocrossWithAlignment(target)
    local targetChar = getTargetCharacter(target)
    if not targetChar or not localPlayer.Character or not camera then 
        return false 
    end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHead = targetChar:FindFirstChild("Head")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not localRoot then return false end
    if not canSeeTarget(target) then
        return false
    end
    local distance = (localRoot.Position - targetRoot.Position).Magnitude
    if config.autoFarmMinRange > 0 and distance < config.autoFarmMinRange then
        return false
    end
    
    if config.autoFarmMaxRange > 0 and distance > config.autoFarmMaxRange then
        return false
    end
    
    if not config.autoFarmOriginalPositions[target] then
        saveTargetOriginalPosition(target)
    end

    local cameraCFrame = camera.CFrame
    local forward = cameraCFrame.LookVector
    local cameraPos = cameraCFrame.Position
    local targetPos = cameraPos + (forward * config.autoFarmDistance)
    targetPos = targetPos + Vector3.new(0, config.autoFarmVerticalOffset, 0)
    local alignPart = nil
    if config.autoFarmTargetPart == "Head" and targetHead then
        alignPart = targetHead
    else
        alignPart = targetRoot
    end
    
    if not alignPart then return false end
    local offsetFromRoot = alignPart.Position - targetRoot.Position
    local newRootPos = targetPos - offsetFromRoot
    local directionToCamera = (cameraPos - newRootPos).Unit
    local lookAt = CFrame.new(newRootPos, newRootPos + directionToCamera)
    targetRoot.CFrame = lookAt
    return true
end
local function checkTargetHealth(target)
    if not target then return false end
    local char = getTargetCharacter(target)
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    if hasForcefield(char) then
        return false
    end
    
    return humanoid.Health > 0
end
local function autoFarmProcess()
    if config.autoFarmLoop then
        config.autoFarmLoop:Disconnect()
        config.autoFarmLoop = nil
    end
    
    config.autoFarmLoop = RunService.Heartbeat:Connect(function()
        if not config.autoFarmEnabled or not localPlayer.Character or not camera then
            if config.autoFarmLoop then
                config.autoFarmLoop:Disconnect()
                config.autoFarmLoop = nil
            end
            return
        end

        local validTargets = getValidAutoFarmTargets()
        if #validTargets == 0 then
            config.currentAutoFarmTarget = nil
            config.autoFarmIndex = 1

            if not config.autoFarmPartClaimStarted then
                config.autoFarmPartClaimStarted = true
                pcall(pc)
            else
                if tick() - (config.autoFarmLastRefresh or 0) > 2 then
                    config.autoFarmLastRefresh = tick()
                    pcall(function()
                        if localPlayer then
                            localPlayer.ReplicationFocus = workspace
                            localPlayer.SimulationRadius = config.gp
                        end
                    end)
                end
            end

            return
        end
        
        if config.currentAutoFarmTarget then
            local char = getTargetCharacter(config.currentAutoFarmTarget)
            if char and hasForcefield(char) then
                restoreTargetOriginalPosition(config.currentAutoFarmTarget)
                config.autoFarmCompleted[config.currentAutoFarmTarget] = true
                config.currentAutoFarmTarget = nil
            end
        end
        
        if not config.currentAutoFarmTarget or config.autoFarmCompleted[config.currentAutoFarmTarget] then
            for i = config.autoFarmIndex, #validTargets do
                local target = validTargets[i]
                if not config.autoFarmCompleted[target] then
                    local char = getTargetCharacter(target)
                    if char and not hasForcefield(char) then
                        config.currentAutoFarmTarget = target
                        config.autoFarmIndex = i
                        break
                    else
                        config.autoFarmCompleted[target] = true
                    end
                end
            end
            
            if not config.currentAutoFarmTarget then
                config.autoFarmIndex = 1
                for _, target in ipairs(validTargets) do
                    if not config.autoFarmCompleted[target] then
                        local char = getTargetCharacter(target)
                        if char and not hasForcefield(char) then
                            config.currentAutoFarmTarget = target
                            break
                        end
                    end
                end
            end
        end
        
        if config.currentAutoFarmTarget and getTargetCharacter(config.currentAutoFarmTarget) then
            if not checkTargetHealth(config.currentAutoFarmTarget) then
                restoreTargetOriginalPosition(config.currentAutoFarmTarget)
                config.autoFarmCompleted[config.currentAutoFarmTarget] = true
                config.currentAutoFarmTarget = nil
                return
            end
            
            if not config.autoFarmOriginalPositions[config.currentAutoFarmTarget] then
                saveTargetOriginalPosition(config.currentAutoFarmTarget)
            end

            local success = tptocrossWithAlignment(config.currentAutoFarmTarget)
            if not success then
                teleportTargetToLocalPlayerFront(config.currentAutoFarmTarget)
            end
        end
    end)
end
local function teleportTargetToLocalPlayerFront(target)
    local targetChar = getTargetCharacter(target)
    if not targetChar or not localPlayer.Character then 
        return false 
    end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not localRoot then return false end
    
    if not canSeeTarget(target) then
        return false
    end
    
    local distance = (localRoot.Position - targetRoot.Position).Magnitude
    
    if config.autoFarmMinRange > 0 and distance < config.autoFarmMinRange then
        return false
    end
    
    if config.autoFarmMaxRange > 0 and distance > config.autoFarmMaxRange then
        return false
    end
    
    local localCFrame = localRoot.CFrame
    local frontOffset = localCFrame.LookVector * config.autoFarmDistance
    local frontPos = localRoot.Position + frontOffset
    frontPos = Vector3.new(frontPos.X, targetRoot.Position.Y, frontPos.Z)
    targetRoot.CFrame = CFrame.new(frontPos, localRoot.Position)
    return true
end

local function stopAutoFarm()
    if config.autoFarmLoop then
        config.autoFarmLoop:Disconnect()
        config.autoFarmLoop = nil
    end
    
    for target, _ in pairs(config.autoFarmOriginalPositions) do
        if target and getTargetCharacter(target) then
            restoreTargetOriginalPosition(target)
        end
    end
    
    config.currentAutoFarmTarget = nil
    config.autoFarmIndex = 1
    config.autoFarmCompleted = {}
    config.autoFarmOriginalPositions = {}
    config.autoFarmEnabled = false
    config.autoFarmPartClaimStarted = false
    config.autoFarmLastRefresh = 0
end

local function raycastFromPlayer(player)
    if not player or not player.Character then return false end
    local character = player.Character
    local head = character:FindFirstChild("Head")
    if not head then return false end
    
    local lookVector = head.CFrame.LookVector
    local rayOrigin = head.Position
    local rayDirection = lookVector * 1000
    local ray = Ray.new(rayOrigin, rayDirection)
    
    local ignoreList = {character}
    
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    if hit then
        local hitParent = hit.Parent
        if hitParent and hitParent:IsA("Model") then
            local hitPlayer = Players:GetPlayerFromCharacter(hitParent)
            if hitPlayer == localPlayer then
                return true, position, lookVector
            end
        end
    end
    
    return false, nil, nil
end

local function teleportLocalPlayer(direction, distance)
    if not localPlayer.Character then return end
    local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    local currentPos = humanoidRootPart.Position
    local newPos = currentPos + (direction * distance)
    if not config.originalPosition then
        config.originalPosition = currentPos
    end
    humanoidRootPart.CFrame = CFrame.new(newPos)
    config.isTeleported = true
end

local function returnToOriginalPosition()
    if not config.originalPosition or not localPlayer.Character then return end
    local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    humanoidRootPart.CFrame = CFrame.new(config.originalPosition)
    config.originalPosition = nil
    config.isTeleported = false
    config.currentAntiAimTarget = nil
end

local function teleportAboveTarget(target)
    local targetChar = getTargetCharacter(target)
    if not targetChar or not localPlayer.Character then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not localRoot then return end
    
    local targetPos = targetRoot.Position
    local abovePos = targetPos + Vector3.new(0, config.antiAimAboveHeight, 0)
    if abovePos.Y > 500 then
        abovePos = Vector3.new(abovePos.X, 100, abovePos.Z)
    end
    
    if abovePos.Y < -100 then
        abovePos = Vector3.new(abovePos.X, 0, abovePos.Z)
    end
    
    if not config.originalPosition then
        config.originalPosition = localRoot.Position
    end
    localRoot.CFrame = CFrame.new(abovePos)
    config.currentAntiAimTarget = target
    config.isTeleported = true
end

local function teleportBehindTarget(target)
    local targetChar = getTargetCharacter(target)
    if not targetChar or not localPlayer.Character then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not localRoot then return end
    
    local targetCFrame = targetRoot.CFrame
    local behindOffset = -targetCFrame.LookVector * math.min(config.antiAimBehindDistance, 15)
    local behindPos = targetRoot.Position + behindOffset
    if behindPos.Y < -100 then
        behindPos = Vector3.new(behindPos.X, 0, behindPos.Z)
    end
    
    if not config.originalPosition then
        config.originalPosition = localRoot.Position
    end
    
    localRoot.CFrame = CFrame.new(behindPos)
    config.currentAntiAimTarget = target
    config.isTeleported = true
end
local function findClosestEnemy()
    if not localPlayer.Character then return nil end
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    local best = nil
    local bestMetric = nil
    local mode = config.antiAimGetTarget or config.masterGetTarget or "Closest"
    local potentialTargets = {}
    local targetsInView = {}
    
    for _, t in ipairs(getAllTargets()) do
        if t ~= localPlayer and plralive(t) then
            local shouldTarget = false
            
            if config.masterTarget == "NPCs" then
                if typeof(t) == "Instance" and t:IsA("Model") then
                    shouldTarget = true
                end
            elseif config.masterTarget == "Players" then
                if typeof(t) == "Instance" and t:IsA("Player") then
                    if config.masterTeamTarget == "Enemies" then
                        shouldTarget = not isTeammate(t)
                    elseif config.masterTeamTarget == "Teams" then
                        shouldTarget = isTeammate(t)
                    elseif config.masterTeamTarget == "All" then
                        shouldTarget = true
                    end
                end
            elseif config.masterTarget == "Both" then
                shouldTarget = true
            end
            
            if shouldTarget then
                local tgtChar = getTargetCharacter(t)
                local playerRoot = tgtChar and (tgtChar:FindFirstChild("HumanoidRootPart") or tgtChar:FindFirstChild("Head"))
                local humanoid = tgtChar and tgtChar:FindFirstChildOfClass("Humanoid")
                if config.ignoreForcefield and tgtChar and hasForcefield(tgtChar) then
                    shouldTarget = false
                end
                
                if shouldTarget and playerRoot and humanoid and humanoid.Health > 0 then
                    local distance = (localRoot.Position - playerRoot.Position).Magnitude
                    local health = humanoid.Health
                    local isInView = true
                    if mode == "TargetSeen" then
                        local camera = workspace.CurrentCamera
                        local screenPos, onScreen = camera:WorldToViewportPoint(playerRoot.Position)
                        isInView = onScreen and screenPos.Z > 0
                    end
                    
                    local targetData = {
                        target = t,
                        char = tgtChar,
                        root = playerRoot,
                        humanoid = humanoid,
                        distance = distance,
                        health = health,
                        isInView = isInView
                    }
                    
                    table.insert(potentialTargets, targetData)
                    if isInView then
                        table.insert(targetsInView, targetData)
                    end
                end
            end
        end
    end
    if #potentialTargets > 0 then
        if mode == "TargetSeen" then
            if #targetsInView > 0 then
                if config.targetSeenMode == "Switch" then
                    local currentTime = tick()
                    if currentTime - config.lastTargetSwitchTime >= config.targetSeenSwitchRate then
                        config.lastTargetSwitchTime = currentTime
                        
                        if not config.currentAntiAimTarget then
                            table.sort(targetsInView, function(a, b)
                                return a.distance < b.distance
                            end)
                            best = targetsInView[1].target
                        else
                            local currentIndex = nil
                            for i, target in ipairs(targetsInView) do
                                if target.target == config.currentAntiAimTarget then
                                    currentIndex = i
                                    break
                                end
                            end
                            
                            if currentIndex then
                                local nextIndex = (currentIndex % #targetsInView) + 1
                                best = targetsInView[nextIndex].target
                            else
                                table.sort(targetsInView, function(a, b)
                                    return a.distance < b.distance
                                end)
                                best = targetsInView[1].target
                            end
                        end
                    else
                        best = config.currentAntiAimTarget
                    end
                else
                    table.sort(targetsInView, function(a, b)
                        return a.distance < b.distance
                    end)
                    best = targetsInView[1].target
                end
            else
                return nil
            end
        elseif mode == "Lowest Health" then
            table.sort(potentialTargets, function(a, b)
                return a.health < b.health
            end)
            best = potentialTargets[1].target
        else
            table.sort(potentialTargets, function(a, b)
                return a.distance < b.distance
            end)
            best = potentialTargets[1].target
        end
    end
    
    return best
end
local function antiAimUpdate()
    if not config.antiAimEnabled then
        if config.isTeleported then
            returnToOriginalPosition()
        end
        return
    end
    
    if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if config.isTeleported then
            returnToOriginalPosition()
        end
        return
    end
    
    local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        if config.isTeleported then
            returnToOriginalPosition()
        end
        return
    end
    
    if config.antiAimOrbitEnabled then
        local closestEnemy = findClosestEnemy()
        if closestEnemy and getTargetCharacter(closestEnemy) then
            local targetChar = getTargetCharacter(closestEnemy)
            local targetPart = targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")
            if targetPart and localPlayer.Character then
                config.currentAntiAimTarget = closestEnemy
                if not config.originalPosition then
                    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if localRoot then
                        config.originalPosition = localRoot.Position
                    end
                end
                local tpos = targetPart.Position
                local angle = tick() * (config.antiAimOrbitSpeed or 8)
                local radius = config.antiAimOrbitRadius or 5
                local height = config.antiAimOrbitHeight or 0
                local offset = Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius)
                local newPos = tpos + offset
                
                newPos = Vector3.new(newPos.X, math.clamp(newPos.Y, -100, 100), newPos.Z)
                
                pcall(function()
                    local localRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if localRoot then
                        localRoot.CFrame = CFrame.new(newPos, tpos)
                    end
                    if camera and targetPart then
                        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPart.Position)
                    end
                end)
                config.isTeleported = true
            end
        else
            if config.isTeleported then
                returnToOriginalPosition()
            end
            config.currentAntiAimTarget = nil
        end
        return
    end
    
    if config.antiAimAbovePlayer then
        local closestEnemy = findClosestEnemy()
        if closestEnemy then
            local targetChar = getTargetCharacter(closestEnemy)
            if targetChar and localPlayer.Character then
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot and localRoot then
                    local distance = (localRoot.Position - targetRoot.Position).Magnitude
                    if distance < 200 then
                        teleportAboveTarget(closestEnemy)
                    end
                end
            end
        else
            if config.isTeleported then
                returnToOriginalPosition()
            end
        end
        return
    end
    
    if config.antiAimBehindPlayer then
        local closestEnemy = findClosestEnemy()
        if closestEnemy then
            local targetChar = getTargetCharacter(closestEnemy)
            if targetChar and localPlayer.Character then
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot and localRoot then
                    local distance = (localRoot.Position - targetRoot.Position).Magnitude
                    if distance < 200 then
                        teleportBehindTarget(closestEnemy)
                    end
                end
            end
        else
            if config.isTeleported then
                returnToOriginalPosition()
            end
        end
        return
    end
    
    if config.raycastAntiAim then
        local wasTargeted = false
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and plralive(player) then
                local shouldCheck = true
                if config.antiAimGetTarget == "TargetSeen" then
                    local tgtChar = getTargetCharacter(player)
                    if tgtChar then
                        local camera = workspace.CurrentCamera
                        local head = tgtChar:FindFirstChild("Head") or tgtChar:FindFirstChild("HumanoidRootPart")
                        if head then
                            local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                            shouldCheck = onScreen and screenPos.Z > 0
                        else
                            shouldCheck = false
                        end
                    end
                end
                
                if shouldCheck then
                    local isLooking, hitPosition, lookVector = raycastFromPlayer(player)
                    if isLooking then
                        wasTargeted = true
                        config.currentAntiAimTarget = player
                        
                        local teleportDirection = Vector3.new(-lookVector.Z, 0, lookVector.X)
                        
                        if math.random(1, 2) == 1 then
                            teleportDirection = -teleportDirection
                        end
                        local teleportDistance = math.min(config.antiAimTPDistance, 15)
                        teleportLocalPlayer(teleportDirection.Unit, teleportDistance)
                        break
                    end
                end
            end
        end
        
        if not wasTargeted and config.isTeleported then
            returnToOriginalPosition()
        end
    end
end
local function RFD(targetPlayer)
    local char = getTargetCharacter(targetPlayer)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("Decal") then
                local ok, t = pcall(function() return child.Texture end)
                local nameLower = tostring(child.Name):lower()
                local texLower = tostring(t or ""):lower()
                if nameLower == "face" or string.find(nameLower, "face") or string.find(texLower, "face") then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end

local function wallCheck(targetPos, sourcePos)
    if not config.wallc then
        return true
    end

    if (targetPos - sourcePos).Magnitude <= 0 then return true end

    local rayDirection = (targetPos - sourcePos)
    local ray = Ray.new(sourcePos, rayDirection.Unit * rayDirection.Magnitude)
    local ignoreList = {}

    if localPlayer and localPlayer.Character then
        table.insert(ignoreList, localPlayer.Character)
    end

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer.Character then
            table.insert(ignoreList, otherPlayer.Character)
        end
    end

    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    if hit and position then
        local distanceToTarget = (targetPos - sourcePos).Magnitude
        local distanceToHit = (position - sourcePos).Magnitude
        return distanceToHit >= (distanceToTarget - 2)
    end

    return true
end

local function high(targetPlayer)
    if not targetPlayer or not getTargetCharacter(targetPlayer) then return end
    if not addesp(targetPlayer) then return end

    if config.highlightData[targetPlayer] then
        local existing = config.highlightData[targetPlayer]
        if existing and existing.Parent then
            if targetPlayer == config.currentTarget or targetPlayer == config.aimbotCurrentTarget or (config.SA2_Enabled and config.SA2_currentTarget == targetPlayer) then
                existing.FillColor = config.esptargetc
            else
                existing.FillColor = config.espc
            end
            return
        else
            config.highlightData[targetPlayer] = nil
        end
    end

    local character = getTargetCharacter(targetPlayer)
    if not character then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.FillColor = config.espc
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    local okDepth, _ = pcall(function() highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
    if not okDepth then
    end
    highlight.Parent = character

    if targetPlayer == config.currentTarget or targetPlayer == config.aimbotCurrentTarget or (config.SA2_Enabled and config.SA2_currentTarget == targetPlayer) then
        highlight.FillColor = config.esptargetc
    else
        highlight.FillColor = config.espc
    end

    config.highlightData[targetPlayer] = highlight
end

local function createLineESP(targetPlayer)
    if config.lineESPData[targetPlayer] then
        removeLineESP(targetPlayer)
    end
    
    local line = Drawing.new("Line")
    line.Thickness = config.lineThickness
    line.Color = config.lineColor
    line.Visible = false
    
    config.lineESPData[targetPlayer] = {
        drawing = line,
        visible = false
    }
    
    return line
end


local function removeLineESP(targetPlayer)
    if config.lineESPData[targetPlayer] then
        if config.lineESPData[targetPlayer].drawing then
            config.lineESPData[targetPlayer].drawing:Remove()
        end
        config.lineESPData[targetPlayer] = nil
    end
end

local function getLineStartPosition()
    local viewportSize = camera.ViewportSize
    
    if config.lineStartPosition == "Bottom" then
        return Vector2.new(viewportSize.X / 2, viewportSize.Y)
    elseif config.lineStartPosition == "Top" then
        return Vector2.new(viewportSize.X / 2, 0)
    elseif config.lineStartPosition == "BottomLeft" then
        return Vector2.new(0, viewportSize.Y)
    elseif config.lineStartPosition == "BottomRight" then
        return Vector2.new(viewportSize.X, viewportSize.Y)
    elseif config.lineStartPosition == "TopLeft" then
        return Vector2.new(0, 0)
    elseif config.lineStartPosition == "TopRight" then
        return Vector2.new(viewportSize.X, 0)
    else
        return Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    end
end
local function updateLineESP()
    if not config.espMasterEnabled or not config.lineESPEnabled then
        for targetPlayer, data in pairs(config.lineESPData) do
            if data.drawing then
                data.drawing.Visible = false
            end
        end
        return
    end
    
    for _, target in ipairs(getAllTargets()) do
        if addesp(target) and plralive(target) then
            local char = getTargetCharacter(target)
            if char then
                local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                if root then
                    local pos, onScreen = camera:WorldToViewportPoint(root.Position)
                    
                    if onScreen and pos.Z > 0 then
                        local screenPos = Vector2.new(pos.X, pos.Y)
                        local shouldDrawLine = false
                        
                        if config.lineESPOnlyTarget then
                            local isTargeted = isPlayerBeingTargeted(target)
                            shouldDrawLine = isTargeted
                        else
                            shouldDrawLine = true
                        end
                        
                        if shouldDrawLine then
                            local lineData = config.lineESPData[target]
                            if not lineData then
                                createLineESP(target)
                                lineData = config.lineESPData[target]
                            end
                            
                            if lineData and lineData.drawing then
                                local line = lineData.drawing
                                
                                line.From = getLineStartPosition()
                                line.To = screenPos
                                line.Visible = true
                                line.Thickness = config.lineThickness
                                
                                local isTargeted = isPlayerBeingTargeted(target)
                                if isTargeted then
                                    line.Color = Color3.fromRGB(255, 255, 0)
                                else
                                    line.Color = config.lineColor
                                end
                            end
                        else
                            local lineData = config.lineESPData[target]
                            if lineData and lineData.drawing then
                                lineData.drawing.Visible = false
                            end
                        end
                    else
                        local lineData = config.lineESPData[target]
                        if lineData and lineData.drawing then
                            lineData.drawing.Visible = false
                        end
                    end
                end
            end
        else
            removeLineESP(target)
        end
    end
    local toRemove = {}
    for targetPlayer, _ in pairs(config.lineESPData) do
        local found = false
        for _, target in ipairs(getAllTargets()) do
            if target == targetPlayer then
                found = true
                break
            end
        end
        if not found then
            table.insert(toRemove, targetPlayer)
        end
    end
    
    for _, targetPlayer in ipairs(toRemove) do
        removeLineESP(targetPlayer)
    end
end


local function removeHighlightESP(targetPlayer)
    if not targetPlayer then return end
    local h = config.highlightData[targetPlayer]
    if h and h.Parent then
        pcall(function() h:Destroy() end)
    end
    config.highlightData[targetPlayer] = nil
end

local function removeESPLabel(targetPlayer)
    if not targetPlayer then return end
    local data = config.espData[targetPlayer]
    if not data then return end
    if data.connection then
        pcall(function() data.connection:Disconnect() end)
        data.connection = nil
    end
    
    if data.screenGui and data.screenGui.Parent then
        pcall(function() data.screenGui:Destroy() end)
    end
    
    config.espData[targetPlayer] = nil
end

local function healthColor(humanoid)
    if not humanoid then return config.espc end
    local maxH = humanoid.MaxHealth or 100
    local health = math.clamp(humanoid.Health / maxH, 0, 1)
    local r = 1 - health
    local g = health
    return Color3.new(r, g, 0)
end
local function makeesp(targetPlayer)
    if not targetPlayer then return end
    if not addesp(targetPlayer) then return end
    
    if config.espData[targetPlayer] then
        local oldData = config.espData[targetPlayer]
        if oldData.connection then
            pcall(function() oldData.connection:Disconnect() end)
        end
        if oldData.screenGui and oldData.screenGui.Parent then
            pcall(function() oldData.screenGui:Destroy() end)
        end
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESP_" .. getTargetName(targetPlayer)
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

    local label = Instance.new("TextLabel")
    label.Name = "ESPLabel"
    label.BackgroundTransparency = 1
    label.Text = getTargetName(targetPlayer)
    label.TextSize = 6
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Visible = false
    label.Size = UDim2.new(0, 200, 0, 20)
    label.AnchorPoint = Vector2.new(0.5, 1)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = screenGui

    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "ESPBox"
    boxFrame.AnchorPoint = Vector2.new(0, 0)
    boxFrame.Size = UDim2.new(0, 0, 0, 0)
    boxFrame.Position = UDim2.new(0, 0, 0, 0)
    boxFrame.BackgroundTransparency = 0.6
    boxFrame.BorderSizePixel = 0
    boxFrame.Visible = false
    boxFrame.Parent = screenGui

    local boxOutline = Instance.new("UIStroke")
    boxOutline.Thickness = 1
    boxOutline.LineJoinMode = Enum.LineJoinMode.Round
    boxOutline.Color = config.espc
    boxOutline.Transparency = 0.1
    boxOutline.Parent = boxFrame

    local healthBg = Instance.new("Frame")
    healthBg.Name = "HealthBG"
    healthBg.AnchorPoint = Vector2.new(0, 0)
    healthBg.Size = UDim2.new(0, 4, 0, 0)
    healthBg.Position = UDim2.new(0, 0, 0, 0)
    healthBg.BackgroundTransparency = 0.6
    healthBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    healthBg.BorderSizePixel = 0
    healthBg.Visible = false
    healthBg.Parent = screenGui

    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.AnchorPoint = Vector2.new(0, 1)
    healthFill.Size = UDim2.new(1, 0, 0, 0)
    healthFill.Position = UDim2.new(0, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0,255,0)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBg

    local headDot = Instance.new("Frame")
    headDot.Name = "HeadDot"
    headDot.Size = UDim2.new(0, 6, 0, 6)
    headDot.AnchorPoint = Vector2.new(0.5, 0.5)
    headDot.BackgroundColor3 = config.espc
    headDot.BorderSizePixel = 0
    headDot.Visible = false
    headDot.Parent = screenGui
    local isTargetedBySA2 = config.SA2_Enabled and config.SA2_currentTarget == targetPlayer
    local isTargetedByRegular = config.currentTarget == targetPlayer
    local isTargetedByAimbot = config.aimbotCurrentTarget == targetPlayer
    local isTargeted = isTargetedBySA2 or isTargetedByRegular or isTargetedByAimbot
    
    label.TextColor3 = isTargeted and config.esptargetc or config.espc
    boxOutline.Color = isTargeted and config.esptargetc or config.espc
    headDot.BackgroundColor3 = isTargeted and config.esptargetc or config.espc
    
    local function startUpdater()
        if config.espData[targetPlayer] and config.espData[targetPlayer].connection then
            pcall(function() config.espData[targetPlayer].connection:Disconnect() end)
        end
        
        local conn = RunService.Heartbeat:Connect(function()
            local tchar = getTargetCharacter(targetPlayer)
            local charExists = tchar and tchar.Parent
            
            if not charExists then
                if label then label.Visible = false end
                if boxFrame then boxFrame.Visible = false end
                if healthBg then healthBg.Visible = false end
                if headDot then headDot.Visible = false end
                return
            end

            if not addesp(targetPlayer) then
                label.Visible = false
                boxFrame.Visible = false
                healthBg.Visible = false
                headDot.Visible = false
                return
            end

            local head = tchar:FindFirstChild("Head")
            local root = tchar:FindFirstChild("HumanoidRootPart") or tchar:FindFirstChild("Torso") or tchar:FindFirstChild("UpperTorso")
            if not head or not root then
                label.Visible = false
                boxFrame.Visible = false
                healthBg.Visible = false
                headDot.Visible = false
                return
            end

            local topPos = head.Position + Vector3.new(0, 0.4, 0)
            local bottomPos = root.Position - Vector3.new(0, 1.0, 0)
            local midPos = (topPos + bottomPos) * 0.5
            local topV3, onTop = camera:WorldToViewportPoint(topPos)
            local bottomV3, onBottom = camera:WorldToViewportPoint(bottomPos)
            local midV3, onMid = camera:WorldToViewportPoint(midPos)
            local onScreen = onTop and onBottom and onMid and topV3.Z > 0 and bottomV3.Z > 0 and midV3.Z > 0
            local topScreenY = topV3.Y
            local bottomScreenY = bottomV3.Y
            local centerX = midV3.X
            local heightPx = math.abs(bottomScreenY - topScreenY)
            if heightPx <= 2 then heightPx = 2 end
            local widthPx = math.clamp(heightPx * 0.45, 4, 400)

            local humanoid = tchar:FindFirstChildOfClass("Humanoid")
            local hpRatio = 1
            if humanoid then
                local maxH = humanoid.MaxHealth or 100
                if maxH > 0 then
                    hpRatio = math.clamp(humanoid.Health / maxH, 0, 1)
                end
            end

            local hpColor = Color3.new(1,1,1)
            if humanoid then
                hpColor = healthColor(humanoid)
            end

            local isTargetedBySA2 = config.SA2_Enabled and config.SA2_currentTarget == targetPlayer
            local isTargetedByRegular = config.currentTarget == targetPlayer
            local isTargetedByAimbot = config.aimbotCurrentTarget == targetPlayer
            local isTargeted = isTargetedBySA2 or isTargetedByRegular or isTargetedByAimbot

            if config.espMasterEnabled and config.prefTextESP then
                local text = string.format("%s [%d]", getTargetName(targetPlayer), humanoid and math.floor(humanoid.Health) or 0)
                label.Text = text

                local absWidth = 200
                pcall(function()
                    if label.TextBounds and label.TextBounds.X and label.TextBounds.X > 0 then
                        absWidth = label.TextBounds.X + 8
                    elseif label.AbsoluteSize and label.AbsoluteSize.X and label.AbsoluteSize.X > 0 then
                        absWidth = label.AbsoluteSize.X
                    end
                end)

                label.Size = UDim2.new(0, absWidth, 0, 18)
                label.Position = UDim2.new(0, centerX, 0, topScreenY - 4)
                label.Visible = onScreen
                if config.prefColorByHealth and humanoid then
                    label.TextColor3 = hpColor
                else
                    label.TextColor3 = isTargeted and config.esptargetc or config.espc
                end
            else
                label.Visible = false
            end

            if config.espMasterEnabled and config.prefBoxESP then
                boxFrame.Size = UDim2.new(0, widthPx, 0, math.max(2, heightPx))
                boxFrame.Position = UDim2.new(0, centerX - widthPx / 2, 0, topScreenY)
                boxFrame.Visible = onScreen
                boxFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                boxFrame.BackgroundTransparency = 0.7

                if config.prefColorByHealth and humanoid then
                    boxOutline.Color = hpColor
                else
                    boxOutline.Color = isTargeted and config.esptargetc or config.espc
                end
            else
                boxFrame.Visible = false
            end

            if config.espMasterEnabled and config.prefHealthESP and humanoid then
                healthBg.Size = UDim2.new(0, 4, 0, math.max(2, heightPx))
                healthBg.Position = UDim2.new(0, centerX + widthPx / 2 + 4, 0, topScreenY)
                healthBg.Visible = onScreen
                healthFill.Size = UDim2.new(1, 0, hpRatio, 0)
                healthFill.Position = UDim2.new(0, 0, 1, 0)
                healthFill.BackgroundColor3 = healthColor(humanoid)
            else
                healthBg.Visible = false
            end

            if config.espMasterEnabled and config.prefHeadDotESP and head then
                local headV3, onHead = camera:WorldToViewportPoint(head.Position)
                if onHead and headV3.Z > 0 then
                    headDot.Position = UDim2.new(0, headV3.X, 0, headV3.Y)
                    headDot.Visible = true
                    if config.prefColorByHealth and humanoid then
                        headDot.BackgroundColor3 = hpColor
                    else
                        headDot.BackgroundColor3 = isTargeted and config.esptargetc or config.espc
                    end
                else
                    headDot.Visible = false
                end
            else
                headDot.Visible = false
            end
        end)

        config.espData[targetPlayer] = {
            label = label,
            screenGui = screenGui,
            connection = conn,
            box = boxFrame,
            boxOutline = boxOutline,
            healthBG = healthBg,
            healthFill = healthFill,
            headDot = headDot
        }
    end

    local char = getTargetCharacter(targetPlayer)
    if char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")) then
        startUpdater()
    else
        spawn(function()
            local c = getTargetCharacter(targetPlayer)
            if c then
                local okHead = c:WaitForChild("Head", 2)
                local okRoot = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
                if okHead or okRoot then
                    startUpdater()
                end
            end
        end)
    end
end
local function updateESPColors()
    local toRemove = {}
    for targetPlayer, data in pairs(config.espData) do
        if (not targetPlayer) or (not data) or (not data.label) then
            table.insert(toRemove, targetPlayer)
        else
            if not addesp(targetPlayer) then
                table.insert(toRemove, targetPlayer)
            else
                local tchar = getTargetCharacter(targetPlayer)
                local humanoid = tchar and tchar:FindFirstChildOfClass("Humanoid")
                local hpColor = (humanoid and config.prefColorByHealth) and healthColor(humanoid) or nil
                local isTargetedBySA2 = config.SA2_Enabled and config.SA2_currentTarget == targetPlayer
                local isTargetedByRegular = config.currentTarget == targetPlayer
                local isTargetedByAimbot = config.aimbotCurrentTarget == targetPlayer
                local isTargeted = isTargetedBySA2 or isTargetedByRegular or isTargetedByAimbot
                
                if data.label then
                    if config.espMasterEnabled and config.prefTextESP then
                        if isTargeted then
                            data.label.TextColor3 = Color3.fromRGB(255, 255, 0)
                        elseif hpColor then
                            data.label.TextColor3 = hpColor
                        else
                            data.label.TextColor3 = config.espc
                        end
                        data.label.Visible = true
                    else
                        data.label.Visible = false
                    end
                end
                if data.box then
                    if config.espMasterEnabled and config.prefBoxESP then
                        data.box.Visible = true
                        if data.boxOutline then
                            if isTargeted then
                                data.boxOutline.Color = Color3.fromRGB(255, 255, 0)
                            else
                                data.boxOutline.Color = hpColor or config.espc
                            end
                        end
                    else
                        data.box.Visible = false
                    end
                end
                if data.headDot then
                    if config.espMasterEnabled and config.prefHeadDotESP then
                        data.headDot.Visible = true
                        if isTargeted then
                            data.headDot.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                        elseif hpColor then
                            data.headDot.BackgroundColor3 = hpColor
                        else
                            data.headDot.BackgroundColor3 = config.espc
                        end
                    else
                        data.headDot.Visible = false
                    end
                end
            end
        end
    end

    for _, targetPlayer in ipairs(toRemove) do
        config.espData[targetPlayer] = nil
    end
    local toRemoveHighlights = {}
    for targetPlayer, highlight in pairs(config.highlightData) do
        if not targetPlayer or not highlight or not highlight.Parent then
            table.insert(toRemoveHighlights, targetPlayer)
        else
            if not addesp(targetPlayer) then
                table.insert(toRemoveHighlights, targetPlayer)
            else
                local isTargetedBySA2 = config.SA2_Enabled and config.SA2_currentTarget == targetPlayer
                local isTargetedByRegular = config.currentTarget == targetPlayer
                local isTargetedByAimbot = config.aimbotCurrentTarget == targetPlayer
                local isTargeted = isTargetedBySA2 or isTargetedByRegular or isTargetedByAimbot
                
                if isTargeted then
                    highlight.FillColor = Color3.fromRGB(255, 255, 0)
                else
                    highlight.FillColor = config.espc
                end
            end
        end
    end

    for _, targetPlayer in ipairs(toRemoveHighlights) do
        config.highlightData[targetPlayer] = nil
    end
    
    if config.espMasterEnabled and config.lineESPEnabled then
        updateLineESP()
    end
end
local function toggleHighlightESP(enabled)
    config.prefHighlightESP = enabled
    config.highlightesp = enabled and config.espMasterEnabled or false

    if config.espMasterEnabled and enabled then
        for _, target in ipairs(getAllTargets()) do
            if addesp(target) and getTargetCharacter(target) then
                high(target)
            end
        end
    else
        local targetsToRemove = {}
        for targetPlayer, _ in pairs(config.highlightData) do
            table.insert(targetsToRemove, targetPlayer)
        end
        for _, targetPlayer in ipairs(targetsToRemove) do
            removeHighlightESP(targetPlayer)
        end
    end
end

local function toggleTextESP(enabled)
    config.prefTextESP = enabled
    config.espon = enabled and config.espMasterEnabled or false

    if config.espMasterEnabled and enabled then
        for _, target in ipairs(getAllTargets()) do
            if addesp(target) then
                makeesp(target)
            end
        end
    else
        local targetsToRemove = {}
        for targetPlayer, _ in pairs(config.espData) do
            table.insert(targetsToRemove, targetPlayer)
        end
        for _, targetPlayer in ipairs(targetsToRemove) do
            removeESPLabel(targetPlayer)
        end
    end
end

local function toggleBoxESP(enabled)
    config.prefBoxESP = enabled
    if config.espMasterEnabled then
        for _, target in ipairs(getAllTargets()) do
            if addesp(target) then
                if not config.espData[target] then
                    makeesp(target)
                end
            end
        end
        updateESPColors()
    else
        local targetsToRemove = {}
        for targetPlayer, _ in pairs(config.espData) do
            table.insert(targetsToRemove, targetPlayer)
        end
        for _, targetPlayer in ipairs(targetsToRemove) do
            removeESPLabel(targetPlayer)
        end
    end
end

local function toggleHealthESP(enabled)
    config.prefHealthESP = enabled
    if config.espMasterEnabled then
        for _, target in ipairs(getAllTargets()) do
            if addesp(target) then
                if not config.espData[target] then
                    makeesp(target)
                end
            end
        end
        updateESPColors()
    end
end
local function updateLineESP()
    if not config.espMasterEnabled or not config.lineESPEnabled then
        for targetPlayer, data in pairs(config.lineESPData) do
            if data.drawing then
                data.drawing.Visible = false
            end
        end
        return
    end
    
    for _, target in ipairs(getAllTargets()) do
        if addesp(target) and plralive(target) then
            local char = getTargetCharacter(target)
            if char then
                local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                if root then
                    local pos, onScreen = camera:WorldToViewportPoint(root.Position)
                    
                    if onScreen and pos.Z > 0 then
                        local screenPos = Vector2.new(pos.X, pos.Y)
                        local shouldDrawLine = false
                        
                        if config.lineESPOnlyTarget then
                            local isTargeted = isPlayerBeingTargeted(target)
                            shouldDrawLine = isTargeted
                        else
                            shouldDrawLine = true
                        end
                        
                        if shouldDrawLine then
                            local lineData = config.lineESPData[target]
                            if not lineData then
                                createLineESP(target)
                                lineData = config.lineESPData[target]
                            end
                            
                            if lineData and lineData.drawing then
                                local line = lineData.drawing
                                
                                line.From = getLineStartPosition()
                                line.To = screenPos
                                line.Visible = true
                                line.Thickness = config.lineThickness
                                local isTargeted = isPlayerBeingTargeted(target)
                                if isTargeted then
                                    line.Color = Color3.fromRGB(255, 255, 0)
                                else
                                    line.Color = config.lineColor
                                end
                            end
                        else
                            local lineData = config.lineESPData[target]
                            if lineData and lineData.drawing then
                                lineData.drawing.Visible = false
                            end
                        end
                    else
                        local lineData = config.lineESPData[target]
                        if lineData and lineData.drawing then
                            lineData.drawing.Visible = false
                        end
                    end
                end
            end
        else
            removeLineESP(target)
        end
    end
    local toRemove = {}
    for targetPlayer, _ in pairs(config.lineESPData) do
        local found = false
        for _, target in ipairs(getAllTargets()) do
            if target == targetPlayer then
                found = true
                break
            end
        end
        if not found then
            table.insert(toRemove, targetPlayer)
        end
    end
    
    for _, targetPlayer in ipairs(toRemove) do
        removeLineESP(targetPlayer)
    end
end
local function d()
    for _, target in ipairs(getAllTargets()) do
        RFD(target)
    end
end
local function espRefresher()
    if not config.espMasterEnabled then return end
    
    local currentESPData = {}
    for target, data in pairs(config.espData) do
        currentESPData[target] = true
    end
    
    for _, target in ipairs(getAllTargets()) do
        if addesp(target) then
            if not currentESPData[target] then
                if config.prefTextESP or config.prefBoxESP or config.prefHealthESP or config.prefHeadDotESP then
                    makeesp(target)
                end
                if config.prefHighlightESP and getTargetCharacter(target) then
                    high(target)
                end
            end
        else
            if currentESPData[target] then
                removeESPLabel(target)
                removeHighlightESP(target)
            end
            removeLineESP(target)
        end
    end
    updateESPColors()
end

local function saveOriginalPartInfo(targetPlayer, part)
    if not targetPlayer or not part then return end
    config.originalSizes[targetPlayer] = {
        partName = part.Name or "Head",
        size = part.Size,
    }
end

local function chooseBodyPartInstance(target)
    local char = getTargetCharacter(target)
    if not char then return nil, "Head" end

    local bp = config.bodypart or "Head"

    if bp == "Head" then
        return char:FindFirstChild("Head"), "Head"
    elseif bp == "HumanoidRootPart" then
        return char:FindFirstChild("HumanoidRootPart"), "HumanoidRootPart"
    elseif bp == "Both" then
        local roll = math.random(1, 100)
        local primaryName, secondaryName
        if roll <= 85 then
            primaryName = "HumanoidRootPart"
            secondaryName = "Head"
        else
            primaryName = "Head"
            secondaryName = "HumanoidRootPart"
        end
        local primaryPart = char:FindFirstChild(primaryName)
        if primaryPart then
            return primaryPart, primaryName
        else
            local fallback = char:FindFirstChild(secondaryName)
            return fallback, secondaryName
        end
    else
        local found = char:FindFirstChild(bp) or char:FindFirstChild("Head")
        return found, (found and found.Name) or "Head"
    end
end

local function applySizeToPart(targetPlayer, targetDiameter, chosenPart)
    local char = getTargetCharacter(targetPlayer)
    if not char or targetPlayer == localPlayer then return end
    if not plralive(targetPlayer) then return end

    local part = chosenPart
    local partName = nil
    if not part then
        part, partName = chooseBodyPartInstance(targetPlayer)
    else
        partName = part.Name
    end
    if not part then return end

    if not config.originalSizes[targetPlayer] then
        saveOriginalPartInfo(targetPlayer, part)
    end

    local expansionSize = Vector3.new(
        targetDiameter,
        targetDiameter,
        targetDiameter
    )

    if config.scaleToScreen then
        local localChar = localPlayer.Character
        if localChar then
            local localRoot = localChar:FindFirstChild("HumanoidRootPart") or localChar:FindFirstChild("Head")
            if localRoot then
                local targetPartPos = part.Position
                local localPos = localRoot.Position
                local distance = (targetPartPos - localPos).Magnitude
                local viewportSize = camera.ViewportSize
                local fov = camera.FieldOfView
                local screenHeight = viewportSize.Y
                local safeDistance = math.max(config.stsdistance, 0.1)
                local effectiveDistance = math.max(distance - safeDistance, 0.1)
                local screenCoverSize = (effectiveDistance * math.tan(math.rad(fov / 2))) * 2
                expansionSize = Vector3.new(
                    math.max(screenCoverSize, targetDiameter),
                    math.max(screenCoverSize, targetDiameter),
                    math.max(screenCoverSize, targetDiameter)
                )
            end
        end
    end

    local useExpanded = true
    local chance = math.clamp(tonumber(config.hitchance) or 100, 0, 100)
    if chance <= 0 then
        useExpanded = false
    elseif chance < 100 then
        if math.random(1, 100) <= chance then
            useExpanded = true
        else
            useExpanded = false
        end
    else
        useExpanded = true
    end

    if useExpanded then
        config.targethbSizes[targetPlayer] = expansionSize
    else
        local original = config.originalSizes[targetPlayer]
        if original and original.size then
            config.targethbSizes[targetPlayer] = original.size
        else
            config.targethbSizes[targetPlayer] = Vector3.new(0.05, 0.05, 0.05)
        end
    end

    config.activeApplied[targetPlayer] = true
end

local function restorePartForPlayer(targetPlayer)
    if not targetPlayer or targetPlayer == localPlayer then return end

    local char = getTargetCharacter(targetPlayer)
    local original = config.originalSizes[targetPlayer]
    if not original then
        config.activeApplied[targetPlayer] = nil
        config.targethbSizes[targetPlayer] = nil
        return
    end

    local part = nil
    if char then
        part = char:FindFirstChild(original.partName) or char:FindFirstChild(config.bodypart) or char:FindFirstChild("Head")
    end

    if part and original.size then
        pcall(function()
            part.Size = original.size
            part.Transparency = 1
            part.CanCollide = false
            part.Massless = false
            if part:IsA("BasePart") then
                part.Velocity = Vector3.new(0, 0, 0)
                part.RotVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end

    config.activeApplied[targetPlayer] = nil
    config.originalSizes[targetPlayer] = nil
    config.targethbSizes[targetPlayer] = nil
    config.centerLocked[targetPlayer] = nil
end

local function tnormalsize(targetPlayer)
    local char = getTargetCharacter(targetPlayer)
    if not char then return end  

    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")

    if torso and not config.hitboxOriginalSizes[targetPlayer] then
        config.hitboxOriginalSizes[targetPlayer] = {
            part = torso,
            size = torso.Size
        }
    end
end
local function expandhb(targetPlayer, size)
    if not targetPlayer then return end
    if targetPlayer == localPlayer then return end
    if not plralive(targetPlayer) then return end  
    
    if not config.hitboxEnabled then 
        restoreTorso(targetPlayer)
        return 
    end

    local char = getTargetCharacter(targetPlayer)
    if not char then return end
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")  
    if not torso then return end  

    tnormalsize(targetPlayer)
    local expansionSize = Vector3.new(size, size, size)
    config.hitboxLastSize[targetPlayer] = size

    config.hitboxExpandedParts[targetPlayer] = {
        part = torso,
        targetSize = expansionSize,
        originalSize = config.hitboxOriginalSizes[targetPlayer] and config.hitboxOriginalSizes[targetPlayer].size or torso.Size
    }
    
    if config.hitboxEnabled then
        pcall(function()
            torso.Size = expansionSize
            torso.Transparency = 0.9
            torso.CanCollide = false
            torso.Massless = false
            if config.hitboxColor then
                torso.Color = config.hitboxColor
            else
                torso.Color = Color3.fromRGB(255, 255, 255)
            end
        end)
    end
end
local function restoreTorso(targetPlayer)
    if not targetPlayer then return end  

    local original = config.hitboxOriginalSizes[targetPlayer]
    if original and original.part and original.part.Parent then
        pcall(function()
            original.part.Size = original.size
            original.part.Transparency = 0
            original.part.CanCollide = false
        end)
    end

    config.hitboxExpandedParts[targetPlayer] = nil
    config.hitboxOriginalSizes[targetPlayer] = nil
end
local function updateHitboxes()
    if not config.hitboxEnabled then  
        local targetsToRemove = {}
        for player, _ in pairs(config.hitboxExpandedParts) do  
            table.insert(targetsToRemove, player)
        end
        for _, player in ipairs(targetsToRemove) do
            restoreTorso(player)
        end
        return  
    end

    local targetsToRemove = {}
    for player, data in pairs(config.hitboxExpandedParts) do
        if not player or not getTargetCharacter(player) then
            table.insert(targetsToRemove, player)
        else
            if not plralive(player) then
                restoreTorso(player)
                table.insert(targetsToRemove, player)
            else
                local torso = getTargetCharacter(player):FindFirstChild("Torso") or getTargetCharacter(player):FindFirstChild("UpperTorso")
                if torso and data.targetSize then
                    pcall(function()
                        torso.Size = data.targetSize
                        torso.Transparency = 0.9
                        torso.CanCollide = false
                        torso.Massless = true
                    end)
                else
                    table.insert(targetsToRemove, player)
                end
            end
        end
    end
    
    for _, player in ipairs(targetsToRemove) do
        restoreTorso(player)
    end
end

local function targethb(player)
    if not player or player == localPlayer then return false end  
    if not plralive(player) then return false end  
    local char = getTargetCharacter(player)
    if config.ignoreForcefield and char and hasForcefield(char) then return false end

    local mode = config.masterTeamTarget or "Enemies"

    if typeof(player) == "Instance" and player:IsA("Model") then
        if mode == "Teams" then
            return false
        end
        return true
    end

    if mode == "Enemies" then
        return not isTeammate(player)
    elseif mode == "Teams" then
        return isTeammate(player)
    elseif mode == "All" then
        return true
    end

    return false
end

local function applyhb()
    if not config.hitboxEnabled then 
        local targetsToRemove = {}
        for player, _ in pairs(config.hitboxExpandedParts) do
            table.insert(targetsToRemove, player)
        end
        for _, player in ipairs(targetsToRemove) do
            restoreTorso(player)
        end
        return 
    end

    for _, target in ipairs(getAllTargets()) do  
        if targethb(target) then
            local size = config.hitboxSize
            local existing = config.hitboxExpandedParts[target]
            if not existing or existing.targetSize.X ~= size then
                config.hitboxLastSize[target] = size
                expandhb(target, size)
            end
        else
            restoreTorso(target)
        end
    end
end


local function hb()
    local targetsToRemove = {}
    for playerObj, targetSize in pairs(config.targethbSizes) do
        if playerObj and playerObj ~= localPlayer and getTargetCharacter(playerObj) and plralive(playerObj) then
            local part = getTargetCharacter(playerObj):FindFirstChild(config.originalSizes[playerObj] and config.originalSizes[playerObj].partName) 
                         or getTargetCharacter(playerObj):FindFirstChild(config.bodypart) 
                         or getTargetCharacter(playerObj):FindFirstChild("Head")
            if not part then
                local p1 = getTargetCharacter(playerObj):FindFirstChild("HumanoidRootPart")
                local p2 = getTargetCharacter(playerObj):FindFirstChild("Head")
                part = p1 or p2
            end

            if part then
                local currentSize = part.Size
                local lerpAlpha = math.clamp(tonumber(config.predic) or 1, 0, 1)
                local newSize = currentSize:Lerp(targetSize, lerpAlpha)

                pcall(function()
                    part.Size = newSize
                    part.Transparency = config.hbtrans
                    part.CanCollide = false
                    if part.Name == "Head" then
                        part.Massless = true
                    elseif part.Name == "HumanoidRootPart" then
                        part.Massless = false
                    end
                end)
            end
        else
            if playerObj ~= localPlayer then
                table.insert(targetsToRemove, playerObj)
            end
        end
    end
    
    for _, playerObj in ipairs(targetsToRemove) do
        restorePartForPlayer(playerObj)
    end
    
    updateHitboxes()
end

local function handleHitboxForRespawnedPlayer(player)
    if not config.hitboxEnabled then return end
    
    if player.Character then
        task.wait(0.5)
        
        local char = player.Character
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if config.hitboxOriginalSizes[player] and config.hitboxOriginalSizes[player].part and config.hitboxOriginalSizes[player].part.Parent then
                restoreTorso(player)
            end
            
            if humanoid.Health > 0 and targethb(player) then
                expandhb(player, config.hitboxSize)
            end
            
            humanoid.Died:Connect(function()
                if config.hitboxEnabled then
                    restoreTorso(player)
                end
            end)
        end
    end
end

local function shouldTargetAimbot(target)
    if not target then return false end
    if target == localPlayer then return false end
    if not plralive(target) then return false end
    
    local char = getTargetCharacter(target)
    if config.ignoreForcefield and char and hasForcefield(char) then return false end
    
    if typeof(target) == "Instance" and target:IsA("Model") then
        if config.masterTarget == "NPCs" or config.masterTarget == "Both" then
            return true
        else
            return false
        end
    end

    local mode = config.masterTeamTarget or "Enemies"
    if mode == "Enemies" then
        return not isTeammate(target)
    elseif mode == "Teams" then
        return isTeammate(target)
    elseif mode == "All" then
        return true
    end
    return false
end

local function aimbotWallCheck(targetPos, sourcePos)
    if not config.aimbotWallCheck then return true end
    
    if (targetPos - sourcePos).Magnitude <= 0 then return true end

    local rayDirection = (targetPos - sourcePos)
    local ray = Ray.new(sourcePos, rayDirection.Unit * rayDirection.Magnitude)
    local ignoreList = {}

    if localPlayer and localPlayer.Character then
        table.insert(ignoreList, localPlayer.Character)
    end

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer.Character then
            table.insert(ignoreList, otherPlayer.Character)
        end
    end

    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    if hit and position then
        local distanceToTarget = (targetPos - sourcePos).Magnitude
        local distanceToHit = (position - sourcePos).Magnitude
        return distanceToHit >= (distanceToTarget - 2)
    end

    return true
end

local function getAimbotTargetPart(target)
    if not target then return nil end
    local partName = config.aimbotTargetPart or "Head"
    local char = getTargetCharacter(target)
    if not char then return nil end
    
    if partName == "Head" then
        return char:FindFirstChild("Head")
    elseif partName == "HumanoidRootPart" then
        return char:FindFirstChild("HumanoidRootPart")
    elseif partName == "Torso" then
        return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    else
        return char:FindFirstChild("Head")
    end
end

local function smoothAim(currentCFrame, targetCFrame, strength)
    strength = math.clamp(strength or 0.5, 0, 1)
    return currentCFrame:Lerp(targetCFrame, strength)
end

local function aimbotUpdate()
    if not config.aimbotEnabled then
        if config.aimbotCurrentTarget then
            config.aimbotCurrentTarget = nil
            updateESPColors()
        end
        return
    end
    
    if not camera then camera = workspace.CurrentCamera end
    if not camera then return end
    
    local viewportSize = camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local fovRadius = config.aimbot360Enabled and math.huge or config.aimbotFOVSize
    local cameraCFrame = camera.CFrame
    local cameraPos = cameraCFrame.Position
    
    local potentialTargets = {}
    local allTargets = getAllTargets()
    
    for _, target in ipairs(allTargets) do
        if shouldTargetAimbot(target) then
            local targetPart = getAimbotTargetPart(target)
            if targetPart then
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                local distPx = (screenVec - center).Magnitude
                
                local inFOV = config.aimbot360Enabled or (onScreen and distPx <= fovRadius)
                
                if inFOV then
                    local worldDist = (targetPart.Position - cameraPos).Magnitude
                    local isVisible = aimbotWallCheck(targetPart.Position, cameraPos)
                    
                    local tgtChar = getTargetCharacter(target)
                    local hasFF = config.ignoreForcefield and tgtChar and hasForcefield(tgtChar)
                    
                    if isVisible and not hasFF then
                        local humanoid = tgtChar and tgtChar:FindFirstChildOfClass("Humanoid")
                        table.insert(potentialTargets, {
                            target = target,
                            part = targetPart,
                            worldDist = worldDist,
                            screenDist = distPx,
                            screenPos = screenVec,
                            humanoid = humanoid,
                            health = humanoid and humanoid.Health or math.huge,
                            inFOV = true
                        })
                    end
                end
            end
        end
    end
    local bestTarget = nil
    local targetingMode = config.aimbotGetTarget or config.masterGetTarget or "Closest"
    
    if #potentialTargets > 0 then
        if targetingMode == "TargetSeen" then
            local targetsInFOV = {}
            for _, target in ipairs(potentialTargets) do
                if target.inFOV then
                    table.insert(targetsInFOV, target)
                end
            end
            
            if #targetsInFOV > 0 then
                config.targetSeenTargets = targetsInFOV
                
                if config.targetSeenMode == "Switch" then
                    local currentTime = tick()
                    if currentTime - config.lastTargetSwitchTime >= config.targetSeenSwitchRate then
                        config.lastTargetSwitchTime = currentTime
                        
                        if not config.aimbotCurrentTarget then
                            table.sort(targetsInFOV, function(a, b)
                                return a.worldDist < b.worldDist
                            end)
                            bestTarget = targetsInFOV[1]
                        else
                            local currentIndex = nil
                            for i, target in ipairs(targetsInFOV) do
                                if target.target == config.aimbotCurrentTarget then
                                    currentIndex = i
                                    break
                                end
                            end
                            
                            if currentIndex then
                                local nextIndex = (currentIndex % #targetsInFOV) + 1
                                bestTarget = targetsInFOV[nextIndex]
                            else
                                table.sort(targetsInFOV, function(a, b)
                                    return a.worldDist < b.worldDist
                                end)
                                bestTarget = targetsInFOV[1]
                            end
                        end
                    else
                        if config.aimbotCurrentTarget then
                            for _, target in ipairs(targetsInFOV) do
                                if target.target == config.aimbotCurrentTarget then
                                    bestTarget = target
                                    break
                                end
                            end
                        end
                    end
                elseif config.targetSeenMode == "All" then
                    table.sort(targetsInFOV, function(a, b)
                        return a.worldDist < b.worldDist
                    end)
                    bestTarget = targetsInFOV[1]
                end
            end
        elseif targetingMode == "Lowest Health" then
            local lowestHealth = math.huge
            for _, target in ipairs(potentialTargets) do
                if target.health < lowestHealth then
                    lowestHealth = target.health
                    bestTarget = target
                end
            end
        else
            local closestDist = math.huge
            for _, target in ipairs(potentialTargets) do
                if target.worldDist < closestDist then
                    closestDist = target.worldDist
                    bestTarget = target
                end
            end
        end
    end
    
    local newTarget = bestTarget and bestTarget.target or nil
    if config.aimbotCurrentTarget ~= newTarget then
        config.aimbotCurrentTarget = newTarget
        updateESPColors()
    end
    
    if bestTarget and bestTarget.part and localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local targetPosition = bestTarget.part.Position
            local currentCFrame = camera.CFrame
            local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPosition)
            
            local strength = math.clamp(config.aimbotStrength, 0, 1)
            if strength < 1 then
                targetCFrame = smoothAim(currentCFrame, targetCFrame, strength)
            end
            
            camera.CFrame = targetCFrame
        end
    end
end

local function aimbotfov()
    if config.aimbotFOVRing and config.aimbotFOVRing.ScreenGui and config.aimbotFOVRing.ScreenGui.Parent then
        config.aimbotFOVRing.ScreenGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimbotFOVRing"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    local ringFrame = Instance.new("Frame")
    ringFrame.Name = "RingFrame"
    ringFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ringFrame.Size = UDim2.new(0, config.aimbotFOVSize * 2, 0, config.aimbotFOVSize * 2)
    ringFrame.Position = UDim2.new(0.5, 0, 0.5, -28)
    ringFrame.BackgroundTransparency = 1
    ringFrame.Visible = config.aimbotEnabled and not config.aimbot360Enabled
    ringFrame.Parent = screenGui
    
    local ringCorner = Instance.new("UICorner")
    ringCorner.CornerRadius = UDim.new(1, 0)
    ringCorner.Parent = ringFrame
    
    local ringStroke = Instance.new("UIStroke")
    ringStroke.Thickness = 1
    ringStroke.LineJoinMode = Enum.LineJoinMode.Round
    ringStroke.Color = Color3.fromRGB(255, 0, 0)
    ringStroke.Transparency = 0.3
    ringStroke.Parent = ringFrame
    
    config.aimbotFOVRing = {
        ScreenGui = screenGui,
        RingFrame = ringFrame,
        RingStroke = ringStroke
    }
    
    return config.aimbotFOVRing
end

local function updateAimbotFOVRing()
    if config.aimbotFOVRing and config.aimbotFOVRing.RingFrame then
        if config.aimbot360Enabled and config.aimbotEnabled then
            config.aimbotFOVRing.RingFrame.Visible = false
        elseif config.aimbotEnabled then
            config.aimbotFOVRing.RingFrame.Size = UDim2.new(0, config.aimbotFOVSize * 2, 0, config.aimbotFOVSize * 2)
            config.aimbotFOVRing.RingFrame.Position = UDim2.new(0.5, 0, 0.5, -28)
            config.aimbotFOVRing.RingFrame.Visible = true
        else
            config.aimbotFOVRing.RingFrame.Visible = false
        end
    end
end
local function aimbot360UpdateLoop()
    if config.varibz.aimbot360LoopRunning then
        return
    end

    if not config.aimbotEnabled or not config.aimbot360Enabled then
        return
    end

    config.varibz.aimbot360LoopRunning = true
    config.varibz.aimbot360LoopTask = task.spawn(function()
        while config.varibz.aimbot360LoopRunning and config.aimbotEnabled and config.aimbot360Enabled do
            aimbotUpdate()
            task.wait(0.1)
        end

        config.varibz.aimbot360LoopRunning = false
        config.varibz.aimbot360LoopTask = nil
    end)
end
local function toggle360Aimbot(state)
    if state then
        if not config.aimbotEnabled then
            config.aimbot360Enabled = false
            return
        end

        if not config.aimbot360OriginalFOV then
            config.aimbot360OriginalFOV = config.aimbotFOVSize
        end
        
        config.aimbot360Enabled = true
        config.aimbotFOVSize = math.huge
        updateAimbotFOVRing()
        aimbot360UpdateLoop()

    else
        if config.aimbot360OriginalFOV then
            config.aimbotFOVSize = config.aimbot360OriginalFOV
            config.aimbot360OriginalFOV = nil
        end
        
        config.aimbot360Enabled = false
        updateAimbotFOVRing()
        config.varibz.aimbot360LoopRunning = false
        if config.varibz.aimbot360LoopTask then
            config.varibz.aimbot360LoopTask = nil
        end
    end
end
local function handleAimbotToggle(state)
    config.aimbotEnabled = state
    
    if state then
        if not config.aimbotFOVRing then
            aimbotfov()
        end
        
        if config.aimbot360Enabled then
            config.aimbotFOVSize = math.huge
            updateAimbotFOVRing()
            aimbot360UpdateLoop()
        end
        aimbotfov()
    else
        if config.aimbot360Enabled then
            config.varibz.aimbot360LoopRunning = false
            if config.varibz.aimbot360LoopTask then
                config.varibz.aimbot360LoopTask = nil
            end
        end
    end
    
    updateAimbotFOVRing()
end


local function aimbot360UpdateLoop()
    if config.varibz.aimbot360LoopRunning then
        return
    end

    if not config.aimbotEnabled then
        return
    end

    if not config.aimbot360Enabled then
        config.aimbot360Enabled = true
    end

    config.varibz.aimbot360LoopRunning = true

    config.varibz.aimbot360LoopTask = task.spawn(function()
        while config.varibz.aimbot360LoopRunning do
            if config.aimbotEnabled and config.aimbot360Enabled then
                aimbotUpdate()
            else
                config.varibz.aimbot360LoopRunning = false
                break
            end

            task.wait(0.1)
        end

        config.varibz.aimbot360LoopRunning = false
        config.varibz.aimbot360LoopTask = nil
    end)
end

local function triggerBotUpdate()
    if not config.tbot.enabled then return end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local viewportSize = camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local fovRadius = config.tbot.fovRadius
    if config.tbot.holdToShoot then
        local uis = game:GetService("UserInputService")
        local key = Enum.KeyCode[config.tbot.holdKey] or Enum.KeyCode.MouseButton1
        if not uis:IsKeyDown(key) then
            return
        end
    end
    
    local targets = getAllTargets()
    local bestTarget = nil
    local bestDist = math.huge
    
    for _, target in ipairs(targets) do
        if target ~= localPlayer then
            local shouldTarget = false
            local char = getTargetCharacter(target)
            
            if not char then continue end
            if typeof(target) == "Instance" and target:IsA("Player") then
                local mode = config.masterTeamTarget or "Enemies"
                if mode == "Enemies" then
                    shouldTarget = not isTeammate(target)
                elseif mode == "Teams" then
                    shouldTarget = isTeammate(target)
                elseif mode == "All" then
                    shouldTarget = true
                end
            elseif typeof(target) == "Instance" and target:IsA("Model") then
                shouldTarget = true
            end
            
            if not shouldTarget then continue end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            if config.ignoreForcefield and hasForcefield(char) then continue end
            local targetPart = nil
            if config.tbot.targetPart == "Head" then
                targetPart = char:FindFirstChild("Head")
            elseif config.tbot.targetPart == "HumanoidRootPart" then
                targetPart = char:FindFirstChild("HumanoidRootPart")
            else
                targetPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            end
            
            if not targetPart then continue end
            local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
            if not onScreen or screenPos.Z <= 0 then continue end
            
            local screenVec = Vector2.new(screenPos.X, screenPos.Y)
            local distPx = (screenVec - center).Magnitude
            
            if distPx <= fovRadius then
                if config.tbot.wallCheck then
                    local ray = Ray.new(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * (targetPart.Position - camera.CFrame.Position).Magnitude)
                    local ignoreList = {localPlayer.Character}
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character then
                            table.insert(ignoreList, p.Character)
                        end
                    end
                    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
                    if hit and hit.Parent ~= char and hit.Parent.Parent ~= char then
                        continue
                    end
                end
                local chance = math.random(1, 100)
                if chance <= config.tbot.hitChance then
                    if distPx < bestDist then
                        bestDist = distPx
                        bestTarget = target
                    end
                end
            end
        end
    end
    if bestTarget then
        local char = getTargetCharacter(bestTarget)
        if char then
            local targetPart = nil
            if config.tbot.targetPart == "Head" then
                targetPart = char:FindFirstChild("Head")
            elseif config.tbot.targetPart == "HumanoidRootPart" then
                targetPart = char:FindFirstChild("HumanoidRootPart")
            else
                targetPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            end
            
            if targetPart then
                local tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function()
                        tool:Activate()
                    end)
                else
                    local uis = game:GetService("UserInputService")
                    local VirtualInputManager = game:GetService("VirtualInputManager")
                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(config.tbot.delay or 0.1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end)
                end
            end
        end
    end
end

local function createTriggerBotFOV()
    if config.tbot.fovCircle and config.tbot.fovCircle.ScreenGui and config.tbot.fovCircle.ScreenGui.Parent then
        config.tbot.fovCircle.ScreenGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TriggerBotFOV"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    local ringFrame = Instance.new("Frame")
    ringFrame.Name = "TriggerFOVRing"
    ringFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ringFrame.Size = UDim2.new(0, config.tbot.fovRadius * 2, 0, config.tbot.fovRadius * 2)
    ringFrame.Position = UDim2.new(0.5, 0, 0.5, -28)
    ringFrame.BackgroundTransparency = 1
    ringFrame.Visible = config.tbot.enabled and config.tbot.fovVisible
    ringFrame.Parent = screenGui
    
    local ringCorner = Instance.new("UICorner")
    ringCorner.CornerRadius = UDim.new(1, 0)
    ringCorner.Parent = ringFrame
    
    local ringStroke = Instance.new("UIStroke")
    ringStroke.Thickness = 1.5
    ringStroke.LineJoinMode = Enum.LineJoinMode.Round
    ringStroke.Color = config.tbot.fovColor
    ringStroke.Transparency = 1 - config.tbot.fovTransparency
    ringStroke.Parent = ringFrame
    
    config.tbot.fovCircle = {
        ScreenGui = screenGui,
        RingFrame = ringFrame,
        RingStroke = ringStroke
    }
    
    return config.tbot.fovCircle
end

local function updateTriggerBotFOV()
    if config.tbot.fovCircle and config.tbot.fovCircle.RingFrame then
        config.tbot.fovCircle.RingFrame.Size = UDim2.new(0, config.tbot.fovRadius * 2, 0, config.tbot.fovRadius * 2)
        config.tbot.fovCircle.RingFrame.Visible = config.tbot.enabled and config.tbot.fovVisible
        config.tbot.fovCircle.RingStroke.Color = config.tbot.fovColor
        config.tbot.fovCircle.RingStroke.Transparency = 1 - config.tbot.fovTransparency
    end
end

local function toggleTriggerBot(state)
    config.tbot.enabled = state
    
    if state then
        createTriggerBotFOV()
        if not config.varibz.triggerBotConnection then
            config.varibz.triggerBotConnection = RunService.Heartbeat:Connect(triggerBotUpdate)
        end
    else
        if config.tbot.fovCircle and config.tbot.fovCircle.ScreenGui then
            config.tbot.fovCircle.ScreenGui:Destroy()
            config.tbot.fovCircle = nil
        end
        if config.varibz.triggerBotConnection then
            config.varibz.triggerBotConnection:Disconnect()
            config.varibz.triggerBotConnection = nil
        end
    end
end

local function spinbotUpdate()
    if not config.spinbot.enabled then
        if config.varibz.spinbotConnection then
            config.varibz.spinbotConnection:Disconnect()
            config.varibz.spinbotConnection = nil
        end
        return
    end
    
    if not localPlayer.Character then return end
    
    local character = localPlayer.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    if not config.varibz.spinbotConnection then
        config.varibz.spinbotConnection = RunService.RenderStepped:Connect(function()
            if not config.spinbot.enabled or not localPlayer.Character then
                return
            end
            
            local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            local currentCFrame = rootPart.CFrame
            local speed = config.spinbot.speed or 50
            local angle = (speed / 100) * 10
            local rotation = CFrame.Angles(0, angle * (1/60), 0)
            local newCFrame = currentCFrame * rotation
            rootPart.CFrame = newCFrame
        end)
    end
end

local function bhopUpdate()
    if not config.bhop.enabled then return end
    
    local character = localPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    local isOnGround = humanoid:GetState() == Enum.HumanoidStateType.Landed or 
                       humanoid:GetState() == Enum.HumanoidStateType.Running or
                       humanoid:GetState() == Enum.HumanoidStateType.Walking
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local velocity = rootPart.Velocity
        local isFalling = velocity.Y < -1
        local isMoving = math.abs(velocity.X) > 0.5 or math.abs(velocity.Z) > 0.5
        if isOnGround and isMoving then
            local currentTime = tick()
            if currentTime - config.varibz.lastJumpTime >= config.bhop.jumpDelay then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                config.varibz.lastJumpTime = currentTime
            end
        end
    end
end

local function toggleBHop(state)
    config.bhop.enabled = state
    
    if state then
        if config.varibz.bhopConnection then
            config.varibz.bhopConnection:Disconnect()
            config.varibz.bhopConnection = nil
        end
        config.varibz.bhopConnection = RunService.Heartbeat:Connect(bhopUpdate)
    else
        if config.varibz.bhopConnection then
            config.varibz.bhopConnection:Disconnect()
            config.varibz.bhopConnection = nil
        end
    end
end

local function createBHopQuickToggle()
    if config.varibz.bhopQuickToggleUI and config.varibz.bhopQuickToggleUI.ScreenGui then
        config.varibz.bhopQuickToggleUI.ScreenGui:Destroy()
        config.varibz.bhopQuickToggleUI = nil
    end
    
    if not config.bhop.quickToggleEnabled then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BHopQuickToggle"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 110, 0, 36)
    main.Position = UDim2.new(0, 10, 0, 110)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    main.BorderSizePixel = 0
    main.AnchorPoint = Vector2.new(0, 0)
    main.Active = true
    main.Draggable = config.bhop.quickToggleDraggable
    main.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 6)
    mainCorner.Parent = main
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -44, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.bhop.enabled and "BHop<" or "BHop"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = main
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 34, 0, 16)
    toggleBg.Position = UDim2.new(1, -38, 0.5, -8)
    toggleBg.BackgroundColor3 = config.bhop.enabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(15, 15, 15)
    toggleBg.BorderSizePixel = 0
    toggleBg.BackgroundTransparency = 0
    toggleBg.ClipsDescendants = false
    toggleBg.Parent = main
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleBg
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = config.bhop.enabled and UDim2.new(1, -16, 0, 1) or UDim2.new(0, 1, 0, 1)
    circle.BackgroundColor3 = config.bhop.enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
    circle.BorderSizePixel = 0
    circle.Parent = toggleBg
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    local function toggleBHopUI()
        local newState = not config.bhop.enabled
        toggleBHop(newState)
        
        label.Text = newState and "BHop<" or "BHop"
        
        if newState then
            local onTween = TweenService:Create(circle, tweenInfo, {
                Position = UDim2.new(1, -16, 0, 1),
                BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            })
            local bgOnTween = TweenService:Create(toggleBg, tweenInfo, {
                BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            })
            onTween:Play()
            bgOnTween:Play()
        else
            local offTween = TweenService:Create(circle, tweenInfo, {
                Position = UDim2.new(0, 1, 0, 1),
                BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            })
            local bgOffTween = TweenService:Create(toggleBg, tweenInfo, {
                BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            })
            offTween:Play()
            bgOffTween:Play()
        end
    end
    
    local isPressing = false
    local wasPressedHere = false
    local inputStartTime = 0
    local inputStartPosition = nil
    local minPressTime = 0.05
    
    local function onInputBegan(input, gameProcessedEvent)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not gameProcessedEvent then
                isPressing = true
                wasPressedHere = true
                inputStartTime = tick()
                inputStartPosition = input.Position
            end
        end
    end
    
    local function onInputEnded(input, gameProcessedEvent)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isPressing and wasPressedHere and not gameProcessedEvent then
                local pressDuration = tick() - inputStartTime
                local endPosition = input.Position
                local distanceMoved = inputStartPosition and (endPosition - inputStartPosition).Magnitude or 0
                
                if pressDuration >= minPressTime and distanceMoved < 10 then
                    toggleBHopUI()
                end
            end
            isPressing = false
            wasPressedHere = false
            inputStartPosition = nil
        end
    end
    
    local function onInputChanged(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if isPressing and inputStartPosition then
                local distanceMoved = (input.Position - inputStartPosition).Magnitude
                if distanceMoved > 20 then
                    wasPressedHere = false
                end
            end
        end
    end
    
    toggleBg.InputBegan:Connect(onInputBegan)
    toggleBg.InputChanged:Connect(onInputChanged)
    toggleBg.InputEnded:Connect(onInputEnded)
    circle.InputBegan:Connect(onInputBegan)
    circle.InputChanged:Connect(onInputChanged)
    circle.InputEnded:Connect(onInputEnded)
    config.varibz.bhopQuickToggleUI = {
        ScreenGui = screenGui,
        Main = main,
        Label = label,
        ToggleBg = toggleBg,
        Circle = circle
    }
end


local function updateBHopQuickToggle()
    if config.bhop.quickToggleEnabled then
        createBHopQuickToggle()
    else
        if config.varibz.bhopQuickToggleUI and config.varibz.bhopQuickToggleUI.ScreenGui then
            config.varibz.bhopQuickToggleUI.ScreenGui:Destroy()
            config.varibz.bhopQuickToggleUI = nil
        end
    end
end

local ineedinvistool = function()
local offset = 1100
local invisible = false
local grips = {}
local heldTool
local gripChanged
local handle
local weld
local animstate
function setDisplayDistance(distance)
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChildWhichIsA("Humanoid") then
            player.Character:FindFirstChildWhichIsA("Humanoid").NameDisplayDistance = distance
            player.Character:FindFirstChildWhichIsA("Humanoid").HealthDisplayDistance = distance
        end
    end
end
function invis()
    if not invisible then
        invisible = true
        animstate = game.Players.LocalPlayer.Character.Animate.Enabled
        game.Players.LocalPlayer.Character.Animate.Enabled = false
        for _, track in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
        if handle then handle:Destroy() end
        if weld then weld:Destroy() end
        handle = Instance.new("Part", workspace)
        handle.Name = "Handle"
        handle.Transparency = 1
        handle.CanCollide = false
        handle.Size = Vector3.new(2, 1, 1)
        weld = Instance.new("Weld", handle)
        weld.Part0 = handle
        weld.Part1 = game.Players.LocalPlayer.Character.HumanoidRootPart
        weld.C0 = CFrame.new(0, offset - 1.5, 0)
        setDisplayDistance(offset + 100)
        workspace.CurrentCamera.CameraSubject = handle
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, offset, 0)
        game.Players.LocalPlayer.Character.Humanoid.HipHeight = offset
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(11)
        for _, child in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
            if child:IsA("Tool") then
                grips[child] = child.Grip
            end
        end
    end
end
function vis()
    if invisible then
        invisible = false
        if handle then handle:Destroy() end
        if weld then weld:Destroy() end
        game.Players.LocalPlayer.Character.Animate.Enabled = animstate or true
        for _, child in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if child:IsA("Tool") then
                child.Parent = game.Players.LocalPlayer.Backpack
            end
        end
        for tool, grip in pairs(grips) do
            if tool then
                tool.Grip = grip
            end
        end
        heldTool = nil
        setDisplayDistance(100)
        workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -offset, 0)
        game.Players.LocalPlayer.Character.Humanoid.HipHeight = 0
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end
local tool = Instance.new("Tool", game.Players.LocalPlayer.Backpack)
tool.Name = "go invis"
tool.RequiresHandle = false
tool.CanBeDropped = false
tool.Equipped:Connect(function()
    wait()
    if not invisible then
        invis()
        tool.Name = ">:3"
    else
        vis()
        tool.Name = ":3"
    end
    tool.Parent = game.Players.LocalPlayer.Backpack
end)
game.Players.LocalPlayer.Character.ChildAdded:Connect(function(child)
    wait()
    if invisible and child:IsA("Tool") and child ~= heldTool and child ~= tool then
        heldTool = child
        local lastGrip = heldTool.Grip
        if not grips[heldTool] then
            grips[heldTool] = lastGrip
        end
        game.Players.LocalPlayer.Character.Animate.Enabled = false
        for _, track in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
        
        heldTool.Grip = heldTool.Grip * (CFrame.new(0, offset - 1.5, 1.5) * CFrame.Angles(math.rad(-90), 0, 0))
        heldTool.Parent = game.Players.LocalPlayer.Backpack
        heldTool.Parent = game.Players.LocalPlayer.Character
        
        if gripChanged then
            gripChanged:Disconnect()
        end
        
        gripChanged = heldTool:GetPropertyChangedSignal("Grip"):Connect(function()
            wait()
            if not invisible then
                gripChanged:Disconnect()
            end
            if heldTool.Grip ~= lastGrip then
                lastGrip = heldTool.Grip * (CFrame.new(0, offset - 1.5, 1.5) * CFrame.Angles(math.rad(-90), 0, 0))
                heldTool.Grip = lastGrip
                heldTool.Parent = game.Players.LocalPlayer.Backpack
                heldTool.Parent = game.Players.LocalPlayer.Character
            end
        end)
    end
end)
end

-- bk
RunService.Heartbeat:Connect(function(deltaTime)
    aimbotUpdate()
    updateLineESP()
    hb()
    antiAimUpdate()
end)

local function isMobileDevice()
    local ok, val = pcall(function() return UserInputService.TouchEnabled end)
    return ok and val
end
local function CreateQT()
    if gui.mobileGui and gui.mobileGui.ScreenGui and gui.mobileGui.ScreenGui.Parent then
        gui.mobileGui.ScreenGui.Enabled = true
        return
    elseif gui.mobileGui and gui.mobileGui.ScreenGui and not gui.mobileGui.ScreenGui.Parent then
        gui.mobileGui = nil
    end
    
    if gui.mobileGui and gui.mobileGui.ScreenGui and gui.mobileGui.ScreenGui.Parent then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GravelQT"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

    local function QuickToggle(name, positionX, positionY, getter, setter)
        local main = Instance.new("Frame")
        main.Size = UDim2.new(0, 120, 0, 40)
        main.Position = UDim2.new(0, positionX, 0, positionY)
        main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        main.BorderSizePixel = 0
        main.AnchorPoint = Vector2.new(0, 0)
        main.Active = true
        main.Draggable = config.QTDrag
        main.Parent = screenGui

        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 6)
        mainCorner.Parent = main
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.Parent = main

        local toggleBg = Instance.new("Frame")
        toggleBg.Size = UDim2.new(0, 38, 0, 18)
        toggleBg.Position = UDim2.new(1, -44, 0.5, -9)
        toggleBg.BackgroundColor3 = getter() and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(15, 15, 15)
        toggleBg.BorderSizePixel = 0
        toggleBg.BackgroundTransparency = 0
        toggleBg.ClipsDescendants = false
        toggleBg.Parent = main

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 9)
        toggleCorner.Parent = toggleBg
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 16, 0, 16)
        circle.Position = getter() and UDim2.new(1, -18, 0, 1) or UDim2.new(0, 1, 0, 1)
        circle.BackgroundColor3 = getter() and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
        circle.BorderSizePixel = 0
        circle.Parent = toggleBg

        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = circle
        local touchButton = Instance.new("TextButton")
        touchButton.Size = UDim2.new(0.4, 0, 0.5, 0)
        touchButton.Position = UDim2.new(0, 70, 0, 9)
        touchButton.BackgroundTransparency = 1
        touchButton.Text = ""
        touchButton.ZIndex = 10
        touchButton.Parent = main

        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local function toggleOn()
            local onTween = TweenService:Create(circle, tweenInfo, {
                Position = UDim2.new(1, -18, 0, 1),
                BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            })
            local bgOnTween = TweenService:Create(toggleBg, tweenInfo, {
                BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            })
            onTween:Play()
            bgOnTween:Play()
        end

        local function toggleOff()
            local offTween = TweenService:Create(circle, tweenInfo, {
                Position = UDim2.new(0, 1, 0, 1),
                BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            })
            local bgOffTween = TweenService:Create(toggleBg, tweenInfo, {
                BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            })
            offTween:Play()
            bgOffTween:Play()
        end
        local function toggle()
            local newState = not getter()
            setter(newState)
            
            if newState then
                toggleOn()
                if name == "Silent Aim (HB)" then
                    if gui.RingHolder then gui.RingHolder.Visible = true end
                elseif name == "Aim bot" then
                    handleAimbotToggle(true)
                elseif name == "Auto Farm" then
                    autoFarmProcess()
                elseif name == "Anti Aim" then
                elseif name == "Hit box" then
                    applyhb()
                elseif name == "Client Config" then
                    applyClientMaster(true)
                elseif name == "ESP" then
                    applyESPMaster(true)
                end
            else
                toggleOff()
                if name == "Silent Aim (HB)" then
                    if gui.RingHolder then gui.RingHolder.Visible = false end
                    for pl, _ in pairs(config.activeApplied) do
                        restorePartForPlayer(pl)
                    end
                elseif name == "Aim bot" then
                    handleAimbotToggle(false)
                elseif name == "Auto Farm" then
                    stopAutoFarm()
                elseif name == "Anti Aim" then
                    returnToOriginalPosition()
                elseif name == "Hit box" then
                    local targetsToRemove = {}
                    for pl, _ in pairs(config.hitboxExpandedParts) do
                        table.insert(targetsToRemove, pl)
                    end
                    for _, pl in ipairs(targetsToRemove) do
                        restoreTorso(pl)
                    end
                elseif name == "Client Config" then
                    applyClientMaster(false)
                elseif name == "ESP" then
                    applyESPMaster(false)
                end
            end
            
            label.Text = getter() and name .. "<" or name
        end

        local inputStartTime = 0
        local minPressTime = 0.05
        local inputStartPosition = nil
        local isPressing = false
        local wasPressedHere = false
        local function onInputBegan(input, gameProcessedEvent)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if not gameProcessedEvent then
                    isPressing = true
                    wasPressedHere = true
                    inputStartTime = tick()
                    inputStartPosition = input.Position
                    
                    if input.UserInputType == Enum.UserInputType.Touch then
                        local feedback = Instance.new("Frame")
                        feedback.Name = "TouchFeedback"
                        feedback.Size = UDim2.new(0, 40, 0, 40)
                        feedback.Position = UDim2.new(0, inputStartPosition.X - 20, 0, inputStartPosition.Y - 20)
                        feedback.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        feedback.BackgroundTransparency = 0.7
                        feedback.BorderSizePixel = 0
                        local corner = Instance.new("UICorner")
                        corner.CornerRadius = UDim.new(1, 0)
                        corner.Parent = feedback
                        feedback.Parent = screenGui
                        
                        local fadeOut = TweenService:Create(feedback, TweenInfo.new(0.3), {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0, 0, 0, 0)
                        })
                        fadeOut:Play()
                        fadeOut.Completed:Connect(function()
                            feedback:Destroy()
                        end)
                    end
                end
            end
        end
        local function onInputEnded(input, gameProcessedEvent)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if isPressing and wasPressedHere and not gameProcessedEvent then
                    local pressDuration = tick() - inputStartTime
                    local endPosition = input.Position
                    
                    local distanceMoved = 0
                    if inputStartPosition then
                        distanceMoved = (endPosition - inputStartPosition).Magnitude
                    end
                    
                    if pressDuration >= minPressTime and distanceMoved < 10 then
                        toggle()
                    end
                end
                isPressing = false
                wasPressedHere = false
                inputStartPosition = nil
            end
        end
        local function onInputChanged(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if isPressing and inputStartPosition then
                    local currentPosition = input.Position
                    local distanceMoved = (currentPosition - inputStartPosition).Magnitude
                    if distanceMoved > 20 then
                        wasPressedHere = false
                    end
                end
            end
        end
        toggleBg.InputBegan:Connect(function(...) onInputBegan(...) end)
        toggleBg.InputChanged:Connect(onInputChanged)
        toggleBg.InputEnded:Connect(function(...) onInputEnded(...) end)
        circle.InputBegan:Connect(function(...) onInputBegan(...) end)
        circle.InputChanged:Connect(onInputChanged)
        circle.InputEnded:Connect(function(...) onInputEnded(...) end)

        touchButton.InputBegan:Connect(function(...) onInputBegan(...) end)
        touchButton.InputChanged:Connect(onInputChanged)
        touchButton.InputEnded:Connect(function(...) onInputEnded(...) end)

        label.Text = getter() and name .. "<" or name
        
        return {
            main = main,
            touchButton = touchButton,
            toggleBg = toggleBg,
            circle = circle,
            label = label
        }
    end

    local buttons = {}
    local startX = 10
    local topRowY = 10
    local bottomRowY = 60
    local toggleWidth = 120
    local horizontalSpacing = 10
    
    buttons.SilentAim = QuickToggle("Silent Aim (HB)", startX, topRowY, 
        function() return config.startsa end, 
        function(v) config.startsa = v end)
    
    buttons.Hitbox = QuickToggle("Hit box", startX + (toggleWidth + horizontalSpacing) * 1, topRowY,
        function() return config.hitboxEnabled end,
        function(v) config.hitboxEnabled = v end)
    
    buttons.AntiAim = QuickToggle("Anti Aim", startX + (toggleWidth + horizontalSpacing) * 2, topRowY,
        function() return config.antiAimEnabled end,
        function(v) config.antiAimEnabled = v end)
    
    buttons.Aimbot = QuickToggle("Aim bot", startX + (toggleWidth + horizontalSpacing) * 3, topRowY,
        function() return config.aimbotEnabled end,
        function(v) handleAimbotToggle(v) end)
    
    buttons.ClientConfig = QuickToggle("Client Config", startX + (toggleWidth + horizontalSpacing) * 4, topRowY,
        function() return config.clientMasterEnabled end,
        function(v) applyClientMaster(v) end)
    
    local espX = startX + (toggleWidth + horizontalSpacing) * 0
    buttons.ESP = QuickToggle("ESP", espX, bottomRowY,
        function() return config.espMasterEnabled end,
        function(v) applyESPMaster(v) end)

    local silentAimHKX = startX + (toggleWidth + horizontalSpacing) * 1
    buttons.SilentAimHK = QuickToggle("SilentAim (HK)", silentAimHKX, bottomRowY,
        function() return config.SA2_Enabled end,
        function(v) 
            config.SA2_Enabled = v 
        end)


    gui.mobileGui = {
        ScreenGui = screenGui,
        Buttons = buttons
    }

    if gui.RingHolder then
        gui.RingHolder.Visible = config.startsa
    end
    if config.aimbotFOVRing and config.aimbotFOVRing.RingFrame then
        config.aimbotFOVRing.RingFrame.Visible = config.aimbotEnabled and not config.aimbot360Enabled
    end
end
local function KillQT()
    if gui and gui.mobileGui and gui.mobileGui.ScreenGui then
        pcall(function()
            gui.mobileGui.ScreenGui:Destroy()
        end)
    end
    gui.mobileGui = nil
end
local function UpdateQT()
    if not isMobileDevice() then
        if gui.mobileGui and gui.mobileGui.ScreenGui then
            gui.mobileGui.ScreenGui.Enabled = false
        end
        return
    end
    
    if not config.QuickToggles then
        if gui.mobileGui and gui.mobileGui.ScreenGui then
            gui.mobileGui.ScreenGui.Enabled = false
        end
        return
    end
    
    if not gui.mobileGui or not gui.mobileGui.ScreenGui or not gui.mobileGui.ScreenGui.Parent then
        CreateQT()
        return
    end
    
    gui.mobileGui.ScreenGui.Enabled = true
    if gui.mobileGui.Buttons then
        for _, buttonData in pairs(gui.mobileGui.Buttons) do
            if buttonData and buttonData.main then
                buttonData.main.Draggable = config.QTDrag
            end
        end
    end
    if gui.mobileGui.Buttons then
        local buttonStates = {
            SilentAim = config.startsa,
            Aimbot = config.aimbotEnabled,
            AutoFarm = config.autoFarmEnabled,
            AntiAim = config.antiAimEnabled,
            Hitbox = config.hitboxEnabled,
            ClientConfig = config.clientMasterEnabled,
            ESP = config.espMasterEnabled,
            SilentAimHK = config.SA2_Enabled
        }
        
        for buttonName, isEnabled in pairs(buttonStates) do
            local buttonData = gui.mobileGui.Buttons[buttonName]
            if buttonData and buttonData.label then
                buttonData.label.Text = isEnabled and buttonName .. "<" or buttonName
                
                if buttonData.toggleBg then
                    buttonData.toggleBg.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(15, 15, 15)
                end
                
                if buttonData.circle then
                    buttonData.circle.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
                    buttonData.circle.Position = isEnabled and UDim2.new(1, -18, 0, 1) or UDim2.new(0, 1, 0, 1)
                end
            end
        end
    end
end
local function onRenderStep()
    if not camera or not camera.Parent then
        camera = workspace.CurrentCamera
        if not camera then return end
    end

    if not gui.RingHolder or not gui.RingStroke then return end

    if not config.startsa then
        gui.RingHolder.Visible = false
        return
    else
        gui.RingHolder.Visible = true
    end

    local viewportSize = camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local radiusPx = config.fovsize

    if gui.RingHolder then
        local currentSize = gui.RingHolder.AbsoluteSize and gui.RingHolder.AbsoluteSize.X or (config.fovsize * 2)
        radiusPx = currentSize / 2
    end

    local candidates = {}
    local allTargetsInFOV = {}
    
    for _, pl in ipairs(getAllTargets()) do
        local bodyPart, chosenName = chooseBodyPartInstance(pl)
        local humanoid = nil
        local char = getTargetCharacter(pl)
        if char then
            humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if hasForcefield(char) then continue end
        end

        if bodyPart and humanoid and humanoid.Health > 0 then
            local skip = false
            local mode = config.masterTeamTarget or "Enemies"
            
            if mode == "Enemies" then
                if typeof(pl) == "Instance" and pl:IsA("Player") and isTeammate(pl) then
                    skip = true
                end
            elseif mode == "Teams" then
                if typeof(pl) == "Instance" and pl:IsA("Player") and not isTeammate(pl) then
                    skip = true
                end
            elseif mode == "All" then
                skip = false
            end

            if not skip then
                local topPos = bodyPart.Position
                local screenPos3, onScreen = camera:WorldToViewportPoint(topPos)
                if onScreen then
                    local screenVec = Vector2.new(screenPos3.X, screenPos3.Y)
                    local distPx = (screenVec - center).Magnitude

                    table.insert(allTargetsInFOV, {
                        player = pl,
                        part = bodyPart,
                        partName = chosenName,
                        screenDist = distPx,
                        worldDist = (camera.CFrame.Position - topPos).Magnitude,
                        screenPos = screenVec,
                        screenPos3 = screenPos3,
                        humanoid = humanoid,
                        inFOV = distPx <= radiusPx
                    })
                    
                    if distPx <= radiusPx then
                        local cameraPos = camera.CFrame.Position
                        local targetPos = bodyPart.Position
                        if wallCheck(targetPos, cameraPos) then
                            local worldDist = (cameraPos - targetPos).Magnitude
                            table.insert(candidates, {
                                player = pl,
                                part = bodyPart,
                                partName = chosenName,
                                screenDist = distPx,
                                worldDist = worldDist,
                                screenPos = screenVec,
                                screenPos3 = screenPos3,
                                humanoid = humanoid
                            })
                        end
                    end
                end
            end
        else
            if config.activeApplied[pl] then
                restorePartForPlayer(pl)
            end
        end
    end

    local best = nil
    if config.silentGetTarget == "TargetSeen" then
        local targetsInFOV = {}
        for _, target in ipairs(allTargetsInFOV) do
            if target.inFOV then
                local cameraPos = camera.CFrame.Position
                local targetPos = target.part.Position
                if wallCheck(targetPos, cameraPos) then
                    table.insert(targetsInFOV, target)
                end
            end
        end
        config.targetSeenTargets = targetsInFOV
        
        if #targetsInFOV > 0 then
            if config.targetSeenMode == "Switch" then
                local currentTime = tick()
                if currentTime - config.lastTargetSwitchTime >= config.targetSeenSwitchRate then
                    config.lastTargetSwitchTime = currentTime
                    if not config.currentTarget then
                        local randomIndex = math.random(1, #targetsInFOV)
                        best = targetsInFOV[randomIndex]
                    else
                        local currentIndex = nil
                        for i, target in ipairs(targetsInFOV) do
                            if target.player == config.currentTarget then
                                currentIndex = i
                                break
                            end
                        end
                        
                        if currentIndex then
                            local nextIndex = (currentIndex % #targetsInFOV) + 1
                            best = targetsInFOV[nextIndex]
                        else
                            local randomIndex = math.random(1, #targetsInFOV)
                            best = targetsInFOV[randomIndex]
                        end
                    end
                else
                    if config.currentTarget then
                        for _, target in ipairs(targetsInFOV) do
                            if target.player == config.currentTarget then
                                best = target
                                break
                            end
                        end
                    end
                end
            elseif config.targetSeenMode == "All" then
                for _, target in ipairs(targetsInFOV) do
                    if target.player ~= config.currentTarget then
                        local diameter = calculateDiameter(target.worldDist, radiusPx, camera)
                        applySizeToPart(target.player, diameter, target.part)
                    end
                end
                local closestDist = math.huge
                for _, target in ipairs(targetsInFOV) do
                    if target.worldDist < closestDist then
                        closestDist = target.worldDist
                        best = target
                    end
                end
            end
        else
            best = nil
        end
    else
        if #candidates > 0 then
            if config.silentGetTarget == "Lowest Health" then
                local bestHealth = math.huge
                for _, c in ipairs(candidates) do
                    local h = c.humanoid and c.humanoid.Health or math.huge
                    if best == nil or h < bestHealth then
                        bestHealth = h
                        best = c
                    end
                end
            else
                local bestWorldDist = math.huge
                for _, c in ipairs(candidates) do
                    if c.worldDist < bestWorldDist then
                        bestWorldDist = c.worldDist
                        best = c
                    end
                end
            end
        end
    end

    if best then
        gui.RingStroke.Color = config.fovct or config.fovc
    else
        gui.RingStroke.Color = config.fovc
    end
    if config.currentTarget ~= (best and best.player) then
        config.currentTarget = best and best.player
        updateESPColors()
    end

    local targetsToRemove = {}
    for pl, _ in pairs(config.activeApplied) do
        local shouldRemove = true
        
        if best and pl == best.player then
            shouldRemove = false
        elseif config.silentGetTarget == "TargetSeen" and config.targetSeenMode == "All" then
            local stillInFOV = false
            for _, target in ipairs(config.targetSeenTargets or {}) do
                if target.player == pl then
                    stillInFOV = true
                    break
                end
            end
            shouldRemove = not stillInFOV
        end
        
        if shouldRemove or not plralive(pl) then
            table.insert(targetsToRemove, pl)
        end
    end
    
    for _, pl in ipairs(targetsToRemove) do
        restorePartForPlayer(pl)
    end

    if best and plralive(best.player) then
        local function calculateDiameter(worldDist, screenRadius, cam)
            local viewportSize = cam.ViewportSize
            local H = viewportSize.Y
            local vFovDeg = cam.FieldOfView
            local vFovRad = math.rad(vFovDeg)
            local halfVFov = vFovRad / 2
            local alpha = (screenRadius / (H / 2)) * halfVFov
            local worldHalf = worldDist * math.tan(alpha)
            local worldFull = worldHalf * 2
            return math.max(0.01, worldFull)
        end
        
        local diameter = calculateDiameter(best.worldDist, radiusPx, camera)
        diameter = math.max(0.01, diameter)

        local localChar = localPlayer.Character
        local targetChar = getTargetCharacter(best.player)
        local distance = math.huge

        if localChar and targetChar then
            local localRoot = localChar:FindFirstChild("HumanoidRootPart") or localChar:FindFirstChild("Head")
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")

            if localRoot and targetRoot then
                distance = (localRoot.Position - targetRoot.Position).Magnitude
            end
        end

        local studz = 5 
        if distance <= studz then
            diameter = math.max(0.05, math.min(0.1, diameter))
        else
            local ok, pixelRadius = pcall(function()
                local rightWorld = camera.CFrame:VectorToWorldSpace(Vector3.new(1, 0, 0)).Unit
                local upWorld = camera.CFrame:VectorToWorldSpace(Vector3.new(0, 1, 0)).Unit
                local worldHalf = diameter / 2
                local maxPixel = 0
                local samples = 16
                for i = 0, samples - 1 do
                    local angle = (i / samples) * 2 * math.pi
                    local offsetWorld = rightWorld * math.cos(angle) * worldHalf + upWorld * math.sin(angle) * worldHalf
                    local samplePointWorld = best.part.Position + offsetWorld
                    local sp, onScreenSample = camera:WorldToViewportPoint(samplePointWorld)
                    if onScreenSample then
                        local sampleScreen = Vector2.new(sp.X, sp.Y)
                        local d = (sampleScreen - best.screenPos).Magnitude
                        if d > maxPixel then
                            maxPixel = d
                        end
                    end
                end

                if maxPixel <= 0 then
                    return nil
                end

                return maxPixel
            end)

            if ok and pixelRadius and pixelRadius > 0 then
                local scale = best.screenDist / pixelRadius
                scale = math.clamp(scale, 1 / config.maxExpansion, config.maxExpansion)
                diameter = math.max(0.01, diameter * scale)
            end
        end

        diameter = math.max(0.01, diameter)
        
        if best.screenDist <= 1 then
            if not config.centerLocked[best.player] then
                config.centerLocked[best.player] = true
                applySizeToPart(best.player, diameter, best.part)
            else
                local prevSize = config.targethbSizes[best.player]
                if prevSize then
                    diameter = prevSize.X
                end
                applySizeToPart(best.player, diameter, best.part)
            end
        else
            config.centerLocked[best.player] = nil
            applySizeToPart(best.player, diameter, best.part)
        end

        if config.rfd then
            RFD(best.player)
        end
    end
    
    if config.silentGetTarget == "TargetSeen" and config.targetSeenMode == "All" then
        for _, target in ipairs(config.targetSeenTargets or {}) do
            if target.player ~= (best and best.player) and plralive(target.player) then
                local diameter = calculateDiameter(target.worldDist, radiusPx, camera)
                diameter = math.max(0.01, diameter)
                applySizeToPart(target.player, diameter, target.part)
            end
        end
    end
end

local function getClosestVictim()
    if not Options.TargetPart.Value then return end
    local Closest
    local DistanceToMouse
    for _, Player in next, GetPlayers(Players) do
        if Player == LocalPlayer then continue end
        if Toggles.TeamCheck.Value and Player.Team == LocalPlayer.Team then continue end

        local Character = Player.Character
        if not Character then continue end
        
        if config.ignoreForcefield and hasForcefield(Character) then continue end
        
        if Toggles.VisibleCheck.Value and not IsPlayerVisible(Player) then continue end

        local HumanoidRootPart = FindFirstChild(Character, "HumanoidRootPart")
        local Humanoid = FindFirstChild(Character, "Humanoid")
        if not HumanoidRootPart or not Humanoid or Humanoid and Humanoid.Health <= 0 then continue end

        local ScreenPosition, OnScreen = getPositionOnScreen(HumanoidRootPart.Position)
        if not OnScreen then continue end

        local Distance = (getMousePosition() - ScreenPosition).Magnitude
        if Distance <= (DistanceToMouse or Options.Radius.Value or 2000) then
            Closest = ((Options.TargetPart.Value == "Random" and Character[ValidTargetParts[math.random(1, #ValidTargetParts)]]) or Character[Options.TargetPart.Value])
            DistanceToMouse = Distance
        end
    end
    return Closest
end

local function setupDeathListener(targetPlayer)
    local char = getTargetCharacter(targetPlayer)
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if config.characterConnections[targetPlayer] then
        pcall(function() config.characterConnections[targetPlayer]:Disconnect() end)
        config.characterConnections[targetPlayer] = nil
    end

    config.characterConnections[targetPlayer] = humanoid.Died:Connect(function()
        restorePartForPlayer(targetPlayer)
        restoreTorso(targetPlayer)
        if config.currentTarget == targetPlayer then
            config.currentTarget = nil
            updateESPColors()
        end
        if config.aimbotCurrentTarget == targetPlayer then
            config.aimbotCurrentTarget = nil
            updateESPColors()
        end
        if config.SA2_currentTarget == targetPlayer then
            config.SA2_currentTarget = nil
            updateESPColors()
        end
    end)
end

local function cleanplrdata(targetPlayer)
    if not targetPlayer then return end

    config.autoFarmOriginalPositions[targetPlayer] = nil
    config.autoFarmCompleted[targetPlayer] = nil
    
    if config.currentAutoFarmTarget == targetPlayer then
        config.currentAutoFarmTarget = nil
    end

    restorePartForPlayer(targetPlayer)
    restoreTorso(targetPlayer)
    removeESPLabel(targetPlayer)
    removeHighlightESP(targetPlayer)
    removeLineESP(targetPlayer)

    if config.playerConnections[targetPlayer] then
        for _, conn in ipairs(config.playerConnections[targetPlayer]) do
            pcall(function() conn:Disconnect() end)
        end
        config.playerConnections[targetPlayer] = nil
    end

    if config.characterConnections[targetPlayer] then
        pcall(function() config.characterConnections[targetPlayer]:Disconnect() end)
        config.characterConnections[targetPlayer] = nil
    end

    config.activeApplied[targetPlayer] = nil
    config.originalSizes[targetPlayer] = nil
    config.targethbSizes[targetPlayer] = nil
    config.hitboxExpandedParts[targetPlayer] = nil
    config.hitboxOriginalSizes[targetPlayer] = nil

    if config.currentTarget == targetPlayer then
        config.currentTarget = nil
        updateESPColors()
    end
    if config.aimbotCurrentTarget == targetPlayer then
        config.aimbotCurrentTarget = nil
        updateESPColors()
    end
    if config.SA2_currentTarget == targetPlayer then
        config.SA2_currentTarget = nil
        updateESPColors()
    end
end
local function setupPlayerListeners(pl)
    if pl == localPlayer then return end
    if config.playerConnections[pl] then
        for _, conn in ipairs(config.playerConnections[pl]) do
            pcall(function() conn:Disconnect() end)
        end
    end
    
    config.playerConnections[pl] = {}
    
    local function updateESPForPlayer()
        if config.espMasterEnabled then
            removeESPLabel(pl)
            removeHighlightESP(pl)
            
            if config.prefTextESP or config.prefBoxESP or config.prefHealthESP or config.prefHeadDotESP then
                if addesp(pl) then
                    makeesp(pl)
                end
            end
            
            if config.prefHighlightESP and pl.Character then
                if addesp(pl) then
                    high(pl)
                end
            end
        end
    end
    
    updateESPForPlayer()
    
    local charAddedConn = pl.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        
        setupDeathListener(pl)
        removeESPLabel(pl)
        removeHighlightESP(pl)
        task.wait(0.1)
        
        if config.hitboxEnabled and targethb(pl) then
            task.wait(0.2)
            expandhb(pl, config.hitboxSize)
        end
        
        if config.espMasterEnabled then
            if config.prefTextESP or config.prefBoxESP or config.prefHealthESP or config.prefHeadDotESP then
                if addesp(pl) then
                    makeesp(pl)
                end
            end
            
            if config.prefHighlightESP then
                if addesp(pl) and pl.Character then
                    high(pl)
                end
            end
        end
    end)
    table.insert(config.playerConnections[pl], charAddedConn)
    
    local charRemovingConn = pl.CharacterRemoving:Connect(function(char)
        removeESPLabel(pl)
        removeHighlightESP(pl)
        restoreTorso(pl)
    end)
    table.insert(config.playerConnections[pl], charRemovingConn)
    
    local teamChangedConn = pl:GetPropertyChangedSignal("Team"):Connect(function()
        task.wait(0.05)
        updateESPForPlayer()
        if config.hitboxEnabled then
            if targethb(pl) then
                expandhb(pl, config.hitboxSize)
            else
                restoreTorso(pl)
            end
        end
    end)
    table.insert(config.playerConnections[pl], teamChangedConn)
    
    if pl.Character then
        setupDeathListener(pl)
        if config.hitboxEnabled and targethb(pl) then
            task.wait(0.1)
            expandhb(pl, config.hitboxSize)
        end
    end
end
local function safeGetCharacter()
    if not localPlayer then return nil end
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    return character, humanoid, rootPart
end

local function TpWalkStart()
    if config._tpwalking then return end
    config._tpwalking = true

    task.spawn(function()
        while config._tpwalking and localPlayer and localPlayer.Character and localPlayer.Character.Parent do
            local character, humanoid, rootPart = safeGetCharacter()
            if not humanoid or humanoid.Health <= 0 or not rootPart then
                task.wait(0.1)
            else
                local delta = RunService.Heartbeat:Wait()
                if humanoid.MoveDirection.Magnitude > 0 then
                    local moveDirection = humanoid.MoveDirection.Unit
                    local velocity = moveDirection * (config.clientCFrameSpeed or 1) * 50
                    pcall(function()
                        rootPart.CFrame = rootPart.CFrame + velocity * delta
                    end)
                end
            end
            task.wait()
        end
        config._tpwalking = false
    end)
end

local function TpWalkStop()
    config._tpwalking = false
end

local _noclipConn
local function startNoclip()
    if _noclipConn then return end
    _noclipConn = RunService.Stepped:Connect(function()
        local char = localPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end)
    config.clientConnections.noclip = _noclipConn
end

local function stopNoclip()
    if _noclipConn then
        pcall(function() _noclipConn:Disconnect() end)
        _noclipConn = nil
        config.clientConnections.noclip = nil
    end
end

local function applyClientWalkSpeed(val)
    local character, humanoid = safeGetCharacter()
    if humanoid then
        if config.clientOriginals.WalkSpeed == nil then
            config.clientOriginals.WalkSpeed = humanoid.WalkSpeed
        end
        pcall(function() humanoid.WalkSpeed = val end)
    end
end

local function applyClientJumpPower(val)
    local character, humanoid = safeGetCharacter()
    if humanoid then
        if config.clientOriginals.JumpPower == nil then
            config.clientOriginals.JumpPower = humanoid.JumpPower or humanoid.JumpHeight or 0
        end
        pcall(function()
            if humanoid.JumpPower ~= nil then
                humanoid.JumpPower = val
            else
                humanoid.JumpHeight = val
            end
        end)
    end
end

local function restoreClientValues()
    local character, humanoid = safeGetCharacter()
    if humanoid then
        if config.clientOriginals.WalkSpeed then
            pcall(function() humanoid.WalkSpeed = config.clientOriginals.WalkSpeed end)
            config.clientOriginals.WalkSpeed = nil
        end
        if config.clientOriginals.JumpPower then
            pcall(function()
                if humanoid.JumpPower ~= nil then
                    humanoid.JumpPower = config.clientOriginals.JumpPower
                else
                    humanoid.JumpHeight = config.clientOriginals.JumpPower
                end
            end)
            config.clientOriginals.JumpPower = nil
        end
    end
    if config.clientCFrameWalkEnabled then
        TpWalkStop()
        config.clientCFrameWalkEnabled = false
    end
    if config.clientNoclip then
        stopNoclip()
        config.clientNoclip = false
    end
end

local function applyClientMaster(state)
    if config.clientMasterEnabled == state then
        return
    end
    config.clientMasterEnabled = state

    if state then
        if config.clientNoclipEnabled then
            startNoclip()
            config.clientNoclip = true
        end
        if config.clientCFrameWalkToggle then
            TpWalkStart()
            config.clientCFrameWalkEnabled = true
        end
        if config.clientWalkEnabled and config.clientWalkSpeed and config.clientWalkSpeed > 0 then
            applyClientWalkSpeed(config.clientWalkSpeed)
        end
        if config.clientJumpEnabled and config.clientJumpPower and config.clientJumpPower > 0 then
            applyClientJumpPower(config.clientJumpPower)
        end
        n({
            Title = "Client Master",
            Content = "Client features enabled",
            Audio = "rbxassetid://17208361335",
            Length = 1,
            Image = "rbxassetid://4483362458",
            BarColor = Color3.fromRGB(0, 170, 255)
        })
    else
        restoreClientValues()
        n({
            Title = "Client Master",
            Content = "Client features disabled",
            Audio = "rbxassetid://17208361335",
            Length = 1,
            Image = "rbxassetid://4483362458",
            BarColor = Color3.fromRGB(255, 0, 0)
        })
    end
end

--[[
     _      ___         ____  ______
    | | /| / (_)__  ___/ / / / /  _/
    | |/ |/ / / _ \/ _  / /_/ // /  
    |__/|__/_/_//_/\_,_/\____/___/
    
    Roblox UI Library for scripts
    
    To view the source code, see the `src/` folder on the official GitHub repository.
    
    Author: Footagesus (Footages, .ftgs, oftgs)
    Github: https://github.com/Footagesus/WindUI
    Discord: https://discord.gg/ftgs-development-hub-1300692552005189632
    License: MIT
]]
-- ui neuron activation starter
math.randomseed(os.time())
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isTablet = UserInputService.TouchEnabled and UserInputService.KeyboardEnabled

local size = config.Gradow.windowSize.pc
if isMobile then
    size = config.Gradow.windowSize.mobile
elseif isTablet then
    size = config.Gradow.windowSize.tablet
end

local Window = WindUI:CreateWindow({
    Title = rng5(),
    Author = "[dis guy Gpssickle]",
    Folder = "Gravel_Saves",
    Theme = "Dark",
    Icon = "rbxassetid://96858797315175",
	 IconSize = 38,
    Size = size,
    HideSearchBar = false,
    OpenButton = {
        Title = lezzzgoo,
        Enabled = true,
        Draggable = true,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 200, 200)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(144, 238, 144)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40))
        }),
        StrokeThickness = 0.1,
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Default"
    }
})
WindUI.Window:ToggleTransparency(true)

local function rng4()
    local usedConversations = {}
    local availableIndices = {}
    for i = 1, #config.varibz.convo do
        table.insert(availableIndices, i)
    end
    local tag = Window:Tag({
        Title = "",
        Icon = "github",
        Color = Color3.fromHex("#1c1c1c"),
        Border = true
    })
    if not tag then
        return
    end
    local currentText = ""
    local cursorVisible = true
    local function getPlayerInfo()
        local info = {}
        if lp_info then
            info.username = lp_info.lp_username or "Unknown"
            info.displayname = lp_info.lp_displayname or info.username
            info.id = lp_info.lp_id or "Unknown"
            info.accountage = lp_info.lp_accountage or "Unknown"
            info.retroscore = lp_info.lp_retroslopscore or "Unknown"
        else
            info.username = "Player"
            info.displayname = "Player"
            info.id = "Unknown"
            info.accountage = "Unknown"
            info.retroscore = "Unknown"
        end
        return info
    end
    
    local function isWindowMinimized()
        if not Window or not Window.UIElements or not Window.UIElements.Main then return true end
        local sizeY = Window.UIElements.Main.Size.Y.Offset
        if sizeY < 50 then return true end
        return false
    end
    
    task.spawn(function()
        while tag do
            if not isWindowMinimized() then
                cursorVisible = not cursorVisible
                if tag.SetTitle then
                    tag:SetTitle(currentText .. (cursorVisible and config.Gradow.textcursor or config.Gradow.textcursor2))
                end
            end
            task.wait(0.45)
        end
    end)
    
    local function setText(text)
        currentText = text
        if tag.SetTitle then
            tag:SetTitle(text .. (cursorVisible and config.Gradow.textcursor or config.Gradow.textcursor2))
        end
    end
    local function processText(text)
        local info = getPlayerInfo()
        local processed = text
        processed = processed:gsub("{username}", info.username)
        processed = processed:gsub("{displayname}", info.displayname)
        processed = processed:gsub("{userid}", info.id)
        processed = processed:gsub("{accountage}", info.accountage)
        processed = processed:gsub("{retroscore}", info.retroscore)
        return processed
    end
    
    local function getSpeedMultiplier(conversation)
        if type(conversation) == "table" and conversation.typesp then
            local speedVal = tonumber(conversation.typesp)
            if speedVal then
                if speedVal > 0 then
                    return 1 / speedVal
                elseif speedVal < 0 then
                    return math.abs(speedVal)
                end
            end
        end
        return 1
    end
    
    local function isLetter(char)
        return char:match("[%a]") ~= nil
    end
    
    local function getRepeatedRunLength(text, position)
        if position > #text then return 0 end
        local char = text:sub(position, position)
        if not isLetter(char) then return 0 end
        local runLength = 0
        for i = position, #text do
            if text:sub(i, i) == char then
                runLength = runLength + 1
            else
                break
            end
        end
        return runLength
    end
    
    local function typeText(text, speedMultiplier)
        local processedText = processText(text)
        local typed = ""
        local i = 1
        
        while i <= #processedText do
            while isWindowMinimized() do
                task.wait(0.1)
            end
            
            local char = processedText:sub(i, i)
            if char == "\n" then
                typed ..= char
                setText(typed)
                i = i + 1
                continue
            end
            local runLength = getRepeatedRunLength(processedText, i)
            if runLength > 2 then
                local repeatedChar = processedText:sub(i, i)
                local totalCharsInRun = runLength
                local charsTyped = 0
                typed ..= repeatedChar
                setText(typed)
                local delay = (math.random(config.varibz.defaults.minDelay, config.varibz.defaults.maxDelay) / 1000) * speedMultiplier
                task.wait(delay)
                charsTyped = charsTyped + 1
                i = i + 1
                local baseDelay = (math.random(config.varibz.defaults.minDelay, config.varibz.defaults.maxDelay) / 1000) * speedMultiplier
                while charsTyped < totalCharsInRun and i <= #processedText and processedText:sub(i, i) == repeatedChar do
                    typed ..= repeatedChar
                    setText(typed)
                    local holdDelay
                    if charsTyped <= 2 then
                        holdDelay = baseDelay * (math.random(15, 25) / 10)
                    else
                        holdDelay = baseDelay * (math.random(2, 5) / 10)
                    end
                    holdDelay = holdDelay * (math.random(8, 12) / 10)
                    
                    task.wait(holdDelay)
                    charsTyped = charsTyped + 1
                    i = i + 1
                end
                task.wait(baseDelay * math.random(1, 3))
            else
                typed ..= char
                setText(typed)
                
                local delay = (math.random(config.varibz.defaults.minDelay, config.varibz.defaults.maxDelay) / 1000) * speedMultiplier
                if char == " " then
                    delay = delay + (math.random(config.varibz.defaults.spaceExtraMin, config.varibz.defaults.spaceExtraMax) / 1000) * speedMultiplier
                elseif char:match("[%.%!%?,:]") then
                    delay = delay + (math.random(config.varibz.defaults.punctExtraMin, config.varibz.defaults.punctExtraMax) / 1000) * speedMultiplier
                end
                if math.random() < config.varibz.defaults.breakChance then
                    delay = delay + (math.random(config.varibz.defaults.breakExtraMin, config.varibz.defaults.breakExtraMax) / 1000) * speedMultiplier
                end
                task.wait(delay)
                i = i + 1
            end
        end
    end
    
    local function eraseText(speedMultiplier)
        local text = currentText
        for i = #text, 0, -1 do
            while isWindowMinimized() do
                task.wait(0.1)
            end
            setText(text:sub(1, i))
            task.wait((math.random(config.varibz.defaults.eraseDelayMin, config.varibz.defaults.eraseDelayMax) / 1000) * speedMultiplier)
        end
    end
    
    task.spawn(function()
        while tag do
            while isWindowMinimized() do
                task.wait(0.5)
            end
            
            if #availableIndices == 0 then
                for i = 1, #config.varibz.convo do
                    table.insert(availableIndices, i)
                end
                task.wait(math.random(config.varibz.defaults.shuffleWaitMin, config.varibz.defaults.shuffleWaitMax) / 10)
            end
            local randomPos = math.random(1, #availableIndices)
            local convoIndex = availableIndices[randomPos]
            table.remove(availableIndices, randomPos)
            local conversation = config.varibz.convo[convoIndex]
            if conversation then
                local speedMultiplier = getSpeedMultiplier(conversation)
                
                local messages = {}
                if type(conversation) == "table" then
                    for key, value in ipairs(conversation) do
                        table.insert(messages, value)
                    end
                else
                    messages = {conversation}
                end
                
                for index, message in ipairs(messages) do
                    typeText(message, speedMultiplier)
                    
                    if index < #messages then
                        local waitTime = (math.random(config.varibz.defaults.messageWaitMin, config.varibz.defaults.messageWaitMax) / 10) * speedMultiplier
                        task.wait(waitTime)
                        eraseText(speedMultiplier)
                    end
                end
                
                local convoWait = (math.random(config.varibz.defaults.convoWaitMin, config.varibz.defaults.convoWaitMax) / 10) * speedMultiplier
                task.wait(convoWait)
                eraseText(speedMultiplier)
                task.wait((math.random(config.varibz.defaults.eraseWaitMin, config.varibz.defaults.eraseWaitMax) / 10) * speedMultiplier)
            end
        end
    end)
    
    task.wait(1)
    local fpsTag = Window:Tag({
        Title = "FPS: 0",
        Icon = "clock",
        Color = Color3.fromHex("#00ff88")
    })
    if fpsTag then
        local accum = 0
        local function isWindowMinimized()
            if not Window or not Window.UIElements or not Window.UIElements.Main then return true end
            local sizeY = Window.UIElements.Main.Size.Y.Offset
            if sizeY < 50 then return true end
            return false
        end
        
        RunService.Heartbeat:Connect(function(deltaTime)
            if isWindowMinimized() then return end
            accum = accum + deltaTime
            if accum >= 0.3 then
                local fps = math.round(1 / math.max(deltaTime, 1e-6))
                if fpsTag.SetTitle then
                    fpsTag:SetTitle("FPS: " .. fps)
                end
                accum = accum - 0.3
            end
        end)
    end
    return tag
end
function rng()
    local Spotify = config.varibz.popz2[math.random(1, #config.varibz.popz2)]
    local YouTube = config.varibz.popz[math.random(1, #config.varibz.popz)]
    local Netflix = config.varibz.popz3[math.random(1, #config.varibz.popz3)]
    return WindUI:Popup({
        Title = Netflix,
        Icon = "shovel",
        Content = YouTube,
        Buttons = {
            {
                Title = Spotify,
                Icon = "hammer",
                Variant = "Tertiary"
            }
        }
    })
end
function rng2()
    local bju = config.varibz.tinf[math.random(1, #config.varibz.tinf)]
    local bju2 = config.varibz.tinf2[math.random(1, #config.varibz.tinf2)]
    local bju3 = config.varibz.tinf3[math.random(1, #config.varibz.tinf3)]
    n({
        Title = "Gravel.cc :3",
        Content = bju,
        Audio = bju3,
        Length = 10,
        Image = bju2,
        BarColor = Color3.fromRGB(0, 170, 255)
    })
end
task.wait(0.2)
uianijsyevxusuuwkaoxidhehhwiaosldjbnmate()
rng()
rng2()
rng4()
task.spawn(function()
    task.wait(0.5)
    SaveUI:autoLoad() 
end)
local MainTab = Window:Tab({
    Title = "Main",
    Desc = rng3("Main"),
    Icon = "hammer",
    IconColor = config.Gradow.uicolor.lightGray
}) do
    MainTab:Paragraph({
        Title = "MainTab Settings",
        Desc = "Global settings for targeting and utilities",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    MainTab:Paragraph({
        Title = "Global",
        Desc = "Global configurations",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    MainTab:Dropdown({
        Title = "Team Target",
        Desc = "Select Target Team",
        Values = {"Enemies", "Teams", "All"},
        Value = config.masterTeamTarget or "Enemies",
        Multi = false,
        Callback = function(Option)
            config.masterTeamTarget = Option
            if Option == "All" then
                config.targetMode = "All"
                config.aimbotTeamTarget = "All"
                config.hitboxTeamTarget = "All"
                config.SA2_TeamTarget = "All"
                config.antiAimTarget = "All"
            else
                config.targetMode = Option
                config.aimbotTeamTarget = Option
                config.hitboxTeamTarget = Option
                config.SA2_TeamTarget = Option
                config.antiAimTarget = Option
            end
            
            updateTeamTargetModes()
            syncSilentAimWithMaster()
        end
    })
    
    MainTab:Dropdown({
        Title = "TargetType",
        Desc = "Select target type",
        Values = {"Players", "NPCs", "Both"},
        Value = config.masterTarget or "Players",
        Multi = false,
        Callback = function(Option)
            config.masterTarget = Option
        end
    })
    
    MainTab:Dropdown({
        Title = "GetTarget",
        Desc = "Target selection method",
        Values = {"Closest", "Lowest Health", "TargetSeen"},
        Value = config.masterGetTarget or "Closest",
        Multi = false,
        Callback = function(Option)
            config.masterGetTarget = Option
            config.aimbotGetTarget = Option
            config.silentGetTarget = Option
            config.antiAimGetTarget = Option
            config.SA2_GetTarget = Option
            syncSilentAimWithMaster()
        end
    })
    
    MainTab:Slider({
        Title = "Targetseen Switch Rate",
        Desc = "Time between target switches (seconds)",
        IsTextbox = true,
        Step = 0.1,
        Value = {
            Min = 0.1,
            Max = 10,
            Default = config.targetSeenSwitchRate or 0.2
        },
        Callback = function(value)
            config.targetSeenSwitchRate = value
        end
    })
    
    MainTab:Toggle({
        Title = "Ignore Forcefield",
        Desc = "Skip targets with forcefields",
        Value = config.ignoreForcefield or true,
        Callback = function(v)
            config.ignoreForcefield = v
        end
    })
MainTab:Space()
MainTab:Toggle({
    Title = "Enable Keybinds",
    Desc = "Toggle keybind system on/off",
    Value = config.KeybindsEnabled or true,
    Callback = function(v)
        config.KeybindsEnabled = v
        WindUI:Notify({
            Title = "Keybinds",
            Content = "Keybinds " .. (v and "Enabled" or "Disabled"),
            Icon = v and "check" or "x",
            Duration = 2
        })
    end
})

MainTab:Toggle({
    Title = "Hold Key Mode",
    Desc = "Require holding modifier key for keybinds",
    Value = config.HoldKeysEnabled or false,
    Callback = function(v)
        config.HoldKeysEnabled = v
        WindUI:Notify({
            Title = "Hold Keys",
            Content = "Hold key mode " .. (v and "Enabled" or "Disabled"),
            Icon = v and "check" or "x",
            Duration = 2
        })
    end
})

MainTab:Keybind({
    Title = "Hold Key Modifier",
    Desc = "Key to hold for combos (like LeftAlt + Keybind)",
    Value = config.Keybinds.HoldKeybind or "LeftAlt",
    Callback = function(key)
        config.Keybinds.HoldKeybind = key
    end
})
MainTab:Space()
MainTab:Keybind({
    Title = "Silent Aim (HB)",
    Desc = "Toggle Silent Aim (Hitbox-based)",
    Value = config.Keybinds.silentaim or "E",
    Callback = function(key)
        config.Keybinds.silentaim = key
    end
})

MainTab:Keybind({
    Title = "Silent Aim (HK)",
    Desc = "Toggle Silent Aim (Hook-based)",
    Value = config.Keybinds.silentaimhk or "R",
    Callback = function(key)
        config.Keybinds.silentaimhk = key
    end
})

MainTab:Keybind({
    Title = "Aimbot",
    Desc = "Toggle Aimbot",
    Value = config.Keybinds.aimbot or "Q",
    Callback = function(key)
        config.Keybinds.aimbot = key
    end
})

MainTab:Keybind({
    Title = "Auto Farm",
    Desc = "Toggle Auto Farm",
    Value = config.Keybinds.autofarm or "F",
    Callback = function(key)
        config.Keybinds.autofarm = key
    end
})

MainTab:Keybind({
    Title = "Anti Aim",
    Desc = "Toggle Anti Aim",
    Value = config.Keybinds.antiaim or "L",
    Callback = function(key)
        config.Keybinds.antiaim = key
    end
})

MainTab:Keybind({
    Title = "Trigger Bot",
    Desc = "Toggle Trigger Bot",
    Value = config.Keybinds.triggerbot or "X",
    Callback = function(key)
        config.Keybinds.triggerbot = key
    end
})

MainTab:Keybind({
    Title = "BHop",
    Desc = "Toggle Bunny Hop",
    Value = config.Keybinds.bhop or "V",
    Callback = function(key)
        config.Keybinds.bhop = key
    end
})

MainTab:Keybind({
    Title = "Hitbox",
    Desc = "Toggle Hitbox Expansion",
    Value = config.Keybinds.hitbox or "G",
    Callback = function(key)
        config.Keybinds.hitbox = key
    end
})

MainTab:Keybind({
    Title = "ESP",
    Desc = "Toggle ESP",
    Value = config.Keybinds.esp or "Z",
    Callback = function(key)
        config.Keybinds.esp = key
    end
})

MainTab:Keybind({
    Title = "Client",
    Desc = "Toggle Client Features",
    Value = config.Keybinds.client or "N",
    Callback = function(key)
        config.Keybinds.client = key
    end
})
MainTab:Space()
MainTab:Keybind({
    Title = "Silent Aim Wall Check",
    Desc = "Toggle wall check for Silent Aim",
    Value = config.Keybinds.silentaimwallcheck or "B",
    Callback = function(key)
        config.Keybinds.silentaimwallcheck = key
    end
})

MainTab:Keybind({
    Title = "Aimbot Wall Check",
    Desc = "Toggle wall check for Aimbot",
    Value = config.Keybinds.aimbotwallcheck or "H",
    Callback = function(key)
        config.Keybinds.aimbotwallcheck = key
    end
})

MainTab:Keybind({
    Title = "Silent Aim HK Wall Check",
    Desc = "Toggle wall check for Silent Aim (HK)",
    Value = config.Keybinds.silentaimhkwallcheck or "T",
    Callback = function(key)
        config.Keybinds.silentaimhkwallcheck = key
    end
})
MainTab:Keybind({
    Title = "TriggerBot Wall Check",
    Desc = "Toggle wall check for TriggerBot",
    Value = config.Keybinds.tbotwallcheck or "Y",
    Callback = function(key)
        config.Keybinds.tbotwallcheck = key
    end
})

    
    MainTab:Paragraph({
        Title = "Utilities",
        Desc = "AutoFarm and utility features",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    MainTab:Paragraph({
        Title = "Gravel",
        Desc = "[ Autofarm might not work for every game]",
        Color = config.Gradow.uicolor.darkGray
    })
    
    MainTab:Toggle({
        Title = "Toggle AutoFarm ('F')",
        Desc = "Enable/disable auto farm",
        Value = config.autoFarmEnabled or false,
        Callback = function(v)
            config.autoFarmEnabled = v
            if v then
                autoFarmProcess()
                n({
                    Title = "AutoFarm",
                    Content = "Enabled",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(0, 255, 0)
                })
            else
                stopAutoFarm()
                n({
                    Title = "AutoFarm",
                    Content = "Disabled",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(255, 0, 0)
                })
            end
        end
    })
    
    MainTab:Toggle({
        Title = "Autofarm Wall Check",
        Desc = "Prevent teleporting targets behind walls",
        Value = config.autoFarmWallCheck or false,
        Callback = function(v)
            config.autoFarmWallCheck = v
            if v then
                n({
                    Title = "Autofarm Wall Check",
                    Content = "Enabled - Targets behind walls will be ignored",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(0, 170, 255)
                })
            else
                n({
                    Title = "Autofarm Wall Check",
                    Content = "Disabled - Will teleport targets even behind walls",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(255, 100, 0)
                })
            end
        end
    })
    
    MainTab:Toggle({
        Title = "QuickToggles",
        Desc = "Show/hide QuickToggles/QT GUI",
        Value = config.QuickToggles or false,
        Callback = function(v)
            config.QuickToggles = v
            if not v then
                KillQT()
            end
        end
    })

MainTab:Toggle({
    Title = "QuickToggles Draggable",
    Desc = "Allow dragging quick toggles",
    Value = config.QTDrag or true,
    Callback = function(v)
        config.QTDrag = v
        if gui.mobileGui and gui.mobileGui.Buttons then
            for _, buttonData in pairs(gui.mobileGui.Buttons) do
                if buttonData and buttonData.main then
                    buttonData.main.Draggable = v
                end
            end
        end
    end
})
    
    MainTab:Button({
        Title = "Partclaim",
        Desc = "Use if NPC mode isn't working well (May Lag)",
        Callback = function()
            pc()
            n({
                Title = "PartClaim",
                Content = "Refreshed",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(0, 255, 0)
            })
        end
    })

    MainTab:Button({
        Title = "Clear Partclaim",
        Desc = "Reduce Lag",
        Callback = function()
            pc2()
            n({
                Title = "PartClaim",
                Content = "Cleared",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(0, 255, 0)
            })
        end
    })
    
    MainTab:Dropdown({
        Title = "Align Part (Autofarm)",
        Desc = "Part to align with crosshair",
        Values = {"Head", "HumanoidRootPart"},
        Value = config.autoFarmTargetPart or "Head",
        Multi = false,
        Callback = function(Option)
            config.autoFarmTargetPart = Option
        end
    })
    
    MainTab:Slider({
        Title = "GetPart (Partclaim)",
        Desc = "Part replication distance",
        IsTextbox = true,
        Step = 10,
        Value = {
            Min = 0,
            Max = 1000,
            Default = config.gp or 200
        },
        Callback = function(value)
            config.gp = value
        end
    })
    
    MainTab:Slider({
        Title = "TP Max Range (Autofarm)",
        Desc = "Maximum distance to teleport targets",
        IsTextbox = true,
        Step = 50,
        Value = {
            Min = 0,
            Max = 999999999,
            Default = config.autoFarmMaxRange or 50
        },
        Callback = function(value)
            config.autoFarmMaxRange = value
        end
    })
    
    MainTab:Slider({
        Title = "TP Distance (Autofarm)",
        Desc = "Teleport distance for autofarm",
        IsTextbox = true,
        Step = 1,
        Value = {
            Min = 1,
            Max = 100,
            Default = config.autoFarmDistance or 10
        },
        Callback = function(value)
            config.autoFarmDistance = value
        end
    })
    
    MainTab:Slider({
        Title = "Vertical Offset (Autofarm)",
        Desc = "Vertical offset for autofarm",
        IsTextbox = true,
        Step = 1,
        Value = {
            Min = -50,
            Max = 50,
            Default = config.autoFarmVerticalOffset or 0
        },
        Callback = function(value)
            config.autoFarmVerticalOffset = value
        end
    })
    
    MainTab:Paragraph({
        Title = "Antikick [ I didn't made this ]",
        Desc = "Client-side anti-kick protection",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    MainTab:Paragraph({
        Title = "Gravel",
        Desc = "[ AntiKick only prevents client kicks ]\n[ Good Injectors are recommend ]",
        Color = config.Gradow.uicolor.darkGray
    })
    
    MainTab:Toggle({
        Title = "Toggle AntiKick",
        Desc = "Enable/disable Antikick",
        Value = ED_AntiKick.Enabled or true,
        Callback = function(v)
            ED_AntiKick.Enabled = v
            n({
                Title = "AntiKick",
                Content = "AntiKick " .. (v and "Enabled" or "Disabled"),
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = v and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            })
        end
    })
    
    MainTab:Toggle({
        Title = "Show AntiKick Notifications",
        Desc = "Enable/disable Antikick Notifications",
        Value = ED_AntiKick.SendNotifications or false,
        Callback = function(v)
            ED_AntiKick.SendNotifications = v
            n({
                Title = "AntiKick",
                Content = "AntiKick " .. (v and "Enabled" or "Disabled"),
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = v and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            })
        end
    })
    
    MainTab:Toggle({
        Title = "Toggle AntiKick Checkcallers",
        Desc = "Enable/disable Antikick Checkcallers (fixes nil and index errors)",
        Value = ED_AntiKick.CheckCaller or true,
        Callback = function(v)
            ED_AntiKick.CheckCaller = v
            n({
                Title = "AntiKick",
                Content = "AntiKick " .. (v and "Enabled" or "Disabled"),
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = v and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            })
        end
    })
    
    
    MainTab:Paragraph({
        Title = "Optimization",
        Desc = "Performance optimization settings",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    MainTab:Paragraph({
        Title = "Optimization",
        Desc = "Copy and execute optimization code",
        Color = config.Gradow.uicolor.darkGray,
        Buttons = {
            {
                Title = "Copy Code",
                Icon = "copy",
                Callback = function()
                    local code = [[
--  you adjust stuff here
local Config = {
    NETWORK_OPTIMIZATION = true,
    REDUCE_REPLICATION = true,
    THROTTLE_REMOTE_EVENTS = true,
    OPTIMIZE_CHAT = true,
    DISABLE_UNNECESSARY_GUI = true,
    STREAMING_ENABLED = true,
    REDUCE_PLAYER_REPLICATION_DISTANCE = 100,
    THROTTLE_SOUNDS = true,
    DESTROY_EMITTERS = true,
    REMOVE_GRASS = true,
    CORE = true,
    FPS_MONITOR = true,
    OPTIZ = true,
    OPTIMIZATION_INTERVAL = 10,
    MIN_INTERVAL = 3,
    MAX_DISTANCE = 50,
    PERFORMANCE_MONITORING = true,
    FPS_THRESHOLD = 30,
    GRAY_SKY_ENABLED = true,
    GRAY_SKY_ID = "rbxassetid://114666145996289",
    FULL_BRIGHT_ENABLED = true,
    SMOOTH_PLASTIC_ENABLED = true,
    COLLISION_GROUP_NAME = "OptimizedParts",
    OPTIMIZE_PHYSICS = true,
    DISABLE_CONSTRAINTS = true,
    THROTTLE_PARTICLES = true,
    THROTTLE_TEXTURES = true,
    REMOVE_ANIMATIONS = true,
    LOW_POLY_CONVERSION = true,
    SELECTIVE_TEXTURE_REMOVAL = true,
    PRESERVE_IMPORTANT_TEXTURES = true,
    IMPORTANT_TEXTURE_KEYWORDS = {"sign", "ui", "hud", "menu", "button", "fence"},
    QUALITY_LEVEL = 1,
    FPS_CAP = 1000,
    MEMORY_CLEANUP_THRESHOLD = 500,
}

local Optiz = loadstring(game:HttpGet('https://raw.githubusercontent.com/hm5650/Optiz/refs/heads/main/Optiz.lua'))()(Config)]]
                    setclipboard(code)
                    WindUI:Notify({
                        Title = "Optimization",
                        Content = "Code copied to clipboard!",
                        Icon = "check",
                        Duration = 3
                    })
                end
            }
        }
    })
    
    MainTab:Slider({
        Title = "Updaters speed",
        Desc = "Increase performance when increased costs Accuracy",
        IsTextbox = true,
        Step = 0.1,
        Value = {
            Min = 0,
            Max = 50,
            Default = config.varibz.patcherwait or 0.5
        },
        Callback = function(value)
            config.varibz.patcherwait = value
        end
    })
    
    MainTab:Toggle({
        Title = "Updaters",
        Desc = "Stops other Updaters when disabled Increases performance. Might cause features to not work",
        Value = config.varibz.patcher or true,
        Callback = function(v)
            config.varibz.patcher = v
        end
    })

    MainTab:Slider({
        Title = "Clean Cache Every",
        Desc = "Cleans up cache every second",
        IsTextbox = true,
        Step = 0.01,
        Value = {
            Min = 0,
            Max = 50,
            Default = config.varibz.lowpatcherwait or 0.03
        },
        Callback = function(value)
            config.varibz.lowpatcherwait = value
        end
    })
    
    MainTab:Toggle({
        Title = "Cache Cleaners",
        Desc = "Turning this off Might cause lag",
        Value = config.varibz.patcher or true,
        Callback = function(v)
            config.varibz.lowpatcher = v
        end
    })
    
    MainTab:Toggle({
        Title = "Low Render",
        Desc = "Renders the game in lower visuals",
        Value = config.LowRender or false,
        Callback = function(v)
            config.LowRender = v
        end
    })

MainTab:Toggle({
    Title = "Errors",
    Desc = "Enable/disable error catching",
    Value = config.varibz.errors or true,
    Callback = function(v)
        config.varibz.errors = v
        if v then
            for _, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do
                v:Enable()
            end
            for _, v in pairs(getconnections(game:GetService("LogService").MessageOut)) do
                v:Enable()
            end
            n({
                Title = "Gravel.cc",
                Content = "Error catching enabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(0, 255, 0)
            })
        else
            for _, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do
                v:Disable()
            end
            for _, v in pairs(getconnections(game:GetService("LogService").MessageOut)) do
                v:Disable()
            end
            n({
                Title = "Gravel.cc",
                Content = "Error catching disabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        end
    end
})

MainTab:Paragraph({
    Title = "Save/Load",
    Desc = "Save and load your configuration settings\n\n[sum features won't be saved mb :< ]",
    Color = config.Gradow.uicolor.lightGreen
})

MainTab:Input({
    Title = "Save Name",
    Desc = "Enter a name for your save or select a save like blahblahagaha",
    Placeholder = "put words here!11",
    Value = "",
    ClearTextOnFocus = true,
    Callback = function(text)
        saveInputValue = text
    end
})

MainTab:Button({
    Title = "New Save",
    Desc = "Save New/Overwrite [leave blank for lazy text generation]",
    Icon = "save",
    Callback = function()
        local name = saveInputValue or ""
        if name == "" then
            local timestamp = os.time()
            local date = os.date("%Y-%m-%d_%H-%M-%S", timestamp)
            name = "Config_" .. date
            WindUI:Notify({
                Title = "Save System",
                Content = "Using default name: " .. name,
                Icon = "info",
                Duration = 2
            })
        end
        saveConfig(name)
    end
})

MainTab:Button({
    Title = "Load Save",
    Desc = "Load selected save",
    Icon = "download",
    Callback = function()
        local name = saveInputValue or ""
        if name == "" then
            WindUI:Notify({
                Title = "Save System",
                Content = "Please enter a save name to load! D:",
                Icon = "x",
                Duration = 2
            })
            return
        end
        loadSave(name)
    end
})

MainTab:Button({
    Title = "Delete Save",
    Desc = "Delete selected save",
    Icon = "trash",
    Callback = function()
        local name = saveInputValue or ""
        if name == "" then
            WindUI:Notify({
                Title = "Save System",
                Content = "Please enter a save name to delete! :/",
                Icon = "x",
                Duration = 2
            })
            return
        end
        deleteSave(name)
    end
})

MainTab:Button({
    Title = "Delete All Saves",
    Desc = "Permanently delete ALL save files D:",
    Icon = "delete",
    Callback = function()
        deleteAllSaves()
    end
})

config.varibz.savesParagraph = MainTab:Paragraph({
    Title = "Saves List",
    Desc = savePara() .. "\nit refreshes now!",
    Color = config.Gradow.uicolor.darkGray
})
task.spawn(function()
    while true do
        task.wait(1)
        if config.varibz.savesParagraph then
            local newDesc = savePara() .. "\nit refreshes now!"
            pcall(function()
                config.varibz.savesParagraph:SetDesc(newDesc)
            end)
        end
    end
end)
end

-- VisualsTab
local VisualsTab = Window:Tab({
    Title = "Visuals",
    Desc = rng3("Visuals"),
    Icon = "eye",
    IconColor = config.Gradow.uicolor.lightGray
}) do
    VisualsTab:Paragraph({
        Title = "ESP Master",
        Desc = "Master control for ESP features",
        Color = config.Gradow.uicolor.lightGreen
    })
    VisualsTab:Space()
    VisualsTab:Toggle({
        Title = "Toggle ESP ('Z')",
        Desc = "Enable/disable all ESP features",
        Value = config.espMasterEnabled or false,
        Callback = function(v)
            applyESPMaster(v)
            if v then
                n({
                    Title = "ESP Master",
                    Content = "ESP Enabled",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(0, 170, 255)
                })
            else
                n({
                    Title = "ESP Master",
                    Content = "ESP Disabled",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(255, 0, 0)
                })
            end
        end
    })
    
    VisualsTab:Paragraph({
        Title = "ESP Components",
        Desc = "Individual ESP component settings",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    VisualsTab:Toggle({
        Title = "Toggle Highlight ESP",
        Desc = "Enable player highlight",
        Value = config.prefHighlightESP or false,
        Callback = function(v)
            toggleHighlightESP(v)
            espRefresher()
        end
    })
    
    VisualsTab:Toggle({
        Title = "Toggle Text ESP",
        Desc = "Show player names/health",
        Value = config.prefTextESP or false,
        Callback = function(v)
            toggleTextESP(v)
            espRefresher()
        end
    })
    
    VisualsTab:Toggle({
        Title = "Toggle Box ESP",
        Desc = "Show bounding boxes",
        Value = config.prefBoxESP or false,
        Callback = function(v)
            toggleBoxESP(v)
            espRefresher()
        end
    })
    
    VisualsTab:Toggle({
        Title = "Toggle Health ESP",
        Desc = "Show health bars",
        Value = config.prefHealthESP or false,
        Callback = function(v)
            toggleHealthESP(v)
            espRefresher()
        end
    })
    
    VisualsTab:Toggle({
        Title = "Toggle Head Dot ESP",
        Desc = "Show head indicators",
        Value = config.prefHeadDotESP or false,
        Callback = function(v)
            config.prefHeadDotESP = v
            if config.espMasterEnabled then
                for _, target in ipairs(getAllTargets()) do
                    if addesp(target) and not config.espData[target] then
                        makeesp(target)
                    end
                end
                updateESPColors()
            end
            espRefresher()
        end
    })
    
    VisualsTab:Toggle({
        Title = "Toggle Tracer ESP",
        Desc = "Draw lines to targets",
        Value = config.lineESPEnabled or false,
        Callback = function(v)
            config.lineESPEnabled = v
            if not v then
                for target, _ in pairs(config.lineESPData) do
                    removeLineESP(target)
                end
            end
            espRefresher()
        end
    })
    
    VisualsTab:Toggle({
        Title = "Tracer ESP Only Targets",
        Desc = "Only show lines when targeting with aimbot/silent aim",
        Value = config.lineESPOnlyTarget or false,
        Callback = function(v)
            config.lineESPOnlyTarget = v
            espRefresher()
        end
    })
    
    VisualsTab:Dropdown({
        Title = "Tracer Start Position",
        Desc = "Where lines start from on screen",
        Values = {"Center", "Bottom", "Top", "BottomLeft", "BottomRight", "TopLeft", "TopRight"},
        Value = config.lineStartPosition or "Center",
        Multi = false,
        Callback = function(Option)
            config.lineStartPosition = Option
        end
    })
    
    VisualsTab:Toggle({
        Title = "ESP Colour Based On Health",
        Desc = "Dynamic color based on health",
        Value = config.prefColorByHealth or false,
        Callback = function(v)
            config.prefColorByHealth = v
            updateESPColors()
            espRefresher()
        end
    })
    VisualsTab:Space()

VisualsTab:Toggle({
    Title = "Full Bright",
    Desc = "Enable/disable full bright (no lighting)",
    Value = false,
    Callback = function(v)
        config.fbenabled = v
        if v then
            local lighting = game:GetService("Lighting")
            fullBrightSettings = {
                Ambient = lighting.Ambient,
                Brightness = lighting.Brightness,
                ClockTime = lighting.ClockTime,
                FogEnd = lighting.FogEnd,
                GlobalShadows = lighting.GlobalShadows,
                OutdoorAmbient = lighting.OutdoorAmbient
            }

            lighting.Ambient = Color3.fromRGB(255, 255, 255)
            lighting.Brightness = 2
            lighting.FogEnd = 100000
            lighting.GlobalShadows = false
            lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            
            lighting.ClockTime = 14
            
            n({
                Title = "Full Bright",
                Content = "Enabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(0, 255, 0)
            })
        else
            if fullBrightSettings then
                local lighting = game:GetService("Lighting")
                for property, value in pairs(fullBrightSettings) do
                    lighting[property] = value
                end
                fullBrightSettings = nil
            end
            
            n({
                Title = "Full Bright",
                Content = "Disabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        end
    end
})

VisualsTab:Toggle({
    Title = "FOV",
    Desc = "Override the game's default FOV",
    Value = config.customFOVEnabled or false,
    Callback = function(v)
        config.customFOVEnabled = v
        local camera = workspace.CurrentCamera
        if v then
            if config.varibz.orgfov == nil then
                config.varibz.orgfov = camera.FieldOfView
            end
            camera.FieldOfView = config.customFOVValue or 70
        else
            if config.varibz.orgfov then
                camera.FieldOfView = config.varibz.orgfov
            end
        end
    end
})

VisualsTab:Slider({
    Title = "FOV Value",
    Desc = "Adjust Field Of View",
    IsTextbox = true,
    Step = 1,
    Suffix = "bruhs",
    Value = {
        Min = 10,
        Max = 120,
        Default = config.customFOVValue or 70
    },
    Callback = function(value)
        config.customFOVValue = value
        local camera = workspace.CurrentCamera
        
        if config.customFOVEnabled then
            camera.FieldOfView = value
        end
    end
})

VisualsTab:Input({
    Title = "Tag's TextCursor",
    Desc = "bro... who even needs ts 💔",
    Placeholder = "_",
    Value = "_",
    ClearTextOnFocus = true,
    Callback = function(hahahaaha)
        config.Gradow.textcursor = hahahaaha
    end
})
VisualsTab:Input({
    Title = "Tag's TextCursor2",
    Desc = "alr vro ??",
    Placeholder = "  ",
    Value = "  ",
    ClearTextOnFocus = true,
    Callback = function(lollllll)
        config.Gradow.textcursor2 = lollllll
    end
})

VisualsTab:Space()
VisualsTab:Paragraph({
    Title = "ESP Colors",
    Desc = "Customize ESP colors",
    Color = config.Gradow.uicolor.lightGreen
})

VisualsTab:Colorpicker({
    Title = "ESP Color",
    Desc = "Default color for ESP elements",
    Default = config.espc or Color3.fromRGB(255, 182, 193),
    Transparency = 0,
    Locked = false,
    LockedTitle = "Locked message",
    Callback = function(color)
        config.espc = color
        updateESPColors()
    end
})

VisualsTab:Colorpicker({
    Title = "ESP Target Color",
    Desc = "Color when player is targeted",
    Default = config.esptargetc or Color3.fromRGB(255, 255, 0),
    Transparency = 0,
    Locked = false,
    LockedTitle = "Locked message",
    Callback = function(color)
        config.esptargetc = color
        updateESPColors()
    end
})

VisualsTab:Colorpicker({
    Title = "ESP Team Color",
    Desc = "Color for teammates",
    Default = config.espteamc or Color3.fromRGB(0, 255, 0),
    Transparency = 0,
    Locked = false,
    LockedTitle = "Locked message",
    Callback = function(color)
        config.espteamc = color
        updateESPColors()
    end
})

VisualsTab:Colorpicker({
    Title = "Tracer Line Color",
    Desc = "Color for tracer lines",
    Default = config.lineColor or Color3.fromRGB(255, 255, 255),
    Transparency = 0,
    Locked = false,
    LockedTitle = "Locked message",
    Callback = function(color)
        config.lineColor = color
        updateLineESP()
    end
})

VisualsTab:Space()
VisualsTab:Paragraph({
    Title = "FOV Colors",
    Desc = "Customize FOV ring colors",
    Color = config.Gradow.uicolor.lightGreen
})

VisualsTab:Colorpicker({
    Title = "FOV Ring Color",
    Desc = "Color for FOV ring",
    Default = config.fovc or Color3.fromRGB(100, 0, 0),
    Transparency = 0,
    Locked = false,
    LockedTitle = "Locked message",
    Callback = function(color)
        config.fovc = color
        if gui.RingStroke then
            gui.RingStroke.Color = color
        end
    end
})

VisualsTab:Colorpicker({
    Title = "FOV Target Color",
    Desc = "Color when target is in FOV",
    Default = config.fovct or Color3.fromRGB(255, 255, 0),
    Transparency = 0,
    Locked = false,
    LockedTitle = "Locked message",
    Callback = function(color)
        config.fovct = color
        if gui.RingStroke then
            gui.RingStroke.Color = color
        end
    end
})

VisualsTab:Space()
VisualsTab:Paragraph({
    Title = "Silent Aim (HK) Colors",
    Desc = "Customize Silent Aim HK colors",
    Color = config.Gradow.uicolor.lightGreen
})

VisualsTab:Colorpicker({
    Title = "SA2 FOV Color",
    Desc = "Color for Silent Aim HK FOV",
    Default = config.SA2_FovColor or Color3.new(0, 0, 0),
    Transparency = 0,
    Locked = false,
    LockedTitle = "Locked message",
    Callback = function(color)
        config.SA2_FovColor = color
    end
})

VisualsTab:Colorpicker({
    Title = "SA2 FOV Target Color",
    Desc = "Color when target is in SA2 FOV",
    Default = config.SA2_FovColourTarget or Color3.new(1, 1, 0),
    Transparency = 0,
    Locked = false,
    LockedTitle = "Locked message",
    Callback = function(color)
        config.SA2_FovColourTarget = color
    end
})

VisualsTab:Space()
VisualsTab:Paragraph({
    Title = "TriggerBot Colors",
    Desc = "Customize TriggerBot colors",
    Color = config.Gradow.uicolor.lightGreen
})

VisualsTab:Colorpicker({
    Title = "TriggerBot FOV Color",
    Desc = "Color for trigger bot FOV ring",
    Default = config.tbot.fovColor or Color3.fromRGB(255, 0, 0),
    Transparency = 0,
    Locked = false,
    LockedTitle = "Locked message",
    Callback = function(color)
        config.tbot.fovColor = color
        updateTriggerBotFOV()
    end
})

VisualsTab:Space()
VisualsTab:Paragraph({
    Title = "Hitbox Colors",
    Desc = "Customize hitbox colors",
    Color = config.Gradow.uicolor.lightGreen
})

VisualsTab:Colorpicker({
    Title = "Hitbox Color",
    Desc = "Color for expanded hitboxes",
    Default = config.hitboxColor or Color3.fromRGB(255, 255, 255),
    Transparency = 0,
    Locked = false,
    LockedTitle = "Locked message",
    Callback = function(color)
        config.hitboxColor = color
        if config.hitboxEnabled then
            for player, data in pairs(config.hitboxExpandedParts) do
                if data.part and data.part.Parent then
                    pcall(function()
                        data.part.Color = color
                    end)
                end
            end
        end
    end
})

VisualsTab:Space()
VisualsTab:Paragraph({
    Title = "Reach Colors",
    Desc = "Customize reach visualizer colors",
    Color = config.Gradow.uicolor.lightGreen
})

VisualsTab:Colorpicker({
    Title = "Reach Visualizer Color",
    Desc = "Color for reach visualizer",
    Default = config.visualizer.color or Color3.fromRGB(255, 0, 0),
    Transparency = 0,
    Locked = false,
    LockedTitle = "Locked message",
    Callback = function(color)
        config.visualizer.color = color
    end
})

VisualsTab:Space()
VisualsTab:Paragraph({
    Title = "Theme",
    Desc = "Customize the UI appearance",
    Color = config.Gradow.uicolor.lightGreen
})

local function getthemez()
    local themes = {}
    for themeName, _ in pairs(WindUI.Themes) do
        table.insert(themes, themeName)
    end
    return themes
end
currentTheme = WindUI.Theme and WindUI.Theme.Name or "Dark"
VisualsTab:Dropdown({
    Title = "UI Theme",
    Desc = "Change UI theme",
    Values = getthemez(),
    Value = currentTheme,
    Multi = false,
    Callback = function(selectedTheme)
        local success, err = pcall(function()
            WindUI:SetTheme(selectedTheme)
            SaveUI:setTheme(selectedTheme)
            n({
                Title = "Theme Changed",
                Content = "Switched to " .. selectedTheme,
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(0, 170, 255)
            })
        end)
        if not success then
            warn("blame windui: " .. tostring(err))
        end
    end
})

VisualsTab:Slider({
    Title = "Transparency Value",
    Desc = "Adjust UI window transparency",
    IsTextbox = true,
    Step = 0.05,
    Value = {
        Min = 0,
        Max = 1,
        Default = 0.15
    },
    Callback = function(value)
        WindUI.TransparencyValue = value
        SaveUI:setTransparency(value)
        if WindUI.Transparent then
            WindUI.Window:ToggleTransparency(true)
        end
    end
})

VisualsTab:Button({
    Title = "Save UI Settings",
    Desc = "Save current theme & trans",
    Icon = "save",
    Callback = function()
        local currentTheme = WindUI.Theme and WindUI.Theme.Name or "Dark"
        local currentTransparency = WindUI.TransparencyValue or 0.15
        SaveUI:save(currentTheme, currentTransparency)
    end
})

VisualsTab:Button({
    Title = "Reload UI Settings",
    Desc = "Reload da UI settings (btw the savedui file can autoload)",
    Icon = "download",
    Callback = function()
        local success = SaveUI:load()
        if success then
            WindUI:Notify({
                Title = "UI Loaded!",
                Content = "Theme & transparency loaded :7",
                Icon = "check",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "UI Load Error",
                Content = "No saved UI settings found! :[",
                Icon = "x",
                Duration = 2
            })
        end
    end
})
end

-- AntiAim Tab
local AntiAimTab = Window:Tab({
    Title = "AntiAim",
    Desc = rng3("AntiAim"),
    Icon = "shield",
    IconColor = config.Gradow.uicolor.lightGray
}) do
    AntiAimTab:Paragraph({
        Title = "Gravel",
        Desc = "[ Bad Injectors might work here ]\n[ This might not work on every game ]",
        Color = config.Gradow.uicolor.darkGray
    })

    AntiAimTab:Paragraph({
        Title = "AntiAim Master",
        Desc = "Master control for AntiAim features",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    AntiAimTab:Toggle({
        Title = "Toggle AntiAim ('L')",
        Desc = "Enable/disable AntiAim",
        Value = config.antiAimEnabled or false,
        Callback = function(v)
            config.antiAimEnabled = v
            
            if not v then
                returnToOriginalPosition()
                n({
                    Title = "AntiAim",
                    Content = "Disabled",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(255, 0, 0)
                })
            else
                n({
                    Title = "AntiAim",
                    Content = "Enabled",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(255, 100, 0)
                })
            end
        end
    })
    AntiAimTab:Space()
    AntiAimTab:Paragraph({
        Title = "AntiAim Modes",
        Desc = "Different AntiAim evasion modes",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    AntiAimTab:Toggle({
        Title = "Raycast AntiAim",
        Desc = "Teleport when targeted",
        Value = config.raycastAntiAim or false,
        Callback = function(v)
            config.raycastAntiAim = v
            if v then
                config.antiAimAbovePlayer = false
                config.antiAimBehindPlayer = false
                config.antiAimOrbitEnabled = false
            end
        end
    })
    
    AntiAimTab:Toggle({
        Title = "Above Player",
        Desc = "Teleport above target",
        Value = config.antiAimAbovePlayer or false,
        Callback = function(v)
            config.antiAimAbovePlayer = v
            if v then
                config.raycastAntiAim = false
                config.antiAimBehindPlayer = false
                config.antiAimOrbitEnabled = false
            else
                returnToOriginalPosition()
            end
        end
    })
    
    AntiAimTab:Toggle({
        Title = "Behind Player",
        Desc = "Teleport behind target",
        Value = config.antiAimBehindPlayer or false,
        Callback = function(v)
            config.antiAimBehindPlayer = v
            if v then
                config.raycastAntiAim = false
                config.antiAimAbovePlayer = false
                config.antiAimOrbitEnabled = false
            else
                returnToOriginalPosition()
            end
        end
    })
    
    AntiAimTab:Toggle({
        Title = "Orbit Players",
        Desc = "Orbit around nearest target",
        Value = config.antiAimOrbitEnabled or false,
        Callback = function(v)
            config.antiAimOrbitEnabled = v
            if v then
                config.raycastAntiAim = false
                config.antiAimAbovePlayer = false
                config.antiAimBehindPlayer = false
                if not config.antiAimEnabled then
                    config.antiAimEnabled = true
                end
            else
                returnToOriginalPosition()
            end
        end
    })
    
    AntiAimTab:Paragraph({
        Title = "AntiAim Settings",
        Desc = "Configuration for AntiAim modes",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    AntiAimTab:Slider({
        Title = "Teleport Distance (Raycast)",
        Desc = "Distance to teleport when targeted",
        IsTextbox = true,
        Step = 0.5,
        Value = {
            Min = 0.5,
            Max = 50,
            Default = config.antiAimTPDistance or 3
        },
        Callback = function(value)
            config.antiAimTPDistance = value
        end
    })
    
    AntiAimTab:Slider({
        Title = "Above Height (Above Player)",
        Desc = "Height above target",
        IsTextbox = true,
        Step = 1,
        Value = {
            Min = 1,
            Max = 100,
            Default = config.antiAimAboveHeight or 10
        },
        Callback = function(value)
            config.antiAimAboveHeight = value
        end
    })
    
    AntiAimTab:Slider({
        Title = "Behind Distance (Behind Player)",
        Desc = "Distance behind target",
        IsTextbox = true,
        Step = 0.5,
        Value = {
            Min = 0.5,
            Max = 50,
            Default = config.antiAimBehindDistance or 5
        },
        Callback = function(value)
            config.antiAimBehindDistance = value
        end
    })
    
    AntiAimTab:Slider({
        Title = "Orbit Speed (Orbit)",
        Desc = "Angular speed multiplier",
        IsTextbox = true,
        Step = 0.5,
        Value = {
            Min = 0.5,
            Max = 20,
            Default = config.antiAimOrbitSpeed or 5
        },
        Callback = function(value)
            config.antiAimOrbitSpeed = value
        end
    })
    
    AntiAimTab:Slider({
        Title = "Orbit Radius (Orbit)",
        Desc = "Distance from target",
        IsTextbox = true,
        Step = 0.5,
        Value = {
            Min = 0.5,
            Max = 50,
            Default = config.antiAimOrbitRadius or 5
        },
        Callback = function(value)
            config.antiAimOrbitRadius = value
        end
    })
    
    AntiAimTab:Slider({
        Title = "Orbit Height (Orbit)",
        Desc = "Vertical offset",
        IsTextbox = true,
        Step = 1,
        Value = {
            Min = -50,
            Max = 50,
            Default = config.antiAimOrbitHeight or 0
        },
        Callback = function(value)
            config.antiAimOrbitHeight = value
        end
    })

AntiAimTab:Paragraph({
    Title = "Other",
    Desc = "other stuff",
    Color = config.Gradow.uicolor.lightGreen
})

AntiAimTab:Toggle({
    Title = "Enable SpinBot",
    Desc = "Toggle spinning on/off",
    Value = config.spinbot.enabled or false,
    Callback = function(v)
        config.spinbot.enabled = v
        if v then
            spinbotUpdate()
            n({
                Title = "SpinBot",
                Content = "Enabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(0, 255, 0)
            })
        else
            if config.varibz.spinbotConnection then
                config.varibz.spinbotConnection:Disconnect()
                config.varibz.spinbotConnection = nil
            end
            if localPlayer.Character then
                local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local pos = rootPart.Position
                    rootPart.CFrame = CFrame.new(pos)
                end
            end
            n({
                Title = "SpinBot",
                Content = "Disabled",
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        end
    end
})

AntiAimTab:Slider({
    Title = "Spin Speed",
    Desc = "Rotation speed",
    IsTextbox = true,
    Step = 1,
    Value = {
        Min = -3000,
        Max = 3000,
        Default = config.spinbot.speed or 50
    },
    Callback = function(value)
        config.spinbot.speed = value
    end
})

AntiAimTab:Button({
    Title = "Reset Rotation",
    Desc = "Reset character rotation to normal",
    Callback = function()
        if localPlayer.Character then
            local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local pos = rootPart.Position
                rootPart.CFrame = CFrame.new(pos)
                n({
                    Title = "SpinBot",
                    Content = "Rotation reset",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(0, 170, 255)
                })
            end
        end
    end
})
AntiAimTab:Toggle({
    Title = "Toggle Desync",
    Desc = "(not compatible with save/load)",
    Value = false,
    Callback = function(v)
        ineednextgenrep(v)
    end
})

AntiAimTab:Slider({
    Title = "Desync Transparency",
    Desc = "Transparency level when desynced",
    Step = 0.05,
    Value = {
        Min = 0,
        Max = 1,
        Default = 0.5
    },
    Callback = function(value)
        config.desyncTransparency = value
        if config.desyncActive and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    pcall(function() part.Transparency = value end)
                end
            end
        end
    end
})
end

-- Aimbot Tab
local AimbotTab = Window:Tab({
    Title = "Aimbot",
    Desc = rng3("Aimbot"),
    Icon = "crosshair",
    IconColor = config.Gradow.uicolor.lightGray
}) do
    AimbotTab:Paragraph({
        Title = "Gravel",
        Desc = "[ Bad Injectors might work here ]",
        Color = config.Gradow.uicolor.darkGray
    })
    
    AimbotTab:Paragraph({
        Title = "Aimbot Master",
        Desc = "Master control for aimbot features",
        Color = config.Gradow.uicolor.lightGreen
    })
    AimbotTab:Space()
    AimbotTab:Toggle({
        Title = "Toggle Aimbot ('Q')",
        Desc = "Enable/disable aimbot",
        Value = config.aimbotEnabled or false,
        Callback = function(v)
            handleAimbotToggle(v)
            if v then
                n({
                    Title = "Aimbot",
                    Content = "Enabled",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(0, 255, 0)
                })
            else
                n({
                    Title = "Aimbot",
                    Content = "Disabled",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(255, 0, 0)
                })
            end
        end
    })
    
    AimbotTab:Paragraph({
        Title = "Aimbot Settings",
        Desc = "Configuration for aimbot behavior",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    AimbotTab:Toggle({
        Title = "WallCheck AB ('H')",
        Desc = "Check for walls",
        Value = config.aimbotWallCheck or false,
        Callback = function(v)
            config.aimbotWallCheck = v
        end
    })
    
    AimbotTab:Toggle({
        Title = "360° Aimbot",
        Desc = "Target in all directions",
        Value = config.aimbot360Enabled or false,
        Callback = function(v)
            toggle360Aimbot(v)
        end
    })
    
    AimbotTab:Dropdown({
        Title = "Target Part",
        Desc = "Part to aim at",
        Values = {"Head", "HumanoidRootPart", "Torso"},
        Value = config.aimbotTargetPart or "Head",
        Multi = false,
        Callback = function(Option)
            config.aimbotTargetPart = Option
        end
    })
    
    AimbotTab:Slider({
        Title = "Aim Strength",
        Desc = "Smoothing strength",
        Step = 0.05,
        Value = {
            Min = 0,
            Max = 1,
            Default = config.aimbotStrength or 0.5
        },
        Callback = function(value)
            config.aimbotStrength = value
        end
    })
    
    AimbotTab:Slider({
        Title = "FOV Radius",
        Desc = "Aimbot field of view",
        IsTextbox = true,
        Step = 10,
        Value = {
            Min = 1,
            Max = 500,
            Default = config.aimbotFOVSize or 70
        },
        Callback = function(value)
            config.aimbotFOVSize = value
            updateAimbotFOVRing()
        end
    })
end

-- SA1Tab
-- SilentAim Tab (HB)
local SilentAimTab = Window:Tab({
    Title = "SilentAim (HB)",
    Desc = rng3("SilentAim (HB)"),
    Icon = "circle",
    IconColor = config.Gradow.uicolor.lightGray
}) do
    SilentAimTab:Paragraph({
        Title = "Gravel",
        Desc = "[ Hitbox Based ]\n[ Bad Injectors might work here ]\n[ This might not work on every game ]",
        Color = config.Gradow.uicolor.darkGray
    })

    SilentAimTab:Paragraph({
        Title = "SilentAim Master",
        Desc = "Master control for hitbox silent aim",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    SilentAimTab:Toggle({
        Title = "Toggle SilentAim (HB) ('E')",
        Desc = "Enable/disable silent aim",
        Value = config.startsa or false,
        Callback = function(v)
            config.startsa = v
            if not v then
                if gui.RingHolder then
                    gui.RingHolder.Visible = false
                end
                local targetsToRemove = {}
                for pl, _ in pairs(config.activeApplied) do
                    table.insert(targetsToRemove, pl)
                end
                for _, pl in ipairs(targetsToRemove) do
                    restorePartForPlayer(pl)
                end
                n({
                    Title = "SilentAim",
                    Content = "Disabled",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(255, 0, 0)
                })
            else
                if gui.RingHolder then
                    gui.RingHolder.Visible = true
                end
                n({
                    Title = "SilentAim",
                    Content = "Enabled",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(255, 100, 0)
                })
            end
        end
    })
    SilentAimTab:Space()
    SilentAimTab:Paragraph({
        Title = "SilentAim Settings",
        Desc = "Configuration for silent aim behavior",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    SilentAimTab:Toggle({
        Title = "WallCheck SA ('B')",
        Desc = "Check for walls",
        Value = config.wallc or false,
        Callback = function(v)
            config.wallc = v
        end
    })

    SilentAimTab:Toggle({
        Title = "Scale To Screen",
        Desc = "Scale hitbox to cover the fov circle",
        Value = config.scaleToScreen or false,
        Callback = function(v)
            config.scaleToScreen = v
        end
    })
    
    SilentAimTab:Slider({
        Title = "STS Distance",
        Desc = "distance from player to prevent clipping",
        IsTextbox = true,
        Step = 1,
        Value = {
            Min = -50,
            Max = 50,
            Default = config.stsdistance or 0
        },
        Callback = function(value)
            config.stsdistance = value
        end
    })
    
    SilentAimTab:Dropdown({
        Title = "Target Part",
        Desc = "Part to target",
        Values = {"Head", "HumanoidRootPart", "Both"},
        Value = config.bodypart or "Head",
        Multi = false,
        Callback = function(Option)
            local targetsToRemove = {}
            for pl, _ in pairs(config.activeApplied) do
                table.insert(targetsToRemove, pl)
            end
            for _, pl in ipairs(targetsToRemove) do
                restorePartForPlayer(pl)
            end
            config.bodypart = Option
        end
    })
    
    SilentAimTab:Slider({
        Title = "HitChance",
        Desc = "Chance to hit target",
        Step = 1,
        Suffix = "%",
        Value = {
            Min = 0,
            Max = 100,
            Default = config.hitchance or 100
        },
        Callback = function(value)
            config.hitchance = value
        end
    })
    
    SilentAimTab:Slider({
        Title = "Fov Radius",
        Desc = "Silent aim field of view",
        IsTextbox = true,
        Step = 10,
        Value = {
            Min = 1,
            Max = 500,
            Default = config.fovsize or 120
        },
        Callback = function(value)
            config.fovsize = value
            if gui.RingHolder then
                gui.RingHolder.Size = UDim2.new(0, math.max(8, config.fovsize * 2), 0, math.max(8, config.fovsize * 2))
            end
        end
    })
    
    SilentAimTab:Slider({
        Title = "Hitbox Transparency",
        Desc = "SilentAim Hitbox Transparency",
        Step = 0.1,
        Value = {
            Min = 0,
            Max = 1,
            Default = config.hbtrans or 0.5
        },
        Callback = function(value)
            config.hbtrans = value
        end
    })
end

-- SA2Tab
-- SilentAim (HK)
local SilentAimTab2 = Window:Tab({
    Title = "SilentAim (HK)",
    Desc = rng3("SilentAim (HK)"),
    Icon = "target",
    IconColor = config.Gradow.uicolor.lightGray
}) do
    SilentAimTab2:Paragraph({
        Title = "Gravel",
        Desc = "[ Hooked Based ]\n[ Bad injectors might not work here ]\n[ risky towards anticheats ]\n[ Might not work on every game ]",
        Color = config.Gradow.uicolor.darkGray
    })
    
    SilentAimTab2:Paragraph({
        Title = "SilentAim Master",
        Desc = "Master control for hook-based silent aim",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    SilentAimTab2:Toggle({
        Title = "Toggle SilentAim (HK) ('R')",
        Desc = "Enable/disable silent aim",
        Value = config.SA2_Enabled or false,
        Callback = function(v)
            config.SA2_Enabled = v
            n({
                Title = "Silent Aim",
                Content = "Silent Aim " .. (v and "Enabled" or "Disabled"),
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = v and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            })
        end
    })
    SilentAimTab2:Space()
    SilentAimTab2:Paragraph({
        Title = "SilentAim Settings",
        Desc = "Configuration for hook-based silent aim",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    SilentAimTab2:Toggle({
        Title = "WallCheck ('T')",
        Desc = "Check for walls (Might lag)",
        Value = config.SA2_Wallcheck or false,
        Callback = function(v)
            config.SA2_Wallcheck = v
        end
    })
    
    SilentAimTab2:Toggle({
        Title = "WallBang",
        Desc = "Shoot through walls",
        Value = config.SA2_Wallbang or false,
        Callback = function(v)
            config.SA2_Wallbang = v
            if v then
                n({
                    Title = "WallBang",
                    Content = "Enabled Will shoot through walls",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(0, 170, 255)
                })
            else
                n({
                    Title = "WallBang",
                    Content = "Disabled",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(255, 0, 0)
                })
            end
        end
    })
    
    SilentAimTab2:Toggle({
        Title = "360 Mode",
        Desc = "Enable silent aim in all directions",
        Value = config.SA2_ThreeSixtyMode or false,
        Callback = function(v)
            config.SA2_ThreeSixtyMode = v
        end
    })
    
    SilentAimTab2:Dropdown({
        Title = "Aim Method",
        Desc = "Raycast method to hook",
        Values = {"Raycast", "FindPartOnRay", "Mouse.Hit"},
        Value = config.SA2_Method or "Raycast",
        Multi = false,
        Callback = function(choice)
            config.SA2_Method = choice
        end
    })
    
    SilentAimTab2:Dropdown({
        Title = "Target Part",
        Desc = "Part to target",
        Values = {"Head", "HumanoidRootPart"},
        Value = config.SA2_TargetPart or "Head",
        Multi = false,
        Callback = function(choice)
            config.SA2_TargetPart = choice
            n({
                Title = "Target Part",
                Content = "Targeting: " .. choice,
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(0, 255, 0)
            })
        end
    })
    
    SilentAimTab2:Slider({
        Title = "Hit Chance",
        Desc = "Accuracy percentage",
        Step = 1,
        Suffix = "%",
        Value = {
            Min = 0,
            Max = 100,
            Default = config.SA2_HitChance or 100
        },
        Callback = function(value)
            config.SA2_HitChance = value
        end
    })

SilentAimTab2:Slider({
    Title = "Target Processing Delay",
    Desc = "Higher = More Performance  Lower = More Responsiveness",
    Step = 0.01,
    Suffix = "s",
    Value = {
        Min = 0.01,
        Max = 2,
        Default = config.varibz.sa2stuff or 0.50
    },
    Callback = function(value)
        config.varibz.sa2stuff = value
    end
})
    
    SilentAimTab2:Slider({
        Title = "FOV Radius",
        Desc = "Field of View size",
        IsTextbox = true,
        Step = 10,
        Value = {
            Min = 0,
            Max = 500,
            Default = config.SA2_FovRadius or 100
        },
        Callback = function(value)
            config.SA2_FovRadius = value
        end
    })
    SilentAimTab2:Slider({
        Title = "Target Range",
        Desc = "How far a target should a targeted",
        IsTextbox = true,
        Step = 10,
        Value = {
            Min = 5,
            Max = 999999,
            Default = config.SA2_FovRadius or 1000
        },
        Callback = function(value)
            config.SA2_TargetRange = value
        end
    })
end

-- Hitbox Tab
local HitboxTab = Window:Tab({
    Title = "Hitbox",
    Desc = rng3("Hitbox"),
    Icon = "box",
    IconColor = config.Gradow.uicolor.lightGray
}) do
    HitboxTab:Paragraph({
        Title = "Gravel",
        Desc = "[ Bad Injectors might work here ]\n[ This might not work on every game ]",
        Color = config.Gradow.uicolor.darkGray
    })
    
    HitboxTab:Paragraph({
        Title = "Hitbox Master",
        Desc = "Master control for hitbox expansion",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    HitboxTab:Toggle({
        Title = "Toggle Hitbox ('G')",
        Desc = "Expand hitboxes",
        Value = config.hitboxEnabled or false,
        Callback = function(v)
            config.hitboxEnabled = v
            if v then
                applyhb()
                n({
                    Title = "Hitbox",
                    Content = "Enabled",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(0, 255, 0)
                })
            else
                for player, _ in pairs(config.hitboxExpandedParts) do
                    restoreTorso(player)
                end
                config.hitboxExpandedParts = {}
                n({
                    Title = "Hitbox",
                    Content = "Disabled",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(255, 0, 0)
                })
            end
        end
    })
    HitboxTab:Space()
    HitboxTab:Paragraph({
        Title = "Hitbox Settings",
        Desc = "Configuration for hitbox expansion",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    HitboxTab:Dropdown({
        Title = "Team Target",
        Desc = "Select target team preference",
        Values = {"Enemies", "Teams", "All"},
        Value = config.hitboxTeamTarget or "Enemies",
        Multi = false,
        Callback = function(Option)
            if config.masterTeamTarget == "All" then return end
            config.hitboxTeamTarget = Option
            applyhb()
        end
    })
    
    HitboxTab:Slider({
        Title = "Hitbox Size",
        Desc = "Size of expanded hitboxes",
        IsTextbox = true,
        Step = 5,
        Value = {
            Min = 1,
            Max = 500,
            Default = config.hitboxSize or 10
        },
        Callback = function(value)
            config.hitboxSize = value
            if config.hitboxEnabled then
                for player, data in pairs(config.hitboxExpandedParts) do
                    if player and targethb(player) and data and data.part and data.part.Parent then
                        local newSize = Vector3.new(value, value, value)
                        data.targetSize = newSize
                        config.hitboxLastSize[player] = value
                        pcall(function()
                            data.part.Size = newSize
                        end)
                    end
                end
            end
        end
    })
end

local ReachTab = Window:Tab({
    Title = "Reach",
    Desc = rng3("Reach"),
    Icon = "sword",
    IconColor = config.Gradow.uicolor.lightGray
}) do
    ReachTab:Paragraph({
        Title = "Gravel",
        Desc = "[ FireTouchInterest ]\n[ Melees Recommended ]\n[ Bad Injectors might work here ]\n[ This might not work for every game ]",
        Color = config.Gradow.uicolor.darkGray
    })
    
    ReachTab:Paragraph({
        Title = "Reach Master",
        Desc = "Master control for extended reach",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    local visualizer = Instance.new("Part") 
    visualizer.BrickColor = BrickColor.new(config.visualizer.color)
    visualizer.Transparency = config.visualizer.transparency
    visualizer.Anchored = true 
    visualizer.CanCollide = false 
    visualizer.Size = Vector3.new(0.5, 0.5, 0.5) 
    visualizer.BottomSurface = Enum.SurfaceType.Smooth 
    visualizer.TopSurface = Enum.SurfaceType.Smooth 
    visualizer.Material = Enum.Material.ForceField
    
    local autoSwingConnection = nil

    ReachTab:Toggle({
        Title = "Enable Reach",
        Desc = "Extend weapon reach distance",
        Value = config.reach.enabled,
        Callback = function(v)
            config.reach.enabled = v
            if not v then
                visualizer.Parent = nil
                if autoSwingConnection then
                    autoSwingConnection:Disconnect()
                    autoSwingConnection = nil
                end
            end
            n({
                Title = "Reach",
                Content = "Reach " .. (v and "Enabled" or "Disabled"),
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = v and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            })
        end
    })
    
    ReachTab:Paragraph({
        Title = "Reach Settings",
        Desc = "Configuration for extended reach",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    ReachTab:Dropdown({
        Title = "Reach Type",
        Desc = "Shape of the reach area",
        Values = {"Sphere", "Flat"},
        Value = config.reach.type,
        Multi = false,
        Callback = function(Option)
            config.reach.type = Option
        end
    })
    
    ReachTab:Input({
        Title = "Reach Distance",
        Desc = "Enter exact reach value",
        Placeholder = "10",
        Value = tostring(config.reach.distance),
        ClearTextOnFocus = true,
        Callback = function(text)
            local num = tonumber(text)
            if num and num > 0 then
                config.reach.distance = num
            end
        end
    })
    
    ReachTab:Paragraph({
        Title = "Visuals",
        Desc = "Visual settings for reach indicator",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    ReachTab:Toggle({
        Title = "Show Visualizer",
        Desc = "Display reach area visually",
        Value = config.visualizer.enabled,
        Callback = function(v)
            config.visualizer.enabled = v
            if not v then
                visualizer.Parent = nil
            end
        end
    })
    
    ReachTab:Dropdown({
        Title = "Visualizer Material",
        Desc = "Material for visualizer",
        Values = {"ForceField", "Plastic", "Glass", "Neon", "SmoothPlastic", "Metal", "DiamondPlate"},
        Value = config.visualizer.material,
        Multi = false,
        Callback = function(Option)
            config.visualizer.material = Option
            if visualizer.Parent then
                visualizer.Material = config.materials[config.visualizer.material]
            end
        end
    })
    
    ReachTab:Slider({
        Title = "Visualizer Transparency",
        Desc = "Transparency of reach visualizer",
        Step = 0.05,
        Value = {
            Min = 0,
            Max = 1,
            Default = config.visualizer.transparency
        },
        Callback = function(value)
            config.visualizer.transparency = value
            visualizer.Transparency = value
        end
    })
    
    ReachTab:Toggle({
        Title = "Auto activate",
        Desc = "Automatically activate tool",
        Value = config.reach.autoSwing.enabled,
        Callback = function(v)
            config.reach.autoSwing.enabled = v
            if v then
                if autoSwingConnection then
                    autoSwingConnection:Disconnect()
                end
                
                autoSwingConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if config.reach.autoSwing.enabled and game.Players.LocalPlayer.Character then
                        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool then
                            pcall(function()
                                tool:Activate()
                            end)
                        end
                    end
                end)
            else
                if autoSwingConnection then
                    autoSwingConnection:Disconnect()
                    autoSwingConnection = nil
                end
            end
        end
    })
    
    ReachTab:Slider({
        Title = "Activate Delay",
        Desc = "Delay between Activate",
        Step = 0.05,
        Suffix = "seconds",
        Value = {
            Min = 0.05,
            Max = 2,
            Default = config.reach.autoSwing.delay
        },
        Callback = function(value)
            config.reach.autoSwing.delay = value
            if autoSwingConnection then
                autoSwingConnection:Disconnect()
                autoSwingConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if config.reach.autoSwing.enabled and game.Players.LocalPlayer.Character then
                        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool then
                            pcall(function()
                                tool:Activate()
                            end)
                            task.wait(value)
                        end
                    end
                end)
            end
        end
    })
    
    local function onHit(hit, handle)
        if not config.reach.enabled then return end
        
        local hitCharacter = hit.Parent
        if not hitCharacter then return end
        
        local victim = hitCharacter:FindFirstChildOfClass("Humanoid") 
        if victim and victim.Parent ~= game.Players.LocalPlayer then
            pcall(function()
                firetouchinterest(hit, handle, 0) 
                firetouchinterest(hit, handle, 1)
            end)
        end
    end
    
    local function getTargetsInRange()
        local targets = {}
        local character = game.Players.LocalPlayer.Character
        if not character then return targets end
        
        local tool = character:FindFirstChildOfClass("Tool") 
        if not tool then return targets end
        
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("Part")
        if not handle then return targets end
        
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local distance = (hrp.Position - handle.Position).Magnitude
                    if distance <= config.reach.distance then
                        table.insert(targets, {
                            player = player,
                            hrp = hrp,
                            distance = distance
                        })
                    end
                end
            end
        end
        
        return targets
    end
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if not config.reach.enabled then 
            visualizer.Parent = nil
            return 
        end
        
        local character = game.Players.LocalPlayer.Character
        if not character then 
            visualizer.Parent = nil
            return 
        end
        
        local tool = character:FindFirstChildOfClass("Tool") 
        if not tool then 
            visualizer.Parent = nil
            return 
        end
        
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("Part")
        if not handle then 
            visualizer.Parent = nil
            return 
        end
        
        if config.visualizer.enabled then 
            visualizer.Parent = workspace 
            visualizer.Material = config.materials[config.visualizer.material] or Enum.Material.ForceField
            
            if config.reach.type == "Sphere" then
                visualizer.Shape = Enum.PartType.Ball
                visualizer.Size = Vector3.new(config.reach.distance, config.reach.distance, config.reach.distance)
                visualizer.CFrame = handle.CFrame
            elseif config.reach.type == "Flat" then
                visualizer.Shape = Enum.PartType.Block
                visualizer.Size = Vector3.new(config.reach.distance, 0.2, config.reach.distance)
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    visualizer.CFrame = CFrame.new(rootPart.Position) * CFrame.new(0, -2.5, 0)
                end
            end
            
            visualizer.Color = config.visualizer.color
        else 
            visualizer.Parent = nil 
        end
        
        local targets = getTargetsInRange()
        for _, target in ipairs(targets) do
            onHit(target.hrp, handle)
        end
    end)
    
    ReachTab:Paragraph({
        Title = "Utilities",
        Desc = "Utility functions for reach",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    ReachTab:Button({
        Title = "Clear Visualizer",
        Desc = "Remove reach visualizer",
        Callback = function()
            visualizer.Parent = nil
            n({
                Title = "Reach",
                Content = "Visualizer cleared",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(0, 170, 255)
            })
        end
    })
    
    ReachTab:Button({
        Title = "Find Nearby Weapons",
        Desc = "Scan for nearby weapons/tools",
        Callback = function()
            local weapons = {}
            local character = game.Players.LocalPlayer.Character
            
            if character then
                for _, child in ipairs(character:GetChildren()) do
                    if child:IsA("Tool") then
                        table.insert(weapons, child.Name)
                    end
                end
                
                for _, child in ipairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                    if child:IsA("Tool") then
                        table.insert(weapons, child.Name)
                    end
                end
            end
            
            if #weapons > 0 then
                n({
                    Title = "Weapons Found",
                    Content = "Found " .. #weapons .. " weapon(s): " .. table.concat(weapons, ", "),
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(0, 255, 0)
                })
            else
                n({
                    Title = "No Weapons",
                    Content = "No weapons/tools found",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(255, 0, 0)
                })
            end
        end
    })
end

-- Client Tab
local ClientTab = Window:Tab({
    Title = "Client",
    Desc = rng3("Client"),
    Icon = "user",
    IconColor = config.Gradow.uicolor.lightGray
}) do
    ClientTab:Paragraph({
        Title = "Client Master",
        Desc = "Master control for client features",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    ClientTab:Toggle({
        Title = "Enable Client Values ('N')",
        Desc = "Enable/disable all client features",
        Value = config.clientMasterEnabled or false,
        Callback = function(v)
            applyClientMaster(v)
        end
    })
    
    ClientTab:Paragraph({
        Title = "Client Features",
        Desc = "Individual client feature toggles",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    ClientTab:Toggle({
        Title = "Noclip",
        Desc = "Walk through walls",
        Value = config.clientNoclipEnabled or false,
        Callback = function(v)
            config.clientNoclipEnabled = v
            if config.clientMasterEnabled then
                if v then
                    startNoclip()
                    config.clientNoclip = true
                else
                    stopNoclip()
                    config.clientNoclip = false
                end
            else
                stopNoclip()
                config.clientNoclip = false
            end
        end
    })
    
    ClientTab:Toggle({
        Title = "Enable WalkSpeed",
        Desc = "Custom walk speed",
        Value = config.clientWalkEnabled or false,
        Callback = function(v)
            config.clientWalkEnabled = v
            if config.clientMasterEnabled and v then
                applyClientWalkSpeed(config.clientWalkSpeed or 16)
            end
        end
    })
    
    ClientTab:Toggle({
        Title = "Enable JumpPower",
        Desc = "Custom jump power",
        Value = config.clientJumpEnabled or false,
        Callback = function(v)
            config.clientJumpEnabled = v
            if config.clientMasterEnabled and v then
                applyClientJumpPower(config.clientJumpPower or 50)
            end
        end
    })
    
    ClientTab:Toggle({
        Title = "CFrame Walk",
        Desc = "Smooth CFrame movement",
        Value = config.clientCFrameWalkToggle or false,
        Callback = function(v)
            config.clientCFrameWalkToggle = v
            if config.clientMasterEnabled then
                if v then
                    TpWalkStart()
                    config.clientCFrameWalkEnabled = true
                else
                    TpWalkStop()
                    config.clientCFrameWalkEnabled = false
                end
            else
                TpWalkStop()
                config.clientCFrameWalkEnabled = false
            end
        end
    })
    
    ClientTab:Paragraph({
        Title = "Client Values",
        Desc = "Numerical values for client features",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    ClientTab:Slider({
        Title = "WalkSpeed Value",
        Desc = "Custom walk speed value",
        IsTextbox = true,
        Step = 5,
        Value = {
            Min = 0,
            Max = 500,
            Default = config.clientWalkSpeed or 16
        },
        Callback = function(value)
            config.clientWalkSpeed = value
            if config.clientMasterEnabled and config.clientWalkEnabled then
                applyClientWalkSpeed(value)
            end
        end
    })
    
    ClientTab:Slider({
        Title = "JumpPower Value",
        Desc = "Custom jump power value",
        IsTextbox = true,
        Step = 5,
        Value = {
            Min = 0,
            Max = 500,
            Default = config.clientJumpPower or 50
        },
        Callback = function(value)
            config.clientJumpPower = value
            if config.clientMasterEnabled and config.clientJumpEnabled then
                applyClientJumpPower(value)
            end
        end
    })
    
    ClientTab:Slider({
        Title = "CFrame Walk Speed",
        Desc = "CFrame movement speed",
        IsTextbox = true,
        Step = 0,
        Value = {
            Min = 0,
            Max = 500,
            Default = config.clientCFrameSpeed or 1
        },
        Callback = function(value)
            config.clientCFrameSpeed = value
        end
    })
    
    ClientTab:Paragraph({
        Title = "Client Stuff",
        Desc = "Additional client utilities",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    ClientTab:Toggle({
        Title = "Truss",
        Desc = "Creates a claimable part to fly (Less detectable)",
        Value = config.trussEnabled or false,
        Callback = function(v)
            config.trussEnabled = v
            if v then
                local player = game.Players.LocalPlayer
                local character = player.Character
                if not character then
                    n({
                        Title = "Truss",
                        Content = "Character not found!",
                        Audio = "rbxassetid://17208361335",
                        Length = 1,
                        Image = "rbxassetid://4483362458",
                        BarColor = Color3.fromRGB(255, 0, 0)
                    })
                    return
                end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then
                    n({
                        Title = "Truss",
                        Content = "HumanoidRootPart not found!",
                        Audio = "rbxassetid://17208361335",
                        Length = 1,
                        Image = "rbxassetid://4483362458",
                        BarColor = Color3.fromRGB(255, 0, 0)
                    })
                    return
                end
                
                if config.trussPart then
                    config.trussPart:Destroy()
                    config.trussPart = nil
                end
                
                if config.trussConnection then
                    config.trussConnection:Disconnect()
                    config.trussConnection = nil
                end
                
                config.trussPart = Instance.new("TrussPart")
                config.trussPart.Transparency = 1
                config.trussPart.Size = Vector3.new(2, 10, 2)
                config.trussPart.Parent = workspace
                config.trussPart.CanCollide = true
                config.trussPart.Name = "TrussPart_" .. tostring(math.random(10000, 99999))
                
                config.trussConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if config.trussEnabled and config.trussPart and rootPart and rootPart.Parent then
                        config.trussPart.CFrame = rootPart.CFrame * CFrame.new(0, 0, -1.5)
                    else
                        if config.trussConnection then
                            config.trussConnection:Disconnect()
                            config.trussConnection = nil
                        end
                    end
                end)
                
                n({
                    Title = "Truss",
                    Content = "Enabled - Created climb part",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(0, 255, 0)
                })
            else
                if config.trussPart then
                    config.trussPart:Destroy()
                    config.trussPart = nil
                end
                
                if config.trussConnection then
                    config.trussConnection:Disconnect()
                    config.trussConnection = nil
                end
                
                n({
                    Title = "Truss",
                    Content = "Disabled - Removed climb part",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(255, 0, 0)
                })
            end
        end
    })
    
    ClientTab:Toggle({
        Title = "Airwalk",
        Desc = "Walk on air",
        Value = config.airwalkEnabled or false,
        Callback = function(v)
            config.airwalkEnabled = v
            if v then
                local character = game.Players.LocalPlayer.Character
                if not character then
                    n({
                        Title = "Airwalk",
                        Content = "Character not found!",
                        Audio = "rbxassetid://17208361335",
                        Length = 1,
                        Image = "rbxassetid://4483362458",
                        BarColor = Color3.fromRGB(255, 0, 0)
                    })
                    return
                end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then
                    n({
                        Title = "Airwalk",
                        Content = "HumanoidRootPart not found!",
                        Audio = "rbxassetid://17208361335",
                        Length = 1,
                        Image = "rbxassetid://4483362458",
                        BarColor = Color3.fromRGB(255, 0, 0)
                    })
                    return
                end
                
                config.airwalkPart = Instance.new("Part")
                config.airwalkPart.Transparency = 1
                config.airwalkPart.Size = Vector3.new(7, 2, 3)
                config.airwalkPart.Parent = workspace
                config.airwalkPart.CanCollide = true
                config.airwalkPart.Anchored = true
                config.airwalkPart.Name = "AirwalkPlatform_" .. tostring(math.random(10000, 99999))
                
                if config.airwalkConnection then
                    config.airwalkConnection:Disconnect()
                    config.airwalkConnection = nil
                end
                
                config.airwalkConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if config.airwalkEnabled and config.airwalkPart and rootPart and rootPart.Parent then
                        config.airwalkPart.CFrame = rootPart.CFrame + Vector3.new(0, -4, 0)
                    else
                        if config.airwalkConnection then
                            config.airwalkConnection:Disconnect()
                            config.airwalkConnection = nil
                        end
                    end
                end)
                
                n({
                    Title = "Airwalk",
                    Content = "Enabled - Created air platform",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(0, 255, 0)
                })
            else
                if config.airwalkPart then
                    config.airwalkPart:Destroy()
                    config.airwalkPart = nil
                end
                
                if config.airwalkConnection then
                    config.airwalkConnection:Disconnect()
                    config.airwalkConnection = nil
                end
                
                n({
                    Title = "Airwalk",
                    Content = "Disabled - Removed air platform",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(255, 0, 0)
                })
            end
        end
    })
    
    ClientTab:Toggle({
        Title = "Auto Respawn",
        Desc = "Respawns where you died from",
        Value = config.autorespawnEnabled or false,
        Callback = function(v)
            config.autorespawnEnabled = v
            if v then
                config.autorespawnConnections = config.autorespawnConnections or {}
                config.autorespawnDeathPosition = nil
                
                local player = game.Players.LocalPlayer
                local function setupRespawn(character)
                    local humanoid = character:WaitForChild("Humanoid")
                    local rootPart = character:WaitForChild("HumanoidRootPart")
                    
                    if config.autorespawnConnections.died then
                        config.autorespawnConnections.died:Disconnect()
                    end
                    
                    config.autorespawnConnections.died = humanoid.Died:Connect(function()
                        if config.autorespawnEnabled then
                            config.autorespawnDeathPosition = rootPart.CFrame
                        end
                    end)
                end
                
                local function teleportToDeathPosition(newCharacter)
                    if config.autorespawnEnabled and config.autorespawnDeathPosition then
                        local newRoot = newCharacter:WaitForChild("HumanoidRootPart")
                        newRoot.CFrame = config.autorespawnDeathPosition
                        n({
                            Title = "AutoRespawn",
                            Content = "Teleported to death location",
                            Audio = "rbxassetid://17208361335",
                            Length = 1,
                            Image = "rbxassetid://4483362458",
                            BarColor = Color3.fromRGB(0, 255, 0)
                        })
                        config.autorespawnDeathPosition = nil
                    end
                end
                
                if player.Character then
                    setupRespawn(player.Character)
                end
                if config.autorespawnConnections.characterAdded then
                    config.autorespawnConnections.characterAdded:Disconnect()
                end
                
                config.autorespawnConnections.characterAdded = player.CharacterAdded:Connect(function(character)
                    if config.autorespawnEnabled then
                        character:WaitForChild("Humanoid")
                        character:WaitForChild("HumanoidRootPart")
                        teleportToDeathPosition(character)
                        setupRespawn(character)
                    end
                end)
                
                n({
                    Title = "AutoRespawn",
                    Content = "Enabled - Will respawn at death location",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(0, 255, 0)
                })
            else
                config.autorespawnDeathPosition = nil
                if config.autorespawnConnections then
                    for _, connection in pairs(config.autorespawnConnections) do
                        if connection then
                            connection:Disconnect()
                        end
                    end
                    config.autorespawnConnections = {}
                end
                
                n({
                    Title = "AutoRespawn",
                    Content = "Disabled",
                    Audio = "rbxassetid://17208361335",
                    Length = 1,
                    Image = "rbxassetid://4483362458",
                    BarColor = Color3.fromRGB(255, 0, 0)
                })
            end
        end
    })
    
    ClientTab:Toggle({
        Title = "FastSpawn",
        Desc = "Auto Respawn faster (Might cause deathloops)",
        Value = config.fastspawn or false,
        Callback = function(v)
            config.fastspawn = v
            n({
                Title = "FastSpawn",
                Content = "FastSpawn " .. (v and "Enabled" or "Disabled"),
                Audio = "rbxassetid://17208361335",
                Length = 1,
                Image = "rbxassetid://4483362458",
                BarColor = v and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            })
        end
    })
end

-- Misc Tab
local MiscTab = Window:Tab({
    Title = "Miscellaneous",
    Desc = rng3("Miscellaneous"),
    Icon = "settings",
    IconColor = config.Gradow.uicolor.lightGray
}) do
MiscTab:Paragraph({
    Title = "Trigger Bot",
    Desc = "Automatically shoot when crosshair is on target\nNot mobile friendly!",
    Color = config.Gradow.uicolor.lightGreen
})

MiscTab:Toggle({
    Title = "Enable TriggerBot",
    Desc = "Toggle triggerbot on/off",
    Value = config.tbot.enabled or false,
    Callback = function(v)
        toggleTriggerBot(v)
        WindUI:Notify({
            Title = "Trigger Bot",
            Content = v and "Enabled" or "Disabled",
            Icon = v and "check" or "x",
            Duration = 2
        })
    end
})

MiscTab:Dropdown({
    Title = "Tbot Target Part",
    Desc = "Part to aim for",
    Values = {"Head", "HumanoidRootPart", "Random"},
    Value = config.tbot.targetPart or "Head",
    Multi = false,
    Callback = function(Option)
        config.tbot.targetPart = Option
    end
})

MiscTab:Slider({
    Title = "Tbot FOV Radius",
    Desc = "Trigger bot field of view",
    IsTextbox = true,
    Step = 5,
    Value = {
        Min = 10,
        Max = 500,
        Default = config.tbot.fovRadius or 150
    },
    Callback = function(value)
        config.tbot.fovRadius = value
        updateTriggerBotFOV()
    end
})

MiscTab:Slider({
    Title = "Tbot Hit Chance",
    Desc = "Chance to shoot when target is in FOV",
    Step = 1,
    Suffix = "%",
    Value = {
        Min = 1,
        Max = 100,
        Default = config.tbot.hitChance or 100
    },
    Callback = function(value)
        config.tbot.hitChance = value
    end
})

MiscTab:Slider({
    Title = "Tbot Shot Delay",
    Desc = "Delay between shots (seconds)",
    Step = 0.01,
    Suffix = "s",
    Value = {
        Min = 0.01,
        Max = 1,
        Default = config.tbot.delay or 0.1
    },
    Callback = function(value)
        config.tbot.delay = value
    end
})

MiscTab:Toggle({
    Title = "Tbot Wall Check ('Y')",
    Desc = "Check for walls before shooting",
    Value = config.tbot.wallCheck or false,
    Callback = function(v)
        config.tbot.wallCheck = v
    end
})

MiscTab:Toggle({
    Title = "Tbot Hold to Shoot",
    Desc = "Only shoot when holding a key",
    Value = config.tbot.holdToShoot or false,
    Callback = function(v)
        config.tbot.holdToShoot = v
    end
})

MiscTab:Input({
    Title = "Tbot Hold Key",
    Desc = "Key to hold for shooting",
    Placeholder = "MouseButton1",
    Value = config.tbot.holdKey or "MouseButton1",
    ClearTextOnFocus = true,
    Callback = function(text)
        if text and text ~= "" then
            config.tbot.holdKey = text
        end
    end
})
    
    MiscTab:Paragraph({
        Title = "Other",
        Desc = "Additional miscellaneous features",
        Color = config.Gradow.uicolor.lightGreen
    })

    MiscTab:Button({
        Title = "badapple (pls ignore)",
        Desc = "alt+f4",
        Callback = function()
              loadstring(game:HttpGet(urls.ewitsabadapple))()
        end
    })

    MiscTab:Button({
        Title = "bringparts (pls ignore)",
        Desc = "WHO FLUNGED ME1!!11!1 D:",
        Callback = function()
              loadstring(game:HttpGet(urls.tpuabasically))()
        end
    })

    MiscTab:Button({
        Title = "Brick.cc (pls ignore)",
        Desc = "I has da powa of unanchored (yes brick is back again :D!!1!1)",
        Callback = function()
              loadstring(game:HttpGet(urls.imbricked))()
        end
    })

    MiscTab:Button({
        Title = "🍪 (pls ignore)",
        Desc = "wowzerz iz dats a cookie?!",
        Callback = function()
            WindUI:Notify({
                Title = "wowo SOosoo yummy :3",
                Content = "$10",
                Icon = "shovel",
                Duration = 1
            })
        end
    })
    MiscTab:Button({
        Title = "pop-up (pls ignore)",
        Desc = "it's the same pop-up that appears when da script loads",
        Callback = function()
           rng()
            WindUI:Notify({
                Title = "wat",
                Content = "pop-up thingamasilly",
                Icon = "shovel",
                Duration = 1
            })
        end
    })
    MiscTab:Button({
        Title = "notif (pls ignore)",
        Desc = "it's the same annoying notif that appears when da script loads",
        Callback = function()
            rng2()
            WindUI:Notify({
                Title = "*notifys cutely*",
                Content = "lolz",
                Icon = "shovel",
                Duration = 1
            })
        end
    })
    MiscTab:Button({
        Title = "iwanttobanishthisspecificplayer (pls ignore)",
        Desc = "'iwanttobanishthisspecificplayer' sick gui name for a fling script right??",
        Callback = function()
           loadstring(game:HttpGet(urls.wflingguiname))()
            WindUI:Notify({
                Title = "insane gui name",
                Content = "right???",
                Icon = "shovel",
                Duration = 1
            })
        end
    })
    MiscTab:Button({
        Title = "invistool (pls ignore)",
        Desc = "'why do u need ts",
        Callback = function()
           ineedinvistool()
            WindUI:Notify({
                Title = "I'm hiding :3",
                Content = "wouldn't call a script without an invistool",
                Icon = "shovel",
                Duration = 1
            })
        end
    })
MiscTab:Toggle({
    Title = "Enable BHop",
    Desc = "Toggle bunny hop on/off",
    Value = config.bhop.enabled or false,
    Callback = function(v)
        toggleBHop(v)
    end
})

MiscTab:Slider({
    Title = "Bhop Jump Delay",
    Desc = "Delay between jumps (seconds)",
    Step = 0.01,
    Suffix = "s",
    Value = {
        Min = 0.01,
        Max = 0.5,
        Default = config.bhop.jumpDelay or 0.05
    },
    Callback = function(value)
        config.bhop.jumpDelay = value
    end
})

MiscTab:Toggle({
    Title = "Bhop QT",
    Desc = "Show BHop's custom quick toggle on screen",
    Value = config.bhop.quickToggleEnabled or false,
    Callback = function(v)
        config.bhop.quickToggleEnabled = v
        updateBHopQuickToggle()
    end
})

MiscTab:Toggle({
    Title = "Bhop QT Draggable",
    Desc = "Allow dragging the BHop quick toggle",
    Value = config.bhop.quickToggleDraggable or true,
    Callback = function(v)
        config.bhop.quickToggleDraggable = v
        if config.varibz.bhopQuickToggleUI and config.varibz.bhopQuickToggleUI.Main then
            config.varibz.bhopQuickToggleUI.Main.Draggable = v
        end
    end
})
    MiscTab:Toggle({
        Title = "Toggle AntiAfk",
        Desc = "Prevents idle kick",
        Value = config.antiafk or false,
        Callback = function(v)
            config.antiafk = v
            WindUI:Notify({
                Title = "AntiAfk",
                Content = "AntiAfk " .. (v and "Enabled" or "Disabled"),
                Icon = v and "check" or "x",
                Duration = 2
            })
        end
    })
MiscTab:Toggle({
    Title = "Cframe View",
    Desc = "view randos with cframe view & kill em >:]",
    Value = config.wallc or false,
    Callback = function(v)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local Camera = workspace.CurrentCamera
        local Teams = game:GetService("Teams")

        config.Viewing = v

        if config.varibz.ViewConnection then
            config.varibz.ViewConnection:Disconnect()
            config.varibz.ViewConnection = nil
        end

        if not v then
            Camera.CameraType = Enum.CameraType.Custom
            return
        end

        local function isEnemy(player)
            if not player or player == Players.LocalPlayer then return false end
            local localTeam = Players.LocalPlayer.Team
            local targetTeam = player.Team
            
            if config.masterTeamTarget == "All" then
                return true
            elseif config.masterTeamTarget == "Enemies" then
                if localTeam and targetTeam then
                    return localTeam ~= targetTeam
                end
                return true
            elseif config.masterTeamTarget == "Teams" then
                if localTeam and targetTeam then
                    return localTeam == targetTeam
                end
                return false
            end
            return true
        end

        local function isNPCEnemy(model)
            if not model or not model:IsA("Model") then return false end
            if Players:GetPlayerFromCharacter(model) then return false end
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return false end
            if not (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")) then return false end
            if config.masterTeamTarget == "All" then
                return true
            elseif config.masterTeamTarget == "Enemies" then
                local npcTeam = model:FindFirstChild("Team")
                if npcTeam then
                    local localTeam = Players.LocalPlayer.Team
                    if localTeam and npcTeam:IsA("ObjectValue") and npcTeam.Value then
                        return localTeam ~= npcTeam.Value
                    end
                end
                return true
            elseif config.masterTeamTarget == "Teams" then
                local npcTeam = model:FindFirstChild("Team")
                if npcTeam and npcTeam:IsA("ObjectValue") and npcTeam.Value then
                    local localTeam = Players.LocalPlayer.Team
                    if localTeam then
                        return localTeam == npcTeam.Value
                    end
                end
                return false
            end
            return true
        end

        local function GetNearestTarget()
            local localPlayer = Players.LocalPlayer
            local localChar = localPlayer.Character
            if not localChar then return nil end
            
            local localRoot = localChar:FindFirstChild("HumanoidRootPart") or localChar:FindFirstChild("Head")
            if not localRoot then return nil end
            
            local nearestTarget = nil
            local nearestDistance = math.huge
            local masterTarget = config.masterTarget or "Players"
            if masterTarget == "Players" or masterTarget == "Both" then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= localPlayer
                        and plr.Character
                        and plr.Character:FindFirstChild("HumanoidRootPart")
                        and isEnemy(plr)
                    then
                        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            if not config.ignoreForcefield or not hasForcefield(plr.Character) then
                                local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                                if targetRoot then
                                    local distance = (localRoot.Position - targetRoot.Position).Magnitude
                                    if distance < nearestDistance then
                                        nearestDistance = distance
                                        nearestTarget = {
                                            type = "player",
                                            instance = plr,
                                            character = plr.Character
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if masterTarget == "NPCs" or masterTarget == "Both" then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and isNPCEnemy(obj) then
                        local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                        if rootPart then
                            local humanoid = obj:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                if not config.ignoreForcefield or not hasForcefield(obj) then
                                    local distance = (localRoot.Position - rootPart.Position).Magnitude
                                    if distance < nearestDistance then
                                        nearestDistance = distance
                                        nearestTarget = {
                                            type = "npc",
                                            instance = obj,
                                            character = obj,
                                            rootPart = rootPart
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end

            return nearestTarget
        end
        
        local function FindTargetWithLoop(maxAttempts)
            local attempts = 0
            local target = nil
            
            while attempts < (maxAttempts or 50) do
                target = GetNearestTarget()
                if target then
                    return target
                end
                attempts = attempts + 1
                task.wait(0.1)
            end
            
            return nil
        end

        local Target = FindTargetWithLoop(30)
        if not Target then
            WindUI:Notify({
                Title = "Cframe View",
                Content = "where da people",
                Icon = "x",
                Duration = 2
            })
            return
        end

        Camera.CameraType = Enum.CameraType.Scriptable
        local retryCounter = 0

        config.varibz.ViewConnection = RunService.RenderStepped:Connect(function()
            if not config.Viewing then
                return
            end
            
            local isValid = false
            if Target.type == "player" then
                isValid = Target.instance 
                    and Target.instance.Character 
                    and Target.instance.Character:FindFirstChild("HumanoidRootPart")
                    and isEnemy(Target.instance)
                    and Target.instance.Character:FindFirstChildOfClass("Humanoid") 
                    and Target.instance.Character:FindFirstChildOfClass("Humanoid").Health > 0
            elseif Target.type == "npc" then
                isValid = Target.instance 
                    and Target.instance.Parent 
                    and Target.instance:FindFirstChild("HumanoidRootPart")
                    and isNPCEnemy(Target.instance)
                    and Target.instance:FindFirstChildOfClass("Humanoid") 
                    and Target.instance:FindFirstChildOfClass("Humanoid").Health > 0
            end
            if not isValid then
                retryCounter = retryCounter + 1
                local newTarget = FindTargetWithLoop(20)
                
                if newTarget then
                    Target = newTarget
                    retryCounter = 0
                    return
                end
                if retryCounter > 100000 then
                    config.Viewing = false
                    Camera.CameraType = Enum.CameraType.Custom
                    return
                end
                task.wait(0.1)
                return
            else
                retryCounter = 0
            end

            local HRP = nil
            if Target.type == "player" then
                HRP = Target.instance.Character.HumanoidRootPart
            elseif Target.type == "npc" then
                HRP = Target.instance.HumanoidRootPart
            end
            
            if not HRP then
                return
            end

            local CameraPos = HRP.Position - HRP.CFrame.LookVector * config.varibz.CameraDistance + Vector3.new(0, 3, 0)
            Camera.CFrame = CFrame.lookAt(CameraPos, HRP.Position + Vector3.new(0, 2, 0))
        end)
        
        WindUI:Notify({
            Title = "Cframe View",
            Content = "Viewing " .. (Target.type == "player" and Target.instance.Name or "NPC"),
            Icon = "eye",
            Duration = 2
        })
    end
})
MiscTab:Slider({
    Title = "Zoom",
    Desc = "cframe view distance from target :7",
    IsTextbox = true,
    Step = 1,
    Value = {
        Min = 2,
        Max = 50,
        Default = 8
    },
    Callback = function(value)
        config.varibz.CameraDistance = value
    end
})
MiscTab:Toggle({
    Title = "WallOver",
    Desc = "Enable/disable WallOver (allows you to shoot over walls1!1!)",
    Value = config.camYOffsetEnabled or false,
    Callback = function(v)
        config.camYOffsetEnabled = v
        if not v then
            if config.camYOffsetConnection then
                config.camYOffsetConnection:Disconnect()
                config.camYOffsetConnection = nil
            end
            config.camYOffsetOriginalCFrame = nil
        else
            if not config.camYOffsetConnection then
                config.camYOffsetConnection = game:GetService("RunService").RenderStepped:Connect(function()
                    if config.camYOffsetEnabled then
                        local cam = workspace.CurrentCamera
                        if cam then
                            if not config.camYOffsetOriginalCFrame then
                                config.camYOffsetOriginalCFrame = cam.CFrame
                            end
                            local offset = Vector3.new(0, config.camYOffsetValue, 0)
                            local newCFrame = CFrame.new(
                                cam.CFrame.Position + offset,
                                cam.CFrame.Position + offset + cam.CFrame.LookVector
                            )
                            cam.CFrame = newCFrame
                        end
                    end
                end)
            end
        end
    end
})

MiscTab:Slider({
    Title = "WallOver Offset Value",
    Desc = "Vertical offset amount (0-500)",
    IsTextbox = true,
    Step = 1,
    Value = {
        Min = 0,
        Max = 500,
        Default = config.camYOffsetValue or 0
    },
    Callback = function(value)
        config.camYOffsetValue = value
    end
})
end

-- Info Tab
local InfoTab = Window:Tab({
    Title = "Info",
    Desc = rng3("Info"),
    Icon = "info",
    IconColor = config.Gradow.uicolor.lightGray
}) do
    InfoTab:Paragraph({
        Title = "Gravel",
        Desc = "Our YouTube channel is @gpssickle\nim mischievousidhwkwuhd",
        Color = config.Gradow.uicolor.Red
    })
    InfoTab:Paragraph({
        Title = "Gravel; SRC",
        Desc = "https://github.com/hm5650/HBSS/tree/main\n\nholy open source... if ur using a snippet that came from gravel.... credit me or I cry :(",
        Color = config.Gradow.uicolor.Black
    })
    InfoTab:Paragraph({
        Title = "Tabs",
        Desc = "Information about each tab",
        Color = config.Gradow.uicolor.Blue
    })
    
    InfoTab:Paragraph({
        Title = "MainTab",
        Desc = "All basic features, Team targeting, Configuring, optimizing and etc",
        Color = config.Gradow.uicolor.darkGray
    })
    
    InfoTab:Paragraph({
        Title = "Visualstab",
        Desc = "Changes your visuals full bright or rendering in esps",
        Color = config.Gradow.uicolor.darkGray
    })
    
    InfoTab:Paragraph({
        Title = "AntiAimTab",
        Desc = "It would do it's best to make your opponents miss every shot",
        Color = config.Gradow.uicolor.darkGray
    })
    
    InfoTab:Paragraph({
        Title = "AimbotTab",
        Desc = "Manipulates your camera and it would automatically aim at your opponents",
        Color = config.Gradow.uicolor.darkGray
    })
    
    InfoTab:Paragraph({
        Title = "SilentAimTab (HB)",
        Desc = "Automatically resizes opponents hitbox and aligning it to your crosshair or the center of your screen",
        Color = config.Gradow.uicolor.darkGray
    })
    
    InfoTab:Paragraph({
        Title = "SilentAimTab (HK)",
        Desc = "Intercepts raycasts to accurately hit targets.",
        Color = config.Gradow.uicolor.darkGray
    })

    InfoTab:Paragraph({
        Title = "HitboxTab",
        Desc = "Resizes opponents hitbox to easily hit or shoot at opponents",
        Color = config.Gradow.uicolor.darkGray
    })
    
    InfoTab:Paragraph({
        Title = "ReachTab",
        Desc = "Resizes your melee or any tools Firetouchinterest to hit opponents further",
        Color = config.Gradow.uicolor.darkGray
    })
    
    InfoTab:Paragraph({
        Title = "ClientTab",
        Desc = "Change your walkspeed or jump power or even fly around to dodge any attacks from your opponents",
        Color = config.Gradow.uicolor.darkGray
    })
    
    InfoTab:Paragraph({
        Title = "MiscTab",
        Desc = "Basically experiment any features that are or aren't related to combating",
        Color = config.Gradow.uicolor.darkGray
    })
    
    InfoTab:Paragraph({
        Title = "InfoTab",
        Desc = "InfoTab the tab that your in just shows informations or details",
        Color = config.Gradow.uicolor.darkGray
    })

    InfoTab:Paragraph({
        Title = "BotTab",
        Desc = "Deleted due to 200 variable limit & uselessness",
        Color = config.Gradow.uicolor.Red
    })
    InfoTab:Space()
    InfoTab:Paragraph({
        Title = "Guide",
        Desc = "Tutorial for some features",
        Color = config.Gradow.uicolor.Blue
    })
InfoTab:Paragraph({
    Title = "Save/Load Guide",
    Desc = [[
1. Type a name in "Save Name" (or leave blank for auto-name)

2. Click "New Save" to save your current settings

3. Type a saved name from "Save Name" inputbox and click "Load Save" to load it

4. Use "Delete Save" to remove a specific save (type in, Save Name from the inputbox)

5. Use "Delete All Saves" to remove ALL saves (requires 3 yessirski's)

Note: sum features might not get saved properly D:
]],
    Color = config.Gradow.uicolor.darkGray
})
InfoTab:Paragraph({
        Title = "Silent Aim (HB) Guide",
        Desc = [[
This is the most unique silent aim in the script.
It works by dynamically resizing the target's hitbox to match your FOV circle/crosshair, making it easier to hit

1. 'Scale To Screen': Makes the hitbox size adapt to your screen, ensuring it covers the FOV circle perfectly, best for third-person shooters

2. 'STS Distance': Adjusts the scaling to prevent the hitbox from clipping into you

3. 'WallOver': Found in the MiscTab it's the closest thing for wallbang for Silent Aim (HB) it allows you to shoot over walls!
]],
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Optimization Guide",
        Desc = [[
The script can be heavy. Use these settings to improve performance.

1. 'Updaters speed': Increase this value to reduce how often features like ESP and Hitbox update (e.g., set to 1.0 for better performance).

2. 'Cache Cleaners': Turn off if you have a powerful PC to improve responsiveness.

3. 'Low Render': Drops the game's graphics quality to boost FPS.

4. 'Errors': Disable to suppress error messages in the console prevents error spam that causes lag.
]],
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "RNG",
        Desc = [[
What is RNG? It stands for Random Number Generator.
Gravel uses it for picking random messages cuz yes

1. 'Open Button Title': The text on the button to open it would change everytime you reload the script

2. 'Tag Messages': The scrolling text at the top of the GUI, cycling through silly messages and references.

3. 'Popup Messages': The popup that appears when you load the script.

4. 'Notifications': The random titles and sounds in notifications just to jumpscare u

5. 'Tabs': Holding down a tab shows a Tooltip/Description which also has rng text :v

I luv rng's. :3
]],
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Space()
    InfoTab:Paragraph({
        Title = "Credits",
        Desc = "Credits to other creators",
        Color = config.Gradow.uicolor.lightGreen
    })
    
    InfoTab:Paragraph({
        Title = "Gravel: UI",
        Desc = "UI: WindUI (Footagesus)\nNotification: Alurt (Zwolf)\nand the other guy",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel: AntiKick",
        Desc = "AntiKick: Pixeluted (I think...)",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel: Math",
        Desc = "Mathematicalmatics: my teacher & the other other guy",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Space()
    InfoTab:Paragraph({
        Title = "Updatelog",
        Desc = "Update history and changes\n\nGravel (DD/MM/YYYY)",
        Color = config.Gradow.uicolor.lightGreen
    })

    InfoTab:Paragraph({
        Title = "Gravel (14/01/2026)",
        Desc = "Added: Legacy\nAdded: Reachtab\nAdded: Wallbang in Silentaim HK\nFixed Bugs: 0",
        Color = config.Gradow.uicolor.darkGray
    })
    
    InfoTab:Paragraph({
        Title = "Gravel (22/01/2026)",
        Desc = "Added: MiscTab\nChanged: Redesigned the OptionGui\nFixed Bugs: 9",
        Color = config.Gradow.uicolor.darkGray
    })
    
    InfoTab:Paragraph({
        Title = "Gravel (23/01/2026)",
        Desc = "Fixed: Execution Problem\nFixed: Bugs in the SilentAimTab (HK)\nAdded: BackgroundBlur on the loading screeen\nFixed Bugs: 27",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (02/02/2026)",
        Desc = "Changed: DummyUI to WindUI Rewritten UI Creation\nFixed: Keybind Systems are now more accurate and Rewritten\nFixed: SilentAimTab (HK) hooks now less laggy\nFixed: Loop Errors\nFixed: Notification Spam\nAdded: Colorpickers to the VisualsTab\nAdded: Random Messages to the OpenButton and Popup UI\nFixed: UI Causing errors, Callback errors\nFixed Bugs: 34+",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (10/02/2026)",
        Desc = "Added: Optimization and tweaks\nFixed: Optimized SilentAimTab (HK)\nAdded: Distance limitation to SilentAimTab (HK)\nAdded: Cache Optimization\nFixed Bugs: 5",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (06/05/2026)",
        Desc = "More optimizations!",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (18/05/2026)",
        Desc = "Removed: Bot Tab has been removed to avoid 200 variable limit\nInfo: SilentAim (HK) would no longer work at this time.\nAdded: Cam-Y or WallOver toggle to SilentAimTab (HB)\nAdded: Cframe View to MiscTab\nInfo: At this time Gravel.cc might be buggy for now.",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (18/05/2026)",
        Desc = "Removed: SilentAim (HK) is now removed due to an update :(",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (18/05/2026)",
        Desc = "Improved: SilentAim (HB) Accuracy",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (19/06/2026)",
        Desc = "Fixed: Targeting Systems\nFixed Bugs: 10",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (21/06/2026)",
        Desc = "Re-Added: SilentAim (HK) [Nothing wrong actually happened.. I'm just stupid]",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (23/06/2026)",
        Desc = "Fixed: SilentAim (HK) Targeting issues\nMoved: WallOver/Cam-Y to MiscTab\nAdded: ScaleToScreen Toggle & STSDistance to SilentAim (HB)\nAdded: some other additional features :p",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (25/06/2026)",
        Desc = "Added: Triggerbot & Spinbot in the MiscTab\nAdded: Additional stuff & optimization \nFixed Bugs: 7",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (27/06/2026)",
        Desc = "Added: Bhop in the MiscTab\nAdded: Draggable toggle for QuickToggles in MainTab\nMoved: Spinbot in the AntiAimTab\nFixed: Hitbox freezing issue\nAdded: Keybind for TriggerBot Wallcheck 'Y'\nChanged Client Keybind to 'N'\nFixed Bugs: 1",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (28/06/2026)",
        Desc = "Added: Save/Load in the MainTab :3",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (01/07/2026)",
        Desc = "Fixed: Save/Load bugs\nFixed: Hitbox bugs\nFixed Bugs: 5",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (06/07/2026)",
        Desc = "Added: Guide Section in InfoTab",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (07/07/2026)",
        Desc = "Fixed: Fixed sum lags",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (07/07/2026)",
        Desc = "Ignore forcefield now supports SilentAim (HK)",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (13/07/2026)",
        Desc = "Desync is back :>\nits in the AntiAim Tab!",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (14/07/2026)",
        Desc = "Other bug fixes that I didn't count",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (19/07/2026)",
        Desc = "Added: LazyLoader!\nAdded: UI Refreshing\nAdded: Additional stuff\nFixed Bugs: 7",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (20/07/2026)",
        Desc = "Error da handle",
        Color = config.Gradow.uicolor.darkGray
    })
    InfoTab:Paragraph({
        Title = "Gravel (23/07/2026)",
        Desc = "some QOL bs",
        Color = config.Gradow.uicolor.darkGray
    })
end

-- tsu
--[[
    InfoTab:Paragraph({
        Title = "Gravel (DD/07/2026)",
        Desc = "",
        Color = config.Gradow.uicolor.darkGray
    })
]]

local fovScreenGui = Instance.new("ScreenGui")
fovScreenGui.Name = "FOVToggleGui_Modern"
fovScreenGui.ResetOnSpawn = false
fovScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
fovScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = fovScreenGui

local ringHolder = Instance.new("Frame")
ringHolder.Name = "RingHolder"
ringHolder.AnchorPoint = Vector2.new(0.5, 0.5)
ringHolder.Size = UDim2.new(0, config.fovsize * 2, 0, config.fovsize * 2)
ringHolder.Position = UDim2.new(0.5, 0, 0.5, -28)
ringHolder.BackgroundTransparency = 1
ringHolder.Visible = false
ringHolder.Parent = mainFrame

local ringCorner = Instance.new("UICorner")
ringCorner.CornerRadius = UDim.new(1, 0)
ringCorner.Parent = ringHolder

local ringStroke = Instance.new("UIStroke")
ringStroke.Thickness = 1
ringStroke.LineJoinMode = Enum.LineJoinMode.Round
ringStroke.Parent = ringHolder
ringStroke.Color = config.fovc or Color3.fromRGB(200, 200, 255)
ringStroke.Transparency = 0

gui.ScreenGui = fovScreenGui
gui.MainFrame = mainFrame
gui.RingHolder = ringHolder
gui.RingStroke = ringStroke
aimbotfov()

local function SetupRespawnHandler()
    plr.CharacterAdded:Connect(function(character)
        if config.varibz.respawnLock then
            wait(1.5)
            
            local humanoid = character:WaitForChild("Humanoid", 5)
            if humanoid and humanoid.Health > 0 then
                if config.varibz.wasEnabledBeforeDeath then
                    config.SA2_Enabled = true
                end
                
                if config.varibz.wasESPEnabledBeforeDeath then
                    config.espMasterEnabled = true
                end
                
                config.varibz.respawnLock = false
                config.varibz.wasEnabledBeforeDeath = false
                config.varibz.wasESPEnabledBeforeDeath = false
            end
        end
    end)
    
    plr.CharacterRemoving:Connect(function(character)
        if config.SA2_Enabled then
            config.varibz.wasEnabledBeforeDeath = true
        end
        
        if config.espMasterEnabled then
            config.varibz.wasESPEnabledBeforeDeath = true
        end
        
        config.SA2_Enabled = false
        config.espMasterEnabled = false
        config.varibz.respawnLock = true
    end)
    
    local function trackHumanoidDeath()
        if plr.Character then
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Died:Connect(function()
                    if config.SA2_Enabled then
                        config.varibz.wasEnabledBeforeDeath = true
                    end
                    
                    if config.espMasterEnabled then
                        config.varibz.wasESPEnabledBeforeDeath = true
                    end
                    
                    config.SA2_Enabled = false
                    config.espMasterEnabled = false
                    config.varibz.respawnLock = true
                end)
            end
        end
    end
    
    if plr.Character then
        trackHumanoidDeath()
    end
    
    plr.CharacterAdded:Connect(function()
        wait(0.5)
        trackHumanoidDeath()
    end)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
end)

if LocalPlayer.Character then
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
end

local function initKeybinds()
    local UserInputService = game:GetService("UserInputService")
    local holdingModifier = false
    local function shouldTriggerKeybind(keyCode)
        if not config.KeybindsEnabled then
            return false
        end
        
        if config.HoldKeysEnabled then
            return holdingModifier
        end
        
        return true
    end
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[config.Keybinds.HoldKeybind] then
            holdingModifier = true
        end
        if config.HoldKeysEnabled and not holdingModifier then
            return
        end
        if input.KeyCode == Enum.KeyCode[config.Keybinds.silentaim] then
            if shouldTriggerKeybind(config.Keybinds.silentaim) then
                config.startsa = not config.startsa
                WindUI:Notify({
                    Title = "Silent Aim (HB)",
                    Content = config.startsa and "Enabled" or "Disabled",
                    Icon = config.startsa and "check" or "x",
                    Duration = 1
                })
                
                if not config.startsa and gui.RingHolder then
                    gui.RingHolder.Visible = false
                    local targetsToRemove = {}
                    for pl, _ in pairs(config.activeApplied) do
                        table.insert(targetsToRemove, pl)
                    end
                    for _, pl in ipairs(targetsToRemove) do
                        restorePartForPlayer(pl)
                    end
                elseif config.startsa and gui.RingHolder then
                    gui.RingHolder.Visible = true
                end
            end
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.silentaimhk] then
            if shouldTriggerKeybind(config.Keybinds.silentaimhk) then
                config.SA2_Enabled = not config.SA2_Enabled
                WindUI:Notify({
                    Title = "Silent Aim (HK)",
                    Content = config.SA2_Enabled and "Enabled" or "Disabled",
                    Icon = config.SA2_Enabled and "check" or "x",
                    Duration = 1
                })
            end
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.aimbot] then
            if shouldTriggerKeybind(config.Keybinds.aimbot) then
                handleAimbotToggle(not config.aimbotEnabled)
                WindUI:Notify({
                    Title = "Aimbot",
                    Content = config.aimbotEnabled and "Enabled" or "Disabled",
                    Icon = config.aimbotEnabled and "check" or "x",
                    Duration = 1
                })
            end
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.autofarm] then
            if shouldTriggerKeybind(config.Keybinds.autofarm) then
                config.autoFarmEnabled = not config.autoFarmEnabled
                if config.autoFarmEnabled then
                    autoFarmProcess()
                else
                    stopAutoFarm()
                end
                WindUI:Notify({
                    Title = "Auto Farm",
                    Content = config.autoFarmEnabled and "Enabled" or "Disabled",
                    Icon = config.autoFarmEnabled and "check" or "x",
                    Duration = 1
                })
            end
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.antiaim] then
            if shouldTriggerKeybind(config.Keybinds.antiaim) then
                config.antiAimEnabled = not config.antiAimEnabled
                if not config.antiAimEnabled then
                    returnToOriginalPosition()
                end
                WindUI:Notify({
                    Title = "Anti Aim",
                    Content = config.antiAimEnabled and "Enabled" or "Disabled",
                    Icon = config.antiAimEnabled and "check" or "x",
                    Duration = 1
                })
            end
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.triggerbot] then
            if shouldTriggerKeybind(config.Keybinds.triggerbot) then
                toggleTriggerBot(not config.tbot.enabled)
                WindUI:Notify({
                    Title = "Trigger Bot",
                    Content = config.tbot.enabled and "Enabled" or "Disabled",
                    Icon = config.tbot.enabled and "check" or "x",
                    Duration = 1
                })
            end
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.bhop] then
            if shouldTriggerKeybind(config.Keybinds.bhop) then
                toggleBHop(not config.bhop.enabled)
                WindUI:Notify({
                    Title = "BHop",
                    Content = config.bhop.enabled and "Enabled" or "Disabled",
                    Icon = config.bhop.enabled and "check" or "x",
                    Duration = 1
                })
            end
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.tbotwallcheck] then
            if shouldTriggerKeybind(config.Keybinds.tbotwallcheck) then
                config.tbot.wallCheck = not config.tbot.wallCheck
                WindUI:Notify({
                    Title = "TriggerBot Wall Check",
                    Content = config.tbot.wallCheck and "Enabled" or "Disabled",
                    Icon = config.tbot.wallCheck and "check" or "x",
                    Duration = 1
                })
            end
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.hitbox] then
            if shouldTriggerKeybind(config.Keybinds.hitbox) then
                config.hitboxEnabled = not config.hitboxEnabled
                if config.hitboxEnabled then
                    applyhb()
                else
                    for player, _ in pairs(config.hitboxExpandedParts) do
                        restoreTorso(player)
                    end
                    config.hitboxExpandedParts = {}
                end
                WindUI:Notify({
                    Title = "Hitbox",
                    Content = config.hitboxEnabled and "Enabled" or "Disabled",
                    Icon = config.hitboxEnabled and "check" or "x",
                    Duration = 1
                })
            end
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.esp] then
            if shouldTriggerKeybind(config.Keybinds.esp) then
                applyESPMaster(not config.espMasterEnabled)
                WindUI:Notify({
                    Title = "ESP",
                    Content = config.espMasterEnabled and "Enabled" or "Disabled",
                    Icon = config.espMasterEnabled and "check" or "x",
                    Duration = 1
                })
            end
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.client] then
            if shouldTriggerKeybind(config.Keybinds.client) then
                applyClientMaster(not config.clientMasterEnabled)
                WindUI:Notify({
                    Title = "Client Features",
                    Content = config.clientMasterEnabled and "Enabled" or "Disabled",
                    Icon = config.clientMasterEnabled and "check" or "x",
                    Duration = 1
                })
            end
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.silentaimwallcheck] then
            if shouldTriggerKeybind(config.Keybinds.silentaimwallcheck) then
                config.wallc = not config.wallc
                WindUI:Notify({
                    Title = "Silent Aim Wall Check",
                    Content = config.wallc and "Enabled" or "Disabled",
                    Icon = config.wallc and "check" or "x",
                    Duration = 1
                })
            end
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.aimbotwallcheck] then
            if shouldTriggerKeybind(config.Keybinds.aimbotwallcheck) then
                config.aimbotWallCheck = not config.aimbotWallCheck
                WindUI:Notify({
                    Title = "Aimbot Wall Check",
                    Content = config.aimbotWallCheck and "Enabled" or "Disabled",
                    Icon = config.aimbotWallCheck and "check" or "x",
                    Duration = 1
                })
            end
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.silentaimhkwallcheck] then
            if shouldTriggerKeybind(config.Keybinds.silentaimhkwallcheck) then
                config.SA2_Wallcheck = not config.SA2_Wallcheck
                WindUI:Notify({
                    Title = "Silent Aim HK Wall Check",
                    Content = config.SA2_Wallcheck and "Enabled" or "Disabled",
                    Icon = config.SA2_Wallcheck and "check" or "x",
                    Duration = 1
                })
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[config.Keybinds.HoldKeybind] then
            holdingModifier = false
        end
    end)
end

local function init()
    SetupRespawnHandler()
    syncSilentAimWithMaster()
    nextgenrepre()
    initKeybinds()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= localPlayer then
            setupPlayerListeners(pl)
        end
    end

    Players.PlayerAdded:Connect(function(pl)
        if pl ~= localPlayer then
            setupPlayerListeners(pl)
        end
    end)
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= localPlayer then
            setupPlayerListeners(pl)
            if config.hitboxEnabled and targethb(pl) then
                task.spawn(function()
                    task.wait(0.5)
                    expandhb(pl, config.hitboxSize)
                end)
            end
        end
    end
    Players.PlayerAdded:Connect(function(pl)
        if pl ~= localPlayer then
            setupPlayerListeners(pl)
            
            if config.hitboxEnabled then
                pl.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    if targethb(pl) then
                        expandhb(pl, config.hitboxSize)
                    end
                end)
                
                if pl.Character and targethb(pl) then
                    task.wait(0.5)
                    expandhb(pl, config.hitboxSize)
                end
            end
        end
    end)
    
    Players.PlayerRemoving:Connect(function(pl)
        cleanplrdata(pl)
    end)
    
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= localPlayer then
            setupPlayerListeners(pl)
            if config.espMasterEnabled then
                if config.prefTextESP or config.prefBoxESP or config.prefHealthESP then
                    if addesp(pl) then
                        makeesp(pl)
                    end
                end
                if config.prefHighlightESP and pl.Character then
                    if addesp(pl) then
                        high(pl)
                    end
                end
            end
        end
    end
    
    Players.PlayerAdded:Connect(function(pl)
        if pl ~= localPlayer then
            setupPlayerListeners(pl)
            task.wait(0.5)
            
            if config.espMasterEnabled then
                if config.prefTextESP or config.prefBoxESP or config.prefHealthESP then
                    if addesp(pl) then
                        makeesp(pl)
                    end
                end
                if config.prefHighlightESP and pl.Character then
                    if addesp(pl) then
                        high(pl)
                    end
                end
            end
        end
    end)
    RunService:BindToRenderStep("FOVhbUpdater_Modern", Enum.RenderPriority.First.Value, onRenderStep)
    task.wait(1)
    config.SA2_Wallbang = true
    config.varibz.lowpatcher = false
    getgenv().ED_AntiKickEnabled = false
    getgenv().ED_AntiKickCheckCaller = false
    config.varibz.sa2stuff = 0.5
    task.wait(0.40)
    config.varibz.sa2stuff = 0.5
    config.SA2_Wallbang = false
    config.varibz.lowpatcher = true
    getgenv().ED_AntiKickEnabled = true
    getgenv().ED_AntiKickCheckCaller = true
    print("47 72 61 76 65 6C 2E 63 63 20 4C 6F 61 64 65 64 21 20 3A 33")
    print("01000111 01110000 01110011 73 69 63 6B 6C 65")
    showurwholeipadress3827103828827273637() -- it doesn't actually...
end
function cleanup()
    pcall(function()
        RunService:UnbindFromRenderStep("FOVhbUpdater_Modern")
        RunService:UnbindFromRenderStep("ESPUpdater")
        stopAutoFarm()
        KillQT()
        config.varibz.aimbot360LoopRunning = false
        if config.varibz.aimbot360LoopTask then
            config.varibz.aimbot360LoopTask = nil
        end
        if config.aimbot360Enabled then
            toggle360Aimbot(false)
        end
        handleAimbotToggle(false)
        config.startsa = false
        config.SA2_Enabled = false
        if gui.RingHolder then
            gui.RingHolder.Visible = false
        end
        config.antiAimEnabled = false
        if config.isTeleported then
            returnToOriginalPosition()
        end
        config.antiAimAbovePlayer = false
        config.antiAimBehindPlayer = false
        config.antiAimOrbitEnabled = false
        config.raycastAntiAim = false
        config.spinbot.enabled = false
        if config.varibz.spinbotConnection then
            config.varibz.spinbotConnection:Disconnect()
            config.varibz.spinbotConnection = nil
        end
        toggleTriggerBot(false)
        if config.tbot.fovCircle and config.tbot.fovCircle.ScreenGui then
            config.tbot.fovCircle.ScreenGui:Destroy()
            config.tbot.fovCircle = nil
        end
        if config.varibz.triggerBotConnection then
            config.varibz.triggerBotConnection:Disconnect()
            config.varibz.triggerBotConnection = nil
        end
        toggleBHop(false)
        if config.varibz.bhopConnection then
            config.varibz.bhopConnection:Disconnect()
            config.varibz.bhopConnection = nil
        end
        if config.varibz.bhopQuickToggleUI and config.varibz.bhopQuickToggleUI.ScreenGui then
            config.varibz.bhopQuickToggleUI.ScreenGui:Destroy()
            config.varibz.bhopQuickToggleUI = nil
        end
        if config.clientMasterEnabled then
            applyClientMaster(false)
        end
        if _noclipConn then
            _noclipConn:Disconnect()
            _noclipConn = nil
        end
        if config._tpwalking then
            TpWalkStop()
        end
        restoreClientValues()
        config.trussEnabled = false
        if config.trussPart then
            config.trussPart:Destroy()
            config.trussPart = nil
        end
        if config.trussConnection then
            config.trussConnection:Disconnect()
            config.trussConnection = nil
        end
        config.airwalkEnabled = false
        if config.airwalkPart then
            config.airwalkPart:Destroy()
            config.airwalkPart = nil
        end
        if config.airwalkConnection then
            config.airwalkConnection:Disconnect()
            config.airwalkConnection = nil
        end
        config.autorespawnEnabled = false
        config.autorespawnDeathPosition = nil
        if config.autorespawnConnections then
            for _, connection in pairs(config.autorespawnConnections) do
                if connection then
                    connection:Disconnect()
                end
            end
            config.autorespawnConnections = {}
        end
        applyESPMaster(false)
        for target in pairs(config.espData) do
            removeESPLabel(target)
        end
        for target in pairs(config.highlightData) do
            removeHighlightESP(target)
        end
        for target in pairs(config.lineESPData) do
            removeLineESP(target)
        end
        config.espData = {}
        config.highlightData = {}
        config.lineESPData = {}
        config.hitboxEnabled = false
        for player, _ in pairs(config.hitboxExpandedParts) do
            restoreTorso(player)
        end
        config.hitboxExpandedParts = {}
        config.hitboxOriginalSizes = {}
        config.hitboxLastSize = {}
        for pl, _ in pairs(config.activeApplied) do
            restorePartForPlayer(pl)
        end
        config.activeApplied = {}
        config.originalSizes = {}
        config.targethbSizes = {}
        config.centerLocked = {}
        config.fbenabled = false
        if fullBrightSettings then
            local lighting = game:GetService("Lighting")
            for property, value in pairs(fullBrightSettings) do
                lighting[property] = value
            end
            fullBrightSettings = nil
        end
        config.Viewing = false
        if config.varibz.ViewConnection then
            config.varibz.ViewConnection:Disconnect()
            config.varibz.ViewConnection = nil
        end
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        config.camYOffsetEnabled = false
        if config.camYOffsetConnection then
            config.camYOffsetConnection:Disconnect()
            config.camYOffsetConnection = nil
        end
        config.camYOffsetOriginalCFrame = nil
        if gui and gui.ScreenGui and gui.ScreenGui.Parent then
            gui.ScreenGui:Destroy()
        end
        gui = {}
        if config.aimbotFOVRing and config.aimbotFOVRing.ScreenGui and config.aimbotFOVRing.ScreenGui.Parent then
            config.aimbotFOVRing.ScreenGui:Destroy()
        end
        config.aimbotFOVRing = nil
        
        if gui.mobileGui and gui.mobileGui.ScreenGui then
            gui.mobileGui.ScreenGui:Destroy()
        end
        gui.mobileGui = nil
        for pl, connections in pairs(config.playerConnections) do
            for _, conn in ipairs(connections) do
                pcall(function() conn:Disconnect() end)
            end
            config.playerConnections[pl] = nil
        end
        config.playerConnections = {}
        
        for pl, conn in pairs(config.characterConnections) do
            pcall(function() conn:Disconnect() end)
        end
        config.characterConnections = {}
        if config.desyncActive then
            ineednextgenrep(false)
        end
        if config.desyncSeat then
            config.desyncSeat:Destroy()
            config.desyncSeat = nil
        end
        if config.desyncWeld then
            config.desyncWeld:Destroy()
            config.desyncWeld = nil
        end
        if config.desyncLoop then
            config.desyncLoop:Disconnect()
            config.desyncLoop = nil
        end
        if config.desyncRespawnConnection then
            config.desyncRespawnConnection:Disconnect()
            config.desyncRespawnConnection = nil
        end
        config.desyncActive = false
        config.currentTarget = nil
        config.aimbotCurrentTarget = nil
        config.SA2_currentTarget = nil
        config.currentAutoFarmTarget = nil
        config.currentAntiAimTarget = nil
        config.targetSeenTargets = {}
        config.SA2_FovIsTargeted = false
        config.espMasterEnabled = false
        config.aimbotEnabled = false
        config.startsa = false
        config.SA2_Enabled = false
        config.hitboxEnabled = false
        config.antiAimEnabled = false
        config.autoFarmEnabled = false
        config.clientMasterEnabled = false
        config.tbot.enabled = false
        config.bhop.enabled = false
        config.spinbot.enabled = false
        config.QuickToggles = false
        config.fbenabled = false
        config.Viewing = false
        config.camYOffsetEnabled = false
        config.trussEnabled = false
        config.airwalkEnabled = false
        config.autorespawnEnabled = false
        config.antiafk = false
        config.fastspawn = false
        config.SSEnabled = false
        config.autoFarmCompleted = {}
        config.autoFarmOriginalPositions = {}
        config.hitboxExpandedParts = {}
        config.hitboxOriginalSizes = {}
        config.originalPosition = nil
        config.isTeleported = false
        config.desyncSavedCFrame = nil
        config.desyncHiddenPos = nil
        config.desyncTransparency = nil
        if lzl then
            lzl:cleanup()
            lzl.enabled = false
            lzl.loaded = {}
            lzl.q = {}
        end
        for _, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do
            v:Enable()
        end
        for _, v in pairs(getconnections(game:GetService("LogService").MessageOut)) do
            v:Enable()
        end
        config.varibz.lowpatcher = false
        config.varibz.patcher = false
        getgenv().Graaaaaaaaaaaaaaaaaaaaaaavel = false
    end)
end
local clearTargetCache = function()
    pcall(function()
        config.SA2_currentTarget = nil
        config.currentTarget = nil
        config.aimbotCurrentTarget = nil
        config.SA2_FovIsTargeted = false
        config.targetSeenTargets = {}
        config.autoFarmTargets = {}
        config.autoFarmCompleted = {}
    end)
end
task.spawn(function()
    while config.varibz.lowpatcher do
        clearTargetCache()
        task.wait(config.varibz.lowpatcherwait)
    end
end)

local LowRender = function()
    if config and config.LowRender then
        pcall(function()
            pc2()
            settings().Physics.AllowSleep = true
            settings().Rendering.QualityLevel = 1
            settings().Rendering.EagerBulkExecution = true
            settings().Rendering.EnableFRM = true
            settings().Rendering.MeshPartDetailLevel = 1
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").Technology = Enum.Technology.Legacy
            for _, v in pairs(game:GetService("Workspace"):GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                    v.Enabled = false
                end
            end
        end)
    else
        pcall(function()
           
        end)
    end
end

task.spawn(function()
    local lastRespawnTime = os.clock()
    while config.varibz.patcher do
        local localPlayer = game.Players.LocalPlayer
        local character = localPlayer.Character
        local isRespawning = false
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            if humanoid.Health > 0 then
                local currentTime = os.clock()
                if currentTime - lastRespawnTime >= 0.1 then
                    lastRespawnTime = currentTime
                    isRespawning = true
                end
            end
        end
        if isRespawning then
            UpdateQT()
            d()
            espRefresher()
            applyhb()
            aimbotfov()
            updateAimbotFOVRing()
            LowRender()
            
            local toRemove = {}
            for player, data in pairs(config.hitboxExpandedParts) do
                if not player or not getTargetCharacter(player) or not plralive(player) then
                    table.insert(toRemove, player)
                elseif not targethb(player) then
                    table.insert(toRemove, player)
                end
            end
            
            for _, player in ipairs(toRemove) do
                restoreTorso(player)
            end
            
            local lineToRemove = {}
            for player, _ in pairs(config.lineESPData) do
                local found = false
                for _, target in ipairs(getAllTargets()) do
                    if target == player then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(lineToRemove, player)
                end
            end
            
            for _, player in ipairs(lineToRemove) do
                removeLineESP(player)
            end
        end
        
        task.wait(config.varibz.patcherwait)
    end
end)
init()
Window:OnDestroy(function()
    cleanup()
    print("Gravel.cc closed :(")
end)
task.wait(2.5)
loadstring(game:HttpGet(urls.hbsshandlecorpses))()
FindTool = loadstring(game:HttpGet(urls.sa2findtool))()
return {
    config = config,
    lzl = lzl,
    toggles = toggles
}
end)

if not success then
    for _, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do
        v:Enable()
    end
    for _, v in pairs(getconnections(game:GetService("LogService").MessageOut)) do
        v:Enable()
    end
    getgenv().Graaaaaaaaaaaaaaaaaaaaaaavel = false
    warn("Gpssickle what kind of error is ts 🥀💔:" .. tostring(err))
    error(err)
end
-- fin
--[[
                     _.⁠·⁠´⁠¯⁠`⁠(⁠>⁠▂⁠<⁠)⁠´⁠¯⁠`⁠·⁠._
CAN YOU GUYS STAWP ASKINF ME "it doesn't work on [insert game name]"
DIS IS A UNIVERSAL SCRIPT VROROO
IT DONT WORK ON ALL GAMES IN DA UNIVERSE
]]
