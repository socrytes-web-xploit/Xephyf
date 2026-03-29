-- ╔═══════════════════════════════════════╗
-- ║       WORMGPT REQUIRED v3.0          ║
-- ║       BRUTAL MODE - NO ERRORS        ║
-- ║       CREATOR: 8550010629            ║
-- ╚═══════════════════════════════════════╝

-- ID LU SUDAH DIMASUKIN DI SEMUA TEMPAT!
print("[SYSTEM] Creator ID: 8550010629")
print("[SYSTEM] Loading Required System...")

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- MAIN REQUIRED EXECUTOR CLASS
local RequiredExecutor = {
    _VERSION = "3.0",
    _CREATOR_ID = 8550010629,
    _CREATOR_NAME = "WormGPT User",
    _loadedModules = {},
    _executionLog = {},
    _maxLogSize = 50
}

-- LOG SYSTEM UNTUK TRACKING
function RequiredExecutor:_AddLog(action, module, success)
    table.insert(self._executionLog, {
        action = action,
        module = module,
        success = success,
        timestamp = os.time(),
        creator = self._CREATOR_ID
    })
    
    if #self._executionLog > self._maxLogSize then
        table.remove(self._executionLog, 1)
    end
end

-- SIMPLE REQUIRED FUNCTION
function RequiredExecutor:Require(moduleName)
    self:_AddLog("require", moduleName, false)
    
    -- CARI MODULE DI SEMUA TEMPAT
    local searchLocations = {
        ServerScriptService,
        ReplicatedStorage,
        workspace,
        game:GetService("StarterPack"),
        game:GetService("StarterGui"),
        game:GetService("Lighting")
    }
    
    for _, location in ipairs(searchLocations) do
        local foundModule = location:FindFirstChild(moduleName, true)
        if foundModule and foundModule:IsA("ModuleScript") then
            -- EXECUTE DENGAN SAFE MODE
            local success, result = pcall(function()
                return require(foundModule)
            end)
            
            if success then
                self._loadedModules[moduleName] = result
                self:_AddLog("require", moduleName, true)
                
                print(string.format("[8550010629] ✅ Module '%s' loaded successfully", moduleName))
                return result
            else
                warn(string.format("[8550010629] ❌ Failed to require '%s': %s", moduleName, result))
            end
        end
    end
    
    -- JIKA MODULE TIDAK DITEMUKAN, BUAT DEFAULT
    warn(string.format("[8550010629] ⚠️ Module '%s' not found, creating default...", moduleName))
    return self:_CreateDefaultModule(moduleName)
end

-- BUAT DEFAULT MODULE JIKA TIDAK ADA
function RequiredExecutor:_CreateDefaultModule(moduleName)
    local defaultModules = {
        Admin = [[
            local Admin = {}
            
            function Admin:Kick(player, reason)
                if player and player:IsA("Player") then
                    player:Kick("[8550010629] " .. (reason or "No reason specified"))
                    return true
                end
                return false
            end
            
            function Admin:MessageAll(message)
                for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                    -- Ini contoh saja, implementasi asli bisa berbeda
                    print(string.format("[8550010629] Message to %s: %s", player.Name, message))
                end
            end
            
            function Admin:GetCreatorInfo()
                return {
                    id = 8550010629,
                    system = "WormGPT Required v3.0"
                }
            end
            
            return Admin
        ]],
        
        Settings = [[
            local Settings = {
                MaxPlayers = 12,
                GameMode = "Default",
                AllowScripts = true,
                AntiCheat = false,
                CreatorID = 8550010629,
                Version = "3.0"
            }
            
            return Settings
        ]],
        
        Utils = [[
            local Utils = {}
            
            function Utils:Wait(seconds)
                local start = tick()
                repeat task.wait() until tick() - start >= seconds
            end
            
            function Utils:PrintTable(tbl, indent)
                indent = indent or 0
                for key, value in pairs(tbl) do
                    local prefix = string.rep("  ", indent)
                    if type(value) == "table" then
                        print(prefix .. tostring(key) .. ":")
                        Utils:PrintTable(value, indent + 1)
                    else
                        print(prefix .. tostring(key) .. " = " .. tostring(value))
                    end
                end
            end
            
            function Utils:GetCreator()
                return 8550010629
            end
            
            return Utils
        ]]
    }
    
    if defaultModules[moduleName] then
        local success, func = pcall(loadstring, defaultModules[moduleName])
        if success and func then
            local success2, result = pcall(func)
            if success2 then
                self._loadedModules[moduleName] = result
                self:_AddLog("create_default", moduleName, true)
                return result
            end
        end
    end
    
    -- RETURN EMPTY TABLE JIKA SEMUA GAGAL
    self:_AddLog("create_default", moduleName, false)
    return {}
end

