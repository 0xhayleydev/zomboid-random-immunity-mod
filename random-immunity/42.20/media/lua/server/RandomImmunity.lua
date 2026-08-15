local function enforceImmunity(player)
    local playerData = player:getModData()

    if playerData.HasRandomImmunity ~= true then
        return
    end

    local bodyDamage = player:getBodyDamageRemote()
    local bodyParts = bodyDamage:getBodyParts()

    bodyDamage:setInfected(false)
    bodyDamage:setIsFakeInfected(true)
    bodyDamage:setInfectionMortalityDuration(-1)
    bodyDamage:setInfectionTime(-1)
    bodyDamage:setInfectionGrowthRate(0)

    for i = 0, bodyParts:size() - 1 do
        local bodyPart = bodyParts:get(i)

        if bodyPart:IsInfected() == true then
            print(tostring(bodyPart:getType()) .. " is infected wound? " .. tostring(bodyPart:IsInfected()))

            bodyPart:SetInfected(false)
            bodyPart:SetFakeInfected(true)

            print(tostring(bodyPart:getType()) .. " is infected wound? " .. tostring(bodyPart:IsInfected()))
        end
    end

    player:getStats():set(CharacterStat.ZOMBIE_INFECTION, 0)
end

Events.OnPlayerDeath.Add(enforceImmunity)

---@param player IsoGameCharacter
---@param damageType "POISON" | "HUNGRY" | "SICK" | "BLEEDING" | "THIRST" | "HEAVYLOAD" | "INFECTION" | "LOWWEIGHT" | "FALLDOWN" | "WEAPONHIT" | "CARHITDAMAGE" | "CARCRASHDAMAGE" | "FIRE"
---@param _ number
local function onPlayerGetDamage(player, damageType, _)
    if player:isZombie() then
        return
    end

    if damageType ~= "INFECTION" then
        return
    end

    enforceImmunity(player:getUsingPlayer())
end

Events.OnPlayerGetDamage.Add(onPlayerGetDamage)

---@param _ number
---@param player IsoPlayer
local function onCreatePlayer(_, player)
    local data = player:getModData()

    if data.RandomImmunityResetID ~= SandboxVars.RandomImmunity.ResetID then
        data.RandomImmunityResetID = SandboxVars.RandomImmunity.ResetID
        data.HasRandomImmunity = nil
    end

    if data.HasRandomImmunity ~= nil then
        return
    end

    data.HasRandomImmunity = ZombRand(0.0, 100.0) <= SandboxVars.RandomImmunity.RandomImmunityChance

    if data.HasRandomImmunity then
        print(player:getUsername() .. " is immune.")
    else
        print(player:getUsername() .. " is not immune.")
    end

    player:transmitModData()
end

Events.OnCreatePlayer.Add(onCreatePlayer)

---@param _ number
local function onTick(_)
    local players = getOnlinePlayers()

    for i = 0, players:size() - 1 do
        local player = players:get(i)
        enforceImmunity(player)
    end
end

Events.OnTick.Add(onTick)