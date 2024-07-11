local _G = getfenv(0)
local aUF = LibStub("AceAddon-3.0"):NewAddon("ag_UnitFrames")
local SM = LibStub("LibSharedMedia-3.0")
local L = aUFLocale

------------
-- LOCALS --
------------

local coreEvents
local events = {}
local unitEvents = {}
local onupdates = {}
aUF.layouts = {}
aUF.classes = {}
aUF.units = {}
aUF.subgroups = {}
local unitsLoaded

------------
-- SYSTEM --
------------

function aUF:GetLocale()
	return L
end

function aUF:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("aUF2DB", aUF.defaultVars, "Default")
	self:LoadSM()
--	self.db.RegisterCallback(self, 'OnNewProfile', 'OnProfileReset')
--	self.db.RegisterCallback(self, 'OnProfileChanged', 'OnProfileReset')
--	self.db.RegisterCallback(self, 'OnProfileCopied', 'OnProfileReset')
--	self.db.RegisterCallback(self, 'OnProfileReset', 'OnProfileReset')
--	self.db.RegisterCallback(self, 'OnProfileDeleted', 'OnProfileReset')
end

function aUF:OnEnable()
	self:RegisterEvents()
	aUF:CreateOptionsPanel()	
end

aUF.soloUnits = {player = true, pet = true, target = true, targettarget = true, targettargettarget = true, focus = true, focustarget = true, pettarget = true}
aUF.partyUnits = {partytarget = true, party = true, partypet = true}
aUF.raidUnits = {raid = true}

function aUF:LoadUnits()
	for k in pairs(aUF.soloUnits) do
		aUF:LoadUnit(k)
	end
	for k in pairs(aUF.partyUnits) do
		aUF:LoadUnit(k)
	end
	for k in pairs(aUF.raidUnits) do
		aUF:LoadUnit(k)
	end	
end

function aUF:LoadUnit(class)
	if aUF.soloUnits[class] then
		aUF:LoadSoloUnits(class)
	elseif aUF.partyUnits[class] then
		aUF:LoadPartyUnits(class)
	elseif aUF.raidUnits[class] then	
		aUF:LoadRaidUnits(class)
	end
end

function aUF:LoadSoloUnits(class)
	if not (self.db.profile.units[class].enabled) then return end
	if class == "player" then
		aUF:CreateUnit(class,"Player")
	elseif class == "pet" then
		aUF:CreateUnit(class)
	elseif class == "target" then
		aUF:CreateUnit(class,"Combo")
	elseif class == "focus" then
		aUF:CreateUnit(class,"Focus")			
	else
		if string.find(class, ".+target") then
			aUF:CreateUnit(class,"Metro")
		else
			aUF:CreateUnit(class)
		end
	end
	if self.Options and self.Options.loaded then
		aUF.Options:AddUnitOptions(class)
	end
end

function aUF:LoadPartyUnits(class)
	if not (self.db.profile.units[class].enabled) then return end
	aUF:UpdatePartyGrouping(class)
	if self.Options and self.Options.loaded then
		aUF.Options:AddUnitOptions(class)
	end
end

function aUF:LoadRaidUnits(class)
	if not (self.db.profile.units[class].enabled) then return end
	for k,v in pairs(self.db.profile.subgroups) do
		if v.Exists == true and not aUF.subgroups[k] then
			aUF:CreateSubgroup(k,class)
		end
	end
	if self.Options and self.Options.loaded then
		aUF.Options:AddUnitOptions(class)
	end
end

function aUF:DisableAllFrames(class, power)
	if not class then return end
	for k, v in pairs(self.units) do
		if v.type == class and not (v.frame.header) then
			if power then
				v:Disable()
			else
				v:Hide()
			end
		end
	end
	for k,v in pairs(self.subgroups) do
		if v.type == class then
			v:Disable()
		end
	end
end

function aUF:EnableAllFrames(class, power)
	if not class then return end
	for k, v in pairs(self.units) do
		if v.type == class and not (v.frame.header) then
			if power then
				v:Enable()
			else
				v:Hide()
			end
		end
	end
	for k,v in pairs(self.subgroups) do
		if v.type == class then
			v:Enable()
		end
	end
end

function aUF:OnProfileReset()
	for k, v in pairs(self.units) do
		v:Disable()
	end
	for k,v in pairs(self.db.profile.units) do
		if v.enabled then
			aUF:EnableAllFrames(k, true)
		end
	end
end

--------------------------------------
-- OBJECT CREATION/METHOD EXECUTION --
--------------------------------------

function aUF:CreateUnit(unit,class,name,grouped)
	local name = "aUF"..(name or unit)
	if not _G[name] then
		local frame = CreateFrame("Button", name, UIParent, "SecureUnitButtonTemplate")
		frame:Hide()
		frame:SetParent("UIParent")
		self.units[name] = self.classes["aUFunit"..(class or "")]:new(frame, unit, grouped)
	end
	return self.units[name]
end

function aUF:CreateSubgroup(name,type,reset)
	if not aUF.subgroups[name] then
		aUF.subgroups[name] = aUF.classes.aUFgroup:new(name,type,reset)
	else
		aUF.subgroups[name]:SetDefaults(true)
		aUF.subgroups[name].database.Exists = true
		aUF:Print(name)
		aUF.subgroups[name]:Enable()
	end
	return aUF.subgroups[name]
end

