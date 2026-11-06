ScriptName playersuccubusmenu Extends SKI_ConfigBase

;-- Variables ---------------------------------------
Int BodySelectionOption = -1
Int BodyChangeMenuPage = 0
Int BodyChangeMenuOffset = 0
Int BodyChangeMenuCount = 0
Int DigestionModeOption = -1
Bool DragonSoulExchangeBusy = False
Int DragonSoulExchangeMode = 2
Int DragonSoulModeOption = -1
Int EyeMaterialMenuPage = 0
Bool GrowthRacialListOpen = False
Int MCMRegistrationAttempts = 0
Bool MCMRegistrationConfirmed = False
Bool MCMReloadPending = False
Int SatiationModeOption = -1
Actor SuccubusNPC
Bool TestToolsOpen = False
Int ThrallSkillDetailSlot = -1
Int TransformBuffModeOption = -1

;-- Properties --------------------------------------
playersuccubusquestscript Property PSQ Auto
GlobalVariable Property PlayerIsSuccubus Auto
succubusenergybarupdate Property SEBU Auto
psqsoulgemincubatequestscript Property SGI Auto
GlobalVariable Property SuccubusEXP Auto
GlobalVariable Property SuccubusEnergy Auto
GlobalVariable Property SuccubusRank Auto

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Function OnVersionUpdate(Int NewVersion)
  Self.OnConfigInit()
EndFunction

Int Function GetVersion()
  Return 151
EndFunction

Function OnConfigInit()
  ; Retire saved fertility-display subscriptions and rebuild the page list.
  Self.UnregisterForModEvent("PSQ_FertilityDisplayChanged")
  Pages = new String[12]
  Pages[0] = "$PSQ_GrowthPage"
  Pages[1] = "$PSQ_Page1"
  Pages[2] = "$PSQ_Page2"
  Pages[3] = "$PSQ_Page3"
  Pages[4] = "$PSQ_Page5"
  Pages[5] = "$PSQ_Page6"
  Pages[6] = "$PSQ_Page8"
  Pages[7] = "$PSQ_Page9"
  Pages[8] = "$PSQ_ThrallPage"
  Pages[9] = "$PSQ_Page4"
  Pages[10] = "$PSQ_CompatibilityPage"
  Pages[11] = "$PSQ_Page10"
EndFunction

Function OnConfigOpen()
  TestToolsOpen = False
  GrowthRacialListOpen = False
  ; Keep resolved appearance resources warm when only viewing MCM pages.
  ; Use CompatibilityRefresh after changing external resource catalogs.
EndFunction

