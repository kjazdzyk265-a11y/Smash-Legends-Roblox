local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local mouse=player:GetMouse()
local net=ReplicatedStorage:WaitForChild("SmashNet")
local action=net:WaitForChild("Action")
local stateEvent=net:WaitForChild("State")
local notice=net:WaitForChild("Notice")
local NumberUtil=require(ReplicatedStorage.Shared.NumberUtil)

local gui=Instance.new("ScreenGui"); gui.Name="SmashHUD"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.Parent=player:WaitForChild("PlayerGui")
local function corner(obj,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 12); c.Parent=obj end
local function stroke(obj,t) local s=Instance.new("UIStroke"); s.Thickness=t or 2; s.Transparency=.25; s.Parent=obj end
local function text(parent,pos,size,txt,font)
	local l=Instance.new("TextLabel"); l.Position=pos; l.Size=size; l.BackgroundTransparency=1; l.Text=txt; l.TextColor3=Color3.new(1,1,1); l.TextStrokeTransparency=.35; l.Font=font or Enum.Font.GothamBold; l.TextScaled=true; l.Parent=parent; return l
end
local function panel(pos,size,color)
	local f=Instance.new("Frame"); f.Position=pos; f.Size=size; f.BackgroundColor3=color or Color3.fromRGB(37,42,55); f.BackgroundTransparency=.08; f.Parent=gui; corner(f,14); stroke(f,2); return f
end

local stats=panel(UDim2.fromOffset(18,18),UDim2.fromOffset(270,92),Color3.fromRGB(42,47,60))
local strength=text(stats,UDim2.fromOffset(12,8),UDim2.new(1,-24,.42,0),"💪 STRENGTH  1",Enum.Font.GothamBlack); strength.TextXAlignment=Enum.TextXAlignment.Left
local coins=text(stats,UDim2.new(0,12,.5,0),UDim2.new(1,-24,.42,0),"🪙 COINS  0",Enum.Font.GothamBlack); coins.TextColor3=Color3.fromRGB(255,218,73); coins.TextXAlignment=Enum.TextXAlignment.Left
local tool=panel(UDim2.new(.5,-155,1,-88),UDim2.fromOffset(310,66),Color3.fromRGB(48,53,67))
local toolText=text(tool,UDim2.fromOffset(10,6),UDim2.new(1,-20,1,-12),"🔨 WOODEN HAMMER",Enum.Font.GothamBlack)
local objective=panel(UDim2.new(.5,-210,0,18),UDim2.fromOffset(420,58),Color3.fromRGB(51,57,70))
local objectiveText=text(objective,UDim2.fromOffset(12,6),UDim2.new(1,-24,1,-12),"TRAIN → SMASH → UPGRADE",Enum.Font.GothamBlack); objectiveText.TextColor3=Color3.fromRGB(255,224,92)

local shop=panel(UDim2.new(.5,-220,.5,-170),UDim2.fromOffset(440,340),Color3.fromRGB(35,39,51)); shop.Visible=false
text(shop,UDim2.fromOffset(20,18),UDim2.new(1,-40,0,50),"⚒ BLACKSMITH",Enum.Font.GothamBlack)
local current=text(shop,UDim2.fromOffset(25,83),UDim2.new(1,-50,0,45),"CURRENT: WOODEN HAMMER")
local nextLabel=text(shop,UDim2.fromOffset(25,137),UDim2.new(1,-50,0,60),"NEXT: STONE MALLET")
local buy=Instance.new("TextButton"); buy.Position=UDim2.new(.1,0,1,-105); buy.Size=UDim2.new(.8,0,0,62); buy.BackgroundColor3=Color3.fromRGB(87,206,92); buy.TextColor3=Color3.new(1,1,1); buy.Text="BUY"; buy.Font=Enum.Font.GothamBlack; buy.TextScaled=true; buy.Parent=shop; corner(buy,13); stroke(buy,2)
local close=Instance.new("TextButton"); close.Position=UDim2.new(1,-50,0,10); close.Size=UDim2.fromOffset(40,40); close.BackgroundColor3=Color3.fromRGB(205,70,70); close.Text="×"; close.TextColor3=Color3.new(1,1,1); close.Font=Enum.Font.GothamBlack; close.TextScaled=true; close.Parent=shop; corner(close,10)
close.Activated:Connect(function() shop.Visible=false end)
buy.Activated:Connect(function() action:FireServer("BuyTool") end)

