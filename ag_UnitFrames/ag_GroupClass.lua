local L = aUFLocale
local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")

-- Group class

aUF.classes.aUFgroup = aUF:NewClass()

local function partyOnEvent(frame, event)
	if frame:IsVisible() then
		if event == "PARTY_MEMBERS_CHANGED" or event == "UNIT_PET" then
			frame.object:UpdateTitle()
		end
	end
end

local function ClassOnShow(frame)
	frame.object:UpdateTitle()
end

function aUF.classes.aUFgroup.prototype:init(name,type,reset)
	self.name = name
	self.type = type

	self:CreateFrame()
	local self = self

	self.header:HookScript("OnEvent", partyOnEvent)
	self.header:HookScript("OnShow", ClassOnShow)

	self.header:SetAttribute("template","SecureUnitButtonTemplate")
	
	if self.type == "raid" then
		self:SetDefaults(reset)	
	else
		self.database = aUF.db.profile[type.."group"]
	end
	self:Enable()
end

function aUF.classes.aUFgroup.prototype:UpdateAll()
	self:BorderBackground()
	self:UpdateScale()
	self:LoadPosition()
	self:UpdateGrowth()
	self:UpdateGroupFilter()
	self:UpdateTitle()
end


function aUF.classes.aUFgroup.prototype:SetDefaults(reset)
	local groupdb = aUF.db.profile.subgroups[self.name]
	if reset then
		local aufDefaults = aUF.db.defaults.profile
		local defaults = aufDefaults.subgroups["**"]
		local nDefaults = aufDefaults.subgroups[self.name]
		for k in pairs(groupdb) do
			groupdb[k] = nil
		end
		for k in pairs(defaults) do
			groupdb[k] = defaults[k]
		end
		if nDefaults then
			for k in pairs(nDefaults) do
				groupdb[k] = nDefaults[k]
			end
		end
		groupdb.Exists = true
		self:SavePosition(true)
	end
	self.database = groupdb
end

function aUF.classes.aUFgroup.prototype:Reset()
--	self:UpdateAll()
end

local agFont = L["Interface\\AddOns\\ag_UnitFrames\\fonts\\barframes.ttf"]
function aUF.classes.aUFgroup.prototype:CreateFrame()
	local frameName = "aUF"..self.name.."Anchor"
	local frameNameHeader = "aUF"..self.name

	if self.type == "raid" then
		self.header = CreateFrame("Button",frameNameHeader,UIParent,"SecureRaidGroupHeaderTemplate")
	elseif self.type == "partypet" then
		self.header = CreateFrame("Button",frameNameHeader,UIParent,"SecurePartyPetHeaderTemplate")        
    else
		self.header = CreateFrame("Button",frameNameHeader,UIParent,"SecurePartyHeaderTemplate")
	end
	self.header:Hide()
	self.header:UnregisterEvent("UNIT_NAME_UPDATE")
	
	self.header.object = self
	self.header:EnableMouse(false)
	
	self.anchor = aUF.newFrame("Button",UIParent)
	self.anchor:SetHeight(20)
	self.anchor:SetWidth(120)
	self.title = aUF.newFrame("FontString", self.anchor, "OVERLAY")
	self.title:SetFont(agFont,9)
	self.title:SetShadowColor(0, 0, 0)
	self.title:SetShadowOffset(0.8, -0.8)
	self.title:SetPoint("CENTER", self.anchor, "CENTER", 0, 1)
	
	self.anchor:SetScript("OnDragStart",function(frame, arg1) self:OnDragStart(arg1) end)
	self.anchor:SetScript("OnDragStop",function(frame, arg1) self:OnDragStop(arg1) end)
	self.anchor:EnableMouse(true)
	self.anchor:RegisterForDrag("LeftButton")
	self.anchor:RegisterForClicks("LeftButtonUp","RightButtonUp","MiddleButtonUp","Button4Up","Button5Up")
		
	self.base = CreateFrame("Button",frameName,UIParent)
	self.base:SetHeight(self.anchor:GetHeight())
	self.base:SetMovable(true)
	self.base:EnableMouse(false)

	if not self.header.initialConfigFunction then
		self.header.initialConfigFunction = function(child) self:SetInitial(child) end
	end	
end

function aUF.classes.aUFgroup.prototype:Enable()
	if self.enabled then return end
	self:UpdateAll()
	self.header:Show()
	self.enabled = true
end

function aUF.classes.aUFgroup.prototype:Disable()
	self.enabled = nil
    self.header:Hide()
    self.anchor:Hide()
end