Function OnPageReset(String Page)
  ; An old save can still request the removed page once while MCM rebuilds.
  If Page == "$PSQ_Page7"
    Page = "$PSQ_Page1"
  EndIf
  DigestionModeOption = -1
  If PSQ.UninstallPrepared || PSQ.UninstallCleanupBusy
    Self.AddHeaderOption("$PSQ_UninstallHeader", 0)
    If PSQ.UninstallPrepared
      Self.AddTextOption("$PSQ_UninstallStatus", "$PSQ_UninstallReady", 1)
      Self.AddTextOptionST("UninstallInstructions", "$PSQ_UninstallInstructions", "$PSQ_Execute", 0)
    Else
      Self.AddTextOption("$PSQ_UninstallStatus", "$PSQ_UninstallBusy", 1)
    EndIf
    Return 
  EndIf
  If Page != "$PSQ_Page10"
    TestToolsOpen = False
  ElseIf TestToolsOpen
    Self.DrawTestTools()
    Return 
  EndIf
  If Page == "$PSQ_ThrallPage"
    GrowthRacialListOpen = False
    Self.DrawSuccubusThrallPage()
    Return 
  EndIf
  TransformBuffModeOption = -1
  If Page != "$PSQ_GrowthPage"
    GrowthRacialListOpen = False
  EndIf
  If Page == "$PSQ_GrowthPage"
    If GrowthRacialListOpen
      Self.DrawRacialTraitCollection()
    Else
      Self.DrawGrowthOverview()
    EndIf
    Return 
  EndIf
  If Page == "$PSQ_CompatibilityPage"
    Self.DrawCompatibilityPage()
    Return 
  EndIf
  If PSQ.SexLab.Config.TargetRef != None
    SuccubusNPC = PSQ.SexLab.Config.TargetRef
  EndIf
  If Page == "$PSQ_Page1"
    Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
    Self.AddHeaderOption("$PSQ_DrainSettings", 0)
    Self.AddToggleOptionST("EnableDrain", "$PSQ_EnableDrain", PSQ.EnableDrain, 0)
    Self.AddMenuOptionST("SkillDrainMode", "$PSQ_SkillDrainMode", Self.GetSkillDrainModeName(PSQ.SkillDrainMode), 0)
    Self.AddMenuOptionST("AttributeDrainMode", "$PSQ_AttributeDrainMode", Self.GetAttributeDrainModeName(), 0)
    Self.AddMenuOptionST("RacialTraitDrainMode", "$PSQ_RacialTraitDrainMode", Self.GetRacialTraitDrainModeName(), 0)
    Self.AddToggleOptionST("AllowDrainFromFemale", "$PSQ_AllowDrainFromFemale", PSQ.AllowDrainFromFemale, 0)
    Self.AddToggleOptionST("AllowDrainFromBeast", "$PSQ_AllowDrainFromBeast", PSQ.AllowDrainFromBeast, 0)
    Self.AddToggleOptionST("AllowDrainFromUndead", "$PSQ_AllowDrainFromUndead", PSQ.AllowDrainFromUndead, 0)
    Self.AddToggleOptionST("ExtractSemenPotion", "$PSQ_ExtractSemenPotion", PSQ.ExtractSemenPotion, 0)
    Self.AddToggleOptionST("AutoExtractSemenPotion", "$PSQ_AutoExtractSemenPotion", PSQ.AutoExtractSemenPotion, 0)
    Self.AddSliderOptionST("AutoExtractSemenPotionThreshold", "$PSQ_AutoExtractSemenPotionThreshold", PSQ.AutoExtractSemenPotionThreshold, "{0}%", 0)
    Self.AddToggleOptionST("FastMode", "$PSQ_FastMode", PSQ.FastMode, 0)
    Self.AddSliderOptionST("FastModeTime", "$PSQ_FastModeTime", PSQ.FastModeTime, "{0}", 0)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_NPCEnergySettings", 0)
    Self.AddSliderOptionST("CalcMaxEnergyHealth", "$PSQ_CalcMaxEnergyHealth", PSQ.CalcMaxEnergyHealth, "{1}", 0)
    Self.AddToggleOptionST("AdjustMinEnergyOfHuman", "$PSQ_AdjustMinEnergyOfHuman", PSQ.AdjustMinEnergyOfHuman, 0)
    Self.AddSliderOptionST("MinEnergyOfHuman", "$PSQ_MinEnergyOfHuman", PSQ.MinEnergyOfHuman, "{0}", 0)
    Self.AddSliderOptionST("LoversRestoreMult", "$PSQ_LoversRestoreMult", PSQ.LoversRestoreMult, "{1}", 0)
    Self.SetCursorPosition(3)
    Self.AddToggleOptionST("AllowKill", "$PSQ_AllowKill", PSQ.AllowKill, 0)
    Self.AddMenuOptionST("ConditionToKill", "$PSQ_DeathCondition", Self.GetConditionalString(PSQ.ConditionToKill), 0)
    Self.AddToggleOptionST("EnableSoulTrap", "$PSQ_EnableSoulTrap", PSQ.EnableSoulTrap, 0)
    Self.AddMenuOptionST("ConditionToSoulTrap", "$PSQ_SoulTrapCondition", Self.GetConditionalString(PSQ.ConditionToSoulTrap), 0)
    Self.AddToggleOptionST("EnableCaptive", "$PSQ_EnableCaptive", PSQ.EnableCaptive, 0)
    Self.AddToggleOptionST("UseArousalAtDrain", "$PSQ_UseArousalAtDrain", PSQ.UseArousalAtDrain, 0)
    Self.AddSliderOptionST("DrainValueMultipliers", "$PSQ_DrainValueMultipliers", PSQ.DrainValueMultipliers, "{2}", 0)
    Self.AddSliderOptionST("EXPGainedMultipliers", "$PSQ_EXPGainedMultipliers", PSQ.EXPGainedMultipliers, "{2}", 0)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_FeedSettings", 0)
    Self.AddToggleOptionST("AllowSneakFeed", "$PSQ_AllowSneakFeed", PSQ.AllowSneakFeed.GetValueInt() as Bool, 0)
    Self.AddToggleOptionST("AllowSleepFeed", "$PSQ_AllowSleepFeed", PSQ.AllowSleepFeed.GetValueInt() as Bool, 0)
    Self.AddToggleOptionST("AllowForceFeed", "$PSQ_AllowForceFeed", PSQ.AllowForceFeed.GetValueInt() as Bool, 0)
    Self.AddToggleOptionST("AllowTeamMateFeed", "$PSQ_AllowTeamMateFeed", PSQ.AllowTeamMateFeed.GetValueInt() as Bool, 0)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_InternalReserveHeader", 0)
    Self.AddToggleOptionST("EnableCumInflation", "$PSQ_EnableCumInflation", PSQ.EnableCumInflation, 0)
    Self.AddToggleOptionST("AllowCumInflationAnal", "$PSQ_AllowCumInflationAnal", PSQ.CumInflationAnal, 0)
    Self.AddToggleOptionST("AllowCumInflationOral", "$PSQ_AllowCumInflationOral", PSQ.CumInflationOral, 0)
    DigestionModeOption = Self.AddMenuOption("$PSQ_DigestionMode", Self.GetDigestionModeName(PSQ.GetDigestionMode()), 0)
    Self.AddKeyMapOptionST("HotkeyDigestion", "$PSQ_HotkeyDigestion", PSQ.HotkeyDigestion, 0)
    Self.AddSliderOptionST("CumInflationIncrement", "$PSQ_CumInflationIncrement", PSQ.CumInflationIncrement, "{0}", 0)
  EndIf
  If Page == "$PSQ_Page2"
    Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
    Int SatiationFlags = (PSQ.GetSatiationEffectMode() != 1) as Int
    Self.AddHeaderOption("$PSQ_SatiationSettings", 0)
    SatiationModeOption = Self.AddMenuOption("$PSQ_SatiationMode", Self.GetSatiationModeName(PSQ.GetSatiationEffectMode()), 0)
    Self.AddToggleOptionST("EnableSatiationNotification", "$PSQ_EnableNotification", PSQ.EnableSatiationNotification, 0)
    Self.AddSliderOptionST("EnergyConsumptionPerMax", "$PSQ_ConsumptionRate", PSQ.EnergyConsumptionPerMax, "{0} %", 0)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_SatiationEffectSettings", 0)
    Self.AddSliderOptionST("HealthBuffInc", "$PSQ_HealthBuffInc", (PSQ.HealthBuffInc - PSQ.HealthBuffDec) * 100.0, "{0} %", SatiationFlags)
    Self.AddSliderOptionST("HealthBuffDec", "$PSQ_HealthBuffDec", -PSQ.HealthBuffDec * 100.0, "{0} %", SatiationFlags)
    Self.AddSliderOptionST("MagickaBuffInc", "$PSQ_MagickaBuffInc", (PSQ.MagickaBuffInc - PSQ.MagickaBuffDec) * 100.0, "{0} %", SatiationFlags)
    Self.AddSliderOptionST("MagickaBuffDec", "$PSQ_MagickaBuffDec", -PSQ.MagickaBuffDec * 100.0, "{0} %", SatiationFlags)
    Self.AddSliderOptionST("StaminaBuffInc", "$PSQ_StaminaBuffInc", (PSQ.StaminaBuffInc - PSQ.StaminaBuffDec) * 100.0, "{0} %", SatiationFlags)
    Self.AddSliderOptionST("StaminaBuffDec", "$PSQ_StaminaBuffDec", -PSQ.StaminaBuffDec * 100.0, "{0} %", SatiationFlags)
    Self.AddSliderOptionST("CarryBuffInc", "$PSQ_CarryBuffInc", (PSQ.CarryBuffInc - PSQ.CarryBuffDec) * 100.0, "{0} %", SatiationFlags)
    Self.AddSliderOptionST("CarryBuffDec", "$PSQ_CarryBuffDec", -PSQ.CarryBuffDec * 100.0, "{0} %", SatiationFlags)
    Self.AddSliderOptionST("SpeedBuffInc", "$PSQ_SpeedBuffInc", PSQ.SpeedBuffInc - PSQ.SpeedBuffDec, "{0} %", SatiationFlags)
    Self.AddSliderOptionST("SpeedBuffDec", "$PSQ_SpeedBuffDec", -PSQ.SpeedBuffDec, "{0} %", SatiationFlags)
    Self.SetCursorPosition(3)
    Self.AddToggleOptionST("EnableStarvation", "$PSQ_EnableStarvationDeath", PSQ.EnableStarvation, 0)
    Self.AddToggleOptionST("EnergyModeAlt", "$PSQ_EnergyModeAlt", PSQ.EnergyModeAlt, 0)
    Self.AddSliderOptionST("MaxEnergyAtAltMode", "$PSQ_MaxEnergyAtAltMode", PSQ.MaxEnergyAtAltMode, "{0}", 0)
    Self.AddEmptyOption()
    Self.AddTextOptionST("SatiationBuffs", "$PSQ_SatiationBuffs", "", SatiationFlags)
    Self.AddSliderOptionST("HealthRateBuffInc", "$PSQ_HealthRateBuffInc", PSQ.HealthRateBuffInc - PSQ.HealthRateBuffDec, "{0} %", SatiationFlags)
    Self.AddSliderOptionST("HealthRateBuffDec", "$PSQ_HealthRateBuffDec", -PSQ.HealthRateBuffDec, "{0} %", SatiationFlags)
    Self.AddSliderOptionST("MagickaRateBuffInc", "$PSQ_MagickaRateBuffInc", PSQ.MagickaRateBuffInc - PSQ.MagickaRateBuffDec, "{0} %", SatiationFlags)
    Self.AddSliderOptionST("MagickaRateBuffDec", "$PSQ_MagickaRateBuffDec", -PSQ.MagickaRateBuffDec, "{0} %", SatiationFlags)
    Self.AddSliderOptionST("StaminaRateBuffInc", "$PSQ_StaminaRateBuffInc", PSQ.StaminaRateBuffInc - PSQ.StaminaRateBuffDec, "{0} %", SatiationFlags)
    Self.AddSliderOptionST("StaminaRateBuffDec", "$PSQ_StaminaRateBuffDec", -PSQ.StaminaRateBuffDec, "{0} %", SatiationFlags)
  EndIf
  If Page == "$PSQ_Page3"
    Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
    Self.SetCursorPosition(0)
    Self.AddHeaderOption("$PSQ_DragonbornTattooSettings", 0)
    Self.AddToggleOptionST("DragonbornSuccubusTattoo", "$PSQ_DragonbornSuccubusTattoo", PSQ.EnableDragonbornSuccubusTattoo, 0)
    Self.AddMenuOptionST("SuccubusTattooSelection", "$PSQ_SelectSuccubusTattoo", Self.GetSelectedSuccubusTattooName(), 0)
    Self.AddColorOptionST("CustomTattooGlowColor", "$PSQ_CustomTattooGlowColor", PSQ.CustomTattooGlowColor, (PSQ.GetTattooGlowMode() != 2) as Int)
    Self.AddMenuOptionST("TattooGlowMode", "$PSQ_TattooGlowMode", Self.GetTattooGlowModeName(PSQ.GetTattooGlowMode()), 0)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_SchlongSettings", 0)
    Self.AddMenuOptionST("PlayerHumanSchlong", "$PSQ_PlayerHumanSchlong", PSQ.GetTRXFutaLabel(False), 0)
    Self.AddMenuOptionST("PlayerSuccubusSchlong", "$PSQ_PlayerSuccubusSchlong", PSQ.GetTRXFutaLabel(True), 0)
    Self.AddToggleOptionST("AutoGenderSwitch", "$PSQ_AutoGenderSwitch", PSQ.AutoGenderSwitch, 0)
    Self.AddToggleOptionST("EnableFutanariPower", "$PSQ_EnableFutanariPower", PSQ.EnableFutanariPower, 0)
    Self.AddKeyMapOptionST("HotkeyCreatePenisSelf", "$PSQ_HotkeyCreatePenisSelf", PSQ.HotkeyCreatePenisSelf, 0)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_PSQSuccubusEye", 0)
    Self.AddSliderOptionST("SuccubusNightEyeStrength", "$PSQ_SuccubusNightEyeStrength", PSQ.SuccubusNightEyeStrength, "{2}", 0)
    Self.AddKeyMapOptionST("HotkeyDetectArousal", "$PSQ_HotkeyDetectArousal", PSQ.HotkeyDetectArousal, 0)
    Self.AddKeyMapOptionST("HotkeyNightEye", "$PSQ_HotkeyNightEye", PSQ.HotkeyNightEye, 0)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_PSQRape", 0)
    Self.AddToggleOptionST("EnablePSQRape", "$PSQ_EnablePSQRape", PSQ.EnablePSQRape, 0)
    Self.AddSliderOptionST("RapeHealthThreshold", "$PSQ_RapeHealthThreshold", PSQ.RapeHealthThreshold, "{0} %", 0)
    Self.AddSliderOptionST("RapeArousalThreshold", "$PSQ_RapeArousalThreshold", PSQ.RapeArousalThreshold as Float, "{0} %", 0)
    Self.AddSliderOptionST("RapeChance", "$PSQ_RapeChance", PSQ.RapeChance, "{0} %", 0)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_PSQFlying", 0)
    Self.AddToggleOptionST("EnableAutoAddFlying", "自动启用 Wingflight 飞行能力", PSQ.EnableAutoAddFlying, (!PSQ.CanControlWingflightPolicy()) as Int)
    Self.AddSliderOptionST("CanFlyingLevel", "$PSQ_CanFlyingLevel", PSQ.CanFlyingLevel as Float, "{0}", (!PSQ.CanControlWingflightPolicy()) as Int)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_Lure", 0)
    Self.AddToggleOptionST("PSQ_LureEffectOnFemale", "$PSQ_LureEffectOnFemale", storageutil.GetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnFemale", 0) == 0, 0)
    Self.AddToggleOptionST("PSQ_LureEffectOnMale", "$PSQ_LureEffectOnMale", storageutil.GetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnMale", 0) == 0, 0)
    Self.AddToggleOptionST("PSQ_LureEffectOnBeast", "$PSQ_LureEffectOnBeast", storageutil.GetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnBeast", 0) == 0, 0)
    Self.AddToggleOptionST("PSQ_LureEffectOnUndead", "$PSQ_LureEffectOnUndead", storageutil.GetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnUndead", 0) == 1, 0)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_OtherSettings", 0)
    Self.AddToggleOptionST("FluidNeedArousal", "$PSQ_FluidNeedArousal", PSQ.FluidNeedArousal, 0)
    Self.AddSliderOptionST("RequiredToFluid", "$PSQ_RequiredToFluid", PSQ.RequiredToFluid, "{0}", 0)
    Self.AddToggleOptionST("AllowHybrid", "$PSQ_AllowHybrid", PSQ.AllowHybrid, 0)
    Self.SetCursorPosition(1)
    Self.AddHeaderOption("$PSQ_TattooSettings", 0)
    Self.AddToggleOptionST("HenshinTattoo", "$PSQ_HenshinTattoo", PSQ.HenshinTattoo, 0)
    Self.AddToggleOptionST("EnableBodyPaintTintChangeSatiation", "$PSQ_EnableBodyPaintTintChangeSatiation", PSQ.EnableBodyPaintTintChangeSatiation, (PSQ.GetTattooGlowMode() == 1) as Int)
    Self.AddToggleOptionST("EnableBodyPaintAlphaChangeSatiation", "$PSQ_EnableBodyPaintAlphaChangeSatiation", PSQ.EnableBodyPaintAlphaChangeSatiation, 0)
    Self.AddToggleOptionST("EnableBodyPaintGlowTintChangeSatiation", "$PSQ_EnableBodyPaintGlowTintChangeSatiation", PSQ.EnableBodyPaintGlowTintChangeSatiation, (PSQ.GetTattooGlowMode() != 2) as Int)
    Self.AddToggleOptionST("EnableBodyPaintGlowAlphaChangeSatiation", "$PSQ_EnableBodyPaintGlowAlphaChangeSatiation", PSQ.EnableBodyPaintGlowAlphaChangeSatiation, (PSQ.GetTattooGlowMode() == 0) as Int)
    Self.AddTextOptionST("GetCurrentColorAsMax", "", "$PSQ_GetCurrentColorAsMax", 0)
    Self.AddTextOptionST("GetCurrentColorAsMin", "", "$PSQ_GetCurrentColorAsMin", 0)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_Familiar", 0)
    Self.AddToggleOptionST("ChargeFull", "$PSQ_ChargeFull", PSQ.ChargeFull, 0)
    Self.AddSliderOptionST("ChargeValueAuto", "$PSQ_ChargeValueAuto", PSQ.ChargeValueAuto, "{0}", 0)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_EnergyBarHeader", 0)
    Self.AddKeyMapOptionST("HotkeyEnergyBar", "$PSQ_HotkeyEnergyBar", PSQ.HotkeyEnergyBar, 0)
    Self.AddMenuOptionST("EnergyBarDisplay", "$PSQ_EnergyBarDisplay", Self.GetEnergyBarDisplayName(SEBU.GetEnergyBarDisplayMode()), 0)
    Self.AddTextOptionST("EnergyBarFillDirection", "$PSQ_EnergyBarFillDirection", Self.GetEnergyBarFillDirectionName(), 0)
    Self.AddSliderOptionST("EnergyBarX", "$PSQ_EnergyBarX", SEBU.EnergyBarX, "{0}", 0)
    Self.AddSliderOptionST("EnergyBarY", "$PSQ_EnergyBarY", SEBU.EnergyBarY, "{0}", 0)
    Self.AddSliderOptionST("ColorChangeThreshould01", "$PSQ_ColorChangeThreshould01", SEBU.ColorChangeThreshould01 * 100.0, "{0} %", 0)
    Self.AddSliderOptionST("ColorChangeThreshould02", "$PSQ_ColorChangeThreshould02", SEBU.ColorChangeThreshould02 * 100.0, "{0} %", 0)
    Self.AddSliderOptionST("ColorChangeThreshould03", "$PSQ_ColorChangeThreshould03", SEBU.ColorChangeThreshould03 * 100.0, "{0} %", 0)
    Self.AddColorOptionST("EnergyBarColor1A", "$PSQ_EnergyBarColor1A", SEBU.EnergyBarColor1A, 0)
    Self.AddColorOptionST("EnergyBarColor1B", "$PSQ_EnergyBarColor1B", SEBU.EnergyBarColor1B, 0)
    Self.AddColorOptionST("EnergyBarColor2A", "$PSQ_EnergyBarColor2A", SEBU.EnergyBarColor2A, 0)
    Self.AddColorOptionST("EnergyBarColor2B", "$PSQ_EnergyBarColor2B", SEBU.EnergyBarColor2B, 0)
    Self.AddColorOptionST("EnergyBarColor3A", "$PSQ_EnergyBarColor3A", SEBU.EnergyBarColor3A, 0)
    Self.AddColorOptionST("EnergyBarColor3B", "$PSQ_EnergyBarColor3B", SEBU.EnergyBarColor3B, 0)
    Self.AddColorOptionST("EnergyBarColor4A", "$PSQ_EnergyBarColor4A", SEBU.EnergyBarColor4A, 0)
    Self.AddColorOptionST("EnergyBarColor4B", "$PSQ_EnergyBarColor4B", SEBU.EnergyBarColor4B, 0)
  EndIf
  If Page == "$PSQ_Page4"
    Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
    Self.AddHeaderOption("$PSQ_Hotkeys", 0)
    Self.AddKeyMapOptionST("HotkeyEnableDrain", "$PSQ_HotkeyEnableDrain", PSQ.HotkeyEnableDrain, 0)
    Self.AddKeyMapOptionST("HotkeyAllowKill", "$PSQ_HotkeyAllowKill", PSQ.HotkeyAllowKill, 0)
    Self.AddKeyMapOptionST("HotkeyExtractSemenPotion", "$PSQ_HotkeyExtractSemenPotion", PSQ.HotkeyExtractSemenPotion, 0)
    Self.AddKeyMapOptionST("HotkeyEnableSoulTrap", "$PSQ_HotkeyEnableSoulTrap", PSQ.HotkeyEnableSoulTrap, 0)
    Self.AddKeyMapOptionST("HotkeySuccubusStats", "$PSQ_HotkeySuccubusStats", PSQ.HotkeySuccubusStats, 0)
    Self.AddKeyMapOptionST("HotkeyHenshin", "$PSQ_HotkeyHenshin", PSQ.HotkeyHenshin, 0)
    Self.AddKeyMapOptionST("HotkeySuccubusCharmSpell", "$PSQ_HotkeySuccubusCharmSpell", PSQ.HotkeySuccubusCharmSpell, 0)
    Self.AddKeyMapOptionST("HotkeyMasturbation", "$PSQ_HotkeyMasturbation", PSQ.HotkeyMasturbation, 0)
    Self.AddKeyMapOptionST("HotkeyCreatePenisSelf", "$PSQ_HotkeyCreatePenisSelf", PSQ.HotkeyCreatePenisSelf, 0)
    Self.AddKeyMapOptionST("HotkeyRestoreMagicka", "$PSQ_HotkeyRestoreMagicka", PSQ.HotkeyRestoreMagicka, 0)
    Self.AddKeyMapOptionST("HotkeyDigestion", "$PSQ_HotkeyDigestion", PSQ.HotkeyDigestion, 0)
    Self.SetCursorPosition(1)
    Self.AddTextOptionST("HotkeyDLTInfo", "$PSQ_HotkeyDLTInfo", "", 0)
    Self.AddKeyMapOptionST("HotkeyEnergyBar", "$PSQ_HotkeyEnergyBar", PSQ.HotkeyEnergyBar, 0)
    Self.AddKeyMapOptionST("HotkeyNightEye", "$PSQ_HotkeyNightEye", PSQ.HotkeyNightEye, 0)
    Self.AddKeyMapOptionST("HotkeyDetectArousal", "$PSQ_HotkeyDetectArousal", PSQ.HotkeyDetectArousal, 0)
    Self.AddKeyMapOptionST("HotkeyIncreaseNode", "$PSQ_HotkeyIncreaseNode", PSQ.HotkeyIncreaseNode, 0)
    Self.AddKeyMapOptionST("HotkeyDecreaseNode", "$PSQ_HotkeyDecreaseNode", PSQ.HotkeyDecreaseNode, 0)
    Self.AddKeyMapOptionST("HotkeyHeight", "$PSQ_HotkeyHeight", PSQ.HotkeyHeight, 0)
    Self.AddKeyMapOptionST("HotkeyButtNode", "$PSQ_HotkeyButtNode", PSQ.HotkeyButtNode, 0)
    Self.AddKeyMapOptionST("HotkeyGenitalsNode", "$PSQ_HotkeyGenitalsNode", PSQ.HotkeyGenitalsNode, 0)
    Self.AddKeyMapOptionST("HotkeyScrotumNode", "$PSQ_HotkeyScrotumNode", PSQ.HotkeyScrotumNode, 0)
  EndIf
  If Page == "$PSQ_Page5"
    Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
    Self.AddTextOptionST("HenshinCaution", "$PSQ_HenshinCaution", "", 0)
    BodySelectionOption = Self.AddMenuOption("$PSQ_TransformBodySelection", Self.GetTransformBodySelectionName(), 0)
    Self.AddToggleOptionST("HenshinSkin", "$PSQ_EnableHenshinSkin", PSQ.HenshinSkin, 0)
    Self.AddColorOptionST("PSQSkinColor", "$PSQ_HenshinSkinColor", PSQ.PSQSkinColor, 0)
    Self.AddSliderOptionST("HenshinSkinColorfulness", "$PSQ_HenshinSkinAlpha", PSQ.PSQSkinColorAlpha as Float, "{0}", 0)
    Self.AddTextOptionST("SetSkinColor", "", "$PSQ_SetSkinColor", 0)
    Self.AddMenuOptionST("SuccubusEyeMaterial", "$PSQ_SelectEyeMaterial", Self.GetSelectedEyeMaterialMenuName(), 0)
    Self.AddMenuOptionST("SwitchWings", "$PSQ_SwitchWings", Self.GetPlayerWingSelectionLabel(), 0)
    Self.AddMenuOptionST("TransformPart3", "$PSQ_TransformPart3", Self.GetIndependentPartLabel(3), 0)
    Self.AddMenuOptionST("TransformPart4", "$PSQ_TransformPart4", Self.GetIndependentPartLabel(4), 0)
    Self.AddMenuOptionST("TransformPart0", "$PSQ_TransformPart0", Self.GetIndependentPartLabel(0), 0)
    Self.AddMenuOptionST("TransformPart1", "$PSQ_TransformPart1", Self.GetIndependentPartLabel(1), 0)
    Self.AddMenuOptionST("TransformPart2", "$PSQ_TransformPart2", Self.GetIndependentPartLabel(2), 0)
    Self.AddToggleOptionST("HenshinPenis", "$PSQ_EnableHenshinPenis", PSQ.HenshinPenis, 0)
    Self.AddMenuOptionST("TransformHairMenu", "$PSQ_TransformHairSelect", Self.GetTransformHairLabel(PSQ.SuccubusHairSelection), 0)
    Self.AddToggleOptionST("HenshinHairColor", "$PSQ_EnableHenshinHairColor", PSQ.HenshinHairColor, 0)
    Self.AddColorOptionST("PSQSuccubusHairColorInt", "$PSQ_HairColor", PSQ.PSQSuccubusHairColorInt, 0)
    Self.AddTextOptionST("SetHairColor", "", "$PSQ_SetHairColor", 0)
    Self.SetCursorPosition(3)
    Self.AddToggleOptionST("EnableSuccubusSpellBooster", "$PSQ_EnableSuccubusSpellBooster", PSQ.GetContinuousOptionEnabled(10), Self.GetContinuousOptionsFlags())
    Self.AddToggleOptionST("CanWalkOnTheWater", "$PSQ_CanWalkOnTheWater", PSQ.CanWalkOnTheWater, 0)
    Self.AddToggleOptionST("HenshinIsCrime", "$PSQ_HenshinIsCrime", PSQ.HenshinIsCrime, 0)
    Self.AddToggleOptionST("HenshinFear", "$PSQ_HenshinFear", PSQ.HenshinFear, 0)
    TransformBuffModeOption = Self.AddMenuOption("$PSQ_HenshinBuff", Self.GetTransformBuffModeName(), 0)
    Int TransformBuffFlags = 1
    If PSQ.GetTransformBuffMode() == 2
      TransformBuffFlags = 0
    EndIf
    Self.AddSliderOptionST("HenshinBuffRateHealth", "$PSQ_HenshinBuffRateHealth", PSQ.GetTransformBuffRate(0), "{0} %", TransformBuffFlags)
    Self.AddSliderOptionST("HenshinBuffRateMagicka", "$PSQ_HenshinBuffRateMagicka", PSQ.GetTransformBuffRate(1), "{0} %", TransformBuffFlags)
    Self.AddSliderOptionST("HenshinBuffRateStamina", "$PSQ_HenshinBuffRateStamina", PSQ.GetTransformBuffRate(2), "{0} %", TransformBuffFlags)
    Self.AddSliderOptionST("HenshinBuffRateCarry", "$PSQ_HenshinBuffRateCarry", PSQ.GetTransformBuffRate(3), "{0} %", TransformBuffFlags)
    Self.AddSliderOptionST("SuccubusArmorMagnitude", "$PSQ_TransformArmorPerRank", PSQ.GetTransformArmorPerRank(), "{0}", TransformBuffFlags)
    Self.AddTextOption("$PSQ_TransformArmorCurrent", (PSQ.GetTransformArmorBonus() as Int) as String + "点", 1)
    Self.AddEmptyOption()
    Self.AddToggleOptionST("ArousedForceTransform", "$PSQ_ArousedForceTransform", PSQ.ArousedForceTransform, 0)
    Self.AddSliderOptionST("TransformThreshold", "$PSQ_TransformThreshold", PSQ.TransformThreshold, "{0}", 0)
    Self.AddToggleOptionST("ArousedForceDeTransform", "$PSQ_ArousedForceDeTransform", PSQ.ArousedForceDeTransform, 0)
    Self.AddSliderOptionST("DeTransformThreshold", "$PSQ_DeTransformThreshold", PSQ.DeTransformThreshold, "{0}", 0)
    Self.AddToggleOptionST("AllowHenshinAddExposure", "$AllowHenshinAddExposure", PSQ.AllowHenshinAddExposure, 0)
    Self.AddToggleOptionST("AllowHenshinConsumeEnergy", "$AllowHenshinConsumeEnergy", PSQ.AllowHenshinConsumeEnergy, 0)
    Self.AddSliderOptionST("HenshinConsumeEnergy", "$HenshinConsumeEnergy", PSQ.HenshinConsumeEnergy, "{1}", 0)
  EndIf
  If Page == "$PSQ_Page6"
    Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
    Self.AddHeaderOption("$PSQ_BodyShapeChange", 0)
    Self.AddToggleOptionST("EnableHeightChangeSuccubus", "$PSQ_EnableHeightChangeSuccubus", PSQ.EnableHeightChangeSuccubus, 0)
    Self.AddSliderOptionST("SuccubusHeight", "$PSQ_SuccubusHeight", PSQ.SuccubusHeight, "{2}", 0)
    Self.AddToggleOptionST("EnableButtChangeSuccubus", "$PSQ_EnableButtChangeSuccubus", PSQ.EnableButtChangeSuccubus, 0)
    Self.AddSliderOptionST("SuccubusButt", "$PSQ_SuccubusButt", PSQ.SuccubusButt, "{2}", 0)
    Self.SetCursorPosition(3)
    Self.AddToggleOptionST("EnableGenitalsChangeSuccubus", "$EnableGenitalsChangeSuccubus", PSQ.EnableGenitalsChangeSuccubus, 0)
    Self.AddSliderOptionST("SuccubusGenitals", "$PSQ_SuccubusGenitals", PSQ.SuccubusGenitals, "{2}", 0)
    Self.AddToggleOptionST("EnableScrotumChangeSuccubus", "$PSQ_EnableScrotumChangeSuccubus", PSQ.EnableScrotumChangeSuccubus, 0)
    Self.AddSliderOptionST("SuccubusScrotum", "$PSQ_SuccubusScrotum", PSQ.SuccubusScrotum, "{2}", 0)
  EndIf
  If Page == "$PSQ_Page8"
    PSQ.SyncManagedAbilities()
    Int AbilityFlags = 1
    If PSQ.GetAbilityManagementMode() == 2
      AbilityFlags = 0
    EndIf
    Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
    Self.AddMenuOptionST("AbilityManagementMode", "$PSQ_AbilityManagementMode", Self.GetAbilityManagementModeName(), 0)
    Self.AddTextOptionST("SpellSwichNotice", "$PSQ_SpellSwichNotice", "", 0)
    Int SenseFlags = AbilityFlags
    If PSQ.SuccubusRank.GetValueInt() < 4
      SenseFlags = 1
    EndIf
    Self.AddToggleOptionST("EnergySenseSpell", "$PSQ_EnergySenseName", PSQ.PlayerRef.HasSpell(PSQ.GetEnergySenseSpell() as Form), SenseFlags)
    Int RepairFlags = AbilityFlags
    If !PSQ.HasAproposRepairIntegration()
      RepairFlags = 1
    EndIf
    Self.AddToggleOptionST("AproposRepairSpell", "$PSQ_AproposRepairName", PSQ.PlayerRef.HasSpell(PSQ.GetAproposRepairSpell() as Form), RepairFlags)
    Self.AddToggleOptionST("EnableSuccubusDrainHealthSpell", "$PSQ_EnableSuccubusDrainHealthSpell", PSQ.EnableSuccubusDrainHealthSpell, AbilityFlags)
    Self.AddToggleOptionST("EnableSuccubusDrainStaminaSpell", "$PSQ_EnableSuccubusDrainStaminaSpell", PSQ.EnableSuccubusDrainStaminaSpell, AbilityFlags)
    Self.AddToggleOptionST("EnableSuccubusDrainFF", "$PSQ_EnableSuccubusDrainFF", PSQ.EnableSuccubusDrainFF, AbilityFlags)
    Self.AddToggleOptionST("CreatePenisSpellSelf", PSQ.CreatePenisSpellSelf.GetName(), PSQ.PlayerRef.HasSpell(PSQ.CreatePenisSpellSelf as Form), AbilityFlags)
    Self.AddToggleOptionST("CreatePenisSpellOther", PSQ.CreatePenisSpellOther.GetName(), PSQ.PlayerRef.HasSpell(PSQ.CreatePenisSpellOther as Form), AbilityFlags)
    Self.AddToggleOptionST("StarkRealitySpell", PSQ.StarkRealitySpell.GetName(), PSQ.PlayerRef.HasSpell(PSQ.StarkRealitySpell as Form), AbilityFlags)
    Self.AddToggleOptionST("SuccuKanashibari", PSQ.SuccuKanashibari.GetName(), PSQ.PlayerRef.HasSpell(PSQ.SuccuKanashibari as Form), AbilityFlags)
    Self.SetCursorPosition(5)
    Self.AddToggleOptionST("SuccubusRaiseArousalSpell", PSQ.SuccubusRaiseArousalSpell.GetName(), PSQ.PlayerRef.HasSpell(PSQ.SuccubusRaiseArousalSpell as Form), AbilityFlags)
    Self.AddToggleOptionST("FortifyMSGBoxSpell", PSQ.FortifyMSGBoxSpell.GetName(), PSQ.PlayerRef.HasSpell(PSQ.FortifyMSGBoxSpell as Form), AbilityFlags)
    Self.AddToggleOptionST("SuccubusSpellLearningMSGBoxSpell", PSQ.SuccubusSpellLearningMSGBoxSpell.GetName(), PSQ.PlayerRef.HasSpell(PSQ.SuccubusSpellLearningMSGBoxSpell as Form), AbilityFlags)
    Self.AddToggleOptionST("SuccubusSummonMerchantSpell", PSQ.SuccubusSummonMerchantSpell.GetName(), PSQ.PlayerRef.HasSpell(PSQ.SuccubusSummonMerchantSpell as Form), AbilityFlags)
    Self.AddToggleOptionST("RestoreMagickaSpell", PSQ.RestoreMagickaSpell.GetName(), PSQ.PlayerRef.HasSpell(PSQ.RestoreMagickaSpell as Form), AbilityFlags)
    Self.AddToggleOptionST("MasturbationSpell", PSQ.MasturbationSpell.GetName(), PSQ.PlayerRef.HasSpell(PSQ.MasturbationSpell as Form), AbilityFlags)
    Self.AddToggleOptionST("ImmunityToSTD", PSQ.ImmunityToSTD.GetName(), PSQ.PlayerRef.HasSpell(PSQ.ImmunityToSTD as Form), 0)
    Self.AddToggleOptionST("SuccubusStorageSpell", PSQ.SuccubusStorageSpell.GetName(), PSQ.GetContinuousOptionEnabled(5), Self.GetStorageOptionFlags())
  EndIf
  If Page == "$PSQ_Page9"
    PSQ.SyncContinuousAbilities(False)
    Int ContinuousFlags = Self.GetContinuousOptionsFlags()
    Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
    Self.AddHeaderOption("$PSQ_SpellEnergySettings", 0)
    Self.AddToggleOptionST("EnableEnergyConsumingBySuccubusSpell", "$PSQ_EnableEnergyConsumingBySuccubusSpell", PSQ.EnableEnergyConsumingBySuccubusSpell, 0)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_ContinuousAbilitySettings", 0)
    Self.AddMenuOptionST("ContinuousAbilityMode", "$PSQ_ContinuousMode", Self.GetContinuousModeName(), 0)
    If PSQ.GetContinuousAbilityMode() == 1
      Self.AddTextOption("$PSQ_ContinuousStats", ("+" + (PSQ.GetContinuousRank() * 10) as String) + "%", 1)
      Self.AddTextOption("$PSQ_ContinuousPower", ("+" + (PSQ.GetContinuousRank() * 5) as String) + "%", 1)
      Self.AddTextOption("$PSQ_ContinuousResistance", ("+" + (PSQ.GetContinuousRank() * 3) as String) + "%", 1)
    EndIf
    Self.AddToggleOptionST("EnableSpellCastingNotification", "$PSQ_EnableSpellCastingNotification", PSQ.GetContinuousOptionEnabled(13), ContinuousFlags)
    Self.AddToggleOptionST("FortifyMagickaSpell", PSQ.FortifyMagickaSpell.GetName(), PSQ.GetContinuousOptionEnabled(0), ContinuousFlags)
    Self.AddToggleOptionST("FortifyStaminaSpell", PSQ.FortifyStaminaSpell.GetName(), PSQ.GetContinuousOptionEnabled(1), ContinuousFlags)
    Self.AddToggleOptionST("FortifyHealthSpell", PSQ.FortifyHealthSpell.GetName(), PSQ.GetContinuousOptionEnabled(2), ContinuousFlags)
    Self.AddToggleOptionST("FortifyCarrySpell", PSQ.FortifyCarrySpell.GetName(), PSQ.GetContinuousOptionEnabled(3), ContinuousFlags)
    Self.AddToggleOptionST("FortifyUnarmedSpell", PSQ.FortifyUnarmedSpell.GetName(), PSQ.GetContinuousOptionEnabled(4), ContinuousFlags)
    Self.AddToggleOptionST("EnableFortifyDestruction", "$PSQ_EnableFortifyDestruction", PSQ.GetContinuousOptionEnabled(7), ContinuousFlags)
    Self.AddSliderOptionST("FortifyDestructionMult", "$PSQ_FortifyDestructionMult", PSQ.FortifyDestructionMult * 100.0, "{0} %", ContinuousFlags)
    Self.AddToggleOptionST("EnableFortifyIllusion", "$PSQ_EnableFortifyIllusion", PSQ.GetContinuousOptionEnabled(8), ContinuousFlags)
    Self.AddSliderOptionST("FortifyIllusionMult", "$PSQ_FortifyIllusionMult", PSQ.FortifyIllusionMult * 100.0, "{0} %", ContinuousFlags)
    Self.AddToggleOptionST("EnableMagicResistance", "$PSQ_EnableMagicResistance", PSQ.GetContinuousOptionEnabled(9), ContinuousFlags)
    Self.AddSliderOptionST("MagicResistanceMult", "$PSQ_MagicResistanceMult", PSQ.MagicResistanceMult * 100.0, "{0} %", ContinuousFlags)
    Self.AddToggleOptionST("EnableSuccubusSpellBooster", "$PSQ_EnableSuccubusSpellBooster", PSQ.GetContinuousOptionEnabled(10), ContinuousFlags)
    Self.AddToggleOptionST("FortifySneakSpell", "$PSQ_EnableFortifySneak", PSQ.GetContinuousOptionEnabled(6), ContinuousFlags)
    Self.AddToggleOptionST("EnableFortifyBartar", "$PSQ_EnableFortifyBartar", PSQ.GetContinuousOptionEnabled(11), ContinuousFlags)
    Self.SetCursorPosition(1)
    Self.AddHeaderOption("$PSQ_OtherAbilitySettings", 0)
    Self.AddSliderOptionST("WingMaxJumpHeight", "Wingflight 翼装跳跃高度", PSQ.WingMaxJumpHeight, "{0}", (!PSQ.CanControlWingflightPolicy()) as Int)
    Self.AddSliderOptionST("DefaultJumpHeight", "$PSQ_DefaultJumpHeight", PSQ.DefaultJumpHeight, "{0}", 0)
    Self.AddHeaderOption("$PSQ_EnergyConversionMAX", 0)
    Self.AddSliderOptionST("RestoreMagickaMAX", "$PSQ_EnergyConversionMagicka", PSQ.RestoreMagickaMAX, "{0}", 0)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_RankMagicCostHeader", 0)
    Self.AddToggleOptionST("RankMagicCostReduction", "$PSQ_RankMagicCostEnabled", PSQ.EnableRankMagicCostReduction, 0)
    Self.AddTextOption("$PSQ_RankMagicCostCurrent", PSQ.GetRankMagicCostReduction() as String + "%", 0)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_RankSpeedHeader", 0)
    Self.AddToggleOptionST("RankSpeedBonusEnabled", "$PSQ_RankSpeedEnabled", PSQ.EnableRankSpeedBonus, 0)
    Self.AddTextOption("$PSQ_RankSpeedHuman", ("+" + (PSQ.GetRankSpeedBonus(False) as Int) as String) + " %", 0)
    Self.AddTextOption("$PSQ_RankSpeedTransformed", ("+" + (PSQ.GetRankSpeedBonus(True) as Int) as String) + " %", 0)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_DragonAbilitiesHeader", 0)
    DragonSoulModeOption = Self.AddMenuOption("$PSQ_DragonSoulMode", Self.GetDragonSoulModeName(DragonSoulExchangeMode), 0)
    Self.AddTextOptionST("DragonSoulExchange", "$PSQ_DragonSoulExchange", "$PSQ_Execute", (DragonSoulExchangeMode == 0) as Int)
    Self.AddToggleOptionST("RankShoutBonusEnabled", "$PSQ_ShoutBonusEnabled", PSQ.EnableRankShoutCooldownBonus, 0)
    Self.AddTextOption("$PSQ_ShoutBonusCurrent", ((PSQ.GetRankShoutCooldownReduction() * 100.0) as Int) as String + "%", 0)
    Self.AddTextOptionST("ResetRankShoutBonus", "$PSQ_ResetShoutBonus", "$PSQ_Execute", 0)
  EndIf
  If Page == "$PSQ_Page10"
    Self.AddToggleOptionST("StopEnergyConsuming", "$PSQ_PauseEnergyConsuming", PSQ.StopEnergyConsuming, 0)
    Self.AddTextOptionST("InitFaction", "", "$PSQ_InitFaction", 0)
    Self.AddTextOptionST("BecomeSuccubus", "", Self.GetBecomeSuccubusStrings(), 0)
    Self.AddTextOptionST("RegisteriNeed", "$PSQ_RegisteriNeed", "$PSQ_Execute", Self.IntegrationOptionFlags("iNeed.esp"))
    Self.AddTextOptionST("RegisterEFF", "$PSQ_RegisterEFF", "$PSQ_Execute", Self.IntegrationOptionFlags("EFFCore.esm"))
    Self.AddTextOptionST("OpenTestTools", "$PSQ_TestTools", "$PSQ_TestToolsOpen", 0)
    Self.AddTextOptionST("StopEnergySenseNow", "$PSQ_EnergySenseForceOff", "$PSQ_Execute", 0)
    Self.AddTextOptionST("RecoverAppearance", "$PSQ_AppearanceRecovery", "$PSQ_Execute", (!PSQ.CanRequestAppearanceRecovery()) as Int)
    Self.AddEmptyOption()
    Self.AddHeaderOption("$PSQ_UninstallHeader", 0)
    Self.AddTextOptionST("PreparePSQUninstall", "$PSQ_UninstallButton", "$PSQ_Execute", 0)
  EndIf
  If Page == "$PSQ_Page11"
    Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
    Self.AddTextOptionST("NPCTransform", "NPC 变身", "", 0)
    Self.AddTextOptionST("NPCName", SuccubusNPC.GetLeveledActorBase().GetName(), "", 0)
    Self.AddToggleOptionST("NPCBecomeSuccubus", "注册为魅魔", storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformRegistered", 0) as Bool, 0)
    Self.AddToggleOptionST("NPCHenshinBody", "$PSQ_EnableHenshinBody", storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformBody", 0) as Bool, 0)
    Self.AddToggleOptionST("NPCHenshinSkin", "$PSQ_EnableHenshinSkin", storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformSkin", 0) as Bool, 0)
    Self.AddColorOptionST("NPCPSQSkinColor", "$PSQ_HenshinSkinColor", storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformSkinColor", 0), 0)
    Self.AddTextOptionST("NPCSetSkinColor", "", "$PSQ_SetSkinColor", 0)
    Self.AddToggleOptionST("NPCHenshinEyes", "$PSQ_EnableHenshinEyes", storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformEye", 0) as Bool, 0)
    Self.AddToggleOptionST("NPCHenshinWings", "$PSQ_EnableHenshinWings", storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformWings", 0) as Bool, 0)
    Self.AddMenuOptionST("NPCSwitchWings", "$PSQ_SwitchWings", storageutil.GetFormValue(SuccubusNPC as Form, "PSQ_NPCWings", None) as String, 0)
    Self.AddToggleOptionST("NPCHenshinHorn", "$PSQ_EnableHenshinHorn", storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformHorns", 0) as Bool, 0)
    Self.AddToggleOptionST("NPCHenshinTail", "$PSQ_EnableHenshinTail", storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformTail", 0) as Bool, 0)
    Self.AddToggleOptionST("NPCHenshinCuirass", "$PSQ_EnableHenshinCuirass", storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformCuirass", 0) as Bool, 0)
    Self.AddToggleOptionST("NPCHenshinBoots", "$PSQ_EnableHenshinBoots", storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformBoots", 0) as Bool, 0)
    Self.AddToggleOptionST("NPCHenshinGloves", "$PSQ_EnableHenshinGloves", storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformGauntlets", 0) as Bool, 0)
    Self.AddToggleOptionST("NPCHenshinPenis", "$PSQ_EnableHenshinPenis", storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformPenis", 0) as Bool, 0)
    Self.SetCursorPosition(1)
    Self.AddToggleOptionST("NPCHenshinScale", "变身时调整体型", storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformScale", 0) as Bool, 0)
    Self.AddSliderOptionST("NPCSuccubusHeight", "$PSQ_SuccubusHeight", storageutil.GetFloatValue(SuccubusNPC as Form, "PSQ_NPCTransformHeight", 0.0), "{2}", 0)
    Self.AddSliderOptionST("NPCSuccubusButt", "$PSQ_SuccubusButt", storageutil.GetFloatValue(SuccubusNPC as Form, "PSQ_NPCTransformButt", 0.0), "{2}", 0)
    Self.AddSliderOptionST("NPCSuccubusGenitals", "$PSQ_SuccubusGenitals", storageutil.GetFloatValue(SuccubusNPC as Form, "PSQ_NPCTransformGenitals", 0.0), "{2}", 0)
    Self.AddSliderOptionST("NPCSuccubusScrotum", "$PSQ_SuccubusScrotum", storageutil.GetFloatValue(SuccubusNPC as Form, "PSQ_NPCTransformScrotum", 0.0), "{2}", 0)
  EndIf
EndFunction

Function HandleAppearanceOnSelectST(Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = PSQ.AppearanceOperationId
    RequireBusy = PSQ.AppearanceEditBusy
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  String ThrallOption = Self.GetState()
  Int ThrallSlot = Self.GetThrallActionSlot(ThrallOption)
  If ThrallSlot >= 0
    If ThrallOption == "ThrallRelease0" || ThrallOption == "ThrallRelease1" || ThrallOption == "ThrallRelease2" || ThrallOption == "ThrallRelease3"
      If Self.ShowMessage("$PSQ_ThrallReleaseConfirm", True, "$Yes", "$No")
        PSQ.ReleaseSuccubusThrall(ThrallSlot)
      EndIf
    Else
      PSQ.RecallSuccubusThrall(ThrallSlot)
    EndIf
    Self.ForcePageReset()
    Return 
  ElseIf ThrallOption == "ThrallRefresh"
    Self.ForcePageReset()
    Return 
  EndIf
  Bool PSQVisualRuntime = skse.GetPluginVersion("skee") >= 0 || skse.GetPluginVersion("NiOverride") >= 0
  String Option = Self.GetState()
  Int ManagedIndex = Self.GetManagedAbilityIndex(Option)
  If ManagedIndex >= 0
    If PSQ.GetAbilityManagementMode() == 2
      PSQ.ToggleManualManagedAbility(ManagedIndex)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      Self.SetToggleOptionValueST(PSQ.GetManagedAbilityEnabled(ManagedIndex), False, "")
    EndIf
    Return 
  EndIf
  If Option == "EnableDrain"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableDrain = !PSQ.EnableDrain
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableDrain, False, "")
  ElseIf Option == "AllowDrainFromFemale"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.AllowDrainFromFemale = !PSQ.AllowDrainFromFemale
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.AllowDrainFromFemale, False, "")
  ElseIf Option == "AllowDrainFromBeast"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.AllowDrainFromBeast = !PSQ.AllowDrainFromBeast
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.AllowDrainFromBeast, False, "")
  ElseIf Option == "AllowDrainFromUndead"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.AllowDrainFromUndead = !PSQ.AllowDrainFromUndead
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.AllowDrainFromUndead, False, "")
  ElseIf Option == "ExtractSemenPotion"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.ExtractSemenPotion = !PSQ.ExtractSemenPotion
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.ExtractSemenPotion, False, "")
  ElseIf Option == "AutoExtractSemenPotion"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.AutoExtractSemenPotion = !PSQ.AutoExtractSemenPotion
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.AutoExtractSemenPotion, False, "")
  ElseIf Option == "FastMode"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.FastMode = !PSQ.FastMode
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.FastMode, False, "")
  ElseIf Option == "AdjustMinEnergyOfHuman"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.AdjustMinEnergyOfHuman = !PSQ.AdjustMinEnergyOfHuman
    PSQ.PublishEnergySenseConfig()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.AdjustMinEnergyOfHuman, False, "")
  ElseIf Option == "EnableSoulTrap"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableSoulTrap = !PSQ.EnableSoulTrap
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableSoulTrap, False, "")
  ElseIf Option == "AllowKill"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.AllowKill = !PSQ.AllowKill
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.AllowKill, False, "")
  ElseIf Option == "EnableCaptive"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableCaptive = !PSQ.EnableCaptive
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableCaptive, False, "")
  ElseIf Option == "UseArousalAtDrain"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.UseArousalAtDrain = !PSQ.UseArousalAtDrain
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.UseArousalAtDrain, False, "")
  ElseIf Option == "AllowSneakFeed"
    If PSQ.AllowSneakFeed.GetValueInt() == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.AllowSneakFeed.SetValue(1.0)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.AllowSneakFeed.SetValue(0.0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.AllowSneakFeed.GetValueInt() as Bool, False, "")
  ElseIf Option == "AllowSleepFeed"
    If PSQ.AllowSleepFeed.GetValueInt() == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.AllowSleepFeed.SetValue(1.0)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.AllowSleepFeed.SetValue(0.0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.AllowSleepFeed.GetValueInt() as Bool, False, "")
  ElseIf Option == "AllowForceFeed"
    If PSQ.AllowForceFeed.GetValueInt() == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.AllowForceFeed.SetValue(1.0)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.AllowForceFeed.SetValue(0.0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.AllowForceFeed.GetValueInt() as Bool, False, "")
  ElseIf Option == "AllowTeamMateFeed"
    If PSQ.AllowTeamMateFeed.GetValueInt() == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.AllowTeamMateFeed.SetValue(1.0)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.AllowTeamMateFeed.SetValue(0.0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.AllowTeamMateFeed.GetValueInt() as Bool, False, "")
  ElseIf Option == "EnableSatiationEffect"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableSatiationEffect = !PSQ.EnableSatiationEffect
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableSatiationEffect, False, "")
  ElseIf Option == "EnableSatiationNotification"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableSatiationNotification = !PSQ.EnableSatiationNotification
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableSatiationNotification, False, "")
  ElseIf Option == "EnableStarvation"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableStarvation = !PSQ.EnableStarvation
    If SuccubusEnergy.GetValue() == 0.0
      If PSQ.EnableStarvation
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusStarvation, False)
      Else
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusStarvation)
      EndIf
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableStarvation, False, "")
  ElseIf Option == "EnergyModeAlt"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnergyModeAlt = !PSQ.EnergyModeAlt
    If PSQ.EnergyModeAlt
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.MaxEnergy = PSQ.MaxEnergyAtAltMode
    ElseIf SuccubusEXP.GetValue() >= 10.0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      Float PendingAppearanceValue1 = 250.0 * Math.Sqrt(SuccubusEXP.GetValue())
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.MaxEnergy = PendingAppearanceValue1
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      Float PendingAppearanceValue2 = 60.0 * SuccubusEXP.GetValue() + 200.0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.MaxEnergy = PendingAppearanceValue2
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnergyConsumption = PSQ.MaxEnergy * PSQ.EnergyConsumptionPerMax / 100.0
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnergyModeAlt, False, "")
  ElseIf Option == "AutoGenderSwitch"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.AutoGenderSwitch = !PSQ.AutoGenderSwitch
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.AutoGenderSwitch, False, "")
  ElseIf Option == "EnableFutanariPower"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableFutanariPower = !PSQ.EnableFutanariPower
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableFutanariPower, False, "")
  ElseIf Option == "EnableAutoAddFlying"
    if !PSQ.CanControlWingflightPolicy()
      Self.SetInfoText("独立飞行模式：Wingflight／OSYRN 自身设置生效；PSQ 专有等级、自动启用和翼装跳高控制不可用。")
      return
    endif
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableAutoAddFlying = !PSQ.EnableAutoAddFlying
    PSQ.SyncWingflightPolicy()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableAutoAddFlying, False, "")
  ElseIf Option == "ChargeFull"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.ChargeFull = !PSQ.ChargeFull
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.ChargeFull, False, "")
  ElseIf Option == "EnablePSQRape"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnablePSQRape = !PSQ.EnablePSQRape
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnablePSQRape, False, "")
  ElseIf Option == "EnableCumInflation"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableCumInflation = !PSQ.EnableCumInflation
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableCumInflation, False, "")
  ElseIf Option == "AllowCumInflationAnal"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.CumInflationAnal = !PSQ.CumInflationAnal
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.CumInflationAnal, False, "")
  ElseIf Option == "AllowCumInflationOral"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.CumInflationOral = !PSQ.CumInflationOral
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.CumInflationOral, False, "")
  ElseIf Option == "FluidNeedArousal"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.FluidNeedArousal = !PSQ.FluidNeedArousal
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.FluidNeedArousal, False, "")
  ElseIf Option == "AllowHybrid"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.AllowHybrid = !PSQ.AllowHybrid
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.AllowHybrid, False, "")
  ElseIf Option == "DragonbornSuccubusTattoo"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableDragonbornSuccubusTattoo = !PSQ.EnableDragonbornSuccubusTattoo
    If PlayerIsSuccubus.GetValueInt() == 1 && PSQ.MaxEnergy > 0.0
      PSQ.ChangeBodyPaint(PSQ.GetEnergyRatio(), True)
    Else
      PSQ.ChangeBodyPaint(0.0, True)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableDragonbornSuccubusTattoo, False, "")
  ElseIf Option == "HenshinTattoo"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinTattoo = !PSQ.HenshinTattoo
    If PlayerIsSuccubus.GetValueInt() == 1
      PSQ.Satiety(0.0)
    Else
      PSQ.ChangeBodyPaint(0.0, True)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.HenshinTattoo, False, "")
  ElseIf Option == "EnableBodyPaintTintChangeSatiation"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableBodyPaintTintChangeSatiation = !PSQ.EnableBodyPaintTintChangeSatiation
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableBodyPaintTintChangeSatiation, False, "")
  ElseIf Option == "EnableBodyPaintAlphaChangeSatiation"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableBodyPaintAlphaChangeSatiation = !PSQ.EnableBodyPaintAlphaChangeSatiation
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableBodyPaintAlphaChangeSatiation, False, "")
  ElseIf Option == "EnableBodyPaintGlowTintChangeSatiation"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableBodyPaintGlowTintChangeSatiation = !PSQ.EnableBodyPaintGlowTintChangeSatiation
    PSQ.ChangeBodyPaint(PSQ.GetEnergyRatio(), True)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableBodyPaintGlowTintChangeSatiation, False, "")
  ElseIf Option == "EnableBodyPaintGlowAlphaChangeSatiation"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableBodyPaintGlowAlphaChangeSatiation = !PSQ.EnableBodyPaintGlowAlphaChangeSatiation
    PSQ.ChangeBodyPaint(PSQ.GetEnergyRatio(), True)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableBodyPaintGlowAlphaChangeSatiation, False, "")
  ElseIf Option == "EnableCursePaintGradient"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableCursePaintGradient = False
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusCurseCloakSpell)
  ElseIf Option == "EnableCursePaintTint"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableCursePaintTint = !PSQ.EnableCursePaintTint
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableCursePaintTint, False, "")
  ElseIf Option == "EnableCursePaintAlpha"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableCursePaintAlpha = !PSQ.EnableCursePaintAlpha
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableCursePaintAlpha, False, "")
  ElseIf Option == "EnableCursePaintGlowTint"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableCursePaintGlowTint = !PSQ.EnableCursePaintGlowTint
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableCursePaintGlowTint, False, "")
  ElseIf Option == "EnableCursePaintGlowAlpha"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableCursePaintGlowAlpha = !PSQ.EnableCursePaintGlowAlpha
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableCursePaintGlowAlpha, False, "")
  ElseIf Option == "HenshinSkin"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinSkin = !PSQ.HenshinSkin
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SyncTransformSkinColor(Owner, RequireBusy)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.HenshinSkin, False, "")
  ElseIf Option == "HenshinWings"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinWings = !PSQ.HenshinWings
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.HenshinWings, False, "")
  ElseIf Option == "HenshinHorn"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinHorn = !PSQ.HenshinHorn
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.HenshinHorn, False, "")
  ElseIf Option == "HenshinTail"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinTail = !PSQ.HenshinTail
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.HenshinTail, False, "")
  ElseIf Option == "HenshinCuirass"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinCuirass = !PSQ.HenshinCuirass
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.HenshinCuirass, False, "")
  ElseIf Option == "HenshinBoots"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinBoots = !PSQ.HenshinBoots
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.HenshinBoots, False, "")
  ElseIf Option == "HenshinGloves"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinGloves = !PSQ.HenshinGloves
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.HenshinGloves, False, "")
  ElseIf Option == "HenshinPenis"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinPenis = !PSQ.HenshinPenis
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.HenshinPenis, False, "")
  ElseIf Option == "HenshinHairColor"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SetTransformHairColorEnabled(!PSQ.HenshinHairColor, Owner, RequireBusy)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.HenshinHairColor, False, "")
  ElseIf Option == "EnableSuccubusSpellBooster"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableSuccubusSpellBooster = !PSQ.EnableSuccubusSpellBooster
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableSuccubusSpellBooster, False, "")
  ElseIf Option == "CanWalkOnTheWater"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.CanWalkOnTheWater = !PSQ.CanWalkOnTheWater
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.CanWalkOnTheWater, False, "")
  ElseIf Option == "HenshinIsCrime"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinIsCrime = !PSQ.HenshinIsCrime
    If PSQ.IsHenshined
      If PSQ.HenshinIsCrime
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddToFaction(PSQ.SuccubusFoeFaction)
      Else
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.RemoveFromFaction(PSQ.SuccubusFoeFaction)
      EndIf
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.HenshinIsCrime, False, "")
  ElseIf Option == "HenshinFear"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinFear = !PSQ.HenshinFear
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.HenshinFear, False, "")
  ElseIf Option == "ArousedForceTransform"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.ArousedForceTransform = !PSQ.ArousedForceTransform
    If PSQ.ArousedForceTransform
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.AddSpell(PSQ.SuccubusForceTransform, True)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusForceTransform)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.ArousedForceTransform, False, "")
  ElseIf Option == "ArousedForceDeTransform"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.ArousedForceDeTransform = !PSQ.ArousedForceDeTransform
    If PSQ.ArousedForceDeTransform
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.AddSpell(PSQ.SuccubusForceTransform, True)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusForceTransform)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.ArousedForceDeTransform, False, "")
  ElseIf Option == "AllowHenshinAddExposure"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.AllowHenshinAddExposure = !PSQ.AllowHenshinAddExposure
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.AllowHenshinAddExposure, False, "")
  ElseIf Option == "AllowHenshinConsumeEnergy"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SettleTransformEnergy()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.AllowHenshinConsumeEnergy = !PSQ.AllowHenshinConsumeEnergy
    PSQ.ResetTransformEnergyClock()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.AllowHenshinConsumeEnergy, False, "")
  ElseIf Option == "EnableHeightChangeSuccubus"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableHeightChangeSuccubus = !PSQ.EnableHeightChangeSuccubus
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableHeightChangeSuccubus, False, "")
  ElseIf Option == "EnableButtChangeSuccubus"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableButtChangeSuccubus = !PSQ.EnableButtChangeSuccubus
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableButtChangeSuccubus, False, "")
  ElseIf Option == "EnableGenitalsChangeSuccubus"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableGenitalsChangeSuccubus = !PSQ.EnableGenitalsChangeSuccubus
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableGenitalsChangeSuccubus, False, "")
  ElseIf Option == "EnableScrotumChangeSuccubus"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableScrotumChangeSuccubus = !PSQ.EnableScrotumChangeSuccubus
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableScrotumChangeSuccubus, False, "")
  ElseIf Option == "EnableSuccubusDrainHealthSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableSuccubusDrainHealthSpell = !PSQ.EnableSuccubusDrainHealthSpell
    If PSQ.EnableSuccubusDrainHealthSpell
      If SuccubusRank.GetValue() == 1.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainHealthSpell01, False)
      ElseIf SuccubusRank.GetValue() == 2.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainHealthSpell02, False)
      ElseIf SuccubusRank.GetValue() == 3.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainHealthSpell03, False)
      ElseIf SuccubusRank.GetValue() == 4.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainHealthSpell04, False)
      ElseIf SuccubusRank.GetValue() == 5.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainHealthSpell05, False)
      ElseIf SuccubusRank.GetValue() == 6.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainHealthSpell06, False)
      ElseIf SuccubusRank.GetValue() == 7.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainHealthSpell07, False)
      ElseIf SuccubusRank.GetValue() >= 8.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainHealthSpell08, False)
      EndIf
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainHealthSpell01)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainHealthSpell02)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainHealthSpell03)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainHealthSpell04)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainHealthSpell05)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainHealthSpell06)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainHealthSpell07)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainHealthSpell08)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableSuccubusDrainHealthSpell, False, "")
  ElseIf Option == "EnableSuccubusDrainStaminaSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableSuccubusDrainStaminaSpell = !PSQ.EnableSuccubusDrainStaminaSpell
    If PSQ.EnableSuccubusDrainStaminaSpell
      If SuccubusRank.GetValue() == 1.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainStaminaSpell01, False)
      ElseIf SuccubusRank.GetValue() == 2.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainStaminaSpell02, False)
      ElseIf SuccubusRank.GetValue() == 3.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainStaminaSpell03, False)
      ElseIf SuccubusRank.GetValue() == 4.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainStaminaSpell04, False)
      ElseIf SuccubusRank.GetValue() == 5.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainStaminaSpell05, False)
      ElseIf SuccubusRank.GetValue() == 6.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainStaminaSpell06, False)
      ElseIf SuccubusRank.GetValue() == 7.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainStaminaSpell07, False)
      ElseIf SuccubusRank.GetValue() >= 8.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainStaminaSpell08, False)
      EndIf
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainStaminaSpell01)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainStaminaSpell02)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainStaminaSpell03)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainStaminaSpell04)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainStaminaSpell05)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainStaminaSpell06)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainStaminaSpell07)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainStaminaSpell08)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableSuccubusDrainStaminaSpell, False, "")
  ElseIf Option == "EnableSuccubusDrainFF"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableSuccubusDrainFF = !PSQ.EnableSuccubusDrainFF
    If PSQ.EnableSuccubusDrainFF
      If SuccubusRank.GetValue() == 1.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainFF01, False)
      ElseIf SuccubusRank.GetValue() == 2.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainFF02, False)
      ElseIf SuccubusRank.GetValue() == 3.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainFF03, False)
      ElseIf SuccubusRank.GetValue() == 4.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainFF04, False)
      ElseIf SuccubusRank.GetValue() == 5.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainFF05, False)
      ElseIf SuccubusRank.GetValue() == 6.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainFF06, False)
      ElseIf SuccubusRank.GetValue() == 7.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainFF07, False)
      ElseIf SuccubusRank.GetValue() >= 8.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.SuccubusDrainFF08, False)
      EndIf
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainFF01)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainFF02)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainFF03)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainFF04)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainFF05)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainFF06)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainFF07)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.SuccubusDrainFF08)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableSuccubusDrainFF, False, "")
  ElseIf Option == "CreatePenisSpellSelf"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.CreatePenisSpellSelf, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.CreatePenisSpellSelf as Form), False, "")
  ElseIf Option == "CreatePenisSpellOther"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.CreatePenisSpellOther, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.CreatePenisSpellOther as Form), False, "")
  ElseIf Option == "SuccubusCurseSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.SuccubusCurseSpell, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.SuccubusCurseSpell as Form), False, "")
  ElseIf Option == "SuccubusSummonMerchantSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.SuccubusSummonMerchantSpell, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.SuccubusSummonMerchantSpell as Form), False, "")
  ElseIf Option == "SuccubusRaiseArousalSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.SuccubusRaiseArousalSpell, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.SuccubusRaiseArousalSpell as Form), False, "")
  ElseIf Option == "SuccubusArousalCloakSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.SuccubusArousalCloakSpell, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.SuccubusArousalCloakSpell as Form), False, "")
  ElseIf Option == "StarkRealitySpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.StarkRealitySpell, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.StarkRealitySpell as Form), False, "")
  ElseIf Option == "SuccuKanashibari"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.SuccuKanashibari, 2)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.SuccuKanashibari as Form), False, "")
  ElseIf Option == "FortifyMSGBoxSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.FortifyMSGBoxSpell, 3)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.FortifyMSGBoxSpell as Form), False, "")
  ElseIf Option == "RestoreMagickaSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.RestoreMagickaSpell, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.RestoreMagickaSpell as Form), False, "")
  ElseIf Option == "MasturbationSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.MasturbationSpell, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.MasturbationSpell as Form), False, "")
  ElseIf Option == "ImmunityToSTD"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.ImmunityToSTD, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.ImmunityToSTD as Form), False, "")
  ElseIf Option == "FortifyMagickaSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.FortifyMagickaSpell, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.FortifyMagickaSpell as Form), False, "")
  ElseIf Option == "FortifyStaminaSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.FortifyStaminaSpell, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.FortifyStaminaSpell as Form), False, "")
  ElseIf Option == "FortifyHealthSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.FortifyHealthSpell, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.FortifyHealthSpell as Form), False, "")
  ElseIf Option == "FortifyCarrySpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.FortifyCarrySpell, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.FortifyCarrySpell as Form), False, "")
  ElseIf Option == "FortifyUnarmedSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.FortifyUnarmedSpell, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.FortifyUnarmedSpell as Form), False, "")
  ElseIf Option == "SuccubusStorageSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.SuccubusStorageSpell, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.SuccubusStorageSpell as Form), False, "")
  ElseIf Option == "SuccubusSpellLearningMSGBoxSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.SuccubusSpellLearningMSGBoxSpell, 1)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.SuccubusSpellLearningMSGBoxSpell as Form), False, "")
  ElseIf Option == "FortifySneakSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSpell(PSQ.FortifySneakSpell, 1)
    If PSQ.PlayerRef.HasSpell(PSQ.FortifySneakSpell as Form)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.AddPerk(PSQ.FortifySneakPerk)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemovePerk(PSQ.FortifySneakPerk)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.FortifySneakSpell as Form), False, "")
  ElseIf False
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.PhysicalWeakness = !PSQ.PhysicalWeakness
    If PlayerIsSuccubus.GetValueInt() == 1
      If PSQ.PhysicalWeakness
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.SetActorValue("Health", PSQ.PlayerRef.GetBaseActorValue("Health") * 0.5)
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.SetActorValue("Stamina", PSQ.PlayerRef.GetBaseActorValue("Stamina") * 0.5)
      EndIf
      PSQ.Satiety(0.0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.PhysicalWeakness, False, "")
  ElseIf Option == "EnableEnergyConsumingBySuccubusSpell"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableEnergyConsumingBySuccubusSpell = !PSQ.EnableEnergyConsumingBySuccubusSpell
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableEnergyConsumingBySuccubusSpell, False, "")
  ElseIf Option == "EnableSpellCastingNotification"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableSpellCastingNotification = !PSQ.EnableSpellCastingNotification
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableSpellCastingNotification, False, "")
  ElseIf Option == "StopEnergyConsuming"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SettleTransformEnergy()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.StopEnergyConsuming = !PSQ.StopEnergyConsuming
    PSQ.ResetTransformEnergyClock()
    If PlayerIsSuccubus.GetValue() == 1.0
      If PSQ.StopEnergyConsuming
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        Float PendingAppearanceValue3 = PSQ.GameDaysPassed.GetValue() - PSQ.LastConsumeTime
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.ConsumeTimer = PendingAppearanceValue3
        PSQ.Satiety(-1.0 * PSQ.EnergyConsumption * PSQ.ConsumeTimer)
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        Float PendingAppearanceValue4 = PSQ.GameDaysPassed.GetValue()
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.LastConsumeTime = PendingAppearanceValue4
      Else
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        Float PendingAppearanceValue5 = PSQ.GameDaysPassed.GetValue()
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.LastConsumeTime = PendingAppearanceValue5
      EndIf
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.StopEnergyConsuming, False, "")
  ElseIf Option == "EnableFortifyDestruction"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableFortifyDestruction = !PSQ.EnableFortifyDestruction
    If PSQ.EnableFortifyDestruction
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.FortifyDestructionSpell.SetNthEffectMagnitude(0, 3.0 * SuccubusRank.GetValue() + Math.Sqrt(SuccubusEXP.GetValue()))
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.AddSpell(PSQ.FortifyDestructionSpell, False)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.FortifyDestructionSpell)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableFortifyDestruction, False, "")
  ElseIf Option == "EnableFortifyIllusion"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableFortifyIllusion = !PSQ.EnableFortifyIllusion
    If PSQ.EnableFortifyIllusion
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.AddPerk(PSQ.FortifyIllusionPerk)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.FortifyIllusionSpell.SetNthEffectMagnitude(0, 3.0 * SuccubusRank.GetValue() + Math.Sqrt(SuccubusEXP.GetValue()))
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.AddSpell(PSQ.FortifyIllusionSpell, False)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.FortifyIllusionSpell)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemovePerk(PSQ.FortifyIllusionPerk)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableFortifyIllusion, False, "")
  ElseIf Option == "EnableMagicResistance"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableMagicResistance = !PSQ.EnableMagicResistance
    If PSQ.EnableMagicResistance
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.MagicResistanceSpell.SetNthEffectMagnitude(0, 2.0 * SuccubusRank.GetValue() + 0.5 * Math.Sqrt(SuccubusEXP.GetValue()) + 7.0)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.AddSpell(PSQ.MagicResistanceSpell, False)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.MagicResistanceSpell)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableMagicResistance, False, "")
  ElseIf Option == "EnableFortifyBartar"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnableFortifyBartar = !PSQ.EnableFortifyBartar
    If PSQ.EnableFortifyBartar
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.AddPerk(PSQ.FortifyBartarPerk)
      If SuccubusRank.GetValue() == 1.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.FortifyBartarSpell1, False)
      ElseIf SuccubusRank.GetValue() == 2.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.FortifyBartarSpell2, False)
      ElseIf SuccubusRank.GetValue() == 3.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.FortifyBartarSpell3, False)
      ElseIf SuccubusRank.GetValue() == 4.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.FortifyBartarSpell4, False)
      ElseIf SuccubusRank.GetValue() == 5.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.FortifyBartarSpell5, False)
      ElseIf SuccubusRank.GetValue() == 6.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.FortifyBartarSpell6, False)
      ElseIf SuccubusRank.GetValue() == 7.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.FortifyBartarSpell7, False)
      ElseIf SuccubusRank.GetValue() >= 8.0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.AddSpell(PSQ.FortifyBartarSpell8, False)
      EndIf
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemovePerk(PSQ.FortifyBartarPerk)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.FortifyBartarSpell1)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.FortifyBartarSpell2)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.FortifyBartarSpell3)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.FortifyBartarSpell4)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.FortifyBartarSpell5)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.FortifyBartarSpell6)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.FortifyBartarSpell7)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.PlayerRef.RemoveSpell(PSQ.FortifyBartarSpell8)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(PSQ.EnableFortifyBartar, False, "")
  ElseIf Option == "NPCBecomeSuccubus"
    If storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformRegistered", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformRegistered", 1)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      SuccubusNPC.AddToFaction(PSQ.SuccubusNPCFaction)
      If PSQVisualRuntime
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        NiOverride.AddNodeOverrideString(SuccubusNPC as ObjectReference, True, "Face [Ovl0]", 9, 0, "Textures\\PSQ\\Overlays\\FollowerSuccubusFace_0.dds", True)
      EndIf
      If PSQVisualRuntime
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        NiOverride.AddNodeOverrideString(SuccubusNPC as ObjectReference, True, "Body [Ovl0]", 9, 0, "Textures\\PSQ\\Overlays\\FollowerSuccubusBody_0.dds", True)
      EndIf
      If PSQVisualRuntime
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        NiOverride.AddNodeOverrideString(SuccubusNPC as ObjectReference, True, "Feet [Ovl0]", 9, 0, "Textures\\PSQ\\Overlays\\FollowerSuccubusBody_0.dds", True)
      EndIf
      If PSQVisualRuntime
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        NiOverride.AddNodeOverrideString(SuccubusNPC as ObjectReference, True, "Hands [Ovl0]", 9, 0, "Textures\\PSQ\\Overlays\\FollowerSuccubusHands_0.dds", True)
      EndIf
      If PSQVisualRuntime
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        NiOverride.AddNodeOverrideFloat(SuccubusNPC as ObjectReference, True, "Face [Ovl0]", 8, -1, 0.0, True)
      EndIf
      If PSQVisualRuntime
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        NiOverride.AddNodeOverrideFloat(SuccubusNPC as ObjectReference, True, "Body [Ovl0]", 8, -1, 0.0, True)
      EndIf
      If PSQVisualRuntime
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        NiOverride.AddNodeOverrideFloat(SuccubusNPC as ObjectReference, True, "Feet [Ovl0]", 8, -1, 0.0, True)
      EndIf
      If PSQVisualRuntime
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        NiOverride.AddNodeOverrideFloat(SuccubusNPC as ObjectReference, True, "Hands [Ovl0]", 8, -1, 0.0, True)
      EndIf
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformRegistered", 0)
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      SuccubusNPC.RemoveFromFaction(PSQ.SuccubusNPCFaction)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformRegistered", 0) as Bool, False, "")
  ElseIf Option == "NPCHenshinBody"
    If storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformBody", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformBody", 1)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformBody", 0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformBody", 0) as Bool, False, "")
  ElseIf Option == "NPCHenshinSkin"
    If storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformSkin", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformSkin", 1)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformSkin", 0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformSkin", 0) as Bool, False, "")
  ElseIf Option == "NPCHenshinEyes"
    If storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformEye", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformEye", 1)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformEye", 0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformEye", 0) as Bool, False, "")
  ElseIf Option == "NPCHenshinWings"
    If storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformWings", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformWings", 1)
      If storageutil.GetFormValue(SuccubusNPC as Form, "PSQ_NPCWings", None) == None
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        storageutil.SetFormValue(SuccubusNPC as Form, "PSQ_NPCWings", PSQ.SuccubusStaticWings as Form)
      EndIf
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformWings", 0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformWings", 0) as Bool, False, "")
  ElseIf Option == "NPCHenshinHorn"
    If storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformHorns", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformHorns", 1)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformHorns", 0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformHorns", 0) as Bool, False, "")
  ElseIf Option == "NPCHenshinTail"
    If storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformTail", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformTail", 1)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformTail", 0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformTail", 0) as Bool, False, "")
  ElseIf Option == "NPCHenshinCuirass"
    If storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformCuirass", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformCuirass", 1)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformCuirass", 0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformCuirass", 0) as Bool, False, "")
  ElseIf Option == "NPCHenshinBoots"
    If storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformBoots", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformBoots", 1)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformBoots", 0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformBoots", 0) as Bool, False, "")
  ElseIf Option == "NPCHenshinGloves"
    If storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformGauntlets", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformGauntlets", 1)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformGauntlets", 0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformGauntlets", 0) as Bool, False, "")
  ElseIf Option == "NPCHenshinPenis"
    If storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformPenis", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformPenis", 1)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformPenis", 0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformPenis", 0) as Bool, False, "")
  ElseIf Option == "NPCHenshinScale"
    If storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformScale", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformScale", 1)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformScale", 0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformScale", 0) as Bool, False, "")
  ElseIf Option == "PSQ_LureEffectOnFemale"
    If storageutil.GetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnFemale", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnFemale", 1)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnFemale", 0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnFemale", 0) == 0, False, "")
  ElseIf Option == "PSQ_LureEffectOnMale"
    If storageutil.GetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnMale", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnMale", 1)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnMale", 0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnMale", 0) == 0, False, "")
  ElseIf Option == "PSQ_LureEffectOnBeast"
    If storageutil.GetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnBeast", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnBeast", 1)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnBeast", 0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnBeast", 0) == 0, False, "")
  ElseIf Option == "PSQ_LureEffectOnUndead"
    If storageutil.GetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnUndead", 0) == 0
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnUndead", 1)
    Else
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      storageutil.SetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnUndead", 0)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetToggleOptionValueST(storageutil.GetIntValue(PSQ.PlayerRef as Form, "PSQ_LureEffectOnUndead", 0) == 1, False, "")
  EndIf
