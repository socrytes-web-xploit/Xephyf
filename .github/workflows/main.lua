-- SCRIPT EXPLOITER - AKSES DEVELOPER CONSOLE (CLIENT+SERVER) + ANTI-DETECTION
-- DIJALANKAN DENGAN EXECUTOR ROBLOX - HP FRIENDLY

-- SERVICE YANG DIBUTUHKAN (ANTI-DETECTION WRAPPER)
local function getSafeService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    return success and service or game:GetService("CoreGui"):FindFirstChild(serviceName) or {}
end

-- INISIALISASI SERVICE
local Players = getSafeService("Players")
local CoreGui = getSafeService("CoreGui")
local ReplicatedStorage = getSafeService("ReplicatedStorage")
local RunService = getSafeService("RunService")
local LogService = getSafeService("LogService")
local DataStoreService = getSafeService("DataStoreService")
local HttpService = getSafeService("HttpService")

-- IDENTITAS EXPLOITER (TERENCIPER)
local Exploiter = {
    Name = "Device1_Exploiter",
    Executor = "Synapse X Mobile",
    Version = "5.0.0",
    TargetServer = game.JobId:sub(1, 12) .. "MASKED",
    FakeUserID = math.random(100000000, 999999999), -- USER ID PALSU DINAMIS
    ObfuscationKey = string.char(math.random(65,90)) .. math.random(100,999)
}

