Config = {}

FolderName = "ReduceNPCBanterRepetitiveness"
Config.configFilePath = "reduce_NPC_banter_repetitiveness_config.json"

Config.defaultConfig = {
    FEATURES = {
        min_distance = 24,            -- Banter occurring within this distance in meters to your active character will be handled by the mod, otherwise it will repeat as in vanilla
        max_occurrences = -1,         -- -1 = banter can still repeat indefinitely, but will have different intervals from vanilla, 0 = disable repeating banter entirely. Any other number is the maximum number of times a banter can occur
        interval_options = {
            first_silence_step = 5,   -- How many seconds to postpone the first time a banter is repeated. This is desirable because we don't know the time between the first and second banter until the second banter occurs

            min_interval_bonus = 5,   -- Time in seconds to add to the interval between banter occurrences
            max_interval_bonus = 300, -- time in seconds (-1 = will increase indefinitely with a square root function)
            random_intervals = true,  -- true = randomize intervals, false = increase with a square root function. Ignored if max_interval_bonus is -1.
            distance_factor_scaling = {
                enabled = true,
                min_distance = 1,         -- Distance in meters where the maximum penalty is applied
                max_distance = 20,        -- Distance in meters beyond which the minimum penalty is applied
                min_penalty_factor = 2.0, -- Factor by which the interval is multiplied at or below minDistance (2.0 = double the interval)
                max_penalty_factor = 1.0, -- Factor by which the interval is multiplied at or beyond maxDistance (1.0 = no change to the interval)
            },
        },
        vendor_options = {          -- Options for vendors
            enabled = true,         -- true = enable, false = use the same interval options for vendors as for regular NPCs
            max_occurrences = -1,   -- -1 = unlimited
            min_interval_bonus = 0, -- Time in seconds
            max_interval_bonus = 0, -- time in seconds (-1 = unlimited, will increase with a square root function)
        },
        reset_conditions = {
            -- cleanup_on_events = { -- Events triggering cleanup of the banter queue/intervals
            --     ["LongRestStarted"] = true,
            --     ["TeleportToCamp"] = false,
            --     -- Add more events as needed (see https://github.com/LaughingLeader/BG3ModdingTools/blob/master/generated/Osi.Events.lua)
            -- },
            cleanup_on_timer = 1800, -- time in seconds to reset intervals (-1 = never cleanup based on time). Default is 30 minutes
            -- based_on_distance = {
            --     enabled = false,
            --     distance = -1, -- Distance threshold in meters to reset banter intervals (set to -1 to disable)
            -- },
        },
    },
    DEBUG = {
        level = 0, -- 0 = no debug, 1 = basic debug, 2 = verbose debug
    },
    GENERAL = {
        enabled = true, -- Toggle the mod on/off
    },
}



function Config.GetModPath(filePath)
    return FolderName .. '/' .. filePath
end

-- Load a JSON configuration file and return a table or nil
function Config.LoadConfig(filePath)
    local configFileContent = Ext.IO.LoadFile(Config.GetModPath(filePath))
    if configFileContent and configFileContent ~= "" then
        Utils.DebugPrint(1, "Loaded config file: " .. filePath)
        return Ext.Json.Parse(configFileContent)
    else
        Utils.DebugPrint(1, "File not found: " .. filePath)
        return nil
    end
end

-- Save a config table to a JSON file
function Config.SaveConfig(filePath, config)
    local configFileContent = Ext.Json.Stringify(config, { Beautify = true })
    Ext.IO.SaveFile(Config.GetModPath(filePath), configFileContent)
end

function Config.JSONFileExists(filePath)
    local fullPath = Config.GetModPath(filePath)
    local fileContent = Ext.IO.LoadFile(fullPath)
    return fileContent ~= nil and fileContent ~= ""
end

function Config.UpdateConfig(existingConfig, defaultConfig)
    local updated = false

    for key, newValue in pairs(defaultConfig) do
        local oldValue = existingConfig[key]

        if oldValue == nil then
            -- Add missing keys from the default config
            existingConfig[key] = newValue
            updated = true
            Utils.DebugPrint(1, "Added new config option:", key)
        elseif type(oldValue) ~= type(newValue) then
            -- If the type has changed...
            if type(newValue) == "table" then
                -- ...and the new type is a table, place the old value in the 'enabled' key
                existingConfig[key] = { enabled = oldValue }
                for subKey, subValue in pairs(newValue) do
                    if existingConfig[key][subKey] == nil then
                        existingConfig[key][subKey] = subValue
                    end
                end
                updated = true
                Utils.DebugPrint(1, "Updated config structure for:", key)
            else
                -- ...otherwise, just replace with the new value
                existingConfig[key] = newValue
                updated = true
                Utils.DebugPrint(1, "Updated config value for:", key)
            end
        elseif type(newValue) == "table" then
            -- Recursively update for nested tables
            if Config.UpdateConfig(oldValue, newValue) then
                updated = true
            end
        end
    end

    -- Remove deprecated keys
    for key, _ in pairs(existingConfig) do
        if defaultConfig[key] == nil then
            -- Remove keys that are not in the default config
            existingConfig[key] = nil
            updated = true
            Utils.DebugPrint(1, "Removed deprecated config option:", key)
        end
    end

    return updated
end

function Config.LoadJSONConfig()
    local jsonConfig = Config.LoadConfig(Config.configFilePath)
    if not jsonConfig then
        jsonConfig = Config.defaultConfig
        Config.SaveConfig(Config.configFilePath, jsonConfig)
        Utils.DebugPrint(1, "Default config file loaded.")
    else
        if Config.UpdateConfig(jsonConfig, Config.defaultConfig) then
            Config.SaveConfig(Config.configFilePath, jsonConfig)
            Utils.DebugPrint(1, "Config file updated with new options.")
        else
            Utils.DebugPrint(1, "Config file loaded.")
        end
    end

    return jsonConfig
end

JsonConfig = Config.LoadJSONConfig()

return Config
