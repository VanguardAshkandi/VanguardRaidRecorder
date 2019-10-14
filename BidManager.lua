
local vanguard_bids = {}
local loot_id = 0;
local classes = {};
local bid_timer = 30;
local selected_player = "";
local selected_bid = 0;
local inBid = false;

function VRRBidManager_BidScroll_Update(selected)
	if inBid then
		selected = ""
	end

	VRRBidManager_SortBidTable();
	local bidcount = table.getn(vanguard_bids);
	FauxScrollFrame_Update(VRRBidManager_BidScroll,bidcount,5,18);
	for line=1,5 do
		offset = FauxScrollFrame_GetOffset(VRRBidManager_BidScroll);
		lineplusoffset = line + offset;
		if lineplusoffset <= bidcount then
			local player = vanguard_bids[lineplusoffset].player
			local bid = vanguard_bids[lineplusoffset].bid
			local tmpname = string.sub(player.."            ",1,12)
			local tmpbid = string.sub("   "..bid, -3)
			getglobal("VRRBidManager_BidEntry"..line):SetText(tmpname.." "..tmpbid);
			getglobal("VRRBidManager_BidEntry"..line):Show();
			if player == selected then
				selected_player = player
				selected_bid = bid
				getglobal("VRRBidManager_BidEntry"..line):SetNormalTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
			else
				getglobal("VRRBidManager_BidEntry"..line):SetNormalTexture("");
			end 
		else
			getglobal("VRRBidManager_BidEntry"..line):Hide();
		end
	end
end

function VRRBidManager_AddBid(player,amount)
	local newBid = true;
    for index, value in pairs(vanguard_bids) do
        if vanguard_bids[index]["player"] == player then
            newBid = false;
			break;
        end
    end
	if newBid then
		table.insert(vanguard_bids, { ["player"] = player, ["bid"] = amount } )
		VRRBidManager_BidScroll_Update()
	end
end

function VRRBidManager_Class_OnClick(button)
	local className = button.class
	if button:GetChecked() then
		table.insert(classes,className)
	else
		local index = VanguardRR:TableSearch(classes,className)
		if index > 0 then
			table.remove(classes,index)
		end
	end
end

function VRRBidManager_SetItem(item_link)
	loot_id = select(3, strfind(item_link, "item:(%d+)"))
	local itemName,itemLink_,itemRarity,_,_,_,_,_,_,itemIcon = GetItemInfo(loot_id)
	local r, g, b, hex = GetItemQualityColor(itemRarity)
	VRRBidManager_itemIcon:SetTexture(itemIcon)
	VRRBidManager_itemName:SetText("|c"..hex..itemName.."|r")
	VRRBidManager_StartBidButton:SetEnabled(true)
	VRRBidManager_ShardButton:SetEnabled(true)
	VRRBidManager_BankButton:SetEnabled(true)
end

function VRRBidManager_OnShow()

	if loot_id == 0 then
		VRRBidManager_itemIcon:SetTexture(0,0,0,1)
		VRRBidManager_itemName:SetText("")
		VRRBidManager_StartBidButton:SetEnabled(false)
		VRRBidManager_AwardLoot:SetEnabled(false)
		VRRBidManager_ShardButton:SetEnabled(false)
		VRRBidManager_BankButton:SetEnabled(false)
	end	

	getglobal("VRRBidManager_Druid"):SetChecked()
	getglobal("VRRBidManager_Hunter"):SetChecked()
	getglobal("VRRBidManager_Mage"):SetChecked()
	getglobal("VRRBidManager_Priest"):SetChecked()
	getglobal("VRRBidManager_Paladin"):SetChecked()
	getglobal("VRRBidManager_Rogue"):SetChecked()
	getglobal("VRRBidManager_Warlock"):SetChecked()
	getglobal("VRRBidManager_Warrior"):SetChecked()
	VRRBidManager_BidScroll_Update()
end

function VRRBidManager_OnLoad()
	VRRBidManager_LoadClass("Druid")
	VRRBidManager_LoadClass("Hunter")
	VRRBidManager_LoadClass("Mage")
	VRRBidManager_LoadClass("Priest")
	VRRBidManager_LoadClass("Paladin")
	VRRBidManager_LoadClass("Rogue")
	VRRBidManager_LoadClass("Warlock")
	VRRBidManager_LoadClass("Warrior")
	VRRBidManager_MinBidValue:SetText("40")
	VRRBidManager_AwardLoot:SetEnabled(false)
end

function VRRBidManager_LoadClass(className)
	local button = getglobal("VRRBidManager_"..className)
	button.class = className
	local buttonlabel = getglobal("VRRBidManager_"..className.."Label")
	buttonlabel:SetText(VRRBidManager_ClassColorize(className,className))
