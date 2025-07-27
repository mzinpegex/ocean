local module = {}
module.__index = module

local ps = game:GetService("Players")

module.AllPlayers = {}

ps.PlayerAdded:Connect(function(plr)
	local default = {
		["Swimming"] = false;
		["Emerging"] = false;
		["Immersing"] = false;
		["CanJump"] = true;
		["UnderWater"] = false;
		["Drowning"] = false;

	}
	
	module.AllPlayers[plr.UserId] = default
end)

function module:SetSwimming(plr, value)
	local plrtable = module.AllPlayers[plr.UserId]
	plrtable["Swimming"] = value
end

function module:SetEmerging(plr, value)
	local plrtable = module.AllPlayers[plr.UserId]
	plrtable["Emerging"] = value
end

function module:SetImmersing(plr, value)
	local plrtable = module.AllPlayers[plr.UserId]
	plrtable["Immersing"] = value
end

function module:SetCanJump(plr, value)
	local plrtable = module.AllPlayers[plr.UserId]
	plrtable["CanJump"] = value
end

function module:SetDrowning(plr, value)
	local plrtable = module.AllPlayers[plr.UserId]
	plrtable["Drowning"] = value
end

return module
