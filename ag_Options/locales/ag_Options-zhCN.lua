local L = LibStub("AceLocale-3.0"):NewLocale("ag_Options","zhCN")
if not L then return end

L["GUnit"] = "头像增强 AG"
L["Open"] = "打开"
L["Options Frame"] = "设置面板"

L["player"]					= "玩家"
L["pet"]					= "玩家的宠物"
L["party"]					= "队友"
L["partypet"]				= "队友的宠物"
L["partytarget"]			= "队友目标"
L["target"]					= "目标"
L["focus"]					= "焦点"
L["focustarget"]			= "焦点目标"
L["targettarget"]			= "目标的目标"
L["targettargettarget"]		= "目标的TOT"
L["raid"]					= "团队"
L["raidpet"]				= "团队宠物"
L["pettarget"]				= "宠物目标"

L["Units"] = "单位"
L["Global Options"] = "全局选项"
L["Unit Frames"] = "单位框体"
L["Misc Options"] = "细节设置"
L["Colors"] = "状态条颜色"
L["Enabled Modules"] = "启用模块"
L["Enabled Units"] = "已启用单位"
L["Sets which units you want frames created for."] = "描述"

L["Health"] = "生命"
L["Sets the health color."] = "设置生命条颜色"
L["Mana"] = "法力"
L["Sets the mana color."] = "设置法力条颜色"
L["Rage"] = "怒气"
L["Sets the rage color."] = "设置怒气条颜色"
L["Energy"] = "能量"
L["Sets the energy color."] = "设置能量条颜色"
L["Rune"] = "符文能量"
L["Sets the rune color."] = "设置符文能量颜色"
L["Pet Focus"] = "宠物集中值"
L["Sets the pet focus color."] = "设置宠物集中值颜色"
L["Casting Bar"] = "施法条"
L["Sets the color for the casting bar progress."] = "设置施法进度条颜色"
L["Experience"] = "经验条"
L["Sets the xp color."] = "设置经验条颜色"
L["Rested Experience"] = "奖励经验"
L["Sets the rested xp color."] = "设置奖励经验的颜色"

L["Frames"] = "框体"
L["Change the unit frame background colour."] = "改变单位框体的背景颜色"
L["Borders"] = "边框"
L["Change the frame border color."] = "改变框体边框的颜色"

L["Lock Frames"] = "锁定框体"
L["Locks the unit frames."] = "锁定单位框体"

L["Bar Texture"] = "状态条素材"
L["Selects the global status bar texture."] = "选择你的状态条素材"

L["Bar Fade Time"] = "状态条淡出时间"
L["Sets the time it takes for a bar to fade"] = "设置状态条的淡出时间"

L["Frame"] = "框体"
L["Fonts"] = "字体"
L["Font options."] = "字体选项"
L["Bars"] = "状态条"
L["Bar options."] = "状态条选项"

L["Hide in Raid"] = "团队中隐藏队伍"
L["Hides party frames in raid."] = "当你在团队中,隐藏队伍框体"
L["Show 5-man Raid as Party"] = "显示5人团队队伍"
L["Handles as 5-man raid as if it was a normal party."] = "当是5人团队的时候，当作小队处理"
L["Group With"] = "队伍"
L["Configures how these unit frames group."] = "如何配置队伍框体"
L["Parent"] = "继承窗体"
L["Free"] = "自由窗体"
L["Self"] = "独立窗体"

L["Relative Position"] = "锚点位置"
L["Sets the position of the child unit in relation to the parent frame."] = "设定子框体相对于父框体的锚点位置"
L["Left Top"] = "左上"
L["Left2"] = "左"
L["Left Bottom"] = "左下" 
L["Right Top"] = "右上" 
L["Right2"] = "右"
L["Right Bottom"] = "右下"
L["Above Left"] = "上左"
L["Above2"] = "上方"
L["Above Right"] = "上右"
L["Below Left"] = "下左"
L["Below2"] = "下方"
L["Below Right"] = "下右"

L["Frame Style"] = "框体样式"
L["Adjust the style of the frame."] = "调整框体样式"
L["Border"] = "边框"
L["Adjust the border type."] = "调整边框类型"
L["Width"] = "长度"
L["Adjust the frame width."] = "调整框体长度"
L["Height"] = "高度"
L["Adjust the frame height."] = "调整框体高度"
L["Scale"] = "比例"
L["Adjust the scale of the frame."] = "调整框体比例"

L["Bar Height Modifier"] = "调节状态条高度"
L["Adjust the height of the individual bars."] = "调节各个状态条的高度"
L["Height Modifier"] = "高度调节"
L["Sets the height factor of the given object."] = "设置所选单位的高度"

