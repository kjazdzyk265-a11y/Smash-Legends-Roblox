local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local DataStoreService=game:GetService("DataStoreService")
local Pets=require(ReplicatedStorage.Shared.Pets)
local ToolVisuals=require(ReplicatedStorage.Shared.ToolVisuals)
local Config=require(ReplicatedStorage.Shared.Config)
local net=ReplicatedStorage:WaitForChild("SmashNet")
local action=net:WaitForChild("Action")
local state=net:WaitForChild("State")
local notice=net:WaitForChild("Notice")
local store=DataStoreService:GetDataStore("SmashLegends_V3")
local data={}

local function cloneDefaults()
	return {Gems=0,Rebirths=0,Zone=1,Pets={},Equipped={},Hatches=0,Index={Pets={},Tools={}}}
end
local function sanitize(loaded)
	local d=cloneDefaults()
	if type(loaded)=="table" then for k,v in pairs(loaded) do d[k]=v end end
	d.Pets=type(d.Pets)=="table" and d.Pets or {}
	d.Equipped=type(d.Equipped)=="table" and d.Equipped or {}
	d.Index=type(d.Index)=="table" and d.Index or {Pets={},Tools={}}
	d.Index.Pets=type(d.Index.Pets)=="table" and d.Index.Pets or {}
	d.Index.Tools=type(d.Index.Tools)=="table" and d.Index.Tools or {}
	d.Zone=math.clamp(tonumber(d.Zone) or 1,1,5)
	d.Rebirths=math.max(0,math.floor(tonumber(d.Rebirths) or 0))
	d.Gems=math.max(0,math.floor(tonumber(d.Gems) or 0))
	d.Hatches=math.max(0,math.floor(tonumber(d.Hatches) or 0))
	return d
end
local function save(plr)
	local d=data[plr]; if not d then return end
	local ok,err=pcall(function() store:UpdateAsync("u"..plr.UserId,function() return d end) end)
	if not ok then warn("[Smash Legends] progression save failed",plr.UserId,err) end
end
local function petMultiplier(d)
	local mult=1
	for _,idx in ipairs(d.Equipped) do local p=d.Pets[idx]; if p then mult*=tonumber(p.Power) or 1 end end
	return math.clamp(mult,1,500)
end
local function applyMultipliers(plr,d)
	plr:SetAttribute("PetMultiplier",petMultiplier(d))
	plr:SetAttribute("RebirthMultiplier",1+d.Rebirths*Config.RebirthPowerPerLevel)
	plr:SetAttribute("UnlockedZone",d.Zone)
end
local function sync(plr)
	local d=data[plr]; if not d then return end
	applyMultipliers(plr,d)
	state:FireClient(plr,"Progression",d)
