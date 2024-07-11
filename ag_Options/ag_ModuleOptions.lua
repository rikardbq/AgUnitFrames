local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local L = LibStub("AceLocale-3.0"):GetLocale("ag_Options", true)

aUF.Options.ModOnRegisterOptions = {}

do
	local plugin = aUF:GetModule("Auras", true)
	if plugin then
		local get = function(info)
			if info.arg and type(info.arg) == "number" then
				return plugin.db.profile.units[info[#info+info.arg]][info[#info]]
			else
				return plugin.db.profile.units[info[#info-2]][info[#info]]
			end
		end
			
		local function setUnitAuraPosition(info, value)
			local class = info[(#info + ((type(info.arg) == "number" and info.arg) or -2))]	
			plugin.db.profile.units[class][info[#info]] = value
			aUF:CallMethodOnUnit(plugin.OnObjectEnable, class, plugin)
			aUF:CallMethodOnUnit("ApplyLayout",class)
			aUF:CallMethodOnUnit(plugin.UpdateAuras, class)		
			aUF:CallMethodOnUnit(plugin.OnRegisterEvents, class, plugin)
		end

		local function setUnitAuraOption(info, value)
			local offset = ((type(info.arg) == "number" and info.arg) or -2)
			local class = info[(#info + offset)]
			plugin.db.profile.units[info[#info + offset]][info[#info]] = value
			aUF:CallMethodOnUnit(plugin.AuraPositions, class)	
			aUF:CallMethodOnUnit(plugin.AuraDimentions, class)	
			aUF:CallMethodOnUnit(plugin.UpdateAuras, class)		
		end

		local function setUnitAuraDebuffColor(info, value)
			local class = info[(#info + ((type(info.arg) == "number" and info.arg) or -2))]
			plugin.db.profile.units[class].AuraDebuffC = value
			aUF:CallMethodOnUnit(plugin.OnObjectEnable, class, plugin)
			aUF:CallMethodOnUnit(plugin.UpdateAuras, class)
			aUF:CallMethodOnUnit(plugin.OnRegisterEvents, class, plugin)
		end

		local function setUnitBuffFilter(info, value)
			local class = info[(#info + ((type(info.arg) == "number" and info.arg) or -2))]
			plugin.db.profile.units[class][info[#info]] = value and true or false
			aUF:CallMethodOnUnit(plugin.UpdateAuras, class)
		end

		local function setUnitAuraGloss(info, value)
			local class = info[(#info + ((type(info.arg) == "number" and info.arg) or -2))]
			plugin.db.profile.units[class].Gloss = value
			aUF:CallMethodOnUnit(plugin.SetAuraGloss, class)
		end
		
		local function auraDisabled(info)
			local class = info[(#info + (type(info.arg) == "number" and info.arg))]
			return plugin.db.profile.units[class].DebuffPos == plugin.db.profile.units[class].AuraPos
		end
		
		aUF.Options.ModOnRegisterOptions.Auras = function()
			local config = {
				hidden = function() return not (aUF.modules.Auras:IsEnabled()) end,
				name = L["Auras"],
				type = "group",
				desc = L["Aura options."],
				get = get,
				args = {
					Buffs = {
						name = L["Buffs"],
						type = "group",
						inline = true,
						order = 1,
						args = {
							AuraPos = {
								name = L["Position"],
								type = "select",
								desc = L["Sets the position in which auras should be displayed in releation to the unit frame."],
								set = setUnitAuraPosition,
								values = {Right = "Right", Left = "Left", Above = "Above", Below = "Below",Inside = "Inside",Hidden = "Hidden"},
								order = 1,
								arg = -3,
							},
							Group1 = {
								name = "",
								type = "group",
								inline = true,
								order = 2,
								args = {
									AuraRows = {
										name = L["Rows"],
										type = "range",
										desc = L["Rows of auras to display."],
										min = 1,
										max = 4,
										step = 1,
										set = setUnitAuraOption,
										order = 1,
										arg = -4,
									},
									AuraColumns = {
										name = L["Columns"],
										type = "range",
										desc = L["Columns of auras to display."],
										min = 8,
										max = 24,
										step = 1,
										set = setUnitAuraOption,
										arg = -4,
									},
								},
							},
							BuffFilter = {
								name = L["Buff Filter"],
								type = "toggle",
								desc = L["Only show buffs that you can cast."],
								set = setUnitBuffFilter,
								arg = -3,
								order = 3,
							},
						},
					},
					Debuffs = {
						name = L["Debuffs"],
						type = "group",
						inline = true,
						order = 2,
						args = {
							DebuffPos = {
								name = L["Position"],
								type = "select",
								desc = L["Sets the position in which auras should be displayed in releation to the unit frame."],
								set = setUnitAuraPosition,
								values = {Right = "Right", Left = "Left", Above = "Above", Below = "Below",Inside = "Inside",Hidden = "Hidden"},
								order = 1,
								arg = -3,
							},
							Group1 = {
								name = "",
								type = "group",
								inline = true,
								order = 2,
								args = {
									DebuffRows = {
										name = L["Rows"],
										type = "range",
										desc = L["Rows of auras to display."],
										min = 1,
										max = 4,
										step = 1,
										set = setUnitAuraOption,
										order = 1,
										arg = -4,
										disabled = auraDisabled					
									},
									DebuffColumns = {
										name = L["Columns"],
										type = "range",
										desc = L["Columns of auras to display."],
										min = 8,
										max = 24,
										step = 1,
										set = setUnitAuraOption,
										arg = -4,
										disabled = auraDisabled
									},
								},
							},
							DebuffFilter = {
								name = L["Debuff Filter"],
								type = "toggle",
								desc = L["Only show debuffs that you can remove."],
								set = setUnitBuffFilter,
								arg = -3,
								order = 3,
							},
						},
					},
					Group2 = {
						name = "",
						type = "group",
						inline = true,
						args = {
							AuraDebuffC = {
								name = L["Enable Highlights"],
								type = "toggle",
								desc = L["Highlights the frame in color if debuffed."],
								set = setUnitAuraDebuffColor,
								order = 1,
								arg = -3,
							},
							AuraPreferBuff = {
								name = L["Prioritize Buffs"],
								type = "toggle",
								desc = L["Prioritize buffs above debuffs"],
								set = setUnitBuffFilter,
								order = 3,
								arg = -3,
							},
							Gloss = {
								name = L["Enable Gloss"],
								type = "toggle",
								desc = L["Shows a white glossy overlay on auras."],
								set = setUnitAuraGloss,
								order = 4,
								arg = -3,
							},						
							cooldown = {
								name = L["Enable Cooldown"],
								type = "toggle",
								desc = L["Shows a cooldown dial on auras"],
								set = setUnitAuraOption,
								arg = -3,
							},			
						},
					},
				}
			}
			return config
		end
	end
end

do
	local plugin = aUF:GetModule("Healthbar", true)
	if plugin then
		local get = function(info)
			if info.arg and type(info.arg) == "number" then
				return plugin.db.profile.units[info[#info+info.arg]][info[#info]]
			else
				return plugin.db.profile.units[info[#info-2]][info[#info]]
			end
		end
		local function optionSet(info, value)
			local class = info[(#info - 3)]
			plugin.db.profile.units[class][info[#info]] = value
			aUF:CallMethodOnUnit(plugin.HealthBarColor, class)
		end
		function aUF.Options.ModOnRegisterOptions.Healthbar()
			local config = {
				inline = true,
				name = L["Healthbar"],
				desc = L["Healthbar options."],
				type = 'group',
				args = {
					ClassColorBars = {
						name = L["Color By Class"],
						type = "toggle",
						desc = L["Colors the healthbar by class."],
						set = optionSet,
						arg = -3,
						get = get,
					},
					TargetShowHostile = {
						name = L["Color By Alignment"],
						type = "toggle",
						desc = L["Colors the healthbar by unit alignment towards you."],
						set = optionSet,
						hidden = function(info)
							local class = info[(#info + ((type(info.arg) == "number" and info.arg) or -2))]
							return not string.find(class, "target")
						end,
						arg = -3,
						get = get,
					},
					FadeHealth = {
						name = L["Fade Healthbar"],
						type = "toggle",
						desc = L["Fades healthbar changes."],
						set = optionSet,
						arg = -3,
						get = get,
					},
					SmoothHealth = {
						name = L["Smooth Healthbar"],
						type = "toggle",
						desc = L["Smooths healthbar changes."],
						set = optionSet,
						arg = -3,
						get = get,
					},
					AggroHealth = {
						name = L["Color Red at Aggro"],
						type = "toggle",
						desc = L["Color the healthbar Red when the unit has aggro."],
						set = optionSet,
						arg = -3,
						get = get,
					},
				}
			}
			return config
		end
	end
end

do
	local plugin = aUF:GetModule("Powerbar", true)
	if plugin then
		local get = function(info)
			if info.arg and type(info.arg) == "number" then
				return plugin.db.profile.units[info[#info+info.arg]][info[#info]]
			else
				return plugin.db.profile.units[info[#info-2]][info[#info]]
			end
		end
		local function layoutSet(info, value)
			local class = info[(#info + ((type(info.arg) == "number" and info.arg) or -2))]					
			plugin.db.profile.units[class][info[#info]] = value
			aUF:CallMethodOnUnit(plugin.OnObjectEnable, class, plugin)
			aUF:CallMethodOnUnit(plugin.OnRegisterEvents, class, plugin)
			aUF:CallMethodOnUnit("ApplyLayout",class)
			aUF:CallMethodOnUnit("UpdateAll",class)
		end
		local function fadeSet(info, value)
			local class = info[(#info - 3)]
			plugin.db.profile.units[class][info[#info]] = value
			aUF:CallMethodOnUnit(plugin.OnRegisterEvents, class, plugin)
			aUF:CallMethodOnUnit(plugin.UpdateColor, class)		
		end
		function aUF.Options.ModOnRegisterOptions.Powerbar()
			local config = {
				inline = true,
				hidden = function() return not (aUF.modules.Powerbar:IsEnabled()) end,
				name = L["Powerbar"],
				desc = L["Powerbar options."],
				type = 'group',
				args = {
					ShowMana = {
						name = L["Enable Powerbar"],
						type = "toggle",
						desc = L["Enables the powerbar."],
						set = layoutSet,
						arg = -3,
						get = get,
					},
					FadeMana = {
						name = L["Fade Powerbar"],
						type = "toggle",
						desc = L["Fades powerbar changes."],
						set = fadeSet,
						arg = -3,
						get = get,
					},
					SmoothMana = {
						name = L["Smooth Powerbar"],
						type = "toggle",
						desc = L["Smooth powerbar changes."],
						set = fadeSet,
						arg = -3,
						get = get,
					},
				},
			}
			return config
		end
	end
end

do
	local plugin = aUF:GetModule("Highlight", true)
	if plugin then
		local get = function(info)
			if info.arg and type(info.arg) == "number" then
				return plugin.db.profile.units[info[#info+info.arg]][info[#info]]
			else
				return plugin.db.profile.units[info[#info-2]][info[#info]]
			end
		end
		local set = function(info, value)
			local class = info[(#info + ((type(info.arg) == "number" and info.arg) or -2))]
			plugin.db.profile.units[class][info[#info]] = value
			aUF:CallMethodOnUnit(plugin.OnObjectEnable, class, plugin)
		end	
		function aUF.Options.ModOnRegisterOptions.Highlight()
			local config = {
				hidden = function() return not (plugin:IsEnabled()) end,		
				name = L["Highlight"],
				desc = L["Highlight options."],
				type = 'group',
				args = {
					HighlightSelected = {
						name = L["Enable Highlights"],
						type = "toggle",
						desc = L["Highlights the frame when selected."],
						set = set,
						get = get,
					}
				}
			}
			return config
		end
	end
end

do
	local plugin = aUF:GetModule("Combattext", true)
	if plugin then
		local get = function(info)
			if info.arg and type(info.arg) == "number" then
				return plugin.db.profile.units[info[#info+info.arg]][info[#info]]
			else
				return plugin.db.profile.units[info[#info-2]][info[#info]]
			end
		end
		local function layoutSet(info, value)
			local class = info[(#info + ((type(info.arg) == "number" and info.arg) or -2))]					
			plugin.db.profile.units[class][info[#info]] = value
			aUF:CallMethodOnUnit(plugin.OnObjectEnable, class, plugin)
			aUF:CallMethodOnUnit(plugin.OnRegisterEvents, class, plugin)
			aUF:CallMethodOnUnit("ApplyLayout",class)
			aUF:CallMethodOnUnit("UpdateAll",class)
		end
		function aUF.Options.ModOnRegisterOptions.Combattext()
			local config = {
				hidden = function() return not (aUF.modules.Combattext:IsEnabled()) end,		
				name = L["Combat Text"],
				desc = L["Combat text options."],
				type = 'group',
				args = {
					ShowCombat = {
						name = L["Enable Combat Text"],
						type = "toggle",
						desc = L["Displays a text overlay with combat information."],
						set = layoutSet,
						get = get,
					}	
				}
			}
			return config
		end
	end
end

do
	local plugin = aUF:GetModule("Castbar", true)
	if plugin then
		local get = function(info)
			if info.arg and type(info.arg) == "number" then
				return plugin.db.profile.units[info[#info+info.arg]][info[#info]]
			else
				return plugin.db.profile.units[info[#info-2]][info[#info]]
			end
		end
		local function castbarSet(info, value)
			local class = info[(#info - 3)]
			plugin.db.profile.units[class][info[#info]] = value
			aUF:CallMethodOnUnit(plugin.OnObjectEnable, class, plugin)
			aUF:CallMethodOnUnit(plugin.OnRegisterEvents, class, plugin)
			aUF:CallMethodOnUnit("ApplyLayout",class)
			aUF:CallMethodOnUnit(plugin.OnRegisterEvents, class, plugin)
		end
		function aUF.Options.ModOnRegisterOptions.Castbar()
			local config = {
				inline = true,
				hidden = function() return not (aUF.modules.Castbar:IsEnabled()) end,		
				name = L["Castbar"],
				desc = L["Castbar options."],
				type = 'group',
				args = {
					CastBar = {
						name = L["Enable Castbar"],
						type = "toggle",
						desc = L["Displays a casting bar for the unit."],
						set = castbarSet,
						arg = -3,
						get = get,
					},	
				},
			}
			return config
		end
	end
end

do
	local plugin = aUF:GetModule("Portrait", true)
	if plugin then
		local get = function(info)
			if info.arg and type(info.arg) == "number" then
				return plugin.db.profile.units[info[#info+info.arg]][info[#info]]
			else
				return plugin.db.profile.units[info[#info-2]][info[#info]]
			end
		end
		local function layoutSet(info, value)
			local class = info[(#info + ((type(info.arg) == "number" and info.arg) or -2))]					
			plugin.db.profile.units[class][info[#info]] = value
			aUF:CallMethodOnUnit(plugin.OnObjectEnable, class, plugin)
			aUF:CallMethodOnUnit(plugin.OnRegisterEvents, class, plugin)
			aUF:CallMethodOnUnit("ApplyLayout",class)
			aUF:CallMethodOnUnit("UpdateAll",class)
		end
		function aUF.Options.ModOnRegisterOptions.Portrait()
			config = {
				hidden = function() return not (aUF.modules.Portrait:IsEnabled()) end,		
				name = L["Portrait"],
				desc = L["Portrait options."],
				type = 'group',
				args = {
					Portrait = {
						name = L["Enable Portrait"],
						type = "toggle",
						desc = L["Draws a portrait of the character."],
						set = layoutSet,
						get = get,
					},
					PortraitStyle = {
						name = L["Portrait Style"],
						type = "select",
						desc = L["How to display the portrait."],
						values = {
							["3d"] = L["3d portrait"],
							["2d"] = L["2d portrait"],
							["icon"] = L["Class icon"],
						},
						set = layoutSet,
						get = get,
					},
				},
			}
			return config
		end
	end
end

do
	local plugin = aUF:GetModule("Rangecheck", true)
	if plugin then
		local get = function(info)
			if info.arg and type(info.arg) == "number" then
				return plugin.db.profile.units[info[#info+info.arg]][info[#info]]
			else
				return plugin.db.profile.units[info[#info-2]][info[#info]]
			end
		end
		local set = function(info, value)
			local class = info[(#info + ((type(info.arg) == "number" and info.arg) or -2))]
			plugin.db.profile.units[class][info[#info]] = value
			aUF:CallMethodOnUnit(plugin.OnUpdateAll, class, plugin)
		end	
		function aUF.Options.ModOnRegisterOptions.Rangecheck()
			local config = {
				hidden = function() return not (plugin:IsEnabled()) end,		
				name = L["Range Check"],
				desc = L["Range check options."],
				type = 'group',
				args = {
					rangeCheck = {
						name = L["Enable Range Check"],
						type = "toggle",
						desc = L["Fades out of range units."],
						get = get,
						set = set,
					},	
				},
			}
			return config
		end
	end
end

do
	local plugin = aUF:GetModule("Xprepbar", true)
	if plugin then
		local get = function(info)
			if info.arg and type(info.arg) == "number" then
				return plugin.db.profile.units[info[#info+info.arg]][info[#info]]
			else
				return plugin.db.profile.units[info[#info-2]][info[#info]]
			end
		end
		local function layoutSet(info, value)
			local class = info[(#info + ((type(info.arg) == "number" and info.arg) or -2))]					
			plugin.db.profile.units[class][info[#info]] = value
			aUF:CallMethodOnUnit(plugin.OnObjectEnable, class, plugin)
			aUF:CallMethodOnUnit(plugin.OnRegisterEvents, class, plugin)
			aUF:CallMethodOnUnit("ApplyLayout",class)
			aUF:CallMethodOnUnit("UpdateAll",class)
		end
		local function setTooltip(info, value)
			local class = info[(#info -3)]
			plugin.db.profile.units[class].ShowXPTooltip = value
			aUF:CallMethodOnUnit(plugin.ToggleTooltip, class)	
		end
		local function setRep(info, value)
			local class = info[(#info -3)]
			plugin.db.profile.units[class].ShowRep = value
			aUF:CallMethodOnUnit(plugin.UpdateXP, class)	
		end	
		function aUF.Options.ModOnRegisterOptions.Xprepbar()
			local config = {
				inline = true,
				hidden = function(info) return (not (aUF.modules.Xprepbar:IsEnabled() and aUF.modules.Xprepbar.inherit[info[#info-2]])) end,
				name = L["Experience Bar"],
				desc = L["Experience options."],
				type = 'group',
				args = {
					ShowXP = {
						name = L["Enable Experiencebar"],
						type = "toggle",
						desc = L["Enables the Experiencebar."],
						set = layoutSet,
						get = get,
						arg = -3,
						hidden = false,
					},
					ShowRep = {
						name = L["Enable Reputation"],
						type = "toggle",
						desc = L["The Experience bar will show reputation if a faction is set to watched in the reputation pane."],
						set = setRep,
						get = get,
						arg = -3,
						hidden = function(info)
							local class = info[(#info -3)]
							if not (class == "player") then
								return true
							end
						end,
					},				
					ShowXPTooltip = {
						name = L["Show Tooltip"],
						type = "toggle",
						desc = L["Show tooltip when mousing over the bar"],
						set = setTooltip,
						get = get,
						arg = -3,
						hidden = false,
					},
				},
			}
			return config
		end
	end
end

do
	local plugin = aUF:GetModule("Aggroborder", true)
	if plugin then
		local get = function(info)
			if info.arg and type(info.arg) == "number" then
				return plugin.db.profile.units[info[#info+info.arg]][info[#info]]
			else
				return plugin.db.profile.units[info[#info-2]][info[#info]]
			end
		end
		local function setThreat(info, value)
			local class = info[(#info -3)]
			plugin.db.profile.units[class][info[#info]] = value
			aUF:CallMethodOnUnit(plugin.OnObjectEnable, class, plugin)	
			aUF:CallMethodOnUnit(plugin.OnRegisterEvents, class, plugin)	
			aUF:CallMethodOnUnit(plugin.ThreatEvent, class)	
		end
		function aUF.Options.ModOnRegisterOptions.Aggroborder()
			local config = {
				inline = true,
				hidden = function(info) return (not (plugin:IsEnabled() and plugin.inherit == info[#info-2])) end,
				name = "",
				type = 'group',
				args = {
					ThreatBorder = {
						name = L["Enable Threat Border"],
						type = "toggle",
						desc = L["Enables a border around the unit frame, displaying the threat status."],
						set = setThreat,
						get = get,
						arg = -3,
						hidden = false,
					},
					ThreatPulse = {
						name = L["Enable Threat Pulse"],
						type = "toggle",
						desc = L["Enables the threat border animation."],
						set = setThreat,
						get = get,
						arg = -3,
						hidden = false,
						disabled = function(info)
							local class = info[(#info -3)]
							if not plugin.db.profile.units[class].ThreatBorder then
								return true
							end
						end,
					},
				},
			}
			return config
		end
	end
end

do
	local plugin = aUF:GetModule("Hideblizz", true)
	if plugin then
		local get = function(info)
			return plugin.db.profile[info[#info]]
		end
		local set = function(info, value)
			plugin.db.profile[info[#info]] = value
			plugin:UpdateBlizzVisibility()
		end	
		local argtbl = {
			name = function(info) return L[info[#info]] end,
			type = "toggle",
			desc = function(info) return L[info[#info].."desc"] end,
			get = get,
			set = set,
		}

		function aUF.Options.ModOnRegisterOptions.Hideblizz()
			local config = {
				hidden = function() return not (plugin:IsEnabled()) end,		
				name = L["Blizzard Frame Visibility"],
				desc = L["Control the visibility of some Blizzard frames."],
				type = 'group',
				args = {
					hidePlayerFrame = argtbl,
					hidePartyFrame = argtbl,
					hideTargetFrame = argtbl,
					hideFocusFrame = argtbl,
					hideCastFrame = argtbl
				},
			}
			aUF.Options.table.args.Modules.plugins.Hideblizz = {}
			aUF.Options.table.args.Modules.plugins.Hideblizz.Hideblizz = config
		end
	end
end

-- ABF LAYOUT OPTIONS!
-- DOING SOMETHING LIKE THIS IN YOUR OWN LAYOUT ADDON WILL MAKE THOUSANDS OF HAPPY BUNNIES COME TRUE
-- Use the "OnRegisterOptions" method to return your options table. Don't use "ModOnRegisterOptions", it is for modules included in the addon only.

do
	local ABF = aUF:GetModule("ABF", true)
	if ABF then
		local function barSet(info, value)
			local class = info[#info-3]
			local option = info[#info]
			local bar = info[#info-1]
			ABF.db.profile[class][option][bar] = value
			aUF:CallMethodOnUnit("ApplyLayout",class)
			aUF:CallMethodOnUnit("UpdateAll",class)
		end
		
		local function barGet(info)
			local class = info[#info-3]
			local option = info[#info]
			local bar = info[#info-1]
			return ABF.db.profile[class][option][bar]
		end

		local function getStringTags(info, tag)
			local class = info[#info-4]
			local bar = info[#info-2]
			local position = info[#info-1]
			local tag = info[#info]
			local dbPath = ABF.db.profile[class][bar..position]
			
			if dbPath and string.find(dbPath, tag) then
				return true
			end
		end
		
		local function setStringTags(info, state)
			local class = info[#info-4]
			local tag = info[#info]
			local position = info[#info-1]
			local bar = info[#info-2]
			local text = bar..position
	
			aUF.Options.SetStringTags(class, ABF.db.profile[class], text, tag, state)
			aUF:CallMethodOnUnit("ApplyLayout",class)
		end
		
		local tagToggle = {
			name = function(info) 
				local name = aUF.textFunctions[info[#info]].name
				-- We have to use rawget here to prevent AceLocale crapping out if the tag isn't one included with the addon (it doesn't have a locale)
				return (name and rawget(aUF.Options.L, name)) or name or info[#info]
			end,
			desc = function(info) 
				local desc = aUF.textFunctions[info[#info]].desc
				return (desc and rawget(aUF.Options.L, desc)) or desc or info[#info]
			end,
			type = "toggle",
			get = getStringTags,
			set = setStringTags,
		}

		local tagArgs = {}
		for k, v in pairs(aUF.textFunctions) do
			if not tagArgs[k] then
				tagArgs[k] = tagToggle
			end
		end			
		
		local createOptions = {
			hidden = function(info)
				local class = info[#info-2]
				local classList = aUF:GetBarTypes()[info[#info]]
				if ((type(classList) == "table" and classList[class]) or (type(classList) == "string" and classList == class) or classList == true) then
					return false
				else
					return true
				end
			end,
			name = function(info) return info[#info] end,
			type = 'group',
			order = function(info)
				local class = info[#info-2]
				return ABF.db.profile[class].order[info[#info]]
			end,
			args = {
				height = {
					name = L["Bar Height"],
					type = "range",
					desc = L["Sets the height factor of the status bar."],
					set = barSet,
					get = barGet,
					hidden = false,
					min = 0.1,
					max = 5,
					step = 0.1,
				},
				order = {
					name = L["Bar Order"],
					type = "range",
					desc = L["Sets the order of the status bar."],
					set = barSet,
					get = barGet,
					hidden = false,
					min = 0,
					max = 50,
					step = 1,
				},
				LeftText = {
					name = L["Left Text"],
					type = "group",
					args = tagArgs,
					hidden = false,
				},
				RightText = {
					name = L["Right Text"],
					type = "group",
					args = tagArgs,
					hidden = false,
				},					
			},
		}		

		local config
		function aUF.Options.ModOnRegisterOptions.ABF()
			if not config then
				config = {
					hidden = function(info) 
						local class = info[#info-1]
						return not (ABF == aUF:GetCurrentLayout(class))
					end,
					name = L["ABF Layout"],
					desc = L["Configure the ABF layout."],
					type = 'group',
					args = {},
					plugins = {}
				}	
			end
			for k, v in pairs(aUF:GetBarTypes()) do
				if not config.plugins[k] then
					config.plugins[k] = {}
				end
				config.plugins[k][k] = createOptions
			end
			return config
		end
	end
end