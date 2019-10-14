VanguardRR = LibStub("AceAddon-3.0"):NewAddon("Vanguard Raid Recorder", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0" );

vanguard_loaded = false;
vanguard_debug = true;

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
	"Winter Wolf", "Large Crag Boar",
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

	self:RegisterChatCommand("vrr", VanguardRR.VanguardShow);
	-- Print a message to the chat frame
	vanguard_loaded = true;
end

function VanguardRR:OnEnable()
	-- Called when the addon is enabled
	VanguardRR:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	VanguardRR:RegisterEvent("CHAT_MSG_MONSTER_YELL");
	VanguardRR:RegisterEvent("GROUP_ROSTER_UPDATE");
	VanguardRR:RegisterEvent("LOOT_OPENED");

	hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", VanguardRR_ContainerClick)

	VanguardRR:RegisterComm("VRRSTARTRAID", "Comm_Start_Raid")
	VanguardRR:RegisterComm("VRRENDRAID", "Comm_End_Raid")
	VanguardRR:RegisterComm("VRRSTARTLOOT", "Comm_Start_Loot")
	VanguardRR:RegisterComm("VRRENDLOOT", "Comm_End_Loot")
	VanguardRR:RegisterComm("VRRBID", "Comm_Bid")
	VanguardRR:RegisterComm("VRRAWARDLOOT","Comm_Award_Loot")
	VanguardRR:RegisterComm("VRRADDSTANDBY", "Comm_Add_Standby")
	VanguardRR:RegisterComm("VRRREMOVESTANDBY", "Comm_Remove_Standby")
	VanguardRR:RegisterComm("VRRSENDRAID", "Comm_Send_Raid")
	VanguardRR:RegisterComm("VRR"..string.upper(UnitName("player")), "Comm_Receive_Raid")

	-- Print a message to the chat frame
	VanguardRR:Print("Enabled.");
end

function VanguardRR:OnDisable()
	-- Called when the addon is disabled
	VanguardRR:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	VanguardRR:UnregisterEvent("CHAT_MSG_MONSTER_YELL");
	VanguardRR:UnregisterEvent("GROUP_ROSTER_UPDATE");
	VanguardRR:UnregisterEvent("LOOT_OPENED");

	VanguardRR:UnregisterComm("VRRSTARTRAID")
	VanguardRR:UnregisterComm("VRRENDRAID")
	VanguardRR:UnregisterComm("VRRSTARTLOOT")
	VanguardRR:UnregisterComm("VRRENDLOOT")
	VanguardRR:UnregisterComm("VRRBID")
	VanguardRR:UnregisterComm("VRRAWARDLOOT")
	VanguardRR:UnregisterComm("VRRADDSTANDBY")
	VanguardRR:UnregisterComm("VRRREMOVESTANDBY")
	VanguardRR:RegisterComm("VRRSENDRAID")
	VanguardRR:RegisterComm("VRR"..string.upper(UnitName("player")))

end

function VanguardRR.VanguardShow()
	if VRRRaidControl:IsVisible() then
		VRRRaidControl:Hide();
	else
		VRRRaidControl:Show();
	end
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
		VRRRaidControl_StandbyFrame_Update()
	end
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
	local raidLeader = "";

	for i = 1, GetNumGroupMembers() do
		local name, rank, subgroup, _, _, _, zone, online, _, _, _ = GetRaidRosterInfo(i)
		if rank == 2 then
			raidLeader = name
		end
		table.insert(players,name)
		VanguardRR:RemoveFromQueue(name);
	end
	
	return players, raidLeader
end

function VanguardRR_ContainerClick(self, button)
	if VanguardRR:IsOfficer(UnitName("player")) then
		if SettingsDB["RaidStarted"] then
			if (button == "RightButton" and IsControlKeyDown() and IsAltKeyDown()) then
				local slot, bag = GetMouseFocus():GetID(), GetMouseFocus():GetParent():GetID()
				local texture, count, locked, quality, readable, lootable, link = GetContainerItemInfo(bag, slot)
				if (link ~= nil) then
					VRRBidManager_SetItem(link)
					VRRBidManager:Show();
				end
				return
			end
		end
	end
end

function VanguardRR:LootWindowHook()			-- hook function into LootFrame window (BREAKS if more than 4 loot slots... trying to fix)
	local num = GetNumLootItems();
	
	if getglobal("ElvLootSlot1") then 			-- fixes hook for ElvUI loot frame
		for i = 1, num do 
			getglobal("ElvLootSlot"..i):HookScript("OnClick", function(self, button)
			if (button == "RightButton" and IsControlKeyDown() and IsAltKeyDown()) then
	        		itemLink = GetLootSlotLink(i)
					if itemLink ~= nil then
						VRRBidManager_SetItem(itemLink)
						VRRBidManager:Show();
					end
		        end
			end)
		end
	else
		if num > 4 then num = 4 end

		for i = 1, num do 
			getglobal("LootButton"..i):HookScript("OnClick", function(self, button)
			if (button == "RightButton" and IsControlKeyDown() and IsAltKeyDown()) then
	        		itemLink = GetLootSlotLink(i)
					if itemLink ~= nil then
						VRRBidManager_SetItem(itemLink)
						VRRBidManager:Show();
					end
		        end
			end)
		end
	end
end


