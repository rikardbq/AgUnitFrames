if not UnitThreatSituation then return end

local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

local plugin = aUF:NewModule("Aggroborder")
plugin.inherit = "player"
plugin.subConfig = "FrameStyle"

local sin = math.sin
local time = 0
local updateTable = {}
local function onUpdate()
	time = time + 0.04
	if time > math.pi*2 then
		time = 0
	end
	for k, v in pairs(updateTable) do
		k:SetAlpha(0.45*sin(time)+0.55)
	end
end
local onUpdateFrame = CreateFrame("Frame")	
onUpdateFrame:SetScript("OnUpdate", onUpdate)
onUpdateFrame:Hide()

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			["player"] = {
				ThreatBorder = true,
				plugin = true
			},
		}
	})
end

function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].ThreatBorder and not power then
		object:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", plugin.ThreatEvent)
	else
		object:UnregisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", plugin.ThreatEvent)
	end
end

function plugin:OnEnable()	
	for _,object in aUF:IterateUnitObjects() do
		if object.type and object.type == self.inherit then
			self:OnObjectEnable(object)
			time = 0
			object:ApplyLayout()
			self:OnRegisterEvents(object)
		end
	end
end

function plugin:OnDisable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectDisable(object)
	end
end

function plugin:OnObjectDisable(object)
	if object.type and object.type == self.inherit then
		self:OnRegisterEvents(object)
	end
	if object.AggroBorder then
		object.AggroBorder:Hide()
		onUpdateFrame:Hide()
	end
end

function plugin:OnUpdateAll(object)
	plugin.ThreatEvent(object)
end

function plugin:OnMetroUpdate(object)
	plugin.ThreatEvent(object)
end

function plugin.ThreatEvent(object)
	if not object.AggroBorder then return end
	local status 
	if object.unit then
		status = UnitThreatSituation(object.unit)
	end
	if object.unit and plugin.db.profile.units[object.type].ThreatBorder and status and status > 0 then
		object.AggroBorder:Show()
		local r, g, b = GetThreatStatusColor(status)
		plugin.SetColor(object, r, g, b)
		if not next(updateTable) then
			time = 0
		end
		if plugin.db.profile.units[object.type].plugin then
			updateTable[object.AggroBorder] = true
			onUpdateFrame:Show()
		else
			updateTable[object.AggroBorder] = nil
			object.AggroBorder:SetAlpha(1)
		end
	else
		object.AggroBorder:Hide()
		updateTable[object.AggroBorder] = nil
		if not next(updateTable) then
			onUpdateFrame:Hide()
		end
	end
end

local tbl = {"topleft", "bottomright", "topright", "bottomleft", "left", "right", "bottom", "top"}

function plugin.SetColor(object, r, g, b)
	for k, v in pairs(tbl) do
		if object.AggroBorder[v] then
			object.AggroBorder[v]:SetVertexColor(r, g, b)
		end
	end
end

function plugin:OnObjectEnable(object)
	if object.AggroBorder then return end
	if not plugin.db.profile.units[object.type].ThreatBorder then return end
	
	local border = CreateFrame("Frame", nil, object.top)	
	
	local edge
	for k, v in ipairs(tbl) do		
		edge = newFrame("Texture", border, "OVERLAY")
		edge:SetTexture("Interface\\AddOns\\ag_UnitFrames\\images\\AggroBorder.tga")
		edge:SetBlendMode("ADD")
		if v == "topleft" then
			edge:SetHeight(10)
			edge:SetWidth(10)
			edge:SetTexCoord("0", "0.3125", "0", "0.3125")
			edge:SetPoint("TOPLEFT")
		elseif v == "top" then
			edge:SetHeight(10)
			edge:SetTexCoord("0.3125", "0.625", "0", "0.3125")
			edge:SetPoint("LEFT",border.topleft,"RIGHT")
			edge:SetPoint("RIGHT",border.topright,"LEFT")
		elseif v == "topright" then
			edge:SetHeight(10)
			edge:SetWidth(10)		
			edge:SetTexCoord("0.625", "0.9375", "0", "0.3125")
			edge:SetPoint("TOPRIGHT")
		elseif v == "left" then
			edge:SetWidth(10)		
			edge:SetTexCoord("0", "0.3125", "0.3125", "0.625")
			edge:SetPoint("TOP",border.topleft,"BOTTOM")
			edge:SetPoint("BOTTOM",border.bottomleft,"TOP")
		elseif v == "right" then
			edge:SetWidth(10)
			edge:SetTexCoord("0.625", "0.9375", "0.3125", "0.625")
			edge:SetPoint("TOP",border.topright,"BOTTOM")
			edge:SetPoint("BOTTOM",border.bottomright,"TOP")
		elseif v == "bottomleft" then
			edge:SetHeight(10)
			edge:SetWidth(10)		
			edge:SetTexCoord("0", "0.3125", "0.625", "0.9375")
			edge:SetPoint("BOTTOMLEFT")
		elseif v == "bottom" then
			edge:SetTexCoord("0.3125", "0.625", "0.625", "0.9375")
			edge:SetHeight(10)
			edge:SetPoint("LEFT",border.bottomleft,"RIGHT")
			edge:SetPoint("RIGHT",border.bottomright,"LEFT")
		elseif v == "bottomright" then
			edge:SetHeight(10)
			edge:SetWidth(10)		
			edge:SetTexCoord("0.625", "0.9375", "0.625", "0.9375")
			edge:SetPoint("BOTTOMRIGHT")
		end
		border[v] = edge
	end
	border:Hide()
	object.AggroBorder = border
end