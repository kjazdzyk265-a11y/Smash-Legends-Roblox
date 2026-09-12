local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")

local world=Workspace:WaitForChild("SmashWorld")
local map=world:WaitForChild("Map")
local old=world:FindFirstChild("MapMegaPass")
if old then old:Destroy() end
local root=Instance.new("Folder")
root.Name="MapMegaPass"
root.Parent=world

local function part(parent,name,size,cf,color,material,collide)
	local p=Instance.new("Part")
	p.Name=name
	p.Size=size
	p.CFrame=cf
	p.Anchored=true
	p.CanCollide=collide~=false
	p.CanTouch=false
	p.CanQuery=true
	p.Color=color
	p.Material=material or Enum.Material.SmoothPlastic
	p.TopSurface=Enum.SurfaceType.Smooth
	p.BottomSurface=Enum.SurfaceType.Smooth
	p.Parent=parent
	return p
end

local function ball(parent,name,pos,size,color,material,collide)
	local p=part(parent,name,Vector3.new(size,size,size),CFrame.new(pos),color,material,collide)
	p.Shape=Enum.PartType.Ball
	return p
end

local function wedge(parent,name,size,cf,color,material,collide)
	local p=Instance.new("WedgePart")
	p.Name=name; p.Size=size; p.CFrame=cf; p.Anchored=true; p.CanCollide=collide~=false; p.CanTouch=false; p.Color=color; p.Material=material or Enum.Material.SmoothPlastic; p.Parent=parent
	return p
end

local function light(parent,color,range,brightness)
	local l=Instance.new("PointLight")
	l.Color=color; l.Range=range or 20; l.Brightness=brightness or 1.5; l.Shadows=true; l.Parent=parent
end

local function label(parent,textValue,color,offset)
	local g=Instance.new("BillboardGui")
	g.Size=UDim2.fromOffset(320,72); g.StudsOffset=offset or Vector3.new(0,7,0); g.AlwaysOnTop=true; g.MaxDistance=220; g.Parent=parent
	local t=Instance.new("TextLabel")
	t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Text=textValue; t.TextColor3=color; t.TextStrokeColor3=Color3.fromRGB(20,20,24); t.TextStrokeTransparency=.1; t.Font=Enum.Font.GothamBlack; t.TextScaled=true; t.TextWrapped=true; t.Parent=g
end

local function tree(parent,pos,scale,leaf)
	scale=scale or 1
	part(parent,"TreeTrunk",Vector3.new(2.6,11,2.6)*scale,CFrame.new(pos+Vector3.new(0,5.5*scale,0)),Color3.fromRGB(104,67,42),Enum.Material.Wood,true)
	for i=1,3 do
		ball(parent,"TreeCrown",pos+Vector3.new((i-2)*2.7*scale,(10+i*2)*scale,((i%2)*2-1)*1.2*scale),6.5*scale,leaf or Color3.fromRGB(68,161,76),Enum.Material.Grass,false)
	end
end

local function lamp(parent,pos,color)
	part(parent,"LampPost",Vector3.new(.8,9,.8),CFrame.new(pos+Vector3.new(0,4.5,0)),Color3.fromRGB(48,51,58),Enum.Material.Metal,true)
	local glow=ball(parent,"LampGlow",pos+Vector3.new(0,9.2,0),1.45,color,Enum.Material.Neon,false)
	light(glow,color,18,1.4)
end

local function arch(parent,center,width,height,color,accent)
	local x=width/2
	part(parent,"ArchLeft",Vector3.new(5,height,5),CFrame.new(center+Vector3.new(-x,height/2,0)),color,Enum.Material.Slate,true)
	part(parent,"ArchRight",Vector3.new(5,height,5),CFrame.new(center+Vector3.new(x,height/2,0)),color,Enum.Material.Slate,true)
	part(parent,"ArchTop",Vector3.new(width+5,5,5),CFrame.new(center+Vector3.new(0,height,0)),color,Enum.Material.Slate,true)
	if accent then
		local rune=part(parent,"ArchRune",Vector3.new(width-3,.45,1.1),CFrame.new(center+Vector3.new(0,height+2.7,-2.7)),accent,Enum.Material.Neon,false)
		light(rune,accent,22,1)
	end
end

local function building(parent,pos,size,body,trim,window)
	local base=part(parent,"Building",size,CFrame.new(pos+Vector3.new(0,size.Y/2,0)),body,Enum.Material.Concrete,true)
	part(parent,"BuildingRoof",Vector3.new(size.X+2,1,size.Z+2),base.CFrame*CFrame.new(0,size.Y/2+.5,0),trim,Enum.Material.Metal,true)
	for floor=1,math.max(1,math.floor(size.Y/8)) do
		for _,side in ipairs({-1,1}) do
			for zoff=-1,1 do
				local w=part(parent,"Window",Vector3.new(3,2.6,.22),CFrame.new(pos.X+side*(size.X/2+.12),floor*6.2,pos.Z+zoff*5),window,Enum.Material.Neon,false)
				w.Transparency=.1
			end
		end
	end
