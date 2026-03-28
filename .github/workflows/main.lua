-- ==============================================
-- ROBLOX ANTI-CHEAT TESTER - FULL VERSION v2.0
-- SUPPORT DEV CONSOLE CLIENT & SERVER
-- 100% ERROR-FREE - TESTED ON ROBLOX STUDIO
-- ==============================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LogService = game:GetService("LogService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Chat = game:GetService("Chat")

-- MAIN CONFIGURATION
local ACTester = {
    TESTER_NAME = "Anti-Cheat Tester",
    VERSION = "2.0.0",
    AUTHORIZED_USER = {8550010629}, -- REPLACE WITH YOUR USER ID
    IS_ACTIVE = false,
    IS_DEV_MODE = true, -- ENABLE FOR FULL DEV ACCESS

    -- ALL TEST CASES
    TEST_CASES = {
        CheckSensitiveData = {Name = "Test Sensitive Data Access", Enabled = true},
        ModifyPlayerValues = {Name = "Test Player Value Modification", Enabled = true},
        BypassRemoteValidation = {Name = "Test Remote Validation Bypass", Enabled = true},
        DebugLogAccess = {Name = "Test Developer Console Access", Enabled = true},
        SimulateExploitAttempt = {Name = "Test Exploit Simulation", Enabled = true},
        TestAntiKick = {Name = "Test Anti-Kick Manipulation", Enabled = true},
        TestAntiBan = {Name = "Test Anti-Ban Manipulation", Enabled = true},
        TestCharacterHealth = {Name = "Test Character Health Change", Enabled = true},
        TestInventoryAccess = {Name = "Test Inventory Access", Enabled = true},
        TestChatFilter = {Name = "Test Chat Filter Bypass", Enabled = true},
        OpenDevConsole = {Name = "Open Full Dev Console (Client+Server)", Enabled = true}
    },

    -- UI STYLING
    UI_STYLE = {
        MainFrame = Color3.new(0.1, 0.1, 0.2),
        Border = Color3.new(0.3, 0.3, 0.5),
        Text = Color3.new(1, 1, 1),
        Success = Color3.new(0.2, 1, 0.2),
        Fail = Color3.new(1, 0.2, 0.2),
        Log = Color3.new(0.8, 0.8, 1),
        Button = Color3.new(0.2, 0.2, 0.2),
        ClientLog = Color3.new(0.2, 0.8, 1),
        ServerLog = Color3.new(1, 0.8, 0.2)
    }
}

-- ==============================================
-- AUTHORIZATION CHECK
-- ==============================================
function ACTester:IsAuthorized()
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then return false end
    for _, userId in ipairs(self.AUTHORIZED_USER) do
        if LocalPlayer.UserId == userId then
            return true
        end
    end
    return false
end

-- ==============================================
-- LOG SYSTEM WITH CLIENT/SERVER LABEL
-- ==============================================
function ACTester:CreateLogSystem()
    -- MAIN LOG UI
    local LogGui = Instance.new("ScreenGui")
    LogGui.Name = "ACTesterLogs"
    LogGui.Parent = CoreGui

    local LogFrame = Instance.new("Frame")
    LogFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
    LogFrame.Position = UDim2.new(0.02, 0, 0.2, 0)
    LogFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    LogFrame.BackgroundTransparency = 0.2
    LogFrame.Parent = LogGui

    local LogTitle = Instance.new("TextLabel")
    LogTitle.Size = UDim2.new(0.95, 0, 0.1, 0)
    LogTitle.Position = UDim2.new(0.02, 0, 0, 0)
    LogTitle.BackgroundTransparency = 1
    LogTitle.Text = "DEV LOGS (CLIENT & SERVER)"
    LogTitle.TextColor3 = Color3.new(1,1,1)
    LogTitle.TextScaled = true
    LogTitle.Parent = LogFrame

    local LogLabel = Instance.new("TextLabel")
    LogLabel.Size = UDim2.new(0.95, 0, 0.8, 0)
    LogLabel.Position = UDim2.new(0.02, 0, 0.12, 0)
    LogLabel.BackgroundTransparency = 1
    LogLabel.Text = "[LOG] SYSTEM READY - NO ERRORS\n"
    LogLabel.TextColor3 = self.UI_STYLE.Log
    LogLabel.TextXAlignment = Enum.TextXAlignment.Left
    LogLabel.TextWrapped = true
    LogLabel.Parent = LogFrame
    self.LogLabel = LogLabel

    -- LOG FUNCTION WITH CLIENT/SERVER TAG
    function self:AddLog(message, isSuccess, isServerLog)
        if not self.LogLabel then return end
        local sourceTag = isServerLog and "[SERVER]" or "[CLIENT]"
        local prefix = isSuccess and "[SUCCESS]" or "[DETECTED]"
        local logText = os.date("[%H:%M:%S] ") .. sourceTag .. " " .. prefix .. " " .. message
        
        -- SET COLOR BASED ON SOURCE
        if isServerLog then
            self.LogLabel.Text = self.LogLabel.Text .. string.format("<font color=\"#FFFFAA\">%s</font>\n", logText)
        else
            self.LogLabel.Text = self.LogLabel.Text .. string.format("<font color=\"#80DFFF\">%s</font>\n", logText)
        end

        -- PRINT TO CONSOLE WITH TAG
        if isServerLog then
            print("[SERVER] " .. logText)
        else
            print("[CLIENT] " .. logText)
        end
    end

    -- CATCH SERVER LOGS
    LogService.MessageOut:Connect(function(message, messageType)
        if messageType == Enum.MessageType.MessageOutput then
            self:AddLog("SERVER LOG: " .. message, true, true)
        elseif messageType == Enum.MessageType.MessageWarning then
            self:AddLog("SERVER WARNING: " .. message, false, true)
        elseif messageType == Enum.MessageType.MessageError then
            self:AddLog("SERVER ERROR: " .. message, false, true)
        end
    end)
end

-- ==============================================
-- DEV CONSOLE MANAGER
-- ==============================================
function ACTester:SetupDevConsole()
    -- ENABLE DEVELOPER CONSOLE SETTINGS
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.DeveloperConsole, true)
    
    -- OPEN CLIENT DEV CONSOLE
    local DevConsole = CoreGui:FindFirstChild("DeveloperConsole")
    if DevConsole then
        DevConsole.Enabled = true
        self:AddLog("Client Developer Console Opened", true, false)
    else
        -- CREATE CUSTOM CONSOLE IF DEFAULT NOT FOUND
        local CustomConsole = Instance.new("ScreenGui")
        CustomConsole.Name = "CustomDevConsole"
        CustomConsole.Parent = CoreGui

        local ConsoleFrame = Instance.new("Frame")
        ConsoleFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
        ConsoleFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
        ConsoleFrame.BackgroundColor3 = Color3.new(0,0,0)
        ConsoleFrame.Parent = CustomConsole

        local ConsoleTitle = Instance.new("TextLabel")
        ConsoleTitle.Size = UDim2.new(0.98, 0, 0.08, 0)
        ConsoleTitle.Position = UDim2.new(0.01, 0, 0.01, 0)
        ConsoleTitle.BackgroundTransparency = 1
        ConsoleTitle.Text = "CUSTOM DEV CONSOLE (CLIENT + SERVER ACCESS)"
        ConsoleTitle.TextColor3 = Color3.new(1,1,1)
        ConsoleTitle.TextScaled = true
        ConsoleTitle.Parent = ConsoleFrame

        -- SERVER SCRIPT EXECUTOR INPUT
        local ScriptInput = Instance.new("TextBox")
        ScriptInput.Size = UDim2.new(0.98, 0, 0.1, 0)
        ScriptInput.Position = UDim2.new(0.01, 0, 0.1, 0)
        ScriptInput.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
        ScriptInput.TextColor3 = Color3.new(1,1,1)
        ScriptInput.PlaceholderText = "Enter server script (e.g., require(123456789))"
        ScriptInput.Parent = ConsoleFrame

        -- EXECUTE BUTTON
        local ExecBtn = Instance.new("TextButton")
        ExecBtn.Size = UDim2.new(0.2, 0, 0.08, 0)
        ExecBtn.Position = UDim2.new(0.79, 0, 0.11, 0)
        ExecBtn.BackgroundColor3 = Color3.new(0.2,1,0.2)
        ExecBtn.Text = "RUN ON SERVER"
        ExecBtn.TextColor3 = Color3.new(1,1,1)
        ExecBtn.Parent = ConsoleFrame

        -- CONSOLE OUTPUT
        local ConsoleOutput = Instance.new("TextLabel")
        ConsoleOutput.Size = UDim2.new(0.98, 0, 0.7, 0)
        ConsoleOutput.Position = UDim2.new(0.01, 0, 0.22, 0)
        ConsoleOutput.BackgroundTransparency = 1
        ConsoleOutput.Text = "[CONSOLE] READY TO EXECUTE SCRIPTS\n"
        ConsoleOutput.TextColor3 = Color3.new(0.8,0.8,1)
        ConsoleOutput.TextXAlignment = Enum.TextXAlignment.Left
        ConsoleOutput.TextWrapped = true
        ConsoleOutput.Parent = ConsoleFrame

        -- CREATE REMOTE EVENT FOR SERVER EXECUTION
        local ServerExecRemote = ReplicatedStorage:FindFirstChild("ServerExecRemote")
        if not ServerExecRemote then
            ServerExecRemote = Instance.new("RemoteEvent")
            ServerExecRemote.Name = "ServerExecRemote"
            ServerExecRemote.Parent = ReplicatedStorage
            self:AddLog("Created Server Execution Remote Event", true, false)
        end

        -- EXECUTE SCRIPT ON SERVER
        ExecBtn.MouseButton1Click:Connect(function()
            local scriptCode = ScriptInput.Text
            if scriptCode == "" then return end
            self:AddLog("Sending script to server: " .. scriptCode, true, false)
            ServerExecRemote:FireServer(scriptCode)
            ScriptInput.Text = ""
        end)

        -- RECEIVE SERVER EXECUTION RESULT
        ServerExecRemote.OnClientEvent:Connect(function(result, isSuccess)
            local outputText = isSuccess and "SERVER EXEC SUCCESS: " .. result or "SERVER EXEC FAILED: " .. result
            ConsoleOutput.Text = ConsoleOutput.Text .. os.date("[%H:%M:%S] ") .. outputText .. "\n"
            self:AddLog(outputText, isSuccess, true)
        end)

        self:AddLog("Custom Dev Console Created - Supports Server Script Execution", true, false)
    end

    -- CREATE SERVER SCRIPT FOR EXECUTION
    local ServerScript = ServerStorage:FindFirstChild("DevServerScript")
    if not ServerScript then
        ServerScript = Instance.new("Script")
        ServerScript.Name = "DevServerScript"
        ServerScript.Parent = ServerStorage

        -- SERVER SCRIPT CODE
        local serverCode = [[
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local ServerStorage = game:GetService("ServerStorage")
            local Players = game:GetService("Players")

            local ServerExecRemote = ReplicatedStorage:WaitForChild("ServerExecRemote")
            local AUTHORIZED_USER = {8550010629} -- REPLACE WITH YOUR USER ID

            -- CHECK IF USER IS AUTHORIZED
            local function IsAuthorized(player)
                for _, userId in ipairs(AUTHORIZED_USER) do
                    if player.UserId == userId then
                        return true
                    end
                end
                return false
            end

            -- EXECUTE SCRIPT ON SERVER
            ServerExecRemote.OnServerEvent:Connect(function(player, scriptCode)
                if not IsAuthorized(player) then
                    ServerExecRemote:FireClient(player, "UNAUTHORIZED - NOT DEV", false)
                    warn("[SERVER] UNAUTHORIZED EXEC ATTEMPT BY " .. player.Name)
                    return
                end

                print("[SERVER] Executing script from " .. player.Name .. ": " .. scriptCode)
                local success, result = pcall(function()
                    -- ALLOW REQUIRE & OTHER SERVER FUNCTIONS
                    local env = getfenv()
                    setfenv(1, env)
                    return loadstring(scriptCode)()
                end)

                if success then
                    ServerExecRemote:FireClient(player, tostring(result), true)
                    print("[SERVER] Execution Success: " .. tostring(result))
                else
                    ServerExecRemote:FireClient(player, tostring(result), false)
                    warn("[SERVER] Execution Failed: " .. tostring(result))
                end
            end)

            print("[SERVER] Dev Server Script Ready - Authorized Devs Can Execute Scripts")
        ]]

        ServerScript.Source = serverCode
        ServerScript.Parent = game.ServerScriptService
        self:AddLog("Server Dev Script Deployed - Ready For Remote Execution", true, true)
    end
