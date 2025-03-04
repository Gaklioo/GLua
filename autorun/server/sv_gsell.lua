local _P = FindMetaTable("Player")
local TABLE_NAME = "gsellitemdb"

if not sql.TableExists(TABLE_NAME) then
    sql.Begin()
        sql.Query("CREATE TABLE `" .. TABLE_NAME .. "` (id char(17), name varchar(255), count int, price int, primary key(id, name))")
    sql.Commit()
end

local inv = {}
local testing = false

function _P:Init()
    self.inv = {} -- Only store ent name and count

    local steamid = sql.SQLStr(self:SteamID64(), true)
    local qry = string.format("SELECT * FROM %s where id = %s;", TABLE_NAME, steamid)
    local res = sql.Query(qry)

    if res then
        for _, r in ipairs(res) do
            local itemAdded = {r.name, ["count"] = r.count, ["price"] = r.price}
            table.insert(self.inv, itemAdded)
        end
    end
end

--Helper function
function _P:GetItemCount(name)
    return self.inv[name].count
end

function _P:RemoveItem(name, count)
    local index = 0
    local amt = 0

    for k, v in ipairs(self.inv) do
        if v[1] == name then
            index = k
        end 
    end

    amt = self.inv[index].count - count

    if amt == 0 then
        local qry = string.format("DELETE FROM %s WHERE id = %s and name = '%s'", TABLE_NAME, self:SteamID64(), name)
        sql.Query(qry)
        table.remove(self.inv, index)
    else
        self.inv[index].count = amt
    end
end

function _P:GetItemIndex(name)
    for k, v in ipairs(self.inv) do
        if v[1] == name then
            return k
        end 
    end
end

-- Dont error check here, when the player sells at the NPC, the npc will calculate how much they can sell max. Check gsellent
function _P:SellItem(name, count)
    local index = self:GetItemIndex(name)
    local sellAmmt = self.inv[index].price
    local amt = sellAmmt * count

    self:RemoveItem(name, count)

    hook.Run("gBankAddMoney", self:SteamID(), amt, self)
end

--Error checking done before getting called
function _P:AddItem(name, price)
    for k, v in ipairs(self.inv) do
        if v[1] == name then
            v.count = v.count + 1
            return
        end 
    end

    --If we havent found it in their inventory, then just add it.
    table.insert(self.inv, {name, ["count"] = 1, ["price"] = price})
end

function _P:PrintInv()
    for k, v in ipairs(self.inv) do
        print(v[1], v.count)
    end
end

--Two different functions to save items, as its easier to do in my mind
--Error checking throws errors but saves correctly, For future there will be a
--Select count statement, from what we expect vs what we actually have in database
function saveItem(steamid, name, count)
    local qry = string.format("UPDATE %s SET count = %d where id = %s and name = '%s';", TABLE_NAME, count, steamid, name)
    local res = sql.Query(qry)
end

function saveNewItem(steamid, name, count, price)
    local qry = string.format("INSERT INTO %s (id, name, count, price) VALUES (%s, '%s', %d, %d);", TABLE_NAME, steamid, name, count, price)
    local res = sql.Query(qry)
end

function _P:SaveInv()
    local steamid = sql.SQLStr(self:SteamID64(), true)

    for k, v in ipairs(self.inv) do
        local strQuery = string.format("SELECT * FROM %s WHERE id = %s and name = '%s';", TABLE_NAME, steamid, v[1])
        local exists = sql.QueryValue(strQuery)

        if exists then
            saveItem(steamid, v[1], v.count)
        else
            saveNewItem(steamid, v[1], v.count, v.price)
        end
    end

end

util.AddNetworkString("gSellingInv")
net.Receive("gSellingInv", function(len, ply)
    local table = net.ReadTable()
    ply:SellItem(table[1], table[2])
    net.Start("gOpenSellNPC")
    net.WriteTable(ply.inv)
    net.Send(ply)
end)

util.AddNetworkString("gSellAddEntity")
net.Receive("gSellAddEntity", function(len, ply)
    local ent = net.ReadEntity()
    ply:AddItem(ent.PrintName, ent.BasePrice)
    ent:Remove()
end)

hook.Add("PlayerInitialSpawn", "gSellInitInv", function(ply)
    ply:Init()
    if testing then
        ply:AddItem("hello")
        ply:PrintInv()
    end
end)

if testing then
    concommand.Add("add", function(player, cmd, args)
        player:AddItem(args[1])
        player:PrintInv()
    end)
end

hook.Add("PlayerDisconnected", "gSellSavePlayer", function(ply)
    ply:SaveInv()
end)