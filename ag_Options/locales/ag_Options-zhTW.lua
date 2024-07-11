local L = LibStub("AceLocale-3.0"):NewLocale("ag_Options","zhTW")
if not L then return end

L["GUnit"] = "頭像增強 AG"
L["Open"] = "打開"
L["Options Frame"] = "設置面板"

L["player"]					= "玩家"
L["pet"]					= "玩家的寵物"
L["party"]					= "隊友"
L["partypet"]				= "隊友的寵物"
L["partytarget"]			= "隊友目標"
L["target"]					= "目標"
L["focus"]					= "焦點"
L["focustarget"]			= "焦點目標"
L["targettarget"]			= "目標的目標"
L["targettargettarget"]		= "目標的TOT"
L["raid"]					= "團隊"
L["raidpet"]				= "團隊寵物"
L["pettarget"]				= "寵物目標"

L["Units"] = "單位"
L["Global Options"] = "全域選項"
L["Unit Frames"] = "單位框體"
L["Misc Options"] = "細節設置"
L["Colors"] = "狀態條顏色"
L["Enabled Modules"] = "啟用模組"
L["Enabled Units"] = "已啟用單位"
L["Sets which units you want frames created for."] = "描述"

L["Health"] = "生命"
L["Sets the health color."] = "設置生命條顏色"
L["Mana"] = "法力"
L["Sets the mana color."] = "設置法力條顏色"
L["Rage"] = "怒氣"
L["Sets the rage color."] = "設置怒氣條顏色"
L["Energy"] = "能量"
L["Sets the energy color."] = "設置能量條顏色"
L["Rune"] = "符能"
L["Sets the rune color."] = "設置符能顏色"
L["Pet Focus"] = "寵物集中值"
L["Sets the pet focus color."] = "設置寵物集中值顏色"
L["Casting Bar"] = "施法條"
L["Sets the color for the casting bar progress."] = "設置施法進度條顏色"
L["Experience"] = "經驗條"
L["Sets the xp color."] = "設置經驗條顏色"
L["Rested Experience"] = "獎勵經驗"
L["Sets the rested xp color."] = "設置獎勵經驗的顏色"

L["Frames"] = "框體"
L["Change the unit frame background colour."] = "改變單位框體的背景顏色"
L["Borders"] = "邊框"
L["Change the frame border color."] = "改變框體邊框的顏色"

L["Lock Frames"] = "鎖定框體"
L["Locks the unit frames."] = "鎖定單位框體"

L["Bar Texture"] = "狀態條素材"
L["Selects the global status bar texture."] = "選擇你的狀態條素材"

L["Bar Fade Time"] = "狀態條淡出時間"
L["Sets the time it takes for a bar to fade"] = "設置狀態條的淡出時間"

L["Frame"] = "框體"
L["Fonts"] = "字體"
L["Font options."] = "字體選項"
L["Bars"] = "狀態條"
L["Bar options."] = "狀態條選項"

L["Hide in Raid"] = "團隊中隱藏隊伍"
L["Hides party frames in raid."] = "當你在團隊中,隱藏隊伍框體"
L["Show 5-man Raid as Party"] = "顯示5人團隊隊伍"
L["Handles as 5-man raid as if it was a normal party."] = "當是5人團隊的時候，當作小隊處理"
L["Group With"] = "隊伍"
L["Configures how these unit frames group."] = "如何配置隊伍框體"
L["Parent"] = "繼承表單"
L["Free"] = "自由表單"
L["Self"] = "獨立表單"

L["Relative Position"] = "錨點位置"
L["Sets the position of the child unit in relation to the parent frame."] = "設定子框體相對于父框體的錨點位置"
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

L["Frame Style"] = "框體樣式"
L["Adjust the style of the frame."] = "調整框體樣式"
L["Border"] = "邊框"
L["Adjust the border type."] = "調整邊框類型"
L["Width"] = "長度"
L["Adjust the frame width."] = "調整框體長度"
L["Height"] = "高度"
L["Adjust the frame height."] = "調整框體高度"
L["Scale"] = "比例"
L["Adjust the scale of the frame."] = "調整框體比例"

L["Bar Height Modifier"] = "調節狀態條高度"
L["Adjust the height of the individual bars."] = "調節各個狀態條的高度"
L["Height Modifier"] = "高度調節"
L["Sets the height factor of the given object."] = "設置所選單位的高度"

L["Font Type"] = "字體"
L["Sets the override font type."] = "選擇字體"
L["Font Size"] = "字體尺寸"
L["Sets the override font size."] = "設置字體大小"
L["Font Override"] = "自訂字體"
L["Enables overriding of font type/size."] = "允許重新定義字體類型和尺寸"

