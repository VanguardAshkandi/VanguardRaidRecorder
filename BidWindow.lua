
vanguard_bids = { { ["player"] = "Feyde", ["bid"] = 20 }, { ["player"] = "Depriest", ["bid"] = 30 }, { ["player"] = "Isux", ["bid"] = 15 }, { ["player"] = "Player4", ["bid"] = 55 }, { ["player"] = "Player5", ["bid"] = 45 }, { ["player"] = "Player6", ["bid"] = 35 } }

function BidWindow_BidScroll_Update(selected)
  BidWindow_SortBidTable();
  local bidcount = table.getn(vanguard_bids);
  FauxScrollFrame_Update(BidWindow_BidScroll,bidcount,5,18);
  for line=1,5 do
	offset = FauxScrollFrame_GetOffset(BidWindow_BidScroll);
    lineplusoffset = line + offset;
    if lineplusoffset <= bidcount then
		local player = vanguard_bids[lineplusoffset].player
		local bid = vanguard_bids[lineplusoffset].bid
		local tmpname = string.sub(player.."            ",1,12)
		local tmpbid = string.sub("   "..bid, -3)
		getglobal("BidWindow_BidEntry"..line):SetText(tmpname.." "..tmpbid);
		getglobal("BidWindow_BidEntry"..line).player = player
		getglobal("BidWindow_BidEntry"..line).bid = bid
		getglobal("BidWindow_BidEntry"..line):Show();
		if vanguard_bids[lineplusoffset].player == selected then
			getglobal("BidWindow_BidEntry"..line):SetNormalTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
		else
			getglobal("BidWindow_BidEntry"..line):SetNormalTexture("");
		end 
    else
		getglobal("BidWindow_BidEntry"..line):Hide();
    end
  end
end

function BidWindow_OnLoad()
	--BidWindow_BidScroll:Show()
	--local itemName,_,itemRarity,_,_,_,_,_,_,itemIcon = GetItemInfo(17705)
	--local r, g, b, hex = GetItemQualityColor(itemRarity)
	--BidWindow_itemIcon:SetTexture(itemIcon)
	--BidWindow_itemName:SetText("|c"..hex..itemName.."|r")
	--getglobal("BidWindow_DruidLabel"):SetText(BidWindow_ClassColorize("Druid","Druid"))
	--getglobal("BidWindow_HunterLabel"):SetText(BidWindow_ClassColorize("Hunter","Hunter"))
	--getglobal("BidWindow_MageLabel"):SetText(BidWindow_ClassColorize("Mage","Mage"))
	--getglobal("BidWindow_PriestLabel"):SetText(BidWindow_ClassColorize("Priest","Priest"))
	--getglobal("BidWindow_PaladinLabel"):SetText(BidWindow_ClassColorize("Paladin","Paladin"))
	--getglobal("BidWindow_RogueLabel"):SetText(BidWindow_ClassColorize("Rogue","Rogue"))
	--getglobal("BidWindow_WarlockLabel"):SetText(BidWindow_ClassColorize("Warlock","Warlock"))
	--getglobal("BidWindow_WarriorLabel"):SetText(BidWindow_ClassColorize("Warrior","Warrior"))
end

function BidWindow_ClassColorize(class,text)
	return "|cFF"..vanguard_class_colors[class]..text.."|r"
end

function BidWindow_SortBidTable()
	table.sort(vanguard_bids, function(a, b)
	    	return a["bid"] > b["bid"]
  	end)
end

function BidWindow_BidEntry_OnClick(self)
	BidWindow_BidScroll_Update(self.player)
end