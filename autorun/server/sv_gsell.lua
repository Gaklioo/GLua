local _P = FindMetaTable("Player")
local TABLENAME = "gselldatabase"

if not sql.TableExists(TABLENAME) then
    sql.Begin()
        sql.Query("CREATE TABLE `" .. TABLENAME .. "` (id char(17), name varchar(255), count int, primary key(id, name))")
    sql.Commit()
end

local inv = {}
local testing = true

function _P:Init()
    self.inv = {} -- Only store ent name and count

    local steamid = sql.SQLStr(self:SteamID(), true)
    local qry = string.format("SELECT * FROM %s where id = %s", TABLENAME, steamid)
    local res = sql.Query(qry)

    if res then
        for _, r in ipairs(res) do
            local itemAdded = {r.name, r.count}
            table.insert(self.inv, itemAdded)
        end
    end
end

--Helper function
function _P:GetItemCount(name)
    return self.inv[name].count
end

-- Dont error check here, when the player sells at the NPC, the npc will calculate how much they can sell max. Check gsellent
function _P:SellItem(name, count)
    local ent = ents.FindByName(name)
    local sellAmmt = ent.BasePrice
    local amt = sellAmmt * count

    hook.Run("gBankAddMoney", self:SteamID(), amt, self)
end

--Error checking done before getting called
function _P:AddItem(name)
    for k, v in ipairs(self.inv) do
        if v[1] == name then
            v.count = v.count + 1
            return
        end 
    end

    --If we havent found it in their inventory, then just add it.
    table.insert(self.inv, {name, ["count"] = 1})
end

function _P:PrintInv()
    for k, v in ipairs(self.inv) do
        print(v[1], v.count)
    end
end

function doesItemExist(steamid, name)
    local qry = string.format("SELECT EXISTS (SELECT 1 FROM %s WHERE id = %s AND name = %s)", TABLENAME, steamid, name)

    local res = sql.Query(qry)

    if res then
        return true 
    else
        return false 
    end
end

--Two different functions to save items, as its easier to do in my mind
function saveItem(steamid, name, count)
    local qry = string.format("UPDATE %s SET count = %s where id = %s and name = %s;", TABLENAME, sql.SQLStr(steamid, true), name, count)
    local res = sql.Query(qry)

    if not res then
        print("Error saving item:", sql.LastError())
    else
        print("Item saved successfully.")
    end
end

function saveNewItem(steamid, name, count)
    local qry = string.format("INSERT INTO %s (id, name, count) VALUES (%s, %s, %d);", TABLENAME, sql.SQLStr(steamid, true), name, count)
    local res = sql.Query(qry)

    if not res then
        print("Error saving new item:", sql.LastError())
    else
        print("Item saved successfully.")
    end
end

function _P:SaveInv()
    local steamid = sql.SQLStr(self:SteamID(), true)
    /*

    local strQuery = string.format("SELECT EXISTS (SELECT 1 FROM `%s` WHERE id = '%s')", TABLENAME, steamid)
    local exists = sql.Query(strQuery)

    if exists then
        for k, v in ipairs(self.inv) do
            if doesItemExist(steamid, v[1]) then
                saveItem(steamid, v[1], v.count)
            else
                saveNewItem(steamid, v[1], v.count)
            end
        end
    else
        for k, v in ipairs(self.inv) do
            saveNewItem(steamid, v[1], v.count)
        end
    end

    */

    for k, v in ipairs(self.inv) do
        local strQuery = string.format("SELECT EXISTS (SELECT 1 FROM %s WHERE id = %s and name = %s)", TABLENAME, steamid, v[1])
        local exists = sql.Query(strQuery)

        if exists and tonumber(exists[1]["exists"]) then
            saveItem(steamid, v[1], v.count)
        else
            saveNewItem(steamid, v[1], v.count)
        end
    end

end

hook.Add("PlayerInitialSpawn", "gSellInitInv", function(ply)
    ply:Init()
    if testing then
        ply:AddItem("hello")
    end

    ply:PrintInv()
end)

concommand.Add("add", function(player, cmd, args)
    player:AddItem(args[1])
    player:PrintInv()
end)

hook.Add("PlayerDisconnected", "gSellSavePlayer", function(ply)
    ply:SaveInv()
end)