local States = {
    AutoCollect = false,
    CollectInterval = 0.5,
    AutoUpgrade = false,
    UpgradeInterval = 0.5,
    AutoRebirth = false,
    RebirthInterval = 0.5,
    BlatantFarm = false,
    HatchTriggered = false,
    RenderingDisabled = false
}

local LocalPlayer = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local TargetPaths = {
    Plot = workspace:WaitForChild("Plot_" .. LocalPlayer.Name),
    RebirthButton = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("GUI"):WaitForChild("Frames"):WaitForChild("Rebirth"):WaitForChild("Rebirth"),
    CameraTarget = workspace:WaitForChild("LocalNPCs"):WaitForChild("LocalGuard_Base13"),
    ConfirmHatchEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ConfirmHatch"),
    ShowCashPopUp = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ShowCashPopUp"),
    ShowNotification = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ShowNotification")
}

local START_POS = Vector3.new(0, 3, 46)
local END_POS = Vector3.new(0, 3, 6)

-- Immediate Popup & Notification Nullification
local function disableOnClientEvent(remote)
    if not remote then return end
    for _, conn in ipairs(getconnections(remote.OnClientEvent)) do
        hookfunction(conn.Function, function() return end)
    end
end
disableOnClientEvent(TargetPaths.ShowCashPopUp)
disableOnClientEvent(TargetPaths.ShowNotification)

local function nullifyController(name)
    local scriptObj = LocalPlayer.PlayerScripts:FindFirstChild(name)
    if scriptObj then
        if scriptObj:IsA("LocalScript") then
            scriptObj.Disabled = true
        end
        local module = pcall(require, scriptObj)
        if module and type(module) == "table" then
            for k, v in pairs(module) do
                if type(v) == "function" then module[k] = function() end end
            end
        end
    end
end
nullifyController("PopUpController")
nullifyController("NotificationController")

-- Network Intercept for Eggs
for _, Connection in ipairs(getconnections(TargetPaths.ConfirmHatchEvent.OnClientEvent)) do
    local old; old = hookfunction(Connection.Function, function(...)
        States.HatchTriggered = true
        return old(...)
    end)
end
TargetPaths.ConfirmHatchEvent.OnClientEvent:Connect(function()
    States.HatchTriggered = true
end)

-- UI Architecture
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("TycoonAutomationHub") then
    CoreGui.TycoonAutomationHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TycoonAutomationHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 337)
MainFrame.Position = UDim2.new(0.5, -120, 0.3, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 0, 30)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Automation Suite"
TitleLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 15
TitleLabel.Parent = MainFrame

local UtilityContainer = Instance.new("Frame")
UtilityContainer.Size = UDim2.new(0, 50, 0, 30)
UtilityContainer.Position = UDim2.new(1, -55, 0, 0)
UtilityContainer.BackgroundTransparency = 1
UtilityContainer.Parent = MainFrame

local UIListLayoutUtil = Instance.new("UIListLayout")
UIListLayoutUtil.FillDirection = Enum.FillDirection.Horizontal
UIListLayoutUtil.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIListLayoutUtil.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayoutUtil.Padding = UDim.new(0, 5)
UIListLayoutUtil.Parent = UtilityContainer

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Parent = UtilityContainer

local DestroyBtn = Instance.new("TextButton")
DestroyBtn.Size = UDim2.new(0, 20, 0, 20)
DestroyBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
DestroyBtn.Text = "X"
DestroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DestroyBtn.Font = Enum.Font.SourceSansBold
DestroyBtn.Parent = UtilityContainer

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -40)
ContentContainer.Position = UDim2.new(0, 10, 0, 35)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local UIListLayoutButtons = Instance.new("UIListLayout")
UIListLayoutButtons.Padding = UDim.new(0, 6)
UIListLayoutButtons.Parent = ContentContainer

local function createToggle(name, stateKey, parent, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 13
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
    
    local function updateVisuals()
        if States[stateKey] then
            Btn.BackgroundColor3 = Color3.fromRGB(46, 117, 89)
            Btn.Text = name .. " [ACTIVE]"
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            Btn.Text = name .. " [DISABLED]"
            Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    end
    
    updateVisuals()
    Btn.MouseButton1Click:Connect(function()
        callback()
        updateVisuals()
    end)
    return Btn
end

local function createSliderRow(labelName, stateKey, parent)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 30)
    Row.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Row.Parent = parent
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 5)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelName
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(0.3, -5, 0, 22)
    Input.Position = UDim2.new(0.7, 0, 0.5, -11)
    Input.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    Input.Text = string.format("%.1f", States[stateKey])
    Input.TextColor3 = Color3.fromRGB(100, 210, 255)
    Input.Font = Enum.Font.Code
    Input.TextSize = 12
    Input.ClearTextOnFocus = false
    Input.Parent = Row
    Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 4)

    Input.FocusLost:Connect(function()
        local raw = tonumber(Input.Text)
        if raw then
            local cl = math.clamp(raw, 0.1, 1.0)
            States[stateKey] = cl
            Input.Text = string.format("%.1f", cl)
        else
            Input.Text = string.format("%.1f", States[stateKey])
        end
    end)
end

-- Layout Population
createToggle("Auto Collect", "AutoCollect", ContentContainer, function() States.AutoCollect = not States.AutoCollect end)
createSliderRow("Collect Speed:", "CollectInterval", ContentContainer)

createToggle("Auto Upgrade", "AutoUpgrade", ContentContainer, function() States.AutoUpgrade = not States.AutoUpgrade end)
createSliderRow("Upgrade Speed:", "UpgradeInterval", ContentContainer)