L["Text Customization"] = "文本定義"
L["Customizes the text on the unit frames."] = "定義單位框體的相應文本"

L["Color Name By Class"] = "名稱以職業顏色顯示"
L["Color the unit's name with its raid class color."] = "根據單位的職業給名字著色"

L["Tags"] = "標籤"
L["Configures what text the string should display."] = "顯示當前文本配置"

L["Hide in raid"] = "團隊中隱藏隊伍"
L["Hide the party while in a raid."] = "在團隊中隱藏你的隊伍"
L["Show in 5 man raid"] = "顯示5人團隊"
L["Show the party in raids smaller than 5."] = "當在團隊中人數小於5人則顯示隊伍"

L["Enable Modules"] = "啟用模組"
L["Enable or disable this module"] = "啟用或禁用此模組"

L["Groups"] = "團隊"
L["Group"] = "小組"
L["Configuration of raid subgroups."] = "團隊小組配置"
L["New Group"] = "新的小組"
L["Creates a new raid subgroup."] = "創建一個新的團隊小組"
L["Group Options."] = "小組選項"
L["Show Group Header"] = "顯示小組名"
L["Should the group header be shown or not."] = "設置小組的名字是否顯示"
L["Anchor Offset"] = "錨點位置"
L["Sets the group offset from the anchor."] = "設置小組錨點的位置"
L["Padding"] = "間距"
L["Sets the distance between group members."] = "設置小組成員間的距離"
L["Grow Direction"] = "伸展方向"
L["Controls which way the group grows."] = "控制小組表單伸展的方向"
L["Delete Group"] = "刪除小組"
L["Deletes the current raid subgroup."] = "刪除當前團隊小組"

L["Group Name"] = "小組名稱"
L["Sets the name of group, displayed in the anchor."] = "設置小組名稱，顯示在錨點位置"
L["Group Filter"] = "小組過濾"
L["Sets which units the group should show. For example '1,2,3' or 'MAGE,WARLOCK'. Seperate with commas, no spaces."] = "設置小組顯示單位，例如：'1,2,3'或者'法師,術士'。用英文逗號隔開，不要有空格"
L["Name List"] = "名稱列表"
L["Sets which players the group should show. For example 'Kristiano,Tritonus,Giustiniano'. Seperate with commas, no spaces."] = "設置小組顯示玩家姓名。例如：'張三,李四,趙五'。用英文逗號隔開，不要有空格"
L["Sort By"] = "排序"
L["Sorts the group by name, index, subgroup or class."] = "是否按照名字，索引，小組或者職業來排序"
L["Index"] = "初始"
L["Class"] = "默認"
L["Name"] = "名字"
L["Subgroup"] = "組"
L["Up"] = "上"
L["Down"] = "下"
L["Left3"] = "左"
L["Right3"] = "右"

L["Modules"] = "模組"

L["Setup Mode"] = "設置模式"
L["Off"] = "關閉"
L["Enables the visibility of all enabled unit frames."] = "開啟所有有效單位框體為可見。"
L["Group change detected. Leaving frame setup mode."] = "隊伍發生變更。離開設置模式。"

L["Absolute HP"] = "精確HP值"
L["Current and maximum HP in absolute values"] = "當前最大HP的精確數值"
L["Absolute Mana"] = "精確法力值"
L["Current and maximum MP in absolute values"] = "當前最大法力的精確數值"
L["Percent HP"] = "HP百分比"
L["Current HP in percent (Unknown value for people not in party/raid)"] = "目前HP百分比(當目標不在隊伍和團隊裡為未知值)"
L["Percent MP"] = "法力百分比"
L["Current MP in percent"] = "當前法力值百分比"
L["Current XP"] = "經驗值"
L["Current and total required XP"] = "當前最大經驗值"
L["Difference HP"] = "生命虧減值"
L["Current HP minus maximum HP"] = "當前最大生命虧減值"
L["Difference MP"] = "法力虧減值"
L["Current MP minus maximum MP"] = "當前最大法力虧減值"
L["Percent XP"] = "經驗百分比"
L["Current XP in percent"] = "當前經驗百分比"
L["Rested XP"] = "獎勵經驗值"
L["Percent Rested XP"] = "休息獎勵經驗百分比"
L["Rested XP as a percentage of the current level"] = "目前休息獎勵經驗百分比"
L["Current Reputation"] = "聲望"
L["Reputation with the currently watched faction"] = "目前陣營聲望"
L["Percent Reputation"] = "聲望"
L["Reputation with the currently watched faction as a percentage"] = "目前陣營聲望百分比"
L["Name"] = "名字"
L["Character Name"] = "名稱"
L["Class"] = "職業"
L["Character Class"] = "職業"
L["Level"] = "等級"
L["Character level"] = "等級"
L["Race"] = "種族"
L["Character Race"] = "種族"
L["Raidgroup"] = "團隊隊伍編號"
L["Current raid subgroup"] = "目前的隊伍小組編號"
L["AFK/DND Status"] = "暫離/請勿打擾 狀態"
L["Displays the AFK or DND status"] = "啟動顯示 暫離/請勿打擾 狀態"
L["Mobtype"] = "怪物類型"
L["Elite, boss or rare"] = "精英、首領、稀有"
L["Name (Raid Colored)"] = "名字(職業著色)"
L["Raid Colored Character Name"] = "團隊著色角色名字"
	
