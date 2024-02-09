local function SubscribeToEvents()
  if JsonConfig.GENERAL.enabled == true then
    Utils.DebugPrint(2, "Subscribing to events with JSON config: " .. Ext.Json.Stringify(JsonConfig, { Beautify = true }))

    Ext.Osiris.RegisterListener("AutomatedDialogStarted", 2, "before", EHandlers.OnAutomatedDialogStarted)

    Ext.Osiris.RegisterListener("AutomatedDialogEnded", 2, "after", EHandlers.OnAutomatedDialogEnded)

    Ext.Osiris.RegisterListener("AutomatedDialogForceStopping", 2, "after", function(dialog, instanceID)
      Utils.DebugPrint(3, "AutomatedDialogForceStopping: " .. dialog .. " " .. instanceID)
    end)

    Ext.Osiris.RegisterListener("InstanceDialogChanged", 4, "after",
      function(oldDialog, oldDialogStopping, instanceID, newDialog)
        Utils.DebugPrint(2,
          "InstanceDialogChanged: " .. oldDialog .. " " .. oldDialogStopping .. " " .. instanceID .. " " .. newDialog)
      end)

    Ext.Osiris.RegisterListener("NestedDialogPlayed", 2, "after", function(dialog, instanceID)
      Utils.DebugPrint(2, "NestedDialogPlayed: " .. dialog .. " " .. instanceID)
    end)

    Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(timer)
      -- if timer begins with "PostponeDialog" then...
      if string.find(timer, "PostponeDialog") == 1 then
        Utils.DebugPrint(2, "TimerFinished: " .. timer)
        local dialog = string.sub(timer, 15)
        if EHandlers.dialogs[dialog] and EHandlers.dialogs[dialog].instances and #EHandlers.dialogs[dialog].instances > 0 then
          EHandlers.handling_dialogs[dialog] = false
          EHandlers.should_handle[dialog] = false
        end
      end
    end)
  end
end

return {
  SubscribeToEvents = SubscribeToEvents
}
