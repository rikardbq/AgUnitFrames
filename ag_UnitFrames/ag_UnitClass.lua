local L = aUFLocale
local media = LibStub("LibSharedMedia-3.0")
local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")

local newFrame, delFrame = aUF.newFrame, aUF.delFrame

local _G = getfenv(0)

local del, new = aUF.del, aUF.new

local defaultLayout = aUF.layouts.ABF

------------
-- SYSTEM --
------------

function aUF:NewClass(inherit)
	local c = {}
	c.prototype = {}
	if inherit then
		c.super = inherit
		setmetatable(c.prototype, {__index = c.super.prototype})
	end
	function c:new(...)
		local o = {}
		setmetatable(o, {__index = self.prototype})
		if o.init then
			o:init(...)
		end
		return o
	end
	return c
end

aUF.classes.aUFunit = aUF:NewClass()
aUF.classes.aUFunitPlayer = aUF:NewClass(aUF.classes.aUFunit)
aUF.classes.aUFunitCombo = aUF:NewClass(aUF.classes.aUFunit)
aUF.classes.aUFunitFocus = aUF:NewClass(aUF.classes.aUFunit)
aUF.classes.aUFunitMetro = aUF:NewClass(aUF.classes.aUFunit)

function aUF.classes.aUFunit:ToString()
	return "aUFunit"
end

local aUFunitClass = aUF.classes.aUFunit.prototype

function aUFunitClass:init(frame,unit,grouped,type)
	self.name = frame:GetName()
	self.frame = frame
	self.frame.object = self
	self.shown = nil
	
	self:SetupFrame()
	
    self.grouped = grouped
	if self.frame and unit then
		local suffix = self.frame:GetAttribute("unitsuffix")
		local suffixunit
		if suffix then
			suffixunit = aUF:UnitSuffix(unit,suffix)
		end
		self:UnitReset(suffixunit or unit)
		self.frame:SetAttribute("unit", unit)
	elseif type then
		self.grouped = true
		self:TypeReset(type)
	end
	self:SetAttributes()
end

function aUFunitClass:TypeReset(unitType)
	if not unitType then
		return
	end
	if self.type ~= unitType then
		self.type = unitType
		self:Enable()
		self:ExecModuleMethods("OnTypeReset")
	end
end

function aUFunitClass:UnitReset(unit)
	if not unit then return end
	if self.unit and self.unit == unit then return end
		
	local oldtype = self.type
	local oldunit = self.unit
	
	self.unit = unit
	_, _, self.number = unit:find("(%d+)")	
	local unitType = unit:gsub("%d", "")
	if not self.type or self.type ~= unitType then
		self:TypeReset(unitType)
	end
	if (unit) then
		if oldtype then
			aUF:UnregisterUnit(self, oldunit, oldtype)
			aUF:RegisterUnit(self, self.unit, self.type)
		else
			aUF:RegisterUnit(self, self.unit, self.type)
		end
	elseif oldunit and oldtype then
		aUF:UnregisterUnit(self, oldunit, oldtype)
	end
	
	if unit:find("pet") then
		if self.type == "partypet" or self.type == "raidpet" then
			self.parent = unit:gsub("pet","")
		else
			self.parent = "player"
		end
    end
	self:ExecModuleMethods("OnUnitReset")
	self:Enable()
end

function aUFunitClass:ExecModuleMethods(method, ...)
	if aUF.modules then
		for k,v in pairs(aUF.modules) do
			if v:IsEnabled() and v[method] and (not v.inherit or self.type == v.inherit or v.inherit[self.type]) then
				v[method](v, self, ...)
			end
		end
	end
end

function aUFunitClass:RegisterUnitEvent(event, method)
	aUF:RegisterEvent(self, event, method, true)
end

function aUFunitClass:UnregisterUnitEvent(event, method)
	aUF:UnregisterEvent(self, event, method, true)
end

function aUFunitClass:RegisterEvent(event, method)
	aUF:RegisterEvent(self, event, method)
end

function aUFunitClass:UnregisterEvent(event, method)
	aUF:UnregisterEvent(self, event, method)
end

function aUFunitClass:RegisterEvents()
	self:RegisterUnitEvent("UNIT_HEALTH", "DisplayStatus")
end

-----------------
-- FRAME SETUP --
-----------------

local function onShow(frame)
	local self = frame.object
	if self then
		if self.Start then
			self:Start()
		end
		if not self.shown then	
			self.shown = true
			self:UpdateAll()
		end
	end
end

