local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local net=ReplicatedStorage:WaitForChild("SmashNet")
local state=net:WaitForChild("State")
local action=net:WaitForChild("Action")
local Pets=require(ReplicatedStorage.Shared.Pets)

local gui=player:WaitForChild("PlayerGui"):WaitForChild("SmashHUD")
local progression={Pets={},Equipped={},Zone=1,Rebirths=0,Gems=0}
local currentEgg=nil
local lastToolIndex=nil

local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 12); c.Parent=o end
local function stroke(o) local s=Instance.new("UIStroke"); s.Thickness=2; s.Transparency=.35; s.Parent=o end
local function mkButton(name,textValue,pos,color)
	local b=Instance.new("TextButton"); b.Name=name; b.Size=UDim2.fromOffset(112,44); b.Position=pos; b.BackgroundColor3=color; b.Text=textValue; b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.GothamBlack; b.TextScaled=true; b.Parent=gui; corner(b,12); stroke(b); return b
end
local function mkPanel(name,size)
	local f=Instance.new("Frame"); f.Name=name; f.AnchorPoint=Vector2.new(.5,.5); f.Position=UDim2.fromScale(.5,.5); f.Size=size; f.BackgroundColor3=Color3.fromRGB(31,35,48); f.BackgroundTransparency=.04; f.Visible=false; f.Parent=gui; corner(f,18); stroke(f); return f
end
local function mkText(parent,textValue,pos,size,font,color)
	local l=Instance.new("TextLabel"); l.Position=pos; l.Size=size; l.BackgroundTransparency=1; l.Text=textValue; l.TextColor3=color or Color3.new(1,1,1); l.TextStrokeTransparency=.45; l.Font=font or Enum.Font.GothamBold; l.TextScaled=true; l.Parent=parent; return l
end
local function clearChildren(parent,keep)
	for _,c in ipairs(parent:GetChildren()) do if not table.find(keep or {},c.Name) and not c:IsA("UICorner") and not c:IsA("UIStroke") then c:Destroy() end end
end

local petsBtn=mkButton("PetsButton","PETS",UDim2.new(0,18,1,-64),Color3.fromRGB(77,152,255))
local rebirthBtn=mkButton("RebirthButton","REBIRTH",UDim2.new(0,140,1,-64),Color3.fromRGB(180,78,255))
local indexBtn=mkButton("IndexButton","INDEX",UDim2.new(0,262,1,-64),Color3.fromRGB(67,188,128))

local petsPanel=mkPanel("PetsPanel",UDim2.fromOffset(580,460))
mkText(petsPanel,"PET INVENTORY",UDim2.fromOffset(24,18),UDim2.new(1,-48,0,46),Enum.Font.GothamBlack)
local equipBest=Instance.new("TextButton"); equipBest.Size=UDim2.fromOffset(160,44); equipBest.Position=UDim2.new(1,-184,0,72); equipBest.BackgroundColor3=Color3.fromRGB(75,202,105); equipBest.Text="EQUIP BEST"; equipBest.TextColor3=Color3.new(1,1,1); equipBest.Font=Enum.Font.GothamBlack; equipBest.TextScaled=true; equipBest.Parent=petsPanel; corner(equipBest,10)
local closePets=Instance.new("TextButton"); closePets.Size=UDim2.fromOffset(42,42); closePets.Position=UDim2.new(1,-54,0,12); closePets.BackgroundColor3=Color3.fromRGB(195,64,70); closePets.Text="×"; closePets.TextColor3=Color3.new(1,1,1); closePets.Font=Enum.Font.GothamBlack; closePets.TextScaled=true; closePets.Parent=petsPanel; corner(closePets,10)
local petGrid=Instance.new("ScrollingFrame"); petGrid.Name="Grid"; petGrid.Position=UDim2.fromOffset(20,128); petGrid.Size=UDim2.new(1,-40,1,-148); petGrid.BackgroundTransparency=1; petGrid.BorderSizePixel=0; petGrid.ScrollBarThickness=6; petGrid.AutomaticCanvasSize=Enum.AutomaticSize.Y; petGrid.CanvasSize=UDim2.new(); petGrid.Parent=petsPanel
local layout=Instance.new("UIGridLayout"); layout.CellSize=UDim2.fromOffset(165,100); layout.CellPadding=UDim2.fromOffset(10,10); layout.Parent=petGrid

