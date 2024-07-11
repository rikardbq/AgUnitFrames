local L = aUFLocale
local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")

local font = L["Interface\\AddOns\\ag_UnitFrames\\fonts\\barframes.ttf"]
local newFrame = aUF.newFrame

local ABF = aUF:NewModule("ABF")

-- Important, stuff won't work if we don't put our new layout into the layout table
aUF.layouts.ABF = ABF

local defaults = {
	profile = {
		["**"] = {
			HealthBarLeftText = "name afkdnd",
			ManaBarLeftText = "mobtype level class race",	
			HealthBarRightText = "curhp",
			ManaBarRightText = "curmp",
			height = {
				HealthBar = 1.2,
				ManaBar = 1.0,
				RuneBar = 0.4,
				TotemBar = 0.4,
				CastBar = 0.8,
				XPBar = 0.4,
			},
			order = {
				HealthBar = 1,
				ManaBar = 2,
				RuneBar = 5,
				TotemBar = 6,
				XPBar = 3,
				CastBar = 4,
			},
		},	
	}	
}

-- Lets use this table to index the string our layout creates
local layoutStrings = {}

function ABF:OnRegister()
	ABF.db = aUF.db:RegisterNamespace("ABFlayout", defaults)
end

-- When creating your own layout you may include options that allows your users to configure their text, their bar height, width, order and so on. It is all up to you. 
-- Including the options is done by creating an AceConfig options table and returning it with the OnRegisterOptions method, see below.
-- A good starting point would be the ABF options table, which can be found in ModuleOptions.lua in the Options Addon. It is not created here for LoD reasons.
--[[
function ABF:OnRegisterOptions()
	local mylayoutoptionstable = {}
	return mylayoutoptionstable
end
--]]

function ABF:LoadScale(object)
	object.frame:SetScale(object.database.Scale)
end

function ABF:BorderBackground(object)
	local colortable = aUF.db.profile.PartyFrameColors
	local bordercolor = aUF.db.profile.FrameBorderColors
	local borderstyle = object.database.BorderStyle or aUF.db.profile.BorderStyle
	
	object.frame:SetBackdrop({
				bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
				edgeFile = aUF.Borders[borderstyle].texture, edgeSize = aUF.Borders[borderstyle].size,
				insets = {left = aUF.Borders[borderstyle].insets, right = aUF.Borders[borderstyle].insets, top = aUF.Borders[borderstyle].insets, bottom = aUF.Borders[borderstyle].insets},
		})

	object.frame:SetBackdropColor(colortable.r,colortable.g,colortable.b,colortable.a)
	object.frame:SetBackdropBorderColor(bordercolor.r,bordercolor.g,bordercolor.b,bordercolor.a)
end

