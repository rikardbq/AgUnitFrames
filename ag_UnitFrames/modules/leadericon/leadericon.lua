local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local plugin = aUF:NewModule("Leadericon")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			["**"] = {
				showLeaderIcon = true,
			},		
		}
	})
end

function plugin:OnRegisterEvents(object, power)
	if plugin.db.profile.units[object.type].showLeaderIcon and not power then
		object:RegisterEvent("PARTY_LEADER_CHANGED", self.UpdateLeaderIcon)
		object:RegisterEvent("PARTY_MEMBERS_CHANGED", self.UpdateLeaderIcon)
	else
		object:UnregisterEvent("PARTY_LEADER_CHANGED", self.UpdateLeaderIcon)
		object:UnregisterEvent("PARTY_MEMBERS_CHANGED", self.UpdateLeaderIcon)
	end
end

function plugin:OnUpdateAll(object)
	self.UpdateLeaderIcon(object)
end

function plugin:OnMetroUpdate(object)
	self.UpdateLeaderIcon(object)
end

function plugin:OnEnable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectEnable(object)
		object:ApplyLayout()
		if object.unit then
			self.UpdateLeaderIcon(object)
			self:OnRegisterEvents(object)
		end
	end
end

function plugin:OnDisable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectDisable(object)
		object:ApplyLayout()
	end
end

function plugin:OnObjectDisable(object)
	if object.icons.leaderIcon then
		object.icons.leaderIcon = delFrame(object.icons.leaderIcon)		
		self:OnRegisterEvents(object, true)
	end
end

function plugin:OnObjectEnable(object)
	if plugin.db.profile.units[object.type].showLeaderIcon and not object.icons.leaderIcon then
		object.icons.leaderIcon = newFrame("Texture", object.top, "OVERLAY")
		object.icons.leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
	end
end

local setupMode = false
function plugin:OnUpdateSetupMode(object, flag)
	setupMode = flag
	self.UpdateLeaderIcon(object)
end

function plugin.UpdateLeaderIcon(self)
	if plugin.db.profile.units[self.type].showLeaderIcon then
		if setupMode and (self.type == "party" or self.unit == "player") then 
			self.icons.leaderIcon:Show() 
			return
		end
		if self.type == "raid" then
			local _, rank = GetRaidRosterInfo(self.number)
			if rank == 2 then
				self.icons.leaderIcon:Show()
				return
			end
		elseif self.type == "party" and tonumber(GetPartyLeaderIndex()) == tonumber(self.number) then
			self.icons.leaderIcon:Show()
			return
		elseif self.unit == "player" and IsPartyLeader() then
			self.icons.leaderIcon:Show()
			return
		end
	end
	if self.icons.leaderIcon then
		self.icons.leaderIcon:Hide()
	end
end