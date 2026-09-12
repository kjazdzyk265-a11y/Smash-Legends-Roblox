local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Pets = require(Shared:WaitForChild("Pets"))

local net = ReplicatedStorage:FindFirstChild("SmashNet") or Instance.new("Folder")
net.Name = "SmashNet"
net.Parent = ReplicatedStorage
local action = net:FindFirstChild("Action") or Instance.new("RemoteEvent")
action.Name = "Action"
action.Parent = net
local stateEvent = net:FindFirstChild("State") or Instance.new("RemoteEvent")
stateEvent.Name = "State"
stateEvent.Parent = net
local notice = net:FindFirstChild("Notice") or Instance.new("RemoteEvent")
notice.Name = "Notice"
notice.Parent = net

local profiles = {}
local hitCooldown = {}
local breakableState = {}

local function newPart(parent, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Anchored = true
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local world = workspace:FindFirstChild("SmashWorld")
if world then world:Destroy() end
world = Instance.new("Folder")
world.Name = "SmashWorld"
world.Parent = workspace

workspace.FallenPartsDestroyHeight = -100
local Lighting = game:GetService("Lighting")
Lighting.Brightness = 2.4
Lighting.ClockTime = 14.2
Lighting.EnvironmentDiffuseScale = 0.55
Lighting.EnvironmentSpecularScale = 0.45
Lighting.Ambient = Color3.fromRGB(115, 125, 145)
Lighting.OutdoorAmbient = Color3.fromRGB(145, 155, 175)
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Density = 0.18
atmosphere.Haze = 1.1
atmosphere.Color = Color3.fromRGB(205, 225, 255)
atmosphere.Decay = Color3.fromRGB(110, 135, 180)
atmosphere.Parent = Lighting

local zoneSpecs = {
	{Name="GREENYARD", z=0, length=230, ground=Color3.fromRGB(89,190,83), path=Color3.fromRGB(222,203,153), accent=Color3.fromRGB(255,208,71), object="Crate"},
	{Name="CONSTRUCTION CITY", z=230, length=245, ground=Color3.fromRGB(93,105,116), path=Color3.fromRGB(185,181,165), accent=Color3.fromRGB(255,151,47), object="Safe"},
	{Name="CRYSTAL CAVES", z=475, length=235, ground=Color3.fromRGB(61,70,96), path=Color3.fromRGB(100,100,130), accent=Color3.fromRGB(78,226,255), object="Crystal"},
	{Name="MAGMA FORGE", z=710, length=235, ground=Color3.fromRGB(69,54,52), path=Color3.fromRGB(92,76,70), accent=Color3.fromRGB(255,91,44), object="Rock"},
	{Name="VOID TEMPLE", z=945, length=250, ground=Color3.fromRGB(43,38,65), path=Color3.fromRGB(72,64,94), accent=Color3.fromRGB(180,80,255), object="Crystal"},
}

local function billboard(parent, text, color, offset, size)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = size or UDim2.fromOffset(250, 70)
	gui.StudsOffset = offset or Vector3.new(0, 7, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 180
	gui.Parent = parent
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1,1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or Color3.new(1,1,1)
	label.TextStrokeTransparency = 0.25
	label.TextStrokeColor3 = Color3.fromRGB(25,25,35)
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.Parent = gui
	return label
end

local function makeTree(parent, pos, scale)
	scale = scale or 1
	newPart(parent,"TreeTrunk",Vector3.new(3,11,3)*scale,CFrame.new(pos+Vector3.new(0,5.5*scale,0)),Color3.fromRGB(116,76,45),Enum.Material.Wood)
	local crown = newPart(parent,"TreeCrown",Vector3.new(10,10,10)*scale,CFrame.new(pos+Vector3.new(0,13*scale,0)),Color3.fromRGB(65,158,73),Enum.Material.Grass)
	crown.Shape = Enum.PartType.Ball
end

local function makeRock(parent, pos, scale, color)
	newPart(parent,"SceneryRock",Vector3.new(7,5,6)*scale,CFrame.new(pos+Vector3.new(0,2.5*scale,0))*CFrame.Angles(0,math.rad(math.random(0,180)),math.rad(math.random(-8,8))),color or Color3.fromRGB(104,110,115),Enum.Material.Slate)
end

local function addHPGui(part, displayName)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Health"
	gui.Size = UDim2.fromOffset(180,48)
	gui.StudsOffset = Vector3.new(0, part.Size.Y/2 + 2.5, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 75
	gui.Parent = part
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1,0,0.5,0)
	title.BackgroundTransparency = 1
	title.Text = displayName
	title.TextColor3 = Color3.new(1,1,1)
	title.TextStrokeTransparency = 0.2
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.Parent = gui
	local back = Instance.new("Frame")
	back.Name = "Back"
	back.Position = UDim2.new(0.05,0,0.58,0)
	back.Size = UDim2.new(0.9,0,0.24,0)
	back.BackgroundColor3 = Color3.fromRGB(35,38,48)
	back.BorderSizePixel = 0
	back.Parent = gui
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(1,1)
	fill.BackgroundColor3 = Color3.fromRGB(91,235,103)
	fill.BorderSizePixel = 0
	fill.Parent = back
	return fill
end

local function registerBreakable(part, kind)
	local cfg = Config.Breakables[kind]
	if not cfg then return end
	part.Name = kind
	part:SetAttribute("Breakable", true)
	part:SetAttribute("Kind", kind)
	part:SetAttribute("MaxHP", cfg.MaxHP)
	part:SetAttribute("HP", cfg.MaxHP)
	part:SetAttribute("Reward", cfg.Reward)
	local fill = addHPGui(part, string.upper(kind))
	breakableState[part] = {hp=cfg.MaxHP, max=cfg.MaxHP, fill=fill, active=true, original=part.CFrame, originalSize=part.Size, transparency=part.Transparency}
end

local function makeBreakable(parent, kind, pos, scale)
	scale = scale or 1
	local size, color, material = Vector3.new(7,7,7), Color3.fromRGB(151,102,61), Enum.Material.WoodPlanks
	if kind == "Barrel" then size=Vector3.new(5,7,5); color=Color3.fromRGB(132,83,48); material=Enum.Material.Wood
	elseif kind == "Fence" then size=Vector3.new(12,5,2); color=Color3.fromRGB(174,119,65); material=Enum.Material.WoodPlanks
	elseif kind == "Rock" then size=Vector3.new(9,7,8); color=Color3.fromRGB(114,121,127); material=Enum.Material.Slate
	elseif kind == "Safe" then size=Vector3.new(8,8,7); color=Color3.fromRGB(69,83,94); material=Enum.Material.Metal
	elseif kind == "Crystal" then size=Vector3.new(7,12,7); color=Color3.fromRGB(79,224,255); material=Enum.Material.Neon
	elseif kind == "Gate" then size=Vector3.new(58,18,7); color=Color3.fromRGB(120,106,88); material=Enum.Material.Slate end
	local p = newPart(parent,kind,size*scale,CFrame.new(pos+Vector3.new(0,size.Y*scale/2,0)),color,material)
	if kind == "Crystal" then p.CFrame *= CFrame.Angles(0,0,math.rad(12)) end
	registerBreakable(p,kind)
	return p
end

local function buildWorld()
	local map = Instance.new("Folder"); map.Name="Map"; map.Parent=world
	for zi,z in ipairs(zoneSpecs) do
		local zone = Instance.new("Folder"); zone.Name=z.Name; zone.Parent=map
		newPart(zone,"Ground",Vector3.new(150,2,z.length),CFrame.new(0,-1,z.z+z.length/2),z.ground,zi==1 and Enum.Material.Grass or Enum.Material.Slate)
		newPart(zone,"MainPath",Vector3.new(28,0.35,z.length-12),CFrame.new(0,0.18,z.z+z.length/2),z.path,Enum.Material.Sand)
		local sign = newPart(zone,"ZoneSign",Vector3.new(26,8,2),CFrame.new(0,7,z.z+12),Color3.fromRGB(43,49,59),Enum.Material.Wood)
		billboard(sign,z.Name,z.accent,Vector3.new(0,0,0),UDim2.fromOffset(300,70))
		for i=1,7 do
			local side = i%2==0 and -1 or 1
			local zz = z.z+34+i*23
			local xx = side*(20+((i*7)%24))
			local kind = z.object
			if zi==1 then kind=({"Crate","Barrel","Fence","Rock","Crate","Barrel","Rock"})[i] end
			makeBreakable(zone,kind,Vector3.new(xx,0,zz),1 + (zi-1)*0.06)
		end
		for i=1,8 do
			local zz=z.z+20+i*24
			if zi==1 then
				makeTree(zone,Vector3.new(-58,0,zz),0.8+((i%3)*0.12)); makeTree(zone,Vector3.new(58,0,zz+8),0.75)
			elseif zi==2 then
				newPart(zone,"Building",Vector3.new(25,18+(i%3)*7,22),CFrame.new((i%2==0 and -56 or 56),9,zz),Color3.fromRGB(116+(i%2)*20,126,132),Enum.Material.Concrete)
			elseif zi==3 then
				makeRock(zone,Vector3.new(-60,0,zz),1.3,Color3.fromRGB(64,74,99)); makeRock(zone,Vector3.new(60,0,zz+7),1.5,Color3.fromRGB(64,74,99))
			elseif zi==4 then
				makeRock(zone,Vector3.new(i%2==0 and -58 or 58,0,zz),1.4,Color3.fromRGB(80,63,58))
			else
				local pillar=newPart(zone,"VoidPillar",Vector3.new(7,20,7),CFrame.new(i%2==0 and -55 or 55,10,zz),Color3.fromRGB(72,62,96),Enum.Material.Slate)
				newPart(zone,"Rune",Vector3.new(8,1,8),pillar.CFrame*CFrame.new(0,10.5,0),z.accent,Enum.Material.Neon)
			end
		end
		if zi < #zoneSpecs then
			local gate=makeBreakable(zone,"Gate",Vector3.new(0,0,z.z+z.length-8),1+(zi-1)*0.22)
			gate:SetAttribute("ZoneGate",zi+1)
			billboard(gate,"SMASH TO ENTER\n"..zoneSpecs[zi+1].Name,z.accent,Vector3.new(0,gate.Size.Y/2+4,0),UDim2.fromOffset(340,85))
		end
	end
	local spawn = Instance.new("SpawnLocation")
	spawn.Name="Spawn"; spawn.Size=Vector3.new(16,1,16); spawn.CFrame=CFrame.new(0,1,18); spawn.Anchored=true
	spawn.Color=Color3.fromRGB(255,220,74); spawn.Material=Enum.Material.Neon; spawn.Neutral=true; spawn.Parent=map
	local training = newPart(map,"TrainingAnvil",Vector3.new(12,8,12),CFrame.new(-38,4,30),Color3.fromRGB(75,83,92),Enum.Material.Metal)
	training:SetAttribute("Training",true)
	billboard(training,"TRAIN STRENGTH\n[CLICK / TAP]",Color3.fromRGB(255,220,72),Vector3.new(0,8,0))
	local shop = newPart(map,"Blacksmith",Vector3.new(24,13,18),CFrame.new(38,6.5,31),Color3.fromRGB(91,63,45),Enum.Material.WoodPlanks)
	shop:SetAttribute("ToolShop",true)
	billboard(shop,"BLACKSMITH\nBETTER HAMMERS",Color3.fromRGB(255,158,56),Vector3.new(0,10,0))
	local prompt=Instance.new("ProximityPrompt"); prompt.ActionText="Open Tool Shop"; prompt.ObjectText="Blacksmith"; prompt.MaxActivationDistance=12; prompt.RequiresLineOfSight=false; prompt.Parent=shop
	prompt.Triggered:Connect(function(player) stateEvent:FireClient(player,"Shop",true) end)
end

buildWorld()

local function stateFor(player)
	local p=profiles[player]
	if not p then return nil end
	return {Coins=p.Coins,Strength=p.Strength,Tool=p.Tool,ToolName=Config.Tools[p.Tool].Name,Damage=Config.Tools[p.Tool].Damage,NextTool=Config.Tools[p.Tool+1]}
end
local function sync(player)
	local p=profiles[player]
	if not p then return end
	player:SetAttribute("CoreCoins",p.Coins)
	player:SetAttribute("CoreStrength",p.Strength)
	player:SetAttribute("CoreTool",p.Tool)
	stateEvent:FireClient(player,"State",stateFor(player))
end

local function getCharacterDistance(player, part)
	local char=player.Character
	local root=char and char:FindFirstChild("HumanoidRootPart")
	if not root then return math.huge end
	return (root.Position-part.Position).Magnitude
end

local function impact(part, damage, player, perfect, crit)
	local st=breakableState[part]
	if not st or not st.active then return end
	st.hp=math.max(0,st.hp-damage)
	part:SetAttribute("HP",st.hp)
	if st.fill then TweenService:Create(st.fill,TweenInfo.new(0.1),{Size=UDim2.fromScale(st.hp/st.max,1)}):Play() end
	local old=part.CFrame
	part.CFrame=old*CFrame.Angles(math.rad(math.random(-2,2)),0,math.rad(math.random(-2,2)))
	task.delay(0.08,function() if part.Parent and st.active then part.CFrame=old end end)
	stateEvent:FireClient(player,"Hit",{Damage=damage,Perfect=perfect,Crit=crit,Position=part.Position})
	if st.hp<=0 then
		st.active=false
		local cfg=Config.Breakables[part:GetAttribute("Kind")]
		local petMult=player:GetAttribute("PetMultiplier") or 1
		local reward=math.max(1,math.floor(cfg.Reward*(1+(petMult-1)*0.25)))
		profiles[player].Coins += reward
		profiles[player].Strength += math.max(1,math.floor(reward*0.025))
		local nextZone=part:GetAttribute("ZoneGate")
		if nextZone then
			player:SetAttribute("UnlockedZone",math.max(player:GetAttribute("UnlockedZone") or 1,nextZone))
			stateEvent:FireClient(player,"ZoneUnlocked",nextZone)
			notice:FireClient(player,"ZONE "..nextZone.." UNLOCKED!")
		else notice:FireClient(player,"SMASHED! +"..reward.." COINS") end
		sync(player)
		part.CanCollide=false
		TweenService:Create(part,TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=st.originalSize*0.25,Transparency=1}):Play()
		task.delay(cfg.Respawn,function()
			if not part.Parent then return end
			st.hp=st.max; st.active=true; part:SetAttribute("HP",st.max); part.CFrame=st.original; part.Transparency=st.transparency; part.CanCollide=true; part.Size=st.originalSize
			if st.fill then st.fill.Size=UDim2.fromScale(1,1) end
		end)
	end
end

local function setupPlayer(player)
	if profiles[player] then return end
	profiles[player]={Coins=0,Strength=1,Tool=1}
	player:SetAttribute("UnlockedZone",player:GetAttribute("UnlockedZone") or 1)
	player.CharacterAdded:Connect(function()
		task.wait(1); sync(player); notice:FireClient(player,"TRAIN, THEN SMASH YOUR WAY FORWARD!")
	end)
	if player.Character then task.defer(sync,player) end
end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player) profiles[player]=nil; hitCooldown[player]=nil end)
for _,player in ipairs(Players:GetPlayers()) do setupPlayer(player) end

