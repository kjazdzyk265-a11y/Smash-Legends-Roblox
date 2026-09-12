local Lighting=game:GetService("Lighting")
local TweenService=game:GetService("TweenService")

local world=workspace:WaitForChild("SmashWorld")
local map=world:WaitForChild("Map")

local old=world:FindFirstChild("WorldOverhaul")
if old then old:Destroy() end
local root=Instance.new("Folder")
root.Name="WorldOverhaul"
root.Parent=world

local function part(parent,name,size,cf,color,material,shape)
	local p=Instance.new("Part")
	p.Name=name
	p.Size=size
	p.CFrame=cf
	p.Anchored=true
	p.CanCollide=true
	p.TopSurface=Enum.SurfaceType.Smooth
	p.BottomSurface=Enum.SurfaceType.Smooth
	p.Color=color
	p.Material=material or Enum.Material.SmoothPlastic
	if shape then p.Shape=shape end
	p.Parent=parent
	return p
end

local function noCollide(p)
	p.CanCollide=false
	p.CanTouch=false
	p.CanQuery=false
	return p
end

local function neon(parent,name,size,cf,color)
	return part(parent,name,size,cf,color,Enum.Material.Neon)
end

local function beam(parent,a,b,width,color,material)
	local delta=b-a
	local len=delta.Magnitude
	local mid=(a+b)/2
	local p=part(parent,"Beam",Vector3.new(width,width,len),CFrame.lookAt(mid,b),color,material or Enum.Material.Metal)
	return p
end

local function ball(parent,name,pos,size,color,material)
	return part(parent,name,Vector3.new(size,size,size),CFrame.new(pos),color,material or Enum.Material.SmoothPlastic,Enum.PartType.Ball)
end

local function cylinder(parent,name,size,cf,color,material)
	local p=part(parent,name,size,cf,color,material or Enum.Material.Metal,Enum.PartType.Cylinder)
	return p
end

local function billboard(parent,textValue,color,size,offset)
	local gui=Instance.new("BillboardGui")
	gui.Name="OverhaulLabel"
	gui.Size=size or UDim2.fromOffset(280,75)
	gui.StudsOffset=offset or Vector3.new(0,6,0)
	gui.AlwaysOnTop=true
	gui.MaxDistance=220
	gui.Parent=parent
	local text=Instance.new("TextLabel")
	text.Size=UDim2.fromScale(1,1)
	text.BackgroundTransparency=1
	text.Text=textValue
	text.TextColor3=color or Color3.new(1,1,1)
	text.TextStrokeColor3=Color3.fromRGB(20,20,28)
	text.TextStrokeTransparency=.15
	text.Font=Enum.Font.GothamBlack
	text.TextScaled=true
	text.TextWrapped=true
	text.Parent=gui
	return text
end

local function arch(parent,z,color,width,height)
	local x=width/2
	part(parent,"ArchLeft",Vector3.new(5,height,5),CFrame.new(-x,height/2,z),color,Enum.Material.Slate)
	part(parent,"ArchRight",Vector3.new(5,height,5),CFrame.new(x,height/2,z),color,Enum.Material.Slate)
	part(parent,"ArchTop",Vector3.new(width+5,5,5),CFrame.new(0,height,z),color,Enum.Material.Slate)
end

local function lamp(parent,pos,color)
	part(parent,"LampPost",Vector3.new(.9,9,.9),CFrame.new(pos+Vector3.new(0,4.5,0)),Color3.fromRGB(47,52,60),Enum.Material.Metal)
	local lightPart=ball(parent,"Lamp",pos+Vector3.new(0,9.3,0),1.8,color,Enum.Material.Neon)
	local light=Instance.new("PointLight")
	light.Color=color
	light.Brightness=1.6
	light.Range=20
	light.Shadows=true
	light.Parent=lightPart
end

local function rockCluster(parent,center,color,scale)
	scale=scale or 1
	for i=1,5 do
		local angle=(i/5)*math.pi*2
		local r=5+(i%2)*3
		local pos=center+Vector3.new(math.cos(angle)*r,1.5+(i%3),math.sin(angle)*r)
		local s=Vector3.new(5+(i%3)*2,4+(i%2)*3,5+((i+1)%3))*scale
		local p=part(parent,"Rock",s,CFrame.new(pos)*CFrame.Angles(math.rad(i*7),math.rad(i*31),math.rad(i*9)),color,Enum.Material.Slate)
		p.Shape=Enum.PartType.Block
	end
end