end
local function equipBest(d)
	local order={}
	for i,p in ipairs(d.Pets) do table.insert(order,{i=i,p=tonumber(p.Power) or 1}) end
	table.sort(order,function(a,b)return a.p>b.p end)
	d.Equipped={}
	for i=1,math.min(Config.MaxEquippedPets,#order) do table.insert(d.Equipped,order[i].i) end
end
local function equipHammer(plr,index)
	local backpack=plr:FindFirstChildOfClass("Backpack"); if not backpack then return end
	for _,v in ipairs(backpack:GetChildren()) do if v:IsA("Tool") then v:Destroy() end end
	local char=plr.Character
	if char then for _,v in ipairs(char:GetChildren()) do if v:IsA("Tool") then v:Destroy() end end end
	local cfg=Config.Tools[index] or Config.Tools[1]
	local tool=ToolVisuals.build(index,cfg.Name); tool.Parent=backpack
	local hum=char and char:FindFirstChildOfClass("Humanoid"); if hum then hum:EquipTool(tool) end
end
local function recordTool(plr,index)
	local d=data[plr]; local cfg=Config.Tools[index]
	if d and cfg then d.Index.Tools[cfg.Name]=true end
end
local function fuse(plr,petIndex)
	local d=data[plr]; local source=d and d.Pets[petIndex]
	if not source then return end
	local tier=source.Tier or "Normal"
	if tier=="Rainbow" then notice:FireClient(plr,"RAINBOW PETS CANNOT BE FUSED FURTHER") return end
	local matches={}
	for i,p in ipairs(d.Pets) do
		if p.Name==source.Name and (p.Tier or "Normal")==tier then table.insert(matches,i) end
	end
	if #matches<Config.FusionCount then notice:FireClient(plr,"YOU NEED 5 MATCHING PETS") return end
	local nextTier=tier=="Normal" and "Shiny" or "Rainbow"
	local boost=nextTier=="Shiny" and 2 or 2.5
	local newPet=table.clone(source)
	newPet.Tier=nextTier
	newPet.Power=math.floor((tonumber(source.Power) or 1)*boost*100)/100
	for i=#matches,1,-1 do if i>#matches-Config.FusionCount then table.remove(d.Pets,matches[i]) end end
	table.insert(d.Pets,newPet)
	d.Index.Pets[newPet.Name..":"..nextTier]=true
	equipBest(d)
	notice:FireClient(plr,nextTier:upper().." "..newPet.Name:upper().." CREATED!")
	sync(plr)
end

local function setup(plr)
	if data[plr] then return end
	local loaded
	pcall(function() loaded=store:GetAsync("u"..plr.UserId) end)
	data[plr]=sanitize(loaded)
	applyMultipliers(plr,data[plr])
	plr.CharacterAdded:Connect(function()
		task.wait(1.2)
		local toolIndex=plr:GetAttribute("CoreTool") or 1
		equipHammer(plr,toolIndex); recordTool(plr,toolIndex); sync(plr)
	end)
	if plr.Character then task.defer(function() task.wait(1); local toolIndex=plr:GetAttribute("CoreTool") or 1; equipHammer(plr,toolIndex); recordTool(plr,toolIndex); sync(plr) end) end
end
Players.PlayerAdded:Connect(setup)
for _,plr in ipairs(Players:GetPlayers()) do task.spawn(setup,plr) end
Players.PlayerRemoving:Connect(function(plr) save(plr); data[plr]=nil end)
game:BindToClose(function() for _,p in ipairs(Players:GetPlayers()) do save(p) end end)

action.OnServerEvent:Connect(function(plr,verb,arg)
	local d=data[plr]; if not d then return end
	if verb=="Hatch" then
		local egg=Pets.Eggs[arg]
		if not egg or d.Zone<egg.Zone then notice:FireClient(plr,"THIS EGG IS LOCKED") return end
		state:FireClient(plr,"HatchRequest",{Egg=arg,Price=egg.Price})
	elseif verb=="ConfirmHatch" then
		local egg=Pets.Eggs[arg]
		if not egg or d.Zone<egg.Zone then return end
		local creditName="HatchCredit_"..arg
		local credits=plr:GetAttribute(creditName) or 0
		if credits<1 then notice:FireClient(plr,"EGG PAYMENT WAS NOT APPROVED") return end
		plr:SetAttribute(creditName,credits-1)
		local pet=Pets.roll(arg); pet.Tier="Normal"
		table.insert(d.Pets,pet); d.Hatches+=1; d.Index.Pets[pet.Name..":Normal"]=true
		if #d.Equipped<Config.MaxEquippedPets then table.insert(d.Equipped,#d.Pets) end
		state:FireClient(plr,"HatchResult",pet); sync(plr)
	elseif verb=="EquipBest" then
		equipBest(d); sync(plr)
	elseif verb=="FusePet" and type(arg)=="number" then
		fuse(plr,math.floor(arg))
	elseif verb=="Rebirth" then
		local strength=plr:GetAttribute("CoreStrength") or 0
		if strength>=Config.RebirthStrength then
			d.Rebirths+=1; d.Gems+=Config.RebirthBaseGems+d.Rebirths
			applyMultipliers(plr,d)
			notice:FireClient(plr,"REBIRTH! PERMANENT POWER +25%")
			sync(plr)
		else notice:FireClient(plr,"YOU NEED 25K STRENGTH TO REBIRTH") end
	elseif verb=="ZoneUnlocked" and type(arg)=="number" then
		d.Zone=math.max(d.Zone,math.clamp(math.floor(arg),1,5)); sync(plr)
	elseif verb=="EquipHammerVisual" and type(arg)=="number" then
		local index=math.clamp(math.floor(arg),1,#Config.Tools); equipHammer(plr,index); recordTool(plr,index); sync(plr)
	end
end)
