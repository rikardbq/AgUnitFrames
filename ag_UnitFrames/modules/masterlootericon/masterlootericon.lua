local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local plugin = aUF:NewModule("Masterlootericon")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			["**"] = {
				looterIcon = true,
			},		
		}
	})
end

function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].looterIcon and not power then
		object:RegisterEvent("PARTY_LOOT_METHOD_CHANGED", self.UpdateMasterLooterIcon)
	else
		object:UnregisterEvent("PARTY_LOOT_METHOD_CHANGED", self.UpdateMasterLooterIcon)	
	end
end

function plugin:OnUpdateAll(object)
	self.UpdateMasterLooterIcon(object)
end

function plugin:OnMetroUpdate(object)
	self.UpdateMasterLooterIcon(object)
end

function plugin:OnRosterUpdate(object)
	self.UpdateMasterLooterIcon(object)
end

function plugin:OnEnable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectEnable(object)
		object:ApplyLayout()
		if object.unit then
			self.UpdateMasterLooterIcon(object)
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
	if object.icons.looterIcon then
		object.icons.looterIcon = delFrame(object.icons.looterIcon)		
		self:OnRegisterEvents(object, true)
	end
end

function plugin:OnObjectEnable(object)
	if plugin.db.profile.units[object.type].looterIcon and not object.icons.looterIcon then
		object.icons.looterIcon = newFrame("Texture", object.top, "OVERLAY")
		object.icons.looterIcon:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter")
	end
end

local setupMode = false
function plugin:OnUpdateSetupMode(object, flag)
	setupMode = flag
	self.UpdateMasterLooterIcon(object)
end

function plugin.UpdateMasterLooterIcon(self)
	if plugin.db.profile.units[self.type].looterIcon and setupMode then
		if self.type == "party" or self.unit == "player" then
			self.icons.looterIcon:Show()
			return
		end
	end
	if plugin.db.profile.units[self.type].looterIcon == true and self.number then
		local lootMaster
		if self.type == "raid" then
			lootMaster = select(11, GetRaidRosterInfo(self.number))
			if lootMaster then
				self.icons.looterIcon:Show()
				return
			end
		else
			_, lootMaster = GetLootMethod()
			if lootMaster then
				if self.unit == "player" and lootMaster == 0 then
					self.icons.looterIcon:Show()
					return
				elseif self.type == "party" and lootMaster > 0 then
					if lootMaster == self.number then
						self.icons.looterIcon:Show()
						return
					end
				end
			end
		end
	end
	if self.icons.looterIcon then
		self.icons.looterIcon:Hide()
	end
end