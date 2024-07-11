local LibHealComm = LibStub("LibHealComm-3.0", true)
if not LibHealComm then return end

local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

local plugin = aUF:NewModule("IncomingHeals", "AceEvent-3.0")

local playerName = UnitName("player")

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			['pettarget'] = {IncomingHeals = false},
			['partytarget'] = {IncomingHeals = false},
			['maintanktarget'] = {IncomingHeals = false},
			['maintanktargettarget'] = {IncomingHeals = false},
			['mainassisttarget'] = {IncomingHeals = false},
			['mainassisttargettarget'] = {IncomingHeals = false},
			["**"] = {
				IncomingHeals = true,
				IncomingHealColor = {0.4, 0.6, 0.4, 0.75},
				OutgoingHealColorN = {0, 1, 0, 1.00},
				OutgoingHealColorF = {1, 0, 0, 0.65},
			},
		}
	})
end

function plugin:OnEnable()
	LibHealComm.RegisterCallback(self, "HealComm_DirectHealStart")
	LibHealComm.RegisterCallback(self, "HealComm_DirectHealStop")
	LibHealComm.RegisterCallback(self, "HealComm_HealModifierUpdate")
end

function plugin:OnDisable()
	LibHealComm.UnregisterAllCallbacks(self)
end

function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].IncomingHeals and not power then
		object:RegisterUnitEvent("UNIT_HEALTH", self.UpdateHeals)
	else
		object:UnregisterUnitEvent("UNIT_HEALTH", self.UpdateHeals)
	end
end

local texture
function plugin:OnSetBarTexture(object)
	texture = aUF:GetBarTexture()
	if object.IncomingHealBar then
		if object.IncomingHealBar.texture.SetStatusBarTexture then
			object.IncomingHealBar.texture:SetStatusBarTexture(texture,"BORDER")
		end
	end
	if object.PlayerHealBar then
		if object.PlayerHealBar.texture.SetStatusBarTexture then
			object.PlayerHealBar.texture:SetStatusBarTexture(texture,"BORDER")
		end
	end
end

function plugin:OnUpdateAll(object)
	if not plugin.db.profile.units[object.type].IncomingHeals then return end
	self.UpdateHeals(object)
end

local function updateForUnitsCalled(...)
	for i = 1, select('#', ...) do
		for k, object in aUF:IterateUnitObjects() do
			if object.unit and plugin.db.profile.units[object.type] and plugin.db.profile.units[object.type].IncomingHeals then
				if (select(i, ...)) == UnitName(object.unit) then
					plugin.UpdateHeals(object)
				end
			end
		end
	end
end

local playerIsCasting = false
local playerHealingTargetName = nil
local playerHealingSize = 0
local playerEndTime = 0

function plugin:HealComm_DirectHealStart(event, healerName, healSize, endTime, ...)
	if healerName == playerName then
		playerIsCasting = true
		playerHealingTargetName = ... 
		playerHealingSize = healSize
		playerEndTime = endTime
	end
	
	updateForUnitsCalled(...)
end

function plugin:HealComm_DirectHealStop(event, healerName, healSize, succeeded, ...)
	if healerName == playerName then
		playerIsCasting = false
	end

	updateForUnitsCalled(...)
end

function plugin:HealComm_HealModifierUpdate(event, unit, targetName, healModifier)
	updateForUnitsCalled(targetName)
end

local maxHealthEstimate = {
	WARRIOR = 4100,
	PALADIN = 4000,
	SHAMAN = 3500,
	ROGUE = 3100,
	HUNTER = 3100,
	DRUID = 3100,
	WARLOCK = 2300,
	MAGE = 2200,
	PRIEST = 2100,
}
local function EstimateUnitHealthMax(unit)
	local _, class = UnitClass(unit)
	local level = UnitLevel(unit) or 60
	
	return (maxHealthEstimate[class] or 4000) * level / 60
end

