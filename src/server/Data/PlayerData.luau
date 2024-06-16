--!strict
--!native
--!optimize 2

--[ TYPES ]--
type Data = {
    Entertainment: number,
    Health: number,
    Hunger: number,
    Money: number,
    Thirst: number,

    FoodOwned: { [string]: number }
}

local PlayerData = {} :: { [number]: Data }

return PlayerData