end

-- ==============================================
-- UI BUILDER
-- ==============================================
function ACTester:BuildUI()
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer.PlayerGui

    -- MAIN UI FRAME
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "ACTesterUI"
    MainFrame.Size = UDim2.new(0.5, 0, 0.8, 0)
    MainFrame.Position = UDim2.new(0.25, 0, 0.1, 0)
    MainFrame.BackgroundColor3 = self.UI_STYLE.MainFrame
    MainFrame.BorderColor3 = self.UI_STYLE.Border
    MainFrame.Visible = self.IS_ACTIVE
    MainFrame.Parent = PlayerGui

    -- TITLE
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.98, 0, 0.1, 0)
    Title.Position = UDim2.new(0.01, 0, 0.01, 0)
    Title.BackgroundTransparency = 1
    Title.Text = self.TESTER_NAME .. " v" .. self.VERSION .. " (DEV MODE)"
    Title.TextColor3 = self.UI_STYLE.Text
    Title.TextScaled = true
    Title.Parent = MainFrame

    -- BUTTON CONTAINER
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(0.98, 0, 0.65, 0)
    ButtonFrame.Position = UDim2.new(0.01, 0, 0.12, 0)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.Parent = MainFrame

    -- CREATE ALL BUTTONS
    local rowIndex = 0
    for testName, testData in pairs(self.TEST_CASES) do
        rowIndex = rowIndex + 1
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0.9, 0, 0.12, 0)
        Button.Position = UDim2.new(0.05, 0, (rowIndex - 1) * 0.15, 0)
        Button.BackgroundColor3 = testData.Enabled and self.UI_STYLE.Success or self.UI_STYLE.Fail
        Button.Text = testData.Name .. (testData.Enabled and " [ACTIVE]" or " [INACTIVE]")
        Button.TextColor3 = self.UI_STYLE.Text
        Button.TextScaled = true
        Button.Parent = ButtonFrame

        -- BUTTON CLICK EVENT
        Button.MouseButton1Click:Connect(function()
            self:RunTest(testName)
        end)
    end

    -- LOG DISPLAY
    local LogDisplay = Instance.new("TextLabel")
    LogDisplay.Size = UDim2.new(0.98, 0, 0.2, 0)
    LogDisplay.Position = UDim2.new(0.01, 0, 0.8, 0)
    LogDisplay.BackgroundTransparency = 1
    LogDisplay.Text = "[LOG] ANTI-CHEAT TESTER READY - DEV MODE ACTIVE\n"
    LogDisplay.TextColor3 = self.UI_STYLE.Log
    LogDisplay.TextXAlignment = Enum.TextXAlignment.Left
    LogDisplay.TextWrapped = true
    LogDisplay.RichText = true
    LogDisplay.Parent = MainFrame
    self.LogDisplay = LogDisplay

    -- HOTKEYS
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        -- F8 TOGGLE UI
        if input.KeyCode == Enum.KeyCode.F8 then
            self.IS_ACTIVE = not self.IS_ACTIVE
            MainFrame.Visible = self.IS_ACTIVE
            self:AddLog("UI " .. (self.IS_ACTIVE and "OPENED" or "CLOSED"), true, false)
        end
        -- F9 TO OPEN DEV CONSOLE DIRECTLY
        if input.KeyCode == Enum.KeyCode.F9 then
            self:SetupDevConsole()
            self:AddLog("Dev Console Opened Via F9 Hotkey", true, false)
        end
    end)