local function onHide(frame)
	local object = frame.object
	if aUF.setupMode and (not InCombatLockdown()) and object.database and object.database.enabled and object.enabled then
		frame:Show()
		return
	end
	if object then
		if object.Stop then
			object:Stop()
		end	
		object:UpdateAll(true)
		frame:StopMovingOrSizing()
	end
	if not object.frame.header then
		object.shown = nil
	end
end

local function onUpdate(frame)
	local object = frame.object
	if not object.onUpdate then return end
	for func, arg in pairs(object.onUpdate) do
		if type(func) == "function" then
			func(object)
		else
			object[func](object, arg)
		end
	end
end

function aUFunitClass:RegisterOnUpdate(func, arg)
	if not self.onUpdate then
		self.onUpdate = {}
	end
	self.onUpdate[func] = true or arg
end

function aUFunitClass:UnregisterOnUpdate(func)
	if not self.onUpdate then return end
	self.onUpdate[func] = nil
end

function aUFunitClass:UnregisterAllOnUpdate()
	if not self.onUpdate then return end
	for func in pairs(self.onUpdate) do
		self.onUpdate[func] = nil
	end
end

function aUFunitClass:AttributeChanged(name,value)
	if name ~= "unit" then return end
	local unit = aUF:UnitSuffix(value,self.frame:GetAttribute("unitsuffix"))
	if self.frame then
		if unit then
			local unitname = UnitName(unit)
			if self.frame.header and (self.unit == unit and self.lastName == unitname) then
				return
			end
			self:UnitReset(unit)
			self.lastName = unitname
			if self.shown then
				self:UpdateAll()
			end
			if self.childFrames then
				for k, v in pairs(self.childFrames) do
					v:AttributeChanged("unit",SecureButton_GetModifiedAttribute(v.frame,"unit"))
				end
			end
		else
			self.lastName = nil
			self.shown = nil
		end
	end
end

local function onAttributeChanged(frame, name, value)
	local object = frame.object
	if object then
		object:AttributeChanged(name,value)
	end
end

local function onShowMenu(self)
	self.object:DropDownUnit()
end

function aUFunitClass:SetupFrame()
	local top = newFrame("Frame", self.frame)
	top:SetFrameLevel(self.frame:GetFrameLevel()+3)
	self.top = top
	local middle = newFrame("Frame", self.frame)
	middle:SetFrameLevel(self.frame:GetFrameLevel()+2)
	self.middle = middle
	
	self.bars = {}
	self.strings = {}
	self.icons = {}
	
	self.frame:SetScript("OnAttributeChanged", onAttributeChanged)
	self.frame:SetScript("OnShow", onShow)
	self.frame:SetScript("OnHide", onHide)
	self.frame:SetScript("OnUpdate", onUpdate)
	self.frame:SetScript("OnEnter", function() self:OnEnter() end)
	self.frame:SetScript("OnLeave", function() self:OnLeave() end)
	self.frame:SetScript("OnDragStart", function() self:OnDragStart(arg1) end)
	self.frame:SetScript("OnDragStop", function() self:OnDragStop(arg1) end)
	
	self.frame:SetMovable(true)
	self.frame:RegisterForDrag("LeftButton")
	self.frame:RegisterForClicks("LeftButtonUp","RightButtonUp","MiddleButtonUp","Button4Up","Button5Up")
	self.frame.menu = onShowMenu
end

function aUFunitClass:SetAttributes()
	self.frame:SetAttribute("*type1","target")
	self.frame:SetAttribute("*type2","menu")

	ClickCastFrames = ClickCastFrames or {}
	ClickCastFrames[self.frame] = true
end

function aUFunitClass:LoadScale()	
	local themetable = aUF.layouts[self.database.FrameStyle or defaultLayout]
	if themetable and themetable.LoadScale then
		themetable:LoadScale(self)
	end
end

function aUFunitClass:BorderBackground()
	local themetable = aUF.layouts[self.database.FrameStyle or defaultLayout]
	if themetable and themetable.BorderBackground then
		themetable:BorderBackground(self)
	end
end

function aUFunitClass:LoadPosition()
	if self.grouped == true then return end
	self.frame:ClearAllPoints()
	local position = aUF.db.profile.Positions[self.name]
	if type(position) == "table" then
		local x, y, point, relPoint = position.x, position.y, position.point, position.relPoint
		local s = self.frame:GetEffectiveScale()
		x, y = x/s, y/s
		self.frame:ClearAllPoints()
		self.frame:SetPoint(point or "TOPLEFT", UIParent, relPoint or "TOPLEFT", x, y)
		local point, parent, relPoint, x, y = self.frame:GetPoint()
	else
		self.frame:SetPoint("CENTER", UIParent, "CENTER")
	end