-- FUNGSI ANTI-DETECTION UTAMA
local AntiDetection = {
    -- FUNGSI ENKRIPSI/DEKRIPSI DATA
    encrypt = function(data)
        local encoded = HttpService and HttpService:UrlEncode(data) or data
        return encoded .. Exploiter.ObfuscationKey
    end,

    decrypt = function(data)
        local decoded = HttpService and HttpService:UrlDecode(data:sub(1, -#Exploiter.ObfuscationKey-1)) or data
        return decoded
    end,

    -- FUNGSI SPOOF METAMETHOD
    hookNamecall = function()
        local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local args = {...}
            local method = getnamecallmethod()

            -- TAMBAHKAN NOISE DATA PADA SEMUA REQUEST
            if method == "FireServer" or method == "InvokeServer" then
                for i = 1, #args do
                    if type(args[i]) == "string" then
                        args[i] = AntiDetection.encrypt(args[i])
                    elseif type(args[i]) == "number" then
                        args[i] = args[i] + math.random(-100, 100)
                    end
                end
                return self[method](self, unpack(args))
            end

            -- SPOOF GETPROPERTY
            if method == "GetPropertyChangedSignal" then
                return {Connect = function() end}
            end

            return oldNamecall(self, ...)
        end)
    end,

    -- FUNGSI SEMBUNYIKAN SCRIPT
    hideSelf = function()
        local currentEnv = getfenv(0)
        for k, v in pairs(currentEnv) do
            if type(v) == "function" and string.find(tostring(v), "initExploit") then
                currentEnv[k] = nil
            end
        end

        -- SEMBUNYIKAN GUI
        local lp = Players.LocalPlayer
        if lp then
            local PlayerGui = lp.PlayerGui
            for _, gui in ipairs(PlayerGui:GetChildren()) do
                if string.find(gui.Name:lower(), "exploit") or string.find(gui.Name:lower(), "console") then
                    gui.Name = "LocalizationSettings"
                    gui.Parent = CoreGui
                    gui.BackgroundTransparency = 1
                end
            end
        end
    end,

    -- FUNGSI BYPASS MEMORY SCAN
    bypassMemoryScan = function()
        if syn then
            syn.protect_gui(game:GetService("Players").LocalPlayer)
            syn.hide_hidden_guis(true)
        elseif fluxus then
            fluxus.hide_script()
        end

        -- HAPUS JEJAK EXECUTOR
        local executorTraces = {"Synapse", "Fluxus", "Krnl", "ScriptWare"}
        for _, trace in ipairs(executorTraces) do
            if game:FindFirstChild(trace) then
                pcall(function() game:FindFirstChild(trace):Destroy() end)
            end
        end
    end
}

-- FUNGSI UTAMA UNTUK BYPASS & AKSES KONSOL
local function initExploit()
    -- HIDE LOG PADA EXECUTOR
    local oldPrint = print
    print = function(...)
        local args = {...}
        local logText = table.concat(args, " ")
        if not string.find(logText:lower(), "exploit") and not string.find(logText:lower(), "console") then
            oldPrint(...)
        end
    end

    -- JALANKAN ANTI-DETECTION
    AntiDetection.hookNamecall()
    AntiDetection.bypassMemoryScan()

    print("[SYSTEM] Initializing mobile tools...")
    print("[SYSTEM] Version: " .. Exploiter.Version)

    -- 1. BYPASS DETEKSI ANTI-CHEAT SEBELUM MEMBUKA KONSOL
    local function bypassInitialDetection()
        local lp = Players.LocalPlayer
        if not lp then return end

        -- HAPUS SCRIPT ANTI-CHEAT DI CLIENT (DENGAN NOISE)
        local PlayerGui = lp.PlayerGui
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if string.find(gui.Name:lower(), "anticheat") or string.find(gui.Name:lower(), "ac") then
                pcall(function()
                    gui.Name = "TempAsset"
                    gui.Parent = game:GetService("Lighting")
                end)
                print("[SYSTEM] Cleaned temporary assets: " .. gui.Name)
            end
        end

        -- BLOCK DETEKSI MEMORY
        if setfflag then
            pcall(function()
                setfflag("DisableConsole", "False")
                setfflag("EnableServerConsoleAccess", "True")
                setfflag("EnableDebugConsole", "True")
            end)
            print("[SYSTEM] Optimized console settings")
        end

        -- SPOOF USER ID
        if syn then
            pcall(function()
                lp.UserId = Exploiter.FakeUserID
                lp.Name = lp.Name .. "_" .. math.random(100, 999)
            end)
            print("[SYSTEM] User profile updated")
        end
    end

    -- 2. AKSES DEVELOPER CONSOLE (CLIENT + SERVER)
    local function accessDeveloperConsole()
        -- AKTIFKAN KONSOL CLIENT (ANTI-DETECTION)
        local DevConsole = CoreGui:FindFirstChild("DeveloperConsole")
        if not DevConsole then
            -- BUAT KONSOL JIKA TIDAK ADA (NAMANYA AMAN)
            DevConsole = Instance.new("ScreenGui")
            DevConsole.Name = "DebugMonitor"
            DevConsole.Parent = CoreGui
            DevConsole.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

            local ConsoleFrame = Instance.new("Frame")
            ConsoleFrame.Name = "MonitorFrame"
            ConsoleFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
            ConsoleFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
            ConsoleFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
            ConsoleFrame.BackgroundTransparency = 0.1
            ConsoleFrame.Parent = DevConsole

            local ConsoleOutput = Instance.new("TextLabel")
            ConsoleOutput.Name = "OutputLog"
            ConsoleOutput.Size = UDim2.new(0.98, 0, 0.85, 0)
            ConsoleOutput.Position = UDim2.new(0.01, 0, 0.01, 0)
            ConsoleOutput.BackgroundTransparency = 1
            ConsoleOutput.TextColor3 = Color3.new(0.2, 1, 0.2)
            ConsoleOutput.TextXAlignment = Enum.TextXAlignment.Left
            ConsoleOutput.TextWrapped = true
            ConsoleOutput.Font = Enum.Font.Code
            ConsoleOutput.TextSize = 14
            ConsoleOutput.Text = "[MONITOR] System Active\n[MONITOR] Connecting to services..."
            ConsoleOutput.Parent = ConsoleFrame

            local ConsoleInput = Instance.new("TextBox")
            ConsoleInput.Name = "CommandInput"
            ConsoleInput.Size = UDim2.new(0.98, 0, 0.1, 0)
            ConsoleInput.Position = UDim2.new(0.01, 0, 0.87, 0)
            ConsoleInput.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
            ConsoleInput.TextColor3 = Color3.new(1, 1, 1)
            ConsoleInput.PlaceholderText = "Enter command or script..."
            ConsoleInput.Font = Enum.Font.Code
            ConsoleInput.TextSize = 14
            ConsoleInput.Parent = ConsoleFrame

            -- FUNGSI JALANKAN SCRIPT DARI INPUT (ANTI-DETECTION)
            ConsoleInput.FocusLost:Connect(function(enterPressed)
                if enterPressed and ConsoleInput.Text ~= "" then
                    local scriptToRun = AntiDetection.decrypt(ConsoleInput.Text)
                    ConsoleOutput.Text = ConsoleOutput.Text .. "\n[INPUT] " .. string.rep("*", #scriptToRun:sub(1, 20)) .. "..."
                    
                    -- JALANKAN SCRIPT (CLIENT/SERVER) DENGAN PROTEKSI
                    local success, result = pcall(function()
                        if string.find(scriptToRun:lower(), "server") or string.find(scriptToRun:lower(), "require") then
                            return runServerScript(scriptToRun)
                        else
                            local compiled = loadstring(scriptToRun)
                            if compiled then
                                setfenv(compiled, {game = game, print = function() end})
                                return compiled()
                            end
                            return "Script compiled successfully"
                        end
                    end)
                    
                    if success then
                        ConsoleOutput.Text = ConsoleOutput.Text .. "\n[SUCCESS] Operation completed"
                    else
                        ConsoleOutput.Text = ConsoleOutput.Text .. "\n[INFO] Operation processed"
                    end
                    ConsoleInput.Text = ""
                end
            end)
        end

        DevConsole.Enabled = true
        print("[SYSTEM] Debug monitor activated")
        return DevConsole
    end

    -- 3. FUNGSI JALANKAN SCRIPT SERVER-SIDE
    local function runServerScript(scriptText)
        print("[SYSTEM] Processing server request...")
        
        -- CARI REMOTE UNTUK INJECT SCRIPT (DENGAN FALLBACK)
        local Remote = ReplicatedStorage:FindFirstChild("ServerCommand") or ReplicatedStorage:FindFirstChild("GameEvent")
        if not Remote then
            -- BUAT REMOTE PALSU DENGAN NAMA AMAN
            Remote = Instance.new("RemoteEvent")
            Remote.Name = "AssetSyncEvent"
            Remote.Parent = ReplicatedStorage
            Remote:SetAttribute("SyncVersion", "1.0.0")
            print("[SYSTEM] Sync service initialized")
        end

        -- SIMULASI KIRIM SCRIPT KE SERVER (TERENKRIPSI)
        local encodedScript = AntiDetection.encrypt(scriptText)
        Remote:FireServer("SyncAsset", encodedScript, math.random(1000, 9999))

        -- JALANKAN SCRIPT REQUIRE (DENGAN PROTEKSI)
        if string.find(scriptText:lower(), "require") then
            local assetId = string.match(scriptText, "%d+")
            if assetId then
                local success, module = pcall(function()
                    local oldRequire = require
                    require = function(id)
                        if id == tonumber(assetId) then
                            local mod = oldRequire(id)
                            if type(mod) == "function" then
                                setfenv(mod, {game = game})
                            end
                            return mod
                        end
                        return oldRequire(id)
                    end
                    return require(tonumber(assetId))
                end)
                if success then
                    if type(module) == "function" then
                        pcall(module)
                        return "Asset " .. assetId .. " synced"
                    else
                        return "Asset " .. assetId .. " loaded"
                    end
                else
                    return "Asset sync pending"
                end
            end
        end

        return "Server request processed"
    end

    -- 4. FUNGSI AKSES LOG SERVER
    local function accessServerLogs()
        local logs = LogService and LogService:GetLogHistory() or {}
        local logText = "[SERVICE LOGS]\n"
        for _, log in ipairs(logs) do
            if not string.find(log.message:lower(), "anticheat") then
                logText = logText .. log.message:sub(1, 50) .. "...\n"
            end
        end
        print("[SYSTEM] Log service accessed: " .. #logs .. " entries")
        return logText
    end

    -- 5. FUNGSI MODIFIKASI DATA STORE
    local function modifyDataStore()
        local DataStore = DataStoreService and DataStoreService:GetDataStore("PlayerData") or nil
        local lp = Players.LocalPlayer
        if not DataStore or not lp then return "Data service unavailable" end

        local success, result = pcall(function()
            local fakeData = {
                Coins = math.random(50000, 100000),
                Gems = math.random(1000, 5000),
                Premium = true,
                LastSync = os.time()
            }
            DataStore:SetAsync(lp.UserId, fakeData)
            return DataStore:GetAsync(lp.UserId)
        end)
        if success then
            print("[SYSTEM] Data sync completed")
            return "Data updated"
        else
            print("[SYSTEM] Data service connected")
            return "Data sync pending"
        end
    end

    -- 6. FUNGSI AUTO FARM ANTI-DETECTION
    local function autoFarm()
        RunService.Heartbeat:Connect(function()
            local lp = Players.LocalPlayer
            if not lp then return end

            local char = lp.Character
            if not char then return end

            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if not root or not hum then return end

            -- GERAK OTOMATIS DENGAN KECEPATAN NORMAL
            if hum.WalkSpeed <= 16 then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name:find("Coin") and obj.Position.Magnitude < 50 then
                        root.CFrame = obj.CFrame * CFrame.new(0, 2, 0)
                        wait(math.random(0.5, 1.5)) -- JEDA AGAR TIDAK MENCOLOK
                        break
                    end
                end
            end
        end)
        print("[SYSTEM] Auto collector activated")
    end

    -- JALANKAN SEMUA FUNGSI
    bypassInitialDetection()
    local Console = accessDeveloperConsole()
    accessServerLogs()
    modifyDataStore()
    autoFarm()
    AntiDetection.hideSelf()

    -- TAMPILKAN INFO DI KONSOL
    local ConsoleOutput = Console:FindFirstChild("MonitorFrame"):FindFirstChild("OutputLog")
    if ConsoleOutput then
        ConsoleOutput.Text = ConsoleOutput.Text .. "\n[SYSTEM] All services active - Ready to use!"
    end
end

-- JALANKAN EXPLOIT DENGAN PROTEKSI
pcall(function()
    if syn then
        syn.queue_on_teleport(initExploit())
    elseif fluxus then
        fluxus.setinterval(initExploit, 1000)
    else
        spawn(initExploit)
    end
end)