local function tree(parent,pos,scale,leafColor)
	scale=scale or 1
	part(parent,"Trunk",Vector3.new(2.4,10,2.4)*scale,CFrame.new(pos+Vector3.new(0,5*scale,0)),Color3.fromRGB(103,66,42),Enum.Material.Wood)
	for i=1,3 do
		local offset=Vector3.new((i-2)*2.7*scale,(9+i*1.8)*scale,((i%2)*2-1)*1.8*scale)
		ball(parent,"Leaf",pos+offset,7*scale,leafColor or Color3.fromRGB(71,164,76),Enum.Material.Grass)
	end
end

local function fenceLine(parent,x,zStart,zEnd,color)
	for z=zStart,zEnd,14 do
		part(parent,"FencePost",Vector3.new(1,5,1),CFrame.new(x,2.5,z),color,Enum.Material.Wood)
		part(parent,"FenceRail",Vector3.new(1,1,14),CFrame.new(x,3.6,z+6.5),color,Enum.Material.WoodPlanks)
		part(parent,"FenceRail",Vector3.new(1,1,14),CFrame.new(x,1.8,z+6.5),color,Enum.Material.WoodPlanks)
	end
end

local function crystalCluster(parent,pos,color,scale)
	scale=scale or 1
	for i=1,5 do
		local a=(i/5)*math.pi*2
		local h=(6+i*1.6)*scale
		local x=math.cos(a)*(2.2+i*.35)*scale
		local z=math.sin(a)*(2.2+i*.35)*scale
		local p=part(parent,"CrystalShard",Vector3.new(2.2*scale,h,2.2*scale),CFrame.new(pos+Vector3.new(x,h/2,z))*CFrame.Angles(math.rad((i-3)*5),0,math.rad((i-3)*8)),color,Enum.Material.Neon)
		p.CanCollide=false
	end
end

local function building(parent,pos,size,body,accent)
	local base=part(parent,"Building",size,CFrame.new(pos+Vector3.new(0,size.Y/2,0)),body,Enum.Material.Concrete)
	part(parent,"Roof",Vector3.new(size.X+2,1,size.Z+2),base.CFrame*CFrame.new(0,size.Y/2+.5,0),Color3.fromRGB(50,55,62),Enum.Material.Metal)
	for floor=1,math.max(1,math.floor(size.Y/8)) do
		for side=-1,1,2 do
			local w=noCollide(neon(parent,"Window",Vector3.new(3,2.5,.25),CFrame.new(pos.X+side*size.X/2,pos.Y+floor*6,pos.Z),accent))
			w.Transparency=.08
		end
	end
end

local function zoneTitle(parent,z,title,subtitle,color)
	local pedestal=part(parent,"ZoneMonument",Vector3.new(24,2,10),CFrame.new(0,1,z),Color3.fromRGB(45,49,59),Enum.Material.Slate)
	local sign=part(parent,"ZoneTitle",Vector3.new(18,8,2),CFrame.new(0,7,z),Color3.fromRGB(32,35,44),Enum.Material.Metal)
	billboard(sign,title.."\n"..subtitle,color,UDim2.fromOffset(360,95),Vector3.new(0,0,0))
	return pedestal
end

-- Lighting pass
Lighting.Brightness=2.8
Lighting.ClockTime=14.6
Lighting.EnvironmentDiffuseScale=.7
Lighting.EnvironmentSpecularScale=.65
Lighting.Ambient=Color3.fromRGB(105,113,130)
Lighting.OutdoorAmbient=Color3.fromRGB(150,158,178)
local cc=Lighting:FindFirstChild("SmashColor") or Instance.new("ColorCorrectionEffect")
cc.Name="SmashColor"
cc.Brightness=.03
cc.Contrast=.09
cc.Saturation=.12
cc.TintColor=Color3.fromRGB(255,248,242)
cc.Parent=Lighting
local bloom=Lighting:FindFirstChild("SmashBloom") or Instance.new("BloomEffect")
bloom.Name="SmashBloom"
bloom.Intensity=.45
bloom.Size=28
bloom.Threshold=1.7
bloom.Parent=Lighting
local sun=Lighting:FindFirstChild("SmashSun") or Instance.new("SunRaysEffect")
sun.Name="SmashSun"
sun.Intensity=.05
sun.Spread=.65
sun.Parent=Lighting

