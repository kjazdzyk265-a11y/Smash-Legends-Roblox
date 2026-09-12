local ToolVisuals = {}
local colors={Color3.fromRGB(137,92,54),Color3.fromRGB(112,118,126),Color3.fromRGB(91,99,110),Color3.fromRGB(66,75,87),Color3.fromRGB(255,192,51),Color3.fromRGB(81,225,255)}
function ToolVisuals.build(index,name)
	local tool=Instance.new("Tool"); tool.Name=name; tool.RequiresHandle=true; tool.CanBeDropped=false
	local handle=Instance.new("Part"); handle.Name="Handle"; handle.Size=Vector3.new(.7,4.4,.7); handle.Color=Color3.fromRGB(105,68,43); handle.Material=Enum.Material.Wood; handle.CanCollide=false; handle.Massless=true; handle.Parent=tool
	local head=Instance.new("Part"); head.Name="HammerHead"; head.Size=Vector3.new(3.2+index*.18,1.45+index*.08,1.5+index*.08); head.Color=colors[index] or Color3.fromRGB(180,80,255); head.Material=index>=5 and Enum.Material.Neon or Enum.Material.Metal; head.CanCollide=false; head.Massless=true; head.CFrame=handle.CFrame*CFrame.new(0,2.1,0); head.Parent=tool
	local weld=Instance.new("WeldConstraint"); weld.Part0=handle; weld.Part1=head; weld.Parent=head
	return tool
end
return ToolVisuals
