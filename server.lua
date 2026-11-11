local presets = {}
local playerOutfits = {}
local allowedComponents = {}
local allowedModels = {}

for _, item in ipairs(Config.Components) do
    allowedComponents[item.key] = true
end

for _, item in ipairs(Config.Models) do
    allowedModels[item.key] = true
end

local function readJsonFile(path)
    local raw = LoadResourceFile(GetCurrentResourceName(), path)
    if not raw or raw == '' then return {} end

    local ok, decoded = pcall(json.decode, raw)
    return ok and type(decoded) == 'table' and decoded or {}
end

local function persist(path, data)
    SaveResourceFile(GetCurrentResourceName(), path, json.encode(data), -1)
end

local function canEdit(source)
    return IsPlayerAceAllowed(source, Config.AdminAce)
end

local function getPlayerLicense(source)
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if identifier:sub(1, 8) == 'license:' then
            return identifier
        end
    end
    return nil
end

local function sanitizeAppearance(appearance)
    if type(appearance) ~= 'table' then return nil end
    local clean = {}
    for key, value in pairs(appearance) do
        if allowedComponents[key] and type(value) == 'table' then
            local drawable = tonumber(value.value)
            local texture = tonumber(value.texture)
            if drawable and texture then
                clean[key] = {
                    value = math.floor(math.max(-1, math.min(drawable, 2000))),
                    texture = math.floor(math.max(0, math.min(texture, 2000)))
                }
            end
        end
    end
    return clean
end

local function sanitizeModel(model)
    return allowedModels[model] and model or 'male'
end

local function normalizePreset(preset)
    if type(preset) ~= 'table' then return nil end
    if preset.appearance then
        return { model = sanitizeModel(preset.model), appearance = sanitizeAppearance(preset.appearance) }
    end
    return { model = 'male', appearance = sanitizeAppearance(preset) }
end

RegisterNetEvent('clothes_editor:requestOpen', function()
    local player = source
    if not canEdit(player) then
        TriggerClientEvent('clothes_editor:accessDenied', player)
        return
    end
    TriggerClientEvent('clothes_editor:open', player, presets)
end)

RegisterNetEvent('clothes_editor:save', function(name, model, appearance)
    local player = source
    if not canEdit(player) then return end

    name = type(name) == 'string' and name:sub(1, 32):gsub('[^%w_%-%s]', ''):gsub('^%s+', ''):gsub('%s+$', '') or ''
    local clean = sanitizeAppearance(appearance)
    if name == '' or not clean then return end

    local count = 0
    for _ in pairs(presets) do count = count + 1 end
    if not presets[name] and count >= Config.MaxPresets then
        TriggerClientEvent('clothes_editor:presets', player, presets)
        TriggerClientEvent('chat:addMessage', player, { args = { '^1Clothes editor', 'The preset limit has been reached.' } })
        return
    end

    presets[name] = { model = sanitizeModel(model), appearance = clean }
    persist(Config.SaveFile, presets)
    TriggerClientEvent('clothes_editor:presets', player, presets)
end)

RegisterNetEvent('clothes_editor:delete', function(name)
    local player = source
    if not canEdit(player) or type(name) ~= 'string' then return end
    presets[name] = nil
    persist(Config.SaveFile, presets)
    TriggerClientEvent('clothes_editor:presets', player, presets)
end)

RegisterNetEvent('clothes_editor:applyPreset', function(name)
    local player = source
    if not canEdit(player) or type(name) ~= 'string' or not presets[name] then return end
    local preset = normalizePreset(presets[name])
    if preset and preset.appearance then
        TriggerClientEvent('clothes_editor:apply', player, preset)
    end
end)

RegisterNetEvent('clothes_editor:savePlayerOutfit', function(model, appearance)
    local player = source
    if not canEdit(player) then return end

    local license = getPlayerLicense(player)
    local clean = sanitizeAppearance(appearance)
    if not license or not clean then return end

    playerOutfits[license] = { model = sanitizeModel(model), appearance = clean }
    persist(Config.PlayerSaveFile, playerOutfits)
    TriggerClientEvent('chat:addMessage', player, { args = { '^2Clothes editor', 'Your outfit has been saved for your character.' } })
end)

RegisterNetEvent('clothes_editor:requestPlayerOutfit', function()
    local player = source
    if not Config.AutoApplyPlayerOutfit then return end

    local license = getPlayerLicense(player)
    local outfit = license and playerOutfits[license] or nil
    local normalized = outfit and normalizePreset(outfit) or nil
    if normalized and normalized.appearance then
        TriggerClientEvent('clothes_editor:applyPlayerOutfit', player, normalized)
    end
end)

presets = readJsonFile(Config.SaveFile)
playerOutfits = readJsonFile(Config.PlayerSaveFile)
