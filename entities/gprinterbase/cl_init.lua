include("shared.lua")

surface.CreateFont("gPrinterFont", {
	font = "Arial",
	size = 40
})

function ENT:Draw()
    self:DrawModel()

    local pos = self:GetPos()
    local ang = self:GetAngles()

    ang:RotateAroundAxis(ang:Up(), 90)

    cam.Start3D2D(pos + ang:Up() * 10.7, ang, 0.11)
        --Outline box
        draw.RoundedBox(3, -128, -141, 259, 265, Color(0, 0, 0, 150))
        draw.DrawText(self:GetClass(), "gPrinterFont", 0, -55, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

        --Money
        draw.RoundedBox(3, -128, 25, 259, 100, Color(0, 0, 0, 200))
        draw.DrawText("$" .. self:GetStoredMoney(), "gPrinterFont", 0, 55, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

        --Flex I made this type box
        draw.RoundedBox(3, -128, -141, 259, 50, Color(0, 0, 0, 200))
        draw.DrawText("Created by Gak", "gPrinterFont", 0, -141, Color(255, 255, 255 ,255), TEXT_ALIGN_CENTER)

    cam.End3D2D()
end