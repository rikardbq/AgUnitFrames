local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame
local L = aUFLocale

local enabledObjects = {}

local plugin = aUF:NewModule("Xprepbar")
plugin.inherit = {["player"]=true,["pet"]=true}

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			player = {
				ShowXP = true,
				ShowXPTooltip = true,
				ShowRep = true,
			},
			pet = {
				ShowXP = true,
				ShowXPTooltip = true,
			},            
		}
	})
	
	self.subConfig = "Bars"

	hooksecurefunc("ReputationWatchBar_Update", self.UpdateRepEvent)
end

function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].ShowXP and not power then
		if object.type == "player" then
			enabledObjects[object] = true
			object:RegisterEvent("PLAYER_XP_UPDATE", self.UpdateXP)
			object:RegisterEvent("UPDATE_EXHAUSTION", self.UpdateXP)
			object:RegisterEvent("PLAYER_LEVEL_UP", self.UpdateXP)
		else
			object:RegisterEvent("UNIT_PET_EXPERIENCE", self.UpdateXPPet)
		end
	else
		if object.type == "player" then
			enabledObjects[object] = nil
			object:UnregisterEvent("PLAYER_XP_UPDATE", self.UpdateXP)
			object:UnregisterEvent("UPDATE_EXHAUSTION", self.UpdateXP)
			object:UnregisterEvent("PLAYER_LEVEL_UP", self.UpdateXP)
		else
			object:UnregisterEvent("UNIT_PET_EXPERIENCE", self.UpdateXPPet)
		end
	end
end

function plugin:OnEnable()
	aUF:RegisterBarType("XPBar", {"player","pet"})
	for _,object in aUF:IterateUnitObjects() do
		if self.inherit[object.type] and plugin.db.profile.units[object.type].ShowXP then
			self:OnObjectEnable(object)
			object:ApplyLayout()
			if object.unit then
				self:OnRegisterEvents(object)
				if object.unit == "player" then
					self.UpdateXP(object)
				else
					self.UpdateXPPet(object)
				end
			end
		end
	end
end

function plugin:OnDisable()
	aUF:UnregisterBarType("XPBar")
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectDisable(object)
	end
end

function plugin:OnObjectDisable(object)
	if self.inherit[object.type] and object.bars.XPBar then
		enabledObjects[object] = nil
		object.bars.XPBar.bg = delFrame(object.bars.XPBar.bg)
		object.bars.XPBar.Rest = delFrame(object.bars.XPBar.Rest)
		object.bars.XPBar = delFrame(object.bars.XPBar)				
		object:ApplyLayout()
		
		-- When you disable a module, it's going to try and register the vents, not unregister them
		-- as ShowXP is still flagged as true, despite the module not being enabled.
		if object.unit then
			object:UnregisterEvent("PLAYER_XP_UPDATE", self.UpdateXP)
			object:UnregisterEvent("UPDATE_EXHAUSTION", self.UpdateXP)
			object:UnregisterEvent("PLAYER_LEVEL_UP", self.UpdateXP)
			object:UnregisterEvent("UNIT_PET_EXPERIENCE", self.UpdateXPPet)
		end
	end
end

function plugin:OnUpdateAll(object)
	if plugin.db.profile.units[object.type].ShowXP then
		if object.unit == "player" then
			self.UpdateXP(object)
		else
			self.UpdateXPPet(object)
		end
	end
end

function plugin:UpdateRepEvent()
	for object in pairs(enabledObjects) do
		if object and object.unit then
			if object.unit == "player" then
				plugin.UpdateXP(object)
			end
		end
	end
end

function plugin:OnSetBarTexture(object)
	local m = aUF:GetBarTexture()
	if object.bars.XPBar then
		object.bars.XPBar:SetStatusBarTexture(m)
		object.bars.XPBar.bg:SetTexture(m)
		if object.bars.XPBar.Rest then
			object.bars.XPBar.Rest:SetStatusBarTexture(m)
		end
	end
end

