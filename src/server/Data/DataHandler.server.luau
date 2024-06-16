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

	if Data ~= nil then
		DataStore.Reconcile(Data)
		PlayerData[player.UserId] = Data

		while AUTO_SAVE do
			task.wait(AUTO_SAVE_WAIT)

			DataStore.SetData(player, PlayerData[player.UserId], true)
		end
	else
		player:Kick("Fetching data failed after 20 tries!")
	end
end

local function OnShutdown()
	if IS_STUDIO then
		task.wait(1)
	else
		local MainThread = coroutine.running()
		local ThreadsRunning = 0

		local StartSaveThread = coroutine.wrap(function(player: Player, data)
			DataStore.SetData(player, data, false)

			ThreadsRunning -= 1

			if ThreadsRunning == 0 then
				coroutine.resume(MainThread)
			end
		end)

		for index, player in ipairs(Players:GetPlayers()) do
			ThreadsRunning += 1

			StartSaveThread(player, PlayerData[player.UserId])
		end

		if ThreadsRunning > 0 then
			coroutine.yield()
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	Initialize(player)
end)

Players.PlayerRemoving:Connect(function(player)
	DataStore.SetData(player, PlayerData[player.UserId], true)
end)

for index, player in ipairs(Players:GetPlayers()) do
	task.defer(Initialize(player))
end

game:BindToClose(OnShutdown)
