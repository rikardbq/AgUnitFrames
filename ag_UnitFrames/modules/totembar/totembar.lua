local pClass = select(2, UnitClass("player"))
if pClass ~= "SHAMAN" then
	-- Non-Death Knights (and now Shamans) suck and cannot stand the awesomeness of this module.
	return
end

local num, state, name
num = 4
		
local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

local plugin = aUF:NewModule("TotemBar")
plugin.inherit = {["player"]=true}
plugin.defaultDisabledState = state

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
		object:RegisterEvent("PLAYER_TOTEM_UPDATE", self.UpdateAllTotems)
		object:RegisterEvent("PLAYER_ENTERING_WORLD", self.UpdateAllTotems)
	else
		object:UnregisterEvent("PLAYER_TOTEM_UPDATE", self.UpdateAllTotems)
		object:UnregisterEvent("PLAYER_ENTERING_WORLD", self.UpdateAllTotems)
	end
end

function plugin:OnEnable()
	aUF:RegisterBarType("TotemBar", "player")
	TotemFrame:Hide()
	for _,object in aUF:IterateUnitObjects() do
		if object.type and object.type == "player" and object.unit then
			self:OnObjectEnable(object)
			object:ApplyLayout()
			self:OnRegisterEvents(object)
			self:OnUpdateAll(object)
		end
	end
end

function plugin:OnDisable()
	aUF:UnregisterBarType("TotemBar", "player")
	if pClass == "DEATHKNIGHT" then
		TotemFrame:Show()
	end
	for _,object in aUF:IterateUnitObjects() do
		self:OnRegisterEvents(object, true)
		self:OnObjectDisable(object)
	end
end

function plugin:OnObjectDisable(object)
	if object.bars.TotemBar then
		self:OnRegisterEvents(object)
		for i = 1,num do
			object.bars.TotemBar["Totem"..i].button = delFrame(object.bars.TotemBar["Totem"..i].button)		
			object.bars.TotemBar["Totem"..i].bg = delFrame(object.bars.TotemBar["Totem"..i].bg)		
			object.bars.TotemBar["Totem"..i] = delFrame(object.bars.TotemBar["Totem"..i])
		end
		object.bars.TotemBar.bg = delFrame(object.bars.TotemBar.bg)
		object.bars.TotemBar = delFrame(object.bars.TotemBar)
		object:ApplyLayout()
	end
end

function plugin:OnUpdateAll(object)
	if pClass == "DEATHKNIGHT" then
		object:UpdateTotem()
	else
		plugin.UpdateAllTotems(object)
	end
end

function plugin:OnMetroUpdate(object)
	if pClass == "DEATHKNIGHT" then
		object:UpdateTotem()
	else
		plugin.UpdateAllTotems(object)
	end
end

function plugin:OnLayoutApplied(object)
	if object.bars.TotemBar then
		local width, height
		for i = 1,num do
			local bar = object.bars.TotemBar["Totem"..i]
			local orientation = object.bars.TotemBar:GetOrientation() == "VERTICAL"
			bar:ClearAllPoints()
			if orientation then
				width = object.bars.TotemBar:GetWidth()
				height = (object.bars.TotemBar:GetHeight()- num + 1)/num		
				if i == 1 then
					bar:SetPoint("TOPLEFT",object.bars.TotemBar)
				else
					bar:SetPoint("TOPLEFT",object.bars.TotemBar["Totem"..(i-1)],"BOTTOMLEFT", 0, -1)
				end
				bar:SetWidth(width)
				bar:SetHeight(height)
			else
				width = (object.bars.TotemBar:GetWidth()- num + 1)/num
				height = object.bars.TotemBar:GetHeight()
				if i == 1 then
					bar:SetPoint("TOPLEFT",object.bars.TotemBar)
				else
					bar:SetPoint("TOPLEFT",object.bars.TotemBar["Totem"..(i-1)],"TOPRIGHT", 1, 0)
				end
				bar:SetWidth(width)
				bar:SetHeight(height)			
			end
		end	
	end
end

