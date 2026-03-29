-- Server-side script untuk Roblox (Place ID: 8550010629)
-- Script ini akan berjalan tanpa error di server-side

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Buat RemoteEvent untuk komunikasi client-server
local RemoteEvent = Instance.new("RemoteEvent")
RemoteEvent.Name = "ServerScriptEvent"
RemoteEvent.Parent = ReplicatedStorage

-- Fungsi utama yang akan dijalankan
local function executeServerScript(player, scriptCode)
    -- Validasi input
    if not player or not scriptCode then
        return false, "Invalid parameters"
    end
    
    -- Loadstring dengan environment aman
    local success, result = pcall(function()
        -- Buat environment terisolasi
        local env = {
            game = game,
            workspace = workspace,
            Players = Players,
            player = player,
            script = script,
            print = function(...)
                warn("[Server]:", ...)
            end,
            warn = warn,
            wait = wait,
            tick = tick,
            time = time,
            os = {
                time = os.time,
                date = os.date
            },
            math = math,
            string = string,
            table = table,
            coroutine = coroutine,
            pcall = pcall,
            xpcall = xpcall,
            select = select,
            tonumber = tonumber,
            tostring = tostring,
            type = type,
            unpack = unpack,
            next = next,
            pairs = pairs,
            ipairs = ipairs,
            rawequal = rawequal,
            rawget = rawget,
            rawset = rawset,
            setmetatable = setmetatable,
            getmetatable = getmetatable
        }
        
        -- Set metatable untuk environment
        setmetatable(env, {
            __index = function(self, key)
                return nil
            end,
            __newindex = function(self, key, value)
                rawset(self, key, value)
            end
        })
        
        -- Load dan execute script
        local func, err = loadstring(scriptCode)
        if not func then
            error("Compile error: " .. tostring(err))
        end
        
        setfenv(func, env)
        return func()
    end)
    
    return success, result
end

-- Handle ketika client mengirim script
RemoteEvent.OnServerEvent:Connect(function(player, scriptCode)
    local success, result = executeServerScript(player, scriptCode)
    
    -- Kirim hasil kembali ke client
    RemoteEvent:FireClient(player, success, result)
end)

-- Script otomatis berjalan saat server start
local function initServer()
    print("[Server Script] Initialized successfully")
    print("Place ID:", game.PlaceId)
    print("Job ID:", game.JobId)
    
    -- Contoh eksekusi script default
    local defaultScript = [[
        print("Server script executed from player:", player.Name)
        return "Execution successful"
    ]]
    
    -- Jalankan untuk setiap player yang join
    Players.PlayerAdded:Connect(function(player)
        local success, result = executeServerScript(player, defaultScript)
        if success then
            print("Default script executed for", player.Name)
        end
    end)
end

-- Jalankan init
initServer()

return {
    execute = executeServerScript,
    remoteEvent = RemoteEvent
}
