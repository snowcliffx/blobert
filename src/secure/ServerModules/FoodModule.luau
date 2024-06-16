--!strict
--!native
--!optimize 2

local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData = require(ServerScriptService.Data.PlayerData)

type Food = { Price: number, Saturation: number }

local FoodList: { [string]: Food } = {
    Chicken = { Price = 10, Saturation = 10 }
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
        CurrentData.Hunger += FoodToFeed.Saturation
    else
        print("Food not found!")
    end
end