function aUF:CreateNewGroup()
	local i = 1
	local k = "group"..i
	while (self.db.profile.subgroups[k] and self.db.profile.subgroups[k].Exists == true) do
		i = i + 1
		k = "group"..i
	end
	aUF:CreateSubgroup(k,"raid",true)

	return k
end

function aUF:CallMethodOnUnit(func, class, object, ...)
	if not func then return end
	for _,unitObject in pairs(self.units) do
		if func and unitObject.unit and ((class and unitObject.type == class) or not class) and unitObject:IsEnabled() then
			if type(func) == "function" then
				if object then
					func(object, unitObject, ...)
				else
					func(unitObject, ...)
				end
			else
				if object then
					object[func](object, unitObject, ...)
				else
					unitObject[func](unitObject, ...)
				end			
			end
		end
	end
end

local function blank() end
function aUF:IterateUnitObjectsByUnit(unit)
	if (not unit) or (not self.unitid) then
		return blank
	end
	local g = self.unitid[unit]
	if g then
		return pairs(g)
	else
		return blank
	end
end

function aUF:IterateUnitObjectsByGroup(class)
	if (not class) or (not self.groupid) then
		return blank
	end
	local g = self.groupid[class]
	if g then
		return pairs(g)
	else
		return blank
	end
end

local function unitIterator(state, n)
	local k, v = next(aUF.units, n)
	if v then
		while v and (not (v:IsEnabled())) do
			k, v = next(aUF.units, k)
		end
	end
	n = k
	if v and v:IsEnabled() then
		return k, v
	end
end

function aUF:IterateUnitObjects()
	return unitIterator
end

function aUF:RegisterUnit(object, unit, group)
	if not self.unitid then
		self.unitid = {}
	end
	if not self.groupid then
		self.groupid = {}
	end
	
	if (not self.unitid[unit]) then
		self.unitid[unit] = {}
	end
	if (not self.groupid[group]) then
		self.groupid[group] = {}
	end

	self.unitid[unit][object] = true
	self.groupid[group][object] = true
end

function aUF:UnregisterUnit(object, unit, group)
	if type(self.unitid) ~= "table" then return end
	if not self.unitid[unit] then return end
	self.unitid[unit][object] = nil
	self.groupid[group][object] = nil
end

---------------------
-- UNIT VISIBILITY --
---------------------

function aUF:UpdatePartyGrouping(class)
	local groupWith = aUF.db.profile.units[class] and aUF.db.profile.units[class].GroupWith
	aUF:DisableAllFrames(class, true)
	
	if groupWith == "parent" then
		for k,v in pairs(self.units) do
			if v.type == "party" then
				v:UpdateChildFrames()
			end
		end
	elseif groupWith == "self" then
		if self.subgroups[class] then
			self.subgroups[class]:Enable()
		else
			aUF:CreateSubgroup(class,class)
		end
	elseif groupWith == "free" then
		for i=1,4 do
			local unit = class..i
			if self.units["aUF"..unit] then
				self.units["aUF"..unit]:Enable()
			else
				if string.find(class, "target") then
					aUF:CreateUnit(unit,"Metro")
				else
					aUF:CreateUnit(unit)
				end
			end
		end
	end
end

-- /script LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames"):RAID_ROSTER_UPDATE(true)
local raidDirty
function aUF:RAID_ROSTER_UPDATE(force)	
	local inRaid = self.inRaid
	if (aUF.db.profile.FiveMan and GetNumRaidMembers()>5) or (not(aUF.db.profile.FiveMan) and GetNumRaidMembers()>0) or aUF.setupMode == "raid" then
		self.inRaid = true
	else
		self.inRaid = false
	end
	
	local raidSet = aUF.db.profile.CurrentRaidSet
	if (inRaid ~= self.inRaid) or force then
		if InCombatLockdown() then
			raidDirty = true
		else
			if aUF.db.profile.units.raid and aUF.db.profile.units.raid.enabled then
				for k,v in pairs(aUF.subgroups) do
					if v.type == "raid" then
						if self.inRaid and (v.database.RaidSets and v.database.RaidSets[tonumber(raidSet)]) then
							v:Enable()
						else
							v:Disable()
						end
					end
				end
			end
			if self.inRaid and aUF.db.profile.HidePartyInRaid then
				for k in pairs(aUF.partyUnits) do
					aUF:DisableAllFrames(k, true)
				end
			elseif aUF.db.profile.units.party and aUF.db.profile.units.party.enabled then
				for k in pairs(aUF.partyUnits) do
					if aUF.db.profile.units[k] and aUF.db.profile.units[k].enabled then
						aUF:UpdatePartyGrouping(k)
					end
				end			
			end
		end
	end
end

function aUF:PLAYER_REGEN_DISABLED()
	if not unitsLoaded then
		unitsLoaded = true
		aUF:LoadUnits()
		aUF:RAID_ROSTER_UPDATE(true)
	end
	if aUF.setupMode then
		if aUF.UpdateSetupMode then
			aUF:UpdateSetupMode("off")
		end
		aUF:Print(L["Combat entered. Leaving frame setup mode."])
	end
end

function aUF:PLAYER_REGEN_ENABLED()
	if raidDirty and self.subgroups then
		for k,v in pairs(self.subgroups) do
			v:SetVisibility()
		end
		if aUF.setupMode then
			for k,v in pairs(aUF.units) do
				v:SetUnitWatch()
			end
		end
		raidDirty = nil
	end
end

