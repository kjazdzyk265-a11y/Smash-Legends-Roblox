local Quests = {}

Quests.List = {
    {Id="smash10", Title="Warm Up", Description="Destroy 10 objects", Kind="Smash", Goal=10, RewardCoins=250},
    {Id="strength500", Title="Getting Strong", Description="Reach 500 Strength", Kind="Strength", Goal=500, RewardCoins=500},
    {Id="hatch3", Title="Pet Collector", Description="Hatch 3 eggs", Kind="Hatch", Goal=3, RewardCoins=900},
    {Id="perfect5", Title="Perfect Timing", Description="Land 5 Perfect Smashes", Kind="Perfect", Goal=5, RewardCoins=1200},
    {Id="zone3", Title="Deep Explorer", Description="Reach Zone 3", Kind="Zone", Goal=3, RewardCoins=2500},
}

function Quests.makeState()
    local state = {}
    for _,q in ipairs(Quests.List) do state[q.Id] = {Progress=0, Claimed=false} end
    return state
end

return Quests