end

local function rockRing(parent,center,radius,count,color,scale)
	for i=1,count do
		local a=(i/count)*math.pi*2
		local x=math.cos(a)*radius
		local z=math.sin(a)*radius
		local s=(scale or 1)*(1+(i%3)*.12)
		part(parent,"Rock",Vector3.new(6,7+(i%4)*2,6)*s,CFrame.new(center+Vector3.new(x,3.5*s,z))*CFrame.Angles(math.rad(i*5),math.rad(i*23),math.rad(i*7)),color,Enum.Material.Slate,true)
	end
end

local function crystal(parent,pos,color,scale)
	scale=scale or 1
	for i=1,5 do
		local angle=(i/5)*math.pi*2
		local h=(7+i*1.7)*scale
		local shard=part(parent,"CrystalShard",Vector3.new(2.1*scale,h,2.1*scale),CFrame.new(pos+Vector3.new(math.cos(angle)*3*scale,h/2,math.sin(angle)*3*scale))*CFrame.Angles(math.rad((i-3)*4),0,math.rad((i-3)*7)),color,Enum.Material.Neon,false)
		if i==3 then light(shard,color,20*scale,1.2) end
	end
end

local function banner(parent,pos,color,textValue)
	local pole=part(parent,"BannerPole",Vector3.new(.7,10,.7),CFrame.new(pos+Vector3.new(0,5,0)),Color3.fromRGB(45,48,55),Enum.Material.Metal,true)
	part(parent,"Banner",Vector3.new(6,5,.25),pole.CFrame*CFrame.new(0,1.5,0),color,Enum.Material.Fabric,false)
	if textValue then label(pole,textValue,color,Vector3.new(0,8,0)) end
end

-- Spawn hub: make first impression feel like a real plaza.
local hub=Instance.new("Folder"); hub.Name="HeroSpawn"; hub.Parent=root
part(hub,"Plaza",Vector3.new(125,1,86),CFrame.new(0,.3,36),Color3.fromRGB(194,184,160),Enum.Material.Cobblestone,true)
for _,z in ipairs({8,34,60}) do
	for _,x in ipairs({-52,52}) do lamp(hub,Vector3.new(x,0,z),Color3.fromRGB(255,218,139)) end
end
for _,x in ipairs({-42,-28,28,42}) do banner(hub,Vector3.new(x,0,72),Color3.fromRGB(238,92,50)) end
arch(hub,Vector3.new(0,0,83),58,24,Color3.fromRGB(65,70,80),Color3.fromRGB(255,201,65))
local hero=part(hub,"HeroMonument",Vector3.new(14,6,14),CFrame.new(0,3,53),Color3.fromRGB(68,72,82),Enum.Material.Slate,true)
local hammerHead=part(hub,"MonumentHammerHead",Vector3.new(11,4,5),CFrame.new(0,15,53)*CFrame.Angles(0,0,math.rad(-15)),Color3.fromRGB(255,191,49),Enum.Material.Metal,false)
part(hub,"MonumentHammerHandle",Vector3.new(2,18,2),CFrame.new(0,10,53)*CFrame.Angles(0,0,math.rad(-15)),Color3.fromRGB(111,73,44),Enum.Material.Wood,false)
label(hero,"SMASH LEGENDS\nBREAK YOUR WAY FORWARD",Color3.fromRGB(255,218,77),Vector3.new(0,8,0))

-- Greenyard village: barn, mill, sheds, orchard, field rows.
local green=Instance.new("Folder"); green.Name="GreenyardMega"; green.Parent=root
building(green,Vector3.new(-52,0,120),Vector3.new(32,17,25),Color3.fromRGB(165,67,52),Color3.fromRGB(77,58,49),Color3.fromRGB(255,221,139))
for i=1,4 do
	part(green,"CropRow",Vector3.new(12,.5,26),CFrame.new(42+(i%2)*14,.25,100+i*28),Color3.fromRGB(126,95+(i%2)*20,52),Enum.Material.Ground,true)
	for j=1,6 do ball(green,"Crop",Vector3.new(42+(i%2)*14,1.5,88+i*28+j*4),2.3,Color3.fromRGB(85,168,70),Enum.Material.Grass,false) end
end
for i=1,10 do
	local side=i%2==0 and -1 or 1
	tree(green,Vector3.new(side*(52+(i%3)*7),0,92+i*12),.72+(i%3)*.08,Color3.fromRGB(69,165+(i%2)*10,77))