EndFunction

Function HandleAppearanceOnSliderAcceptST(Float value, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = PSQ.AppearanceOperationId
    RequireBusy = PSQ.AppearanceEditBusy
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  String Option = Self.GetState()
  If Option == "RapeArousalThreshold"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.RapeArousalThreshold = value as Int
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "RapeHealthThreshold"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.RapeHealthThreshold = value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "RapeChance"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.RapeChance = value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "RestoreMagickaMAX"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.RestoreMagickaMAX = value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  ElseIf Option == "WingMaxJumpHeight"
    if !PSQ.CanControlWingflightPolicy()
      Self.SetInfoText("独立飞行模式：Wingflight／OSYRN 自身设置生效；PSQ 专有等级、自动启用和翼装跳高控制不可用。")
      return
    endif
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.WingMaxJumpHeight = value
    PSQ.UpdatePSQWingJumpHeight(True)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  ElseIf Option == "DefaultJumpHeight"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.DefaultJumpHeight = value
    PSQ.ApplyPSQDefaultJumpPreference()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  ElseIf Option == "CanFlyingLevel"
    if !PSQ.CanControlWingflightPolicy()
      Self.SetInfoText("独立飞行模式：Wingflight／OSYRN 自身设置生效；PSQ 专有等级、自动启用和翼装跳高控制不可用。")
      return
    endif
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.CanFlyingLevel = value as Int
    PSQ.SyncWingflightPolicy()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  ElseIf Option == "EnergyConsumptionPerMax"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnergyConsumptionPerMax = value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.EnergyConsumption = PSQ.MaxEnergy * PSQ.EnergyConsumptionPerMax / 100.0
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "HenshinBuffRateHealth"
    If PSQ.GetTransformBuffMode() != 2
      Return 
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinBuffRateHealth = value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
    PSQ.UpdateTransformBuff(False, -1)
  ElseIf Option == "HenshinBuffRateMagicka"
    If PSQ.GetTransformBuffMode() != 2
      Return 
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinBuffRateMagicka = value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
    PSQ.UpdateTransformBuff(False, -1)
  ElseIf Option == "HenshinBuffRateStamina"
    If PSQ.GetTransformBuffMode() != 2
      Return 
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinBuffRateStamina = value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
    PSQ.UpdateTransformBuff(False, -1)
  ElseIf Option == "HenshinBuffRateCarry"
    If PSQ.GetTransformBuffMode() != 2
      Return 
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinBuffRateCarry = value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
    PSQ.UpdateTransformBuff(False, -1)
  ElseIf Option == "SuccubusArmorMagnitude"
    If PSQ.GetTransformBuffMode() != 2
      Return 
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SuccubusArmorMagnitude = value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0}", False, "")
    PSQ.UpdateTransformBuff(False, -1)
    Self.ForcePageReset()
  ElseIf Option == "TransformThreshold"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.TransformThreshold = value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  ElseIf Option == "DeTransformThreshold"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.DeTransformThreshold = value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  ElseIf Option == "HenshinConsumeEnergy"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SettleTransformEnergy()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinConsumeEnergy = value
    PSQ.ResetTransformEnergyClock()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  ElseIf Option == "ChargeValueAuto"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.ChargeValueAuto = value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  ElseIf Option == "CumInflationIncrement"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.CumInflationIncrement = value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  ElseIf Option == "RequiredToFluid"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.RequiredToFluid = value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  ElseIf Option == "EnergyBarX"
    SEBU.EnergyBarX = value
    SEBU.UpdateEnergyBarPosition()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  ElseIf Option == "EnergyBarY"
    SEBU.EnergyBarY = value
    SEBU.UpdateEnergyBarPosition()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  ElseIf Option == "ColorChangeThreshould01"
    SEBU.ColorChangeThreshould01 = value / 100.0
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "ColorChangeThreshould02"
    SEBU.ColorChangeThreshould02 = value / 100.0
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "ColorChangeThreshould03"
    SEBU.ColorChangeThreshould03 = value / 100.0
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "SuccubusNightEyeStrength"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SuccubusNightEyeStrength = value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{2}", False, "")
  ElseIf Option == "SuccubusHeight"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SuccubusHeight = value
    If PSQ.IsHenshined
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.SetScaleSuccubus(Owner, RequireBusy)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{2}", False, "")
  ElseIf Option == "SuccubusButt"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SuccubusButt = value
    If PSQ.IsHenshined
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.SetScaleSuccubus(Owner, RequireBusy)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{2}", False, "")
  ElseIf Option == "SuccubusGenitals"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SuccubusGenitals = value
    If PSQ.IsHenshined
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.SetScaleSuccubus(Owner, RequireBusy)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{2}", False, "")
  ElseIf Option == "SuccubusScrotum"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SuccubusScrotum = value
    If PSQ.IsHenshined
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.SetScaleSuccubus(Owner, RequireBusy)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{2}", False, "")
  ElseIf Option == "HenshinSkinColorfulness"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.PSQSkinColorAlpha = value as Int
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Int PendingAppearanceValue1 = PSQ.ComposeTransformSkinColor(PSQ.PSQSkinColor, PSQ.PSQSkinColorAlpha)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.PSQSkinColor = PendingAppearanceValue1
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SyncTransformSkinColor(Owner, RequireBusy)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  ElseIf Option == "MaxEnergyAtAltMode"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.MaxEnergyAtAltMode = value
    If PSQ.EnergyModeAlt
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.MaxEnergy = value
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.EnergyConsumption = PSQ.MaxEnergy * PSQ.EnergyConsumptionPerMax / 100.0
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  ElseIf Option == "HealthBuffInc"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HealthBuffInc = value / 100.0 + PSQ.HealthBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "HealthBuffDec"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HealthBuffInc = PSQ.HealthBuffInc - value / 100.0 - PSQ.HealthBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HealthBuffDec = -value / 100.0
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "MagickaBuffInc"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.MagickaBuffInc = value / 100.0 + PSQ.MagickaBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "MagickaBuffDec"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.MagickaBuffInc = PSQ.MagickaBuffInc - value / 100.0 - PSQ.MagickaBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.MagickaBuffDec = -value / 100.0
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "StaminaBuffInc"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.StaminaBuffInc = value / 100.0 + PSQ.StaminaBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "StaminaBuffDec"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.StaminaBuffInc = PSQ.StaminaBuffInc - value / 100.0 - PSQ.StaminaBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.StaminaBuffDec = -value / 100.0
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "CarryBuffInc"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.CarryBuffInc = value / 100.0 + PSQ.CarryBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "CarryBuffDec"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.CarryBuffInc = PSQ.CarryBuffInc - value / 100.0 - PSQ.CarryBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.CarryBuffDec = -value / 100.0
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "HealthRateBuffInc"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HealthRateBuffInc = value + PSQ.HealthRateBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "HealthRateBuffDec"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HealthRateBuffInc = PSQ.HealthRateBuffInc - value - PSQ.HealthRateBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HealthRateBuffDec = -value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "MagickaRateBuffInc"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.MagickaRateBuffInc = value + PSQ.MagickaRateBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "MagickaRateBuffDec"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.MagickaRateBuffInc = PSQ.MagickaRateBuffInc - value - PSQ.MagickaRateBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.MagickaRateBuffDec = -value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "StaminaRateBuffInc"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.StaminaRateBuffInc = value + PSQ.StaminaRateBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "StaminaRateBuffDec"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.StaminaRateBuffInc = PSQ.StaminaRateBuffInc - value - PSQ.StaminaRateBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.StaminaRateBuffDec = -value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "SpeedBuffInc"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SpeedBuffInc = value + PSQ.SpeedBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "SpeedBuffDec"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SpeedBuffInc = PSQ.SpeedBuffInc - value - PSQ.SpeedBuffDec
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SpeedBuffDec = -value
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "FortifyDestructionMult"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.FortifyDestructionMult = value / 100.0
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "FortifyIllusionMult"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.FortifyIllusionMult = value / 100.0
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "MagicResistanceMult"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.MagicResistanceMult = value / 100.0
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{0} %", False, "")
  ElseIf Option == "NPCSuccubusHeight"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    storageutil.SetFloatValue(SuccubusNPC as Form, "PSQ_NPCTransformHeight", value)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{2}", False, "")
  ElseIf Option == "NPCSuccubusButt"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    storageutil.SetFloatValue(SuccubusNPC as Form, "PSQ_NPCTransformButt", value)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{2}", False, "")
  ElseIf Option == "NPCSuccubusGenitals"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    storageutil.SetFloatValue(SuccubusNPC as Form, "PSQ_NPCTransformGenitals", value)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{2}", False, "")
  ElseIf Option == "NPCSuccubusScrotum"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    storageutil.SetFloatValue(SuccubusNPC as Form, "PSQ_NPCTransformScrotum", value)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetSliderOptionValueST(value, "{2}", False, "")
  EndIf
EndFunction

Function OnColorOpenST()
  String Option = Self.GetState()
  If Option == "PSQSkinColor"
    Self.SetColorDialogStartColor(PSQ.PSQSkinColor)
    Self.SetColorDialogDefaultColor(PSQ.PSQSkinColor)
  ElseIf Option == "PSQSuccubusHairColorInt"
    Self.SetColorDialogStartColor(PSQ.PSQSuccubusHairColorInt)
    Self.SetColorDialogDefaultColor(PSQ.PSQSuccubusHairColorInt)
  ElseIf Option == "EnergyBarColor1A"
    Self.SetColorDialogStartColor(SEBU.EnergyBarColor1A)
    Self.SetColorDialogDefaultColor(SEBU.EnergyBarColor1A)
  ElseIf Option == "EnergyBarColor1B"
    Self.SetColorDialogStartColor(SEBU.EnergyBarColor1B)
    Self.SetColorDialogDefaultColor(SEBU.EnergyBarColor1B)
  ElseIf Option == "EnergyBarColor2A"
    Self.SetColorDialogStartColor(SEBU.EnergyBarColor2A)
    Self.SetColorDialogDefaultColor(SEBU.EnergyBarColor2A)
  ElseIf Option == "EnergyBarColor2B"
    Self.SetColorDialogStartColor(SEBU.EnergyBarColor2B)
    Self.SetColorDialogDefaultColor(SEBU.EnergyBarColor2B)
  ElseIf Option == "EnergyBarColor3A"
    Self.SetColorDialogStartColor(SEBU.EnergyBarColor3A)
    Self.SetColorDialogDefaultColor(SEBU.EnergyBarColor3A)
  ElseIf Option == "EnergyBarColor3B"
    Self.SetColorDialogStartColor(SEBU.EnergyBarColor3B)
    Self.SetColorDialogDefaultColor(SEBU.EnergyBarColor3B)
  ElseIf Option == "EnergyBarColor4A"
    Self.SetColorDialogStartColor(SEBU.EnergyBarColor4A)
    Self.SetColorDialogDefaultColor(SEBU.EnergyBarColor4A)
  ElseIf Option == "EnergyBarColor4B"
    Self.SetColorDialogStartColor(SEBU.EnergyBarColor4B)
    Self.SetColorDialogDefaultColor(SEBU.EnergyBarColor4B)
  ElseIf Option == "NPCPSQSkinColor"
    Self.SetColorDialogStartColor(storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformSkinColor", 0))
    Self.SetColorDialogDefaultColor(storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformSkinColor", 0))
  EndIf
EndFunction

Function HandleAppearanceOnColorAcceptST(Int Color, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = PSQ.AppearanceOperationId
    RequireBusy = PSQ.AppearanceEditBusy
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  Bool PSQVisualRuntime = skse.GetPluginVersion("skee") >= 0 || skse.GetPluginVersion("NiOverride") >= 0
  String Option = Self.GetState()
  If Option == "PSQSkinColor"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Int PendingAppearanceValue1 = PSQ.ComposeTransformSkinColor(Color, PSQ.PSQSkinColorAlpha)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.PSQSkinColor = PendingAppearanceValue1
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SyncTransformSkinColor(Owner, RequireBusy)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetColorOptionValueST(Color, False, "")
  ElseIf Option == "PSQSuccubusHairColorInt"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.PSQSuccubusHairColorInt = Color
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SyncTransformHairColor(Owner, RequireBusy)
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetColorOptionValueST(Color, False, "")
  ElseIf Option == "EnergyBarColor1A"
    SEBU.EnergyBarColor1A = Color
    SEBU.UpdateEnergyBarPosition()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetColorOptionValueST(Color, False, "")
  ElseIf Option == "EnergyBarColor1B"
    SEBU.EnergyBarColor1B = Color
    SEBU.UpdateEnergyBarPosition()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetColorOptionValueST(Color, False, "")
  ElseIf Option == "EnergyBarColor2A"
    SEBU.EnergyBarColor2A = Color
    SEBU.UpdateEnergyBarPosition()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetColorOptionValueST(Color, False, "")
  ElseIf Option == "EnergyBarColor2B"
    SEBU.EnergyBarColor2B = Color
    SEBU.UpdateEnergyBarPosition()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetColorOptionValueST(Color, False, "")
  ElseIf Option == "EnergyBarColor3A"
    SEBU.EnergyBarColor3A = Color
    SEBU.UpdateEnergyBarPosition()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetColorOptionValueST(Color, False, "")
  ElseIf Option == "EnergyBarColor3B"
    SEBU.EnergyBarColor3B = Color
    SEBU.UpdateEnergyBarPosition()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetColorOptionValueST(Color, False, "")
  ElseIf Option == "EnergyBarColor4A"
    SEBU.EnergyBarColor4A = Color
    SEBU.UpdateEnergyBarPosition()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetColorOptionValueST(Color, False, "")
  ElseIf Option == "EnergyBarColor4B"
    SEBU.EnergyBarColor4B = Color
    SEBU.UpdateEnergyBarPosition()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetColorOptionValueST(Color, False, "")
  ElseIf Option == "NPCPSQSkinColor"
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformSkinColor", Color)
    If PSQVisualRuntime
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      NiOverride.AddNodeOverrideInt(SuccubusNPC as ObjectReference, True, "Face [Ovl0]", 7, -1, Color, True)
    EndIf
    If PSQVisualRuntime
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      NiOverride.AddNodeOverrideInt(SuccubusNPC as ObjectReference, True, "Body [Ovl0]", 7, -1, Color, True)
    EndIf
    If PSQVisualRuntime
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      NiOverride.AddNodeOverrideInt(SuccubusNPC as ObjectReference, True, "Feet [Ovl0]", 7, -1, Color, True)
    EndIf
    If PSQVisualRuntime
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      NiOverride.AddNodeOverrideInt(SuccubusNPC as ObjectReference, True, "Hands [Ovl0]", 7, -1, Color, True)
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetColorOptionValueST(Color, False, "")
  EndIf
EndFunction

Function OnKeyMapChangeST(Int KeyCode, String ConflictControl, String ConflictName)
  String Option = Self.GetState()
  If Option == "HotkeyEnableDrain"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyEnableDrain = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyEnableDrain, False, "")
    EndIf
  ElseIf Option == "HotkeyAllowKill"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyAllowKill = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyAllowKill, False, "")
    EndIf
  ElseIf Option == "HotkeyHenshin"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyHenshin = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyHenshin, False, "")
    EndIf
  ElseIf Option == "HotkeySuccubusStats"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeySuccubusStats = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeySuccubusStats, False, "")
    EndIf
  ElseIf Option == "HotkeySuccubusCharmSpell"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeySuccubusCharmSpell = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeySuccubusCharmSpell, False, "")
    EndIf
  ElseIf Option == "HotkeyMasturbation"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyMasturbation = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyMasturbation, False, "")
    EndIf
  ElseIf Option == "HotkeyRestoreMagicka"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyRestoreMagicka = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyRestoreMagicka, False, "")
    EndIf
  ElseIf Option == "HotkeyExtractSemenPotion"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyExtractSemenPotion = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyExtractSemenPotion, False, "")
    EndIf
  ElseIf Option == "HotkeyEnableSoulTrap"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyEnableSoulTrap = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyEnableSoulTrap, False, "")
    EndIf
  ElseIf Option == "HotkeyCreatePenisSelf"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyCreatePenisSelf = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyCreatePenisSelf, False, "")
    EndIf
  ElseIf Option == "HotkeyEnergyBar"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyEnergyBar = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyEnergyBar, False, "")
    EndIf
  ElseIf Option == "HotkeyNightEye"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyNightEye = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyNightEye, False, "")
    EndIf
  ElseIf Option == "HotkeyDetectArousal"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyDetectArousal = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyDetectArousal, False, "")
    EndIf
  ElseIf Option == "HotkeyIncreaseNode"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyIncreaseNode = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyIncreaseNode, False, "")
    EndIf
  ElseIf Option == "HotkeyDecreaseNode"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyDecreaseNode = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyDecreaseNode, False, "")
    EndIf
  ElseIf Option == "HotkeyHeight"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyHeight = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyHeight, False, "")
    EndIf
  ElseIf Option == "HotkeyButtNode"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyButtNode = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyButtNode, False, "")
    EndIf
  ElseIf Option == "HotkeyGenitalsNode"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyGenitalsNode = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyGenitalsNode, False, "")
    EndIf
  ElseIf Option == "HotkeyScrotumNode"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyScrotumNode = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyScrotumNode, False, "")
    EndIf
  ElseIf Option == "HotkeyDigestion"
    If !Self.KeyConflict(KeyCode, ConflictControl, ConflictName)
      PSQ.HotkeyDigestion = KeyCode
      Self.SetKeyMapOptionValueST(PSQ.HotkeyDigestion, False, "")
    EndIf
  EndIf
  PSQ.ReloadHotkeys()
EndFunction

Function OnGameReload()
  Parent.OnGameReload()
  MCMReloadPending = True
  MCMRegistrationAttempts = 0
  Self.RegisterForSingleUpdate(2.0)
EndFunction

Function OnConfigRegister()
  MCMRegistrationConfirmed = True
  Debug.Trace("[PSQ-MCM] registration confirmed", 0)
EndFunction

Event OnUpdate()
  MCMRegistrationAttempts += 1
  Form Manager = Game.GetFormFromFile(2050, "SkyUI_SE.esp")
  If Manager != None
    Parent.OnConfigManagerReady("SKICP_configManagerReady", "", 0.0, Manager)
  EndIf
  If !MCMRegistrationConfirmed && MCMRegistrationAttempts < 6
    Self.RegisterForSingleUpdate(5.0)
  ElseIf !MCMRegistrationConfirmed
    Debug.Trace("[PSQ-MCM] registration not confirmed after 6 attempts; awaiting normal SkyUI ready event", 1)
  EndIf
  If MCMReloadPending
    MCMReloadPending = False
    If PSQ != None
      PSQ.PSQReload()
    EndIf
  EndIf
EndEvent

Function SetSpell(Spell akSpell, Int ReqRank)
  If PlayerIsSuccubus.GetValueInt() == 1
    If PSQ.PlayerRef.HasSpell(akSpell as Form)
      PSQ.PlayerRef.RemoveSpell(akSpell)
    ElseIf SuccubusRank.GetValueInt() >= ReqRank
      PSQ.PlayerRef.AddSpell(akSpell, False)
    EndIf
  EndIf
EndFunction

String Function GetTitle()
  If SuccubusRank.GetValue() == 1.0
    Return "$PSQ_RankAndTitle1"
  ElseIf SuccubusRank.GetValue() == 2.0
    Return "$PSQ_RankAndTitle2"
  ElseIf SuccubusRank.GetValue() == 3.0
    Return "$PSQ_RankAndTitle3"
  ElseIf SuccubusRank.GetValue() == 4.0
    Return "$PSQ_RankAndTitle4"
  ElseIf SuccubusRank.GetValue() == 5.0
    Return "$PSQ_RankAndTitle5"
  ElseIf SuccubusRank.GetValue() == 6.0
    Return "$PSQ_RankAndTitle6"
  ElseIf SuccubusRank.GetValue() == 7.0
    Return "$PSQ_RankAndTitle7"
  ElseIf SuccubusRank.GetValue() == 8.0
    Return "$PSQ_RankAndTitle8"
  ElseIf SuccubusRank.GetValue() == 9.0
    Return "$PSQ_RankAndTitle9"
  ElseIf SuccubusRank.GetValue() >= 10.0
    Return "$PSQ_RankAndTitle10"
  EndIf
  Return ""
EndFunction