local rarityColor={Common=Color3.fromRGB(95,102,116),Rare=Color3.fromRGB(66,129,226),Epic=Color3.fromRGB(155,78,222),Legendary=Color3.fromRGB(228,164,39),Secret=Color3.fromRGB(224,65,139)}
local function refreshPets()
	for _,c in ipairs(petGrid:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	local equippedLookup={}; for _,idx in ipairs(progression.Equipped or {}) do equippedLookup[idx]=true end
	for i,pet in ipairs(progression.Pets or {}) do
		local card=Instance.new("Frame"); card.BackgroundColor3=rarityColor[pet.Rarity] or Color3.fromRGB(75,80,95); card.Parent=petGrid; corner(card,12); stroke(card)
		mkText(card,pet.Name,UDim2.fromOffset(8,8),UDim2.new(1,-16,0,35),Enum.Font.GothamBlack)
		mkText(card,string.upper(pet.Rarity).."  x"..string.format("%.2f",pet.Power),UDim2.fromOffset(8,47),UDim2.new(1,-16,0,25),Enum.Font.GothamBold)
		if equippedLookup[i] then mkText(card,"EQUIPPED",UDim2.fromOffset(8,73),UDim2.new(1,-16,0,18),Enum.Font.GothamBlack,Color3.fromRGB(110,255,145)) end
	end
end

local eggPanel=mkPanel("EggPanel",UDim2.fromOffset(540,430))
local eggTitle=mkText(eggPanel,"EGG",UDim2.fromOffset(22,18),UDim2.new(1,-44,0,48),Enum.Font.GothamBlack)
local eggOdds=mkText(eggPanel,"",UDim2.fromOffset(24,82),UDim2.new(1,-48,0,220),Enum.Font.GothamBold); eggOdds.TextWrapped=true; eggOdds.TextYAlignment=Enum.TextYAlignment.Top
local hatch=Instance.new("TextButton"); hatch.Size=UDim2.new(.72,0,0,58); hatch.Position=UDim2.new(.14,0,1,-82); hatch.BackgroundColor3=Color3.fromRGB(80,204,103); hatch.TextColor3=Color3.new(1,1,1); hatch.Font=Enum.Font.GothamBlack; hatch.TextScaled=true; hatch.Text="HATCH"; hatch.Parent=eggPanel; corner(hatch,13); stroke(hatch)
local closeEgg=Instance.new("TextButton"); closeEgg.Size=UDim2.fromOffset(42,42); closeEgg.Position=UDim2.new(1,-54,0,12); closeEgg.BackgroundColor3=Color3.fromRGB(195,64,70); closeEgg.Text="×"; closeEgg.TextColor3=Color3.new(1,1,1); closeEgg.Font=Enum.Font.GothamBlack; closeEgg.TextScaled=true; closeEgg.Parent=eggPanel; corner(closeEgg,10)

local rebirthPanel=mkPanel("RebirthPanel",UDim2.fromOffset(500,330))
mkText(rebirthPanel,"REBIRTH",UDim2.fromOffset(20,22),UDim2.new(1,-40,0,50),Enum.Font.GothamBlack,Color3.fromRGB(221,167,255))
mkText(rebirthPanel,"Reset your current run and restart stronger.\n\nRequirement: 25K Strength\nReward: Gems + permanent progression",UDim2.fromOffset(35,92),UDim2.new(1,-70,0,125),Enum.Font.GothamBold)
local doRebirth=Instance.new("TextButton"); doRebirth.Size=UDim2.new(.7,0,0,58); doRebirth.Position=UDim2.new(.15,0,1,-82); doRebirth.BackgroundColor3=Color3.fromRGB(177,76,239); doRebirth.Text="REBIRTH NOW"; doRebirth.TextColor3=Color3.new(1,1,1); doRebirth.Font=Enum.Font.GothamBlack; doRebirth.TextScaled=true; doRebirth.Parent=rebirthPanel; corner(doRebirth,13)
local closeRebirth=Instance.new("TextButton"); closeRebirth.Size=UDim2.fromOffset(42,42); closeRebirth.Position=UDim2.new(1,-54,0,12); closeRebirth.BackgroundColor3=Color3.fromRGB(195,64,70); closeRebirth.Text="×"; closeRebirth.TextColor3=Color3.new(1,1,1); closeRebirth.Font=Enum.Font.GothamBlack; closeRebirth.TextScaled=true; closeRebirth.Parent=rebirthPanel; corner(closeRebirth,10)

local function closeAll() petsPanel.Visible=false; eggPanel.Visible=false; rebirthPanel.Visible=false end
petsBtn.Activated:Connect(function() local v=not petsPanel.Visible; closeAll(); petsPanel.Visible=v; if v then refreshPets() end end)
rebirthBtn.Activated:Connect(function() local v=not rebirthPanel.Visible; closeAll(); rebirthPanel.Visible=v end)
indexBtn.Activated:Connect(function() petsPanel.Visible=true; refreshPets() end)
closePets.Activated:Connect(function() petsPanel.Visible=false end)
closeEgg.Activated:Connect(function() eggPanel.Visible=false end)
closeRebirth.Activated:Connect(function() rebirthPanel.Visible=false end)
equipBest.Activated:Connect(function() action:FireServer("EquipBest") end)
doRebirth.Activated:Connect(function() action:FireServer("Rebirth"); rebirthPanel.Visible=false end)
hatch.Activated:Connect(function() if currentEgg then action:FireServer("Hatch",currentEgg) end end)

state.OnClientEvent:Connect(function(kind,payload)
	if kind=="Progression" and payload then progression=payload; refreshPets()
	elseif kind=="EggShop" and payload then
		currentEgg=payload.Egg; eggTitle.Text=string.upper(payload.Egg).." EGG  •  "..tostring(payload.Config.Price).." COINS"
		local lines={}
		for _,pet in ipairs(payload.Config.Pets) do table.insert(lines,string.format("%s  •  %s  •  %.1f%%  •  x%.2f",pet.Name,string.upper(pet.Rarity),pet.Weight,pet.Power)) end
		eggOdds.Text=table.concat(lines,"\n\n"); closeAll(); eggPanel.Visible=true
	elseif kind=="RebirthConfirm" then closeAll(); rebirthPanel.Visible=true
	elseif kind=="State" and payload and payload.Tool then
		if lastToolIndex~=payload.Tool then lastToolIndex=payload.Tool; action:FireServer("EquipHammerVisual",payload.Tool) end
	end
end)
