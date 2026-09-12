local Workspace=game:GetService("Workspace")
local CollectionService=game:GetService("CollectionService")

local world=Workspace:WaitForChild("SmashWorld")
local map=world:WaitForChild("Map")

local function detailPart(parent,name,size,cf,color,material,shape)
	local p=Instance.new("Part")
	p.Name=name
	p.Size=size
	p.CFrame=cf
	p.Anchored=true
	p.CanCollide=false
	p.CanQuery=false
	p.CanTouch=false
	p.Massless=true
	p.Color=color
	p.Material=material or Enum.Material.SmoothPlastic
	p.TopSurface=Enum.SurfaceType.Smooth
	p.BottomSurface=Enum.SurfaceType.Smooth
	if shape then p.Shape=shape end
	p.Parent=parent
	return p
end

local decorated={}
local function decorateBreakable(base)
	if decorated[base] or not base:IsA("BasePart") then return end
	decorated[base]=true
	local kind=base:GetAttribute("Kind")
	if not kind then return end
	local folder=Instance.new("Folder")
	folder.Name="VisualDetail"
	folder.Parent=base
	if kind=="Crate" then
		for _,x in ipairs({-.38,.38}) do
			detailPart(folder,"Brace",Vector3.new(.45,base.Size.Y*.92,base.Size.Z*1.015),base.CFrame*CFrame.new(base.Size.X*x,0,0),Color3.fromRGB(104,65,37),Enum.Material.WoodPlanks)
		end
		for _,y in ipairs({-.36,.36}) do
			detailPart(folder,"Band",Vector3.new(base.Size.X*1.01,.42,base.Size.Z*1.02),base.CFrame*CFrame.new(0,base.Size.Y*y,0),Color3.fromRGB(112,70,39),Enum.Material.WoodPlanks)
		end
	elseif kind=="Barrel" then
		for _,y in ipairs({-.33,.33}) do
			local band=detailPart(folder,"MetalBand",Vector3.new(base.Size.X*1.08,.38,base.Size.Z*1.08),base.CFrame*CFrame.new(0,base.Size.Y*y,0),Color3.fromRGB(62,68,73),Enum.Material.Metal)
			band.Shape=Enum.PartType.Cylinder
		end
	elseif kind=="Safe" then
		detailPart(folder,"Door",Vector3.new(base.Size.X*.76,base.Size.Y*.72,.35),base.CFrame*CFrame.new(0,0,-base.Size.Z*.52),Color3.fromRGB(49,58,65),Enum.Material.Metal)
		local dial=detailPart(folder,"Dial",Vector3.new(1.6,.42,1.6),base.CFrame*CFrame.new(0,0,-base.Size.Z*.76)*CFrame.Angles(math.rad(90),0,0),Color3.fromRGB(180,186,190),Enum.Material.Metal,Enum.PartType.Cylinder)
	elseif kind=="Crystal" then
		for i=1,4 do
			local angle=(i-1)*math.pi/2
			local shard=detailPart(folder,"Shard",Vector3.new(base.Size.X*.34,base.Size.Y*.62,base.Size.Z*.34),base.CFrame*CFrame.new(math.cos(angle)*base.Size.X*.42,-base.Size.Y*.08,math.sin(angle)*base.Size.Z*.42)*CFrame.Angles(math.sin(angle)*.25,0,math.cos(angle)*.25),Color3.fromRGB(124,242,255),Enum.Material.Neon)
			shard.Transparency=.08
		end
	elseif kind=="Rock" then
		for i=1,3 do
			local chip=detailPart(folder,"RockChip",Vector3.new(base.Size.X*.42,base.Size.Y*.36,base.Size.Z*.42),base.CFrame*CFrame.new((i-2)*base.Size.X*.26,base.Size.Y*.38,(i%2==0 and 1 or -1)*base.Size.Z*.22)*CFrame.Angles(i*.2,i*.7,i*.15),base.Color:Lerp(Color3.new(1,1,1),.08),Enum.Material.Slate)
		end
	elseif kind=="Fence" then
		for i=-2,2 do detailPart(folder,"Picket",Vector3.new(1.3,base.Size.Y*1.35,base.Size.Z*.7),base.CFrame*CFrame.new(i*2.4,base.Size.Y*.15,0),base.Color,Enum.Material.WoodPlanks) end
	elseif kind=="Gate" then
		for x=-2,2 do detailPart(folder,"GatePillar",Vector3.new(4,base.Size.Y*1.12,base.Size.Z*1.08),base.CFrame*CFrame.new(x*(base.Size.X*.18),0,0),base.Color:Lerp(Color3.new(0,0,0),.12),base.Material) end
		local boss=detailPart(folder,"BossEmblem",Vector3.new(9,9,1),base.CFrame*CFrame.new(0,2,-base.Size.Z*.58),Color3.fromRGB(255,170,55),Enum.Material.Neon)
		boss.Shape=Enum.PartType.Ball
	end
