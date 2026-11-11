local function getModelKey(ped)
    local model = GetEntityModel(ped)
    if model == joaat('mp_f_freemode_01') then return 'female' end
    return 'male'
end

local function getCurrentAppearance(ped)
    local appearance = {}
    for _, item in ipairs(Config.Components) do
        local value
        local texture
        if item.type == 'prop' then
            value = GetPedPropIndex(ped, item.id)
            texture = value >= 0 and GetPedPropTextureIndex(ped, item.id) or 0
        else
            value = GetPedDrawableVariation(ped, item.id)
            texture = GetPedTextureVariation(ped, item.id)
        end
        appearance[item.key] = { value = value, texture = texture }
    end
    return appearance
end

local function loadModel(modelName)
    local model = joaat(modelName)
    if not IsModelInCdimage(model) or not IsModelValid(model) then return false end
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(0)
    end
    if not HasModelLoaded(model) then return false end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    return true
end

local function applyAppearance(ped, appearance)
    for _, item in ipairs(Config.Components) do
        local entry = appearance[item.key]
        if entry then
            local value = math.floor(tonumber(entry.value) or 0)
            local texture = math.max(0, math.floor(tonumber(entry.texture) or 0))
            if item.type == 'prop' then
                if value < 0 then
                    ClearPedProp(ped, item.id)
                else
                    SetPedPropIndex(ped, item.id, value, texture, true)
                end
            else
                SetPedComponentVariation(ped, item.id, math.max(0, value), texture, 0)
            end
        end
    end
end

local function applyOutfit(modelKey, appearance)
    local modelName = modelKey == 'female' and 'mp_f_freemode_01' or 'mp_m_freemode_01'
    if loadModel(modelName) then
        applyAppearance(PlayerPedId(), appearance or {})
    end
end

local function sendEditor()
    local ped = PlayerPedId()
    SendNUIMessage({
        action = 'open',
        model = getModelKey(ped),
        models = Config.Models,
        appearance = getCurrentAppearance(ped),
        components = Config.Components
    })
    SetNuiFocus(true, true)
end

RegisterCommand(Config.Command, function()
    TriggerServerEvent('clothes_editor:requestOpen')
end, false)

RegisterNetEvent('clothes_editor:open', function(presets)
    sendEditor()
    SendNUIMessage({ action = 'presets', presets = presets or {} })
end)

RegisterNetEvent('clothes_editor:applyPlayerOutfit', function(outfit)
    if outfit and outfit.appearance then
        applyOutfit(outfit.model, outfit.appearance)
    end
end)

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(500)
    end
    Wait(3000)
    TriggerServerEvent('clothes_editor:requestPlayerOutfit')
end)

RegisterNetEvent('clothes_editor:accessDenied', function()
    TriggerEvent('chat:addMessage', { args = { '^1Clothes editor', 'You do not have permission to use this editor.' } })
end)

RegisterNUICallback('preview', function(data, cb)
    if data.model then applyOutfit(data.model, data.appearance or {}) else applyAppearance(PlayerPedId(), data.appearance or {}) end
    cb({ ok = true })
end)

RegisterNUICallback('save', function(data, cb)
    TriggerServerEvent('clothes_editor:save', tostring(data.name or ''), tostring(data.model or 'male'), data.appearance or {})
    cb({ ok = true })
end)

RegisterNUICallback('savePlayerOutfit', function(data, cb)
    TriggerServerEvent('clothes_editor:savePlayerOutfit', tostring(data.model or 'male'), data.appearance or {})
    cb({ ok = true })
end)

RegisterNUICallback('delete', function(data, cb)
    TriggerServerEvent('clothes_editor:delete', tostring(data.name or ''))
    cb({ ok = true })
end)

RegisterNUICallback('load', function(data, cb)
    TriggerServerEvent('clothes_editor:applyPreset', tostring(data.name or ''))
    cb({ ok = true })
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

RegisterNetEvent('clothes_editor:presets', function(presets)
    SendNUIMessage({ action = 'presets', presets = presets or {} })
end)

RegisterNetEvent('clothes_editor:apply', function(outfit)
    if outfit.appearance then
        applyOutfit(outfit.model, outfit.appearance)
    else
        applyAppearance(PlayerPedId(), outfit)
    end
end)

CreateThread(function()
    while true do
        Wait(250)
        if IsControlJustPressed(0, 322) then
            SetNuiFocus(false, false)
            SendNUIMessage({ action = 'close' })
        end
    end
end)
