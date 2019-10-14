function VanguardRR:IsOfficer(player)
	local retVal = false;
	local inGuild, guildRank = VanguardRR:IsInGuild(player);
	if inGuild then
		if guildRank >=0 and guildRank <=4 then
			retVal = true;
		end
	end
	return retVal;
end

function VanguardRR:IsInGuild(player)
	local inGuild = false;
	local guildRank = -1;
	if IsInGuild() then
		local guildSize,_,_ = GetNumGuildMembers();
		for i=1, tonumber(guildSize) do
			name,_,rank,level = GetGuildRosterInfo(i);
			name = VanguardRR:FixName(name)
			if name == player then
				inGuild = true;
				guildRank = rank;
				break;
			end
		end
	end
	return inGuild, guildRank;
end

function VanguardRR:GetGuildRaiders()
	local raiders = {};
	local guildSize,_,_ = GetNumGuildMembers();
	if IsInGuild() then
		for i=1, tonumber(guildSize) do
			name,_,rank,level = GetGuildRosterInfo(i);
			name = VanguardRR:FixName(name)
			if level >= 55 then
				table.insert(raiders,name);
			end
		end
	end
	table.sort(raiders);
	return raiders;
end



