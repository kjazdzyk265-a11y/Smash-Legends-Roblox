local Workspace=game:GetService("Workspace")
local TweenService=game:GetService("TweenService")

local world=Workspace:WaitForChild("SmashWorld")
local map=world:WaitForChild("Map")

local function part(parent,name,size,cf,color,material,transparency)
	local p=Instance.new("Part")
	p.Name=name
	p.Size=size
	p.CFrame=cf
	p.Anchored=true
	p.CanCollide=false
	p.CanTouch=false
	p.CanQuery=false
	p.Color=color
	p.Material=material or Enum.Material.SmoothPlastic
	p.Transparency=transparency or 0
	p.TopSurface=Enum.SurfaceType.Smooth
	p.BottomSurface=Enum.SurfaceType.Smooth
	p.Parent=parent
	return p
end

local function weldVisual(base,visual,offset)
	visual.Anchored=false
	visual.CFrame=base.CFrame*offset
	local w=Instance.new("WeldConstraint")
	w.Part0=base
	w.Part1=visual
	w.Parent=visual
end

local function addCrateDetail(p)
	for _,rot in ipairs({0,90}) do
		local plank=part(p,"CrateBrace",Vector3.new(p.Size.X*1.03,.32,.36),p.CFrame,Color3.fromRGB(94,57,32),Enum.Material.Wood)
		weldVisual(p,plank,CFrame.new(0,0,-p.Size.Z*.51)*CFrame.Angles(0,0,math.rad(rot)))
	end
	for _,y in ipairs({-.32,.32}) do
		local band=part(p,"CrateBand",Vector3.new(.28,p.Size.Y*.92,p.Size.Z*1.02),p.CFrame,Color3.fromRGB(116,70,39),Enum.Material.WoodPlanks)
		weldVisual(p,band,CFrame.new(y*p.Size.X,0,0))
	end
end

local function addBarrelDetail(p)
	for _,y in ipairs({-.36,0,.36}) do
		local ring=part(p,"MetalRing",Vector3.new(p.Size.X*1.08,.35,p.Size.Z*1.08),p.CFrame,Color3.fromRGB(58,64,72),Enum.Material.Metal)
		ring.Shape=Enum.PartType.Cylinder
		weldVisual(p,ring,CFrame.new(0,y*p.Size.Y,0)*CFrame.Angles(0,0,math.rad(90)))
	end
end

local function addSafeDetail(p)
	local door=part(p,"SafeDoor",Vector3.new(p.Size.X*.72,p.Size.Y*.72,.35),p.CFrame,Color3.fromRGB(45,55,65),Enum.Material.Metal)
	weldVisual(p,door,CFrame.new(0,0,-p.Size.Z*.53))
	local dial=part(p,"Dial",Vector3.new(1.45,.35,1.45),p.CFrame,Color3.fromRGB(185,196,205),Enum.Material.Metal)
	dial.Shape=Enum.PartType.Cylinder
	weldVisual(p,dial,CFrame.new(0,0,-p.Size.Z*.76)*CFrame.Angles(math.rad(90),0,0))
end

local function addCrystalDetail(p)
	for i=1,3 do
		local shard=part(p,"Shard",Vector3.new(1.2,math.max(3,p.Size.Y*.45),1.2),p.CFrame,Color3.fromRGB(120,240,255),Enum.Material.Neon,.08)
		local x=(i-2)*1.9
		weldVisual(p,shard,CFrame.new(x,-p.Size.Y*.08,(i%2==0 and 1.2 or -1.1))*CFrame.Angles(0,0,math.rad((i-2)*10)))
	end
end

local function addRockDetail(p)
	for i=1,3 do
		local chip=part(p,"RockChunk",Vector3.new(p.Size.X*.45,p.Size.Y*.34,p.Size.Z*.42),p.CFrame,p.Color:Lerp(Color3.new(0,0,0),.12),Enum.Material.Slate)
		weldVisual(p,chip,CFrame.new((i-2)*p.Size.X*.2,(i%2)*p.Size.Y*.22-p.Size.Y*.1,(i==2 and -.22 or .2)*p.Size.Z)*CFrame.Angles(math.rad(i*9),math.rad(i*17),math.rad(i*7)))
	end
