AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/consolebox01a.mdl")
    self:SetMaterial("models/debug/debugwhite")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    self:SetCanSpawnItem(true)

    if phys:IsValid() then
        phys:Wake()
    end
end

util.AddNetworkString("gRockPlayerHit")
net.Receive("gRockPlayerHit", function()
    local ent = net.ReadEntity()

    ent:SetNextHitTime(CurTime() + ent.Cooldown)

    if ent:GetCanSpawnItem() then
        ent:SetCanSpawnItem(false)
        ent:SpawnItem()
    end
end)

function ENT:Think()
    if self:GetNextHitTime() <= CurTime() then
        self:SetCanSpawnItem(true)
    end

    self:NextThink(CurTime() + 1)
end

function ENT:SpawnItem()
    if self.Drop ~= nil then 
        local entC = ents.Create(tostring(self.Drop))
        entC:SetPos(self:GetPos() + Vector(2, 0, 0))
        entC:SetAngles(self:GetAngles())
        entC:Spawn()
    end
end