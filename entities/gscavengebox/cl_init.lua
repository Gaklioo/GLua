include("shared.lua")

surface.CreateFont("gScavengeBox", {
    font = "Arial",
    size = 150
})

local shouldDraw = false
local PressedE = false 
local hitTime = 0
local currTime = 0


hook.Add("HUDPaint", "gScavengeStuff", function()
    if shouldDraw then  
        draw.SimpleText("Harvesting ... " .. math.Round(hitTime - currTime, 0), "gScavengeBox", ScrW() / 2, ScrH() / 2, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
    end
end)

hook.Add("KeyPress", "gScavengeKeyPress", function(ply, key)
    if key == IN_USE then
        PressedE = true
        currTime = CurTime()
    else
        PressedE = false
    end
    
end)

function ENT:Draw()
    local ply = LocalPlayer()
    self:DrawModel()

    if PressedE then
        local tr = util.TraceLine({
            start = ply:EyePos(),
            endpos = ply:EyePos() + ply:EyeAngles():Forward() * 200,
            filter = ply
        })

        if tr.Hit and tr.Entity:GetClass() == "gscavengebox" then -- Hard coding because of odd issues that result in the spawned entity thinking its scavengeable
            hitTime = CurTime()
            shouldDraw = true
        else
            shouldDraw = false
        end
    end
end

function ENT:Think()
    self:NextThink(CurTime() + 0.5)
    local ply = LocalPlayer() -- In both draw and think it causes errors when local player is globally defined, so in function they go
    local plyPos = ply:GetPos()
    local entPos = self:GetPos()

    if math.Distance(plyPos.x, plyPos.y, entPos.x, entPos.y) <= 50 then
        self:Draw()
    else
        shouldDraw = false
    end
    
    if hitTime - currTime >= 5 then
        shouldDraw = false
        
        net.Start("gCheckScavenge")
        net.WriteEntity(self)
        net.SendToServer()

        --Reset variables for next scavenge, because time is an illusion
        hitTime = 0
        currTime = 0
        PressedE = false

        self:NextThink(CurTime() + 5)
    end
end
