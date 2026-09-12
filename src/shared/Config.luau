local Config = {}

Config.Tools = {
    {Name = "Wooden Hammer", Price = 0, Damage = 8, Training = 1},
    {Name = "Stone Mallet", Price = 120, Damage = 16, Training = 1.15},
    {Name = "Iron Hammer", Price = 450, Damage = 32, Training = 1.35},
    {Name = "Steel Sledge", Price = 1400, Damage = 65, Training = 1.65},
    {Name = "Golden Crusher", Price = 4200, Damage = 125, Training = 2.0},
    {Name = "Crystal Maul", Price = 12500, Damage = 240, Training = 2.45},
}

Config.Breakables = {
    Crate = {MaxHP = 35, Reward = 10, Respawn = 3, Material = "Wood"},
    Barrel = {MaxHP = 70, Reward = 18, Respawn = 4, Material = "Wood"},
    Fence = {MaxHP = 130, Reward = 30, Respawn = 5, Material = "Wood"},
    Rock = {MaxHP = 260, Reward = 55, Respawn = 5, Material = "Stone"},
    Safe = {MaxHP = 700, Reward = 150, Respawn = 8, Material = "Metal"},
    Crystal = {MaxHP = 1600, Reward = 420, Respawn = 10, Material = "Crystal"},
    Gate = {MaxHP = 3500, Reward = 900, Respawn = 20, Material = "Stone"},
}

Config.Training = {
    BaseGain = 3,
    Cooldown = 0.45,
}

Config.PerfectWindow = 0.16
Config.CritChance = 0.08
Config.CritMultiplier = 2
Config.PerfectMultiplier = 1.5

return Config
