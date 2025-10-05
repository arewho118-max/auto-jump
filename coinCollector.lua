local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- Custom values
local COIN_VALUE = 1 -- Value of each coin
local MAX_COINS = 40 -- Maximum coins a player can collect
local COLLECTION_RADIUS = 10 -- Radius for coin collection (in studs)
local HOVER_HEIGHT = 3 -- Height above ground when flying to collect coins

-- Function to find the nearest coin
local function findNearestCoin(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end

    local nearestCoin = nil
    local nearestDistance = math.huge

    for _, coin in ipairs(workspace:GetDescendants()) do
        if coin:IsA("BasePart") and coin.Name == "Coin" then
            local distance = (humanoidRootPart.Position - coin.Position).Magnitude
            if distance < nearestDistance then
                nearestCoin = coin
                nearestDistance = distance
            end
        end
    end

    return nearestCoin
end

-- Function to collect a coin
local function collectCoin(player, coin)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not humanoidRootPart then return end

    -- Allow the player to fly
    humanoid.JumpPower = 0
    humanoid.WalkSpeed = 20

    -- Create BodyGyro to control rotation
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Parent = humanoidRootPart
    bodyGyro.MaxTorque = Vector3.new(400, 400, 400)
    bodyGyro.P = 5000
    bodyGyro.CFrame = CFrame.lookAt(humanoidRootPart.Position, coin.Position)

    -- Create BodyPosition to control position
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.Parent = humanoidRootPart
    bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyPosition.P = 5000
    bodyPosition.Position = coin.Position + Vector3.new(0, HOVER_HEIGHT, 0)

    -- Collect the coin
    Debris:AddItem(coin, 0.3)
    player.leaderstats.Coins.Value += COIN_VALUE

    -- Check if the player's coin limit is reached
    if player.leaderstats.Coins.Value >= MAX_COINS then
        humanoid.JumpPower = 50
        humanoid.WalkSpeed = 16
        bodyGyro:Destroy()
        bodyPosition:Destroy()
        print("Inventory full!")
    else
        -- Find the next coin after a delay
        delay(0.5, function()
            local nextCoin = findNearestCoin(player)
            if nextCoin then
                collectCoin(player, nextCoin)
            end
        end)
    end
end

-- When a player joins the game
Players.PlayerAdded:Connect(function(player)
    -- Create leaderstats if not already present
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 0
    coins.Parent = leaderstats

    -- Check for nearby coins every second
    while true do
        wait(1)
        if player and player.Character then
            if player.leaderstats.Coins.Value < MAX_COINS then
                local nearestCoin = findNearestCoin(player)
                if nearestCoin then
                    collectCoin(player, nearestCoin)
                end
            end
        end
    end
end)
