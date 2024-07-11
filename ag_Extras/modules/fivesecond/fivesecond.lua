local _,playerClass = UnitClass("player")
if playerClass == "WARRIOR" or playerClass == "ROGUE" then
	return
end

local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

local plugin = aUF:NewModule("Fivesecond", "AceEvent-3.0")
plugin.inherit = "player"

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			player = {
				ShowFiveSecondRule = true,
				FiveSecondRuleColor = {1, 1, 1, 0.6},
			},
		}
	})
end

local fsbs = {}
local spellcast_finish_time, last_spellcast, current_mana = 0, 0, 0
local mana_regen_wait = 5


local manabar = aUF:GetModule("Powerbar")
local oldOnObjectEnable

local wrapper = function(manabar, object, power)
	oldOnObjectEnable(manabar, object, power)
	if object.type == plugin.inherit then
		plugin:OnObjectEnable(object)	
	end
end
	
function plugin:OnEnable()
	for _,object in aUF:IterateUnitObjects() do
		if object.type == "player" then
			self:OnObjectEnable(object)
		end
	end

	self:RegisterEvent("UNIT_MANA")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	if playerClass == "DRUID" then
		self:RegisterEvent("UNIT_DISPLAYPOWER")
	end
	current_mana = UnitMana('player')
	
	if manabar then
		oldOnObjectEnable = manabar.OnObjectEnable
		manabar.OnObjectEnable = wrapper
	end
end

function plugin:OnDisable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectDisable(object)
	end
	self:UnregisterEvent("UNIT_MANA")
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	if playerClass == "DRUID" then
		self:UnregisterEvent("UNIT_DISPLAYPOWER")
	end	
end

function plugin:OnObjectDisable(object)
	if object.FiveSecondRuleBar then
		local bar = object.FiveSecondRuleBar
		bar.object = nil
		bar.texture:Hide()
		object.FiveSecondRuleBar:Hide()
		bar.texture = delFrame(bar.texture)
		object.FiveSecondRuleBar = delFrame(bar)
	end
end

local function updateFiveSecondRule(bar, t)
	local timediff = GetTime() - spellcast_finish_time
	if timediff > mana_regen_wait then
		bar:Hide()
	else
		bar.texture:SetPoint('LEFT', bar, 'LEFT', (timediff / mana_regen_wait) * (bar:GetWidth() - 1) - 10, 0)
	end	
end

function plugin:OnLayoutApplied(object)
	if object.bars.ManaBar and object.FiveSecondRuleBar then
		local fsb = object.FiveSecondRuleBar
		fsb:SetAllPoints(object.bars.ManaBar)
		fsb:SetFrameLevel(object.bars.ManaBar:GetFrameLevel() + 2)
		fsb.texture:SetHeight(fsb:GetHeight() + 20)
	elseif object.FiveSecondRuleBar then
		object.FiveSecondRuleBar:Hide()
	end
end

function plugin:OnObjectEnable(object)
	if self.db.profile.units[object.type].ShowFiveSecondRule and object.bars.ManaBar then
		local fsb
		if not object.FiveSecondRuleBar then
			fsb = newFrame("Frame", object.frame)
			object.FiveSecondRuleBar = fsb
			fsb.object = object
			
			fsb:SetScript("OnUpdate", updateFiveSecondRule)
			fsb:Hide()
			
			local texture = newFrame("Texture", fsb, "OVERLAY")
			fsb.texture = texture
			texture:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
			texture:SetVertexColor(unpack(plugin.db.profile.units[object.type].FiveSecondRuleColor))
			texture:SetBlendMode('ADD')
			texture:SetWidth(20)
			texture:Show()
			
			texture:SetPoint("LEFT", fsb)

			table.insert(fsbs, fsb)
		end
	end
end

local function forAll(unit, state)
	for k, bar in ipairs(fsbs) do
		if state then
			bar:Show()
		else
			bar:Hide()
		end
	end
end

function plugin:UNIT_MANA(event, unit)
	if unit ~= "player" then return end
	local mana = UnitMana(unit)
	if mana == UnitManaMax(unit) then
		forAll(unit, false)
	elseif mana < current_mana then
		forAll(unit, true)
		spellcast_finish_time = last_spellcast
	end
	current_mana = mana
end

function plugin:UNIT_SPELLCAST_SUCCEEDED(event, unit)
	if unit ~= "player" then return end
	last_spellcast = GetTime()
end

if playerClass == "DRUID" then
	function plugin:UNIT_DISPLAYPOWER(event, unit)
		if unit ~= "player" then return end
		if UnitPowerType(unit) == 0 then
			forAll(unit, false)
		else
			current_mana = UnitMana(unit)
			forAll(unit, true)
		end
	end
end
