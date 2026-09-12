local workspace=game:GetService("Workspace")

local world=workspace:WaitForChild("SmashWorld")
local map=world:WaitForChild("Map")
local polish=map:FindFirstChild("Polish") or Instance.new("Folder")
polish.Name="Polish"
polish.Parent=map

local function part(name,size,pos,color,material,parent)
	local p=Instance.new("Part")
	p.Name=name
	p.Size=size
	p.Position=pos
	p.Anchored=true
	p.Material=material or Enum.Material.SmoothPlastic
	p.Color=color
	p.TopSurface=Enum.SurfaceType.Smooth
	p.BottomSurface=Enum.SurfaceType.Smooth
	p.Parent=parent or polish
	return p
end
local function neonOrb(pos,color,scale)
	local p=part("AmbientGlow",Vector3.new(3,3,3)*(scale or 1),pos,color,Enum.Material.Neon)
	p.Shape=Enum.PartType.Ball
	p.CanCollide=false
	local light=Instance.new("PointLight")
	light.Color=color
	light.Range=16*(scale or 1)
	light.Brightness=1.7
	light.Parent=p
	return p
end
local function lamp(pos,color)
	part("LampPost",Vector3.new(1,10,1),pos+Vector3.new(0,5,0),Color3.fromRGB(55,60,69),Enum.Material.Metal)
	neonOrb(pos+Vector3.new(0,10.5,0),color,.8)
end

-- Greenyard: fence framing, stones and warm lamps.
for i=1,8 do
	local z=18+i*24
	part("FencePost",Vector3.new(2,5,2),Vector3.new(-72,2.5,z),Color3.fromRGB(126,84,49),Enum.Material.Wood)
	part("FencePost",Vector3.new(2,5,2),Vector3.new(72,2.5,z),Color3.fromRGB(126,84,49),Enum.Material.Wood)
	if i%2==0 then lamp(Vector3.new(i%4==0 and -18 or 18,0,z),Color3.fromRGB(255,214,122)) end
end

-- Construction: road markings, barriers and industrial lights.
for i=1,9 do
	local z=240+i*24
	part("RoadMark",Vector3.new(1.2,.15,9),Vector3.new(0,.35,z),Color3.fromRGB(245,218,99),Enum.Material.Neon)
	if i%2==1 then
		part("Barrier",Vector3.new(9,3,2),Vector3.new(i%4==1 and -41 or 41,1.5,z+5),Color3.fromRGB(244,128,42),Enum.Material.Metal)
	end
	lamp(Vector3.new(i%2==0 and -58 or 58,0,z),Color3.fromRGB(255,168,83))
end

-- Crystal Caves: clusters and overhead glows.
for i=1,14 do
	local side=i%2==0 and -1 or 1
	local z=480+i*15
	local base=Vector3.new(side*(46+(i%3)*8),0,z)
	for j=1,3 do
		local c=part("CrystalShard",Vector3.new(2.2,7+j*2,2.2),base+Vector3.new((j-2)*2.4,(7+j*2)/2,0),Color3.fromRGB(77,219,255),Enum.Material.Neon)
		c.CFrame*=CFrame.Angles(0,0,math.rad((j-2)*12))
	end
	if i%3==0 then neonOrb(Vector3.new(0,13,z),Color3.fromRGB(94,188,255),1.1) end
end

-- Magma Forge: lava trenches and forge pylons.
for i=1,7 do
	local z=720+i*29
	part("LavaChannel",Vector3.new(18,.35,5),Vector3.new(i%2==0 and -40 or 40,.18,z),Color3.fromRGB(255,74,27),Enum.Material.Neon)
	local pylon=part("ForgePylon",Vector3.new(7,16,7),Vector3.new(i%2==0 and 61 or -61,8,z),Color3.fromRGB(70,58,55),Enum.Material.Basalt)
	local cap=part("ForgeGlow",Vector3.new(8,1.2,8),pylon.Position+Vector3.new(0,8.6,0),Color3.fromRGB(255,92,37),Enum.Material.Neon)
	cap.CanCollide=false
end

-- Void Temple: ritual rings and arches.
for i=1,8 do
	local z=950+i*27
	local left=part("VoidColumn",Vector3.new(6,18,6),Vector3.new(-53,9,z),Color3.fromRGB(67,55,91),Enum.Material.Slate)
	local right=part("VoidColumn",Vector3.new(6,18,6),Vector3.new(53,9,z),Color3.fromRGB(67,55,91),Enum.Material.Slate)
	part("VoidArch",Vector3.new(112,5,6),Vector3.new(0,18,z),Color3.fromRGB(67,55,91),Enum.Material.Slate)
	if i%2==0 then
		neonOrb(left.Position+Vector3.new(0,10,0),Color3.fromRGB(177,73,255),.8)
		neonOrb(right.Position+Vector3.new(0,10,0),Color3.fromRGB(177,73,255),.8)
	end
end

-- Final vista gives the run a visible destination.
local finalBase=part("FinalDais",Vector3.new(48,3,48),Vector3.new(0,1.5,1168),Color3.fromRGB(54,45,76),Enum.Material.Slate)
for i=0,7 do
	local a=math.rad(i*45)
	neonOrb(finalBase.Position+Vector3.new(math.cos(a)*19,5,math.sin(a)*19),Color3.fromRGB(191,82,255),.65)
end

print("[Smash Legends] map polish pass ready")
