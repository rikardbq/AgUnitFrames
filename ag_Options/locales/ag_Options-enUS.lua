local L = LibStub("AceLocale-3.0"):NewLocale("ag_Options","enUS",true)
if not L then return end

L["GUnit"] = "AG Units"
L["Open"] = true
L["Options Frame"] = true

L["player"]					= "Player"
L["pet"]					= "Player's Pet"
L["party"]					= "Party"
L["partypet"]				= "Party Pets"
L["partytarget"]			= "Party Targets"
L["target"]					= "Target"
L["focus"]					= "Focus"
L["focustarget"]			= "Focus' Target"
L["targettarget"]			= "Target's Target"
L["targettargettarget"]		= "Target of Target's Target"
L["raid"]					= "Raid"
L["raidpet"]				= "Raid Pets"
L["pettarget"]				= "Pet Target"

L["Units"] = true
L["Global Options"] = true
L["Unit Frames"] = true
L["Misc Options"] = true
L["Colors"] = true
L["Enabled Modules"] = true
L["Enabled Units"] = true
L["Sets which units you want frames created for."] = true

L["Health"] = true
L["Sets the health color."] = true
L["Mana"] = true
L["Sets the mana color."] = true
L["Rage"] = true
L["Sets the rage color."] = true
L["Energy"] = true
L["Sets the energy color."] = true
L["Rune"] = true
L["Sets the rune color."] = true
L["Pet Focus"] = true
L["Sets the pet focus color."] = true
L["Casting Bar"] = true
L["Sets the color for the casting bar progress."] = true
L["Experience"] = true
L["Sets the xp color."] = true
L["Rested Experience"] = true
L["Sets the rested xp color."] = true

L["Frames"] = true
L["Change the unit frame background colour."] = true
L["Borders"] = true
L["Change the frame border color."] = true

L["Lock Frames"] = true
L["Locks the unit frames."] = true

L["Bar Texture"] = true
L["Selects the global status bar texture."] = true

L["Bar Fade Time"] = true
L["Sets the time it takes for a bar to fade"] = true

L["Frame"] = true
L["Fonts"] = true
L["Font options."] = true
L["Bars"] = true
L["Bar options."] = true

L["Hide in Raid"] = true
L["Hides party frames in raid."] = true
L["Show 5-man Raid as Party"] = true
L["Handles as 5-man raid as if it was a normal party."] = true
L["Group With"] = true
L["Configures how these unit frames group."] = true
L["Parent"] = true
L["Free"] = true
L["Self"] = true

L["Relative Position"] = true
L["Sets the position of the child unit in relation to the parent frame."] = true
L["Left Top"] = true
L["Left2"] = "Left"
L["Left Bottom"] = true 
L["Right Top"] = true 
L["Right2"] = "Right"
L["Right Bottom"] = true
L["Above Left"] = true
L["Above2"] = "Above"
L["Above Right"] = true
L["Below Left"] = true
L["Below2"] = "Below"
L["Below Right"] = true

L["Frame Style"] = true
L["Adjust the style of the frame."] = true
L["Border"] = true
L["Adjust the border type."] = true
L["Width"] = true
L["Adjust the frame width."] = true
L["Height"] = true
L["Adjust the frame height."] = true
L["Scale"] = true
L["Adjust the scale of the frame."] = true

L["Bar Height Modifier"] = true
L["Adjust the height of the individual bars."] = true
L["Height Modifier"] = true
L["Sets the height factor of the given object."] = true

L["Font Type"] = true
L["Sets the override font type."] = true
L["Font Size"] = true
L["Sets the override font size."] = true
L["Font Override"] = true
L["Enables overriding of font type/size."] = true

L["Text Customization"] = true
L["Customizes the text on the unit frames."] = true

L["Color Name By Class"] = true
L["Color the unit's name with its raid class color."] = true

L["Tags"] = true
L["Configures what text the string should display."] = true

L["Hide in raid"] = true
L["Hide the party while in a raid."] = true
L["Show in 5 man raid"] = true
L["Show the party in raids smaller than 5."] = true

L["Enable Modules"] = true
L["Enable or disable this module"] = true

