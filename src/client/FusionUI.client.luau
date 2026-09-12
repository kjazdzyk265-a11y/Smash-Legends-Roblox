local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local net=ReplicatedStorage:WaitForChild("SmashNet")
local action=net:WaitForChild("Action")
local state=net:WaitForChild("State")
local latest={Pets={}}

local gui=player:WaitForChild("PlayerGui"):WaitForChild("SmashHUD")
local petsPanel=gui:WaitForChild("PetsPanel")
local button=Instance.new("TextButton")
button.Name="FuseButton"
button.Size=UDim2.fromOffset(160,44)
button.Position=UDim2.fromOffset(24,72)
button.BackgroundColor3=Color3.fromRGB(238,119,56)
button.TextColor3=Color3.new(1,1,1)
button.Font=Enum.Font.GothamBlack
button.TextScaled=true
button.Text="FUSE x5"
button.Parent=petsPanel
local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,10); corner.Parent=button

local hint=Instance.new("TextLabel")
hint.Size=UDim2.fromOffset(170,24)
hint.Position=UDim2.fromOffset(194,82)
hint.BackgroundTransparency=1
hint.Text="5 same → Shiny → Rainbow"
hint.TextColor3=Color3.fromRGB(220,225,240)
hint.Font=Enum.Font.GothamMedium
hint.TextScaled=true
hint.Parent=petsPanel

local function findFusionCandidate()
	local groups={}
	for i,p in ipairs(latest.Pets or {}) do
		local tier=p.Tier or "Normal"
		if tier~="Rainbow" then
			local key=p.Name.."|"..tier
			groups[key]=groups[key] or {}
			table.insert(groups[key],i)
		end
	end
	local bestIndex,bestPower
	for _,indices in pairs(groups) do
		if #indices>=5 then
			local idx=indices[1]
			local power=tonumber(latest.Pets[idx].Power) or 1
			if not bestPower or power>bestPower then bestPower=power; bestIndex=idx end
		end
	end
	return bestIndex
end

local function refresh()
	local idx=findFusionCandidate()
	button.AutoButtonColor=idx~=nil
	button.BackgroundTransparency=idx and 0 or .45
	button.Text=idx and "FUSE x5" or "NEED 5 COPIES"
end
state.OnClientEvent:Connect(function(kind,payload)
	if kind=="Progression" and payload then latest=payload; refresh() end
end)
button.Activated:Connect(function()
	local idx=findFusionCandidate()
	if idx then action:FireServer("FusePet",idx) end
end)
