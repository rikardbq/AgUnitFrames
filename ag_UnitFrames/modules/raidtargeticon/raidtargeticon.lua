local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local plugin = aUF:NewModule("Raidtargeticon")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			["**"] = {
				raidIcon = true,
			},		
		}
	})
end

function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].raidIcon then
		object:RegisterEvent("RAID_TARGET_UPDATE", self.UpdateRaidTargetIcon)
	else
		object:UnregisterEvent("RAID_TARGET_UPDATE", self.UpdateRaidTargetIcon)	
	end
end

function plugin:OnUpdateAll(object)
	self.UpdateRaidTargetIcon(object)
end

function plugin:OnMetroUpdate(object)
	self.UpdateRaidTargetIcon(object)
end

function plugin:OnEnable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectEnable(object)
		object:ApplyLayout()
		if object.unit then
			self.UpdateRaidTargetIcon(object)
			self:OnRegisterEvents(object)
		end
	end
end

function plugin:OnDisable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectDisable(object)
		object:ApplyLayout()
	end
end

function plugin:OnObjectDisable(object)
	if object.icons.raidTargetIcon then
		object.icons.raidTargetIcon = delFrame(object.icons.raidTargetIcon)		
		self:OnRegisterEvents(object, true)
	end
end

function plugin:OnObjectEnable(object)
	if plugin.db.profile.units[object.type].raidIcon and not object.icons.raidTargetIcon then
		object.icons.raidTargetIcon = newFrame("Texture", object.top, "OVERLAY")
		object.icons.raidTargetIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	end
end

local setupMode = false
function plugin:OnUpdateSetupMode(object, flag)
	setupMode = flag
	self.UpdateRaidTargetIcon(object)
end

function plugin.UpdateRaidTargetIcon(self)
	if not self.icons.raidTargetIcon then
		return
	end
	if setupMode and plugin.db.profile.units[self.type].raidIcon then
		SetRaidTargetIconTexture(self.icons.raidTargetIcon, 1)
		self.icons.raidTargetIcon:Show()
		return
	end
	local index
	if self.unit then
		index = GetRaidTargetIndex(self.unit)
	end
	if ( index ) and UnitExists(self.unit) and plugin.db.profile.units[self.type].raidIcon then
		SetRaidTargetIconTexture(self.icons.raidTargetIcon, index)
		self.icons.raidTargetIcon:Show()		
	elseif self.icons.raidTargetIcon then
		self.icons.raidTargetIcon:Hide()
	end
end