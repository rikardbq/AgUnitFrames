local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local plugin = aUF:NewModule("Combopoints")
plugin.inherit = "target"
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

function plugin:OnRegisterEvents(object, power)
	if not power then
		object:RegisterEvent("UNIT_COMBO_POINTS", self.UpdateComboPoints)
	else
		object:UnregisterEvent("UNIT_COMBO_POINTS", self.UpdateComboPoints)
	end
end

function plugin:OnObjectEnable(object)
	if not object.Combo1 then
		for i=1,5 do
			local frame = "Combo" .. i
			object[frame] = newFrame("Texture", object.top, "OVERLAY")
			object[frame]:SetTexture("Interface\\AddOns\\ag_UnitFrames\\images\\combo.tga")
			object[frame]:SetHeight(10)
			object[frame]:SetWidth(10)
			object[frame]:Hide()
			if i > 1 then
				object[frame]:SetPoint("BOTTOMRIGHT",object["Combo"..i-1],"BOTTOMLEFT")
			else
				object[frame]:SetPoint("BOTTOMRIGHT",object.frame,"BOTTOMRIGHT",-2,-1)
			end
		end
	end
end

function plugin:OnObjectDisable(object)
	if self.inherit == object.inherit then
		if object.Combo1 then
			object.Combo1 = delFrame(object.Combo1)		
			object.Combo2 = delFrame(object.Combo2)		
			object.Combo3 = delFrame(object.Combo3)		
			object.Combo4 = delFrame(object.Combo4)		
			object.Combo5 = delFrame(object.Combo5)		
			self:OnRegisterEvents(object, true)
		end
	end
end

function plugin:OnDisable(object)
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectDisable(object)
	end
end

function plugin:OnEnable()
	for _,object in aUF:IterateUnitObjects() do
		if object.type then
			if self.inherit == object.type then
				self:OnObjectEnable(object)
				if object.unit then
					self.UpdateComboPoints(object)
					self:OnRegisterEvents(object)
				end
			end
		end
	end
end

function plugin:OnUpdateAll(object)
	self.UpdateComboPoints(object)
end

local setupMode = false
function plugin:OnUpdateSetupMode(object, flag)
	setupMode = flag
	self.UpdateComboPoints(object)
end


-------------------
-- CLASS METHODS --
-------------------

function plugin.UpdateComboPoints(self, event, unit)
	if unit and not (unit == "player" or unit == "vehicle") then return end
	local unit = UnitHasVehicleUI("player") and "vehicle" or "player"
	local points = GetComboPoints(unit, "target")
	if setupMode and self.Combo1 then 
		points = 5
	end
	if self.Combo1 then
		for i=0,4 do
			if points > i then
				self["Combo"..i+1]:Show()
			else
				self["Combo"..i+1]:Hide()
			end
		end
	else
		if points == 0 then
			points = ""
		end
	end
end
