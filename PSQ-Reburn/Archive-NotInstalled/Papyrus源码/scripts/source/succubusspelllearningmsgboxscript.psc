Scriptname SuccubusSpellLearningMSGBoxScript Extends ActiveMagicEffect
PlayerSuccubusQuestScript Property PSQ Auto
Sound Property UISpellLearned Auto
Function LearnIfAble(Spell LearningSpell,Int RequiredRank, Float RequiredEnergy, Float RequiredSkillLevel, String MagicSchool)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Int Result = PSQAppearance.LearnCheck34(PSQ, LearningSpell, RequiredRank, RequiredEnergy, RequiredSkillLevel, MagicSchool)
    If Result == 1
      Debug.Notification("$PSQ_YouHaveThatSpell")
    ElseIf Result == 2
      Debug.Notification("魅魔等级需要达到：" + RequiredRank)
    ElseIf Result == 3
      Debug.Notification(Self.GetMagicSchoolDisplayName(MagicSchool) + "等级需要达到：" + (RequiredSkillLevel as Int))
    ElseIf Result == 4
      Debug.Notification("需要魅魔能量：" + (RequiredEnergy as Int))
    ElseIf Result == 5 && PSQ.PlayerRef.AddSpell(LearningSpell)
      UISpellLearned.Play(PSQ.PlayerRef)
      PSQ.Satiety(-RequiredEnergy)
      PSQ.SatietyNotification(-RequiredEnergy, True)
    EndIf
    Return
  EndIf
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
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.SchoolName34(MagicSchool)
  EndIf
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