L["Font Type"] = "字体"
L["Sets the override font type."] = "选择字体"
L["Font Size"] = "字体尺寸"
L["Sets the override font size."] = "设置字体大小"
L["Font Override"] = "自定义字体"
L["Enables overriding of font type/size."] = "允许重新定义字体类型和尺寸"

L["Text Customization"] = "文本定义"
L["Customizes the text on the unit frames."] = "定义单位框体的相应文本"

L["Color Name By Class"] = "名称以职业颜色显示"
L["Color the unit's name with its raid class color."] = "根据单位的职业给名字着色"

L["Tags"] = "标签"
L["Configures what text the string should display."] = "显示当前文本配置"

L["Hide in raid"] = "团队中隐藏队伍"
L["Hide the party while in a raid."] = "在团队中隐藏你的队伍"
L["Show in 5 man raid"] = "显示5人团队"
L["Show the party in raids smaller than 5."] = "当在团队中人数小于5人则显示队伍"

L["Enable Modules"] = "启用模块"
L["Enable or disable this module"] = "启用或禁用此模块"

L["Groups"] = "团队"
L["Group"] = "小组"
L["Configuration of raid subgroups."] = "团队小组配置"
L["New Group"] = "新的小组"
L["Creates a new raid subgroup."] = "创建一个新的团队小组"
L["Group Options."] = "小组选项"
L["Show Group Header"] = "显示小组名"
L["Should the group header be shown or not."] = "设置小组的名字是否显示"
L["Anchor Offset"] = "锚点位置"
L["Sets the group offset from the anchor."] = "设置小组锚点的位置"
L["Padding"] = "间距"
L["Sets the distance between group members."] = "设置小组成员间的距离"
L["Grow Direction"] = "伸展方向"
L["Controls which way the group grows."] = "控制小组窗体伸展的方向"
L["Delete Group"] = "删除小组"
L["Deletes the current raid subgroup."] = "删除当前团队小组"

L["Group Name"] = "小组名称"
L["Sets the name of group, displayed in the anchor."] = "设置小组名称，显示在锚点位置"
L["Group Filter"] = "小组过滤"
L["Sets which units the group should show. For example '1,2,3' or 'MAGE,WARLOCK'. Seperate with commas, no spaces."] = "设置小组显示单位，例如：'1,2,3'或者'法师,术士'。用英文逗号隔开，不要有空格"
L["Name List"] = "名称列表"
L["Sets which players the group should show. For example 'Kristiano,Tritonus,Giustiniano'. Seperate with commas, no spaces."] = "设置小组显示玩家姓名。例如：'张三,李四,赵五'。用英文逗号隔开，不要有空格"
L["Sort By"] = "排序"
L["Sorts the group by name, index, subgroup or class."] = "是否按照名字，索引，小组或者职业来排序"
L["Index"] = "初始"
L["Class"] = "默认"
L["Name"] = "名字"
L["Subgroup"] = "组"
L["Up"] = "上"
L["Down"] = "下"
L["Left3"] = "左"
L["Right3"] = "右"

L["Modules"] = "模块"

L["Setup Mode"] = "设置模式"
L["Off"] = "关闭"
L["Enables the visibility of all enabled unit frames."] = "开启所有有效单位框体为可见。"
L["Group change detected. Leaving frame setup mode."] = "队伍发生变更。离开设置模式。"

L["Absolute HP"] = "精确HP值"
L["Current and maximum HP in absolute values"] = "当前最大HP的精确数值"
L["Absolute Mana"] = "精确法力值"
L["Current and maximum MP in absolute values"] = "当前最大法力的精确数值"
L["Percent HP"] = "HP百分比"
L["Current HP in percent (Unknown value for people not in party/raid)"] = "目前HP百分比(当目标不在队伍和团队里为未知值)"
L["Percent MP"] = "法力百分比"
L["Current MP in percent"] = "当前法力值百分比"
L["Current XP"] = "经验值"
L["Current and total required XP"] = "当前最大经验值"
L["Difference HP"] = "生命亏减值"
L["Current HP minus maximum HP"] = "当前最大生命亏减值"
L["Difference MP"] = "法力亏减值"
L["Current MP minus maximum MP"] = "当前最大法力亏减值"
L["Percent XP"] = "经验百分比"
L["Current XP in percent"] = "当前经验百分比"
L["Rested XP"] = "奖励经验值"
L["Percent Rested XP"] = "休息奖励经验百分比"
L["Rested XP as a percentage of the current level"] = "目前休息奖励经验百分比"
L["Current Reputation"] = "声望"
L["Reputation with the currently watched faction"] = "目前阵营声望"
L["Percent Reputation"] = "声望"
L["Reputation with the currently watched faction as a percentage"] = "目前阵营声望百分比"
L["Name"] = "名字"
L["Character Name"] = "名称"
L["Class"] = "职业"
L["Character Class"] = "职业"
L["Level"] = "等级"
L["Character level"] = "等级"
L["Race"] = "种族"
L["Character Race"] = "种族"
L["Raidgroup"] = "团队队伍编号"
L["Current raid subgroup"] = "目前的队伍小组编号"
L["AFK/DND Status"] = "暂离/请勿打扰 状态"
L["Displays the AFK or DND status"] = "激活显示 暂离/请勿打扰 状态"
L["Mobtype"] = "怪物类型"
L["Elite, boss or rare"] = "精英、首领、稀有"
L["Name (Raid Colored)"] = "名字(职业着色)"
L["Raid Colored Character Name"] = "团队着色角色名字"
	
