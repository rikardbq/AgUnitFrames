if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
	-- Non-Death Knights suck and cannot stand the awesomeness of this module.
	return
end

local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

local plugin = aUF:NewModule("RuneBar")
plugin.inherit = {["player"]=true}

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			["**"] = {
			},
		}
	})

	self.subConfig = "Bars"
end

function plugin:OnRegisterEvents(object, power)
	if not power then
		object:RegisterEvent("RUNE_POWER_UPDATE", "UpdateRunePower")
		object:RegisterEvent("RUNE_TYPE_UPDATE", "UpdateRune")
		object:RegisterEvent("RUNE_REGEN_UPDATE", "UpdateRune")
	else
		object:UnregisterEvent("RUNE_POWER_UPDATE", "UpdateRune")
		object:UnregisterEvent("RUNE_TYPE_UPDATE", "UpdateRune")
		object:UnregisterEvent("RUNE_REGEN_UPDATE", "UpdateRune")
	end
end

function plugin:OnEnable()
	aUF:RegisterBarType("RuneBar", "player")
	RuneFrame:Hide()
	for _,object in aUF:IterateUnitObjects() do
		if object.type and object.type == "player" and object.unit then
			object:ApplyLayout()
			self:OnRegisterEvents(object)
		end
	end
end

function plugin:OnDisable()
	aUF:UnregisterBarType("RuneBar", "player")
	RuneFrame:Show()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectDisable()
	end
end

function plugin:OnObjectDisable()
	for _,object in aUF:IterateUnitObjects() do
		if object.bars.RuneBar then
			self:OnRegisterEvents(object)
			for i = 1,6 do
				object.bars.RuneBar["Rune"..i] = delFrame(object.bars.RuneBar["Rune"..i])
			end
			object.bars.RuneBar.bg = delFrame(object.bars.RuneBar.bg)
			object.bars.RuneBar = delFrame(object.bars.RuneBar)
			object:ApplyLayout()
		end
	end
end

function plugin:OnUpdateAll(object)
	object:UpdateRune()
end

function plugin:OnMetroUpdate(object)
	object:UpdateRune()
end

function plugin:OnLayoutApplied(object)
	if object.bars.RuneBar then
		local width, height
		for i = 1,6 do
			local bar = object.bars.RuneBar["Rune"..i]
			local orientation = object.bars.RuneBar:GetOrientation() == "VERTICAL"
			bar:ClearAllPoints()
			if orientation then
				width = object.bars.RuneBar:GetWidth()
				height = (object.bars.RuneBar:GetHeight()-5)/6			
				if i == 1 then
					bar:SetPoint("TOPLEFT",object.bars.RuneBar)
				else
					bar:SetPoint("TOPLEFT",object.bars.RuneBar["Rune"..(i-1)],"BOTTOMLEFT", 0, -1)
				end
				bar:SetWidth(width)
				bar:SetHeight(height)
			else
				width = (object.bars.RuneBar:GetWidth()-5)/6
				height = object.bars.RuneBar:GetHeight()
				if i == 1 then
					bar:SetPoint("TOPLEFT",object.bars.RuneBar)
				else
					bar:SetPoint("TOPLEFT",object.bars.RuneBar["Rune"..(i-1)],"TOPRIGHT", 1, 0)
				end
				bar:SetWidth(width)
				bar:SetHeight(height)			
			end
		end	
	end
end

function plugin:OnSetBarTexture(object)
	local m = aUF:GetBarTexture()
	if object.bars.RuneBar then
		object.bars.RuneBar:SetStatusBarTexture(m,"BORDER")
	end
	for i = 1,6 do
		local bar = object.bars.RuneBar["Rune"..i]
		bar:SetStatusBarTexture(m,"BORDER")
		bar.bg:SetTexture(m,"BORDER")
	end
end

local runeID = {
	[1] = 1,
	[2] = 2,
	[3] = 5,
	[4] = 6,
	[5] = 3,
	[6] = 4,
}

