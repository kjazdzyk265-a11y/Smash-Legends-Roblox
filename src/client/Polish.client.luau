local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local net=ReplicatedStorage:WaitForChild("SmashNet")
local state=net:WaitForChild("State")
local action=net:WaitForChild("Action")

local folder=Instance.new("Folder"); folder.Name="LocalPetVisuals"; folder.Parent=workspace
local visuals={}
local progression
local rarityColors={Common=Color3.fromRGB(210,210,210),Rare=Color3.fromRGB(82,160,255),Epic=Color3.fromRGB(191,89,255),Legendary=Color3.fromRGB(255,190,50),Secret=Color3.fromRGB(255,80,150)}

local function makePart(parent,name,size,cf,color,material,shape)
	local p=Instance.new("Part")
	p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color; p.Material=material or Enum.Material.SmoothPlastic; p.Shape=shape or Enum.PartType.Block
	p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.CastShadow=false; p.Parent=parent
	return p
end

local function styleForPet(name)
	name=string.lower(name or "")
	if string.find(name,"dragon") then return "Dragon" end
	if string.find(name,"golem") or string.find(name,"bot") then return "Golem" end
	if string.find(name,"bat") then return "Bat" end
	if string.find(name,"eye") or string.find(name,"star") then return "Orb" end
	if string.find(name,"slime") then return "Slime" end
	if string.find(name,"phoenix") or string.find(name,"bee") then return "Winged" end
	return "Critter"
end

local function buildPet(pet,slot)
	local model=Instance.new("Model"); model.Name=pet.Name; model.Parent=folder
	local base=rarityColors[pet.Rarity] or Color3.new(1,1,1)
	if (pet.Tier or "Normal")=="Shiny" then base=base:Lerp(Color3.fromRGB(255,255,255),.34) end
	if (pet.Tier or "Normal")=="Rainbow" then base=Color3.fromHSV((slot*.21)%1,.7,1) end
	local style=styleForPet(pet.Name)
	local root=makePart(model,"Root",Vector3.new(2.9,2.5,2.6),CFrame.new(),base,Enum.Material.SmoothPlastic,style=="Slime" and Enum.PartType.Ball or Enum.PartType.Block)
	model.PrimaryPart=root
	local accent=base:Lerp(Color3.new(1,1,1),.38)
	if style=="Critter" then
		makePart(model,"EarL",Vector3.new(.65,1.3,.55),CFrame.new(-.78,1.55,0),accent)
		makePart(model,"EarR",Vector3.new(.65,1.3,.55),CFrame.new(.78,1.55,0),accent)
		makePart(model,"Muzzle",Vector3.new(1.3,.75,.5),CFrame.new(0,-.2,-1.48),accent)
	elseif style=="Dragon" then
		makePart(model,"HornL",Vector3.new(.42,1.3,.42),CFrame.new(-.72,1.45,.05)*CFrame.Angles(0,0,math.rad(-24)),accent,Enum.Material.Neon)
		makePart(model,"HornR",Vector3.new(.42,1.3,.42),CFrame.new(.72,1.45,.05)*CFrame.Angles(0,0,math.rad(24)),accent,Enum.Material.Neon)
		makePart(model,"WingL",Vector3.new(1.6,.25,1.4),CFrame.new(-1.9,.2,.35)*CFrame.Angles(0,0,math.rad(-28)),base,Enum.Material.Neon)
		makePart(model,"WingR",Vector3.new(1.6,.25,1.4),CFrame.new(1.9,.2,.35)*CFrame.Angles(0,0,math.rad(28)),base,Enum.Material.Neon)
	elseif style=="Golem" then
		makePart(model,"ShoulderL",Vector3.new(1.25,1.25,1.25),CFrame.new(-1.75,.2,0),base:Lerp(Color3.new(0,0,0),.18),Enum.Material.Metal)
		makePart(model,"ShoulderR",Vector3.new(1.25,1.25,1.25),CFrame.new(1.75,.2,0),base:Lerp(Color3.new(0,0,0),.18),Enum.Material.Metal)
		makePart(model,"Core",Vector3.new(.85,.85,.35),CFrame.new(0,0,-1.48),accent,Enum.Material.Neon)
	elseif style=="Bat" or style=="Winged" then
		makePart(model,"WingL",Vector3.new(1.8,.25,1.45),CFrame.new(-1.8,.05,.25)*CFrame.Angles(0,0,math.rad(-26)),accent,Enum.Material.Neon)
		makePart(model,"WingR",Vector3.new(1.8,.25,1.45),CFrame.new(1.8,.05,.25)*CFrame.Angles(0,0,math.rad(26)),accent,Enum.Material.Neon)
	elseif style=="Orb" then
		root.Shape=Enum.PartType.Ball; root.Material=Enum.Material.Neon
		local ring=makePart(model,"Ring",Vector3.new(3.6,.24,3.6),CFrame.new(),accent,Enum.Material.Neon,Enum.PartType.Cylinder)
		ring.CFrame=CFrame.Angles(0,0,math.rad(90))
	end
	local eyeColor=Color3.fromRGB(25,27,35)
	makePart(model,"EyeL",Vector3.new(.42,.58,.18),CFrame.new(-.58,.34,-1.38),eyeColor,Enum.Material.Neon)
	makePart(model,"EyeR",Vector3.new(.42,.58,.18),CFrame.new(.58,.34,-1.38),eyeColor,Enum.Material.Neon)
	local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromOffset(150,40); gui.StudsOffset=Vector3.new(0,2.45,0); gui.AlwaysOnTop=true; gui.MaxDistance=75; gui.Parent=root
	local l=Instance.new("TextLabel"); l.Size=UDim2.fromScale(1,1); l.BackgroundTransparency=1; l.Text=((pet.Tier and pet.Tier~="Normal") and (pet.Tier.." ") or "")..pet.Name; l.TextColor3=base; l.TextStrokeTransparency=.18; l.Font=Enum.Font.GothamBlack; l.TextScaled=true; l.Parent=gui
	local light=Instance.new("PointLight"); light.Color=base; light.Range=9; light.Brightness=pet.Rarity=="Legendary" and 1.2 or pet.Rarity=="Secret" and 1.8 or .45; light.Parent=root
	return model
