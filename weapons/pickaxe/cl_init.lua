include("shared.lua")

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()

    local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 200,
        filter = ply
    })

    if IsValid(tr.Entity) and tr.Entity.Base == "grockbase" then
        print("Hitting Entity")
        tr.Entity:IsHit()
    end

    self:SetNextPrimaryFire(CurTime() + 5 )
end 

function SWEP:SecondaryAttack()

end