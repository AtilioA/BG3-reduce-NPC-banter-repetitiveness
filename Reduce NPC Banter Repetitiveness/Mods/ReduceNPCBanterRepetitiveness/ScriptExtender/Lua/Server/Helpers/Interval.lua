Interval = {}

function Interval.GetCurrentTime()
    return Ext.Utils.MonotonicTime()
end

function Interval.ElapsedTime(timestamp)
    return Interval.GetCurrentTime() - timestamp
end

function PiecewiseFunction(x)
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

function CalculateWaitFactorScaling(waitTime, distanceToDialog)
    local shouldScaleWithDistance = JsonConfig.FEATURES.interval_options.distance_factor_scaling.enabled

    if shouldScaleWithDistance then
        local distanceConfig = JsonConfig.FEATURES.interval_options.distance_factor_scaling
        local minDistance = distanceConfig.min_distance
        local maxDistance = distanceConfig.max_distance
        local minPenaltyFactor = distanceConfig.min_penalty_factor
        local maxPenaltyFactor = distanceConfig.max_penalty_factor

        -- Ensure distanceToDialog falls within the defined range
        distanceToDialog = math.max(minDistance, math.min(distanceToDialog, maxDistance))

        -- Calculate penalty factor using an approach that aims to simulate logarithmic perception
        -- This approach uses the logarithmic scaling relative to the distance range
        local logBase = 10
        local scaledDistance = (distanceToDialog - minDistance) / (maxDistance - minDistance)
        -- Logarithmically scale distance
        local logDistance = math.log(1 + scaledDistance * (logBase - 1)) /
            math.log(logBase)

        -- Interpolate penalty factor based on logarithmically scaled distance
        local penaltyFactor = minPenaltyFactor + (maxPenaltyFactor - minPenaltyFactor) * logDistance

        -- Apply the penalty factor to the wait time
        waitTime = waitTime * penaltyFactor
    end

    return waitTime
end

function GetRandomInterval(min, max)
    return math.random(min, max)
end

function GetRandomWaitTime()
    local minInterval = JsonConfig.FEATURES.interval_options.min_interval_bonus
    local maxInterval = JsonConfig.FEATURES.interval_options.max_interval_bonus

    return GetRandomInterval(minInterval, maxInterval)
end

function EnsureWaitTimeIsInRange(waitTime)
    local minWaitTime = JsonConfig.FEATURES.interval_options.min_wait_time
    local maxWaitTime = JsonConfig.FEATURES.interval_options.max_wait_time

    if maxWaitTime == -1 then
        return math.max(minWaitTime, waitTime)
    else
        return math.max(minWaitTime, math.min(waitTime, maxWaitTime))
    end
end

-- Function to calculate the wait time for a dialog
function Interval.GetWaitTime(dialog, distanceToDialog)
    if AutomatedDialog.dialogs and AutomatedDialog.dialogs[dialog] and AutomatedDialog.dialogs[dialog].instances then
        local intervalTime = GetRandomWaitTime()
        local shouldUseRandomInterval = JsonConfig.FEATURES.interval_options.random_intervals and
            JsonConfig.FEATURES.interval_options.max_interval_bonus > 0
        if shouldUseRandomInterval then
            intervalTime = PiecewiseFunction(#AutomatedDialog.dialogs[dialog].instances or 0)
        end
        Utils.DebugPrint(1, "Wait time for " .. dialog .. " is " .. intervalTime .. " seconds.")

        local waitTime = intervalTime * 1000
        waitTime = CalculateWaitFactorScaling(waitTime, distanceToDialog)
        Utils.DebugPrint(1,
            "Based on the distance of " ..
            distanceToDialog .. " meters, the wait time is " .. waitTime .. " milliseconds.")

        local boundedWaitTime = EnsureWaitTimeIsInRange(waitTime)

        return boundedWaitTime
    end
end

return Interval