end

local function clear() for _,v in ipairs(visuals) do if v.Model then v.Model:Destroy() end end; visuals={} end
local function rebuild()
	clear(); if not progression then return end
	for slot,index in ipairs(progression.Equipped or {}) do
		local pet=progression.Pets[index]
		if pet then table.insert(visuals,{Model=buildPet(pet,slot),Slot=slot,Pet=pet}) end
	end
end
state.OnClientEvent:Connect(function(kind,payload)
	if kind=="Progression" then progression=payload; rebuild()
	elseif kind=="HatchRequest" then action:FireServer("ConfirmHatch",payload.Egg)
	elseif kind=="HatchResult" then
		local pg=player.PlayerGui:FindFirstChild("SmashHUD"); if pg then
			local l=Instance.new("TextLabel"); l.AnchorPoint=Vector2.new(.5,.5); l.Position=UDim2.fromScale(.5,.45); l.Size=UDim2.fromOffset(460,120); l.BackgroundColor3=Color3.fromRGB(34,38,52); l.BackgroundTransparency=.08; l.Text="YOU HATCHED\n"..string.upper(payload.Name).." • "..string.upper(payload.Rarity); l.TextColor3=rarityColors[payload.Rarity] or Color3.new(1,1,1); l.TextStrokeTransparency=.3; l.Font=Enum.Font.GothamBlack; l.TextScaled=true; l.Parent=pg
			local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,18); c.Parent=l
			local s=Instance.new("UIStroke"); s.Thickness=3; s.Transparency=.25; s.Color=l.TextColor3; s.Parent=l
			l.Size=UDim2.fromOffset(100,40); TweenService:Create(l,TweenInfo.new(.35,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(460,120)}):Play(); task.delay(2,function() if l then l:Destroy() end end)
		end
	end
end)

RunService.RenderStepped:Connect(function()
	local char=player.Character; local root=char and char:FindFirstChild("HumanoidRootPart"); if not root then return end
	for i,v in ipairs(visuals) do
		local model=v.Model; if model and model.PrimaryPart then
			local side=(i-2)*3.5; local bob=math.sin(os.clock()*3+i)*.38
			local goal=root.CFrame*CFrame.new(side,1.35+bob,5.1+math.abs(i-2)*.8)*CFrame.Angles(0,math.rad(180),0)
			local current=model:GetPivot(); model:PivotTo(current:Lerp(goal,.14))
		end
	end
end)
