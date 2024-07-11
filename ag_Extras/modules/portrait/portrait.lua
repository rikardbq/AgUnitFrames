local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local plugin = aUF:NewModule("Portrait")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

plugin.defaultDisabledState = true

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			["**"] = {
				Portrait = false,
				PortraitStyle = "3d",
			},
			["player"] = {
				Portrait = true,
			},
			["target"] = {
				Portrait = true,
			},
			["party"] = {
				Portrait = true,
			}
		}
	})
end

function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].Portrait and not power then
		object:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", self.UpdatePortrait)
	elseif not plugin.db.profile.units[object.type].Portrait then
		object:UnregisterUnitEvent("UNIT_PORTRAIT_UPDATE", self.UpdatePortrait)
	end
end

function plugin:OnEnable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectEnable(object)
		object:ApplyLayout()
		if object.unit then
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

function plugin:OnUpdateAll(object)
	if not plugin.db.profile.units[object.type].Portrait then return end
	self.UpdatePortrait(object)
end

function plugin:OnObjectDisable(object)
	if object.Portrait then
		object.Portrait = delFrame(object.Portrait)		
		object.PortraitModel = delFrame(object.PortraitModel)
		self:OnRegisterEvents(object)
		object:ApplyLayout()
	end
end

function plugin:OnObjectEnable(object)
	if plugin.db.profile.units[object.type].Portrait then
		if not object.Portrait then
			plugin:CreateFrame(object)
		end
		if object.PortraitModel then
			object.PortraitModel:ClearAllPoints()
			object.PortraitModel:SetPoint("TOPRIGHT", object.Portrait, "TOPRIGHT", 0, -0.5)
			object.PortraitModel:SetPoint("BOTTOMLEFT", object.Portrait, "BOTTOMLEFT", 1, 0)
		end
		if object.PortraitTexture then
			object.PortraitTexture:ClearAllPoints()
			object.PortraitTexture:SetPoint("TOPRIGHT", object.Portrait, "TOPRIGHT")
			object.PortraitTexture:SetPoint("BOTTOMLEFT", object.Portrait, "BOTTOMLEFT")
		end
	elseif object.Portrait then
		object.Portrait = delFrame(object.Portrait)		
		object.PortraitModel = delFrame(object.PortraitModel)
		object.PortraitTexture = delFrame(object.PortraitTexture)
	end
end

function plugin:CreateFrame(object)
	object.Portrait = newFrame("Texture", object.frame, "BORDER")
	object.Portrait:SetTexture(0, 0, 0, 0.3)
	object.PortraitModel = newFrame("PlayerModel", object.frame)
	object.PortraitModel:SetScript("OnShow",function() this:SetCamera(0) end)
	if not object.PortraitTexture then
		object.PortraitTexture = newFrame("Texture", object.frame, "ARTWORK")
	end
end

local classIcons = {
	["WARRIOR"] = {0, 0.25, 0, 0.25},
	["MAGE"] = {0.25, 0.49609375, 0, 0.25},
	["ROGUE"] = {0.49609375, 0.7421875, 0, 0.25},
	["DRUID"] = {0.7421875, 0.98828125, 0, 0.25},
	["HUNTER"] = {0, 0.25, 0.25, 0.5},
	["SHAMAN"] = {0.25, 0.49609375, 0.25, 0.5},
	["PRIEST"] = {0.49609375, 0.7421875, 0.25, 0.5},
	["WARLOCK"] = {0.7421875, 0.98828125, 0.25, 0.5},
	["PALADIN"] = {0, 0.25, 0.5, 0.75},
	["DEATHKNIGHT"] = {0.25, 0.49609375, 0.5, 0.75},
}

function plugin.UpdatePortrait(self, stop)
	if not self.Portrait then
		if self.PortraitModel then
			self.PortraitModel:Hide()
		end
		if self.PortraitTexture then
			self.PortraitTexture:Hide()
		end
		return
	end
	local style = plugin.db.profile.units[self.type].PortraitStyle
	if style == "3d" then
		self.PortraitTexture:SetTexture(nil)
		self.PortraitTexture:Hide()
		self.PortraitModel:Show()
		if not UnitExists(self.unit) or not UnitIsConnected(self.unit) or not UnitIsVisible(self.unit) then
			self.PortraitModel:SetModelScale(4.25)
			self.PortraitModel:SetPosition(0,0,-1.5)
			self.PortraitModel:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
		else
			self.PortraitModel:SetUnit(self.unit)
			self.PortraitModel:SetCamera(0)
		end
	else
		self.PortraitModel:Hide()
		self.PortraitTexture:Show()
		if style == "2d" then
			self.PortraitTexture:SetTexCoord(0.10, 0.90, 0.10, 0.90)
			SetPortraitTexture(self.PortraitTexture, self.unit)
	else
			local _, classname = UnitClass(self.unit)
			if classname then
				local class = classIcons[classname]
				self.PortraitTexture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
				self.PortraitTexture:SetTexCoord(class[1], class[2], class[3], class[4])
			else
				-- Pets. Work out a better icon?
				self.PortraitTexture:SetTexture("Interface\\Icons\\Ability_Hunter_BeastCall")
				self.PortraitTexture:SetTexCoord(0,1,0,1)
			end
		end
	end
end