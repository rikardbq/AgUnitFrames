local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame
local L = aUFLocale

local plugin = aUF:NewModule("Castbar")

local spellCastData = {}

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			["**"] = {
				CastBar = false,
			},		
			["player"] = {
				CastBar = true,
			},
			["target"] = {
				CastBar = true,
			},
			["party"] = {
				CastBar = true,
			},
		}
	})
	self.subConfig = "Bars"
end

function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].CastBar and not power then
		object:RegisterUnitEvent("UNIT_SPELLCAST_START", self.SpellcastStart)
		object:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.SpellcastChannelStart)
		object:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.SpellcastStop)
		object:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.SpellcastFailed)
		object:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", self.SpellcastDelayed)
		object:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", self.SpellcastChannelUpdate)
		object:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.SpellcastChannelStop)
		object:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.SpellcastFailed)
		object:RegisterOnUpdate(self.SpellcastUpdate)
	else
		object:UnregisterUnitEvent("UNIT_SPELLCAST_START", self.SpellcastStart)
		object:UnregisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.SpellcastChannelStart)
		object:UnregisterUnitEvent("UNIT_SPELLCAST_STOP", self.SpellcastStop)
		object:UnregisterUnitEvent("UNIT_SPELLCAST_FAILED", self.SpellcastFailed)
		object:UnregisterUnitEvent("UNIT_SPELLCAST_DELAYED", self.SpellcastDelayed)
		object:UnregisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", self.SpellcastChannelUpdate)
		object:UnregisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.SpellcastChannelStop)
		object:UnregisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.SpellcastFailed)
		object:UnregisterOnUpdate(self.SpellcastUpdate)
	end
end

function plugin:OnEnable()
	aUF:RegisterBarType("CastBar")
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectEnable(object)
		object:ApplyLayout()
		if object.unit then
			self:OnRegisterEvents(object)			
			object:UpdateAll()
		end
	end
end

function plugin:OnDisable()
	aUF:UnregisterBarType("CastBar")
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectDisable(object)
	end
end

function plugin:OnObjectDisable(object)
	if object.bars.CastBar then
		object.bars.CastBar.bg = delFrame(object.bars.CastBar.bg)
		object.bars.CastBar.text1 = nil
		object.bars.CastBar.text2 = nil			
		object.bars.CastBar = delFrame(object.bars.CastBar)
		object.strings.CastText = delFrame(object.strings.CastText)
		object.strings.BarCastText = delFrame(object.strings.BarCastText)
		self:OnRegisterEvents(object, true)
		object:ApplyLayout()
	end
end

function plugin:OnUpdateAll(object)
	if plugin.db.profile.units[object.type].CastBar and self:IsEnabled() then
		self.UpdateCastBar(object)
	end
end

function plugin:OnMetroUpdate(object)
	if plugin.db.profile.units[object.type].CastBar and self:IsEnabled() then
		self.UpdateCastBar(object)
	end
end

function plugin:OnLayoutApplied(object)
	if object.bars.CastBar then
		object.bars.CastBar.bg:ClearAllPoints()
		object.bars.CastBar.bg:SetAllPoints(object.bars.CastBar)
	end
end

function plugin:OnSetBarTexture(object)
	local m = aUF:GetBarTexture()
	if object.bars.CastBar then
		object.bars.CastBar:SetStatusBarTexture(m)
	end
	if object.bars.CastBar then
		object.bars.CastBar.bg:SetTexture(m)
	end
end

function plugin:OnObjectEnable(object)
	if plugin.db.profile.units[object.type].CastBar == true then
		if not object.bars.CastBar then
			object.bars.CastBar = newFrame("StatusBar", object.frame)
			object.bars.CastBar:SetMinMaxValues(0,100)
			
			object.bars.CastBar.bg = newFrame("Texture", object.frame, "BORDER")
			object.bars.CastBar.bg:SetVertexColor(0.25, 0.25, 0.25, 0.35)
			
			local BarCastText = newFrame("FontString", object.top, "OVERLAY")
			BarCastText:SetShadowColor(0, 0, 0)
			BarCastText:SetShadowOffset(0.8, -0.8)
			
			local CastText = newFrame("FontString", object.top, "OVERLAY")
			CastText:SetShadowColor(0, 0, 0)
			CastText:SetShadowOffset(0.8, -0.8)
			
			object.bars.CastBar.text1 = BarCastText
			object.bars.CastBar.text2 = CastText
			
			object.strings.BarCastText = BarCastText
			object.strings.CastText = CastText
			
			if not spellCastData[object] then
				spellCastData[object] = {}
			end
		end
	elseif object.bars.CastBar then
		object.bars.CastBar.bg = delFrame(object.bars.CastBar.bg)
		object.bars.CastBar.text1 = nil
		object.bars.CastBar.text2 = nil
		object.bars.CastBar = delFrame(object.bars.CastBar)
		object.strings.CastText = delFrame(object.strings.CastText)
		object.strings.BarCastText = delFrame(object.strings.BarCastText)
	end
end

