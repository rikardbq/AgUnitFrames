local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

local plugin = aUF:NewModule("Healthbar")
-- Healthbar can't be disabled
plugin.hideFromMenu = true

local activeframes = {}
local DURATION = 0.5
local fadeFrame = CreateFrame("Frame")
local _abs, _cos, _pi = math.abs, math.cos, math.pi

local function CosineInterpolate(y1, y2, mu)
	local mu2 = (1 - _cos(mu * _pi)) / 2
	return y1 * (1 - mu2) + y2 * mu2
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
			plugin.UpdateHealth(object, true)
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
				ClassColorBars = true,
			},
			["target"] = {
				TargetShowHostile = true,
			}
		}
	})

	self.subConfig = "Bars"
end

function plugin:OnEnable()
	aUF:RegisterBarType("HealthBar")
end

function plugin:OnObjectEnable(object)
	local bars = object.bars
	if not bars.HealthBar then
		bars.HealthBar = newFrame("StatusBar", object.frame)	
		bars.HealthBar.bg = newFrame("Texture", object.frame, "BORDER")
		bars.HealthBar:SetMinMaxValues(0,100)
	end
end

function plugin:OnRegisterEvents(object)
	object:RegisterUnitEvent("UNIT_HEALTH", self.UpdateHealth)
	object:RegisterUnitEvent("UNIT_MAXHEALTH", self.UpdateHealth)
	object:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", self.UpdateAggro)
	if object.type == "pet" then
		object:RegisterEvent("UNIT_HAPPINESS", self.HealthBarColor)
	end
	if object.type:find("target") then
		object:RegisterUnitEvent("UNIT_FACTION", self.HealthBarColor)
	end
end

function plugin:OnObjectDisable(object)
	object:UnregisterUnitEvent("UNIT_HEALTH", self.UpdateHealth)
	object:UnregisterUnitEvent("UNIT_MAXHEALTH", self.UpdateHealth)
	object:UnregisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", self.UpdateAggro)
	object:UnregisterEvent("UNIT_HAPPINESS", self.HealthBarColor)
	object:UnregisterUnitEvent("UNIT_FACTION", self.HealthBarColor)
end

function plugin:OnUpdateAll(object)
	self.UpdateHealth(object)
	self.HealthBarColor(object)
end

function plugin:OnMetroUpdate(object)
	self.UpdateHealth(object)
end

function plugin:OnStatusBarsColor(object)
    if object.bars.HealthBar then
        self.HealthBarColor(object)
    end
end

function plugin:OnLayoutApplied(object)
	if object.bars.HealthBar then
		object.bars.HealthBar.bg:ClearAllPoints()
		object.bars.HealthBar.bg:SetAllPoints(object.bars.HealthBar)
	end
end

function plugin:OnSetBarTexture(object)
	local texture = aUF:GetBarTexture()
	if object.bars.HealthBar then
		object.bars.HealthBar:SetStatusBarTexture(texture,"BORDER")
	end
	if object.bars.HealthBar.bg then
		object.bars.HealthBar.bg:SetTexture(texture,"BORDER")
	end
	if object.healthFade then
		object.healthFade:SetStatusBarTexture(texture)
	end
end

local targets, victims, aggro, oldaggro = {}, {}, {}, {}
function plugin.UpdateAggro(object)
	local status = UnitThreatSituation(object.unit)
	
    if plugin.db.profile.units[object.type].AggroHealth and status and status == 3 then
		if not object.aggro then
			object.aggro = true
			plugin.HealthBarColor(object)
		end
	else
		if object.aggro then
			object.aggro = nil		
			plugin.HealthBarColor(object)
		end		
	end
end

local function DrawFader(object)
	local healthFade
	
    if object.healthFade then
		healthFade = object.healthFade
	else
		healthFade = newFrame("StatusBar", object.frame)
	end
	
    object.healthFade = healthFade
	healthFade.object = object
	healthFade.destValue = nil
	healthFade.faderstop = nil
	healthFade:SetOrientation(object.bars.HealthBar:GetOrientation())
	healthFade:SetAllPoints(object.bars.HealthBar)
	healthFade:SetMinMaxValues(object.bars.HealthBar:GetMinMaxValues())
	healthFade:SetValue(object.bars.HealthBar:GetValue())
	healthFade:SetStatusBarTexture(aUF:GetBarTexture())
	healthFade:Hide()
	-- hack in setting the updater function
	fadeFrame:SetScript("OnUpdate", updateFaders)
	return healthFade
end

---------------------
-- STATUSBAR COLOR --
---------------------
local colorTables = {
    tapped = {0.5, 0.5, 0.5},
    red = {0.9, 0.2, 0.3},
    yellow = {1, 0.85, 0.1},
    green = {0.4, 0.95, 0.3}
}

local function colorGradient(perc)
	local healthColor = aUF.db.profile.HealthColor
	if perc and perc >= 1 then
		return {healthColor.r, healthColor.g, healthColor.b}
	elseif (perc and perc <= 0) or not perc then
		return {colorTables.red[1], colorTables.red[2], colorTables.red[3]}
	end

	local _, relperc = math.modf(perc*2)
	local r1, g1, b1 = colorTables.red[1], colorTables.red[2], colorTables.red[3]
    local r2, g2, b2 = colorTables.yellow[1], colorTables.yellow[2], colorTables.yellow[3]
	if perc >= 0.5 then	
		r1, g1, b1 = colorTables.yellow[1], colorTables.yellow[2], colorTables.yellow[3]
		r2, g2, b2 = healthColor.r, healthColor.g, healthColor.b
    end
	return {r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc}
