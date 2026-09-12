local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")

local player=Players.LocalPlayer
local gui=player:WaitForChild("PlayerGui"):WaitForChild("SmashHUD")
local net=ReplicatedStorage:WaitForChild("SmashNet")
local notice=net:WaitForChild("Notice")
local state=net:WaitForChild("State")

local combo=0
local expiresAt=0
local best=0

local frame=Instance.new("Frame")
frame.Name="ComboFrame"
frame.AnchorPoint=Vector2.new(.5,0)
frame.Position=UDim2.new(.5,0,0,86)
frame.Size=UDim2.fromOffset(250,74)
frame.BackgroundColor3=Color3.fromRGB(34,38,49)
frame.BackgroundTransparency=.12
frame.Visible=false
frame.Parent=gui
local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,15); c.Parent=frame
local s=Instance.new("UIStroke"); s.Thickness=2; s.Transparency=.25; s.Parent=frame
local label=Instance.new("TextLabel")
label.Size=UDim2.fromScale(1,1)
label.BackgroundTransparency=1
label.Font=Enum.Font.GothamBlack
label.TextScaled=true
label.TextColor3=Color3.fromRGB(255,208,72)
label.TextStrokeTransparency=.35
label.Text="COMBO x2"
label.Parent=frame

local function setCombo(value)
	combo=value
	best=math.max(best,combo)
	if combo<2 then frame.Visible=false return end
	frame.Visible=true
	label.Text="COMBO x"..combo.."\nKEEP SMASHING!"
	frame.Size=UDim2.fromOffset(210,58)
	TweenService:Create(frame,TweenInfo.new(.18,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(250,74)}):Play()
end

notice.OnClientEvent:Connect(function(message)
	if type(message)~="string" then return end
	if string.find(message,"SMASHED!",1,true) or string.find(message,"ZONE ",1,true) then
		if os.clock()<=expiresAt then setCombo(math.min(combo+1,25)) else setCombo(1) end
		expiresAt=os.clock()+3.25
	end
end)

state.OnClientEvent:Connect(function(kind)
	if kind=="RebirthCoreReset" then combo=0; best=0; frame.Visible=false end
end)

task.spawn(function()
	while gui.Parent do
		task.wait(.1)
		if combo>0 and os.clock()>expiresAt then
			combo=0
			frame.Visible=false
		end
	end
end)