-------------
-- CASTBAR --
-------------

function plugin.SpellcastUpdate(self)
	local currentTime = GetTime()
	if( spellCastData[self].casting) then
		local showTime = math.min(currentTime, spellCastData[self].endTime)
		local percent = ((currentTime - spellCastData[self].startTime) / (spellCastData[self].endTime - spellCastData[self].startTime)) * 100
		self.bars.CastBar:SetValue(percent)
		if spellCastData[self].delay then
			self.strings.CastText:SetText(string.format("|cffFF0000+%.1f|cffffffff %.1f",spellCastData[self].delay, spellCastData[self].endTime - showTime))
		else
			self.strings.CastText:SetText(string.format("%.1f", spellCastData[self].endTime - showTime))
		end
		if currentTime > spellCastData[self].endTime and not UnitIsUnit("player", self.unit) then
			spellCastData[self].casting        = nil
			spellCastData[self].fadeout        = 1
			spellCastData[self].stopTime       = GetTime()
		end
	elseif(spellCastData[self].channelling) then
		local showTime = currentTime
		if(currentTime > spellCastData[self].endTime) then
			showTime = spellCastData[self].endTime
			spellCastData[self].channelling = nil
			spellCastData[self].stopTime = GetTime()
		end
		local remainingTime = spellCastData[self].endTime - showTime
		self.bars.CastBar:SetValue(spellCastData[self].startTime + remainingTime)
		self.strings.CastText:SetText(string.format("%.1f", remainingTime))

		if spellCastData[self].delay then
			self.strings.CastText:SetText(string.format("|cffFF0000-%.1f|cffffffff %.1f", spellCastData[self].delay, remainingTime))
		else
			self.strings.CastText:SetText(string.format("%.1f", remainingTime))
		end
	elseif(spellCastData[self].fadeOut) then
		local alpha = spellCastData[self].stopTime - currentTime + 1
		if(alpha >= 1) then
			alpha = 1
		end
		if(alpha <= 0) then
			spellCastData[self].fadeOut = nil
			self.bars.CastBar:Hide()
			self.strings.CastText:SetText("")
			self.strings.BarCastText:SetText("")
			-- This is to reduce flicker on subsequent spells
			self.bars.CastBar:SetValue(0)
		else
			self.bars.CastBar:SetAlpha(alpha)
			self.strings.BarCastText:SetAlpha(alpha)
			self.strings.CastText:SetAlpha(alpha)
		end
	elseif self.bars.CastBar and self.bars.CastBar:IsVisible() then
		self.bars.CastBar:Hide()
		self.strings.CastText:SetText("")
		self.strings.BarCastText:SetText("")		
	end
end

function plugin.UpdateCastBar(self)	
	local rank, displayName
	
	local _, castRank, castDisplayName, _, castStartTime, castEndTime, isTrade, castID = UnitCastingInfo(self.unit)

	if castDisplayName then
		rank = castRank
		displayName = castDisplayName
		spellCastData[self].startTime = castStartTime * 0.001
		spellCastData[self].endTime = castEndTime * 0.001

		self.bars.CastBar:SetMinMaxValues(1, 100)

		local percent = ((GetTime() - castStartTime) / (castEndTime - castStartTime)) * 100
		self.bars.CastBar:SetValue(percent)
		self.bars.CastBar:SetStatusBarColor(1.0, 0.7, 0.0)
		self.bars.CastBar:Show()
		spellCastData[self].casting = 1
		spellCastData[self].channelling = nil
		spellCastData[self].castID = castID
	elseif chanDisplayName then
		rank = chanRank
		displayName = chanDisplayName
		spellCastData[self].startTime = chanStartTime * 0.001
		spellCastData[self].endTime = chanEndTime * 0.001

		self.bars.CastBar:SetMinMaxValues(spellCastData[self].startTime, spellCastData[self].endTime)

		local remainingTime = spellCastData[self].endTime - GetTime()
		self.bars.CastBar:SetValue(spellCastData[self].startTime + remainingTime)
		self.bars.CastBar:SetStatusBarColor(1.0, 0.7, 0.0)
		self.bars.CastBar:Show()
		spellCastData[self].casting = nil
		spellCastData[self].channelling = 1
		spellCastData[self].castID = castID
	else
		if spellCastData[self].casting or spellCastData[self].channelling then
			spellCastData[self].fadeOut	= 1
			spellCastData[self].casting = nil
			spellCastData[self].channelling = nil
			spellCastData[self].stopTime = GetTime()
			spellCastData[self].castID = nil
			self.strings.CastText:SetText("")
		end
		return
	end

	self.bars.CastBar:SetAlpha(1.0)
	spellCastData[self].fadeOut = 0
	self.strings.BarCastText:SetText(displayName)
	self.strings.BarCastText:SetAlpha(1.0)
	self.strings.CastText:SetAlpha(1.0)
	spellCastData[self].delay = nil
end

