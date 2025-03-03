

hook.Add("PlayerButtonDown", "gSellEntAddToInv", function(ply, button)
    if button == IN_USE and input.IsKeyDown(KEY_LCONTROL) then 
        local tr = util.TraceLine({
            start = ply:EyePos(),
            endpos = ply:EyePos() + ply:EyeAngles():Forward() * 5,
            filter = ply
        })

        if IsValid(tr.Entity) and tr.Entity.BaseClass == "gsellent" then
            ply:AddItem(tr.Entity.PrintName)
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
            frame:SetSize(50, 20)
            frame:Dock(TOP)

            local sell = vgui.Create("DButton", frame)
            sell:SetText(v[1] .. " " .. v.count)
            sell:Dock(TOP)

            local num = vgui.Create("DNumberWang", frame)
            num:Dock(RIGHT)
            num:SetSize(50, 20)
            num:SetMax(v.count)

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