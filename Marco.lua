local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local customSpeed = 150
local defaultWalkSpeed = 16
local minSpeed = 16
local maxSpeed = 1000
local speedEnabled = false
local bodyVelocity, bodyGyro, speedConnection

local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MarcoSpeed"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(0, 150, 0, 80)
speedFrame.Position = UDim2.new(1, -165, 0, 200)
speedFrame.BackgroundColor3 = Color3.new(0, 0, 0)
speedFrame.BackgroundTransparency = 0.5
speedFrame.Active = true
speedFrame.Draggable = true
speedFrame.Parent = screenGui

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 12)
speedCorner.Parent = speedFrame

local speedTitle = Instance.new("TextLabel")
speedTitle.Size = UDim2.new(1, 0, 0.35, 0)
speedTitle.BackgroundTransparency = 1
speedTitle.Text = "Marco Speed"
speedTitle.TextColor3 = Color3.new(0, 0.7, 1)
speedTitle.TextScaled = true
speedTitle.Font = Enum.Font.GothamBold
speedTitle.Parent = speedFrame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.8, 0, 0.3, 0)
speedBox.Position = UDim2.new(0.1, 0, 0.3, 0)
speedBox.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.PlaceholderText = "16-1000"
speedBox.Text = tostring(customSpeed)
speedBox.TextScaled = true
speedBox.Font = Enum.Font.Gotham
speedBox.ClearTextOnFocus = false
speedBox.Parent = speedFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0.25, 0)
toggleButton.Position = UDim2.new(0.1, 0, 0.7, 0)
toggleButton.BackgroundColor3 = Color3.new(1, 0, 0)
toggleButton.Text = "Off"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = speedFrame

local function cleanupSpeed()
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if speedConnection then speedConnection:Disconnect() speedConnection = nil end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = defaultWalkSpeed
    end
end

local function startSpeed()
    cleanupSpeed()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(50000, 0, 50000)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.P = 3000
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(0, math.huge, 0)
    bodyGyro.P = 5000
    bodyGyro.D = 800
    bodyGyro.Parent = root

    speedConnection = RunService.Heartbeat:Connect(function()
        if hum.Health <= 0 then return end
        local dir = hum.MoveDirection
        if dir.Magnitude > 0 then
            bodyVelocity.Velocity = dir * customSpeed
            bodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + dir)
        else
            bodyVelocity.Velocity = Vector3.new(0,0,0)
        end
    end)
end

toggleButton.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        local n = tonumber(speedBox.Text)
        if n and n >= minSpeed and n <= maxSpeed then customSpeed = n end
        toggleButton.Text = "On"
        toggleButton.BackgroundColor3 = Color3.new(0,1,0)
        startSpeed()
    else
        toggleButton.Text = "Off"
        toggleButton.BackgroundColor3 = Color3.new(1,0,0)
        cleanupSpeed()
    end
end)

speedBox.FocusLost:Connect(function(enter)
    if enter then
        local n = tonumber(speedBox.Text)
        if n and n >= minSpeed and n <= maxSpeed then
            customSpeed = n
            if speedEnabled then startSpeed() end
        else
            speedBox.Text = tostring(customSpeed)
        end
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    if speedEnabled then startSpeed() end
end)