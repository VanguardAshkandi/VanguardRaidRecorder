
VRRRaidControl_Guild_Select = "";
VRRRaidControl_Standby_Select = "";
VRRRaidControl_IsOfficer = false;
VRRRaidControl_Filter = "";

function VRRRaidControl_StandbyFrame_Update(selected)
  local line; -- 1 through 5 of our window to scroll
  local lineplusoffset; -- an index into our data calculated from the scroll offset
  local standbycount = table.getn(SettingsDB["RaidQueue"]);
  FauxScrollFrame_Update(VRRRaidControl_StandbyScroll,standbycount,17,16);
  for line=1,17 do
    lineplusoffset = line + FauxScrollFrame_GetOffset(VRRRaidControl_StandbyScroll);
    if lineplusoffset <= standbycount then
		getglobal("VRRRaidControl_StandByEntry"..line):SetText(SettingsDB["RaidQueue"][lineplusoffset]);
		getglobal("VRRRaidControl_StandByEntry"..line):Show();
		if SettingsDB["RaidQueue"][lineplusoffset] == selected then
			getglobal("VRRRaidControl_StandByEntry"..line):SetNormalTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
		else
			getglobal("VRRRaidControl_StandByEntry"..line):SetNormalTexture("");
		end 
    else
		getglobal("VRRRaidControl_StandByEntry"..line):Hide();
    end
  end
end

function VRRRaidControl_GuildFrame_Update(selected)
	local line; -- 1 through 5 of our window to scroll
	local lineplusoffset; -- an index into our data calculated from the scroll offset
	local initraiders = VanguardRR:GetGuildRaiders();
	if VRRRaidControl_Filter ~= "" then
		raiders = {};
		for index, value in pairs(initraiders) do
			if string.find(string.upper(value),string.upper(VRRRaidControl_Filter)) ~= nil then
				table.insert(raiders,value)
			end
		end
		table.sort(raiders);
	else
		raiders = initraiders;
	end
	local raidercount = table.getn(raiders);
	FauxScrollFrame_Update(VRRRaidControl_GuildScroll,raidercount,17,16);
	for line=1,17 do
		lineplusoffset = line + FauxScrollFrame_GetOffset(VRRRaidControl_GuildScroll);
		if lineplusoffset <= raidercount then
			getglobal("VRRRaidControl_GuildEntry"..line):SetText(raiders[lineplusoffset]);
			getglobal("VRRRaidControl_GuildEntry"..line):Show();
			if raiders[lineplusoffset] == selected then
				getglobal("VRRRaidControl_GuildEntry"..line):SetNormalTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
			else
				getglobal("VRRRaidControl_GuildEntry"..line):SetNormalTexture("");
			end 
		else
			getglobal("VRRRaidControl_GuildEntry"..line):Hide();
		end
	end
end

function VRRRaidControl_GuildEntry_OnClick(self)
	if VRRRaidControl_IsOfficer then
		VRRRaidControl_Guild_Select = self:GetText()
		VRRRaidControl_GuildFrame_Update(VRRRaidControl_Guild_Select)
		VRRRaidControl_AddStandby:SetEnabled(true)
	end
end

function VRRRaidControl_StandbyEntry_OnClick(self)
	if VRRRaidControl_IsOfficer then
		VRRRaidControl_Standby_Select = self:GetText()
		VRRRaidControl_StandbyFrame_Update(VRRRaidControl_Standby_Select)
		VRRRaidControl_RemoveStandby:SetEnabled(true)
	end
end

function VRRRaidControl_RemoveFromStandBy(player)
	VanguardRR:RemoveFromQueue(player)
	VRRRaidControl_Standby_Select = ""
	VRRRaidControl_RemoveStandby:SetEnabled(false)
	VRRRaidControl_StandbyFrame_Update()
	VanguardRR:CommSend("VRRREMOVESTANDBY", player)
end

function VRRRaidControl_AddToStandBy(player)
	VanguardRR:AddToQueue(player)
	VRRRaidControl_Guild_Select = ""
	VRRRaidControl_AddStandby:SetEnabled(false)
	VRRRaidControl_GuildFrame_Update()
	VRRRaidControl_StandbyFrame_Update()
	VanguardRR:CommSend("VRRADDSTANDBY", player)
end

function VRRRaidControl_StartRaid()
	if not SettingsDB["RaidStarted"] then
		VanguardRR:StartRaid(nil,VRRRaidControl_LootRaid:GetChecked())
	else
		VanguardRR:Print("Raid already started.")
	end
	VRRRaidControl_OnShow()
end

function VRRRaidControl_EndRaid()
	if SettingsDB["RaidStarted"] then
		StaticPopupDialogs["VRR_ENDRAID"] = {
			text = "Ending a raid will stop all officers from recording.\n\nAre you sure you wish to end this raid?",
			button1 = "Yes",
			button2 = "No",
			OnAccept = function()
			VanguardRR:EndRaid()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show ("VRR_ENDRAID")
	else
		VanguardRR:Print("No raid started.")
	end
end

function VRRRaidControl_OnLoad()
	VRRRaidControl_GuildScroll:Show()
	VRRRaidControl_StandbyScroll:Show()
end

function VRRRaidControl_OnShow()
	VRRRaidControl_StartButton:SetEnabled(false)
	VRRRaidControl_EndButton:SetEnabled(false)
	VRRRaidControl_BidManagerButton:SetEnabled(false)
	VRRRaidControl_AddStandby:SetEnabled(false)
	VRRRaidControl_RemoveStandby:SetEnabled(false)
	VRRRaidControl_LootRaid:SetChecked(false)
	VRRRaidControl_LootRaid:SetEnabled(false)

	VRRRaidControl_IsOfficer = VanguardRR:IsOfficer(UnitName("player"))

	if VRRRaidControl_IsOfficer then
		if SettingsDB["RaidStarted"] then
			if SettingsDB["LootRaid"] then
				VRRRaidControl_LootRaid:SetChecked(true)
			end
			VRRRaidControl_StartButton:SetEnabled(false)
			VRRRaidControl_EndButton:SetEnabled(true)
			VRRRaidControl_BidManagerButton:SetEnabled(true)
		else
			VRRRaidControl_StartButton:SetEnabled(true)
			VRRRaidControl_EndButton:SetEnabled(false)
			VRRRaidControl_BidManagerButton:SetEnabled(false)
			VRRRaidControl_LootRaid:SetEnabled(true)
		end
	end
end

function VRRRaidControl_TextChanged(editbox)
	local curText = editbox:GetText();
	VRRRaidControl_Filter = strtrim(curText);
	VRRRaidControl_GuildFrame_Update()
end