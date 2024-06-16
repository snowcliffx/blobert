local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore = require(ServerScriptService.Data.DataStore)
local PlayerData = require(ServerScriptService.Data.PlayerData)

local AUTO_SAVE = true
local AUTO_SAVE_WAIT = 60

local function Initialize(player: Player)
    local Data = DataStore.GetData(player)

    if Data then
        PlayerData[player.UserId] = Data

        while AUTO_SAVE do
            task.wait(AUTO_SAVE_WAIT)

            for key, value in pairs(PlayerData[player.UserId]) do
                DataStore.SetData(player, key, value)
            end
        end
    else
        player:Kick("Fetching data failed after 10 tries!")
    end
end

Players.PlayerAdded:Connect(function(player)
    Initialize(player)
end)

for index, player in ipairs(Players:GetPlayers()) do
    task.defer(Initialize(player))
end