function aUF:PLAYER_ENTERING_WORLD()
	if not unitsLoaded then
		unitsLoaded = true
		aUF:LoadUnits()
		aUF:RAID_ROSTER_UPDATE(true)
	end
	aUF:ShowRaidHeaders()
	coreEvents.PLAYER_ENTERING_WORLD = false
	coreEvents.PLAYER_LEAVING_WORLD = true
end

function aUF:ShowRaidHeaders()
	for k,v in pairs(aUF.subgroups) do
		v.forcedHidden = false
	end
	aUF:RAID_ROSTER_UPDATE(true)
end

function aUF:PLAYER_LEAVING_WORLD()
	for k,v in pairs(aUF.subgroups) do
		v:Disable()
	end
	coreEvents.PLAYER_LEAVING_WORLD = false
	coreEvents.PLAYER_ENTERING_WORLD = true
end

function aUF:SetRaidset(option)
	set = tonumber(self.db.profile.CurrentRaidSet)
	if not (InCombatLockdown()) and set then
		if option == "prev" then
			if set <= 1 then
				self.db.profile.CurrentRaidSet = "10"
			else
				self.db.profile.CurrentRaidSet = tostring(set - 1)
			end
		elseif option == "next" then
			if tonumber(set) >= 10 then
				self.db.profile.CurrentRaidSet = "1"
			else
				self.db.profile.CurrentRaidSet = tostring(set + 1)
			end
		else
			self.db.profile.CurrentRaidSet = tostring(option)
		end
		aUF:RAID_ROSTER_UPDATE(true)
		self:Print(string.format("Raidset %s activated.",self.db.profile.CurrentRaidSet))
	elseif set then
		self:Print("You cannot change the raid set while in combat.")
	end
end

-----------
-- TIMER --
-----------

local timers = {}
local HZ = 11
local lastint = floor(GetTime() * HZ)
local function timerFunction(self)
	local now = GetTime()
	local nowint = floor(now * HZ)
	if nowint == lastint then return end
	local when
	for k, v in pairs(timers) do
		local when = v.when
		if when and now > when then
			v.when = now + v.delay
			local func = v.func
			if type(func) == "string" then
				v.object[func](v.object)
			else
				func(v.object)
			end
		end
	end
	lastint = nowint
end

local timerFrame = CreateFrame("Frame")
timerFrame:SetScript("OnUpdate", timerFunction)
timerFrame:Show()

function aUF.StartTimer(object, func, time)
	local timer = aUF.new()
	timer.object = object
	timer.func = func
	timer.delay = time
	timer.when = GetTime() + time
	
	local str = tostring(timer)
	timers[str] = timer
	return str
end

function aUF.CancelTimer(object, str)
	local timer = timers[str]
	timer.when = nil
	timers[str] = aUF.del(timer, true)
end

-------------
-- MODULES --
-------------

local modPrototype = {}

function modPrototype:OnInitialize()
	if self.OnRegister then
		self:OnRegister()
	end
	if aUF.db.profile.modulesDisabled[self.name] or (aUF.db.profile.modulesDisabled[self.name] == nil and not self.defaultDisabledState) then
		self.enabledState = true
	else
		self.enabledState = false
	end
end

function modPrototype:RegisterDefaults(defaults)
	local tbl = { profile = defaults }				
	self.db = aUF.db:RegisterNamespace(self.name, tbl)
end

modPrototype.StartTimer = aUF.StartTimer
modPrototype.CancelTimer = aUF.CancelTimer

aUF:SetDefaultModulePrototype(modPrototype)

---------------------
-- TEXT TAG SYSTEM --
---------------------

local function formatLargeValue(value)
	if value < 9999 then
		return value
	elseif value < 999999 then
		return string.format("%.1fk", value / 1000)
	else
		return string.format("%.2fm", value / 1000000)
	end
end