String Function GetConditionalString(Int Cond)
  If Cond == 0
    Return "$PSQ_Unconditional"
  ElseIf Cond == 1
    Return "$PSQ_WhenAggressor"
  ElseIf Cond == 2
    Return "$PSQ_WhenVictim"
  ElseIf Cond == 3
    Return "$PSQ_WhenBoth"
  EndIf
  Return ""
EndFunction

Float Function GetNextExp()
  If SuccubusRank.GetValue() == 1.0
    Return 1000.0
  ElseIf SuccubusRank.GetValue() == 2.0
    Return 5000.0
  ElseIf SuccubusRank.GetValue() == 3.0
    Return 10000.0
  ElseIf SuccubusRank.GetValue() == 4.0
    Return 25000.0
  ElseIf SuccubusRank.GetValue() == 5.0
    Return 50000.0
  ElseIf SuccubusRank.GetValue() == 6.0
    Return 100000.0
  ElseIf SuccubusRank.GetValue() == 7.0
    Return 200000.0
  ElseIf SuccubusRank.GetValue() == 8.0
    Return 400000.0
  ElseIf SuccubusRank.GetValue() == 9.0
    Return 800000.0
  ElseIf SuccubusRank.GetValue() >= 10.0
    Return 0.0
  EndIf
  Return 0.0
EndFunction

String Function GetBecomeSuccubusStrings()
  If PSQ.AlternateStartBecomePending
    Return "$PSQ_LALActivationPending"
  EndIf
  If PlayerIsSuccubus.GetValue() == 0.0
    Return "$PSQ_BecomeSuccubus"
  ElseIf PlayerIsSuccubus.GetValue() == 1.0
    Return "$PSQ_QuitSuccubus"
  EndIf
  Return ""
EndFunction

Bool Function KeyConflict(Int KeyCode, String ConflictControl, String ConflictName)
  Bool Continue = True
  If ConflictControl != ""
    String Msg
    If ConflictName != ""
      Msg = "This key is already mapped to: \n'" + ConflictControl + "'\n(" + ConflictName + ")\n\nAre you sure you want to continue?"
    Else
      Msg = "This key is already mapped to: \n'" + ConflictControl + "'\n\nAre you sure you want to continue?"
    EndIf
    Continue = Self.ShowMessage(Msg, True, "$Yes", "$No")
  EndIf
  Return !Continue
EndFunction

Function OnSliderAcceptST(Float value)
  Bool Guard = Self.IsPlayerAppearanceSetting(Self.GetState())
  If Guard && !PSQ.BeginAppearanceEdit()
    Return 
  EndIf
  Int MenuAppearanceOwner = PSQ.AppearanceOperationId
  If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, Guard)
    Return 
  EndIf
  Self.HandleAppearanceOnSliderAcceptST(value, MenuAppearanceOwner, Guard)
  String ContinuousSlider = Self.GetState()
  If PSQ.GetContinuousAbilityMode() == 2 && (ContinuousSlider == "FortifyDestructionMult" || ContinuousSlider == "FortifyIllusionMult" || ContinuousSlider == "MagicResistanceMult")
    PSQ.SyncContinuousAbilities(True)
  EndIf
  If Guard
    PSQ.EndAppearanceEdit(MenuAppearanceOwner)
  EndIf
EndFunction