local mobileHit=Instance.new("TextButton"); mobileHit.AnchorPoint=Vector2.new(1,1); mobileHit.Position=UDim2.new(1,-24,1,-24); mobileHit.Size=UDim2.fromOffset(120,120); mobileHit.BackgroundColor3=Color3.fromRGB(238,103,52); mobileHit.BackgroundTransparency=.08; mobileHit.Text="SMASH!"; mobileHit.TextColor3=Color3.new(1,1,1); mobileHit.Font=Enum.Font.GothamBlack; mobileHit.TextScaled=true; mobileHit.Visible=UserInputService.TouchEnabled; mobileHit.Parent=gui; corner(mobileHit,60); stroke(mobileHit,3)

local latestState
local lastSwing=0
local function targetUnderPointer()
	local target=mouse.Target
	if target and (target:GetAttribute("Breakable") or target:GetAttribute("Training")) then return target end
	return nil
end
local function swing()
	if shop.Visible then return end
	local now=os.clock(); if now-lastSwing<.3 then return end; lastSwing=now
	local target=targetUnderPointer()
	if not target then return end
	-- timing cycles around a sweet spot, giving active players occasional Perfect Smashes.
	local phase=((now*2.15)%1)-.5
	action:FireServer("Hit",target,phase)
end
mouse.Button1Down:Connect(swing)
mobileHit.Activated:Connect(swing)

local function popup(message,color)
	local l=text(gui,UDim2.new(.5,-190,.25,0),UDim2.fromOffset(380,65),message,Enum.Font.GothamBlack); l.TextColor3=color or Color3.new(1,1,1); l.TextTransparency=0; l.AnchorPoint=Vector2.new(0,.5)
	TweenService:Create(l,TweenInfo.new(.65,Enum.EasingStyle.Back),{Position=UDim2.new(.5,-190,.19,0),TextTransparency=1}):Play(); task.delay(.7,function() l:Destroy() end)
end

stateEvent.OnClientEvent:Connect(function(kind,data)
	if kind=="State" and data then
		latestState=data; strength.Text="💪 STRENGTH  "..NumberUtil.format(data.Strength); coins.Text="🪙 COINS  "..NumberUtil.format(data.Coins); toolText.Text="🔨 "..string.upper(data.ToolName); current.Text="CURRENT: "..string.upper(data.ToolName).."  •  DMG "..NumberUtil.format(data.Damage)
		if data.NextTool then nextLabel.Text="NEXT: "..string.upper(data.NextTool.Name).."\nDMG "..NumberUtil.format(data.NextTool.Damage).."  •  "..NumberUtil.format(data.NextTool.Price).." COINS"; buy.Text="BUY  •  "..NumberUtil.format(data.NextTool.Price).." COINS"; buy.Visible=true else nextLabel.Text="MAX TOOL EQUIPPED"; buy.Visible=false end
	elseif kind=="Shop" then shop.Visible=data
	elseif kind=="Train" then popup("+"..NumberUtil.format(data).." STRENGTH",Color3.fromRGB(255,224,92))
	elseif kind=="Hit" and data then
		local prefix=data.Perfect and "PERFECT! " or data.Crit and "CRIT! " or ""; popup(prefix..NumberUtil.format(data.Damage).." DMG",data.Perfect and Color3.fromRGB(90,231,255) or data.Crit and Color3.fromRGB(255,101,78) or Color3.new(1,1,1))
	end
end)
notice.OnClientEvent:Connect(function(message) popup(message,Color3.fromRGB(255,220,75)) end)

-- keyboard escape closes modal
UserInputService.InputBegan:Connect(function(input,gp) if not gp and input.KeyCode==Enum.KeyCode.Escape and shop.Visible then shop.Visible=false end end)
