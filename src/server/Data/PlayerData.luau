--!strict
--!native
--!optimize 2

--[ TYPES ]--
type Data = {
	Money: number,
}

local PlayerData = {} :: { [number]: Data }

return PlayerData
