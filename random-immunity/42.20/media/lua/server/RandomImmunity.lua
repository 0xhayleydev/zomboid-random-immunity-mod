local function enforceImmunity(player)
    local playerData = player:getModData()

    if playerData.HasRandomImmunity ~= true then
        return
    end

    local bodyDamage = player:getBodyDamage()
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

local function onPlayerGetDamage(player, damageType, _)
    if damageType ~= "INFECTION" then
        return
    end

    enforceImmunity(player)
end

Events.OnPlayerGetDamage.Add(onPlayerGetDamage)

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

local function onTick()
    local players = getOnlinePlayers()

    for i = 0, players:size() - 1 do
        local player = players:get(i)
        enforceImmunity(player)
    end
end

Events.OnTick.Add(onTick)