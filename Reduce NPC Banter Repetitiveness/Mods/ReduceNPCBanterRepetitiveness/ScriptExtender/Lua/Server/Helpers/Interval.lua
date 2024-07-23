Interval = {}

local function getRandomInterval(min, max)
    return math.random(min, max)
end

local function getRandomWaitTime()
    local minInterval = MCMGet("min_interval_bonus")
    local maxInterval = MCMGet("max_interval_bonus")

    return getRandomInterval(minInterval, maxInterval)
end

local function ensureWaitTimeIsInRange(waitTime, dialog)
    local minWaitTime = MCMGet("min_interval_bonus")
    local maxWaitTime = MCMGet("max_interval_bonus")

    if maxWaitTime == -1 then
        return math.max(minWaitTime, waitTime)
    else
        return math.max(minWaitTime, math.min(waitTime, maxWaitTime))
    end
end

function Interval.GetCurrentTime()
    return Ext.Utils.MonotonicTime()
end

function Interval.ElapsedTime(timestamp)
    return Interval.GetCurrentTime() - timestamp
end

local function piecewiseFunction(x)
    -- Transition point for the piece-wise function
    local transitionPoint = 7.37

    -- Make sure x is an integer
    x = math.floor(x)

    -- Calculate the function value based on the piece-wise condition
    if x <= transitionPoint then
        -- Quadratic function for x <= transitionPoint
        return x * x
    else
        -- Square root function for x > transitionPoint
        return math.sqrt(400 * x)
    end
end

local function calculateWaitFactorScaling(waitTime, distanceToDialog)
    local shouldScaleWithDistance = MCMGet("distance_factor_scaling_enabled")
    if not shouldScaleWithDistance then
        return waitTime
    end

    local minDistance = MCMGet("distance_factor_scaling_min_distance")
    local maxDistance = MCMGet("distance_factor_scaling_max_distance")
    local minPenaltyFactor = MCMGet("distance_factor_scaling_min_penalty_factor")
    local maxPenaltyFactor = MCMGet("distance_factor_scaling_max_penalty_factor")

    -- Ensure distanceToDialog falls within the defined range
    distanceToDialog = math.max(minDistance, math.min(distanceToDialog, maxDistance))

    -- Calculate penalty factor using an approach that aims to simulate logarithmic perception
    -- This approach uses the logarithmic scaling relative to the distance range
    local logBase = 10
    local scaledDistance = (distanceToDialog - minDistance) / (maxDistance - minDistance)
    local logDistance = math.log(1 + scaledDistance * (logBase - 1)) / math.log(logBase)

    -- Interpolate penalty factor based on logarithmically scaled distance
    local penaltyFactor = minPenaltyFactor + (maxPenaltyFactor - minPenaltyFactor) * logDistance

    -- Apply the penalty factor to the wait time
    return waitTime * penaltyFactor
end

function Interval.GetWaitTime(dialog, distanceToDialog)
    local shouldUseRandomInterval = MCMGet("random_intervals") and MCMGet("max_occurrences") ~= -1
    if not AutomatedDialog.dialogs or not AutomatedDialog.dialogs[dialog] or not AutomatedDialog.dialogs[dialog].instances then
        return 0
    end

    local intervalTime = 0
    if shouldUseRandomInterval then
        intervalTime = getRandomWaitTime()
    else
        intervalTime = piecewiseFunction(#AutomatedDialog.dialogs[dialog].instances or 0)
    end

    RNPCBRDebug(1, "Wait time for " .. dialog .. " is " .. intervalTime .. " seconds.")

    local waitTime = intervalTime * 1000

    waitTime = calculateWaitFactorScaling(waitTime, distanceToDialog)

    waitTime = ensureWaitTimeIsInRange(waitTime, dialog)

    return waitTime
end

return Interval
