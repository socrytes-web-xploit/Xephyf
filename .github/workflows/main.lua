-- Server Script (ServerScriptService)
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- LIST DEVELOPER YANG DI-APPROVE (ID LU SUDAH MASUK)
local approvedDevelopers = {
    8550010629,  -- ID lu
    -- Tambah ID developer lain di sini
}

-- Function untuk cek apakah player developer
local function isDeveloper(player)
    local userId = player.UserId
    for _, devId in ipairs(approvedDevelopers) do
        if userId == devId then
            return true
        end
    end
    return false
end

-- Function untuk execute command dari developer
local function executeDeveloperCommand(player, command)
    if isDeveloper(player) then
        local success, result = pcall(function()
            return loadstring(command)()
        end)
        
        if success then
            return "✅ Success: " .. tostring(result)
        else
            return "❌ Error: " .. tostring(result)
        end
    else
        return "🚫 Access denied. Developer only."
    end
end

-- RemoteEvent untuk komunikasi client-server
local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "DeveloperConsole"
remoteEvent.Parent = ServerStorage

-- Handler di server
remoteEvent.OnServerEvent:Connect(function(player, command)
    local result = executeDeveloperCommand(player, command)
    remoteEvent:FireClient(player, result)
end)

print("✅ Developer Console Loaded")
print("✅ Approved Developers: " .. #approvedDevelopers .. " users")
-- Client Script (LocalScript di StarterPlayerScripts)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local remoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("DeveloperConsole")

-- Toggle console dengan key (misal F9)
local consoleVisible = false
local consoleGUI = nil

local function createConsoleGUI()
    if consoleGUI then
        consoleGUI:Destroy()
        consoleGUI = nil
        return
    end
    
    -- Buat ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DevConsole"
    screenGui.Parent = player.PlayerGui
    
    -- Frame utama
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 400)
    frame.Position = UDim2.new(0.5, -250, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    frame.Parent = screenGui
    
    -- Title bar
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    title.Text = "DEV CONSOLE - UserID: " .. player.UserId
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.Code
    title.Parent = frame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    closeButton.Parent = frame
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        consoleGUI = nil
    end)
    
    -- TextBox untuk input command
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -10, 0, 35)
    textBox.Position = UDim2.new(0, 5, 0, 35)
    textBox.PlaceholderText = "Enter Lua command..."
    textBox.Text = ""
    textBox.Font = Enum.Font.Code
    textBox.TextSize = 14
    textBox.TextColor3 = Color3.fromRGB(0, 255, 0)
    textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    textBox.Parent = frame
    
    -- Execute button
    local executeButton = Instance.new("TextButton")
    executeButton.Size = UDim2.new(0, 100, 0, 35)
    executeButton.Position = UDim2.new(1, -105, 0, 35)
    executeButton.Text = "EXECUTE"
    executeButton.Font = Enum.Font.Code
    executeButton.TextColor3 = Color3.fromRGB(0, 255, 0)
    executeButton.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
    executeButton.Parent = frame
    
    -- Output text (ScrollingFrame)
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, -10, 1, -85)
    scrollingFrame.Position = UDim2.new(0, 5, 0, 75)
    scrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
    scrollingFrame.Parent = frame
    
    local outputText = Instance.new("TextLabel")
    outputText.Size = UDim2.new(1, 0, 0, 0)
    outputText.Position = UDim2.new(0, 5, 0, 5)
    outputText.BackgroundTransparency = 1
    outputText.TextColor3 = Color3.fromRGB(0, 255, 0)
    outputText.TextXAlignment = Enum.TextXAlignment.Left
    outputText.TextYAlignment = Enum.TextYAlignment.Top
    outputText.TextWrapped = true
    outputText.Font = Enum.Font.Code
    outputText.TextSize = 12
    outputText.Parent = scrollingFrame
    
    -- Event handler untuk execute button
    executeButton.MouseButton1Click:Connect(function()
        local command = textBox.Text
        if command ~= "" then
            remoteEvent:FireServer(command)
            textBox.Text = ""
        end
    end)
    
    -- Event untuk enter key
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local command = textBox.Text
            if command ~= "" then
                remoteEvent:FireServer(command)
                textBox.Text = ""
            end
        end
    end)
    
    -- Event untuk menerima hasil dari server
    remoteEvent.OnClientEvent:Connect(function(result)
        outputText.Text = outputText.Text .. "\n> " .. tostring(result)
        scrollingFrame.CanvasPosition = Vector2.new(0, outputText.TextBounds.Y)
    end)
    
    consoleGUI = screenGui
end

-- Bind key F9 untuk toggle console
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F9 then
        createConsoleGUI()
    end
end)

-- Auto-check jika developer
if player.UserId == 8550010629 then
    print("✅ Developer console ready! Press F9 to open")
else
    print("❌ Access denied: Not in developer list")
end
