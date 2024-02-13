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

function EHandlers.OnTimerFinished(timer)
  -- if timer begins with "PostponeDialog" then...
  if string.find(timer, "PostponeDialog") == 1 then
    Utils.DebugPrint(2, "TimerFinished: " .. timer)
    local dialog = string.sub(timer, 15)
    if EHandlers.dialogs[dialog] and EHandlers.dialogs[dialog].instances and #EHandlers.dialogs[dialog].instances > 0 then
      EHandlers.handling_dialogs[dialog] = false
      EHandlers.should_handle[dialog] = false
    end
  elseif timer == "ResetBanterIntervals" then
    Utils.DebugPrint(2, "TimerFinished: " .. timer)
    AutomatedDialog.ResetBanterIntervals()
  end
end

function EHandlers.OnLevelGameplayStarted(isEditorMode, levelName)
  if JsonConfig.FEATURES.reset_conditions.cleanup_on_timer > 0 then
    Osi.TimerLaunch("ResetBanterIntervals", JsonConfig.FEATURES.reset_conditions.cleanup_on_timer * 1000)
  end
end

function EHandlers.OnAutomatedDialogForceStopping(dialog, instanceID)
  Utils.DebugPrint(3, "AutomatedDialogForceStopping: " .. dialog .. " " .. instanceID)
end

return EHandlers
