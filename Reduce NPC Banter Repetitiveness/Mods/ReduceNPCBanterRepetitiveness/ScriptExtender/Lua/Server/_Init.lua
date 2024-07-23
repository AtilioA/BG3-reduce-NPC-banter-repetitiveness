setmetatable(Mods.ReduceNPCBanterRepetitiveness, { __index = Mods.VolitionCabinet })

local deps = {
    VCModuleUUID = "f97b43be-7398-4ea5-8fe2-be7eb3d4b5ca",
    MCMModuleUUID = "755a8a72-407f-4f0d-9a33-274ac0f0b53d"
}

local function getModName(uuid)
    if not uuid then return "Unknown Mod" end

    local mod = Ext.Mod.GetMod(uuid)
    return mod and mod.Info and mod.Info.Name or "Unknown Mod"
end

local currentModName = getModName(ModuleUUID)

for _, uuid in pairs({ deps.VCModuleUUID, deps.MCMModuleUUID }) do
    if not Ext.Mod.IsModLoaded(uuid) then
        Ext.Utils.PrintError(
            string.format("%s requires %s, which is missing. PLEASE MAKE SURE IT IS ENABLED IN YOUR MOD MANAGER.",
                currentModName, getModName(uuid)))
    end
end

---Ext.Require files at the path
---@param path string
---@param files string[]
function RequireFiles(path, files)
    for _, file in pairs(files) do
        Ext.Require(string.format("%s%s.lua", path, file))
    end
end

function MCMGet(settingID)
    return Mods.BG3MCM.MCMAPI:GetSettingValue(settingID, ModuleUUID)
end

function MCMSet(settingID, value)
    return Mods.BG3MCM.MCMAPI:SetSettingValue(settingID, value, ModuleUUID)
end

RequireFiles("Server/", {
    "Helpers/_Init",
    "AutomatedDialog",
    "EventHandlers",
    "SubscribedEvents",
})

local MODVERSION = Ext.Mod.GetMod(ModuleUUID).Info.ModVersion

if MODVERSION == nil then
    RNPCBRPrint(0, "loaded (version unknown)")
else
    table.remove(MODVERSION)

    local versionNumber = table.concat(MODVERSION, ".")
    RNPCBRPrint(0, "version " .. versionNumber .. " loaded")
end

SubscribedEvents.SubscribeToEvents()
