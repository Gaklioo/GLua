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

    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Think()
    self:NextThink(CurTime() + self.printTime)

    if IsValid(self) then
        self:SetStoredMoney(self:GetStoredMoney() + self.printAmmount)
    end

    return true
end

function ENT:collectMoney(ply)
    local amt = self:GetStoredMoney()

    if amt > 0 then
        hook.Run("gBankAddMoney", ply:SteamID(), amt, ply)
    end
end

function ENT:Use(act, call, type, val)
    self:collectMoney(act)
    self:SetStoredMoney(0)
end
