-- ==========================================
--  Universal Script Hub | 脚本中心
--  Multi-Game Support | 按服务器分类
--  Mobile & PC | Draggable UI
-- ==========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ==========================================
--  状态 & 循环管理
-- ==========================================
local States = {}
local Threads = {}

local function StopAll()
	for k, _ in pairs(States) do
		States[k] = false
	end
	for _, t in ipairs(Threads) do
		if typeof(t) == "thread" then
			pcall(function() coroutine.close(t) end)
		end
	end
	Threads = {}
end

local function Toggle(key)
	States[key] = not States[key]
	return States[key]
end

local function IsRunning(key)
	return States[key] == true
end

local function Spawn(fn)
	local t = task.spawn(fn)
	table.insert(Threads, t)
	return t
end

-- ==========================================
--  UI 构建
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalHub_v2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 360, 0, 520)
Main.Position = UDim2.new(0.5, -180, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 18)

-- 阴影
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.Parent = Main

-- 顶部栏
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 18)

local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 20)
TopFix.Position = UDim2.new(0, 0, 0.6, 0)
TopFix.BackgroundColor3 = TopBar.BackgroundColor3
TopFix.BorderSizePixel = 0
TopFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "脚本中心"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -40, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextSize = 22
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui.Enabled = false end)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 34, 0, 34)
MinBtn.Position = UDim2.new(1, -80, 0, 8)
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.TextSize = 22
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 10)

local Minimized = false
MinBtn.MouseButton1Click:Connect(function()
	Minimized = not Minimized
	local targetSize = Minimized and UDim2.new(0, 360, 0, 50) or UDim2.new(0, 360, 0, 520)
	TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
end)

-- 分类标签页
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 36)
TabBar.Position = UDim2.new(0, 10, 0, 55)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 6)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.Parent = TabBar

local Tabs = {}
local Pages = {}
local CurrentTab = nil

local function SwitchTab(name)
	for n, btn in pairs(Tabs) do
		if n == name then
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 130, 255)}):Play()
			btn.TextColor3 = Color3.new(1,1,1)
			Pages[n].Visible = true
		else
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
			btn.TextColor3 = Color3.fromRGB(180, 180, 180)
			Pages[n].Visible = false
		end
	end
	CurrentTab = name
end

local function CreateTab(name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 0, 1, 0)
	btn.AutomaticSize = Enum.AutomaticSize.X
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(180, 180, 180)
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamBold
	btn.Parent = TabBar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	local pad = Instance.new("UIPadding", btn)
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)

	local page = Instance.new("ScrollingFrame")
	page.Name = name.."Page"
	page.Size = UDim2.new(1, -20, 1, -105)
	page.Position = UDim2.new(0, 10, 0, 96)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = Main

	Instance.new("UIListLayout", page).Padding = UDim.new(0, 8)

	Tabs[name] = btn
	Pages[name] = page
	btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
	return page
end

-- 内容组件
local function AddCategory(page, text)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -10, 0, 24)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(140, 140, 160)
	lbl.TextSize = 12
	lbl.Font = Enum.Font.GothamBold
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = page
end

local function CreateToggle(page, name, stateKey, onToggle)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -6, 0, 46)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = page
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

	local stroke = Instance.new("UIStroke", btn)
	stroke.Color = Color3.fromRGB(55, 55, 70)
	stroke.Thickness = 1

	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, -50, 1, 0)
	lbl.Position = UDim2.new(0, 14, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
	lbl.TextSize = 15
	lbl.Font = Enum.Font.GothamBold
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	local ind = Instance.new("Frame", btn)
	ind.Size = UDim2.new(0, 18, 0, 18)
	ind.Position = UDim2.new(1, -32, 0.5, -9)
	ind.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
	ind.BorderSizePixel = 0
	Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

	local function Update()
		if States[stateKey] then
			ind.BackgroundColor3 = Color3.fromRGB(0, 255, 130)
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}):Play()
		else
			ind.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
		end
	end

	btn.MouseButton1Click:Connect(function()
		States[stateKey] = not States[stateKey]
		Update()
		if onToggle then onToggle(States[stateKey]) end
	end)
	Update()
