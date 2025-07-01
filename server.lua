RegisterServerEvent('MrJujuri:EngineSystem:server:checkPermission')
AddEventHandler('MrJujuri:EngineSystem:server:checkPermission', function()
    local src = source
    local permType = GetPlayerAcePermissionType(src)

    if permType == 'none' then
        TriggerClientEvent('MrJujuri:EngineSystem:client:noPermission', src)
        return
    end

    local steam = GetPlayerIdentifierByType(src, 'steam')
    TriggerClientEvent('MrJujuri:EngineSystem:client:openMenu', src, permType, steam)
end)

function GetPlayerAcePermissionType(src)
    if IsPlayerAceAllowed(src, 'mrjujuri.enginesound.admin') then
        return 'admin'
    elseif IsPlayerAceAllowed(src, 'mrjujuri.enginesound.donator') then
        return 'donator'
    end
    return 'none'
end

RegisterServerEvent('MrJujuri:EngineSystem:server:applySound')
AddEventHandler('MrJujuri:EngineSystem:server:applySound', function(netId, audio)
    local src = source
    if Config.UsePermissions and not (IsPlayerAceAllowed(src, "mrjujuri.enginesound.admin") or IsPlayerAceAllowed(src, "mrjujuri.enginesound.donator")) then
        TriggerClientEvent('MrJujuri:EngineSystem:client:noPermission', src)
        return
    end

    if vehicle and DoesEntityExist(vehicle) then
        local class = GetVehicleClass(vehicle)
        if class == 18 or IsVehicleElectric(vehicle) then return end -- blokir polisi/listrik

        Entity(vehicle).state:set('tunerData', audio, true)
    end


    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle and DoesEntityExist(vehicle) then
        Entity(vehicle).state:set('tunerData', audio, true)
    end
end)

RegisterServerEvent('MrJujuri:EngineSystem:server:resetSound')
AddEventHandler('MrJujuri:EngineSystem:server:resetSound', function(netId)
    local src = source
    if not (IsPlayerAceAllowed(src, "mrjujuri.enginesound.admin") or IsPlayerAceAllowed(src, "mrjujuri.enginesound.donator")) then
        TriggerClientEvent('MrJujuri:EngineSystem:client:noPermission', src)
        return
    end

    if vehicle and DoesEntityExist(vehicle) then
        local class = GetVehicleClass(vehicle)
        if class == 18 or IsVehicleElectric(vehicle) then return end -- blokir polisi/listrik

        Entity(vehicle).state:set('tunerData', audio, true)
    end


    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle and DoesEntityExist(vehicle) then
        Entity(vehicle).state:set('tunerData', nil, true)
    end
end)
