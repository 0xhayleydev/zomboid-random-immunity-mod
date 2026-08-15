---@param player IsoPlayer
local function enforceImmunity(player)
    local playerData = player:getModData()

    if playerData.HasRandomImmunity ~= true then
        return
    end

    local bodyDamage = player:getBodyDamage()
    local bodyParts = bodyDamage:getBodyParts()

    if bodyDamage:IsInfected() == false then
        return
    end

    local useFakeInfection = SandboxVars.RandomImmunity.FakeInfection

    bodyDamage:setInfected(false)
    local isBodyDamageFakeInfected = bodyDamage:IsFakeInfected()
    bodyDamage:setIsFakeInfected(isBodyDamageFakeInfected or useFakeInfection)
    bodyDamage:setInfectionMortalityDuration(-1)
    bodyDamage:setInfectionTime(-1)
    bodyDamage:setInfectionGrowthRate(0)

    for i = 0, bodyParts:size() - 1 do
        local bodyPart = bodyParts:get(i)

        if bodyPart:IsInfected() == true then
            bodyPart:SetInfected(false)

            local isBodyPartFakeInfected = bodyPart:IsFakeInfected()
            bodyPart:SetFakeInfected(isBodyPartFakeInfected or useFakeInfection)
        end
    end

    player:getStats():set(CharacterStat.ZOMBIE_INFECTION, 0)
end

Events.OnPlayerDeath.Add(enforceImmunity)

---@param character IsoGameCharacter
---@param damageType "POISON" | "HUNGRY" | "SICK" | "BLEEDING" | "THIRST" | "HEAVYLOAD" | "INFECTION" | "LOWWEIGHT" | "FALLDOWN" | "WEAPONHIT" | "CARHITDAMAGE" | "CARCRASHDAMAGE" | "FIRE"
---@param _ number
local function onPlayerGetDamage(character, damageType, _)
    if character:isZombie() then
        return
    end

    if damageType ~= "INFECTION" then
        return
    end

    enforceImmunity(character:getUsingPlayer())
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