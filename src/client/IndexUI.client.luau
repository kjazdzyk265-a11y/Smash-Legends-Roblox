local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local state=ReplicatedStorage:WaitForChild("SmashNet"):WaitForChild("State")
local Config=require(ReplicatedStorage.Shared.Config)
local Pets=require(ReplicatedStorage.Shared.Pets)

local gui=player:WaitForChild("PlayerGui"):WaitForChild("SmashHUD")
local indexButton=gui:WaitForChild("IndexButton")
local petsPanel=gui:WaitForChild("PetsPanel")
local latest={Index={Pets={},Tools={}}}

local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 12); c.Parent=o end
local function stroke(o) local s=Instance.new("UIStroke"); s.Thickness=2; s.Transparency=.4; s.Parent=o end
local panel=Instance.new("Frame")
panel.Name="IndexPanel"; panel.AnchorPoint=Vector2.new(.5,.5); panel.Position=UDim2.fromScale(.5,.5); panel.Size=UDim2.fromOffset(650,500); panel.BackgroundColor3=Color3.fromRGB(30,34,47); panel.Visible=false; panel.Parent=gui; corner(panel,18); stroke(panel)
local title=Instance.new("TextLabel"); title.Position=UDim2.fromOffset(22,16); title.Size=UDim2.new(1,-80,0,50); title.BackgroundTransparency=1; title.Text="COLLECTION INDEX"; title.TextColor3=Color3.fromRGB(108,226,166); title.Font=Enum.Font.GothamBlack; title.TextScaled=true; title.TextXAlignment=Enum.TextXAlignment.Left; title.Parent=panel
local close=Instance.new("TextButton"); close.Position=UDim2.new(1,-54,0,12); close.Size=UDim2.fromOffset(42,42); close.BackgroundColor3=Color3.fromRGB(196,68,73); close.Text="×"; close.TextColor3=Color3.new(1,1,1); close.Font=Enum.Font.GothamBlack; close.TextScaled=true; close.Parent=panel; corner(close,10)
local list=Instance.new("ScrollingFrame"); list.Position=UDim2.fromOffset(20,78); list.Size=UDim2.new(1,-40,1,-98); list.BackgroundTransparency=1; list.BorderSizePixel=0; list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.CanvasSize=UDim2.new(); list.Parent=panel
local layout=Instance.new("UIListLayout"); layout.Padding=UDim.new(0,8); layout.Parent=list

local function row(textValue,owned)
	local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-8,0,36); l.BackgroundColor3=owned and Color3.fromRGB(49,86,70) or Color3.fromRGB(48,53,67); l.TextColor3=owned and Color3.fromRGB(137,255,182) or Color3.fromRGB(126,132,149); l.Text=(owned and "✓  " or "?  ")..textValue; l.Font=Enum.Font.GothamBold; l.TextScaled=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=list; corner(l,8)
	local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,12); pad.Parent=l
end
local function heading(textValue)
	local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-8,0,44); l.BackgroundTransparency=1; l.Text=textValue; l.TextColor3=Color3.fromRGB(255,211,92); l.Font=Enum.Font.GothamBlack; l.TextScaled=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=list
end
local function refresh()
	for _,c in ipairs(list:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
	local idx=latest.Index or {Pets={},Tools={}}
	heading("HAMMERS")
	for _,tool in ipairs(Config.Tools) do row(tool.Name,idx.Tools and idx.Tools[tool.Name]==true) end
	heading("PETS")
	local seen={}
	for _,egg in pairs(Pets.Eggs) do
		for _,pet in ipairs(egg.Pets) do
			if not seen[pet.Name] then
				seen[pet.Name]=true
				row(pet.Name.."  •  Normal",idx.Pets and idx.Pets[pet.Name..":Normal"]==true)
				row(pet.Name.."  •  Shiny",idx.Pets and idx.Pets[pet.Name..":Shiny"]==true)
				row(pet.Name.."  •  Rainbow",idx.Pets and idx.Pets[pet.Name..":Rainbow"]==true)
			end
		end
	end
end
indexButton.Activated:Connect(function()
	task.defer(function()
		petsPanel.Visible=false
		panel.Visible=not panel.Visible
		if panel.Visible then refresh() end
	end)
end)
close.Activated:Connect(function() panel.Visible=false end)
state.OnClientEvent:Connect(function(kind,payload) if kind=="Progression" and payload then latest=payload; if panel.Visible then refresh() end end end)
