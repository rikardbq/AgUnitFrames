local L = LibStub("AceLocale-3.0"):GetLocale("ag_Options", true)
local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")

local SM = LibStub("LibSharedMedia-3.0")

local options = {}
options.L = L
-----------------------------------------------------------------------------------------------------------------------------------------------------
---- getter / setter functions ----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

local function getClass(info,offset)
    return info[(#info + ((type(offset) == "number" and offset) or -2))]
end

local function getOption(info)
	return aUF.db.profile[info[#info]]
end

local function setOption(info, value)
	aUF.db.profile[info[#info]] = value
end

local function getColor(info)
	local key = info.arg
	if type(key) == "string" then
		return aUF.db.profile[key].r, aUF.db.profile[key].g, aUF.db.profile[key].b, aUF.db.profile[key].a
	else
		return aUF.db.profile.ManaColor[key].r, aUF.db.profile.ManaColor[key].g, aUF.db.profile.ManaColor[key].b, aUF.db.profile.ManaColor[key].a
	end
end

local function setColor(info, r, g, b, a)
	local key = info.arg
	if type(key) == "string" then
		aUF.db.profile[key] = { r = r, g = g, b = b, a = a }
	else
		aUF.db.profile.ManaColor[key] = { r = r, g = g, b = b, a = a }
	end
	if key == "PartyFrameColors" or key == "TargetFrameColors" or key == "FrameBorderColors" then
		aUF:CallMethodOnUnit("BorderBackground")
		for k,v in pairs(aUF.subgroups) do
			v:BorderBackground()
		end
	else
		aUF:CallMethodOnUnit("UpdateBarColor")
	end
end

local function setUnitFrameStyle(info, value)
    local class = getClass(info,info.arg)
	
	aUF:CallMethodOnUnit("UnapplyLayout",class,nil,true)
	
	aUF.db.profile.units[class].FrameStyle = value
		
	aUF:CallMethodOnUnit("ApplyLayout",class,nil,true)
	aUF:CallMethodOnUnit("BorderBackground",class)
	aUF:CallMethodOnUnit("UpdateAll",class)
	for k,v in pairs(aUF.subgroups) do
		v:UpdateWidth()
	end
end

local function setUnitBorderStyle(info, value)
    local class = getClass(info,info.arg)
	aUF.db.profile.units[class].BorderStyle = value
	aUF:CallMethodOnUnit("BorderBackground",class)
end

local function setUnitWidth(info, value)
    local class = getClass(info,info.arg)
	aUF.db.profile.units[class].Width = value
	aUF:CallMethodOnUnit("ApplyLayout",class)
	for k,v in pairs(aUF.subgroups) do
		v:UpdateWidth()
	end
end

local function setUnitHeight(info, value)
    local class = getClass(info,info.arg)
	aUF.db.profile.units[class].Height = value
	aUF:CallMethodOnUnit("ApplyLayout",class)
end

local function setUnitScale(info, value)
    local class = getClass(info,info.arg)
	aUF.db.profile.units[class].Scale = value
	aUF:CallMethodOnUnit("LoadScale",class)
	aUF:CallMethodOnUnit("LoadPosition",class)
	for k,v in pairs(aUF.subgroups) do
		v:UpdateScale()
		v:LoadPosition()
	end
end

local function setFontOption(info, value)
    local class = getClass(info,info.arg)
    local tbl = SM:List("font")
	aUF.db.profile.units[class][info[#info]] = tbl[value]
	aUF:CallMethodOnUnit("ApplyLayout",class)
--	aUF:CallMethodOnUnit("UpdateAll",class)
end

local function setUnitOption(info, value)
	local num = -2
	if info.arg and type(info.arg) == "number" then
		num = info.arg
	end
	aUF.db.profile.units[info[#info+num]][info[#info]] = value
	
	if aUF.setupMode then
		aUF:UpdateSetupMode(aUF.setupMode, true)
	else
		aUF:UpdatePartyGrouping(info[#info+num])
	end
end

local function getFrameOptions(info)
	local class = info[#info-3]
	local frame = info[#info-1]
	local dbPath = aUF.db.profile.units[class][info[#info]]
	return (dbPath and dbPath[frame]) or 1
end

local function setFrameOptions(info, value)
	local class = info[#info-3]
	local frame = info[#info-1]
	local dbPath = aUF.db.profile.units[class][info[#info]]
	if not dbPath then
		aUF.db.profile.units[class][info[#info]] = {}
		dbPath = aUF.db.profile.units[class][info[#info]]
	end
	dbPath[frame] = value
	aUF:CallMethodOnUnit("SetHeight",class)
end

local function textSort(alpha, bravo)
	local tag1 = aUF.textFunctions[alpha] 
	local tag2 = aUF.textFunctions[bravo]
	return (tag1.order or 0) < (tag2.order or 0)
end

function options.SetStringTags(class, db, stringName, tag, state)
	if not (type(db[stringName]) == "string") then
		db[stringName] = ""
	end
	local sortTbl = {}
	for word in string.gmatch(db[stringName], "%a+") do
		if not (word == tag) and aUF.textFunctions[word] then
			table.insert(sortTbl, word)
		end
	end
	if state then
		table.insert(sortTbl, tag)
	end
	
	if next(sortTbl) then
		table.sort(sortTbl, textSort)
		db[stringName] = table.concat(sortTbl, " ")
	else
		db[stringName] = ""
	end
end

local function setHideInRaid(info, value)
	if info.arg and type(info.arg) == "number" then
		aUF.db.profile[info[#info]] = value
	else
		aUF.db.profile[info[#info]] = value
	end
	aUF:RAID_ROSTER_UPDATE(true)
end

local function classOrder(class)
	local order
	if class:find("^player") then
		order = 50 + class:len()/1000
	elseif class:find("^pet") then
		order = 51 + class:len()/1000
	elseif class:find("^target") then
		order = 52 + class:len()/1000
	elseif class:find("^focus") then
		order = 53 + class:len()/1000		
	elseif class:find("^party") then
		order = 54 + class:len()/1000
	elseif class:find("^partypet") then
		order = 55 + class:len()/1000		
	elseif class:find("^raid") then
		order = 56 + class:len()/1000
	elseif class:find("^raidpet") then
		order = 55 + class:len()/1000
	else
		class = 58 + class:len()/1000
	end
	return order
end

options.table = {
	type = "group",
	icon = "",
	name = L["GUnit"],
	childGroups = "tree",
	args = {
	}
}

-----------------------------------------------------------------------------------------------------------------------------------------------------
---- on the run updates -----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

local unitOptionsTable	
local raidGroupOptions	
local groupOptions	
function options:AddUnitOptions(class)
	local path = options.table.args.Units
	path.args[class] = unitOptionsTable

	if class == "raid" then
		options:UpdateSubgroups()
	end
end

local stringValues

-----------------------------------------------------------------------------------------------------------------------------------------------------
---- populate enabled units/modules -----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

local xpetGroupTable = {parent = L["Parent"], free = L["Free"], self = L["Self"]}
local xtargetGroupTable = {parent = L["Parent"], free = L["Free"]}
local partyGroupTable = {free = L["Free"], self = L["Self"]}

local function getGroupOption(info)
	local raidClass = info[#info+((info.arg or 0) - 1)]
	local class = info[#info+(info.arg or 0)]
	
	if raidClass == "raid" then
		local group = info[#info+((info.arg or 0) + 1)]
		return (aUF.db.profile.subgroups[group] and aUF.db.profile.subgroups[group][info[#info]]) or nil
	elseif aUF.partyUnits[class] then
		return (aUF.db.profile[class.."group"] and aUF.db.profile[class.."group"][info[#info]]) or nil
	end
end

local function setGroupOption(info, value)
	local raidClass = info[#info+((info.arg or 0) - 1)]
	local class = info[#info+(info.arg or 0)]
	if raidClass == "raid" then
		local group = info[#info+((info.arg or 0) + 1)]
		if not (aUF.db.profile.subgroups[group]) then
			aUF.db.profile.subgroups[group] = {}
		end
		aUF.db.profile.subgroups[group][info[#info]] = value
		aUF.subgroups[group]:UpdateAll()
	elseif aUF.partyUnits[class] and aUF.db.profile[class.."group"] then
		aUF.db.profile[class.."group"][info[#info]] = value
		if aUF.subgroups[class] then
			aUF.subgroups[class]:UpdateAll()
		end
	end
end

--GUnits -> Units -> raid -> RaidGroupOptions -> party/group# -> <Option header>
local groupHidden = function(info)
	if info[#info+(info.arg or -3)] ~= "raid" or info[4] == "party" then
		return true
	end
end

-- grouping
raidGroupOptions = {
	name = L["Groups"],
	type = "group",
	desc = L["Configuration of raid subgroups."],
	order = 3,
	childGroups = "tree",
	args = {
		New = {
			name = L["New Group"],
			type = "execute",
			desc = L["Creates a new raid subgroup."],
			func = function(info) 
				aUF:CreateNewGroup()
				aUF.Options:UpdateSubgroups()
			end,
			order = 1,
			hidden = false,
		}
	},
	plugins = {},
	hidden = groupHidden,
	arg = -1,
}

groupOptions = {
	name = function(info)
		if info[#info] == "GroupOptions" then
			return L["Group"]
		else
			return (aUF.subgroups[info[#info]] and aUF.subgroups[info[#info]].database and aUF.subgroups[info[#info]].database.Name) or info[#info]
		end
	end,
	type = "group",
	desc = L["Group Options."],
	order = 3,
	arg = -1,
	args = {
		Name = {
			name = L["Group Name"],
			type = "input",
			desc = L["Sets the name of group, displayed in the anchor."],
			get = getGroupOption,
			set = setGroupOption,
			order = 2,
			arg = -2,
			hidden = function(info) 
				local class = info[#info-3]
				if class ~= "raid" then
					return true
				end
			end,
		},	
		ShowAnchor = {
			name = L["Show Group Header"],
			type = "toggle",
			desc = L["Should the group header be shown or not."],
			get = getGroupOption,
			set = setGroupOption,
			order = 1,
			arg = -2,
			hidden = false,
		},
		Group1 = {
			name = "",
			type = "group",
			inline = true,
			order = 3,
			hidden = false,
			args = {
				AnchorOffset = {
					name = L["Anchor Offset"],
					type = "range",
					desc = L["Sets the group offset from the anchor."],
					get = getGroupOption,
					set = setGroupOption,
					order = 2,
					arg = -3,
					min = 0,
					max = 25,
					step = 1,
					hidden = false,
				},
				Padding = {
					name = L["Padding"],
					type = "range",
					desc = L["Sets the distance between group members."],
					get = getGroupOption,
					set = setGroupOption,
					order = 3,
					arg = -3,
					min = 0,
					max = 50,
					step = 1,
					hidden = false,
				},
			}
		},
		Group2 = {
			name = "",
			type = "group",
			inline = true,
			order = 4,
			hidden = false,		
			args = {		
				Grow = {
					name = L["Grow Direction"],
					type = "select",
					desc = L["Controls which way the group grows."],
					values = {LEFT = L["Left3"], RIGHT = L["Right3"], BOTTOM = L["Up"], TOP = L["Down"]},
					get = getGroupOption,
					set = setGroupOption,
					order = 3,
					arg = -3,
					hidden = false,
				}
			}
		},
		Group3 = {
			name = "",
			type = "group",
			inline = true,
			order = 5,
			hidden = groupHidden,
			args = {			
				groupFilter = {
					name = L["Group Filter"],
					type = "input",
					desc = L["Sets which units the group should show. For example '1,2,3' or 'MAGE,WARLOCK'. Seperate with commas, no spaces."],
					get = getGroupOption,
					set = setGroupOption,
					order = 4,
					arg = -3,
					hidden = false,
				},
				nameList = {
					name = L["Name List"],
					type = "input",
					desc = L["Sets which players the group should show. For example 'Kristiano,Tritonus,Giustiniano'. Seperate with commas, no spaces."],
					get = getGroupOption,
					set = setGroupOption,
					order = 5,
					arg = -3,
					hidden = false,
				},
				groupBy = {
					name = L["Sort By"],
					type = "select",
					desc = L["Sorts the group by name, index, subgroup or class."],
					values = {NAME = L["Name"], INDEX = L["Index"], CLASS = L["Class"], GROUP = L["Subgroup"]},
					get = getGroupOption,
					set = setGroupOption,
					order = 6,
					arg = -3,
					hidden = false,
				}				
			}
		},
		Delete = {
			name = L["Delete Group"],
			type = "execute",
			desc = L["Deletes the current raid subgroup."],
			func = function(info)
				local group = info[#(info) - 1]
				if aUF.subgroups[group] then
					
					aUF.subgroups[group]:Delete()
				end
			end,
			order = 10,
			hidden = function(info) 
				local class = info[#info-3]
				if class ~= "raid" then
					return true
				end
			end,
		}		
	},
	plugins = {},
	hidden = function(info)
		local raidClass = info[#info-2]
		local class = info[#info+(info.arg or -1)]
		local group = info[#info]
		if class ~= "party" and class ~= "partypet" and raidClass ~= "raid" then
			return true
		elseif raidClass == "raid" then
			if group == "party" or not aUF.db.profile.subgroups[group] or not aUF.db.profile.subgroups[group].Exists then
				return true
			end
		elseif aUF.db.profile.units[class].GroupWith ~= "self" then
			return true
		end
	end,
}

function options:PopulateOptions()
	unitOptionsTable = {
		type = "group",
		childGroups = "tab",
		name = function(info) return L[info[#(info)]] end,
		order = function(info) return classOrder(info[#info]) end,
		hidden = function(info) return not(aUF.db.profile.units[info[#info]].enabled) end,
		get = function(info)
			if info.arg and type(info.arg) == "number" then
				return aUF.db.profile.units[info[#info+info.arg]][info[#info]]
			else
				return aUF.db.profile.units[info[#info-2]][info[#info]]
			end
		end,
		set = function(info, value)
			if info.arg and type(info.arg) == "number" then
				aUF.db.profile.units[info[#info+info.arg]][info[#info]] = value
			else
				aUF.db.profile.units[info[#info-2]][info[#info]] = value
			end
		end,
		handler = {
			UpdateSet = function(self, info, value)
				local class = info[(#info + ((type(info.arg) == "number" and info.arg) or -2))]
				aUF.db.profile.units[class][info[#info]] = value
				aUF:CallMethodOnUnit("UpdateAll",class)
			end,
			LayoutSet = function(self, info, value)
				local class = info[(#info + ((type(info.arg) == "number" and info.arg) or -2))]

				aUF.db.profile.units[class][info[#info]] = value
				aUF:CallMethodOnUnit("ApplyLayout",class)
				aUF:CallMethodOnUnit("UpdateAll",class)
			end
		},
		plugins = {},
		args = {
			Header = {
				type = "header",
				order = 1,
				name = function(info) return L[info[#(info) - 1]] end,
			},
			FrameStyle = {
				hidden = false,
				name = L["Frame"],
				type = "group",
				order = 1,
				args = {
					Group1 = {
						name = "",
						type = "group",
						inline = true,
						order = 1,
						args = {
							HidePartyInRaid = {
								name = L["Hide in Raid"],
								type = "toggle",
								desc = L["Hides party frames in raid."],
								get = getOption,
								set = setHideInRaid,
								order = 1,
								arg = -3,
								hidden = function(info) return not (info[#info-3] == "party") end,
							},
							FiveMan = {
								name = L["Show 5-man Raid as Party"],
								type = "toggle",
								desc = L["Handles as 5-man raid as if it was a normal party."],
								get = getOption,
								set = setHideInRaid,
								order = 1,
								arg = -3,
								hidden = function(info) return not (info[#info-3] == "party") end,
							},								
						},
					},
					Group2 = {
						name = "",
						type = "group",
						inline = true,
						order = 2,
						args = {
							FrameStyle = {
								name = L["Frame Style"],
								type = "select",
								desc = L["Adjust the style of the frame."],
								values = function() local layouts = {} for k, v in pairs(aUF.layouts) do if v:IsEnabled() then layouts[k] = k end end return layouts end,
								set = setUnitFrameStyle,
								order = 2,
								arg = -3,
							},
							BorderStyle = {
								name = L["Border"],
								type = "select",
								desc = L["Adjust the border type."],
								values = {RoundBlizz = "RoundBlizz", SquareBlizz = "SquareBlizz", SquareClean = "SquareClean", Hidden = "Hidden"},
								set = setUnitBorderStyle,
								order = 3,
								arg = -3,
							},
						},
					},
					Group3 = {
						name = "",
						type = "group",
						inline = true,
						order = 3,
						args = {					
							Width = {
								name = L["Width"],
								type = "range",
								desc = L["Adjust the frame width."],
								min = 10,
								max = 400,
								step = 1,
								set = setUnitWidth,
								order = 5,
								arg = -3,
							},
							Height = {
								name = L["Height"],
								type = "range",
								desc = L["Adjust the frame height."],
								min = 10,
								max = 400,
								step = 1,
								set = setUnitHeight,
								order = 6,
								arg = -3,
							},
							Scale = {
								name = L["Scale"],
								type = "range",
								desc = L["Adjust the scale of the frame."],
								min = 0.5,
								max = 2,
								step = 0.05,
								isPercent = true,
								set = setUnitScale,
								order = 7,
								arg = -3,
							},
						},
					},
					Group4 = {
						name = "",
						type = "group",
						inline = true,
						order = 4,
						args = {	
							GroupWith = {
								name = L["Group With"],
								type = "select",
								desc = L["Configures how these unit frames group."],
								values = function(info) 
										if string.find(info[#info-3], "%a+pet") then
											return xpetGroupTable
										elseif string.find(info[#info-3], "%a+target") then
											return xtargetGroupTable
										elseif info[#info-3] == "party" then
											return partyGroupTable
										end
									end,
								set = setUnitOption,
								order = 1,
								hidden = function(info) return not (aUF.partyUnits[info[#info-3]]) end,
								arg = -3,
							},
							PetPos = {
								name = L["Relative Position"],
								type = "select",
								desc = L["Sets the position of the child unit in relation to the parent frame."],
								values = { L["Left Top"], L["Left2"], L["Left Bottom"], L["Right Top"], L["Right2"], L["Right Bottom"], L["Above Left"], L["Above2"], L["Above Right"], L["Below Left"], L["Below2"], L["Below Right"]},
								set = setUnitOption,
								order = 1,
								hidden = function(info) return (not (aUF.partyUnits[info[#info-3]])) or ((not(string.find(info[#info-3],"pet"))) and (not(string.find(info[#info-3],"target")))) end,
								disabled = function(info) if not (aUF.db.profile.units[info[#info-3]].GroupWith == "parent") then return true end end,
								arg = -3,
							},							
						},
					},
				},
			},
			Fonts = {
				hidden = false,
				name = L["Fonts"],
				type = "group",
				desc = L["Font options."],
				order = 2,
				childGroups = "tree",
				args = {
					fontOverride = {
						name = L["Font Override"],
						type = "toggle",
						desc = L["Enables overriding of font type/size."],
						set = "LayoutSet",
						order = 1,
					},
					Group1 = {
						name = "",
						type = "group",
						inline = true,
						order = 2,
						args = {
							fontOverrideType = {
								name = L["Font Type"],
								type = "select",
								desc = L["Sets the override font type."],
								values = SM:List("font"),
								get = function(info)
									local tbl = SM:List("font")
									for k, v in pairs(tbl) do
										if aUF.db.profile.units[info[#info-3]][info[#info]] == v then
											return k
										end
									end
								end,
								set = setFontOption,
								order = 1,
								arg = -3,
								disabled = function(info) if not (aUF.db.profile.units[info[#info-3]].fontOverride) then return true end end,
							},
							fontOverrideSize = {
								name = L["Font Size"],
								type = "range",
								desc = L["Sets the override font size."],
								min = -10,
								max = 10,
								step = 1,
								set = "LayoutSet",
								arg = -3,
								disabled = function(info) if not (aUF.db.profile.units[info[#info-3]].fontOverride) then return true end end,
							},
						},
					},
				},
			},
			Bars = {
				hidden = false,
				name = L["Bars"],
				type = "group",
				desc = L["Bar options."],
				order = 3,
				args = {},
				plugins = {},
				disabled = function(info)
					local class = info[#info-1]
				end,
			},
			GroupOptions = groupOptions,
			RaidGroupOptions = raidGroupOptions
		}
	}
	
	options.table.args = {
		Units = {
			name = L["Unit Frames"],
			type = "group",
			order = 10,
			args = {
				FrameColors = {
					order = 3,
					inline = true,
					type= "group",
					name = L["Misc Options"],
					get = getColor,
					set = setColor,
					args = {
						Group1 = {
							name = "",
							type= "group",
							order = 1,
							inline = true,
							args = {
								BarStyle = {
									order = 2,
									name = L["Bar Texture"],
									type = "select",
									desc = L["Selects the global status bar texture."],
									get = function(info)
										local tbl = SM:List("statusbar")
										for k, v in pairs(tbl) do
											if aUF.db.profile[info[#info]] == v then
												return k
											end
										end
									end,
									set = function(key, value)
										local tbl = SM:List("statusbar")
										aUF.db.profile.BarStyle = tbl[value]
										aUF:CallMethodOnUnit("UpdateBarTexture")
									end,
									values = SM:List("statusbar"),
								},
								Setup = {
									order = 1,
									name = L["Setup Mode"],
									type = "select",
									desc = L["Enables the visibility of all enabled unit frames."],
									values = {off = L["Off"], party = L["party"], raid = L["raid"]},
									get = function() return aUF.setupMode or "off" end,
									set = function(info, value)
										aUF:UpdateSetupMode(value)
									end,
								},
								BarFadeTime = {
									order = 3,
									name = L["Bar Fade Time"],
									type = "range",
									desc = L["Sets the time it takes for a bar to fade"],
									min = 0.1,
									max = 2,
									step = 0.1,
									get = getOption,
									set = setOption,
								},
								
							},
						},
						Group2 = {
							name = "",
							type= "group",
							order = 2,
							inline = true,
							args = {
								Locked = {
									order = 2,
									name = L["Lock Frames"],
									type = "toggle",
									desc = L["Locks the unit frames."],
									get = getOption,
									set = setOption,
								},
								
							}
						}
					},
				},
				BarColors = {
					type= "group",
					name = L["Colors"],
					get = getColor,
					set = setColor,
					order = 2,
					inline = true,
					args = {
						partybg = {
							name = L["Frames"],
							type = "color",
							desc = L["Change the unit frame background colour."],
							hasAlpha = true,
							arg = "PartyFrameColors",
							order = 20,
						},
						borderbg = {
							name = L["Borders"],
							type = "color",
							desc = L["Change the frame border color."],
							hasAlpha = true,
							arg = "FrameBorderColors",
							order = 20,
						},
						Health = {
							name = L["Health"],
							type = "color",
							desc = L["Sets the health color."],
							arg = "HealthColor",
							order = 2,
						},
						Mana = {
							name = L["Mana"],
							type = "color",
							desc = L["Sets the mana color."],
							arg = 0,
							order = 3,
						},
						Rage = {
							name = L["Rage"],
							type = "color",
							desc = L["Sets the rage color."],
							arg = 1,
							order = 4,
						},
						Energy = {
							name = L["Energy"],
							type = "color",
							desc = L["Sets the energy color."],
							arg = 3,
							order = 6,
						},
						Rune = {
							name = L["Rune"],
							type = "color",
							desc = L["Sets the rune color."],
							arg = 6,
							order = 5,
						},						
						PetFocus = {
							name = L["Pet Focus"],
							type = "color",
							desc = L["Sets the pet focus color."],
							arg = 2,
							order = 7,
						},
						Casting = {
							type = "color",
							name = L["Casting Bar"],
							desc = L["Sets the color for the casting bar progress."],
							arg = "CastbarColor",
							order = 8,
						},
--[[
						Experience = {
							type = "color",
							name = L["Experience"],
							desc = L["Sets the xp color."],
							arg = "XPColor",
							order = 9,
						},
						Rested = {
							type = "color",
							name = L["Rested Experience"],
							desc = L["Sets the rested xp color."],
							arg = "RestedXPColor",
							order = 10,
						},
--]]						
					},
				},
			},
		},
		Modules = {
			name = L["Modules"],
			type = "group",
			order = 20,
			args = {},
			plugins = {},
		},
		Profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(aUF.db),
	}
	self.unitOptions = unitOptionsTable
	options:UpdateSubgroups()
	
	local path = options.table.args.Units
	local values = {}

	path.args.EnabledUnits = {
		order = 1,
		name = L["Enabled Units"],
		desc = L["Sets which units you want frames created for."],
		type = "multiselect",
		get = function(info, key)
			return aUF.db.profile.units[key].enabled
		end,
		set = function(info, key, value)
			aUF.db.profile.units[key].enabled = value
			aUF:LoadUnit(key)
			if not (value) then
				aUF:DisableAllFrames(key, true)
			else
				aUF:EnableAllFrames(key, true)
			end
			if aUF.setupMode then
				aUF:UpdateSetupMode(aUF.setupMode, true)
			else
				aUF:RAID_ROSTER_UPDATE(true)
			end
		end,
	}
	for k in pairs(aUF.soloUnits) do
		values[k] = L[k]
	end
	for k in pairs(aUF.partyUnits) do
		values[k] = L[k]
	end
	for k in pairs(aUF.raidUnits) do
		values[k] = L[k]
	end
	
	path.args.EnabledUnits.values = values

	local path = options.table.args.Modules
	local values = {}

	path.args.EnabledModules = {
		name = L["Enabled Modules"],
		desc = L["Enable or disable this module"],
		type = "multiselect",
		get = function(info, modname)
            local module = aUF.modules[modname]
			return module.enabledState
		end,
		set = function(info, modname)
			local module = aUF.modules[modname]
			if module.enabledState then
                aUF.db.profile.modulesDisabled[module.name] = false
				module:Disable()
			else
                aUF.db.profile.modulesDisabled[module.name] = true
				module:Enable()
			end
		end,
	}
	for k,v in pairs(aUF.modules) do
		if not (v.hideFromMenu or aUF.layouts[k]) then
			if (GetLocale() == "zhCN") or (GetLocale() == "zhTW") then 
				values[k] = fixModuleNames[k] or k --ModuleNames Locale
			else 
				values[k] = k
			end
		end
	end
	path.args.EnabledModules.values = values

	for k,v in pairs(aUF.modules) do
		local name = v.name
		local options
		if v.OnRegisterOptions then
			options = v:OnRegisterOptions()
		elseif self.ModOnRegisterOptions and self.ModOnRegisterOptions[k] then
			options = self.ModOnRegisterOptions[k]()
		end
		if options then
			local subConfig = v.subConfig
			if subConfig then
				if not unitOptionsTable.args[subConfig].plugins then
					unitOptionsTable.args[subConfig].plugins = {}
				end
				unitOptionsTable.args[subConfig].plugins[name] = {}
				unitOptionsTable.args[subConfig].plugins[name][name] = options
			else
				unitOptionsTable.plugins[name] = {}
				unitOptionsTable.plugins[name][name] = options
			end
		end
	end

	for k in pairs(aUF.soloUnits) do
		if aUF.db.profile.units[k].enabled then
			aUF.Options:AddUnitOptions(k)
		end
	end
	for k in pairs(aUF.partyUnits) do
		if aUF.db.profile.units[k].enabled then
			aUF.Options:AddUnitOptions(k)
		end
	end
	for k in pairs(aUF.raidUnits) do
		if aUF.db.profile.units[k].enabled then
			aUF.Options:AddUnitOptions(k)
		end
	end
	
	options.loaded = true
	for k,v in pairs(aUF.modules) do
		
	end
end


--options loading
local opened
function options:OpenOptions()
	if not (opened) then
		LibStub("AceConfig-3.0"):RegisterOptionsTable("GUnits", aUF.Options.table)
		LibStub("AceConfigDialog-3.0"):SetDefaultSize("GUnits", 810, 550)
		options:PopulateOptions()
		opened = true
	end
	LibStub("AceConfigDialog-3.0"):Open("GUnits")
end

function options:UpdateSubgroups()
	for k, v in pairs(aUF.subgroups) do
		if not unitOptionsTable.args.RaidGroupOptions.args[k] then
			unitOptionsTable.args.RaidGroupOptions.args[k] = groupOptions
		end
	end
end

-- end of options
aUF.Options = options

-- setup mode code
do
	local hooked, blizzUpdate
	local configureChildren

	blizzUpdate = function(self)
		if aUF.setupMode then
			local object = self.object
			local type = object.type
			if type then
				configureChildren(self, type)
			end
		end
	end
	
	function aUF:UpdateSetupMode(flag, force)
		if flag == "off" then
			flag = nil
		end
		if (not force) and aUF.setupMode == flag then
			return
		end
		aUF.setupMode = flag
		
		if not hooked then
			hooked = true
			hooksecurefunc("SecureGroupHeader_Update", blizzUpdate)
			hooksecurefunc("SecureGroupPetHeader_Update", blizzUpdate)
		end
		aUF:RAID_ROSTER_UPDATE(true)
		aUF:CallMethodOnUnit("UpdateSetupMode", nil, nil, flag)
	end
	
	--working tables
	local tokenTable = {}
	local sortingTable = {}
	local groupingTable = {}
	local tempTable = {}

	local function getRelativePointAnchor( point )
		point = strupper(point)
		if (point == "TOP") then
			return "BOTTOM", 0, -1
		elseif (point == "BOTTOM") then
			return "TOP", 0, 1
		elseif (point == "LEFT") then
			return "RIGHT", 1, 0
		elseif (point == "RIGHT") then
			return "LEFT", -1, 0
		elseif (point == "TOPLEFT") then
			return "BOTTOMRIGHT", 1, -1
		elseif (point == "TOPRIGHT") then
			return "BOTTOMLEFT", -1, -1
		elseif (point == "BOTTOMLEFT") then
			return "TOPRIGHT", 1, 1
		elseif (point == "BOTTOMRIGHT") then
			return "TOPLEFT", -1, 1
		else
			return "CENTER", 0, 0
		end
	end

	-- creates child frames and finished configuring them
	configureChildren = function(self, type)
		local point = self:GetAttribute("point") or "TOP"; --default anchor point of "TOP"
		local relativePoint, xOffsetMult, yOffsetMult = getRelativePointAnchor(point);
		local xMultiplier, yMultiplier =  abs(xOffsetMult), abs(yOffsetMult);
		local xOffset = self:GetAttribute("xOffset") or 0; --default of 0
		local yOffset = self:GetAttribute("yOffset") or 0; --default of 0
		local sortDir = self:GetAttribute("sortDir") or "ASC"; --sort ascending by default
		local columnSpacing = self:GetAttribute("columnSpacing") or 0;
		local startingIndex = self:GetAttribute("startingIndex") or 1;
		
		local unitCount
		if type == "raid" then
			unitCount = 5;
		else
			unitCount = 4;
		end
		
		local numDisplayed = unitCount - (startingIndex - 1)
		local unitsPerColumn = self:GetAttribute("unitsPerColumn")
		local numColumns;
		if ( unitsPerColumn and numDisplayed > unitsPerColumn ) then
			numColumns = min( ceil(numDisplayed / unitsPerColumn), (self:GetAttribute("maxColumns") or 1) )
		else
			unitsPerColumn = numDisplayed
			numColumns = 1
		end
		local loopStart = startingIndex
		local loopFinish = min((startingIndex - 1) + unitsPerColumn * numColumns, unitCount)
		local step = 1
	 
		numDisplayed = loopFinish - (loopStart - 1)
	 
		if ( sortDir == "DESC" ) then
			loopStart = unitCount - (startingIndex - 1)
			loopFinish = loopStart - (numDisplayed - 1)
			step = -1;
		end
	 
		-- ensure there are enough buttons
		local needButtons = max(1, numDisplayed)
		if not ( self:GetAttribute("child"..needButtons) ) then
			local buttonTemplate = self:GetAttribute("template")
			local templateType = self:GetAttribute("templateType") or "Button"
			local name = self:GetName()
			if not ( name ) then
				self:Hide()
				return;
			end
			for i = 1, needButtons, 1 do
				if not ( self:GetAttribute("child"..i) ) then
					local newButton = CreateFrame(templateType, name.."UnitButton"..i, self, buttonTemplate)
					SetupUnitButtonConfiguration(self, newButton)
					self:SetAttribute("child"..i, newButton)
				end
			end
		end
	 
		local columnAnchorPoint, columnRelPoint, colxMulti, colyMulti
		if ( numColumns > 1 ) then
			columnAnchorPoint = self:GetAttribute("columnAnchorPoint")
			columnRelPoint, colxMulti, colyMulti = getRelativePointAnchor(columnAnchorPoint)
		end
	 
		local buttonNum = 0
		local columnNum = 1
		local columnUnitCount = 0
		local currentAnchor = self
		for i = loopStart, loopFinish, step do
			buttonNum = buttonNum + 1
			columnUnitCount = columnUnitCount + 1
			if ( columnUnitCount > unitsPerColumn ) then
				columnUnitCount = 1
				columnNum = columnNum + 1
			end
	 
			local unitButton = self:GetAttribute("child"..buttonNum)
			unitButton:Hide()
			unitButton:ClearAllPoints()
			if ( buttonNum == 1 ) then
				unitButton:SetPoint(point, currentAnchor, point, 0, 0)
				if ( columnAnchorPoint ) then
					unitButton:SetPoint(columnAnchorPoint, currentAnchor, columnAnchorPoint, 0, 0)
				end
	 
			elseif ( columnUnitCount == 1 ) then
				local columnAnchor = self:GetAttribute("child"..(buttonNum - unitsPerColumn))
				unitButton:SetPoint(columnAnchorPoint, columnAnchor, columnRelPoint, colxMulti * columnSpacing, colyMulti * columnSpacing)
	 
			else
				unitButton:SetPoint(point, currentAnchor, relativePoint, xMultiplier * xOffset, yMultiplier * yOffset)
			end
			unitButton:SetAttribute("unit", type..((type == "raid" and 50) or i))
			unitButton:Show()
	 
			currentAnchor = unitButton
		end
		repeat
			buttonNum = buttonNum + 1
			local unitButton = self:GetAttribute("child"..buttonNum)
			if ( unitButton ) then
				unitButton:Hide()
				unitButton:SetAttribute("unit", nil)
			end
		until not ( unitButton )
	 
		local unitButton = self:GetAttribute("child1")
		local unitButtonWidth = unitButton:GetWidth()
		local unitButtonHeight = unitButton:GetHeight()
		if ( numDisplayed > 0 ) then
			local width = xMultiplier * (unitsPerColumn - 1) * unitButtonWidth + ( (unitsPerColumn - 1) * (xOffset * xOffsetMult) ) + unitButtonWidth
			local height = yMultiplier * (unitsPerColumn - 1) * unitButtonHeight + ( (unitsPerColumn - 1) * (yOffset * yOffsetMult) ) + unitButtonHeight
	 
			if ( numColumns > 1 ) then
				width = width + ( (numColumns -1) * abs(colxMulti) * (width + columnSpacing) )
				height = height + ( (numColumns -1) * abs(colyMulti) * (height + columnSpacing) )
			end
	 
			self:SetWidth(width)
			self:SetHeight(height)
		else
			local minWidth = self:GetAttribute("minWidth") or (yMultiplier * unitButtonWidth)
			local minHeight = self:GetAttribute("minHeight") or (xMultiplier * unitButtonHeight)
			self:SetWidth( max(minWidth, 0.1) )
			self:SetHeight( max(minHeight, 0.1) )
		end
	end
end

