function VanguardRR:TableSearch(tab,el)
	retVal = 0;
    for index, value in pairs(tab) do
        if value == el then
            retVal = index;
			break;
        end
    end
	return retVal;
end

function VanguardRR:GenerateID()
	local retVal = "";
	for i=1,24 do
		if i == 5 or i == 9 or i == 13 then
			retVal = retVal.."-"
		end
		retVal = retVal..strchar(math.random(26)+64)
	end
	retVal = date("%Y%m%d").."-"..retVal
	return retVal
end

function VanguardRR:Round(number, decimals)
    return tonumber((("%%.%df"):format(decimals)):format(number))
end

function VanguardRR:RoundMultiple(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function VanguardRR:Debug(message)
	if vanguard_debug then
		VanguardRR:Print(message)
	end
end

function VanguardRR:FixName(player)
	local retVal = player;
	local charpos = strfind(player,"-");
	if charpos ~= nil then
		retVal = strsub(player, 1, charpos-1)  --remove server from player name.  example: Feyde-Ashkandi
	end
	return retVal;
end

function VanguardRR:GetNotRaidLeader()
	
end