local buffFrames = {"buffFrame","debuffFrame"}
function ABF:ApplyLayout(object)
	local db = ABF.db.profile
	local mFont, mFontSize
	
	-- Here we get the override font, can be set by the user in the options frame
	mFont, mFontSize = aUF:GetOverrideFont(object)
	
	-- Lets set the font on all strings created by modules regardless if we're going to show them later or not, to prevent "font not set" error, object.strings
	for k,v in pairs(object.strings) do
		v:SetFont(font, 10)
	end
	
	-- Special frames created by some modules, lets position them
	if object.Portrait then
		object.Portrait:ClearAllPoints()
		object.Portrait:SetWidth(12+0.15*object.frame:GetWidth())
	end
	
	if object.Totems then
		object.Totems:ClearAllPoints()
		object.Totems:SetPoint("BOTTOMLEFT", object.frame, "TOPLEFT", 4, -4)
	end
	
	local fontSize
	if object.strings.HitIndicator then
		object.strings.HitIndicator:ClearAllPoints()
		object.strings.HitIndicator:SetFont(mFont or font, (mFontSize and (mFontSize + 16)) or 16)
		object.strings.HitIndicator:SetPoint("CENTER",object.frame)
	end
	
	if object.Combo1 then
		object.Combo1:ClearAllPoints()
		object.Combo1:SetPoint("BOTTOMRIGHT",object.frame,"BOTTOMRIGHT")
	end
	
	-- Place the icons created by modules, object.icons
	local icon = object.icons.pvpIcon
	if icon then
		icon:ClearAllPoints()
		icon:SetPoint("TOPRIGHT",object.frame,"TOPRIGHT",11,2)
		icon:SetWidth(23)
		icon:SetHeight(23)
	end
	icon = object.icons.statusIcon
	if icon then
		icon:ClearAllPoints()
		icon:SetPoint("BOTTOMLEFT",object.frame,"BOTTOMLEFT",-4,-3)
		icon:SetWidth(18)
		icon:SetHeight(18)
	end
	icon = object.icons.leaderIcon
	if icon then
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT",object.frame,"TOPLEFT",-2,2)
		icon:SetWidth(12)
		icon:SetHeight(12)
	end
	icon = object.icons.looterIcon
	if icon then
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT",object.frame,"TOPLEFT",7,2)
		icon:SetWidth(11)
		icon:SetHeight(11)
	end
	icon = object.icons.raidTargetIcon
	if icon then
		icon:ClearAllPoints()
		icon:SetPoint("CENTER",object.frame,"TOP",0,-3)
		icon:SetWidth(18)
		icon:SetHeight(18)
	end
	icon = object.icons.HappinessIcon
	if icon then
		icon:ClearAllPoints()
		icon:SetPoint("BOTTOMRIGHT",object.frame,"BOTTOMRIGHT",4,-3)
		icon:SetWidth(15)
		icon:SetHeight(15)
	end
	
	icon = object.icons.lfgIcon
	if icon then
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT",object.frame,"TOPLEFT",-2,-10)
		icon:SetWidth(12)
		icon:SetHeight(12)
	end   
	
	-- Lets position the bars created by modules, in object.bars
	-- First we just calculate the height each bar should have and creates a sorted table of the order we want to position them in
	local numBars = 0
	for k,v in pairs(object.bars) do
		numBars = numBars + 1
	end
	local fHeight = object.frame:GetHeight() - 10 - numBars + 1
	
	local totalWeight = 0
	local str,str2
	local anchor
	
	local sortTbl = {}
	for k,v in pairs(object.bars) do
		table.insert(sortTbl, k)
		totalWeight = totalWeight + (db[object.type].height[k] or 1)
	end
	
	local order = db[object.type].order
	local textSort = function(alpha, bravo)
		return (order[alpha] or 999) > (order[bravo] or 999)
	end	
	table.sort(sortTbl, textSort)
	
	local LEFT = "LEFT"
	local RIGHT = "RIGHT"
	local offset = 1
	if string.find(object.type, "target") then
		LEFT = "RIGHT"
		RIGHT = "LEFT"
		offset = -1
	end
	
	local v
	local anchoredPortrait
	local tag
	
	if not layoutStrings[object] then
		layoutStrings[object] = {}
	end
	
	for i,k in pairs(sortTbl) do
		local v = object.bars[k]
		v:ClearAllPoints()
	end
	for i,k in pairs(sortTbl) do
		local v = object.bars[k]
		v:ClearAllPoints()
		
		if anchor then
			if object.Portrait and not (anchoredPortrait) and (order[k] or 999) < 3 then
				v:SetPoint("BOTTOM"..LEFT,object.Portrait,"BOTTOM"..RIGHT, 1*offset, 0)
				v:SetPoint("BOTTOM"..RIGHT,anchor,"TOP"..RIGHT, 0, 1)
				anchoredPortrait = true
				object.Portrait:ClearAllPoints()
				object.Portrait:SetPoint("BOTTOM"..LEFT,anchor,"TOP"..LEFT, 0, 1)
				object.Portrait:SetPoint("TOP"..LEFT,object.frame,"TOP"..LEFT, 5*offset, -5)
			else
				v:SetPoint("BOTTOM"..LEFT,anchor,"TOP"..LEFT, 0, 1)
				v:SetPoint("BOTTOM"..RIGHT,anchor,"TOP"..RIGHT, 0, 1)
			end
		else
			if object.Portrait and not (anchoredPortrait) and (order[k] or 999) < 3 then
				v:SetPoint("BOTTOM"..LEFT,object.Portrait,"BOTTOM"..RIGHT, 1*offset, 0)
				v:SetPoint("BOTTOM"..RIGHT,object.frame,"BOTTOM"..RIGHT, -5*offset, 5)
				anchoredPortrait = true
				object.Portrait:ClearAllPoints()
				object.Portrait:SetPoint("BOTTOM"..LEFT,object.frame,"BOTTOM"..LEFT, 5*offset, 5)
				object.Portrait:SetPoint("TOP"..LEFT,object.frame,"TOP"..LEFT, 5*offset, -5)
			else
				v:SetPoint("BOTTOM"..LEFT,object.frame,"BOTTOM"..LEFT, 5*offset, 5)
				v:SetPoint("BOTTOM"..RIGHT,object.frame,"BOTTOM"..RIGHT, -5*offset, 5)
			end
		end
		
		v:SetHeight(fHeight*((db[object.type].height[k] or 1)/totalWeight))
		v:Show()
		
		if i == #sortTbl then
			fontSize = 11
		else
			fontSize = 10
		end
		
		if v.text2 then
			str2 = v.text2
		else
			if not layoutStrings[object][k.."RightText"] then
				layoutStrings[object][k.."RightText"] = newFrame("FontString", object.top, "OVERLAY")
			end
			str2 = layoutStrings[object][k.."RightText"]
			tag = self.db.profile[object.type][k.."RightText"]
			object:RegisterString(str2, tag)
		end
		str2:SetShadowColor(0, 0, 0)
		str2:SetShadowOffset(0.8, -0.8)
		str2:SetPoint("RIGHT",v,"RIGHT",-3,0.5)
		str2:SetFont(mFont or font, (mFontSize and (mFontSize + fontSize)) or fontSize)
		str2:SetJustifyH("RIGHT")
		if k == "HealthBar" then
			object.statusText = str2
		end
		
		if v.text1 then
			str = v.text1
		else
			if not layoutStrings[object][k.."LeftText"] then
				layoutStrings[object][k.."LeftText"] = newFrame("FontString", object.top, "OVERLAY")
			end
			str = layoutStrings[object][k.."LeftText"]
			tag = self.db.profile[object.type][k.."LeftText"]
			object:RegisterString(str, tag)
		end
		str:SetShadowColor(0, 0, 0)
		str:SetShadowOffset(0.8, -0.8)
		str:SetPoint("LEFT",v,"LEFT",3,0.5)
		str:SetPoint("RIGHT",str2,"LEFT",3,0.5)
		str:SetFont(mFont or font, (mFontSize and (mFontSize + fontSize)) or fontSize)
		str:SetJustifyH("LEFT")
		
		anchor = v
	end
	if object.Portrait and not (anchoredPortrait) then
		object.Portrait:SetPoint("BOTTOMLEFT",object.frame,"BOTTOMLEFT", 5, 5)
	end
	
	-- Position the aura frames, and set the values on the aura frames the aura modules uses to make them look like we want them (for example autoScale, which makes our auras fit our frame width).
	local buffFrame
	for _, str in pairs(buffFrames) do
		buffFrame = object[str]
		if buffFrame then
			local position = buffFrame.position
			local width = object.frame:GetWidth()
			buffFrame:SetWidth(0)
			buffFrame:SetHeight(0)
			buffFrame:ClearAllPoints()
			buffFrame.hideCount = nil
			buffFrame.auraScale = nil
			if position == "Below" then
				buffFrame:SetPoint("TOPLEFT", object.frame, "BOTTOMLEFT", 5, 0)
				buffFrame:SetPoint("TOPRIGHT", object.frame, "BOTTOMRIGHT", -5, 0)
				buffFrame:SetHeight(1)
				buffFrame.autoScale = -10
				buffFrame.autoHeight = nil
				buffFrame.growAs = nil
			elseif position == "Above" then
				buffFrame:SetPoint("BOTTOMLEFT", object.frame, "TOPLEFT", 5, 0)
				buffFrame:SetPoint("BOTTOMRIGHT", object.frame, "TOPRIGHT", -5, 0)
				buffFrame:SetHeight(1)
				buffFrame.autoScale = -10
				buffFrame.autoHeight = nil
				buffFrame.growAs = nil
			elseif position == "Left" then
				buffFrame:SetPoint("RIGHT", object.frame, "LEFT", 0, 0)
				buffFrame:SetWidth(1)
				buffFrame.autoScale = nil
				buffFrame.autoHeight = true
				buffFrame.growAs = nil
				buffFrame.auraScale = (width and width > 0 and width/190)*0.9 or 1
			elseif position == "Right" then
				buffFrame:SetPoint("LEFT", object.frame, "RIGHT", 0, 0)
				buffFrame:SetWidth(1)
				buffFrame.autoScale = nil
				buffFrame.autoHeight = true
				buffFrame.growAs = nil
				buffFrame.auraScale = (width and width > 0 and width/190)*0.9 or 1
			elseif position == "Inside" then
				buffFrame:SetPoint("TOPRIGHT", object.frame, "TOPRIGHT", -5, -5)
				buffFrame:SetPoint("TOPLEFT", object.frame, "TOPLEFT", 5, -5)
				buffFrame:SetPoint("BOTTOMRIGHT", object.frame, "BOTTOMRIGHT", -5, 5)
				buffFrame:SetPoint("BOTTOMLEFT", object.frame, "BOTTOMLEFT", 5, 5)
				buffFrame.autoScale = nil
				buffFrame.autoHeight = nil				
				buffFrame.auraScale = 0.7
				buffFrame.growAs = "Left"
				buffFrame.hideCount = true
			end
		end
	end
	if object.AggroBorder then
		object.AggroBorder:SetPoint("TOPLEFT",object.frame,"TOPLEFT",2,-2)
		object.AggroBorder:SetPoint("BOTTOMRIGHT",object.frame,"BOTTOMRIGHT",-2,2)
	end
end

-- We need to clean up if the user doesn't want our layout anymore :(
function ABF:UnapplyLayout(object)
	local buffFrame
	for _, str in pairs(buffFrames) do
		buffFrame = object[str]
		if buffFrame then
			buffFrame.autoHeight = nil
			buffFrame.autoScale = nil
			buffFrame.auraScale = nil
			buffFrame.growAs = nil
			buffFrame.hideCount = nil
		end
	end
	for k, v in pairs(layoutStrings[object]) do
		layoutStrings[object][k] = aUF.delFrame(v)
	end
	object:UnregisterAllStrings()
	
	if object.Portrait then
		object.Portrait:ClearAllPoints()
	end
	if object.Totems then
		object.Totems:ClearAllPoints()
	end
	if object.strings.HitIndicator then
		object.strings.HitIndicator:ClearAllPoints()
	end
	if object.Combo1 then
	object.Combo1:ClearAllPoints()
	end
end
