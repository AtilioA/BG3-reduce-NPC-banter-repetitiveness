RNPCBRPrinter = VolitionCabinetPrinter:New { Prefix = "Reduce NPC Banter Repetitiveness", ApplyColor = true, DebugLevel = MCMGet("debug_level") }

-- Update the Printer debug level when the setting is changed, since the value is only used during the object's creation
Ext.RegisterNetListener("MCM_Saved_Setting", function(call, payload)
    local data = Ext.Json.Parse(payload)
    if not data or data.modGUID ~= ModuleUUID or not data.settingId then
        return
    end

    if data.settingId == "debug_level" then
        RNPCBRDebug(0, "Setting debug level to " .. data.value)
        RNPCBRPrinter.DebugLevel = data.value
    end
end)

function RNPCBRPrint(debugLevel, ...)
    RNPCBRPrinter:SetFontColor(0, 255, 255)
    RNPCBRPrinter:Print(debugLevel, ...)
end

function RNPCBRTest(debugLevel, ...)
    RNPCBRPrinter:SetFontColor(100, 200, 150)
    RNPCBRPrinter:PrintTest(debugLevel, ...)
end

function RNPCBRDebug(debugLevel, ...)
    RNPCBRPrinter:SetFontColor(200, 200, 0)
    RNPCBRPrinter:PrintDebug(debugLevel, ...)
end

function RNPCBRWarn(debugLevel, ...)
    RNPCBRPrinter:SetFontColor(255, 100, 50)
    RNPCBRPrinter:PrintWarning(debugLevel, ...)
end

function RNPCBRDump(debugLevel, ...)
    RNPCBRPrinter:SetFontColor(190, 150, 225)
    RNPCBRPrinter:Dump(debugLevel, ...)
end

function RNPCBRDumpArray(debugLevel, ...)
    RNPCBRPrinter:DumpArray(debugLevel, ...)
end
