-----------------------------
-- DISABLE BLIZZARD FRAMES --
-----------------------------

local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local hideblizz = aUF:NewModule("Hideblizz")

function hideblizz:OnRegister()
	self:RegisterDefaults({
		hidePlayerFrame = true,
		hidePartyFrame = true,
		hideTargetFrame = true,
		hideFocusFrame = true,
		hideCastFrame = false
	})
end

function hideblizz:OnEnable()
    hideblizz:UpdateBlizzVisibility()
end

function hideblizz:OnDisable()
	hideblizz:ShowBlizzPlayer()
	hideblizz:ShowBlizzParty()
	hideblizz:ShowBlizzTarget()
end

function hideblizz:UpdateBlizzVisibility()
	if self.db.profile.hidePlayerFrame == true then
		hideblizz:HideBlizzPlayer()
	else
		hideblizz:ShowBlizzPlayer()
	end
	if self.db.profile.hidePartyFrame == true then
		hideblizz:HideBlizzParty()
	else
		hideblizz:ShowBlizzParty()
	end
	if self.db.profile.hideTargetFrame == true then
		hideblizz:HideBlizzTarget()
	else
		hideblizz:ShowBlizzTarget()
	end
	if self.db.profile.hideFocusFrame == true then
		hideblizz:HideBlizzFocus()
	else
		hideblizz:ShowBlizzFocus()
	end
	if self.db.profile.hideCastFrame == true then
		hideblizz:HideBlizzCast()
	else
--		hideblizz:ShowBlizzCast()
	end		
end

local playerFrameState = true
function hideblizz:HideBlizzPlayer()
	if not playerFrameState then
		return
	end
	playerFrameState = false
	PlayerFrame:UnregisterAllEvents()
	PlayerFrameHealthBar:UnregisterAllEvents()
	PlayerFrameManaBar:UnregisterAllEvents()
	PlayerFrame:Hide()

end

function hideblizz:ShowBlizzPlayer()
	if playerFrameState then
		return
	end
	playerFrameState = true
	PlayerFrame:RegisterEvent("UNIT_LEVEL")
	PlayerFrame:RegisterEvent("UNIT_COMBAT")
	PlayerFrame:RegisterEvent("UNIT_SPELLMISS")
	PlayerFrame:RegisterEvent("UNIT_PVP_UPDATE")
	PlayerFrame:RegisterEvent("UNIT_MAXMANA")
	PlayerFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
	PlayerFrame:RegisterEvent("PLAYER_LEAVE_COMBAT")
	PlayerFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
	PlayerFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	PlayerFrame:RegisterEvent("PARTY_LEADER_CHANGED")
	PlayerFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
	PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	PlayerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	PlayerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	PlayerFrameHealthBar:RegisterEvent("UNIT_HEALTH")
	PlayerFrameHealthBar:RegisterEvent("UNIT_MAXHEALTH")
	PlayerFrameManaBar:RegisterEvent("UNIT_MANA")
	PlayerFrameManaBar:RegisterEvent("UNIT_RAGE")
	PlayerFrameManaBar:RegisterEvent("UNIT_FOCUS")
	PlayerFrameManaBar:RegisterEvent("UNIT_ENERGY")
	PlayerFrameManaBar:RegisterEvent("UNIT_HAPPINESS")
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXMANA")
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXRAGE")
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXFOCUS")
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXENERGY")
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXHAPPINESS")
	PlayerFrameManaBar:RegisterEvent("UNIT_DISPLAYPOWER")
	PlayerFrame:RegisterEvent("UNIT_NAME_UPDATE")
	PlayerFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	PlayerFrame:RegisterEvent("UNIT_DISPLAYPOWER")
	PlayerFrame:Show()
end

local partyFrameState = true

function hideblizz:HideBlizzParty()
	if not partyFrameState then
		return
	end
	partyFrameState = false
	for i = 1, 4 do
		local frame = _G["PartyMemberFrame"..i]
		frame:UnregisterAllEvents()
		frame:Hide()
		frame.Show = function() end
	end
	
	UIParent:UnregisterEvent("RAID_ROSTER_UPDATE")
