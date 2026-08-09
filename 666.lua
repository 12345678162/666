local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Event = game:GetService("ReplicatedStorage").HugRemotes.HugRequest
local UIS = game:GetService("UserInputService")

-- 停止旧循环
if _G.NoCDGrab then
    _G.NoCDGrab(false)
end

-- ========== 状态 ==========
local lockedTarget = nil
local running = false
_G.NoCDGrab = function(state)
    if state ~= nil then running = state end
    return running
end

-- ========== 创建 UI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NoCDGrab"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 260)
frame.Position = UDim2.new(0.5, -160, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

-- 拖动条
local dragBar = Instance.new("Frame")
dragBar.Size = UDim2.new(1, 0, 0, 44)
dragBar.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
dragBar.BorderSizePixel = 0
dragBar.Parent = frame

Instance.new("UICorner", dragBar).CornerRadius = UDim.new(0, 16)

local dragHint = Instance.new("TextLabel")
dragHint.Size = UDim2.new(1, 0, 1, 0)
dragHint.BackgroundTransparency = 1
dragHint.Text = "≡ 拖动我"
dragHint.TextColor3 = Color3.fromRGB(180, 180, 180)
dragHint.TextSize = 18
dragHint.Font = Enum.Font.GothamBold
dragHint.Parent = dragBar

-- 标题
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.Position = UDim2.new(0, 0, 0.19, 0)
title.BackgroundTransparency = 1
title.Text = "无CD 锁定抓取"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- 输入框
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0.9, 0, 0, 44)
textBox.Position = UDim2.new(0.05, 0, 0.32, 0)
textBox.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.PlaceholderText = "输入玩家名字..."
textBox.Text = ""
textBox.TextSize = 20
textBox.Font = Enum.Font.Gotham
textBox.ClearTextOnFocus = false
textBox.Parent = frame

Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 10)

-- 锁定按钮
local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(0.9, 0, 0, 44)
lockBtn.Position = UDim2.new(0.05, 0, 0.52, 0)
lockBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
lockBtn.TextColor3 = Color3.new(1, 1, 1)
lockBtn.Text = "锁定目标"
lockBtn.TextSize = 20
lockBtn.Font = Enum.Font.GothamBold
lockBtn.Parent = frame

Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0, 10)

-- 状态显示
local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 24)
status.Position = UDim2.new(0.05, 0, 0.68, 0)
status.BackgroundTransparency = 1
status.Text = "未锁定"
status.TextColor3 = Color3.fromRGB(255, 80, 80)
status.TextSize = 16
status.Font = Enum.Font.Gotham
status.Parent = frame

-- 自动抓取开关（大按钮）
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0.76, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Text = "开始抓取"
toggleBtn.TextSize = 22
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = frame

Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 12)

-- ========== 拖动功能 ==========
local dragging = false
local dragStart, startPos = nil, nil

local function updateInput(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end

dragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

dragBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        updateInput(input)
    end
end)

UIS.InputChanged:Connect(updateInput)

-- ========== 锁定逻辑 ==========
lockBtn.MouseButton1Click:Connect(function()
    local name = textBox.Text:gsub("^%s*(.-)%s*$", "%1")
    if name == "" then
        status.Text = "名字不能为空"
        status.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end

    local char = workspace:FindFirstChild(name)
    if char and char:FindFirstChild("Humanoid") then
        lockedTarget = char
        status.Text = "已锁定: " .. name
        status.TextColor3 = Color3.fromRGB(80, 255, 120)
    else
        status.Text = "找不到: " .. name
        status.TextColor3 = Color3.fromRGB(255, 80, 80)
        lockedTarget = nil
    end
end)

-- ========== 开关逻辑 ==========
toggleBtn.MouseButton1Click:Connect(function()
    if not lockedTarget then
        status.Text = "请先锁定目标"
        status.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end

    running = not running

    if running then
        toggleBtn.Text = "停止抓取"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        status.Text = "抓取中: " .. lockedTarget.Name
        status.TextColor3 = Color3.fromRGB(255, 255, 100)
    else
        toggleBtn.Text = "开始抓取"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        status.Text = "已锁定: " .. lockedTarget.Name
        status.TextColor3 = Color3.fromRGB(80, 255, 120)
    end
end)

-- ========== 无CD 抓取循环 ==========
task.spawn(function()
    while true do
        if running and lockedTarget and lockedTarget.Parent and lockedTarget:FindFirstChild("Humanoid") and lockedTarget.Humanoid.Health > 0 then
            -- 无间隔连续发送 = 无CD
            Event:FireServer("tryGrab", lockedTarget)
        elseif running and lockedTarget and (not lockedTarget.Parent or not lockedTarget:FindFirstChild("Humanoid") or lockedTarget.Humanoid.Health <= 0) then
            -- 目标死亡或离开，自动停止
            running = false
            toggleBtn.Text = "开始抓取"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            status.Text = "目标已消失"
            status.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
        task.wait() -- 每帧发送，极限频率
    end
end)

-- PC按Q停止
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Q and running then
        running = false
        toggleBtn.Text = "开始抓取"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        if lockedTarget then
            status.Text = "已锁定: " .. lockedTarget.Name
            status.TextColor3 = Color3.fromRGB(80, 255, 120)
        end
    end
end)

print("无CD锁定抓取已加载 | 输入名字 -> 锁定 -> 开始抓取 | 按Q停止")