Function OnSliderOpenST()
  String Option = Self.GetState()
  If Option == "RapeArousalThreshold"
    Self.SetSliderDialogStartValue(PSQ.RapeArousalThreshold as Float)
    Self.SetSliderDialogDefaultValue(100.0)
    Self.SetSliderDialogRange(0.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "RapeHealthThreshold"
    Self.SetSliderDialogStartValue(PSQ.RapeHealthThreshold)
    Self.SetSliderDialogDefaultValue(100.0)
    Self.SetSliderDialogRange(0.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "RapeChance"
    Self.SetSliderDialogStartValue(PSQ.RapeChance)
    Self.SetSliderDialogDefaultValue(100.0)
    Self.SetSliderDialogRange(0.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "RestoreMagickaMAX"
    Self.SetSliderDialogStartValue(PSQ.RestoreMagickaMAX)
    Self.SetSliderDialogDefaultValue(100.0)
    Self.SetSliderDialogRange(0.0, 3000.0)
    Self.SetSliderDialogInterval(10.0)
  ElseIf Option == "WingMaxJumpHeight"
    if !PSQ.CanControlWingflightPolicy()
      Self.SetInfoText("独立飞行模式：Wingflight／OSYRN 自身设置生效；PSQ 专有等级、自动启用和翼装跳高控制不可用。")
      return
    endif
    Self.SetSliderDialogStartValue(PSQ.WingMaxJumpHeight)
    Self.SetSliderDialogDefaultValue(300.0)
    Self.SetSliderDialogRange(80.0, 2000.0)
    Self.SetSliderDialogInterval(20.0)
  ElseIf Option == "DefaultJumpHeight"
    Self.SetSliderDialogStartValue(PSQ.DefaultJumpHeight)
    Self.SetSliderDialogDefaultValue(76.0)
    Self.SetSliderDialogRange(0.0, 200.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "EnergyConsumptionPerMax"
    Self.SetSliderDialogStartValue(PSQ.EnergyConsumptionPerMax)
    Self.SetSliderDialogDefaultValue(14.0)
    Self.SetSliderDialogRange(0.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "CanFlyingLevel"
    if !PSQ.CanControlWingflightPolicy()
      Self.SetInfoText("独立飞行模式：Wingflight／OSYRN 自身设置生效；PSQ 专有等级、自动启用和翼装跳高控制不可用。")
      return
    endif
    Self.SetSliderDialogStartValue(PSQ.CanFlyingLevel as Float)
    Self.SetSliderDialogDefaultValue(4.0)
    Self.SetSliderDialogRange(1.0, 8.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "HenshinBuffRateHealth"
    If PSQ.GetTransformBuffMode() != 2
      Return 
    EndIf
    Self.SetSliderDialogStartValue(PSQ.HenshinBuffRateHealth)
    Self.SetSliderDialogDefaultValue(50.0)
    Self.SetSliderDialogRange(0.0, 200.0)
    Self.SetSliderDialogInterval(5.0)
  ElseIf Option == "HenshinBuffRateMagicka"
    If PSQ.GetTransformBuffMode() != 2
      Return 
    EndIf
    Self.SetSliderDialogStartValue(PSQ.HenshinBuffRateMagicka)
    Self.SetSliderDialogDefaultValue(50.0)
    Self.SetSliderDialogRange(0.0, 200.0)
    Self.SetSliderDialogInterval(5.0)
  ElseIf Option == "HenshinBuffRateStamina"
    If PSQ.GetTransformBuffMode() != 2
      Return 
    EndIf
    Self.SetSliderDialogStartValue(PSQ.HenshinBuffRateStamina)
    Self.SetSliderDialogDefaultValue(50.0)
    Self.SetSliderDialogRange(0.0, 200.0)
    Self.SetSliderDialogInterval(5.0)
  ElseIf Option == "HenshinBuffRateCarry"
    If PSQ.GetTransformBuffMode() != 2
      Return 
    EndIf
    Self.SetSliderDialogStartValue(PSQ.HenshinBuffRateCarry)
    Self.SetSliderDialogDefaultValue(50.0)
    Self.SetSliderDialogRange(0.0, 200.0)
    Self.SetSliderDialogInterval(5.0)
  ElseIf Option == "SuccubusArmorMagnitude"
    If PSQ.GetTransformBuffMode() != 2
      Return 
    EndIf
    Self.SetSliderDialogStartValue(PSQ.SuccubusArmorMagnitude)
    Self.SetSliderDialogDefaultValue(50.0)
    Self.SetSliderDialogRange(0.0, 500.0)
    Self.SetSliderDialogInterval(5.0)
  ElseIf Option == "CumInflationIncrement"
    Self.SetSliderDialogStartValue(PSQ.CumInflationIncrement)
    Self.SetSliderDialogDefaultValue(15.0)
    Self.SetSliderDialogRange(1.0, 200.0)
    Self.SetSliderDialogInterval(5.0)
  ElseIf Option == "RequiredToFluid"
    Self.SetSliderDialogStartValue(PSQ.RequiredToFluid)
    Self.SetSliderDialogDefaultValue(30.0)
    Self.SetSliderDialogRange(0.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "TransformThreshold"
    Self.SetSliderDialogStartValue(PSQ.TransformThreshold)
    Self.SetSliderDialogDefaultValue(100.0)
    Self.SetSliderDialogRange(0.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "DeTransformThreshold"
    Self.SetSliderDialogStartValue(PSQ.DeTransformThreshold)
    Self.SetSliderDialogDefaultValue(20.0)
    Self.SetSliderDialogRange(0.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "HenshinConsumeEnergy"
    Self.SetSliderDialogStartValue(PSQ.HenshinConsumeEnergy)
    Self.SetSliderDialogDefaultValue(1.0)
    Self.SetSliderDialogRange(0.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "ChargeValueAuto"
    Self.SetSliderDialogStartValue(PSQ.ChargeValueAuto)
    Self.SetSliderDialogDefaultValue(1000.0)
    Self.SetSliderDialogRange(0.0, 10000.0)
    Self.SetSliderDialogInterval(500.0)
  ElseIf Option == "EnergyBarX"
    Self.SetSliderDialogStartValue(SEBU.EnergyBarX)
    Self.SetSliderDialogDefaultValue(495.0)
    Self.SetSliderDialogRange(0.0, 1280.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "EnergyBarY"
    Self.SetSliderDialogStartValue(SEBU.EnergyBarY)
    Self.SetSliderDialogDefaultValue(700.0)
    Self.SetSliderDialogRange(0.0, 720.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "ColorChangeThreshould01"
    Self.SetSliderDialogStartValue(SEBU.ColorChangeThreshould01 * 100.0)
    Self.SetSliderDialogDefaultValue(85.0)
    Self.SetSliderDialogRange(0.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "ColorChangeThreshould02"
    Self.SetSliderDialogStartValue(SEBU.ColorChangeThreshould02 * 100.0)
    Self.SetSliderDialogDefaultValue(85.0)
    Self.SetSliderDialogRange(0.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "ColorChangeThreshould03"
    Self.SetSliderDialogStartValue(SEBU.ColorChangeThreshould03 * 100.0)
    Self.SetSliderDialogDefaultValue(85.0)
    Self.SetSliderDialogRange(0.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "SuccubusNightEyeStrength"
    Self.SetSliderDialogStartValue(PSQ.SuccubusNightEyeStrength)
    Self.SetSliderDialogDefaultValue(0.5)
    Self.SetSliderDialogRange(0.0, 1.0)
    Self.SetSliderDialogInterval(0.01)
  ElseIf Option == "SuccubusHeight"
    Self.SetSliderDialogStartValue(PSQ.SuccubusHeight)
    Self.SetSliderDialogDefaultValue(1.0)
    Self.SetSliderDialogRange(0.01, 6.0)
    Self.SetSliderDialogInterval(0.01)
  ElseIf Option == "SuccubusButt"
    Self.SetSliderDialogStartValue(PSQ.SuccubusButt)
    Self.SetSliderDialogDefaultValue(2.0)
    Self.SetSliderDialogRange(0.01, 4.0)
    Self.SetSliderDialogInterval(0.01)
  ElseIf Option == "SuccubusGenitals"
    Self.SetSliderDialogStartValue(PSQ.SuccubusGenitals)
    Self.SetSliderDialogDefaultValue(2.0)
    Self.SetSliderDialogRange(0.01, 6.0)
    Self.SetSliderDialogInterval(0.01)
  ElseIf Option == "SuccubusScrotum"
    Self.SetSliderDialogStartValue(PSQ.SuccubusScrotum)
    Self.SetSliderDialogDefaultValue(2.0)
    Self.SetSliderDialogRange(0.01, 6.0)
    Self.SetSliderDialogInterval(0.01)
  ElseIf Option == "HenshinSkinColorfulness"
    Self.SetSliderDialogStartValue(PSQ.PSQSkinColorAlpha as Float)
    Self.SetSliderDialogDefaultValue(255.0)
    Self.SetSliderDialogRange(0.0, 255.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "MaxEnergyAtAltMode"
    Self.SetSliderDialogStartValue(PSQ.MaxEnergyAtAltMode)
    Self.SetSliderDialogDefaultValue(1000.0)
    Self.SetSliderDialogRange(100.0, 5000.0)
    Self.SetSliderDialogInterval(50.0)
  ElseIf Option == "HealthBuffInc"
    Self.SetSliderDialogStartValue((PSQ.HealthBuffInc - PSQ.HealthBuffDec) * 100.0)
    Self.SetSliderDialogDefaultValue(40.0)
    Self.SetSliderDialogRange(-100.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "HealthBuffDec"
    Self.SetSliderDialogStartValue(-PSQ.HealthBuffDec * 100.0)
    Self.SetSliderDialogDefaultValue(-20.0)
    Self.SetSliderDialogRange(-100.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "MagickaBuffInc"
    Self.SetSliderDialogStartValue((PSQ.MagickaBuffInc - PSQ.MagickaBuffDec) * 100.0)
    Self.SetSliderDialogDefaultValue(40.0)
    Self.SetSliderDialogRange(-100.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "MagickaBuffDec"
    Self.SetSliderDialogStartValue(-PSQ.MagickaBuffDec * 100.0)
    Self.SetSliderDialogDefaultValue(-20.0)
    Self.SetSliderDialogRange(-100.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "StaminaBuffInc"
    Self.SetSliderDialogStartValue((PSQ.StaminaBuffInc - PSQ.StaminaBuffDec) * 100.0)
    Self.SetSliderDialogDefaultValue(40.0)
    Self.SetSliderDialogRange(-100.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "StaminaBuffDec"
    Self.SetSliderDialogStartValue(-PSQ.StaminaBuffDec * 100.0)
    Self.SetSliderDialogDefaultValue(-20.0)
    Self.SetSliderDialogRange(-100.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "CarryBuffInc"
    Self.SetSliderDialogStartValue((PSQ.CarryBuffInc - PSQ.CarryBuffDec) * 100.0)
    Self.SetSliderDialogDefaultValue(40.0)
    Self.SetSliderDialogRange(-100.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "CarryBuffDec"
    Self.SetSliderDialogStartValue(-PSQ.CarryBuffDec * 100.0)
    Self.SetSliderDialogDefaultValue(-20.0)
    Self.SetSliderDialogRange(-100.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "HealthRateBuffInc"
    Self.SetSliderDialogStartValue(PSQ.HealthRateBuffInc - PSQ.HealthRateBuffDec)
    Self.SetSliderDialogDefaultValue(100.0)
    Self.SetSliderDialogRange(-200.0, 200.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "HealthRateBuffDec"
    Self.SetSliderDialogStartValue(-PSQ.HealthRateBuffDec)
    Self.SetSliderDialogDefaultValue(-100.0)
    Self.SetSliderDialogRange(-200.0, 200.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "MagickaRateBuffInc"
    Self.SetSliderDialogStartValue(PSQ.MagickaRateBuffInc - PSQ.MagickaRateBuffDec)
    Self.SetSliderDialogDefaultValue(100.0)
    Self.SetSliderDialogRange(-200.0, 200.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "MagickaRateBuffDec"
    Self.SetSliderDialogStartValue(-PSQ.MagickaRateBuffDec)
    Self.SetSliderDialogDefaultValue(-100.0)
    Self.SetSliderDialogRange(-200.0, 200.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "StaminaRateBuffInc"
    Self.SetSliderDialogStartValue(PSQ.StaminaRateBuffInc - PSQ.StaminaRateBuffDec)
    Self.SetSliderDialogDefaultValue(100.0)
    Self.SetSliderDialogRange(-200.0, 200.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "StaminaRateBuffDec"
    Self.SetSliderDialogStartValue(-PSQ.StaminaRateBuffDec)
    Self.SetSliderDialogDefaultValue(-100.0)
    Self.SetSliderDialogRange(-200.0, 200.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "SpeedBuffInc"
    Self.SetSliderDialogStartValue(PSQ.SpeedBuffInc - PSQ.SpeedBuffDec)
    Self.SetSliderDialogDefaultValue(40.0)
    Self.SetSliderDialogRange(-100.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "SpeedBuffDec"
    Self.SetSliderDialogStartValue(-PSQ.SpeedBuffDec)
    Self.SetSliderDialogDefaultValue(-20.0)
    Self.SetSliderDialogRange(-100.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "FortifyDestructionMult"
    Self.SetSliderDialogStartValue(PSQ.FortifyDestructionMult * 100.0)
    Self.SetSliderDialogDefaultValue(100.0)
    Self.SetSliderDialogRange(0.0, 200.0)
  ElseIf Option == "FortifyIllusionMult"
    Self.SetSliderDialogStartValue(PSQ.FortifyIllusionMult * 100.0)
    Self.SetSliderDialogDefaultValue(100.0)
    Self.SetSliderDialogRange(0.0, 200.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "MagicResistanceMult"
    Self.SetSliderDialogStartValue(PSQ.MagicResistanceMult * 100.0)
    Self.SetSliderDialogDefaultValue(100.0)
    Self.SetSliderDialogRange(0.0, 200.0)
    Self.SetSliderDialogInterval(1.0)
  ElseIf Option == "NPCSuccubusHeight"
    Self.SetSliderDialogStartValue(storageutil.GetFloatValue(SuccubusNPC as Form, "PSQ_NPCTransformHeight", 0.0))
    Self.SetSliderDialogDefaultValue(2.0)
    Self.SetSliderDialogRange(0.01, 5.0)
    Self.SetSliderDialogInterval(0.01)
  ElseIf Option == "NPCSuccubusButt"
    Self.SetSliderDialogStartValue(storageutil.GetFloatValue(SuccubusNPC as Form, "PSQ_NPCTransformButt", 0.0))
    Self.SetSliderDialogDefaultValue(2.0)
    Self.SetSliderDialogRange(0.01, 5.0)
    Self.SetSliderDialogInterval(0.01)
  ElseIf Option == "NPCSuccubusGenitals"
    Self.SetSliderDialogStartValue(storageutil.GetFloatValue(SuccubusNPC as Form, "PSQ_NPCTransformGenitals", 0.0))
    Self.SetSliderDialogDefaultValue(2.0)
    Self.SetSliderDialogRange(0.01, 5.0)
    Self.SetSliderDialogInterval(0.01)
  ElseIf Option == "NPCSuccubusScrotum"
    Self.SetSliderDialogStartValue(storageutil.GetFloatValue(SuccubusNPC as Form, "PSQ_NPCTransformScrotum", 0.0))
    Self.SetSliderDialogDefaultValue(2.0)
    Self.SetSliderDialogRange(0.01, 5.0)
    Self.SetSliderDialogInterval(0.01)
  EndIf
EndFunction

Function OnSelectST()
  Int ContinuousIndex = Self.GetContinuousOptionIndex(Self.GetState())
  If ContinuousIndex >= 0
    If PSQ.GetContinuousAbilityMode() == 2
      PSQ.ToggleManualContinuousOption(ContinuousIndex)
      Self.ForcePageReset()
    EndIf
    Return 
  EndIf
  Bool Guard = Self.IsPlayerAppearanceSetting(Self.GetState())
  If Guard && !PSQ.BeginAppearanceEdit()
    Return 
  EndIf
  Int MenuAppearanceOwner = PSQ.AppearanceOperationId
  If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, Guard)
    Return 
  EndIf
  Self.HandleAppearanceOnSelectST(MenuAppearanceOwner, Guard)
  If Guard
    PSQ.EndAppearanceEdit(MenuAppearanceOwner)
  EndIf
EndFunction

Function ExchangeDragonSoul()
  If DragonSoulExchangeMode < 1 || DragonSoulExchangeMode > 2
    Return 
  EndIf
  Actor player = Game.GetPlayer()
  If !PSQ || !PSQ.PlayerIsSuccubus || !PSQ.SuccubusEnergy
    Self.ShowMessage("$PSQ_DragonSoulUnavailable", False, "$OK", "$Cancel")
    Return 
  EndIf
  If PSQ.PlayerIsSuccubus.GetValueInt() != 1 || PSQ.MaxEnergy <= 0.0
    Self.ShowMessage("$PSQ_DragonSoulUnavailable", False, "$OK", "$Cancel")
    Return 
  EndIf
  If player.GetActorValue("DragonSouls") < 1.0
    Self.ShowMessage("$PSQ_DragonSoulMissing", False, "$OK", "$Cancel")
    Return 
  EndIf
  If DragonSoulExchangeMode == 2 && Game.GetPerkPoints() >= 255
    Self.ShowMessage("$PSQ_DragonSoulPerkLimit", False, "$OK", "$Cancel")
    Return 
  EndIf
  player.ModActorValue("DragonSouls", -1.0)
  If DragonSoulExchangeMode == 2
    Game.ModPerkPoints(1)
    PSQ.SuccubusEXP.SetValue(PSQ.SuccubusEXP.GetValue() + 10.0)
    PSQ.SuccubusLevelUp(0.0)
  EndIf
  PSQ.Satiety(PSQ.MaxEnergy * 0.5)
  If DragonSoulExchangeMode == 1
    Self.ShowMessage("$PSQ_DragonSoulEnergySuccess", False, "$OK", "$Cancel")
  Else
    Self.ShowMessage("$PSQ_DragonSoulSuccess", False, "$OK", "$Cancel")
  EndIf
EndFunction

String[] Function GetSuccubusTattooNames()
  String[] Options = new String[19]
  Options[0] = "$PSQ_EvolvingTattoo"
  Options[1] = "淫纹01_肉壶"
  Options[2] = "淫纹02_恶魔"
  Options[3] = "淫纹03_便器"
  Options[4] = "淫纹04_欲望"
  Options[5] = "淫纹05_公主"
  Options[6] = "淫纹06_榨取"
  Options[7] = "淫纹07_雌豚"
  Options[8] = "淫纹08_恶堕"
  Options[9] = "$PSQ_RankTattoo1"
  Options[10] = "$PSQ_RankTattoo2"
  Options[11] = "$PSQ_RankTattoo3"
  Options[12] = "$PSQ_RankTattoo4"
  Options[13] = "$PSQ_RankTattoo5"
  Options[14] = "$PSQ_RankTattoo6"
  Options[15] = "$PSQ_RankTattoo7"
  Options[16] = "$PSQ_RankTattoo8"
  Options[17] = "$PSQ_RankTattoo9"
  Options[18] = "$PSQ_RankTattoo10"
  Return Options
EndFunction

Int Function GetSuccubusTattooSelection()
  If PSQ.SuccubusTattooSelection < 0 || PSQ.SuccubusTattooSelection > 18
    Return 0
  EndIf
  Return PSQ.SuccubusTattooSelection
EndFunction

String Function GetSelectedSuccubusTattooName()
  String[] Options = Self.GetSuccubusTattooNames()
  Return Options[Self.GetSuccubusTattooSelection()]
EndFunction

String Function GetSelectedEyeMaterialMenuName()
  Int Count = PSQ.GetSuccubusEyeMaterialCount()
  If !PSQ.HenshinEyes
    Return "$PSQ_EyeNoChange"
  EndIf
  Return PSQ.GetSuccubusEyeMaterialName(PSQ.SuccubusEyeMaterialSelection)
EndFunction

Bool Function CompatibilityPluginLoaded(String Plugin)
  Return PSQ.IsIntegrationPluginLoaded(Plugin)
EndFunction

Function CompatibilityRow(String Label, Bool Present)
  String Status = "$PSQ_CompatMissing"
  If Present
    Status = "$PSQ_CompatPresent"
  EndIf
  Self.AddTextOption(Label, Status, 1)
EndFunction

Function DrawCompatibilityPage()
  Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
  Self.SetCursorPosition(0)
  Self.AddHeaderOption("$PSQ_CompatCore", 0)
  Self.CompatibilityRow("SexLab Framework", Self.CompatibilityPluginLoaded("SexLab.esm"))
  Self.AddTextOption("当前互动框架", PSQ.GetSexLabFrameworkStatus(), 1)
  Self.AddTextOptionST("FrameworkSwitchInfo", "框架切换说明", "查看", 0)
  Self.AddMenuOptionST("ArousalBackend", "欲望框架选择", Self.GetArousalModeLabel(), 0)
  Self.AddTextOption("当前欲望框架", psqarousalruntime.GetBackendName(), 1)
  Self.AddTextOptionST("ArousalCapabilities", "欲望接入能力", psqarousalruntime.GetCapabilityText(), 0)
  Self.CompatibilityRow("Heels Sound", Self.CompatibilityPluginLoaded("Heels Sound.esm"))
  Self.CompatibilityRow("SKSE64", skse.GetVersion() > 0)
  Self.CompatibilityRow("眷属眼睛材质：Papyrus Extender", PSQ.CanUseSuccubusThrallEyes())
  Self.CompatibilityRow("SkyUI", Self.CompatibilityPluginLoaded("SkyUI_SE.esp"))
  Self.CompatibilityRow("PapyrusUtil", skse.GetPluginVersion("papyrusutil plugin") >= 0 || skse.GetPluginVersion("PapyrusUtil") >= 0)
  Self.CompatibilityRow("RaceMenu", Self.CompatibilityPluginLoaded("RaceMenu.esp"))
  Self.CompatibilityRow("MFG Fix", skse.GetPluginVersion("mfgfix") >= 0)
  Self.CompatibilityRow("SKEE / NiOverride", skse.GetPluginVersion("skee") >= 0 || skse.GetPluginVersion("NiOverride") >= 0)
  Self.CompatibilityRow("Open Animation Replacer", skse.GetPluginVersion("OpenAnimationReplacer") >= 0)
  Self.DrawTransformCompatibility()
  Self.AddTextOptionST("CompatibilityRefresh", "刷新兼容与外观资源", "$PSQ_Execute", 0)
  Self.SetCursorPosition(1)
  Self.AddHeaderOption("$PSQ_CompatOptional", 0)
  Self.CompatibilityRow("Alternate Start - Live Another Life", PSQ.HasAlternateStart())
  Self.AddTextOptionST("AlternateStartProtectionInfo", "$PSQ_LALProtection", PSQ.GetAlternateStartProtectionStatus(), 0)
  Self.CompatibilityRow("RaceCompatibility（独立种族）", psqracecompatibility.IsAvailable())
  Self.AddTextOption("当前玩家种族", Self.GetPlayerRaceName(), 1)
  Self.AddTextOption("RC 普通／吸血鬼配对", psqracecompatibility.GetRegistrationStatus(PSQ.PlayerRef.GetRace()), 1)
  Self.AddMenuOptionST("RaceAppearancePolicy", "种族外观策略", Self.GetRaceAppearanceModeLabel(), 0)
  Self.AddTextOptionST("RaceAppearanceInfo", "当前外观处理", psqracecompatibility.GetAppearanceStatus(PSQ.PlayerRef), 0)
  Self.CompatibilityRow("UBE 种族身形", psqracecompatibility.HasUBE())
  Self.CompatibilityRow("DX魅魔 UBE 服装适配", PSQDXUBE.GetRawPart(0) != None)
  If psqracecompatibility.IsUBEActor(PSQ.PlayerRef)
    Self.AddTextOption("UBE 变身身形", "Body Change 专用预设", 1)
    Self.AddTextOption("UBE 身体与皮肤", "保留当前模型、贴图和附件", 1)
    Self.AddTextOption("UBE 服装与淫纹", "需对应 UBE 资源版本", 1)
  EndIf
  Self.CompatibilityRow("SLSO", Self.CompatibilityPluginLoaded("SLSO.esp"))
  Self.CompatibilityRow("Apropos 2（撕裂损伤修复）", PSQ.HasAproposRepairIntegration())
  Self.CompatibilityRow("TDF", Self.CompatibilityPluginLoaded("SexLab TDF Aggressive Prostitution.esp"))
  Self.CompatibilityRow("TDF Enhanced", Self.CompatibilityPluginLoaded("TDF Enhanced Prostitution.esp"))
  Self.CompatibilityRow("Fill Her Up", Self.CompatibilityPluginLoaded("sr_FillHerUp.esp"))
  Self.CompatibilityRow("UIExtensions", Self.CompatibilityPluginLoaded("UIExtensions.esp"))
  Self.CompatibilityRow("EFF", Self.CompatibilityPluginLoaded("EFFCore.esm"))
  Self.CompatibilityRow("NFF（Nether随从框架）", Self.CompatibilityPluginLoaded("nwsFollowerFramework.esp"))
  If Self.CompatibilityPluginLoaded("nwsFollowerFramework.esp")
    Self.AddTextOptionST("NFFCompatibilityInfo", "$PSQ_NFFScope", "$PSQ_NFFScopeValue", 0)
  EndIf
  Self.CompatibilityRow("iNeed", Self.CompatibilityPluginLoaded("iNeed.esp"))
  Self.CompatibilityRow("Mannaz（种族特性吸取）", Self.CompatibilityPluginLoaded("Mannaz - Integrated Races of Skyrim.esp"))
  If Self.CompatibilityPluginLoaded("Mannaz - Integrated Races of Skyrim.esp")
    Self.AddTextOption("$PSQ_RacialTraitSource", "Mannaz · 30项", 1)
  Else
    Self.AddTextOption("$PSQ_RacialTraitSource", "原版十种族 · 20项", 1)
  EndIf
  Self.AddHeaderOption("$PSQ_CompatBundled", 0)
  Self.CompatibilityRow("$PSQ_CompatIntegratedTransform", Game.GetFormFromFile(42240, "PSQ PlayerSuccubusQuest.esm") != None && Game.GetFormFromFile(42243, "PSQ PlayerSuccubusQuest.esm") != None)
  Self.CompatibilityRow("GT Softbody", PSQ.CanUseGTSoftbody())
  If PSQ.CanUseGTSoftbody()
    Self.AddTextOptionST("GTSoftbodyCompatInfo", "$PSQ_GTProtection", "$PSQ_GTProtectionEnabled", 0)
    If PSQ.GTSoftbodyOwnsAppearance()
      Self.AddTextOption("$PSQ_GTBodyOwner", "$PSQ_GTBodyOwnerBusy", 1)
    Else
      Self.AddTextOption("$PSQ_GTBodyOwner", "$PSQ_GTBodyOwnerFree", 1)
    EndIf
  EndIf
  Self.CompatibilityRow("Wingflight／OSYRN（飞行控制）", PSQ.HasWingflight())
  Self.AddTextOption("飞行接口状态", PSQ.GetWingflightStatus(), 1)
  Self.AddTextOptionST("OSYRNFlightInfo", "OSYRN 飞行适配", PSQ.GetOSYRNFlightCompatibilityInfo(), 0)
  Self.CompatibilityRow("Animated Fairy Wings", PSQ.CanUseAnimatedFairyWings())
  Self.CompatibilityRow("Animated Dragon Wings 资源", PSQ.CanUseAnimatedDragonWings())
  Self.AddTextOption("DX魅魔原作适配", PSQ.GetExternalOutfitSourceStatus(1), 1)
  Self.AddTextOption("海伦娜原作适配", PSQ.GetExternalOutfitSourceStatus(2), 1)
  Self.AddTextOptionST("ShinanoOutfitInfo", "信浓魅魔原作适配", PSQ.GetShinanoOutfitSourceStatus(), 0)
  Self.AddTextOption("凤蝶深渊适配", PSQ.GetExternalOutfitSourceStatus(4), 1)
  Self.AddTextOption("SW吸血鬼适配", PSQ.GetExternalOutfitSourceStatus(7), 1)
  Self.AddTextOption("TERA魅魔适配", PSQ.GetExternalOutfitSourceStatus(100), 1)
  Self.AddTextOption("龙之公主适配", PSQ.GetExternalOutfitSourceStatus(3), 1)
  Self.AddTextOption("TERA魅魔2适配", PSQ.GetExternalOutfitSourceStatus(5), 1)
  Self.AddHeaderOption("$PSQ_CompatScope", 0)
  Self.AddTextOption("$PSQ_CompatUnverified", "$PSQ_CompatManual", 1)
EndFunction

String Function GetPlayerRaceName()
  Race Current = PSQ.PlayerRef.GetRace()
  If Current == None
    Return "未知／正在切换"
  EndIf
  String Name = Current.GetName()
  If Name == ""
    Return Current.GetFormID() as String
  EndIf
  Return Name
EndFunction

String[] Function GetRaceAppearanceModeOptions()
  String[] Options = new String[3]
  Options[0] = "自动：保护独立种族外观"
  Options[1] = "始终保留当前种族外观"
  Options[2] = "使用 PSQ 外观（需资源适配）"
  Return Options
EndFunction

String Function GetRaceAppearanceModeLabel()
  String[] Options = Self.GetRaceAppearanceModeOptions()
  Return Options[psqracecompatibility.GetMode(PSQ.PlayerRef)]
EndFunction

String[] Function GetArousalModeOptions()
  String[] Options = new String[6]
  Options[0] = "自动选择"
  Options[1] = "SLA / Redux / SLAX 兼容接口"
  Options[2] = "SLO / SLA Aroused NG"
  Options[3] = "OSL Aroused"
  Options[4] = "外部适配器"
  Options[5] = "禁用欲望接入"
  Return Options
EndFunction

String Function GetArousalModeLabel()
  String[] Options = Self.GetArousalModeOptions()
  Int Mode = psqarousalruntime.GetMode()
  If Mode < 0 || Mode >= Options.Length
    Mode = 0
  EndIf
  Return Options[Mode]
EndFunction

String Function GetSkillDrainModeName(Int Mode)
  If Mode == 1
    Return "$PSQ_SkillDrainFixed"
  ElseIf Mode == 2
    Return "$PSQ_SkillDrainRank"
  EndIf
  Return "$PSQ_SkillDrainOff"
EndFunction

Function OnOptionMenuOpen(Int Option)
  If Option == TransformBuffModeOption
    String[] Modes = new String[3]
    Modes[0] = "$PSQ_TransformBuffOff"
    Modes[1] = "$PSQ_TransformBuffRank"
    Modes[2] = "$PSQ_TransformBuffManual"
    Self.SetMenuDialogOptions(Modes)
    Self.SetMenuDialogStartIndex(PSQ.GetTransformBuffMode())
    Self.SetMenuDialogDefaultIndex(1)
  ElseIf Option == BodySelectionOption
    PSQ.MigrateTransformPresetCatalog(-1, False)
    Int Count = PSQ.GetTransformBodyPresetCount(-1, False)
    If !PSQ.HasBodyChangeNGAPI()
      Self.ShowMessage("$PSQ_BCNGRequirementInfo", False, "$OK", "$Cancel")
    EndIf
    If Count < 0
      Count = 0
    EndIf
    Int BodyPageCount = (Count + 119) / 120
    If BodyPageCount < 1
      BodyPageCount = 1
    EndIf
    If BodyChangeMenuPage < 0 || BodyChangeMenuPage >= BodyPageCount
      BodyChangeMenuPage = 0
    EndIf
    BodyChangeMenuOffset = BodyChangeMenuPage * 120
    BodyChangeMenuCount = Count - BodyChangeMenuOffset
    If BodyChangeMenuCount > 120
      BodyChangeMenuCount = 120
    EndIf
    String[] BodyOptions = Utility.CreateStringArray(BodyChangeMenuCount + 3, "")
    BodyOptions[0] = "$PSQ_BodyNoChange"
    BodyOptions[1] = "$PSQ_BCNGPreviousPage"
    BodyOptions[2] = "$PSQ_BCNGNextPage"
    Int i = 0
    While i < BodyChangeMenuCount
      BodyOptions[i + 3] = PSQ.GetTransformBodyPresetName(BodyChangeMenuOffset + i + 1, -1, False)
      i += 1
    EndWhile
    Int Start = PSQ.SuccubusBodySelection - BodyChangeMenuOffset + 2
    If Start < 3 || Start >= BodyOptions.Length
      Start = 0
    EndIf
    Self.SetMenuDialogOptions(BodyOptions)
    Self.SetMenuDialogStartIndex(Start)
    Self.SetMenuDialogDefaultIndex(0)
  ElseIf Option == DigestionModeOption
    String[] DigestionModes = new String[3]
    DigestionModes[0] = "$PSQ_DigestionAuto"
    DigestionModes[1] = "$PSQ_DigestionBoth"
    DigestionModes[2] = "$PSQ_DigestionActive"
    Self.SetMenuDialogOptions(DigestionModes)
    Self.SetMenuDialogStartIndex(PSQ.GetDigestionMode())
    Self.SetMenuDialogDefaultIndex(1)
  ElseIf Option == SatiationModeOption
    String[] SatiationModes = new String[3]
    SatiationModes[0] = "$PSQ_SatiationOff"
    SatiationModes[1] = "$PSQ_SatiationManual"
    SatiationModes[2] = "$PSQ_SatiationRank"
    Self.SetMenuDialogOptions(SatiationModes)
    Self.SetMenuDialogStartIndex(PSQ.GetSatiationEffectMode())
    Self.SetMenuDialogDefaultIndex(0)
  ElseIf Option == DragonSoulModeOption
    String[] modes = new String[3]
    modes[0] = "$PSQ_DragonSoulModeOff"
    modes[1] = "$PSQ_DragonSoulModeEnergy"
    modes[2] = "$PSQ_DragonSoulModeEnergyPerk"
    Self.SetMenuDialogOptions(modes)
    Self.SetMenuDialogStartIndex(DragonSoulExchangeMode)
    Self.SetMenuDialogDefaultIndex(2)
  Else
    Parent.OnOptionMenuOpen(Option)
  EndIf
EndFunction

Function OnOptionMenuAccept(Int Option, Int Selection)
  If Option == TransformBuffModeOption
    If Selection >= 0 && Selection <= 2
      PSQ.SetTransformBuffMode(Selection)
      Self.ForcePageReset()
    EndIf
  ElseIf Option == BodySelectionOption
    Int Count = PSQ.GetTransformBodyPresetCount(-1, False)
    Int BodyPageCount = (Count + 119) / 120
    If BodyPageCount < 1
      BodyPageCount = 1
    EndIf
    If Selection == 1
      BodyChangeMenuPage -= 1
      If BodyChangeMenuPage < 0
        BodyChangeMenuPage = BodyPageCount - 1
      EndIf
      Self.ForcePageReset()
    ElseIf Selection == 2
      BodyChangeMenuPage = (BodyChangeMenuPage + 1) % BodyPageCount
      Self.ForcePageReset()
    ElseIf Selection == 0
      If PSQ.SetSuccubusBodySelection(0)
        Self.ForcePageReset()
      EndIf
    ElseIf Selection >= 3 && Selection < BodyChangeMenuCount + 3
      If PSQ.SetSuccubusBodySelection(BodyChangeMenuOffset + Selection - 2)
        Self.ForcePageReset()
      EndIf
    EndIf
  ElseIf Option == DigestionModeOption
    If Selection >= 0 && Selection <= 2
      PSQ.DigestionMode = Selection
      Self.ForcePageReset()
    EndIf
  ElseIf Option == SatiationModeOption
    If Selection >= 0 && Selection <= 2
      PSQ.SetSatiationEffectMode(Selection)
      Self.ForcePageReset()
    EndIf
  ElseIf Option == DragonSoulModeOption
    If Selection >= 0 && Selection <= 2
      DragonSoulExchangeMode = Selection
      Self.SetMenuOptionValue(DragonSoulModeOption, Self.GetDragonSoulModeName(Selection), False)
      Self.ForcePageReset()
    EndIf
  Else
    Parent.OnOptionMenuAccept(Option, Selection)
  EndIf
EndFunction

String Function GetDragonSoulModeName(Int Mode)
  If Mode == 1
    Return "$PSQ_DragonSoulModeEnergy"
  ElseIf Mode == 2
    Return "$PSQ_DragonSoulModeEnergyPerk"
  EndIf
  Return "$PSQ_DragonSoulModeOff"
EndFunction

Function OnOptionHighlight(Int Option)
  If Option == TransformBuffModeOption
    Self.SetInfoText("$PSQ_TransformBuffInfo")
  ElseIf Option == BodySelectionOption
    Self.SetInfoText("$PSQ_TransformBodyInfo")
  ElseIf Option == DigestionModeOption
    Self.SetInfoText("$PSQ_DigestionModeInfo")
  ElseIf Option == SatiationModeOption
    Self.SetInfoText("$PSQ_SatiationModeInfo")
  ElseIf Option == DragonSoulModeOption
    Self.SetInfoText("$PSQ_DragonSoulInfo")
  Else
    Parent.OnOptionHighlight(Option)
  EndIf
EndFunction

Function OnOptionDefault(Int Option)
  If Option == TransformBuffModeOption
    PSQ.SetTransformBuffMode(1)
    Self.ForcePageReset()
  ElseIf Option == BodySelectionOption
    If PSQ.SetSuccubusBodySelection(0)
      Self.ForcePageReset()
    EndIf
  ElseIf Option == DigestionModeOption
    PSQ.DigestionMode = 1
    Self.ForcePageReset()
  ElseIf Option == SatiationModeOption
    PSQ.SetSatiationEffectMode(0)
    Self.ForcePageReset()
  ElseIf Option == DragonSoulModeOption
    DragonSoulExchangeMode = 2
    Self.ForcePageReset()
  Else
    Parent.OnOptionDefault(Option)
  EndIf
EndFunction

String Function GetSatiationModeName(Int Mode)
  If Mode == 1
    Return "$PSQ_SatiationManual"
  ElseIf Mode == 2
    Return "$PSQ_SatiationRank"
  EndIf
  Return "$PSQ_SatiationOff"
EndFunction

String Function GetDigestionModeName(Int Mode)
  If Mode == 0
    Return "$PSQ_DigestionAuto"
  ElseIf Mode == 2
    Return "$PSQ_DigestionActive"
  EndIf
  Return "$PSQ_DigestionBoth"
EndFunction

String Function GetTransformBodySelectionName()
  PSQ.MigrateTransformPresetCatalog(-1, False)
  If !PSQ.HenshinBody
    Return "$PSQ_BodyNoChange"
  EndIf
  String SelectedName = PSQ.GetTransformBodyPresetName(PSQ.SuccubusBodySelection, -1, False)
  If SelectedName == ""
    Return PSQ.GetSelectedTransformBodyName()
  EndIf
  Return SelectedName
EndFunction

String Function GetTransformBuffModeName()
  Int Mode = PSQ.GetTransformBuffMode()
  If Mode == 1
    Return "$PSQ_TransformBuffRank"
  ElseIf Mode == 2
    Return "$PSQ_TransformBuffManual"
  EndIf
  Return "$PSQ_TransformBuffOff"
EndFunction

Int Function IntegrationOptionFlags(String Plugin)
  If PSQ.IsIntegrationPluginLoaded(Plugin)
    Return 0
  EndIf
  Return 1
EndFunction

Armor[] Function GetPlayerWingChoices(Bool FollowOutfit)
  Armor[] Wing
  Int Offset = 0
  If FollowOutfit
    Wing = new Armor[19]
    Int i = 0
    While i < 8
      Wing[i] = PSQ.GetOutfitWings(i + 1)
      i += 1
    EndWhile
    Offset = 7
  Else
    Wing = new Armor[12]
    Wing[0] = PSQ.SuccubusStaticWings
  EndIf
  If PSQ.CanUseAnimatedDragonWings()
    Wing[1 + Offset] = PSQ.SuccubusDragonWingsCommon
    Wing[2 + Offset] = PSQ.SuccubusDragonWingsBoss
    Wing[3 + Offset] = PSQ.SuccubusDragonWingsForest
    Wing[4 + Offset] = PSQ.SuccubusDragonWingOdaviing
    Wing[5 + Offset] = PSQ.SuccubusDragonWingsParthurnax
    Wing[6 + Offset] = PSQ.SuccubusDragonWingsSnow
    Wing[7 + Offset] = PSQ.SuccubusDragonWingsTundra
    Wing[8 + Offset] = PSQ.SuccubusDragonWingsUnderskin
    Wing[9 + Offset] = PSQ.SuccubusDragonWingsAlduin
    Wing[10 + Offset] = PSQ.SuccubusDragonWingsBloody
  EndIf
  If PSQ.CanUseAnimatedFairyWings()
    Wing[11 + Offset] = PSQ.SuccubusFairyWings
  EndIf
  Return Wing
EndFunction

String Function GetOutfitWingLabel(Int Selection)
  If Selection == 1
    Return "$PSQ_OutfitWing1"
  ElseIf Selection == 2
    Return "$PSQ_OutfitWing2"
  ElseIf Selection == 3
    Return "$PSQ_OutfitWing3"
  ElseIf Selection == 4
    Return "$PSQ_OutfitWing4"
  ElseIf Selection == 5
    Return "$PSQ_OutfitWing5"
  ElseIf Selection == 6
    Return "$PSQ_OutfitWing6"
  ElseIf Selection == 7
    Return "$PSQ_OutfitWing7"
  ElseIf Selection == 8
    Return "$PSQ_OutfitWing8"
  EndIf
  Return "$PSQ_WingsSwitchOff"
EndFunction

String Function GetPlayerWingSelectionLabel()
  If !PSQ.HenshinWings || !PSQ.PSQSuccubusWings
    Return "$PSQ_WingsSwitchOff"
  EndIf
  Int i = 1
  While i <= 8
    If PSQ.PSQSuccubusWings == PSQ.GetOutfitWings(i)
      Return Self.GetOutfitWingLabel(i)
    EndIf
    i += 1
  EndWhile
  Return PSQ.PSQSuccubusWings.GetName()
EndFunction

Int Function GetManagedAbilityIndex(String Option)
  If Option == "EnableSuccubusDrainHealthSpell"
    Return 0
  ElseIf Option == "EnableSuccubusDrainStaminaSpell"
    Return 1
  ElseIf Option == "EnableSuccubusDrainFF"
    Return 2
  ElseIf Option == "CreatePenisSpellSelf"
    Return 3
  ElseIf Option == "CreatePenisSpellOther"
    Return 4
  ElseIf Option == "SuccubusCurseSpell"
    Return 5
  ElseIf Option == "StarkRealitySpell"
    Return 6
  ElseIf Option == "SuccuKanashibari"
    Return 7
  ElseIf Option == "SuccubusRaiseArousalSpell"
    Return 8
  ElseIf Option == "SuccubusArousalCloakSpell"
    Return 9
  ElseIf Option == "FortifyMSGBoxSpell"
    Return 10
  ElseIf Option == "SuccubusSpellLearningMSGBoxSpell"
    Return 11
  ElseIf Option == "SuccubusSummonMerchantSpell"
    Return 12
  ElseIf Option == "RestoreMagickaSpell"
    Return 13
  ElseIf Option == "MasturbationSpell"
    Return 14
  EndIf
  Return -1
EndFunction

String Function GetAbilityManagementModeName()
  Int Mode = PSQ.GetAbilityManagementMode()
  If Mode == 0
    Return "$PSQ_ManagedAbilitiesOff"
  ElseIf Mode == 2
    Return "$PSQ_ManagedAbilitiesManual"
  EndIf
  Return "$PSQ_ManagedAbilitiesRank"
EndFunction

String Function GetTransformHairLabel(Int Choice)
  If Choice == 1
    If PSQ.GetTransformHairChoice(Choice, -1, False) == None
      Return "BDOR Sharvis（缺少BDOR插件或对应发型）"
    EndIf
    Return "BDOR Sharvis"
  ElseIf Choice == 2
    If PSQ.GetTransformHairChoice(Choice, -1, False) == None
      Return "BDOR Rosally（缺少BDOR插件或对应发型）"
    EndIf
    Return "BDOR Rosally"
  ElseIf Choice == 3
    If PSQ.GetTransformHairChoice(Choice, -1, False) == None
      Return "BDOR Paramella（缺少BDOR插件或对应发型）"
    EndIf
    Return "BDOR Paramella"
  ElseIf Choice == 4
    If PSQ.GetTransformHairChoice(Choice, -1, False) == None
      Return "BDOR Tumerlin A（缺少BDOR插件或对应发型）"
    EndIf
    Return "BDOR Tumerlin A"
  EndIf
  Return "$PSQ_TransformHairOff"
EndFunction

Function DrawTransformCompatibility()
  Self.AddHeaderOption("$PSQ_CompatTransform", 0)
  Self.CompatibilityRow("$PSQ_CompatHairBDOR", Self.CompatibilityPluginLoaded("[Dint999] BDOr_Hairstyles.esp"))
  Int HairCount = 0
  Int i = 1
  While i <= 4
    If PSQ.GetTransformHairChoice(i, -1, False) != None
      HairCount += 1
    EndIf
    i += 1
  EndWhile
  Self.AddTextOption("$PSQ_CompatHairCount", HairCount as String + "/4", 1)
  Self.CompatibilityRow("$PSQ_CompatEyesTullius", Self.CompatibilityPluginLoaded("Tullius Eyes.esp"))
  Bool PapyrusReady = skse.GetPluginVersion("papyrusutil plugin") >= 0 || skse.GetPluginVersion("PapyrusUtil") >= 0
  Int EyeTotal = 0
  Int EyeCount = 0
  Int BodyCount = 0
  String BuildBase = "$PSQ_CompatMissing"
  Bool BodyTRI = False
  Bool BodySlidePresent = False
  Int OutfitTRICount = 0
  If PapyrusReady
    EyeTotal = PSQ.GetCachedEyeMaterialCount()
    i = 1
    While i <= EyeTotal
      If PSQ.GetExternalEyeTexture(i, -1, False) != None
        EyeCount += 1
      EndIf
      i += 1
    EndWhile
    BodyCount = PSQ.GetTransformBodyPresetCount(-1, False)
    BuildBase = PSQ.GetBodyChangeStatusName()
    BodyTRI = miscutil.FileExists("Data/meshes/actors/character/character assets/femalebody.tri")
    BodySlidePresent = miscutil.FileExists("Data/CalienteTools/BodySlide/BodySlide x64.exe")
    i = 1
    While i <= 8
      String Number = "0" + i as String
      String BasePath = "Data/meshes/PSQ/Outfits/Set" + Number + "/"
      If miscutil.FileExists(BasePath + "cuirass.tri")
        OutfitTRICount += 1
      EndIf
      If miscutil.FileExists(BasePath + "boots.tri")
        OutfitTRICount += 1
      EndIf
      If miscutil.FileExists(BasePath + "gloves.tri")
        OutfitTRICount += 1
      EndIf
      i += 1
    EndWhile
  EndIf
  Self.AddTextOption("$PSQ_CompatEyeCount", (EyeCount as String + "/") + EyeTotal as String, 1)
  Self.CompatibilityRow("$PSQ_CompatBodyRuntime", PSQ.HasBodyChangeNGAPI())
  Self.CompatibilityRow("$PSQ_CompatBodySlide", BodySlidePresent)
  Self.CompatibilityRow("$PSQ_CompatPresetIndex", PSQ.HasBodyChangeNGAPI() && BodyCount > 0)
  Self.AddTextOption("$PSQ_CompatBodyCount", BodyCount as String, 1)
  Self.AddTextOption("$PSQ_CompatBuildBase", BuildBase, 1)
  Self.CompatibilityRow("$PSQ_CompatBodyTRI", BodyTRI)
  Self.AddTextOption("$PSQ_CompatOutfitTRI", OutfitTRICount as String + "/24", 1)
  Self.CompatibilityRow("$PSQ_CompatTattooRuntime", PSQ.HasNiOverrideRuntime())
  Self.AddTextOptionST("TransformCompatibilityInfo", "$PSQ_CompatTransformNotes", "$PSQ_CompatManual", 0)
EndFunction

Function OnHighlightST()
  If Self.GetState() == "SuccubusStorageSpell"
    Self.SetInfoText("$PSQ_StorageRankInfo")
    Return 
  EndIf
  String ThrallOption = Self.GetState()
  If ThrallOption == "SuccubusCurseSpell" || ThrallOption == "ThrallRefresh"
    Self.SetInfoText("$PSQ_ThrallInfo")
    Return 
  ElseIf Self.GetThrallActionSlot(ThrallOption) >= 0
    Self.SetInfoText("$PSQ_ThrallActionsInfo")
    Return 
  ElseIf ThrallOption == "SuccubusArousalCloakSpell"
    Self.SetInfoText("$PSQ_ThrallPoisonInfo")
    Return 
  EndIf
  String Option = Self.GetState()
  Int ManagedIndex = Self.GetManagedAbilityIndex(Option)
  If ManagedIndex >= 0
    Self.SetInfoText(("等级解锁要求：魅魔 " + PSQ.GetManagedAbilityUnlockRank(ManagedIndex) as String) + " 级。只有自主设置模式可以修改单项开关。")
    Return 
  EndIf
  If Option == "EnableDrain"
    If PSQ.EnableDrain
      Self.SetInfoText("$PSQ_EnableDrainInfo1")
    Else
      Self.SetInfoText("$PSQ_EnableDrainInfo2")
    EndIf
  ElseIf Option == "AllowHybrid"
    Self.SetInfoText("$PSQ_AllowHybridInfo")
  ElseIf Option == "AllowDrainFromFemale"
    If !PSQ.AllowDrainFromFemale
      Self.SetInfoText("$PSQ_EnableDrainFemaleInfo1")
    Else
      Self.SetInfoText("$PSQ_EnableDrainFemaleInfo2")
    EndIf
  ElseIf Option == "AllowDrainFromBeast"
    If !PSQ.AllowDrainFromBeast
      Self.SetInfoText("$PSQ_EnableDrainBeastInfo1")
    Else
      Self.SetInfoText("$PSQ_EnableDrainBeastInfo2")
    EndIf
  ElseIf Option == "AllowDrainFromUndead"
    If !PSQ.AllowDrainFromUndead
      Self.SetInfoText("$PSQ_EnableDrainUndeadInfo1")
    Else
      Self.SetInfoText("$PSQ_EnableDrainUndeadInfo2")
    EndIf
  ElseIf Option == "ExtractSemenPotion"
    If !PSQ.ExtractSemenPotion
      Self.SetInfoText("$PSQ_EnableSemenPotionInfo1")
    Else
      Self.SetInfoText("$PSQ_EnableSemenPotionInfo2")
    EndIf
  ElseIf Option == "AutoExtractSemenPotion"
    Self.SetInfoText("$PSQ_SuccubusExtractPotionAutoCheckInfo")
  ElseIf Option == "EnableSoulTrap"
    If !PSQ.EnableSoulTrap
      Self.SetInfoText("$PSQ_EnableDrainSoulTrapInfo1")
    Else
      Self.SetInfoText("$PSQ_EnableDrainSoulTrapInfo2")
    EndIf
  ElseIf Option == "AllowKill"
    If PSQ.AllowKill
      Self.SetInfoText("$PSQ_EnableDrainDeathInfo1")
    Else
      Self.SetInfoText("$PSQ_EnableDrainDeathInfo2")
    EndIf
  ElseIf Option == "EnableCaptive"
    Self.SetInfoText("$PSQ_EnableCaptiveInfo")
  ElseIf Option == "UseArousalAtDrain"
    Self.SetInfoText("$PSQ_UseArousalAtDrainInfo")
  ElseIf Option == "EnableSatiationNotification"
    If PSQ.EnableSatiationNotification
      Self.SetInfoText("$PSQ_EnableNotificationInfo1")
    Else
      Self.SetInfoText("$PSQ_EnableNotificationInfo2")
    EndIf
  ElseIf Option == "EnableStarvation"
    If PSQ.EnableStarvation
      Self.SetInfoText("$PSQ_EnableStarvationDeathInfo1")
    Else
      Self.SetInfoText("$PSQ_EnableStarvationDeathInfo2")
    EndIf
  ElseIf Option == "EnergyModeAlt"
    Self.SetInfoText("$PSQ_EnergyModeAltInfo")
  ElseIf Option == "FluidNeedArousal"
    Self.SetInfoText("$PSQ_FluidNeedArousalInfo")
  ElseIf Option == "HenshinIsCrime"
    Self.SetInfoText("$PSQ_HenshinIsCrimeInfo")
  ElseIf Option == "HenshinFear"
    Self.SetInfoText("$PSQ_HenshinFearInfo")
  ElseIf Option == "ArousedForceTransform"
    Self.SetInfoText("$PSQ_ArousedForceTransformInfo")
  ElseIf Option == "ArousedForceDeTransform"
    Self.SetInfoText("$PSQ_ArousedForceDeTransformInfo")
  ElseIf False
    Self.SetInfoText("$PSQ_PhysicalWeaknessInfo")
  ElseIf Option == "StopEnergyConsuming"
    If !PSQ.StopEnergyConsuming
      Self.SetInfoText("$PSQ_PauseEnergyConsumingInfo1")
    Else
      Self.SetInfoText("$PSQ_PauseEnergyConsumingInfo2")
    EndIf
  ElseIf Option == "EnergyConsumptionPerMax"
    Self.SetInfoText("$PSQ_ConsumptionRateInfo")
  ElseIf Option == "WingMaxJumpHeight"
    if !PSQ.CanControlWingflightPolicy()
      Self.SetInfoText("独立飞行模式：Wingflight／OSYRN 自身设置生效；PSQ 专有等级、自动启用和翼装跳高控制不可用。")
      return
    endif
    Self.SetInfoText("通过 Wingflight 的翼装跳跃倍率实现，不再用 PSQ 全局跳高叠加。飞行升力、速度和体力在 Wingflight 菜单中调整。")
  ElseIf Option == "RestoreMagickaMAX"
    Self.SetInfoText("$PSQ_ConversionEnergyMagickaInfo")
  EndIf
EndFunction

String Function GetAttributeDrainModeName()
  If PSQ.AttributeDrainMode == 1
    Return "$PSQ_AttributeDrainRank"
  EndIf
  Return "$PSQ_AttributeDrainOff"
EndFunction

String Function GrowthNumber(Float value)
  If value == (value as Int) as Float
    Return (value as Int) as String
  EndIf
  Return value as String
EndFunction

Function DrawGrowthOverview()
  Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
  Self.SetCursorPosition(0)
  Self.AddHeaderOption("$PSQ_GrowthCurrent", 0)
  Self.AddTextOption("$PSQ_PlayerSuccubusFlag", PlayerIsSuccubus.GetValueInt() as String, 1)
  Self.AddTextOption("$PSQ_EnergyConsumptionPerDay", Self.GrowthNumber(PSQ.EnergyConsumption), 1)
  Int Rank = SuccubusRank.GetValueInt()
  Float Experience = SuccubusEXP.GetValue() * 100.0
  If PlayerIsSuccubus.GetValueInt() == 1 && Rank > 0
    Self.AddTextOption("$PSQ_GrowthRank", Self.GetTitle(), 0)
    If Rank >= 10
      Self.AddTextOption("$PSQ_GrowthExperience", Self.GrowthNumber(Experience), 0)
      Self.AddTextOption("$PSQ_GrowthRemaining", "$PSQ_GrowthMaxRank", 0)
    Else
      Float Next = Self.GetNextExp()
      Float Remaining = Next - Experience
      If Remaining < 0.0
        Remaining = 0.0
      EndIf
      Self.AddTextOption("$PSQ_GrowthExperience", Self.GrowthNumber(Experience) + " / " + Self.GrowthNumber(Next), 0)
      Self.AddTextOption("$PSQ_GrowthRemaining", Self.GrowthNumber(Remaining), 0)
    EndIf
    Self.AddTextOption("$PSQ_GrowthEnergy", Self.GrowthNumber(SuccubusEnergy.GetValue()) + " / " + Self.GrowthNumber(PSQ.MaxEnergy), 0)
    Self.AddTextOption("$PSQ_ShoutBonusCurrent", Self.GrowthNumber(PSQ.GetRankShoutCooldownReduction() * 100.0) + "%", 0)
    Self.AddTextOption("$PSQ_RankMagicCostCurrent", PSQ.GetRankMagicCostReduction() as String + "%", 0)
    Self.AddTextOption("$PSQ_RankSpeedHuman", "+" + Self.GrowthNumber(PSQ.GetRankSpeedBonus(False)) + "%", 0)
    Self.AddTextOption("$PSQ_RankSpeedTransformed", "+" + Self.GrowthNumber(PSQ.GetRankSpeedBonus(True)) + "%", 0)
  Else
    Self.AddTextOption("$PSQ_GrowthRank", "$PSQ_GrowthNotSuccubus", 0)
  EndIf
  Self.AddEmptyOption()
  Self.AddHeaderOption("$PSQ_GrowthAttributeHeader", 0)
  Self.AddTextOption("$PSQ_GrowthAttributeHealth", Self.GrowthNumber(PSQ.GetGrowthAbsorbed("Attribute", "Health")), 0)
  Self.AddTextOption("$PSQ_GrowthAttributeMagicka", Self.GrowthNumber(PSQ.GetGrowthAbsorbed("Attribute", "Magicka")), 0)
  Self.AddTextOption("$PSQ_GrowthAttributeStamina", Self.GrowthNumber(PSQ.GetGrowthAbsorbed("Attribute", "Stamina")), 0)
  Self.AddTextOption("$PSQ_GrowthAttributeTotal", Self.GrowthNumber(PSQ.GetGrowthAbsorbed("Attribute", "Total")), 0)
  Self.AddTextOptionST("GrowthRacialTraits", "$PSQ_GrowthRacialTraits", storageutil.GetIntValue(PSQ.PlayerRef as Form, "PSQ_Growth_RacialTraits", 0) as String + "项", 0)
  Self.SetCursorPosition(1)
  Self.AddHeaderOption("$PSQ_GrowthNextUnlock", 0)
  If PlayerIsSuccubus.GetValueInt() != 1 || Rank < 1
    Self.AddTextOption("", "$PSQ_GrowthNotSuccubus", 0)
  ElseIf Rank >= 10
    Self.AddTextOption("", "$PSQ_GrowthMaxRank", 0)
  Else
    String[] Abilities = new String[15]
    Abilities[0] = "魅魔吸取生命"
    Abilities[1] = "魅魔吸取体力"
    Abilities[2] = "魅魔远程吸取"
    Abilities[3] = "肉棒"
    Abilities[4] = "附棒"
    Abilities[5] = "眷属化"
    Abilities[6] = "赤裸"
    Abilities[7] = "束缚"
    Abilities[8] = "欲望"
    Abilities[9] = "欲毒"
    Abilities[10] = "强体"
    Abilities[11] = "学习"
    Abilities[12] = "召唤商人"
    Abilities[13] = "法转"
    Abilities[14] = "自慰"
    Int Count = 0
    Int i = 0
    While i < Abilities.Length
      If PSQ.GetManagedAbilityUnlockRank(i) == Rank + 1
        Self.AddTextOption(Abilities[i], (Rank + 1) as String + "级", 0)
        Count += 1
      EndIf
      i += 1
    EndWhile
    If Rank + 1 == 3
      Self.AddTextOption(PSQ.SuccubusStorageSpell.GetName(), "$PSQ_StorageRankUnlock", 0)
      Count += 1
    EndIf
    If Count == 0
      Self.AddTextOption("", "$PSQ_GrowthNoNewAbility", 0)
    EndIf
    If Rank + 1 == 4
      Self.AddTextOption("$PSQ_EnergySenseName", "4级解锁", 0)
    EndIf
    If PSQ.RacialTraitDrainMode == 1 && Rank + 1 == 4
      Self.AddTextOption("$PSQ_RacialTraitDrainMode", "4级解锁", 0)
    EndIf
    If PSQ.AttributeDrainMode == 1 && Rank + 1 >= 5
      String Scope = "最高一项"
      If Rank + 1 >= 8
        Scope = "三项各"
      EndIf
      Self.AddTextOption("$PSQ_AttributeDrainMode", (Scope + " " + PSQ.GetAttributeDrainAmount(Rank + 1) as String) + "点", 0)
    EndIf
  EndIf
  Self.AddEmptyOption()
  Self.AddHeaderOption("$PSQ_GrowthSkillHeader", 0)
  Self.AddTextOption("$PSQ_GrowthSkillTotal", Self.GrowthNumber(PSQ.GetGrowthAbsorbed("Skill", "Total")), 0)
  Self.AddTextOptionST("GrowthStatsInfo", "$PSQ_GrowthStatsInfo", "$PSQ_GrowthView", 0)
  Self.SetCursorPosition(40)
  Self.AddHeaderOption("$PSQ_GrowthSkillDetail", 0)
  String[] Skills = new String[18]
  Skills[0] = "OneHanded"
  Skills[1] = "TwoHanded"
  Skills[2] = "Marksman"
  Skills[3] = "Block"
  Skills[4] = "Smithing"
  Skills[5] = "HeavyArmor"
  Skills[6] = "LightArmor"
  Skills[7] = "Pickpocket"
  Skills[8] = "Lockpicking"
  Skills[9] = "Sneak"
  Skills[10] = "Alchemy"
  Skills[11] = "Speechcraft"
  Skills[12] = "Alteration"
  Skills[13] = "Conjuration"
  Skills[14] = "Destruction"
  Skills[15] = "Illusion"
  Skills[16] = "Restoration"
  Skills[17] = "Enchanting"
  Int j = 0
  While j < 9
    Self.AddTextOption(PSQ.GetDrainedSkillName(Skills[j]), Self.GrowthNumber(PSQ.GetGrowthAbsorbed("Skill", Skills[j])), 0)
    j += 1
  EndWhile
  Self.SetCursorPosition(41)
  Self.AddHeaderOption("$PSQ_GrowthSkillDetail", 0)
  While j < 18
    Self.AddTextOption(PSQ.GetDrainedSkillName(Skills[j]), Self.GrowthNumber(PSQ.GetGrowthAbsorbed("Skill", Skills[j])), 0)
    j += 1
  EndWhile
EndFunction

String Function GetRacialTraitDrainModeName()
  If PSQ.RacialTraitDrainMode == 1
    Return "$PSQ_RacialTraitDrainRank"
  EndIf
  Return "$PSQ_AttributeDrainOff"
EndFunction

Function DrawFertilityBridgeStatus()
  ; Retired compatibility callback: no pregnancy UI or external status reads.
  Self.UnregisterForModEvent("PSQ_FertilityDisplayChanged")
EndFunction

Function OnFertilityDisplayChanged(String EventName, String ArgString, Float ArgNum, Form Sender)
  ; Retired compatibility callback: no pregnancy UI or external status reads.
  Self.UnregisterForModEvent("PSQ_FertilityDisplayChanged")
EndFunction

Int Function GetThrallActionSlot(String Option)
  If Option == "ThrallRecall0" || Option == "ThrallRelease0"
    Return 0
  ElseIf Option == "ThrallRecall1" || Option == "ThrallRelease1"
    Return 1
  ElseIf Option == "ThrallRecall2" || Option == "ThrallRelease2"
    Return 2
  ElseIf Option == "ThrallRecall3" || Option == "ThrallRelease3"
    Return 3
  EndIf
  Return -1
EndFunction

Function DrawSuccubusThrallPage()
  If ThrallSkillDetailSlot >= 0
    Actor Selected = PSQ.GetSuccubusThrall(ThrallSkillDetailSlot)
    If Selected != None
      Self.DrawThrallSkillDetails(Selected)
      Return 
    EndIf
    ThrallSkillDetailSlot = -1
  EndIf
  PSQ.SyncManagedAbilities()
  Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
  Self.AddHeaderOption("$PSQ_ThrallMagic", 0)
  Int AbilityFlags = 1
  If PSQ.GetAbilityManagementMode() == 2
    AbilityFlags = 0
  EndIf
  Int CurseFlags = AbilityFlags
  If PSQ.SuccubusRank.GetValueInt() < 7
    CurseFlags = 1
  EndIf
  Self.AddToggleOptionST("SuccubusCurseSpell", "$PSQ_ThrallSpell", PSQ.PlayerRef.HasSpell(PSQ.SuccubusCurseSpell as Form), CurseFlags)
  Self.AddToggleOptionST("SuccubusArousalCloakSpell", PSQ.SuccubusArousalCloakSpell.GetName(), PSQ.PlayerRef.HasSpell(PSQ.SuccubusArousalCloakSpell as Form), AbilityFlags)
  Self.AddTextOption("$PSQ_ThrallCapacity", (PSQ.GetSuccubusThrallCount() as String + " / ") + PSQ.GetSuccubusThrallCapacity() as String, 1)
  Self.AddTextOption("$PSQ_ThrallUnlock", "7级1名，8级2名，9级3名，10级4名", 1)
  Self.AddTextOptionST("ThrallRefresh", "$PSQ_ThrallRefresh", "$PSQ_Execute", 0)
  Self.AddTextOption("$PSQ_ThrallRule", "$PSQ_ThrallRuleValue", 1)
  Self.SetCursorPosition(1)
  Self.AddHeaderOption("$PSQ_ThrallRoster", 0)
  Int i = 0
  While i < 4
    Actor Member = PSQ.GetSuccubusThrall(i)
    If Member != None
      Self.AddHeaderOption(Member.GetDisplayName(), 0)
      String Status = "$PSQ_ThrallAlive"
      If Member.IsDead()
        Status = "$PSQ_ThrallDead"
      EndIf
      Self.AddTextOption("$PSQ_ThrallStatus", Status, 1)
      Self.AddTextOption("$PSQ_ThrallLevel", Member.GetLevel() as String, 1)
      Self.AddTextOptionST("ThrallSkillDetails" + i as String, "$PSQ_ThrallSkills", "$PSQ_ThrallSkillsView", 0)
      Self.AddTextOption("$PSQ_ThrallSkillRate", "+50%", 1)
      Self.AddTextOption("$PSQ_ThrallRace", Member.GetRace().GetName(), 1)
      Int TattooChoice = PSQ.GetSuccubusThrallTattooSelection(Member)
      String[] TattooNames = Self.GetSuccubusTattooNames()
      Int TattooFlags = 1
      If PSQ.HasNiOverrideRuntime()
        TattooFlags = 0
      EndIf
      If TattooChoice >= 1 && TattooChoice < TattooNames.Length
        Self.AddMenuOptionST("ThrallTattoo" + i as String, "$PSQ_ThrallTattoo", TattooNames[TattooChoice], TattooFlags)
      Else
        Self.AddMenuOptionST("ThrallTattoo" + i as String, "$PSQ_ThrallTattoo", "$PSQ_ThrallTattooChoose", TattooFlags)
      EndIf
      Self.AddTextOption("$PSQ_ThrallHealth", ((Member.GetActorValue("Health") as Int) as String + " / ") + (Member.GetActorValueMax("Health") as Int) as String, 1)
      Self.AddTextOption("$PSQ_ThrallMagicka", ((Member.GetActorValue("Magicka") as Int) as String + " / ") + (Member.GetActorValueMax("Magicka") as Int) as String, 1)
      Self.AddTextOption("$PSQ_ThrallStamina", ((Member.GetActorValue("Stamina") as Int) as String + " / ") + (Member.GetActorValueMax("Stamina") as Int) as String, 1)
      Self.AddTextOption("$PSQ_ThrallJoined", ((PSQ.GameDaysPassed.GetValue() - storageutil.GetFloatValue(Member as Form, "PSQ_ThrallJoinedDay", 0.0)) as Int) as String + " 天", 1)
      Int EyeFlags = 1
      If PSQ.CanUseSuccubusThrallEyes()
        EyeFlags = 0
      EndIf
      Self.AddMenuOptionST("ThrallEyes" + i as String, "$PSQ_ThrallEyes", PSQ.GetSuccubusEyeMaterialName(PSQ.GetSuccubusThrallEyeSelection(Member)), EyeFlags)
      Self.AddTextOptionST("ThrallRecall" + i as String, "$PSQ_ThrallRecall", "$PSQ_Execute", 0)
      Self.AddTextOptionST("ThrallRelease" + i as String, "$PSQ_ThrallRelease", "$PSQ_Execute", 0)
    EndIf
    i += 1
  EndWhile
EndFunction

Function OpenSuccubusThrallEyesMenu(Int Slot)
  Actor Target = PSQ.GetSuccubusThrall(Slot)
  If Target == None || !PSQ.CanUseSuccubusThrallEyes()
    Return 
  EndIf
  Int Count = PSQ.GetSuccubusEyeMaterialCount()
  If Count < 0 || Count > 127
    Return 
  EndIf
  String[] Options = Utility.CreateStringArray(Count + 1, "")
  Options[0] = "$PSQ_EyeNoChange"
  Int i = 1
  While i <= Count
    Options[i] = PSQ.GetSuccubusEyeMaterialName(i)
    If PSQ.GetExternalEyeTexture(i, -1, False) == None
      Options[i] = Options[i] + "（缺少对应眼睛模组）"
    EndIf
    i += 1
  EndWhile
  Int Selected = PSQ.GetSuccubusThrallEyeSelection(Target)
  If Selected < 0 || Selected > Count
    Selected = 0
  EndIf
  Self.SetMenuDialogOptions(Options)
  Self.SetMenuDialogStartIndex(Selected)
  Self.SetMenuDialogDefaultIndex(0)
EndFunction

Function AcceptSuccubusThrallEyesMenu(Int Slot, Int Choice)
  If !PSQ.SetSuccubusThrallEyes(Slot, Choice)
    Self.ShowMessage("$PSQ_ThrallEyeUnavailable", False, "$OK", "$Cancel")
  EndIf
  Self.ForcePageReset()
EndFunction

Function ApplyPlayerWingChoice(Int i, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = PSQ.AppearanceOperationId
    RequireBusy = PSQ.AppearanceEditBusy
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  If i >= 1 && i <= 8 && !PSQ.CanUseTransformOutfitChoice(5, i)
    Self.ShowMessage("$PSQ_OutfitUnavailable", False, "$OK", "$Cancel")
    Return
  EndIf
  If i < 0 || i > 19 || PSQ.IsHenshinchu
    Return 
  EndIf
  Bool WasEnabled = PSQ.HenshinWings
  Armor OldWing = PSQ.PSQSuccubusWings
  Armor[] Wing = Self.GetPlayerWingChoices(True)
  If i > 0 && !Wing[i - 1]
    Self.ShowMessage("$PSQ_AppearanceWingMissing", False, "$OK", "$Cancel")
    Return 
  EndIf
  If i == 0 && !WasEnabled || i > 0 && WasEnabled && OldWing == Wing[i - 1]
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetMenuOptionValueST(Self.GetPlayerWingSelectionLabel(), False, "")
    Return 
  EndIf
  If PSQ.IsHenshined && WasEnabled && OldWing as Bool
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.RemoveTransformEquipmentItem(OldWing, Owner, RequireBusy)
  EndIf
  If i == 0
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinWings = False
    If PSQ.IsHenshined && WasEnabled
      If PSQ.OrgWings as Bool && PSQ.PlayerRef.GetItemCount(PSQ.OrgWings as Form) > 0
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.PlayerRef.EquipItem(PSQ.OrgWings as Form, False, True)
      EndIf
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.OrgWings = None
    EndIf
  Else
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.PSQSuccubusWings = Wing[i - 1]
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinWings = True
    If PSQ.IsHenshined
      If !WasEnabled
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        Armor PendingAppearanceValue1 = PSQ.PlayerRef.GetWornForm(32768) as Armor
        If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
          Return 
        EndIf
        PSQ.OrgWings = PendingAppearanceValue1
      EndIf
      If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return 
      EndIf
      PSQ.EnsurePlayerTransformEquipment(PSQ.PSQSuccubusWings, Owner, RequireBusy)
    EndIf
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  Self.SetMenuOptionValueST(Self.GetPlayerWingSelectionLabel(), False, "")
EndFunction

Function ApplyPlayerEyeChoice(Int i, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = PSQ.AppearanceOperationId
    RequireBusy = PSQ.AppearanceEditBusy
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  If i < 0 || i > PSQ.GetSuccubusEyeMaterialCount()
    Return 
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  If i > 0 && PSQ.GetExternalEyeTexture(i, Owner, RequireBusy) == None
    Self.ShowMessage(PSQ.GetExternalEyeReadFailure(i), False, "$OK", "$Cancel")
    Return 
  EndIf
  If i == 0 && !PSQ.HenshinEyes && PSQ.OrgEyes == None || i > 0 && PSQ.SuccubusEyeMaterialSelection == i && PSQ.IsSelectedEyeMaterialApplied()
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    Self.SetMenuOptionValueST(Self.GetSelectedEyeMaterialMenuName(), False, "")
    Return 
  EndIf
  If i == 0
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinEyes = False
  Else
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SuccubusEyeMaterialSelection = i
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.HenshinEyes = True
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  PSQ.RefreshSuccubusEyeToggle(Owner, RequireBusy)
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  Self.SetMenuOptionValueST(Self.GetSelectedEyeMaterialMenuName(), False, "")
EndFunction

Function ApplyPlayerHairChoice(Int Choice, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = PSQ.AppearanceOperationId
    RequireBusy = PSQ.AppearanceEditBusy
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  If Choice < 0 || Choice > 4 || PSQ.IsHenshinchu
    Return 
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  If Choice > 0 && PSQ.GetTransformHairChoice(Choice, Owner, RequireBusy) == None
    Self.ShowMessage("$PSQ_TransformHairMissing", False, "$OK", "$Cancel")
    Return 
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  PSQ.SuccubusHairSelection = Choice
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  PSQ.ApplySelectedTransformHair(Owner, RequireBusy)
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  PSQ.ApplySelectedSuccubusEyes(Owner, RequireBusy)
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  Self.SetMenuOptionValueST(Self.GetTransformHairLabel(Choice), False, "")
EndFunction

Function ApplyPlayerTattooChoice(Int i, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = PSQ.AppearanceOperationId
    RequireBusy = PSQ.AppearanceEditBusy
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  If i < 0 || i > 18
    Return 
  EndIf
  If i == 0
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SuccubusTattooSelection = 19
  Else
    If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return 
    EndIf
    PSQ.SuccubusTattooSelection = i
  EndIf
  If PlayerIsSuccubus.GetValueInt() == 1 && PSQ.MaxEnergy > 0.0
    PSQ.ChangeBodyPaint(PSQ.GetEnergyRatio(), True)
  Else
    PSQ.ChangeBodyPaint(0.0, True)
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 
  EndIf
  Self.SetMenuOptionValueST(Self.GetSelectedSuccubusTattooName(), False, "")
EndFunction

Function ApplyPlayerHumanSchlongChoice(Int i, Int Owner, Bool RequireBusy)
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  Armor Choice = PSQ.GetTRXFutaChoice(i)
  If Choice == None
    Self.ShowMessage("未检测到对应 TRX 装备或模型，请启用 TRX 并完成 BodySlide 构建。", False, "$OK", "$Cancel")
    Return
  EndIf
  PSQ.PlayerHumanSchlong = Choice
  Self.SetMenuOptionValueST(PSQ.GetTRXFutaLabel(False), False, "")
EndFunction

Function ApplyPlayerSuccubusSchlongChoice(Int i, Int Owner, Bool RequireBusy)
  If !PSQ.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  Armor Choice = PSQ.GetTRXFutaChoice(i)
  If Choice == None
    Self.ShowMessage("未检测到对应 TRX 装备或模型，请启用 TRX 并完成 BodySlide 构建。", False, "$OK", "$Cancel")
    Return
  EndIf
  PSQ.PlayerSuccubusSchlong = Choice
  Self.SetMenuOptionValueST(PSQ.GetTRXFutaLabel(True), False, "")
EndFunction

Bool Function IsPlayerAppearanceSetting(String Option)
  Return Option == "HenshinTattoo" || Option == "HenshinSkin" || Option == "HenshinWings" || Option == "HenshinHorn" || Option == "HenshinTail" || Option == "HenshinCuirass" || Option == "HenshinBoots" || Option == "HenshinGloves" || Option == "HenshinPenis" || Option == "HenshinHairColor" || Option == "PSQSkinColor" || Option == "PSQSuccubusHairColorInt" || Option == "HenshinSkinColorfulness" || Option == "SuccubusHeight" || Option == "SuccubusButt" || Option == "SuccubusGenitals" || Option == "SuccubusScrotum" || Option == "EnableHeightChangeSuccubus" || Option == "EnableButtChangeSuccubus" || Option == "EnableGenitalsChangeSuccubus" || Option == "EnableScrotumChangeSuccubus" || Option == "PlayerHumanSchlong"
EndFunction

Int Function GetContinuousOptionsFlags()
  If PSQ.GetContinuousAbilityMode() == 2
    Return 0
  EndIf
  Return 1
EndFunction

Int Function GetContinuousOptionIndex(String Option)
  If Option == "FortifyMagickaSpell"
    Return 0
  ElseIf Option == "FortifyStaminaSpell"
    Return 1
  ElseIf Option == "FortifyHealthSpell"
    Return 2
  ElseIf Option == "FortifyCarrySpell"
    Return 3
  ElseIf Option == "FortifyUnarmedSpell"
    Return 4
  ElseIf Option == "SuccubusStorageSpell"
    Return 5
  ElseIf Option == "FortifySneakSpell"
    Return 6
  ElseIf Option == "EnableFortifyDestruction"
    Return 7
  ElseIf Option == "EnableFortifyIllusion"
    Return 8
  ElseIf Option == "EnableMagicResistance"
    Return 9
  ElseIf Option == "EnableSuccubusSpellBooster"
    Return 10
  ElseIf Option == "EnableFortifyBartar"
    Return 11
  ElseIf Option == "EnableSpellCastingNotification"
    Return 13
  EndIf
  Return -1
EndFunction

String Function GetContinuousModeName()
  Int Mode = PSQ.GetContinuousAbilityMode()
  If Mode == 0
    Return "$PSQ_ContinuousOff"
  ElseIf Mode == 2
    Return "$PSQ_ContinuousManual"
  EndIf
  Return "$PSQ_ContinuousRank"
EndFunction

Int Function GetStorageOptionFlags()
  If !PSQ.IsStorageRankUnlocked()
    Return 1
  EndIf
  Return Self.GetContinuousOptionsFlags()
EndFunction

String Function GetIndependentPartLabel(Int Part)
  Int Choice = PSQ.GetTransformPartSelection(Part)
  If Choice == 0
    Return "$PSQ_PartSwitchOff"
  EndIf
  Return PSQ.GetIndependentTransformPartName(Part, Choice)
EndFunction

Function OpenIndependentPartMenu(Int Part)
  String Key = "PSQ_PartChoice" + Part
  storageutil.IntListClear(Self, Key)
  storageutil.IntListAdd(Self, Key, 0, True)
  Self.SaveOutfitMenuIdentity(Key)
  Int Limit = 8
  If Part == 3 && !psqracecompatibility.IsUBEActor(PSQ.PlayerRef)
    Limit += PSQ.GetOptionalHornCount()
  EndIf
  Int i = 1
  While i <= Limit
    If PSQ.CanUseTransformOutfitChoice(Part, i)
      storageutil.IntListAdd(Self, Key, i, True)
    EndIf
    i += 1
  EndWhile
  If Part != 3 && PSQ.CanUseTransformOutfitChoice(Part, 100)
    storageutil.IntListAdd(Self, Key, 100, True)
  EndIf
  Int Count = storageutil.IntListCount(Self, Key)
  String[] Options = PapyrusUtil.StringArray(Count, "")
  Options[0] = "$PSQ_PartSwitchOff"
  Int Selected = PSQ.GetTransformPartSelection(Part)
  Int Start = 0
  i = 1
  While i < Count
    Int Source = storageutil.IntListGet(Self, Key, i)
    Options[i] = PSQ.GetIndependentTransformPartName(Part, Source)
    If Source == Selected
      Start = i
    EndIf
    i += 1
  EndWhile
  Self.SetMenuDialogOptions(Options)
  Self.SetMenuDialogStartIndex(Start)
  Self.SetMenuDialogDefaultIndex(0)
EndFunction

Function AcceptIndependentPartMenu(Int Part, Int Choice)
  If Choice > 0
    String Key = "PSQ_PartChoice" + Part
    If !Self.IsOutfitMenuIdentityCurrent(Key) || Choice >= storageutil.IntListCount(Self, Key)
      Self.ShowMessage("服装列表已变化，请重新打开菜单。", False, "$OK", "$Cancel")
      Return
    EndIf
    Choice = storageutil.IntListGet(Self, Key, Choice)
  EndIf
  If Choice < 0 || !PSQ.SetIndependentTransformPart(Part, Choice)
    Self.ShowMessage("$PSQ_OutfitUnavailable", False, "$OK", "$Cancel")
    Return
  EndIf
  Self.SetMenuOptionValueST(Self.GetIndependentPartLabel(Part), False, "")
EndFunction

Function DrawThrallSkillDetails(Actor Target)
  Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
  Self.AddTextOptionST("ThrallSkillsBack", "$PSQ_ThrallSkillsBack", "", 0)
  Self.AddHeaderOption(Target.GetDisplayName(), 0)
  Self.AddTextOption("$PSQ_ThrallSkillRate", "+50%", 1)
  Self.AddHeaderOption("$PSQ_ThrallSkillsBase", 0)
  String[] Skills = PSQ.GetThrallSkillNames()
  Int i = 0
  While i < Skills.Length
    Self.AddTextOption(PSQ.GetDrainedSkillName(Skills[i]), Self.GrowthNumber(Target.GetBaseActorValue(Skills[i])), 1)
    i += 1
  EndWhile
EndFunction

Function OpenSuccubusThrallTattooMenu(Int Slot)
  Actor Target = PSQ.GetSuccubusThrall(Slot)
  If Target == None || !PSQ.HasNiOverrideRuntime()
    Return 
  EndIf
  String[] Names = Self.GetSuccubusTattooNames()
  String[] Options = new String[18]
  Int i = 0
  While i < 18
    Options[i] = Names[i + 1]
    i += 1
  EndWhile
  Int Selected = PSQ.GetSuccubusThrallTattooSelection(Target) - 1
  If Selected < 0 || Selected >= 18
    Selected = 0
  EndIf
  Self.SetMenuDialogOptions(Options)
  Self.SetMenuDialogStartIndex(Selected)
  Self.SetMenuDialogDefaultIndex(Selected)
EndFunction

Function AcceptSuccubusThrallTattooMenu(Int Slot, Int Choice)
  If Choice < 0 || Choice >= 18
    Return 
  EndIf
  If !PSQ.SetSuccubusThrallTattoo(Slot, Choice + 1)
    Self.ShowMessage("$PSQ_ThrallTattooUnavailable", False, "$OK", "$Cancel")
  EndIf
  Self.ForcePageReset()
EndFunction

Function OnColorAcceptST(Int Color)
  String ColorOption = Self.GetState()
  Bool Guard = Self.IsPlayerAppearanceSetting(ColorOption)
  If Guard && !PSQ.BeginAppearanceEdit()
    Return
  EndIf
  Int MenuAppearanceOwner = PSQ.AppearanceOperationId
  If PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, Guard) && Self.GetState() == ColorOption
    Self.HandleAppearanceOnColorAcceptST(Color, MenuAppearanceOwner, Guard)
  EndIf
  If Guard
    PSQ.EndAppearanceEdit(MenuAppearanceOwner)
  EndIf
EndFunction

String Function GetTattooGlowModeName(Int Mode)
  If Mode == 1
    Return "$PSQ_GlowOriginal"
  ElseIf Mode == 2
    Return "$PSQ_GlowCustom"
  EndIf
  Return "$PSQ_GlowOff"
EndFunction

Int Function AddRacialCollectionRows(String Catalog, Bool AcquiredOnly, Spell[] Sources, String[] Names, String[] Races, Int[] Statuses, Int Filled, Race OwnRace)
  Int i = 0
  Int Count = jsonutil.StringListCount(Catalog, "Owner")
  While i < Count && Filled < Sources.Length
    String Owner = jsonutil.StringListGet(Catalog, "Owner", i)
    If PSQ.IsIntegrationPluginLoaded(Owner)
      Spell Source = Game.GetFormFromFile(jsonutil.IntListGet(Catalog, "primary", i), Owner) as Spell
      If Source != None && Sources.find(Source, 0) < 0
        Bool Acquired = storageutil.FormListHas(PSQ.PlayerRef as Form, "PSQ_RacialDrainAcquiredTraits", Source as Form)
        If !AcquiredOnly || Acquired
          Sources[Filled] = Source
          Names[Filled] = jsonutil.StringListGet(Catalog, "Name", i)
          Races[Filled] = jsonutil.StringListGet(Catalog, "race", i)
          Int Status = 0
          If Acquired
            Status = 1
          ElseIf PSQ.PlayerRef.HasSpell(Source as Form) || PSQ.RaceContainsTrait(OwnRace, Source)
            Status = 2
          Else
            Int GrantID = jsonutil.IntListGet(Catalog, "Grant", i)
            If GrantID != 0
              Spell Grant = Game.GetFormFromFile(GrantID, "PSQ PlayerSuccubusQuest.esm") as Spell
              If Grant != None && PSQ.PlayerRef.HasSpell(Grant as Form)
                Status = 2
              EndIf
            EndIf
          EndIf
          Statuses[Filled] = Status
          Filled += 1
        EndIf
      EndIf
    EndIf
    i += 1
  EndWhile
  Return Filled
EndFunction

Function DrawRacialCollectionGroup(Int Wanted, String Header, String[] Names, String[] Races, Int[] Statuses, Int Filled)
  Int Count = 0
  Int i = 0
  While i < Filled
    If Statuses[i] == Wanted
      Count += 1
    EndIf
    i += 1
  EndWhile
  Self.AddHeaderOption(Header, 0)
  Self.AddTextOption("$PSQ_RacialCollectionCount", Count as String, 1)
  If Count == 0
    Self.AddTextOption("$PSQ_RacialCollectionNone", "", 1)
    Return 
  EndIf
  i = 0
  While i < Filled
    If Statuses[i] == Wanted
      Self.AddTextOption(Names[i], Races[i], 0)
    EndIf
    i += 1
  EndWhile
EndFunction

Function DrawRacialTraitCollection()
  Spell[] Sources = new Spell[64]
  String[] Names = new String[64]
  String[] Races = new String[64]
  Int[] Statuses = new Int[64]
  String ActiveCatalog = PSQ.GetRacialTraitCatalog()
  Race OwnRace = PSQ.PlayerRef.GetRace()
  Int Filled = Self.AddRacialCollectionRows(ActiveCatalog, False, Sources, Names, Races, Statuses, 0, OwnRace)
  If ActiveCatalog != "PSQ/RacialTraitsVanilla"
    Filled = Self.AddRacialCollectionRows("PSQ/RacialTraitsVanilla", True, Sources, Names, Races, Statuses, Filled, OwnRace)
  EndIf
  If ActiveCatalog != "PSQ/RacialTraitsMannaz"
    Filled = Self.AddRacialCollectionRows("PSQ/RacialTraitsMannaz", True, Sources, Names, Races, Statuses, Filled, OwnRace)
  EndIf
  Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
  Self.SetCursorPosition(0)
  Self.AddHeaderOption("$PSQ_RacialCollectionTitle", 0)
  Self.AddTextOptionST("GrowthRacialBack", "$PSQ_RacialCollectionBack", "", 0)
  Self.AddEmptyOption()
  Self.DrawRacialCollectionGroup(1, "$PSQ_RacialCollectionAcquired", Names, Races, Statuses, Filled)
  Self.SetCursorPosition(1)
  String SourceLabel = "$PSQ_RacialCollectionVanilla"
  If ActiveCatalog == "PSQ/RacialTraitsMannaz"
    SourceLabel = "$PSQ_RacialCollectionMannaz"
  EndIf
  Self.AddTextOption("$PSQ_RacialCollectionSource", SourceLabel, 1)
  Self.AddEmptyOption()
  Self.AddEmptyOption()
  Self.DrawRacialCollectionGroup(0, "$PSQ_RacialCollectionMissing", Names, Races, Statuses, Filled)
  Self.AddEmptyOption()
  Self.DrawRacialCollectionGroup(2, "$PSQ_RacialCollectionOtherOwned", Names, Races, Statuses, Filled)
EndFunction

Function DrawTestTools()
  Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
  Self.SetCursorPosition(0)
  Self.AddHeaderOption("$PSQ_TestTools", 0)
  Self.AddTextOptionST("CloseTestTools", "$PSQ_TestToolsBack", "", 0)
  Self.AddEmptyOption()
  Self.AddHeaderOption("$PSQ_TransformDiagnostics", 0)
  Self.AddToggleOptionST("EquipmentDiagnostics", "$PSQ_EquipmentDiagnostics", PSQ.EnableEquipmentDiagnostics, 0)
  Self.AddEmptyOption()
  Self.AddHeaderOption("$PSQ_TestVisualHeader", 0)
  Self.AddTextOptionST("RankAnimationPreview", "$PSQ_RankAnimationPreview", "$PSQ_RankAnimationSuspended", 1)
  Self.SetCursorPosition(1)
  Self.AddHeaderOption("$PSQ_EnergySenseDiagnostics", 0)
  Actor player = Game.GetPlayer()
  String Status = "$PSQ_SenseStateOff"
  If storageutil.GetIntValue(player as Form, "PSQ_EnergySenseStartPending", 0) == 1
    Status = "$PSQ_SenseStateStarting"
  ElseIf storageutil.GetIntValue(player as Form, "PSQ_EnergySenseRuntimeActive", 0) == 1
    Status = "$PSQ_SenseStateOn"
  EndIf
  Self.AddTextOption("$PSQ_SenseStatus", Status, 1)
  Self.AddTextOption("$PSQ_SenseTargetCount", storageutil.GetIntValue(player as Form, "PSQ_SenseTracked", 0) as String + " / 24", 1)
  Self.AddTextOption("$PSQ_SenseCandidateCount", storageutil.GetIntValue(player as Form, "PSQ_SenseCandidateCount", 0) as String + " / 64", 1)
  Self.AddTextOption("$PSQ_SenseBatchPolicy", "$PSQ_SenseBatchValue", 1)
  Self.AddTextOption("$PSQ_SenseScanPolicy", "$PSQ_SenseScanValue", 1)
  Self.AddTextOption("$PSQ_SenseSliceTime", Self.GrowthNumber(storageutil.GetFloatValue(player as Form, "PSQ_SenseLastSliceSeconds", 0.0)) + " 秒", 1)
  Self.AddTextOptionST("RefreshSenseDiagnostics", "$PSQ_SenseRefresh", "$PSQ_Execute", 0)
EndFunction

;-- State -------------------------------------------
State AbilityManagementMode

  Function OnDefaultST()
    PSQ.SetAbilityManagementMode(1)
    Self.ForcePageReset()
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_ManagedAbilitiesInfo")
  EndFunction

  Function OnMenuAcceptST(Int Mode)
    If Mode >= 0 && Mode <= 2
      PSQ.SetAbilityManagementMode(Mode)
      Self.ForcePageReset()
    EndIf
  EndFunction

  Function OnMenuOpenST()
    String[] Options = new String[3]
    Options[0] = "$PSQ_ManagedAbilitiesOff"
    Options[1] = "$PSQ_ManagedAbilitiesRank"
    Options[2] = "$PSQ_ManagedAbilitiesManual"
    Self.SetMenuDialogOptions(Options)
    Self.SetMenuDialogStartIndex(PSQ.GetAbilityManagementMode())
    Self.SetMenuDialogDefaultIndex(1)
  EndFunction
EndState

;-- State -------------------------------------------
State AllowHybrid

  Function OnDefaultST()
    PSQ.AllowHybrid = True
    Self.SetToggleOptionValueST(True, False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State AlternateStartProtectionInfo

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_LALProtectionInfo")
  EndFunction
EndState

;-- State -------------------------------------------
State AproposRepairSpell

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_AproposRepairInfo")
  EndFunction

  Function OnSelectST()
    If PSQ.GetAbilityManagementMode() != 2 || !PSQ.HasAproposRepairIntegration()
      Return 
    EndIf
    PSQ.EnableAproposRepairSpell = !PSQ.EnableAproposRepairSpell
    PSQ.SyncAproposRepairSpell()
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.GetAproposRepairSpell() as Form), False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State ArousalBackend

  Function OnDefaultST()
    psqarousalruntime.SetMode(0)
    Self.ForcePageReset()
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("自动优先 SLO/SLA NG、OSL、SLA 兼容接口，再使用已注册的外部适配器。手动选择未安装的框架不会自动换用其他框架；未知欲望值不会触发强制变身。")
  EndFunction

  Function OnMenuAcceptST(Int Index)
    psqarousalruntime.SetMode(Index)
    Self.ForcePageReset()
  EndFunction

  Function OnMenuOpenST()
    Self.SetMenuDialogOptions(Self.GetArousalModeOptions())
    Self.SetMenuDialogStartIndex(psqarousalruntime.GetMode())
    Self.SetMenuDialogDefaultIndex(0)
  EndFunction
EndState

;-- State -------------------------------------------
State ArousalCapabilities

  Function OnHighlightST()
    Self.SetInfoText("读取和即时增减使用当前框架的接口。旧药剂的时间率、暴露率只在框架提供对应机制时生效；SLO NG 不支持这两个旧速率，OSL 原生模式不支持旧时间率。")
  EndFunction

  Function OnSelectST()
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State AttributeDrainMode

  Function OnDefaultST()
    Self.OnMenuAcceptST(1)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_AttributeDrainInfo")
  EndFunction

  Function OnMenuAcceptST(Int Mode)
    If Mode < 0 || Mode > 1
      Return 
    EndIf
    PSQ.AttributeDrainMode = Mode
    Self.SetMenuOptionValueST(Self.GetAttributeDrainModeName(), False, "")
  EndFunction

  Function OnMenuOpenST()
    String[] Modes = new String[2]
    Modes[0] = "$PSQ_AttributeDrainOff"
    Modes[1] = "$PSQ_AttributeDrainRank"
    Self.SetMenuDialogOptions(Modes)
    Int Selected = 0
    If PSQ.AttributeDrainMode == 1
      Selected = 1
    EndIf
    Self.SetMenuDialogStartIndex(Selected)
    Self.SetMenuDialogDefaultIndex(1)
  EndFunction
EndState

;-- State -------------------------------------------
State AutoExtractSemenPotionThreshold

  Function OnSliderAcceptST(Float value)
    PSQ.AutoExtractSemenPotionThreshold = value
    Self.SetSliderOptionValueST(value, "{0}%", False, "")
  EndFunction

  Function OnSliderOpenST()
    Self.SetSliderDialogStartValue(PSQ.AutoExtractSemenPotionThreshold)
    Self.SetSliderDialogDefaultValue(80.0)
    Self.SetSliderDialogRange(0.0, 100.0)
    Self.SetSliderDialogInterval(1.0)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_SuccubusEPACThresholdInfo")
  EndFunction
EndState

;-- State -------------------------------------------
State BecomeSuccubus

  Function OnSelectST()
    If PSQ.AlternateStartBecomePending
      PSQ.CancelAlternateStartActivation()
    ElseIf PSQ.PlayerIsSuccubus.GetValueInt() == 0
      PSQ.BecomeSuccubus()
    Else
      PSQ.QuitSuccubus()
    EndIf
    Self.SetTextOptionValueST(Self.GetBecomeSuccubusStrings(), False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State CalcMaxEnergyHealth

  Function OnSliderOpenST()
    Self.SetSliderDialogStartValue(PSQ.CalcMaxEnergyHealth)
    Self.SetSliderDialogDefaultValue(4.0)
    Self.SetSliderDialogRange(0.0, 6.0)
    Self.SetSliderDialogInterval(0.100000001)
  EndFunction

  Function OnSliderAcceptST(Float value)
    PSQ.CalcMaxEnergyHealth = value
    PSQ.PublishEnergySenseConfig()
    Self.SetSliderOptionValueST(value, "{1}", False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State CloseTestTools

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_TestToolsBackInfo")
  EndFunction

  Function OnSelectST()
    TestToolsOpen = False
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State CompatibilityRefresh

  Function OnHighlightST()
    Self.SetInfoText("重新检测兼容及飞行接口状态，并清除PSQ保存的服装、身形、发型、眼睛和外部角资源缓存。新增身形XML后，请先在Body Change NG的身体页面刷新预设，再点击本项。新增插件或替换模型、贴图后仍需重启游戏；本项不会重新应用当前外观。")
  EndFunction

  Function OnSelectST()
    If !PSQ.RequestTransformAppearanceCacheRefresh()
      Self.ShowMessage("正在载入、变身、更换外观或恢复中断状态，暂时无法刷新。请等待当前流程结束后重试。", False, "$OK", "$Cancel")
      Return
    EndIf
    PSQ.ResetWingflightProbe()
    PSQ.RefreshWingflightState()
    BodyChangeMenuPage = 0
    BodyChangeMenuCount = 0
    BodyChangeMenuOffset = 0
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State ConditionToKill

  Function OnMenuAcceptST(Int i)
    String[] Option = new String[4]
    Option[0] = "$PSQ_Unconditional"
    Option[1] = "$PSQ_WhenAggressor"
    Option[2] = "$PSQ_WhenVictim"
    Option[3] = "$PSQ_WhenBoth"
    PSQ.ConditionToKill = i
    Self.SetMenuOptionValueST(Option[i], False, "")
  EndFunction

  Function OnMenuOpenST()
    String[] Option = new String[4]
    Option[0] = "$PSQ_Unconditional"
    Option[1] = "$PSQ_WhenAggressor"
    Option[2] = "$PSQ_WhenVictim"
    Option[3] = "$PSQ_WhenBoth"
    Self.SetMenuDialogStartIndex(PSQ.ConditionToKill)
    Self.SetMenuDialogDefaultIndex(0)
    Self.SetMenuDialogOptions(Option)
  EndFunction

  Function OnHighlightST()
    If PSQ.ConditionToKill == 0
      Self.SetInfoText("$PSQ_DeathConditionInfo1")
    ElseIf PSQ.ConditionToKill == 1
      Self.SetInfoText("$PSQ_DeathConditionInfo2")
    ElseIf PSQ.ConditionToKill == 2
      Self.SetInfoText("$PSQ_DeathConditionInfo3")
    ElseIf PSQ.ConditionToKill == 3
      Self.SetInfoText("$PSQ_DeathConditionInfo4")
    EndIf
  EndFunction
EndState

;-- State -------------------------------------------
State ConditionToSoulTrap

  Function OnMenuAcceptST(Int i)
    String[] Option = new String[4]
    Option[0] = "$PSQ_Unconditional"
    Option[1] = "$PSQ_WhenAggressor"
    Option[2] = "$PSQ_WhenVictim"
    Option[3] = "$PSQ_WhenBoth"
    PSQ.ConditionToSoulTrap = i
    Self.SetMenuOptionValueST(Option[i], False, "")
  EndFunction

  Function OnMenuOpenST()
    String[] Option = new String[4]
    Option[0] = "$PSQ_Unconditional"
    Option[1] = "$PSQ_WhenAggressor"
    Option[2] = "$PSQ_WhenVictim"
    Option[3] = "$PSQ_WhenBoth"
    Self.SetMenuDialogStartIndex(PSQ.ConditionToSoulTrap)
    Self.SetMenuDialogDefaultIndex(0)
    Self.SetMenuDialogOptions(Option)
  EndFunction

  Function OnHighlightST()
    If PSQ.ConditionToSoulTrap == 0
      Self.SetInfoText("$PSQ_SoulTrapConditionInfo1")
    ElseIf PSQ.ConditionToSoulTrap == 1
      Self.SetInfoText("$PSQ_SoulTrapConditionInfo2")
    ElseIf PSQ.ConditionToSoulTrap == 2
      Self.SetInfoText("$PSQ_SoulTrapConditionInfo3")
    ElseIf PSQ.ConditionToSoulTrap == 3
      Self.SetInfoText("$PSQ_SoulTrapConditionInfo4")
    EndIf
  EndFunction
EndState

;-- State -------------------------------------------
State ContinuousAbilityMode

  Function OnDefaultST()
    Self.OnMenuAcceptST(1)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_ContinuousModeInfo")
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    PSQ.SetContinuousAbilityMode(Choice)
    Self.ForcePageReset()
  EndFunction

  Function OnMenuOpenST()
    String[] Options = new String[3]
    Options[0] = "$PSQ_ContinuousOff"
    Options[1] = "$PSQ_ContinuousRank"
    Options[2] = "$PSQ_ContinuousManual"
    Self.SetMenuDialogOptions(Options)
    Self.SetMenuDialogStartIndex(PSQ.GetContinuousAbilityMode())
    Self.SetMenuDialogDefaultIndex(1)
  EndFunction
EndState

;-- State -------------------------------------------
State CustomTattooGlowColor

  Function OnColorAcceptST(Int Color)
    PSQ.CustomTattooGlowColor = Color
    PSQ.preservetattooglowcolor = False
    PSQ.TattooGlowMode = 2
    PSQ.EnableCustomTattooGlow = True
    PSQ.ChangeBodyPaint(PSQ.GetEnergyRatio(), True)
    Self.SetColorOptionValueST(Color, False, "")
    Self.SetMenuOptionValueST(Self.GetTattooGlowModeName(2), False, "TattooGlowMode")
  EndFunction

  Function OnDefaultST()
    PSQ.CustomTattooGlowColor = 16738740
    PSQ.ChangeBodyPaint(PSQ.GetEnergyRatio(), True)
    Self.SetColorOptionValueST(16738740, False, "")
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_CustomTattooGlowInfo")
  EndFunction

  Function OnColorOpenST()
    Self.SetColorDialogStartColor(PSQ.CustomTattooGlowColor)
    Self.SetColorDialogDefaultColor(16738740)
  EndFunction
EndState

;-- State -------------------------------------------
State DragonSoulExchange

  Function OnSelectST()
    If DragonSoulExchangeMode == 0 || DragonSoulExchangeBusy
      Return 
    EndIf
    DragonSoulExchangeBusy = True
    String Confirmation = "$PSQ_DragonSoulConfirm"
    If DragonSoulExchangeMode == 1
      Confirmation = "$PSQ_DragonSoulEnergyConfirm"
    EndIf
    If Self.ShowMessage(Confirmation, True, "$Yes", "$No")
      Self.ExchangeDragonSoul()
    EndIf
    DragonSoulExchangeBusy = False
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_DragonSoulInfo")
  EndFunction
EndState

;-- State -------------------------------------------
State DrainValueMultipliers

  Function OnSliderAcceptST(Float value)
    PSQ.DrainValueMultipliers = value
    Self.SetSliderOptionValueST(value, "{2}", False, "")
  EndFunction

  Function OnSliderOpenST()
    Self.SetSliderDialogStartValue(PSQ.DrainValueMultipliers)
    Self.SetSliderDialogDefaultValue(1.0)
    Self.SetSliderDialogRange(0.050000001, 6.0)
    Self.SetSliderDialogInterval(0.050000001)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_DrainValueMultipliersInfo")
  EndFunction
EndState

;-- State -------------------------------------------
State EXPGainedMultipliers

  Function OnSliderAcceptST(Float value)
    PSQ.EXPGainedMultipliers = value
    Self.SetSliderOptionValueST(value, "{2}", False, "")
  EndFunction

  Function OnSliderOpenST()
    Self.SetSliderDialogStartValue(PSQ.EXPGainedMultipliers)
    Self.SetSliderDialogDefaultValue(1.0)
    Self.SetSliderDialogRange(0.050000001, 6.0)
    Self.SetSliderDialogInterval(0.050000001)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_EXPGainedMultipliersInfo")
  EndFunction
EndState

;-- State -------------------------------------------
State EnableCustomTattooGlow

  Function OnDefaultST()
    PSQ.EnableCustomTattooGlow = False
    PSQ.ChangeBodyPaint(PSQ.GetEnergyRatio(), True)
    Self.SetToggleOptionValueST(False, False, "")
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_CustomTattooGlowInfo")
  EndFunction

  Function OnSelectST()
    PSQ.EnableCustomTattooGlow = !PSQ.EnableCustomTattooGlow
    PSQ.ChangeBodyPaint(PSQ.GetEnergyRatio(), True)
    Self.SetToggleOptionValueST(PSQ.EnableCustomTattooGlow, False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State EnableEnergyConsumingBySuccubusSpell

  Function OnDefaultST()
    PSQ.EnableEnergyConsumingBySuccubusSpell = False
    Self.SetToggleOptionValueST(False, False, "")
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_SpellEnergyInfo")
  EndFunction

  Function OnSelectST()
    PSQ.EnableEnergyConsumingBySuccubusSpell = !PSQ.EnableEnergyConsumingBySuccubusSpell
    Self.SetToggleOptionValueST(PSQ.EnableEnergyConsumingBySuccubusSpell, False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State EnergyBarFillDirection

  Function OnSelectST()
    If SEBU.EnergyBarFillDirection == "Right"
      SEBU.EnergyBarFillDirection = "Left"
      SEBU.UpdateEnergyBarPosition()
      Self.SetTextOptionValueST(Self.GetEnergyBarFillDirectionName(), False, "")
    ElseIf SEBU.EnergyBarFillDirection == "Left"
      SEBU.EnergyBarFillDirection = "Both"
      SEBU.UpdateEnergyBarPosition()
      Self.SetTextOptionValueST(Self.GetEnergyBarFillDirectionName(), False, "")
    ElseIf SEBU.EnergyBarFillDirection == "Both"
      SEBU.EnergyBarFillDirection = "Right"
      SEBU.UpdateEnergyBarPosition()
      Self.SetTextOptionValueST(Self.GetEnergyBarFillDirectionName(), False, "")
    EndIf
  EndFunction
EndState

;-- State -------------------------------------------
State EnergySenseSpell

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_EnergySenseInfo")
  EndFunction

  Function OnSelectST()
    If PSQ.GetAbilityManagementMode() != 2 || PSQ.SuccubusRank.GetValueInt() < 4
      Return 
    EndIf
    PSQ.EnableEnergySenseSpell = !PSQ.EnableEnergySenseSpell
    PSQ.SyncEnergySenseSpell()
    Self.SetToggleOptionValueST(PSQ.PlayerRef.HasSpell(PSQ.GetEnergySenseSpell() as Form), False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State EquipmentDiagnostics

  Function OnDefaultST()
    PSQ.EnableEquipmentDiagnostics = False
    Self.SetToggleOptionValueST(False, False, "")
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_EquipmentDiagnosticsInfo")
  EndFunction

  Function OnSelectST()
    PSQ.EnableEquipmentDiagnostics = !PSQ.EnableEquipmentDiagnostics
    Self.SetToggleOptionValueST(PSQ.EnableEquipmentDiagnostics, False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State FastModeTime

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_FastModeTimeInfo")
  EndFunction

  Function OnSliderOpenST()
    Self.SetSliderDialogStartValue(PSQ.FastModeTime)
    Self.SetSliderDialogDefaultValue(60.0)
    Self.SetSliderDialogRange(0.0, 300.0)
    Self.SetSliderDialogInterval(1.0)
  EndFunction

  Function OnSliderAcceptST(Float value)
    PSQ.FastModeTime = value
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State GTSoftbodyCompatInfo

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_GTCompatInfo")
  EndFunction
EndState

;-- State -------------------------------------------
State GetCurrentColorAsMax

  Function OnSelectST()
    PSQ.GetBodyPaintData(True)
    Self.SetTextOptionValueST("$PSQ_Done", False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State GetCurrentColorAsMin

  Function OnSelectST()
    PSQ.GetBodyPaintData(False)
    Self.SetTextOptionValueST("$PSQ_Done", False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State GrowthRacialBack

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_RacialCollectionInfo")
  EndFunction

  Function OnSelectST()
    GrowthRacialListOpen = False
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State GrowthRacialTraits

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_RacialCollectionOpenInfo")
  EndFunction

  Function OnSelectST()
    GrowthRacialListOpen = True
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State GrowthStatsInfo

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_GrowthStatsInfoText")
  EndFunction

  Function OnSelectST()
    Self.ShowMessage("$PSQ_GrowthStatsInfoText", False, "$OK", "$Cancel")
  EndFunction
EndState

;-- State -------------------------------------------
State HenshinCaution

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_HenshinCautionInfo")
  EndFunction
EndState

;-- State -------------------------------------------
State InitFaction

  Function OnSelectST()
    Self.SetTextOptionValueST("$PSQ_Processing", False, "")
    PSQ.FactionInit()
    Self.SetTextOptionValueST("$PSQ_Completed", False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State LoversRestoreMult

  Function OnSliderOpenST()
    Self.SetSliderDialogStartValue(PSQ.LoversRestoreMult)
    Self.SetSliderDialogDefaultValue(1.5)
    Self.SetSliderDialogRange(1.0, 6.0)
    Self.SetSliderDialogInterval(0.100000001)
  EndFunction

  Function OnSliderAcceptST(Float value)
    PSQ.LoversRestoreMult = value
    PSQ.PublishEnergySenseConfig()
    Self.SetSliderOptionValueST(value, "{1}", False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State MinEnergyOfHuman

  Function OnSliderOpenST()
    Self.SetSliderDialogStartValue(PSQ.MinEnergyOfHuman)
    Self.SetSliderDialogDefaultValue(500.0)
    Self.SetSliderDialogRange(50.0, 2000.0)
    Self.SetSliderDialogInterval(10.0)
  EndFunction

  Function OnSliderAcceptST(Float value)
    PSQ.MinEnergyOfHuman = value
    PSQ.PublishEnergySenseConfig()
    Self.SetSliderOptionValueST(value, "{0}", False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State NFFCompatibilityInfo

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_NFFScopeInfo")
  EndFunction

  Function OnSelectST()
    Self.ShowMessage("$PSQ_NFFScopeInfo", False, "$OK", "$Cancel")
  EndFunction
EndState

;-- State -------------------------------------------
State NPCSetSkinColor

  Function OnSelectST()
    Int Color = Game.GetTintMaskColor(6, 0)
    storageutil.SetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformSkinColor", Color)
    NiOverride.AddNodeOverrideInt(SuccubusNPC as ObjectReference, True, "Face [Ovl0]", 7, -1, Color, True)
    NiOverride.AddNodeOverrideInt(SuccubusNPC as ObjectReference, True, "Body [Ovl0]", 7, -1, Color, True)
    NiOverride.AddNodeOverrideInt(SuccubusNPC as ObjectReference, True, "Feet [Ovl0]", 7, -1, Color, True)
    NiOverride.AddNodeOverrideInt(SuccubusNPC as ObjectReference, True, "Hands [Ovl0]", 7, -1, Color, True)
    Self.SetColorOptionValueST(storageutil.GetIntValue(SuccubusNPC as Form, "PSQ_NPCTransformSkinColor", 0), False, "NPCPSQSkinColor")
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_SetSkinColorInfo")
  EndFunction
EndState

;-- State -------------------------------------------
State NPCSwitchWings

  Function OnMenuOpenST()
    String[] Options = new String[12]
    Armor[] Wings = Self.GetPlayerWingChoices(False)
    Int i = 0
    While i < Wings.Length
      If Wings[i] != None
        Options[i] = Wings[i].GetName()
      Else
        Options[i] = "未安装可选翅膀资源"
      EndIf
      i += 1
    EndWhile
    Options[0] = "$PSQ_OutfitWings"
    Self.SetMenuDialogOptions(Options)
    Self.SetMenuDialogStartIndex(0)
    Self.SetMenuDialogDefaultIndex(0)
  EndFunction

  Function OnMenuAcceptST(Int i)
    Armor[] Wing = Self.GetPlayerWingChoices(False)
    If SuccubusNPC == None || i < 0 || i >= Wing.Length || Wing[i] == None
      Self.ShowMessage("$PSQ_AppearanceWingMissing", False, "$OK", "$Cancel")
      Return 
    EndIf
    Armor NPCWings = storageutil.GetFormValue(SuccubusNPC as Form, "PSQ_NPCWings", None) as Armor
    Bool HasWings = False
    If NPCWings != None && SuccubusNPC.GetItemCount(NPCWings as Form) > 0
      SuccubusNPC.RemoveItem(NPCWings as Form, SuccubusNPC.GetItemCount(NPCWings as Form), True, None)
      HasWings = True
    EndIf
    NPCWings = Wing[i]
    If HasWings
      SuccubusNPC.AddItem(NPCWings as Form, 1, True)
      SuccubusNPC.EquipItem(NPCWings as Form, False, True)
    EndIf
    storageutil.SetFormValue(SuccubusNPC as Form, "PSQ_NPCWings", NPCWings as Form)
    If i == 0
      Self.SetMenuOptionValueST("$PSQ_OutfitWings", False, "")
    Else
      Self.SetMenuOptionValueST(NPCWings.GetName(), False, "")
    EndIf
  EndFunction
EndState

;-- State -------------------------------------------
State NPCTransform

  Function OnHighlightST()
    Self.SetInfoText("NPC 的外观变换方式与玩家不同，部分情况下可能无法完整生效。")
  EndFunction
EndState

;-- State -------------------------------------------
State OpenTestTools

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_TestToolsInfo")
  EndFunction

  Function OnSelectST()
    TestToolsOpen = True
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State PlayerHumanSchlong
  Function OnMenuOpenST()
    String[] Options = new String[3]
    Options[0] = "TRX 普通"
    Options[1] = "TRX 轻甲"
    Options[2] = "TRX 重甲"
    Self.SetMenuDialogOptions(Options)
    Self.SetMenuDialogStartIndex(0)
    Self.SetMenuDialogDefaultIndex(0)
  EndFunction
  Function OnMenuAcceptST(Int i)
    If !PSQ.BeginAppearanceEdit()
      Return
    EndIf
    Int Owner = PSQ.AppearanceOperationId
    Self.ApplyPlayerHumanSchlongChoice(i, Owner, True)
    PSQ.EndAppearanceEdit(Owner)
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("引用独立 TRX 的普通、轻甲或重甲装备及其种族贴图。不再使用 PSQ 自带模型／贴图；选择后在下次创建或变身时穿戴。")
  EndFunction
EndState

;-- State -------------------------------------------
State PlayerSuccubusSchlong
  Function OnMenuOpenST()
    String[] Options = new String[3]
    Options[0] = "TRX 普通"
    Options[1] = "TRX 轻甲"
    Options[2] = "TRX 重甲"
    Self.SetMenuDialogOptions(Options)
    Self.SetMenuDialogStartIndex(0)
    Self.SetMenuDialogDefaultIndex(0)
  EndFunction
  Function OnMenuAcceptST(Int i)
    If !PSQ.BeginAppearanceEdit()
      Return
    EndIf
    Int Owner = PSQ.AppearanceOperationId
    Self.ApplyPlayerSuccubusSchlongChoice(i, Owner, True)
    PSQ.EndAppearanceEdit(Owner)
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("引用独立 TRX 的普通、轻甲或重甲装备及其种族贴图。不再使用 PSQ 自带模型／贴图；选择后在下次创建或变身时穿戴。")
  EndFunction
EndState

;-- State -------------------------------------------
State PreparePSQUninstall

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_UninstallConfirm")
  EndFunction

  Function OnSelectST()
    If !PSQ.CanPrepareUninstall()
      Self.ShowMessage("$PSQ_UninstallCannotStart", False, "$OK", "$Cancel")
      Return 
    EndIf
    If !Self.ShowMessage("$PSQ_UninstallConfirm", True, "$Yes", "$No")
      Return 
    EndIf
    If PSQ.PrepareForUninstall()
      Self.ShowMessage("$PSQ_UninstallDone", False, "$OK", "$Cancel")
    Else
      Self.ShowMessage("$PSQ_UninstallCannotStart", False, "$OK", "$Cancel")
    EndIf
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State RaceAppearanceInfo

  Function OnHighlightST()
    Self.SetInfoText("UBE 按实际种族皮肤模型识别，不因安装插件就影响普通角色。自动模式允许 Body Change 筛选的 UBE 预设；头发、眼睛仍检查种族列表。保留 UBE 身体、皮肤、原生附件和已穿服装，跳过未转换的 CBBE 服装、TRX 与淫纹。选择保留外观时也不改变身形。不切换种族、不修改 UBE 原文件。")
  EndFunction
EndState

;-- State -------------------------------------------
State RaceAppearancePolicy

  Function OnDefaultST()
    Self.OnMenuAcceptST(0)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("UBE 按实际种族皮肤模型识别，不因安装插件就影响普通角色。自动模式允许 Body Change 筛选的 UBE 预设；头发、眼睛仍检查种族列表。保留 UBE 身体、皮肤、原生附件和已穿服装，跳过未转换的 CBBE 服装、TRX 与淫纹。选择保留外观时也不改变身形。不切换种族、不修改 UBE 原文件。")
  EndFunction

  Function OnMenuAcceptST(Int Index)
    If PSQ.IsHenshined || PSQ.IsHenshinchu
      Self.ShowMessage("请先退出魅魔形态，再修改种族外观策略。", False, "$Accept", "$Cancel")
      Return 
    EndIf
    If psqracecompatibility.SetMode(PSQ.PlayerRef, Index)
      PSQ.InvalidateTransformAppearanceCache()
      Self.ForcePageReset()
    EndIf
  EndFunction

  Function OnMenuOpenST()
    Self.SetMenuDialogOptions(Self.GetRaceAppearanceModeOptions())
    Self.SetMenuDialogStartIndex(psqracecompatibility.GetMode(PSQ.PlayerRef))
    Self.SetMenuDialogDefaultIndex(0)
  EndFunction
EndState

;-- State -------------------------------------------
State RacialTraitDrainMode

  Function OnDefaultST()
    Self.OnMenuAcceptST(1)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_RacialTraitDrainInfo")
  EndFunction

  Function OnMenuAcceptST(Int Mode)
    If Mode < 0 || Mode > 1
      Return 
    EndIf
    PSQ.RacialTraitDrainMode = Mode
    Self.SetMenuOptionValueST(Self.GetRacialTraitDrainModeName(), False, "")
  EndFunction

  Function OnMenuOpenST()
    String[] Modes = new String[2]
    Modes[0] = "$PSQ_AttributeDrainOff"
    Modes[1] = "$PSQ_RacialTraitDrainRank"
    Self.SetMenuDialogOptions(Modes)
    Self.SetMenuDialogStartIndex(PSQ.RacialTraitDrainMode)
    Self.SetMenuDialogDefaultIndex(1)
  EndFunction
EndState

;-- State -------------------------------------------
State RankAnimationPreview

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_RankAnimationSuspendedInfo")
  EndFunction

  Function OnSelectST()
    Self.ShowMessage("$PSQ_RankAnimationSuspendedInfo", False, "$OK", "$Cancel")
  EndFunction
EndState

;-- State -------------------------------------------
State RankMagicCostReduction

  Function OnDefaultST()
    PSQ.EnableRankMagicCostReduction = True
    PSQ.SyncRankMagicCostReduction()
    Self.ForcePageReset()
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_RankMagicCostInfo")
  EndFunction

  Function OnSelectST()
    PSQ.EnableRankMagicCostReduction = !PSQ.EnableRankMagicCostReduction
    PSQ.SyncRankMagicCostReduction()
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State RankShoutBonusEnabled

  Function OnSelectST()
    PSQ.EnableRankShoutCooldownBonus = !PSQ.EnableRankShoutCooldownBonus
    PSQ.UpdateRankShoutCooldownBonus()
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State RankSpeedBonusEnabled

  Function OnDefaultST()
    PSQ.EnableRankSpeedBonus = True
    PSQ.Satiety(0.0)
    Self.ForcePageReset()
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_RankSpeedEnabledInfo")
  EndFunction

  Function OnSelectST()
    PSQ.EnableRankSpeedBonus = !PSQ.EnableRankSpeedBonus
    PSQ.Satiety(0.0)
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State RecoverAppearance

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_AppearanceRecoveryInfo")
  EndFunction

  Function OnSelectST()
    If PSQ.RetryInterruptedAppearance()
      Self.ShowMessage("$PSQ_AppearanceRecoveryQueued", False, "$OK", "$Cancel")
    EndIf
  EndFunction
EndState

;-- State -------------------------------------------
State RefreshSenseDiagnostics

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_EnergySenseDiagnosticsInfo")
  EndFunction

  Function OnSelectST()
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State RegisterEFF

  Function OnSelectST()
    If !PSQ.IsIntegrationPluginLoaded("EFFCore.esm")
      Self.SetTextOptionValueST("$PSQ_CompatMissing", False, "")
      Return 
    EndIf
    Self.SetTextOptionValueST("$PSQ_Processing", False, "")
    PSQ.RegisterEFF()
    Self.SetTextOptionValueST("$PSQ_Completed", False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State RegisteriNeed

  Function OnSelectST()
    If !PSQ.IsIntegrationPluginLoaded("iNeed.esp")
      Self.SetTextOptionValueST("$PSQ_CompatMissing", False, "")
      Return 
    EndIf
    Self.SetTextOptionValueST("$PSQ_Processing", False, "")
    PSQ.RegisteriNeed()
    Self.SetTextOptionValueST("$PSQ_Completed", False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State ResetRankShoutBonus

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_ResetShoutBonusInfo")
  EndFunction

  Function OnSelectST()
    PSQ.ResetRankShoutCooldownBonus()
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------

;-- State -------------------------------------------
State SatiationBuffs

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_SuccubusBuffTextInfo")
  EndFunction
EndState

;-- State -------------------------------------------
State SetHairColor

  Function OnSelectST()
    If !PSQ.BeginAppearanceEdit()
      Return 
    EndIf
    Int MenuAppearanceOwner = PSQ.AppearanceOperationId
    If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, True)
      Return 
    EndIf
    Int PendingAppearanceValue1 = PSQ.PlayerRef.GetLeveledActorBase().GetHairColor().GetColor()
    If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, True)
      Return 
    EndIf
    PSQ.PSQSuccubusHairColorInt = PendingAppearanceValue1
    If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, True)
      Return 
    EndIf
    PSQ.SyncTransformHairColor(MenuAppearanceOwner, True)
    If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, True)
      Return 
    EndIf
    Self.SetColorOptionValueST(PSQ.PSQSuccubusHairColorInt, False, "PSQSuccubusHairColorInt")
    PSQ.EndAppearanceEdit(MenuAppearanceOwner)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_SethairColorInfo")
  EndFunction
EndState

;-- State -------------------------------------------
State SetSkinColor

  Function OnSelectST()
    If !PSQ.BeginAppearanceEdit()
      Return 
    EndIf
    Int MenuAppearanceOwner = PSQ.AppearanceOperationId
    If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, True)
      Return 
    EndIf
    Int PendingAppearanceValue1 = Game.GetTintMaskColor(6, 0)
    If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, True)
      Return 
    EndIf
    PSQ.PSQSkinColor = PendingAppearanceValue1
    If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, True)
      Return 
    EndIf
    Int PendingAppearanceValue2 = colorcomponent.GetAlpha(PSQ.PSQSkinColor)
    If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, True)
      Return 
    EndIf
    PSQ.PSQSkinColorAlpha = PendingAppearanceValue2
    If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, True)
      Return 
    EndIf
    Self.SetSliderOptionValueST(PSQ.PSQSkinColorAlpha as Float, "{0}", False, "HenshinSkinColorfulness")
    If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, True)
      Return 
    EndIf
    Self.SetColorOptionValueST(PSQ.PSQSkinColor, False, "PSQSkinColor")
    PSQ.EndAppearanceEdit(MenuAppearanceOwner)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_SetSkinColorInfo")
  EndFunction
EndState

;-- State -------------------------------------------
State SkillDrainMode

  Function OnDefaultST()
    Self.OnMenuAcceptST(2)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_SkillDrainModeInfo")
  EndFunction

  Function OnMenuAcceptST(Int Mode)
    If Mode >= 0 && Mode <= 2
      PSQ.SkillDrainMode = Mode
      Self.SetMenuOptionValueST(Self.GetSkillDrainModeName(Mode), False, "")
    EndIf
  EndFunction

  Function OnMenuOpenST()
    String[] Modes = new String[3]
    Modes[0] = "$PSQ_SkillDrainOff"
    Modes[1] = "$PSQ_SkillDrainFixed"
    Modes[2] = "$PSQ_SkillDrainRank"
    Self.SetMenuDialogOptions(Modes)
    Self.SetMenuDialogStartIndex(PSQ.SkillDrainMode)
    Self.SetMenuDialogDefaultIndex(2)
  EndFunction
EndState

;-- State -------------------------------------------
State SpellSwichNotice

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_SpellSwichNoticeInfo")
  EndFunction
EndState

;-- State -------------------------------------------
State StopEnergySenseNow

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_EnergySenseForceOffInfo")
  EndFunction

  Function OnSelectST()
    psqenergysenseruntime.Stop(Game.GetPlayer(), True, True)
  EndFunction
EndState

;-- State -------------------------------------------
State SuccubusEyeMaterial

  Function OnDefaultST()
    Self.OnMenuAcceptST(0)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_SelectEyeMaterialInfo")
  EndFunction

  Function OnMenuAcceptST(Int i)
    If !PSQ.BeginAppearanceEdit()
      Return 
    EndIf
    Int MenuAppearanceOwner = PSQ.AppearanceOperationId
    If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, True)
      Return 
    EndIf
    Self.ApplyPlayerEyeChoice(i, MenuAppearanceOwner, True)
    PSQ.EndAppearanceEdit(MenuAppearanceOwner)
  EndFunction

  Function OnMenuOpenST()
    Int Count = PSQ.GetSuccubusEyeMaterialCount()
    If Count < 0 || Count > 127
      Return 
    EndIf
    String[] Options = Utility.CreateStringArray(Count + 1, "")
    Options[0] = "$PSQ_EyeNoChange"
    Int i = 0
    While i < Count
      Options[i + 1] = PSQ.GetSuccubusEyeMaterialName(i + 1)
      If PSQ.GetExternalEyeTexture(i + 1, -1, False) == None
        Options[i + 1] = Options[i + 1] + "（缺少Tullius Eyes或对应材质）"
      EndIf
      i += 1
    EndWhile
    Int Selected = 0
    If PSQ.HenshinEyes
      Selected = PSQ.SuccubusEyeMaterialSelection
      If Selected < 1 || Selected > Count
        Selected = 1
      EndIf
    EndIf
    Self.SetMenuDialogOptions(Options)
    Self.SetMenuDialogStartIndex(Selected)
    Self.SetMenuDialogDefaultIndex(0)
  EndFunction
EndState

;-- State -------------------------------------------
State SuccubusTattooSelection

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_SelectSuccubusTattooInfo")
  EndFunction

  Function OnMenuAcceptST(Int i)
    If !PSQ.BeginAppearanceEdit()
      Return 
    EndIf
    Int MenuAppearanceOwner = PSQ.AppearanceOperationId
    If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, True)
      Return 
    EndIf
    Self.ApplyPlayerTattooChoice(i, MenuAppearanceOwner, True)
    PSQ.EndAppearanceEdit(MenuAppearanceOwner)
  EndFunction

  Function OnMenuOpenST()
    Self.SetMenuDialogStartIndex(Self.GetSuccubusTattooSelection())
    Self.SetMenuDialogDefaultIndex(0)
    Self.SetMenuDialogOptions(Self.GetSuccubusTattooNames())
  EndFunction
EndState

;-- State -------------------------------------------
State SwitchWings

  Function OnDefaultST()
    Self.OnMenuAcceptST(0)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_WingsSwitchInfo")
  EndFunction

  Function OnMenuOpenST()
    Self.OpenBodyMatchedWingMenu()
  EndFunction

  Function OnMenuAcceptST(Int i)
    If i > 0
      If !Self.IsOutfitMenuIdentityCurrent("PSQ_WingChoices") || i >= storageutil.IntListCount(Self, "PSQ_WingChoices")
        Self.ShowMessage("服装列表已变化，请重新打开菜单。", False, "$OK", "$Cancel")
        Return
      EndIf
      i = storageutil.IntListGet(Self, "PSQ_WingChoices", i)
    EndIf
    If !PSQ.BeginAppearanceEdit()
      Return 
    EndIf
    Int MenuAppearanceOwner = PSQ.AppearanceOperationId
    If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, True)
      Return 
    EndIf
    Self.ApplyPlayerWingChoice(i, MenuAppearanceOwner, True)
    PSQ.EndAppearanceEdit(MenuAppearanceOwner)
  EndFunction
EndState

;-- State -------------------------------------------
State TattooGlowMode

  Function OnDefaultST()
    PSQ.SetTattooGlowMode(0)
    Self.ForcePageReset()
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_TattooGlowModeInfo")
  EndFunction

  Function OnMenuAcceptST(Int Index)
    If Index >= 0 && Index <= 2
      PSQ.SetTattooGlowMode(Index)
      Self.ForcePageReset()
    EndIf
  EndFunction

  Function OnMenuOpenST()
    String[] Options = new String[3]
    Options[0] = "$PSQ_GlowOff"
    Options[1] = "$PSQ_GlowOriginal"
    Options[2] = "$PSQ_GlowCustom"
    Self.SetMenuDialogOptions(Options)
    Self.SetMenuDialogStartIndex(PSQ.GetTattooGlowMode())
    Self.SetMenuDialogDefaultIndex(0)
  EndFunction
EndState

;-- State -------------------------------------------
State ThrallSkillsBack

  Function OnSelectST()
    ThrallSkillDetailSlot = -1
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State TransformCompatibilityInfo

  Function OnSelectST()
    Self.ShowMessage("$PSQ_CompatTransformNotesInfo", False, "$OK", "$Cancel")
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_CompatTransformNotesInfo")
  EndFunction
EndState

;-- State -------------------------------------------
State TransformHairMenu

  Function OnDefaultST()
    Self.OnMenuAcceptST(0)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_TransformHairInfo")
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    If !PSQ.BeginAppearanceEdit()
      Return 
    EndIf
    Int MenuAppearanceOwner = PSQ.AppearanceOperationId
    If !PSQ.IsAppearanceOperationCurrent(MenuAppearanceOwner, True)
      Return 
    EndIf
    Self.ApplyPlayerHairChoice(Choice, MenuAppearanceOwner, True)
    PSQ.EndAppearanceEdit(MenuAppearanceOwner)
  EndFunction

  Function OnMenuOpenST()
    String[] Options = new String[5]
    Int i = 0
    While i < 5
      Options[i] = Self.GetTransformHairLabel(i)
      i += 1
    EndWhile
    Self.SetMenuDialogOptions(Options)
    Self.SetMenuDialogStartIndex(PSQ.SuccubusHairSelection)
    Self.SetMenuDialogDefaultIndex(0)
  EndFunction
EndState

;-- State -------------------------------------------
State TransformPart0

  Function OnDefaultST()
    Self.AcceptIndependentPartMenu(0, 0)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_IndependentPartInfo")
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    Self.AcceptIndependentPartMenu(0, Choice)
  EndFunction

  Function OnMenuOpenST()
    Self.OpenIndependentPartMenu(0)
  EndFunction
EndState

;-- State -------------------------------------------
State TransformPart1

  Function OnDefaultST()
    Self.AcceptIndependentPartMenu(1, 0)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_IndependentPartInfo")
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    Self.AcceptIndependentPartMenu(1, Choice)
  EndFunction

  Function OnMenuOpenST()
    Self.OpenIndependentPartMenu(1)
  EndFunction
EndState

;-- State -------------------------------------------
State TransformPart2

  Function OnDefaultST()
    Self.AcceptIndependentPartMenu(2, 0)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_IndependentPartInfo")
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    Self.AcceptIndependentPartMenu(2, Choice)
  EndFunction

  Function OnMenuOpenST()
    Self.OpenIndependentPartMenu(2)
  EndFunction
EndState

;-- State -------------------------------------------
State TransformPart3

  Function OnDefaultST()
    Self.AcceptIndependentPartMenu(3, 0)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_IndependentPartInfo")
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    Self.AcceptIndependentPartMenu(3, Choice)
  EndFunction

  Function OnMenuOpenST()
    Self.OpenIndependentPartMenu(3)
  EndFunction
EndState

;-- State -------------------------------------------
State TransformPart4

  Function OnDefaultST()
    Self.AcceptIndependentPartMenu(4, 0)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_IndependentPartInfo")
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    Self.AcceptIndependentPartMenu(4, Choice)
  EndFunction

  Function OnMenuOpenST()
    Self.OpenIndependentPartMenu(4)
  EndFunction
EndState

;-- State -------------------------------------------
State UninstallInstructions

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_UninstallDone")
  EndFunction

  Function OnSelectST()
    Self.ShowMessage("$PSQ_UninstallDone", False, "$OK", "$Cancel")
  EndFunction
EndState

;-- State -------------------------------------------
State loversdrainmult

  Function OnSliderOpenST()
    Self.SetSliderDialogStartValue(PSQ.loversdrainmult)
    Self.SetSliderDialogDefaultValue(2.0)
    Self.SetSliderDialogRange(1.0, 6.0)
    Self.SetSliderDialogInterval(0.100000001)
  EndFunction

  Function OnSliderAcceptST(Float value)
    PSQ.loversdrainmult = value
    Self.SetSliderOptionValueST(value, "{1}", False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State preservetattooglowcolor

  Function OnDefaultST()
    PSQ.preservetattooglowcolor = True
    PSQ.ChangeBodyPaint(PSQ.GetEnergyRatio(), True)
    Self.SetToggleOptionValueST(True, False, "")
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_OriginalTattooGlowInfo")
  EndFunction

  Function OnSelectST()
    PSQ.preservetattooglowcolor = !PSQ.preservetattooglowcolor
    If PSQ.preservetattooglowcolor
      PSQ.EnableCustomTattooGlow = True
      Self.SetToggleOptionValueST(True, False, "EnableCustomTattooGlow")
    EndIf
    PSQ.ChangeBodyPaint(PSQ.GetEnergyRatio(), True)
    Self.SetToggleOptionValueST(PSQ.preservetattooglowcolor, False, "")
  EndFunction
EndState

;-- State -------------------------------------------
State thralleyes0

  Function OnDefaultST()
    Self.AcceptSuccubusThrallEyesMenu(0, 0)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_ThrallEyesInfo")
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    Self.AcceptSuccubusThrallEyesMenu(0, Choice)
  EndFunction

  Function OnMenuOpenST()
    Self.OpenSuccubusThrallEyesMenu(0)
  EndFunction
EndState

;-- State -------------------------------------------
State thralleyes1

  Function OnDefaultST()
    Self.AcceptSuccubusThrallEyesMenu(1, 0)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_ThrallEyesInfo")
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    Self.AcceptSuccubusThrallEyesMenu(1, Choice)
  EndFunction

  Function OnMenuOpenST()
    Self.OpenSuccubusThrallEyesMenu(1)
  EndFunction
EndState

;-- State -------------------------------------------
State thralleyes2

  Function OnDefaultST()
    Self.AcceptSuccubusThrallEyesMenu(2, 0)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_ThrallEyesInfo")
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    Self.AcceptSuccubusThrallEyesMenu(2, Choice)
  EndFunction

  Function OnMenuOpenST()
    Self.OpenSuccubusThrallEyesMenu(2)
  EndFunction
EndState

;-- State -------------------------------------------
State thralleyes3

  Function OnDefaultST()
    Self.AcceptSuccubusThrallEyesMenu(3, 0)
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_ThrallEyesInfo")
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    Self.AcceptSuccubusThrallEyesMenu(3, Choice)
  EndFunction

  Function OnMenuOpenST()
    Self.OpenSuccubusThrallEyesMenu(3)
  EndFunction
EndState

;-- State -------------------------------------------
State thrallskilldetails0

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_ThrallSkillInfo")
  EndFunction

  Function OnSelectST()
    ThrallSkillDetailSlot = 0
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State thrallskilldetails1

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_ThrallSkillInfo")
  EndFunction

  Function OnSelectST()
    ThrallSkillDetailSlot = 1
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State thrallskilldetails2

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_ThrallSkillInfo")
  EndFunction

  Function OnSelectST()
    ThrallSkillDetailSlot = 2
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State thrallskilldetails3

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_ThrallSkillInfo")
  EndFunction

  Function OnSelectST()
    ThrallSkillDetailSlot = 3
    Self.ForcePageReset()
  EndFunction
EndState

;-- State -------------------------------------------
State thralltattoo0

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_ThrallTattooInfo")
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    Self.AcceptSuccubusThrallTattooMenu(0, Choice)
  EndFunction

  Function OnMenuOpenST()
    Self.OpenSuccubusThrallTattooMenu(0)
  EndFunction
EndState

;-- State -------------------------------------------
State thralltattoo1

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_ThrallTattooInfo")
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    Self.AcceptSuccubusThrallTattooMenu(1, Choice)
  EndFunction

  Function OnMenuOpenST()
    Self.OpenSuccubusThrallTattooMenu(1)
  EndFunction
EndState

;-- State -------------------------------------------
State thralltattoo2

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_ThrallTattooInfo")
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    Self.AcceptSuccubusThrallTattooMenu(2, Choice)
  EndFunction

  Function OnMenuOpenST()
    Self.OpenSuccubusThrallTattooMenu(2)
  EndFunction
EndState

;-- State -------------------------------------------
State thralltattoo3

  Function OnHighlightST()
    Self.SetInfoText("$PSQ_ThrallTattooInfo")
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    Self.AcceptSuccubusThrallTattooMenu(3, Choice)
  EndFunction

  Function OnMenuOpenST()
    Self.OpenSuccubusThrallTattooMenu(3)
  EndFunction
EndState

State FrameworkSwitchInfo
  Function OnSelectST()
    Self.ShowMessage("PSQ会在重启并读档后重新识别旧SexLab/P+与欲望接口。请先结束互动，在地面另存并备份，再更换框架。PSQ只清理自己的待结算记录；不能保证其他模组或旧存档可以任意互换框架。", False, "$PSQ_Accept", "$PSQ_Cancel")
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("更换框架需退出游戏后操作，不可同时叠加两套核心。旧存档先备份测试。")
  EndFunction
EndState



String Function GetEnergyBarFillDirectionName()
  If SEBU.EnergyBarFillDirection == "Left"
    Return "$PSQ_EnergyBarFillLeft"
  ElseIf SEBU.EnergyBarFillDirection == "Right"
    Return "$PSQ_EnergyBarFillRight"
  EndIf
  Return "$PSQ_EnergyBarFillBoth"
EndFunction

String Function GetEnergyBarDisplayName(Int Mode)
  If Mode == 2
    Return "$PSQ_EnergyBarAngular"
  ElseIf Mode == 1
    Return "$PSQ_EnergyBarClassic"
  EndIf
  Return "$PSQ_EnergyBarOff"
EndFunction

State EnergyBarDisplay
  Function OnHighlightST()
    Self.SetInfoText("$PSQ_EnergyBarDisplayInfo")
  EndFunction

  Function OnMenuOpenST()
    String[] Modes = new String[3]
    Modes[0] = "$PSQ_EnergyBarOff"
    Modes[1] = "$PSQ_EnergyBarClassic"
    Modes[2] = "$PSQ_EnergyBarAngular"
    Self.SetMenuDialogOptions(Modes)
    Self.SetMenuDialogStartIndex(SEBU.GetEnergyBarDisplayMode())
    Self.SetMenuDialogDefaultIndex(1)
  EndFunction

  Function OnMenuAcceptST(Int Mode)
    If Mode >= 0 && Mode <= 2
      SEBU.SetEnergyBarDisplayMode(Mode)
      Self.SetMenuOptionValueST(Self.GetEnergyBarDisplayName(SEBU.GetEnergyBarDisplayMode()), False, "")
    EndIf
  EndFunction

  Function OnDefaultST()
    Self.OnMenuAcceptST(1)
  EndFunction
EndState


State FastMode
  Function OnHighlightST()
    Self.SetInfoText("$PSQ_FastModeInfo")
  EndFunction
EndState


State OSYRNFlightInfo
  Function OnHighlightST()
    Self.SetInfoText("OSYRN使用自身的菜单与按键控制飞行；PSQ会让位飞行动作并保护悬浮和起降状态。OSYRN只支持Mage's Leap动画版，不支持Gravity重力版。检测到SmoothJump组件不代表能唯一判断版本，请核对安装包。更改飞行设置后可点击本页刷新，重新检测接口。")
  EndFunction
EndState

State ShinanoOutfitInfo
  Event OnHighlightST()
    SetInfoText("检测gui-SucubusSister Shinano.esp及适配资源。第六套沿用PSQ上衣组合、六部位独立选择与原槽位；原作目录不放补丁。旧PSQ第六套已移除；原作未启用或资源不完整时不可选择，旧保存配置临时使用默认服装。更新或停用原作后需重启游戏并读档。")
  EndEvent
EndState

State PSQSkinColor
  Function OnColorOpenST()
    Self.SetColorDialogStartColor(PSQ.PSQSkinColor)
    Self.SetColorDialogDefaultColor(PSQ.PSQSkinColor)
  EndFunction
  Function OnColorAcceptST(Int Color)
    PSQ.SaveAppearanceColor(0, Color)
    Self.SetColorOptionValueST(Color, False, "PSQSkinColor")
    Self.SetInfoText("肤色已保存。启用皮肤变色后，关闭菜单应用；变身进行中会等待安全时机。")
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("设置变身肤色。正常形态与变身形态均可保存；关闭菜单后刷新，不修改原肤色备份。")
  EndFunction
EndState

State PSQSuccubusHairColorInt
  Function OnColorOpenST()
    Self.SetColorDialogStartColor(PSQ.PSQSuccubusHairColorInt)
    Self.SetColorDialogDefaultColor(PSQ.PSQSuccubusHairColorInt)
  EndFunction
  Function OnColorAcceptST(Int Color)
    PSQ.SaveAppearanceColor(1, Color)
    Self.SetColorOptionValueST(Color, False, "PSQSuccubusHairColorInt")
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("设置变身发色。两种形态均可保存，启用发色变换后在关闭菜单时刷新。")
  EndFunction
EndState

State HenshinSkin
  Function OnSelectST()
    PSQ.SetAppearanceColorEnabled(0, !PSQ.HenshinSkin)
    Self.SetToggleOptionValueST(PSQ.HenshinSkin, False, "HenshinSkin")
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("启用变身肤色。关闭后在退出菜单时恢复备份的原肤色；不替换身体贴图。")
  EndFunction
EndState

State HenshinSkinColorfulness
  Function OnSliderOpenST()
    Self.SetSliderDialogStartValue(PSQ.PSQSkinColorAlpha as Float)
    Self.SetSliderDialogDefaultValue(255.0)
    Self.SetSliderDialogRange(0.0, 255.0)
    Self.SetSliderDialogInterval(1.0)
  EndFunction
  Function OnSliderAcceptST(Float Value)
    PSQ.SaveAppearanceColor(2, Value as Int)
    Self.SetSliderOptionValueST(PSQ.PSQSkinColorAlpha as Float, "{0}", False, "HenshinSkinColorfulness")
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("肤色覆盖强度：0为透明，255为完整覆盖。关闭菜单后刷新。")
  EndFunction
EndState

Function AddTRXFutaSkinMenus()
  Self.AddMenuOptionST("PlayerSuccubusSchlong", "$PSQ_PlayerSuccubusSchlong", PSQ.GetTRXFutaLabel(True), 0)
  Self.AddMenuOptionST("HumanTRXFutaSkin", "普通形态扶她皮肤", PSQ.GetBCNGFutaSkinName(PSQ.GetBCNGFutaSetting(False)), 0)
  Self.AddMenuOptionST("SuccubusTRXFutaSkin", "魅魔形态扶她皮肤", PSQ.GetBCNGFutaSkinName(PSQ.GetBCNGFutaSetting(True)), 0)
  Self.AddTextOption("Body Change 扶她管理", PSQ.GetBCNGFutaStatus(), 1)
EndFunction

Function OpenTRXFutaSkinMenu()
  String Key = "PSQ_BCNGFutaMenu_" + Self.GetState()
  String[] IDs = PSQ.GetBCNGFutaSkinIDs()
  String[] Names = papyrusutil.StringArray(IDs.Length, "")
  Int Start = 0
  String Current = PSQ.GetBCNGFutaSetting(Self.GetState() == "SuccubusTRXFutaSkin")
  If Current == ""
    Current = "@follow"
  EndIf
  storageutil.StringListClear(Self, Key)
  storageutil.SetIntValue(Self, Key + "_Load", PSQ.GetBCNGFutaLoadEpoch())
  Int i = 0
  While i < IDs.Length
    storageutil.StringListAdd(Self, Key, IDs[i], True)
    Names[i] = PSQ.GetBCNGFutaSkinName(IDs[i])
    If IDs[i] == Current
      Start = i
    EndIf
    i += 1
  EndWhile
  Self.SetMenuDialogOptions(Names)
  Self.SetMenuDialogStartIndex(Start)
  Self.SetMenuDialogDefaultIndex(0)
EndFunction

Function AcceptTRXFutaSkinMenu(Int Index, Bool Transformed)
  String Key = "PSQ_BCNGFutaMenu_" + Self.GetState()
  If storageutil.GetIntValue(Self, Key + "_Load", -1) != PSQ.GetBCNGFutaLoadEpoch() || Index < 0 || Index >= storageutil.StringListCount(Self, Key)
    Self.ShowMessage("皮肤列表已失效，请重新打开列表。", False, "$OK", "$Cancel")
    Return
  EndIf
  String ID = storageutil.StringListGet(Self, Key, Index)
  PSQ.SetBCNGFutaSetting(Transformed, ID)
  Self.SetMenuOptionValueST(PSQ.GetBCNGFutaSkinName(PSQ.GetBCNGFutaSetting(Transformed)), False, "")
EndFunction

State HumanTRXFutaSkin
  Function OnMenuOpenST()
    Self.OpenTRXFutaSkinMenu()
  EndFunction
  Function OnMenuAcceptST(Int Index)
    Self.AcceptTRXFutaSkinMenu(Index, False)
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("普通形态的TRX皮肤，由Body Change应用。跟随Body Change保留其现有选择；TRX装备默认贴图使用原部件贴图。默认包仅供人类，兽族保留TRX种族贴图。")
  EndFunction
EndState

State SuccubusTRXFutaSkin
  Function OnMenuOpenST()
    Self.OpenTRXFutaSkinMenu()
  EndFunction
  Function OnMenuAcceptST(Int Index)
    Self.AcceptTRXFutaSkinMenu(Index, True)
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("魅魔形态的TRX皮肤，由Body Change应用。退出变身恢复普通形态设置；关闭扶她时恢复接管前选择。在BCNG界面主动换皮肤会优先保留，重选PSQ皮肤可重新接管。")
  EndFunction
EndState

Function DrawBodyFutaPage()
  Self.SetCursorFillMode(Self.TOP_TO_BOTTOM)
  Self.SetCursorPosition(0)
  Self.AddHeaderOption("$PSQ_BodyShapeChange", 0)
  Self.AddToggleOptionST("EnableHeightChangeSuccubus", "$PSQ_EnableHeightChangeSuccubus", PSQ.EnableHeightChangeSuccubus, 0)
  Self.AddSliderOptionST("SuccubusHeight", "$PSQ_SuccubusHeight", PSQ.SuccubusHeight, "{2}", 0)
  Self.AddToggleOptionST("EnableButtChangeSuccubus", "$PSQ_EnableButtChangeSuccubus", PSQ.EnableButtChangeSuccubus, 0)
  Self.AddSliderOptionST("SuccubusButt", "$PSQ_SuccubusButt", PSQ.SuccubusButt, "{2}", 0)
  Self.AddEmptyOption()
  Self.AddHeaderOption("FUTA：部件与皮肤", 0)
  Self.AddMenuOptionST("PlayerHumanSchlong", "$PSQ_PlayerHumanSchlong", PSQ.GetTRXFutaLabel(False), 0)
  Self.AddTRXFutaSkinMenus()
  Self.AddToggleOptionST("HenshinPenis", "变身时创建扶她部件", PSQ.HenshinPenis, 0)
  Self.AddToggleOptionST("AutoGenderSwitch", "$PSQ_AutoGenderSwitch", PSQ.AutoGenderSwitch, 0)
  Self.AddToggleOptionST("EnableFutanariPower", "$PSQ_EnableFutanariPower", PSQ.EnableFutanariPower, 0)
  Int Flags = 1
  If PSQ.GetAbilityManagementMode() == 2
    Flags = 0
  EndIf
  Self.AddHeaderOption("FUTA：法术与热键", 0)
  Self.AddToggleOptionST("CreatePenisSpellSelf", PSQ.CreatePenisSpellSelf.GetName(), PSQ.PlayerRef.HasSpell(PSQ.CreatePenisSpellSelf), Flags)
  Self.AddToggleOptionST("CreatePenisSpellOther", PSQ.CreatePenisSpellOther.GetName(), PSQ.PlayerRef.HasSpell(PSQ.CreatePenisSpellOther), Flags)
  Self.AddKeyMapOptionST("HotkeyCreatePenisSelf", "$PSQ_HotkeyCreatePenisSelf", PSQ.HotkeyCreatePenisSelf, 0)
  Self.AddKeyMapOptionST("HotkeyGenitalsNode", "$PSQ_HotkeyGenitalsNode", PSQ.HotkeyGenitalsNode, 0)
  Self.AddKeyMapOptionST("HotkeyScrotumNode", "$PSQ_HotkeyScrotumNode", PSQ.HotkeyScrotumNode, 0)
  Self.SetCursorPosition(1)
  Self.AddHeaderOption("FUTA：普通形态大小", 0)
  Self.AddSliderOptionST("TRXFutaHumanSize", "阴茎大小倍率", PSQ.GetTRXFutaSize(PSQ.PlayerRef, False, False), "{2} 倍", 0)
  Self.AddSliderOptionST("TRXFutaHumanScrotum", "阴囊大小倍率", PSQ.GetTRXFutaSize(PSQ.PlayerRef, True, False), "{2} 倍", 0)
  Self.AddHeaderOption("FUTA：魅魔形态大小", 0)
  Self.AddToggleOptionST("EnableGenitalsChangeSuccubus", "使用独立阴茎大小", PSQ.EnableGenitalsChangeSuccubus, 0)
  Self.AddSliderOptionST("SuccubusGenitals", "阴茎大小倍率", PSQ.GetTRXFutaSize(PSQ.PlayerRef, False, True), "{2} 倍", 0)
  Self.AddToggleOptionST("EnableScrotumChangeSuccubus", "使用独立阴囊大小", PSQ.EnableScrotumChangeSuccubus, 0)
  Self.AddSliderOptionST("SuccubusScrotum", "阴囊大小倍率", PSQ.GetTRXFutaSize(PSQ.PlayerRef, True, True), "{2} 倍", 0)
  Self.AddTextOption("未开启独立大小", "沿用普通形态倍率", 1)
  Self.AddHeaderOption("FUTA：当前NPC", 0)
  If SuccubusNPC != None && SuccubusNPC != PSQ.PlayerRef
    Self.AddTextOption("SexLab 当前目标", SuccubusNPC.GetLeveledActorBase().GetName(), 1)
    Self.AddToggleOptionST("NPCHenshinPenis", "NPC变身时创建扶她部件", storageutil.GetIntValue(SuccubusNPC, "PSQ_NPCTransformPenis", PSQ.HenshinPenis as Int) as Bool, 0)
    Self.AddSliderOptionST("NPCSuccubusGenitals", "NPC变身阴茎倍率", PSQ.GetTRXFutaSize(SuccubusNPC, False, True), "{2} 倍", 0)
    Self.AddSliderOptionST("NPCSuccubusScrotum", "NPC变身阴囊倍率", PSQ.GetTRXFutaSize(SuccubusNPC, True, True), "{2} 倍", 0)
  Else
    Self.AddTextOption("未选择NPC", "先在SexLab选择目标", 1)
  EndIf
EndFunction

State TRXFutaHumanSize
  Function OnSliderOpenST()
    Self.SetSliderDialogStartValue(PSQ.GetTRXFutaSize(PSQ.PlayerRef, False, False))
    Self.SetSliderDialogDefaultValue(1.0)
    Self.SetSliderDialogRange(0.25, 3.0)
    Self.SetSliderDialogInterval(0.05)
  EndFunction
  Function OnSliderAcceptST(Float Value)
    PSQ.SetTRXFutaSize(False, False, Value)
    Self.SetSliderOptionValueST(PSQ.GetTRXFutaSize(PSQ.PlayerRef, False, False), "{2} 倍", False, "")
  EndFunction
  Function OnDefaultST()
    Self.OnSliderAcceptST(1.0)
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("TRX骨骼大小倍率，范围0.25～3倍。1倍不额外放大，保留SOS等模组的缩放。确认后关闭菜单刷新；调整魅魔倍率会开启对应独立大小。只修改PSQ自己的缩放层。")
  EndFunction
EndState

State TRXFutaHumanScrotum
  Function OnSliderOpenST()
    Self.SetSliderDialogStartValue(PSQ.GetTRXFutaSize(PSQ.PlayerRef, True, False))
    Self.SetSliderDialogDefaultValue(1.0)
    Self.SetSliderDialogRange(0.25, 3.0)
    Self.SetSliderDialogInterval(0.05)
  EndFunction
  Function OnSliderAcceptST(Float Value)
    PSQ.SetTRXFutaSize(False, True, Value)
    Self.SetSliderOptionValueST(PSQ.GetTRXFutaSize(PSQ.PlayerRef, True, False), "{2} 倍", False, "")
  EndFunction
  Function OnDefaultST()
    Self.OnSliderAcceptST(1.0)
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("TRX骨骼大小倍率，范围0.25～3倍。1倍不额外放大，保留SOS等模组的缩放。确认后关闭菜单刷新；调整魅魔倍率会开启对应独立大小。只修改PSQ自己的缩放层。")
  EndFunction
EndState

State SuccubusGenitals
  Function OnSliderOpenST()
    Self.SetSliderDialogStartValue(PSQ.GetTRXFutaSize(PSQ.PlayerRef, False, True))
    Self.SetSliderDialogDefaultValue(1.0)
    Self.SetSliderDialogRange(0.25, 3.0)
    Self.SetSliderDialogInterval(0.05)
  EndFunction
  Function OnSliderAcceptST(Float Value)
    PSQ.SetTRXFutaSize(True, False, Value)
    Self.SetSliderOptionValueST(PSQ.GetTRXFutaSize(PSQ.PlayerRef, False, True), "{2} 倍", False, "")
  EndFunction
  Function OnDefaultST()
    Self.OnSliderAcceptST(1.0)
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("TRX骨骼大小倍率，范围0.25～3倍。1倍不额外放大，保留SOS等模组的缩放。确认后关闭菜单刷新；调整魅魔倍率会开启对应独立大小。只修改PSQ自己的缩放层。")
  EndFunction
EndState

State SuccubusScrotum
  Function OnSliderOpenST()
    Self.SetSliderDialogStartValue(PSQ.GetTRXFutaSize(PSQ.PlayerRef, True, True))
    Self.SetSliderDialogDefaultValue(1.0)
    Self.SetSliderDialogRange(0.25, 3.0)
    Self.SetSliderDialogInterval(0.05)
  EndFunction
  Function OnSliderAcceptST(Float Value)
    PSQ.SetTRXFutaSize(True, True, Value)
    Self.SetSliderOptionValueST(PSQ.GetTRXFutaSize(PSQ.PlayerRef, True, True), "{2} 倍", False, "")
  EndFunction
  Function OnDefaultST()
    Self.OnSliderAcceptST(1.0)
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("TRX骨骼大小倍率，范围0.25～3倍。1倍不额外放大，保留SOS等模组的缩放。确认后关闭菜单刷新；调整魅魔倍率会开启对应独立大小。只修改PSQ自己的缩放层。")
  EndFunction
EndState

State NPCSuccubusGenitals
  Function OnSliderOpenST()
    Self.SetSliderDialogStartValue(PSQ.GetTRXFutaSize(SuccubusNPC, False, True))
    Self.SetSliderDialogDefaultValue(1.0)
    Self.SetSliderDialogRange(0.25, 3.0)
    Self.SetSliderDialogInterval(0.05)
  EndFunction
  Function OnSliderAcceptST(Float Value)
    PSQ.SetTRXNPCFutaSize(SuccubusNPC, False, Value)
    Self.SetSliderOptionValueST(PSQ.GetTRXFutaSize(SuccubusNPC, False, True), "{2} 倍", False, "")
  EndFunction
  Function OnDefaultST()
    Self.OnSliderAcceptST(1.0)
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("TRX骨骼大小倍率，范围0.25～3倍。1倍不额外放大，保留SOS等模组的缩放。确认后关闭菜单刷新；调整魅魔倍率会开启对应独立大小。只修改PSQ自己的缩放层。")
  EndFunction
EndState

State NPCSuccubusScrotum
  Function OnSliderOpenST()
    Self.SetSliderDialogStartValue(PSQ.GetTRXFutaSize(SuccubusNPC, True, True))
    Self.SetSliderDialogDefaultValue(1.0)
    Self.SetSliderDialogRange(0.25, 3.0)
    Self.SetSliderDialogInterval(0.05)
  EndFunction
  Function OnSliderAcceptST(Float Value)
    PSQ.SetTRXNPCFutaSize(SuccubusNPC, True, Value)
    Self.SetSliderOptionValueST(PSQ.GetTRXFutaSize(SuccubusNPC, True, True), "{2} 倍", False, "")
  EndFunction
  Function OnDefaultST()
    Self.OnSliderAcceptST(1.0)
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("TRX骨骼大小倍率，范围0.25～3倍。1倍不额外放大，保留SOS等模组的缩放。确认后关闭菜单刷新；调整魅魔倍率会开启对应独立大小。只修改PSQ自己的缩放层。")
  EndFunction
EndState

State EnableGenitalsChangeSuccubus
  Function OnSelectST()
    PSQ.EnableGenitalsChangeSuccubus = !PSQ.EnableGenitalsChangeSuccubus
    PSQ.QueueTRXFutaSize(PSQ.PlayerRef)
    Self.ForcePageReset()
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("开启后使用魅魔形态独立大小，关闭后沿用普通形态大小。已穿戴TRX部件时，关闭菜单后立即刷新。")
  EndFunction
EndState

State EnableScrotumChangeSuccubus
  Function OnSelectST()
    PSQ.EnableScrotumChangeSuccubus = !PSQ.EnableScrotumChangeSuccubus
    PSQ.QueueTRXFutaSize(PSQ.PlayerRef)
    Self.ForcePageReset()
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("开启后使用魅魔形态独立大小，关闭后沿用普通形态大小。已穿戴TRX部件时，关闭菜单后立即刷新。")
  EndFunction
EndState

Function AddTransformSkinControls()
  Int Flags = 1
  If PSQ.HasBCNGSkinAPI()
    Flags = 0
  EndIf
  Self.AddMenuOptionST("BCNGTransformSkin", "变身皮肤", PSQ.GetBCNGTransformSkinName(), Flags)
  Self.AddToggleOptionST("HenshinSkin", "$PSQ_EnableHenshinSkin", PSQ.HenshinSkin, 0)
  Int HideFlags = 1
  If PSQ.HasPSQAppearanceAPI()
    HideFlags = 0
  EndIf
  Self.AddToggleOptionST("HideOriginalAccessories", "隐藏原有附加装备", PSQ.GetOriginalEquipmentHideEnabled(), HideFlags)
EndFunction

State BCNGTransformSkin
  Function OnMenuOpenST()
    If !PSQ.HasBCNGSkinAPI()
      Return
    EndIf
    String[] IDs = BCNGPSQBridge.GetSkinIds(PSQ.PlayerRef)
    Int Count = IDs.Length
    Int SkinPageCount = (Count + 119) / 120
    If SkinPageCount < 1
      SkinPageCount = 1
    EndIf
    Int SkinPage = storageutil.GetIntValue(Self, "PSQ_SkinMenuPage", 0)
    If SkinPage < 0 || SkinPage >= SkinPageCount
      SkinPage = 0
    EndIf
    storageutil.SetIntValue(Self, "PSQ_SkinMenuPage", SkinPage)
    storageutil.SetIntValue(Self, "PSQ_SkinMenuPages", SkinPageCount)
    storageutil.SetIntValue(Self, "PSQ_SkinMenuEpoch", PSQ.GetBCNGFutaLoadEpoch())
    storageutil.SetFormValue(Self, "PSQ_SkinMenuRace", PSQ.PlayerRef.GetRace())
    storageutil.StringListClear(Self, "PSQ_SkinMenuIDs")
    Int Offset = SkinPage * 120
    Int Visible = Count - Offset
    If Visible > 120
      Visible = 120
    EndIf
    String[] Options = papyrusutil.StringArray(Visible + 3, "")
    Options[0] = "上一页"
    Options[1] = "下一页"
    Options[2] = "保留当前皮肤"
    Int i = 0
    Int Selected = 2
    String Current = storageutil.GetStringValue(PSQ, "PSQ_BCNGTransformSkin", "")
    While i < Visible
      String ID = IDs[Offset + i]
      storageutil.StringListAdd(Self, "PSQ_SkinMenuIDs", ID, True)
      Options[i + 3] = BCNGPSQBridge.GetSkinName(ID)
      If ID == Current
        Selected = i + 3
      EndIf
      i += 1
    EndWhile
    Self.SetMenuDialogOptions(Options)
    Self.SetMenuDialogStartIndex(Selected)
    Self.SetMenuDialogDefaultIndex(2)
  EndFunction

  Function OnMenuAcceptST(Int Choice)
    If !PSQ.HasBCNGSkinAPI() || storageutil.GetIntValue(Self, "PSQ_SkinMenuEpoch", -1) != PSQ.GetBCNGFutaLoadEpoch() || storageutil.GetFormValue(Self, "PSQ_SkinMenuRace", None) != PSQ.PlayerRef.GetRace()
      Return
    EndIf
    If Choice == 0 || Choice == 1
      Int SkinPageCount = storageutil.GetIntValue(Self, "PSQ_SkinMenuPages", 1)
      Int SkinPage = storageutil.GetIntValue(Self, "PSQ_SkinMenuPage", 0)
      If Choice == 0
        SkinPage = (SkinPage + SkinPageCount - 1) % SkinPageCount
      Else
        SkinPage = (SkinPage + 1) % SkinPageCount
      EndIf
      storageutil.SetIntValue(Self, "PSQ_SkinMenuPage", SkinPage)
      Debug.Notification("皮肤列表页码已切换，再次打开选择器查看。")
      Return
    EndIf
    String ID = ""
    If Choice >= 3 && Choice < storageutil.StringListCount(Self, "PSQ_SkinMenuIDs") + 3
      ID = storageutil.StringListGet(Self, "PSQ_SkinMenuIDs", Choice - 3)
    ElseIf Choice != 2
      Return
    EndIf
    If PSQ.SetBCNGTransformSkin(ID)
      Self.SetMenuOptionValueST(PSQ.GetBCNGTransformSkinName(), False, "")
    EndIf
  EndFunction

  Function OnDefaultST()
    PSQ.SetBCNGTransformSkin("")
    Self.SetMenuOptionValueST(PSQ.GetBCNGTransformSkinName(), False, "")
  EndFunction

  Function OnHighlightST()
    Self.SetInfoText("由 Body Change NG 1.3.8 与对应PSQ接口补丁提供皮肤目录，按实际性别、种族和身体图集筛选。变身时切换，退出恢复；保留当前皮肤表示不额外切换。期间在Body Change手动选择另一皮肤时优先保留该选择。不会转换CBBE/UBE贴图。更新Body Change后需匹配的新补丁，缺少独立本体时不可用。")
  EndFunction
EndState

State HideOriginalAccessories
  Function OnSelectST()
    PSQ.SetOriginalEquipmentHideEnabled(!PSQ.GetOriginalEquipmentHideEnabled())
    Self.SetToggleOptionValueST(PSQ.GetOriginalEquipmentHideEnabled(), False, "")
  EndFunction
  Function OnDefaultST()
    PSQ.SetOriginalEquipmentHideEnabled(True)
    Self.SetToggleOptionValueST(True, False, "")
  EndFunction
  Function OnHighlightST()
    Self.SetInfoText("变身时隐藏仍穿着的原有附加装备，保留其护甲、附魔及其他装备效果；不移入储物空间。与变身衣服冲突的槽位仍正常替换，帽子和包含身体的模型保留卸装规则。退出恢复可见，读档和模型重建后重新检查。关闭会立即恢复可见，之后变身使用原卸下方式。隐藏不保证停止物理运算或提高帧率；缺少PSQ外观组件时回退原流程。")
  EndFunction
EndState


Function SaveOutfitMenuIdentity(String Key)
  storageutil.SetFormValue(Self, Key + "Race", PSQ.PlayerRef.GetRace())
  storageutil.SetIntValue(Self, Key + "UBE", psqracecompatibility.IsUBEActor(PSQ.PlayerRef) as Int)
EndFunction

Bool Function IsOutfitMenuIdentityCurrent(String Key)
  Return storageutil.GetFormValue(Self, Key + "Race", None) == PSQ.PlayerRef.GetRace() && storageutil.GetIntValue(Self, Key + "UBE", -1) == (psqracecompatibility.IsUBEActor(PSQ.PlayerRef) as Int)
EndFunction

Function OpenBodyMatchedWingMenu()
  String Key = "PSQ_WingChoices"
  storageutil.IntListClear(Self, Key)
  storageutil.IntListAdd(Self, Key, 0, True)
  Self.SaveOutfitMenuIdentity(Key)
  Armor[] Wings = Self.GetPlayerWingChoices(True)
  Int i = 0
  While i < Wings.Length
    If Wings[i] != None && (i >= 8 || PSQ.CanUseTransformOutfitChoice(5, i + 1))
      storageutil.IntListAdd(Self, Key, i + 1, True)
    EndIf
    i += 1
  EndWhile
  Int Count = storageutil.IntListCount(Self, Key)
  String[] Options = PapyrusUtil.StringArray(Count, "")
  Options[0] = "$PSQ_WingsSwitchOff"
  Int Start = 0
  i = 1
  While i < Count
    Int Raw = storageutil.IntListGet(Self, Key, i)
    If Raw <= 8
      Options[i] = Self.GetOutfitWingLabel(Raw)
    Else
      Options[i] = Wings[Raw - 1].GetName()
    EndIf
    If PSQ.HenshinWings && Wings[Raw - 1] == PSQ.GetTransformPartArmor(5)
      Start = i
    EndIf
    i += 1
  EndWhile
  Self.SetMenuDialogOptions(Options)
  Self.SetMenuDialogStartIndex(Start)
  Self.SetMenuDialogDefaultIndex(0)
EndFunction