end

function VRRBidManager_ClassColorize(class,text)
	return "|cFF"..vanguard_class_colors[class]..text.."|r"
end

function VRRBidManager_SortBidTable()
	table.sort(vanguard_bids, function(a, b)
	    	return a["bid"] > b["bid"]
  	end)
end

function VRRBidManager_BidEntry_OnClick(self)
	local player = strsub(self:GetText(),1,12);
	player = strtrim(player);
	VRRBidManager_BidScroll_Update(player)
end

function VRRBidManager_Bidding(button)
	if button:GetText() == "Start Bidding" then
		inBid = true;
		VRRBidManager_AwardLoot:SetEnabled(false)
		VRRBidManager_ShardButton:SetEnabled(false)
		VRRBidManager_BankButton:SetEnabled(false)
		vanguard_bids = {}
		VRRBidManager_BidScroll_Update()
		local commdata = {}
		table.insert(commdata,loot_id)
		table.insert(commdata,VRRBidManager_MinBidValue:GetText())
		table.insert(commdata,bid_timer)
		if table.getn(classes) == 0 then
			table.insert(commdata,"")
		else
			table.insert(commdata,classes)
		end
		VanguardRR:CommSend("VRRSTARTLOOT", commdata)
		button:SetText("Stop Bidding")
		VRRBidWindow_StartTimer()
	else
		VRRBidWindow_EndTimer()
	end
end

function VRRBidManager_OnValueChanged(slider)
	bid_timer = VanguardRR:RoundMultiple(slider:GetValue(),15)
	VRRBidManager_TimerLabel:SetText(bid_timer)
	slider:SetValue(bid_timer)
end

function VRRBidWindow_StartTimer()
	local START = 0
	local END = bid_timer+5

	VRRBidManager_TimerBar:SetBackdrop({bgFile = [[Interface\ChatFrame\ChatFrameBackground]]})
	VRRBidManager_TimerBar:SetBackdropColor(0, 0, 0, 0.7)
	VRRBidManager_TimerBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
	VRRBidManager_TimerBar:SetStatusBarColor(0, 0.5, 1)

	VRRBidManager_TimerBar:SetMinMaxValues(START, END)
	VRRBidManager_TimerBar:SetValue(END)
	VRRBidManager_TimerBar:Show();

	local timer = 0

	-- this function will run repeatedly, incrementing the value of timer as it goes
	VRRBidManager_TimerBar:SetScript("OnUpdate", function(self, elapsed)
		timer = timer + elapsed
		VRRBidManager_TimerBar:SetValue(END-timer)
		-- when timer has reached the desired value, as defined by global END (seconds), restart it by setting it to 0, as defined by global START
		if timer >= END then
			VRRBidWindow_EndTimer()
		end
	end)
end

function VRRBidWindow_EndTimer()
	VRRBidManager_TimerBar:SetScript("OnUpdate",nil);
	VRRBidManager_TimerBar:Hide();
	VanguardRR:CommSend("VRRENDLOOT", "nil")
	VRRBidManager_StartBidButton:SetText("Start Bidding")
	if table.getn(vanguard_bids) > 0 then
		VRRBidManager_AwardLoot:SetEnabled(true)
	else
		VRRBidManager_ShardButton:SetEnabled(true)
		VRRBidManager_BankButton:SetEnabled(true)
	end
	inBid = false;
end

function VRRBidManager_CloseButton_OnClick()
	if inBid then
		VRRBidWindow_EndTimer()
	else
		VRRBidManager_TimerBar:SetScript("OnUpdate",nil);
	end
	vanguard_bids = {};
	VRRBidManager_BidScroll_Update();
	loot_id = 0;
	VRRBidManager:Hide();
end

function VRRBidManager_ShardButton_OnClick()
	StaticPopupDialogs["VRR_SHARDPROMPT"] = {
		text = "Are you sure you wish to SHARD this loot?",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
		VRRBidManager_Shard()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
	StaticPopup_Show ("VRR_SHARDPROMPT")
	
end

function VRRBidManager_Shard()
	VanguardRR:Loot(loot_id,"SHARD","",0)
	VRRBidManager:Hide()
end

function VRRBidManager_Bank()
	VanguardRR:Loot(loot_id,"BANK","",0)
	VRRBidManager:Hide()
end

function VRRBidManager_BankButton_OnClick()
	StaticPopupDialogs["VRR_BANKPROMPT"] = {
		text = "Are you sure you wish to BANK this loot?",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
		VRRBidManager_Bank()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
	StaticPopup_Show ("VRR_BANKPROMPT")
end

function VRRBidWindow_AwardLoot()
	VanguardRR:Loot(loot_id,"AWARD",selected_player,selected_bid)
end
