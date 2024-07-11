local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local plugin = aUF:NewModule("Pvpicon")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			["**"] = {
				pvpIcon = true,
			},		
		}
	})
end

plugin.defaultDisabledState = true

function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].pvpIcon and not power then
		if object.unit == "player" then
			object:RegisterEvent("UPDATE_FACTION", self.UpdatePvPIcon)
		end
		object:RegisterUnitEvent("PLAYER_FLAGS_CHANGED", self.UpdatePvPIcon)
		object:RegisterUnitEvent("UNIT_FACTION", self.UpdatePvPIcon)
	else
		if object.unit == "player" then
			object:UnregisterEvent("UPDATE_FACTION", self.UpdatePvPIcon)
		end
		object:UnregisterUnitEvent("PLAYER_FLAGS_CHANGED", self.UpdatePvPIcon)
		object:UnregisterUnitEvent("UNIT_FACTION", self.UpdatePvPIcon)	
	end
end

function plugin:OnUpdateAll(object)
	self.UpdatePvPIcon(object)
end

function plugin:OnMetroUpdate(object)
	self.UpdatePvPIcon(object)
end

function plugin:OnEnable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectEnable(object)
		object:ApplyLayout()
		if object.unit then
			self.UpdatePvPIcon(object)
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
	if object.icons.pvpIcon then
		object.icons.pvpIcon = delFrame(object.icons.pvpIcon)		
		self:OnRegisterEvents(object, true)
		object:ApplyLayout()
	end
end

function plugin:OnObjectEnable(object)
	if plugin.db.profile.units[object.type].pvpIcon and not object.icons.pvpIcon then
		object.icons.pvpIcon = newFrame("Texture", object.top, "OVERLAY")
	end
end

local setupMode = false
function plugin:OnUpdateSetupMode(object, flag)
	setupMode = flag
	self.UpdatePvPIcon(object)
end
	
function plugin.UpdatePvPIcon(self)
	if not self.icons.pvpIcon then
		return
	end
	if plugin.db.profile.units[self.type].pvpIcon then
		if setupMode then
			self.icons.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
			self.icons.pvpIcon:Show()
			return
		end
		if ( UnitIsPVPFreeForAll(self.unit) ) then
			self.icons.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
			self.icons.pvpIcon:Show()
			return
		elseif ( UnitFactionGroup(self.unit) and UnitIsPVP(self.unit) ) then
			self.icons.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..UnitFactionGroup(self.unit))
			self.icons.pvpIcon:Show()
			return
		end
	end
	self.icons.pvpIcon:Hide()
end