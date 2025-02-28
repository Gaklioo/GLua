SWEP.PrintName = "SCP Reality Bending"
SWEP.Author = "Gak"
SWEP.Instructions = "Press R to choose an ability"

SWEP.Spawnable = true 
SWEP.AdminOnly = false 

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"
SWEP.MaxEnergy = 300
SWEP.CurEnergy = 300
SWEP.EnergyMaterialize = 35
SWEP.EnergyIgnite = 20
SWEP.EnergyExplodeHead = 40
SWEP.EnergyDetain =  30
SWEP.EnergyInversion = 50
SWEP.EnergyEscapeCard = 20
SWEP.InversionEnabled = false
SWEP.EnergyRecharge = 1 -- Seconds to gain +1 energy

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "CurrentEnergy")
    self:NetworkVar("String", 1, "CurrentAbility")
end

abilities = {"Materialize", "Ignite", "Explode Head", "Detain", "Invert", "Escape Card"}