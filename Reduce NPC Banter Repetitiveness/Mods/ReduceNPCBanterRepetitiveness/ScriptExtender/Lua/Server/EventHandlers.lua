EHandlers = {}

function EHandlers.OnAutomatedDialogStarted(dialog, instanceID)
  RNPCBRPrint(2, "AutomatedDialogStarted: " .. dialog .. " " .. instanceID)
  AutomatedDialog.HandleAutomatedDialog(dialog, instanceID)
end

function EHandlers.OnAutomatedDialogEnded(dialog, instanceID)
  RNPCBRPrint(2, "AutomatedDialogEnded: " .. dialog .. " " .. instanceID)
  -- Calculate duration based on last played time
  if AutomatedDialog.dialogs[dialog] == nil then
    return
  end
  AutomatedDialog.dialogs[dialog].duration = Interval.ElapsedTime(AutomatedDialog.dialogs[dialog].lastAllowed)
end

function EHandlers.OnTimerFinished(timer)
  -- if timer begins with "PostponeDialog" then...
  if string.find(timer, "PostponeDialog") == 1 then
    RNPCBRPrint(2, "TimerFinished: " .. timer)
    local dialog = string.sub(timer, 15)
    if EHandlers.dialogs[dialog] and EHandlers.dialogs[dialog].instances and #EHandlers.dialogs[dialog].instances > 0 then
      EHandlers.handling_dialogs[dialog] = false
      EHandlers.should_handle[dialog] = false
    end
  elseif timer == "ResetBanterIntervals" then
    RNPCBRPrint(2, "TimerFinished: " .. timer)
    AutomatedDialog.ResetBanterIntervals()
  end
end

function EHandlers.OnLevelGameplayStarted(isEditorMode, levelName)
  if JsonConfig.FEATURES.reset_conditions.cleanup_on_timer > 0 then
    Osi.TimerLaunch("ResetBanterIntervals", JsonConfig.FEATURES.reset_conditions.cleanup_on_timer * 1000)
  end
end

function EHandlers.OnAutomatedDialogForceStopping(dialog, instanceID)
  RNPCBRPrint(3, "AutomatedDialogForceStopping: " .. dialog .. " " .. instanceID)
end

function EHandlers.HandleMCMSettingChange(call, payload)
  -- Make sure the ranges are consistent
  local function adjustDistanceSettings(changedSetting)
    local minDistanceForFactor = MCMGet("distance_factor_scaling_min_distance")
    local maxDistanceForFactor = MCMGet("distance_factor_scaling_max_distance")

    if changedSetting == "min_distance" and minDistanceForFactor > maxDistanceForFactor then
      MCMSet("max_distance", minDistanceForFactor)
    elseif changedSetting == "max_distance" and maxDistanceForFactor < minDistanceForFactor then
      MCMSet("min_distance", maxDistanceForFactor)
    end
  end

  -- Make sure the ranges are consistent
  local function adjustIntervalSettings(changedSetting)
    local minInterval = MCMGet("min_interval_bonus")
    local maxInterval = MCMGet("max_interval_bonus")

    if changedSetting == "min_interval_bonus" and minInterval > maxInterval then
      MCMSet("max_interval_bonus", minInterval)
    elseif changedSetting == "max_interval_bonus" and maxInterval < minInterval then
      MCMSet("min_interval_bonus", maxInterval)
    end
  end

  local data = Ext.Json.Parse(payload)
  if not data or data.modGUID ~= ModuleUUID or not data.settingId then
    return
  end

  if data.settingId == "debug_level" then
    RNPCBRDebug(0, "Setting debug level to " .. data.value)
    RNPCBRPrinter.DebugLevel = data.value
  elseif data.settingId == "min_distance" or data.settingId == "max_distance" then
    adjustDistanceSettings(data.settingId)
  elseif data.settingId == "min_interval_bonus" or data.settingId == "max_interval_bonus" then
    adjustIntervalSettings(data.settingId)
  end
end

return EHandlers
