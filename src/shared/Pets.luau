local Pets = {}

Pets.Eggs = {
	Greenyard = {Price=250, Zone=1, Pets={{Name="Bunny",Rarity="Common",Weight=55,Power=1.12},{Name="Bee",Rarity="Rare",Weight=28,Power=1.25},{Name="Fox",Rarity="Epic",Weight=13,Power=1.5},{Name="Forest Golem",Rarity="Legendary",Weight=4,Power=2.1}}},
	Construction = {Price=2200, Zone=2, Pets={{Name="Robo Pup",Rarity="Common",Weight=55,Power=1.45},{Name="Drill Bot",Rarity="Rare",Weight=28,Power=1.7},{Name="Loader Cub",Rarity="Epic",Weight=13,Power=2.05},{Name="Traffic Dragon",Rarity="Legendary",Weight=4,Power=2.8}}},
	Crystal = {Price=15000, Zone=3, Pets={{Name="Gem Bat",Rarity="Common",Weight=55,Power=1.9},{Name="Crystal Fox",Rarity="Rare",Weight=28,Power=2.25},{Name="Shard Sprite",Rarity="Epic",Weight=13,Power=2.75},{Name="Crystal Golem",Rarity="Legendary",Weight=4,Power=3.8}}},
	Magma = {Price=90000, Zone=4, Pets={{Name="Fire Slime",Rarity="Common",Weight=55,Power=2.5},{Name="Lava Hound",Rarity="Rare",Weight=28,Power=3.0},{Name="Ember Golem",Rarity="Epic",Weight=13,Power=3.7},{Name="Phoenix",Rarity="Legendary",Weight=4,Power=5.1}}},
	Void = {Price=450000, Zone=5, Pets={{Name="Void Eye",Rarity="Common",Weight=55,Power=3.4},{Name="Shadow Cub",Rarity="Rare",Weight=28,Power=4.0},{Name="Cosmic Golem",Rarity="Epic",Weight=13,Power=5.0},{Name="Void Dragon",Rarity="Legendary",Weight=3.8,Power=7.0},{Name="Null Star",Rarity="Secret",Weight=.2,Power=12}}},
}

function Pets.roll(eggName,rng)
	local egg=Pets.Eggs[eggName]; if not egg then return nil end
	rng=rng or Random.new(); local total=0
	for _,pet in ipairs(egg.Pets) do total += pet.Weight end
	local roll=rng:NextNumber(0,total); local cursor=0
	for _,pet in ipairs(egg.Pets) do
		cursor += pet.Weight
		if roll <= cursor then return table.clone(pet) end
	end
	return table.clone(egg.Pets[#egg.Pets])
end

return Pets
