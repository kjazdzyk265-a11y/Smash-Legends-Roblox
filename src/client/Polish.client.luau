local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local net=ReplicatedStorage:WaitForChild("SmashNet")
local state=net:WaitForChild("State")
local action=net:WaitForChild("Action")

local folder=Instance.new("Folder"); folder.Name="LocalPetVisuals"; folder.Parent=workspace
local visuals={}
local progression
local rarityColors={Common=Color3.fromRGB(210,210,210),Rare=Color3.fromRGB(82,160,255),Epic=Color3.fromRGB(191,89,255),Legendary=Color3.fromRGB(255,190,50),Secret=Color3.fromRGB(255,80,150)}

local function clear() for _,v in ipairs(visuals) do v:Destroy() end; visuals={} end
local function rebuild()
	clear(); if not progression then return end
	for slot,index in ipairs(progression.Equipped or {}) do
		local pet=progression.Pets[index]
		if pet then
			local p=Instance.new("Part"); p.Name=pet.Name; p.Shape=Enum.PartType.Ball; p.Size=Vector3.new(2.8,2.8,2.8); p.Material=Enum.Material.SmoothPlastic; p.Color=rarityColors[pet.Rarity] or Color3.new(1,1,1); p.Anchored=true; p.CanCollide=false; p.Parent=folder; p:SetAttribute("Slot",slot)
			local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromOffset(120,30); gui.StudsOffset=Vector3.new(0,2.2,0); gui.AlwaysOnTop=true; gui.Parent=p
			local l=Instance.new("TextLabel"); l.Size=UDim2.fromScale(1,1); l.BackgroundTransparency=1; l.Text=pet.Name; l.TextColor3=rarityColors[pet.Rarity] or Color3.new(1,1,1); l.TextStrokeTransparency=.25; l.Font=Enum.Font.GothamBold; l.TextScaled=true; l.Parent=gui
			table.insert(visuals,p)
		end
	end
end
state.OnClientEvent:Connect(function(kind,payload)
	if kind=="Progression" then progression=payload; rebuild()
	elseif kind=="HatchRequest" then action:FireServer("ConfirmHatch",payload.Egg)
	elseif kind=="HatchResult" then
		local pg=player.PlayerGui:FindFirstChild("SmashHUD"); if pg then
			local l=Instance.new("TextLabel"); l.AnchorPoint=Vector2.new(.5,.5); l.Position=UDim2.fromScale(.5,.45); l.Size=UDim2.fromOffset(460,120); l.BackgroundColor3=Color3.fromRGB(34,38,52); l.BackgroundTransparency=.08; l.Text="YOU HATCHED\n"..string.upper(payload.Name).." • "..string.upper(payload.Rarity); l.TextColor3=rarityColors[payload.Rarity] or Color3.new(1,1,1); l.TextStrokeTransparency=.3; l.Font=Enum.Font.GothamBlack; l.TextScaled=true; l.Parent=pg
			local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,18); c.Parent=l
			l.Size=UDim2.fromOffset(100,40); TweenService:Create(l,TweenInfo.new(.35,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(460,120)}):Play(); task.delay(2,function() if l then l:Destroy() end end)
		end
	end
end)

RunService.RenderStepped:Connect(function()
	local char=player.Character; local root=char and char:FindFirstChild("HumanoidRootPart"); if not root then return end
	for i,p in ipairs(visuals) do
		local side=(i-2)*3.3; local bob=math.sin(os.clock()*3+i)*.35
		local goal=root.CFrame*CFrame.new(side,1.2+bob,4.8+math.abs(i-2)*.7)
		p.CFrame=p.CFrame:Lerp(goal,.13)
	end
end)
