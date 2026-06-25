-- Target UI Path
local player = game:GetService("Players").LocalPlayer
local RebirthButton = player:FindFirstChild("PlayerGui")
if RebirthButton then
    RebirthButton = RebirthButton:FindFirstChild("GUI")
    if RebirthButton then RebirthButton = RebirthButton:FindFirstChild("Frames") end
    if RebirthButton then RebirthButton = RebirthButton:FindFirstChild("Rebirth") end
    if RebirthButton then RebirthButton = RebirthButton:FindFirstChild("Rebirth") end
end

-- Screen elements
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local DelayInput = Instance.new("TextBox")
local MultInput = Instance.new("TextBox")
local ToggleBtn = Instance.new("TextButton")
local DestroyBtn = Instance.new("TextButton") -- New Destroy Button
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "AutoRebirthUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -80)
MainFrame.Size = UDim2.new(0, 200, 0, 160)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Size = UDim2.new(0.75, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "REBIRTH PANEL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextSize = 13

-- Destroy/Close GUI Button Setup (Top Right 'X')
DestroyBtn.Name = "DestroyBtn"
DestroyBtn.Parent = MainFrame
DestroyBtn.BackgroundTransparency = 1
DestroyBtn.Position = UDim2.new(0.85, 0, 0, 0)
DestroyBtn.Size = UDim2.new(0, 25, 0, 30)
DestroyBtn.Font = Enum.Font.GothamBold
DestroyBtn.Text = "X"
DestroyBtn.TextColor3 = Color3.fromRGB(220, 60, 60)
DestroyBtn.TextSize = 14

DelayInput.Name = "DelayInput"
DelayInput.Parent = MainFrame
DelayInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DelayInput.Position = UDim2.new(0.05, 0, 0.25, 0)
DelayInput.Size = UDim2.new(0.9, 0, 0, 25)
DelayInput.Font = Enum.Font.Gotham
DelayInput.PlaceholderText = "Delay (0.01 - 1)"
DelayInput.Text = "0.5"
DelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayInput.TextSize = 12

MultInput.Name = "MultInput"
MultInput.Parent = MainFrame
MultInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MultInput.Position = UDim2.new(0.05, 0, 0.48, 0)
MultInput.Size = UDim2.new(0.9, 0, 0, 25)
MultInput.Font = Enum.Font.Gotham
MultInput.PlaceholderText = "Multiplier (1 - 1000)"
MultInput.Text = "1"
MultInput.TextColor3 = Color3.fromRGB(255, 255, 255)
MultInput.TextSize = 12

ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.72, 0)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 30)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "AUTO: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 12

-- Configurations
local active = false
local running = true -- Script state kill switch
local delayTime = 0.5
local multiplier = 1

-- Inputs Check
DelayInput.FocusLost:Connect(function()
    local num = tonumber(DelayInput.Text)
    delayTime = math.clamp(num or 0.5, 0.01, 1)
    DelayInput.Text = tostring(delayTime)
end)

MultInput.FocusLost:Connect(function()
    local num = tonumber(MultInput.Text)
    -- Clamped to your requested 1 - 1000 range
    multiplier = math.floor(math.clamp(num or 1, 1, 1000))
    MultInput.Text = tostring(multiplier)
end)

-- Toggle Function
ToggleBtn.MouseButton1Click:Connect(function()
    active = not active
    if active then
        ToggleBtn.Text = "AUTO: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        ToggleBtn.Text = "AUTO: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- Destroy GUI Clean Logic
DestroyBtn.MouseButton1Click:Connect(function()
    running = false -- Signals background thread to terminate immediately
    active = false
    ScreenGui:Destroy()
end)

-- Engine Click Thread Loop
task.spawn(function()
    while running do
        if active and RebirthButton then
            for i = 1, multiplier do
                -- Double check in execution line if user hit destroy mid-run
                if not running then break end
                
                local success, conns = pcall(function() return getconnections(RebirthButton.MouseButton1Click) end)
                if success and conns and #conns > 0 then
                    for _, conn in ipairs(conns) do
                        conn:Fire()
                    end
                else
                    local vu = game:GetService("VirtualUser")
                    vu:CaptureController()
                    vu:ClickButton1(Vector2.new(RebirthButton.AbsolutePosition.X + (RebirthButton.AbsoluteSize.X / 2), RebirthButton.AbsolutePosition.Y + (RebirthButton.AbsoluteSize.Y / 2)))
                end
            end
        end
        task.wait(delayTime)
    end
end)
