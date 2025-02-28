ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "gprinterbase"
ENT.Category = "gPrinters"
ENT.Spawnable = true 

ENT.Printtime = 1
ENT.MoneyPerPrint = 100
ENT.Color = Color(255, 255, 255, 255)
ENT.printTime = 5
ENT.printAmmount = 100

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "StoredMoney")
end