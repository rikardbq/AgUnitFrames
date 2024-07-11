local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local plugin = aUF:NewModule("Combattext")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

local font = "Fonts\\FRIZQT__.TTF"
local maxalpha = 0.6
local feedback = {}

setmetatable(feedback, { __newindex = function(self,k,v)
	rawset(self, k, v)
	if not plugin.schedule then
		plugin.schedule = aUF.StartTimer(plugin, "UpdatePool", 0.05)
	end
end })	

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			["**"] = {
				ShowCombat = true,
			},		
		}
	})	
end

function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].ShowCombat and not power then
		object:RegisterUnitEvent("UNIT_COMBAT", self.UnitCombat)
		object:RegisterUnitEvent("UNIT_SPELLMISS", self.UnitSpellmiss)
	else
		object:UnregisterUnitEvent("UNIT_COMBAT", self.UnitCombat)
		object:UnregisterUnitEvent("UNIT_SPELLMISS", self.UnitSpellmiss)
	end
end

function plugin:OnEnable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectEnable(object)
		object:ApplyLayout()
		if object.unit then
			self:OnRegisterEvents(object)			
		end
	end
end

function plugin:OnDisable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectDisable(object)
	end
end

function plugin:OnObjectDisable(object)
	if object.strings.HitIndicator then
		object.strings.HitIndicator = delFrame(object.strings.HitIndicator)
	end
	self:OnRegisterEvents(object, true)
	feedback[object] = nil	
end

function plugin:UpdatePool()
	if next(feedback) == nil and self.schedule then
		self:CancelTimer(self.schedule)
		self.schedule = nil
		return
	end
	for object in pairs(feedback) do
        local elapsedTime = GetTime() - object.feedbackStartTime
        if ( elapsedTime < COMBATFEEDBACK_FADEINTIME ) then
            local alpha = maxalpha*(elapsedTime / COMBATFEEDBACK_FADEINTIME)
            object.strings.HitIndicator:SetAlpha(alpha)
        elseif ( elapsedTime < (COMBATFEEDBACK_FADEINTIME + COMBATFEEDBACK_HOLDTIME) ) then
            object.strings.HitIndicator:SetAlpha(maxalpha)
        elseif ( elapsedTime < (COMBATFEEDBACK_FADEINTIME + COMBATFEEDBACK_HOLDTIME + COMBATFEEDBACK_FADEOUTTIME) ) then
            local alpha = maxalpha - maxalpha*((elapsedTime - COMBATFEEDBACK_HOLDTIME - COMBATFEEDBACK_FADEINTIME) / COMBATFEEDBACK_FADEOUTTIME)
            object.strings.HitIndicator:SetAlpha(alpha)
        else
            object.strings.HitIndicator:SetAlpha(0)
            feedback[object] = nil
        end
	end
end

function plugin:OnObjectEnable(object)
	if plugin.db.profile.units[object.type].ShowCombat then
		if not object.strings.HitIndicator then
			object.strings.HitIndicator = newFrame("FontString", object.top, "OVERLAY")
			object.strings.HitIndicator:SetShadowColor(0, 0, 0)
			object.strings.HitIndicator:SetShadowOffset(0.8, -0.8)
		end
	elseif object.strings.HitIndicator then
		object.strings.HitIndicator = delFrame(object.strings.HitIndicator)		
	end
end

-------------------
-- COMBAT EVENTS --
-------------------

function plugin.UnitCombat(self, event, unit, ...)
	if unit ~= self.unit then return end
	if not ( plugin.db.profile.units[self.type].ShowCombat ) then return end    
	plugin.CombatFeedback_OnCombatEvent(self, unit, ...)
end

function plugin.UnitSpellmiss(self, event, unit, ...)
	if unit ~= self.unit then return end
	if not ( plugin.db.profile.units[self.type].ShowCombat ) then return end
	plugin.CombatFeedback_OnSpellMissEvent(self, unit, ...)
end

function plugin.CombatFeedback_OnCombatEvent(self, unit, event, flags, amount, type)
	if not self.strings.HitIndicator then return end
	local fontHeight = 13
	local text = ""
	local r,g,b = 1,1,1
	if( event == "IMMUNE" ) then
		fontHeight = fontHeight * 0.75
		text = CombatFeedbackText[event]
	elseif ( event == "WOUND" ) then
		if ( amount ~= 0 ) then
			if ( flags == "CRITICAL" or flags == "CRUSHING" ) then
				fontHeight = fontHeight * 1.5
			elseif ( flags == "GLANCING" ) then
				fontHeight = fontHeight * 0.75
			end
			if ( type > 0 ) then
				r = 1.0
				g = 1.0
				b = 0.0
			end
			if UnitInParty(self.unit) or UnitInRaid(self.unit) then
				r = 1.0
				g = 0.0
				b = 0.0
			end
			text = "-"..amount
		elseif ( flags == "ABSORB" ) then
			fontHeight = fontHeight * 0.75
			text = CombatFeedbackText["ABSORB"]
		elseif ( flags == "BLOCK" ) then
			fontHeight = fontHeight * 0.75
			text = CombatFeedbackText["BLOCK"]
		elseif ( flags == "RESIST" ) then
			fontHeight = fontHeight * 0.75
			text = CombatFeedbackText["RESIST"]
		else
			text = CombatFeedbackText["MISS"]
		end
	elseif ( event == "BLOCK" ) then
		fontHeight = fontHeight * 0.75
		text = CombatFeedbackText[event]
	elseif ( event == "HEAL" ) then
		text = "+"..amount
		r = 0.0
		g = 1.0
		b = 0.0
		if ( flags == "CRITICAL" ) then
			fontHeight = fontHeight * 1.3
		end
	elseif ( event == "ENERGIZE" ) then
		text = amount
		r = 0.41
		g = 0.8
		b = 0.94
		if ( flags == "CRITICAL" ) then
			fontHeight = fontHeight * 1.3
		end
	else
		text = CombatFeedbackText[event]
	end

	self.feedbackStartTime = GetTime()
	local font = self.strings.HitIndicator:GetFont()
	self.strings.HitIndicator:SetFont(font,fontHeight,"OUTLINE")
	self.strings.HitIndicator:SetText(text)
	self.strings.HitIndicator:SetTextColor(r, g, b)
	self.strings.HitIndicator:SetAlpha(0)
	
	feedback[self] = true
end
