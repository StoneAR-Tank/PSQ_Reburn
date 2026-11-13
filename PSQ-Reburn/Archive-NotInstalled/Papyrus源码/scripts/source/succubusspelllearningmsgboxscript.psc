Scriptname SuccubusSpellLearningMSGBoxScript Extends ActivemagicEffect

PlayerSuccubusQuestScript Property PSQ Auto

Sound Property UISpellLearned Auto

String Property StringSuccubusRank Auto
String Property StringIsRequired Auto
String Property StringLevel Auto
String Property StringEnergy Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akCaster == PSQ.PlayerRef
		PSQ.Satiety(0.0)
		MainMenu()
	EndIf
EndEvent

Function MainMenu()
	If Game.GetFormFromFile(0xE00, "UIExtensions.esp") != None
		UIListMenu ListMenu = UIExtensions.GetMenu("UIListMenu", True) as UIListMenu
    If ListMenu == None
      Return
    EndIf
		
		Spell RoseStorm = PSQ.GetRoseStormSpell()
		String[] sOptions
		If RoseStorm
			sOptions = New String[46]
			sOptions[45] = RoseStorm.GetName() + ";;40;;43;;2;;0"
		Else
			sOptions = New String[45]
		EndIf
		sOptions[0]  = "毁灭系"			+ ";;" + -1 + ";;" +  1 + ";;" + 0 + ";;1"
		sOptions[1]  = "幻术系"				+ ";;" + -1 + ";;" +  2 + ";;" + 0 + ";;1"
		sOptions[2]  = "变化系"				+ ";;" + -1 + ";;" +  3 + ";;" + 0 + ";;1"
		sOptions[3]  = "恢复系"				+ ";;" + -1 + ";;" +  4 + ";;" + 0 + ";;1"
		
		sOptions[4]  = "学徒级"				+ ";;" +  1 + ";;" + 10 + ";;" + 0 + ";;1"
		sOptions[5]  = PSQ.SuccuFirebolt.GetName()			+ ";;" + 10 + ";;" + 11 + ";;" + 0 + ";;0"
		sOptions[6]  = PSQ.SuccuIceSpike.GetName()			+ ";;" + 10 + ";;" + 12 + ";;" + 1 + ";;0"
		sOptions[7]  = PSQ.SuccuLightningBolt.GetName()	+ ";;" + 10 + ";;" + 13 + ";;" + 2 + ";;0"
		
		sOptions[8]  = "精通级"					+ ";;" +  1 + ";;" + 20 + ";;" + 0 + ";;1"
		sOptions[9]  = PSQ.SuccuFireball.GetName()			+ ";;" + 20 + ";;" + 21 + ";;" + 0 + ";;0"
		sOptions[10] = PSQ.SuccuIceStorm.GetName()		+ ";;" + 20 + ";;" + 22 + ";;" + 1 + ";;0"
		sOptions[11] = PSQ.SuccuChainLightning.GetName()	+ ";;" + 20 + ";;" + 23 + ";;" + 2 + ";;0"
		
		sOptions[12] = "专家级"					+ ";;" +  1 + ";;" + 30 + ";;" + 0 + ";;1"
		sOptions[13] = PSQ.SuccuIncinerate.GetName()		+ ";;" + 30 + ";;" + 31 + ";;" + 0 + ";;0"
		sOptions[14] = PSQ.SuccuIcySpear.GetName()		+ ";;" + 30 + ";;" + 32 + ";;" + 1 + ";;0"
		sOptions[15] = PSQ.SuccuThunderbolt.GetName()		+ ";;" + 30 + ";;" + 33 + ";;" + 2 + ";;0"
		
		sOptions[16] = "大师级"					+ ";;" +  1 + ";;" + 40 + ";;" + 0 + ";;1"
		sOptions[17] = PSQ.SuccuFireStorm.GetName()		+ ";;" + 40 + ";;" + 41 + ";;" + 0 + ";;0"
		sOptions[18] = PSQ.SuccuBlizzard.GetName()			+ ";;" + 40 + ";;" + 42 + ";;" + 1 + ";;0"
		
		sOptions[19] = "单体法术"					+ ";;" +  2 + ";;" + 50 + ";;" + 0 + ";;1"
		sOptions[20] = "魅魔·勇气术"			+ ";;" + 50 + ";;" + 51 + ";;" + 0 + ";;0"
		sOptions[21] = "魅魔·平静术"				+ ";;" + 50 + ";;" + 52 + ";;" + 1 + ";;0"
		sOptions[22] = "魅魔·恐惧术"				+ ";;" + 50 + ";;" + 53 + ";;" + 2 + ";;0"
		sOptions[23] = "魅魔·狂怒术"				+ ";;" + 50 + ";;" + 54 + ";;" + 3 + ";;0"
		
		sOptions[24] = "范围法术"					+ ";;" +  2 + ";;" + 60 + ";;" + 0 + ";;1"
		sOptions[25] = "魅魔·激励术"			+ ";;" + 60 + ";;" + 61 + ";;" + 0 + ";;0"
		sOptions[26] = "魅魔·安抚术"			+ ";;" + 60 + ";;" + 62 + ";;" + 1 + ";;0"
		sOptions[27] = "魅魔·驱散术"				+ ";;" + 60 + ";;" + 63 + ";;" + 2 + ";;0"
		sOptions[28] = "魅魔·暴怒术"			+ ";;" + 60 + ";;" + 64 + ";;" + 3 + ";;0"
		
		sOptions[29] = "群体法术"					+ ";;" +  2 + ";;" + 70 + ";;" + 0 + ";;1"
		sOptions[30] = "魅魔·战斗号召"		+ ";;" + 70 + ";;" + 71 + ";;" + 0 + ";;0"
		sOptions[31] = "魅魔·和谐术"			+ ";;" + 70 + ";;" + 72 + ";;" + 1 + ";;0"
		sOptions[32] = "魅魔·歇斯底里"			+ ";;" + 70 + ";;" + 73 + ";;" + 2 + ";;0"
		sOptions[33] = "魅魔·暴乱术"			+ ";;" + 70 + ";;" + 74 + ";;" + 3 + ";;0"
		
		sOptions[34] = "魅魔·橡木甲"			+ ";;" +  3 + ";;" + 81 + ";;" + 0 + ";;0"
		sOptions[35] = "魅魔·石甲术"		+ ";;" +  3 + ";;" + 82 + ";;" + 1 + ";;0"
		sOptions[36] = "魅魔·铁甲术"		+ ";;" +  3 + ";;" + 83 + ";;" + 2 + ";;0"
		sOptions[37] = "魅魔·乌木甲"		+ ";;" +  3 + ";;" + 84 + ";;" + 3 + ";;0"
		sOptions[38] = "魅魔·龙皮术"		+ ";;" +  3 + ";;" + 85 + ";;" + 4 + ";;0"
		sOptions[39] = "魅魔·麻痹术"			+ ";;" +  3 + ";;" + 86 + ";;" + 5 + ";;0"
		
		sOptions[40] = "魅魔·快速治疗"		+ ";;" +  4 + ";;" + 91 + ";;" + 0 + ";;0"
		sOptions[41] = "魅魔·治愈伤口"		+ ";;" +  4 + ";;" + 92 + ";;" + 1 + ";;0"
		sOptions[42] = "魅魔·治疗他人"		+ ";;" +  4 + ";;" + 93 + ";;" + 2 + ";;0"
		sOptions[43] = "魅魔·大治疗术"	+ ";;" +  4 + ";;" + 94 + ";;" + 3 + ";;0"
		
		sOptions[44] = "取消"					+ ";;" + -1 + ";;" +  5 + ";;" + 0 + ";;0"
		
		ListMenu.SetPropertyStringA("appendEntries", sOptions)
		ListMenu.OpenMenu(None, None)
		
		Int sButton = Listmenu.GetResultInt()
		If sButton == 11
			LearnIfAble(PSQ.SuccuFirebolt, 2, 1000, 15, "Destruction")
		ElseIf sButton == 12
			LearnIfAble(PSQ.SuccuIceSpike, 2, 1000, 15, "Destruction")
		ElseIf sButton == 13
			LearnIfAble(PSQ.SuccuLightningBolt, 2, 1000, 15, "Destruction")
		ElseIf sButton == 21
			LearnIfAble(PSQ.SuccuFireball, 4, 2000, 40, "Destruction")
		ElseIf sButton == 22
			LearnIfAble(PSQ.SuccuIceStorm, 4, 2000, 40, "Destruction")
		ElseIf sButton == 23
			LearnIfAble(PSQ.SuccuChainLightning, 4, 2000, 40, "Destruction")
		ElseIf sButton == 31
			LearnIfAble(PSQ.SuccuIncinerate, 5, 3000, 65, "Destruction")
		ElseIf sButton == 32
			LearnIfAble(PSQ.SuccuIcySpear, 5, 3000, 65, "Destruction")
		ElseIf sButton == 33
			LearnIfAble(PSQ.SuccuThunderbolt, 5, 3000, 65, "Destruction")
		ElseIf sButton == 41
			LearnIfAble(PSQ.SuccuFireStorm, 6, 5000, 90, "Destruction")
		ElseIf sButton == 42
			LearnIfAble(PSQ.SuccuBlizzard, 6, 5000, 90, "Destruction")
		ElseIf sButton == 43 && RoseStorm
			LearnIfAble(RoseStorm, 6, 5000, 90, "Destruction")
		ElseIf sButton == 51
			LearnIfAble(PSQ.SuccuCourage, 1, 500, 0, "Illusion")
		ElseIf sButton == 52
			LearnIfAble(PSQ.SuccuCalm, 2, 1000, 15, "Illusion")
		ElseIf sButton == 53
			LearnIfAble(PSQ.SuccuFear, 2, 1000, 15, "Illusion")
		ElseIf sButton == 54
			LearnIfAble(PSQ.SuccuFury, 1, 500, 0, "Illusion")
		ElseIf sButton == 61
			LearnIfAble(PSQ.SuccuRally, 3, 1500, 30, "Illusion")
		ElseIf sButton == 62
			LearnIfAble(PSQ.SuccuPacify, 4, 2000, 45, "Illusion")
		ElseIf sButton == 63
			LearnIfAble(PSQ.SuccuRout, 4, 2000, 30, "Illusion")
		ElseIf sButton == 64
			LearnIfAble(PSQ.SuccuFrenzy, 3, 1500, 45, "Illusion")
		ElseIf sButton == 71
			LearnIfAble(PSQ.SuccuCallToArms, 6, 5000, 90, "Illusion")
		ElseIf sButton == 72
			LearnIfAble(PSQ.SuccuHarmony, 6, 5000, 90, "Illusion")
		ElseIf sButton == 73
			LearnIfAble(PSQ.SuccuHysteria, 6, 5000, 90, "Illusion")
		ElseIf sButton == 74
			LearnIfAble(PSQ.SuccuMayhem, 6, 5000, 90, "Illusion")
		ElseIf sButton == 81
			LearnIfAble(PSQ.SuccuOakflesh,1 ,500, 0, "Alteration")
		ElseIf sButton == 82
			LearnIfAble(PSQ.SuccuStoneflesh, 3, 1500, 30, "Alteration")
		ElseIf sButton == 83
			LearnIfAble(PSQ.SuccuIronflesh, 4, 2000, 45, "Alteration")
		ElseIf sButton == 84
			LearnIfAble(PSQ.SuccuEbonyflesh, 5, 3000, 65, "Alteration")
		ElseIf sButton == 85
			LearnIfAble(PSQ.SuccuDragonhide, 6, 5000, 90, "Alteration")
		ElseIf sButton == 86
			LearnIfAble(PSQ.SuccuParalyze, 5, 3000, 65, "Alteration")
		ElseIf sButton == 91
			LearnIfAble(PSQ.SuccuFastHealing, 2, 1000, 15, "Restoration")
		ElseIf sButton == 92
			LearnIfAble(PSQ.SuccuCloseWounds, 4, 2000, 40, "Restoration")
		ElseIf sButton == 93
			LearnIfAble(PSQ.SuccuHealOther,4 ,2000, 40, "Restoration")
		ElseIf sButton == 94
			LearnIfAble(PSQ.SuccuGrandHealing, 5, 3000, 65, "Restoration")
		EndIf
	EndIf