function plugin:OnSetBarTexture(object)
	local m = aUF:GetBarTexture()
	if object.bars.TotemBar then
		object.bars.TotemBar:SetStatusBarTexture(m,"BORDER")
	end
	local i = 1
	while object.bars.TotemBar["Totem"..i] do
		local bar = object.bars.TotemBar["Totem"..i]
		bar:SetStatusBarTexture(m,"BORDER")
		bar.bg:SetTexture(m,"BORDER")
		i = i + 1
	end
end

local totemID = {
	[1] = 1,
	[2] = 2,
	[3] = 5,
	[4] = 6,
	[5] = 3,
	[6] = 4,
}

local function onclick(self, mousebutton)
	if mousebutton == "RightButton" then
		DestroyTotem(self.slot)
	end
end

local function onenter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:ClearLines()
	GameTooltip:SetTotem(self.slot)
end

local function onleave()
	GameTooltip:Hide()
end

function plugin:OnObjectEnable(object)
	local bars = object.bars
	if not bars.TotemBar then
		bars.TotemBar = newFrame("StatusBar", object.frame)
		bars.TotemBar:SetMinMaxValues(0,100)
		bars.TotemBar:SetValue(0)
		for i = 1,num do
			bars.TotemBar["Totem"..i] = newFrame("StatusBar", object.frame)
			bars.TotemBar["Totem"..i]:SetMinMaxValues(0,1000)
			bars.TotemBar["Totem"..i]:SetID(totemID[i])
			bars.TotemBar["Totem"..i].bg = newFrame("Texture", object.frame, "BORDER")
			bars.TotemBar["Totem"..i].bg:ClearAllPoints()
			bars.TotemBar["Totem"..i].bg:SetAllPoints(bars.TotemBar["Totem"..i])
			bars.TotemBar["Totem"..i].bg:SetVertexColor(0.25, 0.25, 0.25, 0.25)
			if pClass == "SHAMAN" then
				bars.TotemBar["Totem"..i]:SetID(i)
				button = CreateFrame("Button")
				button:ClearAllPoints()
				button:SetAllPoints(bars.TotemBar["Totem"..i])
				button:SetParent(bars.TotemBar["Totem"..i])
				button:EnableMouse("true")
				button:RegisterForClicks("RightButtonUp")
				button:SetScript("OnClick", onclick)
				button:SetScript("OnEnter", onenter or nil)
				button:SetScript("OnLeave", onleave or nil)				
				button.slot = i
				button:Show()
				bars.TotemBar["Totem"..i].button = button
			end
		end
	end
end

---------------
-- STATUSBAR --
---------------

local totemTextures = {
	[1] = {r = 1, g = 0, b = 0.4},
	[2] = {r = 0, g = 1, b = 0.4},
	[3] = {r = 0, g = 0.4, b = 1},
	[4] = {r = 0.7, g = 0.5, b = 1},
}

-- Totem stuff

local function TotemButton_OnUpdate(self, elapsed)
	local id = self:GetID()
	local start = self.startTime
	local duration = self.duration
	self:SetValue((1-((GetTime() - start)/duration)) * 1000)
	self:SetAlpha(0.4 + (1-((GetTime() - start)/duration)) * 0.6)

	if (GetTime() > start + duration) then
		self:SetScript("OnUpdate", nil)
		self:SetValue(0)
	end
end

function plugin.UpdateTotem(self, slot)
	local frame = self.bars.TotemBar["Totem"..slot]
	local bg = self.bars.TotemBar["Totem"..slot].bg
	local haveTotem, name, startTime, duration, icon = GetTotemInfo(slot)
	local color = totemTextures[slot]
	if haveTotem and name ~= "" then
		frame.startTime = startTime
		frame.duration = duration
		frame:SetStatusBarColor(color.r, color.g, color.b)
		frame:SetScript("OnUpdate", TotemButton_OnUpdate)
	else
		frame:SetScript("OnUpdate", nil)
		frame:SetValue(0)
	end
	bg:SetVertexColor(color.r, color.g, color.b, 0.25)
end

function plugin.UpdateAllTotems(self)
	for i=1, MAX_TOTEMS do
		plugin.UpdateTotem(self, i)
	end
end