end

function plugin.HealthBarColor(self)
	local bar = self.bars.HealthBar
    local healthColor = aUF.db.profile.HealthColor
	local _, class = UnitClass(self.unit)
    local db = plugin.db.profile.units[self.type]
    local petHappiness = GetPetHappiness()

	if UnitIsTapped(self.unit) and not UnitIsTappedByPlayer(self.unit) then
        plugin.SetBarColor(self, colorTables.tapped)
	elseif db.AggroHealth and self.aggro then
        plugin.SetBarColor(self, colorTables.red)
	elseif (self.unit == "pet" and petHappiness) then
        local colorTable = colorTables.green
		if (petHappiness == 1) then
			colorTable = colorTables.red
		elseif (petHappiness == 2) then
			colorTable = colorTables.yellow
        end

        plugin.SetBarColor(self, colorTable)
	elseif not UnitIsFriend(self.unit, "player") and db.TargetShowHostile then
        local colorTable = {0.68, 0.33, 0.38}
		
        if (UnitPlayerControlled(self.unit)) then
            if UnitCanAttack("player", self.unit) then
				colorTable = colorTables.red
			end
		else
			local reaction = UnitReaction(self.unit, "player")
			
            if (reaction) then
				if reaction == 5 or reaction == 6 or reaction == 7 then
					colorTable = colorTables.green
				elseif reaction == 4 then
					colorTable = colorTables.yellow
				elseif reaction == 1 or reaction == 2 or reaction == 3 then
					colorTable = colorTables.red
				else
                    -- possible bug?
					return UnitReactionColor[reaction]
				end
			end
		end

        plugin.SetBarColor(self, colorTable)
	elseif (db.ClassColorBars and UnitIsPlayer(self.unit) and class and RAID_CLASS_COLORS[class]) then
		local raidColor = RAID_CLASS_COLORS[class]
        
        plugin.SetBarColor(self, {raidColor.r, raidColor.g, raidColor.b})
    elseif db.GradientHealth then
		local currValue, maxValue = UnitHealth(self.unit), UnitHealthMax(self.unit)
		plugin.SetBarColor(self, colorGradient(currValue / maxValue))
	else
        plugin.SetBarColor(self, {healthColor.r, healthColor.g, healthColor.b})
    end
	if (plugin.db.profile.units[self.type].SmoothHealth or plugin.db.profile.units[self.type].FadeHealth) then
		bar:SetAlpha(1)
	else
		bar:SetAlpha(0.8)
	end
end

function plugin.SetBarColor(self, colorTable)
	local bar = self.bars.HealthBar
	local bg = self.bars.HealthBar.bg
	local fade = self.healthFade
    local r, g, b = colorTable[1], colorTable[2], colorTable[3]
	
	if(r and g and b) then
		bar:SetStatusBarColor(r, g, b)
		bg:SetVertexColor(r, g, b, 0.25)
		if fade then
			fade:SetStatusBarColor(r, g, b)
		end	
	end
end

---------------
-- STATUSBAR --
---------------

function plugin.UpdateHealth(self, skipFade)
	local currValue, maxValue = UnitHealth(self.unit), UnitHealthMax(self.unit)
	local perc = currValue / maxValue * 100

	if (not UnitExists(self.unit) or UnitIsDead(self.unit) or UnitIsGhost(self.unit) or not UnitIsConnected(self.unit) or maxValue == 1) then
		perc = 0
		self.bars.HealthBar:SetValue(0)
	end

    local db = plugin.db.profile.units[self.type]
	
    if db.HealthDeficit then
		perc = 100 - perc
	end
	
    if skipFade ~= true and (db.SmoothHealth or db.FadeHealth) then
		DURATION = aUF.db.profile.BarFadeTime
		if not self.healthFade then
            DrawFader(self)
        end

		local preValue = self.healthFade.destValue or self.bars.HealthBar:GetValue()
		local destValue = (maxValue == 0 and 0) or perc
		
        if _abs(destValue - preValue) >= 0.015 then
			local healthFade = self.healthFade
            local isFading
			
            if (not healthFade.startValue) then
				healthFade.startValue = preValue
                isFading = false
			end

			healthFade.stop = GetTime() + DURATION
			healthFade.destValue = destValue
			
            if (db.SmoothHealth and db.FadeHealth) then
				if preValue < destValue then
					self.bars.HealthBar:SetValue(preValue)
				end
				if (not isFading) then
					healthFade:SetValue(preValue)
				end
				healthFade:SetAlpha(0)
				healthFade.style = 'both'
			elseif db.SmoothHealth then
				if preValue < destValue then
				                self.bars.HealthBar:SetValue(preValue)
				end
				if (not isFading) then
					healthFade:SetValue(preValue)
				end
				healthFade:SetAlpha(0.7)
				healthFade.style = "smooth"
			elseif db.FadeHealth then
				if preValue < destValue then
					healthFade:SetAlpha(0)
					self.bars.HealthBar:SetValue(preValue)
					if (not isFading) then
						healthFade:SetValue(destValue)
					end
				else
					if (not isFading) then
						healthFade:SetAlpha(0.7)
						healthFade:SetValue(preValue)
					end
				end
				healthFade.style = "flash"
			end
			healthFade:Show()
			activeframes[healthFade] = self
			fadeFrame:Show()
		end
	end
	self.bars.HealthBar:SetValue(perc)

	if db.HealthGradient then
		plugin.SetBarColor(self, colorGradient(currValue / maxValue))
	end
end