end

function hideblizz:ShowBlizzParty()
	if partyFrameState then
		return
	end
	partyFrameState = true
	for i = 1, 4 do
		local frame = _G["PartyMemberFrame"..i]
		frame.Show = nil
		frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
		frame:RegisterEvent("PARTY_LEADER_CHANGED")
		frame:RegisterEvent("PARTY_MEMBER_ENABLE")
		frame:RegisterEvent("PARTY_MEMBER_DISABLE")
		frame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
		frame:RegisterEvent("UNIT_PVP_UPDATE")
		frame:RegisterEvent("UNIT_AURA")
		frame:RegisterEvent("UNIT_PET")
		frame:RegisterEvent("VARIABLES_LOADED")
		frame:RegisterEvent("UNIT_NAME_UPDATE")
		frame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
		frame:RegisterEvent("UNIT_DISPLAYPOWER")

		UnitFrame_OnEvent("PARTY_MEMBERS_CHANGED")
		
		_G.this = frame
		PartyMemberFrame_UpdateMember(frame)
	end
	
	UIParent:RegisterEvent("RAID_ROSTER_UPDATE")
end

local targetFrameState = true

function hideblizz:HideBlizzTarget()
	if not targetFrameState then
		return
	end
	targetFrameState = false
	TargetFrame:UnregisterAllEvents()
	TargetFrame:Hide()

	ComboFrame:UnregisterAllEvents()
end

function hideblizz:ShowBlizzTarget()
	if targetFrameState then
		return
	end
	targetFrameState = true
	TargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	TargetFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
	TargetFrame:RegisterEvent("UNIT_HEALTH")
	TargetFrame:RegisterEvent("UNIT_LEVEL")
	TargetFrame:RegisterEvent("UNIT_FACTION")
	TargetFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
	TargetFrame:RegisterEvent("UNIT_AURA")
	TargetFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
	TargetFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	if UnitExists("target") then
		TargetFrame:Show()
	end

	ComboFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
	ComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	ComboFrame:RegisterEvent("PLAYER_COMBO_POINTS")
end

local focusFrameState = true
function hideblizz:HideBlizzFocus()
	if not focusFrameState or not FocusFrame then
		return
	end
	focusFrameState = false
	FocusFrame:UnregisterAllEvents()
	FocusFrame:Hide()
end

function hideblizz:ShowBlizzFocus()
	if focusFrameState or not FocusFrame then
		return
	end
	focusFrameState = true
	FocusFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	FocusFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
	FocusFrame:RegisterEvent("UNIT_HEALTH")
	FocusFrame:RegisterEvent("UNIT_LEVEL")
	FocusFrame:RegisterEvent("UNIT_FACTION")
	FocusFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
	FocusFrame:RegisterEvent("UNIT_AURA")
	FocusFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
	FocusFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	if UnitExists("focus") then
		FocusFrame:Show()
	end
end

local castingBarState = true
function hideblizz:HideBlizzCast()
	if not castingBarState then
		return
	end
	castingBarState = false
	CastingBarFrame:UnregisterAllEvents()
	PetCastingBarFrame:UnregisterAllEvents()
end

function hideblizz:ShowBlizzCast()
	if castingBarState then
		return
	end
	castingBarState = true
	local t = newList(CastingBarFrame, PetCastingBarFrame)
	for i,v in ipairs(t) do
		v:RegisterEvent("UNIT_SPELLCAST_START")
		v:RegisterEvent("UNIT_SPELLCAST_STOP")
		v:RegisterEvent("UNIT_SPELLCAST_FAILED")
		v:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
		v:RegisterEvent("UNIT_SPELLCAST_DELAYED")
		v:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		v:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
		v:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
	t = del(t)
	
	PetCastingBarFrame:RegisterEvent("UNIT_PET")
end