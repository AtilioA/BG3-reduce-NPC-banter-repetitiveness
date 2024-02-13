AutomatedDialog = {}

AutomatedDialog.dialogs = {}
AutomatedDialog.handling_dialogs = {}
AutomatedDialog.should_handle = {}

function AutomatedDialog.ResetBanterIntervals()
  AutomatedDialog.dialogs = {}
  AutomatedDialog.handling_dialogs = {}
  AutomatedDialog.should_handle = {}
end

--- Placeholder for logic to request stopping a dialog instance.
---@param dialog string
---@param instanceID integer
function AutomatedDialog.RequestStopDialog(dialog, instanceID)
  Osi.DialogRequestStopForDialog(dialog, Osi.DialogGetInvolvedNPC(instanceID, 1))
end

function AutomatedDialog.InitializeDialog(dialog, instanceID, currentTime)
  -- Initialize tracking for a new dialog with its first occurrence.
  Utils.DebugPrint(1, "Registering dialog " .. dialog .. " for the first time.")
  -- TODO: add config option for default silencePeriod (to be used while we couldn't have calculated it yet)
  AutomatedDialog.dialogs[dialog] = {
    instances = { instanceID },
    lastAllowed = currentTime,
    duration = -1,      -- To be determined at the end of the first occurrence.
    silencePeriod = -1, -- To be determined after the second occurrence.
  }
end

function AutomatedDialog.HandleDialogSecondOccurrence(dialog, instanceID, currentTime)
  -- After the first occurrence ends, calculate the silence period during the second occurrence.
  AutomatedDialog.dialogs[dialog].silencePeriod = Interval.ElapsedTime(AutomatedDialog.dialogs[dialog].lastAllowed +
    AutomatedDialog.dialogs[dialog].duration)
  AutomatedDialog.dialogs[dialog].lastAllowed = currentTime
  Utils.DebugPrint(0,
    "Silence period for " .. dialog .. " is " .. AutomatedDialog.dialogs[dialog].silencePeriod .. " milliseconds.")

  -- local shouldPostponeSecondOccurrence = JsonConfig.FEATURES.interval_options.first_silence_step
  -- if shouldPostponeSecondOccurrence > 0 then
  --   Utils.DebugPrint(2, "Postponing dialog " .. dialog .. " for " .. shouldPostponeSecondOccurrence .. " seconds.")
  --   AutomatedDialog.RequestStopDialog(dialog, instanceID)
  -- else
  -- Don't add if postponed so that it still falls into this condition
  table.insert(AutomatedDialog.dialogs[dialog].instances, instanceID)
  -- end
end

function AutomatedDialog.BlockOrAllowDialog(dialog, instanceID, involvedNPCsDistance, currentTime)
  if #AutomatedDialog.dialogs[dialog].instances == 1 then
    AutomatedDialog.HandleDialogSecondOccurrence(dialog, instanceID, currentTime)
  else
    -- For the third and subsequent occurrences, use the established silence period to decide.
    local elapsed = Interval.ElapsedTime(AutomatedDialog.dialogs[dialog].lastAllowed)
    -- Get wait time for this dialog based on the number of instances so far, using a piecewise function, and the distance
    local distanceToDialog = involvedNPCsDistance[1].Distance
    local waitTime = Interval.GetWaitTime(dialog, distanceToDialog)
    if AutomatedDialog.dialogs[dialog].silencePeriod == -1 or elapsed >= waitTime then
      -- Enough time has elapsed, update lastAllowed timestamp and allow this dialog.
      AutomatedDialog.dialogs[dialog].lastAllowed = currentTime
      table.insert(AutomatedDialog.dialogs[dialog].instances, instanceID)
      Utils.DebugPrint(1, "Dialog " .. dialog .. " allowed after " .. elapsed .. " milliseconds.")
    else
      -- Not enough time has elapsed, request to stop this dialog instance.
      Utils.DebugPrint(2, "Postponing dialog " .. dialog .. " for " .. waitTime .. " seconds.")
      AutomatedDialog.RequestStopDialog(dialog, instanceID)
    end
  end
end

--- Function to register or update automated dialog occurrence, and decide whether to allow it to proceed.
---@param dialog string @The dialog identifier.
---@param instanceID integer @The instance ID of the dialog.
function AutomatedDialog.HandleAutomatedDialog(dialog, instanceID)
  local currentTime = Interval.GetCurrentTime()
  local minNPCDistance = JsonConfig.FEATURES.min_distance

  if Osi.DialogGetNumberOfInvolvedPlayers(instanceID) > 0 then
    Utils.DebugPrint(2, "Ignoring dialog " .. dialog .. " involving players.")
    return
  end

  local involvedNPCs = AutomatedDialog.GetInvolvedNPCs(instanceID)

  if AutomatedDialog.CheckIfPartyInvolved(involvedNPCs) then
    Utils.DebugPrint(1, "Ignoring dialog " .. dialog .. " involving party members.")
    return
  end

  -- Check if the nearest NPC is too far away
  local involvedNPCsDistance = GetInvolvedNPCsByDistance(involvedNPCs)
  if involvedNPCsDistance and involvedNPCsDistance[1] and involvedNPCsDistance[1].Distance then
    if involvedNPCsDistance[1].Distance > minNPCDistance then
      Utils.DebugPrint(1, "Ignoring dialog " .. dialog .. " involving NPCs too far away.")
      return
    end
  else
    Utils.DebugPrint(1, "Ignoring dialog " .. dialog .. ". No distance information available.")
    return
  end

  if AutomatedDialog.dialogs[dialog] == nil then
    AutomatedDialog.InitializeDialog(dialog, instanceID, currentTime)
  else
    AutomatedDialog.BlockOrAllowDialog(dialog, instanceID, involvedNPCsDistance, currentTime)
  end
end

-- Returns a table with all the NPCs involved in an automated dialog instance
function AutomatedDialog.GetInvolvedNPCs(instanceID)
  local involvedNPCs = {}

  local nInvolvedNPCs = Osi.DialogGetNumberOfInvolvedNPCs(instanceID)
  for i = 1, nInvolvedNPCs do
    local npcHandle = Osi.DialogGetInvolvedNPC(instanceID, i)
    if npcHandle ~= nil and Osi.IsCharacter(npcHandle) == 1 then
      table.insert(involvedNPCs, npcHandle)
    end
  end

  return involvedNPCs
end

function AutomatedDialog.CheckIfPartyInvolved(involvedNPCs)
  for _, npc in ipairs(involvedNPCs) do
    if Osi.IsInPartyWith(npc, Osi.GetHostCharacter()) == 1 then
      return true
    end
  end

  return false
end

return AutomatedDialog