function plugin.UpdateHeals(self)
	local healthBar = self.bars.HealthBar
	if not healthBar or not plugin.db.profile.units[self.type].IncomingHeals then
		return
	end
	
	local incomingHealBar = self.IncomingHealBar
	local playerHealBar = self.PlayerHealBar
	local incomingHeal
	local isCastingOnThisUnit
	
	local unit = self.type

	if playerIsCasting then
		isCastingOnThisUnit = playerHealingTargetName == UnitName(unit)
	end

	if isCastingOnThisUnit then
		incomingHeal = LibHealComm:UnitIncomingHealGet(unit, playerEndTime)
	else
		incomingHeal = select(2, LibHealComm:UnitIncomingHealGet(unit, GetTime()))
	end 
	
	-- Bail out early if nothing going on for this unit
	if not isCastingOnThisUnit and not incomingHeal then
		if incomingHealBar then
			delFrame(incomingHealBar.texture)
			self.IncomingHealBar = delFrame(incomingHealBar)
		end
		if playerHealBar then
			playerHealBar.texture = delFrame(playerHealBar.texture)
			self.PlayerHealBar = delFrame(playerHealBar)
		end
		return
	end
	
	local healModifier = LibHealComm:UnitHealModifierGet(unit)
	
	local unitHealthMax = UnitHealthMax(unit)
	if unitHealthMax == 100 then
		-- Estimate
		unitHealthMax = EstimateUnitHealthMax(unit)
	end
	
	local currentPercent = UnitHealth(unit) / UnitHealthMax(unit)
	local incomingPercent = incomingHeal and healModifier * incomingHeal / unitHealthMax or 0
	local playerPercent = isCastingOnThisUnit and healModifier * playerHealingSize / unitHealthMax or 0
	
	local frameLevel = healthBar:GetFrameLevel()
	local height, width = healthBar:GetHeight(), healthBar:GetWidth()
	if incomingPercent > 0 then
		
		if not incomingHealBar then
			incomingHealBar = newFrame("Frame", healthBar)
			self.IncomingHealBar = incomingHealBar
			local incomingHealBar_texture = newFrame("Texture", incomingHealBar, "BACKGROUND")
			incomingHealBar.texture = incomingHealBar_texture
			incomingHealBar_texture:SetTexture(texture)
			incomingHealBar_texture:SetAllPoints(incomingHealBar)
		end
		incomingHealBar:ClearAllPoints()
		incomingHealBar.texture:SetVertexColor(unpack(plugin.db.profile.units[self.type].IncomingHealColor))
		
		incomingHealBar:SetWidth(width * incomingPercent)
		incomingHealBar:SetHeight(height)
		
		local n = width * currentPercent
		incomingHealBar.texture:SetTexCoord(0, 0, 0, 1, incomingPercent, 0, incomingPercent, 1)
		incomingHealBar:SetPoint("LEFT", healthBar, "LEFT", n, 0)
	else
		if incomingHealBar then
			delFrame(incomingHealBar.texture)
			self.IncomingHealBar = delFrame(incomingHealBar)
		end
	end
	
	if playerPercent > 0 then
		if not playerHealBar then
			playerHealBar = newFrame("Frame", healthBar)
			self.PlayerHealBar = playerHealBar
			local playerHealBar_texture = newFrame("Texture", playerHealBar, "BACKGROUND")
			playerHealBar.texture = playerHealBar_texture
			playerHealBar_texture:SetTexture(texture)
			playerHealBar_texture:SetAllPoints(playerHealBar)
			
			playerHealBar:SetWidth(width)
			playerHealBar:SetHeight(height)
			playerHealBar:Show()
		end
		local waste
		if currentPercent + incomingPercent > 1 then
			waste = 1
		else
			waste = currentPercent + incomingPercent + playerPercent - 1
			if waste > 0 then
				waste = waste / playerPercent
			else
				waste = 0
			end
		end

		-- Calculate color for overheal severity
		local OutgoingHealColorF = plugin.db.profile.units[self.type].OutgoingHealColorF
		local red, green, blue, alpha = unpack(plugin.db.profile.units[self.type].OutgoingHealColorN)
		local iwaste = 1 - waste
		red = red * iwaste + waste * OutgoingHealColorF[1]
		green = green * iwaste + waste * OutgoingHealColorF[2]
		blue = blue * iwaste + waste * OutgoingHealColorF[3]
		alpha = alpha * iwaste + waste * OutgoingHealColorF[4]

		-- Set color for heal
		playerHealBar.texture:SetVertexColor(red, green, blue, alpha)

		playerHealBar:ClearAllPoints()
		
		playerHealBar:SetWidth(width * playerPercent)
		playerHealBar:SetHeight(height)
		
		local n = width * (currentPercent + incomingPercent)
		playerHealBar.texture:SetTexCoord(0, 0, 0, 1, playerPercent, 0, playerPercent, 1)
		playerHealBar:SetPoint("LEFT", healthBar, "LEFT", n, 0)
	else
		if playerHealBar then
			playerHealBar.texture = delFrame(playerHealBar.texture)
			self.PlayerHealBar = delFrame(playerHealBar)
		end
	end
end
