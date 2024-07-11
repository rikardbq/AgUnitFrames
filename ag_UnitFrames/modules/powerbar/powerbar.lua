local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

local plugin = aUF:NewModule("Powerbar")

local enabledObjects = {}
local activeframes = {}
local DURATION = 0.5
local fadeFrame = CreateFrame("Frame")
local _abs, _cos, _pi = math.abs, math.cos, math.pi

local function CosineInterpolate(y1, y2, mu)
	local mu2 = (1-_cos(mu*_pi))/2
	return y1*(1-mu2)+y2*mu2
end

local function updateFaders(self)
	local now, stop, alpha = GetTime()
	local ran = false
	for frame, object in pairs(activeframes) do
		ran = true
		stop, alpha = frame.stop
		if stop < now then
			-- done.  set both bar values to the dest value, nuke entry in activeframes, set alpha to 0
			activeframes[frame] = nil
			-- set skipFade == true
			plugin.UpdatePower(object, true)
			frame.startValue = nil
			frame.destValue = nil
			frame:Hide()
			return
		end
		if frame.startValue < frame.destValue then
			alpha = (1 - ((stop - now) / DURATION))*0.7
		else
			alpha = ((stop - now) / DURATION)*0.7
		end
		if frame.style == "flash" then
			frame:SetAlpha(alpha)
		elseif frame.style == 'both' then
			frame:SetAlpha(alpha)
			local cVal = frame:GetValue()
			cVal = CosineInterpolate(cVal,frame.destValue, 1 - ((stop - now) / DURATION) )
			frame:SetValue(cVal)
		elseif frame.style == 'smooth' then
			local cVal = frame:GetValue()
			cVal = CosineInterpolate(cVal,frame.destValue, 1 - ((stop - now) / DURATION) )
			frame:SetValue(cVal)
		end
	end
	if not ran then
		self:Hide()
	end
end

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			["**"] = {
				ShowMana = true,
			},
			partypet = {
				ShowMana = false,
			},
			raid = {
				ShowMana = false,
			},
			raidpet = {
				ShowMana = false,
			},
			targettarget = {
				ShowMana = false,
			},
			targettargettarget = {
				ShowMana = false,
			},
			partytarget = {
				ShowMana = false,
			},
		}
	})

	self.subConfig = "Bars"
end

function plugin:OnEnable()
	aUF:RegisterBarType("ManaBar")
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectEnable(object)
		object:ApplyLayout()
		if object.unit then
			self:OnRegisterEvents(object)			
			object:UpdateAll()
		end
	end
	if not fadeFrame then
		fadeFrame = CreateFrame("Frame")
	end
	fadeFrame:SetScript("OnUpdate", updateFaders)
end

function plugin:OnDisable()
	aUF:UnregisterBarType("ManaBar")
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectDisable(object)
		object:ApplyLayout()
	end
end

function plugin:OnObjectDisable(object)
	if object.bars.ManaBar then
		object.bars.ManaBar.bg = delFrame(object.bars.ManaBar.bg)
		object.bars.ManaBar = delFrame(object.bars.ManaBar)
		self:OnRegisterEvents(object, true)
	end
	if fadeFrame then
		fadeFrame:Hide()
		fadeFrame:SetScript("OnUpdate", nil)
	end
end

local onUpdateFrame = CreateFrame("Frame")
onUpdateFrame.objects = {}
local function onUpdate()
	for k in pairs(onUpdateFrame.objects) do
		plugin:OnMetroUpdate(k)
	end
end
onUpdateFrame:SetScript("OnUpdate",onUpdate)

