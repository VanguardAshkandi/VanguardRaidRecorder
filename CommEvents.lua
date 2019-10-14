
local LibCompress = LibStub:GetLibrary("LibCompress")
local LibCompressAddonEncodeTable = LibCompress:GetAddonEncodeTable()


function VanguardRR:Comm_Start_Raid(prefix, message, distribution, sender)
	if (prefix and UnitName("player") ~= sender) then
		local isOfficer = VanguardRR:IsOfficer(sender)
		local success,decoded,deserialized = VanguardRR:DecodeMessage(message)
		if success then
			VanguardRR:Debug(prefix..":"..decoded..":"..sender.."("..tostring(isOfficer)..")")
			if isOfficer then
				VanguardRR:StartRaid(deserialized,sender)
			end
		else
			VanguardRR:Debug("Prefix:"..prefix..":Decode FAILED!")
		end
	end
end

function VanguardRR:Comm_End_Raid(prefix, message, distribution, sender)
	if (prefix and UnitName("player") ~= sender) then
		local isOfficer = VanguardRR:IsOfficer(sender)
		local success,decoded,deserialized = VanguardRR:DecodeMessage(message)
		if success then
			VanguardRR:Debug(prefix..":"..decoded..":"..sender.."("..tostring(isOfficer)..")")
			if isOfficer then
				VanguardRR:EndRaid(sender)
			end
		else
			VanguardRR:Debug("Prefix:"..prefix..":Decode FAILED!")
		end
	end
end

function VanguardRR:Comm_Start_Loot(prefix, message, distribution, sender)
	if (prefix and UnitName("player") ~= sender) then
		local isOfficer = VanguardRR:IsOfficer(sender)
		local success,decoded,deserialized = VanguardRR:DecodeMessage(message)
		if success then
			VanguardRR:Debug(prefix..": "..decoded..": "..sender.."("..tostring(isOfficer)..")")
			if isOfficer then
				if deserialized[4] == "" then
					VRRBidWindow_ShowWindow(deserialized[1],deserialized[2],deserialized[3])
				elseif VanguardRR:TableSearch(deserialized[4],UnitClass("player")) > 0 then
					VRRBidWindow_ShowWindow(deserialized[1],deserialized[2],deserialized[3])
				end
			end
		else
			VanguardRR:Debug("Prefix:"..prefix..":Decode FAILED!")
		end
	end
end

function VanguardRR:Comm_End_Loot(prefix, message, distribution, sender)
	if (prefix and UnitName("player") ~= sender) then
		local isOfficer = VanguardRR:IsOfficer(sender)
		local success,decoded,deserialized = VanguardRR:DecodeMessage(message)
		if success then
			VanguardRR:Debug(prefix..":"..decoded..":"..sender.."("..tostring(isOfficer)..")")
			if isOfficer then
				VRRBidWindow_EndBid()
			end
		else
			VanguardRR:Debug("Prefix:"..prefix..":Decode FAILED!")
		end
	end
end

function VanguardRR:Comm_Bid(prefix, message, distribution, sender)
	if (prefix and UnitName("player") ~= sender) then
		local success,decoded,deserialized = VanguardRR:DecodeMessage(message)
		if success then
			VanguardRR:Debug(prefix..":"..decoded..":"..sender.."("..tostring(isOfficer)..")")
			if VanguardRR:IsInGuild(sender) then
				VRRBidManager_AddBid(sender,deserialized)
			end
		else
			VanguardRR:Debug("Prefix:"..prefix..":Decode FAILED!")
		end
	end
end

function VanguardRR:Comm_Award_Loot(prefix, message, distribution, sender)
	if (prefix and UnitName("player") ~= sender) then
		local isOfficer = VanguardRR:IsOfficer(sender)
		local success,decoded,deserialized = VanguardRR:DecodeMessage(message)
		if success then
			VanguardRR:Debug(prefix..":"..decoded..":"..sender.."("..tostring(isOfficer)..")")
			if isOfficer then
				VanguardRR:Loot(deserialized[1],deserialized[2],deserialized[3],deserialized[4],sender)
			end
		else
			VanguardRR:Debug("Prefix:"..prefix..":Decode FAILED!")
		end
	end
end

function VanguardRR:Comm_Add_Standby(prefix, message, distribution, sender)
	if (prefix and UnitName("player") ~= sender) then
		local isOfficer = VanguardRR:IsOfficer(sender)
		local success,decoded,deserialized = VanguardRR:DecodeMessage(message)
		if success then
			VanguardRR:Debug(prefix..":"..decoded..":"..sender.."("..tostring(isOfficer)..")")
			if isOfficer then
				VanguardRR:AddToQueue(deserialized)
				VRRRaidControl_StandbyFrame_Update()
			end
		else
			VanguardRR:Debug("Prefix:"..prefix..":Decode FAILED!")
		end
	end
