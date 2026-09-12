local ToolVisuals = {}

local palettes={
	{Color3.fromRGB(137,92,54),Enum.Material.Wood},
	{Color3.fromRGB(112,118,126),Enum.Material.Slate},
	{Color3.fromRGB(91,99,110),Enum.Material.Metal},
	{Color3.fromRGB(66,75,87),Enum.Material.Metal},
	{Color3.fromRGB(255,192,51),Enum.Material.Metal},
	{Color3.fromRGB(81,225,255),Enum.Material.Neon},
	{Color3.fromRGB(255,91,44),Enum.Material.Neon},
	{Color3.fromRGB(46,42,52),Enum.Material.Slate},
	{Color3.fromRGB(174,72,255),Enum.Material.Neon},
	{Color3.fromRGB(255,236,156),Enum.Material.Neon},
	{Color3.fromRGB(98,195,255),Enum.Material.Neon},
	{Color3.fromRGB(255,91,180),Enum.Material.Neon},
}

local function part(parent,name,size,color,material)
	local p=Instance.new("Part")
	p.Name=name; p.Size=size; p.Color=color; p.Material=material
	p.CanCollide=false; p.Massless=true; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
	p.Parent=parent
	return p
end

function ToolVisuals.build(index,name)
	local palette=palettes[index] or palettes[#palettes]
	local tool=Instance.new("Tool"); tool.Name=name; tool.RequiresHandle=true; tool.CanBeDropped=false
	tool.Grip=CFrame.new(0,-1.2,0)*CFrame.Angles(0,0,math.rad(-8))

	local handle=part(tool,"Handle",Vector3.new(.65,4.2+index*.08,.65),Color3.fromRGB(96,63,43),index>=8 and Enum.Material.Metal or Enum.Material.Wood)
	local headWidth=3.1+index*.16
	local head=part(tool,"HammerHead",Vector3.new(headWidth,1.35+index*.055,1.45+index*.05),palette[1],palette[2])
	head.CFrame=handle.CFrame*CFrame.new(0,2.15+index*.04,0)
	local weld=Instance.new("WeldConstraint"); weld.Part0=handle; weld.Part1=head; weld.Parent=head

	if index>=4 then
		local band=part(tool,"HeadBand",Vector3.new(.38,head.Size.Y*1.12,head.Size.Z*1.12),index>=9 and Color3.fromRGB(245,245,255) or Color3.fromRGB(42,47,57),Enum.Material.Metal)
		band.CFrame=head.CFrame
		local w=Instance.new("WeldConstraint"); w.Part0=head; w.Part1=band; w.Parent=band
	end
	if index>=6 then
		for side=-1,1,2 do
			local spike=part(tool,"EnergyProng",Vector3.new(.42,1.9+index*.06,.42),palette[1],Enum.Material.Neon)
			spike.CFrame=head.CFrame*CFrame.new(side*(head.Size.X/2+.22),.25,0)*CFrame.Angles(0,0,math.rad(side*-22))
			local w=Instance.new("WeldConstraint"); w.Part0=head; w.Part1=spike; w.Parent=spike
		end
	end
	if index>=9 then
		local core=part(tool,"Core",Vector3.new(.8,.8,head.Size.Z*1.16),Color3.fromRGB(245,245,255),Enum.Material.Neon)
		core.Shape=Enum.PartType.Cylinder; core.CFrame=head.CFrame*CFrame.Angles(0,math.rad(90),0)
		local w=Instance.new("WeldConstraint"); w.Part0=head; w.Part1=core; w.Parent=core
	end
	if index>=11 then
		local glow=Instance.new("PointLight"); glow.Brightness=1.7; glow.Range=10; glow.Color=palette[1]; glow.Parent=head
	end
	return tool
end

return ToolVisuals