aUF.formats = {}
aUF.textFunctions = {
	["curhp"] = {
		func = function (u)
			return formatLargeValue(UnitHealth(u)).."/"..formatLargeValue(UnitHealthMax(u))
		end,
		order = 44,
		events = "UNIT_HEALTH",
		name = "Absolute HP",
		desc = "Current and maximum HP in absolute values",
		qhProxy = true,
	},
	["curmp"] = {
		func = function (u)
			local mpmax = UnitManaMax(u)
			if mpmax > 1 then
				return formatLargeValue(min(UnitMana(u),mpmax)).."/"..formatLargeValue(mpmax)
			end
		end,
		order = 43,
		metro = "player",
		onupdate = "player",
		events = {"UNIT_MANA", "UNIT_RAGE", "UNIT_FOCUS", "UNIT_ENERGY", "UNIT_DISPLAYPOWER", "UNIT_RUNIC_POWER" },
		name = "Absolute Mana",
		desc = "Current and maximum MP in absolute values",
	},
	["percenthp"] =  {
		func = function (u)
			local hpmax = UnitHealthMax(u)
			return (hpmax ~= 0) and (floor((UnitHealth(u) / hpmax) * 100)).."%" or "0%"
		end,
		order = 42,
		events = "UNIT_HEALTH",
		name = "Percent HP",
		desc = "Current HP in percent (Unknown value for people not in party/raid)",
		qhProxy = true,
	},
	["percentmp"] =  {
		func = function (u)
			local mpmax = UnitManaMax(u)
			return (mpmax > 1) and (floor((min(UnitMana(u), mpmax) / mpmax) * 100)).."%" or "0%"
		end,
		order = 41,
		metro = "player",
		onupdate = "player",
		events = {"UNIT_MANA", "UNIT_RAGE", "UNIT_FOCUS", "UNIT_ENERGY", "UNIT_DISPLAYPOWER", "UNIT_RUNIC_POWER" },
		name = "Percent MP",
		desc = "Current MP in percent",
	},
	["diffhp"] = {
		func = function (u)
			local v = math.abs(UnitHealth(u) - UnitHealthMax(u))
			if v > 0 then
				return "-"..formatLargeValue(v)
			end
			return nil
		end,
		order = 40,
		events = "UNIT_HEALTH",
		name = "Difference HP",
		desc = "Current HP minus maximum HP",
		qhProxy = true,
	},
	["diffmp"] = {
		func = function (u)
			local v = math.abs(min(UnitMana(u), UnitManaMax(u)) - UnitManaMax(u))
			if v > 0 then
				return "-"..formatLargeValue(v)
			end
		end,
		order = 39,
		metro = "player",
		onupdate = "player",
		events = {"UNIT_MANA", "UNIT_RAGE", "UNIT_FOCUS", "UNIT_ENERGY", "UNIT_DISPLAYPOWER", "UNIT_RUNIC_POWER" },
		name = "Difference MP",
		desc = "Current MP minus maximum MP",
	},
	["name"] = {
		func = function(u, obj)
			local type = u:gsub("%d", "")
			return UnitName(u) or ""
		end,
		order = 11,
		events = {"UNIT_NAME_UPDATE", "PARTY_MEMBERS_CHANGED"},
		name = "Name",
		desc = "Character Name",
	},
	["raidname"] = {
		func = function(u, obj)
			local type = u:gsub("%d", "")
			if UnitIsPlayer(u) then
				local _,x=UnitClass(u)
				return string.format("%s%s%s",aUF:GetRaidColors(x) or "",UnitName(u) or "","|cFFFFFFFF")
			else
				return UnitName(u) or ""
			end
		end,
		order = 11,
		events = {"UNIT_NAME_UPDATE", "PARTY_MEMBERS_CHANGED"},
		name = "Name (Raid Colored)",
		desc = "Raid Colored Character Name",
	},	
	["mobtype"] = {
		func = function(u)
			if UnitClassification(u) == "rare" then
				return L["Rare"]
			elseif UnitClassification(u) == "rareelite" then
				return L["Rare-Elite"]
			elseif UnitClassification(u) == "elite" then
				return L["Elite"]
			elseif UnitClassification(u) == "worldboss" then
				return L["Boss"]
			else
				return nil
			end
		end,
		order = 21,
		name = "Mobtype",
		desc = "Elite, boss or rare",
	},
	["level"] = {
		func = function (u)
			
			local x = UnitLevel(u)
			local color
			if UnitCanAttack("player", u) then color = aUF:GiveHex(GetQuestDifficultyColor((x > 0) and x or 99)) end
			
			return string.format("%s%s%s", color or "", ((x>0) and x or "??"), "|cFFFFFFFF")
		end,
		order = 22,
		events = {"UNIT_NAME_UPDATE", "PARTY_MEMBERS_CHANGED","UNIT_LEVEL"},
		name = "Level",
		desc = "Character level",
	},
	["class"] = {
		func = function (u)
			if UnitIsPlayer(u) then
				local _,x=UnitClass(u)
				return string.format("%s%s%s",aUF:GetRaidColors(x) or "",(UnitClass(u) or L["Unknown"]) or "","|cFFFFFFFF")
			else
				return	(UnitCreatureFamily(u) or UnitCreatureType(u) or "")
			end
		end,
		order = 23,
		name = "Class",
		desc = "Character Class",
		events = {"UNIT_NAME_UPDATE", "PARTY_MEMBERS_CHANGED"},
	},
	["race"] = {
		func = function (u)
			return UnitRace(u) or ""
		end,
		order = 24,
		name = "Race",
		desc = "Character Race",
		events = {"UNIT_NAME_UPDATE", "PARTY_MEMBERS_CHANGED"},
	},
	["raidgroup"] = {
		func = function (u)
			for i=1, GetNumRaidMembers() do
				local name, rank, subgroup = GetRaidRosterInfo(i)
				if (name == UnitName(u)) then
					return "(" .. subgroup .. ")"
				end
			end
			return ""
		end,
		events = "RAID_ROSTER_UPDATE",
		order = 51,
		name = "Raidgroup",
		desc = "Current raid subgroup",
	},
	["afkdnd"] = {
		func = function(u)
			if UnitIsAFK(u) then
				return "(AFK)"
			elseif UnitIsDND(u) then
				return "(DND)"
			else
				return nil
			end
		end,
		events = "PLAYER_FLAGS_CHANGED",
		order = 52,
		name = "AFK/DND Status",
		desc = "Displays the AFK or DND status",
	},
	["curxp"] = {
		func = function(u)
			local curXP, totalXP
			if u == 'pet' then
				curXP, totalXP = GetPetExperience()
			else
				curXP, totalXP = UnitXP(u), UnitXPMax(u)
			end
			return curXP and (curXP .. '/' .. totalXP) or ''
		end,
		events = {"PLAYER_XP_UPDATE", "UNIT_PET_EXPERIENCE"},
		order = 61,
		name = "Current XP",
		desc = "Current and total required XP",
	},
	["percentxp"] = {
		func = function(u)
			local curXP, totalXP
			if u == 'pet' then
				curXP, totalXP = GetPetExperience()
			else
				curXP, totalXP = UnitXP(u), UnitXPMax(u)
			end
			return (curXP and (totalXP > 0)) and (floor((curXP / totalXP) * 100).."%") or "0%"
		end,
		events = {"PLAYER_XP_UPDATE", "UNIT_PET_EXPERIENCE"},
		order = 62,
		name = "Percent XP",
		desc = "Current XP in percent",
	},
	["restxp"] = {
		func = function(u)
			if u == 'player' then
				return GetXPExhaustion() or 0
			end
		end,
		events = "UPDATE_EXHAUSTION",
		order = 63,
		name = "Rested XP",
		desc = "Rested XP",
	},
	["percentrestxp"] = {
		func = function(u)
			if u == 'player' then
				local totalXP, restXP = UnitXPMax(u), GetXPExhaustion() or 0
				return (totalXP > 0) and (floor((restXP / totalXP) * 100).."%") or "0%"
			end
		end,
		events = "UPDATE_EXHAUSTION",
		order = 64,
		name = "Percent Rested XP",
		desc = "Rested XP as a percentage of the current level",
	},
	["currep"] = {
		func = function(u)
			local repname, repreaction, repmin, repmax, repvalue = GetWatchedFactionInfo()
			if repname then
				repvalue = repvalue - repmin
				repmax = repmax - repmin
				return repvalue..'/'..repmax
			end
			return ''
		end,
		events = "PLAYER_XP_UPDATE",
		order = 66,
		name = "Current Reputation",
		desc = "Reputation with the currently watched faction",
	},
	["percentrep"] = {
		func = function(u)
			local repname, repreaction, repmin, repmax, repvalue = GetWatchedFactionInfo()
			if repname then
				repvalue = repvalue - repmin
				repmax = repmax - repmin
				return (repmax > 0) and (floor((repvalue / repmax) * 100)..'%') or '0%'
			end
			return ''
		end,
		events = "PLAYER_XP_UPDATE",
		order = 67,
		name = "Percent Reputation",
		desc = "Reputation with the currently watched faction as a percentage",
	},
}

