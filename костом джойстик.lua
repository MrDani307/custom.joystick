local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

if Player.PlayerGui:FindFirstChild("BlackDynamicJoystick") then
    Player.PlayerGui.BlackDynamicJoystick:Destroy()
end

local function hideDefaultControls()
    local touchGui = Player:FindFirstChild("PlayerGui"):WaitForChild("TouchGui", 5)
    if touchGui then
        touchGui.Enabled = false
    end
end
hideDefaultControls()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlackDynamicJoystick"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local CaptureArea = Instance.new("Frame")
CaptureArea.Name = "CaptureArea"
CaptureArea.Parent = ScreenGui
CaptureArea.Size = UDim2.new(0.5, 0, 0.55, 0) 
CaptureArea.Position = UDim2.new(0, 0, 0.45, 0)
CaptureArea.BackgroundTransparency = 1
CaptureArea.Active = true

local Base = Instance.new("Frame")
Base.Parent = ScreenGui
Base.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Base.BackgroundTransparency = 0.85
Base.Size = UDim2.new(0, 40, 0, 40)
Base.Visible = false
Base.BorderSizePixel = 0
Instance.new("UICorner", Base).CornerRadius = UDim.new(1, 0)

local dots = {}
for i = 1, 6 do
    local dot = Instance.new("Frame")
    dot.Parent = ScreenGui
    dot.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    dot.BackgroundTransparency = 0.95 - (i * 0.05)
    dot.Size = UDim2.new(0, 6 + (i * 2), 0, 6 + (i * 2))
    dot.Visible = false
    dot.BorderSizePixel = 0
    dot.ZIndex = 2
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    table.insert(dots, dot)
end

local Stick = Instance.new("Frame")
Stick.Parent = ScreenGui
Stick.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Stick.BackgroundTransparency = 0.5
Stick.Size = UDim2.new(0, 45, 0, 45)
Stick.Visible = false
Stick.BorderSizePixel = 0
Stick.ZIndex = 5
Instance.new("UICorner", Stick).CornerRadius = UDim.new(1, 0)

local JumpButton = Instance.new("TextButton")
JumpButton.Name = "CustomJumpButton"
JumpButton.Parent = ScreenGui
JumpButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
JumpButton.BackgroundTransparency = 0.5
JumpButton.Position = UDim2.new(1, -95, 1, -95) 
JumpButton.Size = UDim2.new(0, 70, 0, 70)
JumpButton.Text = ""
JumpButton.BorderSizePixel = 0
Instance.new("UICorner", JumpButton).CornerRadius = UDim.new(1, 0)

local ArrowIcon = Instance.new("Frame")
ArrowIcon.Size = UDim2.new(0, 30, 0, 30)
ArrowIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
ArrowIcon.AnchorPoint = Vector2.new(0.5, 0.5)
ArrowIcon.BackgroundTransparency = 1
ArrowIcon.Parent = JumpButton

local Tip = Instance.new("Frame")
Tip.Size = UDim2.new(0, 20, 0, 20)
Tip.Position = UDim2.new(0.5, 0, 0.35, 0)
Tip.AnchorPoint = Vector2.new(0.5, 0.5)
Tip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Tip.Rotation = 45
Tip.BorderSizePixel = 0
Tip.Parent = ArrowIcon
Instance.new("UICorner", Tip).CornerRadius = UDim.new(0, 2)

local Stem = Instance.new("Frame")
Stem.Size = UDim2.new(0, 12, 0, 14)
Stem.Position = UDim2.new(0.5, 0, 0.6, 0)
Stem.AnchorPoint = Vector2.new(0.5, 0)
Stem.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Stem.BorderSizePixel = 0
Stem.Parent = ArrowIcon

local dragging = false
local inputObject = nil
local moveVector = Vector3.new(0, 0, 0)
local startPos = Vector2.new(0, 0)

JumpButton.MouseButton1Down:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    JumpButton.BackgroundTransparency = 0.3
end)

JumpButton.MouseButton1Up:Connect(function()
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    JumpButton.BackgroundTransparency = 0.5
end)

CaptureArea.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and not dragging then
        dragging = true
        inputObject = input
        startPos = Vector2.new(input.Position.X, input.Position.Y)
        Base.Position = UDim2.new(0, startPos.X - 20, 0, startPos.Y - 20)
        Base.Visible = true
        Stick.Visible = true
        for _, dot in pairs(dots) do dot.Visible = true end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == inputObject then
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
        for _, dot in pairs(dots) do dot.Visible = false end
        moveVector = Vector3.new(0, 0, 0)
    end
end)

RunService.RenderStepped:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid:Move(moveVector, true)
    end
end)
