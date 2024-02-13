local function SubscribeToEvents()
  if JsonConfig.GENERAL.enabled == true then
    Utils.DebugPrint(2, "Subscribing to events with JSON config: " .. Ext.Json.Stringify(JsonConfig, { Beautify = true }))

    Ext.Osiris.RegisterListener("UseStarted", 2, "after", EHandlers.OnUseStarted)

    Ext.Osiris.RegisterListener("UseFinished", 2, "after", EHandlers.OnUseFinished)

    Ext.Osiris.RegisterListener("AutomatedDialogStarted", 2, "before", EHandlers.OnAutomatedDialogStarted)

    Ext.Osiris.RegisterListener("AutomatedDialogEnded", 2, "after", EHandlers.OnAutomatedDialogEnded)

    Ext.Osiris.RegisterListener("AutomatedDialogForceStopping", 2, "after", EHandlers.OnAutomatedDialogForceStopping)

    Ext.Osiris.RegisterListener("InstanceDialogChanged", 4, "after",
      function(oldDialog, oldDialogStopping, instanceID, newDialog)
        Utils.DebugPrint(2,
          "InstanceDialogChanged: " .. oldDialog .. " " .. oldDialogStopping .. " " .. instanceID .. " " .. newDialog)
      end)

    Ext.Osiris.RegisterListener("TimerFinished", 1, "after", EHandlers.OnTimerFinished)

    Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after")
  end
end

return {
  SubscribeToEvents = SubscribeToEvents
}