action.OnServerEvent:Connect(function(player,verb,target,timing)
	local p=profiles[player]; if not p then return end
	local now=os.clock()
	if verb=="Hit" then
		if hitCooldown[player] and now-hitCooldown[player]<0.28 then return end
		if typeof(target)~="Instance" or not target:IsDescendantOf(world) then return end
		if getCharacterDistance(player,target)>18 then return end
		if target:GetAttribute("Training") then
			hitCooldown[player]=now
			local permanent=player:GetAttribute("RebirthMultiplier") or 1
			local gain=math.max(1,math.floor(Config.Training.BaseGain*Config.Tools[p.Tool].Training*permanent))
			p.Strength+=gain; stateEvent:FireClient(player,"Train",gain); sync(player); return
		end
		if not target:GetAttribute("Breakable") then return end
		hitCooldown[player]=now
		local tool=Config.Tools[p.Tool]
		local petMult=player:GetAttribute("PetMultiplier") or 1
		local permanent=player:GetAttribute("RebirthMultiplier") or 1
		local base=tool.Damage*(1+math.sqrt(p.Strength)*0.055)*petMult*permanent
		local perfect=typeof(timing)=="number" and math.abs(timing)<=Config.PerfectWindow
		local crit=math.random()<Config.CritChance
		local damage=base*(perfect and Config.PerfectMultiplier or 1)*(crit and Config.CritMultiplier or 1)
		impact(target,math.max(1,math.floor(damage)),player,perfect,crit)
	elseif verb=="BuyTool" then
		local nextIndex=p.Tool+1; local nextTool=Config.Tools[nextIndex]; if not nextTool then return end
		if p.Coins>=nextTool.Price then p.Coins-=nextTool.Price; p.Tool=nextIndex; notice:FireClient(player,"EQUIPPED "..string.upper(nextTool.Name).."!"); sync(player)
		else notice:FireClient(player,"NOT ENOUGH COINS") end
	elseif verb=="Hatch" and type(target)=="string" then
		local egg=Pets.Eggs[target]
		local unlocked=player:GetAttribute("UnlockedZone") or 1
		if not egg or unlocked<egg.Zone then return end
		if p.Coins<egg.Price then notice:FireClient(player,"NOT ENOUGH COINS FOR THIS EGG") return end
		p.Coins-=egg.Price
		local creditName="HatchCredit_"..target
		player:SetAttribute(creditName,(player:GetAttribute(creditName) or 0)+1)
		sync(player)
	elseif verb=="Rebirth" then
		if p.Strength>=25000 then
			task.delay(.35,function()
				if not profiles[player] then return end
				p.Coins=0; p.Strength=1; p.Tool=1; sync(player)
				stateEvent:FireClient(player,"RebirthCoreReset",true)
			end)
		end
	end
end)

print("[Smash Legends] integrated V1 core world ready")
