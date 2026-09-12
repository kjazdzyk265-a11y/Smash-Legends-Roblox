local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")

local world=Workspace:WaitForChild("SmashWorld")
local map=world:WaitForChild("Map")
local terrain=Workspace.Terrain

local old=world:FindFirstChild("TerrainLandmarks")
if old then old:Destroy() end
local root=Instance.new("Folder")
root.Name="TerrainLandmarks"
root.Parent=world

local function part(name,size,cf,color,material,parent,collide)
	local p=Instance.new("Part")
	p.Name=name
	p.Size=size
	p.CFrame=cf
	p.Anchored=true
	p.CanCollide=collide~=false
	p.TopSurface=Enum.SurfaceType.Smooth
	p.BottomSurface=Enum.SurfaceType.Smooth
	p.Color=color
	p.Material=material or Enum.Material.SmoothPlastic
	p.Parent=parent or root
	return p
end

local function ball(name,pos,size,color,material,parent)
	local p=part(name,Vector3.new(size,size,size),CFrame.new(pos),color,material,parent,false)
	p.Shape=Enum.PartType.Ball
	return p
end

local function light(parent,color,range,brightness)
	local l=Instance.new("PointLight")
	l.Color=color
	l.Range=range or 18
	l.Brightness=brightness or 1.5
	l.Shadows=true
	l.Parent=parent
end

local function arch(z,width,height,color,material,parent)
	parent=parent or root
	local x=width/2
	part("ArchLeft",Vector3.new(5,height,6),CFrame.new(-x,height/2,z),color,material,parent)
	part("ArchRight",Vector3.new(5,height,6),CFrame.new(x,height/2,z),color,material,parent)
	part("ArchTop",Vector3.new(width+5,5,6),CFrame.new(0,height,z),color,material,parent)
end

local function tower(pos,h,color,accent,parent)
	local base=part("Tower",Vector3.new(16,h,16),CFrame.new(pos.X,h/2,pos.Z),color,Enum.Material.Concrete,parent)
	part("TowerCap",Vector3.new(18,2,18),CFrame.new(pos.X,h+1,pos.Z),Color3.fromRGB(47,51,59),Enum.Material.Metal,parent)
	for y=8,h-5,8 do
		for _,xoff in ipairs({-8.1,8.1}) do
			local w=part("Window",Vector3.new(.25,3.4,5),CFrame.new(pos.X+xoff,y,pos.Z),accent,Enum.Material.Neon,parent,false)
			w.Transparency=.05
		end
	end
	return base
end

-- Broad terrain shoulders. The playable road remains built from Parts, while Terrain fills the empty horizon.
terrain:FillBlock(CFrame.new(0,-9,115),Vector3.new(260,18,230),Enum.Material.Grass)
terrain:FillBlock(CFrame.new(0,-9,352),Vector3.new(260,18,245),Enum.Material.Rock)
terrain:FillBlock(CFrame.new(0,-11,592),Vector3.new(270,22,235),Enum.Material.Slate)
terrain:FillBlock(CFrame.new(0,-11,827),Vector3.new(270,22,235),Enum.Material.Basalt)
terrain:FillBlock(CFrame.new(0,-12,1070),Vector3.new(280,24,250),Enum.Material.Slate)

-- GREENYARD hills and valley silhouette.
local green=Instance.new("Folder"); green.Name="GreenyardTerrain"; green.Parent=root
for i=1,14 do
	local z=15+i*15
	local side=i%2==0 and -1 or 1
	terrain:FillBall(Vector3.new(side*(86+(i%3)*10),-1,z),24+(i%4)*4,Enum.Material.Grass)
end
for i=1,7 do
	local z=38+i*25
	local trunk=part("OakTrunk",Vector3.new(3,14,3),CFrame.new((i%2==0 and -72 or 72),7,z),Color3.fromRGB(101,67,42),Enum.Material.Wood,green)
	for j=1,3 do
		ball("OakCrown",trunk.Position+Vector3.new((j-2)*3,9+j,0),9,Color3.fromRGB(63+(j*5),155+(j*6),70),Enum.Material.Grass,green)
	end