EndFunction

Function LearnIfAble(Spell LearningSpell,Int RequiredRank, Float RequiredEnergy, Float RequiredSkillLevel, String MagicSchool)
	If !PSQ.PlayerRef.HasSpell(LearningSpell)
		If PSQ.SuccubusRank.GetValueInt() >= RequiredRank
			If PSQ.PlayerRef.GetBaseAV(MagicSchool) >= RequiredSkillLevel
				If PSQ.SuccubusEnergy.GetValue() >= RequiredEnergy
					If !PSQ.PlayerRef.AddSpell(LearningSpell)
						Return
					EndIf
					Int LearnSound = UISpellLearned.Play(PSQ.PlayerRef)
					PSQ.Satiety(-RequiredEnergy)
					PSQ.SatietyNotification(-RequiredEnergy, True)
				Else
					Debug.Notification("需要魅魔能量：" + RequiredEnergy as Int)
				EndIf
			Else
				Debug.Notification(Self.GetMagicSchoolDisplayName(MagicSchool) + "等级需要达到：" + RequiredSkillLevel as Int)
			EndIf
		Else
			Debug.Notification("魅魔等级需要达到：" + RequiredRank)
		EndIf
	Else
		Debug.Notification("$PSQ_YouHaveThatSpell")
	EndIf
EndFunction

String Function GetMagicSchoolDisplayName(String MagicSchool)
  If MagicSchool == "Destruction"
    Return "毁灭系"
  ElseIf MagicSchool == "Illusion"
    Return "幻术系"
  ElseIf MagicSchool == "Alteration"
    Return "变化系"
  ElseIf MagicSchool == "Restoration"
    Return "恢复系"
  EndIf
  Return MagicSchool
EndFunction