end
local mill=part(green,"MillTower",Vector3.new(11,26,11),CFrame.new(49,13,193),Color3.fromRGB(218,208,181),Enum.Material.Concrete,true)
local hubBall=ball(green,"MillHub",Vector3.new(49,25,186.8),3.1,Color3.fromRGB(107,72,46),Enum.Material.Wood,false)
for i=0,3 do
	part(green,"MillBlade",Vector3.new(2.5,21,.8),CFrame.new(49,25,186.5)*CFrame.Angles(0,0,math.rad(i*90))*CFrame.new(0,9.6,0),Color3.fromRGB(235,226,204),Enum.Material.WoodPlanks,false)
end
for _,z in ipairs({112,154,198}) do lamp(green,Vector3.new(-18,0,z),Color3.fromRGB(255,211,118)); lamp(green,Vector3.new(18,0,z+7),Color3.fromRGB(255,211,118)) end

-- Construction City: denser skyline, scaffolding, containers, crane yard.
local city=Instance.new("Folder"); city.Name="ConstructionMega"; city.Parent=root
for i=1,8 do
	local z=252+i*25
	local side=i%2==0 and -1 or 1
	local h=20+(i%4)*9
	building(city,Vector3.new(side*57,0,z),Vector3.new(28,h,23),Color3.fromRGB(101+i*3,108+i*2,115+i*2),Color3.fromRGB(52,57,63),i%2==0 and Color3.fromRGB(98,205,255) or Color3.fromRGB(255,184,76))
end
for i=1,6 do
	local x=i%2==0 and -35 or 35
	local z=270+i*31
	part(city,"Container",Vector3.new(18,7,8),CFrame.new(x,3.5,z),i%3==0 and Color3.fromRGB(61,129,172) or Color3.fromRGB(194,81,55),Enum.Material.Metal,true)
	part(city,"ContainerRib",Vector3.new(18.2,.35,8.2),CFrame.new(x,6.6,z),Color3.fromRGB(55,60,66),Enum.Material.Metal,false)
end
for _,z in ipairs({280,340,400,450}) do
	for _,x in ipairs({-26,26}) do lamp(city,Vector3.new(x,0,z),Color3.fromRGB(255,176,89)) end
end
for i=1,4 do
	local x=-45+i*15
	part(city,"ScaffoldPole",Vector3.new(.8,24,.8),CFrame.new(x,12,432),Color3.fromRGB(89,93,99),Enum.Material.Metal,true)
	part(city,"ScaffoldDeck",Vector3.new(14,1,7),CFrame.new(x+7,9,432),Color3.fromRGB(134,115,78),Enum.Material.WoodPlanks,true)
end

-- Crystal Caves: canyon walls, cathedral arches, crystals above the player.
local cave=Instance.new("Folder"); cave.Name="CrystalMega"; cave.Parent=root
for z=490,700,18 do
	part(cave,"CaveWallL",Vector3.new(22,18+(z%4)*2,18),CFrame.new(-78,8,z)*CFrame.Angles(0,math.rad(z%29),math.rad(-4)),Color3.fromRGB(48,54,77),Enum.Material.Slate,true)
	part(cave,"CaveWallR",Vector3.new(22,20+((z+1)%4)*2,18),CFrame.new(78,9,z)*CFrame.Angles(0,math.rad(-(z%31)),math.rad(4)),Color3.fromRGB(52,58,84),Enum.Material.Slate,true)
end
for _,z in ipairs({525,580,635,690}) do arch(cave,Vector3.new(0,0,z),68,28,Color3.fromRGB(54,62,90),Color3.fromRGB(72,222,255)) end
for i=1,12 do
	local side=i%2==0 and -1 or 1
	crystal(cave,Vector3.new(side*(37+(i%3)*7),0,495+i*16),i%3==0 and Color3.fromRGB(172,86,255) or Color3.fromRGB(70,224,255),.65+(i%2)*.18)
end
for _,z in ipairs({545,610,675}) do
	local c=crystal(cave,Vector3.new(0,23,z),Color3.fromRGB(92,199,255),.9)
end

-- Magma Forge: factory line, furnaces, chains and lava bridges.
local forge=Instance.new("Folder"); forge.Name="MagmaMega"; forge.Parent=root
for i=1,5 do
	local z=725+i*42
	for _,x in ipairs({-57,57}) do
		local tower=part(forge,"Furnace",Vector3.new(15,26,15),CFrame.new(x,13,z),Color3.fromRGB(67,58,56),Enum.Material.Basalt,true)
		local mouth=part(forge,"FurnaceMouth",Vector3.new(8,8,.5),tower.CFrame*CFrame.new(0,-2,-7.8),Color3.fromRGB(255,79,31),Enum.Material.Neon,false)
		light(mouth,mouth.Color,24,2)
		part(forge,"FurnaceCap",Vector3.new(17,2,17),tower.CFrame*CFrame.new(0,14,0),Color3.fromRGB(87,72,67),Enum.Material.Metal,true)
	end