function plugin:OnObjectEnable(object)
	local bars = object.bars
	if not bars.RuneBar then
		bars.RuneBar = newFrame("StatusBar", object.frame)	
		
		bars.RuneBar:SetMinMaxValues(0,100)
		bars.RuneBar:SetValue(0)

		for i = 1,6 do
			bars.RuneBar["Rune"..i] = newFrame("StatusBar", object.frame)
			bars.RuneBar["Rune"..i]:SetMinMaxValues(0,1000)
			bars.RuneBar["Rune"..i]:SetID(runeID[i])
			bars.RuneBar["Rune"..i].bg = newFrame("Texture", object.frame, "BORDER")
			bars.RuneBar["Rune"..i].bg:ClearAllPoints()
			bars.RuneBar["Rune"..i].bg:SetAllPoints(bars.RuneBar["Rune"..i])
		end
	end
end

local eventFrame = CreateFrame("Frame")

---------------
-- STATUSBAR --
---------------

local runeTextures = {
	[1] = {r = 1, g = 0, b = 0.4},
	[2] = {r = 0, g = 1, b = 0.4},
	[3] = {r = 0, g = 0.4, b = 1},
	[4] = {r = 0.7, g = 0.5, b = 1},
}

local flashLength = 0.4
local maxColor = 1
local function RuneButton_OnUpdate(self, elapsed)
	local start, duration, runeReady = GetRuneCooldown(self:GetID())
	self:SetValue(min(((GetTime() - start)/duration) * 1000,1000))
	self:SetAlpha(0 + min(((GetTime() - start)/duration)*0.4,0.4))

	if ( runeReady ) then
		if not self.flashStart then
			self.flashStart = GetTime()
		end
		local runeType = GetRuneType(self:GetID())
		if (GetTime() > self.flashStart + flashLength) or (not runeType) then
			self:SetScript("OnUpdate", nil)
			self:SetValue(1000)
			self:SetAlpha(0.8)
			if runeType then
				self:SetStatusBarColor(self.r, self.g, self.b)
			end
			self.flashStart = nil
			self.r = nil
			self.g = nil
			self.b = nil
		else
			local frac = max(1 - ((GetTime() - self.flashStart)/flashLength),0)
			if runeType then
				local r, g, b
				r = self.r or runeTextures[runeType].r
				g = self.g or runeTextures[runeType].g
				b = self.b or runeTextures[runeType].b
				if not self.r then
					self.r = r
					self.g = g
					self.b = b
				end
				self:SetStatusBarColor((maxColor - min(r, maxColor))*frac + r, (maxColor - min(g, maxColor))*frac + g, (maxColor - min(b, maxColor))*frac + b)
				self:SetAlpha(0.4 + 0.4* (1 - frac))
			end
		end
	end
end

function aUF.classes.aUFunit.prototype:UpdateRunePower(event, rune, usable)
	local runeType, color
	for i = 1,6 do
		if runeID[i] == rune and not usable then
			runeType = GetRuneType(rune)
			if runeType then
				color = runeTextures[runeType]
				self.bars.RuneBar["Rune"..i]:SetScript("OnUpdate", RuneButton_OnUpdate)
				self.bars.RuneBar["Rune"..i]:SetStatusBarColor((color.r + 0.5 / 2), (color.g + 0.5 / 2), (color.b + 0.5 / 2))
			end
		end
	end
end

function aUF.classes.aUFunit.prototype:UpdateRune(event, rune)	
	local runeType, color
	if rune then
		runeType = GetRuneType(rune)
		if runeType then
			color = runeTextures[runeType]
			self.bars.RuneBar["Rune"..runeID[rune]]:SetAlpha(0.8)
			self.bars.RuneBar["Rune"..runeID[rune]]:SetStatusBarColor(color.r, color.g, color.b)
			self.bars.RuneBar["Rune"..runeID[rune]].bg:SetVertexColor(0.25, 0.25, 0.25, 0.15)
		end
	else
		for i = 1,6 do
			runeType = GetRuneType(i)
			if runeType then
				color = runeTextures[runeType]
				self.bars.RuneBar["Rune"..runeID[i]]:SetAlpha(0.8)
				self.bars.RuneBar["Rune"..runeID[i]]:SetStatusBarColor(color.r, color.g, color.b)
				self.bars.RuneBar["Rune"..runeID[i]].bg:SetVertexColor(0.25, 0.25, 0.25, 0.25)
			end
		end
	end
end