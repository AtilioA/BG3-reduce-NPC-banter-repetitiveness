-- Adapted from FocusBG3: https://www.nexusmods.com/baldursgate3/mods/5972

---@param origin vec3
---@param target vec3
---@param ignoreHeight? boolean
---@return number
function GetDistance(origin, target, ignoreHeight)
  ignoreHeight = ignoreHeight == nil or ignoreHeight
  return math.sqrt(
    (origin[1] - target[1]) ^ 2
    + ((ignoreHeight and 0) or (origin[2] - target[2]) ^ 2)
    + (origin[3] - target[3]) ^ 2
  )
end

--- Returns a sorted table of involved NPCs by distance from the host character, including detailed info.
---@param involvedNPCs EntityHandle[] @List of NPC handles.
---@return table A table with details of involved NPCs: Entity, Guid, Distance, and Name, sorted by Distance.
function GetInvolvedNPCsByDistance(involvedNPCs)
  local hostCharacter = Osi.GetHostCharacter()   -- Assuming this retrieves the player or designated character
  local NPCsInfo = {}

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
