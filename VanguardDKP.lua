VanguardDKP = LibStub("AceAddon-3.0"):NewAddon("VanguardDKP", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0" );

vanguard_loaded = false;
vanguard_raid_started = false;
vanguard_raid_members = {};
vanguard_raid_queue = {};
vanguard_officer = false;
vanguard_raid_index = 0;

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

function VanguardDKP:OnInitialize()
	-- Called when the addon is loaded
	if (RaidDB == nil) then
		RaidDB = {};
	end
	self:RegisterChatCommand("vanguard", VanguardDKP.VanguardShow);
	-- Print a message to the chat frame
	VanguardDKP:Debug("OnInitialize");
	vanguard_loaded = true;
	vanguard_officer = VanguardDKP:IsOfficer(UnitName("player"));
end

function VanguardDKP:Debug(msg)
	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99VanguardDKP|r: "..msg);
	end
end

function VanguardDKP:OnEnable()
	-- Called when the addon is enabled
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");


	self:RegisterComm("VRRSTARTRAID", VanguardDKP:OnCommReceived())
	self:RegisterComm("VRRENDRAID", VanguardDKP:OnCommReceived())
	self:RegisterComm("VRRSTARTLOOT", VanguardDKP:OnCommReceived())
	self:RegisterComm("VRRENDLOOT", VanguardDKP:OnCommReceived())
	self:RegisterComm("VRRBID", VanguardDKP:OnCommReceived())
	self:RegisterComm("VRRAWARDLOOT", VanguardDKP:OnCommReceived())

	-- Print a message to the chat frame
	VanguardDKP:Debug("OnEnable");
end

function VanguardDKP:OnCommReceived(prefix, message, distribution, sender)
	if (prefix and UnitName("player") ~= sender) then
		if VanguardDKP:IsOfficer(sender) then		-- validates sender as an officer. fail-safe to prevent addon alterations to manipulate DKP table
			if (prefix == "VRRSTARTRAID") then
				VanguardDKP:StartRaid(message)
			elseif (prefix == "VRRENDRAID") then
			elseif (prefix == "VRRSTARTLOOT") then
			elseif (prefix == "VRRENDLOOT") then
			elseif (prefix == "VRRAWARDLOOT") then
			end
		end
	end
end

function VanguardDKP:CommSend(prefix, data)
	if IsInGuild() and vanguard_officer then
		VanguardDKP:SendCommMessage(prefix, data, "RAID")
	end
end

function VanguardDKP:IsOfficer(sender)
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

function VanguardDKP:OnDisable()
	-- Called when the addon is disabled
end

function VanguardDKP:COMBAT_LOG_EVENT_UNFILTERED(event)
	if not vanguard_raid_started then
		return;
	end
   local timestamp, eventType, hideCaster,
   srcGUID, srcName, srcFlags, srcFlags2,
   dstGUID, dstName, dstFlags, dstFlags2,
   spellID, spellName, arg3, arg4, arg5 = CombatLogGetCurrentEventInfo()
	
   local isSrcPlayer = bit.band(srcFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
	
	if eventType == "UNIT_DIED" then
		if VanguardDKP:TableSearch(vanguard_boss_list,dstName) > 0 then
			VanguardDKP:BossKill(dstName);
		end
	end
end

function VanguardDKP:CHAT_MSG_MONSTER_YELL(event, msg, name)
	if not vanguard_raid_started then
		return;
	end
	if msg == "Impossible! Stay your attack, mortals... I submit! I submit!"  then
		VanguardDKP:BossKill("Majordomo Executus");
	end
end

function VanguardDKP:GUILD_ROSTER_UPDATE()
	if vanguard_loaded then
		RaidControl_GuildFrame_Update()
	end
end

function VanguardDKP:GROUP_ROSTER_UPDATE()
	local roster = VanguardDKP:GetRaidRoster()

	if vanguard_raid_started then
		for index, player in pairs(roster) do
			if not VanguardDKP:PlayerInRaid(player) and not VanguardDKP:PlayerInQueue(player) then
				VanguardDKP:AddToRaid(player)
				VanguardDKP:PlayerJoined(player)
			elseif VanguardDKP:PlayerInQueue(player) then
				VanguardDKP:AddToRaid(player)
				VanguardDKP:RemoveFromQueue(player)
			end
		end
		for index, player in pairs(vanguard_raid_members) do
			if not VanguardDKP:PlayerInQueue(player) then
				if VanguardDKP:TableSearch(roster,player) == 0 then
					VanguardDKP:RemoveFromRaid(player)
					VanguardDKP:PlayerLeft(player)
				end
			end
		end
	else
		for index, player in pairs(roster) do
			VanguardDKP:RemoveFromQueue(player)
		end
		for index, player in pairs(vanguard_raid_queue) do
			if VanguardDKP:TableSearch(roster,player) == 0 then
				VanguardDKP:RemoveFromQueue(player)
			end
		end
	end
end

function VanguardDKP.VanguardShow()
	if RaidControl:IsVisible() then
		RaidControl:Hide();
	else
		RaidControl:Show();
	end

end

function VanguardDKP:StartRaid(RaidID)
	if RaidID == nil then
		RaidID = VanguardDKP:GenerateID()
	end
	vanguard_raid_id = RaidID
	table.insert(RaidDB,{[vanguard_raid_id] = {}})
	vanguard_raid_index = table.getn(RaidDB)
	vanguard_raid_members = VanguardDKP:GetRaidRoster()
	players = VanguardDKP:GetAllPlayers()
	table.insert(RaidDB[vanguard_raid_index][vanguard_raid_id],
		{
			["RAID_START"] = {
				["Time"] = date("%m/%d/%y %H:%M:%S"),
				["Players"] = players
			}
		} 
	);
	vanguard_raid_started = true;
	VanguardDKP:Print("Raid Started!")
end

function VanguardDKP:EndRaid()
	vanguard_raid_started = false;
	table.insert(RaidDB[vanguard_raid_index][vanguard_raid_id],
		{
			["RAID_END"] = {
				["Time"] = date("%m/%d/%y %H:%M:%S")
			}
		} 
	);
	VanguardDKP:Print("Raid Ended!")
end


function VanguardDKP:PlayerInRaid(player)
	local retVal = false;
	local index = VanguardDKP:TableSearch(vanguard_raid_members,player)
	if index > 0 then
		retVal = true;
	end
	return retVal;
end

function VanguardDKP:AddToRaid(player)
	if VanguardDKP:TableSearch(vanguard_raid_members,player) == 0 then
		table.insert(vanguard_raid_members,player)
	end
end

function VanguardDKP:RemoveFromRaid(player)
	index = VanguardDKP:TableSearch(vanguard_raid_members,player)
	if index > 0 then
		table.remove(vanguard_raid_members,index)
	end
end

function VanguardDKP:PlayerInQueue(player)
	local retVal = false;
	local index = VanguardDKP:TableSearch(vanguard_raid_queue,player)
	if index > 0 then
		retVal = true;
	end
	return retVal;
end

function VanguardDKP:AddToQueue(player)
	if not VanguardDKP:PlayerInQueue(player) then
		if vanguard_raid_started then
			if not VanguardDKP:PlayerInRaid(player) then
				VanguardDKP:PlayerJoined(player)
			end
		end
		table.insert(vanguard_raid_queue,player)
	else
		VanguardDKP:Print(player.." already on stand by.")
	end
end

function VanguardDKP:RemoveFromQueue(player)
	index = VanguardDKP:TableSearch(vanguard_raid_queue,player)
	if index > 0 then
		if vanguard_raid_started then
			if not VanguardDKP:PlayerInRaid(player) then
				VanguardDKP:PlayerLeft(player)
			end
		end
		table.remove(vanguard_raid_queue,index)
		RaidControl_StandbyFrame_Update()
	end
end

function VanguardDKP:PlayerJoined(player)
	table.insert(RaidDB[vanguard_raid_index][vanguard_raid_id],
		{
			["RAID_JOIN"] = {
				["Time"] = date("%m/%d/%y %H:%M:%S"),
				["Name"] = player
			}
		} 
	);
end

function VanguardDKP:PlayerLeft(player)
	table.insert(RaidDB[vanguard_raid_index][vanguard_raid_id],
		{
			["RAID_LEAVE"] = {
				["Time"] = date("%m/%d/%y %H:%M:%S"),
				["Name"] = player
			}
		} 
	);
end

function VanguardDKP:BossKill(bossname)
	local players = VanguardDKP:GetAllPlayers()
	table.insert(RaidDB[vanguard_raid_index][vanguard_raid_id],
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

function VanguardDKP:Loot(lootid,lootname,action,player,amount)
	table.insert(RaidDB[vanguard_raid_id][vanguard_raid_id],
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

function VanguardDKP:GetAllPlayers()
	allPlayers = {}
	for index, player in pairs(vanguard_raid_members) do
		if VanguardDKP:TableSearch(allPlayers,player) == 0 then
			table.insert(allPlayers,player)
		end
	end
	for index, player in pairs(vanguard_raid_queue) do
		if VanguardDKP:TableSearch(allPlayers,player) == 0 then
			table.insert(allPlayers,player)
		end
	end
	
	return allPlayers;
end

function VanguardDKP:GetRaidRoster()
	local players = {}
	
	for i = 1, GetNumGroupMembers() do
		local name, _, subgroup, _, _, _, zone, online, _, _, _ = GetRaidRosterInfo(i)
		table.insert(players,name)
		VanguardDKP:RemoveFromQueue(name);
	end
	
	return players
end

function VanguardDKP:GetGuildRaiders()
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

function VanguardDKP:TableSearch(tab,el)
	retVal = 0;
    for index, value in pairs(tab) do
        if value == el then
            retVal = index;
			break;
        end
    end
	return retVal;
end

function VanguardDKP:GenerateID()
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