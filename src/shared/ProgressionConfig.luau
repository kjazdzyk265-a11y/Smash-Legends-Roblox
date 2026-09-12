local ProgressionConfig = {}

ProgressionConfig.EggStations = {
	{Egg="Greenyard", Zone=1, Position=Vector3.new(48,0,82), Color=Color3.fromRGB(255,214,92)},
	{Egg="Construction", Zone=2, Position=Vector3.new(-48,0,315), Color=Color3.fromRGB(255,145,60)},
	{Egg="Crystal", Zone=3, Position=Vector3.new(48,0,560), Color=Color3.fromRGB(76,224,255)},
	{Egg="Magma", Zone=4, Position=Vector3.new(-48,0,800), Color=Color3.fromRGB(255,88,44)},
	{Egg="Void", Zone=5, Position=Vector3.new(48,0,1030), Color=Color3.fromRGB(184,77,255)},
}

ProgressionConfig.Quests = {
	{Id="break10", Title="WRECKING BALL", Description="Destroy 10 objects", Type="Break", Target=10, RewardCoins=500},
	{Id="train250", Title="GET STRONG", Description="Gain 250 Strength", Type="Strength", Target=250, RewardCoins=750},
	{Id="hatch3", Title="PET COLLECTOR", Description="Hatch 3 pets", Type="Hatch", Target=3, RewardCoins=1200},
	{Id="perfect8", Title="PERFECT TIMING", Description="Land 8 Perfect Smashes", Type="Perfect", Target=8, RewardCoins=900},
}

ProgressionConfig.GiantEvent = {
	Interval=300,
	Duration=120,
	HP=75000,
	Reward=12500,
	Position=Vector3.new(0,0,1145),
}

return ProgressionConfig
