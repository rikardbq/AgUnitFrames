local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local plugin = aUF:NewModule("LFGicon")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			["**"] = {
				showLFGIcon = true,
			},		
		}
	})
end

function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].showLFGIcon and not power then
		object:RegisterEvent("PARTY_LEADER_CHANGED", self.UpdateLFGIcon)
		object:RegisterEvent("PARTY_MEMBERS_CHANGED", self.UpdateLFGIcon)
	else
		object:UnregisterEvent("PARTY_LEADER_CHANGED", self.UpdateLFGIcon)
		object:UnregisterEvent("PARTY_MEMBERS_CHANGED", self.UpdateLFGIcon)
	end
end

function plugin:OnUpdateAll(object)
	self.UpdateLFGIcon(object)
end

function plugin:OnMetroUpdate(object)
	self.UpdateLFGIcon(object)
end

function plugin:OnEnable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectEnable(object)
		object:ApplyLayout()
		if object.unit then
			self.UpdateLFGIcon(object)
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
	if object.icons.lfgIcon then
		object.icons.lfgIcon = delFrame(object.icons.lfgIcon)		
		self:OnRegisterEvents(object, true)
	end
end

function plugin:OnObjectEnable(object)
	if plugin.db.profile.units[object.type].showLFGIcon and not object.icons.lfgIcon then
		object.icons.lfgIcon = newFrame("Texture", object.top, "OVERLAY")
		object.icons.lfgIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
	end
end

local setupMode = false
function plugin:OnUpdateSetupMode(object, flag)
	setupMode = flag
	self.UpdateLFGIcon(object)
end

function plugin.UpdateLFGIcon(self)

	if plugin.db.profile.units[self.type].showLFGIcon then
		local isTank, isHealer, isDamage = UnitGroupRolesAssigned(self.unit)

		if setupMode and (self.type == "party" or self.unit == "player") then
	 		self.icons.lfgIcon:SetTexCoord(20/64, 39/64, 22/64, 41/64)
			return
		end 

		if isTank then
			self.icons.lfgIcon:SetTexCoord(0, 19/64, 22/64, 41/64)
			self.icons.lfgIcon:Show()
		elseif isHealer then
			self.icons.lfgIcon:SetTexCoord(20/64, 39/64, 1/64, 20/64)
			self.icons.lfgIcon:Show()
		elseif isDamage then
			self.icons.lfgIcon:SetTexCoord(20/64, 39/64, 22/64, 41/64)
			self.icons.lfgIcon:Show()
		else
			self.icons.lfgIcon:Hide()
		end      
	else
		self.icons.lfgIcon:Hide()
	end

end



