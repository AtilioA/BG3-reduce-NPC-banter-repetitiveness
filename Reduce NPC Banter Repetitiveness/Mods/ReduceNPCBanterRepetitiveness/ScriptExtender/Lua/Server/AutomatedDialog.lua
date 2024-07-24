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
    RNPCBRDebug(1, "Registering dialog " .. dialog .. " for the first time.")
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
    RNPCBRDebug(0,
        "Silence period for " .. dialog .. " is " .. AutomatedDialog.dialogs[dialog].silencePeriod .. " milliseconds.")

    -- local shouldPostponeSecondOccurrence = MCMGet("first_silence_step")
    -- if shouldPostponeSecondOccurrence > 0 then
    --     RNPCBRPrint(2, "Postponing dialog " .. dialog .. " for " .. shouldPostponeSecondOccurrence .. " seconds.")
    --     AutomatedDialog.RequestStopDialog(dialog, instanceID)
    -- else
    -- Don't add if postponed so that it still falls into this condition
    table.insert(AutomatedDialog.dialogs[dialog].instances, instanceID)
    -- end
end

function AutomatedDialog.BlockOrAllowDialog(dialog, instanceID, involvedNPCsDistance, currentTime)
    if #AutomatedDialog.dialogs[dialog].instances == 1 then
        AutomatedDialog.HandleDialogSecondOccurrence(dialog, instanceID, currentTime)
    else
        local elapsed = Interval.ElapsedTime(AutomatedDialog.dialogs[dialog].lastAllowed)
        local firstSilenceStep = MCMGet("first_silence_step")
        if AutomatedDialog.dialogs[dialog].silencePeriod == -1 and firstSilenceStep ~= -1 then
            elapsed = elapsed - firstSilenceStep
        else
            -- For the third and subsequent occurrences, use the established silence period to decide.
            elapsed = elapsed - AutomatedDialog.dialogs[dialog].silencePeriod
        end

        -- Get wait time for this dialog based on the number of instances so far, using a piecewise function/random interval, and the distance
        local distanceToDialog = involvedNPCsDistance[1].Distance
        local waitTime = Interval.GetWaitTime(dialog, distanceToDialog) * 1000
        -- REFACTOR: simplify/move this logic to a separate function
        if elapsed >= waitTime then
            -- Enough time has elapsed, update lastAllowed timestamp and allow this dialog.
            AutomatedDialog.dialogs[dialog].lastAllowed = currentTime
            table.insert(AutomatedDialog.dialogs[dialog].instances, instanceID)

            RNPCBRPrint(1,
                string.format("\x1b[%dm%s\x1b[0m", 33,
                    "Dialog " .. dialog .. " allowed after " .. elapsed .. " milliseconds."))
        else
            -- Not enough time has elapsed, request to stop this dialog instance.
            RNPCBRPrint(2,
                "Postponing dialog " .. dialog .. " for " .. math.floor((waitTime - elapsed) ) .. " more seconds.")
            AutomatedDialog.RequestStopDialog(dialog, instanceID)
        end
    end
end

function ShouldSkipDialogWithMaxOccurrences(dialog)
    -- local vendorOptionsEnabled = MCMGet("vendor_options_enabled")
    -- local involvesTrader = false -- AutomatedDialog.DialogInvolvesTrader(dialog)

    local maxOccurrences = MCMGet("max_occurrences")
    -- if vendorOptionsEnabled and involvesTrader then
    --     maxOccurrences = MCMGet("vendor_options_max_occurrences")
    -- end

    if maxOccurrences == -1 then
        return false
    elseif AutomatedDialog.dialogs and AutomatedDialog.dialogs[dialog] and AutomatedDialog.dialogs[dialog].instances and #AutomatedDialog.dialogs[dialog].instances > maxOccurrences then
        return true
    end
end

--- Function to register or update automated dialog occurrence, and decide whether to allow it to proceed.
---@param dialog string @The dialog identifier.
---@param instanceID integer @The instance ID of the dialog.
function AutomatedDialog.HandleAutomatedDialog(dialog, instanceID)
    local currentTime = Interval.GetCurrentTime()
    local minNPCDistance = MCMGet("min_distance")

    -- REFACTOR: simplify/modularize this logic

    if Osi.DialogGetNumberOfInvolvedPlayers(instanceID) > 0 then
        RNPCBRPrint(2, "Ignoring dialog " .. dialog .. " involving players.")
        return
    end

    local involvedNPCs = VCHelpers.Dialog:GetInvolvedNPCs(instanceID)

    if VCHelpers.Dialog:CheckIfPartyInvolved(involvedNPCs) then
        RNPCBRPrint(2, "Ignoring dialog " .. dialog .. " involving party members.")
        return
    end

    if ShouldSkipDialogWithMaxOccurrences(dialog) then
        RNPCBRPrint(2, "Ignoring dialog " .. dialog .. " with maximum occurrences.")
        AutomatedDialog.RequestStopDialog(dialog, instanceID)
        return
    end

    -- Check if the nearest NPC is too far away
    local involvedNPCsDistance = VCHelpers.Object:GetNPCsByDistance(involvedNPCs)
    if involvedNPCsDistance and involvedNPCsDistance[1] and involvedNPCsDistance[1].Distance then
        if involvedNPCsDistance[1].Distance > minNPCDistance then
            RNPCBRPrint(3, "Ignoring dialog " .. dialog .. " involving NPCs too far away.")
            return
        end
    else
        RNPCBRPrint(2, "Ignoring dialog " .. dialog .. ". No distance information available.")
        return
    end

    if AutomatedDialog.dialogs[dialog] == nil then
        AutomatedDialog.InitializeDialog(dialog, instanceID, currentTime)
    else
        AutomatedDialog.BlockOrAllowDialog(dialog, instanceID, involvedNPCsDistance, currentTime)
    end
end

return AutomatedDialog
