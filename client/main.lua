local hasGSR = {}
local washingOff = false

RegisterNetEvent('DE_gsr:updateData')
AddEventHandler('DE_gsr:updateData', function(data)
    hasGSR = data
end)

CreateThread(function()
    while true do

        local playerId = PlayerId()
        local serverId = GetPlayerServerId(playerId)

        if IsPedShooting(cache.ped) and not hasGSR[serverId] then
            TriggerServerEvent('DE_gsr:addGSR')

            while IsPedShooting(cache.ped) do
                Wait(100)
            end

            lib.notify({type = 'inform', description = 'Smells of gun powder.'})
            AutoRemove()
        end

        Wait(5)
    end
end)

CreateThread(function()
    while true do

        local playerId = PlayerId()
        local serverId = GetPlayerServerId(playerId)

        if IsEntityInWater(cache.ped) and hasGSR[serverId] and not washingOff and Config.WashInWater then
            washingOff = true

            lib.progressCircle({
                duration = Config.WashTimer * 1000,
                label = 'Washing off GSR...',
                position = 'bottom',
                allowSwimming = true,
                useWhileDead = false,
                canCancel = false,
            })

            if not IsEntityInWater(cache.ped) then
                lib.notify({type = 'error', description = 'You went out of the water too quickly!'})
            else
                lib.notify({type = 'success', description = 'You have successfully washed off your gunshot residue.'})
                TriggerServerEvent('DE_gsr:removeGSR')
            end

            washingOff = false
        end

        Wait(1000)
    end
end)

CreateThread(function()
    while true do

        if washingOff and lib.progressActive() and not IsEntityInWater(cache.ped) then
            lib.cancelProgress()
            washingOff = false
        end

        Wait(2000)
    end
end)

AutoRemove = function()
    local timer = Config.GSRAutoRemove * 60

    CreateThread(function()
        while timer > 0 do

            local playerId = PlayerId()
            local serverId = GetPlayerServerId(playerId)

            timer -= 1

            if timer == 0 and hasGSR[serverId] then
                TriggerServerEvent('DE_gsr:removeGSR')
                lib.notify({type = 'inform', description = 'Your gunshot residue has went away.'})
            end

            Wait(1000)
        end
    end)
end

exports.ox_target:addGlobalPlayer({
    {
        label = 'Check for GSR',
        icon = 'fas fa-gun',
        groups = 'police',
        onSelect = function(data)
            local coords = GetEntityCoords(cache.ped)
            local targetId, targetPed, targetCoords = lib.GetClosestPlayer(coords)
            local targetServerId = GetPlayerServerId(targetId)

            if hasGSR[targetServerId] then
                lib.notify({type = 'inform', description = 'GSR Result: POSITIVE.'})
            else
                lib.notify({type = 'inform', description = 'GSR Result: NEGATIVE.'})
            end
        end,
    }
})