L["ABF Layout"] = "ABF樣式"
L["Bar Height"]  = "狀態條高度"
L["Sets the height factor of the status bar."] = "設置狀態條高度。"
L["Bar Order"] = "狀態條次序"
L["Sets the order of the status bar."] = "設置狀態條次序。"
L["Configure the ABF layout."] = "ABF 樣式配置。"
L["Left Text"] = "左側文字"
L["Right Text"] = "右側文字"

---------------------------------------
--------[[ HealthBar Module ]]---------
---------------------------------------

L["Healthbar"] = "生命條"
L["Healthbar options."] = "生命條選項"
L["Color By Class"] = "職業著色"
L["Colors the healthbar by class."] = "按照職業對生命條著色"
L["Color By Alignment"] = "陣營著色"
L["Colors the healthbar by unit alignment towards you."] = "按照和你對應的陣營對生命條著色"
L["Fade Healthbar"] = "漸隱效果"
L["Fades healthbar changes."] = "血條減少以漸隱變化效果顯示"
L["Smooth Healthbar"] = "平滑漸隱效果"
L["Smooths healthbar changes."] = "血條減少以平滑漸隱變化效果顯示"
L["Color Red at Aggro"] = "仇恨目標染紅"
L["Color the healthbar Red when the unit has aggro."] = "單位獲得仇恨時染紅生命條"

---------------------------------------
---------[[ PowerBar Module ]]---------
---------------------------------------

L["Powerbar"] = "能量狀態條"
L["Powerbar options."] = "能量狀態條選項"
L["Enable Powerbar"] = "顯示能量狀態條"
L["Enables the powerbar."] = "顯示能量狀態條"
L["Fade Powerbar"] = "漸隱效果"
L["Fades powerbar changes."] = "能量減少以漸隱變化效果顯示"
L["Smooth Powerbar"] = "平滑漸隱效果"
L["Smooth powerbar changes."] = "能量減少以平滑漸隱變化效果顯示"

---------------------------------------
---------[[ Aura Module ]]-------------
---------------------------------------

L["Buffs"] = "增益"
L["Debuffs"] = "減益"
L["Auras"] = "光環"
L["Aura options."] = "光環選項"
L["Position"] = "位置"
L["Sets the position in which auras should be displayed in releation to the unit frame."] = "設置光環在框體位置"
L["Right"] = "右"
L["Left"] = "左"
L["Above"] = "上"
L["Below"] = "下"
L["Inside"] = "內部"
L["Hidden"] = "隱藏"
L["Rows"] = "列"
L["Rows of auras to display."] = "光環按列設置"
L["Columns"] = "行"
L["Columns of auras to display."] = "光環按行設置"
L["Buff Filter"] = "增益過濾"
L["Only show buffs that you can cast."] = "只顯示你能釋放的增益法術"
L["Debuff Filter"] = "減益過濾"
L["Only show debuffs that you can remove."] = "只顯示你能移除的簡易法術"
L["Enable Highlights"] = "顯示高亮"
L["Highlights the frame in color if debuffed."] = "高亮顯示減益效果"
L["Prioritize Buffs"] = "優先增益"
L["Prioritize buffs above debuffs"] = "將增益優先顯示在減益前"
L["Enable Cooldown"] = "啟用冷卻顯示" 
L["Shows a cooldown dial on auras"] = "顯示光環冷卻時間"
L["Enable Gloss"] = "使用高亮"
L["Shows a white glossy overlay on auras."] = "光環上白色高亮顯示"

---------------------------------------
---------[[ CastBar Module ]]-------------
---------------------------------------

L["Castbar"] = "施法條"
L["Castbar options."] = "施法條選項"
L["Enable Castbar"] = "顯示施法條"
L["Displays a casting bar for the unit."] = "顯示施法狀態條"

