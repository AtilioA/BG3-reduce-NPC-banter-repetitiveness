Interval = {}

function Interval.GetCurrentTime()
    return Ext.Utils.MonotonicTime()
end

function Interval.ElapsedTime(timestamp)
    return Interval.GetCurrentTime() - timestamp
end

function PiecewiseFunction(x)
  -- Define the transition point
  local transitionPoint = 7.37

  -- Check if x is an integer
  if x ~= math.floor(x) then
      error("x must be an integer")
  end

  -- Calculate the function value based on the piece-wise condition
  if x <= transitionPoint then
      return x * x
  else
      return math.sqrt(400 * x)
  end
end

-- Function to calculate the wait time for a dialog
function Interval.GetWaitTime(dialog)
    if AutomatedDialog.dialogs and AutomatedDialog.dialogs[dialog] and AutomatedDialog.dialogs[dialog].instances then
        return PiecewiseFunction(#AutomatedDialog.dialogs[dialog].instances or 0)
    end
end

return Interval