function aUF.classes.aUFgroup.prototype:UpdateGroupFilter()
	if self.type == "raid" then
		local tempHide
		if self.header:IsVisible() then
			self.header:Hide()
			tempHide = true
		end
		local groupFilter = self.database.groupFilter
		local nameList = self.database.nameList
		local groupBy = self.database.groupBy
		if nameList and nameList ~= "" then
			self.header:SetAttribute("nameList",nameList)
			self.header:SetAttribute("groupFilter",nil)
			self.header:SetAttribute("groupBy","CLASS")
			self.header:SetAttribute("sortMethod","NAME")
			self.header:SetAttribute("groupingOrder",nil)
		else
			self.header:SetAttribute("groupFilter",groupFilter)
			self.header:SetAttribute("nameList",nil)
			if groupBy and groupBy == "NAME" then
				self.header:SetAttribute("sortMethod","NAME")
				self.header:SetAttribute("groupBy",nil)
			elseif groupBy and groupBy == "INDEX" then
				self.header:SetAttribute("sortMethod","INDEX")
				self.header:SetAttribute("groupBy",nil)
			 elseif groupBy and groupBy == "CLASS" then
				self.header:SetAttribute("sortMethod","INDEX")
				self.header:SetAttribute("groupBy","CLASS")
				self.header:SetAttribute("groupingOrder","DEATHKNIGHT,DRUID,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR")
			else
				self.header:SetAttribute("sortMethod","INDEX")
				self.header:SetAttribute("groupBy","GROUP")
				self.header:SetAttribute("groupingOrder","1,2,3,4,5,6,7,8")
			end
		end
		if tempHide then
			self.header:Show()
		end
	end
end

function aUF.classes.aUFgroup.prototype:UpdateTitle()
	local child = self.header:GetAttribute("child1")
	if self.header:IsVisible() and self.database.ShowAnchor == true and child and child:IsShown() then
		self.title:SetText(self.database.Name or self.name)
		self.anchor:Show()
	else
		self.anchor:Hide()
	end
	self.base:StopMovingOrSizing()
	self:UpdateWidth()
end

function aUF.classes.aUFgroup.prototype:UpdateRaidSet()
	local var = aUF.db.profile.CurrentRaidSet
	if (self.database.RaidSets and self.database.RaidSets[var])
		or (not (self.database.RaidSets))
		or (self.database.RaidSets and self.database.RaidSets[var] == nil) then
		self.raidSetVisible = true
	else
		self.raidSetVisible = nil
	end
end

function aUF.classes.aUFgroup.prototype:UpdateGrowth()
	local point, relativePoint = self.database.Grow
	local padding = (self.database.Padding or 2) - 6
	local AnchorOffset = (self.database.AnchorOffset or 2)

	if point == "TOP" then
		relativePoint = "BOTTOM"
		self.header:SetAttribute("xOffset",0)
		self.header:SetAttribute("yOffset",-(padding))
		self.header:ClearAllPoints()
		self.header:SetPoint(point,self.base,relativePoint,0,-(AnchorOffset - 7))
		self.anchor:ClearAllPoints()
		self.anchor:SetPoint("TOPLEFT",self.base,"TOPLEFT")
	elseif point == "BOTTOM" then
		relativePoint = "TOP"
		self.header:SetAttribute("xOffset",0)
		self.header:SetAttribute("yOffset",padding)
		self.header:ClearAllPoints()
		self.header:SetPoint(point,self.base,relativePoint,0,AnchorOffset - 7)
		self.anchor:ClearAllPoints()
		self.anchor:SetPoint("TOPLEFT",self.base,"TOPLEFT")
	elseif point == "LEFT" then
		relativePoint = "BOTTOMLEFT"
		self.header:SetAttribute("xOffset",padding)
		self.header:SetAttribute("yOffset",0)
		self.header:ClearAllPoints()
		self.header:SetPoint("TOPLEFT",self.base,relativePoint,0,AnchorOffset + 2)
		self.anchor:ClearAllPoints()
		self.anchor:SetPoint("TOPLEFT",self.base,"TOPLEFT")
	elseif point == "RIGHT" then
		relativePoint = "BOTTOMRIGHT"
		self.header:SetAttribute("xOffset",-(padding))
		self.header:SetAttribute("yOffset",0)
		self.header:ClearAllPoints()
		self.header:SetPoint("TOPRIGHT",self.base,relativePoint,0,AnchorOffset + 2)
		self.anchor:ClearAllPoints()
		self.anchor:SetPoint("TOPRIGHT",self.base,"TOPRIGHT")
	end

	self.header:SetAttribute("point",point)
	self.anchor:SetWidth(self.header:GetWidth())
	self:BorderBackground()
end

local function getRelativePointAnchor( point )
	point = strupper(point);
	if (point == "TOP") then
		return "BOTTOM", 0, -1;
	elseif (point == "BOTTOM") then
		return "TOP", 0, 1;
	elseif (point == "LEFT") then
		return "RIGHT", 1, 0;
	elseif (point == "RIGHT") then
		return "LEFT", -1, 0;
	elseif (point == "TOPLEFT") then
		return "BOTTOMRIGHT", 1, -1;
	elseif (point == "TOPRIGHT") then
		return "BOTTOMLEFT", -1, -1;
	elseif (point == "BOTTOMLEFT") then
		return "TOPRIGHT", 1, 1;
	elseif (point == "BOTTOMRIGHT") then
		return "TOPLEFT", -1, 1;
	else
		return "CENTER", 0, 0;
	end
