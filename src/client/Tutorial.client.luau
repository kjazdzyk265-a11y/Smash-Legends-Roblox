local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local state=ReplicatedStorage:WaitForChild("SmashNet"):WaitForChild("State")

local gui=player:WaitForChild("PlayerGui"):WaitForChild("SmashHUD")
local banner=Instance.new("Frame")
banner.Name="TutorialBanner"; banner.AnchorPoint=Vector2.new(.5,0); banner.Position=UDim2.new(.5,0,0,88); banner.Size=UDim2.fromOffset(520,62); banner.BackgroundColor3=Color3.fromRGB(36,41,54); banner.BackgroundTransparency=.05; banner.Parent=gui
local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,15); corner.Parent=banner
local stroke=Instance.new("UIStroke"); stroke.Thickness=2; stroke.Transparency=.3; stroke.Parent=banner
local label=Instance.new("TextLabel"); label.Size=UDim2.new(1,-24,1,-12); label.Position=UDim2.fromOffset(12,6); label.BackgroundTransparency=1; label.TextColor3=Color3.fromRGB(255,225,105); label.TextStrokeTransparency=.45; label.Font=Enum.Font.GothamBlack; label.TextScaled=true; label.Parent=banner

local core={Coins=0,Strength=1,Tool=1}
local meta={Hatches=0,Zone=1}
local finished=false
local function update()
	if finished then return end
	local text
	if (core.Strength or 1)<20 then text="1/5  HIT THE TRAINING ANVIL • REACH 20 STRENGTH"
	elseif (core.Coins or 0)<120 then text="2/5  SMASH CRATES & BARRELS • EARN 120 COINS"
	elseif (core.Tool or 1)<2 then text="3/5  VISIT THE BLACKSMITH • BUY STONE MALLET"
	elseif (meta.Hatches or 0)<1 then text="4/5  OPEN THE GREENYARD EGG • HATCH YOUR FIRST PET"
	elseif (meta.Zone or 1)<2 then text="5/5  BREAK THE GIANT GATE • REACH CONSTRUCTION CITY"
	else
		finished=true; label.Text="TUTORIAL COMPLETE • KEEP SMASHING FORWARD!"
		TweenService:Create(banner,TweenInfo.new(.35),{Size=UDim2.fromOffset(560,68)}):Play()
		task.delay(4,function() if banner then TweenService:Create(banner,TweenInfo.new(.4),{Position=UDim2.new(.5,0,0,-90),BackgroundTransparency=1}):Play() end end)
		return
	end
	if label.Text~=text then label.Text=text; banner.Size=UDim2.fromOffset(500,56); TweenService:Create(banner,TweenInfo.new(.22,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(520,62)}):Play() end
end
state.OnClientEvent:Connect(function(kind,payload)
	if kind=="State" and payload then core=payload; update()
	elseif kind=="Progression" and payload then meta=payload; update() end
end)
update()
