local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local TweenService=game:GetService("TweenService")

local player=Players.LocalPlayer
local gui=player:WaitForChild("PlayerGui"):WaitForChild("SmashHUD")
local world=Workspace:WaitForChild("SmashWorld")

local bar=Instance.new("Frame")
bar.Name="BossBar"
bar.AnchorPoint=Vector2.new(.5,0)
bar.Position=UDim2.new(.5,0,0,166)
bar.Size=UDim2.fromOffset(520,64)
bar.BackgroundColor3=Color3.fromRGB(30,32,43)
bar.BackgroundTransparency=.05
bar.Visible=false
bar.Parent=gui
local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,13); corner.Parent=bar
local stroke=Instance.new("UIStroke"); stroke.Thickness=2; stroke.Transparency=.2; stroke.Parent=bar
local title=Instance.new("TextLabel")
title.Position=UDim2.fromOffset(12,5); title.Size=UDim2.new(1,-24,0,25); title.BackgroundTransparency=1; title.Font=Enum.Font.GothamBlack; title.TextScaled=true; title.TextColor3=Color3.new(1,1,1); title.TextStrokeTransparency=.4; title.Text="ZONE BOSS"; title.Parent=bar
local back=Instance.new("Frame")
back.Position=UDim2.fromOffset(18,36); back.Size=UDim2.new(1,-36,0,16); back.BackgroundColor3=Color3.fromRGB(67,69,78); back.BorderSizePixel=0; back.Parent=bar
local bc=Instance.new("UICorner"); bc.CornerRadius=UDim.new(1,0); bc.Parent=back
local fill=Instance.new("Frame")
fill.Size=UDim2.fromScale(1,1); fill.BackgroundColor3=Color3.fromRGB(239,92,68); fill.BorderSizePixel=0; fill.Parent=back
local fc=Instance.new("UICorner"); fc.CornerRadius=UDim.new(1,0); fc.Parent=fill

local tracked
local conns={}
local function disconnect()
	for _,c in ipairs(conns) do c:Disconnect() end
	table.clear(conns)
end
local function update()
	if not tracked or not tracked.Parent then bar.Visible=false return end
	local hp=tonumber(tracked:GetAttribute("HP")) or 0
	local max=tonumber(tracked:GetAttribute("MaxHP")) or 1
	local ratio=math.clamp(hp/max,0,1)
	TweenService:Create(fill,TweenInfo.new(.12),{Size=UDim2.fromScale(ratio,1)}):Play()
	title.Text="ZONE BOSS  •  "..math.ceil(hp).." / "..math.ceil(max).." HP"
	bar.Visible=ratio>0
	if ratio<=.75 then tracked.Color=tracked.Color:Lerp(Color3.fromRGB(85,70,64),.12) end
	if ratio<=.5 then tracked.Color=tracked.Color:Lerp(Color3.fromRGB(65,52,50),.16) end
	if ratio<=.25 then tracked.Color=tracked.Color:Lerp(Color3.fromRGB(42,35,38),.22) end
end
local function track(gate)
	if tracked==gate then return end
	disconnect(); tracked=gate
	table.insert(conns,gate:GetAttributeChangedSignal("HP"):Connect(update))
	table.insert(conns,gate.AncestryChanged:Connect(update))
	update()
end

task.spawn(function()
	while gui.Parent do
		task.wait(.25)
		local char=player.Character
		local root=char and char:FindFirstChild("HumanoidRootPart")
		if root then
			local best,bestDist=nil,80
			for _,d in ipairs(world:GetDescendants()) do
				if d:IsA("BasePart") and d:GetAttribute("ZoneGate") then
					local dist=(root.Position-d.Position).Magnitude
					if dist<bestDist then best,bestDist=d,dist end
				end
			end
			if best then track(best) elseif bestDist==80 then bar.Visible=false end
		end
	end
end)
