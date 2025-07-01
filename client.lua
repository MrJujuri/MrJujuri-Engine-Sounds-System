local hasPermission = true
local currentTargetVehicle = nil
local electricModels = {
    [`neon`] = true,
    [`cyclone`] = true,
    [`raiden`] = true,
    [`tezeract`] = true,
    [`voltic`] = true,
    [`voltic2`] = true,
    [`imorgon`] = true,
    [`khamelion`] = true,
    [`iwagen`] = true,
    [`virtue`] = true,
    [`thrax2`] = true,
    [`tenf2`] = true,
    [`buffalo4`] = true,
    [`omnisegt`] = true,
}


local function playMechAnim()
    local ped = PlayerPedId()
    RequestAnimDict('mini@repair')
    while not HasAnimDictLoaded('mini@repair') do Wait(0) end
    TaskPlayAnim(ped, 'mini@repair', 'fixing_a_ped', 8.0, -8.0, -1, 1, 0, false, false, false)
end

function getSoundCategories(category)
    local found = {}
    for _, data in pairs(Config.EngineSounds[category]) do
        if data.category and not found[data.category] then
            found[data.category] = true
        end
    end
    return found
end

local function isRestrictedVehicle(vehicle)
    local class = GetVehicleClass(vehicle)
    local model = GetEntityModel(vehicle)

    -- 🔒 Blokir mobil polisi dan listrik
    if class == 18 then return true end -- POLICE
    if electricModels[model] then return true end -- ELECTRIC
    return false
end


local function applyEngineSound(audio)
    local vehicle = currentTargetVehicle or GetVehiclePedIsIn(PlayerPedId(), false)
    if not vehicle or vehicle == 0 then
        lib.notify({ title = 'Engine Sound', position = 'center-right', description = 'Kenderaan Tidak Ditemukan!', type = 'error' })
        return
    end

    if isRestrictedVehicle(vehicle) then
        lib.notify({ title = 'Engine Sound', position = 'center-right', description = 'Kenderaan ini tidak boleh mengganti suara mesin.', type = 'error' })
        return
    end

    playMechAnim()

    lib.progressBar({
        duration = 3000,
        label = 'Mengganti Suara Kenderaan...',
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, move = true, combat = true },
    })

    ClearPedTasks(PlayerPedId())

    ForceVehicleEngineAudio(vehicle, audio)
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerServerEvent('MrJujuri:EngineSystem:server:applySound', netId, audio)

    currentTargetVehicle = nil -- reset setelah dipakai
end

local function resetEngineSound()
    local vehicle = currentTargetVehicle or GetVehiclePedIsIn(PlayerPedId(), false)
    if not vehicle or vehicle == 0 then
        lib.notify({ title = 'Engine Sound', position = 'center-right', description = 'Kenderaan Tidak Ditemukan!', type = 'error' })
        return
    end

    if isRestrictedVehicle(vehicle) then
        lib.notify({ title = 'Engine Sound', position = 'center-right', description = 'Kenderaan ini tidak boleh mengganti suara mesin.', type = 'error' })
        return
    end


    playMechAnim()

    lib.progressBar({
        duration = 2500,
        label = 'Mengembalikan Suara Kenderaan...',
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, move = true, combat = true },
    })

    ClearPedTasks(PlayerPedId())

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerServerEvent('MrJujuri:EngineSystem:server:resetSound', netId)

    lib.notify({ title = 'Engine Sound', position = 'center-right', description = 'Suara Kenderaan Kembali ke Default.', type = 'inform' })

    currentTargetVehicle = nil
end


local function openEngineCategoryMenu()
    lib.registerContext({
        id = 'engine_category_menu',
        title = 'Pilih Kategori Mesin',
        options = {
            {
                title = 'Mobil',
                icon = 'car-side',
                onSelect = function()
                    openEngineSoundMenu('car')
                end
            },
            {
                title = 'Motor',
                icon = 'motorcycle',
                onSelect = function()
                    openEngineSoundMenu('bike')
                end
            }
        }
    })
    lib.showContext('engine_category_menu')
end

function openEngineSoundMenu(category)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    -- Batasi kategori bike hanya untuk motor
    if category == 'bike' then
        local class = GetVehicleClass(vehicle)
        if class ~= 8 then
            lib.notify({
                title = 'Engine Sound',
                description = 'Kategori ini hanya untuk motor.',
                position = 'center-right',
                type = 'error'
            })
            return
        end
    end

    local soundCategories = getSoundCategories(category)
    local options = {}

    for soundCat in pairs(soundCategories) do
        options[#options + 1] = {
            title = soundCat,
            icon = 'folder',
            onSelect = function()
                openEngineCategoryList(category, soundCat)
            end
        }
    end

    options[#options + 1] = {
        title = '🔍 Mencari Semua Suara',
        icon = 'magnifying-glass',
        onSelect = function()
            searchAndShowSounds(category)
        end
    }

    options[#options + 1] = {
        title = '🔙 Kembali ke Jenis Kenderaan',
        icon = 'arrow-left',
        onSelect = function()
            lib.showContext('engine_category_menu')
        end
    }

    options[#options + 1] = {
        title = '❌ Tutup',
        icon = 'xmark',
        onSelect = function()
            lib.hideContext(true)
        end
    }

    lib.registerContext({
        id = 'engine_category_group_' .. category,
        title = 'Jenis Suara - ' .. category:upper(),
        options = options
    })

    lib.showContext('engine_category_group_' .. category)
end

function openEngineCategoryList(category, soundCategory)
    showSoundsFiltered(category, nil, soundCategory)
end