-- Spawn plaza / hub
local hub=Instance.new("Folder"); hub.Name="SpawnPlaza"; hub.Parent=root
part(hub,"Plaza",Vector3.new(105,1,75),CFrame.new(0,.35,30),Color3.fromRGB(202,191,164),Enum.Material.Cobblestone)
for _,x in ipairs({-46,46}) do for _,z in ipairs({8,30,52}) do lamp(hub,Vector3.new(x,0,z),Color3.fromRGB(255,215,120)) end end
arch(hub,70,Color3.fromRGB(78,84,95),46,20)
zoneTitle(hub,78,"SMASH LEGENDS","THE BREAKING ROAD",Color3.fromRGB(255,211,73))
for x=-40,40,20 do
	local p=part(hub,"BannerPole",Vector3.new(.7,10,.7),CFrame.new(x,5,65),Color3.fromRGB(58,62,70),Enum.Material.Metal)
	local banner=noCollide(part(hub,"Banner",Vector3.new(6,6,.3),p.CFrame*CFrame.new(0,1.5,0),Color3.fromRGB(244,104,52),Enum.Material.Fabric))
end

-- GREENYARD
local green=Instance.new("Folder"); green.Name="GreenyardOverhaul"; green.Parent=root
zoneTitle(green,96,"GREENYARD","BEGINNER SMASH TRAIL",Color3.fromRGB(255,215,69))
fenceLine(green,-68,95,210,Color3.fromRGB(148,95,57)); fenceLine(green,68,95,210,Color3.fromRGB(148,95,57))
for i=1,9 do
	local z=100+i*13
	tree(green,Vector3.new(-52+(i%3)*5,0,z),.72+(i%2)*.12,Color3.fromRGB(68,171,76))
	tree(green,Vector3.new(52-(i%3)*4,0,z+5),.65+(i%3)*.08,Color3.fromRGB(77,181,82))
end
for _,z in ipairs({122,164,202}) do
	part(green,"HayBale",Vector3.new(8,5,5),CFrame.new(-30,2.5,z)*CFrame.Angles(0,math.rad(18),0),Color3.fromRGB(218,176,69),Enum.Material.Fabric)
	cylinder(green,"WaterBarrel",Vector3.new(5,5,5),CFrame.new(32,2.5,z+5)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(111,76,48),Enum.Material.Wood)
end
local windBase=part(green,"WindmillTower",Vector3.new(10,28,10),CFrame.new(-47,14,190),Color3.fromRGB(226,216,186),Enum.Material.Concrete)
local windHub=ball(green,"WindHub",Vector3.new(-47,27,184),3.5,Color3.fromRGB(116,77,50),Enum.Material.Wood)
for a=0,3 do
	local angle=math.rad(a*90)
	local blade=part(green,"WindBlade",Vector3.new(3,22,1),CFrame.new(-47,27,183.7)*CFrame.Angles(0,0,angle)*CFrame.new(0,10,0),Color3.fromRGB(236,227,202),Enum.Material.WoodPlanks)
	blade.CanCollide=false
end

-- CONSTRUCTION CITY
local city=Instance.new("Folder"); city.Name="ConstructionCityOverhaul"; city.Parent=root
zoneTitle(city,250,"CONSTRUCTION CITY","BREAK THROUGH THE BLOCK",Color3.fromRGB(255,147,55))
part(city,"Road",Vector3.new(95,.25,210),CFrame.new(0,.18,350),Color3.fromRGB(48,52,58),Enum.Material.Asphalt)
for z=270,445,35 do
	part(city,"Lane",Vector3.new(1,.08,12),CFrame.new(0,.34,z),Color3.fromRGB(238,203,81),Enum.Material.Neon)
end
for i=1,6 do
	local z=268+i*30
	building(city,Vector3.new(-55,0,z),Vector3.new(28,20+(i%3)*8,24),Color3.fromRGB(104+(i%2)*12,111,118),Color3.fromRGB(104,205,255))
	building(city,Vector3.new(55,0,z+10),Vector3.new(30,18+((i+1)%3)*9,26),Color3.fromRGB(119,112+(i%2)*10,105),Color3.fromRGB(255,191,91))
	lamp(city,Vector3.new(-24,0,z),Color3.fromRGB(255,188,90)); lamp(city,Vector3.new(24,0,z+10),Color3.fromRGB(255,188,90))