local tmpSubstrings = {}

function aUF:FormatString(str)
	if not (type(str) == "string") then str = nil return end

	if aUF.formats[str] and aUF.formats[str].func then
		return aUF.formats[str].func, aUF.formats[str].events, aUF.formats[str].onupdate
	end

	local formatArgs, formatEvents, formatOnupdate = aUF.new()
	for word in string.gmatch(str, "%a+") do
		if aUF.textFunctions[word] and aUF.textFunctions[word].func then
			table.insert(formatArgs, aUF.textFunctions[word].func)
			local events = aUF.textFunctions[word].events
			if events then
				if not formatEvents then
					formatEvents = aUF.new()
				end
				if type(events) == "table" then
					for k,v in pairs(events) do
						formatEvents[v] = true
					end
				elseif type(events) == "string" then
					formatEvents[events] = true
				end
			end
			local onupdate = aUF.textFunctions[word].onupdate
			if onupdate then
				if not formatOnupdate then
					formatOnupdate = aUF.new()
				end
				if type(onupdate) == "table" then
					for k,v in pairs(onupdate) do
						formatOnupdate[v] = true
					end
				elseif type(onupdate) == "string" then
					formatOnupdate[onupdate] = true
				end
			end
		end
	end

	if not aUF.formats[str] then
		aUF.formats[str] = aUF.new()
	end

	aUF.formats[str].func = function(unit, obj)
		local n = 0
		for i,func in ipairs(formatArgs) do
			local result = func(unit)
			if result then
				n = n + 1
				tmpSubstrings[n] = result
			end
		end
		return table.concat(tmpSubstrings, " ", 1, n)
	end
	aUF.formats[str].events = formatEvents
	aUF.formats[str].onupdate = formatOnupdate

	return aUF.formats[str].func, aUF.formats[str].events, aUF.formats[str].onupdate
end

-------------
-- OPTIONS --
-------------

local loadedBlizz
local function CreateBlizzPanel()
	if not (loadedBlizz) then
		local name = "GUnit"
	
	local f = CreateFrame('Frame', name, UIParent)
	f.name = title
	
		local name = "Options Frame"
		local width = 136
		local height = 22
		local b = CreateFrame('Button', nil, f, 'UIPanelButtonTemplate')
		b:SetText(name)
		b:SetWidth(width)
		b:SetHeight(height or width)	
		b:Show()
		b:SetPoint("TOPLEFT",f, "TOPLEFT",0,0)
		
		InterfaceOptions_AddCategory(f)
	end
end


local function showoptionsgui()
	local loaded = LoadAddOn("ag_Options")
	if loaded or aUF.Options then
		aUF.Options:OpenOptions()
	else
		aUF:Print(L["ag_Options addon isn't available."])
	end
end

local function optionsfunc()
	InterfaceOptionsFrame.lastFrame = nil
	HideUIPanel(InterfaceOptionsFrame)
	showoptionsgui()
end

function aUF:CreateOptionsPanel()
	local frame = CreateFrame("Frame")
	frame.name = L["GUnit"]
	
	local b = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
	b:SetText(L["Open GUnit Options"])
	b:SetWidth(155)
	b:SetHeight(25)	
	b:SetPoint("TOPLEFT", 15, -15)
	b:SetScript("OnClick",function() optionsfunc() end)
	
	InterfaceOptions_AddCategory(frame)
	InterfaceOptionsFrame:SetMovable(true)
	
	local title = InterfaceOptionsFrame:CreateTitleRegion()
	title:ClearAllPoints()
	title:SetAllPoints(InterfaceOptionsFrameHeader)
	self.frame = frame

	_G["SLASH_AGUNITFRAMES1"] = "/aguf"
	_G["SLASH_AGUNITFRAMES2"] = "/gunit"
	_G["SLASH_AGUNITFRAMES3"] = "/gu"
	_G["SLASH_AGUNITFRAMES4"] = "/agu"
	SlashCmdList["AGUNITFRAMES"] = showoptionsgui
