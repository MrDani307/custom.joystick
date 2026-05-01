local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local folderName = "joystick ID's"
local placeId = game.PlaceId
local filePath = folderName .. "/" .. placeId .. ".txt"

local function loadSetting()
    if isfolder and isfile then
        if not isfolder(folderName) then makefolder(folderName) end
        if isfile(filePath) then
            return readfile(filePath) == "true"
        end
    end
    return true
end

local function saveSetting(state)
    if writefile then
        if not isfolder(folderName) then makefolder(folderName) end
        writefile(filePath, tostring(state))
    end
end

local function showNotification(text)
    local hint = Instance.new("Hint")
    hint.Text = text
    hint.Parent = game.Workspace
    task.delay(2, function() hint:Destroy() end)
end

local isEnabled = loadSetting()

if Player.PlayerGui:FindFirstChild("BlackDynamicJoystick") then
    Player.PlayerGui.BlackDynamicJoystick:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlackDynamicJoystick"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = isEnabled

local CaptureArea = Instance.new("Frame", ScreenGui)
CaptureArea.Name = "CaptureArea"
CaptureArea.Size = UDim2.new(0.5, 0, 1, 0)
CaptureArea.Position = UDim2.new(0, 0, 0, 0)
CaptureArea.BackgroundTransparency = 1
CaptureArea.Active = true

local Base = Instance.new("Frame", ScreenGui)
Base.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Base.BackgroundTransparency = 0.85
Base.Size = UDim2.new(0, 40, 0, 40)
Base.Visible = false
Instance.new("UICorner", Base).CornerRadius = UDim.new(1, 0)

local dots = {}
for i = 1, 6 do
    local dot = Instance.new("Frame", ScreenGui)
    dot.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    dot.BackgroundTransparency = 0.95 - (i * 0.05)
    dot.Size = UDim2.new(0, 6 + (i * 2), 0, 6 + (i * 2))
    dot.Visible = false
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    table.insert(dots, dot)
end

local Stick = Instance.new("Frame", ScreenGui)
Stick.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Stick.BackgroundTransparency = 0.5
Stick.Size = UDim2.new(0, 45, 0, 45)
Stick.Visible = false
Stick.ZIndex = 5
Instance.new("UICorner", Stick).CornerRadius = UDim.new(1, 0)

local JumpButton = Instance.new("TextButton", ScreenGui)
JumpButton.Name = "CustomJumpButton"
JumpButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
JumpButton.BackgroundTransparency = 0.5
JumpButton.Position = UDim2.new(1, -95, 1, -95) 
JumpButton.Size = UDim2.new(0, 70, 0, 70)
JumpButton.Text = ""
Instance.new("UICorner", JumpButton).CornerRadius = UDim.new(1, 0)

local ArrowIcon = Instance.new("Frame", JumpButton)
ArrowIcon.Size = UDim2.new(0, 30, 0, 30)
ArrowIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
ArrowIcon.AnchorPoint = Vector2.new(0.5, 0.5)
ArrowIcon.BackgroundTransparency = 1
local Tip = Instance.new("Frame", ArrowIcon)
Tip.Size = UDim2.new(0, 20, 0, 20)
Tip.Position = UDim2.new(0.5, 0, 0.35, 0)
Tip.AnchorPoint = Vector2.new(0.5, 0.5)
Tip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Tip.Rotation = 45
local Stem = Instance.new("Frame", ArrowIcon)
Stem.Size = UDim2.new(0, 12, 0, 14)
Stem.Position = UDim2.new(0.5, 0, 0.6, 0)
Stem.AnchorPoint = Vector2.new(0.5, 0)
Stem.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

local function setStandardControls(visible)
    pcall(function()
        local touchGui = Player.PlayerGui:FindFirstChild("TouchGui")
        if touchGui then touchGui.Enabled = visible end
    end)
end

local function toggleSystem(state)
    if not state then showNotification("Wait...") end
    isEnabled = state
    ScreenGui.Enabled = state
    saveSetting(state)
    setStandardControls(not state)
end

Player.Chatted:Connect(function(msg)
    local m = msg:lower()
    if m == "on" then toggleSystem(true)
    elseif m == "off" then toggleSystem(false) end
end)

local dragging = false
local inputObject = nil
local moveVector = Vector3.new(0, 0, 0)
local startPos = Vector2.new(0, 0)

JumpButton.MouseButton1Down:Connect(function()
    if isEnabled then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        JumpButton.BackgroundTransparency = 0.3
    end
end)

JumpButton.MouseButton1Up:Connect(function()
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    JumpButton.BackgroundTransparency = 0.5
end)

CaptureArea.InputBegan:Connect(function(input)
    if isEnabled and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        dragging = true
        inputObject = input
        startPos = Vector2.new(input.Position.X, input.Position.Y)
        Base.Position = UDim2.new(0, startPos.X - 20, 0, startPos.Y - 20)
        Base.Visible = true
        Stick.Visible = true
        for _, d in pairs(dots) do d.Visible = true end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isEnabled and dragging and input == inputObject then
        local currentPos = Vector2.new(input.Position.X, input.Position.Y)
        local diff = currentPos - startPos
        if diff.Magnitude > 0 then
            local direction = diff.Unit
            Stick.Position = UDim2.new(0, currentPos.X - 22.5, 0, currentPos.Y - 22.5)
            for i, dot in pairs(dots) do
                local ratio = i / 7
                local dotPos = startPos + (diff * ratio)
                dot.Position = UDim2.new(0, dotPos.X - (dot.Size.X.Offset/2), 0, dotPos.Y - (dot.Size.Y.Offset/2))
            end
            moveVector = Vector3.new(direction.X, 0, direction.Y)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == inputObject then
        dragging = false
        inputObject = nil
        Base.Visible = false
        Stick.Visible = false
        for _, d in pairs(dots) do d.Visible = false end
        moveVector = Vector3.new(0, 0, 0)
    end
end)

RunService.RenderStepped:Connect(function()
    if isEnabled and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid:Move(moveVector, true)
    end
end)

task.spawn(function()
    task.wait(1)
    setStandardControls(not isEnabled)
end)