L["Groups"] = true
L["Group"] = true
L["Configuration of raid subgroups."] = true
L["New Group"] = true
L["Creates a new raid subgroup."] = true
L["Group Options."] = true
L["Show Group Header"] = true
L["Should the group header be shown or not."] = true
L["Anchor Offset"] = true
L["Sets the group offset from the anchor."] = true
L["Padding"] = true
L["Sets the distance between group members."] = true
L["Grow Direction"] = true
L["Controls which way the group grows."] = true
L["Delete Group"] = true
L["Deletes the current raid subgroup."] = true

L["Group Name"] = true
L["Sets the name of group, displayed in the anchor."] = true
L["Group Filter"] = true
L["Sets which units the group should show. For example '1,2,3' or 'MAGE,WARLOCK'. Seperate with commas, no spaces."] = true
L["Name List"] = true
L["Sets which players the group should show. For example 'Kristiano,Tritonus,Giustiniano'. Seperate with commas, no spaces."] = true
L["Sort By"] = true
L["Sorts the group by name, index, subgroup or class."] = true
L["Index"] = true
L["Class"] = true
L["Name"] = true
L["Subgroup"] = true
L["Up"] = true
L["Down"] = true
L["Left3"] = "Left"
L["Right3"] = "Right"

L["Modules"] = true

L["Setup Mode"] = true
L["Off"] = true
L["Enables the visibility of all enabled unit frames."] = true
L["Group change detected. Leaving frame setup mode."] = true

L["Absolute HP"] = true
L["Current and maximum HP in absolute values"] = true
L["Absolute Mana"] = true
L["Current and maximum MP in absolute values"] = true
L["Percent HP"] = true
L["Current HP in percent (Unknown value for people not in party/raid)"] = true
L["Percent MP"] = true
L["Current MP in percent"] = true
L["Current XP"] = true
L["Current and total required XP"] = true
L["Difference HP"] = true
L["Current HP minus maximum HP"] = true
L["Difference MP"] = true
L["Current MP minus maximum MP"] = true
L["Percent XP"] = true
L["Current XP in percent"] = true
L["Rested XP"] = true
L["Percent Rested XP"] = true
L["Rested XP as a percentage of the current level"] = true
L["Current Reputation"] = true
L["Reputation with the currently watched faction"] = true
L["Percent Reputation"] = true
L["Reputation with the currently watched faction as a percentage"] = true
L["Name"] = true
L["Character Name"] = true
L["Class"] = true
L["Character Class"] = true
L["Level"] = true
L["Character level"] = true
L["Race"] = true
L["Character Race"] = true
L["Raidgroup"] = true
L["Current raid subgroup"] = true
L["AFK/DND Status"] = true
L["Displays the AFK or DND status"] = true
L["Mobtype"] = true
L["Elite, boss or rare"] = true
L["Name (Raid Colored)"] = true
L["Raid Colored Character Name"] = true
	
L["ABF Layout"] = true
L["Bar Height"]  = true
L["Sets the height factor of the status bar."] = true
L["Bar Order"] = true
L["Sets the order of the status bar."] = true
L["Configure the ABF layout."] = true
L["Left Text"] = true
L["Right Text"] = true

---------------------------------------
--------[[ HealthBar Module ]]---------
---------------------------------------

L["Healthbar"] = true
L["Healthbar options."] = true
L["Color By Class"] = true
L["Colors the healthbar by class."] = true
L["Color By Alignment"] = true
L["Colors the healthbar by unit alignment towards you."] = true
L["Fade Healthbar"] = true
L["Fades healthbar changes."] = true
L["Smooth Healthbar"] = true
L["Smooths healthbar changes."] = true
L["Color Red at Aggro"] = true
L["Color the healthbar Red when the unit has aggro."] = true

---------------------------------------
---------[[ PowerBar Module ]]---------
---------------------------------------

L["Powerbar"] = true
L["Powerbar options."] = true
L["Enable Powerbar"] = true
L["Enables the powerbar."] = true
L["Fade Powerbar"] = true
L["Fades powerbar changes."] = true
L["Smooth Powerbar"] = true
L["Smooth powerbar changes."] = true

