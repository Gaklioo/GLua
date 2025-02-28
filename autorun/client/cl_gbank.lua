local curPlayerBal = 0

net.Receive("gBankRecieveBalance", function()
    local bal = net.ReadUInt(32)
    curPlayerBal = bal
end)

hook.Add("OnPlayerChat", "gBankCheckMoney", function(ply, strText, bTeam, bDead)
    if strText == "/bal" then
        print(curPlayerBal)
    end
end)