end
for _,z in ipairs({748,806,864,920}) do
	part(forge,"LavaRiver",Vector3.new(100,.4,9),CFrame.new(0,.15,z),Color3.fromRGB(255,70,24),Enum.Material.Neon,false)
	part(forge,"Bridge",Vector3.new(22,1.2,14),CFrame.new(0,1,z),Color3.fromRGB(72,72,76),Enum.Material.DiamondPlate,true)
	for _,x in ipairs({-13,13}) do part(forge,"BridgeRail",Vector3.new(1,4,14),CFrame.new(x,2.4,z),Color3.fromRGB(77,65,62),Enum.Material.Metal,true) end
end
for i=1,7 do
	local z=728+i*30
	part(forge,"Chain",Vector3.new(.45,15,.45),CFrame.new(i%2==0 and -31 or 31,16,z),Color3.fromRGB(48,46,46),Enum.Material.Metal,false)
	ball(forge,"ChainWeight",Vector3.new(i%2==0 and -31 or 31,8.4,z),2.4,Color3.fromRGB(52,49,50),Enum.Material.Metal,false)
end

-- Void Temple: real temple silhouette, stairs, floating monoliths and final arena.
local void=Instance.new("Folder"); void.Name="VoidMega"; void.Parent=root
for _,z in ipairs({970,1025,1080,1135}) do arch(void,Vector3.new(0,0,z),78,31,Color3.fromRGB(54,45,77),Color3.fromRGB(184,72,255)) end
for i=1,10 do
	local side=i%2==0 and -1 or 1
	local z=955+i*22
	local h=20+(i%3)*8
	local ob=part(void,"Obelisk",Vector3.new(7,h,7),CFrame.new(side*(49+(i%2)*8),h/2,z)*CFrame.Angles(0,math.rad(i*17),0),Color3.fromRGB(59,49,84),Enum.Material.Slate,true)
	local cap=part(void,"ObeliskRune",Vector3.new(7.5,1,7.5),ob.CFrame*CFrame.new(0,h/2+.6,0),Color3.fromRGB(175,68,255),Enum.Material.Neon,false)
	light(cap,cap.Color,16,1.1)
end
for i=1,5 do
	part(void,"TempleStep",Vector3.new(78,1.5,16),CFrame.new(0,.75+i*1.5,1112+i*12),Color3.fromRGB(63,52,86),Enum.Material.Slate,true)
end
local arena=part(void,"FinalArena",Vector3.new(112,3,82),CFrame.new(0,8,1182),Color3.fromRGB(48,39,70),Enum.Material.Slate,true)
for i=0,11 do
	local a=math.rad(i*30)
	local pos=Vector3.new(math.cos(a)*48,13,1182+math.sin(a)*32)
	local orb=ball(void,"ArenaOrb",pos,3.5,Color3.fromRGB(177,73,255),Enum.Material.Neon,false)
	light(orb,orb.Color,20,1.4)
end
local core=ball(void,"VoidHeart",Vector3.new(0,24,1182),13,Color3.fromRGB(151,56,255),Enum.Material.Neon,false)
light(core,core.Color,54,3.5)
label(core,"VOID HEART\nFINAL BREAK ZONE",Color3.fromRGB(226,177,255),Vector3.new(0,14,0))

-- Visible separators and horizon silhouettes so zones do not feel like one flat strip.
local bands={
	{115,Color3.fromRGB(69,135,69),Enum.Material.Grass},
	{352,Color3.fromRGB(78,82,88),Enum.Material.Concrete},
	{592,Color3.fromRGB(47,53,78),Enum.Material.Slate},
	{827,Color3.fromRGB(65,48,46),Enum.Material.Basalt},
	{1072,Color3.fromRGB(43,35,65),Enum.Material.Slate},
}
for _,b in ipairs(bands) do
	for _,x in ipairs({-108,108}) do
		part(root,"HorizonMass",Vector3.new(28,28,210),CFrame.new(x,9,b[1]),b[2],b[3],true)
	end
end

local cc=Lighting:FindFirstChild("MegaColor") or Instance.new("ColorCorrectionEffect")
cc.Name="MegaColor"; cc.Brightness=.025; cc.Contrast=.11; cc.Saturation=.14; cc.Parent=Lighting
local bloom=Lighting:FindFirstChild("MegaBloom") or Instance.new("BloomEffect")
bloom.Name="MegaBloom"; bloom.Intensity=.42; bloom.Size=24; bloom.Threshold=1.35; bloom.Parent=Lighting

print("[Smash Legends] Map Mega Pass loaded")