end

local function CreateButton(page, name, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -6, 0, 46)
	btn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = page
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
	lbl.TextSize = 15
	lbl.Font = Enum.Font.GothamBold
	lbl.Parent = btn

	btn.MouseButton1Down:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 70, 90)}):Play()
	end)
	btn.MouseButton1Up:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 55, 70)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 55, 70)}):Play()
	end)
	btn.MouseButton1Click:Connect(onClick)
end

-- 拖动
local dragging = false
local dragStart, startPos = nil, nil
TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
TopBar.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- ==========================================
--  页面内容
-- ==========================================

-- ---------- Bake or Die ----------
local PageBOD = CreateTab("烤或死")
AddCategory(PageBOD, "⚔️ Bake or Die")

CreateToggle(PageBOD, "近战光环 (ZAP)", "BOD_Melee", function(on)
	if not on then return end
	Spawn(function()
		local Event1 = ReplicatedStorage.ZAP.ZAP_RELIABLE
		local Event2 = ReplicatedStorage.ZAP.ZAP_RELIABLE
		local function buf(slot)
			local b = buffer.create(6)
			buffer.writeu8(b,0,45); buffer.writeu8(b,1,1); buffer.writeu8(b,2,0); buffer.writeu8(b,3,0); buffer.writeu8(b,4,0); buffer.writeu8(b,5,slot)
			return b
		end
		local function wbuf()
			local b = buffer.create(1); buffer.writeu8(b,0,3); return b
		end
		while IsRunning("BOD_Melee") do
			local c = LocalPlayer.Character
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			if hrp then
				local mons = Workspace:FindFirstChild("Monsters")
				if mons then
					for _, mon in ipairs(mons:GetChildren()) do
						if not IsRunning("BOD_Melee") then break end
						if mon:FindFirstChild("Humanoid") and mon.Humanoid.Health > 0 then
							local p = mon:FindFirstChild("HumanoidRootPart")
							if p and (hrp.Position - p.Position).Magnitude <= 300 then
								for slot = 1, 10 do
									for i = 1, 3 do
										Event1:FireServer(buf(slot), {mon})
										Event2:FireServer(wbuf(), {})
									end
								end
							end
						end
					end
				end
			end
			task.wait(0.05)
		end
	end)
end)