end
local farmhouse=Instance.new("Model"); farmhouse.Name="Farmhouse"; farmhouse.Parent=green
part("House",Vector3.new(30,15,22),CFrame.new(45,7.5,180),Color3.fromRGB(224,210,177),Enum.Material.WoodPlanks,farmhouse)
part("Roof",Vector3.new(34,3,26),CFrame.new(45,16.5,180)*CFrame.Angles(0,0,math.rad(10)),Color3.fromRGB(109,65,48),Enum.Material.Slate,farmhouse)
part("Porch",Vector3.new(20,1,8),CFrame.new(45,.8,165),Color3.fromRGB(140,96,58),Enum.Material.WoodPlanks,farmhouse)
for _,x in ipairs({37,45,53}) do
	local w=part("Window",Vector3.new(4,5,.4),CFrame.new(x,8.5,168.8),Color3.fromRGB(255,219,135),Enum.Material.Neon,farmhouse,false)
	light(w,w.Color,12,.7)
end

-- CONSTRUCTION CITY skyline, bridge and service yard.
local city=Instance.new("Folder"); city.Name="ConstructionSkyline"; city.Parent=root
for i=1,10 do
	local side=i%2==0 and -1 or 1
	local z=245+i*21
	local h=28+(i%5)*10
	tower(Vector3.new(side*(78+(i%3)*12),0,z),h,Color3.fromRGB(92+(i%3)*8,99,108),i%2==0 and Color3.fromRGB(91,198,255) or Color3.fromRGB(255,177,75),city)
end
part("Overpass",Vector3.new(145,3,18),CFrame.new(0,18,430),Color3.fromRGB(83,88,96),Enum.Material.Concrete,city)
for _,x in ipairs({-60,-20,20,60}) do part("OverpassPillar",Vector3.new(6,18,6),CFrame.new(x,9,430),Color3.fromRGB(75,80,88),Enum.Material.Concrete,city) end
for i=1,5 do
	local x=-50+(i-1)*25
	part("Container",Vector3.new(20,8,8),CFrame.new(x,4,458),i%2==0 and Color3.fromRGB(65,127,169) or Color3.fromRGB(180,78,56),Enum.Material.Metal,city)
end

-- CRYSTAL CAVES: terrain canyon walls plus luminous ribs.
local cave=Instance.new("Folder"); cave.Name="CrystalCanyon"; cave.Parent=root
for i=1,18 do
	local z=480+i*13
	terrain:FillBall(Vector3.new(-92+(i%3)*5,10,z),30+(i%4)*4,Enum.Material.Slate)
	terrain:FillBall(Vector3.new(92-(i%3)*5,10,z+5),30+((i+2)%4)*4,Enum.Material.Slate)
end
for z=505,690,31 do
	arch(z,82,32,Color3.fromRGB(53,64,92),Enum.Material.Slate,cave)
	for _,x in ipairs({-33,33}) do
		local shard=part("CrystalRib",Vector3.new(4,21,4),CFrame.new(x,11,z)*CFrame.Angles(0,0,math.rad(x<0 and -13 or 13)),Color3.fromRGB(74,220,255),Enum.Material.Neon,cave,false)
		light(shard,shard.Color,20,1.1)
	end
end
for i=1,10 do
	local a=(i/10)*math.pi*2
	local x=math.cos(a)*28
	local z=675+math.sin(a)*18
	local h=10+(i%4)*5
	part("CrystalNeedle",Vector3.new(3,h,3),CFrame.new(x,h/2,z)*CFrame.Angles(math.rad((i%3-1)*8),0,math.rad((i%4-2)*7)),Color3.fromRGB(93,229,255),Enum.Material.Neon,cave,false)
end

-- MAGMA FORGE: volcanic rims, giant furnaces, pipes and central crucible.
local forge=Instance.new("Folder"); forge.Name="MagmaIndustrial"; forge.Parent=root
for i=1,14 do
	local z=712+i*16
	terrain:FillBall(Vector3.new(i%2==0 and -93 or 93,8,z),28+(i%3)*5,Enum.Material.Basalt)
