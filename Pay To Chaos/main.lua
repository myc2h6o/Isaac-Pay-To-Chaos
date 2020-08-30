local mod = RegisterMod("Pay To Chaos", 1)
mod.ChallengeIdPayToChaos = Isaac.GetChallengeIdByName("Pay To Chaos")
mod.ItemIdPayToChaos = Isaac.GetItemIdByName("Pay To Chaos")

-- Sin and Cos
mod.Cos90D = 0.000
mod.Cos54D = 0.588
mod.Cos18D = 0.951
mod.Sin90D = 1.000
mod.Sin54D = 0.809
mod.Sin18D = 0.309

-- Chaos card speed vector
mod.ChaosCardSpeed = 10
mod.ChaosCardSpeedVectors =
{
    Vector(mod.ChaosCardSpeed * mod.Cos90D, mod.ChaosCardSpeed * mod.Sin90D),
    Vector(mod.ChaosCardSpeed * mod.Cos90D, -mod.ChaosCardSpeed * mod.Sin90D),
    Vector(mod.ChaosCardSpeed * mod.Cos54D, mod.ChaosCardSpeed * mod.Sin54D),
    Vector(mod.ChaosCardSpeed * mod.Cos54D, -mod.ChaosCardSpeed * mod.Sin54D),
    Vector(-mod.ChaosCardSpeed * mod.Cos54D, mod.ChaosCardSpeed * mod.Sin54D),
    Vector(-mod.ChaosCardSpeed * mod.Cos54D, -mod.ChaosCardSpeed * mod.Sin54D),
    Vector(mod.ChaosCardSpeed * mod.Cos18D, mod.ChaosCardSpeed * mod.Sin18D),
    Vector(mod.ChaosCardSpeed * mod.Cos18D, -mod.ChaosCardSpeed * mod.Sin18D),
    Vector(-mod.ChaosCardSpeed * mod.Cos18D, mod.ChaosCardSpeed * mod.Sin18D),
    Vector(-mod.ChaosCardSpeed * mod.Cos18D, -mod.ChaosCardSpeed * mod.Sin18D)
}

-- Initial coins
mod.CoinRadius = 50
mod.InitialCoins = 
{
    { mod.CoinRadius * mod.Cos90D, mod.CoinRadius * mod.Sin90D, CoinSubType.COIN_NICKEL },
    { mod.CoinRadius * mod.Cos90D, -mod.CoinRadius * mod.Sin90D, CoinSubType.COIN_DIME },
    { mod.CoinRadius * mod.Cos54D, mod.CoinRadius * mod.Sin54D, CoinSubType.COIN_DIME },
    { mod.CoinRadius * mod.Cos54D, -mod.CoinRadius * mod.Sin54D, CoinSubType.COIN_DIME },
    { -mod.CoinRadius * mod.Cos54D, mod.CoinRadius * mod.Sin54D, CoinSubType.COIN_DIME },
    { -mod.CoinRadius * mod.Cos54D, -mod.CoinRadius * mod.Sin54D, CoinSubType.COIN_DIME },
    { mod.CoinRadius * mod.Cos18D, mod.CoinRadius * mod.Sin18D, CoinSubType.COIN_DIME },
    { mod.CoinRadius * mod.Cos18D, -mod.CoinRadius * mod.Sin18D, CoinSubType.COIN_PENNY },
    { -mod.CoinRadius * mod.Cos18D, mod.CoinRadius * mod.Sin18D, CoinSubType.COIN_DIME },
    { -mod.CoinRadius * mod.Cos18D, -mod.CoinRadius * mod.Sin18D, CoinSubType.COIN_PENNY }
}

function mod:PostGameStarted(isContinued)
    -- Create starting stuff at middle of the start room on a new game
    local roomCenterX = 320
    local roomCenterY = 280
    if mod.ChallengeIdPayToChaos == Isaac.GetChallenge() and not isContinued then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, mod.ItemIdPayToChaos, Vector(roomCenterX, roomCenterY), Vector(0,0), nil)
        for i = 1, #mod.InitialCoins, 1 do
            local position = Vector(roomCenterX + mod.InitialCoins[i][1], roomCenterY + mod.InitialCoins[i][2])
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, mod.InitialCoins[i][3], position, Vector(0,0), nil)
        end
    end
end


function mod:PreUseItemPayToChaos(item, rng)
    -- Prevent item to be triggered if player does not have coin
    local player = Isaac.GetPlayer(0)
    if player:GetNumCoins() <= 0 then
        return true
    end
end

function mod:UseItemPayToChaos(item, rng)
    -- Spawn chaos tears by decreasing one coin
    local player = Isaac.GetPlayer(0)
    player:AddCoins(-1)
    mod:SpawnChaosTears(player)

    -- Return true to show animation of using item
    return true
end

function mod:SpawnChaosTears(player)
    -- Spawn chaos tears based on player position
    local playerX = player.Position.X
    local playerY = player.Position.Y
    for i = 1, #mod.ChaosCardSpeedVectors , 1 do
        Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.CHAOS_CARD, 0, Vector(playerX, playerY), mod.ChaosCardSpeedVectors[i], player)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.PostGameStarted)
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, mod.PreUseItemPayToChaos, mod.ItemIdPayToChaos)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseItemPayToChaos, mod.ItemIdPayToChaos)
