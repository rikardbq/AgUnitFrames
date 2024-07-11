if select(2, UnitClass("player")) ~= "HUNTER" then
	-- Non-Hunters suck and cannot stand the awesomeness of this module.
	return
end

local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local plugin = aUF:NewModule("HappinessIcon")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

plugin.inherit = "pet"

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			["pet"] = {
				HappinessIcon = true,
			},
		}
	})
end

function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].HappinessIcon and not power then
		object:RegisterEvent("UNIT_HAPPINESS", self.UpdateHappiness)
	else
		object:UnregisterEvent("UNIT_HAPPINESS", self.UpdateHappiness)
	end
end

function plugin:OnEnable()
	for _,object in aUF:IterateUnitObjects() do
		if object.unit == "pet" then
			self:OnObjectEnable(object)
			object:ApplyLayout()
			self:OnRegisterEvents(object)
			object:UpdateAll()
		end
	end
end

function plugin:OnDisable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectDisable(object)
	end
end

function plugin:OnObjectDisable(object)
	if object.icons.HappinessIcon then
		object.icons.HappinessIcon = delFrame(object.icons.HappinessIcon)
		self:OnRegisterEvents(object, true)
		object:ApplyLayout()
	end
end

function plugin:OnUpdateAll(object)
	if not plugin.db.profile.units[object.type].HappinessIcon then return end
	self.UpdateHappiness(object)
end

function plugin:OnObjectEnable(object)
	if plugin.db.profile.units[object.type].HappinessIcon then
		if not object.icons.HappinessIcon then
			object.icons.HappinessIcon = newFrame("Texture", object.frame, "ARTWORK")
			object.icons.HappinessIcon:SetTexture("Interface\\PetPaperDollFrame\\UI-PetHappiness")
		end
	elseif object.icons.HappinessIcon then
		object.icons.HappinessIcon = delFrame(object.icons.HappinessIcon)
	end
end
local setupMode = false
function plugin:OnUpdateSetupMode(object, flag)
	setupMode = flag
	self.UpdateHappiness(object)
end
function plugin.UpdateHappiness(self, stop)
	if not self.icons.HappinessIcon then return end
	local happiness = GetPetHappiness()
	if setupMode then happiness = 1 end
	if happiness == 1 then
		self.icons.HappinessIcon:SetTexCoord(0.375, 0.5625, 0, 0.359375)
	elseif happiness == 2 then
		self.icons.HappinessIcon:SetTexCoord(0.1875, 0.375, 0, 0.359375)
	elseif happiness == 3 then
		self.icons.HappinessIcon:SetTexCoord(0, 0.1875, 0, 0.359375)
	end
end
