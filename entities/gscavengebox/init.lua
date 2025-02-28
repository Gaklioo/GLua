AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
util.AddNetworkString("gCheckScavenge")

local entsToSpawn = {}

function ENT:Initialize()
    self:SetModel("models/props_c17/TrapPropeller_Engine.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    entsToSpawn = {}
    self:InitializeSpawns()
end

function ENT:InitializeSpawns()
    local files, dir = file.Find(self.filePrefix, "GAME")

    -- For all files in the directory, only find those that start with or include gprinter, as that is what we want to spawn in terms of what can be scavanged
    for _, dirName in ipairs(dir) do
        if string.find(dirName, self.entPrefix) then
            table.insert(entsToSpawn, dirName)
        end
    end
end

function ENT:SpawnRandom()
    local randNum = math.random(1, #entsToSpawn)
    local pos = self:GetPos()
    local angle = self:GetLocalAngles()

    local entC = ents.Create(tostring(entsToSpawn[randNum]))
    entC:SetPos(pos)
    entC:SetAngles(angle)
    entC:Spawn()
end

function ENT:RemoveSelf()
    local class = self:GetClass()

    local pos = self:GetPos()
    local angle = self:GetLocalAngles()

    self:Remove()
    timer.Simple(self.RespawnTime, function()
        if not IsValid(self) then
            local entC = ents.Create(tostring(class))
            entC:SetPos(pos)
            entC:SetAngles(angle)
            entC:Spawn()
        end
    end)
end

net.Receive("gCheckScavenge", function()
    local entC = net.ReadEntity()
    entC:SpawnRandom()
    entC:RemoveSelf()
end)