end

function aUFunitClass:SavePosition()
	local point, parent, relPoint, x, y = self.frame:GetPoint()
	local s = self.frame:GetEffectiveScale()
	x, y = x*s, y*s
	if not aUF.db.profile.Positions[self.name] then
		aUF.db.profile.Positions[self.name] = {}
	end
	local position = aUF.db.profile.Positions[self.name]
	position.x, position.y = x, y
	position.point, position.relPoint = point, relPoint
end

function aUFunitClass:ApplyLayout(reset)
	local themetable = aUF.layouts[self.database.FrameStyle or defaultLayout]

	if reset and themetable.db then
		themetable.db:ResetProfile()
	end
	
    local height = self.database.Height
    self.frame:SetHeight(height)
	
	local frameWidth = self.database.Width    
	self.frame:SetWidth(frameWidth)
	
	themetable:ApplyLayout(self)
	
	self:UpdateBarTexture()
	self:UpdateTextStrings()
	self:ExecModuleMethods("OnLayoutApplied")
end

function aUFunitClass:UpdateBarTexture()
	self:ExecModuleMethods("OnSetBarTexture")
end

function aUFunitClass:UpdateBarColor()
	self:ExecModuleMethods("OnStatusBarsColor")
end

function aUFunitClass:UnapplyLayout()
	local themetable = aUF.layouts[self.database.FrameStyle or defaultLayout]
	themetable:UnapplyLayout(self)
end

function aUFunitClass:IsEnabled()
	return self.enabled
end

function aUFunitClass:Enable()
	if self:IsEnabled() then return end
	self.database = aUF.db.profile.units[self.type]
	self.enabled = true
	self:ExecModuleMethods("OnObjectEnable")
	if not InCombatLockdown() then
		self:LoadScale()
		self:LoadPosition()		
		self:ApplyLayout()
		self:BorderBackground()
		self:UpdateChildFrames()
		self:SetUnitWatch()
	end
    if self.frame.header then
		return
	end
	if not self.unit then
		return
	end	
	aUF:RegisterUnit(self, self.unit, self.type)
	self.eventsRegistered = true
	if self.RegisterEvents then
		self:RegisterEvents()
	end
	self:ExecModuleMethods("OnRegisterEvents")
end

function aUFunitClass:Show()
    if self.frame.header then
		return
	end
	if not self.unit then
		return
	end
    self.hidden = nil
	self:SetUnitWatch()
end

function aUFunitClass:Hide(power)
    if self.frame.header then
		return
	end
	if power then
		self.enabled = nil
	else
		self.hidden = true
		if self.unit then
			aUF:UnregisterUnit(self, self.unit, self.type)
		end
	end
	if not (InCombatLockdown()) then
		self:SetUnitWatch(true)
	end
	if self.childFrames then
		for k, v in pairs(self.childFrames) do
			if power then
				v:Disable()
			else
				v:Hide()
			end
		end
	end
end

function aUFunitClass:Disable()
	self.eventsRegistered = nil
	self:Hide(true)
	self:ExecModuleMethods("OnObjectDisable")
end

function aUFunitClass:UpdateSetupMode(flag)
	if self.frame:IsVisible() then
		self:DisplayStatus()
		self:UpdateTextStrings()
	end
	self:SetUnitWatch()
	self:ExecModuleMethods("OnUpdateSetupMode", (flag and true) or false)
end

function aUFunitClass:SetUnitWatch(flag)
	if (not self.database.enabled) or flag then
		UnregisterUnitWatch(self.frame)
		self.frame:Hide()
	elseif aUF.setupMode and self.database.enabled and self.enabled then
		UnregisterUnitWatch(self.frame)
		self.frame:Show()	
	else
		RegisterUnitWatch(self.frame, false)
	end
end