L["ABF Layout"] = "ABF样式"
L["Bar Height"]  = "状态条高度"
L["Sets the height factor of the status bar."] = "设置状态条高度。"
L["Bar Order"] = "状态条次序"
L["Sets the order of the status bar."] = "设置状态条次序。"
L["Configure the ABF layout."] = "ABF 样式配置。"
L["Left Text"] = "左侧文字"
L["Right Text"] = "右侧文字"

---------------------------------------
--------[[ HealthBar Module ]]---------
---------------------------------------

L["Healthbar"] = "生命条"
L["Healthbar options."] = "生命条选项"
L["Color By Class"] = "职业着色"
L["Colors the healthbar by class."] = "按照职业对生命条着色"
L["Color By Alignment"] = "阵营着色"
L["Colors the healthbar by unit alignment towards you."] = "按照和你对应的阵营对生命条着色"
L["Fade Healthbar"] = "渐隐效果"
L["Fades healthbar changes."] = "血条减少以渐隐变化效果显示"
L["Smooth Healthbar"] = "平滑渐隐效果"
L["Smooths healthbar changes."] = "血条减少以平滑渐隐变化效果显示"
L["Color Red at Aggro"] = "仇恨目标染红"
L["Color the healthbar Red when the unit has aggro."] = "单位获得仇恨时染红生命条"

---------------------------------------
---------[[ PowerBar Module ]]---------
---------------------------------------

L["Powerbar"] = "能量状态条"
L["Powerbar options."] = "能量状态条选项"
L["Enable Powerbar"] = "显示能量状态条"
L["Enables the powerbar."] = "显示能量状态条"
L["Fade Powerbar"] = "渐隐效果"
L["Fades powerbar changes."] = "能量减少以渐隐变化效果显示"
L["Smooth Powerbar"] = "平滑渐隐效果"
L["Smooth powerbar changes."] = "能量减少以平滑渐隐变化效果显示"

---------------------------------------
---------[[ Aura Module ]]-------------
---------------------------------------

L["Buffs"] = "增益"
L["Debuffs"] = "减益"
L["Auras"] = "光环"
L["Aura options."] = "光环选项"
L["Position"] = "位置"
L["Sets the position in which auras should be displayed in releation to the unit frame."] = "设置光环在框体位置"
L["Right"] = "右"
L["Left"] = "左"
L["Above"] = "上"
L["Below"] = "下"
L["Inside"] = "内部"
L["Hidden"] = "隐藏"
L["Rows"] = "列"
L["Rows of auras to display."] = "光环按列设置"
L["Columns"] = "行"
L["Columns of auras to display."] = "光环按行设置"
L["Buff Filter"] = "增益过滤"
L["Only show buffs that you can cast."] = "只显示你能释放的增益法术"
L["Debuff Filter"] = "减益过滤"
L["Only show debuffs that you can remove."] = "只显示你能移除的简易法术"
L["Enable Highlights"] = "显示高亮"
L["Highlights the frame in color if debuffed."] = "高亮显示减益效果"
L["Prioritize Buffs"] = "优先增益"
L["Prioritize buffs above debuffs"] = "将增益优先显示在减益前"
L["Enable Cooldown"] = "启用冷却显示" 
L["Shows a cooldown dial on auras"] = "显示光环冷却时间"
L["Enable Gloss"] = "使用高亮"
L["Shows a white glossy overlay on auras."] = "光环上白色高亮显示"

---------------------------------------
---------[[ CastBar Module ]]-------------
---------------------------------------

