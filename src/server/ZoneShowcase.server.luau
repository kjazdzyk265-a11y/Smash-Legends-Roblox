local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")

local world=Workspace:WaitForChild("SmashWorld")
local map=world:WaitForChild("Map")

local function p(parent,name,size,cf,color,material,canCollide)
	local x=Instance.new("Part")
	x.Name=name; x.Size=size; x.CFrame=cf; x.Anchored=true; x.CanCollide=canCollide==true; x.Color=color; x.Material=material or Enum.Material.SmoothPlastic
	x.TopSurface=Enum.SurfaceType.Smooth; x.BottomSurface=Enum.SurfaceType.Smooth; x.Parent=parent
	return x
end

local function beam(parent,a,b,color,width)
	local mid=(a+b)/2; local len=(b-a).Magnitude
	local part=p(parent,"Beam",Vector3.new(width,width,len),CFrame.lookAt(mid,b),color,Enum.Material.Neon,false)
	return part
end

local function greenyard(zone)
	local barn=Instance.new("Model"); barn.Name="Farmstead"; barn.Parent=zone
	p(barn,"Barn",Vector3.new(34,18,26),CFrame.new(-50,9,118),Color3.fromRGB(174,63,48),Enum.Material.WoodPlanks,true)
	p(barn,"Roof",Vector3.new(38,2,30),CFrame.new(-50,19,118)*CFrame.Angles(0,0,math.rad(12)),Color3.fromRGB(74,55,48),Enum.Material.Slate,false)
	for i=1,4 do
		p(barn,"FencePost",Vector3.new(1.1,5,1.1),CFrame.new(44+(i-1)*6,2.5,125),Color3.fromRGB(116,77,45),Enum.Material.Wood,true)
		if i<4 then p(barn,"FenceRail",Vector3.new(6,1,1),CFrame.new(47+(i-1)*6,3,125),Color3.fromRGB(145,96,55),Enum.Material.Wood,true) end
	end
	for i=1,5 do
		local hay=p(barn,"HayBale",Vector3.new(5,4,5),CFrame.new(-50+(i%2)*6,2,145+i*3),Color3.fromRGB(222,188,76),Enum.Material.Grass,true)
		hay.Shape=Enum.PartType.Cylinder; hay.CFrame*=CFrame.Angles(0,0,math.rad(90))
	end
end

local function construction(zone)
	local site=Instance.new("Model"); site.Name="ConstructionSetpiece"; site.Parent=zone
	for i=1,5 do
		local h=22+i*5
		p(site,"Tower",Vector3.new(20,h,20),CFrame.new(i%2==0 and -56 or 56,h/2,275+i*34),Color3.fromRGB(105+i*6,110+i*4,118+i*3),Enum.Material.Concrete,true)
		for floor=1,math.floor(h/7) do
			p(site,"WindowBand",Vector3.new(20.3,1.2,20.3),CFrame.new(i%2==0 and -56 or 56,floor*7,275+i*34),Color3.fromRGB(45,50,58),Enum.Material.Metal,false)
		end
	end
	local mast=p(site,"CraneMast",Vector3.new(4,58,4),CFrame.new(-44,29,370),Color3.fromRGB(241,176,55),Enum.Material.Metal,true)
	local jib=p(site,"CraneJib",Vector3.new(54,3,3),CFrame.new(-20,56,370),Color3.fromRGB(241,176,55),Enum.Material.Metal,false)
	local cable=p(site,"CraneCable",Vector3.new(.4,24,.4),CFrame.new(3,44,370),Color3.fromRGB(46,49,55),Enum.Material.Metal,false)
	p(site,"CraneHook",Vector3.new(2,2,2),CFrame.new(3,31.5,370),Color3.fromRGB(65,68,74),Enum.Material.Metal,false)
end

