AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
util.AddNetworkString("gOpenSellNPC")

function ENT:Initialize()
    self:SetModel("models/Humans/Group01/Female_04.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use(act)
    net.Start("gOpenSellNPC")
    net.WriteTable(act.inv)
    net.Send(act)
end