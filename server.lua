RedEM = exports["redem_roleplay"]:RedEM()

data = {}
TriggerEvent("redemrp_inventory:getData",function(call)
    data = call
end)

RegisterServerEvent("RegisterUsableItem:chikencoop")
AddEventHandler("RegisterUsableItem:chikencoop", function(source)
	local _source = source
    TriggerClientEvent('chikens:setcoop', _source)
end)


RegisterServerEvent('chikens:getEggs')
AddEventHandler('chikens:getEggs',function (amout)
       
    print("amout",amout)
            ItemData = data.getItem(source, 'egg')
            ItemData.AddItem(amout)
            TriggerClientEvent("redem_roleplay:NotifyLeft", source, "Galinheiro", 'Recebeu '..amout..' ovo(s)', "generic_textures", "tick", 3000)
       
end)