L["Castbar"] = "施法条"
L["Castbar options."] = "施法条选项"
L["Enable Castbar"] = "显示施法条"
L["Displays a casting bar for the unit."] = "显示施法状态条"

---------------------------------------
---------[[ Combat Text Module ]]------
---------------------------------------

L["Combat Text"] = "战斗文字"
L["Combat text options."] = "战斗文字选项"
L["Enable Combat Text"] = "显示战斗文字"
L["Displays a text overlay with combat information."] = "显示作战信息文本"

---------------------------------------
---------[[ Highlight Module ]]--------
---------------------------------------

L["Highlight"] = "高亮"
L["Highlight options."] = "高亮选项"
L["Enable Highlights"] = "显示高亮"
L["Highlights the frame when selected."] = "选择框体高亮"

---------------------------------------
---------[[ Experience Module ]]-------
---------------------------------------

L["Experience Bar"] = "经验条"
L["Experience options."] = "经验条选项"
L["Enable Experiencebar"] = "显示经验条"
L["Enables the Experiencebar."] = "显示经验状态条"
L["Show text"] = "显示文本"
L["Show text on bar"] = "在经验条上显示经验文本"
L["Show Tooltip"] = "显示说明"
L["Show tooltip when mousing over the bar"] = "当鼠标移动到状态条上时候显示"
L["Enable Reputation"] = "显示声望条"
L["The Experience bar will show reputation if a faction is set to watched in the reputation pane."] = "设置一个阵营的声望将它显示在经验条上。"

---------------------------------------
---------[[ Portrait Module ]]---------
---------------------------------------

L["Portrait"] = "头像"
L["Portrait options."] = "头像选项"
L["Enable Portrait"] = "启用头像"
L["Draws a portrait of the character."] = "头像绘制"
L["Portrait Style"] = "头像风格"
L["How to display the portrait."] = "如何显示头像"
L["3d portrait"] = "3D头像"
L["2d portrait"] = "2D头像"
L["Class icon"] = "职业图标"

---------------------------------------
---------[[ Range Check Module ]]------
---------------------------------------

L["Range Check"] = "距离侦测"
L["Range check options."] = "距离侦测选项"
L["Enable Range Check"] = "显示距离侦测"
L["Fades out of range units."] = "渐隐超出范围的单位"

---------------------------------------
---------[[ Threat Module ]]-----------
---------------------------------------

L["Enable Threat Border"] = "启用仇恨边框"
L["Enables a border around the unit frame, displaying the threat status."] = "在单位框体的边框上显示仇恨状态"
L["Enable Threat Pulse"] = "启用仇恨闪烁"
L["Enables the threat border animation."] = "显示仇恨边框动画"

---------------------------------------
---------[[ Hide Blizz Module ]]-------
---------------------------------------
L["Blizzard Frame Visibility"] = "系统框体可见"
L["Control the visibility of some Blizzard frames."] = "控制一些系统框体的可见状态。"
L["hidePlayerFrame"] = "隐藏玩家框体"
L["hidePlayerFramedesc"] = "设置系统玩家框体可见状态。"
L["hidePartyFrame"] = "隐藏队伍框架"
L["hidePartyFramedesc"] = "设置系统队伍框体可见状态。"
L["hideTargetFrame"] = "隐藏目标框体"
L["hideTargetFramedesc"] = "设置系统目标框体可见状态。"
L["hideFocusFrame"] = "隐藏焦点框体"
L["hideFocusFramedesc"] = "设置系统焦点框体可见状态。"
L["hideCastFrame"] = "隐藏施法条"
L["hideCastFramedesc"] = "设置系统施法条可见状态。"


fixModuleNames = { --add
	["Auras"] = "光环",
	["Castbar"] = "施法条",
	["Statusicon"] = "战斗图标",
	["Combattext"] = "战斗文字",
	["Combopoints"] = "连击点",
	["Fivesecond"] = "5秒回蓝",
	["HappinessIcon"] = "快乐度",
	["Healthbar"] = "血量条",
	["Hideblizz"] = "隐藏默认框体",
	["Highlight"] = "高亮",
	["IncomingHeals"] = "过量治疗",
	["Leadericon"] = "团长图标",
	["Masterlootericon"] = "拾取图标",
	["Portrait"] = "头像",
	["Powerbar"] = "能量条",
	["Pvpicon"] = "PVP图标",
	["Raidtargeticon"] = "团队标记",
	["Rangecheck"] = "检查范围",
	["Totems"] = "图腾",
	["Xprepbar"] = "经验条",
};