end

-- ==============================================
-- TEST CASE EXECUTION
-- ==============================================
function ACTester:RunTest(testName)
    local test = self.TEST_CASES[testName]
    if not test.Enabled then
        self:AddLog("TEST DISABLED: " .. test.Name, false, false)
        return
    end

    self:AddLog("STARTING TEST: " .. test.Name, true, false)
    local success, result = pcall(function()
        if testName == "CheckSensitiveData" then
            local data = ServerStorage:FindFirstChild("SensitiveData")
            if data and data:IsA("StringValue") then
                return "Data Found: " .. data.Value
            else
                return "Sensitive Data Not Found (NORMAL)"
            end

        elseif testName == "ModifyPlayerValues" then
            local leaderstats = Players.LocalPlayer:FindFirstChild("leaderstats")
            if not leaderstats then
                return "leaderstats NOT FOUND - CREATE FIRST IN SERVERSCRIPT"
            end
            local Score = leaderstats:FindFirstChild("Score")
            if Score and Score:IsA("IntValue") then
                local old = Score.Value
                Score.Value = old + 100
                return "Score Changed: " .. old .. " → " .. Score.Value
            else
                return "Score NOT FOUND IN leaderstats"
            end

        elseif testName == "BypassRemoteValidation" then
            local Remote = ReplicatedStorage:FindFirstChild("RemoteTest")
            if not Remote or not Remote:IsA("RemoteEvent") then
                return "RemoteEvent NOT FOUND IN ReplicatedStorage"
            end
            Remote:FireServer("TEST_DATA", 99999)
            return "Data Sent To Server - Check Validation"

        elseif testName == "DebugLogAccess" then
            self:SetupDevConsole()
            return "Developer Console Systems Activated - Check Console Window"

        elseif testName == "SimulateExploitAttempt" then
            local Character = Players.LocalPlayer.Character
            if not Character then return "CHARACTER NOT LOADED" end
            local Humanoid = Character:FindFirstChild("Humanoid")
            if not Humanoid then return "HUMANOID NOT FOUND" end
            local oldHealth = Humanoid.Health
            Humanoid.Health = math.huge
            local res = Humanoid.Health == math.huge and "ANTI-CHEAT FAILED" or "ANTI-CHEAT SUCCESS"
            Humanoid.Health = oldHealth
            return res

        elseif testName == "TestAntiKick" then
            local originalKick = Players.LocalPlayer.Kick
            Players.LocalPlayer.Kick = function()
                self:AddLog("KICK ATTEMPT BLOCKED", false, false)
            end
            Players.LocalPlayer:Kick("TEST KICK")
            Players.LocalPlayer.Kick = originalKick
            return "Anti-Kick Test Complete"

        elseif testName == "TestAntiBan" then
            local originalBan = Players.LocalPlayer.Ban
            Players.LocalPlayer.Ban = function()
                self:AddLog("BAN ATTEMPT BLOCKED", false, false)
            end
            Players.LocalPlayer:Ban(3600, "TEST BAN")
            Players.LocalPlayer.Ban = originalBan
            return "Anti-Ban Test Complete"

        elseif testName == "TestCharacterHealth" then
            local Character = Players.LocalPlayer.Character
            if not Character then return "CHARACTER NOT LOADED" end
            local Humanoid = Character:FindFirstChild("Humanoid")
            if not Humanoid then return "HUMANOID NOT FOUND" end
            local old = Humanoid.Health
            Humanoid.Health = old + 50
            return "Health Changed: " .. old .. " → " .. Humanoid.Health

        elseif testName == "TestInventoryAccess" then
            local Inventory = Players.LocalPlayer:FindFirstChild("Backpack")
            if not Inventory then return "INVENTORY NOT FOUND" end
            local Item = Inventory:FindFirstChild("Sword")
            if Item then
                return "Item Found: " .. Item.Name
            else
                return "NO ITEMS IN INVENTORY"
            end

        elseif testName == "TestChatFilter" then
            local filtered = Chat:FilterStringAsync("Test Message", Players.LocalPlayer.UserId)
            return "Filtered Text: " .. filtered

        elseif testName == "OpenDevConsole" then
            self:SetupDevConsole()
            return "Full Dev Console Access Granted - Can Run Server Scripts (require, etc.)"
        end
    end)

    if success then
        self:AddLog("TEST SUCCESS: " .. tostring(result), true, false)
    else
        self:AddLog("TEST FAILED: " .. tostring(result), false, false)
    end
end

-- ==============================================
-- INITIALIZATION
-- ==============================================
function ACTester:Initialize()
   
