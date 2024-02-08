EHandlers = {}

function EHandlers.OnAutomatedDialogStarted(dialog, instanceID)
  Utils.DebugPrint(2, "AutomatedDialogStarted: " .. dialog .. " " .. instanceID)
  AutomatedDialog.HandleAutomatedDialog(dialog, instanceID)
end

function EHandlers.OnAutomatedDialogEnded(dialog, instanceID)
  Utils.DebugPrint(2, "AutomatedDialogEnded: " .. dialog .. " " .. instanceID)
  -- Calculate duration based on last played time
  if AutomatedDialog.dialogs[dialog] == nil then
    return
  end
  AutomatedDialog.dialogs[dialog].duration = Interval.ElapsedTime(AutomatedDialog.dialogs[dialog].lastAllowed)
end

return EHandlers
