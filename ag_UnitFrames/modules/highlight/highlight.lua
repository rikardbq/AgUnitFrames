local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local plugin = aUF:NewModule("Highlight")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			["**"] = {
				HighlightSelected = true
			}
		}
	})	
end

function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].HighlightSelected and self:IsEnabled() and not power then
		object:RegisterEvent("PLAYER_TARGET_CHANGED", self.UpdateHighlight)
	else
		object:UnregisterEvent("PLAYER_TARGET_CHANGED", self.UpdateHighlight)
	end
end

function plugin:OnEnable()
	for _,object in aUF:IterateUnitObjects() do
		if object.type then	
			self:OnObjectEnable(object)
			self.UpdateHighlight(object)
			if object.unit then
				self:OnRegisterEvents(object)
			end
		end
	end
end

function plugin:OnDisable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectDisable(object)
	end
end

function plugin:OnObjectDisable(object)
	if object.highlight then
		object.highlight = delFrame(object.highlight)		
		self:OnRegisterEvents(object, true)
	end
end

function plugin:OnUpdateAll(object)
	self.UpdateHighlight(object)
end

function plugin:OnEnter(object)
	self.UpdateHighlight(object, nil, true)
end

function plugin:OnLeave(object)
	self.UpdateHighlight(object)
end

function plugin:OnObjectEnable(object)
	if plugin.db.profile.units[object.type].HighlightSelected and not object.highlight then
		local highlight = newFrame("Texture",object.top, "OVERLAY")
		highlight:SetAlpha(0.5)
		highlight:SetTexture("Interface\\AddOns\\ag_UnitFrames\\Images\\MouseoverHighlight")
		highlight:SetBlendMode("ADD")	
		highlight:SetPoint("TOPLEFT",object.frame, "TOPLEFT", 5, -5)
		highlight:SetPoint("BOTTOMRIGHT",object.frame, "BOTTOMRIGHT", -5, 5)
		highlight:Hide()
		object.highlight = highlight
	end
end

	
function plugin.UpdateHighlight(self, event, entered)
	if not self.highlight then return end
	if self.unit and (UnitExists("target") and UnitIsUnit("target",self.unit) and not (self.unit:find("target")) and plugin.db.profile.units[self.type].HighlightSelected == true) or (entered and plugin.db.profile.units[self.type].HighlightSelected == true) then
		self.highlight:Show()
	else
		self.highlight:Hide()
	end
end