local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local Debris=game:GetService("Debris")

local player=Players.LocalPlayer
local state=ReplicatedStorage:WaitForChild("SmashNet"):WaitForChild("State")
local camera=workspace.CurrentCamera
local shake=0

local function attachToolFX(tool)
	if not tool:IsA("Tool") or tool:GetAttribute("PolishAttached") then return end
	tool:SetAttribute("PolishAttached",true)
	local baseGrip=tool.Grip
	tool.Activated:Connect(function()
		if not tool.Parent or not tool.Parent:IsA("Model") then return end
		tool.Grip=baseGrip*CFrame.Angles(math.rad(-42),0,math.rad(-14))
		TweenService:Create(tool,TweenInfo.new(.09,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Grip=baseGrip*CFrame.Angles(math.rad(28),0,math.rad(7))}):Play()
		task.delay(.13,function()
			if tool and tool.Parent then TweenService:Create(tool,TweenInfo.new(.13,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Grip=baseGrip}):Play() end
		end)
	end)
end

local function watchCharacter(char)
	for _,v in ipairs(char:GetChildren()) do attachToolFX(v) end
	char.ChildAdded:Connect(attachToolFX)
	local backpack=player:WaitForChild("Backpack")
	for _,v in ipairs(backpack:GetChildren()) do attachToolFX(v) end
	backpack.ChildAdded:Connect(attachToolFX)
end
if player.Character then watchCharacter(player.Character) end
player.CharacterAdded:Connect(watchCharacter)

local function burst(pos,color,strong)
	local holder=Instance.new("Part")
	holder.Size=Vector3.new(.2,.2,.2)
	holder.Transparency=1
	holder.Anchored=true
	holder.CanCollide=false
	holder.Position=pos
	holder.Parent=workspace
	local emitter=Instance.new("ParticleEmitter")
	emitter.Texture="rbxasset://textures/particles/sparkles_main.dds"
	emitter.Color=ColorSequence.new(color)
	emitter.LightEmission=.45
	emitter.Lifetime=NumberRange.new(.18,.38)
	emitter.Speed=NumberRange.new(strong and 12 or 6,strong and 22 or 12)
	emitter.Rate=0
	emitter.SpreadAngle=Vector2.new(60,60)
	emitter.Rotation=NumberRange.new(0,360)
	emitter.RotSpeed=NumberRange.new(-160,160)
	emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,strong and .65 or .35),NumberSequenceKeypoint.new(1,0)})
	emitter.Parent=holder
	emitter:Emit(strong and 18 or 9)
	Debris:AddItem(holder,.8)
end

state.OnClientEvent:Connect(function(kind,data)
	if kind~="Hit" or type(data)~="table" or typeof(data.Position)~="Vector3" then return end
	local color=Color3.fromRGB(255,222,145)
	if data.Perfect then color=Color3.fromRGB(86,231,255) elseif data.Crit then color=Color3.fromRGB(255,99,74) end
	burst(data.Position,color,data.Perfect or data.Crit)
	shake=math.max(shake,data.Perfect and .42 or data.Crit and .3 or .14)
end)

RunService:BindToRenderStep("SmashCameraPolish",Enum.RenderPriority.Camera.Value+1,function(dt)
	if shake<=.002 then return end
	local power=shake
	shake*=math.pow(.04,dt)
	camera.CFrame=camera.CFrame*CFrame.new((math.random()-.5)*power,(math.random()-.5)*power,0)*CFrame.Angles(0,0,math.rad((math.random()-.5)*power*1.6))
end)