end

for _,d in ipairs(world:GetDescendants()) do if d:IsA("BasePart") and d:GetAttribute("Breakable") then decorateBreakable(d) end end
world.DescendantAdded:Connect(function(d) task.defer(function() if d:IsA("BasePart") and d:GetAttribute("Breakable") then decorateBreakable(d) end end) end)

-- Landmark pass: stronger silhouettes at transitions.
local landmarkSpecs={
	{"GREENYARD",Vector3.new(-58,0,180),Color3.fromRGB(63,146,67),"Windmill"},
	{"CONSTRUCTION CITY",Vector3.new(55,0,400),Color3.fromRGB(255,147,43),"Crane"},
	{"CRYSTAL CAVES",Vector3.new(-52,0,650),Color3.fromRGB(75,224,255),"CrystalSpire"},
	{"MAGMA FORGE",Vector3.new(53,0,880),Color3.fromRGB(255,78,39),"ForgeTower"},
	{"VOID TEMPLE",Vector3.new(0,0,1135),Color3.fromRGB(180,78,255),"VoidCrown"},
}
for _,spec in ipairs(landmarkSpecs) do
	local parent=map:FindFirstChild(spec[1]) or map
	local pos,color,name=spec[2],spec[3],spec[4]
	local model=Instance.new("Model"); model.Name=name; model.Parent=parent
	if name=="Windmill" then
		detailPart(model,"Tower",Vector3.new(7,27,7),CFrame.new(pos+Vector3.new(0,13.5,0)),Color3.fromRGB(205,190,160),Enum.Material.WoodPlanks)
		for i=0,3 do detailPart(model,"Blade",Vector3.new(2,18,1),CFrame.new(pos+Vector3.new(0,22,-4))*CFrame.Angles(0,0,i*math.pi/2),Color3.fromRGB(235,225,195),Enum.Material.WoodPlanks) end
	elseif name=="Crane" then
		detailPart(model,"Mast",Vector3.new(5,38,5),CFrame.new(pos+Vector3.new(0,19,0)),Color3.fromRGB(232,164,50),Enum.Material.Metal)
		detailPart(model,"Boom",Vector3.new(34,3,3),CFrame.new(pos+Vector3.new(-8,34,0)),Color3.fromRGB(232,164,50),Enum.Material.Metal)
	elseif name=="CrystalSpire" then
		for i=1,5 do local s=detailPart(model,"Spire",Vector3.new(5,20+i*3,5),CFrame.new(pos+Vector3.new((i-3)*4,(20+i*3)/2,0))*CFrame.Angles(0,0,(i-3)*.08),color,Enum.Material.Neon); s.Transparency=.08 end
	elseif name=="ForgeTower" then
		detailPart(model,"Tower",Vector3.new(14,32,14),CFrame.new(pos+Vector3.new(0,16,0)),Color3.fromRGB(65,54,52),Enum.Material.Basalt)
		for i=0,3 do detailPart(model,"Vent",Vector3.new(4,18,4),CFrame.new(pos+Vector3.new(math.cos(i*math.pi/2)*9,24,math.sin(i*math.pi/2)*9)),color,Enum.Material.Neon) end
	else
		for i=0,5 do detailPart(model,"Crown",Vector3.new(4,28,4),CFrame.new(pos+Vector3.new(math.cos(i*math.pi/3)*13,14,math.sin(i*math.pi/3)*13))*CFrame.Angles(0,0,(i%2==0 and .18 or -.18)),color,Enum.Material.Neon) end
	end
end

print("[Smash Legends] world detail pass ready")