local partyChildren = {"pet","target"}
local petPos = { "TOPRIGHT", "RIGHT", "BOTTOMRIGHT", "TOPLEFT", "LEFT", "BOTTOMLEFT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT", "TOPLEFT", "TOP", "TOPRIGHT"}
local parentPos = { "TOPLEFT", "LEFT", "BOTTOMLEFT", "TOPRIGHT", "RIGHT", "BOTTOMRIGHT", "TOPLEFT", "TOP", "TOPRIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
function aUFunitClass:UpdateChildFrames()
	for _, v in pairs(partyChildren) do
		local petType = self.type..v
		if aUF.db.profile.units[petType] and aUF.db.profile.units[petType].GroupWith == "parent" then
			if not self.childFrames then
				self.childFrames = {}
			end
			if not self.childFrames[v] then
				self:CreateChild(v)
			elseif self.childFrames and not (self.childFrames[v].enabled) then
				self.childFrames[v]:Enable()
			end
			
			local pos = aUF.db.profile.units[petType].PetPos
			self.childFrames[v].frame:ClearAllPoints()
			self.childFrames[v].frame:SetPoint(petPos[pos] or "LEFT",self.frame,parentPos[pos] or "RIGHT")
	
		elseif self.childFrames and self.childFrames[v] and self.childFrames[v].enabled then
			self.childFrames[v]:Disable()
		end
	end
end

function aUFunitClass:CreateChild(class)
	local kind
	if string.find(class, "target") then
		kind = "Metro"
	end
	
	local name = "aUF"..self.name..class
	local frame = CreateFrame("Button", name, parent or UIParent, "SecureUnitButtonTemplate")

	frame:SetParent(self.frame)		
	frame:SetAttribute("useparent-unit","true")
	frame:SetAttribute("unitsuffix",class)
	
	self.childFrames[class] = aUF.classes["aUFunit"..(kind or "")]:new(frame,self.unit,true,self.type..class)
	aUF.units[name] = self.childFrames[class]
end

-------------
-- UPDATES --
-------------

function aUFunitClass:UpdateAll(unload)
	if not self.database or not self.unit or not (self.enabled) then return end
	if not unload and self.database.enabled then
		self:ExecModuleMethods("OnUpdateAll")
		self:UpdateTextStrings()
--		if not InCombatLockdown() then
--			self:UpdateChildFrames()
--		end
		if self.RegisterEvents and not self.eventsRegistered then
			self:RegisterEvents()
			self:ExecModuleMethods("OnRegisterEvents")
		end
	else
		if self.pet then
			self.pet:Disable()
		end
 		self:ExecModuleMethods("OnDisableObject")
	end
end

local strings = {}
function aUFunitClass:RegisterString(frame, tag)
	local layout = aUF.layouts[self.database.FrameStyle or defaultLayout]
	if (not frame) or (not tag) then return end
	if frame.updateFunc then
		self:UnregisterString(frame)
	end
	if not strings[self] then
		strings[self] = {}
	end
	strings[self][frame] = true	
	if not (frame.updateFunc) then
		local func, events, onupdate = aUF:FormatString(tag)
		if func then
			frame.updateFunc = function()
				if not self.unit then return end
				if frame:IsShown() and not frame.override then
					frame:SetText(func(self.unit))
				end
			end
		end
		if (onupdate and onupdate[self.type]) or self.metro then
			self:RegisterOnUpdate(frame.updateFunc)
			frame.onupdate = true
		elseif events then
			frame.events = events
			for i, j in pairs(frame.events) do
				self:RegisterEvent(i, frame.updateFunc)
			end
		end
	end
end

function aUFunitClass:UnregisterAllStrings()
	for k in pairs(strings[self]) do
		self:UnregisterString(k)
	end
end

function aUFunitClass:UnregisterString(frame)
	if frame then
		if strings[self] and strings[self][frame] then
			strings[self][frame] = nil
		end
		if frame.onupdate then
			self:UnregisterOnUpdate(frame.updateFunc)
		elseif frame.events then
			for i, j in pairs(frame.events) do
				if frame.updateFunc then
					self:UnregisterEvent(i, frame.updateFunc)
				end
			end
		end
		frame.updateFunc = nil
		frame.events = nil
		if frame:GetText() then
			frame:SetText("")
		end
	end
end

function aUFunitClass:UpdateTextString(frame)
	if frame and frame:IsShown() then
		if frame.updateFunc and not frame.override then
			frame.updateFunc()
		end
	end
end

function aUFunitClass:UpdateTextStrings()
	self:DisplayStatus()
	local themetable = aUF.layouts[self.database.FrameStyle or defaultLayout]
	if strings[self] then
		for k,v in pairs(strings[self]) do
			self:UpdateTextString(k)
		end
	end
end

function aUFunitClass:DisplayStatus()
	local statusString = self.statusText
	if not (statusString) then
		return
	end
	
	if self.unit and not aUF.setupMode then
		local maxValue = UnitHealthMax(self.unit)
		if ( UnitIsDead(self.unit) ) then
			statusString:SetText(L["dead"])
			statusString.override = true
			return
		elseif ( UnitIsGhost(self.unit) ) then
			statusString:SetText(L["ghost"])
			statusString.override = true
			return
		elseif ( not UnitIsConnected(self.unit) ) then
			statusString:SetText(L["disc"])
			statusString.override = true
			return
		elseif ( maxValue == 1 ) then
			statusString:SetText(L["N/A"])
			statusString.override = true
			return	
		elseif statusString.override == true then
			statusString.override = false
			statusString:SetText("")
			self:UpdateTextString(statusText)
		end
	else
		statusString:SetText(L["Config: "]..(self.type or ""))
		statusString.override = true
		return
	end
end

-----------------------
-- MOUSE INTERACTION --
-----------------------

function aUFunitClass:OnDragStart(button)
	if self.grouped then
        if self.frame:GetParent().object then
            self.frame:GetParent().object:OnDragStart(button)
        end
		return
    end
	if button == "LeftButton" and not (aUF.db.profile.Locked) then
		self.frame:StartMoving()
	end
end

function aUFunitClass:OnDragStop(button)
	if self.grouped then
        if self.frame:GetParent().object then
		self.frame:GetParent().object:OnDragStop(button)
        end
		return
	end
	self.frame:StopMovingOrSizing()
	self:SavePosition()
	self.frame:SetUserPlaced(false)
end



function aUFunitClass:OnEnter()
	self:ExecModuleMethods("OnEnter")
	if self.unit then
		self.frame.unit = self.unit
		UnitFrame_OnEnter(self.frame)
	end
end

function aUFunitClass:OnLeave()
	self:ExecModuleMethods("OnLeave")
	UnitFrame_OnLeave(self.frame)
end

function aUFunitClass:DropDownUnit()
	local type = nil
	
	if self.unit == "player" then
		type = PlayerFrameDropDown
	elseif self.unit == "target" then
		type = TargetFrameDropDown
	elseif self.unit == "pet" then
		type = PetFrameDropDown
	elseif self.type == "party" then
		type = _G["PartyMemberFrame"..self.number.."DropDown"]
	elseif self.unit:find("raid") then
		type = FriendsDropDown
		FriendsDropDown.displayMode = "MENU"
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
	end

	if type then
		HideDropDownMenu(1)
		type.unit = self.unit
		type.name = UnitName(self.unit)
		type.id = self.number
		ToggleDropDownMenu(1, nil, type,"cursor")
	end
end

---------------------
-- TARGET SUBCLASS --
---------------------

function aUF.classes.aUFunitCombo.prototype:RegisterEvents()
	self:RegisterEvent("PLAYER_TARGET_CHANGED","TargetChanged")
	self:RegisterUnitEvent("UNIT_HEALTH", "DisplayStatus")
end

function aUF.classes.aUFunitCombo.prototype:TargetChanged()
	if UnitExists(self.unit) and self.frame:IsVisible() then
		self:UpdateAll()
		CloseDropDownMenus()
	end
end

---------------------
-- FOCUS SUBCLASS --
---------------------

function aUF.classes.aUFunitFocus.prototype:RegisterEvents()
	self:RegisterEvent("PLAYER_FOCUS_CHANGED","FocusChanged")
	self:RegisterUnitEvent("UNIT_HEALTH", "DisplayStatus")
end

function aUF.classes.aUFunitFocus.prototype:FocusChanged()
	if UnitExists(self.unit) and self.frame:IsVisible() then
		self:UpdateAll()
	end
end

-----------------------
-- ONUPDATE SUBCLASS --
-----------------------

aUF.classes.aUFunitMetro.prototype.RegisterEvents = false
aUF.classes.aUFunitMetro.prototype.metro = true

function aUF.classes.aUFunitMetro.prototype:UpdateMetro(force)
	if self.unit and (force or self.frame:IsVisible()) then
		self:ExecModuleMethods("OnMetroUpdate")
		if self.unitName and self.unitName ~= UnitName(self.unit) then
			self:UpdateAll()
		end
	end
	self.unitName = self.unit and UnitName(self.unit)
end

function aUF.classes.aUFunitMetro.prototype:Start()
	if self.database.enabled then
		if not self.schedule then
			local time = 0.25
			if self.unit and string.find(self.unit, "player") then
				time = 0.1
			end
			self.schedule = aUF.StartTimer(self, "UpdateMetro", time)
		end
		self:UpdateMetro()
	end
end

function aUF.classes.aUFunitMetro.prototype:Stop()
	if self.schedule then
		aUF.CancelTimer(self, self.schedule)
		self.schedule = nil
	end
	self:UpdateMetro()
end