local function unregisterEvents(object)
	object:UnregisterUnitEvent("UNIT_MAXMANA", plugin.UpdatePower)
	object:UnregisterUnitEvent("UNIT_MANA", plugin.UpdatePower)
	object:UnregisterUnitEvent("UNIT_MAXRAGE", plugin.UpdatePower)
	object:UnregisterUnitEvent("UNIT_RAGE", plugin.UpdatePower)
	object:UnregisterUnitEvent("UNIT_MAXFOCUS", plugin.UpdatePower)
	object:UnregisterUnitEvent("UNIT_FOCUS", plugin.UpdatePower)
	object:UnregisterUnitEvent("UNIT_MAXENERGY", plugin.UpdatePower)
	object:UnregisterUnitEvent("UNIT_ENERGY", plugin.UpdatePower)
	object:UnregisterUnitEvent("UNIT_MAXRUNIC_POWER", plugin.UpdatePower)
	object:UnregisterUnitEvent("UNIT_RUNIC_POWER", plugin.UpdatePower)
	object:UnregisterUnitEvent("UNIT_DISPLAYPOWER",plugin.UpdatePower)
end

function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].ShowMana and not power then
		if object.type == "player" and not (plugin.db.profile.units[object.type].SmoothMana or plugin.db.profile.units[object.type].FadeMana) then
			object:RegisterOnUpdate(self.UpdatePower)
			unregisterEvents(object)
		else
			if object.type == "player" then
				object:UnregisterOnUpdate(self.UpdatePower)
			end
			object:RegisterUnitEvent("UNIT_MAXMANA", self.UpdatePower)
			object:RegisterUnitEvent("UNIT_MANA",	self.UpdatePower)
			object:RegisterUnitEvent("UNIT_MAXRAGE", self.UpdatePower)
			object:RegisterUnitEvent("UNIT_RAGE", self.UpdatePower)
			object:RegisterUnitEvent("UNIT_MAXFOCUS", self.UpdatePower)
			object:RegisterUnitEvent("UNIT_FOCUS", self.UpdatePower)
			object:RegisterUnitEvent("UNIT_MAXENERGY", self.UpdatePower)
			object:RegisterUnitEvent("UNIT_ENERGY", self.UpdatePower)
			object:RegisterUnitEvent("UNIT_MAXRUNIC_POWER", self.UpdatePower)
			object:RegisterUnitEvent("UNIT_RUNIC_POWER", self.UpdatePower)
			object:RegisterUnitEvent("UNIT_DISPLAYPOWER",self.UpdatePower)
		end
	else
		if object.type == "player" then
			object:UnregisterOnUpdate(self.UpdatePower)
		else
			unregisterEvents(object)
		end
	end
end

function plugin:OnUpdateAll(object)
	if (plugin.db.profile.units[object.type].ShowMana) and self:IsEnabled() then
		self.UpdatePower(object)
	end
end

function plugin:OnMetroUpdate(object)
	if (plugin.db.profile.units[object.type].ShowMana) and self:IsEnabled() then
		self.UpdatePower(object)
	end
end

function plugin:OnStatusBarsColor(object)
    if object.bars.ManaBar then
        self.UpdateColor(object)
    end
end

function plugin:OnSetBarTexture(object)
	local texture = aUF:GetBarTexture()
	if object.bars.ManaBar then
		object.bars.ManaBar:SetStatusBarTexture(texture)
	end
	if object.bars.ManaBar then
		object.bars.ManaBar.bg:SetTexture(texture)
	end
	if object.powerFade then
		object.powerFade:SetStatusBarTexture(texture)
	end
end

function plugin:OnObjectEnable(object, power)
	if plugin.db.profile.units[object.type].ShowMana then
		object.powertype = nil
		if not object.bars.ManaBar then
			object.bars.ManaBar = newFrame("StatusBar", object.frame)
			object.bars.ManaBar:SetMinMaxValues(0,100)
			object.bars.ManaBar.bg = newFrame("Texture", object.frame, "BORDER")
			object.bars.ManaBar.bg:SetDrawLayer("BORDER")
			object.bars.ManaBar.bg:ClearAllPoints()
			object.bars.ManaBar.bg:SetAllPoints(object.bars.ManaBar)
		end
	else
		if object.bars.ManaBar then
			object.bars.ManaBar.bg = delFrame(object.bars.ManaBar.bg)
			object.bars.ManaBar = delFrame(object.bars.ManaBar)
		end
	end
end

