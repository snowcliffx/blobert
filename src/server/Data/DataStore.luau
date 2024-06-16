--!strict
--!native
--!optimize 2

--[ SERVICES ]--
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

--[ TYPES ]--
type Data = {
	Money: number,
}

--[ SETTINGS ]--
local ATTEMPT_COUNT = 20
local BUDGET_SCARCE = 1
local BUDGET_WAIT = 5

--[ ENUMS ]--
local GetAsyncRequest = Enum.DataStoreRequestType.GetAsync
local SetAsyncRequest = Enum.DataStoreRequestType.SetIncrementAsync
local UpdateAsyncRequest = Enum.DataStoreRequestType.UpdateAsync

--[ MAIN MODULE ]--
local DataStore = {}

--[ DATA STORE ]--
local MainDataStore = DataStoreService:GetDataStore("MainDataStore")

--[ DATA TEMPLATE ]--
local DataTemplate: Data = {
	Money = 0,
}

local function DeepCopyTable(t)
	local Copy = {}

	for key, value in pairs(t) do
		if type(value) == "table" then
			Copy[key] = DeepCopyTable(value)
		else
			Copy[key] = value
		end
	end

	return Copy
end

local function WaitForRequestBudget(request_type: Enum.DataStoreRequestType)
	local CurrentBudget = DataStoreService:GetRequestBudgetForRequestType(request_type)

	while CurrentBudget < BUDGET_SCARCE do
		CurrentBudget = DataStoreService:GetRequestBudgetForRequestType(request_type)
		task.wait(BUDGET_WAIT)
	end
end

function DataStore.Reconcile(data: Data)
	for key, value in pairs(DataTemplate) do
		if data[key] == nil then
			if type(value) == "table" then
				data[key] = DeepCopyTable(value)
			else
				data[key] = value
			end
		end
	end
end

function DataStore.GetData(player: Player): Data | {} | nil
	local success, result
	local count = 0

	repeat
		count += 1

		WaitForRequestBudget(GetAsyncRequest)
		success, result = pcall(MainDataStore.GetAsync, MainDataStore, player.UserId)
	until success or not Players:FindFirstChild(player.Name) or count == ATTEMPT_COUNT

	if success then
        if result == nil then
            return {}
        else
            return result
        end
	else
		print("There was an error while getting data: " .. result)
		return nil
	end
end

function DataStore.SetData(player: Player, value: any, halt: boolean)
	local success, result
	local count = 0

	repeat
		count += 1

		if halt then
			WaitForRequestBudget(SetAsyncRequest)
		end

		success, result = pcall(MainDataStore.SetAsync, MainDataStore, player.UserId, value)
	until success or count == ATTEMPT_COUNT

	if success then
		print("Saved successfully!")
	else
		print("There was an error while saving data: " .. result)
	end
end

function DataStore.UpdateData(player: Player, callback: <T>(old_value: T) -> T, halt: boolean)
	local success, result
	local count = 0

	repeat
		count += 1

		if halt then
			WaitForRequestBudget(UpdateAsyncRequest)
		end

		success, result = pcall(MainDataStore.UpdateAsync, MainDataStore, player.UserId, callback)
	until success or count == ATTEMPT_COUNT

	if success then
		print("Updated successfully!")
	else
		print("There was an error while updating data: " .. result)
	end
end

return DataStore
