local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local plugin = aUF:NewModule("Rangecheck")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

plugin.defaultDisabledState = true

local pool = {}

--borrowed from pitbull
local distanceCheckFunction
local distanceCheckFunctionLow
do
	local _,class = UnitClass("player")
	if class == "PRIEST" then
		distanceCheckFunction = function(unit) return IsSpellInRange(GetSpellInfo(29170), unit) == 1 or not UnitIsFriend("player", unit) end
	elseif class == "DRUID" then
		distanceCheckFunction = function(unit) return IsSpellInRange(GetSpellInfo(5185), unit) == 1 or not UnitIsFriend("player", unit) end
	elseif class == "PALADIN" then
		distanceCheckFunction = function(unit) return IsSpellInRange(GetSpellInfo(635), unit) == 1 or not UnitIsFriend("player", unit) end
	elseif class == "SHAMAN" then
		distanceCheckFunction = function(unit) return IsSpellInRange(GetSpellInfo(331), unit) == 1 or not UnitIsFriend("player", unit) end
	elseif class == "WARLOCK" then
		distanceCheckFunction = function(unit) return IsSpellInRange(GetSpellInfo(172), unit) == 1 or IsSpellInRange(GetSpellInfo(686), unit) == 1 or CheckInteractDistance(unit, 4) end
		distanceCheckFunctionLow = function(unit) return IsSpellInRange(GetSpellInfo(5782), unit) == 1 or UnitIsFriend("player", unit) end
	elseif class == "MAGE" then
		distanceCheckFunction = function(unit) return IsSpellInRange(GetSpellInfo(133), unit) == 1 or CheckInteractDistance(unit, 4) end
		distanceCheckFunctionLow = function(unit) return IsSpellInRange(GetSpellInfo(2136), unit) == 1 or UnitIsFriend("player", unit) end
	elseif class == "HUNTER" then
		distanceCheckFunction = function(unit) 
			return IsSpellInRange(UnitIsUnit(unit, "pet") == 1 and GetSpellInfo(136) or GetSpellInfo(75), unit) == 1 or CheckInteractDistance(unit, 4)
		end 
	else
		distanceCheckFunction = function(unit) return CheckInteractDistance(unit, 4) end
	end
end

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			["**"] = {
				rangeCheck = false,
			},		
		},		
	})
end

function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].rangeCheck and not power then
		if not self.schedule then          
			self.schedule = aUF.StartTimer(self, "UpdatePool", 0.7)
		end
		pool[object] = true
	else
		pool[object] = nil
		if next(pool) == nil and self.schedule then
			self:CancelTimer(self.schedule)
			self.schedule = nil
		end		
	end
end

function plugin:OnObjectDisable(object)
	object.frame:SetAlpha(1)
	pool[object] = nil
end

function plugin:OnUpdateAll(object)
	if plugin.db.profile.units[object.type].rangeCheck and self:IsEnabled() then
		self.RangeCheck(object)
		self:OnRegisterEvents(object)
	else
		object.frame:SetAlpha(1)
		self:OnRegisterEvents(object, true)
	end
end

function plugin:OnEnable()
	for _,object in aUF:IterateUnitObjects() do
		if plugin.db.profile.units[object.type].rangeCheck then
			if self.unit then
				self:OnRegisterEvents(object)
			end
		end
	end
end

function plugin:OnDisable()
	if self.schedule then
		self:CancelTimer(self.schedule)
		self.schedule = nil
	end
	for _,object in aUF:IterateUnitObjects() do
		object.frame:SetAlpha(1)
	end
end

function plugin:UpdatePool()
	if next(pool) == nil and self.schedule then
		self:CancelTimer(self.schedule)
		self.schedule = nil
	end
	for object in pairs(pool) do
		self.RangeCheck(object)
	end
end

function plugin.RangeCheck(self)
	local opacity = 0.4
	if pool[self] and self.frame:IsShown() then
		if distanceCheckFunction(self.unit) then
			if distanceCheckFunctionLow then
				if distanceCheckFunctionLow( self.unit ) then
					self.frame:SetAlpha(1)
				else
					self.frame:SetAlpha(opacity+(1-opacity)/2)
				end
			else
				self.frame:SetAlpha(1)
			end
		else
			self.frame:SetAlpha(opacity)
		end
	end
--[[
    if self.frame:IsShown() then
		ChatFrame1:AddMessage(UnitInRange(self.unit) and "yes" or "no")
		if(UnitIsConnected(self.unit) and not UnitInRange(self.unit)) then
			if(self.frame:GetAlpha() == 1) then
				self.frame:SetAlpha(opacity)
			end
		elseif(self.frame:GetAlpha() ~= 1) then
			self.frame:SetAlpha(1)
		end
	end
--]]	
end