end
local craneBase=part(city,"CraneTower",Vector3.new(6,58,6),CFrame.new(50,29,430),Color3.fromRGB(242,178,43),Enum.Material.Metal)
beam(city,Vector3.new(50,58,430),Vector3.new(-20,58,430),3,Color3.fromRGB(242,178,43),Enum.Material.Metal)
beam(city,Vector3.new(50,58,430),Vector3.new(72,58,430),3,Color3.fromRGB(242,178,43),Enum.Material.Metal)
local hookLine=part(city,"CraneCable",Vector3.new(.4,20,.4),CFrame.new(0,48,430),Color3.fromRGB(45,46,50),Enum.Material.Metal)
ball(city,"CraneHook",Vector3.new(0,37.5,430),2.2,Color3.fromRGB(65,68,73),Enum.Material.Metal)
for _,x in ipairs({-35,35}) do for _,z in ipairs({290,360,420}) do
	local barricade=part(city,"Barricade",Vector3.new(12,3,1),CFrame.new(x,1.5,z),Color3.fromRGB(247,139,44),Enum.Material.Metal)
	for s=-1,1,2 do part(city,"BarricadeFoot",Vector3.new(2,1,5),CFrame.new(x+s*4.5,.5,z),Color3.fromRGB(63,68,74),Enum.Material.Metal) end
end end

-- CRYSTAL CAVES
local cave=Instance.new("Folder"); cave.Name="CrystalCavesOverhaul"; cave.Parent=root
zoneTitle(cave,495,"CRYSTAL CAVES","FOLLOW THE GLOW",Color3.fromRGB(80,226,255))
for z=500,695,22 do
	rockCluster(cave,Vector3.new(-62,0,z),Color3.fromRGB(54,61,84),1.05)
	rockCluster(cave,Vector3.new(62,0,z+8),Color3.fromRGB(58,64,91),.95)
	if z%44==16 then crystalCluster(cave,Vector3.new(-38,0,z+5),Color3.fromRGB(76,225,255),.7) else crystalCluster(cave,Vector3.new(38,0,z+5),Color3.fromRGB(171,88,255),.65) end
end
for z=520,680,40 do arch(cave,z,Color3.fromRGB(63,69,93),104,31) end
for z=515,690,28 do
	local glow=noCollide(neon(cave,"CrystalRoadGlow",Vector3.new(1,.12,10),CFrame.new(0,.38,z),Color3.fromRGB(78,214,255)))
	glow.Transparency=.15
end
local spireBase=part(cave,"CrystalSpireBase",Vector3.new(24,6,24),CFrame.new(0,3,675),Color3.fromRGB(52,58,81),Enum.Material.Slate)
crystalCluster(cave,Vector3.new(0,5.5,675),Color3.fromRGB(103,226,255),2.2)
for _,pos in ipairs({Vector3.new(-18,2,650),Vector3.new(18,2,652),Vector3.new(-18,2,697),Vector3.new(18,2,695)}) do crystalCluster(cave,pos,Color3.fromRGB(181,83,255),.8) end

-- MAGMA FORGE
local forge=Instance.new("Folder"); forge.Name="MagmaForgeOverhaul"; forge.Parent=root
zoneTitle(forge,730,"MAGMA FORGE","HEAT. STEEL. POWER.",Color3.fromRGB(255,91,45))
for _,x in ipairs({-55,55}) do
	local lava=neon(forge,"LavaRiver",Vector3.new(18,.5,205),CFrame.new(x,.05,830),Color3.fromRGB(255,79,31))
	local light=Instance.new("PointLight"); light.Color=Color3.fromRGB(255,88,38); light.Brightness=.5; light.Range=24; light.Parent=lava
end
for z=750,930,30 do
	beam(forge,Vector3.new(-45,1,z),Vector3.new(45,1,z),2.2,Color3.fromRGB(58,55,57),Enum.Material.Metal)
	for _,x in ipairs({-35,35}) do
		local p=part(forge,"ForgePylon",Vector3.new(6,15,6),CFrame.new(x,7.5,z),Color3.fromRGB(67,60,61),Enum.Material.Metal)
		local cap=neon(forge,"HeatCore",Vector3.new(3,5,3),p.CFrame*CFrame.new(0,4,0),Color3.fromRGB(255,92,36))
		local light=Instance.new("PointLight"); light.Color=cap.Color; light.Brightness=1.1; light.Range=18; light.Parent=cap
	end
end
local tower=part(forge,"ForgeTower",Vector3.new(30,34,30),CFrame.new(0,17,920),Color3.fromRGB(56,52,54),Enum.Material.Metal)
for i=0,3 do
	local a=math.rad(i*90)
	local pos=Vector3.new(math.cos(a)*19,20,920+math.sin(a)*19)
	part(forge,"ForgeButtress",Vector3.new(7,40,7),CFrame.new(pos),Color3.fromRGB(71,61,60),Enum.Material.Slate)
end
local core=ball(forge,"ForgeCore",Vector3.new(0,26,920),9,Color3.fromRGB(255,76,28),Enum.Material.Neon)
local coreLight=Instance.new("PointLight"); coreLight.Color=core.Color; coreLight.Range=50; coreLight.Brightness=2; coreLight.Parent=core

