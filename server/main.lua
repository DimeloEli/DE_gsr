local hasGSR = {}

RegisterNetEvent('DE_gsr:addGSR')
AddEventHandler('DE_gsr:addGSR', function()
    local source = source

    hasGSR[source] = true
    TriggerClientEvent('DE_gsr:updateData', -1, hasGSR)
end)

RegisterNetEvent('DE_gsr:removeGSR')
AddEventHandler('DE_gsr:removeGSR', function()
    local source = source

    hasGSR[source] = nil
    TriggerClientEvent('DE_gsr:updateData', -1, hasGSR)
end)