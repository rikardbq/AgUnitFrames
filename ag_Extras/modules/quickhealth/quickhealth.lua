local QuickHealth = LibStub("LibQuickHealth-1.0", true)
if not QuickHealth then return end
local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local eventFrame = CreateFrame("Frame")
local _G = getfenv(0)

local plugin = aUF:NewModule("Quickhealth")

plugin.defaultDisabledState = true

-- Map that will contain the units of every guid
local GUIDMap = {}

-- This function will regenerate the map
local function RemapGUIDMap()
	for key in pairs(GUIDMap) do
		GUIDMap[key] = nil;
	end
	for _, object in aUF:IterateUnitObjects() do
		if object.unit then
			local unit = object.unit
			local guid = UnitGUID(unit)
			if(guid) then
				if(not GUIDMap[guid]) then
					GUIDMap[guid] = {}
				end
				table.insert(GUIDMap[guid], unit)
			end
		end
	end
end


-- env changement code taken from interruptus

local handlerTable = {}
eventFrame:SetScript("OnEvent", function(self, event, ...)
	handlerTable[event](handlerTable, ...);
end)

local oldEnvUpdateHealth
local oldEnvStatusBarsOnValueChanged
local oldEnvTextFuncs = {}
function plugin:OnEnable()
	QuickHealth.RegisterCallback(self, "HealthUpdated", function(event, GUID, newHealth)
		local unitids = GUIDMap[GUID]
		if(unitids) then
			for i = 1, #unitids do
				local unit = unitids[i]
				aUF:OnEvent("UNIT_HEALTH", unit)
			end
		end
	end)
	RemapGUIDMap()
end

function plugin:OnObjectEnable()
	RemapGUIDMap()
end

function plugin:OnObjectDisable()
	RemapGUIDMap()
end

function plugin:OnDisable()
	QuickHealth.UnregisterCallback(self, "HealthUpdated")
end

-- Remap guids when party changed ONLY if we're not in a raid.
function handlerTable:PARTY_MEMBERS_CHANGED()
	if(GetNumRaidMembers() > 0) then return end
	RemapGUIDMap()
end

-- Remap guids when the raid roster gets updated.
handlerTable.RAID_ROSTER_UPDATE = RemapGUIDMap
eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")