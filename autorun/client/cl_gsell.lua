local pressedEnt = true

hook.Add("PlayerButtonDown", "gSellEntAddToInv", function(ply, button)
    if button == KEY_E and input.IsKeyDown(KEY_LCONTROL) and pressedEnt then
        local tr = util.TraceLine({
            start = ply:EyePos(),
            endpos = ply:EyePos() + ply:EyeAngles():Forward() * 100,
            filter = ply
        })

        print(tr.Entity)
        if IsValid(tr.Entity) and tr.Entity.Base == "gsellent" then
            net.Start("gSellAddEntity")
            net.WriteEntity(tr.Entity)
            net.SendToServer()

            pressedEnt = false 
            timer.Simple(1, function() pressedEnt = true end)
        end
    end
end)

surface.CreateFont("gSellFont", {
    font = "Arial",
    size = 30
})

local isOpen = false 
local panel = {}

net.Receive("gOpenSellNPC", function()
    local ply = LocalPlayer()
    local curInv = net.ReadTable()

    if not isOpen then
        panel = vgui.Create("DFrame")
        panel:SetPos(500, ScrH() / 2)
        panel:SetSize(500, 300)
        panel:Center()
        panel:SetTitle("")
        panel:SetDraggable(false)
        panel:MakePopup()

        local items = vgui.Create("DScrollPanel", panel)
        items:Dock(FILL)

        for k, v in ipairs(curInv) do
            local frame = vgui.Create("DPanel", items)
            frame:SetSize(items:GetWide(), 20)
            frame:Dock(TOP)

            local sell = vgui.Create("DButton", frame)
            sell:SetSize(items:GetWide(), 20)
            sell:SetText(v[1] .. " #In Inv = " .. v.count)
            sell:Dock(FILL)

            local num = vgui.Create("DNumberWang", frame)
            num:Dock(RIGHT)
            num:SetSize(50, 20)
            num:SetMax(v.count)
            num:SetMin(1)
            num:SetValue(1)
        
            sell.DoClick = function()
                local name = v[1]
                local ammountToSell = num:GetValue()
                local tab = {name, ammountToSell}
                
                net.Start("gSellingInv")
                net.WriteTable(tab)
                net.SendToServer()

                panel:Close()
            end

            items:Add(frame)

        end

        isOpen = true 



        -- Default panel
        panel.Paint = function(self, w, h)
            draw.RoundedBox(2, 0, 0, w, h, Color(0, 0, 0, 180))

            draw.DrawText("Sell", "gSellFont", 250, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end

        panel.OnClose = function()
            isOpen = false
        end
    end
end)