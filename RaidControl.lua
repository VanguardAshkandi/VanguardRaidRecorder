
RaidControl_Guild_Select = "";
RaidControl_Standby_Select = "";

function RaidControl_StandbyFrame_Update(selected)
  local line; -- 1 through 5 of our window to scroll
  local lineplusoffset; -- an index into our data calculated from the scroll offset
  local standbycount = table.getn(vanguard_raid_queue);
  FauxScrollFrame_Update(RaidControl_StandbyScroll,standbycount,17,16);
  for line=1,17 do
    lineplusoffset = line + FauxScrollFrame_GetOffset(RaidControl_StandbyScroll);
    if lineplusoffset <= standbycount then
		getglobal("RaidControl_StandByEntry"..line):SetText(vanguard_raid_queue[lineplusoffset]);
		getglobal("RaidControl_StandByEntry"..line):Show();
		if vanguard_raid_queue[lineplusoffset] == selected then
			getglobal("RaidControl_StandByEntry"..line):SetNormalTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
		else
			getglobal("RaidControl_StandByEntry"..line):SetNormalTexture("");
		end 
    else
		getglobal("RaidControl_StandByEntry"..line):Hide();
    end
  end
end

function RaidControl_GuildFrame_Update(selected)
  local line; -- 1 through 5 of our window to scroll
  local lineplusoffset; -- an index into our data calculated from the scroll offset
  local raiders = VanguardDKP:GetGuildRaiders();
  local raidercount = table.getn(raiders);
  FauxScrollFrame_Update(RaidControl_GuildScroll,raidercount,17,16);
  for line=1,17 do
    lineplusoffset = line + FauxScrollFrame_GetOffset(RaidControl_GuildScroll);
    if lineplusoffset <= raidercount then
		getglobal("RaidControl_GuildEntry"..line):SetText(raiders[lineplusoffset]);
		getglobal("RaidControl_GuildEntry"..line):Show();
		if raiders[lineplusoffset] == selected then
			getglobal("RaidControl_GuildEntry"..line):SetNormalTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
		else
			getglobal("RaidControl_GuildEntry"..line):SetNormalTexture("");
		end 
    else
		getglobal("RaidControl_GuildEntry"..line):Hide();
    end
  end
end

function RaidControl_GuildEntry_OnClick(self)
	RaidControl_Guild_Select = self:GetText()
	RaidControl_GuildFrame_Update(RaidControl_Guild_Select)
	RaidControl_AddStandby:SetEnabled(true)
end

function RaidControl_StandbyEntry_OnClick(self)
	RaidControl_Standby_Select = self:GetText()
	RaidControl_StandbyFrame_Update(RaidControl_Standby_Select)
	RaidControl_RemoveStandby:SetEnabled(true)
end

function RaidControl_RemoveFromStandBy(selected)
	VanguardDKP:RemoveFromQueue(selected)
	RaidControl_Standby_Select = ""
	RaidControl_RemoveStandby:SetEnabled(false)
	RaidControl_StandbyFrame_Update()
end

function RaidControl_AddToStandBy(selected)
	VanguardDKP:AddToQueue(selected)
	RaidControl_Guild_Select = ""
	RaidControl_AddStandby:SetEnabled(false)
	RaidControl_GuildFrame_Update()
	RaidControl_StandbyFrame_Update()
end

function RaidControl_StartRaid()
	if not vanguard_raid_started then
		VanguardDKP:StartRaid()
	else
		VanguardDKP:Print("Raid already started.")
	end
end

function RaidControl_EndRaid()
	if vanguard_raid_started then
		VanguardDKP:EndRaid()
	else
		VanguardDKP:Print("No raid started.")
	end
end

function RaidControl_OnLoad()
	RaidControl_AddStandby:SetEnabled(false)
	RaidControl_RemoveStandby:SetEnabled(false)
	RaidControl_GuildScroll:Show()
	RaidControl_StandbyScroll:Show()
end