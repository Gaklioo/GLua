ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "gRock"
ENT.Category = "gMining"
ENT.Spawnable = true 
ENT.Drop = "nil"
ENT.Cooldown = 5

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "NextHitTime")
    self:NetworkVar("Bool", 1, "CanSpawnItem")
end