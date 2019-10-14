VanguardRR = LibStub("AceAddon-3.0"):NewAddon("VanguardRR", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0" );

vanguard_loaded = false;
vanguard_officer = false;

vanguard_class_colors = {
	["Druid"] = "FF7D0A",
	["Hunter"] = "ABD473",
	["Mage"] = "40C7EB",
	["Priest"] = "FFFFFF",
	["Rogue"] = "FFF569",
	["Shaman"] = "F58CBA",
	["Paladin"] = "F58CBA",
	["Warlock"] = "8787ED",
	["Warrior"] = "C79C6E" 
}

vanguard_boss_list = {
	"Kobold Tunneler",
    "Lucifron", "Magmadar", "Gehennas",
    "Garr", "Baron Geddon", "Shazzrah", "Sulfuron Harbinger", 
    "Golemagg the Incinerator", "Ragnaros",
    "Razorgore the Untamed", "Vaelastrasz the Corrupt", "Broodlord Lashlayer",
    "Firemaw", "Ebonroc", "Flamegor", "Chromaggus", 
    "Nefarian",
    "The Prophet Skeram", "Battleguard Sartura", "Fankriss the Unyielding",
    "Princess Huhuran", "Twin Emperors", "C'Thun", 
    "Bug Family", "Viscidus", "Ouro",
    "Anub'Rekhan", "Grand Widow Faerlina", "Maexxna",
    "Noth the Plaguebringer", "Heigan the Unclean", "Loatheb", 
    "Instructor Razuvious", "Gothik the Harvester", "The Four Horsemen",
    "Patchwerk", "Grobbulus", "Gluth", "Thaddius",
    "Sapphiron", "Kel'Thuzad",
    "Bloodlord Mandokir", "Gahz'ranka", "Hakkar", "High Priest Thekal", "High Priest Venoxis", "High Priestess Arlokk",
    "High Priestess Jeklik", "Jin'do the Hexxer", "High Priestess Mar'li", "Edge of Madness",
    "Ayamiss the Hunter", "Buru the Gorger", "General Rajaxx", "Kurinnaxx", "Moam", "Ossirian the Unscarred",
	"Onyxia",
    "Azuregos", "Lord Kazzak", "Emeriss", "Lethon", "Ysondre", "Taerar"
  }

function VanguardRR:OnInitialize()
	-- Called when the addon is loaded
	if (RaidDB == nil) then
		RaidDB = {};
	end
	if (SettingsDB == nil) then
		SettingsDB = {};
		SettingsDB["RaidStarted"]=false
		SettingsDB["RaidMembers"]={}
		SettingsDB["RaidQueue"]={}
		SettingsDB["RaidID"]=0
	end

	self:RegisterChatCommand("vanguard", VanguardRR.VanguardShow);
	-- Print a message to the chat frame
	VanguardRR:Debug("OnInitialize");
	vanguard_loaded = true;
	vanguard_officer = VanguardRR:IsOfficer(UnitName("player"));
end

function VanguardRR:Debug(msg)
	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99VanguardRR|r: "..msg);
	end
end

function VanguardRR:OnEnable()
	-- Called when the addon is enabled
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");


	self:RegisterComm("VRRSTARTRAID", VanguardRR:OnCommReceived())
	self:RegisterComm("VRRENDRAID", VanguardRR:OnCommReceived())
	self:RegisterComm("VRRSTARTLOOT", VanguardRR:OnCommReceived())
	self:RegisterComm("VRRENDLOOT", VanguardRR:OnCommReceived())
	self:RegisterComm("VRRBID", VanguardRR:OnCommReceived())
	self:RegisterComm("VRRAWARDLOOT", VanguardRR:OnCommReceived())

	-- Print a message to the chat frame
	VanguardRR:Debug("OnEnable");
end

function VanguardRR:OnCommReceived(prefix, message, distribution, sender)
	if (prefix and UnitName("player") ~= sender) then
		if VanguardRR:IsOfficer(sender) then		-- validates sender as an officer. fail-safe to prevent addon alterations to manipulate DKP table
			if (prefix == "VRRSTARTRAID") then
				VanguardRR:StartRaid(message)
			elseif (prefix == "VRRENDRAID") then
			elseif (prefix == "VRRSTARTLOOT") then
			elseif (prefix == "VRRENDLOOT") then
			elseif (prefix == "VRRAWARDLOOT") then
			end
		end
	end
end

function VanguardRR:CommSend(prefix, data)
	if IsInGuild() and vanguard_officer then
		VanguardRR:SendCommMessage(prefix, data, "RAID")
	end
end

function VanguardRR:IsOfficer(sender)
	local retVal = false;
	local guildSize,_,_ = GetNumGuildMembers();
	if IsInGuild() then
		for i=1, tonumber(guildSize) do
			name,_,rank,level = GetGuildRosterInfo(i);
			name = strsub(name, 1, string.find(name, "-")-1)
			if name == sender then
				if rank <= 4 then
					retVal = true;
				end
				break;
			end
		end
	end
	return retVal;
end

function VanguardRR:OnDisable()
	-- Called when the addon is disabled
end

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

function VanguardRR:GUILD_ROSTER_UPDATE()
	if vanguard_loaded then
		RaidControl_GuildFrame_Update()
	end
end

function VanguardRR:GROUP_ROSTER_UPDATE()
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

function VanguardRR.VanguardShow()
	if RaidControl:IsVisible() then
		RaidControl:Hide();
	else
		RaidControl:Show();
	end

end

function VanguardRR:StartRaid(RaidID)
	if RaidID == nil then
		RaidID = VanguardRR:GenerateID()
	end
	SettingsDB["RaidID"] = RaidID
	RaidDB[SettingsDB["RaidID"]] = {}
	SettingsDB["RaidMembers"] = VanguardRR:GetRaidRoster()
	players = VanguardRR:GetAllPlayers()
	table.insert(RaidDB[SettingsDB["RaidID"]],{
		["RAID_START"] = {
			["Time"] = date("%m/%d/%y %H:%M:%S"),
			["Players"] = players
		}
	})
	SettingsDB["RaidStarted"] = true;
	VanguardRR:Print("Raid Started!")
end

function VanguardRR:EndRaid()
	SettingsDB["RaidStarted"] = false;
	table.insert(RaidDB[SettingsDB["RaidID"]],{
		["RAID_END"] = {
			["Time"] = date("%m/%d/%y %H:%M:%S")
		}
	})
	VanguardRR:Print("Raid Ended!")
end


function VanguardRR:PlayerInRaid(player)
	local retVal = false;
	local index = VanguardRR:TableSearch(SettingsDB["RaidMembers"],player)
	if index > 0 then
		retVal = true;
	end
	return retVal;
end

function VanguardRR:AddToRaid(player)
	if VanguardRR:TableSearch(SettingsDB["RaidMembers"],player) == 0 then
		table.insert(SettingsDB["RaidMembers"],player)
	end
end

function VanguardRR:RemoveFromRaid(player)
	index = VanguardRR:TableSearch(SettingsDB["RaidMembers"],player)
	if index > 0 then
		table.remove(SettingsDB["RaidMembers"],index)
	end
end

function VanguardRR:PlayerInQueue(player)
	local retVal = false;
	local index = VanguardRR:TableSearch(SettingsDB["RaidQueue"],player)
	if index > 0 then
		retVal = true;
	end
	return retVal;
end

function VanguardRR:AddToQueue(player)
	if not VanguardRR:PlayerInQueue(player) then
		if SettingsDB["RaidStarted"] then
			if not VanguardRR:PlayerInRaid(player) then
				VanguardRR:PlayerJoined(player)
			end
		end
		table.insert(SettingsDB["RaidQueue"],player)
	else
		VanguardRR:Print(player.." already on stand by.")
	end
end

function VanguardRR:RemoveFromQueue(player)
	index = VanguardRR:TableSearch(SettingsDB["RaidQueue"],player)
	if index > 0 then
		if SettingsDB["RaidStarted"] then
			if not VanguardRR:PlayerInRaid(player) then
				VanguardRR:PlayerLeft(player)
			end
		end
		table.remove(SettingsDB["RaidQueue"],index)
		RaidControl_StandbyFrame_Update()
	end
end

function VanguardRR:PlayerJoined(player)
	table.insert(RaidDB[SettingsDB["RaidID"]],
		{
			["RAID_JOIN"] = {
				["Time"] = date("%m/%d/%y %H:%M:%S"),
				["Name"] = player
			}
		} 
	);
end

function VanguardRR:PlayerLeft(player)
	table.insert(RaidDB[SettingsDB["RaidID"]],
		{
			["RAID_LEAVE"] = {
				["Time"] = date("%m/%d/%y %H:%M:%S"),
				["Name"] = player
			}
		} 
	);
end

function VanguardRR:BossKill(bossname)
	local players = VanguardRR:GetAllPlayers()
	table.insert(RaidDB[SettingsDB["RaidID"]],
		{
			["BOSS_KILL"] = {
				["Time"] = date("%m/%d/%y %H:%M:%S"),
				["Name"] = bossname,
				["Players"] = players
			}
		} 
	);
	SendChatMessage("BOSS KILL: "..bossname,"GUILD");
end

function VanguardRR:Loot(lootid,lootname,action,player,amount)
	table.insert(RaidDB[SettingsDB["RaidID"]],
		{
			["LOOT"] = {
				["Time"] = date("%m/%d/%y %H:%M:%S"),
				["ID"] = lootid,
				["Name"] = lootname,
				["Action"] = action,
				["Player"] = player,
				["Amount"] = amount
			}
		} 
	);
end

function VanguardRR:GetAllPlayers()
	allPlayers = {}
	for index, player in pairs(SettingsDB["RaidMembers"]) do
		if VanguardRR:TableSearch(allPlayers,player) == 0 then
			table.insert(allPlayers,player)
		end
	end
	for index, player in pairs(SettingsDB["RaidQueue"]) do
		if VanguardRR:TableSearch(allPlayers,player) == 0 then
			table.insert(allPlayers,player)
		end
	end
	
	return allPlayers;
end

function VanguardRR:GetRaidRoster()
	local players = {}
	
	for i = 1, GetNumGroupMembers() do
		local name, _, subgroup, _, _, _, zone, online, _, _, _ = GetRaidRosterInfo(i)
		table.insert(players,name)
		VanguardRR:RemoveFromQueue(name);
	end
	
	return players
end

function VanguardRR:GetGuildRaiders()
	local raiders = {};
	local guildSize,_,_ = GetNumGuildMembers();
	if IsInGuild() then
		for i=1, tonumber(guildSize) do
			name,_,rank,level = GetGuildRosterInfo(i);
			name = strsub(name, 1, string.find(name, "-")-1)
			table.insert(raiders,name);
		end
	end
	table.sort(raiders);
	return raiders;
end

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