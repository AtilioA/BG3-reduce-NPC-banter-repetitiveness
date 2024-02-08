AutomatedDialog = {}

AutomatedDialog.dialogs = {}
AutomatedDialog.handling_dialogs = {}
AutomatedDialog.should_handle = {}

--- Placeholder for logic to request stopping a dialog instance.
---@param dialog string
---@param instanceID integer
function AutomatedDialog.RequestStopDialog(dialog, instanceID)
  Osi.DialogRequestStopForDialog(dialog, Osi.DialogGetInvolvedNPC(instanceID, 1))
end

--- Function to register or update automated dialog occurrence, and decide whether to allow it to proceed.
---@param dialog string @The dialog identifier.
---@param instanceID integer @The instance ID of the dialog.
function HandleAutomatedDialog(dialog, instanceID)
  local currentTime = Interval.GetCurrentTime()

  if Osi.DialogGetNumberOfInvolvedPlayers(instanceID) > 0 then
    Utils.DebugPrint(2, "Ignoring dialog " .. dialog .. " involving players.")
    return
  end

  -- TODO: use distance to calculate wait time
  -- TODO: do not register occurrences if the dialog is too far away
  local involvedNPCs = AutomatedDialog.GetInvolvedNPCsByDistance(instanceID)

  if AutomatedDialog.dialogs[dialog] == nil then
    -- Initialize tracking for a new dialog with its first occurrence.
    Utils.DebugPrint(0, "Registering dialog " .. dialog .. " for the first time.")
    -- TODO: add config option for default silencePeriod (to be used while we couldn't have calculated it yet)
    AutomatedDialog.dialogs[dialog] = {
      instances = { instanceID },
      lastAllowed = currentTime,
      duration = -1,      -- To be determined at the end of the first occurrence.
      silencePeriod = -1, -- To be determined after the second occurrence.
    }
  else
    if #AutomatedDialog.dialogs[dialog].instances == 1 then
      -- After the first occurrence ends, calculate the silence period during the second occurrence.
      AutomatedDialog.dialogs[dialog].silencePeriod = Interval.ElapsedTime(AutomatedDialog.dialogs[dialog].lastAllowed +
        AutomatedDialog.dialogs[dialog].duration)
      Utils.DebugPrint(0,
        "Silence period for " .. dialog .. " is " .. AutomatedDialog.dialogs[dialog].silencePeriod .. " milliseconds.")
      table.insert(AutomatedDialog.dialogs[dialog].instances, instanceID)
      AutomatedDialog.dialogs[dialog].lastAllowed = currentTime
    else
      -- For the third and subsequent occurrences, use the established silence period to decide.
      local elapsed = Interval.ElapsedTime(AutomatedDialog.dialogs[dialog].lastAllowed)
      -- Get wait time for this dialog based on the number of instances so far, using a piecewise function.
      if AutomatedDialog.dialogs[dialog].silencePeriod == -1 or elapsed >= Interval.GetWaitTime(dialog) then
        -- Enough time has elapsed, update lastAllowed timestamp and allow this dialog.
        AutomatedDialog.dialogs[dialog].lastAllowed = currentTime
        table.insert(AutomatedDialog.dialogs[dialog].instances, instanceID)
        Utils.DebugPrint(0, "Dialog " .. dialog .. " allowed after " .. elapsed .. " milliseconds.")
      else
        -- Not enough time has elapsed, request to stop this dialog instance.
        Utils.DebugPrint(2, "Postponing dialog " .. dialog .. " for 15000 milliseconds.")
        AutomatedDialog.RequestStopDialog(dialog, instanceID)
      end
    end
  end
end

-- Returns a table with all the NPCs involved in an automated dialog instance
function AutomatedDialog.GetInvolvedNPCs(instanceID)
  local involvedNPCs = {}

  local nInvolvedNPCs = Osi.DialogGetNumberOfInvolvedNPCs(instanceID)
  for i = 1, nInvolvedNPCs do
    local npcHandle = Osi.DialogGetInvolvedNPC(instanceID, i)
    if npcHandle ~= nil then
      table.insert(involvedNPCs, npcHandle)
    end
  end

  return involvedNPCs
end

--- Returns a sorted table of involved NPCs by distance from the host character, including detailed info.
---@param involvedNPCs EntityHandle[] @List of NPC handles.
---@return table A table with details of involved NPCs: Entity, Guid, Distance, and Name, sorted by Distance.
function AutomatedDialog.GetInvolvedNPCsByDistance(instanceID)
  local hostCharacter = Osi.GetHostCharacter() -- Assuming this retrieves the player or designated character
  local NPCsInfo = {}
  local involvedNPCs = AutomatedDialog.GetInvolvedNPCs(instanceID)

  for _, npcHandle in ipairs(involvedNPCs) do
    local npcEntity = Ext.Entity.Get(npcHandle)
    if npcEntity ~= nil then
      local distance = Osi.GetDistanceTo(npcHandle, hostCharacter)
      -- Collect detailed information for each NPC
      table.insert(NPCsInfo, {
        Entity = npcEntity,
        Guid = npcEntity.Uuid.EntityUuid,
        Distance = distance,
        Name = Ext.Loca.GetTranslatedString(npcEntity.DisplayName.NameKey.Handle.Handle)
      })
    end
  end

  -- Sort the NPCs by distance in descending order
  table.sort(NPCsInfo, function(a, b) return a.Distance > b.Distance end)

  return NPCsInfo
end

function AutomatedDialog.CheckIfPartyInvolved(character) end

return AutomatedDialog
