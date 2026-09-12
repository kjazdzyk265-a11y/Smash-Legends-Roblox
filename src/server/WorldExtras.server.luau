local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")

local Pets=require(ReplicatedStorage.Shared.Pets)
local ProgressionConfig=require(ReplicatedStorage.Shared.ProgressionConfig)
local net=ReplicatedStorage:WaitForChild("SmashNet")
local state=net:WaitForChild("State")

local world=workspace:WaitForChild("SmashWorld")
local map=world:WaitForChild("Map")
local extras=map:FindFirstChild("ProgressionExtras") or Instance.new("Folder")
extras.Name="ProgressionExtras"
extras.Parent=map

local function label(part,text,color)
	local gui=Instance.new("BillboardGui")
	gui.Size=UDim2.fromOffset(240,72)
	gui.StudsOffset=Vector3.new(0,6,0)
	gui.AlwaysOnTop=true
	gui.MaxDistance=100
	gui.Parent=part
	local t=Instance.new("TextLabel")
	t.Size=UDim2.fromScale(1,1)
	t.BackgroundTransparency=1
	t.Text=text
	t.TextColor3=color
	t.TextStrokeColor3=Color3.fromRGB(22,24,35)
	t.TextStrokeTransparency=.2
	t.Font=Enum.Font.GothamBlack
	t.TextScaled=true
	t.Parent=gui
end

local function eggStation(spec)
	local model=Instance.new("Model")
	model.Name=spec.Egg.."EggStation"
	model.Parent=extras
	local base=Instance.new("Part")
	base.Name="Base"
	base.Size=Vector3.new(14,2,14)
	base.Position=spec.Position+Vector3.new(0,1,0)
	base.Anchored=true
	base.Material=Enum.Material.Slate
	base.Color=Color3.fromRGB(50,55,67)
	base.Parent=model
	local egg=Instance.new("Part")
	egg.Name="Egg"
	egg.Shape=Enum.PartType.Ball
	egg.Size=Vector3.new(7,9,7)
	egg.Position=spec.Position+Vector3.new(0,6,0)
	egg.Anchored=true
	egg.Material=Enum.Material.SmoothPlastic
	egg.Color=spec.Color
	egg.Parent=model
	local band=Instance.new("Part")
	band.Name="Glow"
	band.Shape=Enum.PartType.Ball
	band.Size=Vector3.new(7.4,4,7.4)
	band.Position=egg.Position
	band.Anchored=true
	band.CanCollide=false
	band.Material=Enum.Material.Neon
	band.Color=spec.Color
	band.Transparency=.15
	band.Parent=model
	local config=Pets.Eggs[spec.Egg]
	label(egg,string.upper(spec.Egg).." EGG\n"..tostring(config.Price).." COINS",spec.Color)
	local prompt=Instance.new("ProximityPrompt")
	prompt.ActionText="View Egg"
	prompt.ObjectText=spec.Egg.." Egg"
	prompt.MaxActivationDistance=12
	prompt.RequiresLineOfSight=false
	prompt.HoldDuration=.15
	prompt.Parent=egg
	prompt.Triggered:Connect(function(player)
		state:FireClient(player,"EggShop",{Egg=spec.Egg,Config=config})
	end)
end

for _,spec in ipairs(ProgressionConfig.EggStations) do eggStation(spec) end

-- Rebirth shrine at the end of the expedition.
local shrine=Instance.new("Part")
shrine.Name="RebirthShrine"
shrine.Size=Vector3.new(22,3,22)
shrine.Position=Vector3.new(0,1.5,1170)
shrine.Anchored=true
shrine.Material=Enum.Material.Neon
shrine.Color=Color3.fromRGB(191,84,255)
shrine.Parent=extras
label(shrine,"REBIRTH SHRINE\n25K STRENGTH",Color3.fromRGB(231,180,255))
local prompt=Instance.new("ProximityPrompt")
prompt.ActionText="Rebirth"
prompt.ObjectText="Rebirth Shrine"
prompt.MaxActivationDistance=14
prompt.RequiresLineOfSight=false
prompt.Parent=shrine
prompt.Triggered:Connect(function(player)
	state:FireClient(player,"RebirthConfirm",true)
end)

-- Zone checkpoints make long sessions less annoying after death.
for index,spec in ipairs({
	{z=30,name="Greenyard"},{z=255,name="Construction City"},{z=500,name="Crystal Caves"},{z=735,name="Magma Forge"},{z=970,name="Void Temple"}
}) do
	local pad=Instance.new("Part")
	pad.Name="Checkpoint"..index
	pad.Size=Vector3.new(12,.6,12)
	pad.Position=Vector3.new(0,.35,spec.z)
	pad.Anchored=true
	pad.Material=Enum.Material.Neon
	pad.Color=Color3.fromRGB(90,220,140)
	pad.Transparency=.2
	pad.Parent=extras
	pad.Touched:Connect(function(hit)
		local char=hit.Parent
		local player=char and Players:GetPlayerFromCharacter(char)
		if player then player:SetAttribute("CheckpointZ",spec.z) end
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local root=char:WaitForChild("HumanoidRootPart",5)
		local z=player:GetAttribute("CheckpointZ")
		if root and type(z)=="number" and z>35 then root.CFrame=CFrame.new(0,5,z) end
	end)
end)

print("[Smash Legends] Egg stations, rebirth shrine and checkpoints ready")