---------------------------------------
---------[[ Aura Module ]]-------------
---------------------------------------

L["Buffs"] = true
L["Debuffs"] = true
L["Auras"] = true
L["Aura options."] = true
L["Position"] = true
L["Sets the position in which auras should be displayed in releation to the unit frame."] = true
L["Right"] = true
L["Left"] = true
L["Above"] = true
L["Below"] = true
L["Inside"] = true
L["Hidden"] = true
L["Rows"] = true
L["Rows of auras to display."] = true
L["Columns"] = true
L["Columns of auras to display."] = true
L["Buff Filter"] = true
L["Only show buffs that you can cast."] = true
L["Debuff Filter"] = true
L["Only show debuffs that you can remove."] = true
L["Enable Highlights"] = true
L["Highlights the frame in color if debuffed."] = true
L["Prioritize Buffs"] = true
L["Prioritize buffs above debuffs"] = true
L["Enable Cooldown"] = true 
L["Shows a cooldown dial on auras"] = true
L["Enable Gloss"] = true
L["Shows a white glossy overlay on auras."] = true

---------------------------------------
---------[[ CastBar Module ]]-------------
---------------------------------------

L["Castbar"] = true
L["Castbar options."] = true
L["Enable Castbar"] = true
L["Displays a casting bar for the unit."] = true

---------------------------------------
---------[[ Combat Text Module ]]------
---------------------------------------

L["Combat Text"] = true
L["Combat text options."] = true
L["Enable Combat Text"] = true
L["Displays a text overlay with combat information."] = true

---------------------------------------
---------[[ Highlight Module ]]--------
---------------------------------------

L["Highlight"] = true
L["Highlight options."] = true
L["Enable Highlights"] = true
L["Highlights the frame when selected."] = true

---------------------------------------
---------[[ Experience Module ]]-------
---------------------------------------

L["Experience Bar"] = true
L["Experience options."] = true
L["Enable Experiencebar"] = true
L["Enables the Experiencebar."] = true
L["Show text"] = true
L["Show text on bar"] = true
L["Show Tooltip"] = true
L["Show tooltip when mousing over the bar"] = true
L["Enable Reputation"] = true
L["The Experience bar will show reputation if a faction is set to watched in the reputation pane."] = true

---------------------------------------
---------[[ Portrait Module ]]---------
---------------------------------------

L["Portrait"] = true
L["Portrait options."] = true
L["Enable Portrait"] = true
L["Draws a portrait of the character."] = true
L["Portrait Style"] = true
L["How to display the portrait."] = true
L["3d portrait"] = true
L["2d portrait"] = true
L["Class icon"] = true

---------------------------------------
---------[[ Range Check Module ]]------
---------------------------------------

L["Range Check"] = true
L["Range check options."] = true
L["Enable Range Check"] = true
L["Fades out of range units."] = true

---------------------------------------
---------[[ Threat Module ]]-----------
---------------------------------------

L["Enable Threat Border"] = true
L["Enables a border around the unit frame, displaying the threat status."] = true
L["Enable Threat Pulse"] = true
L["Enables the threat border animation."] = true

---------------------------------------
---------[[ Hide Blizz Module ]]-------
---------------------------------------
L["Blizzard Frame Visibility"] = true
L["Control the visibility of some Blizzard frames."] = true
L["hidePlayerFrame"] = "Hide Player Frame"
L["hidePlayerFramedesc"] = "Sets the visibility of the Blizzard player frame."
L["hidePartyFrame"] = "Hide Party Frame"
L["hidePartyFramedesc"] = "Sets the visibility of the Blizzard party frame."
L["hideTargetFrame"] = "Hide Target Frame"
L["hideTargetFramedesc"] = "Sets the visibility of the Blizzard target frame."
L["hideFocusFrame"] = "Hide Focus Frame"
L["hideFocusFramedesc"] = "Sets the visibility of the Blizzard focus frame."
L["hideCastFrame"] = "Hide Cast Frame"
L["hideCastFramedesc"] = "Sets the visibility of the Blizzard cast bar."