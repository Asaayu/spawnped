-- Spawn a specific ped with a specific weapon and specified hostility towards the player
-- Asaayu @ 12/11/21

-- Register new chat command to spawn a ped with specific weapon and hostility towards the player
RegisterCommand("spawnped", function(source, args)
        -- Because this command uses the player's ped position this needs to be run by a player and not a resource or through the server console
        -- If source >= 0 then this must be a player. See https://docs.fivem.net/natives/?_0x5FA79B0F
        if source < 0 then error("'/spawnped': this command can only be run in-game by a player", 0) return end

        -- Make sure that enough parameters have been passed through for the command to run
        if #args <= 2 then error("'/spawnped': check input, not enough parameters provided", 0) return end

        -- Extract the arguments from the user input
        local pedHash = GetHashKey(args[1])
        local weaponHash = GetHashKey(args[2])
        local hostile = string.lower(args[3]) == "true"

        -- Check that the model for the ped exists
        if not IsModelAPed(pedHash) then error("'/spawnped': Provided model name is not a valid ped model.", 0) return end

        -- Get player's ped
        local player = GetPlayerPed(GetPlayerFromServerId(source));

        -- Get position of the player's ped
        local playerPosition = GetEntityCoords(player, nil)
        
        -- Get the forward vector of the player's ped
        local playerVector = GetEntityForwardVector(player)

        -- Convert the forward vector to an offset of three meters from the players position
        local spawnOffset = playerVector*3

        -- Get the new spawn position from the players position plus the offset caluclated above
        local pedSpawnPosition = playerPosition + spawnOffset

        -- Preload the ped model into memory
        RequestModel(pedHash)

        -- Make sure the ped model is loaded into memory
        while not HasModelLoaded(pedHash) do Wait(1) end

        -- Create the ped model in the world
        local ped = CreatePed
        (
            0,
            pedHash,
            pedSpawnPosition.x,
            pedSpawnPosition.y,
            pedSpawnPosition.z,
            GetEntityHeading(player)-180, -- Spawn the ped facing towards the player (Direction player is facing - 180 degrees)
            true,
            false
        )

        -- Give the ped the specified weapon with 1k ammo
        GiveWeaponToPed
        (
            ped,
            weaponHash,
            1000,
            true
        )

        -- Get the ped to select the weapon we just gave them
        SetCurrentPedWeapon(
            ped,
            weaponHash,
            true,
            0,
            0,
            0
        )

        -- Make the ped hostile towards the player if the hostile variable is true
        if hostile then
            -- Make the spawned ped attack the player's ped
            TaskCombatPed
            (
                ped,
                player,
                0,
                16
            ) 
        end

        -- End of command
    end
)

-- Add suggestion to show user information about the command
TriggerEvent('chat:addSuggestion', '/spawnped', 'Spawns a ped in front of the player. Arguments define the ped model, weapon, and hostility towards the player.',
{
    -- Parameters for the command
    { name="pedClass", help="Ped model name (STRING)" },
    { name="weaponClass", help="Weapon name (STRING)" },
    { name="hostile", help="Is the ped hostile towards the player (BOOL)" }
})