end
for _,x in ipairs({-57,57}) do
	for i=1,4 do
		local z=748+i*43
		local furnace=part("Furnace",Vector3.new(20,28,18),CFrame.new(x,14,z),Color3.fromRGB(54,51,52),Enum.Material.Basalt,forge)
		local mouth=part("FurnaceMouth",Vector3.new(12,9,.7),CFrame.new(x,8,z-(x<0 and 9.4 or -9.4))*CFrame.Angles(0,x<0 and 0 or math.pi,0),Color3.fromRGB(255,83,30),Enum.Material.Neon,forge,false)
		light(mouth,mouth.Color,25,2.2)
	end
end
for i=1,6 do
	local z=730+i*33
	part("Pipe",Vector3.new(3,3,48),CFrame.new(i%2==0 and -72 or 72,17,z),Color3.fromRGB(80,77,76),Enum.Material.Metal,forge)
	part("PipeJoint",Vector3.new(6,6,6),CFrame.new(i%2==0 and -72 or 72,17,z+22),Color3.fromRGB(102,83,72),Enum.Material.Metal,forge)
end
local crucible=part("GrandCrucible",Vector3.new(34,12,34),CFrame.new(0,6,915),Color3.fromRGB(58,55,57),Enum.Material.Metal,forge)
local molten=part("MoltenCore",Vector3.new(28,1.5,28),CFrame.new(0,12.5,915),Color3.fromRGB(255,71,24),Enum.Material.Neon,forge,false)
light(molten,molten.Color,42,3.4)

-- VOID TEMPLE: cliff islands, monumental stairs and crown arena.
local void=Instance.new("Folder"); void.Name="VoidMonuments"; void.Parent=root
for i=1,12 do
	local z=950+i*20
	terrain:FillBall(Vector3.new(i%2==0 and -96 or 96,5,z),26+(i%4)*4,Enum.Material.Slate)
end
for step=1,8 do
	part("TempleStep",Vector3.new(70-step*3,2,10),CFrame.new(0,step,1065+step*9),Color3.fromRGB(55,47,78),Enum.Material.Slate,void)
end
for _,x in ipairs({-38,38}) do
	for i=1,5 do
		local z=1010+i*34
		local ob=part("VoidObelisk",Vector3.new(9,30+(i%2)*8,9),CFrame.new(x,(30+(i%2)*8)/2,z)*CFrame.Angles(0,math.rad(i*12),0),Color3.fromRGB(51,43,73),Enum.Material.Slate,void)
		local rune=part("RuneCap",Vector3.new(9.5,1.2,9.5),ob.CFrame*CFrame.new(0,ob.Size.Y/2+.7,0),Color3.fromRGB(180,68,255),Enum.Material.Neon,void,false)
		light(rune,rune.Color,20,1.5)
	end
end
local arena=part("FinalArena",Vector3.new(96,5,96),CFrame.new(0,2.5,1172),Color3.fromRGB(48,40,69),Enum.Material.Slate,void)
for i=0,11 do
	local a=math.rad(i*30)
	local pos=Vector3.new(math.cos(a)*43,8,1172+math.sin(a)*43)
	local ob=part("ArenaSpire",Vector3.new(6,20,6),CFrame.new(pos),Color3.fromRGB(63,48,89),Enum.Material.Slate,void)
	local orb=ball("ArenaGlow",pos+Vector3.new(0,11,0),3.2,Color3.fromRGB(184,72,255),Enum.Material.Neon,void)
	light(orb,orb.Color,18,1.4)
end
local crown=ball("VoidCrownCore",Vector3.new(0,24,1172),13,Color3.fromRGB(146,55,255),Enum.Material.Neon,void)
crown.Transparency=.08
light(crown,crown.Color,60,4)

-- Global atmosphere tuned for a denser, less baseplate-like world.
Lighting.Technology=Enum.Technology.Future
Lighting.GlobalShadows=true
Lighting.ShadowSoftness=.35
local atm=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atm.Density=.28
atm.Offset=.15
atm.Haze=1.6
atm.Glare=.08
atm.Color=Color3.fromRGB(205,218,240)
atm.Decay=Color3.fromRGB(92,103,135)
atm.Parent=Lighting

print("[Smash Legends] Terrain + skyline map pass loaded")
