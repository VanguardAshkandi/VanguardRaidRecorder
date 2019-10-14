local VRRBidWindow_ItemLink = "";
local VRRBidWindow_Minimum = 150;
local VRRBidWindow_EndTimer = 30;

function VRRBidWindow_StartBid()
	local START = 0
	local END = VRRBidWindow_EndTimer

	VRRBidWindow_Timer:SetBackdrop({bgFile = [[Interface\ChatFrame\ChatFrameBackground]]})
	VRRBidWindow_Timer:SetBackdropColor(0, 0, 0, 0.7)
	VRRBidWindow_Timer:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
	VRRBidWindow_Timer:SetStatusBarColor(0, 0.5, 1)

	VRRBidWindow_Timer:SetMinMaxValues(START, END)
	VRRBidWindow_Timer:SetValue(END)
	VRRBidWindow_Timer:Show();

	local timer = 0

	-- this function will run repeatedly, incrementing the value of timer as it goes
	VRRBidWindow_Timer:SetScript("OnUpdate", function(self, elapsed)
		timer = timer + elapsed
		VRRBidWindow_Timer:SetValue(END-timer)
		-- when timer has reached the desired value, as defined by global END (seconds), restart it by setting it to 0, as defined by global START
		if timer >= END then
			VRRBidWindow_EndBid()
		end
	end)
end

function VRRBidWindow_EndBid()
	VRRBidWindow_BidButton:SetEnabled(false);
	VRRBidWindow_Timer:SetScript("OnUpdate",nil);
	VRRBidWindow:Hide();
end

function VRRBidWindow_ShowWindow(loot_id,min_bid,timer)
	VRRBidWindow_Minimum = tonumber(min_bid)
	VRRBidWindow_EndTimer = timer
	local itemName,itemLink,itemRarity,_,_,_,_,_,_,itemIcon = GetItemInfo(loot_id)
	VRRBidWindow_ItemLink = itemLink;
	local r, g, b, hex = GetItemQualityColor(itemRarity)
	VRRBidWindow_itemIcon:SetNormalTexture(itemIcon)
	VRRBidWindow_itemName:SetText("|c"..hex..itemName.."|r")
	VRRBidWindow_MinBid:SetText("Minimum: "..min_bid)
	VRRBidWindow_BidButton:SetEnabled(true);
	VRRBidWindow_BidAmount:SetText("")
	VRRBidWindow:Show()
	VRRBidWindow_StartBid()
end

function VRRBidWindow_SubmitBid()
	local bidAmount = VRRBidWindow_BidAmount:GetText()
	bidAmount = tonumber(bidAmount)
	if bidAmount == nil then
		VanguardRR:Print("|cFFFF0000Invalid bid amount!|r")
	elseif bidAmount < VRRBidWindow_Minimum then
		VanguardRR:Print("|cFFFF0000Bid does not meet the minimum!|r")
	else
		VRRBidWindow_BidButton:SetEnabled(false);
		VRRBidWindow_Timer:SetScript("OnUpdate",nil);
		VRRBidWindow:Hide();
		VanguardRR:CommSend("VRRBID",bidAmount)
		VanguardRR:Print("Bid submitted!")
	end
end

function VRRBidWindow_OnEnter()
	GameTooltip:SetOwner(VRRBidWindow_itemIcon)
	GameTooltip:SetPoint("TOPLEFT")
	GameTooltip:SetHyperlink(VRRBidWindow_ItemLink);
	GameTooltip:Show();
end

function VRRBidWindow_OnLeave()
	GameTooltip:Hide()
end

