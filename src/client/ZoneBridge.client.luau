local ReplicatedStorage=game:GetService("ReplicatedStorage")
local net=ReplicatedStorage:WaitForChild("SmashNet")
local state=net:WaitForChild("State")
local action=net:WaitForChild("Action")

state.OnClientEvent:Connect(function(kind,payload)
	if kind=="ZoneUnlocked" and type(payload)=="number" then
		action:FireServer("ZoneUnlocked",payload)
	end
end)