local function crystal(zone)
	local cave=Instance.new("Model"); cave.Name="CrystalCathedral"; cave.Parent=zone
	for i=1,9 do
		local side=i%2==0 and -1 or 1
		local h=18+(i%4)*7
		local c=p(cave,"CrystalPillar",Vector3.new(5,h,5),CFrame.new(side*(35+(i%3)*9),h/2,500+i*20)*CFrame.Angles(0,0,math.rad(side*(6+i))),Color3.fromRGB(78,220,255),Enum.Material.Neon,true)
		local light=Instance.new("PointLight"); light.Color=c.Color; light.Brightness=.8; light.Range=16; light.Parent=c
	end
	for i=1,4 do
		local z=540+i*42
		beam(cave,Vector3.new(-66,18,z),Vector3.new(66,18,z),Color3.fromRGB(65,105,180),2)
	end
end

local function magma(zone)
	local forge=Instance.new("Model"); forge.Name="GrandForge"; forge.Parent=zone
	for _,x in ipairs({-54,54}) do
		for i=1,4 do
			local z=745+i*45
			p(forge,"ForgePillar",Vector3.new(10,28,10),CFrame.new(x,14,z),Color3.fromRGB(66,58,58),Enum.Material.Basalt,true)
			local cap=p(forge,"MoltenCap",Vector3.new(11,2,11),CFrame.new(x,28,z),Color3.fromRGB(255,83,36),Enum.Material.Neon,false)
			local light=Instance.new("PointLight"); light.Color=cap.Color; light.Range=20; light.Brightness=2; light.Parent=cap
		end
	end
	for i=1,5 do
		local z=760+i*34
		p(forge,"LavaCanal",Vector3.new(7,.35,26),CFrame.new(i%2==0 and -24 or 24,.3,z),Color3.fromRGB(255,72,28),Enum.Material.Neon,false)
		p(forge,"MetalBridge",Vector3.new(18,1.2,8),CFrame.new(i%2==0 and -24 or 24,1.1,z),Color3.fromRGB(76,77,82),Enum.Material.DiamondPlate,true)
	end
end

local function void(zone)
	local temple=Instance.new("Model"); temple.Name="VoidSanctum"; temple.Parent=zone
	for i=1,7 do
		local z=965+i*28
		for _,x in ipairs({-48,48}) do
			local ob=p(temple,"Obelisk",Vector3.new(7,25+(i%2)*6,7),CFrame.new(x,(25+(i%2)*6)/2,z)*CFrame.Angles(0,math.rad(i*11),0),Color3.fromRGB(59,50,82),Enum.Material.Slate,true)
			local rune=p(temple,"VoidRune",Vector3.new(7.2,1,7.2),ob.CFrame*CFrame.new(0,ob.Size.Y/2+.55,0),Color3.fromRGB(185,78,255),Enum.Material.Neon,false)
			local light=Instance.new("PointLight"); light.Color=rune.Color; light.Range=18; light.Brightness=1.4; light.Parent=rune
		end
	end
	local core=p(temple,"VoidCore",Vector3.new(16,16,16),CFrame.new(0,13,1135),Color3.fromRGB(148,63,255),Enum.Material.Neon,false); core.Shape=Enum.PartType.Ball
	local light=Instance.new("PointLight"); light.Color=core.Color; light.Range=42; light.Brightness=3; light.Parent=core
end

local builders={
	["GREENYARD"]=greenyard,
	["CONSTRUCTION CITY"]=construction,
	["CRYSTAL CAVES"]=crystal,
	["MAGMA FORGE"]=magma,
	["VOID TEMPLE"]=void,
}
for name,fn in pairs(builders) do local z=map:FindFirstChild(name); if z then fn(z) end end

local bloom=Lighting:FindFirstChild("SmashBloom") or Instance.new("BloomEffect")
bloom.Name="SmashBloom"; bloom.Intensity=.65; bloom.Size=28; bloom.Threshold=1.25; bloom.Parent=Lighting
local cc=Lighting:FindFirstChild("SmashColor") or Instance.new("ColorCorrectionEffect")
cc.Name="SmashColor"; cc.Brightness=.015; cc.Contrast=.08; cc.Saturation=.12; cc.Parent=Lighting
local rays=Lighting:FindFirstChild("SmashRays") or Instance.new("SunRaysEffect")
rays.Name="SmashRays"; rays.Intensity=.035; rays.Spread=.75; rays.Parent=Lighting

print("[Smash Legends] Zone showcase setpieces loaded")