end

function VanguardRR:Comm_Remove_Standby(prefix, message, distribution, sender)
	if (prefix and UnitName("player") ~= sender) then
		local isOfficer = VanguardRR:IsOfficer(sender)
		local success,decoded,deserialized = VanguardRR:DecodeMessage(message)
		if success then
			VanguardRR:Debug(prefix..":"..decoded..":"..sender.."("..tostring(isOfficer)..")")
			if isOfficer then
				VanguardRR:RemoveFromQueue(deserialized)
				VRRRaidControl_StandbyFrame_Update()
			end
		else
			VanguardRR:Debug("Prefix:"..prefix..":Decode FAILED!")
		end
	end
end

function VanguardRR:Comm_Send_Raid(prefix, message, distribution, sender)
	if (prefix and UnitName("player") ~= sender) then
		local success,decoded,deserialized = VanguardRR:DecodeMessage(message)
		if success then
			if deserialized == UnitName("player") then
				local raiddata = {}
				if SettingsDB["RaidStarted"] then
					table.insert(raiddata, SettingsDB["RaidID"])
					table.insert(raiddata, SettingsDB["RaidQueue"])
					table.insert(raiddata, RaidDB[SettingsDB["RaidID"]])
				else
					table.insert(raiddata, SettingsDB["RaidQueue"])
				end
				VanguardRR:CommSend("VRR"..string.upper(sender),raiddata)
			end
		else
			VanguardRR:Debug("Prefix:"..prefix..":Decode FAILED!")
		end
	end	
end

function VanguardRR:Comm_Receive_Raid(prefix, message, distribution, sender)
	if (prefix and UnitName("player") ~= sender) then
		if prefix == "VRR"..string.upper(UnitName("player")) then
			local success,decoded,deserialized = VanguardRR:DecodeMessage(message)
			if success then
				VanguardRR:Debug(prefix..":"..decoded..":"..sender)
				if table.getn(deserialized) == 1 then
					SettingsDB["RaidQueue"] = deserialized[2]
				else
					SettingsDB["RaidID"] = deserialized[1]
					SettingsDB["RaidQueue"] = deserialized[2]
					RaidDB[SettingsDB["RaidID"]] = deserialized[3]
					SettingsDB["RaidStarted"] = true;
				end
			else
				VanguardRR:Debug("Unable to receive raid from "..sender.."!")
			end
		end
	end
end


function VanguardRR:CommSend(prefix, data)
	if IsInGuild() then
		local serialized, encoded = VanguardRR:EncodeMessage(data)
		if prefix == "VRRBID" then
			VanguardRR:Debug(prefix..":"..serialized)
			VanguardRR:SendCommMessage(prefix, encoded, "RAID")
		else
			VanguardRR:Debug(prefix..":"..serialized)
			if VanguardRR:IsOfficer(UnitName("player")) then
				VanguardRR:SendCommMessage(prefix, encoded, "RAID")
			end
		end
	end
end


function VanguardRR:DecodeMessage(message)
	local decoded = LibCompress:Decompress(LibCompressAddonEncodeTable:Decode(message))
	local success, deserialized = VanguardRR:Deserialize(decoded);
	return success, decoded, deserialized
end

function VanguardRR:EncodeMessage(message) --cannot be empty string, send "nil" (as test) if necessary
	local serialized = VanguardRR:Serialize(message)
	-- compress serialized string with both possible compressions for comparison
	-- I do both in case one of them doesn't retain integrity after decompression and decoding, the other is sent
	local huffmanCompressed = LibCompress:CompressHuffman(serialized);
	if huffmanCompressed then
		huffmanCompressed = LibCompressAddonEncodeTable:Encode(huffmanCompressed);
	end
	local lzwCompressed = LibCompress:CompressLZW(serialized);
	if lzwCompressed then
		lzwCompressed = LibCompressAddonEncodeTable:Encode(lzwCompressed);
	end

	-- Decode to test integrity
	local test1 = LibCompress:Decompress(LibCompressAddonEncodeTable:Decode(huffmanCompressed))
	if test1 == serialized then
		verInteg1 = true
	end
	local test2 = LibCompress:Decompress(LibCompressAddonEncodeTable:Decode(lzwCompressed))
	if test2 == serialized then
		verInteg2 = true
	end
	-- check which string with verified integrity is shortest. Huffman usually is
	if (strlen(huffmanCompressed) < strlen(lzwCompressed) and verInteg1 == true) then
		packet = huffmanCompressed;
	elseif (strlen(huffmanCompressed) > strlen(lzwCompressed) and verInteg2 == true) then
		packet = lzwCompressed
	elseif (strlen(huffmanCompressed) == strlen(lzwCompressed)) then
		if verInteg1 == true then packet = huffmanCompressed
		elseif verInteg2 == true then packet = lzwCompressed end
	end

	return serialized, packet

end
