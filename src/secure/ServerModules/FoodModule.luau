--!strict
--!native
--!optimize 2

local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData = require(ServerScriptService.Data.PlayerData)

type Food = { Price: number, Saturation: number }

local FoodList: { [string]: Food } = {
    Cheese = { Price = 5, Saturation = 1 },
    Chocolate = { Price = 35, Saturation = 10},
	Chicken = { Price = 80, Saturation = 25 },
}

local FoodModule = {}

function FoodModule.Purchase(player: Player, name: string)
	local FoodToPurchase = FoodList[name]
	local CurrentData = PlayerData[player.UserId]

	if FoodToPurchase then
		if CurrentData.Money >= FoodToPurchase.Price then
			CurrentData.Money -= FoodToPurchase.Price
			CurrentData.FoodOwned[name] = CurrentData.FoodOwned[name] + 1 or 1
		else
			print("Not enough money!")
		end
	else
		print("Food not found!")
	end
end

function FoodModule.Feed(player: Player, name: string)
	local FoodToFeed = FoodList[name]
	local CurrentData = PlayerData[player.UserId]

	if FoodToFeed then
		if CurrentData.FoodOwned[name] then
			CurrentData.Hunger += FoodToFeed.Saturation
		else
			print("Food is not in the inventory!")
		end
	else
		print("Food not found!")
	end
end
