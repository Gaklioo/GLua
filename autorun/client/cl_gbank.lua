local curPlayerBal = 0

net.Receive("gBankRecieveBalance", function()
    local bal = net.ReadUInt(32)
    print("Bal: ", bal)
    curPlayerBal = bal
    print("curBal: ", curPlayerBal )
end)

hook.Add("OnPlayerChat", "gBankCheckMoney", function(ply, strText, bTeam, bDead)
    if strText == "/bal" then
        print(curPlayerBal)
    end
end)

