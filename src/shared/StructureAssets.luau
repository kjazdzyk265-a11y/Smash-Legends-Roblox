local StructureAssets = {}

-- Only asset IDs explicitly added here are allowed to load.
-- Keep this list curated; the server loader strips all scripts from imported models.
StructureAssets.Items = {
    -- Example shape:
    -- {Id = 123456789, Name = "GreenyardHouse", Position = Vector3.new(-70, 0, 150), RotationY = 0, Scale = 1},
}

return StructureAssets
