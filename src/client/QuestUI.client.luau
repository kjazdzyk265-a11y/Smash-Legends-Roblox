local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local net=ReplicatedStorage:WaitForChild("SmashNet")
local action=net:WaitForChild("Action")
local state=net:WaitForChild("State")
local Quests=require(ReplicatedStorage.Shared.Quests)

local gui=player:WaitForChild("PlayerGui"):WaitForChild("SmashHUD")
local latest=nil

local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 12); c.Parent=o end
local function stroke(o) local s=Instance.new("UIStroke"); s.Thickness=2; s.Transparency=.4; s.Parent=o end

local open=Instance.new("TextButton")
open.Name="QuestsButton"; open.Size=UDim2.fromOffset(112,44); open.Position=UDim2.new(0,384,1,-64)
open.BackgroundColor3=Color3.fromRGB(237,154,54); open.Text="QUESTS"; open.TextColor3=Color3.new(1,1,1); open.Font=Enum.Font.GothamBlack; open.TextScaled=true; open.Parent=gui; corner(open,12); stroke(open)

local panel=Instance.new("Frame")
panel.Name="QuestsPanel"; panel.AnchorPoint=Vector2.new(.5,.5); panel.Position=UDim2.fromScale(.5,.5); panel.Size=UDim2.fromOffset(620,480)
panel.BackgroundColor3=Color3.fromRGB(30,34,47); panel.Visible=false; panel.Parent=gui; corner(panel,18); stroke(panel)
local title=Instance.new("TextLabel"); title.Position=UDim2.fromOffset(22,16); title.Size=UDim2.new(1,-70,0,50); title.BackgroundTransparency=1; title.Text="QUESTS"; title.TextColor3=Color3.fromRGB(255,208,91); title.Font=Enum.Font.GothamBlack; title.TextScaled=true; title.TextXAlignment=Enum.TextXAlignment.Left; title.Parent=panel
local close=Instance.new("TextButton"); close.Position=UDim2.new(1,-54,0,12); close.Size=UDim2.fromOffset(42,42); close.BackgroundColor3=Color3.fromRGB(196,68,73); close.Text="×"; close.TextColor3=Color3.new(1,1,1); close.Font=Enum.Font.GothamBlack; close.TextScaled=true; close.Parent=panel; corner(close,10)
local list=Instance.new("ScrollingFrame"); list.Position=UDim2.fromOffset(20,78); list.Size=UDim2.new(1,-40,1,-98); list.BackgroundTransparency=1; list.BorderSizePixel=0; list.ScrollBarThickness=6; list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.CanvasSize=UDim2.new(); list.Parent=panel
local layout=Instance.new("UIListLayout"); layout.Padding=UDim.new(0,10); layout.Parent=list

local function refresh()
	for _,c in ipairs(list:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	if not latest then return end
	for _,q in ipairs(Quests.List) do
		local qs=latest.Quests and latest.Quests[q.Id] or {Progress=0,Claimed=false}
		local card=Instance.new("Frame"); card.Size=UDim2.new(1,-8,0,82); card.BackgroundColor3=Color3.fromRGB(48,53,69); card.Parent=list; corner(card,12)
		local name=Instance.new("TextLabel"); name.Position=UDim2.fromOffset(12,8); name.Size=UDim2.new(.55,-12,0,28); name.BackgroundTransparency=1; name.Text=q.Title.." — "..q.Description; name.TextColor3=Color3.new(1,1,1); name.Font=Enum.Font.GothamBold; name.TextScaled=true; name.TextXAlignment=Enum.TextXAlignment.Left; name.Parent=card
		local progress=Instance.new("TextLabel"); progress.Position=UDim2.fromOffset(12,43); progress.Size=UDim2.new(.5,-12,0,26); progress.BackgroundTransparency=1; progress.Text=string.format("%d / %d",math.floor(qs.Progress or 0),q.Goal); progress.TextColor3=Color3.fromRGB(191,204,225); progress.Font=Enum.Font.GothamBold; progress.TextScaled=true; progress.TextXAlignment=Enum.TextXAlignment.Left; progress.Parent=card
		local claim=Instance.new("TextButton"); claim.Position=UDim2.new(1,-176,.5,-24); claim.Size=UDim2.fromOffset(160,48); claim.Font=Enum.Font.GothamBlack; claim.TextScaled=true; claim.TextColor3=Color3.new(1,1,1); claim.Parent=card; corner(claim,10)
		if qs.Claimed then claim.Text="CLAIMED"; claim.BackgroundColor3=Color3.fromRGB(83,92,108); claim.AutoButtonColor=false
		elseif (qs.Progress or 0)>=q.Goal then claim.Text="CLAIM +"..tostring(q.RewardGems).." 💎"; claim.BackgroundColor3=Color3.fromRGB(82,193,103); claim.Activated:Connect(function() action:FireServer("ClaimQuest",q.Id) end)
		else claim.Text="+"..tostring(q.RewardGems).." 💎"; claim.BackgroundColor3=Color3.fromRGB(85,112,155); claim.AutoButtonColor=false end
	end
end

open.Activated:Connect(function() panel.Visible=not panel.Visible; if panel.Visible then refresh() end end)
close.Activated:Connect(function() panel.Visible=false end)
state.OnClientEvent:Connect(function(kind,payload) if kind=="Progression" and payload then latest=payload; if panel.Visible then refresh() end end end)
