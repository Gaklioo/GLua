include("config.lua")

surface.CreateFont("realityBendingEnergy", {
    font = "Arial",
    size = 30
})

hook.Add("HUDPaint", "realityBendingSwep", function()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    local scrw, scrh = ScrW(), ScrH()


    if IsValid(wep) and wep:GetClass() == "realitybending" and IsValid(ply) then
        draw.DrawText(wep:GetCurrentEnergy(), "realityBendingEnergy", scrw / 2, scrh / 1.15, white, TEXT_ALIGN_CENTER)
        draw.DrawText("Energy", "realityBendingEnergy", scrw / 2, scrh / 1.1, white, TEXT_ALIGN_CENTER)

        if wep:GetCurrentAbility() then
            draw.DrawText("Ability", "realityBendingEnergy", scrw / 2, scrh / 1.3, white, TEXT_ALIGN_CENTER)
            draw.DrawText(wep:GetCurrentAbility(), "realityBendingEnergy", scrw / 2, scrh / 1.25, white, TEXT_ALIGN_CENTER)
        end
    end
end)

local isOpen = false
local rb = nil

function SWEP:PrimaryAttack()
    if self:GetCurrentEnergy() == 0 then return end

    self:SetNextPrimaryFire( CurTime() + 10)
    self:SetCurrentAbility(self:GetCurrentAbility())
end


function SWEP:Think()
    local ply = self:GetOwner()

    if input.WasKeyPressed(KEY_R) and not isOpen then
        self:SetCurrentAbility("nil")

        rb = vgui.Create("DFrame")
        rb:SetPos(100, 100)
        rb:SetSize(300, 200)
        rb:SetTitle("")
        rb:Center()
        rb:MakePopup()

        local ab = vgui.Create("DListView", rb)
        ab:Dock(FILL)
        ab:SetMultiSelect(false)
        ab:AddColumn("Ability")

        for _, i in ipairs(abilities) do
            ab:AddLine(i)
        end

        ab.OnRowSelected = function(lst, index, pnl)
            self:SetCurrentAbility(pnl:GetColumnText(1)) 
            net.Start("setAbility")
            net.WriteString(self:GetCurrentAbility())
            net.SendToServer()
            print(self:GetCurrentAbility())
        end
        isOpen = true

        rb.OnClose = function()
            isOpen = false
        end

        print("Pressing R")
    end
end

concommand.Add("wepName", function(ply, cmd, args)
    print(ply:GetActiveWeapon())
end)