-- VOID TEMPLE
local void=Instance.new("Folder"); void.Name="VoidTempleOverhaul"; void.Parent=root
zoneTitle(void,965,"VOID TEMPLE","THE FINAL BREAK",Color3.fromRGB(181,87,255))
for z=980,1160,32 do
	arch(void,z,Color3.fromRGB(62,53,87),92,28)
	for _,x in ipairs({-50,50}) do
		local ob=part(void,"Obelisk",Vector3.new(7,24,7),CFrame.new(x,12,z+10),Color3.fromRGB(49,43,72),Enum.Material.Slate)
		local rune=noCollide(neon(void,"Rune",Vector3.new(7.2,8,.35),ob.CFrame*CFrame.new(0,2,-3.7),Color3.fromRGB(181,78,255)))
		local light=Instance.new("PointLight"); light.Color=rune.Color; light.Brightness=.9; light.Range=18; light.Parent=rune
	end
end
for z=985,1160,22 do
	for _,x in ipairs({-16,16}) do
		local tile=noCollide(neon(void,"VoidRoadRune",Vector3.new(5,.15,8),CFrame.new(x,.35,z),Color3.fromRGB(110,55,205)))
		tile.Transparency=.25
	end
end
local crownBase=part(void,"VoidCrownBase",Vector3.new(46,5,46),CFrame.new(0,2.5,1160),Color3.fromRGB(45,40,66),Enum.Material.Slate)
for i=0,7 do
	local a=math.rad(i*45)
	local x=math.cos(a)*19
	local z=1160+math.sin(a)*19
	local spike=part(void,"CrownSpike",Vector3.new(4,24,4),CFrame.new(x,12,z)*CFrame.Angles(math.rad(math.cos(a)*18),0,math.rad(-math.sin(a)*18)),Color3.fromRGB(75,51,108),Enum.Material.Slate)
	local tip=ball(void,"CrownGlow",spike.Position+Vector3.new(0,12,0),2.5,Color3.fromRGB(189,72,255),Enum.Material.Neon)
	tip.CanCollide=false
end
local vortex=ball(void,"VoidHeart",Vector3.new(0,14,1160),9,Color3.fromRGB(139,49,235),Enum.Material.Neon)
vortex.Transparency=.15
local vl=Instance.new("PointLight"); vl.Color=vortex.Color; vl.Range=58; vl.Brightness=2.2; vl.Parent=vortex

-- side paths + hidden areas
local secret=Instance.new("Folder"); secret.Name="Secrets"; secret.Parent=root
local secretSpecs={
	{z=175,x=-72,color=Color3.fromRGB(255,211,67),name="GOLDEN GROVE"},
	{z=390,x=73,color=Color3.fromRGB(255,145,48),name="SCRAP YARD"},
	{z=610,x=-72,color=Color3.fromRGB(80,225,255),name="SHARD GROTTO"},
	{z=845,x=72,color=Color3.fromRGB(255,78,35),name="EMBER PIT"},
	{z=1080,x=-72,color=Color3.fromRGB(186,72,255),name="NULL CHAMBER"},
}
for _,s in ipairs(secretSpecs) do
	beam(secret,Vector3.new(math.sign(s.x)*18,.5,s.z),Vector3.new(s.x,.5,s.z),6,Color3.fromRGB(98,91,82),Enum.Material.Cobblestone)
	local pad=part(secret,"SecretPad",Vector3.new(28,1,28),CFrame.new(s.x,.5,s.z),Color3.fromRGB(54,55,64),Enum.Material.Slate)
	local orb=ball(secret,"SecretOrb",Vector3.new(s.x,6,s.z),5,s.color,Enum.Material.Neon)
	orb.CanCollide=false
	billboard(orb,s.name.."\nSECRET AREA",s.color,UDim2.fromOffset(250,70),Vector3.new(0,6,0))
end

-- atmospheric animated props
for _,obj in ipairs(root:GetDescendants()) do
	if obj:IsA("BasePart") and (obj.Name=="VoidHeart" or obj.Name=="ForgeCore" or obj.Name=="SecretOrb") then
		task.spawn(function()
			local baseSize=obj.Size
			while obj.Parent do
				TweenService:Create(obj,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Size=baseSize*1.08}):Play()
				task.wait(1.2)
				if not obj.Parent then break end
				TweenService:Create(obj,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Size=baseSize}):Play()
				task.wait(1.2)
			end
		end)
	end
end

print("[Smash Legends] World overhaul loaded")
