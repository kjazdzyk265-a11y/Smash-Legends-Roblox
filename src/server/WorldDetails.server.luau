local world=workspace:WaitForChild("SmashWorld")
local root=world:FindFirstChild("WorldDetails")
if root then root:Destroy() end
root=Instance.new("Folder"); root.Name="WorldDetails"; root.Parent=world

local function part(name,size,cf,color,material,parent)
	local p=Instance.new("Part")
	p.Name=name; p.Size=size; p.CFrame=cf; p.Anchored=true; p.Color=color; p.Material=material or Enum.Material.SmoothPlastic
	p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent or root
	return p
end
local function ball(name,pos,size,color,material,parent)
	local p=part(name,Vector3.new(size,size,size),CFrame.new(pos),color,material,parent); p.Shape=Enum.PartType.Ball; return p
end
local function billboard(parent,text,color,offset)
	local g=Instance.new("BillboardGui"); g.Size=UDim2.fromOffset(220,55); g.StudsOffset=offset or Vector3.new(0,4,0); g.AlwaysOnTop=true; g.MaxDistance=130; g.Parent=parent
	local l=Instance.new("TextLabel"); l.Size=UDim2.fromScale(1,1); l.BackgroundTransparency=1; l.Text=text; l.TextColor3=color; l.TextStrokeTransparency=.15; l.Font=Enum.Font.GothamBlack; l.TextScaled=true; l.Parent=g
end

-- World boundary silhouettes so the map no longer floats in an empty plane.
local bands={
	{0,230,Color3.fromRGB(66,130,67),Enum.Material.Grass},
	{230,475,Color3.fromRGB(79,83,88),Enum.Material.Concrete},
	{475,710,Color3.fromRGB(44,49,72),Enum.Material.Slate},
	{710,945,Color3.fromRGB(57,43,42),Enum.Material.Slate},
	{945,1200,Color3.fromRGB(36,31,56),Enum.Material.Slate},
}
for _,b in ipairs(bands) do
	local z0,z1,color,mat=b[1],b[2],b[3],b[4]
	local len=z1-z0
	for _,x in ipairs({-92,92}) do
		part("WorldWall",Vector3.new(26,18,len),CFrame.new(x,7,z0+len/2),color,mat)
	end
end

-- Decorative stepping stones and road dressing.
for z=105,220,18 do
	for _,x in ipairs({-11,11}) do
		part("GreenStone",Vector3.new(4,.35,6),CFrame.new(x,.32,z)*CFrame.Angles(0,math.rad((z+x)%13),0),Color3.fromRGB(202,188,145),Enum.Material.Cobblestone)
	end
end
for z=255,470,22 do
	for _,x in ipairs({-16,16}) do
		part("CityCurb",Vector3.new(3,.8,12),CFrame.new(x,.4,z),Color3.fromRGB(182,181,176),Enum.Material.Concrete)
	end
end
for z=490,705,20 do
	for _,x in ipairs({-12,12}) do
		local shard=part("FloorShard",Vector3.new(1.4,4+(z%5),1.4),CFrame.new(x,2,z)*CFrame.Angles(math.rad(7),0,math.rad((z%3-1)*8)),Color3.fromRGB(85,218,246),Enum.Material.Neon)
		shard.CanCollide=false
	end
end
for z=725,940,24 do
	for _,x in ipairs({-14,14}) do
		part("ForgePlate",Vector3.new(8,.45,12),CFrame.new(x,.3,z),Color3.fromRGB(65,61,61),Enum.Material.DiamondPlate)
	end
end
for z=960,1180,18 do
	for _,x in ipairs({-10,10}) do
		local rune=part("VoidTile",Vector3.new(5,.18,7),CFrame.new(x,.27,z),Color3.fromRGB(129,60,213),Enum.Material.Neon)
		rune.Transparency=.16
	end
end

-- Small reward-looking points of interest to pull the player forward visually.
local points={
	{Vector3.new(34,3,145),"SMASH YARD",Color3.fromRGB(255,210,74)},
	{Vector3.new(-35,3,335),"HEAVY OBJECTS",Color3.fromRGB(255,143,52)},
	{Vector3.new(34,3,575),"GEM VEIN",Color3.fromRGB(78,220,255)},
	{Vector3.new(-34,3,810),"FORGE LINE",Color3.fromRGB(255,83,35)},
	{Vector3.new(34,3,1040),"VOID ALTAR",Color3.fromRGB(188,77,255)},
}
for _,v in ipairs(points) do
	local pedestal=part("POI",Vector3.new(12,5,12),CFrame.new(v[1]),Color3.fromRGB(42,44,53),Enum.Material.Slate)
	local orb=ball("POIGlow",v[1]+Vector3.new(0,5,0),3.4,v[3],Enum.Material.Neon)
	orb.CanCollide=false
	billboard(orb,v[2],v[3],Vector3.new(0,4.5,0))
end

-- Bridges at zone transitions.
local transitions={230,475,710,945}
for i,z in ipairs(transitions) do
	local color=({Color3.fromRGB(135,116,90),Color3.fromRGB(84,91,105),Color3.fromRGB(76,61,59),Color3.fromRGB(62,49,82)})[i]
	part("TransitionBridge",Vector3.new(42,1.2,18),CFrame.new(0,.6,z),color,Enum.Material.Cobblestone)
	for _,x in ipairs({-20,20}) do
		part("BridgeRail",Vector3.new(2,5,18),CFrame.new(x,2.5,z),color,Enum.Material.Slate)
	end
end

print("[Smash Legends] world details loaded")