function plugin.SpellcastStart(self, event, unit)
	local _, rank, displayName, _, startTime, endTime, isTrade, castID = UnitCastingInfo(self.unit)

	spellCastData[self].startTime = startTime * 0.001
	spellCastData[self].endTime = endTime * 0.001
	spellCastData[self].delay = nil

	local c = aUF.db.profile.CastbarColor

	self.bars.CastBar:SetStatusBarColor(c.r, c.g, c.b)
	self.bars.CastBar:SetAlpha(1.0)
	self.bars.CastBar:SetMinMaxValues(1, 100)
	self.bars.CastBar:SetValue(1)
	self.bars.CastBar:Show()
	spellCastData[self].casting = 1
	spellCastData[self].channelling = nil
	spellCastData[self].fadeOut = 0
	spellCastData[self].castID = castID
	self.strings.BarCastText:SetText(displayName)
	self.strings.BarCastText:SetAlpha(1.0)
	self.strings.CastText:SetAlpha(1.0)
end

function plugin.SpellcastStop(self)
	if spellCastData[self].casting then
		self.bars.CastBar:SetStatusBarColor(0.0, 1.0, 0.0)
		self.bars.CastBar:SetMinMaxValues(0, 1)
		self.bars.CastBar:SetValue(1)
		spellCastData[self].casting = nil
		spellCastData[self].fadeout = 1
		spellCastData[self].stopTime = GetTime()
		spellCastData[self].castID = nil
		self.strings.CastText:SetText("")
	end
end

function plugin.SpellcastFailed(self, event, ...)
	local id = select(4, ...)
	if (spellCastData[self].casting or spellCastData[self].channelling) and spellCastData[self].castID == id then
		self.bars.CastBar:SetStatusBarColor(1.0, 0.0, 0.0)
		self.bars.CastBar:SetAlpha(1.0)
		self.bars.CastBar:SetMinMaxValues(0, 1)
		self.bars.CastBar:SetValue(1)
		self.bars.CastBar:Show()
		spellCastData[self].stopTime   = GetTime()
		spellCastData[self].casting    = nil
		spellCastData[self].channelling = nil
		spellCastData[self].fadeOut    = 1
		spellCastData[self].castID    = nil
		if event == "UNIT_SPELLCAST_FAILED" then
			self.strings.BarCastText:SetText(L["Failed"])
		else
			self.strings.BarCastText:SetText(L["Interrupted"])
		end
	end
end

function plugin.SpellcastChannelStart(self)
	local name, rank, displayName, b, startTime, endTime, isTrade, castID = UnitChannelInfo(self.unit)
	if not name then
		return
	end
	spellCastData[self].startTime = startTime * 0.001
	spellCastData[self].endTime = endTime * 0.001
	spellCastData[self].delay = nil

	local c = aUF.db.profile.CastbarColor

	self.bars.CastBar:SetStatusBarColor(c.r, c.g, c.b)
	self.bars.CastBar:SetAlpha(1.0)
	self.bars.CastBar:SetMinMaxValues(spellCastData[self].startTime, spellCastData[self].endTime)
	self.bars.CastBar:SetValue(spellCastData[self].endTime)
	self.bars.CastBar:Show()
	spellCastData[self].casting        = nil
	spellCastData[self].channelling    = 1
	spellCastData[self].fadeOut        = 0
	spellCastData[self].castID        = castID
	self.strings.BarCastText:SetText(displayName)
	self.strings.BarCastText:SetAlpha(1.0)
	self.strings.CastText:SetAlpha(1.0)
end

function plugin.SpellcastDelayed(self)
	if(spellCastData[self].casting) then
		local startTime, endTime = select(5, UnitCastingInfo(self.unit))

		if not startTime or not endTime then return end

		local oldStart = spellCastData[self].startTime
		spellCastData[self].startTime = startTime * 0.001
		spellCastData[self].endTime = endTime * 0.001
		spellCastData[self].delay = (spellCastData[self].delay or 0) + (spellCastData[self].startTime-oldStart)
		self.bars.CastBar:SetMinMaxValues(1, 100)
	end
end

function plugin.SpellcastChannelUpdate(self)
	local spell, _, _, _, startTime, endTime = UnitChannelInfo(self.unit)

	if not spell and self.bars.CastBar then
		self.bars.CastBar:Hide()
		self.strings.CastText:SetText("")
		self.strings.BarCastText:SetText("")
		return
	end

	local oldStart = spellCastData[self].startTime
	spellCastData[self].startTime = startTime * 0.001
	spellCastData[self].endTime = endTime * 0.001
	spellCastData[self].delay = (spellCastData[self].delay or 0) + (oldStart - spellCastData[self].startTime)
	self.bars.CastBar:SetMinMaxValues(spellCastData[self].startTime, spellCastData[self].endTime)
end

function plugin.SpellcastChannelStop(self)
	spellCastData[self].channelling = nil
	spellCastData[self].casting = nil
	spellCastData[self].fadeout = 1
	spellCastData[self].stopTime = GetTime()
	spellCastData[self].castID = nil
	self.strings.CastText:SetText("")
	self.strings.BarCastText:SetText("")
end
