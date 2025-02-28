AddCSLuaFile("cl_init.lua")
AddCSLuaFile("config.lua")

include("config.lua")
util.AddNetworkString("setAbility")

local curTargets = {} -- Store entity information if they are a player

function SWEP:Materialize()
    if self:GetCurrentEnergy() < self.EnergyMaterialize then return end

    local owner = self:GetOwner()
    owner:Give("weapon_bugbait")
end

function SWEP:IgnitePlayer()
    if self:GetCurrentEnergy() < self.EnergyIgnite then return end

    if curTargets then
        for _, p in ipairs(curTargets) do
            p:Ignite(5)
        end
    end

    self:SetCurrentEnergy(self:GetCurrentEnergy() - self.EnergyIgnite)
end

function SWEP:ExplodeHead()
    if self:GetCurrentEnergy() < self.EnergyExplodeHead then return end

    if curTargets then
        for _, p in ipairs(curTargets) do
            p:Kill()
        end
    end
end

function SWEP:Detain()
    if self:GetCurrentEnergy() < self.EnergyDetain then return end

    if curTargets then
        
    end

end

local isInverted = false
local currentPlayer = nil 

function setCurPlayer(ply)
    currentPlayer = ply
end

hook.Add("EntityTakeDamage", "realityBendingInversionHook", function(target, dmgInfo)
    if target:IsPlayer() and IsValid(target) and isInverted and target == currentPlayer and target:Health() <= 500 then
        local healAmount = dmgInfo:GetDamage() / 2

        target:SetHealth(math.min(target:GetMaxHealth(), target:Health() + healAmount))

        dmgInfo:SetDamage(0)
    end
end)

function SWEP:Inversion(ply)
    if self:GetCurrentEnergy() < self.EnergyInversion then return end

    isInverted = true
    ply:SetMaxHealth(500)

    print(isInverted)
    setCurPlayer(ply)

    timer.Simple(30, function() 
        print("inversion is now false")
        isInverted = false
    end)
    
end

function SWEP:EscapeCard()
    if self:GetCurrentEnergy() < self.EnergyEscapeCard then return end

    
end


local curAbility

function SWEP:PrimaryAttack()

    print(curAbility, " Ability")

    if curAbility == "Materialize" then
        self:Materialize()
    elseif curAbility == "Ignite" then
        self:IgnitePlayer()
    elseif curAbility == "Explode Head" then
        self:ExplodeHead()
    elseif curAbility == "Detain" then
        self:Detain()
    elseif curAbility == "Invert" then
        self:Inversion(ply)
    elseif curAbility == "Escape Card" then
        self:EscapeCard()
    else
        return
    end

    curTargets = {}

    self:SetNextPrimaryFire( CurTime() + 10)
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()

    local tr = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * 1000,
        filter = owner,
        mask = MASK_SHOT_HULL
    })
    
    if IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:Health() > 0) then
        if self:GetCurrentAbility() == "Ignite" or self:GetCurrentAbility() == "Explode Head" then
            if #curTargets < 2 then
                table.insert(curTargets, tr.Entity)
                print("Added entity to targets: " .. tostring(tr.Entity))
            else
                curTargets = {}
                print("Resetting curTargets as it already has 2 entities.")
            end
        elseif self:GetCurrentAbility() == "Detain" or self:GetCurrentAbility() == "Escape Card" then
            if #curTargets <= 1 then
                table.insert(curTargets, tr.Entity)
                print("Added entity to detain: " .. tostring(tr.Entity))
            else
                curTargets = {}
                print("Resetting curTargets to 1 for new detainee")
            end
        end
    end
    
end

local selector = nil
local isOpen = false

function SWEP:rechargeEnergy()
    if self:GetCurrentEnergy() < 300 then
        self:SetCurrentEnergy(self:GetCurrentEnergy() + 3)
    end
end

function SWEP:Initialize()
    self:SetCurrentEnergy(300)
end

function SWEP:Think()
    curAbility = self:GetCurrentAbility()
    local ply = self:GetOwner()

    if ply:GetActiveWeapon() == self and not timer.Exists("rb_EnergyRecharge") then
        timer.Create("rb_EnergyRecharge", self.EnergyRecharge, 0, function()
            if self:GetCurrentEnergy() < 300 then
                self:SetCurrentEnergy(self:GetCurrentEnergy() + 3)
            end
        end)
    end

    net.Receive("setAbility", function()
        self:SetCurrentAbility(net.ReadString()) 
        curAbility = self:GetCurrentAbility()
    end)
end