end

function aUF.classes.aUFgroup.prototype:UpdateWidth()
	local unitdb = self.unitdb or aUF.db.profile.units[self.type]

	local i = 0
	local child = self.header:GetAttribute("child"..i+1)
	while child and child:IsShown() do
		if child then
			i = i + 1
			child = self.header:GetAttribute("child"..i+1)
		else
			break
		end
	end
	
	local point = self.header:GetAttribute("point") or "TOP"
	local relativePoint, xOffsetMult, yOffsetMult = getRelativePointAnchor(point)
	local xMultiplier, yMultiplier =  abs(xOffsetMult), abs(yOffsetMult)
	local xOffset = self.header:GetAttribute("xOffset") or 0
	local yOffset = self.header:GetAttribute("yOffset") or 0
	
	local unitsPerColumn = i
	local unitButtonWidth = unitdb.Width
	
	local width = xMultiplier * (unitsPerColumn - 1) * unitButtonWidth + ( (unitsPerColumn - 1) * (xOffset * xOffsetMult) ) + unitButtonWidth

	self.anchor:SetWidth(width)
    if not (InCombatLockdown()) then
        self.base:SetWidth(unitdb.Width)
    end
end

function aUF.classes.aUFgroup.prototype:UpdateScale()
	local unitdb = self.unitdb or aUF.db.profile.units[self.type]
	self.anchor:SetScale(unitdb.Scale)
	self.base:SetScale(unitdb.Scale)
end

local partyChildren = {"pet","target"}
function aUF.classes.aUFgroup.prototype:SetInitial(child)
	if child then
		local name = child:GetName()
		child.header = self

		local unitdb = self.unitdb or aUF.db.profile.units[self.type]
		child.initialWidth = unitdb.Width
		child:SetAttribute("initial-width",unitdb.Width)
		child:SetAttribute("initial-height",unitdb.Height)
		child:SetAttribute("initial-scale",unitdb.Scale or 1)
		if aUF.setupMode then
			child:SetAttribute("initial-unitWatch",true)
		else
			child:SetAttribute("initial-unitWatch",false)
		end
		
		aUF.units[name] = aUF.units[name] or aUF.classes.aUFunit:new(child,nil,nil,self.type)
	end
end

function aUF.classes.aUFgroup.prototype:BorderBackground(frame)
	local colortable = aUF.db.profile.PartyFrameColors
	local bordercolor = aUF.db.profile.FrameBorderColors
	local borderstyle = aUF.db.profile.units[self.type].BorderStyle
	
	local frame = frame or self.anchor
	
	frame:SetBackdrop({
				bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
				edgeFile = aUF.Borders[borderstyle].texture, edgeSize = aUF.Borders[borderstyle].size,
				insets = {left = aUF.Borders[borderstyle].insets, right = aUF.Borders[borderstyle].insets, top = aUF.Borders[borderstyle].insets, bottom = aUF.Borders[borderstyle].insets},
		})

	frame:SetBackdropColor(colortable.r,colortable.g,colortable.b,colortable.a)
	frame:SetBackdropBorderColor(bordercolor.r,bordercolor.g,bordercolor.b,bordercolor.a)
end

function aUF.classes.aUFgroup.prototype:OnDragStart(button)
	if button == "LeftButton" and (aUF.db.profile.Locked == false or IsAltKeyDown()) then
		self.base:StartMoving()
	end
end

function aUF.classes.aUFgroup.prototype:OnDragStop(button)
	self.base:StopMovingOrSizing()
	self.base:SetUserPlaced(false)
	self:SavePosition()
end

function aUF.classes.aUFgroup.prototype:LoadPosition()
	if self.grouped == true then return end
	self.base:ClearAllPoints()
	local position = aUF.db.profile.Positions[self.name]
	if type(position) == "table" then
		local x, y, point, relPoint = position.x, position.y, position.point, position.relPoint
		local s = self.base:GetEffectiveScale()
		x, y = x/s, y/s
		self.base:ClearAllPoints()
		self.base:SetPoint(point or "TOPLEFT", UIParent, relPoint or "TOPLEFT", x, y)
	else
		self.base:SetPoint("CENTER", UIParent, "CENTER")
	end
end

function aUF.classes.aUFgroup.prototype:SavePosition(reset)
	if reset then
		aUF.db.profile.Positions[self.name] = false
	else
		local point, parent, relPoint, x, y = self.base:GetPoint()
		local s = self.base:GetEffectiveScale()
		x, y = x*s, y*s
		if type(aUF.db.profile.Positions[self.name]) ~= "table" then
			aUF.db.profile.Positions[self.name] = {}
		end
		local position = aUF.db.profile.Positions[self.name]
		position.x, position.y = x, y
		position.point, position.relPoint = point, relPoint
	end
end

function aUF.classes.aUFgroup.prototype:Delete()
	self.database.Exists = false
	self.header:Hide()
	self.anchor:Hide()
end
