local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local plugin = aUF:NewModule("Statusicon")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

local combatStatus = {}

function plugin:OnInitialize()
	self:RegisterDefaults({
		units = {
			["**"] = {
				statusIcon = true,
			},		
		},
		modulesDisabled = {
			ag_UnitFrames_Pvpicon = true,
		},
	})
end

local pool = {}
function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].statusIcon and not power then
		if object.type == "player" then
			object:RegisterEvent("PLAYER_REGEN_ENABLED", self.UpdateStatusIcon)
			object:RegisterEvent("PLAYER_REGEN_DISABLED", self.UpdateStatusIcon)
			object:RegisterEvent("PLAYER_UPDATE_RESTING", self.UpdateStatusIcon)
			object:RegisterEvent("PLAYER_ENTERING_WORLD", self.UpdateStatusIcon)
		else
			if not self.inCombatSchedule then
				self.inCombatSchedule = self:StartTimer("UpdatePool", 1)
			end
			pool[object] = true
		end
	else
		if object.type == "player" then
			object:UnregisterEvent("PLAYER_REGEN_ENABLED", self.UpdateStatusIcon)
			object:UnregisterEvent("PLAYER_REGEN_DISABLED", self.UpdateStatusIcon)
			object:UnregisterEvent("PLAYER_UPDATE_RESTING", self.UpdateStatusIcon)
			object:UnregisterEvent("PLAYER_ENTERING_WORLD", self.UpdateStatusIcon)
		else
			pool[object] = nil
		end
	end
end

function plugin:OnUpdateAll(object)
	self.UpdateStatusIcon(object)
end

function plugin:OnMetroUpdate(object)
	self.UpdateStatusIcon(object)
end

function plugin:UpdatePool()
	if next(pool) == nil and self.inCombatSchedule then
		self:CancelTimer(self.inCombatSchedule)
		self.inCombatSchedule = nil
	end
	for object in pairs(pool) do
		self.UpdateStatusIcon(object)
	end
end

function plugin:OnEnable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectEnable(object)
		object:ApplyLayout()
		if object.unit then
			self.UpdateStatusIcon(object)
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

function plugin:OnObjectEnable(object)
	if not object.icons.statusIcon and plugin.db.profile.units[object.type].statusIcon then
		object.icons.statusIcon = newFrame("Texture", object.top, "OVERLAY")
		object.icons.statusIcon:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
	end
end

function plugin:OnObjectDisable(object)
	if plugin.db.profile.units[object.type].statusIcon and object.icons.statusIcon then
		object.icons.statusIcon = delFrame(object.icons.statusIcon)
	end
	self:OnRegisterEvents(object, true)
end

local setupMode = false
function plugin:OnUpdateSetupMode(object, flag)
	setupMode = flag
	self.UpdateStatusIcon(object)
end

function plugin.UpdateStatusIcon(self)
	if not self.icons.statusIcon then return end
	if plugin.db.profile.units[self.type].statusIcon then
		if setupMode then
			self.icons.statusIcon:Show()
			self.icons.statusIcon:SetTexCoord(0.5,1,0,0.49)
			return
		else
			if self.unit and UnitAffectingCombat(self.unit) then
				self.icons.statusIcon:Show()
				self.icons.statusIcon:SetTexCoord(0.5,1,0,0.49)
				return
			elseif self.unit == "player" and IsResting() then
				self.icons.statusIcon:Show()
				self.icons.statusIcon:SetTexCoord(0,0.5,0,0.421875)
				return
			end
		end
	end
	self.icons.statusIcon:Hide()
end