local function DrawFader(object)
	local powerFade
	if object.powerFade then
		powerFade = object.powerFade
	else
		powerFade = newFrame("StatusBar", object.frame)
	end
	object.powerFade = powerFade
	powerFade.object = object
	powerFade.destValue = nil
	powerFade.faderstop = nil
	powerFade:SetOrientation(object.bars.ManaBar:GetOrientation())
	powerFade:SetAllPoints(object.bars.ManaBar)
	powerFade:SetMinMaxValues(object.bars.ManaBar:GetMinMaxValues())
	powerFade:SetValue(object.bars.ManaBar:GetValue())
	powerFade:SetStatusBarTexture(aUF:GetBarTexture())
	powerFade:Hide()
	return powerFade
end

---------------
-- STATUSBAR --
---------------

function plugin.UpdatePower(self, skipFade)
	local currValue,maxValue = UnitMana(self.unit),UnitManaMax(self.unit)
	local perc = currValue/maxValue * 100
	--DURATION = aUF.
	-- db should be the object db
	local db = plugin.db.profile.units[self.type]
	if skipFade ~= true and (db.SmoothMana or db.FadeMana) then
		DURATION = aUF.db.profile.BarFadeTime
		if not self.powerFade then DrawFader(self) end
		local preValue = self.powerFade.destValue or self.bars.ManaBar:GetValue()
		local destValue = (maxValue == 0 and 0) or perc
		if _abs(destValue - preValue) >= 0.015 then
			local powerFade = self.powerFade
			if (not powerFade.startValue) then
				powerFade.startValue = preValue
				isFading = false
			end
			powerFade.stop = GetTime() + DURATION
			powerFade.destValue = destValue
			if (db.SmoothMana and db.FadeMana) then
				if preValue < destValue then
					self.bars.ManaBar:SetValue(preValue)
				end
				if (not isFading) then
					powerFade:SetValue(preValue)
				end
				powerFade:SetAlpha(0)
				powerFade.style = 'both'
			elseif db.SmoothMana then
				if preValue < destValue then
					self.bars.ManaBar:SetValue(preValue)
				end
				if (not isFading) then
					powerFade:SetValue(preValue)
				end
				powerFade:SetAlpha(0.7)
				powerFade.style = "smooth"
			elseif db.FadeMana then
				if preValue < destValue then
					powerFade:SetAlpha(0)
					self.bars.ManaBar:SetValue(preValue)
					if (not isFading) then
						powerFade:SetValue(destValue)
					end
				else
					if (not isFading) then
						powerFade:SetAlpha(0.7)
						powerFade:SetValue(preValue)
					end
				end
				powerFade.style = "flash"
			end
			powerFade:Show()
			activeframes[powerFade] = self
			fadeFrame:Show()
		end
	end

	if ( not UnitExists(self.unit) or UnitIsDead(self.unit) or UnitIsGhost(self.unit) or not UnitIsConnected(self.unit) or (currValue == 1 and maxValue == 1) or UnitHealthMax(self.unit) == 1 ) then
		if not self.bars.ManaBar then
			ChatFrame1:AddMessage("ERROR".." "..self.name.." "..(self.enabled and "TRUE" or "FALSE"))
		end
		self.bars.ManaBar:SetValue(0)
		perc = 0
	else
		if maxValue == 0 then
			self.bars.ManaBar:SetValue(0)
		else
			self.bars.ManaBar:SetValue(perc)
		end
	end
	if force or not (self.powertype) or (self.powertype ~= UnitPowerType(self.unit)) then
		plugin.UpdateColor(self)
	end
end

function plugin.UpdateColor(self)
    local db = aUF.db.profile
	self.powertype = UnitPowerType(self.unit)
	if self.powertype == -1 then self.powertype = 1 end
	local info = db.ManaColor[self.powertype]

	self.bars.ManaBar.bg:SetVertexColor(info.r,info.g,info.b,0.25)
	if (plugin.db.profile.units[self.type].SmoothMana or plugin.db.profile.units[self.type].FadeMana) then
		self.bars.ManaBar:SetStatusBarColor(info.r,info.g,info.b,1)
	else
		self.bars.ManaBar:SetStatusBarColor(info.r,info.g,info.b,0.8)
	end

	if self.powerFade then
		self.powerFade:SetStatusBarColor(self.bars.ManaBar:GetStatusBarColor())
	end
end
