local money = 0

net.Receive("gBankRecieveBalance", function()
    local bal = net.ReadUInt(32)
    money = bal
end)


hook.Add("HUDPaint", "gHudPaint", function()
    local scrw, scrh = ScrW(), ScrH()
    local player = LocalPlayer()
    local health = player:Health()
    local armor = player:Armor()
    local maxArmor = player:GetMaxArmor()
    local maxHealth = player:GetMaxHealth()

    local baseYPos = scrh * 0.4

    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(0, baseYPos, 500, 200)
    if IsValid(player:GetActiveWeapon()) then
        surface.DrawRect(scrw / 1.25, scrh / 1.1, 500, 100)
        draw.DrawText(player:GetActiveWeapon():Clip1() .. " / ", "gHudGuns", (scrw / 1.25) + 150, scrh / 1.1, white, TEXT_ALIGN_CENTER)
        draw.DrawText(player:GetAmmoCount(player:GetActiveWeapon():GetPrimaryAmmoType()), "gHudGuns", (scrw / 1.25) + 250, scrh / 1.1)
    end

    surface.SetDrawColor(0, 0, 255, 160)
    surface.DrawRect(50, baseYPos + 150, (baseYPos * (armor / maxArmor)) / 1.28, 10)
    draw.DrawText("Armor", "gHudText", 25, baseYPos + 147, white, TEXT_ALIGN_CENTER)
    draw.DrawText(armor, "gHudText", 400, baseYPos + 147, white, TEXT_ALIGN_CENTER)

    surface.SetDrawColor(255, 0, 0, 160)
    surface.DrawRect(50, baseYPos + 75, (baseYPos * (health / maxHealth)) / 1.28, 10)
    draw.DrawText("Health", "gHudText", 25, baseYPos + 72, white, TEXT_ALIGN_CENTER)
    draw.DrawText(health, "gHudText", 400, baseYPos + 72, white, TEXT_ALIGN_CENTER)

    draw.DrawText(player:GetName(), "gHudText", 25, baseYPos + 20, white, TEXT_ALIGN_CENTER)
    draw.DrawText("$" .. money, "gHudText", 400, baseYPos + 20, white, TEXT_ALIGN_CENTER)

end)

surface.CreateFont("gHudFont", {
    font = "Arial",
    size = 35
})

surface.CreateFont("gHudText", {
    font = "Arial",
    size = 15
})

surface.CreateFont("gHudGuns", {
    font = "Arial",
    size = 100
})

local white = Color(255, 255, 255, 255)

local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true
}

hook.Add("HUDShouldDraw", "hideDefaultHud", function(n)
    if(hide[n]) then
        return false
    end
end)

concommand.Add("wep", function(player)
    local wep = player:GetActiveWeapon()
    if IsValid(wep) then
        PrintTable(wep:GetTable())
    end
end)