createToggle("Auto Rebirth", "AutoRebirth", ContentContainer, function() States.AutoRebirth = not States.AutoRebirth end)
createSliderRow("Rebirth Speed:", "RebirthInterval", ContentContainer)

createToggle("Blatant Auto Farm", "BlatantFarm", ContentContainer, function() States.BlatantFarm = not States.BlatantFarm end)

-- Dark Mode overlay: sits above the 3D world but below all game ScreenGuis
local DarkOverlayGui = Instance.new("ScreenGui")
DarkOverlayGui.Name = "DarkModeOverlay"
DarkOverlayGui.DisplayOrder = -10          -- behind game GUIs (default is 0)
DarkOverlayGui.ResetOnSpawn = false
DarkOverlayGui.IgnoreGuiInset = true
DarkOverlayGui.Parent = CoreGui

local DarkFrame = Instance.new("Frame")
DarkFrame.Size = UDim2.new(1, 0, 1, 0)
DarkFrame.Position = UDim2.new(0, 0, 0, 0)
DarkFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DarkFrame.BackgroundTransparency = 1       -- starts invisible
DarkFrame.BorderSizePixel = 0
DarkFrame.ZIndex = 1
DarkFrame.Parent = DarkOverlayGui

createToggle("Dark Mode (Hide 3D)", "RenderingDisabled", ContentContainer, function()
    States.RenderingDisabled = not States.RenderingDisabled
    DarkFrame.BackgroundTransparency = States.RenderingDisabled and 0 or 1
    game:GetService("RunService"):Set3dRenderingEnabled(not States.RenderingDisabled)
end)

local activeThreads = true

local function orientCameraToTarget()
    if TargetPaths.CameraTarget and workspace.CurrentCamera then
        pcall(function()
            local cam = workspace.CurrentCamera
            local guardPos = TargetPaths.CameraTarget.Position
            cam.CFrame = CFrame.new(cam.CFrame.Position, Vector3.new(guardPos.X, cam.CFrame.Position.Y, guardPos.Z))
        end)
    end
end

local noclipConnection
noclipConnection = RunService.Stepped:Connect(function()
    if not activeThreads then noclipConnection:Disconnect() return end
    if States.BlatantFarm and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Anti-Kick / Anti-AFK Engine (Triggers every 2 minutes)
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if activeThreads then
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end
    end)
end)

-- Loop 1: Auto Collect
task.spawn(function()
    while activeThreads do
        task.wait(States.CollectInterval)
        if States.AutoCollect and LocalPlayer.Character then
            local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                for f = 1, 3 do
                    local floor = TargetPaths.Plot:FindFirstChild("Floor" .. f)
                    local slots = floor and floor:FindFirstChild("Slots")
                    if slots then
                        for s = 1, 10 do
                            local slot = slots:FindFirstChild("Slot" .. s)
                            local collectTouch = slot and slot:FindFirstChild("CollectTouch")
                            if collectTouch then
                                pcall(function()
                                    firetouchinterest(rootPart, collectTouch, 0)
                                    task.wait(0.005)
                                    firetouchinterest(rootPart, collectTouch, 1)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Loop 2: Auto Upgrade
task.spawn(function()
    while activeThreads do
        task.wait(States.UpgradeInterval)
        if States.AutoUpgrade then
            for f = 1, 3 do
                local floor = TargetPaths.Plot:FindFirstChild("Floor" .. f)
                local slots = floor and floor:FindFirstChild("Slots")
                if slots then
                    for s = 1, 10 do
                        local slot = slots:FindFirstChild("Slot" .. s)
                        local upgradeBtn = slot and slot:FindFirstChild("UpgradePart") and slot.UpgradePart:FindFirstChild("UpgradeGUI") and slot.UpgradePart.UpgradeGUI:FindFirstChild("UpgradeButton")
                        if upgradeBtn then
                            pcall(function()
                                for _, conn in ipairs(getconnections(upgradeBtn.MouseButton1Click)) do conn:Fire() end
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- Loop 3: Auto Rebirth
task.spawn(function()
    while activeThreads do
        task.wait(States.RebirthInterval)
        if States.AutoRebirth and TargetPaths.RebirthButton then
            pcall(function()
                for _, conn in ipairs(getconnections(TargetPaths.RebirthButton.MouseButton1Click)) do conn:Fire() end
            end)
        end
    end
end)

-- Loop 4: Blatant Anime Farm Engine
task.spawn(function()
    while activeThreads do
        task.wait(0.2)
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if States.BlatantFarm and rootPart and humanoid then
            States.HatchTriggered = false
            rootPart.CFrame = CFrame.new(START_POS)
            task.wait(0.2)
            orientCameraToTarget()
            
            while States.BlatantFarm and not States.HatchTriggered do
                humanoid:Move(Vector3.new(0, 0, 1), true)
                RunService.Heartbeat:Wait()
            end
            
            humanoid:Move(Vector3.new(0, 0, 0), true)
            
            if States.BlatantFarm and States.HatchTriggered then
                rootPart.CFrame = CFrame.new(END_POS)
                task.wait(6.0)
            end
        end
    end
end)

-- Window Mechanics
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 240, 0, 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
        ContentContainer.Visible = false
        MinimizeBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 240, 0, 337), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
        ContentContainer.Visible = true
        MinimizeBtn.Text = "-"
    end
end)

DestroyBtn.MouseButton1Click:Connect(function()
    activeThreads = false
    States.AutoCollect = false
    States.AutoUpgrade = false
    States.AutoRebirth = false
    States.BlatantFarm = false
    DarkFrame.BackgroundTransparency = 1
    game:GetService("RunService"):Set3dRenderingEnabled(true)
    ScreenGui:Destroy()
    DarkOverlayGui:Destroy()
end)