local function xpOnEnter(frame) plugin.XPOnEnter(frame) end
local function xpPetOnEnter(frame) plugin.XPOnEnterPet(frame) end
function plugin:OnObjectEnable(object)
	local _,eClass = UnitClass("player")
	if (object.unit == 'pet' and eClass ~= "HUNTER") or not plugin.db.profile.units[object.type].ShowXP then
		if object.bars.XPBar then
			object.bars.XPBar.bg = delFrame(object.bars.XPBar.bg)
			object.bars.XPBar.Rest = delFrame(object.bars.XPBar.Rest)
			object.bars.XPBar = delFrame(object.bars.XPBar)				
		end
	elseif plugin.db.profile.units[object.type].ShowXP then
		if not object.bars.XPBar then
			object.bars.XPBar = newFrame("StatusBar", object.frame, "ARTWORK")
			object.bars.XPBar:SetMinMaxValues(0, 100)
			
			object.bars.XPBar.bg = newFrame("Texture", object.frame, "BORDER")
			object.bars.XPBar.bg:SetDrawLayer("BORDER")
			
			object.bars.XPBar.bg:ClearAllPoints()
			object.bars.XPBar.bg:SetAllPoints(object.bars.XPBar)

			if object.unit == "player" then
				object.bars.XPBar.Rest = newFrame("StatusBar", object.frame, "ARTWORK")
				object.bars.XPBar.Rest:SetMinMaxValues(0, 100)
				object.bars.XPBar:SetParent(object.bars.XPBar.Rest)
				
				object.bars.XPBar.Rest:ClearAllPoints()
				object.bars.XPBar.Rest:SetAllPoints(object.bars.XPBar)
			end
			self.ToggleTooltip(object)
		end
	end
end

function plugin.ToggleTooltip(object)
	-- ensure the XPBar exists, since people uncheck it then go to uncheck teh rep bar and it goes boom
	if not object.bars.XPBar then return end
	if plugin.db.profile.units[object.type].ShowXPTooltip then
		object.bars.XPBar.unit = object
		object.bars.XPBar:EnableMouse(true)
		if object.unit == "player" then
			object.bars.XPBar:SetScript("OnEnter", xpOnEnter)
		else
			object.bars.XPBar:SetScript("OnEnter", xpPetOnEnter)
		end
		object.bars.XPBar:SetScript("OnLeave", hideTT)
	else
		object.bars.XPBar:EnableMouse(nil)
		object.bars.XPBar:SetScript("OnEnter", nil)
		object.bars.XPBar:SetScript("OnLeave", nil)
	end
end

----------------------
-- UNITPLAYER CLASS --
----------------------

local red = {r = 0.9, g = 0.2, b = 0.3}
local yellow = {r = 1, g = 0.85, b = 0.1}
local green = {r = 0.4, g = 0.95, b = 0.3}

function plugin.UpdateXP(self)
	local repname, repreaction, repmin, repmax, repvalue = GetWatchedFactionInfo()
	if plugin.db.profile.units[self.type].ShowXP then
		if repname and plugin.db.profile.units[self.type].ShowRep then
			local color
			if repreaction then
				if repreaction < 4 then
					color = red
				elseif repreaction == 4 then
					color = yellow
				else
					color = green
				end
			end
			repmax = repmax - repmin
			repvalue = repvalue - repmin
			repmin = 0

			if self.bars.XPBar.Rest then
				self.bars.XPBar.Rest:Hide()
			end

			self.bars.XPBar:SetParent(self.frame)
			self.bars.XPBar:Show()
			if repmax ~= 0 then
				self.bars.XPBar:SetValue((repvalue/repmax)*100)
			else
				self.bars.XPBar:SetValue(0)
			end
			self.bars.XPBar:SetStatusBarColor(color.r, color.g, color.b)
			self.bars.XPBar.bg:SetVertexColor(color.r, color.g, color.b, 0.25)
		else
			local XPColor = aUF.db.profile.XPColor
			local RestedXPColor = aUF.db.profile.RestedXPColor
			local priorXP = self.bars.XPBar:GetValue()
			local restXP = GetXPExhaustion()
			local currXP, nextXP = UnitXP(self.unit), UnitXPMax(self.unit)

			if nextXP ~= 0 then
				self.bars.XPBar:SetValue((currXP/nextXP)*100)
			else
				self.bars.XPBar:SetValue(0)
			end

			if restXP then
				self.bars.XPBar.Rest:Show()
				self.bars.XPBar.Rest:SetFrameLevel(self.bars.XPBar:GetFrameLevel()-1)
				self.bars.XPBar:SetParent(self.bars.XPBar.Rest)
				self.bars.XPBar.Rest:SetStatusBarColor(RestedXPColor.r, RestedXPColor.g, RestedXPColor.b)
				if nextXP ~= 0 then
					self.bars.XPBar.Rest:SetValue(((currXP+restXP)/nextXP)*100)
				else
					self.bars.XPBar.Rest:SetValue(0)
				end
			else
				self.bars.XPBar:SetParent(self.frame)
				self.bars.XPBar:Show()
				self.bars.XPBar.Rest:Hide()
			end

			self.bars.XPBar:SetStatusBarColor(XPColor.r, XPColor.g, XPColor.b)
			self.bars.XPBar.bg:SetVertexColor(XPColor.r, XPColor.g, XPColor.b, 0.25)
		end
	else
		self.bars.XPBar:Hide()
		self.bars.XPBar.bg:Hide()
		self.bars.XPBar.Rest:Hide()
	end
