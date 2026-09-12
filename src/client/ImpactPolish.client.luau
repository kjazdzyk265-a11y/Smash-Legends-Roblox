local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local net=ReplicatedStorage:WaitForChild("SmashNet")
local state=net:WaitForChild("State")
local rng=Random.new()

local function burst(position,color,count)
	for i=1,count do
		local p=Instance.new("Part")
		p.Name="HitShard"
		p.Size=Vector3.new(.18,.18,.18)*rng:NextNumber(.8,1.8)
		p.Shape=Enum.PartType.Ball
		p.Material=Enum.Material.Neon
		p.Color=color
		p.Anchored=true
		p.CanCollide=false
		p.CanTouch=false
		p.CanQuery=false
		p.CFrame=CFrame.new(position+Vector3.new(rng:NextNumber(-1.2,1.2),rng:NextNumber(-.5,1.4),rng:NextNumber(-1.2,1.2)))
		p.Parent=workspace
		local dir=Vector3.new(rng:NextNumber(-1,1),rng:NextNumber(.4,1.5),rng:NextNumber(-1,1)).Unit
		local dist=rng:NextNumber(2.5,6.5)
		TweenService:Create(p,TweenInfo.new(.28,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=p.CFrame+CFrame.new(dir*dist),Transparency=1,Size=Vector3.zero}):Play()
		Debris:AddItem(p,.35)
	end
end

local shake=0
local shakeDecay=9
RunService:BindToRenderStep("SmashImpactShake",Enum.RenderPriority.Camera.Value+1,function(dt)
	if shake<=0 then return end
	local cam=workspace.CurrentCamera
	if cam then
		local amount=shake
		cam.CFrame=cam.CFrame*CFrame.new(rng:NextNumber(-amount,amount),rng:NextNumber(-amount,amount),0)*CFrame.Angles(0,0,math.rad(rng:NextNumber(-amount,amount)*1.2))
	end
	shake=math.max(0,shake-dt*shakeDecay)
end)

local function materialColor(target)
	if not target or not target:IsA("BasePart") then return Color3.new(1,1,1) end
	local kind=target:GetAttribute("Kind")
	if kind=="Crystal" then return Color3.fromRGB(95,232,255) end
	if kind=="Safe" then return Color3.fromRGB(220,226,235) end
	if kind=="Rock" or kind=="Gate" then return Color3.fromRGB(170,175,184) end
	if kind=="Barrel" or kind=="Crate" or kind=="Fence" then return Color3.fromRGB(194,131,73) end
	return target.Color
end

state.OnClientEvent:Connect(function(kind,data)
	if kind~="Hit" or type(data)~="table" or typeof(data.Position)~="Vector3" then return end
	local cam=workspace.CurrentCamera
	local nearest=nil
	local best=6
	local world=workspace:FindFirstChild("SmashWorld")
	if world then
		for _,obj in ipairs(world:GetDescendants()) do
			if obj:IsA("BasePart") and obj:GetAttribute("Breakable") then
				local d=(obj.Position-data.Position).Magnitude
				if d<best then nearest=obj; best=d end
			end
		end
	end
	local color=materialColor(nearest)
	local count=data.Perfect and 14 or data.Crit and 11 or 7
	burst(data.Position,color,count)
	shake=math.max(shake,data.Perfect and .18 or data.Crit and .14 or .08)
	if cam and data.Perfect then
		local old=cam.FieldOfView
		cam.FieldOfView=old+2.5
		TweenService:Create(cam,TweenInfo.new(.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{FieldOfView=old}):Play()
	end
end)