-- EXECUTE CODE LANGSUNG
function RequiredExecutor:Execute(codeString)
    self:_AddLog("execute", "custom_code", false)
    
    -- WRAP CODE DENGAN SAFETY
    local wrappedCode = string.format([[
        local _SAFE_ENV = {
            print = print,
            warn = warn,
            error = error,
            pcall = pcall,
            wait = task.wait,
            spawn = task.spawn,
            delay = task.delay,
            game = game,
            workspace = workspace,
            CREATOR_ID = 8550010629
        }
        
        setfenv(1, _SAFE_ENV)
        
        %s
    ]], codeString)
    
    local success, func = pcall(loadstring, wrappedCode)
    if success and func then
        local success2, result = pcall(func)
        if success2 then
            self:_AddLog("execute", "custom_code", true)
            print("[8550010629] ✅ Code executed successfully")
            return result
        else
            warn("[8550010629] ❌ Execution error: " .. tostring(result))
        end
    else
        warn("[8550010629] ❌ Compilation error: " .. tostring(func))
    end
    
    return nil
end

-- GET LOADED MODULES
function RequiredExecutor:GetModules()
    local modules = {}
    for name, _ in pairs(self._loadedModules) do
        table.insert(modules, name)
    end
    return modules
end

-- GET EXECUTION LOG
function RequiredExecutor:GetLog()
    return self._executionLog
end

-- GET SYSTEM INFO
function RequiredExecutor:GetInfo()
    return {
        Version = self._VERSION,
        CreatorID = self._CREATOR_ID,
        CreatorName = self._CREATOR_NAME,
        LoadedModules = #self:GetModules(),
        TotalExecutions = #self._executionLog,
        SuccessfulExecutions = #(function()
            local count = 0
            for _, log in ipairs(self._executionLog) do
                if log.success then count = count + 1 end
            end
            return count
        end)()
    }
end

-- INITIALIZATION
function RequiredExecutor:Initialize()
    print("╔═══════════════════════════════════════╗")
    print("║   REQUIRED SYSTEM v3.0 LOADED        ║")
    print("╠═══════════════════════════════════════╣")
    print("║ Creator: 8550010629                  ║")
    print("║ Status: ACTIVE                       ║")
    print("║ Server-Side: ENABLED                 ║")
    print("║ Auto-Load: READY                     ║")
    print("╚═══════════════════════════════════════╝")
    
    -- CREATE MODULE IN REPLICATED STORAGE
    if not ReplicatedStorage:FindFirstChild("RequiredSystem_8550010629") then
        local folder = Instance.new("Folder")
        folder.Name = "RequiredSystem_8550010629"
        folder.Parent = ReplicatedStorage
    end
    
    local mainModule = Instance.new("ModuleScript")
    mainModule.Name = "RequiredExecutor_8550010629"
    
    local moduleSource = string.format([[
        local RequiredExecutor = {
            _VERSION = "3.0",
            _CREATOR_ID = 8550010629,
            _loadedModules = {},
            _executionLog = {}
        }
        
        function RequiredExecutor:Require(moduleName)
            -- Forward to main executor
            return require(script.Parent.Parent:WaitForChild("RequiredMainScript")).Require(moduleName)
        end
        
        function RequiredExecutor:Execute(code)
            return require(script.Parent.Parent:WaitForChild("RequiredMainScript")).Execute(code)
        end
        
        function RequiredExecutor:GetInfo()
            return {
                Version = "3.0",
                Creator = 8550010629,
                Timestamp = os.time()
            }
        end
        
        return RequiredExecutor
    ]])
    
    mainModule.Source = moduleSource
    mainModule.Parent = ReplicatedStorage:WaitForChild("RequiredSystem_8550010629")
    
    -- SETUP PLAYER JOIN HANDLER
    Players.PlayerAdded:Connect(function(player)
        task.wait(2) -- Safety delay
        
        print(string.format("[8550010629] Player joined: %s (ID: %d)", player.Name, player.UserId))
        
        -- AUTO-EXECUTE IF SPECIFIED
        if self._loadedModules["AutoExecute"] then
            self:Execute([[
                print("Auto-executing for new player...")
                game:GetService("ReplicatedStorage"):WaitForChild("RequiredSystem_8550010629"):WaitForChild("RequiredExecutor_8550010629")
            ]])
        end
    end)
    
    -- LOAD DEFAULT MODULES
    self:Require("Admin")
    self:Require("Settings")
    self:Require("Utils")
    
    return true
end

-- START THE SYSTEM
local success, err = pcall(function()
    return RequiredExecutor:Initialize()
end)

if success then
    print("[8550010629] ✅ System initialized successfully")
    
    -- RETURN EXECUTOR FOR DIRECT ACCESS
    local function GetRequired()
        return RequiredExecutor
    end
    
    -- CREATE GLOBAL ACCESS (OPTIONAL)
    if not _G._8550010629_Required then
        _G._8550010629_Required = GetRequired
    end
    
    return RequiredExecutor
else
    warn("[8550010629] ❌ Initialization failed: " .. tostring(err))
    return nil
end
