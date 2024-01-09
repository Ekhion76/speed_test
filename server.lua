RegisterCommand('speedtest', function(source, args, user)
    TriggerClientEvent('speedTest:toggle', source)
end, true)

RegisterCommand('speedroad',  function(source, args, user)
    TriggerClientEvent('speedTest:teleport', source)
end, true)