---------------------------------------
---------[[ Combat Text Module ]]------
---------------------------------------

L["Combat Text"] = "戰鬥文字"
L["Combat text options."] = "戰鬥文字選項"
L["Enable Combat Text"] = "顯示戰鬥文字"
L["Displays a text overlay with combat information."] = "顯示作戰資訊文本"

---------------------------------------
---------[[ Highlight Module ]]--------
---------------------------------------

L["Highlight"] = "高亮"
L["Highlight options."] = "高亮選項"
L["Enable Highlights"] = "顯示高亮"
L["Highlights the frame when selected."] = "選擇框體高亮"

---------------------------------------
---------[[ Experience Module ]]-------
---------------------------------------

L["Experience Bar"] = "經驗條"
L["Experience options."] = "經驗條選項"
L["Enable Experiencebar"] = "顯示經驗條"
L["Enables the Experiencebar."] = "顯示經驗狀態條"
L["Show text"] = "顯示文本"
L["Show text on bar"] = "在經驗條上顯示經驗文本"
L["Show Tooltip"] = "顯示說明"
L["Show tooltip when mousing over the bar"] = "當滑鼠移動到狀態條上時候顯示"
L["Enable Reputation"] = "顯示聲望條"
L["The Experience bar will show reputation if a faction is set to watched in the reputation pane."] = "設置一個陣營的聲望將它顯示在經驗條上。"

---------------------------------------
---------[[ Portrait Module ]]---------
---------------------------------------

L["Portrait"] = "頭像"
L["Portrait options."] = "頭像選項"
L["Enable Portrait"] = "啟用頭像"
L["Draws a portrait of the character."] = "頭像繪製"
L["Portrait Style"] = "頭像風格"
L["How to display the portrait."] = "如何顯示頭像"
L["3d portrait"] = "3D頭像"
L["2d portrait"] = "2D頭像"
L["Class icon"] = "職業圖示"

---------------------------------------
---------[[ Range Check Module ]]------
---------------------------------------

L["Range Check"] = "距離偵測"
L["Range check options."] = "距離偵測選項"
L["Enable Range Check"] = "顯示距離偵測"
L["Fades out of range units."] = "漸隱超出範圍的單位"

---------------------------------------
---------[[ Threat Module ]]-----------
---------------------------------------

L["Enable Threat Border"] = "啟用仇恨邊框"
L["Enables a border around the unit frame, displaying the threat status."] = "在單位框體的邊框上顯示仇恨狀態"
L["Enable Threat Pulse"] = "啟用仇恨閃爍"
L["Enables the threat border animation."] = "顯示仇恨邊框動畫"

---------------------------------------
---------[[ Hide Blizz Module ]]-------
---------------------------------------
L["Blizzard Frame Visibility"] = "系統框體可見"
L["Control the visibility of some Blizzard frames."] = "控制一些系統框體的可見狀態。"
L["hidePlayerFrame"] = "隱藏玩家框體"
L["hidePlayerFramedesc"] = "設置系統玩家框體可見狀態。"
L["hidePartyFrame"] = "隱藏隊伍框架"
L["hidePartyFramedesc"] = "設置系統隊伍框體可見狀態。"
L["hideTargetFrame"] = "隱藏目標框體"
L["hideTargetFramedesc"] = "設置系統目標框體可見狀態。"
L["hideFocusFrame"] = "隱藏焦點框體"
L["hideFocusFramedesc"] = "設置系統焦點框體可見狀態。"
L["hideCastFrame"] = "隱藏施法條"
L["hideCastFramedesc"] = "設置系統施法條可見狀態。"


fixModuleNames = { --add
	["Auras"] = "光環",
	["Castbar"] = "施法條",
	["Statusicon"] = "戰鬥圖示",
	["Combattext"] = "戰鬥文字",
	["Combopoints"] = "連擊點數",
	["Fivesecond"] = "5秒回魔",
	["HappinessIcon"] = "快樂度",
	["Healthbar"] = "血量條",
	["Hideblizz"] = "隱藏默認框體",
	["Highlight"] = "高亮",
	["IncomingHeals"] = "過量治療",
	["Leadericon"] = "團長圖示",
	["Masterlootericon"] = "拾取圖示",
	["Portrait"] = "頭像",
	["Powerbar"] = "能量條",
	["Pvpicon"] = "PVP圖示",
	["Raidtargeticon"] = "團隊標記",
	["Rangecheck"] = "檢查範圍",
	["Totems"] = "圖騰",
	["Xprepbar"] = "經驗條",
};
