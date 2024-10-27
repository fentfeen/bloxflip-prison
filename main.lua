local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TargetInput = Instance.new("TextBox")
local InmateButton = Instance.new("TextButton")
local PoliceButton = Instance.new("TextButton")
local TargetUserButton = Instance.new("TextButton")
local StopButton = Instance.new("TextButton")
local TeleportButton = Instance.new("TextButton")
local ModeIndicator = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TargetInputCorner = Instance.new("UICorner")
local InmateButtonCorner = Instance.new("UICorner")
local PoliceButtonCorner = Instance.new("UICorner")
local TargetUserButtonCorner = Instance.new("UICorner")
local StopButtonCorner = Instance.new("UICorner")
local TeleportButtonCorner = Instance.new("UICorner")

local Mode = "Inmate"
local loopActive = false
local currentTarget = nil -- Track the current target player

-- Setup ScreenGui properties
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "TeleportGUI"

-- Setup Frame properties
Frame.Size = UDim2.new(0, 400, 0, 350)
Frame.Position = UDim2.new(0.5, -200, 0.5, -175)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true
Frame.Parent = ScreenGui

-- Make the frame draggable
local dragInput
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        startPos = Frame.Position

        dragInput = UserInputService.InputChanged:Connect(updateInput)
    end
end)

Frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragInput:Disconnect()
    end
end)

-- Setup UICorner for the main frame
UICorner.Parent = Frame
UICorner.CornerRadius = UDim.new(0, 12)

-- Setup TextBox for target input
TargetInput.Size = UDim2.new(1, -20, 0, 40)
TargetInput.Position = UDim2.new(0, 10, 0, 20)
TargetInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TargetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetInput.BorderSizePixel = 0
TargetInput.Parent = Frame

-- Setup UICorner for the target input
TargetInputCorner.Parent = TargetInput
TargetInputCorner.CornerRadius = UDim.new(0, 10)

-- Setup Mode Buttons
InmateButton.Size = UDim2.new(0.45, -10, 0, 40)
InmateButton.Position = UDim2.new(0, 10, 0, 70)
InmateButton.Text = "Inmate"
InmateButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
InmateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
InmateButton.BorderSizePixel = 0
InmateButton.Parent = Frame

-- Setup UICorner for Inmate Button
InmateButtonCorner.Parent = InmateButton
InmateButtonCorner.CornerRadius = UDim.new(0, 10)

PoliceButton.Size = UDim2.new(0.45, -10, 0, 40)
PoliceButton.Position = UDim2.new(0.5, 5, 0, 70)
PoliceButton.Text = "Police"
PoliceButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
PoliceButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PoliceButton.BorderSizePixel = 0
PoliceButton.Parent = Frame

-- Setup UICorner for Police Button
PoliceButtonCorner.Parent = PoliceButton
PoliceButtonCorner.CornerRadius = UDim.new(0, 10)

-- Setup Teleport Button for .ak command
TeleportButton.Size = UDim2.new(1, -20, 0, 40)
TeleportButton.Position = UDim2.new(0, 10, 0, 120)
TeleportButton.Text = ".ak"
TeleportButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportButton.BorderSizePixel = 0
TeleportButton.Parent = Frame

-- Setup UICorner for Teleport Button
TeleportButtonCorner.Parent = TeleportButton
TeleportButtonCorner.CornerRadius = UDim.new(0, 10)

-- Setup Target User Button
TargetUserButton.Size = UDim2.new(1, -20, 0, 40)
TargetUserButton.Position = UDim2.new(0, 10, 0, 170)
TargetUserButton.Text = "Target User"
TargetUserButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
TargetUserButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetUserButton.BorderSizePixel = 0
TargetUserButton.Parent = Frame

-- Setup UICorner for Target User Button
TargetUserButtonCorner.Parent = TargetUserButton
TargetUserButtonCorner.CornerRadius = UDim.new(0, 10)

-- Setup Stop Button
StopButton.Size = UDim2.new(1, -20, 0, 40)
StopButton.Position = UDim2.new(0, 10, 0, 220)
StopButton.Text = "Stop"
StopButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.BorderSizePixel = 0
StopButton.Parent = Frame

-- Setup UICorner for Stop Button
StopButtonCorner.Parent = StopButton
StopButtonCorner.CornerRadius = UDim.new(0, 10)

-- Setup Mode Indicator
ModeIndicator.Size = UDim2.new(0, 20, 0, 20)
ModeIndicator.Position = UDim2.new(1, -30, 0, 10)
ModeIndicator.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
ModeIndicator.BorderSizePixel = 0
ModeIndicator.Parent = Frame

-- Function to check if a given player name matches the input
local function matchesPlayerName(player, input)
    return player.Name:lower():find(input) or player.DisplayName:lower():find(input)
end

-- Function to update the mode indicator color
local function updateModeIndicator()
    if Mode == "Police" then
        ModeIndicator.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    else
        ModeIndicator.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    end
end

-- Function to teleport above the target player
local function loopTeleportAbove(targetPlayer)
    local height = Mode == "Police" and 5 or 10
    loopActive = true
    while loopActive do
        local targetCharacter = targetPlayer.Character
        local localCharacter = LocalPlayer.Character
        
        if targetCharacter and localCharacter then
            local targetPosition = targetCharacter.PrimaryPart.Position + Vector3.new(0, height, 0)
            localCharacter:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        end
        
        wait()
    end
end

-- Connect button actions
InmateButton.MouseButton1Click:Connect(function()
    Mode = "Inmate"
    updateModeIndicator()
end)

PoliceButton.MouseButton1Click:Connect(function()
    Mode = "Police"
    updateModeIndicator()
end)

TeleportButton.MouseButton1Click:Connect(function()
    LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(1519.57, 70.07, 1334.12))
end)

TargetUserButton.MouseButton1Click:Connect(function()
    local inputName = TargetInput.Text:lower()

    if currentTarget then
        loopActive = false -- Stop previous loop if it exists
    end

    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if matchesPlayerName(targetPlayer, inputName) then
            currentTarget = targetPlayer -- Set current target
            loopTeleportAbove(targetPlayer) -- Activate loop teleporting
            break
        end
    end
end)

StopButton.MouseButton1Click:Connect(function()
    loopActive = false -- Stop the loop teleporting
    currentTarget = nil -- Clear the current target
end)

-- Toggle visibility with Right Control
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Initial mode indicator setup
updateModeIndicator()

print("Teleport GUI Loaded!")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "BloxFlip Prisont",
    Text = "made at KM softworks",
    Duration = 5
})
