local InsertService=game:GetService("InsertService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")

local Shared=ReplicatedStorage:WaitForChild("Shared")
local StructureAssets=require(Shared:WaitForChild("StructureAssets"))
local world=Workspace:WaitForChild("SmashWorld")

local old=world:FindFirstChild("ImportedStructures")
if old then old:Destroy() end
local root=Instance.new("Folder")
root.Name="ImportedStructures"
root.Parent=world

local function sanitize(instance)
	for _,d in ipairs(instance:GetDescendants()) do
		if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then
			d:Destroy()
		elseif d:IsA("BasePart") then
			d.Anchored=true
			d.CanTouch=false
		end
	end
end

local function getModel(container)
	for _,child in ipairs(container:GetChildren()) do
		if child:IsA("Model") then return child end
	end
	return nil
end

local function scaleModel(model,scale)
	if not scale or math.abs(scale-1)<0.001 then return end
	pcall(function() model:ScaleTo(scale) end)
end

for _,entry in ipairs(StructureAssets.Items) do
	if type(entry)=="table" and type(entry.Id)=="number" and entry.Id>0 then
		local ok,container=pcall(function() return InsertService:LoadAsset(entry.Id) end)
		if ok and container then
			sanitize(container)
			local model=getModel(container)
			if model then
				model.Name=entry.Name or ("Structure_"..tostring(entry.Id))
				model.Parent=root
				scaleModel(model,entry.Scale or 1)
				local pos=entry.Position or Vector3.zero
				local rot=CFrame.Angles(0,math.rad(entry.RotationY or 0),0)
				model:PivotTo(CFrame.new(pos)*rot)
			end
			container:Destroy()
		else
			warn("[Smash Legends] Could not load approved structure asset",entry.Id)
		end
	end
end

print("[Smash Legends] approved Roblox structure loader ready")
