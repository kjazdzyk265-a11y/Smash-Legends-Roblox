local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local Config=require(ReplicatedStorage.Shared.Config)
local net=ReplicatedStorage:WaitForChild("SmashNet")
local action=net:WaitForChild("Action")
local state=net:WaitForChild("State")
local notice=net:WaitForChild("Notice")

local folder=workspace:FindFirstChild("GiantEvent") or Instance.new("Folder")
folder.Name="GiantEvent"; folder.Parent=workspace
local active=nil
local hp=0
local maxHP=0
local contributions={}
local hitCd={}

local function makeGui(part,title)
	local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromOffset(360,90); gui.StudsOffset=Vector3.new(0,15,0); gui.AlwaysOnTop=true; gui.Parent=part
	local label=Instance.new("TextLabel"); label.Name="Title"; label.Size=UDim2.new(1,0,.45,0); label.BackgroundTransparency=1; label.Text=title; label.TextColor3=Color3.fromRGB(255,208,82); label.TextStrokeTransparency=.2; label.Font=Enum.Font.GothamBlack; label.TextScaled=true; label.Parent=gui
	local back=Instance.new("Frame"); back.Name="Back"; back.Position=UDim2.new(.05,0,.58,0); back.Size=UDim2.new(.9,0,.2,0); back.BackgroundColor3=Color3.fromRGB(33,36,46); back.BorderSizePixel=0; back.Parent=gui
	local fill=Instance.new("Frame"); fill.Name="Fill"; fill.Size=UDim2.fromScale(1,1); fill.BackgroundColor3=Color3.fromRGB(244,87,66); fill.BorderSizePixel=0; fill.Parent=back
	return fill
end

local function spawnEvent()
	if active then active:Destroy() end
	contributions={}
	maxHP=Config.Breakables.FallenMeteor.MaxHP
	hp=maxHP
	local p=Instance.new("Part")
	p.Name="FallenMeteor"; p.Shape=Enum.PartType.Ball; p.Size=Vector3.new(24,24,24); p.Position=Vector3.new(0,13,1125); p.Anchored=true; p.Material=Enum.Material.Slate; p.Color=Color3.fromRGB(79,62,63); p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
	p:SetAttribute("Breakable",true); p:SetAttribute("Kind","FallenMeteor"); p:SetAttribute("HP",hp); p:SetAttribute("MaxHP",maxHP); p:SetAttribute("GiantEvent",true)
	p.Parent=folder
	local core=Instance.new("PointLight"); core.Color=Color3.fromRGB(255,92,44); core.Range=30; core.Brightness=4; core.Parent=p
	local fire=Instance.new("ParticleEmitter"); fire.Rate=18; fire.Lifetime=NumberRange.new(.5,1.1); fire.Speed=NumberRange.new(1,4); fire.SpreadAngle=Vector2.new(180,180); fire.Color=ColorSequence.new(Color3.fromRGB(255,93,42),Color3.fromRGB(255,210,87)); fire.Parent=p
	local fill=makeGui(p,"GLOBAL EVENT • FALLEN METEOR")
	p:SetAttribute("FillReady",true)
	active=p
	for _,plr in ipairs(Players:GetPlayers()) do notice:FireClient(plr,"GLOBAL EVENT: FALLEN METEOR HAS LANDED!") end
	return fill
end

local fill=spawnEvent()

local function charDistance(plr,part)
	local char=plr.Character; local root=char and char:FindFirstChild("HumanoidRootPart")
	if not root then return math.huge end
	return (root.Position-part.Position).Magnitude
end

local function defeat()
	local total=0
	for _,d in pairs(contributions) do total+=d end
	for plr,dmg in pairs(contributions) do
		if plr.Parent==Players and dmg>0 then
			local share=total>0 and dmg/total or 0
			local gems=share>=.35 and 5 or share>=.15 and 3 or 1
			plr:SetAttribute("EventGemCredit",(plr:GetAttribute("EventGemCredit") or 0)+gems)
		end
	end
	for _,plr in ipairs(Players:GetPlayers()) do notice:FireClient(plr,"THE FALLEN METEOR WAS DESTROYED!") end
	local old=active
	active=nil
	if old then
		old.CanCollide=false
		TweenService:Create(old,TweenInfo.new(.65,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=Vector3.new(1,1,1),Transparency=1}):Play()
		task.delay(.8,function() if old then old:Destroy() end end)
	end
	task.delay(90,function() fill=spawnEvent() end)
end

action.OnServerEvent:Connect(function(plr,verb,target,timing)
	if verb~="Hit" or not active or target~=active then return end
	if charDistance(plr,active)>26 then return end
	local now=os.clock(); if hitCd[plr] and now-hitCd[plr]<.28 then return end; hitCd[plr]=now
	local toolIndex=math.clamp(math.floor(tonumber(plr:GetAttribute("CoreTool")) or 1),1,#Config.Tools)
	local strength=math.max(1,tonumber(plr:GetAttribute("CoreStrength")) or 1)
	local pet=math.max(1,tonumber(plr:GetAttribute("PetMultiplier")) or 1)
	local rebirth=math.max(1,tonumber(plr:GetAttribute("RebirthMultiplier")) or 1)
	local base=Config.Tools[toolIndex].Damage*(1+math.sqrt(strength)*.055)*pet*rebirth
	local perfect=type(timing)=="number" and math.abs(timing)<=Config.PerfectWindow
	local crit=math.random()<Config.CritChance
	local damage=math.max(1,math.floor(base*(perfect and Config.PerfectMultiplier or 1)*(crit and Config.CritMultiplier or 1)))
	hp=math.max(0,hp-damage); contributions[plr]=(contributions[plr] or 0)+damage; active:SetAttribute("HP",hp)
	if fill then TweenService:Create(fill,TweenInfo.new(.1),{Size=UDim2.fromScale(hp/maxHP,1)}):Play() end
	state:FireClient(plr,"Hit",{Damage=damage,Perfect=perfect,Crit=crit,Position=active.Position})
	if hp<=0 then defeat() end
end)

Players.PlayerRemoving:Connect(function(plr) contributions[plr]=nil; hitCd[plr]=nil end)
