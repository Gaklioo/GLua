include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local pos = self:GetPos()
    local ang = self:GetAngles()

    ang:RotateAroundAxis(ang:Up(), 90)

    cam.Start3D2D(pos + ang:Up() * 10.7, ang, 0.11)

        --Flex I made this type box
        draw.RoundedBox(3, -128, -141, 259, 50, Color(0, 0, 0, 200))
        draw.DrawText("Created by Gak", "gPrinterFont", 0, -141, Color(255, 255, 255 ,255), TEXT_ALIGN_CENTER)

    cam.End3D2D()
end

function ENT:IsHit()
    net.Start("gRockPlayerHit")
    net.WriteEntity(self)
    net.SendToServer()
end