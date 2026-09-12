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
local store=DataStoreService:GetDataStore("SmashLegends_V2")
local data={}

local function cloneDefaults()
	return {Gems=0,Rebirths=0,Zone=1,Pets={},Equipped={},Hatches=0}
end
local function sanitize(loaded)
	local d=cloneDefaults()
	if type(loaded)=="table" then
		for k,v in pairs(loaded) do d[k]=v end
	end
	d.Pets=type(d.Pets)=="table" and d.Pets or {}
	d.Equipped=type(d.Equipped)=="table" and d.Equipped or {}
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
	return math.clamp(mult,1,250)
end
local function applyMultipliers(plr,d)
	plr:SetAttribute("PetMultiplier",petMultiplier(d))
	plr:SetAttribute("RebirthMultiplier",1+d.Rebirths*.2)
	plr:SetAttribute("UnlockedZone",d.Zone)
end
local function sync(plr)
	local d=data[plr]
	if not d then return end
	applyMultipliers(plr,d)
	state:FireClient(plr,"Progression",d)
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

local function setup(plr)
	if data[plr] then return end
	local loaded
	pcall(function() loaded=store:GetAsync("u"..plr.UserId) end)
	data[plr]=sanitize(loaded)
	applyMultipliers(plr,data[plr])
	plr.CharacterAdded:Connect(function()
		task.wait(1.2)
		equipHammer(plr,plr:GetAttribute("CoreTool") or 1)
		sync(plr)
	end)
	if plr.Character then task.defer(function() task.wait(1); equipHammer(plr,plr:GetAttribute("CoreTool") or 1); sync(plr) end) end
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
		-- Core economy script charges Coins and issues a one-use HatchCredit attribute.
		state:FireClient(plr,"HatchRequest",{Egg=arg,Price=egg.Price})
	elseif verb=="ConfirmHatch" then
		local egg=Pets.Eggs[arg]
		if not egg or d.Zone<egg.Zone then return end
		local creditName="HatchCredit_"..arg
		local credits=plr:GetAttribute(creditName) or 0
		if credits<1 then notice:FireClient(plr,"EGG PAYMENT WAS NOT APPROVED") return end
		plr:SetAttribute(creditName,credits-1)
		local pet=Pets.roll(arg)
		table.insert(d.Pets,pet)
		d.Hatches+=1
		if #d.Equipped<3 then table.insert(d.Equipped,#d.Pets) end
		applyMultipliers(plr,d)
		state:FireClient(plr,"HatchResult",pet)
		sync(plr)
	elseif verb=="EquipBest" then
		local order={}; for i,p in ipairs(d.Pets) do table.insert(order,{i=i,p=tonumber(p.Power) or 1}) end
		table.sort(order,function(a,b)return a.p>b.p end); d.Equipped={}
		for i=1,math.min(3,#order) do table.insert(d.Equipped,order[i].i) end
		sync(plr)
	elseif verb=="Rebirth" then
		local strength=plr:GetAttribute("CoreStrength") or 0
		if strength>=25000 then
			d.Rebirths+=1; d.Gems+=5+d.Rebirths
			applyMultipliers(plr,d)
			notice:FireClient(plr,"REBIRTH! PERMANENT POWER +20%")
			sync(plr)
		else notice:FireClient(plr,"YOU NEED 25K STRENGTH TO REBIRTH") end
	elseif verb=="ZoneUnlocked" and type(arg)=="number" then
		d.Zone=math.max(d.Zone,math.clamp(math.floor(arg),1,5)); sync(plr)
	elseif verb=="EquipHammerVisual" and type(arg)=="number" then
		equipHammer(plr,math.clamp(math.floor(arg),1,#Config.Tools))
	end
end)
