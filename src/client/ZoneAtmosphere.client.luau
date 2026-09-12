local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local gui=player:WaitForChild("PlayerGui"):WaitForChild("SmashHUD")

local zones={
	{Name="GREENYARD",Min=0,Max=230,Color=Color3.fromRGB(255,216,78),Tint=Color3.fromRGB(255,250,238),Fog=Color3.fromRGB(210,230,205)},
	{Name="CONSTRUCTION CITY",Min=230,Max=475,Color=Color3.fromRGB(255,151,55),Tint=Color3.fromRGB(255,241,225),Fog=Color3.fromRGB(183,190,196)},
	{Name="CRYSTAL CAVES",Min=475,Max=710,Color=Color3.fromRGB(82,225,255),Tint=Color3.fromRGB(222,241,255),Fog=Color3.fromRGB(78,87,125)},
	{Name="MAGMA FORGE",Min=710,Max=945,Color=Color3.fromRGB(255,93,43),Tint=Color3.fromRGB(255,224,207),Fog=Color3.fromRGB(108,71,62)},
	{Name="VOID TEMPLE",Min=945,Max=1300,Color=Color3.fromRGB(185,82,255),Tint=Color3.fromRGB(230,214,255),Fog=Color3.fromRGB(57,46,83)},
}

local cc=Lighting:FindFirstChild("ClientZoneColor") or Instance.new("ColorCorrectionEffect")
cc.Name="ClientZoneColor"
cc.Parent=Lighting

local banner=Instance.new("Frame")
banner.Name="ZoneBanner"
banner.AnchorPoint=Vector2.new(.5,0)
banner.Position=UDim2.new(.5,0,-.2,0)
banner.Size=UDim2.fromOffset(500,84)
banner.BackgroundColor3=Color3.fromRGB(29,32,42)
banner.BackgroundTransparency=.08
banner.Parent=gui
local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,18); corner.Parent=banner
local stroke=Instance.new("UIStroke"); stroke.Thickness=2; stroke.Transparency=.25; stroke.Parent=banner
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-24,1,-18)
title.Position=UDim2.fromOffset(12,9)
title.BackgroundTransparency=1
title.Font=Enum.Font.GothamBlack
title.TextScaled=true
title.TextStrokeTransparency=.35
title.Text=""
title.Parent=banner

local current=nil
local transitionToken=0
local function showZone(zone)
	transitionToken+=1
	local token=transitionToken
	title.Text=zone.Name
	title.TextColor3=zone.Color
	stroke.Color=zone.Color
	banner.Position=UDim2.new(.5,0,-.2,0)
	TweenService:Create(banner,TweenInfo.new(.45,Enum.EasingStyle.Back),{Position=UDim2.new(.5,0,.09,0)}):Play()
	task.delay(2.2,function()
		if token~=transitionToken then return end
		TweenService:Create(banner,TweenInfo.new(.4,Enum.EasingStyle.Quad),{Position=UDim2.new(.5,0,-.2,0)}):Play()
	end)
	TweenService:Create(cc,TweenInfo.new(1),{TintColor=zone.Tint,Saturation=.08,Contrast=.05}):Play()
	TweenService:Create(Lighting,TweenInfo.new(1),{FogColor=zone.Fog,FogStart=130,FogEnd=420}):Play()
end

local elapsed=0
RunService.RenderStepped:Connect(function(dt)
	elapsed+=dt
	if elapsed<.25 then return end
	elapsed=0
	local char=player.Character
	local root=char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local z=root.Position.Z
	for _,zone in ipairs(zones) do
		if z>=zone.Min and z<zone.Max then
			if current~=zone.Name then current=zone.Name; showZone(zone) end
			break
		end
	end
end)
