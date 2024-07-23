SubscribedEvents = {}

function SubscribedEvents:SubscribeToEvents()
  local function conditionalWrapper(handler)
    return function(...)
      if MCMGet("mod_enabled") then
        handler(...)
      else
        RNPCBRPrint(1, "Event handling is disabled.")
      end
    end
  end

  RNPCBRDebug(2, "Subscribing to events with JSON config: " ..
    Ext.Json.Stringify(Mods.BG3MCM.MCMAPI:GetAllModSettings(ModuleUUID)))

  Ext.Osiris.RegisterListener("AutomatedDialogStarted", 2, "before",
    conditionalWrapper(EHandlers.OnAutomatedDialogStarted))

  -- Ext.Osiris.RegisterListener("AutomatedDialogEnded", 2, "after", conditionalWrapper(EHandlers.OnAutomatedDialogEnded))

  Ext.Osiris.RegisterListener("AutomatedDialogForceStopping", 2, "after",
    conditionalWrapper(EHandlers.OnAutomatedDialogForceStopping))

  Ext.Osiris.RegisterListener("InstanceDialogChanged", 4, "after",
    conditionalWrapper(function(oldDialog, oldDialogStopping, instanceID, newDialog)
      RNPCBRPrint(2,
        "InstanceDialogChanged: " .. oldDialog .. " " .. oldDialogStopping .. " " .. instanceID .. " " .. newDialog)
    end))

  Ext.Osiris.RegisterListener("TimerFinished", 1, "after", conditionalWrapper(EHandlers.OnTimerFinished))

  Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", conditionalWrapper(EHandlers.OnLevelGameplayStarted))

  Ext.RegisterNetListener("MCM_Saved_Setting", EHandlers.HandleMCMSettingChange)
end

return SubscribedEvents
