AddCSLuaFile("sh_gbank.lua")
include("sh_gbank.lua")

local playerCache = {}

util.AddNetworkString("gBankRecieveBalance")

if not sql.TableExists(config.sqltable) then
    sql.Begin()
        sql.Query("CREATE TABLE `" .. config.sqltable .. "` (id int PRIMARY KEY, balance int)")
    sql.Commit()
end

function createPlayer(steamid, ply)
    local insertIntoTable = "INSERT INTO `" .. config.sqltable .. "` (id, balance) VALUES ('" .. steamid .. "', '" .. config.startingBalance ..  "')"
    local didInsert = sql.QueryRow(insertIntoTable)

    if not didInsert then 
        print("Failure to create player with id: " .. steamid .. " Error: " .. sql.LastError())
        return
    end

    playerCache[steamid] = config.startingBalance
    print(didInsert)
    print("Ended loading new player")
    return
end

function insertPlayerToCache(steamid, ply)
    if not steamid or steamid == "" then 
        print("Invalid steamid attempting to insert into cache")    
    return end

    local q = "SELECT balance FROM `" .. config.sqltable .. "` where id = '" .. steamid .. "'"
    local res = sql.QueryRow(q)

    if not res then 
        createPlayer(steamid, ply)
        return
    end
    playerCache[steamid] = res.balance

    print("Ended loading player cache")
end

function savePlayerBalance(steamid)

    if not  steamid or steamid == "" then
        print("Invalid steam id provided")
        return
    end

    local bal = playerCache[steamid]
    local q = "UPDATE `" .. config.sqltable .. "` SET balance = '" .. bal .. "' WHERE id = '" .. steamid .. "'"
    local res = sql.QueryRow(q)

    if not res then
        print("Failure to save ", steamid, " to table, please manually update", sql.LastError())
        
        return
    end

    print("Saved player balance into database for player ", steamid)
end

function transferMoney(to, from, amt)
    if playerCache[from] >= amt or playerCache[from] <= 0 then
        print("Unable to transfer money between ", to, " ", from, " Player does not have enough money")
        return
    end

    local toBal = playerCache[to]
    local fromBal = playerCache[from]

    playerCache[to] = toBal + amt
    playerCache[from] = fromBal - amt
end

function SendMoneyToPlayer(ply)
    local steamID = ply:SteamID()
    net.Start("gBankRecieveBalance")
    net.WriteUInt(playerCache[steamID], 32)
    net.Send(ply)
end

hook.Add("gBankTransferMoney", "gBankTransferProcess", function(to, from, amt, ply)
    transferMoney(sql.SQLStr(to, true), sql.SQLStr(from, true), sql.SQLStr(amt, true))
    SendMoneyToPlayer(ply)
end)

hook.Add("gBankGetBalance", "gBankGetPlayerBalance", function(ply)
    print("Called add money")
    SendMoneyToPlayer(ply)
end)

hook.Add("PlayerInitialSpawn", "gBankLoadPlayer", function(ply)
    local steamID = sql.SQLStr(ply:SteamID(), true)
    print(steamID)
    insertPlayerToCache(steamID, ply)
    hook.Run("gBankGetBalance", ply)
    hook.Run("gCharacterCreation", ply)
end)

hook.Add("PlayerDisconnected", "gBankSavePlayer", function(ply)
    local steamID = sql.SQLStr(ply:SteamID(), true)
    print(steamID, "Player Left")
    savePlayerBalance(steamID)
end)

hook.Add("gBankAddMoney", "gBankPlayerAddMoney", function(steamid, amt, ply)
    local steamID = sql.SQLStr(steamid, true)
    local ammount = tonumber(sql.SQLStr(amt, true))

    playerCache[steamid] = playerCache[steamid] + amt
    SendMoneyToPlayer(ply)
end)




