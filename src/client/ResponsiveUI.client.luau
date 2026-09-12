local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local gui=player:WaitForChild("PlayerGui"):WaitForChild("SmashHUD")

local function scaleForViewport()
	local cam=workspace.CurrentCamera
	if not cam then return end
	local v=cam.ViewportSize
	local scale=Instance.new("UIScale")
	scale.Name="ResponsiveScale"
	scale.Parent=gui
	local minAxis=math.min(v.X,v.Y)
	if UserInputService.TouchEnabled then
		scale.Scale=math.clamp(minAxis/720,.72,1)
	else
		scale.Scale=math.clamp(v.X/1400,.82,1.08)
	end
end
scaleForViewport()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		local old=gui:FindFirstChild("ResponsiveScale")
		if old then old:Destroy() end
		scaleForViewport()
	end)
end

-- Keep central modal windows inside small phone screens.
for _,name in ipairs({"PetsPanel","EggPanel","RebirthPanel"}) do
	local panel=gui:FindFirstChild(name)
	if panel then
		local constraint=Instance.new("UISizeConstraint")
		constraint.MinSize=Vector2.new(280,220)
		constraint.MaxSize=Vector2.new(620,520)
		constraint.Parent=panel
	end
end

print("[Smash Legends] responsive HUD ready")
