local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore = require(ServerScriptService.Data.DataStore)
local PlayerData = require(ServerScriptService.Data.PlayerData)

local AUTO_SAVE = true
local AUTO_SAVE_WAIT = 60
local IS_STUDIO = RunService:IsStudio()

local function Initialize(player: Player)
	local Data = DataStore.GetData(player)

	if Data then
        DataStore.Reconcile(Data)
		PlayerData[player.UserId] = Data

		while AUTO_SAVE do
			task.wait(AUTO_SAVE_WAIT)

			DataStore.SetData(player, Data, true)
		end
	else
		player:Kick("Fetching data failed after 10 tries!")
	end
end

local function OnShutdown()
    if IS_STUDIO then
        task.wait(1)
    else
        for index, player in ipairs(Players:GetPlayers()) do
            local Data = PlayerData[player.UserId]
            DataStore.SetData(player, Data, false)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
	Initialize(player)
end)

for index, player in ipairs(Players:GetPlayers()) do
	task.defer(Initialize(player))
end

game:BindToClose(OnShutdown)