end

-----------------------
-- EVENT REGISTERING --
-----------------------

coreEvents = {
	RAID_ROSTER_UPDATE = true,
	PLAYER_REGEN_DISABLED = true,
	PLAYER_REGEN_ENABLED = true,
	PLAYER_LEAVING_WORLD = false,
	PLAYER_ENTERING_WORLD = true,
}

aUF.eventFrame = CreateFrame("Frame")
function aUF:RegisterEvents()
	self.eventFrame:SetScript("OnEvent", aUF.OnEvent)

	self.eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
	self.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.eventFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
	self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.eventFrame:RegisterEvent("PLAYER_LOGIN")
end

function aUF:OnEvent(event, ...)
	if coreEvents[event] then
		if aUF[event] then
			aUF[event](self)
		end
	end
	local unit = (...)
	if unit and aUF.unitid and aUF.unitid[unit] then
		for object in pairs(aUF.unitid[unit]) do
			if unitEvents[object] and unitEvents[object][event] then
				for method in pairs(unitEvents[object][event]) do
					if type(method) == "function" then
						method(object, event, ...)
					else
						object[method](object, event, ...)
					end
				end
			end
		end
	end
	for object, methods in pairs(events) do
		if methods[event] then
			for method in pairs(methods[event]) do
				if object[method] then
					object[method](object, event, ...)
				elseif type(method) == "function" then
					method(object, event, ...)
				end
			end
		end
	end
end

function aUF:RegisterEvent(object, event, method, unit)
	local eventTbl = unit and unitEvents or events
	if not eventTbl[object] then
		eventTbl[object] = aUF.new()
	end
	if not eventTbl[object][event] then
		eventTbl[object][event] = aUF.new()
	end
	eventTbl[object][event][method] = true

	self.eventFrame:RegisterEvent(event)
end

function aUF:UnregisterEvent(object, event, method, unit)
	local eventTbl = unit and unitEvents or events
	if eventTbl[object] then
		if eventTbl[object][event] then
			if eventTbl[object][event][method] then
				eventTbl[object][event][method] = aUF.del(eventTbl[object][event][method])
			end
			if next(eventTbl[object][event]) == nil then
				eventTbl[object][event] = aUF.del(eventTbl[object][event])
			end
		end
	end
	if not (coreEvents[event] == nil) then
		return
	end
	for object, objEvents in pairs(events) do
		if objEvents[event] then
			return
		end
	end
	for object, objEvents in pairs(unitEvents) do
		if objEvents[event] then
			return
		end
	end	
	self.eventFrame:UnregisterEvent(event)
end

function aUF:UnregisterAllEvents(object)
	if events[object] then
		for event in pairs(events[object]) do
			self:UnregisterEvent(object, event, method)
		end
	end
	if unitEvents[object] then
		for event in pairs(unitEvents[object]) do
			self:UnregisterEvent(object, event, method, true)
		end
	end
end

-------------
-- UTILITY --
-------------

function aUF:UnitSuffix(unit,suffix)
	if not suffix then return unit end
	if unit then
		unit = unit..suffix
		if unit:find("pet") then
			unit = gsub(unit, "^([^%d]+)([%d]+)[pP][eE][tT]","%1pet%2")
		end
		return unit
	end
end
		
function aUF:UtilFactionColors(unit)
	local r, g, b = 0,0,0
	local a = 0.5
	if ( UnitPlayerControlled(unit) ) then
		if ( UnitCanAttack(unit, "player") ) then
			if ( not UnitCanAttack("player", unit) ) then
				r,g,b = 0.84, 0.52, 0.28
			else
				r,g,b = 0.88, 0.17, 0.29
			end
		elseif ( UnitCanAttack("player", unit) ) then
			r,g,b = 1, 0.97, 0.1
		elseif ( UnitIsPVP(unit) ) then
			r,g,b = 0.41, 0.95, 0.2
		else
			r,g,b = 0.84, 0.52, 0.28
		end
	else
		local reaction = UnitReaction(unit, "player")
		if ( reaction ) then
			if reaction == 5 or reaction == 6 or reaction == 7 then
				r,g,b = 0.41, 0.95, 0.2
			elseif reaction == 4 then
				r,g,b = 1, 0.97, 0.1
			elseif reaction == 1 or reaction == 2 or reaction == 3 then
				r,g,b = 0.88, 0.17, 0.29
			else
				return UnitReactionColor[reaction]
			end
		end
	end
	return r, g, b
end

function aUF:GiveHex(r,g,b)
	if type(r) == "table" then
		if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

function aUF:GetRaidColors(class)
	if RAID_CLASS_COLORS[class] then
		local tbl = RAID_CLASS_COLORS[class]
		return string.format("|cff%2x%2x%2x", min(tbl.r*255,255), min(tbl.g*255,255), min(tbl.b*255,255)) or ""
	else
		return "|r"
	end
end

