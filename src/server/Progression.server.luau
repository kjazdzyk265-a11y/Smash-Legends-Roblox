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
local store=DataStoreService:GetDataStore("SmashLegends_V1")
local data={}

local defaults={Gems=0,Rebirths=0,Zone=1,Pets={},Equipped={}}
local function cloneDefaults() return {Gems=0,Rebirths=0,Zone=1,Pets={},Equipped={}} end
local function save(plr)
	local d=data[plr]; if not d then return end
	pcall(function() store:UpdateAsync("u"..plr.UserId,function() return d end) end)
end
local function sync(plr) if data[plr] then state:FireClient(plr,"Progression",data[plr]) end end
local function equipHammer(plr,index)
	local backpack=plr:FindFirstChildOfClass("Backpack"); if not backpack then return end
	for _,v in ipairs(backpack:GetChildren()) do if v:IsA("Tool") then v:Destroy() end end
	local char=plr.Character
	if char then for _,v in ipairs(char:GetChildren()) do if v:IsA("Tool") then v:Destroy() end end end
	local cfg=Config.Tools[index] or Config.Tools[1]
	local tool=ToolVisuals.build(index,cfg.Name); tool.Parent=backpack
	local hum=char and char:FindFirstChildOfClass("Humanoid"); if hum then hum:EquipTool(tool) end
end

Players.PlayerAdded:Connect(function(plr)
	local loaded
	pcall(function() loaded=store:GetAsync("u"..plr.UserId) end)
	data[plr]=loaded or cloneDefaults()
	plr:SetAttribute("PetMultiplier",1)
	plr.CharacterAdded:Connect(function() task.wait(1.5); equipHammer(plr,1); sync(plr) end)
end)
Players.PlayerRemoving:Connect(function(plr) save(plr); data[plr]=nil end)
game:BindToClose(function() for _,p in ipairs(Players:GetPlayers()) do save(p) end end)

local function petMultiplier(d)
	local mult=1
	for _,idx in ipairs(d.Equipped) do local p=d.Pets[idx]; if p then mult*=p.Power end end
	return mult
end

action.OnServerEvent:Connect(function(plr,verb,arg)
	local d=data[plr]; if not d then return end
	if verb=="Hatch" then
		local egg=Pets.Eggs[arg]; if not egg or d.Zone<egg.Zone then return end
		-- Coin spending is finalized by the core server through an explicit request; this module owns pet roll only.
		state:FireClient(plr,"HatchRequest",{Egg=arg,Price=egg.Price})
	elseif verb=="ConfirmHatch" then
		local egg=Pets.Eggs[arg]; if not egg or d.Zone<egg.Zone then return end
		local pet=Pets.roll(arg); table.insert(d.Pets,pet)
		if #d.Equipped<3 then table.insert(d.Equipped,#d.Pets) end
		plr:SetAttribute("PetMultiplier",petMultiplier(d)); state:FireClient(plr,"HatchResult",pet); sync(plr)
	elseif verb=="EquipBest" then
		local order={}; for i,p in ipairs(d.Pets) do table.insert(order,{i=i,p=p.Power}) end
		table.sort(order,function(a,b)return a.p>b.p end); d.Equipped={}
		for i=1,math.min(3,#order) do table.insert(d.Equipped,order[i].i) end
		plr:SetAttribute("PetMultiplier",petMultiplier(d)); sync(plr)
	elseif verb=="Rebirth" then
		local strength=plr:GetAttribute("CoreStrength") or 0
		if strength>=25000 then d.Rebirths+=1; d.Gems+=5+d.Rebirths; notice:FireClient(plr,"REBIRTH! PERMANENT POWER INCREASED"); sync(plr) else notice:FireClient(plr,"YOU NEED 25K STRENGTH TO REBIRTH") end
	elseif verb=="ZoneUnlocked" and type(arg)=="number" then
		d.Zone=math.max(d.Zone,math.clamp(math.floor(arg),1,5)); sync(plr)
	elseif verb=="EquipHammerVisual" and type(arg)=="number" then equipHammer(plr,math.clamp(math.floor(arg),1,#Config.Tools)) end
	end
end)