end

function plugin.XPOnEnter(self, object)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:ClearLines()
	local _,eClass = UnitClass("player")

	local totalXP = UnitXPMax("player")
	local currentXP = UnitXP("player")
	local toLevelXP = totalXP - currentXP
	local restXP = GetXPExhaustion() or 0

	GameTooltip:AddLine(format(L["XP: %d/%d (%.1f%%)"], currentXP, totalXP, currentXP/totalXP*100))
	if restXP == 0 then
		restXP = ""
	else
		restXP = format(L["|c0064e1ff+%d rested|r"], restXP)
	end
	GameTooltip:AddLine(format(L["%d to level%s"], toLevelXP, restXP))

	local repname, repreaction, repmin, repmax, repvalue = GetWatchedFactionInfo()
	if (repname) then
		GameTooltip:AddLine(repname .. " (" .. _G["FACTION_STANDING_LABEL" .. repreaction] .. ")")
		GameTooltip:AddLine(format("%d/%d (%.1f%%)", repvalue-repmin, repmax-repmin, (repvalue-repmin)/(repmax-repmin) * 100))
	end
	GameTooltip:Show()
end

----------------------
-- UNITPET CLASS --
----------------------

function plugin.UpdateXPPet(self)
	local _,eClass = UnitClass("player")
	if eClass ~= "HUNTER" then return end
	if plugin.db.profile.units[self.type].ShowXP == true and eClass == "HUNTER" then
		local XPColor = aUF.db.profile.XPColor
		local priorXP = self.bars.XPBar:GetValue()
		local currXP, nextXP = GetPetExperience()

		if nextXP ~= 0 then
			self.bars.XPBar:SetValue((currXP/nextXP)*100)
		else
			self.bars.XPBar:SetValue(0)
		end

		self.bars.XPBar:SetStatusBarColor(XPColor.r, XPColor.g, XPColor.b)
		self.bars.XPBar.bg:SetVertexColor(XPColor.r, XPColor.g, XPColor.b, 0.25)
	else
		self.bars.XPBar:Hide()
		self.bars.XPBar.bg:Hide()
	end
end

function plugin.XPOnEnterPet(self)
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:ClearLines()
	local _,eClass = UnitClass("player")

	if ( eClass == "HUNTER") then
		currXP, nextXP = GetPetExperience()
		local toLevelXP = nextXP - currXP

		GameTooltip:AddLine(string.format(L["Pet XP: %d/%d (%.1f%%)"], currXP, nextXP, currXP/nextXP*100))
		GameTooltip:AddLine(L["Next level XP : "] .. toLevelXP.."")
		GameTooltip:AddLine()

		local happiness, damagePercentage, loyaltyRate = GetPetHappiness()
		happiness = ({L["|cffff0000Unhappy|r"], L["|cffffff00Content|r"], L["|cff00ff00Happy|r"]})[happiness]
--		local loyalty = loyaltyRate > 0 and "Gaining" or "Losing"

		GameTooltip:AddLine(L["Pet is "] .. happiness .. L[", doing |cff00ff00"] .. damagePercentage .. L["%|r damage"])
--		GameTooltip:AddLine(loyalty .. " loyalty")
	end
	GameTooltip:Show()
end