local new, del
do
	local cache = setmetatable({},{__mode="k"})
	function new(...)
		local t = next(cache)
		if t then
			cache[t] = nil
			for i = 1, select("#", ...) do
				table.insert(t, (select(i, ...)))
			end
			return t
		else
			return {...}
		end
	end
	function del(t, notDeep)
		if type(t) == "table" then
			for k, v in pairs(t) do
				if not (notDeep) and type(v) == "table" then
					del(v)
				end
				t[k] = nil
			end
			cache[t] = true
	end
		return nil
	end
end

aUF.del = del
aUF.new = new

local newFrame, delFrame
do
	local frameCache = {}
	local frameCount = {}
	function newFrame(kind, parent, extra)
		local frame
		if frameCache[kind] then
			frame = table.remove(frameCache[kind])
			if #frameCache[kind] == 0 then
				frameCache[kind] = del(frameCache[kind])
			end
			frame:SetParent(parent)
			if kind == "Texture" or kind == "FontString" then
				frame:SetDrawLayer(extra)
			end
			frame:Show()
		else
			frameCount[kind] = (frameCount[kind] or 0) + 1
			local name = "aUF" .. kind .. frameCount[kind]
			if kind == "Texture" then
				frame = parent:CreateTexture(name, extra)
			elseif kind == "FontString" then
				frame = parent:CreateFontString(name, extra)
			else
				if kind == "Cooldown" then
					frame = CreateFrame("Cooldown", name, parent, "CooldownFrameTemplate")
					frame:Show()
				else
					frame = CreateFrame(kind, name, parent)
				end
			end
		end
		return frame
	end

	function delFrame(frame)
		if not frame then return nil end
		local kind = frame:GetObjectType()
		if kind == "FontString" then
			frame:SetText("")
			frame:SetJustifyH("CENTER")
			frame:SetJustifyV("MIDDLE")
			frame:SetNonSpaceWrap(true)
			frame:SetTextColor(1, 1, 1, 1)
			frame:SetFontObject(nil)
		elseif kind == "Texture" then
			frame:SetTexture(nil)
			frame:SetVertexColor(1, 1, 1, 1)
			frame:SetBlendMode("BLEND")
			frame:SetDesaturated(false)
			frame:SetTexCoord(0, 1, 0, 1)
                        --SetTexCoordModifiesRect() in 3.3 not working
			--frame:SetTexCoordModifiesRect(false)
		elseif kind == "StatusBar" then
			frame:SetStatusBarColor(1, 1, 1, 1)
			frame:SetStatusBarTexture(nil)
			frame:SetValue(1)
			frame:SetOrientation("HORIZONTAL")
		end
		frame:Hide()
		if frame.SetBackdrop then
			frame:SetBackdrop(nil)
		end
		frame:SetParent(UIParent)
		frame:ClearAllPoints()
		frame:SetAlpha(1)
		frame:SetHeight(0)
		frame:SetWidth(0)
		local frameCache_kind = frameCache[kind]
		if not frameCache_kind then
			frameCache_kind = aUF.new()
			frameCache[kind] = frameCache_kind
		end
		frameCache_kind[#frameCache_kind+1] = frame
		return nil
	end
end

aUF.delFrame = delFrame
aUF.newFrame = newFrame

function aUF:Print(text)
	DEFAULT_CHAT_FRAME:AddMessage(L["GUnit"]..": "..(text or "nil"))
end

---------------
-- CONSTANTS --
---------------

aUF.defaultVars = {
	profile = {
		Locked = true,
		BarStyle = "Aluminium",
		BarFadeTime = 0.5,
		CurrentRaidSet = "1",
		HidePartyInRaid = true,
		FiveMan = true,
		
		CastbarColor = {
			r = 1.0,
			g = 0.7,
			b = 0.0,
		},
		HealthColor = {
			r = 0.4,
			g = 0.95,
			b = 0.3,
		},
		ManaColor = {
			[0] = { r = 0.3, g = 0.5, b = 0.85},
			[1] = { r = 0.9, g = 0.2, b = 0.3},
			[2] = { r = 1, g = 0.85, b = 0},
			[3] = { r = 1, g = 0.85, b = 0.1},
			[4] = { r = 0, g = 1, b = 1},
			[5] = { r = 0.5, g = 0.5, b = 0.5 },
			[6] = { b = 0.6, g = 0.45, r = 0.35},
		},
		TapDeadColor = {
			r = 0.5,
			g = 0.5,
			b = 0.5,
		},
		PartyFrameColors = {
			r = 0,
			g = 0,
			b = 0,
			a = 0.5
		},
		FrameBorderColors = {
			a = 1,
			b = 0.47,
			g = 0.28,
			r = 0.31,
		},
		XPColor = {
			r = 0.8,
			g = 0,
			b = 0.7,
		},
		RestedXPColor = {
			r = 0,
			g = 0,
			b = 1,
		},
		units = {
			["**"] = {
				BorderStyle = "SquareClean",
				fontOverride = false,
				fontOverrideSize = 0,
				fontOverrideType = "Myriad Condensed Web",
				FrameStyle = "ABF",
				Scale = 1,
				Width = 190,
				Height = 66,
				enabled = false,
			},
			player = {
				enabled = true,
				ShowXP = true,
				Height = 70,
			},
			pet = {
				enabled = true,
				ShowXP = true,
				Height = 60,
			},
			party = {
				enabled = true,
				GroupWith = "self",
				Height = 60,
				HideInRaid = true,
			},
			raid = {
				Width = 110,
				Height = 28,
			},
			raidpet = {
				Width = 110,
				Height = 28,
			},
			target = {
				enabled = true,
			},
			targettarget = {
				enabled = true,
				Width = 135,
				Height = 28,
			},
			pettarget = {
				Width = 135,
				Height = 28,
			},
			partytarget = {
				GroupWith = "parent",
				Width = 100,
				Height = 25,
				PetPos = 4,
			},
			partypet = {
				enabled = true,
				GroupWith = "parent",
				Width = 100,
				Height = 25,
				PetPos = 6,
			},
			targettargettarget = {
				Width = 135,
				Height = 28,
			},
		},
		partygroup = {
				Grow = "TOP",
				ShowAnchor = false,
				Exists = true,
				groupFilter = "",
				Padding = 21,
				AnchorOffset = 2,
		},
		partypetgroup = {
				Grow = "TOP",
				ShowAnchor = true,
				Exists = true,
				groupFilter = "",
				Padding = 21,
				AnchorOffset = 2,
				suffix = "pet",
		},
		subgroups = {
			["**"] = {
				Name = "New Group",
				Grow = "TOP",
				ShowAnchor = true,
				Padding = 2,
				AnchorOffset = 2,
				RaidSets = {"1","2","3","4","5","6","7","8","9","10"},
				groupFilter = "",
				groupBy = "GROUP",
			},
			group1 = {
				Name = "Group 1",
				groupFilter = "1",
				Exists = true,
			},
			group2 = {
				Name = "Group 2",
				groupFilter = "2",
				Exists = true,
			},
			group3 = {
				Name = "Group 3",
				groupFilter = "3",
				Exists = true,
			},
			group4 = {
				Name = "Group 4",
				groupFilter = "4",
				Exists = true,
			},
			group5 = {
				Name = "Group 5",
				groupFilter = "5",
				Exists = true,
			},
			group6 = {
				Name = "Group 6",
				groupFilter = "6",
				Exists = true,
			},
			group7 = {
				Name = "Group 7",
				groupFilter = "7",
				Exists = true,
			},
			group8 = {
				Name = "Group 8",
				groupFilter = "8",
				Exists = true,
			},
		},
		Positions = {
			aUFplayer = {
				x = 10,
				y = -15,
			},
			aUFpet = {
				x = 10,
				y = -120,
			},
			aUFtarget = {
				x = 250,
				y = -15,
			},
			aUFtargettarget = {
				x = 430,
				y = -15,
			},
			aUFtargettargettarget = {
				x = 430,
				y = -35,
			},
			party = {
				x = 10,
				y = -180,
			},
			partypet = {
				x = 185,
				y = -109,
			},
		},
		modulesDisabled = {},
	},
}

aUF.Borders = {
	RoundBlizz = {texture = "Interface\\Tooltips\\UI-Tooltip-Border",size = 16,insets = 4},
	SquareBlizz  = {texture = "Interface\\DialogFrame\\UI-DialogBox-Border",size = 16,insets = 5},
	SquareClean  = {texture = "Interface\\AddOns\\ag_UnitFrames\\images\\aUFBorder.tga",size = 8,insets = 4},
	Hidden  = {texture = "",size = 0,insets = 3, tileSize= 1},
}

local bars = {
	Otravi  	 = "Interface\\AddOns\\ag_UnitFrames\\images\\bars\\AceBarFrames.tga",
	Smooth 		 = "Interface\\AddOns\\ag_UnitFrames\\images\\bars\\smooth.tga",
	Gloss  		 = "Interface\\AddOns\\ag_UnitFrames\\images\\bars\\Gloss.tga",
	BantoBar	 = "Interface\\AddOns\\ag_UnitFrames\\images\\bars\\BantoBar.tga",
	Aluminium    = "Interface\\AddOns\\ag_UnitFrames\\images\\bars\\Aluminium.tga",
	Rupture  	 = "Interface\\AddOns\\ag_UnitFrames\\images\\bars\\Rupture.tga",
}

function aUF:UpdateMedia()
	aUF:CallMethodOnUnit("UpdateBarTexture")
end

function aUF:LoadSM()
	if SM then	
		for n,t in pairs(bars) do
			SM:Register("statusbar", n, t)
		end
		SM:Register("font", "Myriad Condensed Web", "Interface\\AddOns\\ag_UnitFrames\\fonts\\barframes.ttf")
		SM.RegisterCallback(aUF, "LibSharedMedia_Registered", aUF.UpdateMedia)
		SM.RegisterCallback(aUF, "LibSharedMedia_SetGlobal", aUF.UpdateMedia)
	end
end

function aUF:GetOverrideFont(object)
	if object.database.fontOverride then
		return SM:Fetch("font", object.database.fontOverrideType), object.database.fontOverrideSize
	end
end

function aUF:GetBarTexture()
	local texture
	if SM then
		texture = SM:Fetch("statusbar", aUF.db.profile.BarStyle)
	else
		texture = bars[aUF.db.profile.BarStyle]
	end
	return texture
end

function aUF:GetCurrentLayout(class)
	if not class then return end
	return aUF.layouts[aUF.db.profile.units[class].FrameStyle]
end

local bartypes = {}

function aUF:RegisterBarType(name, class)
	local tbl
	if type(class) == "table" then
		tbl = {}
		for k,v in pairs(class) do
			tbl[v] = true
		end
	end
	
	if type(tbl) == "table" or type(class) == "string" then
		bartypes[name] = tbl or class
	else
		bartypes[name] = true
	end
end

function aUF:UnregisterBarType(name)
	bartypes[name] = nil
end

function aUF:GetBarTypes()
	return bartypes
end