CreateToggle(PageBOD, "法杖远程 (ZAP)", "BOD_Staff", function(on)
	if not on then return end
	Spawn(function()
		local Event1 = ReplicatedStorage.ZAP.ZAP_UNRELIABLE_0
		local Event2 = ReplicatedStorage.ZAP.ZAP_RELIABLE
		local dmg = (function(bytes)
			local b = buffer.create(#bytes)
			for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
			return b
		end)({0,1,194,10,236,62,251,219,241,189,178,38,97,191,1,154,57,133,196,171,212,181,66,151,91,174,195,119,102,27,188,140,15,124,57,12,253,127,63})
		local wbuf = (function(bytes)
			local b = buffer.create(#bytes)
			for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
			return b
		end)({3})
		while IsRunning("BOD_Staff") do
			local c = LocalPlayer.Character
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			if hrp then
				local nearest, minD = nil, 300
				local mons = Workspace:FindFirstChild("Monsters")
				if mons then
					for _, mon in ipairs(mons:GetChildren()) do
						if mon:FindFirstChild("Humanoid") and mon.Humanoid.Health > 0 then
							local p = mon:FindFirstChild("HumanoidRootPart")
							if p then
								local d = (hrp.Position - p.Position).Magnitude
								if d < minD then minD = d; nearest = mon end
							end
						end
					end
				end
				if nearest then
					for i = 1, 5 do
						if not IsRunning("BOD_Staff") then break end
						Event1:FireServer(dmg, {nearest.Humanoid})
						Event2:FireServer(wbuf, {})
					end
				end
			end
			task.wait(0.05)
		end
	end)
end)

CreateToggle(PageBOD, "死灵召唤高频", "BOD_Necro", function(on)
	if not on then return end
	Spawn(function()
		local Event = ReplicatedStorage.ZAP.ZAP_RELIABLE
		local buf = (function(bytes)
			local b = buffer.create(#bytes)
			for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
			return b
		end)({65,199,128,191,190,221,247,15,191,167,201,60,191})
		while IsRunning("BOD_Necro") do
			for i = 1, 10 do
				if not IsRunning("BOD_Necro") then break end
				Event:FireServer(buf, {})
			end
			task.wait(0.05)
		end
	end)
end)

-- ---------- 2V2 射击 ----------
local Page2V2 = CreateTab("2V2射击")
AddCategory(Page2V2, "🔫 2V2 ShootReplicate")

CreateToggle(Page2V2, "自瞄射击", "V2_Shoot", function(on)
	if not on then return end
	Spawn(function()
		local Event = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShootReplicate")
		while IsRunning("V2_Shoot") do
			local c = LocalPlayer.Character
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			if hrp then
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character then
						local head = plr.Character:FindFirstChild("Head")
						if head then
							local pos = head.Position
							local normal = (pos - hrp.Position).Unit
							Event:FireServer({
								hitPos = pos, to = pos, origin = hrp.Position,
								id = 2, hitNormal = normal,
								effects = {Frost = 0, Ricochet = 0, Barrage = 0},
								hitInstance = head, kind = "bullet",
								isCharacterHit = true, mode = "single",
								ownerUserId = LocalPlayer.UserId, isADS = false,
							})
						end
					end
				end
			end
			task.wait(0.05)
		end
	end)
end)

-- ---------- 末日生存 ----------
local PageSurv = CreateTab("末日生存")
AddCategory(PageSurv, "⚔️ 近战 / 刺杀 / 射击")

CreateToggle(PageSurv, "Bat 杀戮光环", "Surv_Bat", function(on)
	if not on then return end
	Spawn(function()
		while IsRunning("Surv_Bat") do
			local c = LocalPlayer.Character
			if not c then task.wait(0.1); continue end
			local bat = c:FindFirstChild("Bat")
			local ev = bat and bat:FindFirstChild("HitTargets")
			if ev then
				local hrp = c:FindFirstChild("HumanoidRootPart")
				if hrp then
					local targets = {}
					for _, obj in ipairs(Workspace:GetDescendants()) do
						if obj:IsA("Humanoid") and obj.Health > 0 then
							local m = obj.Parent
							if m and m ~= c then
								local p = m:FindFirstChild("HumanoidRootPart")
								if p and (hrp.Position - p.Position).Magnitude <= 50 then
									table.insert(targets, m)
								end
								end
							end
						end
						if #targets > 0 then
							for i = 1, 5 do
								if not IsRunning("Surv_Bat") then break end
								ev:FireServer(targets)
							end
						end
					end
				end
			end
			task.wait(0.05)
		end
	end)
end)

CreateToggle(PageSurv, "Stab 刺杀光环", "Surv_Stab", function(on)
	if not on then return end
	Spawn(function()
		local cached = nil
		local function getEv()
			if cached then return cached end
			local c = LocalPlayer.Character
			if c then
				for _, o in ipairs(c:GetChildren()) do
					if o:IsA("Tool") then
						local r = o:FindFirstChild("RemoteEvent")
						if r then cached = r return r end
					end
				end
				local m = c:FindFirstChild("Musket")
				if m then
					local r = m:FindFirstChild("RemoteEvent")
					if r then cached = r return r end
				end
			end
			if getnilinstances then
				for _, o in ipairs(getnilinstances()) do
					if o.Name == "RemoteEvent" and o:IsA("RemoteEvent") then cached = o return o end
				end
			end
			return nil
		end
		while IsRunning("Surv_Stab") do
			local ev = getEv()
			if ev then
				for i = 1, 10 do
					if not IsRunning("Surv_Stab") then break end
					ev:FireServer(nil, "Stab")
					task.wait(0.01)
				end
			end
			task.wait(0.03)
		end
	end)
end)

CreateToggle(PageSurv, "Gun 射击光环", "Surv_Gun", function(on)
	if not on then return end
	Spawn(function()
		local Event = ReplicatedStorage:FindFirstChild("GunShot")
		if not Event then return end
		local buf = (function(bytes)
			local b = buffer.create(#bytes)
			for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
			return b
		end)({1,219,3,21,195,232,145,51,194,84,240,194,195,233,205,27,195,229,178,58,194,7,2,193,195})
		while IsRunning("Surv_Gun") do
			local c = LocalPlayer.Character
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			if hrp then
				for _, obj in ipairs(Workspace:GetDescendants()) do
					if obj:IsA("Humanoid") and obj.Health > 0 then
						local m = obj.Parent
						if m and m ~= c then
							local p = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Head") or m:FindFirstChildWhichIsA("BasePart")
							if p and (hrp.Position - p.Position).Magnitude <= 300 then
								local plr = Players:GetPlayerFromCharacter(m)
								local plrs = plr and {plr} or {}
								for i = 1, 3 do
									Event:FireServer("shoot", buf, plrs, {p})
								end
							end
						end
					end
				end
			end
			task.wait(0.05)
		end
	end)
end)

-- ---------- 超级模式 ----------
local PageSuper = CreateTab("超级模式")
AddCategory(PageSuper, "✨ Sparion Light Ring")

CreateToggle(PageSuper, "Sparion 光环", "Super_Sparion", function(on)
	if not on then return end
	Spawn(function()
		while IsRunning("Super_Sparion") do
			local c = LocalPlayer.Character
			local tool = c and c:FindFirstChild("Sparion Light Ring")
			local event = tool and tool:FindFirstChild("FireAstraFlashEvent")
			local blast = tool and tool:FindFirstChild("BlastEffect")
			local origin = tool and tool:FindFirstChild("OriginPart")
			local fire = origin and origin:FindFirstChild("Fire")
			if event and blast and origin and fire then
				local hrp = c:FindFirstChild("HumanoidRootPart")
				if hrp then
					for _, plr in ipairs(Players:GetPlayers()) do
						if plr ~= LocalPlayer and plr.Character then
							local t = plr.Character:FindFirstChild("HumanoidRootPart")
							if t then
								for i = 1, 5 do
									if not IsRunning("Super_Sparion") then break end
									event:FireServer(0, 0, 99999, {}, t, t.Position, blast, origin, fire)
								end
							end
						end
					end
				end
			end
			task.wait(0.1)
		end
	end)
end)

-- ---------- 其他游戏 ----------
local PageOther = CreateTab("其他")
AddCategory(PageOther, "🎮 其他服务器功能")

CreateToggle(PageOther, "Network 射击+重生", "Other_NetShoot", function(on)
	if not on then return end
	Spawn(function()
		local Event = ReplicatedStorage.Modules.Packages.Network.NetworkRemote
		local lastPos = nil
		local function setup(char)
			local hum = char:WaitForChild("Humanoid", 3)
			if hum then
				hum.Died:Connect(function()
					task.wait(0.5)
					if lastPos then
						pcall(function()
							ReplicatedStorage.Modules.Packages.Network.NetworkRemoteFunction:InvokeServer("Deploy", string.format("Spawn@%.2f,%.2f,%.2f", lastPos.X, lastPos.Y, lastPos.Z))
						end)
					end
				end)
			end
			task.spawn(function()
				while char.Parent do
					local hrp = char:FindFirstChild("HumanoidRootPart")
					if hrp then lastPos = hrp.Position end
					task.wait(0.2)
				end
			end)
		end
		if LocalPlayer.Character then setup(LocalPlayer.Character) end
		LocalPlayer.CharacterAdded:Connect(setup)
		while IsRunning("Other_NetShoot") do
			local c = LocalPlayer.Character
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			if hrp then
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= LocalPlayer and plr.Character then
						local t = plr.Character:FindFirstChild("HumanoidRootPart")
						if t then
							Event:FireServer("Shoot", hrp.Position, t.Position, nil, nil)
						end
					end
				end
			end
			task.wait(0.1)
		end
	end)
end)

CreateToggle(PageOther, "汉堡高频投掷", "Other_Burger", function(on)
	if not on then return end
	Spawn(function()
		local Event = ReplicatedStorage.Shared.Network.Remotes.Building.Success
		while IsRunning("Other_Burger") do
			for i = 1, 5 do
				if not IsRunning("Other_Burger") then break end
				Event:FireServer(-6.0046349961312)
			end
			task.wait(0.05)
		end
	end)
end)

CreateToggle(PageOther, "水桶 AOE", "Other_Bucket", function(on)
	if not on then return end
	Spawn(function()
		local Event = ReplicatedStorage.VerdantRemotes["VDT_Bucket.Used"]
		while IsRunning("Other_Bucket") do
			local waterTop = Workspace:FindFirstChild("Start") and Workspace.Start:FindFirstChild("Water") and Workspace.Start.Water:FindFirstChild("Top")
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if waterTop and hrp then
				local pos2 = hrp.Position + Vector3.new(0, 2.5, 0)
				for _, obj in ipairs(Workspace:GetDescendants()) do
					if obj:IsA("Humanoid") and obj.Health > 0 then
						local m = obj.Parent
						if m and m ~= LocalPlayer.Character then
							local p = m:FindFirstChild("HumanoidRootPart")
							if p then
								for s = 1, 3 do
									if not IsRunning("Other_Bucket") then break end
									local offset = Vector3.new(math.random(-15, 15), 0, math.random(-15, 15))
									local pos4 = p.Position + offset
									local dir = (pos4 - pos2).Unit
									Event:FireServer(waterTop, pos2, dir, pos4)
								end
							end
						end
					end
				end
			end
			task.wait(0.1)
		end
	end)
end)

CreateToggle(PageOther, "自动放物品", "Other_Place", function(on)
	if not on then return end
	Spawn(function()
		local Event = ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker._remotes.Match.RemoteEvent
		while IsRunning("Other_Place") do
			local house = Workspace:FindFirstChild("House_1")
			if house then
				local items = house:FindFirstChild("Items")
				local slots = house:FindFirstChild("Slots")
				if items and slots then
					local itemList = {}
					for _, o in ipairs(items:GetChildren()) do
						if o:IsA("BasePart") or o:IsA("Model") then table.insert(itemList, o) end
					end
					local slotList = slots:GetChildren()
					local n = math.min(#itemList, #slotList, 2)
					for i = 1, n do
						Event:FireServer("placeCarried", slotList[i], itemList[i])
					end
				end
			end
			task.wait(0.3)
		end
	end)
end)

-- ---------- 通用 ----------
local PageUtil = CreateTab("通用")
AddCategory(PageUtil, "🔧 通用功能")

CreateToggle(PageUtil, "刷 Bucks", "Util_Bucks", function(on)
	if not on then return end
	Spawn(function()
		local Event = ReplicatedStorage:FindFirstChild("Event") and ReplicatedStorage.Event:FindFirstChild("IncreaseBucks")
		if not Event then return end
		while IsRunning("Util_Bucks") do
			for i = 1, 10 do
				if not IsRunning("Util_Bucks") then break end
				Event:FireServer()
			end
			task.wait(0.01)
		end
	end)
end)

CreateToggle(PageUtil, "第三人称解锁", "Util_TP", function(on)
	if not on then return end
	Spawn(function()
		while IsRunning("Util_TP") do
			if LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
				LocalPlayer.CameraMode = Enum.CameraMode.Classic
			end
			if LocalPlayer.CameraMaxZoomDistance < 10 then
				LocalPlayer.CameraMaxZoomDistance = 128
			end
			task.wait(0.1)
		end
	end)
end)

CreateButton(PageUtil, "🛑 停止所有", function()
	StopAll()
end)

CreateButton(PageUtil, "❌ 销毁UI", function()
	StopAll()
	ScreenGui:Destroy()
end)

-- ==========================================
--  初始化 & 快捷键
-- ==========================================
SwitchTab("烤或死")

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)

print("脚本中心已加载 | 按 RightShift 显示/隐藏 | 拖动顶部移动")