function searchAndShowSounds(category)
    local input = lib.inputDialog('Mencari Engine Sound', {
        { type = 'input', label = 'Sound Name', placeholder = 'Contoh: ferrari, gtr', required = false }
    })

    local keyword = input and input[1] and input[1]:lower()
    showSoundsFiltered(category, keyword)
end

function showSoundsFiltered(category, keyword, onlyCategory)
    local options = {}
    local steamHex = LocalPlayer.state.engineSteam
    local vehicle = currentTargetVehicle or GetVehiclePedIsIn(PlayerPedId(), false)
    local model = vehicle and GetEntityModel(vehicle)
    local modelName = model and GetDisplayNameFromVehicleModel(model):lower()

    for label, data in pairs(Config.EngineSounds[category]) do
        if onlyCategory and (data.category ~= onlyCategory) then goto continue end

        local allowedModel = false
        if data.vehicles == false then
            allowedModel = true
        elseif type(data.vehicles) == 'table' and modelName then
            for _, allowedName in pairs(data.vehicles) do
                if allowedName:lower() == modelName then
                    allowedModel = true
                    break
                end
            end
        end

        local whitelisted = (data.whitelist == false or (data.whitelist and data.whitelist[steamHex]))
        local matchKeyword = not keyword or label:lower():find(keyword)

        if allowedModel and whitelisted and matchKeyword then
            options[#options + 1] = {
                title = label,
                description = 'Mengantikan suara kenderaan ke: ' .. data.sound,
                icon = 'wrench',
                onSelect = function()
                    applyEngineSound(data.sound)
                end
            }
        elseif allowedModel and not whitelisted and matchKeyword then
            options[#options + 1] = {
                title = label,
                description = 'Anda tidak mempunyai permissions untuk menggunakan suara ini.',
                icon = 'ban',
                disabled = true
            }
        end

        ::continue::
    end

    options[#options + 1] = {
        title = '🔄 Ganti Ke Default',
        icon = 'rotate-left',
        onSelect = function()
            resetEngineSound()
        end
    }

    options[#options + 1] = {
        title = '🔙 Kembali ke Jenis Kenderaan',
        icon = 'arrow-left',
        onSelect = function()
            openEngineSoundMenu(category)
        end
    }

    options[#options + 1] = {
        title = '❌ Tutup Menu',
        icon = 'xmark',
        onSelect = function()
            lib.hideContext(true)
        end
    }

    lib.registerContext({
        id = 'engine_sound_menu_' .. (onlyCategory or 'all') .. '_' .. category,
        title = 'Sounds - ' .. (onlyCategory or 'All'),
        options = options
    })

    lib.showContext('engine_sound_menu_' .. (onlyCategory or 'all') .. '_' .. category)
end

RegisterNetEvent('MrJujuri:EngineSystem:client:openMenu', function(accessType, steamHex)
    print('[DEBUG] AccessType:', accessType, 'Steam:', steamHex)
    LocalPlayer.state.engineSteam = steamHex

    if (accessType == 'admin' or accessType == 'donator') then
        openEngineCategoryMenu()
    else
        lib.notify({
            title = 'Access Denied',
            description = 'Anda tidak mempunyai akses untuk fitur ini.',
            type = 'error'
        })
    end
end)


RegisterNetEvent('MrJujuri:EngineSystem:client:audioSet', function(audio)
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    if vehicle and vehicle > 0 then
        ForceVehicleEngineAudio(vehicle, audio)
        lib.notify({ title = 'Engine Sound', position = 'center-right', description = 'Suara Kenderaan diubah kepada ' .. audio, type = 'inform' })
    end
end)

RegisterNetEvent('MrJujuri:EngineSystem:client:noPermission', function()
    lib.notify({ title = 'Access Denied', position = 'center-right', description = 'Anda tidak mempunyai permissions untuk mengubah suara kenderaan.', type = 'error' })
end)

-- Command untuk membuka menu suara mesin
RegisterCommand('enginemenu', function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        lib.notify({
            title = 'Engine Sound',
            description = 'Kamu harus berada di dalam kendaraan.',
            position = 'center-right',
            type = 'error'
        })
        return
    end

    currentTargetVehicle = nil
    TriggerServerEvent('MrJujuri:EngineSystem:server:checkPermission')
end)


RegisterNetEvent('MrJujuri:EngineSystem:client:noPermission', function()
    lib.notify({ title = 'Access Denied', position = 'center-right', description = 'Anda tidak mempunyai kebenaran untuk menggunakan command ini.', type = 'error' })
end)

CreateThread(function()
    if GetResourceState('ox_target') ~= 'started' then return end

    exports.ox_target:addGlobalVehicle({
        {
            name = 'engine_sound_access',
            icon = 'fas fa-car',
            label = 'Ubah Suara Mesin',
            distance = 2.5,
            bones = {
                'bonnet', -- Kap mesin depan
                'engine',
            },
            onSelect = function(data)
                currentTargetVehicle = data.entity
                TriggerServerEvent('MrJujuri:EngineSystem:server:checkPermission')
            end,
            canInteract = function(entity, distance, coords, bone)
                return true -- Boleh interact dari luar mobil
            end
        }
    })
end)


AddStateBagChangeHandler('tunerData', nil, function(bagName, key, value, _unused, replicated)
    Wait(250)

    local entNet = tonumber(bagName:gsub('entity:', ''), 10)
    local vehicle = NetworkGetEntityFromNetworkId(entNet)
    if not vehicle or vehicle == 0 then return end

    if value == nil then
        -- 🔁 Reset Ke Suara Asli
        ForceVehicleEngineAudio(vehicle, "stock_car")
        return
    end
    ForceVehicleEngineAudio(vehicle, value)
end)
