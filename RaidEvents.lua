function VanguardRR:StartRaid(RaidID, LootRaid, sender)
	if SettingsDB["RaidStarted"] then  --raid already started, ignore
		return;
	end
	local raidstarter = false;
	if RaidID == nil then
		RaidID = VanguardRR:GenerateID()
		raidstarter = true;
	end
	if LootRaid == nil then
		LootRaid = false;
	end
	SettingsDB["RaidID"] = RaidID;
	SettingsDB["LootRaid"] = LootRaid;
	RaidDB[SettingsDB["RaidID"]] = {};
	SettingsDB["RaidMembers"] = VanguardRR:GetRaidRoster();
	players = VanguardRR:GetAllPlayers()
	local data = {
			["Time"] = GetServerTime(),
			["Players"] = players,
			["Loot"] = tostring(LootRaid)
		};
	VanguardRR:AddRaidEvent("RAID_START",data);
	SettingsDB["RaidStarted"] = true;
	if raidstarter then
		VanguardRR:CommSend("VRRSTARTRAID", RaidID);
		VanguardRR:Print("Raid Started!");
	else
		VanguardRR:Print(sender.." has started a raid!");
	end
end

function VanguardRR:PlayerJoined(player)
	if SettingsDB["RaidStarted"] == false then --if you were not there for the raid start, ignore
		return;
	end
	local data = {
		["Time"] = GetServerTime(),
		["Name"] = player
	}
	VanguardRR:AddRaidEvent("RAID_JOIN",data)
end

function VanguardRR:PlayerLeft(player)
	if SettingsDB["RaidStarted"] == false then --if you were not there for the raid start, ignore
		return;
	end
	local data = {
		["Time"] = GetServerTime(),
		["Name"] = player
	}
	VanguardRR:AddRaidEvent("RAID_LEAVE",data)
end

function VanguardRR:BossKill(bossname)
	if not SettingsDB["RaidStarted"] then --if you were not there for the raid start, ignore
		return;
	end
	local players = VanguardRR:GetAllPlayers()
	local data = {
		["Time"] = GetServerTime(),
		["Name"] = bossname,
		["Players"] = players
	}
	VanguardRR:AddRaidEvent("RAID_BOSS",data);
	local _, raidLeader = VanguardRR:GetRaidRoster();
	if raidLeader == UnitName("player") then
		VanguardRR:Debug("raidLeader:"..raidLeader..", unitname:"..UnitName("player"));
		SendChatMessage("BOSS KILL: "..bossname,"GUILD");
	end
end

function VanguardRR:Loot(lootid,action,player,amount,sender)
	if not SettingsDB["RaidStarted"] then --if you were not there for the raid start, ignore
		return;
	end
	local itemName,itemLink,itemRarity,_,_,_,_,_,_,itemIcon = GetItemInfo(lootid)

	local data = {
		["Time"] = GetServerTime(),
		["ID"] = lootid,
		["Name"] = itemName,
		["Action"] = action,
		["Player"] = player,
		["Amount"] = amount
	}

	VanguardRR:AddRaidEvent("RAID_LOOT",data)
	if sender == nil then
		if player ~= "" then
			SendChatMessage("Congratulations to "..player.." for winning "..itemLink.."!","GUILD")
		end
		local commdata = {}
		table.insert(commdata,lootid)
		table.insert(commdata,action)
		table.insert(commdata,player)
		table.insert(commdata,amount)
		VanguardRR:CommSend("VRRAWARDLOOT", commdata)
	end
end

function VanguardRR:EndRaid(sender)
	if SettingsDB["RaidStarted"] == false then --if you were not there for the raid start, ignore
		return;
	else
		SettingsDB["RaidStarted"] = false;
	end
	local data = {
			["Time"] = GetServerTime()
		}
	VanguardRR:AddRaidEvent("RAID_END",data)
	RaidID = SettingsDB["RaidID"]
	SettingsDB["RaidID"] = ""
	SettingsDB["RaidMembers"] = {}
	if sender == nil then
		VanguardRR:CommSend("VRRENDRAID", RaidID)
		VanguardRR:Print("Raid Ended!")
	else
		VanguardRR:Print(sender.." has ended the raid.")
	end
	VRRRaidControl_OnShow()

end


function VanguardRR:AddRaidEvent(event,data)
	local eventData = { 
		["EVENT_TYPE"] = event,
		["EVENT_DATA"]= data }
	table.insert(RaidDB[SettingsDB["RaidID"]], eventData)
end