end

local function addGateDetail(p)
	local archColor=p.Color:Lerp(Color3.new(0,0,0),.18)
	for _,x in ipairs({-.43,.43}) do
		local tower=part(p,"GateTower",Vector3.new(p.Size.X*.11,p.Size.Y*1.22,p.Size.Z*1.35),p.CFrame,archColor,Enum.Material.Slate)
		weldVisual(p,tower,CFrame.new(x*p.Size.X,0,0))
		local cap=part(p,"GateCap",Vector3.new(p.Size.X*.15,1.2,p.Size.Z*1.55),p.CFrame,p.Color:Lerp(Color3.new(1,1,1),.08),Enum.Material.Slate)
		weldVisual(p,cap,CFrame.new(x*p.Size.X,p.Size.Y*.62,0))
	end
	local crown=part(p,"GateCrown",Vector3.new(p.Size.X*.68,2.2,p.Size.Z*1.25),p.CFrame,archColor,Enum.Material.Slate)
	weldVisual(p,crown,CFrame.new(0,p.Size.Y*.47,0))
end

local decorated={}
local function decorate(p)
	if decorated[p] or not p:IsA("BasePart") or not p:GetAttribute("Breakable") then return end
	decorated[p]=true
	local kind=p:GetAttribute("Kind") or p.Name
	if kind=="Crate" then addCrateDetail(p)
	elseif kind=="Barrel" then addBarrelDetail(p)
	elseif kind=="Safe" then addSafeDetail(p)
	elseif kind=="Crystal" then addCrystalDetail(p)
	elseif kind=="Rock" then addRockDetail(p)
	elseif kind=="Gate" then addGateDetail(p) end
end

for _,d in ipairs(map:GetDescendants()) do decorate(d) end
map.DescendantAdded:Connect(function(d) task.defer(decorate,d) end)

local function makeEggPedestal(parent,pos,accent,label)
	local model=Instance.new("Model"); model.Name=label.."EggPedestal"; model.Parent=parent
	part(model,"Base",Vector3.new(12,1,12),CFrame.new(pos),Color3.fromRGB(45,49,61),Enum.Material.Slate)
	part(model,"Step",Vector3.new(8,1.2,8),CFrame.new(pos+Vector3.new(0,1.05,0)),Color3.fromRGB(65,70,86),Enum.Material.Slate)
	local ring=part(model,"GlowRing",Vector3.new(6,.25,6),CFrame.new(pos+Vector3.new(0,1.78,0)),accent,Enum.Material.Neon,.12); ring.Shape=Enum.PartType.Cylinder
	local egg=part(model,"DisplayEgg",Vector3.new(4.2,5.5,4.2),CFrame.new(pos+Vector3.new(0,4.4,0)),accent,Enum.Material.SmoothPlastic)
	egg.Shape=Enum.PartType.Ball
	local light=Instance.new("PointLight"); light.Color=accent; light.Range=18; light.Brightness=1.5; light.Parent=egg
	TweenService:Create(egg,TweenInfo.new(2.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{CFrame=egg.CFrame*CFrame.new(0,.7,0)}):Play()
end

local eggSpecs={
	{"GREENYARD",Vector3.new(35,0.5,78),Color3.fromRGB(255,220,95),"Greenyard"},
	{"CONSTRUCTION CITY",Vector3.new(-34,0.5,305),Color3.fromRGB(255,145,55),"Construction"},
	{"CRYSTAL CAVES",Vector3.new(34,0.5,555),Color3.fromRGB(92,229,255),"Crystal"},
	{"MAGMA FORGE",Vector3.new(-34,0.5,785),Color3.fromRGB(255,88,46),"Magma"},
	{"VOID TEMPLE",Vector3.new(34,0.5,1025),Color3.fromRGB(188,83,255),"Void"},
}
for _,spec in ipairs(eggSpecs) do
	local zone=map:FindFirstChild(spec[1])
	if zone then makeEggPedestal(zone,spec[2],spec[3],spec[4]) end
end

print("[Smash Legends] World art pass loaded")
