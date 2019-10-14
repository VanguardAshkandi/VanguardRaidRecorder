local inRaid = false;

function VanguardRR:COMBAT_LOG_EVENT_UNFILTERED(event)
	if not SettingsDB["RaidStarted"] then
		return;
	end
   local timestamp, eventType, hideCaster,
   srcGUID, srcName, srcFlags, srcFlags2,
   dstGUID, dstName, dstFlags, dstFlags2,
   spellID, spellName, arg3, arg4, arg5 = CombatLogGetCurrentEventInfo()
	
   local isSrcPlayer = bit.band(srcFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
	
	if eventType == "UNIT_DIED" then
		if VanguardRR:TableSearch(vanguard_boss_list,dstName) > 0 then
			VanguardRR:Debug("UNIT_DIED:"..dstName);
			VanguardRR:BossKill(dstName);
		end
	end
end

function VanguardRR:CHAT_MSG_MONSTER_YELL(event, msg, name)
	if not SettingsDB["RaidStarted"] then
		return;
	end
	if msg == "Impossible! Stay your attack, mortals... I submit! I submit!"  then
		VanguardRR:BossKill("Majordomo Executus");
	end
end

function VanguardRR:GROUP_ROSTER_UPDATE()

	if UnitInRaid("player") == nil then
		inRaid = false;
		return;
	else
		if not inRaid then
			local players, raidleader = VanguardRR:GetRaidRoster();
			if raidleader == UnitName("player") then
				for index, value in pairs(players) do
					if value ~= UnitName("player") then
						VanguardRR:CommSend("VRRSENDRAID",value);
						break;
					end
				end
			else
				VanguardRR:CommSend("VRRSENDRAID",raidleader);
			end
		end
	end

	local roster = VanguardRR:GetRaidRoster()

	if SettingsDB["RaidStarted"] then
		for index, player in pairs(roster) do
			if not VanguardRR:PlayerInRaid(player) and not VanguardRR:PlayerInQueue(player) then
				VanguardRR:AddToRaid(player)
				VanguardRR:PlayerJoined(player)
			elseif VanguardRR:PlayerInQueue(player) then
				VanguardRR:AddToRaid(player)
				VanguardRR:RemoveFromQueue(player)
			end
		end
		for index, player in pairs(SettingsDB["RaidMembers"]) do
			if not VanguardRR:PlayerInQueue(player) then
				if VanguardRR:TableSearch(roster,player) == 0 then
					VanguardRR:RemoveFromRaid(player)
					VanguardRR:PlayerLeft(player)
				end
			end
		end
	else
		for index, player in pairs(roster) do
			VanguardRR:RemoveFromQueue(player)
		end
		for index, player in pairs(SettingsDB["RaidQueue"]) do
			if VanguardRR:TableSearch(roster,player) == 0 then
				VanguardRR:RemoveFromQueue(player)
			end
		end
	end
end

function VanguardRR:LOOT_OPENED()
	--if IsInRaid() then
		if SettingsDB["RaidStarted"] then
			if VanguardRR:IsOfficer(UnitName("player")) then
				VanguardRR:LootWindowHook()
			end
		end
	--end
end

