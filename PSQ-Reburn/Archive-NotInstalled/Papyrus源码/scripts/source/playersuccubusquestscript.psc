ScriptName playersuccubusquestscript Extends Quest

Int Property AWUWingID Auto Hidden
Spell AWUOwnedWing
; Only set when PSQ observed the control missing before a successful wing grant.
; Existing saves begin with no evidence of ownership.
Bool AWUMayRemoveSpell
Bool AWUMayRemovePower
Int AWUControlGeneration
Int AWUControlChecks

String Function GetAWUWingName(Int ID)
  Int Index = JsonUtil.IntListFind("PSQ/AWUWings", "ids", ID)
  If Index >= 0
    Return "AWU · " + JsonUtil.StringListGet("PSQ/AWUWings", "names", Index)
  EndIf
  Return "$PSQ_WingsSwitchOff"
EndFunction

Spell Function GetAWUWing(Int ID)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.AnimatedWing34(ID)
  EndIf
  If ID <= 0 || !Self.IsIntegrationPluginLoaded("Animated Wings Ultimate.esp")
    Return None
  EndIf
  Return Game.GetFormFromFile(ID, "Animated Wings Ultimate.esp") as Spell
EndFunction

Function SyncAWUWing()
  If PlayerRef == None || (AWUWingID == 0 && AWUOwnedWing == None)
    Return
  EndIf
  Spell Desired
  If IsHenshined && HenshinWings && !UninstallPrepared && !UninstallCleanupBusy
    Desired = Self.GetAWUWing(AWUWingID)
  EndIf
  Bool ReplacingOwned = AWUOwnedWing != None && PlayerRef.HasSpell(AWUOwnedWing)
  If AWUOwnedWing == Desired && (Desired == None || ReplacingOwned)
    Return
  EndIf
  AWUControlGeneration += 1
  AWUControlChecks = 0
  If AWUOwnedWing != None && AWUOwnedWing != Desired
    PlayerRef.RemoveSpell(AWUOwnedWing)
    AWUOwnedWing = None
  EndIf
  If Desired != None && !PlayerRef.HasSpell(Desired)
    Keyword WingsPresent = Game.GetFormFromFile(2048, "Animated Wings Ultimate.esp") as Keyword
    Keyword Persistent = Game.GetFormFromFile(2051, "Animated Wings Ultimate.esp") as Keyword
    If (Persistent && PlayerRef.HasMagicEffectWithKeyword(Persistent)) || (!ReplacingOwned && WingsPresent && PlayerRef.HasMagicEffectWithKeyword(WingsPresent))
      Debug.Notification("已有独立启用的 AWU 翅膀，本次保留当前翼型。")
      Return
    EndIf
    Spell Toggle = Self.GetAWUWing(2652)
    Spell Power = Self.GetAWUWing(2653)
    Bool MissingSpell = Toggle != None && !PlayerRef.HasSpell(Toggle)
    Bool MissingPower = Power != None && !PlayerRef.HasSpell(Power)
    If PlayerRef.AddSpell(Desired, False)
      AWUMayRemoveSpell = AWUMayRemoveSpell || MissingSpell
      AWUMayRemovePower = AWUMayRemovePower || MissingPower
      AWUOwnedWing = Desired
    EndIf
  EndIf
EndFunction


; AWU grants its controls in OnEffectStart. Its OnEffectFinish releases the
; ancillary effect, but leaves both controls in the spellbook. Check twice
; on independent maintenance updates so a queued grant is also seen.
Function SettleAWUWingControls()
  If (!AWUMayRemoveSpell && !AWUMayRemovePower) || AWUOwnedWing != None || PlayerRef == None
    Return
  EndIf
  Int Generation = AWUControlGeneration
  Bool External = !Self.IsIntegrationPluginLoaded("Animated Wings Ultimate.esp")
  Bool Preserve = False
  If !External
    Keyword Persistent = Game.GetFormFromFile(2051, "Animated Wings Ultimate.esp") as Keyword
    Keyword Present = Game.GetFormFromFile(2048, "Animated Wings Ultimate.esp") as Keyword
    ; Independently obtained wings may be toggled off and still need the controls.
    External = Persistent && PlayerRef.HasMagicEffectWithKeyword(Persistent)
    Preserve = Present && PlayerRef.HasMagicEffectWithKeyword(Present)
  EndIf
  If Generation != AWUControlGeneration || AWUOwnedWing != None
    Return
  EndIf
  If !External && !Preserve
    Spell Toggle = Self.GetAWUWing(2652)
    Spell Power = Self.GetAWUWing(2653)
    If AWUMayRemoveSpell && Toggle != None && PlayerRef.HasSpell(Toggle) && Generation == AWUControlGeneration && AWUOwnedWing == None
      PlayerRef.RemoveSpell(Toggle)
    EndIf
    If AWUMayRemovePower && Power != None && PlayerRef.HasSpell(Power) && Generation == AWUControlGeneration && AWUOwnedWing == None
      PlayerRef.RemoveSpell(Power)
    EndIf
  EndIf
  If Generation != AWUControlGeneration || AWUOwnedWing != None
    Return
  EndIf
  AWUControlChecks += 1
  If External || AWUControlChecks >= 2
    AWUMayRemoveSpell = False
    AWUMayRemovePower = False
    AWUControlChecks = 0
  EndIf
EndFunction

Bool WingflightHasFlyingVar
Bool WingflightHasHoverVar
Bool WingflightHasTakeoffVar
Bool WingflightHasLandingVar
Bool WingflightHasPSQVar
Int WingflightProbeLoadEpoch = -1
Int WingflightProbeAttempts = 0
Int WingflightProbeGeneration = 0
Float WingflightNextQueryAt = 0.0

Int PSQEquipmentMorphTicket = 0
Int PSQEquipmentMorphOwner = -1
Int PSQEquipmentMorphLoad = -1

;-- Variables ---------------------------------------
String BCNGSelectedPresetId = ""
String[] BCNGBodyPresetIds
Int BCNGLegacyMorphCleanupEpoch = -1
Bool BCNGLegacyMorphsRetired = False
Bool BCNGBodyNeedsSync = True
Bool BCNGBodyOwned = False
Bool BCNGBodyClearOnly = False
Int BCNGBodyRequest = 0
Int BCNGBodyRequestOwner = -1
Int BCNGBodyRequestLoad = -1
Bool BCNGBodyRequestActive = False
String BCNGBodyRequestPreset = ""
Float BCNGBodyRequestStarted = 0.0
Int BCNGBodyAPIVerifiedLoad = -1
Int BCNGBodyAppliedLoad = -1
String BCNGBodyAppliedPreset = ""
Int BCNGBodyStatus = 0
Int ActiveDigestionGeneration = 0
Quest AlternateStartChargen
Bool AlternateStartChecked = False
Float AlternateStartReleaseAfter = -1.0
Bool AlternateStartReleased = False
Bool AlternateStartResumePending = False
Int AppearanceCacheRevision = 0
Float AppearanceLastProgress = 0.0
Int AppearanceInvalidatedLoad = -1
Float AppearanceRecoveryAfter = 0.0
Bool AppearanceRecoveryRequested = False
Bool AppearanceSlowNotified = False
Bool AppliedBellyMorphMode = False
Float AppliedBellyScale = -1.0
Float AppliedBreastScale = -1.0
Float StableAppliedContinuousCarry = -1.0
Float StableAppliedContinuousHealth = -1.0
Float StableAppliedContinuousMagicka = -1.0
Int StableAppliedContinuousMode = -1
Int StableAppliedContinuousRank = -1
Float StableAppliedContinuousStamina = -1.0
Float StableAppliedContinuousUnarmed = -1.0
Float AppliedEnergyDisplayPercent = -1.0
Bool AppliedInflationViaSLIF = False
Int AppliedSLIFBackend = -1
Float AppliedMovementBonus = 0.0
Bool AppliedMovementValid = False
Int AppliedRankMagicCostTier = -1
Float AppliedSLIFBelly = -1.0
Float AppliedSLIFBreast = -1.0
Float AppliedSLIFBreastBase = -1.0
Float[] StableAppliedSatiationMagnitudes
Spell StableAppliedSatiationSpell
Float[] AppliedTransformBodyBaseHigh
Float[] AppliedTransformBodyBaseLow
Float[] AppliedTransformBodyHigh
Float[] AppliedTransformBodyLow
String AppliedTransformBodyName = ""
Int AppliedTransformBodyRevision = -1
String[] AppliedTransformBodySliders
Bool AppliedTransformBodyValid = False
Float AppliedTransformBodyWeight = -1.0
TextureSet AppliedTransformEyeTexture
Bool AproposRepairBusy = False
Float AproposRepairReserved = 0.0
Bool AproposRepairVoiceSlotMigrated = False
Bool AttributeDrainBusy = False
Float BPGAlphaDef = 2.0
Float BPGCurrentAlpha
Float BPGTintColorMaxBlue = 0.0
Float BPGTintColorMaxGreen = 0.0
Float BPGTintColorMaxRed = 255.0
Float BPGTintColorTempBlue
Float BPGTintColorTempGreen
Float BPGTintColorTempRed
Int BPGTintCurrentColor
Float BPGTintDefBlue = 0.0
Float BPGTintDefGreen = 0.0
Float BPGTintDefRed = 255.0
Float BPTintColorMaxBlue = 0.0
Float BPTintColorMaxGreen = 0.0
Float BPTintColorMaxRed = 255.0
Float BPTintColorTempBlue
Float BPTintColorTempGreen
Float BPTintColorTempRed
Int BPTintCurrentColor
Float BPTintDefBlue = 0.0
Float BPTintDefGreen = 0.0
Float BPTintDefRed = 255.0
Bool BodySelectionRefreshBusy = False
Float[] StableCachedSatiationInputs
Bool ContinuousSyncBusy = False
Bool ContinuousSyncPending = False
Armor[] DefaultSuccubusOutfit
String[] DrainSkillNames
Actor[] EmptyActorArray
ArmorAddon[] EmptyArmorAddonArray
Armor[] EmptyArmorArray
Bool[] EmptyBoolArray
Float[] EmptyFloatArray
Form[] EmptyFormArray
HeadPart[] EmptyHeadPartArray
Int[] EmptyIntArray
String[] EmptyStringArray
Spell EnergyDisplayAbilityA
Spell EnergyDisplayAbilityB
Float EnergySenseLastToggleTime = -1.0
Bool EnergySenseRegistrationBusy = False
Bool EnergySenseVoiceSlotMigrated = False
Bool FHUActiveDigestionFinished = False
Bool FHUActiveDigestionWaiting = False
Float FHUTransferAmount = 0.0
Float FHUTransferBeforeAnal = 0.0
Float FHUTransferBeforeVaginal = 0.0
Float FHUTransferConversion = 100.0
Float FHUTransferDeadline = 0.0
String FHUTransferEvent = ""
Int FHUTransferPool = 0
String FHUTransferPoolKey = ""
Bool FHUTransferReceiptBusy = False
Int FHUTransferReceiptEpoch = 0
Form[] OriginalCopyForms
String[] OriginalCopyKeys
Bool HasOriginalCopyKeys
Int FHUTransferSerial = 0
Int FHUTransferSettlementSerial = -1
Float FHUTransferStartingTotal = 0.0
Bool FHUTransferUncertain = False
Actor[] Fish
Int FishCount
Bool ForceTransformBuffRefresh = False
Bool GTSoftbodyCacheAvailable = False
Bool GTSoftbodyCacheReady = False
Bool IsMilking
Int LastRankAnimation = 0
Bool ManagedAbilitiesBusy = False
Bool ManagedAbilitiesInitialized = False
Bool[] ManualContinuousChoices
Bool ManualDigestionBusy = False
Bool[] ManualManagedAbilities
Actor[] NPCEnergyThrallCache
Int NPCEnergyThrallCachePublishedRevision = -1
Bool NPCEnergyThrallCacheReady = False
Int NPCEnergyThrallCacheRevision = 0
Bool NightEyeProceeding
Armor[] OptionalHornArmors
Bool OptionalHornCatalogReady = False
Int OptionalHornCount = 0
String[] OptionalHornKeys
String[] OptionalHornNames
String OptionalHornSelectedKey = ""
Armor OrgArmorTemp
Armor OutfitDefaultV2_0
Armor OutfitDefaultV2_1
Armor OutfitDefaultV2_2
Armor OutfitDefaultV2_3
Armor OutfitDefaultV2_4
Armor OutfitDefaultV2_5
Bool OutfitDefaultsV2Ready = False
Bool OutfitSwitchBusy = False
Form[] TransformEquipmentRecoveryItems
Int EquipmentRecoveryRequest = 0
Int EquipmentRecoveryRequestOwner = -1
Int EquipmentRecoveryRequestLoad = -1
Bool EquipmentRecoveryRequestQueued = False
Int PSQSexSceneEpoch = 0
Int FastModeSceneSerial = 0
Int FastModeCallbackGeneration = 0
String FastModeEndClaimKey = ""
Int PPlusCallbacksPending = 0
Float[] PPlusDrainTimes
Int[] PPlusOrgasmCounts
Actor[] PPlusSceneActors
Bool PPlusSceneClosed = False
Bool PPlusSettlementBusy = False
Int PPlusThreadID = -1
Float PSQAppliedJumpHeight = 76.0
Bool PSQJumpHeightOwned = False
Bool PSQJumpHeightYielded = False
ArmorAddon[] PSQOutfitAddonCache
Bool PSQOutfitModelsNormalized = False
Float PSQSavedJumpHeight = 76.0
Int PendingRankAnimation = 0
Race PlayerAppearanceRace
Bool RacialTraitDrainBusy = False
Bool RacialUISyncBusy = False
Bool RankAnimationPlaybackBusy = False
Bool RankAnimationPreviewPending = False
Float RankAnimationReadyAt = 0.0
Bool RankAnimationRetryBusy = False
Int RankAnimationRetryEpoch = 0
Bool RankMagicCostBusy = False
Bool RetiredWingMigrationDone = False
Bool RetirementPoolsPending = False
Float RetirementSavedHealth = 0.0
Float RetirementSavedMagicka = 0.0
Float RetirementSavedStamina = 0.0
Bool SLIFOutputPending = False
Int RemovedInflationCleanedLoadEpoch = -1
Float RemovedInflationNextSourceCheck = -1.0
Int RemovedReproductionCleanedLoadEpoch = -1
Float SatiationLastAttributeRefresh = -10.0
Bool SatiationRefreshBusy = False
Bool SatiationRefreshPending = False
Int SatiationTimedRefreshEpoch = 0
Bool SatiationTimedRefreshQueued = False
Spell SatiatySpell1
Spell SatiatySpell2
Bool SkillDrainBusy = False
Actor[] Slots
Bool StatPoolEditBusy = False
Int StatPoolEditEpoch = 0
String TattooPresentationKey = ""
Bool TattooPresentationNeedsApply = True
Int TattooPresentationRevision = 0
Bool TattooPresentationValid = False
Bool ThrallConversionBusy = False
Int ThrallBondGeneration = 0
Bool ThrallSkillGrowthBusy = False
Int ThrallSkillGrowthGeneration = 0
Int TransformAttributesRefilledOwner = -1
Float[] TransformBodyBaseHigh
Float[] TransformBodyBaseLow
Bool TransformBodyCatalogReady = False
Bool TransformBodyDataReady = False
Float[] TransformBodyHigh
Float[] TransformBodyLow
String[] TransformBodyNames
String[] TransformBodySliders
Bool TransformBuffRefreshPending = False
Int TransformCachedBodyPreset = -1
Bool TransformClockActive = False
Float TransformClockDays = 0.0
Bool TransformClockReady = False
Float TransformClockReal = 0.0
Float TransformClockScale = 0.0
GlobalVariable TransformClockTimeScale
Bool TransformEyeCatalogReady = False
Int[] TransformEyeIds
String[] TransformEyeNames
String[] TransformEyePlugins
Bool[] TransformEyeResolved
Form[] TransformEyeTextures
HeadPart[] TransformHairCache
Bool[] TransformHairResolved
Int[] TransformInventoryAdded
Int[] TransformInventoryBaseline
Form[] TransformInventoryItems
Form[] DeferredTransformClaims25
Bool TransformInventoryLedgerReady = False
Armor[] TransformOutfitCache
Int TransformPresetCatalogVersion = 0
String TransformPresetName = ""
Form[] TransformProtectedArmorCache
Bool WingflightBridgeReady = False
Float WingflightPublishedJump = -1.0
Int WingflightPublishedKey = -1
Int WingflightPublishedPolicy = -1

Int AppliedContinuousMode = -1
Int AppliedContinuousRank = -1
Float AppliedContinuousHealth = -1.0
Float AppliedContinuousMagicka = -1.0
Float AppliedContinuousStamina = -1.0
Float AppliedContinuousCarry = -1.0
Float AppliedContinuousUnarmed = -1.0
Float[] CachedSatiationInputs
Float[] AppliedSatiationMagnitudes
Spell AppliedSatiationSpell
Bool StatCachesMigrated = False
Bool ContinuousRecordSyncPending = True
Bool TransformRecordSyncPending = True
Bool SatiationRecordSyncPending = True
Float[] StableTransformMagnitudes

; Load generation belongs to the player alias OnPlayerLoadGame event.
Bool StrongCarryInitialized = False
Int StrongCarryLegacyTotal = 0
Int StrongCarryLegacyRetained = -1
Int StrongCarryRevision = 0
Int StrongCarryApplied = 0
Bool StrongCarryPending = True
Bool StrongCarryBusy = False
Bool ReviewStrongCarry = True
Bool ReviewContinuousCarry = True
Bool ReviewTransformCarry = True
Int StrongBodyMenuTicket = 0
Int StrongBodyMenuLoad = -1
Float StrongBodyMenuLastUse = 0.0
Int PSQLoadEpoch = 0
Bool TransformLoadInitializing = False
Int QueuedTransformEpoch = -1
Bool PSQReloadBusy = False
Int PSQReloadBusyEpoch = -1
Int PSQReloadCompletedEpoch = -1
Int RacialUISyncEpoch = -1

Int TransformPoolsPrimedOwner = -1
Float[] PrimedTransformPoolValues
Int PrimedTransformPoolLoad = -1
Int TransformRefillBusyOwner = -1
Int DeferredTransformRefillRequest = 0
Int DeferredTransformRefillOwner = -1
Int DeferredTransformRefillLoadEpoch = -1
Float DeferredTransformRefillUntil = 0.0
Float[] DeferredTransformRefillFloors
String DeferredTransformRefillClaimKey = ""
Int TransformEntryLoadEpoch = -1

;-- Properties --------------------------------------
Int Property AbilityManagementMode = 1 Auto hidden
Keyword Property ActorTypeUndead Auto
Bool Property AdjustMinEnergyOfHuman = True Auto hidden
Bool Property AllowAnalPregnancy Auto hidden
Bool Property AllowDrainFromBeast = True Auto hidden
Bool Property AllowDrainFromFemale = True Auto hidden
Bool Property AllowDrainFromUndead Auto hidden
GlobalVariable Property AllowForceFeed Auto
Bool Property AllowHenshinAddExposure Auto hidden
Bool Property AllowHenshinConsumeEnergy Auto hidden
Bool Property AllowHybrid = True Auto hidden
Bool Property AllowKill = True Auto hidden
GlobalVariable Property AllowSleepFeed Auto
GlobalVariable Property AllowSneakFeed Auto
GlobalVariable Property AllowTeamMateFeed Auto
Bool Property AlternateStartBecomePending = False Auto hidden
GlobalVariable Property AnimationEnergyPercent Auto hidden
Bool Property AppearanceEditBusy = False Auto hidden
Int Property AppearanceOperationId = 0 Auto hidden
String Property AppearanceOperationStage = "" Auto hidden
Bool Property AppearanceRecoveryInProgress = False Auto hidden
Bool Property AppearanceRecoveryPending = False Auto hidden
Bool Property AppearanceSnapshotReady = False Auto hidden
Int Property AppearanceTransformDirection = 0 Auto hidden
Float Property AppliedRankShoutCooldownReduction = 0.0 Auto hidden
Int Property AproposRepairTicket = 0 Auto hidden
Bool Property ArousedForceDeTransform Auto hidden
Bool Property ArousedForceTransform Auto hidden
Int Property AttributeDrainMode = 1 Auto hidden
Bool Property AutoExtractSemenPotion Auto hidden
Float Property AutoExtractSemenPotionThreshold = 90.0 Auto hidden
Bool Property AutoGenderSwitch = True Auto hidden
Float Property BPGAlphaEnd = 0.0 Auto hidden
Float Property BPGAlphaStart = 2.0 Auto hidden
Int Property BPGTintColorEnd = 0 Auto hidden
Int Property BPGTintColorStart = 16711680 Auto hidden
Int Property BPTintColorEnd = -16777216 Auto hidden
Int Property BPTintColorStart = -65536 Auto hidden
Float Property BellyScaleMax = 6.0 Auto hidden
Float Property BreastScaleMax = 4.0 Auto hidden
Quest Property C00 Auto
Float Property CalcMaxEnergyHealth = 6.0 Auto hidden
Int Property CanFlyingLevel = 4 Auto hidden
Bool Property CanWalkOnTheWater Auto hidden
Float Property CarryBuffDec = 0.200000003 Auto hidden
Float Property CarryBuffInc = 0.400000006 Auto hidden
Bool Property ChargeFull Auto hidden
Float Property ChargeValueAuto = 1000.0 Auto hidden
Int Property CharmSpellAmmo Auto hidden
Int Property ConditionToKill = 3 Auto hidden
Int Property ConditionToSoulTrap Auto hidden
Float Property ConsumeTimer Auto hidden
Int Property ContinuousAbilityMode = 1 Auto hidden
Spell Property CreatePenisSpellOther Auto
Spell Property CreatePenisSpellSelf Auto
Bool Property CumInflationAnal = True Auto hidden
Float Property CumInflationIncrement = 10.0 Auto hidden
Bool Property CumInflationOral = True Auto hidden
Spell Property CumInflationSpell Auto
Float Property CumInflationValue Auto hidden
Int Property CustomTattooGlowColor = 16738740 Auto hidden
Float Property DeTransformThreshold = 20.0 Auto hidden
Float Property DefaultJumpHeight = 76.0 Auto hidden
Spell Property DetectArousalCloakSpell Auto
Int Property DigestionMode = 1 Auto hidden
Float Property DrainValueMultipliers = 1.0 Auto hidden
Bool Property EFFActive Auto hidden
Float Property EXPGainedMultipliers = 1.0 Auto hidden
Bool Property EnableAproposRepairSpell = True Auto hidden
Bool Property EnableAutoAddFlying = True Auto hidden
Bool Property EnableBellyGrowthByPregnancy Auto hidden
Bool Property EnableBodyPaintAlphaChangeSatiation Auto hidden
Bool Property EnableBodyPaintGlowAlphaChangeSatiation Auto hidden
Bool Property EnableBodyPaintGlowTintChangeSatiation Auto hidden
Bool Property EnableBodyPaintTintChangeSatiation Auto hidden
Bool Property EnableBodyslideMorph Auto hidden
Bool Property EnableBreastChangeSuccubus Auto hidden
Bool Property EnableBreastGrowthByMilk Auto hidden
Bool Property EnableBreastGrowthByPregnancy Auto hidden
Bool Property EnableButtChangeSuccubus Auto hidden
Bool Property EnableCaptive = True Auto hidden
Bool Property EnableCumInflation = True Auto hidden
Bool Property EnableCursePaintAlpha Auto hidden
Bool Property EnableCursePaintGlowAlpha Auto hidden
Bool Property EnableCursePaintGlowTint Auto hidden
Bool Property EnableCursePaintGradient Auto hidden
Bool Property EnableCursePaintTint Auto hidden
Bool Property EnableCustomTattooGlow = False Auto hidden
Bool Property EnableDragonbornSuccubusTattoo = False Auto hidden
Bool Property EnableDrain = True Auto hidden
Bool Property EnableEnergyConsumingBySuccubusSpell = False Auto hidden
Bool Property EnableEnergySenseSpell = True Auto hidden
Bool Property EnableEquipmentDiagnostics = False Auto hidden
Bool Property EnableFertilityBridge = False Auto hidden
Bool Property EnableFortifyBartar = True Auto hidden
Bool Property EnableFortifyDestruction = True Auto hidden
Bool Property EnableFortifyIllusion = True Auto hidden
Bool Property EnableFutanariPower = True Auto hidden
Bool Property EnableGenitalsChangeSuccubus Auto hidden
Bool Property EnableHeightChangeSuccubus Auto hidden
Bool Property EnableMagicResistance = True Auto hidden
Bool Property EnablePSQRape Auto hidden
Bool Property EnableRankMagicCostReduction = True Auto hidden
Bool Property EnableRankShoutCooldownBonus = True Auto hidden
Bool Property EnableRankSpeedBonus = True Auto hidden
Bool Property EnableSLIFBridge = False Auto hidden
Bool Property EnableSatiationEffect = False Auto hidden
Bool Property EnableSatiationNotification = True Auto hidden
Bool Property EnableScrotumChangeSuccubus Auto hidden
Bool Property EnableSoulGemPregnancy Auto hidden
Bool Property EnableSoulTrap Auto hidden
Bool Property EnableSpellCastingNotification Auto hidden
Bool Property EnableStarvation = True Auto hidden
Bool Property EnableSuccubusDrainFF = True Auto hidden
Bool Property EnableSuccubusDrainHealthSpell = True Auto hidden
Bool Property EnableSuccubusDrainStaminaSpell = True Auto hidden
Bool Property EnableSuccubusSpellBooster = True Auto hidden
Float Property EnergyConsumption Auto hidden
Float Property EnergyConsumptionPerMax = 14.0 Auto hidden
; Retired save properties. No energy calculation or option reads them.
Bool Property EnergyModeAlt Auto hidden
Bool Property EnergySenseActive = False Auto hidden
Int Property EnergySenseGeneration = 0 Auto hidden
Bool Property ExtractSemenPotion Auto hidden
String Property FHU_SEMENPOTION = "AddSemenPotion" AutoReadOnly hidden
Faction Property FamiliarDebuffFaction Auto
Faction Property FamiliarLoyaltyFaction Auto
Bool Property FastMode Auto hidden
Float Property FastModeTime = 60.0 Auto hidden
Armor Property FemaleSchlongA Auto
Armor Property FemaleSchlongB Auto
Armor Property FemaleSchlongC Auto
Armor Property FemaleSchlongD Auto
Armor Property FemaleSchlongE Auto
Int Property FertilisationProbability = 5 Auto hidden
Float Property FertilityBridgeDuration = 0.0 Auto hidden
Float Property FertilityBridgeProgress = 0.0 Auto hidden
Int Property FertilityBridgeRank = -1 Auto hidden
Float Property FertilityBridgeRemaining = 0.0 Auto hidden
EffectShader Property FireFXShader Auto
Bool Property FluidNeedArousal = True Auto hidden
Quest Property FollowerExtension Auto hidden
GlobalVariable Property FoodPointsSemen Auto
Perk Property FortifyBartarPerk Auto
Spell Property FortifyBartarSpell1 Auto
Spell Property FortifyBartarSpell2 Auto
Spell Property FortifyBartarSpell3 Auto
Spell Property FortifyBartarSpell4 Auto
Spell Property FortifyBartarSpell5 Auto
Spell Property FortifyBartarSpell6 Auto
Spell Property FortifyBartarSpell7 Auto
Spell Property FortifyBartarSpell8 Auto
Spell Property FortifyCarrySpell Auto
Float Property FortifyDestructionMult = 1.0 Auto hidden
Spell Property FortifyDestructionSpell Auto
Spell Property FortifyHealthSpell Auto
Float Property FortifyIllusionMult = 1.0 Auto hidden
Perk Property FortifyIllusionPerk Auto
Spell Property FortifyIllusionSpell Auto
Spell Property FortifyMSGBoxSpell Auto
Spell Property FortifyMagickaSpell Auto
Perk Property FortifySneakPerk Auto
Spell Property FortifySneakSpell Auto
Spell Property FortifyStaminaSpell Auto
Spell Property FortifyUnarmedSpell Auto
GlobalVariable Property GameDaysPassed Auto
GlobalVariable Property HasWing Auto
Float Property HealthBuffDec = 0.200000003 Auto hidden
Float Property HealthBuffInc = 0.400000006 Auto hidden
Float Property HealthRateBuffDec = 100.0 Auto hidden
Float Property HealthRateBuffInc = 100.0 Auto hidden
Int Property HeartEyeCatalogVersion = 0 Auto hidden
Bool Property HenshinArmorRate Auto hidden
Bool Property HenshinBody Auto hidden
Bool Property HenshinBoots Auto hidden
Bool Property HenshinBuff = True Auto hidden
Int Property HenshinBuffMode = 1 Auto hidden
Float Property HenshinBuffRateCarry = 50.0 Auto hidden
Float Property HenshinBuffRateHealth = 50.0 Auto hidden
Float Property HenshinBuffRateMagicka = 50.0 Auto hidden
Float Property HenshinBuffRateStamina = 50.0 Auto hidden
Float Property HenshinConsumeEnergy = 1.0 Auto hidden
Bool Property HenshinCuirass Auto hidden
Bool Property HenshinEyes Auto hidden
Bool Property HenshinFear Auto hidden
Bool Property HenshinGloves Auto hidden
Bool Property HenshinHair Auto hidden
Bool Property HenshinHairColor Auto hidden
Bool Property HenshinHorn Auto hidden
Bool Property HenshinIsCrime Auto hidden
Bool Property HenshinPenis Auto hidden
Bool Property HenshinSkin Auto hidden
Spell Property HenshinSpell Auto
Bool Property HenshinTail Auto hidden
Bool Property HenshinTattoo Auto hidden
Bool Property HenshinWings Auto hidden
Int Property HotkeyAllowKill = 211 Auto hidden
Int Property HotkeyBreastNode = 211 Auto hidden
Int Property HotkeyButtNode = 211 Auto hidden
Int Property HotkeyCreatePenisSelf = 211 Auto hidden
Int Property HotkeyDecreaseNode = 211 Auto hidden
Int Property HotkeyDetectArousal = 211 Auto hidden
Int Property HotkeyDigestion = 211 Auto hidden
Int Property HotkeyEnableDrain = 211 Auto hidden
Int Property HotkeyEnableSoulTrap = 211 Auto hidden
Int Property HotkeyEnergyBar = 211 Auto hidden
Int Property HotkeyExtractSemenPotion = 211 Auto hidden
Int Property HotkeyGenitalsNode = 211 Auto hidden
Int Property HotkeyHeight = 211 Auto hidden
Int Property HotkeyHenshin = 211 Auto hidden
Int Property HotkeyIncreaseNode = 211 Auto hidden
Int Property HotkeyMasturbation = 211 Auto hidden
Int Property HotkeyNightEye = 211 Auto hidden
Int Property HotkeyRestoreMagicka = 211 Auto hidden
Int Property HotkeyScrotumNode = 211 Auto hidden
Int Property HotkeySuccubusCharmSpell = 211 Auto hidden
Int Property HotkeySuccubusStats = 211 Auto hidden
Int Property HotkeyWeight = 211 Auto hidden
Bool Property HybridDefaultMigrated = False Auto hidden
Spell Property ImmunityToSTD Auto
Bool Property IsHenshinchu Auto hidden
Bool Property IsHenshined Auto hidden
Float Property LastConsumeTime Auto hidden
Float Property LastReloadTime Auto hidden
Float Property LoversDrainMult = 2.0 Auto hidden
Float Property LoversRestoreMult = 1.5 Auto hidden
Keyword Property MagicInfluence Auto
Float Property MagicResistanceMult = 1.0 Auto hidden
Spell Property MagicResistanceSpell Auto
Float Property MagickaBuffDec = 0.200000003 Auto hidden
Float Property MagickaBuffInc = 0.400000006 Auto hidden
Float Property MagickaRateBuffDec = 100.0 Auto hidden
Float Property MagickaRateBuffInc = 100.0 Auto hidden
Bool Property ManualDigestionMode Auto hidden
Spell Property MasturbationSpell Auto
Float Property MaxEnergy Auto hidden
Float Property MaxEnergyAtAltMode = 0.0 Auto hidden
Float Property MinEnergyOfHuman = 500.0 Auto hidden
Armor Property OrgArmor Auto hidden
FormList Property OrgArmorList Auto
Armor Property OrgBoots Auto hidden
headpart Property OrgEyes Auto hidden
Armor Property OrgGloves Auto hidden
headpart Property OrgHair Auto hidden
colorform Property OrgHairColor Auto hidden
headpart Property OrgHead Auto hidden
Armor Property OrgHorns Auto hidden
Armor Property OrgSkin Auto hidden
Int Property OrgSkinColor Auto hidden
Armor Property OrgSlot52 Auto hidden
Armor Property OrgTail Auto hidden
Armor Property OrgWings Auto hidden
Keyword Property PSQContractableActor Auto
Spell Property PSQEatSemenSpell Auto
Keyword Property PSQFamiliarActor Auto
Package Property PSQFishPackage Auto
headpart Property PSQHumanHead Auto
Armor Property PSQHumanSkin Auto
Spell Property PSQLureCastSpell Auto
Message Property PSQLureMSGBox Auto
Spell Property PSQLureRegisterSpell Auto
Spell Property PSQLureSelfCalmSpell Auto
Spell Property PSQLureTriggerSpell Auto
Faction Property PSQRapeNoAttackFaction Auto
Int Property PSQSkinColor = -16775751 Auto hidden
Int Property PSQSkinColorAlpha = 255 Auto hidden
Spell Property PSQSoulGemBirthingSpell Auto
Spell Property PSQSoulGemImpregnateSpell Auto
Armor Property PSQSuccubusBoots Auto
Armor Property PSQSuccubusCuirass Auto
headpart Property PSQSuccubusEyes Auto
TextureSet Property PSQSuccubusEyesTexture Auto
Armor Property PSQSuccubusGauntlets Auto
headpart Property PSQSuccubusHair Auto
colorform Property PSQSuccubusHairColor Auto
Int Property PSQSuccubusHairColorInt Auto hidden
headpart Property PSQSuccubusHead Auto
Armor Property PSQSuccubusHorns Auto
Armor Property PSQSuccubusSkin Auto
Armor Property PSQSuccubusTail Auto
Armor Property PSQSuccubusWings Auto
Spell Property PSQTerminateLureSpell Auto
Bool Property PhysicalWeakness Auto hidden
Armor Property PlayerHumanSchlong Auto
GlobalVariable Property PlayerIsSuccubus Auto
GlobalVariable Property PlayerIsVampire Auto
GlobalVariable Property PlayerIsWerewolf Auto
Actor Property PlayerRef Auto
Armor Property PlayerSuccubusSchlong Auto
Quest Property PlayerVampireQuest Auto
Spell Property PowerOfFutanari Auto
Bool Property PreserveTattooGlowColor = True Auto hidden
Int Property RacialTraitDrainMode = 1 Auto hidden
Spell Property RankShoutAbilityA Auto hidden
Spell Property RankShoutAbilityB Auto hidden
Bool Property RankShoutAbilityMigrated = False Auto hidden
Int Property RapeArousalThreshold = 80 Auto hidden
Float Property RapeChance = 20.0 Auto hidden
Float Property RapeHealthThreshold = 20.0 Auto hidden
Float Property RequiredToFluid = 20.0 Auto hidden
Float Property RestoreMagickaMAX = 100.0 Auto hidden
Spell Property RestoreMagickaSpell Auto
succubusenergybarupdate Property SEBU Auto
Int Property SatiationEffectMode = 0 Auto hidden
Message Property SelectSchlongMSGBox Auto
Potion Property SemenPotion Auto
sexlabframework Property SexLab Auto
EffectShader Property SexLabCumOralShaderPSQ Auto
Float Property SexTimer Auto hidden
EffectShader Property ShockPlayerCloakFXShader Auto
Int Property SkillDrainMode = 2 Auto hidden
Spell Property SoulGemPregnantEffectA Auto
Spell Property SoulGemPregnantEffectB Auto
Sound Property SoundHenshinMoan Auto
Sound Property SoundMilking Auto
Float Property SpeedBuffDec = 20.0 Auto hidden
Float Property SpeedBuffInc = 40.0 Auto hidden
Float Property StaminaBuffDec = 0.200000003 Auto hidden
Float Property StaminaBuffInc = 0.400000006 Auto hidden
Float Property StaminaRateBuffDec = 100.0 Auto hidden
Float Property StaminaRateBuffInc = 100.0 Auto hidden
Spell Property StarkRealitySpell Auto
Spell Property StatsMSGBoxSpell Auto
Bool Property StopAddMilk = True Auto hidden
Bool Property StopEnergyConsuming Auto hidden
String Property StringConsumptionPerDay Auto
String Property StringCurrent Auto
String Property StringDrained Auto
String Property StringGot Auto
String Property StringSatiation Auto
String Property StringSemenFrom Auto
String Property StringSemenPotionsFrom Auto
String Property StringSuccubusEXP Auto
String Property StringUsed Auto
Spell Property SuccuBlizzard Auto
Spell Property SuccuCallToArms Auto
Spell Property SuccuCalm Auto
Spell Property SuccuChainLightning Auto
Spell Property SuccuCloseWounds Auto
Spell Property SuccuCourage Auto
Spell Property SuccuDragonhide Auto
Spell Property SuccuEbonyflesh Auto
Spell Property SuccuFastHealing Auto
Spell Property SuccuFear Auto
Spell Property SuccuFireStorm Auto
Spell Property SuccuFireball Auto
Spell Property SuccuFirebolt Auto
Spell Property SuccuFrenzy Auto
Spell Property SuccuFury Auto
Spell Property SuccuGrandHealing Auto
Spell Property SuccuHarmony Auto
Spell Property SuccuHealOther Auto
Spell Property SuccuHysteria Auto
Spell Property SuccuIceSpike Auto
Spell Property SuccuIceStorm Auto
Spell Property SuccuIcySpear Auto
Spell Property SuccuIncinerate Auto
Spell Property SuccuIronflesh Auto
Spell Property SuccuKanashibari Auto
Spell Property SuccuLightningBolt Auto
Spell Property SuccuMayhem Auto
Spell Property SuccuOakflesh Auto
Spell Property SuccuPacify Auto
Spell Property SuccuParalyze Auto
Spell Property SuccuRally Auto
Spell Property SuccuRout Auto
Spell Property SuccuStoneflesh Auto
Spell Property SuccuThunderbolt Auto
Float Property SuccubusArmorMagnitude = 50.0 Auto hidden
Spell Property SuccubusArmorSpell Auto
Spell Property SuccubusArousalCloakSpell Auto
Int Property SuccubusBodySelection = 0 Auto hidden
Float Property SuccubusBreast = 2.0 Auto hidden
Float Property SuccubusButt = 2.0 Auto hidden
Spell Property SuccubusCharmSpell Auto
Spell Property SuccubusCureDisease Auto
Spell Property SuccubusCurseCloakSpell Auto hidden
Spell Property SuccubusCurseSpell Auto
Faction Property SuccubusCursedFaction Auto hidden
Armor Property SuccubusDragonWingOdaviing Auto
Armor Property SuccubusDragonWingsAlduin Auto
Armor Property SuccubusDragonWingsBloody Auto
Armor Property SuccubusDragonWingsBoss Auto
Armor Property SuccubusDragonWingsCommon Auto
Armor Property SuccubusDragonWingsForest Auto
Armor Property SuccubusDragonWingsParthurnax Auto
Armor Property SuccubusDragonWingsSnow Auto
Armor Property SuccubusDragonWingsTundra Auto
Armor Property SuccubusDragonWingsUnderskin Auto
Spell Property SuccubusDrainFF01 Auto
Spell Property SuccubusDrainFF02 Auto
Spell Property SuccubusDrainFF03 Auto
Spell Property SuccubusDrainFF04 Auto
Spell Property SuccubusDrainFF05 Auto
Spell Property SuccubusDrainFF06 Auto
Spell Property SuccubusDrainFF07 Auto
Spell Property SuccubusDrainFF08 Auto
Spell Property SuccubusDrainHealthSpell01 Auto
Spell Property SuccubusDrainHealthSpell02 Auto
Spell Property SuccubusDrainHealthSpell03 Auto
Spell Property SuccubusDrainHealthSpell04 Auto
Spell Property SuccubusDrainHealthSpell05 Auto
Spell Property SuccubusDrainHealthSpell06 Auto
Spell Property SuccubusDrainHealthSpell07 Auto
Spell Property SuccubusDrainHealthSpell08 Auto
Spell Property SuccubusDrainStaminaSpell01 Auto
Spell Property SuccubusDrainStaminaSpell02 Auto
Spell Property SuccubusDrainStaminaSpell03 Auto
Spell Property SuccubusDrainStaminaSpell04 Auto
Spell Property SuccubusDrainStaminaSpell05 Auto
Spell Property SuccubusDrainStaminaSpell06 Auto
Spell Property SuccubusDrainStaminaSpell07 Auto
Spell Property SuccubusDrainStaminaSpell08 Auto
GlobalVariable Property SuccubusEXP Auto
GlobalVariable Property SuccubusEnergy Auto
Int Property SuccubusEyeMaterialSelection = 0 Auto hidden
Armor Property SuccubusFairyWings Auto
Perk Property SuccubusFeed Auto
Potion Property SuccubusFluid1 Auto
Potion Property SuccubusFluid2 Auto
Potion Property SuccubusFluid3 Auto
Potion Property SuccubusFluid4 Auto
Potion Property SuccubusFluid5 Auto
Potion Property SuccubusFluid6 Auto
Potion Property SuccubusFluid7 Auto
Potion Property SuccubusFluid8 Auto
Faction Property SuccubusFoeFaction Auto
FormList Property SuccubusFoeList Auto
Spell Property SuccubusForceTransform Auto
Spell Property SuccubusFormFearSpell Auto
FormList Property SuccubusFriendList Auto
Float Property SuccubusGenitals = 2.0 Auto hidden
Int Property SuccubusHairSelection = 0 Auto hidden
Float Property SuccubusHeight = 2.0 Auto hidden
Spell Property SuccubusHenshinBonusSpell Auto
Potion Property SuccubusMilk Auto
Faction Property SuccubusNPCFaction Auto
Armor Property SuccubusNanka Auto
Bool Property SuccubusNightEyeEnabled Auto hidden
ImageSpaceModifier Property SuccubusNightEyeImod Auto
ImageSpaceModifier Property SuccubusNightEyeIntroFXImod Auto
ImageSpaceModifier Property SuccubusNightEyeOutroFXImod Auto
Float Property SuccubusNightEyeStrength = 0.5 Auto hidden
Int Property SuccubusOutfitSelection = 4 Auto hidden
Spell Property SuccubusRaiseArousalSpell Auto
GlobalVariable Property SuccubusRank Auto
Spell Property SuccubusRapeVictimDebuffSpell Auto
Spell Property SuccubusSatiatySpellA Auto
Spell Property SuccubusSatiatySpellB Auto
Spell Property SuccubusSatiatySpellC Auto
Float Property SuccubusScrotum = 2.0 Auto hidden
Spell Property SuccubusSoulTrap Auto
Keyword Property SuccubusSpell Auto
Perk Property SuccubusSpellBoostPerk Auto
Spell Property SuccubusSpellLearningMSGBoxSpell Auto
Keyword Property SuccubusSpellNoConsume Auto
Spell Property SuccubusStarvation Auto
Armor Property SuccubusStaticWings Auto
Spell Property SuccubusStorageSpell Auto
Spell Property SuccubusSummonMerchantSpell Auto
Int Property SuccubusTattooSelection = 19 Auto hidden
EffectShader Property SuccubusTransFXS Auto
Spell Property SuccubusWaterWalking Auto
Perk Property SuccubusWingPerk Auto
Int Property TattooGlowMode = -1 Auto hidden
Spell Property TerminateDetectArousalSpell Auto
Bool Property TransformBodySaved = False Auto hidden
GlobalVariable Property TransformBooster Auto
Spell Property TransformNPCSuccubusSpell Auto
headpart Property TransformOriginalHead Auto hidden
Armor Property TransformOriginalSkin Auto hidden
Int[] Property TransformPartSources Auto hidden
Bool Property TransformSkinOriginalSaved = False Auto hidden
Float Property TransformThreshold = 80.0 Auto hidden
Int Property UninstallCleanedDataCount = 0 Auto hidden
Bool Property UninstallCleanupBusy = False Auto hidden
Bool Property UninstallPrepared = False Auto hidden
Bool Property UseArousalAtDrain = True Auto hidden
GlobalVariable Property WaterPointsSemen Auto
Spell Property WerewolfChange Auto
Spell Property WerewolfImmunity Auto
Float Property WingMaxJumpHeight = 280.0 Auto hidden
effcore Property XFLMain Auto hidden

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Event OnInit()
  Self.InitializeWingflightIntegration()
  Self.RegisterInflationFertilityEvents()
  Self.RegisterForSingleUpdate(15.0)
EndEvent

Event OnUpdate()
  If !PSQReloadBusy && !UninstallCleanupBusy && (AWUMayRemoveSpell || AWUMayRemovePower) && AWUOwnedWing == None
    Self.SettleAWUWingControls()
  EndIf
  If PSQReloadBusy
    Self.RegisterForSingleUpdate(3.0)
    Return
  EndIf
  Self.RefreshWingflightState()
  Self.SyncPlayerAppearanceRace()
  If UninstallPrepared || UninstallCleanupBusy
    Self.UnregisterForUpdate()
    Self.UnregisterForAllKeys()
    Return
  EndIf
  If Self.ShouldDeferForAlternateStart()
    Self.ResetTransformEnergyClock()
    LastConsumeTime = GameDaysPassed.GetValue()
    AlternateStartResumePending = True
    Self.RegisterForSingleUpdate(3.0)
    Return
  EndIf
  If AlternateStartResumePending
    AlternateStartResumePending = False
    LastConsumeTime = GameDaysPassed.GetValue()
    Self.PSQReload()
    If AlternateStartBecomePending
      AlternateStartBecomePending = False
      Self.BecomeSuccubus()
    EndIf
    Return
  EndIf
  Self.CheckAppearanceProgress()
  If Self.TryRecoverInterruptedAppearance()
    Self.ResetTransformEnergyClock()
    LastConsumeTime = GameDaysPassed.GetValue()
    Self.RegisterForSingleUpdate(3.0)
    Return
  EndIf
  Float TransformSeconds = Self.TakeTransformEnergySeconds()
  If PendingRankAnimation > 0 || RankAnimationPreviewPending
    Self.ProcessRankUpAnimation()
  EndIf
  Self.RecoverFHUTransfer(False)
  ; Avoid noncritical native/appearance work while the foreground owns appearance.
  If !(AppearanceEditBusy || IsHenshinchu || BodySelectionRefreshBusy)
    Self.UpdateInflationBridgeBackend()
  EndIf
  ; Avoid noncritical native/appearance work while the foreground owns appearance.
  If !(AppearanceEditBusy || IsHenshinchu || BodySelectionRefreshBusy)
    Self.SyncPendingBCNGBody()
  EndIf
  ; Avoid noncritical native/appearance work while the foreground owns appearance.
  If !(AppearanceEditBusy || IsHenshinchu || BodySelectionRefreshBusy)
    Self.SyncRankMagicCostReduction()
  EndIf
  Self.MigrateHybridDefault()
  If !AppearanceEditBusy && !IsHenshinchu && !UI.IsMenuOpen("Sleep/Wait Menu")
    If PlayerIsSuccubus.GetValueInt() == 1 && GameDaysPassed.GetValue() - LastConsumeTime >= 0.025
      Self.QueueStrongBodyCarrySync()
      ReviewStrongCarry = True
      ReviewContinuousCarry = True
      ReviewTransformCarry = True
      Debug.Trace("[PSQ Carry] time jump; inventory=" + PlayerRef.GetAV("InventoryWeight") + "; capacity=" + PlayerRef.GetAV("CarryWeight") + "; base=" + PlayerRef.GetBaseAV("CarryWeight"))
    EndIf
    If StrongCarryPending
      Self.SyncStrongBodyCarry()
    EndIf
  EndIf
  ; Avoid noncritical native/appearance work while the foreground owns appearance.
  If !(AppearanceEditBusy || IsHenshinchu || BodySelectionRefreshBusy)
    Self.SyncContinuousAbilities(False)
  EndIf
  If PlayerIsSuccubus.GetValue() == 1.0
    ConsumeTimer = GameDaysPassed.GetValue() - LastConsumeTime
    If !StopEnergyConsuming
      If EnergyConsumption != 0.0 && ConsumeTimer != 0.0
        Self.ChangeSatiationEnergy(-1.0 * EnergyConsumption * ConsumeTimer, False)
      EndIf
      If IsHenshined && AllowHenshinConsumeEnergy
        If TransformSeconds != 0.0 && HenshinConsumeEnergy != 0.0
          Self.ChangeSatiationEnergy(-TransformSeconds * HenshinConsumeEnergy, False)
        EndIf
        If SuccubusEnergy.GetValue() <= 0.0 && !IsHenshinchu
          HenshinSpell.Cast(PlayerRef as ObjectReference, None)
        EndIf
      EndIf
    EndIf
    If Self.GetDigestionMode() != 2 && !ManualDigestionBusy && !FHUActiveDigestionWaiting
      Float Decrement = Self.GetAutomaticDigestionRate() * ConsumeTimer * 24.0
      If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
        Decrement = PSQAppearance.DigestStep(Decrement, storageutil.GetFloatValue(PlayerRef, "PSQ_InternalSemen", 0.0), 0.0, False)
      ElseIf Decrement > storageutil.GetFloatValue(PlayerRef as Form, "PSQ_InternalSemen", 0.0)
        Decrement = storageutil.GetFloatValue(PlayerRef as Form, "PSQ_InternalSemen", 0.0)
      EndIf
      ; Preserve all nonzero settlements and their order, including legacy
      ; negative inputs. A zero delta needs no reserve write or energy commit.
      If Decrement != 0.0
        storageutil.SetFloatValue(PlayerRef as Form, "PSQ_InternalSemen", storageutil.GetFloatValue(PlayerRef as Form, "PSQ_InternalSemen", 0.0) - Decrement)
        Self.ChangeSatiationEnergy(Decrement, False)
      EndIf
    EndIf
    If AppearanceEditBusy || IsHenshinchu || BodySelectionRefreshBusy
      ; Keep energy clamping/starvation bookkeeping, but let the active
      ; transformation own tattoo presentation and final stat synchronization.
      Self.ChangeSatiationEnergy(0.0, False)
      TransformBuffRefreshPending = True
      SatiationRefreshPending = True
    Else
      Self.Satiety(0.0)
    EndIf
    LastConsumeTime = GameDaysPassed.GetValue()
    If IsHenshined && AllowHenshinAddExposure
      psqarousalruntime.ModifyArousal(PlayerRef, 0.5)
    EndIf
    Self.ReloadSuccubusCharm()
    If PlayerIsVampire.GetValue() == 1.0 || PlayerIsWerewolf.GetValue() == 1.0
      If !AllowHybrid
        Self.QuitSuccubus()
      EndIf
    EndIf
    If EnableFortifyBartar && !PlayerRef.HasPerk(FortifyBartarPerk)
      PlayerRef.AddPerk(FortifyBartarPerk)
    EndIf
  ElseIf storageutil.GetIntValue(Game.GetPlayer() as Form, "PSQ_SpellON", 0) == 1
    storageutil.SetIntValue(Game.GetPlayer() as Form, "PSQ_SpellON", 0)
    Self.BecomeSuccubus()
  EndIf
  Self.RegisterForSingleUpdate(6.0)
EndEvent

Function PSQStartSex(Form FormRef, Int TID)
  Self.PSQStartSex35(FormRef,TID)
EndFunction

Function PSQOrgasm(Form FormRef, Int TID)
  Self.PSQOrgasm35(FormRef,TID)
EndFunction

Function PSQOrgasmCore(Form FormRef, Int TID)
  Self.PSQOrgasmCore35(FormRef,TID)
EndFunction

Function PSQOrgasmSeparate(Form FormRef, Int TID)
  Self.PSQOrgasmSeparate35(FormRef,TID)
EndFunction

Function PSQOrgasmSeparateCore(Form FormRef, Int TID)
  Self.PSQOrgasmSeparateCore35(FormRef,TID)
EndFunction

Function PSQEndSex(Form FormRef, Int TID)
  Self.PSQEndSex35(FormRef,TID)
EndFunction

Bool Function IsNotUndead(Actor Hector)
  If Hector.HasKeyword(PSQFamiliarActor) == True || Hector.HasKeyword(PSQContractableActor) == True
    Return False
  EndIf
  If Hector.HasKeyword(ActorTypeUndead) == True || Hector.IsCommandedActor() == True
    If AllowDrainFromUndead
      Return True
    EndIf
    Return False
  EndIf
  Return True
EndFunction

Bool Function IsFamiliar(Actor Hector)
  If Hector.HasKeyword(PSQFamiliarActor) == True
    Return True
  EndIf
  Return False
EndFunction

Function SetEnergy(Actor Victim)
  If Victim == None
    Return
  EndIf
  Float[] Snapshot = Self.GetNPCEnergySnapshot(Victim)
  storageutil.SetFloatValue(Victim as Form, "PSQ_EnergyOfActor", Snapshot[0])
  storageutil.SetFloatValue(Victim as Form, "PSQ_LastEnergyCalcTime", Snapshot[2])
EndFunction

Float[] Function GetNPCEnergySnapshot(Actor Victim)
  Float Energy
  Float[] Values = new Float[3]
  If Victim == None
    Return Values
  EndIf
  Float BaseHealth = Victim.GetBaseActorValue("Health")
  Bool IsHuman = Victim.HasKeywordString("ActorTypeNPC")
  Float Now = GameDaysPassed.GetValue()
  Float Last = storageutil.GetFloatValue(Victim as Form, "PSQ_LastEnergyCalcTime", 0.0)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777230
    Float AnimalScale = 1.0
    If !IsHuman
      AnimalScale += Self.GetAnimalRaceFamiliarity(Self.GetVictimRace(Victim)) / 100.0
    EndIf
    Float LoverScale = 1.0
    If Victim.GetRelationshipRank(PlayerRef) == 4
      LoverScale = LoversRestoreMult
    EndIf
    Float Stored = storageutil.GetFloatValue(Victim, "PSQ_EnergyOfActor", 0.0)
    Return PSQAppearance.NPCEnergyValues(BaseHealth, CalcMaxEnergyHealth, AdjustMinEnergyOfHuman && IsHuman, MinEnergyOfHuman, Now, Last, AnimalScale, LoverScale, Self.IsSuccubusThrall(Victim), Stored)
  EndIf
  Float NPCMaxEnergy = BaseHealth * CalcMaxEnergyHealth
  Bool UseMinEnergy = False
  If AdjustMinEnergyOfHuman
    If IsHuman
      If NPCMaxEnergy < MinEnergyOfHuman
        NPCMaxEnergy = MinEnergyOfHuman
        UseMinEnergy = True
      EndIf
    EndIf
  EndIf
  Float Timer = Now - Last
  If Last == 0.0
    Timer = 1000.0
  EndIf
  If !IsHuman
    Float Familiarity = Self.GetAnimalRaceFamiliarity(Self.GetVictimRace(Victim))
    Float RaceLikeMult = Familiarity / 100.0 + 1.0
    If RaceLikeMult > 2.0
      RaceLikeMult = 2.0
    EndIf
    NPCMaxEnergy *= RaceLikeMult
    Timer *= RaceLikeMult
  EndIf
  If Victim.GetRelationshipRank(PlayerRef) == 4
    Timer *= LoversRestoreMult
  EndIf
  If Self.IsSuccubusThrall(Victim)
    Timer *= 1.5
    NPCMaxEnergy *= 2.0
  EndIf
  If UseMinEnergy
    Energy = storageutil.GetFloatValue(Victim as Form, "PSQ_EnergyOfActor", 0.0) + MinEnergyOfHuman / 3.0 * Timer
  Else
    Energy = storageutil.GetFloatValue(Victim as Form, "PSQ_EnergyOfActor", 0.0) + BaseHealth * Timer
  EndIf
  If Energy > NPCMaxEnergy
    Energy = NPCMaxEnergy
  EndIf
  Values[0] = Energy
  Values[1] = NPCMaxEnergy
  Values[2] = Now
  Return Values
EndFunction

Function SuccubusDrain(Actor Target, Float DrainValue, Bool PlayerIsVictim, Bool PlayerIsAggressor, Bool CanExtractSemenPotion, Bool CanImpregnant, Bool IsOral, Bool CumInflation, Bool IsMalePosition, Bool RealPenis)
  Self.SuccubusDrain35(Target,DrainValue,PlayerIsVictim,PlayerIsAggressor,CanExtractSemenPotion,CanImpregnant,IsOral,CumInflation,IsMalePosition,RealPenis)
EndFunction

Bool Function SemenPotionChecker()
  If ExtractSemenPotion || AutoExtractSemenPotion && AutoExtractSemenPotionThreshold < Self.GetEnergyRatio() * 100.0
    Return True
  EndIf
  Return False
EndFunction

Bool Function KillAtDrain(Bool PisV, Bool PisA)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Return PSQAppearance.DrainRoleAllowed(AllowKill, ConditionToKill, PisV, PisA)
  EndIf
  If AllowKill
    If ConditionToKill == 0 || ConditionToKill == 1 && PisA || ConditionToKill == 2 && PisV == True || ConditionToKill == 3 && PisA || ConditionToKill == 3 && PisV
      Return True
    EndIf
  EndIf
  Return False
EndFunction

Bool Function SoulTrapWhenKillAtDrain(Bool PisV, Bool PisA)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Return PSQAppearance.DrainRoleAllowed(EnableSoulTrap, ConditionToSoulTrap, PisV, PisA)
  EndIf
  If EnableSoulTrap
    If ConditionToSoulTrap == 0 || ConditionToSoulTrap == 1 && PisA || ConditionToSoulTrap == 2 && PisV || ConditionToSoulTrap == 3 && PisA || ConditionToSoulTrap == 3 && PisV
      Return True
    EndIf
  EndIf
  Return False
EndFunction

Float Function ProcessingArousal(Actor Target, Float DrainValue)
  Return Self.ProcessingArousal35(Target,DrainValue)
EndFunction

Float Function ChargeFamiliar(Actor FamiliarActor)
  Float ChargeValue
  Float FamiliarMaxEnergy = storageutil.GetFloatValue(FamiliarActor as Form, "PSQ_FamiliarMaxEnergy", 0.0)
  If storageutil.GetFloatValue(FamiliarActor as Form, "PSQ_ChargeValue", 0.0) == 0.0
    If ChargeFull
      ChargeValue = FamiliarMaxEnergy - storageutil.GetFloatValue(FamiliarActor as Form, "PSQ_FamiliarEnergy", 0.0)
    ElseIf ChargeValueAuto != 0.0
      ChargeValue = ChargeValueAuto
    EndIf
  Else
    ChargeValue = storageutil.GetFloatValue(FamiliarActor as Form, "PSQ_ChargeValue", 0.0)
    storageutil.SetFloatValue(FamiliarActor as Form, "PSQ_ChargeValue", 0.0)
  EndIf
  If ChargeValue > SuccubusEnergy.GetValue()
    ChargeValue = SuccubusEnergy.GetValue()
  EndIf
  SuccubusEnergy.SetValue(SuccubusEnergy.GetValue() - ChargeValue)
  storageutil.SetFloatValue(FamiliarActor as Form, "PSQ_FamiliarEnergy", storageutil.GetFloatValue(FamiliarActor as Form, "PSQ_FamiliarEnergy", 0.0) + ChargeValue)
  If storageutil.GetFloatValue(FamiliarActor as Form, "PSQ_FamiliarEnergy", 0.0) > FamiliarMaxEnergy
    storageutil.SetFloatValue(FamiliarActor as Form, "PSQ_OverEnergy", storageutil.GetFloatValue(FamiliarActor as Form, "PSQ_FamiliarEnergy", 0.0) - FamiliarMaxEnergy)
    storageutil.SetFloatValue(FamiliarActor as Form, "PSQ_FamiliarEnergy", FamiliarMaxEnergy)
  EndIf
  If storageutil.GetFloatValue(FamiliarActor as Form, "PSQ_FamiliarEnergy", 0.0) >= 0.0
    FamiliarActor.RemoveFromFaction(FamiliarDebuffFaction)
  EndIf
  Float FamiliarLoyalty = storageutil.GetFloatValue(FamiliarActor as Form, "PSQ_FamiliarLoyalty", 0.0)
  FamiliarLoyalty += 1.0
  If FamiliarLoyalty > 100.0
    FamiliarLoyalty = 100.0
  EndIf
  storageutil.SetFloatValue(FamiliarActor as Form, "PSQ_FamiliarLoyalty", FamiliarLoyalty)
  FamiliarActor.SetFactionRank(FamiliarLoyaltyFaction, FamiliarLoyalty as Int)
  FamiliarActor.Activate(FamiliarActor as ObjectReference, False)
EndFunction

Function Captive(Actor Target, Float DrainValue)
  If UseArousalAtDrain
    DrainValue = Self.ProcessingArousal(Target, DrainValue)
  EndIf
  Int IncreasingDisposition = 0
  Int CurrentDisposition = Target.GetRelationshipRank(PlayerRef)
  Float Threshold = DrainValue / 5.0 + SuccubusRank.GetValue() * 20.0
  Float Random = Utility.RandomFloat(0.0, 100.0)
  While Threshold >= Random
    IncreasingDisposition += 1
    Threshold -= 100.0
  EndWhile
  If CurrentDisposition >= -4
    If CurrentDisposition < 4
      Int TargetDisposition
      If CurrentDisposition + IncreasingDisposition > 4
        TargetDisposition = 4
      Else
        TargetDisposition = CurrentDisposition + IncreasingDisposition
      EndIf
      Target.SetRelationshipRank(PlayerRef, TargetDisposition)
    EndIf
  EndIf
EndFunction

Function AddSuccubusFluid()
  Int ArousalAtBeginning = storageutil.GetIntValue(PlayerRef as Form, "PSQ_ArousalAtBeginning", -1)
  If !FluidNeedArousal || ArousalAtBeginning < 0 || (ArousalAtBeginning >= RequiredToFluid as Int)
    If SuccubusRank.GetValue() == 1.0
      PlayerRef.AddItem(SuccubusFluid1 as Form, 1, False)
    ElseIf SuccubusRank.GetValue() == 2.0
      PlayerRef.AddItem(SuccubusFluid2 as Form, 1, False)
    ElseIf SuccubusRank.GetValue() == 3.0
      PlayerRef.AddItem(SuccubusFluid3 as Form, 1, False)
    ElseIf SuccubusRank.GetValue() == 4.0
      PlayerRef.AddItem(SuccubusFluid4 as Form, 1, False)
    ElseIf SuccubusRank.GetValue() == 5.0
      PlayerRef.AddItem(SuccubusFluid5 as Form, 1, False)
    ElseIf SuccubusRank.GetValue() == 6.0
      PlayerRef.AddItem(SuccubusFluid6 as Form, 1, False)
    ElseIf SuccubusRank.GetValue() == 7.0
      PlayerRef.AddItem(SuccubusFluid7 as Form, 1, False)
    ElseIf SuccubusRank.GetValue() >= 8.0
      PlayerRef.AddItem(SuccubusFluid8 as Form, 1, False)
    EndIf
  EndIf
EndFunction

Function SuccubusLevelUp(Float value)
  Self.SuccubusLevelUp35(value)
EndFunction

Function Fishery()
  If FishCount > 0
    Slots = sslutility.PushActor(PlayerRef, Slots)
    Int j = 0
    While j < 4
      uilistmenu ListMenu = uiextensions.GetMenu("uilistmenu", True) as uilistmenu
      ListMenu.ResetMenu()
      ListMenu.AddEntryItem("End", -1, -1, False)
      Int i = 0
      While i < FishCount
        ListMenu.AddEntryItem(Fish[i].GetLeveledActorBase().GetName(), -1, -1, False)
        i += 1
      EndWhile
      ListMenu.OpenMenu(None, None)
      Int Ret = ListMenu.GetResultInt()
      If Ret == -1 || Ret == 0
        j = 666
      Else
        Slots = sslutility.PushActor(Fish[Ret - 1], Slots)
        Fish[Ret - 1] = None
      EndIf
      If FishCount != 1
        i = 0
        Int k = 0
        While i < FishCount
          If Fish[k] != None
            Fish[k] = Fish[i]
            k += 1
          EndIf
          i += 1
        EndWhile
      Else
        j = 666
      EndIf
      j += 1
    EndWhile
    If Slots.Length > 1
      Self.TriggerSex()
    Else
      Self.ResetSlots()
      Self.DischargeFish()
    EndIf
  Else
    Self.DischargeFish()
  EndIf
EndFunction

Function TriggerSex()
  Int i
  sslthreadmodel Thread = SexLab.NewThread(30.0)
  Slots = SexLab.SortActors(Slots, True)
  While i < Slots.Length
    If Thread.AddActor(Slots[i], False, None, False) == -1
      Thread.Initialize()
      Self.ResetSlots()
      Return
    EndIf
    i += 1
  EndWhile
  Thread.StartThread()
  Self.ResetSlots()
EndFunction

Function RegisterFish(Actor FishActor, Int AI)
  If SexLab.ValidateActor(FishActor) == 1 && !FishActor.HasKeywordString("SexLabActive")
    If storageutil.GetIntValue(PlayerRef as Form, "PSQ_LureEffectOnFemale", 0) == 1
      If FishActor.GetLeveledActorBase().GetSex() == 1
        Return
      EndIf
    EndIf
    If storageutil.GetIntValue(PlayerRef as Form, "PSQ_LureEffectOnMale", 0) == 1
      If FishActor.GetLeveledActorBase().GetSex() == 0
        Return
      EndIf
    EndIf
    If storageutil.GetIntValue(PlayerRef as Form, "PSQ_LureEffectOnBeast", 0) == 1
      If !FishActor.HasKeywordString("ActorTypeNPC")
        Return
      EndIf
    EndIf
    If storageutil.GetIntValue(PlayerRef as Form, "PSQ_LureEffectOnUndead", 0) == 0
      If FishActor.HasKeyword(ActorTypeUndead) == True || FishActor.IsCommandedActor() == True
        Return
      EndIf
    EndIf
    psqarousalruntime.ModifyArousal(FishActor, AI as Float)
    If Self.GetActorArousal(FishActor) > 70
      If !Self.IsSlotted(FishActor) && PlayerRef.HasSpell(PSQLureCastSpell as Form)
        Fish[FishCount] = FishActor
        PSQLureSelfCalmSpell.Cast(FishActor as ObjectReference, FishActor as ObjectReference)
        actorutil.AddPackageOverride(FishActor, PSQFishPackage, 98, 0)
        FishActor.EvaluatePackage()
        FishCount += 1
      EndIf
    EndIf
  EndIf
EndFunction

Function ResetSlots()
  Self.ResetSlots35()
EndFunction

Function DischargeFish()
  While FishCount > 0
    Fish[FishCount - 1] = None
    FishCount -= 1
  EndWhile
  PSQTerminateLureSpell.Cast(PlayerRef as ObjectReference, PlayerRef as ObjectReference)
EndFunction

Bool Function IsSlotted(Actor FishActor)
  Return Fish.find(FishActor, 0) != -1
EndFunction

Function AddMilk()
  ; Retired compatibility entry point. PSQ no longer produces milk.
EndFunction

Function Milking()
  ; Retired compatibility entry point. No animation, sound or item output.
  IsMilking = False
EndFunction

Function Satiety(Float value)
  Self.ChangeSatiationEnergy(value, True)
EndFunction

Bool Function RefreshTransformSatiety29(Int Owner, Int Epoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777245
    Int Ticket = PSQAppearance.StartAppearanceTask(PlayerRef, Self, None, Owner, Epoch, True, 9, False, 0.0)
    If Ticket >= 2
      Return Self.WaitAppearanceReceipt27(Ticket, Owner, Epoch) == 1
    EndIf
    ; An old suspended stack must not finish a refresh for another transform.
    If !Self.IsEquipmentRecoveryCurrent(Owner, True, Epoch)
      Return False
    EndIf
    Debug.Trace("[PSQ-RECOVERY] finish.satiety29 could not start; using saved refresh entry; owner=" + Owner)
  EndIf
  Self.Satiety(0.0)
  Return Self.IsEquipmentRecoveryCurrent(Owner, True, Epoch)
EndFunction

Function ChangeSatiationEnergy(Float value, Bool RefreshEffects)
  If MaxEnergy <= 0.0
    Self.RefreshEnergyCapacity()
  EndIf
  If PlayerIsSuccubus.GetValue() == 1.0
    If value != 0.0
      SuccubusEnergy.SetValue(SuccubusEnergy.GetValue() + value)
    EndIf
    If SuccubusEnergy.GetValue() <= 0.0
      If value != 0.0 || SuccubusEnergy.GetValue() < 0.0
        SuccubusEnergy.SetValue(0.0)
      EndIf
      If EnableStarvation
        If !PlayerRef.HasSpell(SuccubusStarvation as Form)
          PlayerRef.AddSpell(SuccubusStarvation, False)
        EndIf
      ElseIf PlayerRef.HasSpell(SuccubusStarvation as Form)
        PlayerRef.RemoveSpell(SuccubusStarvation)
      EndIf
    Else
      If PlayerRef.HasSpell(SuccubusStarvation as Form)
        PlayerRef.RemoveSpell(SuccubusStarvation)
      EndIf
      If SuccubusEnergy.GetValue() > MaxEnergy
        SuccubusEnergy.SetValue(MaxEnergy)
      EndIf
    EndIf
    If RefreshEffects
      Self.UpdateTransformBuff(False, -1)
      Self.UpdateRankShoutCooldownBonus()
      Float EnergyRatio = Self.GetEnergyRatio()
      Self.RefreshSatiationPresentation(EnergyRatio)
      Self.RefreshSatiationAttributes(EnergyRatio)
    EndIf
    Self.UpdatePSQWingJumpHeight(False)
  EndIf
EndFunction

Function SatietyNotification(Float value, Bool NoticeConsumed)
  Float Manpukudo = Self.GetEnergyRatio() * 100.0
  If EnableSatiationNotification
    If NoticeConsumed
      Debug.Notification(((("消耗魅魔能量:" + (-value as Int) as String) + " / " + "当前魅魔能量:" + SuccubusEnergy.GetValueInt() as String) + " / " + "当前魅魔能量百分比:" + (Manpukudo as Int) as String) + "%")
    Else
      Debug.Notification((("当前魅魔能量:" + SuccubusEnergy.GetValueInt() as String) + " / " + "当前魅魔能量百分比:" + (Manpukudo as Int) as String) + "%")
    EndIf
  EndIf
EndFunction

Function ChangeBodyPaint(Float Manpukudo, Bool Force)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777238 && PSQAppearance.IsReady()
    Self.RunAppearanceTask(None, AppearanceOperationId, PSQLoadEpoch, AppearanceEditBusy, 0, Force, Manpukudo)
    Return
  EndIf
  If Force
    Self.InvalidateTattooPresentation()
  EndIf
  Int PresentationRevision = TattooPresentationRevision
  If !Self.HasNiOverrideRuntime() || PlayerRef == None || !PlayerRef.Is3DLoaded()
    Self.InvalidateTattooPresentation()
    Return
  EndIf
  Int GlowMode = Self.GetTattooGlowMode()
  Bool Changed = False
  Bool ShowBuiltin = HenshinTattoo && PlayerIsSuccubus.GetValueInt() == 1
  Bool ShowDragonborn = EnableDragonbornSuccubusTattoo && PlayerIsSuccubus.GetValueInt() == 1
  Bool UseUBE = psqracecompatibility.IsUBEActor(PlayerRef)
  Bool DragonbornFemale = PlayerRef.GetLeveledActorBase().GetSex() == 1
  If UseUBE
    ; The original four-region set has no UBE hands/feet/face transfer.
    ShowBuiltin = False
    ShowDragonborn = ShowDragonborn && DragonbornFemale
  EndIf
  If ShowBuiltin || ShowDragonborn
    Self.ComputeTattooGradient(Manpukudo)
  EndIf
  String DragonbornNode = Self.ResolvePlayerTattooSlot(ShowDragonborn, UseUBE)
  Bool TattooReady = !ShowDragonborn || DragonbornNode != ""
  String Texture = Self.GetSelectedSuccubusTattooTexture()
  If ShowDragonborn && UseUBE
    Texture = Self.GetUBEBodyTattooTexture(Texture)
  EndIf
  Float Alpha = 1.0
  If EnableBodyPaintAlphaChangeSatiation
    Alpha = Manpukudo
  EndIf
  String PSQKey = ((ShowBuiltin as String + ":") + ShowDragonborn as String) + ":" + Texture + ":" + GlowMode as String
  PSQKey += (":" + EnableBodyPaintTintChangeSatiation as String) + ":" + EnableBodyPaintAlphaChangeSatiation as String
  PSQKey += (":" + EnableBodyPaintGlowTintChangeSatiation as String) + ":" + EnableBodyPaintGlowAlphaChangeSatiation as String
  PSQKey += (":" + EnableCustomTattooGlow as String) + ":" + PreserveTattooGlowColor as String
  PSQKey += (((":" + BPTintCurrentColor as String) + ":" + BPGTintCurrentColor as String) + ":" + BPGCurrentAlpha as String) + ":" + Alpha as String
  PSQKey += ":" + DragonbornNode + ":" + DragonbornFemale as String
  If !Force && TattooReady && !TattooPresentationNeedsApply && TattooPresentationValid && TattooPresentationKey == PSQKey
    Return
  EndIf
  Self.SetDefaultSuccubusTattoo(False)
  Changed = Self.SetSuccubusTattooOverlay("Body [Ovl5]", "PSQ_BuiltinBody", "PSQ\\Overlays\\body_0.dds", ShowBuiltin, False, True) || Changed
  If ShowBuiltin
    Changed = Self.ApplyComputedTattooGradient("Body [Ovl5]", Manpukudo, False, True) || Changed
  EndIf
  Changed = Self.SetSuccubusTattooOverlay("Hands [Ovl2]", "PSQ_BuiltinHands", "PSQ\\Overlays\\hand_0.dds", ShowBuiltin, False, True) || Changed
  If ShowBuiltin
    Changed = Self.ApplyComputedTattooGradient("Hands [Ovl2]", Manpukudo, False, True) || Changed
  EndIf
  Changed = Self.SetSuccubusTattooOverlay("Feet [Ovl2]", "PSQ_BuiltinFeet", "PSQ\\Overlays\\feet_0.dds", ShowBuiltin, False, True) || Changed
  If ShowBuiltin
    Changed = Self.ApplyComputedTattooGradient("Feet [Ovl2]", Manpukudo, False, True) || Changed
  EndIf
  Changed = Self.SetSuccubusTattooOverlay("Face [Ovl2]", "PSQ_BuiltinFace", "PSQ\\Overlays\\face_0.dds", ShowBuiltin, False, True) || Changed
  If ShowBuiltin
    Changed = Self.ApplyComputedTattooGradient("Face [Ovl2]", Manpukudo, False, True) || Changed
  EndIf
  If ShowDragonborn && DragonbornNode != ""
    Changed = Self.SetSuccubusTattooOverlay(DragonbornNode, "PSQ_PlayerTattoo", Texture, True, False, DragonbornFemale) || Changed
    storageutil.SetStringValue(PlayerRef as Form, "PSQ_PlayerTattoo_Texture", Texture)
    Changed = Self.ApplyComputedTattooGradient(DragonbornNode, Manpukudo, False, DragonbornFemale) || Changed
  EndIf
  If Changed || TattooPresentationNeedsApply
    nioverride.ApplyNodeOverrides(PlayerRef as ObjectReference)
  EndIf
  If TattooReady && PresentationRevision == TattooPresentationRevision
    TattooPresentationKey = PSQKey
    TattooPresentationValid = True
    TattooPresentationNeedsApply = False
  Else
    Self.InvalidateTattooPresentation()
  EndIf
EndFunction

Function ChangeAccursedBodyPaint(Actor Accursed)
  If !Self.HasNiOverrideRuntime()
    Return
  EndIf
  Float Arousal = Self.GetActorArousal(Accursed) as Float
  If Arousal < 0.0
    Return
  EndIf
  Arousal /= 100.0
  If EnableCursePaintTint
    Int CurrentColor = colorcomponent.SetRed(CurrentColor, (storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxRed", 0.0) - storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooDefRed", 0.0) * Math.Abs(1.0 - Arousal)) as Int)
    CurrentColor = colorcomponent.SetBlue(CurrentColor, (storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxBlue", 0.0) - storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooDefBlue", 0.0) * Math.Abs(1.0 - Arousal)) as Int)
    CurrentColor = colorcomponent.SetGreen(CurrentColor, (storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxGreen", 0.0) - storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooDefGreen", 0.0) * Math.Abs(1.0 - Arousal)) as Int)
    nioverride.AddNodeOverrideInt(Accursed as ObjectReference, True, "Body [Ovl5]", 7, -1, CurrentColor, True)
    nioverride.AddNodeOverrideInt(Accursed as ObjectReference, True, "Hands [Ovl2]", 7, -1, CurrentColor, True)
    nioverride.AddNodeOverrideInt(Accursed as ObjectReference, True, "Feet [Ovl2]", 7, -1, CurrentColor, True)
    nioverride.AddNodeOverrideInt(Accursed as ObjectReference, True, "Face [Ovl2]", 7, -1, CurrentColor, True)
  EndIf
  If EnableCursePaintAlpha
    nioverride.AddNodeOverrideFloat(Accursed as ObjectReference, True, "Face [Ovl2]", 8, -1, Arousal, True)
    nioverride.AddNodeOverrideFloat(Accursed as ObjectReference, True, "Feet [Ovl2]", 8, -1, Arousal, True)
    nioverride.AddNodeOverrideFloat(Accursed as ObjectReference, True, "Hands [Ovl2]", 8, -1, Arousal, True)
    nioverride.AddNodeOverrideFloat(Accursed as ObjectReference, True, "Body [Ovl5]", 8, -1, Arousal, True)
  EndIf
  If EnableCursePaintGlowTint
    Int CurrentGlow = colorcomponent.SetRed(CurrentGlow, (storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxRedG", 0.0) - storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooDefRedG", 0.0) * Math.Abs(1.0 - Arousal)) as Int)
    CurrentGlow = colorcomponent.SetBlue(CurrentGlow, (storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxBlueG", 0.0) - storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooDefBlueG", 0.0) * Math.Abs(1.0 - Arousal)) as Int)
    CurrentGlow = colorcomponent.SetGreen(CurrentGlow, (storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxGreenG", 0.0) - storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooDefGreenG", 0.0) * Math.Abs(1.0 - Arousal)) as Int)
    nioverride.AddNodeOverrideInt(Accursed as ObjectReference, True, "Body [Ovl5]", 0, -1, CurrentGlow, True)
    nioverride.AddNodeOverrideInt(Accursed as ObjectReference, True, "Hands [Ovl2]", 0, -1, CurrentGlow, True)
    nioverride.AddNodeOverrideInt(Accursed as ObjectReference, True, "Feet [Ovl2]", 0, -1, CurrentGlow, True)
    nioverride.AddNodeOverrideInt(Accursed as ObjectReference, True, "Face [Ovl2]", 0, -1, CurrentGlow, True)
  EndIf
  If EnableCursePaintGlowAlpha
    Float CurrentGlowAlpha = storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxAlphaG", 0.0) - storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooDefAlphaG", 0.0) * Math.Abs(1.0 - Arousal)
    nioverride.AddNodeOverrideFloat(Accursed as ObjectReference, True, "Face [Ovl2]", 1, -1, CurrentGlowAlpha, True)
    nioverride.AddNodeOverrideFloat(Accursed as ObjectReference, True, "Feet [Ovl2]", 1, -1, CurrentGlowAlpha, True)
    nioverride.AddNodeOverrideFloat(Accursed as ObjectReference, True, "Hands [Ovl2]", 1, -1, CurrentGlowAlpha, True)
    nioverride.AddNodeOverrideFloat(Accursed as ObjectReference, True, "Body [Ovl5]", 1, -1, CurrentGlowAlpha, True)
  EndIf
EndFunction

Function ReloadSuccubusCharm()
  Int Rank = SuccubusRank.GetValueInt()
  Float Now = GameDaysPassed.GetValue()
  If Rank < 1
    CharmSpellAmmo = 0
    LastReloadTime = Now
    Return
  EndIf
  If CharmSpellAmmo < 0
    CharmSpellAmmo = 0
  EndIf
  Float Elapsed = Now - LastReloadTime
  ; A whole game day recharges every slot, including saves with a runaway clock.
  If CharmSpellAmmo >= Rank || Elapsed >= 1.0
    CharmSpellAmmo = Rank
    LastReloadTime = Now
  ElseIf !(Elapsed >= 0.0)
    LastReloadTime = Now
  Else
    Int Added = Math.Floor(Elapsed * Rank)
    If Added >= Rank - CharmSpellAmmo
      CharmSpellAmmo = Rank
      LastReloadTime = Now
    ElseIf Added > 0
      CharmSpellAmmo += Added
      LastReloadTime += Added as Float / Rank
    EndIf
  EndIf
EndFunction

Function SetScaleSuccubus(Int Owner, Bool RequireBusy)
  Self.SetScaleSuccubus41(Owner, RequireBusy)
EndFunction

Function SetScaleHuman(Int Owner, Bool RequireBusy)
  Self.SetScaleHuman41(Owner, RequireBusy)
EndFunction

Function SetBreastScaleHuman(Int Owner, Bool RequireBusy)
; Retired compatibility entry point. Old saved scripts may still call it.
  ; No size calculation, morph write, skeleton scaling, or SLIF submission.
EndFunction

Function SetBreastScaleSuccubus(Int Owner, Bool RequireBusy)
; Retired compatibility entry point. Old saved scripts may still call it.
  ; No size calculation, morph write, skeleton scaling, or SLIF submission.
EndFunction

Function SetBellyScale()
; Retired compatibility entry point. Old saved scripts may still call it.
  ; No size calculation, morph write, skeleton scaling, or SLIF submission.
EndFunction

Function BeginPSQLoadSession()
  Self.BeginPSQLoadSession35()
EndFunction

Bool Function IsPSQLoadCurrent(Int LoadEpoch)
  Return LoadEpoch == PSQLoadEpoch
EndFunction

Function PSQReload()
  Self.PSQReload35()
EndFunction

Function PSQReloadCore(Int LoadEpoch)
  Self.PSQReloadCore35(LoadEpoch)
EndFunction

Function SetSuccubusLevel()
  Self.RefreshEnergyCapacity()
  SuccubusRank.SetValue(1.0)
  If EnableSuccubusDrainFF
    PlayerRef.AddSpell(SuccubusDrainFF01, False)
  EndIf
  If EnableSuccubusDrainHealthSpell
    PlayerRef.AddSpell(SuccubusDrainHealthSpell01, False)
  EndIf
  If EnableSuccubusDrainStaminaSpell
    PlayerRef.AddSpell(SuccubusDrainStaminaSpell01, False)
  EndIf
  If EnableFortifyBartar
    PlayerRef.AddSpell(FortifyBartarSpell1, False)
  EndIf
  If SuccubusEXP.GetValue() >= 10.0
    SuccubusRank.SetValue(2.0)
    If EnableSuccubusDrainFF
      PlayerRef.AddSpell(SuccubusDrainFF02, False)
    EndIf
    If EnableSuccubusDrainHealthSpell
      PlayerRef.AddSpell(SuccubusDrainHealthSpell02, False)
    EndIf
    If EnableSuccubusDrainStaminaSpell
      PlayerRef.AddSpell(SuccubusDrainStaminaSpell02, False)
    EndIf
    If EnableFortifyBartar
      PlayerRef.AddSpell(FortifyBartarSpell2, False)
    EndIf
    PlayerRef.AddSpell(SuccuKanashibari, False)
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell01)
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell01)
    PlayerRef.RemoveSpell(SuccubusDrainFF01)
    PlayerRef.RemoveSpell(FortifyBartarSpell1)
  EndIf
  If SuccubusEXP.GetValue() >= 50.0
    SuccubusRank.SetValue(3.0)
    If EnableSuccubusDrainStaminaSpell
      PlayerRef.AddSpell(SuccubusDrainStaminaSpell03, False)
    EndIf
    If EnableSuccubusDrainHealthSpell
      PlayerRef.AddSpell(SuccubusDrainHealthSpell03, False)
    EndIf
    If EnableSuccubusDrainFF
      PlayerRef.AddSpell(SuccubusDrainFF03, False)
    EndIf
    PlayerRef.AddSpell(FortifyMSGBoxSpell, False)
    If EnableFortifyBartar
      PlayerRef.AddSpell(FortifyBartarSpell3, False)
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell02)
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell02)
    PlayerRef.RemoveSpell(SuccubusDrainFF02)
    PlayerRef.RemoveSpell(FortifyBartarSpell2)
  EndIf
  If SuccubusEXP.GetValue() >= 100.0
    SuccubusRank.SetValue(4.0)
    If EnableSuccubusDrainStaminaSpell
      PlayerRef.AddSpell(SuccubusDrainStaminaSpell04, False)
    EndIf
    If EnableSuccubusDrainHealthSpell
      PlayerRef.AddSpell(SuccubusDrainHealthSpell04, False)
    EndIf
    If EnableSuccubusDrainFF
      PlayerRef.AddSpell(SuccubusDrainFF04, False)
    EndIf
    If EnableFortifyBartar
      PlayerRef.AddSpell(FortifyBartarSpell4, False)
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell03)
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell03)
    PlayerRef.RemoveSpell(SuccubusDrainFF03)
    PlayerRef.RemoveSpell(FortifyBartarSpell3)
  EndIf
  If SuccubusEXP.GetValue() >= 250.0
    SuccubusRank.SetValue(5.0)
    If EnableSuccubusDrainStaminaSpell
      PlayerRef.AddSpell(SuccubusDrainStaminaSpell05, False)
    EndIf
    If EnableSuccubusDrainHealthSpell
      PlayerRef.AddSpell(SuccubusDrainHealthSpell05, False)
    EndIf
    If EnableSuccubusDrainFF
      PlayerRef.AddSpell(SuccubusDrainFF05, False)
    EndIf
    If EnableFortifyBartar
      PlayerRef.AddSpell(FortifyBartarSpell5, False)
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell04)
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell04)
    PlayerRef.RemoveSpell(SuccubusDrainFF04)
    PlayerRef.RemoveSpell(FortifyBartarSpell4)
  EndIf
  If SuccubusEXP.GetValue() >= 500.0
    SuccubusRank.SetValue(6.0)
    If EnableSuccubusDrainStaminaSpell
      PlayerRef.AddSpell(SuccubusDrainStaminaSpell06, False)
    EndIf
    If EnableSuccubusDrainHealthSpell
      PlayerRef.AddSpell(SuccubusDrainHealthSpell06, False)
    EndIf
    If EnableSuccubusDrainFF
      PlayerRef.AddSpell(SuccubusDrainFF06, False)
    EndIf
    If EnableFortifyBartar
      PlayerRef.AddSpell(FortifyBartarSpell6, False)
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell05)
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell05)
    PlayerRef.RemoveSpell(SuccubusDrainFF05)
    PlayerRef.RemoveSpell(FortifyBartarSpell5)
  EndIf
  If SuccubusEXP.GetValue() >= 1000.0
    SuccubusRank.SetValue(7.0)
    If EnableSuccubusDrainStaminaSpell
      PlayerRef.AddSpell(SuccubusDrainStaminaSpell07, False)
    EndIf
    If EnableSuccubusDrainHealthSpell
      PlayerRef.AddSpell(SuccubusDrainHealthSpell07, False)
    EndIf
    If EnableSuccubusDrainFF
      PlayerRef.AddSpell(SuccubusDrainFF07, False)
    EndIf
    If EnableFortifyBartar
      PlayerRef.AddSpell(FortifyBartarSpell7, False)
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell06)
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell06)
    PlayerRef.RemoveSpell(SuccubusDrainFF06)
    PlayerRef.RemoveSpell(FortifyBartarSpell6)
  EndIf
  If SuccubusEXP.GetValue() >= 2000.0
    SuccubusRank.SetValue(8.0)
    If EnableSuccubusDrainStaminaSpell
      PlayerRef.AddSpell(SuccubusDrainStaminaSpell08, False)
    EndIf
    If EnableSuccubusDrainHealthSpell
      PlayerRef.AddSpell(SuccubusDrainHealthSpell08, False)
    EndIf
    If EnableSuccubusDrainFF
      PlayerRef.AddSpell(SuccubusDrainFF08, False)
    EndIf
    If EnableFortifyBartar
      PlayerRef.AddSpell(FortifyBartarSpell8, False)
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell07)
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell07)
    PlayerRef.RemoveSpell(SuccubusDrainFF07)
    PlayerRef.RemoveSpell(FortifyBartarSpell7)
  EndIf
  If Self.UpdateAdvancedSuccubusRank(False)
    Self.SuccubusLevelUp(0.0)
  EndIf
EndFunction

Function FHUDigestion(Actor Target, Float Decrement)
  If !Self.IsIntegrationPluginLoaded("sr_FillHerUp.esp")
    Return
  EndIf
  If PlayerIsSuccubus.GetValue() == 1.0 && Target == PlayerRef
    Self.Satiety(Decrement * 100.0 * SuccubusRank.GetValue())
  EndIf
EndFunction

Function FHUAddSemenPotion(Actor Target, Float AddSemen)
  If !Self.IsIntegrationPluginLoaded("sr_FillHerUp.esp")
    Return
  EndIf
  If PlayerIsSuccubus.GetValue() == 1.0 && Target == PlayerRef
    Int Quantity
    storageutil.SetFloatValue(PlayerRef as Form, Self.FHU_SEMENPOTION, storageutil.GetFloatValue(PlayerRef as Form, Self.FHU_SEMENPOTION, 0.0) + AddSemen * 100.0 * SuccubusRank.GetValue())
    While storageutil.GetFloatValue(PlayerRef as Form, Self.FHU_SEMENPOTION, 0.0) >= 50.0
      Quantity += 1
      storageutil.SetFloatValue(PlayerRef as Form, Self.FHU_SEMENPOTION, storageutil.GetFloatValue(PlayerRef as Form, Self.FHU_SEMENPOTION, 0.0) - 50.0)
    EndWhile
    PlayerRef.AddItem(SemenPotion as Form, Quantity, True)
  EndIf
EndFunction

Function OnKeyDown(Int KeyCode)
  If Self.ShouldDeferForAlternateStart()
    Return
  EndIf
  If UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  If !Utility.IsInMenuMode()
    If PlayerIsSuccubus.GetValue() == 1.0
      If KeyCode == HotkeySuccubusStats
        StatsMSGBoxSpell.Cast(PlayerRef as ObjectReference, None)
      EndIf
      If KeyCode == HotkeyDigestion
        Self.RecoverFHUTransfer(False)
      EndIf
      If KeyCode == HotkeyDigestion && Self.GetDigestionMode() != 0 && !ManualDigestionBusy && !FHUActiveDigestionWaiting
        ActiveDigestionGeneration += 1
        Int DigestionOwner = ActiveDigestionGeneration
        ManualDigestionBusy = True
        storageutil.SetIntValue(PlayerRef as Form, "PSQ_Digestioning", 1)
        Self.RefreshEnergyCapacity()
        Bool ContinueDigestion = Self.TransferAllFHUToPSQ(DigestionOwner)
        While DigestionOwner == ActiveDigestionGeneration && ContinueDigestion && Self.GetDigestionMode() != 0 && input.IsKeyPressed(HotkeyDigestion) && SuccubusEnergy.GetValue() < MaxEnergy * 0.949999988
          Float Rate = CumInflationIncrement
          If Rate <= 0.0 || PlayerIsSuccubus.GetValueInt() != 1
            ContinueDigestion = False
          Else
            Float Reserve = storageutil.GetFloatValue(PlayerRef as Form, "PSQ_InternalSemen", 0.0)
            Float Room = MaxEnergy * 0.949999988 - SuccubusEnergy.GetValue()
            If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
              Rate = PSQAppearance.DigestStep(Rate, Reserve, Room, True)
            ElseIf Rate > Room
              Rate = Room
            EndIf
            If Reserve > 0.0
              If Rate > Reserve
                Rate = Reserve
              EndIf
              storageutil.SetFloatValue(PlayerRef as Form, "PSQ_InternalSemen", Reserve - Rate)
              Self.ChangeSatiationEnergy(Rate, False)
              Utility.Wait(0.200000003)
            Else
              ContinueDigestion = False
            EndIf
          EndIf
        EndWhile
        If DigestionOwner == ActiveDigestionGeneration
          Self.Satiety(0.0)
          Self.SetBellyScale()
          storageutil.SetIntValue(PlayerRef as Form, "PSQ_Digestioning", 0)
          Debug.Notification(Self.GetActiveDigestionReserveText())
          If SuccubusEnergy.GetValue() >= MaxEnergy * 0.949999988
            Debug.Notification("能量已达到95%，主动消化停止。")
          EndIf
          ManualDigestionBusy = False
        EndIf
      EndIf
      If KeyCode == HotkeyEnableDrain
        EnableDrain = !EnableDrain
        If EnableDrain
          Debug.Notification("$PSQ_EnableDrainHotkeyNotice1")
        Else
          Debug.Notification("$PSQ_EnableDrainHotkeyNotice2")
        EndIf
      EndIf
      If KeyCode == HotkeyAllowKill
        AllowKill = !AllowKill
        If AllowKill
          Debug.Notification("$PSQ_AllowKillHotkeyNotice1")
        Else
          Debug.Notification("$PSQ_AllowKillHotkeyNotice2")
        EndIf
      EndIf
      If KeyCode == HotkeyEnableSoulTrap
        EnableSoulTrap = !EnableSoulTrap
        If EnableSoulTrap
          Debug.Notification("$PSQ_EnableDrainSoulTrapHotkeyNotice1")
        Else
          Debug.Notification("$PSQ_EnableDrainSoulTrapHotkeyNotice2")
        EndIf
      EndIf
      If KeyCode == HotkeyExtractSemenPotion
        ExtractSemenPotion = !ExtractSemenPotion
        If ExtractSemenPotion
          Debug.Notification("$PSQ_EnableSemenPotionHotkeyNotice1")
        Else
          Debug.Notification("$PSQ_EnableSemenPotionHotkeyNotice2")
        EndIf
      EndIf
      If KeyCode == HotkeyEnergyBar
        SEBU.EnegyBarVisible = !SEBU.EnegyBarVisible
        SEBU.UpdateEnergyBarPosition()
      EndIf
      If KeyCode == HotkeyNightEye && !input.IsKeyPressed(HotkeyIncreaseNode) && !input.IsKeyPressed(HotkeyDecreaseNode)
        If !NightEyeProceeding
          NightEyeProceeding = True
          If SuccubusNightEyeEnabled
            SuccubusNightEyeEnabled = False
            SuccubusNightEyeImod.PopTo(SuccubusNightEyeOutroFXImod, SuccubusNightEyeStrength)
            SuccubusNightEyeIntroFXImod.Remove()
          Else
            SuccubusNightEyeEnabled = True
            SuccubusNightEyeIntroFXImod.Apply(SuccubusNightEyeStrength)
            Utility.Wait(0.5)
            SuccubusNightEyeIntroFXImod.PopTo(SuccubusNightEyeImod, SuccubusNightEyeStrength)
          EndIf
          NightEyeProceeding = False
        EndIf
      EndIf
      If KeyCode == HotkeySuccubusCharmSpell
        If CharmSpellAmmo > 0
          If SuccubusRank.GetValue() < 8.0
            CharmSpellAmmo -= 1
          EndIf
          SuccubusCharmSpell.Cast(PlayerRef as ObjectReference, None)
        Else
          Debug.Notification("$PSQ_OutOfAmmo")
        EndIf
      EndIf
      If KeyCode == HotkeyDetectArousal
        If PlayerRef.HasSpell(DetectArousalCloakSpell as Form)
          PlayerRef.RemoveSpell(DetectArousalCloakSpell)
          TerminateDetectArousalSpell.Cast(PlayerRef as ObjectReference, None)
        Else
          PlayerRef.AddSpell(DetectArousalCloakSpell, False)
        EndIf
      EndIf
      If KeyCode == HotkeyCreatePenisSelf
        CreatePenisSpellSelf.Cast(PlayerRef as ObjectReference, None)
      EndIf
      If KeyCode == HotkeyHenshin
        If IsHenshined
          HenshinSpell.Cast(PlayerRef as ObjectReference, None)
        ElseIf SuccubusEnergy.GetValue() > 0.0
          HenshinSpell.Cast(PlayerRef as ObjectReference, None)
          TransformNPCSuccubusSpell.Cast(PlayerRef as ObjectReference, None)
        Else
          Debug.Notification("$PSQ_NotEnoughEnergyToHenshin")
        EndIf
      EndIf
      If KeyCode == HotkeyMasturbation
        MasturbationSpell.Cast(PlayerRef as ObjectReference, None)
      EndIf
      If KeyCode == HotkeyRestoreMagicka
        RestoreMagickaSpell.Cast(PlayerRef as ObjectReference, None)
      EndIf
      If input.IsKeyPressed(HotkeyIncreaseNode)
        If KeyCode == HotkeyNightEye
          If !NightEyeProceeding
            NightEyeProceeding = True
            SuccubusNightEyeStrength += 0.100000001
            If SuccubusNightEyeStrength > 1.0
              SuccubusNightEyeStrength = 1.0
            EndIf
            If SuccubusNightEyeEnabled && SuccubusNightEyeStrength < 1.0
              SuccubusNightEyeIntroFXImod.Apply(0.100000001)
              Utility.Wait(1.0)
              SuccubusNightEyeIntroFXImod.PopTo(SuccubusNightEyeImod, 0.100000001)
            EndIf
            NightEyeProceeding = False
          EndIf
        EndIf
        If KeyCode == HotkeyHeight
          If IsHenshined
            If EnableHeightChangeSuccubus
              SuccubusHeight += 0.01
              Self.SetScaleSuccubus(-1, False)
            EndIf
          EndIf
        EndIf
        If KeyCode == HotkeyButtNode
          If IsHenshined
            If EnableButtChangeSuccubus
              SuccubusButt += 0.01
              Self.SetScaleSuccubus(-1, False)
            EndIf
          EndIf
        EndIf
        If KeyCode == HotkeyGenitalsNode
          If IsHenshined
            If EnableGenitalsChangeSuccubus
              SuccubusGenitals += 0.01
              Self.SetScaleSuccubus(-1, False)
            EndIf
          EndIf
        EndIf
        If KeyCode == HotkeyScrotumNode
          If IsHenshined
            If EnableScrotumChangeSuccubus
              SuccubusScrotum += 0.01
              Self.SetScaleSuccubus(-1, False)
            EndIf
          EndIf
        EndIf
      EndIf
      If input.IsKeyPressed(HotkeyDecreaseNode)
        If KeyCode == HotkeyNightEye
          If !NightEyeProceeding
            NightEyeProceeding = True
            SuccubusNightEyeStrength -= 0.100000001
            If SuccubusNightEyeStrength < 0.0
              SuccubusNightEyeStrength = 0.0
            EndIf
            If SuccubusNightEyeEnabled && SuccubusNightEyeStrength > 0.0
              SuccubusNightEyeIntroFXImod.Remove()
              SuccubusNightEyeImod.PopTo(SuccubusNightEyeOutroFXImod, SuccubusNightEyeStrength)
              Utility.Wait(1.0)
              SuccubusNightEyeImod.Apply(SuccubusNightEyeStrength)
            EndIf
            NightEyeProceeding = False
          EndIf
        EndIf
        If KeyCode == HotkeyHeight
          If IsHenshined
            If EnableHeightChangeSuccubus && !PlayerRef.IsOnMount()
              SuccubusHeight -= 0.01
              Self.SetScaleSuccubus(-1, False)
            EndIf
          EndIf
        EndIf
        If KeyCode == HotkeyButtNode
          If IsHenshined
            If EnableButtChangeSuccubus
              SuccubusButt -= 0.01
              Self.SetScaleSuccubus(-1, False)
            EndIf
          EndIf
        EndIf
        If KeyCode == HotkeyGenitalsNode
          If IsHenshined
            If EnableGenitalsChangeSuccubus
              SuccubusGenitals -= 0.01
              Self.SetScaleSuccubus(-1, False)
            EndIf
          EndIf
        EndIf
        If KeyCode == HotkeyScrotumNode
          If IsHenshined
            If EnableScrotumChangeSuccubus
              SuccubusScrotum -= 0.01
              Self.SetScaleSuccubus(-1, False)
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
EndFunction

Function ReloadHotkeys()
  If UninstallPrepared || UninstallCleanupBusy
    Self.UnregisterForUpdate()
    Self.UnregisterForAllKeys()
    Return
  EndIf
  Self.UnregisterForAllKeys()
  Self.RegisterForKey(HotkeyEnableDrain)
  Self.RegisterForKey(HotkeyAllowKill)
  Self.RegisterForKey(HotkeySuccubusCharmSpell)
  Self.RegisterForKey(HotkeyMasturbation)
  Self.RegisterForKey(HotkeyRestoreMagicka)
  Self.RegisterForKey(HotkeyExtractSemenPotion)
  Self.RegisterForKey(HotkeyEnableSoulTrap)
  Self.RegisterForKey(HotkeyCreatePenisSelf)
  Self.RegisterForKey(HotkeyHenshin)
  Self.RegisterForKey(HotkeyEnergyBar)
  Self.RegisterForKey(HotkeyNightEye)
  Self.RegisterForKey(HotkeyDetectArousal)
  Self.RegisterForKey(HotkeySuccubusStats)
  Self.RegisterForKey(HotkeyHeight)
  Self.RegisterForKey(HotkeyWeight)
  Self.RegisterForKey(HotkeyButtNode)
  Self.RegisterForKey(HotkeyGenitalsNode)
  Self.RegisterForKey(HotkeyScrotumNode)
  Self.RegisterForKey(HotkeyDigestion)
  Self.UnRegisterForKey(211)
EndFunction

Function BecomeSuccubus()
  If UninstallPrepared || UninstallCleanupBusy
    Self.UnregisterForUpdate()
    Self.UnregisterForAllKeys()
    Return
  EndIf
  If Self.ShouldDeferForAlternateStart()
    AlternateStartBecomePending = True
    AlternateStartResumePending = True
    Self.RegisterForSingleUpdate(3.0)
    Debug.Notification("$PSQ_LALActivationDeferred")
    Return
  EndIf
  AlternateStartBecomePending = False
  If PlayerIsSuccubus.GetValueInt() != 1 && !ManualContinuousChoices
    Self.CaptureManualContinuousChoices()
  EndIf
  Self.MigrateHybridDefault()
  If PlayerIsSuccubus.GetValue() != 1.0
    SuccubusCureDisease.Cast(PlayerRef as ObjectReference, None)
    If !AllowHybrid
      If PlayerIsVampire.GetValue() == 1.0
        (PlayerVampireQuest as playervampirequestscript).VampireCure(PlayerRef)
      EndIf
      If PlayerIsWerewolf.GetValue() == 1.0
        (C00 as companionshousekeepingscript).CurePlayer()
        PlayerIsWerewolf.SetValue(0.0)
      EndIf
    EndIf
    PlayerIsSuccubus.SetValue(1.0)
    If SEBU != None
      SEBU.SyncVisibility()
    EndIf
    storageutil.SetIntValue(PlayerRef as Form, "PSQ_PlayerIsSuccubus", 1)
    Self.SetSuccubusLevel()
    Self.Satiety(PlayerRef.GetActorValue("Health") * SuccubusRank.GetValue() * 6.0)
    PlayerRef.AddSpell(FortifyMagickaSpell, False)
    PlayerRef.AddSpell(FortifyCarrySpell, False)
    PlayerRef.AddSpell(FortifyHealthSpell, False)
    PlayerRef.AddSpell(FortifyStaminaSpell, False)
    PlayerRef.AddSpell(FortifyUnarmedSpell, False)
    If Self.IsStorageRankUnlocked()
      PlayerRef.AddSpell(SuccubusStorageSpell, False)
    EndIf
    PlayerRef.AddSpell(ImmunityToSTD, False)
    PlayerRef.AddSpell(RestoreMagickaSpell, False)
    PlayerRef.AddSpell(FortifySneakSpell, False)
    PlayerRef.AddSpell(MasturbationSpell, False)
    PlayerRef.AddSpell(SuccubusCharmSpell, False)
    PlayerRef.AddSpell(CreatePenisSpellSelf, False)
    PlayerRef.AddSpell(CreatePenisSpellOther, False)
    PlayerRef.AddSpell(StarkRealitySpell, False)
    PlayerRef.AddSpell(HenshinSpell, False)
    PlayerRef.AddSpell(StatsMSGBoxSpell, False)
    PlayerRef.AddSpell(SuccubusCurseSpell, False)
    PlayerRef.AddSpell(SuccubusSummonMerchantSpell, False)
    PlayerRef.AddSpell(SuccubusRaiseArousalSpell, False)
    PlayerRef.AddSpell(SuccubusArousalCloakSpell, False)
    PlayerRef.AddSpell(SuccubusSpellLearningMSGBoxSpell, False)
    PlayerRef.AddPerk(SuccubusFeed)
    PlayerRef.AddPerk(FortifySneakPerk)
    PlayerRef.AddPerk(SuccubusWingPerk)
    PlayerRef.AddPerk(SuccubusSpellBoostPerk)
    Self.RegisterSuccubusEvents()
    Fish = new Actor[100]
    Self.ResetSlots()
    LastConsumeTime = GameDaysPassed.value
    Self.FactionInit()
    Self.EnableEnterSoulCairn()
  EndIf
  Self.SyncManagedAbilities()
  Self.SyncContinuousAbilities(True)
EndFunction

Function RegisterSuccubusEvents()
  Self.RegisterInflationFertilityEvents()
  If UninstallPrepared || UninstallCleanupBusy
    Self.UnregisterForUpdate()
    Self.UnregisterForAllKeys()
    Return
  EndIf
  If !Self.IsIntegrationPluginLoaded("SexLab.esm") || SexLab == None
    Return
  EndIf
  SexLab.TrackActor(PlayerRef, "PSQHook")
  Self.UnregisterForModEvent("PSQHook_Orgasm")
  Self.RegisterForModEvent("PSQHook_Start", "PSQStartSex")
  Self.RegisterForModEvent("PSQHook_End", "PSQEndSex")
  Self.UnregisterForModEvent("SexLabOrgasmSeparate")
  If Self.IsSexLabPPlus()
    Self.RegisterForModEvent("SexLabOrgasmSeparate", "PSQOrgasmSeparate")
    Debug.Trace("[PSQ SLCompat] P+ actor orgasm integration enabled", 0)
  Else
    Self.RegisterForModEvent("PSQHook_Orgasm", "PSQOrgasm")
  EndIf
  If !Self.IsSexLabPPlus() && Self.IsIntegrationPluginLoaded("SLSO.esp")
    Self.RegisterForModEvent("SexLabOrgasmSeparate", "PSQOrgasmSeparate")
  EndIf
EndFunction

Bool Function IsLegacySeparateOrgasmMode()
  If Self.IsSexLabPPlus() || SexLab == None || !Self.IsIntegrationPluginLoaded("SLSO.esp")
    Return False
  EndIf
  Return PSQSexLabLegacyBridge.UseSeparateOrgasms(SexLab)
EndFunction

Function ResetPSQSexSceneState()
  Self.ResetPSQSexSceneState35()
EndFunction

Bool Function IsSexLabPPlus()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    Return PSQAppearance.SexLabPPlus33()
  EndIf
  Return skse.GetPluginVersion("SexLabUtil") >= 33554432
EndFunction

Int Function GetActorArousal(Actor Target)
  Return psqarousalruntime.GetArousalInt(Target)
EndFunction

Bool Function ModifyActorArousal(Actor Target, Float Amount)
  Return psqarousalruntime.ModifyArousal(Target, Amount)
EndFunction

Function BeginPPlusScene(Actor[] actors, Int TID, Bool NewScene = True)
  Self.BeginPPlusScene35(actors,TID,NewScene)
EndFunction

Function PSQPPlusOrgasm(Form FormRef, Int TID)
  Self.PSQPPlusOrgasm35(FormRef,TID)
EndFunction

Function ProcessPPlusOrgasm(Actor Source, Int TID)
  Self.ProcessPPlusOrgasm35(Source,TID)
EndFunction

Function SettlePPlusOrgasm(Actor Source, Int TID, Actor[] actors, Int Count, Float SceneTime, Bool RealPenis, Int ContactMask, Bool PlayerIsVictim, Bool PlayerIsAggressor)
  Self.SettlePPlusOrgasm35(Source,TID,actors,Count,SceneTime,RealPenis,ContactMask,PlayerIsVictim,PlayerIsAggressor)
EndFunction

Spell Function GetRoseStormSpell()
  Return Game.GetFormFromFile(0xB700, "PSQ PlayerSuccubusQuest.esm") as Spell
EndFunction

Function QuitSuccubus()
  Self.QuitSuccubus35()
EndFunction

Function UnregisterSuccubusEvents()
  Self.ResetPSQSexSceneState()
  If Self.IsIntegrationPluginLoaded("SexLab.esm") && SexLab != None
    SexLab.UntrackActor(PlayerRef, "PSQHook")
  EndIf
  Self.UnregisterForModEvent("PSQHook_Orgasm")
  Self.UnregisterForModEvent("PSQHook_Start")
  Self.UnregisterForModEvent("PSQHook_End")
  Self.UnregisterForModEvent("SexLabOrgasmSeparate")
EndFunction

Function FactionInit()
  Faction AiteFaction
  Int NumFactions = SuccubusFoeList.GetSize()
  Int FactionIndex = 0
  While FactionIndex < NumFactions
    AiteFaction = SuccubusFoeList.GetAt(FactionIndex) as Faction
    If AiteFaction
      SuccubusFoeFaction.SetEnemy(AiteFaction, False, False)
    EndIf
    FactionIndex += 1
  EndWhile
  FactionIndex = 0
  NumFactions = SuccubusFriendList.GetSize()
  While FactionIndex < NumFactions
    AiteFaction = SuccubusFriendList.GetAt(FactionIndex) as Faction
    If AiteFaction
      PSQRapeNoAttackFaction.SetAlly(AiteFaction, False, False)
    EndIf
    FactionIndex += 1
  EndWhile
EndFunction

Function MoanNoWait(sslbasevoice Voice, Int Strength)
  If SexLab.Config.UseLipSync && Game.GetCameraState() != 3
    PlayerRef.Say(SexLab.Config.LipSync, None, False)
  EndIf
  Sound GetMoan = Voice.GetSound(Strength, False)
  GetMoan.Play(PlayerRef as ObjectReference)
EndFunction

Function EnableEnterSoulCairn()
  Int Mods = Game.GetModCount()
  While Mods
    Mods -= 1
    String Name = Game.GetModName(Mods)
    If Name == "Dawnguard.esm"
      (Game.GetFormFromFile(54285, "Dawnguard.esm") as GlobalVariable).SetValue(1.0)
      (Game.GetFormFromFile(54290, "Dawnguard.esm") as ObjectReference).Disable(False)
      (Game.GetFormFromFile(54288, "Dawnguard.esm") as ObjectReference).Disable(False)
    EndIf
  EndWhile
EndFunction

Function DisableEnterSoulCairn()
  Int Mods = Game.GetModCount()
  While Mods
    Mods -= 1
    String Name = Game.GetModName(Mods)
    If Name == "Dawnguard.esm"
      (Game.GetFormFromFile(54285, "Dawnguard.esm") as GlobalVariable).SetValue(0.0)
      (Game.GetFormFromFile(54290, "Dawnguard.esm") as ObjectReference).Enable(False)
      (Game.GetFormFromFile(54288, "Dawnguard.esm") as ObjectReference).Enable(False)
    EndIf
  EndWhile
EndFunction

Function RegisteriNeed()
  If !Self.IsIntegrationPluginLoaded("iNeed.esp")
    Return
  EndIf
  Self.AddIntegrationFood(3435, SemenPotion as Form)
  Self.AddIntegrationFood(3436, Game.GetFormFromFile(3612, "PSQ PlayerSuccubusQuest.esm"))
  Self.AddIntegrationFood(3433, Game.GetFormFromFile(3613, "PSQ PlayerSuccubusQuest.esm"))
EndFunction

Function AddIntegrationFood(Int ListID, Form Food)
  If !Self.IsIntegrationPluginLoaded("iNeed.esp") || Food == None
    Return
  EndIf
  FormList Foods = Game.GetFormFromFile(ListID, "iNeed.esp") as FormList
  If Foods as Bool && !Foods.HasForm(Food)
    Foods.AddForm(Food)
  EndIf
EndFunction

Function GetBodyPaintData(Bool IsStartValue)
  If !Self.HasNiOverrideRuntime()
    Return
  EndIf
  If netimmerse.HasNode(PlayerRef as ObjectReference, "Body [Ovl5]", False)
    If IsStartValue
      BPTintColorStart = nioverride.GetNodePropertyInt(PlayerRef as ObjectReference, False, "Body [Ovl5]", 7, -1)
      BPGTintColorStart = nioverride.GetNodePropertyInt(PlayerRef as ObjectReference, False, "Body [Ovl5]", 0, -1)
      BPGAlphaStart = nioverride.GetNodePropertyFloat(PlayerRef as ObjectReference, False, "Body [Ovl5]", 1, -1)
    Else
      BPTintColorEnd = nioverride.GetNodePropertyInt(PlayerRef as ObjectReference, False, "Body [Ovl5]", 7, -1)
      BPGTintColorEnd = nioverride.GetNodePropertyInt(PlayerRef as ObjectReference, False, "Body [Ovl5]", 0, -1)
      BPGAlphaEnd = nioverride.GetNodePropertyFloat(PlayerRef as ObjectReference, False, "Body [Ovl5]", 1, -1)
    EndIf
  Else
    Bool IsFemale = PlayerRef.GetActorBase().GetSex() as Bool
    If IsStartValue
      BPTintColorStart = nioverride.GetNodeOverrideInt(PlayerRef as ObjectReference, IsFemale, "Body [Ovl5]", 7, -1)
      BPGTintColorStart = nioverride.GetNodeOverrideInt(PlayerRef as ObjectReference, IsFemale, "Body [Ovl5]", 0, -1)
      BPGAlphaStart = nioverride.GetNodeOverrideFloat(PlayerRef as ObjectReference, IsFemale, "Body [Ovl5]", 1, -1)
    Else
      BPTintColorEnd = nioverride.GetNodeOverrideInt(PlayerRef as ObjectReference, IsFemale, "Body [Ovl5]", 7, -1)
      BPGTintColorEnd = nioverride.GetNodeOverrideInt(PlayerRef as ObjectReference, IsFemale, "Body [Ovl5]", 0, -1)
      BPGAlphaEnd = nioverride.GetNodeOverrideFloat(PlayerRef as ObjectReference, IsFemale, "Body [Ovl5]", 1, -1)
    EndIf
  EndIf
  BPTintColorMaxRed = colorcomponent.GetRed(BPTintColorStart) as Float
  BPTintColorMaxGreen = colorcomponent.GetGreen(BPTintColorStart) as Float
  BPTintColorMaxBlue = colorcomponent.GetBlue(BPTintColorStart) as Float
  BPTintDefRed = BPTintColorMaxRed - colorcomponent.GetRed(BPTintColorEnd) as Float
  BPTintDefGreen = BPTintColorMaxGreen - colorcomponent.GetGreen(BPTintColorEnd) as Float
  BPTintDefBlue = BPTintColorMaxBlue - colorcomponent.GetBlue(BPTintColorEnd) as Float
  BPGTintColorMaxRed = colorcomponent.GetRed(BPGTintColorStart) as Float
  BPGTintColorMaxGreen = colorcomponent.GetGreen(BPGTintColorStart) as Float
  BPGTintColorMaxBlue = colorcomponent.GetBlue(BPGTintColorStart) as Float
  BPGTintDefRed = BPGTintColorMaxRed - colorcomponent.GetRed(BPGTintColorEnd) as Float
  BPGTintDefGreen = BPGTintColorMaxGreen - colorcomponent.GetGreen(BPGTintColorEnd) as Float
  BPGTintDefBlue = BPGTintColorMaxBlue - colorcomponent.GetBlue(BPGTintColorEnd) as Float
  BPGAlphaDef = BPGAlphaStart - BPGAlphaEnd
EndFunction

Function RegisterEFF()
  EFFActive = False
  XFLMain = None
  FollowerExtension = None
  If !Self.IsIntegrationPluginLoaded("EFFCore.esm")
    Return
  EndIf
  FollowerExtension = Game.GetFormFromFile(3839, "EFFCore.esm") as Quest
  XFLMain = FollowerExtension as effcore
  EFFActive = XFLMain != None
EndFunction

Function OpenRaceMenu(Actor Target)
  Bool UICheck
  Bool RaceMenuCheck
  Bool PSQVisualRuntime = skse.GetPluginVersion("skee") >= 0 || skse.GetPluginVersion("nioverride") >= 0
  If !Self.IsIntegrationPluginLoaded("UIExtensions.esp") || !Self.IsIntegrationPluginLoaded("RaceMenu.esp") || !Self.HasNiOverrideRuntime() || Target == None
    Return
  EndIf
  If Game.GetFormFromFile(3584, "UIExtensions.esp") != None
    UICheck = True
  EndIf
  If Game.GetFormFromFile(2048, "RaceMenu.esp") != None
    RaceMenuCheck = True
  EndIf
  If UICheck && RaceMenuCheck
    If Self.HasNiOverrideRuntime()
      If PSQVisualRuntime && !nioverride.HasOverlays(Target as ObjectReference)
        If PSQVisualRuntime
          nioverride.AddOverlays(Target as ObjectReference)
        EndIf
      EndIf
    EndIf
    uimenubase MenuBase = uiextensions.GetMenu("UICosmeticMenu", True)
    If MenuBase == None
      Return
    EndIf
    MenuBase.SetPropertyInt("Categories", 126)
    MenuBase.OpenMenu(Target as Form, None)
    If Self.HasNiOverrideRuntime()
      If Self.GetAllVisibleOverlays(Target) == 0
        If PSQVisualRuntime
          nioverride.RemoveOverlays(Target as ObjectReference)
        EndIf
      EndIf
    EndIf
  EndIf
EndFunction

Int Function GetAllVisibleOverlays(Actor Target)
  Bool PSQVisualRuntime = skse.GetPluginVersion("skee") >= 0 || skse.GetPluginVersion("nioverride") >= 0
  Int TotalVisible = 0
  If Self.HasNiOverrideRuntime()
    If PSQVisualRuntime
      TotalVisible += Self.GetVisibleOverlays(Target, 256, "Body [Ovl", nioverride.GetNumBodyOverlays())
    EndIf
    If PSQVisualRuntime
      TotalVisible += Self.GetVisibleOverlays(Target, 257, "Hands [Ovl", nioverride.GetNumHandOverlays())
    EndIf
    If PSQVisualRuntime
      TotalVisible += Self.GetVisibleOverlays(Target, 258, "Feet [Ovl", nioverride.GetNumFeetOverlays())
    EndIf
    If PSQVisualRuntime
      TotalVisible += Self.GetVisibleOverlays(Target, 259, "Face [Ovl", nioverride.GetNumFaceOverlays())
    EndIf
  EndIf
  Return TotalVisible
EndFunction

Int Function GetVisibleOverlays(Actor Target, Int TintType, String TintTemplate, Int TintCount)
  Bool PSQVisualRuntime = skse.GetPluginVersion("skee") >= 0 || skse.GetPluginVersion("nioverride") >= 0
  Int i = 0
  Int Visible = 0
  ActorBase TargetBase = Target.GetActorBase()
  While i < TintCount
    String NodeName = (TintTemplate + i as String) + "]"
    Float Alpha = 0.0
    String Texture = ""
    If netimmerse.HasNode(Target as ObjectReference, NodeName, False)
      If PSQVisualRuntime
        Alpha = nioverride.GetNodePropertyFloat(Target as ObjectReference, False, NodeName, 8, -1)
      EndIf
      If PSQVisualRuntime
        Texture = nioverride.GetNodePropertyString(Target as ObjectReference, False, NodeName, 9, 0)
      EndIf
    Else
      Bool IsFemale = TargetBase.GetSex() as Bool
      If PSQVisualRuntime
        Alpha = nioverride.GetNodeOverrideFloat(Target as ObjectReference, IsFemale, NodeName, 8, -1)
      EndIf
      If PSQVisualRuntime
        Texture = nioverride.GetNodeOverrideString(Target as ObjectReference, IsFemale, NodeName, 9, 0)
      EndIf
    EndIf
    If Texture == ""
      Texture = "Actors\\Character\\Overlays\\Default.dds"
    EndIf
    If Texture != "Actors\\Character\\Overlays\\Default.dds" && Alpha > 0.0
      Visible += 1
    EndIf
    i += 1
  EndWhile
  Return Visible
EndFunction

Function GetAccursedBodyPaintData(Actor Accursed, Bool IsStartValue)
  Int TintColor
  Int GlowColor
  Float GlowAlpha
  If !Self.HasNiOverrideRuntime()
    Return
  EndIf
  If netimmerse.HasNode(Accursed as ObjectReference, "Body [Ovl5]", False)
    TintColor = nioverride.GetNodePropertyInt(Accursed as ObjectReference, False, "Body [Ovl5]", 7, -1)
    GlowColor = nioverride.GetNodePropertyInt(Accursed as ObjectReference, False, "Body [Ovl5]", 0, -1)
    GlowAlpha = nioverride.GetNodePropertyFloat(Accursed as ObjectReference, False, "Body [Ovl5]", 1, -1)
  Else
    Bool IsFemale = Accursed.GetActorBase().GetSex() as Bool
    TintColor = nioverride.GetNodeOverrideInt(Accursed as ObjectReference, IsFemale, "Body [Ovl5]", 7, -1)
    GlowColor = nioverride.GetNodeOverrideInt(Accursed as ObjectReference, IsFemale, "Body [Ovl5]", 0, -1)
    GlowAlpha = nioverride.GetNodeOverrideFloat(Accursed as ObjectReference, IsFemale, "Body [Ovl5]", 1, -1)
  EndIf
  If IsStartValue
    storageutil.SetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxRed", colorcomponent.GetRed(TintColor) as Float)
    storageutil.SetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxGreen", colorcomponent.GetGreen(TintColor) as Float)
    storageutil.SetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxBlue", colorcomponent.GetBlue(TintColor) as Float)
    storageutil.SetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxRedG", colorcomponent.GetRed(GlowColor) as Float)
    storageutil.SetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxGreenG", colorcomponent.GetGreen(GlowColor) as Float)
    storageutil.SetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxBlueG", colorcomponent.GetBlue(GlowColor) as Float)
    storageutil.SetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxAlphaG", GlowAlpha)
  Else
    storageutil.SetFloatValue(Accursed as Form, "PSQ_CurseTattooDefRed", storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxRed", 0.0) - colorcomponent.GetRed(TintColor) as Float)
    storageutil.SetFloatValue(Accursed as Form, "PSQ_CurseTattooDefGreen", storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxGreen", 0.0) - colorcomponent.GetGreen(TintColor) as Float)
    storageutil.SetFloatValue(Accursed as Form, "PSQ_CurseTattooDefBlue", storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxBlue", 0.0) - colorcomponent.GetBlue(TintColor) as Float)
    storageutil.SetFloatValue(Accursed as Form, "PSQ_CurseTattooDefRedG", storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxRedG", 0.0) - colorcomponent.GetRed(TintColor) as Float)
    storageutil.SetFloatValue(Accursed as Form, "PSQ_CurseTattooDefGreenG", storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxGreenG", 0.0) - colorcomponent.GetGreen(TintColor) as Float)
    storageutil.SetFloatValue(Accursed as Form, "PSQ_CurseTattooDefBlueG", storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxBlueG", 0.0) - colorcomponent.GetBlue(TintColor) as Float)
    storageutil.SetFloatValue(Accursed as Form, "PSQ_CurseTattooDefAlphaG", storageutil.GetFloatValue(Accursed as Form, "PSQ_CurseTattooMaxAlphaG", 0.0) - GlowAlpha)
  EndIf
EndFunction

String Function GetVictimRace(Actor Victim)
  String RaceString = sslcreatureanimationslots.GetRaceKey(Victim.GetLeveledActorBase().GetRace())
  If RaceString == "Canines" || RaceString == "Wolves" || RaceString == "Dogs" || RaceString == "Foxes"
    Return "Canines"
  ElseIf RaceString == "Bears"
    Return "Bears"
  ElseIf RaceString == "Horses"
    Return "Horses"
  ElseIf RaceString == "Trolls"
    Return "Trolls"
  ElseIf RaceString == "SabreCats"
    Return "SabreCats"
  ElseIf RaceString == "Chaurus" || RaceString == "ChaurusReapers" || RaceString == "ChaurusHunters"
    Return "Chaurus"
  ElseIf RaceString == "Spiders" || RaceString == "LargeSpiders" || RaceString == "GiantSpiders"
    Return "Spiders"
  ElseIf RaceString == "DwarvenBallistas" || RaceString == "DwarvenCenturions" || RaceString == "DwarvenSpheres" || RaceString == "DwarvenSpiders"
    Return "DwarvenBallistas"
  ElseIf RaceString == "Draugrs"
    Return "Draugrs"
  ElseIf RaceString == "Falmers"
    Return "Falmers"
  ElseIf RaceString == "FlameAtronach"
    Return "FlameAtronach"
  ElseIf RaceString == "FrostAtronach"
    Return "FrostAtronach"
  ElseIf RaceString == "Gargoyles"
    Return "Gargoyles"
  ElseIf RaceString == "Lurkers"
    Return "Lurkers"
  ElseIf RaceString == "Giants"
    Return "Giants"
  ElseIf RaceString == "Goats"
    Return "Goats"
  ElseIf RaceString == "Boars" || RaceString == "BoarsAny" || RaceString == "BoarsMounted"
    Return "Boars"
  ElseIf RaceString == "Werewolves"
    Return "Werewolves"
  ElseIf RaceString == "Skeevers"
    Return "Skeevers"
  ElseIf RaceString == "Spriggans"
    Return "Spriggans"
  ElseIf RaceString == "WispMothers"
    Return "WispMothers"
  ElseIf RaceString == "Wisps"
    Return "Wisps"
  ElseIf RaceString == "Dragons"
    Return "Dragons"
  ElseIf RaceString == "DragonPriests"
    Return "DragonPriests"
  ElseIf RaceString == "VampireLords"
    Return "VampireLords"
  ElseIf RaceString == "Cows"
    Return "Cows"
  ElseIf RaceString == "IceWraiths"
    Return "IceWraiths"
  ElseIf RaceString == "Rieklings"
    Return "Rieklings"
  ElseIf RaceString == "Deers"
    Return "Deers"
  ElseIf RaceString == "Ashhoppers"
    Return "Ashhoppers"
  ElseIf RaceString == "Slaughterfishes"
    Return "Slaughterfishes"
  ElseIf RaceString == "Chickens"
    Return "Chickens"
  ElseIf RaceString == "Hagravens"
    Return "Hagravens"
  ElseIf RaceString == "Mammoths"
    Return "Mammoths"
  ElseIf RaceString == "Horkers"
    Return "Horkers"
  ElseIf RaceString == "Mudcrabs"
    Return "Mudcrabs"
  ElseIf RaceString == "Netches"
    Return "Netches"
  ElseIf RaceString == "Rabbits"
    Return "Rabbits"
  ElseIf RaceString == "Seekers"
    Return "Seekers"
  ElseIf RaceString == "StormAtronach"
    Return "StormAtronach"
  Else
    Return "None"
  EndIf
EndFunction

Bool Function UpdateAdvancedSuccubusRank(Bool Notify)
  Int PreviousRank = SuccubusRank.GetValueInt()
  If PreviousRank < 8
    Return False
  EndIf
  Int NewRank = PreviousRank
  Float CurrentEXP = SuccubusEXP.GetValue()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777234
    NewRank = PSQAppearance.PromotionRank(PreviousRank, CurrentEXP, True)
  ElseIf CurrentEXP >= 8000.0 && PreviousRank < 10
    NewRank = 10
  ElseIf CurrentEXP >= 4000.0 && PreviousRank < 9
    NewRank = 9
  EndIf
  If NewRank == PreviousRank
    Return False
  EndIf
  SuccubusRank.SetValue(NewRank as Float)
  If Notify
    If PreviousRank < 9 && NewRank >= 9
      Debug.Notification("$PSQ_RankUpTo9")
      Debug.Notification("$PSQ_GotTitle9")
    EndIf
    If PreviousRank < 10 && NewRank >= 10
      Debug.Notification("$PSQ_RankUpTo10")
      Debug.Notification("$PSQ_GotTitle10")
    EndIf
  EndIf
  Return True
EndFunction

Float Function GetRankSpeedBonus(Bool Transformed)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.RankSpeed34(Self, Transformed)
  EndIf
  If !EnableRankSpeedBonus
    Return 0.0
  EndIf
  If PlayerIsSuccubus.GetValueInt() != 1
    Return 0.0
  EndIf
  Int Rank = SuccubusRank.GetValueInt()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777228
    Return PSQAppearance.RankSpeed(Rank, Transformed)
  EndIf
  If Rank < 2
    Return 0.0
  ElseIf Rank > 10
    Rank = 10
  EndIf
  If Transformed
    Return (Rank - 1) as Float * 4.0
  EndIf
  Return (Rank - 1) as Float * 2.0
EndFunction

Float Function GetTotalSpeedBonus(Float Satiation)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.TotalSpeed34(Self)
  EndIf
  Return Self.GetRankSpeedBonus(IsHenshined)
EndFunction

Function SaveDefaultTattooProperty(Int PSQKey, Int Index, Int Kind)
  If !Self.HasNiOverrideRuntime()
    Return
  EndIf
  String Saved = "PSQ_DefaultTattoo_" + PSQKey as String
  Bool Present = nioverride.HasNodeOverride(PlayerRef as ObjectReference, True, "Body [Ovl5]", PSQKey, Index)
  storageutil.SetIntValue(PlayerRef as Form, Saved + "_Present", Present as Int)
  If Present
    If Kind == 0
      storageutil.SetStringValue(PlayerRef as Form, Saved, nioverride.GetNodeOverrideString(PlayerRef as ObjectReference, True, "Body [Ovl5]", PSQKey, Index))
    ElseIf Kind == 1
      storageutil.SetIntValue(PlayerRef as Form, Saved, nioverride.GetNodeOverrideInt(PlayerRef as ObjectReference, True, "Body [Ovl5]", PSQKey, Index))
    Else
      storageutil.SetFloatValue(PlayerRef as Form, Saved, nioverride.GetNodeOverrideFloat(PlayerRef as ObjectReference, True, "Body [Ovl5]", PSQKey, Index))
    EndIf
  EndIf
EndFunction

Function RestoreDefaultTattooProperty(Int PSQKey, Int Index, Int Kind)
  If !Self.HasNiOverrideRuntime()
    Return
  EndIf
  String Saved = "PSQ_DefaultTattoo_" + PSQKey as String
  If storageutil.GetIntValue(PlayerRef as Form, Saved + "_Present", 0) == 1
    If Kind == 0
      nioverride.AddNodeOverrideString(PlayerRef as ObjectReference, True, "Body [Ovl5]", PSQKey, Index, storageutil.GetStringValue(PlayerRef as Form, Saved, ""), True)
    ElseIf Kind == 1
      nioverride.AddNodeOverrideInt(PlayerRef as ObjectReference, True, "Body [Ovl5]", PSQKey, Index, storageutil.GetIntValue(PlayerRef as Form, Saved, 0), True)
    Else
      nioverride.AddNodeOverrideFloat(PlayerRef as ObjectReference, True, "Body [Ovl5]", PSQKey, Index, storageutil.GetFloatValue(PlayerRef as Form, Saved, 0.0), True)
    EndIf
  ElseIf Kind == 0
    nioverride.AddNodeOverrideString(PlayerRef as ObjectReference, True, "Body [Ovl5]", PSQKey, Index, "Actors\\Character\\slavetats\\blank.dds", True)
  ElseIf Kind == 1
    Int DefaultColor = 0
    If PSQKey == 7
      DefaultColor = -1
    EndIf
    nioverride.AddNodeOverrideInt(PlayerRef as ObjectReference, True, "Body [Ovl5]", PSQKey, Index, DefaultColor, True)
  Else
    nioverride.AddNodeOverrideFloat(PlayerRef as ObjectReference, True, "Body [Ovl5]", PSQKey, Index, 0.0, True)
  EndIf
  storageutil.UnsetIntValue(PlayerRef as Form, Saved + "_Present")
  storageutil.UnsetStringValue(PlayerRef as Form, Saved)
  storageutil.UnsetIntValue(PlayerRef as Form, Saved)
  storageutil.UnsetFloatValue(PlayerRef as Form, Saved)
EndFunction

Function SetDefaultSuccubusTattoo(Bool Show)
  If !Self.HasNiOverrideRuntime()
    Return
  EndIf
  If psqracecompatibility.IsUBEActor(PlayerRef)
    Show = False
  EndIf
  Bool Active = storageutil.GetIntValue(PlayerRef as Form, "PSQ_DefaultTattooActive", 0) == 1
  If Show
    If !nioverride.HasOverlays(PlayerRef as ObjectReference)
      nioverride.AddOverlays(PlayerRef as ObjectReference)
    EndIf
    If !Active
      Self.SaveDefaultTattooProperty(9, 0, 0)
      Self.SaveDefaultTattooProperty(7, -1, 1)
      Self.SaveDefaultTattooProperty(8, -1, 2)
      Self.SaveDefaultTattooProperty(0, -1, 1)
      Self.SaveDefaultTattooProperty(1, -1, 2)
      storageutil.SetIntValue(PlayerRef as Form, "PSQ_DefaultTattooActive", 1)
    EndIf
    nioverride.AddNodeOverrideString(PlayerRef as ObjectReference, True, "Body [Ovl5]", 9, 0, Self.GetEvolvingSuccubusTattooTexture(SuccubusRank.GetValueInt()), True)
    If !EnableBodyPaintTintChangeSatiation || EnableCustomTattooGlow && PreserveTattooGlowColor
      nioverride.AddNodeOverrideInt(PlayerRef as ObjectReference, True, "Body [Ovl5]", 7, -1, -1, True)
    EndIf
    If !EnableBodyPaintAlphaChangeSatiation
      nioverride.AddNodeOverrideFloat(PlayerRef as ObjectReference, True, "Body [Ovl5]", 8, -1, 1.0, True)
    EndIf
    If !EnableBodyPaintGlowTintChangeSatiation && !EnableCustomTattooGlow
      nioverride.AddNodeOverrideInt(PlayerRef as ObjectReference, True, "Body [Ovl5]", 0, -1, 0, True)
    EndIf
    If !EnableBodyPaintGlowAlphaChangeSatiation && !EnableCustomTattooGlow
      nioverride.AddNodeOverrideFloat(PlayerRef as ObjectReference, True, "Body [Ovl5]", 1, -1, 0.0, True)
    EndIf
  ElseIf Active
    Self.RestoreDefaultTattooProperty(9, 0, 0)
    Self.RestoreDefaultTattooProperty(7, -1, 1)
    Self.RestoreDefaultTattooProperty(8, -1, 2)
    Self.RestoreDefaultTattooProperty(0, -1, 1)
    Self.RestoreDefaultTattooProperty(1, -1, 2)
    storageutil.UnsetIntValue(PlayerRef as Form, "PSQ_DefaultTattooActive")
  EndIf
  If Show || Active
    nioverride.ApplyNodeOverrides(PlayerRef as ObjectReference)
  EndIf
EndFunction

Bool Function IsEmptyPlayerTattooTexture(String Texture)
  Return Texture == "" || Texture == "Actors\\Character\\Overlays\\Default.dds" || Texture == "textures\\Actors\\Character\\Overlays\\Default.dds" || Texture == "Actors\\Character\\slavetats\\blank.dds" || Texture == "textures\\Actors\\Character\\slavetats\\blank.dds"
EndFunction

Bool Function IsPSQPlayerTattooTexture(String Texture)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777234
    Return PSQAppearance.OwnsTattooTexture(Texture)
  EndIf
  Int Choice = 1
  While Choice <= 18
    If Texture == Self.GetFixedSuccubusTattooTexture(Choice)
      Return True
    EndIf
    Choice += 1
  EndWhile
  Return False
EndFunction

Function ReleasePlayerTattooSlotState(String Node, String Prefix, Bool Female, Bool Write)
  Self.RestoreTattooSlotProperty(Node, Prefix, 9, 0, 0, Female, Write)
  Self.RestoreTattooSlotProperty(Node, Prefix, 7, -1, 1, Female, Write)
  Self.RestoreTattooSlotProperty(Node, Prefix, 8, -1, 2, Female, Write)
  Self.RestoreTattooSlotProperty(Node, Prefix, 0, -1, 1, Female, Write)
  Self.RestoreTattooSlotProperty(Node, Prefix, 1, -1, 2, Female, Write)
  storageutil.UnsetIntValue(PlayerRef as Form, Prefix + "_Active")
  If Write
    TattooPresentationNeedsApply = True
  EndIf
EndFunction

Function ReleaseLegacyDragonbornTattoo()
  If storageutil.GetIntValue(PlayerRef as Form, "PSQ_DragonbornTattoo_Active", 0) == 1
    String Texture = nioverride.GetNodeOverrideString(PlayerRef as ObjectReference, True, "Body [Ovl6]", 9, 0)
    Self.ReleasePlayerTattooSlotState("Body [Ovl6]", "PSQ_DragonbornTattoo", True, Self.IsPSQPlayerTattooTexture(Texture))
  EndIf
EndFunction

Function ReleaseDragonbornTattoo(Bool ApplyNow)
  If !Self.HasNiOverrideRuntime() || PlayerRef == None
    Return
  EndIf
  Self.ReleaseLegacyDragonbornTattoo()
  String Node = storageutil.GetStringValue(PlayerRef as Form, "PSQ_PlayerTattoo_Node", "")
  If Node != "" && storageutil.GetIntValue(PlayerRef as Form, "PSQ_PlayerTattoo_Active", 0) == 1
    Bool Female = storageutil.GetIntValue(PlayerRef as Form, "PSQ_PlayerTattoo_Female", 1) == 1
    String Texture = storageutil.GetStringValue(PlayerRef as Form, "PSQ_PlayerTattoo_Texture", "")
    Bool Owned = Texture != "" && nioverride.GetNodeOverrideString(PlayerRef as ObjectReference, Female, Node, 9, 0) == Texture
    Self.ReleasePlayerTattooSlotState(Node, "PSQ_PlayerTattoo", Female, Owned)
  EndIf
  storageutil.UnsetStringValue(PlayerRef as Form, "PSQ_PlayerTattoo_Node")
  storageutil.UnsetStringValue(PlayerRef as Form, "PSQ_PlayerTattoo_Texture")
  storageutil.UnsetIntValue(PlayerRef as Form, "PSQ_PlayerTattoo_Female")
  storageutil.UnsetIntValue(PlayerRef as Form, "PSQ_PlayerTattoo_Slot")
  If ApplyNow && TattooPresentationNeedsApply && PlayerRef.Is3DLoaded()
    nioverride.ApplyNodeOverrides(PlayerRef as ObjectReference)
  EndIf
EndFunction

String Function ResolveDragonbornTattooNode(Bool Show)
  Return Self.ResolvePlayerTattooSlot(Show, psqracecompatibility.IsUBEActor(PlayerRef))
EndFunction

String Function ResolvePlayerTattooSlot(Bool Show, Bool AllowBuiltinSlot)
  Self.ReleaseLegacyDragonbornTattoo()
  If !Show
    Self.ReleaseDragonbornTattoo(False)
    Return ""
  EndIf
  If !nioverride.HasOverlays(PlayerRef as ObjectReference)
    nioverride.AddOverlays(PlayerRef as ObjectReference)
    TattooPresentationNeedsApply = True
  EndIf
  Bool Female = PlayerRef.GetLeveledActorBase().GetSex() == 1
  Int Limit = nioverride.GetNumBodyOverlays()
  String Node = storageutil.GetStringValue(PlayerRef as Form, "PSQ_PlayerTattoo_Node", "")
  If Node != ""
    Int Slot = storageutil.GetIntValue(PlayerRef as Form, "PSQ_PlayerTattoo_Slot", -1)
    Bool SavedFemale = storageutil.GetIntValue(PlayerRef as Form, "PSQ_PlayerTattoo_Female", 1) == 1
    String Texture = storageutil.GetStringValue(PlayerRef as Form, "PSQ_PlayerTattoo_Texture", "")
    Bool Active = storageutil.GetIntValue(PlayerRef as Form, "PSQ_PlayerTattoo_Active", 0) == 1
    If Active && SavedFemale == Female && Slot >= 0 && Slot < Limit && (Slot != 5 || AllowBuiltinSlot) && Node == ("Body [Ovl" + Slot as String) + "]"
      If !netimmerse.HasNode(PlayerRef as ObjectReference, Node, False)
        ; Clothing can rebuild the skeleton between updates. Keep the saved
        ; slot and retry after it is attached instead of releasing another layer.
        Return ""
      EndIf
      If Texture != "" && nioverride.GetNodeOverrideString(PlayerRef as ObjectReference, SavedFemale, Node, 9, 0) == Texture
        Return Node
      EndIf
    EndIf
    Self.ReleaseDragonbornTattoo(False)
  EndIf
  Int CandidateSlot = 0
  While CandidateSlot < Limit
    String Candidate = ("Body [Ovl" + CandidateSlot as String) + "]"
    If (CandidateSlot != 5 || AllowBuiltinSlot) && netimmerse.HasNode(PlayerRef as ObjectReference, Candidate, False)
      String StoredTexture = nioverride.GetNodeOverrideString(PlayerRef as ObjectReference, Female, Candidate, 9, 0)
      String LiveTexture = nioverride.GetNodePropertyString(PlayerRef as ObjectReference, False, Candidate, 9, 0)
      If Self.IsEmptyPlayerTattooTexture(StoredTexture) && Self.IsEmptyPlayerTattooTexture(LiveTexture)
        storageutil.SetStringValue(PlayerRef as Form, "PSQ_PlayerTattoo_Node", Candidate)
        storageutil.SetIntValue(PlayerRef as Form, "PSQ_PlayerTattoo_Slot", CandidateSlot)
        storageutil.SetIntValue(PlayerRef as Form, "PSQ_PlayerTattoo_Female", Female as Int)
        storageutil.UnsetIntValue(PlayerRef as Form, "PSQ_PlayerTattoo_Deferred")
        TattooPresentationNeedsApply = True
        Return Candidate
      EndIf
    EndIf
    CandidateSlot += 1
  EndWhile
  If storageutil.GetIntValue(PlayerRef as Form, "PSQ_PlayerTattoo_Deferred", 0) == 0
    Debug.Trace("[PSQ] Player tattoo deferred: no free, loaded body overlay; configured count=" + Limit as String, 0)
    storageutil.SetIntValue(PlayerRef as Form, "PSQ_PlayerTattoo_Deferred", 1)
  EndIf
  Return ""
EndFunction

Function SaveTattooSlotProperty(String Node, String Prefix, Int PSQKey, Int Index, Int Kind, Bool Female)
  If !Self.HasNiOverrideRuntime()
    Return
  EndIf
  String Saved = Prefix + "_" + PSQKey as String
  Bool Present = nioverride.HasNodeOverride(PlayerRef as ObjectReference, Female, Node, PSQKey, Index)
  storageutil.SetIntValue(PlayerRef as Form, Saved + "_Present", Present as Int)
  If Present
    If Kind == 0
      storageutil.SetStringValue(PlayerRef as Form, Saved, nioverride.GetNodeOverrideString(PlayerRef as ObjectReference, Female, Node, PSQKey, Index))
    ElseIf Kind == 1
      storageutil.SetIntValue(PlayerRef as Form, Saved, nioverride.GetNodeOverrideInt(PlayerRef as ObjectReference, Female, Node, PSQKey, Index))
    Else
      storageutil.SetFloatValue(PlayerRef as Form, Saved, nioverride.GetNodeOverrideFloat(PlayerRef as ObjectReference, Female, Node, PSQKey, Index))
    EndIf
  EndIf
EndFunction

Function RestoreTattooSlotProperty(String Node, String Prefix, Int PSQKey, Int Index, Int Kind, Bool Female, Bool Write)
  If !Self.HasNiOverrideRuntime()
    Return
  EndIf
  String Saved = Prefix + "_" + PSQKey as String
  If Write
    If storageutil.GetIntValue(PlayerRef as Form, Saved + "_Present", 0) == 1
      If Kind == 0
        nioverride.AddNodeOverrideString(PlayerRef as ObjectReference, Female, Node, PSQKey, Index, storageutil.GetStringValue(PlayerRef as Form, Saved, ""), True)
      ElseIf Kind == 1
        nioverride.AddNodeOverrideInt(PlayerRef as ObjectReference, Female, Node, PSQKey, Index, storageutil.GetIntValue(PlayerRef as Form, Saved, 0), True)
      Else
        nioverride.AddNodeOverrideFloat(PlayerRef as ObjectReference, Female, Node, PSQKey, Index, storageutil.GetFloatValue(PlayerRef as Form, Saved, 0.0), True)
      EndIf
    ElseIf Kind == 0
      nioverride.AddNodeOverrideString(PlayerRef as ObjectReference, Female, Node, PSQKey, Index, "Actors\\Character\\slavetats\\blank.dds", True)
    ElseIf Kind == 1
      Int DefaultColor = 0
      If PSQKey == 7
        DefaultColor = -1
      EndIf
      nioverride.AddNodeOverrideInt(PlayerRef as ObjectReference, Female, Node, PSQKey, Index, DefaultColor, True)
    Else
      nioverride.AddNodeOverrideFloat(PlayerRef as ObjectReference, Female, Node, PSQKey, Index, 0.0, True)
    EndIf
  EndIf
  storageutil.UnsetIntValue(PlayerRef as Form, Saved + "_Present")
  storageutil.UnsetStringValue(PlayerRef as Form, Saved)
  storageutil.UnsetIntValue(PlayerRef as Form, Saved)
  storageutil.UnsetFloatValue(PlayerRef as Form, Saved)
EndFunction

Bool Function SetSuccubusTattooOverlay(String Node, String Prefix, String Texture, Bool Show, Bool ApplyNow, Bool Female)
  If !Self.HasNiOverrideRuntime()
    Return False
  EndIf
  Bool Changed = False
  Bool Active = storageutil.GetIntValue(PlayerRef as Form, Prefix + "_Active", 0) == 1
  If Show
    If !nioverride.HasOverlays(PlayerRef as ObjectReference)
      nioverride.AddOverlays(PlayerRef as ObjectReference)
      Changed = True
    EndIf
    If !Active
      Changed = True
      Self.SaveTattooSlotProperty(Node, Prefix, 9, 0, 0, Female)
      Self.SaveTattooSlotProperty(Node, Prefix, 7, -1, 1, Female)
      Self.SaveTattooSlotProperty(Node, Prefix, 8, -1, 2, Female)
      Self.SaveTattooSlotProperty(Node, Prefix, 0, -1, 1, Female)
      Self.SaveTattooSlotProperty(Node, Prefix, 1, -1, 2, Female)
      storageutil.SetIntValue(PlayerRef as Form, Prefix + "_Active", 1)
    EndIf
    Changed = Self.SetTattooStringIfChanged(Node, 9, 0, Texture, Female) || Changed
    If !EnableBodyPaintTintChangeSatiation || EnableCustomTattooGlow && PreserveTattooGlowColor
      Changed = Self.SetTattooIntIfChanged(Node, 7, -1, -1, Female) || Changed
    EndIf
    If !EnableBodyPaintAlphaChangeSatiation
      Changed = Self.SetTattooFloatIfChanged(Node, 8, -1, 1.0, Female) || Changed
    EndIf
    If !EnableBodyPaintGlowTintChangeSatiation && !EnableCustomTattooGlow
      Changed = Self.SetTattooIntIfChanged(Node, 0, -1, 0, Female) || Changed
    EndIf
    If !EnableBodyPaintGlowAlphaChangeSatiation && !EnableCustomTattooGlow
      Changed = Self.SetTattooFloatIfChanged(Node, 1, -1, 0.0, Female) || Changed
    EndIf
  ElseIf Active
    Changed = True
    Self.RestoreTattooSlotProperty(Node, Prefix, 9, 0, 0, Female, True)
    Self.RestoreTattooSlotProperty(Node, Prefix, 7, -1, 1, Female, True)
    Self.RestoreTattooSlotProperty(Node, Prefix, 8, -1, 2, Female, True)
    Self.RestoreTattooSlotProperty(Node, Prefix, 0, -1, 1, Female, True)
    Self.RestoreTattooSlotProperty(Node, Prefix, 1, -1, 2, Female, True)
    storageutil.UnsetIntValue(PlayerRef as Form, Prefix + "_Active")
  EndIf
  If ApplyNow && Changed
    nioverride.ApplyNodeOverrides(PlayerRef as ObjectReference)
  EndIf
  Return Changed
EndFunction

Bool Function ApplySuccubusTattooGradient(String Node, Float Manpukudo, Bool ApplyNow)
  Self.ComputeTattooGradient(Manpukudo)
  Return Self.ApplyComputedTattooGradient(Node, Manpukudo, ApplyNow, True)
EndFunction

Bool Function ApplyComputedTattooGradient(String Node, Float Manpukudo, Bool ApplyNow, Bool Female)
  Bool PSQVisualRuntime = skse.GetPluginVersion("skee") >= 0 || skse.GetPluginVersion("nioverride") >= 0
  Int GlowMode = Self.GetTattooGlowMode()
  Bool Changed = False
  If EnableBodyPaintTintChangeSatiation && !(EnableCustomTattooGlow && PreserveTattooGlowColor)
    Changed = Self.SetTattooIntIfChanged(Node, 7, -1, BPTintCurrentColor, Female) || Changed
  EndIf
  If EnableBodyPaintAlphaChangeSatiation
    Changed = Self.SetTattooFloatIfChanged(Node, 8, -1, Manpukudo, Female) || Changed
  EndIf
  If GlowMode != 0 && (EnableBodyPaintGlowTintChangeSatiation || EnableCustomTattooGlow)
    Changed = Self.SetTattooIntIfChanged(Node, 0, -1, BPGTintCurrentColor, Female) || Changed
  EndIf
  If GlowMode != 0 && (EnableBodyPaintGlowAlphaChangeSatiation || EnableCustomTattooGlow)
    Changed = Self.SetTattooFloatIfChanged(Node, 1, -1, BPGCurrentAlpha, Female) || Changed
  EndIf
  If GlowMode == 0
    Changed = Self.SetTattooIntIfChanged(Node, 0, -1, 0, Female) || Changed
    Changed = Self.SetTattooFloatIfChanged(Node, 1, -1, 0.0, Female) || Changed
  EndIf
  If ApplyNow && Changed
    If PSQVisualRuntime
      nioverride.ApplyNodeOverrides(PlayerRef as ObjectReference)
    EndIf
  EndIf
  Return Changed
EndFunction

String Function GetUBEBodyTattooTexture(String Texture)
  String Root = "PSQ\\Overlays\\"
  If StringUtil.Find(Texture, Root) != 0
    Return ""
  EndIf
  Return Root + "UBE\\" + StringUtil.Substring(Texture, StringUtil.GetLength(Root))
EndFunction

String Function GetSelectedSuccubusTattooTexture()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777234
    Return PSQAppearance.TattooTexture(SuccubusTattooSelection, SuccubusRank.GetValueInt())
  EndIf
  If SuccubusTattooSelection == 19
    Return Self.GetEvolvingSuccubusTattooTexture(SuccubusRank.GetValueInt())
  EndIf
  If SuccubusTattooSelection == 9
    Return "PSQ\\Overlays\\RankTattoos\\Rank01.dds"
  EndIf
  If SuccubusTattooSelection == 10
    Return "PSQ\\Overlays\\RankTattoos\\Rank02.dds"
  EndIf
  If SuccubusTattooSelection == 11
    Return "PSQ\\Overlays\\RankTattoos\\Rank03.dds"
  EndIf
  If SuccubusTattooSelection == 12
    Return "PSQ\\Overlays\\RankTattoos\\Rank04.dds"
  EndIf
  If SuccubusTattooSelection == 13
    Return "PSQ\\Overlays\\RankTattoos\\Rank05.dds"
  EndIf
  If SuccubusTattooSelection == 14
    Return "PSQ\\Overlays\\RankTattoos\\Rank06.dds"
  EndIf
  If SuccubusTattooSelection == 15
    Return "PSQ\\Overlays\\RankTattoos\\Rank07.dds"
  EndIf
  If SuccubusTattooSelection == 16
    Return "PSQ\\Overlays\\RankTattoos\\Rank08.dds"
  EndIf
  If SuccubusTattooSelection == 17
    Return "PSQ\\Overlays\\RankTattoos\\Rank09.dds"
  EndIf
  If SuccubusTattooSelection == 18
    Return "PSQ\\Overlays\\RankTattoos\\Rank10.dds"
  EndIf
  If SuccubusTattooSelection < 1 || SuccubusTattooSelection > 8
    Return Self.GetEvolvingSuccubusTattooTexture(SuccubusRank.GetValueInt())
  EndIf
  If SuccubusTattooSelection == 1
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_01.dds"
  EndIf
  If SuccubusTattooSelection == 2
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_02.dds"
  EndIf
  If SuccubusTattooSelection == 3
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_03.dds"
  EndIf
  If SuccubusTattooSelection == 4
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_04.dds"
  EndIf
  If SuccubusTattooSelection == 5
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_05.dds"
  EndIf
  If SuccubusTattooSelection == 6
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_06.dds"
  EndIf
  If SuccubusTattooSelection == 7
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_07.dds"
  EndIf
  If SuccubusTattooSelection == 8
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_08.dds"
  EndIf
  Return Self.GetEvolvingSuccubusTattooTexture(SuccubusRank.GetValueInt())
EndFunction

Float Function GetRankShoutCooldownReduction()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.RankShout34(Self)
  EndIf
  If !EnableRankShoutCooldownBonus || PlayerIsSuccubus.GetValueInt() != 1
    Return 0.0
  EndIf
  Int Rank = SuccubusRank.GetValueInt()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777228
    Return PSQAppearance.ShoutReduction(Rank)
  EndIf
  If Rank < 2
    Return 0.0
  ElseIf Rank > 10
    Rank = 10
  EndIf
  Return (Rank - 1) as Float * 0.050000001
EndFunction

Function UpdateRankShoutCooldownBonus()
  If !Self.ResolveRankShoutAbilities()
    Return
  EndIf
  If !RankShoutAbilityMigrated
    If AppliedRankShoutCooldownReduction != 0.0
      PlayerRef.ModActorValue("ShoutRecoveryMult", AppliedRankShoutCooldownReduction)
    EndIf
    AppliedRankShoutCooldownReduction = 0.0
    RankShoutAbilityMigrated = True
  EndIf
  Float Desired = Self.GetRankShoutCooldownReduction()
  If Desired <= 0.0
    If PlayerRef.HasSpell(RankShoutAbilityA as Form)
      PlayerRef.RemoveSpell(RankShoutAbilityA)
    EndIf
    If PlayerRef.HasSpell(RankShoutAbilityB as Form)
      PlayerRef.RemoveSpell(RankShoutAbilityB)
    EndIf
    AppliedRankShoutCooldownReduction = 0.0
    Return
  EndIf
  If PlayerRef.HasSpell(RankShoutAbilityA as Form) && PlayerRef.HasSpell(RankShoutAbilityB as Form)
    PlayerRef.RemoveSpell(RankShoutAbilityB)
    AppliedRankShoutCooldownReduction = 0.0
  EndIf
  If Desired != AppliedRankShoutCooldownReduction || !PlayerRef.HasSpell(RankShoutAbilityA as Form) && !PlayerRef.HasSpell(RankShoutAbilityB as Form)
    Spell NextAbility = RankShoutAbilityA
    Spell OldAbility = RankShoutAbilityB
    If PlayerRef.HasSpell(RankShoutAbilityA as Form)
      NextAbility = RankShoutAbilityB
      OldAbility = RankShoutAbilityA
    EndIf
    NextAbility.SetNthEffectMagnitude(0, Desired)
    PlayerRef.RemoveSpell(OldAbility)
    PlayerRef.AddSpell(NextAbility, False)
    AppliedRankShoutCooldownReduction = Desired
  EndIf
EndFunction

Bool Function SetTattooStringIfChanged(String Node, Int PSQKey, Int Index, String value, Bool Female)
  If !Self.HasNiOverrideRuntime()
    Return False
  EndIf
  If nioverride.HasNodeOverride(PlayerRef as ObjectReference, Female, Node, PSQKey, Index)
    If nioverride.GetNodeOverrideString(PlayerRef as ObjectReference, Female, Node, PSQKey, Index) == value
      Return False
    EndIf
  EndIf
  nioverride.AddNodeOverrideString(PlayerRef as ObjectReference, Female, Node, PSQKey, Index, value, True)
  Return True
EndFunction

Bool Function SetTattooIntIfChanged(String Node, Int PSQKey, Int Index, Int value, Bool Female)
  If !Self.HasNiOverrideRuntime()
    Return False
  EndIf
  If nioverride.HasNodeOverride(PlayerRef as ObjectReference, Female, Node, PSQKey, Index)
    If nioverride.GetNodeOverrideInt(PlayerRef as ObjectReference, Female, Node, PSQKey, Index) == value
      Return False
    EndIf
  EndIf
  nioverride.AddNodeOverrideInt(PlayerRef as ObjectReference, Female, Node, PSQKey, Index, value, True)
  Return True
EndFunction

Bool Function SetTattooFloatIfChanged(String Node, Int PSQKey, Int Index, Float value, Bool Female)
  If !Self.HasNiOverrideRuntime()
    Return False
  EndIf
  If nioverride.HasNodeOverride(PlayerRef as ObjectReference, Female, Node, PSQKey, Index)
    If nioverride.GetNodeOverrideFloat(PlayerRef as ObjectReference, Female, Node, PSQKey, Index) == value
      Return False
    EndIf
  EndIf
  nioverride.AddNodeOverrideFloat(PlayerRef as ObjectReference, Female, Node, PSQKey, Index, value, True)
  Return True
EndFunction

Int Function GetSuccubusEyeMaterialCount()
  Return Self.GetSuccubusEyeMaterialCount38()
EndFunction

String Function GetSuccubusEyeMaterialName(Int Index)
  Return Self.GetSuccubusEyeMaterialName38(Index)
EndFunction

Function ApplySelectedSuccubusEyes(Int Owner, Bool RequireBusy)
  Self.ApplySelectedSuccubusEyes40(Owner, RequireBusy)
EndFunction

Function RefreshSuccubusEyeToggle(Int Owner, Bool RequireBusy)
  Self.RefreshSuccubusEyeToggle40(Owner, RequireBusy)
EndFunction

Function MigrateHeartEyeSelection()
  Self.MigrateHeartEyeSelection38()
EndFunction

Function UpdateAnimationEnergyPercent(Float Ratio)
  If AnimationEnergyPercent == None
    AnimationEnergyPercent = Game.GetFormFromFile(40830, "PSQ PlayerSuccubusQuest.esm") as GlobalVariable
  EndIf
  If Ratio < 0.0
    Ratio = 0.0
  ElseIf Ratio > 1.0
    Ratio = 1.0
  EndIf
  If AnimationEnergyPercent
    AnimationEnergyPercent.SetValue(Ratio * 100.0)
  EndIf
EndFunction

Float Function CalculateEnergyCapacity()
  Float EXP = SuccubusEXP.GetValue()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777229
    Return PSQAppearance.EnergyCapacity(EXP)
  EndIf
  If EXP < 0.0
    EXP = 0.0
  EndIf
  If EXP >= 10.0
    Return 250.0 * Math.Sqrt(EXP)
  EndIf
  Return 60.0 * EXP + 200.0
EndFunction

Function RefreshEnergyCapacity()
  MaxEnergy = Self.CalculateEnergyCapacity()
  EnergyConsumption = MaxEnergy * EnergyConsumptionPerMax / 100.0
EndFunction

Float Function GetEnergyRatio()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.EnergyRatio34(Self)
  EndIf
  If MaxEnergy <= 0.0
    Return 0.0
  EndIf
  Float Ratio = SuccubusEnergy.GetValue() / MaxEnergy
  If Ratio < 0.0
    Return 0.0
  ElseIf Ratio > 1.0
    Return 1.0
  EndIf
  Return Ratio
EndFunction

Bool Function ResolveRankShoutAbilities()
  If !RankShoutAbilityA
    RankShoutAbilityA = Game.GetFormFromFile(40832, "PSQ PlayerSuccubusQuest.esm") as Spell
  EndIf
  If !RankShoutAbilityB
    RankShoutAbilityB = Game.GetFormFromFile(40833, "PSQ PlayerSuccubusQuest.esm") as Spell
  EndIf
  Return RankShoutAbilityA != None && RankShoutAbilityB != None
EndFunction

Function ResetRankShoutCooldownBonus()
  If !Self.ResolveRankShoutAbilities()
    Return
  EndIf
  Self.UpdateRankShoutCooldownBonus()
  PlayerRef.RemoveSpell(RankShoutAbilityA)
  PlayerRef.RemoveSpell(RankShoutAbilityB)
  AppliedRankShoutCooldownReduction = 0.0
  Self.UpdateRankShoutCooldownBonus()
EndFunction

Function DrainHighestNPCSkill(Actor Target)
  If SkillDrainMode == 0 || SkillDrainBusy || Target == None || Target == PlayerRef
    Return
  EndIf
  If Target.IsDead() || !Target.HasKeywordString("ActorTypeNPC")
    Return
  EndIf
  SkillDrainBusy = True
  If !DrainSkillNames
    DrainSkillNames = new String[18]
    DrainSkillNames[0] = "OneHanded"
    DrainSkillNames[1] = "TwoHanded"
    DrainSkillNames[2] = "Marksman"
    DrainSkillNames[3] = "Block"
    DrainSkillNames[4] = "Smithing"
    DrainSkillNames[5] = "HeavyArmor"
    DrainSkillNames[6] = "LightArmor"
    DrainSkillNames[7] = "Pickpocket"
    DrainSkillNames[8] = "Lockpicking"
    DrainSkillNames[9] = "Sneak"
    DrainSkillNames[10] = "Alchemy"
    DrainSkillNames[11] = "Speechcraft"
    DrainSkillNames[12] = "Alteration"
    DrainSkillNames[13] = "Conjuration"
    DrainSkillNames[14] = "Destruction"
    DrainSkillNames[15] = "Illusion"
    DrainSkillNames[16] = "Restoration"
    DrainSkillNames[17] = "Enchanting"
  EndIf
  String[] Skills = DrainSkillNames
  Int ChosenSkill = -1
  Float Highest = 2.0
  Float PlayerLevel = 0.0
  Int Amount = 0
  Float[] Selected
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Selected = PSQAppearance.SelectDrainSkill(Target,PlayerRef,SkillDrainMode,SuccubusRank.GetValueInt(),Utility.RandomInt(0,2147483646))
  EndIf
  If Selected && Selected.Length == 4
    ChosenSkill = Selected[0] as Int
    Highest = Selected[1]
    PlayerLevel = Selected[2]
    Amount = Selected[3] as Int
  Else
    Int[] Candidates = new Int[18]
    Int Count = 0
    Int i = 0
    While i < Skills.Length
      Float Level = Target.GetBaseActorValue(Skills[i])
      If Level > Highest
        Highest = Level
        Count = 1
        Candidates[0] = i
      ElseIf Level == Highest
        Candidates[Count] = i
        Count += 1
      EndIf
      i += 1
    EndWhile
    If Count > 0
      ChosenSkill = Candidates[Utility.RandomInt(0,Count-1)]
      PlayerLevel = PlayerRef.GetBaseActorValue(Skills[ChosenSkill])
      Amount = Self.GetSkillDrainAmount(Highest,PlayerLevel)
    EndIf
  EndIf
  If ChosenSkill >= 0 && ChosenSkill < Skills.Length
    String Skill = Skills[ChosenSkill]
    If Amount > 0
      Game.IncrementSkillBy(Skill, Amount)
      Float NewLevel = PlayerRef.GetBaseActorValue(Skill)
      Float ActualGain = NewLevel - PlayerLevel
      If ActualGain > 0.0
        If ActualGain > Amount as Float
          ActualGain = Amount as Float
        EndIf
        Target.SetActorValue(Skill, Highest - ActualGain)
        Self.RecordGrowthAbsorption("Skill", Skill, ActualGain)
        Debug.Notification(("从" + Target.GetLeveledActorBase().GetName() + "吸取技能：" + Self.GetDrainedSkillName(Skill) + "，目标 -" + (ActualGain as Int) as String) + "，玩家 +" + (ActualGain as Int) as String)
      EndIf
    EndIf
  EndIf
  SkillDrainBusy = False
EndFunction

String Function GetDrainedSkillName(String Skill)
  If Skill == "OneHanded"
    Return "单手武器"
  ElseIf Skill == "TwoHanded"
    Return "双手武器"
  ElseIf Skill == "Marksman"
    Return "弓术"
  ElseIf Skill == "Block"
    Return "格挡"
  ElseIf Skill == "Smithing"
    Return "锻造"
  ElseIf Skill == "HeavyArmor"
    Return "重甲"
  ElseIf Skill == "LightArmor"
    Return "轻甲"
  ElseIf Skill == "Pickpocket"
    Return "扒窃"
  ElseIf Skill == "Lockpicking"
    Return "开锁"
  ElseIf Skill == "Sneak"
    Return "潜行"
  ElseIf Skill == "Alchemy"
    Return "炼金"
  ElseIf Skill == "Speechcraft"
    Return "口才"
  ElseIf Skill == "Alteration"
    Return "变幻"
  ElseIf Skill == "Conjuration"
    Return "召唤"
  ElseIf Skill == "Destruction"
    Return "毁灭"
  ElseIf Skill == "Illusion"
    Return "幻术"
  ElseIf Skill == "Restoration"
    Return "恢复"
  ElseIf Skill == "Enchanting"
    Return "附魔"
  EndIf
  Return Skill
EndFunction

String Function GetSuccubusOutfitName(Int Selection)
  If Selection == 100
    Return "$PSQ_OutfitHarryTERA"
  EndIf
  If Selection == 0
    Return "$PSQ_OutfitName4"
  ElseIf Selection == 1
    Return "$PSQ_OutfitName1"
  ElseIf Selection == 2
    Return "$PSQ_OutfitName2"
  ElseIf Selection == 3
    Return "$PSQ_OutfitName3"
  ElseIf Selection == 4
    Return "$PSQ_OutfitName4"
  ElseIf Selection == 5
    Return "$PSQ_OutfitName5"
  ElseIf Selection == 6
    Return "$PSQ_OutfitName6"
  ElseIf Selection == 7
    Return "$PSQ_OutfitName7"
  ElseIf Selection == 8
    Return "$PSQ_OutfitName8"
  EndIf
  Return "$PSQ_OutfitName4"
EndFunction

Bool Function ApplySuccubusOutfitSelection(Int Selection)
  If !Self.BeginAppearanceEdit()
    Return False
  EndIf
  Int Owner = AppearanceOperationId
  Bool Result = Self.ApplySuccubusOutfitSelectionCore(Selection, Owner, True)
  Self.EndAppearanceEdit(Owner)
  Return Result
EndFunction

Bool Function ApplyEntryOutfitSelection28(Int Selection, Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777244 || IsHenshined
    Return Self.ApplySuccubusOutfitSelectionCore(Selection, Owner, RequireBusy)
  EndIf
  If Selection == 0
    Selection = 4
  EndIf
  Int Epoch = PSQLoadEpoch
  If Selection < 1 || Selection > 8 || IsHenshinchu || !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, Epoch)
    Return False
  EndIf
  Race ExpectedRace = PlayerRef.GetRace()
  Int Family = PSQAppearance.IsUBEActor(PlayerRef)
  If Family < 0
    ; A leveled player base needs the established Papyrus race resolver.
    Return Self.ApplySuccubusOutfitSelectionCore(Selection, Owner, RequireBusy)
  EndIf
  Float Started
  If EnableEquipmentDiagnostics
    Started = Utility.GetCurrentRealTime()
  EndIf
  ; Old saves reconstruct these choices once from their equipped records.
  If !TransformPartSources || TransformPartSources.Length != 5
    If !Self.EnsureEntryPartSources28(Owner, RequireBusy, Epoch)
      Return False
    EndIf
  EndIf
  If !OptionalHornCatalogReady && (OptionalHornSelectedKey != "" || (TransformPartSources && TransformPartSources.Length == 5 && TransformPartSources[3] > 8 && TransformPartSources[3] != 100))
    Self.EnsureOptionalHornCatalog()
  EndIf
  Armor[] Parts = PSQAppearance.ResolveOutfitChoices28(PlayerRef, Self, ExpectedRace, Owner, Epoch, RequireBusy, Selection)
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, Epoch)
    Return False
  EndIf
  If !Parts || Parts.Length != 6
    If PlayerRef.GetRace() != ExpectedRace || PSQAppearance.IsUBEActor(PlayerRef) != Family
      Return False
    EndIf
    If EnableEquipmentDiagnostics
      Debug.Trace("[PSQ-PERF] outfit.choice28; owner=" + Owner + "; route=fallback")
    EndIf
    Return Self.ApplySuccubusOutfitSelectionCore(Selection, Owner, RequireBusy)
  EndIf
  If PSQAppearance.CheckEquipmentContext(PlayerRef, PlayerAppearanceRace, ExpectedRace, Family) != 1
    Return False
  EndIf
  ; The MCM stores the independently selected wing in the armor property.
  ; AWU owns a spell instead. A missing outfit wing stays empty unless the
  ; player has a separately selected wing; the planner checks its body family.
  If AWUWingID > 0
    Parts[5] = None
  ElseIf PSQSuccubusWings != None
    Parts[5] = PSQSuccubusWings
  EndIf
  Bool Changed = SuccubusOutfitSelection != Selection || PSQSuccubusCuirass != Parts[0] || PSQSuccubusBoots != Parts[1] || PSQSuccubusGauntlets != Parts[2] || PSQSuccubusHorns != Parts[3] || PSQSuccubusTail != Parts[4] || PSQSuccubusWings != Parts[5]
  If Changed
    Self.ClearAppliedTransformBody(Owner, RequireBusy)
    If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, Epoch)
      Return False
    EndIf
    If !PSQAppearance.CommitEntryOutfitChoices28(PlayerRef, Self, ExpectedRace, Owner, Epoch, RequireBusy, Selection, Parts, Family)
      Return False
    EndIf
  EndIf
  If EnableEquipmentDiagnostics
    Debug.Trace("[PSQ-PERF] outfit.choice28; owner=" + Owner + "; route=native; selectionSeconds=" + (Utility.GetCurrentRealTime() - Started))
  EndIf
  Self.ApplyPSQOutfitBodyModels(False, Owner, RequireBusy)
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, Epoch)
    Return False
  EndIf
  If Changed
    OutfitSwitchBusy = False
  EndIf
  Return True
EndFunction

Bool Function EnsureEntryPartSources28(Int Owner, Bool RequireBusy, Int Epoch)
  Return PSQAppearance.EnsureEntryPartSources28(PlayerRef, Self, PlayerAppearanceRace, Owner, Epoch, RequireBusy)
EndFunction

Bool Function ApplySuccubusOutfitSelectionCore(Int Selection, Int Owner, Bool RequireBusy)
  Return Self.ApplySuccubusOutfitSelectionCore40(Selection, Owner, RequireBusy)
EndFunction

Int Function GetSkillDrainAmount(Float TargetLevel, Float PlayerLevel)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777230
    Return PSQAppearance.SkillDrainAmount(SkillDrainMode, SuccubusRank.GetValueInt(), TargetLevel, PlayerLevel)
  EndIf
  Int Amount = 0
  If SkillDrainMode == 1
    Amount = 1
  ElseIf SkillDrainMode == 2
    Amount = SuccubusRank.GetValueInt()
    If Amount < 1
      Amount = 1
    ElseIf Amount > 10
      Amount = 10
    EndIf
  EndIf
  Int Available = (TargetLevel - 1.0) as Int
  Int Room = (100.0 - PlayerLevel) as Int
  If Available < Amount
    Amount = Available
  EndIf
  If Room < Amount
    Amount = Room
  EndIf
  If Amount < 0
    Amount = 0
  EndIf
  Return Amount
EndFunction

String Function GetEvolvingSuccubusTattooTexture(Int Rank)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777234
    Return PSQAppearance.TattooTexture(19, Rank)
  EndIf
  If Rank < 1
    Rank = 1
  ElseIf Rank > 10
    Rank = 10
  EndIf
  String Number = Rank as String
  If Rank < 10
    Number = "0" + Number
  EndIf
  Return "PSQ\\Overlays\\RankTattoos\\Rank" + Number + ".dds"
EndFunction

Int Function GetSatiationEffectMode()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.SatietyMode34(Self)
  EndIf
  If SatiationEffectMode == 1 || SatiationEffectMode == 2
    Return 1
  EndIf
  Return 0
EndFunction

Function SetSatiationEffectMode(Int Mode)
  Self.SetSatiationEffectMode40(Mode)
EndFunction

Float Function GetSatiationRankScale()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.RankScale34(Self)
  EndIf
  Int Rank = SuccubusRank.GetValueInt()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777228
    Return PSQAppearance.SatiationScale(Rank)
  EndIf
  If Rank < 1
    Rank = 1
  ElseIf Rank > 10
    Rank = 10
  EndIf
  Return Rank as Float / 10.0
EndFunction

Float Function GetSatiationModifier(Float Satiation, Float Increase, Float Decrease, Float DefaultIncrease, Float DefaultDecrease)
  ; Retired attribute modifiers. Kept for old saved callers only.
  Return 0.0
EndFunction

Function MigrateHybridDefault()
  If !HybridDefaultMigrated
    AllowHybrid = True
    HybridDefaultMigrated = True
  EndIf
EndFunction

Int Function GetDigestionMode()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.DigestionMode34(Self)
  EndIf
  If DigestionMode < 0 || DigestionMode > 2
    Return 1
  EndIf
  Return DigestionMode
EndFunction

Float Function GetAutomaticDigestionRate()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.AutoDigestion34(Self)
  EndIf
  Int Rank = SuccubusRank.GetValueInt()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777230
    Return PSQAppearance.DigestionRate(Rank, CumInflationIncrement)
  EndIf
  If Rank < 1
    Rank = 1
  ElseIf Rank > 10
    Rank = 10
  EndIf
  Return CumInflationIncrement * Rank as Float
EndFunction

Armor Function GetSelectedTransformSkin()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.SelectedSkin34(Self)
  EndIf
  If SuccubusBodySelection == 1
    Return Game.GetFormFromFile(40933, "PSQ PlayerSuccubusQuest.esm") as Armor
  EndIf
  If SuccubusBodySelection == 2
    Return Game.GetFormFromFile(40937, "PSQ PlayerSuccubusQuest.esm") as Armor
  EndIf
  If SuccubusBodySelection == 3
    Return Game.GetFormFromFile(40941, "PSQ PlayerSuccubusQuest.esm") as Armor
  EndIf
  If SuccubusBodySelection == 4
    Return Game.GetFormFromFile(40945, "PSQ PlayerSuccubusQuest.esm") as Armor
  EndIf
  Return Game.GetFormFromFile(40933, "PSQ PlayerSuccubusQuest.esm") as Armor
EndFunction

Function ApplySelectedTransformBody(Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.ApplyTransformBodyMorphs(True, Owner, RequireBusy)
EndFunction

Function ApplyTransformBodyMorphs(Bool RefreshModel, Int Owner, Bool RequireBusy)
  Self.SyncPlayerAppearanceRace()
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  ; Legacy PSQ output is only removed, never calculated or written again.
  Self.CleanupLegacyPSQBodyMorphs(Owner, RequireBusy)
  If TransformBodySaved
    Self.RestoreLegacyTransformSkin(Owner, RequireBusy)
  EndIf
  Self.ApplyPSQOutfitBodyModels(False, Owner, RequireBusy)
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  If !HenshinBody || !IsHenshined || psqracecompatibility.ShouldPreserveBCNGBody(PlayerRef)
    Return
  EndIf
  ; The catalog and slot are invalidated together on load, race change or manual refresh.
  ; RequestBCNGBodyChange still verifies the ID against the current native preset catalog.
  If TransformPresetCatalogVersion < 2 || !TransformBodyCatalogReady || BCNGSelectedPresetId == "" || SuccubusBodySelection < 1 || SuccubusBodySelection > BCNGBodyPresetIds.Length || BCNGBodyPresetIds[SuccubusBodySelection - 1] != BCNGSelectedPresetId
    Self.MigrateTransformPresetCatalog(Owner, RequireBusy)
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  BCNGBodyClearOnly = False
  BCNGBodyNeedsSync = True
  If BCNGSelectedPresetId == "" || SuccubusBodySelection <= 0
    BCNGBodyStatus = -3
    Return
  EndIf
  ; Normal entry checks the same request after equipping. Keep all other callers synchronous.
  Bool DeferWait = RequireBusy && IsHenshinchu && AppearanceTransformDirection == 1 && !AppearanceRecoveryInProgress && !RefreshModel
  Self.RequestBCNGBodyChange(True, BCNGSelectedPresetId, Owner, RequireBusy, !DeferWait)
EndFunction

Function RestoreTransformBody(Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.RestoreTransformBodyMorphs(True, Owner, RequireBusy)
EndFunction

Function RestoreTransformBodyMorphs(Bool RefreshModel, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  Self.CleanupLegacyPSQBodyMorphs(Owner, RequireBusy)
  Self.ClearAppliedTransformBody(Owner, RequireBusy)
  Self.RestoreLegacyTransformSkin(Owner, RequireBusy)
  Self.ApplyPSQOutfitBodyModels(False, Owner, RequireBusy)
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  ; BCNG removes only the PSQ temporary layer; its normal actor choice is intact.
  BCNGBodyClearOnly = True
  Bool DeferWait = RequireBusy && IsHenshinchu && AppearanceTransformDirection == 2 && !AppearanceRecoveryInProgress && !RefreshModel
  Self.RequestBCNGBodyChange(False, "", Owner, RequireBusy, !DeferWait)
EndFunction

Bool Function SetSuccubusBodySelection(Int Selection)
  If !Self.BeginAppearanceEdit()
    Return False
  EndIf
  Int Owner = AppearanceOperationId
  Bool Result = Self.SetSuccubusBodySelectionCore(Selection, Owner, True)
  Self.EndAppearanceEdit(Owner)
  Return Result
EndFunction

Bool Function SetSuccubusBodySelectionCore(Int Selection, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy) || IsHenshinchu || BodySelectionRefreshBusy
    Return False
  EndIf
  Int Count = Self.GetTransformBodyPresetCount(Owner, RequireBusy)
  If Selection < 0 || Selection > Count
    Return False
  EndIf
  String NextId = ""
  String NextName = ""
  If Selection > 0
    If !Self.HasBodyChangeNGAPI() || !BCNGPSQBridge.IsReady()
      Debug.Notification("$PSQ_BCNGAPIMissing")
      Return False
    EndIf
    NextId = BCNGBodyPresetIds[Selection - 1]
    NextName = BCNGPSQBridge.GetPresetName(NextId)
    If NextId == "" || NextName == "" || psqracecompatibility.ShouldPreserveBCNGBody(PlayerRef)
      BCNGBodyStatus = -3
      Debug.Notification("$PSQ_BCNGPresetMissing")
      Return False
    EndIf
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  ; Validate/queue natively before committing selection. A rejected request leaves
  ; the existing choice and HenshinBody unchanged.
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236
    Int MenuEpoch = PSQLoadEpoch
    Int Prepare = PSQAppearance.MenuBodyStep(Self, Owner, MenuEpoch, RequireBusy, Selection, NextId, NextName, False, False)
    If Prepare != 0
      If Prepare < 0
        Return False
      EndIf
      Bool Queued = True
      If Prepare >= 2
        Queued = Self.RequestBCNGBodyChange(Prepare == 3, NextId, Owner, RequireBusy, True)
      EndIf
      Int Done = PSQAppearance.MenuBodyStep(Self, Owner, MenuEpoch, RequireBusy, Selection, NextId, NextName, Queued, True)
      If Done == 2
        Self.CleanupLegacyPSQBodyMorphs(Owner, RequireBusy)
        Self.ApplyPSQOutfitBodyModels(False, Owner, RequireBusy)
      EndIf
      Return Done > 0
    EndIf
  EndIf
  BodySelectionRefreshBusy = True
  Bool Accepted = True
  If IsHenshined || BCNGBodyOwned || BCNGBodyRequest > 0
    Accepted = Self.RequestBCNGBodyChange(Selection > 0 && IsHenshined, NextId, Owner, RequireBusy, True)
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  BodySelectionRefreshBusy = False
  If !Accepted
    Return False
  EndIf
  SuccubusBodySelection = Selection
  BCNGSelectedPresetId = NextId
  TransformPresetName = NextName
  HenshinBody = Selection > 0
  BCNGBodyClearOnly = Selection == 0
  TransformPresetCatalogVersion = 2
  If IsHenshined
    BCNGBodyNeedsSync = True
    Self.CleanupLegacyPSQBodyMorphs(Owner, RequireBusy)
    Self.ApplyPSQOutfitBodyModels(False, Owner, RequireBusy)
    ; A native completion may already have been observed while queuing.
    If BCNGBodyRequest == 0 && BCNGBodyAppliedLoad == PSQLoadEpoch && BCNGBodyAppliedPreset == NextId
      BCNGBodyNeedsSync = False
    EndIf
  EndIf
  Return True
EndFunction

Function ApplyPSQOutfitBodyModels(Bool UsePreset, Int Owner, Bool RequireBusy)
  Self.ApplyPSQOutfitBodyModels38(UsePreset, Owner, RequireBusy)
EndFunction

Function SetPSQOutfitBodyModel(Int FormID, Int OutfitID, String Part, String OriginalThird, String OriginalFirst, Bool UsePreset, Int Owner, Bool RequireBusy)
  ArmorAddon Addon
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If PSQAppearance.SetModel34(Self, FormID, OutfitID, OriginalThird, OriginalFirst, Owner, RequireBusy, PSQLoadEpoch)
      Return
    EndIf
  EndIf
  Int CacheIndex = -1
  If FormID >= 3455 && FormID <= 3457
    CacheIndex = FormID - 3455
  ElseIf FormID >= 40834 && FormID <= 40922
    Int Offset = FormID - 40834
    Int PartOffset = Offset % 12
    If PartOffset == 0 || PartOffset == 2 || PartOffset == 4
      CacheIndex = 3 + Offset / 12 * 3 + PartOffset / 2
    EndIf
  EndIf
  If !PSQOutfitAddonCache
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return
    EndIf
    PSQOutfitAddonCache = new ArmorAddon[27]
  EndIf
  If CacheIndex >= 0 && CacheIndex < 27
    Addon = PSQOutfitAddonCache[CacheIndex]
    If !Addon
      Addon = Game.GetFormFromFile(FormID, "PSQ PlayerSuccubusQuest.esm") as ArmorAddon
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      PSQOutfitAddonCache[CacheIndex] = Addon
    EndIf
  Else
    Addon = Game.GetFormFromFile(FormID, "PSQ PlayerSuccubusQuest.esm") as ArmorAddon
  EndIf
  If !Addon
    Return
  EndIf
  String Third = OriginalThird
  String First = OriginalFirst
  If Addon.GetModelPath(False, True) != Third
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return
    EndIf
    Addon.SetModelPath(Third, False, True)
  EndIf
  If (First != "" || OutfitID == 100) && Addon.GetModelPath(True, True) != First
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return
    EndIf
    Addon.SetModelPath(First, True, True)
  EndIf
EndFunction

Int Function GetTransformBuffMode()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.BuffMode34(Self)
  EndIf
  If HenshinBuffMode < 0 || HenshinBuffMode > 2
    If HenshinBuff
      HenshinBuffMode = 2
    Else
      HenshinBuffMode = 0
    EndIf
  EndIf
  HenshinBuff = HenshinBuffMode != 0
  HenshinArmorRate = HenshinBuffMode != 0
  Return HenshinBuffMode
EndFunction

Function SetTransformBuffMode(Int Mode)
  If Mode < 0 || Mode > 2
    Return
  EndIf
  HenshinBuffMode = Mode
  HenshinBuff = Mode != 0
  Self.UpdateTransformBuff(False, -1)
EndFunction

Float Function GetTransformBuffRate(Int EffectIndex)
  Int Mode = Self.GetTransformBuffMode()
  If Mode == 0
    Return 0.0
  ElseIf Mode == 1
    Int Rank = SuccubusRank.GetValueInt()
    If Rank < 1
      Rank = 1
    ElseIf Rank > 10
      Rank = 10
    EndIf
    Return Rank as Float * 10.0
  EndIf
  Float Rate = HenshinBuffRateCarry
  If EffectIndex == 0
    Rate = HenshinBuffRateHealth
  ElseIf EffectIndex == 1
    Rate = HenshinBuffRateMagicka
  ElseIf EffectIndex == 2
    Rate = HenshinBuffRateStamina
  EndIf
  If Rate < 0.0
    Return 0.0
  EndIf
  Return Rate
EndFunction

Function UpdateTransformBuff(Bool DuringTransform, Int Owner)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777239
    PSQAppearance.SyncTransformBonus(PlayerRef,Self,Owner,PSQLoadEpoch,-1,DuringTransform,False,False)
    Return
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
  EndIf
  If DuringTransform && (!AppearanceEditBusy || AppearanceTransformDirection != 1)
    Return
  EndIf
  Int PoolEpoch = Self.BeginStatPoolEdit(Owner, DuringTransform)
  If PoolEpoch < 0
    TransformBuffRefreshPending = True
    Return
  EndIf
  Bool ForceRefresh = ForceTransformBuffRefresh
  ForceTransformBuffRefresh = False
  TransformBuffRefreshPending = False
  Self.UpdateTransformBuffCore(DuringTransform, Owner, PoolEpoch, ForceRefresh)
  Self.EndStatPoolEdit(PoolEpoch)
EndFunction

Function UpdateTransformBuffCore(Bool DuringTransform, Int Owner, Int PoolEpoch, Bool ForceRefresh)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777239
    PSQAppearance.SyncTransformBonus(PlayerRef,Self,Owner,PSQLoadEpoch,PoolEpoch,DuringTransform,ForceRefresh,False)
    Return
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  Self.UpdateTransformArmor(DuringTransform)
  If IsHenshinchu && !DuringTransform
    Return
  EndIf
  If !PlayerRef || !SuccubusHenshinBonusSpell
    Return
  EndIf
  Int Mode = Self.GetTransformBuffMode()
  If !IsHenshined || Mode == 0
    If PlayerRef.HasSpell(SuccubusHenshinBonusSpell as Form)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.RemoveTransformBuffSafely(Owner, PoolEpoch)
    EndIf
    Return
  EndIf
  Float HealthBonus
  Float MagickaBonus
  Float StaminaBonus
  Float CarryBonus
  Float[] Bonuses
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777226
    Int NativeRank = 0
    If Mode == 1
      NativeRank = Self.GetContinuousRank()
    EndIf
    Bonuses = PSQAppearance.TransformBonuses(PlayerRef, Mode, NativeRank, HenshinBuffRateHealth, HenshinBuffRateMagicka, HenshinBuffRateStamina, HenshinBuffRateCarry)
  EndIf
  If Bonuses && Bonuses.Length == 4
    HealthBonus = Bonuses[0]
    MagickaBonus = Bonuses[1]
    StaminaBonus = Bonuses[2]
    CarryBonus = Bonuses[3]
  Else
    Float[] Bases
    If SKSE.GetPluginVersion("PSQ Appearance") >= 16777221
      Bases = PSQAppearance.ReadTransformBases(PlayerRef)
    EndIf
    Float HealthRate = HenshinBuffRateHealth
    Float MagickaRate = HenshinBuffRateMagicka
    Float StaminaRate = HenshinBuffRateStamina
    Float CarryRate = HenshinBuffRateCarry
    If Mode == 1
      HealthRate = Self.GetContinuousRank() * 10.0
      MagickaRate = HealthRate
      StaminaRate = HealthRate
      CarryRate = HealthRate
    Else
      If HealthRate < 0.0
        HealthRate = 0.0
      EndIf
      If MagickaRate < 0.0
        MagickaRate = 0.0
      EndIf
      If StaminaRate < 0.0
        StaminaRate = 0.0
      EndIf
      If CarryRate < 0.0
        CarryRate = 0.0
      EndIf
    EndIf
    If Bases && Bases.Length == 4
      HealthBonus = Bases[0] * HealthRate / 100.0
      MagickaBonus = Bases[1] * MagickaRate / 100.0
      StaminaBonus = Bases[2] * StaminaRate / 100.0
      CarryBonus = Bases[3] * CarryRate / 100.0
    Else
      HealthBonus = PlayerRef.GetBaseAV("Health") * HealthRate / 100.0
      MagickaBonus = PlayerRef.GetBaseAV("Magicka") * MagickaRate / 100.0
      StaminaBonus = PlayerRef.GetBaseAV("Stamina") * StaminaRate / 100.0
      CarryBonus = PlayerRef.GetBaseAV("CarryWeight") * CarryRate / 100.0
    EndIf
    If HealthBonus < 0.0
      HealthBonus = 0.0
    EndIf
    If MagickaBonus < 0.0
      MagickaBonus = 0.0
    EndIf
    If StaminaBonus < 0.0
      StaminaBonus = 0.0
    EndIf
    If CarryBonus < 0.0
      CarryBonus = 0.0
    EndIf
  EndIf
  If ReviewTransformCarry && PlayerRef.Is3DLoaded() && !PlayerRef.IsDead() && !Utility.IsInMenuMode()
    ReviewTransformCarry = False
    If !ForceRefresh
      ForceRefresh = Self.NeedsCarryEffectRepair(SuccubusHenshinBonusSpell, CarryBonus)
    EndIf
  EndIf
  If !ForceRefresh && PlayerRef.HasSpell(SuccubusHenshinBonusSpell as Form) && Self.AreStatPoolEffectsReady(SuccubusHenshinBonusSpell)
    If StableTransformMagnitudes && StableTransformMagnitudes.Length == 4
      If StableTransformMagnitudes[0] == HealthBonus && StableTransformMagnitudes[1] == MagickaBonus && StableTransformMagnitudes[2] == StaminaBonus && StableTransformMagnitudes[3] == CarryBonus
        If TransformRecordSyncPending
          Self.RestoreTransformRuntimeRecords(Owner, PoolEpoch)
        EndIf
        Return
      EndIf
    ElseIf SuccubusHenshinBonusSpell.GetNthEffectMagnitude(0) == HealthBonus && SuccubusHenshinBonusSpell.GetNthEffectMagnitude(1) == MagickaBonus && SuccubusHenshinBonusSpell.GetNthEffectMagnitude(2) == StaminaBonus && SuccubusHenshinBonusSpell.GetNthEffectMagnitude(3) == CarryBonus
      Self.CommitTransformMagnitudes(HealthBonus, MagickaBonus, StaminaBonus, CarryBonus, Owner, PoolEpoch)
      Return
    EndIf
  EndIf
  If PlayerRef.IsDead() || PlayerRef.GetAV("Health") <= 0.0
    Return
  EndIf
  If PlayerRef.HasSpell(SuccubusHenshinBonusSpell as Form)
    Float RemovalMaximum = PlayerRef.GetAVMax("Health")
    Float PreviousHealthBonus = SuccubusHenshinBonusSpell.GetNthEffectMagnitude(0)
    If PreviousHealthBonus > 0.0 && RemovalMaximum - PreviousHealthBonus < 1.0
      TransformBuffRefreshPending = True
      Return
    EndIf
  EndIf
  Float BeforeHealth = PlayerRef.GetAV("Health")
  Float BeforeMagicka = PlayerRef.GetAV("Magicka")
  Float BeforeStamina = PlayerRef.GetAV("Stamina")
  If PlayerRef.HasSpell(SuccubusHenshinBonusSpell as Form) && BeforeHealth > 0.0 && !PlayerRef.IsDead()
    Float BufferMaximum = PlayerRef.GetAVMax("Health")
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    PlayerRef.RestoreAV("Health", BufferMaximum)
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  StableTransformMagnitudes = EmptyFloatArray
  PlayerRef.RemoveSpell(SuccubusHenshinBonusSpell)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  Int Wrote = 0
  If Bonuses && Bonuses.Length == 4
    Wrote = PSQAppearance.SyncTransformRecords(PlayerRef, Self, Owner, PSQLoadEpoch, PoolEpoch, SuccubusHenshinBonusSpell, Bonuses, None, 0.0)
  EndIf
  If Wrote < 0
    Return
  ElseIf Wrote == 0
    SuccubusHenshinBonusSpell.SetNthEffectMagnitude(0, HealthBonus)
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    SuccubusHenshinBonusSpell.SetNthEffectMagnitude(1, MagickaBonus)
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    SuccubusHenshinBonusSpell.SetNthEffectMagnitude(2, StaminaBonus)
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    SuccubusHenshinBonusSpell.SetNthEffectMagnitude(3, CarryBonus)
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  PlayerRef.AddSpell(SuccubusHenshinBonusSpell, False)
  Int Kept = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777226
    Kept = PSQAppearance.PreserveTransformPools(PlayerRef, Self, Owner, PSQLoadEpoch, PoolEpoch, BeforeHealth, BeforeMagicka, BeforeStamina)
  EndIf
  If Kept < 0
    Return
  ElseIf Kept == 0
    If BeforeHealth > 0.0 && !PlayerRef.IsDead()
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.PreserveSatiationCurrentValue("Health", BeforeHealth, PoolEpoch, Owner)
    EndIf
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Self.PreserveSatiationCurrentValue("Magicka", BeforeMagicka, PoolEpoch, Owner)
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Self.PreserveSatiationCurrentValue("Stamina", BeforeStamina, PoolEpoch, Owner)
  EndIf
  Self.CommitTransformMagnitudes(HealthBonus, MagickaBonus, StaminaBonus, CarryBonus, Owner, PoolEpoch)
  Debug.Trace("[PSQ Stats] transform applied; health=" + HealthBonus + "; carry=" + CarryBonus, 0)
EndFunction

Function RefreshSatiationPresentation(Float EnergyRatio)
  Self.UpdateEnergyDisplay(EnergyRatio)
  Self.UpdateAnimationEnergyPercent(EnergyRatio)
  SEBU.UpdateEnergyBar(EnergyRatio)
  Self.ChangeBodyPaint(EnergyRatio, False)
EndFunction

Function RefreshSatiationAttributes(Float Manpukudo)
  Float ExperienceMultiplier = Self.GetSatiationExperienceMultiplier()
  If PlayerRef == None
    Return
  EndIf
  If !PlayerRef.HasSpell(SuccubusSatiatySpellA) && !PlayerRef.HasSpell(SuccubusSatiatySpellB) && !PlayerRef.HasSpell(SuccubusSatiatySpellC)
    SatiationRefreshPending = False
    Self.RefreshManagedMovement(Self.GetRankSpeedBonus(IsHenshined))
    Return
  EndIf
  Int Owner = AppearanceOperationId
  Int PoolEpoch = Self.BeginStatPoolEdit(Owner, False)
  If PoolEpoch < 0
    SatiationRefreshPending = True
    Return
  EndIf
  Self.RefreshSatiationAttributesCore(Manpukudo, Owner, PoolEpoch)
  If PoolEpoch == StatPoolEditEpoch
    SatiationRefreshBusy = False
  EndIf
  Self.EndStatPoolEdit(PoolEpoch)
EndFunction

Function RefreshSatiationAttributesCore(Float Manpukudo, Int Owner, Int PoolEpoch)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  If Self.ShouldDeferForAlternateStart()
    Return
  EndIf
  If SatiationRefreshBusy
    SatiationRefreshPending = True
    Return
  EndIf
  If !PlayerRef || !SuccubusSatiatySpellA || !SuccubusSatiatySpellB
    Return
  EndIf
  MagicEffect HealthEffectA = SuccubusSatiatySpellA.GetNthEffectMagicEffect(0)
  MagicEffect HealthEffectB = SuccubusSatiatySpellB.GetNthEffectMagicEffect(0)
  If HealthEffectA == None || HealthEffectB == None || HealthEffectA == HealthEffectB
    Debug.Trace("[PSQ] Satiation health records missing; install the matching ESM and script together", 2)
    Return
  EndIf
  Self.RemoveLegacySatiationC(Owner, PoolEpoch)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  SatiationLastAttributeRefresh = Utility.GetCurrentRealTime()
  SatiationRefreshPending = False
  Bool HasA = PlayerRef.HasSpell(SuccubusSatiatySpellA)
  Bool HasB = PlayerRef.HasSpell(SuccubusSatiatySpellB)
  If !HasA && !HasB
    Return
  EndIf
  SatiationRefreshBusy = True
  ; The temporary zero-magnitude replacement is only for pre-v0.29 saves.
  Float[] Desired = Utility.CreateFloatArray(9, 0.0)
  Desired[6] = Self.GetRankSpeedBonus(IsHenshined)
  Spell NextSpell = SuccubusSatiatySpellA
  Spell PreviousSpell = SuccubusSatiatySpellB
  If HasA
    NextSpell = SuccubusSatiatySpellB
    PreviousSpell = SuccubusSatiatySpellA
  EndIf
  Float OldHealth = PlayerRef.GetAV("Health")
  Float OldMagicka = PlayerRef.GetAV("Magicka")
  Float OldStamina = PlayerRef.GetAV("Stamina")
  Float RemovalHealth = 0.0
  If HasA || HasB
    If (StableAppliedSatiationMagnitudes as Bool && StableAppliedSatiationSpell as Bool) && PlayerRef.HasSpell(StableAppliedSatiationSpell as Form) && !(HasA && HasB)
      RemovalHealth = StableAppliedSatiationMagnitudes[0]
      If RemovalHealth < 0.0
        RemovalHealth = 0.0
      EndIf
    Else
      RemovalHealth = PlayerRef.GetAVMax("Health")
    EndIf
  EndIf
  If OldHealth > 0.0 && !PlayerRef.IsDead() && RemovalHealth + 1.0 > OldHealth
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    PlayerRef.RestoreAV("Health", RemovalHealth + 1.0 - OldHealth)
  EndIf
  Int j = 0
  While j < 9
    If j == 6
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      NextSpell.SetNthEffectMagnitude(j, 0.0)
    ElseIf j < 6
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      NextSpell.SetNthEffectMagnitude(j, Desired[j])
    ElseIf j == 8
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      NextSpell.SetNthEffectMagnitude(7, Desired[j])
    EndIf
    j += 1
  EndWhile
  If HasA && HasB
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    PlayerRef.RemoveSpell(NextSpell)
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  PlayerRef.RemoveSpell(PreviousSpell)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  PlayerRef.AddSpell(NextSpell, False)
  Bool HealthEffectsReady = Self.WaitForSatiationHealthEffect(NextSpell, PreviousSpell, PoolEpoch, Owner)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  If PlayerRef.HasSpell(NextSpell as Form) && !PlayerRef.HasSpell(PreviousSpell as Form)
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    StableAppliedSatiationMagnitudes = Desired
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    StableAppliedSatiationSpell = NextSpell
    SatiationRecordSyncPending = False
    Debug.Trace("[PSQ Stats] satiation applied; health=" + Desired[0] + "; carry=" + Desired[8], 0)
  Else
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    StableCachedSatiationInputs = EmptyFloatArray
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    StableAppliedSatiationMagnitudes = EmptyFloatArray
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    StableAppliedSatiationSpell = None
  EndIf
  If HealthEffectsReady && OldHealth > 0.0 && !PlayerRef.IsDead()
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Self.PreserveSatiationCurrentValue("Health", OldHealth, PoolEpoch, Owner)
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  Self.PreserveSatiationCurrentValue("Magicka", OldMagicka, PoolEpoch, Owner)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  Self.PreserveSatiationCurrentValue("Stamina", OldStamina, PoolEpoch, Owner)
  If StableAppliedSatiationMagnitudes as Bool && StableAppliedSatiationSpell as Bool
    Self.RefreshManagedMovement(Desired[6])
  EndIf
  ; Only remove the replacement after the owned zero effects have settled.
  If HealthEffectsReady && Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    PlayerRef.RemoveSpell(NextSpell)
    StableAppliedSatiationSpell = None
    StableAppliedSatiationMagnitudes = EmptyFloatArray
    StableCachedSatiationInputs = EmptyFloatArray
    AppliedSatiationSpell = None
    AppliedSatiationMagnitudes = EmptyFloatArray
    CachedSatiationInputs = EmptyFloatArray
  EndIf
  SatiationRefreshBusy = False
  If SatiationRefreshPending
    Self.RefreshSatiationAttributes(Self.GetEnergyRatio())
  EndIf
EndFunction

Function PreserveSatiationCurrentValue(String ValueName, Float Before, Int PoolEpoch, Int Owner)
  If PlayerRef == None
    Return
  EndIf
  If PoolEpoch >= 0 && !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  Float NewMaximum = PlayerRef.GetAVMax(ValueName)
  Bool IsHealth = ValueName == "Health"
  If IsHealth && (Before <= 0.0 || NewMaximum < 1.0 || PlayerRef.IsDead())
    Return
  EndIf
  Float DesiredCurrent = Before
  If DesiredCurrent > NewMaximum
    DesiredCurrent = NewMaximum
  EndIf
  If IsHealth && DesiredCurrent < 1.0
    DesiredCurrent = 1.0
  ElseIf DesiredCurrent < 0.0
    DesiredCurrent = 0.0
  EndIf
  If PoolEpoch >= 0 && !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  If IsHealth && PlayerRef.IsDead()
    Return
  EndIf
  Float Current = PlayerRef.GetAV(ValueName)
  If IsHealth && Current <= 0.0
    Return
  EndIf
  If PoolEpoch >= 0 && !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  If Current > DesiredCurrent
    Float Damage = Current - DesiredCurrent
    If IsHealth
      Float LiveHealth = PlayerRef.GetAV("Health")
      If PlayerRef.IsDead() || LiveHealth <= 1.0
        Return
      EndIf
      If Damage > LiveHealth - 1.0
        Damage = LiveHealth - 1.0
      EndIf
    EndIf
    If Damage > 0.0
      PlayerRef.DamageAV(ValueName, Damage)
    EndIf
  ElseIf Current < DesiredCurrent
    PlayerRef.RestoreAV(ValueName, DesiredCurrent - Current)
  EndIf
EndFunction

Function RemoveTransformBuffSafely(Int Owner, Int PoolEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777239
    PSQAppearance.SyncTransformBonus(PlayerRef,Self,Owner,PSQLoadEpoch,PoolEpoch,False,False,True)
    Return
  EndIf
  Bool OwnsEdit = PoolEpoch < 0
  If Owner < 0
    If AppearanceEditBusy
      TransformBuffRefreshPending = True
      Return
    EndIf
    Owner = AppearanceOperationId
  EndIf
  If OwnsEdit
    PoolEpoch = Self.BeginStatPoolEdit(Owner, True)
  EndIf
  If PoolEpoch < 0 || !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    TransformBuffRefreshPending = True
    Return
  EndIf
  Self.RemoveTransformBuffCore(Owner, PoolEpoch)
  If OwnsEdit
    Self.EndStatPoolEdit(PoolEpoch)
  EndIf
EndFunction

Function RemoveTransformBuffCore(Int Owner, Int PoolEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777239
    PSQAppearance.SyncTransformBonus(PlayerRef,Self,Owner,PSQLoadEpoch,PoolEpoch,False,False,True)
    Return
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  Self.RestoreTransformRuntimeRecords(Owner, PoolEpoch)
  StableTransformMagnitudes = EmptyFloatArray
  If PlayerRef == None || SuccubusHenshinBonusSpell == None || !PlayerRef.HasSpell(SuccubusHenshinBonusSpell as Form)
    Return
  EndIf
  Float CurrentMaximum = PlayerRef.GetAVMax("Health")
  Float RemovedBonus = SuccubusHenshinBonusSpell.GetNthEffectMagnitude(0)
  If RemovedBonus > 0.0 && CurrentMaximum - RemovedBonus < 1.0
    TransformBuffRefreshPending = True
    Return
  EndIf
  Float BeforeHealth = PlayerRef.GetAV("Health")
  Float BeforeMagicka = PlayerRef.GetAV("Magicka")
  Float BeforeStamina = PlayerRef.GetAV("Stamina")
  If BeforeHealth > 0.0 && !PlayerRef.IsDead()
    Float BufferMaximum = PlayerRef.GetAVMax("Health")
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    PlayerRef.RestoreAV("Health", BufferMaximum)
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  PlayerRef.RemoveSpell(SuccubusHenshinBonusSpell)
  Int Kept = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777226
    Kept = PSQAppearance.PreserveTransformPools(PlayerRef, Self, Owner, PSQLoadEpoch, PoolEpoch, BeforeHealth, BeforeMagicka, BeforeStamina)
  EndIf
  If Kept < 0
    Return
  ElseIf Kept == 0
    If BeforeHealth > 0.0 && !PlayerRef.IsDead()
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.PreserveSatiationCurrentValue("Health", BeforeHealth, PoolEpoch, Owner)
    EndIf
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Self.PreserveSatiationCurrentValue("Magicka", BeforeMagicka, PoolEpoch, Owner)
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Self.PreserveSatiationCurrentValue("Stamina", BeforeStamina, PoolEpoch, Owner)
  EndIf
EndFunction

Function RefreshEquippedTransformBody(Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  ; BCNG handles body/outfit rebuilds. The end of the clothing stage only checks
  ; its owned request; it does not issue another PSQ/RaceMenu body rebuild.
  If BCNGBodyRequest > 0 && BCNGBodyRequestOwner == Owner && BCNGBodyRequestLoad == PSQLoadEpoch
    Self.WaitForBCNGBodyRequest(BCNGBodyRequest, Owner, RequireBusy)
  EndIf
EndFunction

Function ApplyBreastScaleIfChanged(Float BreastScale, Int Owner, Bool RequireBusy)
; Retired compatibility entry point. Old saved scripts may still call it.
  ; No size calculation, morph write, skeleton scaling, or SLIF submission.
EndFunction

Bool Function ResolveEnergyDisplayAbilities()
  If !EnergyDisplayAbilityA
    EnergyDisplayAbilityA = Game.GetFormFromFile(40946, "PSQ PlayerSuccubusQuest.esm") as Spell
  EndIf
  If !EnergyDisplayAbilityB
    EnergyDisplayAbilityB = Game.GetFormFromFile(40947, "PSQ PlayerSuccubusQuest.esm") as Spell
  EndIf
  Return EnergyDisplayAbilityA != None && EnergyDisplayAbilityB != None
EndFunction

Function ClearEnergyDisplay()
  If !Self.ResolveEnergyDisplayAbilities()
    Return
  EndIf
  If PlayerRef.HasSpell(EnergyDisplayAbilityA as Form)
    PlayerRef.RemoveSpell(EnergyDisplayAbilityA)
  EndIf
  If PlayerRef.HasSpell(EnergyDisplayAbilityB as Form)
    PlayerRef.RemoveSpell(EnergyDisplayAbilityB)
  EndIf
  AppliedEnergyDisplayPercent = -1.0
EndFunction

Function UpdateEnergyDisplay(Float EnergyRatio)
  If !Self.ResolveEnergyDisplayAbilities()
    Return
  EndIf
  Float Percent = EnergyRatio * 100.0
  Bool HasA = PlayerRef.HasSpell(EnergyDisplayAbilityA as Form)
  Bool HasB = PlayerRef.HasSpell(EnergyDisplayAbilityB as Form)
  If Percent == AppliedEnergyDisplayPercent && (HasA || HasB) && !(HasA && HasB)
    Return
  EndIf
  Spell Next = EnergyDisplayAbilityA
  Spell Previous = EnergyDisplayAbilityB
  If HasA
    Next = EnergyDisplayAbilityB
    Previous = EnergyDisplayAbilityA
  EndIf
  If HasA && HasB
    PlayerRef.RemoveSpell(Next)
  EndIf
  Next.SetNthEffectMagnitude(0, Percent)
  PlayerRef.RemoveSpell(Previous)
  PlayerRef.AddSpell(Next, False)
  If PlayerRef.HasSpell(Next as Form) && !PlayerRef.HasSpell(Previous as Form)
    AppliedEnergyDisplayPercent = Percent
  Else
    AppliedEnergyDisplayPercent = -1.0
  EndIf
EndFunction

Function SyncScaledAbility(Spell Ability, Bool Enabled, Float Magnitude)
  If !Ability
    Return
  EndIf
  Bool Present = PlayerRef.HasSpell(Ability as Form)
  If !Enabled
    If Present
      PlayerRef.RemoveSpell(Ability)
    EndIf
    Return
  EndIf
  If Ability.GetNthEffectMagnitude(0) != Magnitude
    If Present
      PlayerRef.RemoveSpell(Ability)
    EndIf
    Ability.SetNthEffectMagnitude(0, Magnitude)
    PlayerRef.AddSpell(Ability, False)
  ElseIf !Present
    PlayerRef.AddSpell(Ability, False)
  EndIf
EndFunction

Function ComputeTattooGradient(Float Manpukudo)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231 && PSQAppearance.TattooGradient(Self, Manpukudo)
    Return
  EndIf
  If EnableCustomTattooGlow
    BPGTintCurrentColor = CustomTattooGlowColor
    If PreserveTattooGlowColor
      BPGTintCurrentColor = 16777215
    ElseIf EnableBodyPaintGlowTintChangeSatiation
      Float GlowRatio = Manpukudo
      If GlowRatio < 0.0
        GlowRatio = 0.0
      ElseIf GlowRatio > 1.0
        GlowRatio = 1.0
      EndIf
      Int GlowRed = (colorcomponent.GetRed(BPGTintColorEnd) as Float + ((colorcomponent.GetRed(CustomTattooGlowColor) - colorcomponent.GetRed(BPGTintColorEnd)) as Float * GlowRatio)) as Int
      Int GlowGreen = (colorcomponent.GetGreen(BPGTintColorEnd) as Float + ((colorcomponent.GetGreen(CustomTattooGlowColor) - colorcomponent.GetGreen(BPGTintColorEnd)) as Float * GlowRatio)) as Int
      Int GlowBlue = (colorcomponent.GetBlue(BPGTintColorEnd) as Float + ((colorcomponent.GetBlue(CustomTattooGlowColor) - colorcomponent.GetBlue(BPGTintColorEnd)) as Float * GlowRatio)) as Int
      BPGTintCurrentColor = colorcomponent.SetRed(BPGTintCurrentColor, GlowRed)
      BPGTintCurrentColor = colorcomponent.SetGreen(BPGTintCurrentColor, GlowGreen)
      BPGTintCurrentColor = colorcomponent.SetBlue(BPGTintCurrentColor, GlowBlue)
    EndIf
    BPGCurrentAlpha = 2.0
  EndIf
  If EnableBodyPaintTintChangeSatiation
    BPTintColorTempRed = BPTintColorMaxRed - BPTintDefRed * Math.Abs(1.0 - Manpukudo)
    BPTintColorTempGreen = BPTintColorMaxGreen - BPTintDefGreen * Math.Abs(1.0 - Manpukudo)
    BPTintColorTempBlue = BPTintColorMaxBlue - BPTintDefBlue * Math.Abs(1.0 - Manpukudo)
    BPTintCurrentColor = colorcomponent.SetRed(BPTintCurrentColor, BPTintColorTempRed as Int)
    BPTintCurrentColor = colorcomponent.SetGreen(BPTintCurrentColor, BPTintColorTempGreen as Int)
    BPTintCurrentColor = colorcomponent.SetBlue(BPTintCurrentColor, BPTintColorTempBlue as Int)
  EndIf
  If EnableBodyPaintGlowTintChangeSatiation && !EnableCustomTattooGlow
    BPGTintColorTempRed = BPGTintColorMaxRed - BPGTintDefRed * Math.Abs(1.0 - Manpukudo)
    BPGTintColorTempGreen = BPGTintColorMaxGreen - BPGTintDefGreen * Math.Abs(1.0 - Manpukudo)
    BPGTintColorTempBlue = BPGTintColorMaxBlue - BPGTintDefBlue * Math.Abs(1.0 - Manpukudo)
    BPGTintCurrentColor = colorcomponent.SetRed(BPGTintCurrentColor, BPGTintColorTempRed as Int)
    BPGTintCurrentColor = colorcomponent.SetGreen(BPGTintCurrentColor, BPGTintColorTempGreen as Int)
    BPGTintCurrentColor = colorcomponent.SetBlue(BPGTintCurrentColor, BPGTintColorTempBlue as Int)
  EndIf
  If EnableBodyPaintGlowAlphaChangeSatiation
    BPGCurrentAlpha = BPGAlphaStart - BPGAlphaDef * Math.Abs(1.0 - Manpukudo)
  EndIf
EndFunction

Bool Function IsIntegrationPluginLoaded(String Plugin)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    Return PSQAppearance.ExternalPluginLoaded33(Plugin)
  EndIf
  Return Game.GetModByName(Plugin) != 255 || Game.GetLightModByName(Plugin) != 65535
EndFunction

Bool Function HasNiOverrideRuntime()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    Return PSQAppearance.HasNiOverride33()
  EndIf
  Return skse.GetPluginVersion("skee") >= 0 || skse.GetPluginVersion("nioverride") >= 0
EndFunction

Bool Function CanUseEFF()
  Return EFFActive && Self.IsIntegrationPluginLoaded("EFFCore.esm") && XFLMain != None
EndFunction

Bool Function CanUseFlying()
  Return CanControlWingflightPolicy() || IsWingflightNativeReady()
EndFunction

Int Function GetAbilityManagementMode()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.AbilityMode34(Self)
  EndIf
  If AbilityManagementMode < 0 || AbilityManagementMode > 2
    AbilityManagementMode = 1
  EndIf
  Return AbilityManagementMode
EndFunction

Function CaptureManualManagedAbilities()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If PSQAppearance.CaptureAbilities34(Self)
      Return
    EndIf
  EndIf
  If PlayerIsSuccubus.GetValueInt() != 1
    Return
  EndIf
  If !ManualManagedAbilities || ManualManagedAbilities.Length != 15
    ManualManagedAbilities = new Bool[15]
  EndIf
  Int i = 0
  While i < 15
    ManualManagedAbilities[i] = Self.GetManagedAbilityEnabled(i)
    i += 1
  EndWhile
  ManagedAbilitiesInitialized = True
EndFunction

Function SetAbilityManagementMode(Int Mode)
  If Mode < 0 || Mode > 2
    Return
  EndIf
  If !ManagedAbilitiesInitialized || Self.GetAbilityManagementMode() == 2
    Self.CaptureManualManagedAbilities()
  EndIf
  If !(SKSE.GetPluginVersion("PSQ Appearance") >= 16777231) || PSQAppearance.ChangeGameplayMode(Self, 1, Mode) < 0
    AbilityManagementMode = Mode
  EndIf
  Self.SyncManagedAbilities()
EndFunction

Function ToggleManualManagedAbility(Int Index)
  If Self.GetAbilityManagementMode() != 2 || Index < 0 || Index >= 15
    Return
  EndIf
  If !ManagedAbilitiesInitialized
    Self.CaptureManualManagedAbilities()
  EndIf
  If !ManualManagedAbilities
    Return
  EndIf
  ManualManagedAbilities[Index] = !ManualManagedAbilities[Index]
  Self.SyncManagedAbilities()
EndFunction

Int Function GetManagedAbilityUnlockRank(Int Index)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777228
    Return PSQAppearance.UnlockRank(Index)
  EndIf
  If Index == 0
    Return 3
  ElseIf Index == 1
    Return 3
  ElseIf Index == 2
    Return 3
  ElseIf Index == 3
    Return 2
  ElseIf Index == 4
    Return 6
  ElseIf Index == 5
    Return 7
  ElseIf Index == 6
    Return 1
  ElseIf Index == 7
    Return 4
  ElseIf Index == 8
    Return 2
  ElseIf Index == 9
    Return 7
  ElseIf Index == 10
    Return 4
  ElseIf Index == 11
    Return 1
  ElseIf Index == 12
    Return 6
  ElseIf Index == 13
    Return 5
  ElseIf Index == 14
    Return 1
  EndIf
  Return 10
EndFunction

Spell Function GetManagedAbilitySpell(Int Index)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.Ability34(Self, Index)
  EndIf
  If Index == 0
    Return Self.GetManagedDrainSpell(0, SuccubusRank.GetValueInt())
  ElseIf Index == 1
    Return Self.GetManagedDrainSpell(1, SuccubusRank.GetValueInt())
  ElseIf Index == 2
    Return Self.GetManagedDrainSpell(2, SuccubusRank.GetValueInt())
  ElseIf Index == 3
    Return CreatePenisSpellSelf
  ElseIf Index == 4
    Return CreatePenisSpellOther
  ElseIf Index == 5
    Return SuccubusCurseSpell
  ElseIf Index == 6
    Return StarkRealitySpell
  ElseIf Index == 7
    Return SuccuKanashibari
  ElseIf Index == 8
    Return SuccubusRaiseArousalSpell
  ElseIf Index == 9
    Return SuccubusArousalCloakSpell
  ElseIf Index == 10
    Return FortifyMSGBoxSpell
  ElseIf Index == 11
    Return SuccubusSpellLearningMSGBoxSpell
  ElseIf Index == 12
    Return SuccubusSummonMerchantSpell
  ElseIf Index == 13
    Return RestoreMagickaSpell
  ElseIf Index == 14
    Return MasturbationSpell
  EndIf
  Return None
EndFunction

Bool Function GetManagedAbilityEnabled(Int Index)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.AbilityEnabled34(Self, Index)
  EndIf
  If Index == 0
    Return EnableSuccubusDrainHealthSpell
  ElseIf Index == 1
    Return EnableSuccubusDrainStaminaSpell
  ElseIf Index == 2
    Return EnableSuccubusDrainFF
  EndIf
  Spell Ability = Self.GetManagedAbilitySpell(Index)
  Return Ability != None && PlayerRef.HasSpell(Ability as Form)
EndFunction

Spell Function GetManagedDrainSpell(Int Family, Int Rank)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.DrainSpell34(Self, Family, Rank)
  EndIf
  If Rank < 1
    Rank = 1
  ElseIf Rank > 8
    Rank = 8
  EndIf
  If Family == 0
    If Rank == 1
      Return SuccubusDrainHealthSpell01
    ElseIf Rank == 2
      Return SuccubusDrainHealthSpell02
    ElseIf Rank == 3
      Return SuccubusDrainHealthSpell03
    ElseIf Rank == 4
      Return SuccubusDrainHealthSpell04
    ElseIf Rank == 5
      Return SuccubusDrainHealthSpell05
    ElseIf Rank == 6
      Return SuccubusDrainHealthSpell06
    ElseIf Rank == 7
      Return SuccubusDrainHealthSpell07
    ElseIf Rank == 8
      Return SuccubusDrainHealthSpell08
    EndIf
  ElseIf Family == 1
    If Rank == 1
      Return SuccubusDrainStaminaSpell01
    ElseIf Rank == 2
      Return SuccubusDrainStaminaSpell02
    ElseIf Rank == 3
      Return SuccubusDrainStaminaSpell03
    ElseIf Rank == 4
      Return SuccubusDrainStaminaSpell04
    ElseIf Rank == 5
      Return SuccubusDrainStaminaSpell05
    ElseIf Rank == 6
      Return SuccubusDrainStaminaSpell06
    ElseIf Rank == 7
      Return SuccubusDrainStaminaSpell07
    ElseIf Rank == 8
      Return SuccubusDrainStaminaSpell08
    EndIf
  ElseIf Family == 2
    If Rank == 1
      Return SuccubusDrainFF01
    ElseIf Rank == 2
      Return SuccubusDrainFF02
    ElseIf Rank == 3
      Return SuccubusDrainFF03
    ElseIf Rank == 4
      Return SuccubusDrainFF04
    ElseIf Rank == 5
      Return SuccubusDrainFF05
    ElseIf Rank == 6
      Return SuccubusDrainFF06
    ElseIf Rank == 7
      Return SuccubusDrainFF07
    ElseIf Rank == 8
      Return SuccubusDrainFF08
    EndIf
  EndIf
  Return None
EndFunction

Function SyncManagedAbilities()
  Self.SyncRankMagicCostReduction()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Int BookResult = PSQAppearance.ManagedBook34(Self)
    If BookResult == 1
      Return
    ElseIf BookResult == 2
      Self.SyncEnergySenseSpell()
      Self.SyncAproposRepairSpell()
      Return
    EndIf
  EndIf
  If ManagedAbilitiesBusy || PlayerIsSuccubus.GetValueInt() != 1 || PlayerRef == None
    Return
  EndIf
  If !ManagedAbilitiesInitialized || !ManualManagedAbilities || ManualManagedAbilities.Length != 15
    Self.CaptureManualManagedAbilities()
  EndIf
  ManagedAbilitiesBusy = True
  Int Mode = Self.GetAbilityManagementMode()
  Int Rank = SuccubusRank.GetValueInt()
  If !(SKSE.GetPluginVersion("PSQ Appearance") >= 16777231) || !PSQAppearance.SyncAbilityBook(Self, PlayerRef, Rank, Mode, ManualManagedAbilities)
    Int i = 0
    While i < 15
      Bool Enabled = False
      If Mode == 1
        Enabled = Rank >= Self.GetManagedAbilityUnlockRank(i)
      ElseIf Mode == 2
        Enabled = ManualManagedAbilities[i]
      EndIf
      If i == 5 && Rank < 7
        Enabled = False
      EndIf
      If i < 3
        Int Tier = 1
        Spell Selected = Self.GetManagedAbilitySpell(i)
        While Tier <= 8
          Spell Ability = Self.GetManagedDrainSpell(i, Tier)
          Self.SyncManagedSpell(Ability, Enabled && Ability == Selected)
          Tier += 1
        EndWhile
        If i == 0
          EnableSuccubusDrainHealthSpell = Enabled
        ElseIf i == 1
          EnableSuccubusDrainStaminaSpell = Enabled
        ElseIf i == 2
          EnableSuccubusDrainFF = Enabled
        EndIf
      Else
        Self.SyncManagedSpell(Self.GetManagedAbilitySpell(i), Enabled)
      EndIf
      i += 1
    EndWhile
  EndIf
  ManagedAbilitiesBusy = False
  Self.SyncEnergySenseSpell()
  Self.SyncAproposRepairSpell()
EndFunction

Function SyncManagedSpell(Spell Ability, Bool Enabled)
  If Ability == None
    Return
  EndIf
  Bool Present = PlayerRef.HasSpell(Ability as Form)
  If Enabled && !Present
    PlayerRef.AddSpell(Ability, False)
  ElseIf !Enabled && Present
    PlayerRef.RemoveSpell(Ability)
  EndIf
EndFunction

sr_inflateQuest Function GetFHULiveInflater()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.Inflater34() as sr_inflateQuest
  EndIf
  If !Self.IsIntegrationPluginLoaded("sr_FillHerUp.esp")
    Return None
  EndIf
  Return Game.GetFormFromFile(3427, "sr_FillHerUp.esp") as sr_inflateQuest
EndFunction

Float Function GetFHUDigestibleReserve()
  If Self.GetFHULiveInflater() == None
    Return 0.0
  EndIf
  Float Total = storageutil.GetFloatValue(PlayerRef as Form, "sr.inflater.cum.vaginal", 0.0)
  Total += storageutil.GetFloatValue(PlayerRef as Form, "sr.inflater.cum.anal", 0.0)
  Total += storageutil.GetFloatValue(PlayerRef as Form, "sr.inflater.cum.oral", 0.0)
  If Total < 0.0
    Return 0.0
  EndIf
  Return Total
EndFunction

Bool Function TransferAllFHUToPSQ(Int Owner)
  sr_inflateQuest Inflater = Self.GetFHULiveInflater()
  If Inflater == None || Self.GetFHUDigestibleReserve() <= 0.0
    Return True
  EndIf
  If FHUActiveDigestionWaiting
    Return False
  EndIf
  If Self.CountFHUPlayerJobs(Inflater) > 0 || (Inflater.inflaterAnimatingFaction as Bool && PlayerRef.IsInFaction(Inflater.inflaterAnimatingFaction))
    Debug.Notification("FHU正在处理玩家，未转入储量，请稍后重试。")
    Return False
  EndIf
  Float Rank = SuccubusRank.GetValue()
  If Rank < 1.0
    Rank = 1.0
  ElseIf Rank > 10.0
    Rank = 10.0
  EndIf
  FHUTransferConversion = 100.0 * Rank
  Debug.Notification("正在将FHU储量转入PSQ，请稍候。")
  If !Self.TransferFHUPoolToPSQ(Inflater, 1, "sr.inflater.cum.vaginal", Owner)
    Return False
  EndIf
  If !Self.TransferFHUPoolToPSQ(Inflater, 2, "sr.inflater.cum.anal", Owner)
    Return False
  EndIf
  If !Self.TransferFHUPoolToPSQ(Inflater, 4, "sr.inflater.cum.oral", Owner)
    Return False
  EndIf
  Self.SetBellyScale()
  If Self.GetFHUDigestibleReserve() > 0.0
    Debug.Notification("FHU仍有未转入储量，本次不开始消化，请稍后重试。")
    Return False
  EndIf
  Debug.Notification("FHU储量已转入PSQ，继续按住热键开始消化。")
  Return True
EndFunction

Int Function CountFHUPlayerJobs(sr_inflateQuest Inflater)
  If Inflater == None
    Return 0
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777235
    Int Jobs = PSQAppearance.CountInflaterJobs(PlayerRef, Inflater)
    If Jobs >= 0
      Return Jobs
    EndIf
  EndIf
  Int Count = 0
  Int i = 0
  While Inflater.threads as Bool && i < Inflater.threads.Length
    If Inflater.threads[i] != None && Inflater.threads[i].GetActorReference() == PlayerRef
      Count += 1
    EndIf
    i += 1
  EndWhile
  Return Count
EndFunction

Function RecoverFHUTransfer(Bool AfterLoad)
  If !FHUActiveDigestionWaiting || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  sr_inflateQuest Inflater = Self.GetFHULiveInflater()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Int Jobs = Self.CountFHUPlayerJobs(Inflater)
    Int Action = PSQAppearance.FHURecoveryStep(Self, AfterLoad, Inflater != None, Jobs, Utility.GetCurrentRealTime())
    If Action == 1
      Self.RegisterForModEvent(FHUTransferEvent, "OnFHUActiveDigestDone")
    ElseIf Action == 2 || Action == 3
      storageutil.SetFloatValue(PlayerRef,"PSQ_FHUUnconfirmedAmount",FHUTransferAmount)
      storageutil.SetIntValue(PlayerRef,"PSQ_FHUUnconfirmedRequest",FHUTransferSerial)
      Self.EndFHUTransfer(False,-1,-1)
      If Action == 3
        Debug.Notification("FHU转入等待已解除；未确认的请求不会补发储量。请检查FHU储量后重试。")
      EndIf
    EndIf
    If Action >= 0
      Return
    EndIf
  EndIf
  If AfterLoad
    FHUTransferReceiptEpoch += 1
    FHUTransferReceiptBusy = False
    If FHUTransferSettlementSerial == FHUTransferSerial
      storageutil.SetFloatValue(PlayerRef as Form, "PSQ_FHUUnconfirmedAmount", FHUTransferAmount)
      storageutil.SetIntValue(PlayerRef as Form, "PSQ_FHUUnconfirmedRequest", FHUTransferSerial)
      Self.EndFHUTransfer(False, -1, -1)
      Return
    EndIf
    ManualDigestionBusy = False
    FHUTransferDeadline = Utility.GetCurrentRealTime() + 30.0
    If FHUTransferEvent != "" && Inflater != None
      Self.RegisterForModEvent(FHUTransferEvent, "OnFHUActiveDigestDone")
    EndIf
  EndIf
  If FHUTransferReceiptBusy
    Return
  EndIf
  If Inflater != None && Self.CountFHUPlayerJobs(Inflater) > 1
    FHUTransferUncertain = True
  EndIf
  If Inflater == None || FHUTransferEvent == "" || Utility.GetCurrentRealTime() >= FHUTransferDeadline
    storageutil.SetFloatValue(PlayerRef as Form, "PSQ_FHUUnconfirmedAmount", FHUTransferAmount)
    storageutil.SetIntValue(PlayerRef as Form, "PSQ_FHUUnconfirmedRequest", FHUTransferSerial)
    Self.EndFHUTransfer(False, -1, -1)
    Debug.Notification("FHU转入等待已解除；未确认的请求不会补发储量。请检查FHU储量后重试。")
  EndIf
EndFunction

Function EndFHUTransfer(Bool Completed, Int Request, Int Epoch)
  If Request >= 0 && !Self.IsCurrentFHUReceipt(Request, Epoch)
    Return
  EndIf
  String EventName = FHUTransferEvent
  Int EndResult = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    If Request >= 0
      EndResult = PSQAppearance.EndDigestPool(Self,Request,Epoch,EventName,Completed,True)
    Else
      EndResult = PSQAppearance.EndDigestPool(Self,FHUTransferSerial,FHUTransferReceiptEpoch,EventName,Completed,False)
    EndIf
  EndIf
  If EndResult < 0
    Return
  ElseIf EndResult == 0
    FHUTransferEvent = ""
    FHUTransferReceiptBusy = False
    FHUActiveDigestionWaiting = False
    FHUActiveDigestionFinished = Completed
    FHUTransferDeadline = 0.0
  EndIf
  If EventName != ""
    Self.UnregisterForModEvent(EventName)
  EndIf
  Self.UnregisterForModEvent("PSQ_FHUActiveDigestDone")
EndFunction

Bool Function TransferFHUPoolToPSQ(sr_inflateQuest Inflater, Int Pool, String PoolKey, Int Owner)
  If Owner != ActiveDigestionGeneration
    Return False
  EndIf
  If Self.CountFHUPlayerJobs(Inflater) > 0
    Debug.Notification("FHU仍在处理玩家，本次不开始转入。")
    Return False
  EndIf
  Float Amount = storageutil.GetFloatValue(PlayerRef as Form, PoolKey, 0.0)
  If Amount <= 0.0
    Return True
  EndIf
  Int PoolRequest = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    PoolRequest = PSQAppearance.BeginDigestPool(Self,Owner,Pool,PoolKey,Amount,storageutil.GetFloatValue(PlayerRef,"sr.inflater.cum.vaginal",0.0),storageutil.GetFloatValue(PlayerRef,"sr.inflater.cum.anal",0.0),Utility.GetCurrentRealTime())
  EndIf
  If PoolRequest < 0
    Return False
  ElseIf PoolRequest == 0
    FHUTransferSerial += 1
    FHUTransferEvent = "PSQ_FHUTransfer_" + FHUTransferSerial as String
    FHUTransferPool = Pool
    FHUTransferPoolKey = PoolKey
    FHUTransferAmount = Amount
    FHUTransferBeforeVaginal = storageutil.GetFloatValue(PlayerRef as Form, "sr.inflater.cum.vaginal", 0.0)
    FHUTransferBeforeAnal = storageutil.GetFloatValue(PlayerRef as Form, "sr.inflater.cum.anal", 0.0)
    FHUTransferDeadline = Utility.GetCurrentRealTime() + 30.0
    FHUTransferUncertain = False
    FHUActiveDigestionFinished = False
    FHUActiveDigestionWaiting = True
    PoolRequest = FHUTransferSerial
  EndIf
  Self.RegisterForModEvent(FHUTransferEvent, "OnFHUActiveDigestDone")
  Int Slot = Inflater.QueueAbsorbActor(PlayerRef, False, Pool, Amount, 0.5, FHUTransferEvent, 0)
  If PoolRequest != FHUTransferSerial || Owner != ActiveDigestionGeneration
    Return False
  EndIf
  If Slot < 0
    Self.EndFHUTransfer(False, -1, -1)
    Debug.Notification("FHU转入请求未成功，本次不开始消化。")
    Return False
  EndIf
  Int Request = FHUTransferSerial
  Inflater.AbsorptionQueued()
  Int Attempts = 0
  While Owner == ActiveDigestionGeneration && FHUActiveDigestionWaiting && Attempts < 40
    Utility.Wait(0.25)
    Self.RecoverFHUTransfer(False)
    Attempts += 1
  EndWhile
  If Owner != ActiveDigestionGeneration
    Return False
  EndIf
  If !FHUActiveDigestionFinished
    Debug.Notification("FHU尚未确认转入；PSQ会检查超时并解除等待，请稍后重试。")
    Return False
  EndIf
  Return Self.WaitForCompletedFHUThread(Inflater, Slot, Request, Owner)
EndFunction

Bool Function WaitForCompletedFHUThread(sr_inflateQuest Inflater, Int Slot, Int Request, Int Owner)
  If Inflater == None || !Inflater.threads || Slot < 0 || Slot >= Inflater.threads.Length || Inflater.threads[Slot] == None
    Return False
  EndIf
  Int Attempts = 0
  Bool NativePolicy = SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
  While Inflater.threads[Slot].GetActorReference() == PlayerRef
    If (NativePolicy && !PSQAppearance.FHUTaskCurrent34(Self, Request, Owner)) || (!NativePolicy && (Owner != ActiveDigestionGeneration || Request != FHUTransferSerial || !FHUActiveDigestionFinished || UninstallPrepared || UninstallCleanupBusy))
      Return False
    EndIf
    If Self.CountFHUPlayerJobs(Inflater) > 1
      Debug.Notification("$PSQ_FHUThreadParallelAfterTransfer")
      Return False
    EndIf
    If Attempts >= 12
      Debug.Notification("$PSQ_FHUThreadClosingAfterTransfer")
      Return False
    EndIf
    Utility.Wait(0.25)
    Attempts += 1
  EndWhile
  If (NativePolicy && !PSQAppearance.FHUTaskCurrent34(Self, Request, Owner)) || (!NativePolicy && (Owner != ActiveDigestionGeneration || Request != FHUTransferSerial || !FHUActiveDigestionFinished || UninstallPrepared || UninstallCleanupBusy))
    Return False
  EndIf
  If Self.CountFHUPlayerJobs(Inflater) > 0 || (Inflater.inflaterAnimatingFaction as Bool && PlayerRef.IsInFaction(Inflater.inflaterAnimatingFaction))
    Debug.Notification("$PSQ_FHUOtherTaskAfterTransfer")
    Return False
  EndIf
  Return True
EndFunction

Function OnFHUActiveDigestDone(Form Target, Float StartingVaginal, Float StartingAnal)
  If !FHUActiveDigestionWaiting || FHUTransferEvent == "" || (Target != PlayerRef as Form) || FHUTransferReceiptBusy || FHUTransferSettlementSerial == FHUTransferSerial || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  Int ReceiptRequest = FHUTransferSerial
  Int ReceiptEpoch = FHUTransferReceiptEpoch
  Int Claim = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    Claim = PSQAppearance.FHUReceipt(Self, ReceiptRequest, ReceiptEpoch, 0)
  EndIf
  If Claim < 0
    Return
  ElseIf Claim == 0
    FHUTransferReceiptBusy = True
  EndIf
  If Math.Abs(StartingVaginal - FHUTransferBeforeVaginal) > 0.001 || Math.Abs(StartingAnal - FHUTransferBeforeAnal) > 0.001
    If !Self.IsCurrentFHUReceipt(ReceiptRequest, ReceiptEpoch)
      Return
    EndIf
    storageutil.SetFloatValue(PlayerRef as Form, "PSQ_FHUUnconfirmedAmount", FHUTransferAmount)
    Self.EndFHUTransfer(False, ReceiptRequest, ReceiptEpoch)
    Debug.Notification("FHU储量在请求期间改变，本次不自动结算，请检查储量。")
    Return
  EndIf
  If FHUTransferUncertain || Self.CountFHUPlayerJobs(Self.GetFHULiveInflater()) > 1
    If !Self.IsCurrentFHUReceipt(ReceiptRequest, ReceiptEpoch)
      Return
    EndIf
    storageutil.SetFloatValue(PlayerRef as Form, "PSQ_FHUUnconfirmedAmount", FHUTransferAmount)
    Self.EndFHUTransfer(False, ReceiptRequest, ReceiptEpoch)
    Debug.Notification("检测到FHU并行处理，本次转入不自动结算，请检查储量。")
    Return
  EndIf
  Float Before = FHUTransferAmount
  Float After = storageutil.GetFloatValue(PlayerRef as Form, FHUTransferPoolKey, 0.0)
  Float Maximum = FHUTransferAmount
  Float Removed
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    Float Combined = 0.0
    If FHUTransferPool != 4 && StartingVaginal + StartingAnal - FHUTransferAmount <= 1.0
      Combined = storageutil.GetFloatValue(PlayerRef as Form, "sr.inflater.cum.vaginal", 0.0) + storageutil.GetFloatValue(PlayerRef as Form, "sr.inflater.cum.anal", 0.0)
    EndIf
    Removed = PSQAppearance.DigestRemoved(FHUTransferPool, FHUTransferAmount, StartingVaginal, StartingAnal, After, Combined, FHUTransferBeforeVaginal + FHUTransferBeforeAnal)
  Else
  If FHUTransferPool != 4
    Before = StartingVaginal
    If FHUTransferPool == 2
      Before = StartingAnal
    EndIf
    If StartingVaginal + StartingAnal - FHUTransferAmount <= 1.0
      Before = StartingVaginal + StartingAnal
      After = storageutil.GetFloatValue(PlayerRef as Form, "sr.inflater.cum.vaginal", 0.0) + storageutil.GetFloatValue(PlayerRef as Form, "sr.inflater.cum.anal", 0.0)
      Maximum = FHUTransferBeforeVaginal + FHUTransferBeforeAnal
    EndIf
  EndIf
  Removed = Before - After
  If Removed > Maximum
    Removed = Maximum
  EndIf
  EndIf
  If !Self.IsCurrentFHUReceipt(ReceiptRequest, ReceiptEpoch)
    Return
  EndIf
  If Removed <= 0.0
    Self.EndFHUTransfer(False, ReceiptRequest, ReceiptEpoch)
    Return
  EndIf
  Float Credit = Removed * FHUTransferConversion
  If Claim == 1
    If PSQAppearance.FHUReceipt(Self, ReceiptRequest, ReceiptEpoch, 2) != 1
      Return
    EndIf
  Else
    FHUTransferSettlementSerial = ReceiptRequest
  EndIf
  If !Self.IsCurrentFHUReceipt(ReceiptRequest, ReceiptEpoch)
    Return
  EndIf
  storageutil.AdjustFloatValue(PlayerRef as Form, "PSQ_InternalSemen", Credit)
  If !Self.IsCurrentFHUReceipt(ReceiptRequest, ReceiptEpoch)
    Return
  EndIf
  storageutil.UnsetFloatValue(PlayerRef as Form, "PSQ_FHUUnconfirmedAmount")
  storageutil.UnsetIntValue(PlayerRef as Form, "PSQ_FHUUnconfirmedRequest")
  Self.EndFHUTransfer(True, ReceiptRequest, ReceiptEpoch)
  Self.SetBellyScale()
EndFunction

Bool Function IsCurrentFHUReceipt(Int Request, Int Epoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    Int Check = PSQAppearance.FHUReceipt(Self, Request, Epoch, 1)
    If Check != 0
      Return Check == 1
    EndIf
  EndIf
  Return FHUTransferReceiptBusy && FHUActiveDigestionWaiting && Request == FHUTransferSerial && Epoch == FHUTransferReceiptEpoch && !UninstallPrepared && !UninstallCleanupBusy
EndFunction

String Function GetActiveDigestionReserveText()
  String PSQMessage = "PSQ储量：" + storageutil.GetFloatValue(PlayerRef as Form, "PSQ_InternalSemen", 0.0) as String
  If Self.GetFHULiveInflater() != None
    PSQMessage += "；FHU阴道：" + storageutil.GetFloatValue(PlayerRef as Form, "sr.inflater.cum.vaginal", 0.0) as String
    PSQMessage += "，肛门：" + storageutil.GetFloatValue(PlayerRef as Form, "sr.inflater.cum.anal", 0.0) as String
    PSQMessage += "，口腔：" + storageutil.GetFloatValue(PlayerRef as Form, "sr.inflater.cum.oral", 0.0) as String
  EndIf
  Return PSQMessage
EndFunction

headpart Function GetTransformHairChoice(Int Choice, Int Owner, Bool RequireBusy)
  Return Self.GetTransformHairChoice38(Choice, Owner, RequireBusy)
EndFunction

HeadPart Function GetCurrentPlayerHair()
  If PlayerRef == None
    Return None
  EndIf
  ActorBase Base = PlayerRef.GetActorBase()
  If Base == None
    Return None
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777225
    HeadPart NativeHair = PSQAppearance.ReadTransformHead(Base, True)
    If NativeHair != None
      Return NativeHair
    EndIf
  EndIf
  ; SKSE's indexed lookups exclude extra parts (hairlines etc.). The actor's
  ; ChangeHeadPart uses the overlay list when a race overlay is active.
  If Base.GetNumOverlayHeadParts() > 0
    Int OverlayIndex = Base.GetIndexOfOverlayHeadPartByType(3)
    If OverlayIndex >= 0
      Return Base.GetNthOverlayHeadPart(OverlayIndex)
    EndIf
    Return None
  EndIf
  Int Index = Base.GetIndexOfHeadPartByType(3)
  If Index >= 0
    Return Base.GetNthHeadPart(Index)
  EndIf
  Return None
EndFunction

Function RestoreTransformHair(Int Owner, Bool RequireBusy)
  Self.RestoreTransformHair40(Owner, RequireBusy)
EndFunction

Function ApplySelectedTransformHair(Int Owner, Bool RequireBusy)
  Self.SyncPlayerAppearanceRace()
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  HeadPart Hair = Self.GetTransformHairChoice(SuccubusHairSelection, Owner, RequireBusy)
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  HenshinHair = Hair != None
  If !IsHenshined
    Return
  EndIf
  If Hair == None || psqracecompatibility.ShouldPreserveHeadAppearance(PlayerRef) || !psqracecompatibility.CanUseHeadPart(Hair, PlayerRef.GetRace())
    If OrgHair != None
      Self.RestoreTransformHair(Owner, RequireBusy)
    EndIf
    Return
  EndIf
  HeadPart Current = Self.GetCurrentPlayerHair()
  If Current == None || Current == Hair || !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  If OrgHair == None
    ; Covers enabling PSQ hair from the menu after transformation.
    OrgHair = Current
  EndIf
  If Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    If !(SKSE.GetPluginVersion("PSQ Appearance") >= 16777231) || PSQAppearance.SwitchHead(PlayerRef, PlayerRef.GetLeveledActorBase(), Current, Hair, Self, PlayerAppearanceRace, Owner, PSQLoadEpoch, RequireBusy, False) == 0
      PlayerRef.ChangeHeadPart(Hair)
    EndIf
    If Self.IsAppearanceOperationCurrent(Owner, RequireBusy) && Self.GetCurrentPlayerHair() == Hair
      StorageUtil.SetFormValue(PlayerRef, "PSQ_AppliedTransformHair", Hair)
    EndIf
  EndIf
EndFunction

Function RestoreLegacyTransformSkin(Int Owner, Bool RequireBusy)
  Self.RestoreLegacyTransformSkin40(Owner, RequireBusy)
EndFunction

Function MigrateTransformPresetCatalog(Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  ; A legacy numeric slot is never interpreted as a new BCNG numeric slot.
  If TransformPresetCatalogVersion < 2 && BCNGSelectedPresetId == "" && TransformPresetName == "" && HenshinBody
    If TransformPresetCatalogVersion < 1
      If SuccubusBodySelection == 1
        TransformPresetName = "GT+++"
      ElseIf SuccubusBodySelection == 2
        TransformPresetName = "性感骚鸡CBBE 3BA身形"
      ElseIf SuccubusBodySelection == 3
        TransformPresetName = "MouseBell V2"
      ElseIf SuccubusBodySelection == 4
        TransformPresetName = "Demonic Body"
      EndIf
    Else
      TransformPresetName = jsonutil.StringListGet("PSQ/BodyPresets", "names", SuccubusBodySelection - 1)
    EndIf
  EndIf
  If !Self.HasBodyChangeNGAPI() || !BCNGPSQBridge.IsReady()
    Return
  EndIf
  Self.EnsureTransformBodyCatalog(Owner, RequireBusy)
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy) || !TransformBodyCatalogReady
    Return
  EndIf
  If !HenshinBody
    SuccubusBodySelection = 0
    TransformPresetCatalogVersion = 2
    Return
  EndIf
  String Id = BCNGSelectedPresetId
  If Id == "" && TransformPresetName != ""
    Id = BCNGPSQBridge.FindPresetId(PlayerRef, TransformPresetName)
  EndIf
  Int Index = BCNGBodyPresetIds.Find(Id)
  If Id == "" || Index < 0
    ; Retain the name/identity so a temporarily missing preset is recoverable.
    SuccubusBodySelection = 0
    BCNGBodyStatus = -3
    Return
  EndIf
  BCNGSelectedPresetId = Id
  TransformPresetName = BCNGPSQBridge.GetPresetName(Id)
  SuccubusBodySelection = Index + 1
  TransformPresetCatalogVersion = 2
EndFunction

TextureSet Function GetExternalEyeTexture(Int Index, Int Owner, Bool RequireBusy)
  Return Self.GetExternalEyeTexture38(Index, Owner, RequireBusy)
EndFunction

Bool Function CanPrepareUninstall()
  If skse.GetPluginVersion("papyrusutil plugin") < 0 && skse.GetPluginVersion("PapyrusUtil") < 0
    Return False
  EndIf
  If UninstallPrepared || UninstallCleanupBusy || IsHenshinchu || AppearanceEditBusy || ManualDigestionBusy || FHUActiveDigestionWaiting || IsMilking || PlayerRef.IsDead()
    Return False
  EndIf
  If Self.IsIntegrationPluginLoaded("SexLab.esm") && SexLab != None
    If SexLab.IsActorActive(PlayerRef)
      Return False
    EndIf
  EndIf
  psqsoulgemincubatequestscript Incubator = Game.GetFormFromFile(3428, "PSQ PlayerSuccubusQuest.esm") as psqsoulgemincubatequestscript
  If Incubator != None && Incubator.IsBusyForUninstall()
    Return False
  EndIf
  Return True
EndFunction

Bool Function PrepareForUninstall()
  If Self.IsWingflightAirborne()
    Debug.Notification("请先着陆，再准备卸载 PSQ。")
    Return False
  EndIf
  If !Self.CanPrepareUninstall()
    Return False
  EndIf
  If jsonutil.IntListCount("PSQ/UninstallManifest", "quests") != 7
    Debug.MessageBox("清理资源清单缺失，请重新安装本次更新后再清理。")
    Return False
  EndIf
  If !Self.BeginAppearanceEdit()
    Return False
  EndIf
  Int CleanupOwner = AppearanceOperationId
  Self.RestoreOriginalEquipmentVisibility()
  If !Self.RestoreBCNGTransformSkin()
    Self.EndAppearanceEdit(CleanupOwner)
    Debug.MessageBox("变身皮肤尚未恢复，请启用对应的 Body Change NG 接口补丁后再准备卸载。")
    Return False
  EndIf
  BCNGBodyClearOnly = True
  If !Self.RequestBCNGBodyChange(False, "", CleanupOwner, True, True) || BCNGBodyNeedsSync
    Self.EndAppearanceEdit(CleanupOwner)
    Debug.MessageBox("$PSQ_BCNGUninstallPending")
    Return False
  EndIf
  If !Self.ReturnPersonalStorageItems(CleanupOwner, True)
    Self.EndAppearanceEdit(CleanupOwner)
    Debug.MessageBox("$PSQ_StorageReturnUninstallFailed")
    Return False
  EndIf
  If CleanupOwner != AppearanceOperationId
    Return False
  EndIf
  UninstallCleanupBusy = True
  Self.SyncSatiationSkillPerks(1)
  Self.EndAppearanceEdit(CleanupOwner)
  AlternateStartBecomePending = False
  AlternateStartResumePending = False
  Float SavedHealth = PlayerRef.GetActorValue("Health")
  RetirementSavedHealth = SavedHealth
  RetirementSavedMagicka = PlayerRef.GetActorValue("Magicka")
  RetirementSavedStamina = PlayerRef.GetActorValue("Stamina")
  RetirementPoolsPending = True
  PlayerRef.RestoreActorValue("Health", PlayerRef.GetActorValueMax("Health"))
  EnableDrain = False
  EnablePSQRape = False
  StopEnergyConsuming = True
  StopAddMilk = True
  EnableRankShoutCooldownBonus = False
  FHUActiveDigestionWaiting = False
  FHUActiveDigestionFinished = False
  Self.UnregisterForAllModEvents()
  Self.UnregisterForAllKeys()
  Self.UnregisterForAllControls()
  Self.UnregisterForNiNodeUpdate()
  Self.UnregisterForUpdate()
  Self.UnregisterForUpdateGameTime()
  Self.UnregisterSuccubusEvents()
  Self.ResetRankMagicCostReduction()
  Self.RemoveTransformBuffSafely(CleanupOwner, -1)
  Self.QuitSuccubus()
  Self.RestoreTransformHair(-1, False)
  Self.RestoreTransformBody(-1, False)
  Self.RestoreOriginalPlayerEyes(-1, False)
  Self.RestoreTransformSkinColor(-1, False)
  If Self.RestoreOriginalPlayerHairColor(-1, False)
    PlayerRef.QueueNiNodeUpdate()
  EndIf
  Self.SetScaleHuman(-1, False)
  Self.ResetRankShoutCooldownBonus()
  Self.ClearEnergyDisplay()
  SuccubusNightEyeEnabled = False
  SuccubusNightEyeImod.Remove()
  SuccubusNightEyeIntroFXImod.Remove()
  SuccubusNightEyeOutroFXImod.Remove()
  SuccubusTransFXS.Stop(PlayerRef as ObjectReference)
  FireFXShader.Stop(PlayerRef as ObjectReference)
  ShockPlayerCloakFXShader.Stop(PlayerRef as ObjectReference)
  PlayerIsSuccubus.SetValue(0.0)
  If SEBU != None
    SEBU.SyncVisibility()
  EndIf
  IsHenshined = False
  Self.SyncAWUWing()
  IsHenshinchu = False
  OrgHairColor = None
  Self.ClearPSQSLIFOutput()
  Self.CleanupRacialDrainTraits()
  Self.StopEnergySense()
  PlayerRef.RemoveSpell(Self.GetEnergySenseSpell())
  PlayerRef.RemoveSpell(Self.GetAproposRepairSpell())
  Self.ReleaseAllSuccubusThralls()
  Self.CleanupPSQActor(PlayerRef)
  Self.CleanupStoredPSQActors(storageutil.debug_AllIntObjs())
  Self.CleanupStoredPSQActors(storageutil.debug_AllFloatObjs())
  Self.CleanupStoredPSQActors(storageutil.debug_AllFormObjs())
  Self.CleanupStoredPSQActors(storageutil.debug_AllIntListObjs())
  Self.CleanupStoredPSQActors(storageutil.debug_AllFormListObjs())
  Int i = 0
  While i < jsonutil.IntListCount("PSQ/UninstallManifest", "quests")
    Quest OwnedQuest = Game.GetFormFromFile(jsonutil.IntListGet("PSQ/UninstallManifest", "quests", i), "PSQ PlayerSuccubusQuest.esm") as Quest
    If OwnedQuest != None && (OwnedQuest != Game.GetFormFromFile(3427, "PSQ PlayerSuccubusQuest.esm") as Quest)
      Int j = 0
      While j < OwnedQuest.GetNumAliases()
        Alias OwnedAlias = OwnedQuest.GetNthAlias(j)
        OwnedAlias.UnregisterForUpdate()
        OwnedAlias.UnregisterForUpdateGameTime()
        OwnedAlias.UnregisterForAllModEvents()
        OwnedAlias.UnregisterForAllKeys()
        ReferenceAlias RefAlias = OwnedAlias as ReferenceAlias
        If RefAlias != None
          Self.CleanupPSQActor(RefAlias.GetActorReference())
          RefAlias.Clear()
        EndIf
        j += 1
      EndWhile
      OwnedQuest.UnregisterForUpdate()
      OwnedQuest.UnregisterForUpdateGameTime()
      OwnedQuest.UnregisterForAllModEvents()
      OwnedQuest.UnregisterForAllKeys()
      If OwnedQuest != Self as Quest
        OwnedQuest.Stop()
      EndIf
    EndIf
    i += 1
  EndWhile
  Self.RemovePSQIntegrationFood()
  i = 0
  While i < jsonutil.IntListCount("PSQ/UninstallManifest", "items")
    Form Item = Game.GetFormFromFile(jsonutil.IntListGet("PSQ/UninstallManifest", "items", i), "PSQ PlayerSuccubusQuest.esm")
    If Item != None && PlayerRef.GetItemCount(Item) > 0
      PlayerRef.RemoveItem(Item, PlayerRef.GetItemCount(Item), True, None)
    EndIf
    i += 1
  EndWhile
  i = 0
  While i < jsonutil.IntListCount("PSQ/UninstallManifest", "globals")
    GlobalVariable value = Game.GetFormFromFile(jsonutil.IntListGet("PSQ/UninstallManifest", "globals", i), "PSQ PlayerSuccubusQuest.esm") as GlobalVariable
    If value != None
      value.SetValue(0.0)
    EndIf
    i += 1
  EndWhile
  i = 0
  While i < jsonutil.StringListCount("PSQ/UninstallManifest", "pregnancy_keys")
    String PSQKey = jsonutil.StringListGet("PSQ/UninstallManifest", "pregnancy_keys", i)
    storageutil.UnsetIntValue(PlayerRef as Form, PSQKey)
    storageutil.UnsetFloatValue(PlayerRef as Form, PSQKey)
    storageutil.UnsetStringValue(PlayerRef as Form, PSQKey)
    storageutil.UnsetFormValue(PlayerRef as Form, PSQKey)
    storageutil.IntListClear(PlayerRef as Form, PSQKey)
    storageutil.FloatListClear(PlayerRef as Form, PSQKey)
    storageutil.StringListClear(PlayerRef as Form, PSQKey)
    storageutil.FormListClear(PlayerRef as Form, PSQKey)
    i += 1
  EndWhile
  UninstallCleanedDataCount = storageutil.ClearAllPrefix("PSQ_")
  Self.ClearManagedMovement()
  Fish = EmptyActorArray
  FishCount = 0
  Slots = EmptyActorArray
  ManualManagedAbilities = EmptyBoolArray
  StableCachedSatiationInputs = EmptyFloatArray
  StableAppliedSatiationMagnitudes = EmptyFloatArray
  StableAppliedSatiationSpell = None
  ; Retire recovery references only; personal inventory is never removed.
  EquipmentRecoveryRequest += 1
  EquipmentRecoveryRequestQueued = False
  TransformEquipmentRecoveryItems = EmptyFormArray
  OrgArmorList.Revert()
  XFLMain = None
  FollowerExtension = None
  EFFActive = False
  If Self.HasNiOverrideRuntime()
    nioverride.ClearBodyMorphKeys(PlayerRef as ObjectReference, "PSQ")
    nioverride.ClearBodyMorphKeys(PlayerRef as ObjectReference, "PSQ_TransformPreset")
    Self.RemovePSQActorNodeScales(PlayerRef)
    nioverride.UpdateModelWeight(PlayerRef as ObjectReference)
  EndIf
  Self.InvalidateTransformAppearanceCache()
  Self.ClearAppliedTransformBody(-1, False)
  AppliedTransformEyeTexture = None
  ; Normal maintenance was stopped for uninstall, so settle any pending controls here.
  Int AWUAttempt = 0
  While AWUAttempt < 2 && (AWUMayRemoveSpell || AWUMayRemovePower) && AWUOwnedWing == None
    Utility.WaitMenuMode(1.0)
    Self.SettleAWUWingControls()
    AWUAttempt += 1
  EndWhile
  UninstallPrepared = True
  Self.SendWingflightCommand("policy", 0.0)
  WingflightPublishedPolicy = 0
  Self.RestoreCleanupHealth(PlayerRef, SavedHealth)
  Self.PreserveSatiationCurrentValue("Magicka", RetirementSavedMagicka, -1, -1)
  Self.PreserveSatiationCurrentValue("Stamina", RetirementSavedStamina, -1, -1)
  RetirementPoolsPending = False
  UninstallCleanupBusy = False
  Return True
EndFunction

Function CleanupStoredPSQActors(Form[] Stored)
  Int i = 0
  While Stored as Bool && i < Stored.Length
    Actor Target = Stored[i] as Actor
    If Target != None && storageutil.CountAllObjPrefix(Target as Form, "PSQ_") > 0
      Self.CleanupPSQActor(Target)
    EndIf
    i += 1
  EndWhile
EndFunction

Function CleanupPSQActor(Actor Target)
  If Target == None || storageutil.GetIntValue(Target as Form, "PSQ_UninstallActorCleaned", 0) == 1
    Return
  EndIf
  Float SavedHealth = Target.GetActorValue("Health")
  Bool WasAlive = !Target.IsDead()
  If WasAlive
    Target.RestoreActorValue("Health", Target.GetActorValueMax("Health"))
  EndIf
  If storageutil.GetIntValue(Target as Form, "PSQ_IsSummoned", 0) == 1
    If Self.CanUseEFF()
      XFLMain.XFL_RemoveFollower(Target as ObjectReference, 0, 0)
    EndIf
    Target.SetPlayerTeammate(False, True)
  EndIf
  Int i = 0
  While i < jsonutil.IntListCount("PSQ/UninstallManifest", "spells")
    Spell Owned = Game.GetFormFromFile(jsonutil.IntListGet("PSQ/UninstallManifest", "spells", i), "PSQ PlayerSuccubusQuest.esm") as Spell
    If Owned != None
      Target.DispelSpell(Owned)
      Target.RemoveSpell(Owned)
    EndIf
    i += 1
  EndWhile
  i = 0
  While i < jsonutil.IntListCount("PSQ/UninstallManifest", "perks")
    Perk owned = Game.GetFormFromFile(jsonutil.IntListGet("PSQ/UninstallManifest", "perks", i), "PSQ PlayerSuccubusQuest.esm") as Perk
    If owned != None
      Target.RemovePerk(owned)
    EndIf
    i += 1
  EndWhile
  i = 0
  While i < jsonutil.IntListCount("PSQ/UninstallManifest", "factions")
    Faction owned = Game.GetFormFromFile(jsonutil.IntListGet("PSQ/UninstallManifest", "factions", i), "PSQ PlayerSuccubusQuest.esm") as Faction
    If owned != None
      Target.RemoveFromFaction(owned)
    EndIf
    i += 1
  EndWhile
  Self.RemovePSQActorNodeScales(Target)
  If WasAlive
    Self.RestoreCleanupHealth(Target, SavedHealth)
  EndIf
  storageutil.SetIntValue(Target as Form, "PSQ_UninstallActorCleaned", 1)
EndFunction

Function RestoreCleanupHealth(Actor Target, Float SavedHealth)
  Float Maximum = Target.GetActorValueMax("Health")
  If SavedHealth > Maximum
    SavedHealth = Maximum
  EndIf
  If SavedHealth < 1.0
    SavedHealth = 1.0
  EndIf
  Float Difference = SavedHealth - Target.GetActorValue("Health")
  If Difference > 0.0
    Target.RestoreActorValue("Health", Difference)
  ElseIf Difference < 0.0
    Target.DamageActorValue("Health", -Difference)
  EndIf
EndFunction

Function RemovePSQActorNodeScales(Actor Target)
  If !Self.HasNiOverrideRuntime() || Target == None
    Return
  EndIf
  String[] Nodes = new String[10]
  Nodes[0] = "NPC"
  Nodes[1] = "NPC L Butt"
  Nodes[2] = "NPC R Butt"
  Nodes[3] = "NPC Genitals01 [Gen01]"
  Nodes[4] = "NPC GenitalsScrotum [GenScrot]"
  Nodes[5] = "NPC Belly"
  Nodes[6] = "NPC L PreBreast"
  Nodes[7] = "NPC R PreBreast"
  Nodes[8] = "NPC L Breast"
  Nodes[9] = "NPC R Breast"
  Bool Female = Target.GetLeveledActorBase().GetSex() == 1
  Int i = 0
  While i < Nodes.Length
    nioverride.RemoveNodeTransformScale(Target as ObjectReference, True, Female, Nodes[i], "PSQ")
    nioverride.RemoveNodeTransformScale(Target as ObjectReference, False, Female, Nodes[i], "PSQ")
    nioverride.UpdateNodeTransform(Target as ObjectReference, True, Female, Nodes[i])
    nioverride.UpdateNodeTransform(Target as ObjectReference, False, Female, Nodes[i])
    i += 1
  EndWhile
EndFunction

Function RemovePSQIntegrationFood()
  If !Self.IsIntegrationPluginLoaded("iNeed.esp")
    Return
  EndIf
  Int[] Lists = new Int[6]
  Int[] Foods = new Int[6]
  Lists[0] = 3435
  Lists[1] = 3435
  Lists[2] = 3435
  Lists[3] = 3436
  Lists[4] = 3433
  Lists[5] = 47656
  Foods[0] = SemenPotion.GetFormID() % 16777216
  Foods[1] = 3629
  Foods[2] = 3630
  Foods[3] = 3612
  Foods[4] = 3613
  Foods[5] = 3628
  Int i = 0
  While i < 6
    FormList List = Game.GetFormFromFile(Lists[i], "iNeed.esp") as FormList
    Form Food = Game.GetFormFromFile(Foods[i], "PSQ PlayerSuccubusQuest.esm")
    If List != None && Food != None
      List.RemoveAddedForm(Food)
    EndIf
    i += 1
  EndWhile
EndFunction

Int Function GetAttributeDrainAmount(Int Rank)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777228
    Return PSQAppearance.DrainAmount(Rank)
  EndIf
  If Rank < 5
    Return 0
  ElseIf Rank < 9
    Return 10
  ElseIf Rank == 9
    Return 20
  EndIf
  Return 30
EndFunction

Bool Function IsAttributeDrainProtected(Actor Target)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    Return PSQAppearance.ProtectedDrainTarget(Target, Self.GetSuccubusThrallQuest(), Game.GetFormFromFile(378958, "Skyrim.esm") as Faction)
  EndIf
  If Target == None || Target == PlayerRef
    Return True
  EndIf
  If Target.IsPlayerTeammate()
    Return True
  EndIf
  If Self.IsSuccubusThrall(Target)
    Return True
  EndIf
  Faction CurrentFollowers = Game.GetFormFromFile(378958, "Skyrim.esm") as Faction
  Return CurrentFollowers != None && Target.IsInFaction(CurrentFollowers)
EndFunction

Function DrainNPCAttributes(Actor Target)
  If Self.IsAttributeDrainProtected(Target)
    Return
  EndIf
  If AttributeDrainMode != 1 || AttributeDrainBusy || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  If Target == None || Target == PlayerRef || Target.IsDead() || PlayerRef.IsDead() || !Target.HasKeywordString("ActorTypeNPC")
    Return
  EndIf
  Int Rank = SuccubusRank.GetValueInt()
  Int Amount = Self.GetAttributeDrainAmount(Rank)
  If Amount <= 0
    Return
  EndIf
  AttributeDrainBusy = True
  String[] Values = new String[3]
  Values[0] = "Health"
  Values[1] = "Magicka"
  Values[2] = "Stamina"
  String[] Labels = new String[3]
  Labels[0] = "生命上限"
  Labels[1] = "法力上限"
  Labels[2] = "耐力上限"
  Float[] Batch
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777233
    Batch = PSQAppearance.DrainAttributesBatch(Target, PlayerRef, Self.GetSuccubusThrallQuest(), Game.GetFormFromFile(378958, "Skyrim.esm") as Faction, Rank, Utility.RandomInt(0, 2147483646))
  EndIf
  Int Chosen = -1
  Int i = 0
  If !Batch || Batch.Length != 3
    Float Highest = -1.0
    Int[] Candidates = new Int[3]
    Int Count = 0
    While i < 3
      Float value = Target.GetBaseActorValue(Values[i])
      If value > Highest
        Highest = value
        Candidates[0] = i
        Count = 1
      ElseIf value == Highest
        Candidates[Count] = i
        Count += 1
      EndIf
      i += 1
    EndWhile
    If Rank < 8 && Count > 0
      Chosen = Candidates[Utility.RandomInt(0, Count - 1)]
    EndIf
  EndIf
  String Notice = "从" + Target.GetLeveledActorBase().GetName() + "吸取属性："
  Bool Changed = False
  i = 0
  While i < 3
    If (Batch && Batch.Length == 3) || Rank >= 8 || i == Chosen
      Float Received
      If Batch && Batch.Length == 3
        Received = Batch[i]
      Else
        Received = Self.TransferNPCAttribute(Target, Values[i], Amount as Float)
      EndIf
      If Received > 0.0
        Self.RecordGrowthAbsorption("Attribute", Values[i], Received)
        If Changed
          Notice += "，"
        EndIf
        Notice += Labels[i] + " +" + (Received as Int) as String
        Changed = True
      EndIf
    EndIf
    i += 1
  EndWhile
  If Changed
    Debug.Notification(Notice)
  EndIf
  AttributeDrainBusy = False
EndFunction

Float Function TransferNPCAttribute(Actor Target, String ValueName, Float Requested)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    Return PSQAppearance.TransferAttribute(Target, PlayerRef, Self.GetSuccubusThrallQuest(), Game.GetFormFromFile(378958, "Skyrim.esm") as Faction, ValueName, Requested)
  EndIf
  If Self.IsAttributeDrainProtected(Target)
    Return 0.0
  EndIf
  Float TargetBase = Target.GetBaseActorValue(ValueName)
  Float PlayerBase = PlayerRef.GetBaseActorValue(ValueName)
  Float Minimum = 0.0
  If ValueName == "Health"
    Minimum = 1.0
  EndIf
  Float Available = TargetBase - Minimum
  Float MaxAvailable = Target.GetActorValueMax(ValueName) - Minimum
  If Available > MaxAvailable
    Available = MaxAvailable
  EndIf
  Float Amount = Requested
  If Amount > Available
    Amount = Available
  EndIf
  If Amount <= 0.0
    Return 0.0
  EndIf
  Float SavedTarget = Target.GetActorValue(ValueName)
  Float SavedPlayer = PlayerRef.GetActorValue(ValueName)
  If ValueName == "Health"
    Target.RestoreActorValue("Health", Target.GetActorValueMax("Health"))
  EndIf
  Target.SetActorValue(ValueName, TargetBase - Amount)
  Float Debited = TargetBase - Target.GetBaseActorValue(ValueName)
  If Debited > Amount
    Debited = Amount
  EndIf
  Float Received = 0.0
  If Debited > 0.0
    PlayerRef.SetActorValue(ValueName, PlayerBase + Debited)
    Received = PlayerRef.GetBaseActorValue(ValueName) - PlayerBase
    If Received < 0.0
      Received = 0.0
    ElseIf Received > Debited
      PlayerRef.SetActorValue(ValueName, PlayerBase + Debited)
      Received = Debited
    EndIf
    If Received < Debited
      Target.SetActorValue(ValueName, TargetBase - Received)
    EndIf
  EndIf
  Self.RestoreAttributeCurrent(Target, ValueName, SavedTarget)
  Self.RestoreAttributeCurrent(PlayerRef, ValueName, SavedPlayer)
  Return Received
EndFunction

Function RestoreAttributeCurrent(Actor Target, String ValueName, Float Saved)
  Float Maximum = Target.GetActorValueMax(ValueName)
  If Saved > Maximum
    Saved = Maximum
  EndIf
  If ValueName == "Health" && Saved < 1.0
    Saved = 1.0
  ElseIf Saved < 0.0
    Saved = 0.0
  EndIf
  Float Difference = Saved - Target.GetActorValue(ValueName)
  If Difference > 0.0
    Target.RestoreActorValue(ValueName, Difference)
  ElseIf Difference < 0.0
    Target.DamageActorValue(ValueName, -Difference)
  EndIf
EndFunction

Function RecordStrongBodyPurchase(Int Choice)
  If PlayerRef == None || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  If Choice == 1
    StorageUtil.AdjustIntValue(PlayerRef, "PSQ_Growth_StrongBody_Magicka", 10)
  ElseIf Choice == 2
    Self.GetStrongBodyLegacyCarry()
    StorageUtil.AdjustIntValue(PlayerRef, "PSQ_Growth_StrongBody_CarryWeight", 50)
    Self.QueueStrongBodyCarrySync()
    Self.SyncStrongBodyCarry()
  ElseIf Choice == 3
    StorageUtil.AdjustIntValue(PlayerRef, "PSQ_Growth_StrongBody_PerkPoints", 1)
  EndIf
EndFunction

Function RecordGrowthAbsorption(String Category, String ValueName, Float Actual)
  If Actual <= 0.0 || PlayerRef == None || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  String PSQKey = "PSQ_Growth_" + Category + "_" + ValueName
  storageutil.AdjustFloatValue(PlayerRef as Form, PSQKey, Actual)
  PSQKey = "PSQ_Growth_" + Category + "_Total"
  storageutil.AdjustFloatValue(PlayerRef as Form, PSQKey, Actual)
EndFunction

Float Function GetGrowthAbsorbed(String Category, String ValueName)
  If PlayerRef == None
    Return 0.0
  EndIf
  Return storageutil.GetFloatValue(PlayerRef as Form, "PSQ_Growth_" + Category + "_" + ValueName, 0.0)
EndFunction

Function PrepareSuccubusMerchantTrade()
  If UninstallPrepared || UninstallCleanupBusy
    Self.UnregisterForUpdateGameTime()
    Return
  EndIf
  Faction MerchantFaction = Game.GetFormFromFile(3788, "PSQ PlayerSuccubusQuest.esm") as Faction
  FormList Exclusions = Game.GetFormFromFile(3789, "PSQ PlayerSuccubusQuest.esm") as FormList
  ObjectReference Chest = Game.GetFormFromFile(3777, "PSQ PlayerSuccubusQuest.esm") as ObjectReference
  Form Gold = Game.GetFormFromFile(15, "Skyrim.esm")
  If MerchantFaction == None || Exclusions == None || Chest == None || Gold == None
    Return
  EndIf
  Exclusions.Revert()
  MerchantFaction.SetBuySellList(Exclusions)
  MerchantFaction.SetNotSellBuy(True)
  MerchantFaction.SetOnlyBuysStolenItems(True)
  Float Now = GameDaysPassed.GetValue()
  Float Last = storageutil.GetFloatValue(PlayerRef as Form, "PSQ_MerchantLastRefill", Now)
  Bool Initialized = storageutil.GetIntValue(PlayerRef as Form, "PSQ_MerchantInitialized", 0) == 1
  If !Initialized || Now - Last >= 1.0
    If ui.IsMenuOpen("BarterMenu")
      Self.RegisterForSingleUpdateGameTime(0.01)
      Return
    EndIf
    Int MerchantRank = SuccubusRank.GetValueInt()
    If MerchantRank < 1
      MerchantRank = 1
    ElseIf MerchantRank > 10
      MerchantRank = 10
    EndIf
    Int Difference = (MerchantRank * 10000) - Chest.GetItemCount(Gold)
    If Difference > 0
      Chest.AddItem(Gold, Difference, True)
    ElseIf Difference < 0
      Chest.RemoveItem(Gold, -Difference, True, None)
    EndIf
    storageutil.SetFloatValue(PlayerRef as Form, "PSQ_MerchantLastRefill", Now)
    storageutil.SetIntValue(PlayerRef as Form, "PSQ_MerchantInitialized", 1)
    Last = Now
  ElseIf Now < Last
    storageutil.SetFloatValue(PlayerRef as Form, "PSQ_MerchantLastRefill", Now)
    Last = Now
  EndIf
  Float Hours = (Last + 1.0 - Now) * 24.0
  If Hours < 0.01
    Hours = 0.01
  EndIf
  Self.RegisterForSingleUpdateGameTime(Hours)
EndFunction

Event OnUpdateGameTime()
  Self.PrepareSuccubusMerchantTrade()
EndEvent

String Function GetRacialTraitCatalog()
  If Self.IsIntegrationPluginLoaded("Mannaz - Integrated Races of Skyrim.esp")
    Return "PSQ/RacialTraitsMannaz"
  EndIf
  Return "PSQ/RacialTraitsVanilla"
EndFunction

Bool Function RaceContainsTrait(Race Source, Spell Trait)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Return PSQAppearance.RaceHasTrait(Source, Trait)
  EndIf
  If Source == None || Trait == None
    Return False
  EndIf
  Int i = 0
  While i < Source.GetSpellCount()
    If Source.GetNthSpell(i) == Trait
      Return True
    EndIf
    i += 1
  EndWhile
  Return False
EndFunction

Function DrainNPCRacialTrait(Actor Target)
  If RacialTraitDrainMode != 1 || RacialTraitDrainBusy || UninstallPrepared || UninstallCleanupBusy || SuccubusRank.GetValueInt() < 4
    Return
  EndIf
  If Target == None || Target == PlayerRef || Target.IsDead() || Target.IsChild() || PlayerRef.IsDead() || !Target.HasKeywordString("ActorTypeNPC")
    Return
  EndIf
  RacialTraitDrainBusy = True
  String Catalog = Self.GetRacialTraitCatalog()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Form[] Award = PSQAppearance.AcquireRacialTrait(PlayerRef, Target, JsonUtil.StringListToArray(Catalog,"Owner"), JsonUtil.IntListToArray(Catalog,"primary"), JsonUtil.IntListToArray(Catalog,"secondary"), JsonUtil.IntListToArray(Catalog,"Grant"), StorageUtil.FormListToArray(PlayerRef,"PSQ_RacialDrainAcquiredTraits"), Utility.RandomInt(0,2147483646))
    If Award && Award[0] == PlayerRef
      If Award.Length == 4
        Spell SourceAward = Award[1] as Spell
        Spell MainAward = Award[2] as Spell
        Spell ExtraAward = Award[3] as Spell
        StorageUtil.FormListAdd(PlayerRef,"PSQ_RacialDrainOwnedSpells",MainAward,False)
        StorageUtil.FormListAdd(PlayerRef,"PSQ_RacialDrainAcquiredTraits",SourceAward,False)
        If ExtraAward
          StorageUtil.FormListAdd(PlayerRef,"PSQ_RacialDrainOwnedSpells",ExtraAward,False)
        EndIf
        StorageUtil.AdjustIntValue(PlayerRef,"PSQ_Growth_RacialTraits",1)
        Self.PrefixAbsorbedRacialTrait(MainAward)
        If ExtraAward
          Self.PrefixAbsorbedRacialTrait(ExtraAward)
        EndIf
        SuccubusEXP.SetValue(SuccubusEXP.GetValue()+10.0)
        Self.SuccubusLevelUp(0.0)
        Self.SyncRacialTraitDisplay()
        Int AwardRow = 0
        Int AwardRows = JsonUtil.StringListCount(Catalog, "Owner")
        While AwardRow < AwardRows
          String AwardOwner = JsonUtil.StringListGet(Catalog, "Owner", AwardRow)
          If Self.IsIntegrationPluginLoaded(AwardOwner) && Game.GetFormFromFile(JsonUtil.IntListGet(Catalog, "primary", AwardRow), AwardOwner) == SourceAward
            Debug.Notification("获得种族特性：魅魔之力：" + jsonutil.StringListGet(Catalog, "Name", AwardRow) + "（" + jsonutil.StringListGet(Catalog, "Race", AwardRow) + "）＋1000魅魔经验")
            AwardRow = AwardRows
          EndIf
          AwardRow += 1
        EndWhile
      EndIf
      RacialTraitDrainBusy = False
      Return
    EndIf
  EndIf
  Int Count = jsonutil.StringListCount(Catalog, "Owner")
  Int i = 0
  Int Eligible = 0
  Int Selected = -1
  Race SourceRace = Target.GetRace()
  Race OwnRace = PlayerRef.GetRace()
  While i < Count
    String Owner = jsonutil.StringListGet(Catalog, "Owner", i)
    If Self.IsIntegrationPluginLoaded(Owner)
      Spell Trait = Game.GetFormFromFile(jsonutil.IntListGet(Catalog, "primary", i), Owner) as Spell
      Int ExtraID = jsonutil.IntListGet(Catalog, "secondary", i)
      Spell Extra = None
      If ExtraID != 0
        Extra = Game.GetFormFromFile(ExtraID, Owner) as Spell
      EndIf
      If Trait != None && (ExtraID == 0 || Extra != None) && Self.RaceContainsTrait(SourceRace, Trait)
        Int GrantID = jsonutil.IntListGet(Catalog, "Grant", i)
        Spell Grant = None
        If GrantID != 0
          Grant = Game.GetFormFromFile(GrantID, "PSQ PlayerSuccubusQuest.esm") as Spell
        EndIf
        If !PlayerRef.HasSpell(Trait as Form) && !Self.RaceContainsTrait(OwnRace, Trait) && !storageutil.FormListHas(PlayerRef as Form, "PSQ_RacialDrainAcquiredTraits", Trait as Form) && (GrantID == 0 || Grant != None && !PlayerRef.HasSpell(Grant as Form))
          Eligible += 1
          If Utility.RandomInt(1, Eligible) == 1
            Selected = i
          EndIf
        EndIf
      EndIf
    EndIf
    i += 1
  EndWhile
  If Selected >= 0
    String owner = jsonutil.StringListGet(Catalog, "Owner", Selected)
    Spell SourceTrait = Game.GetFormFromFile(jsonutil.IntListGet(Catalog, "primary", Selected), owner) as Spell
    Int grantid = jsonutil.IntListGet(Catalog, "Grant", Selected)
    Spell trait = SourceTrait
    If grantid != 0
      trait = Game.GetFormFromFile(grantid, "PSQ PlayerSuccubusQuest.esm") as Spell
    EndIf
    If trait == None
      RacialTraitDrainBusy = False
      Return
    EndIf
    Int extraid = jsonutil.IntListGet(Catalog, "secondary", Selected)
    If grantid != 0
      extraid = 0
    EndIf
    Spell extra = None
    Bool ExtraWasOwned = False
    Bool ExtraReady = True
    If extraid != 0
      extra = Game.GetFormFromFile(extraid, owner) as Spell
      ExtraWasOwned = PlayerRef.HasSpell(extra as Form) || Self.RaceContainsTrait(OwnRace, extra)
      If !ExtraWasOwned
        ExtraReady = PlayerRef.AddSpell(extra, False)
      EndIf
    EndIf
    If ExtraReady && PlayerRef.AddSpell(trait, False)
      storageutil.FormListAdd(PlayerRef as Form, "PSQ_RacialDrainOwnedSpells", trait as Form, False)
      storageutil.FormListAdd(PlayerRef as Form, "PSQ_RacialDrainAcquiredTraits", SourceTrait as Form, False)
      If extra != None && !ExtraWasOwned
        storageutil.FormListAdd(PlayerRef as Form, "PSQ_RacialDrainOwnedSpells", extra as Form, False)
      EndIf
      storageutil.SetIntValue(PlayerRef as Form, "PSQ_Growth_RacialTraits", storageutil.GetIntValue(PlayerRef as Form, "PSQ_Growth_RacialTraits", 0) + 1)
      Self.PrefixAbsorbedRacialTrait(trait)
      If extra != None && !ExtraWasOwned
        Self.PrefixAbsorbedRacialTrait(extra)
      EndIf
      SuccubusEXP.SetValue(SuccubusEXP.GetValue() + 10.0)
      Self.SuccubusLevelUp(0.0)
      Self.SyncRacialTraitDisplay()
      Debug.Notification("获得种族特性：魅魔之力：" + jsonutil.StringListGet(Catalog, "Name", Selected) + "（" + jsonutil.StringListGet(Catalog, "Race", Selected) + "）＋1000魅魔经验")
    ElseIf extra != None && !ExtraWasOwned && ExtraReady
      PlayerRef.RemoveSpell(extra)
    EndIf
  EndIf
  RacialTraitDrainBusy = False
EndFunction

Function CleanupRacialDrainTraits()
  Self.RestoreRacialGameplayVisibility()
  Self.RestoreRacialDisplayEffectNames()
  Self.ClearRacialTraitDisplay()
  Int i = storageutil.FormListCount(PlayerRef as Form, "PSQ_RacialDrainOwnedSpells") - 1
  Race OwnRace = PlayerRef.GetRace()
  While i >= 0
    Spell Trait = storageutil.FormListGet(PlayerRef as Form, "PSQ_RacialDrainOwnedSpells", i) as Spell
    If Trait != None
      Self.RestoreAbsorbedRacialTraitName(Trait)
      If !Self.RaceContainsTrait(OwnRace, Trait)
        PlayerRef.RemoveSpell(Trait)
      EndIf
    EndIf
    i -= 1
  EndWhile
  storageutil.FormListClear(PlayerRef as Form, "PSQ_RacialDrainOwnedSpells")
  storageutil.FormListClear(PlayerRef as Form, "PSQ_RacialDrainAcquiredTraits")
EndFunction

Function PrefixAbsorbedRacialTrait(Spell Trait)
  If Trait == None || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  String Original = storageutil.GetStringValue(Trait as Form, "PSQ_RacialTraitOriginalName", "")
  If Original == ""
    Original = Trait.GetName()
    If Original == ""
      Return
    EndIf
    If stringutil.Find(Original, "魅魔之力：", 0) == 0
      Return
    EndIf
    storageutil.SetStringValue(Trait as Form, "PSQ_RacialTraitOriginalName", Original)
  EndIf
  String Desired = "魅魔之力：" + Original
  If Trait.GetName() != Desired
    Trait.SetName(Desired)
  EndIf
EndFunction

Function RefreshAbsorbedRacialTraitNames()
  Int i = 0
  Int Count = storageutil.FormListCount(PlayerRef as Form, "PSQ_RacialDrainOwnedSpells")
  While i < Count
    Spell Trait = storageutil.FormListGet(PlayerRef as Form, "PSQ_RacialDrainOwnedSpells", i) as Spell
    Self.PrefixAbsorbedRacialTrait(Trait)
    i += 1
  EndWhile
  Self.SyncRacialTraitDisplay()
EndFunction

Function RestoreAbsorbedRacialTraitName(Spell Trait)
  String Original = storageutil.GetStringValue(Trait as Form, "PSQ_RacialTraitOriginalName", "")
  If Original != ""
    If Trait.GetName() == "魅魔之力：" + Original
      Trait.SetName(Original)
    EndIf
    storageutil.UnsetStringValue(Trait as Form, "PSQ_RacialTraitOriginalName")
  EndIf
EndFunction

Function MigrateAcquiredRacialPassives()
  If UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  Self.MigrateRacialPassiveCatalog("PSQ/RacialTraitsVanilla")
  If Self.IsIntegrationPluginLoaded("Mannaz - Integrated Races of Skyrim.esp")
    Self.MigrateRacialPassiveCatalog("PSQ/RacialTraitsMannaz")
  EndIf
EndFunction

Function MigrateRacialPassiveCatalog(String Catalog)
  Int i = 0
  While i < jsonutil.StringListCount(Catalog, "Owner")
    Int GrantID = jsonutil.IntListGet(Catalog, "Grant", i)
    String Owner = jsonutil.StringListGet(Catalog, "Owner", i)
    If GrantID != 0 && Self.IsIntegrationPluginLoaded(Owner)
      Spell SourceTrait = Game.GetFormFromFile(jsonutil.IntListGet(Catalog, "primary", i), Owner) as Spell
      Spell NewTrait = Game.GetFormFromFile(GrantID, "PSQ PlayerSuccubusQuest.esm") as Spell
      If SourceTrait != None && NewTrait != None && (storageutil.FormListHas(PlayerRef as Form, "PSQ_RacialDrainOwnedSpells", SourceTrait as Form) || storageutil.FormListHas(PlayerRef as Form, "PSQ_RacialDrainAcquiredTraits", SourceTrait as Form))
        If Owner == "Mannaz - Integrated Races of Skyrim.esp" && GrantID == 41515 && PlayerRef.HasSpell(NewTrait as Form)
          PlayerRef.RemoveSpell(NewTrait)
        EndIf
        Bool Ready = PlayerRef.HasSpell(NewTrait as Form)
        If !Ready
          Ready = PlayerRef.AddSpell(NewTrait, False)
        EndIf
        If Ready
          Self.RestoreAbsorbedRacialTraitName(SourceTrait)
          If !Self.RaceContainsTrait(PlayerRef.GetRace(), SourceTrait)
            PlayerRef.DispelSpell(SourceTrait)
            PlayerRef.RemoveSpell(SourceTrait)
            Self.ClearLegacyRacialActiveEffects(Catalog, i, Owner)
          EndIf
          storageutil.FormListRemove(PlayerRef as Form, "PSQ_RacialDrainOwnedSpells", SourceTrait as Form, True)
          storageutil.FormListAdd(PlayerRef as Form, "PSQ_RacialDrainOwnedSpells", NewTrait as Form, False)
          Int ExtraID = jsonutil.IntListGet(Catalog, "secondary", i)
          If ExtraID != 0
            Spell Extra = Game.GetFormFromFile(ExtraID, Owner) as Spell
            If Extra != None && storageutil.FormListHas(PlayerRef as Form, "PSQ_RacialDrainOwnedSpells", Extra as Form)
              Self.RestoreAbsorbedRacialTraitName(Extra)
              If !Self.RaceContainsTrait(PlayerRef.GetRace(), Extra)
                PlayerRef.DispelSpell(Extra)
                PlayerRef.RemoveSpell(Extra)
              EndIf
              storageutil.FormListRemove(PlayerRef as Form, "PSQ_RacialDrainOwnedSpells", Extra as Form, True)
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    i += 1
  EndWhile
EndFunction

Function ClearLegacyRacialActiveEffects(String Catalog, Int Index, String Owner)
  String PSQKey = "legacy_" + jsonutil.IntListGet(Catalog, "primary", Index) as String
  Int j = 0
  While j < jsonutil.IntListCount(Catalog, PSQKey)
    Spell Legacy = Game.GetFormFromFile(jsonutil.IntListGet(Catalog, PSQKey, j), Owner) as Spell
    If Legacy != None
      PlayerRef.DispelSpell(Legacy)
      PlayerRef.RemoveSpell(Legacy)
    EndIf
    j += 1
  EndWhile
EndFunction

Int Function GetRankMagicCostReduction()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.RankMagic34(Self)
  EndIf
  If !EnableRankMagicCostReduction || UninstallPrepared || UninstallCleanupBusy || PlayerIsSuccubus.GetValueInt() != 1
    Return 0
  EndIf
  Int Rank = SuccubusRank.GetValueInt()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777228
    Return PSQAppearance.MagicReduction(Rank, IsHenshined)
  EndIf
  Int Reduction = 100
  If Rank < 1
    Return 0
  ElseIf Rank <= 3
    Reduction = Rank * 20
  ElseIf Rank < 7
    Reduction = 60 + (Rank - 3) * 10
  EndIf
  If !IsHenshined
    Reduction /= 2
  EndIf
  Return Reduction
EndFunction

Function SyncRankMagicCostReduction()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If PSQAppearance.SyncCost34(Self, False)
      Return
    EndIf
  EndIf
  If RankMagicCostBusy || PlayerRef == None
    Return
  EndIf
  Int Tier = Self.GetRankMagicCostReduction()
  Spell Next = None
  If Tier > 0
    Next = Self.GetRankMagicCostSpell(Tier)
    If Next == None
      Return
    EndIf
  EndIf
  If AppliedRankMagicCostTier == Tier && (Next == None || PlayerRef.HasSpell(Next as Form))
    Return
  EndIf
  RankMagicCostBusy = True
  Int i = 1
  While i <= 12
    Int Reduction = Self.GetRankMagicCostPercentByIndex(i)
    Spell Owned = Self.GetRankMagicCostSpell(Reduction)
    If Owned != None && Owned != Next && PlayerRef.HasSpell(Owned as Form)
      PlayerRef.RemoveSpell(Owned)
    EndIf
    i += 1
  EndWhile
  If Next == None || PlayerRef.HasSpell(Next as Form) || PlayerRef.AddSpell(Next, False)
    AppliedRankMagicCostTier = Tier
  EndIf
  RankMagicCostBusy = False
EndFunction

Function ResetRankMagicCostReduction()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If PSQAppearance.SyncCost34(Self, True)
      Return
    EndIf
  EndIf
  If PlayerRef == None
    Return
  EndIf
  Int i = 1
  While i <= 12
    Int Reduction = Self.GetRankMagicCostPercentByIndex(i)
    Spell Owned = Self.GetRankMagicCostSpell(Reduction)
    If Owned != None && PlayerRef.HasSpell(Owned as Form)
      PlayerRef.RemoveSpell(Owned)
    EndIf
    i += 1
  EndWhile
  AppliedRankMagicCostTier = -1
EndFunction

Spell Function GetRankMagicCostSpell(Int Reduction)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.CostSpell34(Reduction)
  EndIf
  If Reduction == 10
    Return Game.GetFormFromFile(41601, "PSQ PlayerSuccubusQuest.esm") as Spell
  ElseIf Reduction == 30
    Return Game.GetFormFromFile(41602, "PSQ PlayerSuccubusQuest.esm") as Spell
  ElseIf Reduction == 35
    Return Game.GetFormFromFile(41603, "PSQ PlayerSuccubusQuest.esm") as Spell
  ElseIf Reduction == 45
    Return Game.GetFormFromFile(41604, "PSQ PlayerSuccubusQuest.esm") as Spell
  ElseIf Reduction == 50
    Return Game.GetFormFromFile(41605, "PSQ PlayerSuccubusQuest.esm") as Spell
  ElseIf Reduction == 70
    Return Game.GetFormFromFile(41482, "PSQ PlayerSuccubusQuest.esm") as Spell
  ElseIf Reduction == 90
    Return Game.GetFormFromFile(41483, "PSQ PlayerSuccubusQuest.esm") as Spell
  ElseIf Reduction == 20 || Reduction == 40 || Reduction == 60 || Reduction == 80 || Reduction == 100
    Return Game.GetFormFromFile(41476 + Reduction / 20, "PSQ PlayerSuccubusQuest.esm") as Spell
  EndIf
  Return None
EndFunction

Bool Function CanUseSLIFBridge()
; Inflation was removed; retained only for old callers.
  Return False
EndFunction

Bool Function CanReadFertilityBridge()
  ; Pregnancy integrations are retired. FHU uses its own independent interface.
  Return False
EndFunction

Function ClearPSQDirectInflation()
; Cleanup only. Generic PSQ_TransformPreset morphs have a different key.
  if !Self.HasNiOverrideRuntime() || PlayerRef == None
    return
  endif
  Bool Changed = False
  if nioverride.GetBodyMorph(PlayerRef, "PregnancyBelly", "PSQ") != 0.0
    nioverride.ClearBodyMorph(PlayerRef, "PregnancyBelly", "PSQ")
    Changed = True
  endif
  String[] Nodes = new String[5]
  Nodes[0] = "NPC Belly"
  Nodes[1] = "NPC L PreBreast"
  Nodes[2] = "NPC R PreBreast"
  Nodes[3] = "NPC L Breast"
  Nodes[4] = "NPC R Breast"
  Int i = 0
  while i < Nodes.Length
    Bool NodeChanged = False
    if nioverride.HasNodeTransformScale(PlayerRef, True, True, Nodes[i], "PSQ")
      nioverride.RemoveNodeTransformScale(PlayerRef, True, True, Nodes[i], "PSQ")
      NodeChanged = True
    endif
    if nioverride.HasNodeTransformScale(PlayerRef, False, True, Nodes[i], "PSQ")
      nioverride.RemoveNodeTransformScale(PlayerRef, False, True, Nodes[i], "PSQ")
      NodeChanged = True
    endif
    if NodeChanged
      nioverride.UpdateNodeTransform(PlayerRef, True, True, Nodes[i])
      nioverride.UpdateNodeTransform(PlayerRef, False, True, Nodes[i])
      Changed = True
    endif
    i += 1
  endwhile
  if Changed
    nioverride.UpdateModelWeight(PlayerRef)
  endif
  AppliedBellyScale = -1.0
  AppliedBreastScale = -1.0
EndFunction

Function ApplyPSQTransformBreastBase(Float Scale)
; Retired compatibility entry point. Old saved scripts may still call it.
  ; No size calculation, morph write, skeleton scaling, or SLIF submission.
EndFunction

Function ClearPSQSLIFOutput()
  If PSQSLIFNG.IsInstalled()
    PSQSLIFNG.RemoveSource(PlayerRef)
  Else
    Self.UnregisterPSQSLIFSource("SLIF_unregisterMorphActor")
    Self.UnregisterPSQSLIFSource("SLIF_unregisterActor")
  EndIf
  SLIFOutputPending = False
  AppliedInflationViaSLIF = False
  AppliedSLIFBackend = 0
  AppliedSLIFBelly = -1.0
  AppliedSLIFBreast = -1.0
  AppliedSLIFBreastBase = -1.0
EndFunction

Function UnregisterPSQSLIFSource(String EventName)
  If PlayerRef == None || !Self.IsIntegrationPluginLoaded("SexLab Inflation Framework.esp")
    Return
  EndIf
  Int Handle = modevent.Create(EventName)
  If Handle
    modevent.PushForm(Handle, PlayerRef as Form)
    modevent.PushString(Handle, "PSQ Reburn")
    modevent.Send(Handle)
  EndIf
EndFunction

Function UseInflationBackend(Bool UseSLIF)
; Retired compatibility entry point. Old saved scripts may still call it.
  ; No size calculation, morph write, skeleton scaling, or SLIF submission.
EndFunction

Bool Function SendPSQSLIFMorph(String Morph, Float value)
; Inflation was removed; retained only for old callers.
  Return False
EndFunction

Bool Function HasAcceptedPSQSLIFOutput(String Morph, Float value)
; Inflation was removed; retained only for old callers.
  Return False
EndFunction

Function RefreshInflationFertilityBridge()
if UninstallPrepared || UninstallCleanupBusy
    return
  endif
  Self.RetirePSQInflation()
  Self.RetirePSQReproduction()
  Self.RegisterInflationFertilityEvents()
  Self.RefreshFertilityBridgeStatus()
EndFunction

Function UpdateInflationBridgeBackend()
; No active inflation backend remains. Only retire old owned output.
  Self.RetirePSQInflation()
  Self.RetirePSQReproduction()
EndFunction

Function RegisterInflationFertilityEvents()
  ; Remove old registrations without subscribing to external fertility events.
  Self.UnregisterForModEvent("FMR_ActorStatus")
EndFunction

Function OnPSQFertilityStatus(Form Mother, Int Rank, String Father, Int FatherRace)
  ; Ignore queued callbacks from older versions.
EndFunction

Function RefreshFertilityBridgeStatus()
  FertilityBridgeRank = -1
  FertilityBridgeProgress = 0.0
  FertilityBridgeDuration = 0.0
  FertilityBridgeRemaining = 0.0
EndFunction

String Function GetFertilityBridgeStatusName()
  Return "$PSQ_AttributeDrainOff"
EndFunction

String Function GetInflationBackendName()
Return "$PSQ_InflationRemoved"
EndFunction

String Function GetFertilityScalingName()
  Return "$PSQ_AttributeDrainOff"
EndFunction

Float Function GetTransformArmorPerRank()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.ArmorPerRank34(Self)
  EndIf
  Int Mode = Self.GetTransformBuffMode()
  If Mode == 1
    Return 50.0
  ElseIf Mode == 2
    Return SuccubusArmorMagnitude
  EndIf
  Return 0.0
EndFunction

Float Function GetTransformArmorBonus()
  Int Rank = SuccubusRank.GetValueInt()
  If Rank < 1
    Return 0.0
  ElseIf Rank > 10
    Rank = 10
  EndIf
  Float PerRank = Self.GetTransformArmorPerRank()
  If PerRank < 0.0
    PerRank = 0.0
  EndIf
  Return PerRank * Rank as Float
EndFunction

Function UpdateTransformArmor(Bool DuringTransform)
  If IsHenshinchu && !DuringTransform
    Return
  EndIf
  If PlayerRef == None || SuccubusArmorSpell == None
    Return
  EndIf
  Float Bonus = 0.0
  If IsHenshined && !UninstallPrepared && !UninstallCleanupBusy
    Bonus = Self.GetTransformArmorBonus()
  EndIf
  Bool Present = PlayerRef.HasSpell(SuccubusArmorSpell as Form)
  If Bonus <= 0.0
    If Present
      PlayerRef.RemoveSpell(SuccubusArmorSpell)
    EndIf
    Return
  EndIf
  If Present && SuccubusArmorSpell.GetNthEffectMagnitude(0) == Bonus
    Return
  EndIf
  If Present
    PlayerRef.RemoveSpell(SuccubusArmorSpell)
  EndIf
  SuccubusArmorSpell.SetNthEffectMagnitude(0, Bonus)
  PlayerRef.AddSpell(SuccubusArmorSpell, False)
EndFunction

Faction Function GetSuccubusThrallFaction()
  Return Game.GetFormFromFile(41484, "PSQ PlayerSuccubusQuest.esm") as Faction
EndFunction

Quest Function GetSuccubusThrallQuest()
  Quest Holder = Game.GetFormFromFile(41485, "PSQ PlayerSuccubusQuest.esm") as Quest
  Return Holder
EndFunction

Int Function GetSuccubusThrallCapacity()
  If PlayerIsSuccubus.GetValueInt() != 1 || UninstallPrepared || UninstallCleanupBusy
    Return 0
  EndIf
  Int Rank = SuccubusRank.GetValueInt()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777228
    Return PSQAppearance.ThrallCapacity(Rank)
  EndIf
  If Rank < 7
    Return 0
  ElseIf Rank > 10
    Rank = 10
  EndIf
  Return Rank - 6
EndFunction

Actor Function GetSuccubusThrall(Int Slot)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Return PSQAppearance.GetRosterActor(Self.GetSuccubusThrallQuest(),Slot)
  EndIf
  If Slot < 0 || Slot > 3
    Return None
  EndIf
  Quest Holder = Self.GetSuccubusThrallQuest()
  If Holder == None
    Return None
  EndIf
  ReferenceAlias Seat = Holder.GetAlias(Slot) as ReferenceAlias
  If Seat == None
    Return None
  EndIf
  Return Seat.GetActorReference()
EndFunction

Int Function GetSuccubusThrallCount()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    Return PSQAppearance.InspectThralls(Self.GetSuccubusThrallQuest(), None, 0)
  EndIf
  Int Count = 0
  Int i = 0
  While i < 4
    If Self.GetSuccubusThrall(i) != None
      Count += 1
    EndIf
    i += 1
  EndWhile
  Return Count
EndFunction

Bool Function IsSuccubusThrall(Actor Target)
  If Target == None
    Return False
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    Return PSQAppearance.InspectThralls(Self.GetSuccubusThrallQuest(), Target, 2) >= 0
  EndIf
  If !NPCEnergyThrallCacheReady || !NPCEnergyThrallCache || NPCEnergyThrallCachePublishedRevision != NPCEnergyThrallCacheRevision
    Self.RefreshNPCEnergyThrallCache()
  EndIf
  If !NPCEnergyThrallCacheReady || NPCEnergyThrallCachePublishedRevision != NPCEnergyThrallCacheRevision
    Int Slot = 0
    While Slot < 4
      If Self.GetSuccubusThrall(Slot) == Target
        Return True
      EndIf
      Slot += 1
    EndWhile
    Return False
  EndIf
  Int i = 0
  While i < 4
    If NPCEnergyThrallCache[i] == Target
      Return True
    EndIf
    i += 1
  EndWhile
  Return False
EndFunction

Bool Function ConvertSuccubusThrall(Actor Target, Actor Caster)
  Int BondEpoch = PSQLoadEpoch
  Int BondTicket = 0
  Int Reservation = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    BondTicket = PSQAppearance.ReserveThrallBond(Self, Self.GetSuccubusThrallQuest(), Caster, Target, SuccubusCurseSpell, Self.GetSuccubusThrallCapacity(), False, -1, BondEpoch)
    Reservation = BondTicket
  ElseIf SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Reservation = PSQAppearance.BeginThrallConversion(Self, Self.GetSuccubusThrallQuest(), Caster, Target, SuccubusCurseSpell, Self.GetSuccubusThrallCapacity())
  EndIf
  If Reservation < 0
    If Reservation == -2
      Debug.Notification("$PSQ_ThrallLocked")
    ElseIf Reservation == -3
      Debug.Notification("$PSQ_ThrallInvalid")
    ElseIf Reservation == -4
      Debug.Notification("$PSQ_ThrallAlready")
    ElseIf Reservation == -5
      Debug.Notification("$PSQ_ThrallFull")
    EndIf
    Return False
  ElseIf Reservation == 0
    If Caster != PlayerRef || Target == None || ThrallConversionBusy || UninstallPrepared || UninstallCleanupBusy
      Return False
    EndIf
    If Self.GetSuccubusThrallCapacity() == 0 || !PlayerRef.HasSpell(SuccubusCurseSpell as Form)
      Debug.Notification("$PSQ_ThrallLocked")
      Return False
    EndIf
    If Target == PlayerRef || Target.IsDead() || Target.IsChild() || !Target.HasKeywordString("ActorTypeNPC")
      Debug.Notification("$PSQ_ThrallInvalid")
      Return False
    EndIf
    If Self.IsSuccubusThrall(Target)
      Debug.Notification("$PSQ_ThrallAlready")
      Return False
    EndIf
    ThrallConversionBusy = True
    If Self.GetSuccubusThrallCount() >= Self.GetSuccubusThrallCapacity()
      Self.FinishOwnedThrallOperation(BondEpoch, BondTicket)
      Debug.Notification("$PSQ_ThrallFull")
      Return False
    EndIf
  EndIf
  Quest Holder = Self.GetSuccubusThrallQuest()
  Faction OwnFaction = Self.GetSuccubusThrallFaction()
  If Holder != None && !Holder.IsRunning()
    Holder.Start()
  EndIf
  If Holder == None || OwnFaction == None
    Self.FinishOwnedThrallOperation(BondEpoch, BondTicket)
    Return False
  EndIf
  If BondTicket > 0 && !PSQAppearance.CheckThrallBond(Self, BondEpoch, BondTicket, False)
    Return False
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    If PSQAppearance.ChooseThrall(Holder, Target, Self.GetSuccubusThrallCapacity()) < 0
      Self.FinishOwnedThrallOperation(BondEpoch, BondTicket)
      Return False
    EndIf
    Self.InvalidateNPCEnergyThrallCache()
  Else
    Int Slot = 0
    If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
      Slot = PSQAppearance.InspectThralls(Holder, None, 1)
    Else
      While Slot < 4 && Self.GetSuccubusThrall(Slot) != None
        Slot += 1
      EndWhile
    EndIf
    If Holder == None || OwnFaction == None || Slot >= 4
      Self.FinishOwnedThrallOperation(BondEpoch, BondTicket)
      Return False
    EndIf
    ReferenceAlias Seat = Holder.GetAlias(Slot) as ReferenceAlias
    If Seat == None
      Self.FinishOwnedThrallOperation(BondEpoch, BondTicket)
      Return False
    EndIf
    Seat.ForceRefTo(Target as ObjectReference)
    Self.InvalidateNPCEnergyThrallCache()
    If Seat.GetActorReference() != Target
      Self.FinishOwnedThrallOperation(BondEpoch, BondTicket)
      Return False
    EndIf
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Int MemberSlot = PSQAppearance.InspectThralls(Holder, Target, 2)
    Int PreviousRank = Target.GetRelationshipRank(PlayerRef)
    Int PreviousFaction = Target.GetFactionRank(OwnFaction)
    If BondTicket > 0 && !PSQAppearance.CheckThrallBond(Self, BondEpoch, BondTicket, False)
      Return False
    EndIf
    StorageUtil.SetIntValue(Target, "PSQ_ThrallPreviousRelationship", PreviousRank)
    If BondTicket > 0 && !PSQAppearance.CheckThrallBond(Self, BondEpoch, BondTicket, False)
      Return False
    EndIf
    StorageUtil.SetIntValue(Target, "PSQ_ThrallPreviousFactionRank", PreviousFaction)
    If BondTicket > 0 && !PSQAppearance.CheckThrallBond(Self, BondEpoch, BondTicket, False)
      Return False
    EndIf
    StorageUtil.SetFloatValue(Target, "PSQ_ThrallJoinedDay", GameDaysPassed.GetValue())
    Int ApplyRank = PSQAppearance.ThrallBondAction(Self, Holder, Target, OwnFaction, BondEpoch, False, PreviousRank, PreviousRank, PreviousFaction, BondTicket)
    If ApplyRank < -4
      If PSQLoadEpoch == BondEpoch
        Self.FinishOwnedThrallOperation(BondEpoch, BondTicket)
      EndIf
      Return False
    ElseIf ApplyRank <= 4
      Target.SetRelationshipRank(PlayerRef, ApplyRank)
    EndIf
    If !PSQAppearance.ThrallBondFinish(Self, Holder, Target, BondEpoch, False, MemberSlot, BondTicket)
      If PSQLoadEpoch == BondEpoch
        Self.FinishOwnedThrallOperation(BondEpoch, BondTicket)
      EndIf
      Return False
    EndIf
  Else
    storageutil.SetIntValue(Target as Form, "PSQ_ThrallPreviousRelationship", Target.GetRelationshipRank(PlayerRef))
    storageutil.SetFloatValue(Target as Form, "PSQ_ThrallJoinedDay", GameDaysPassed.GetValue())
    Target.AddToFaction(OwnFaction)
    Target.SetRelationshipRank(PlayerRef, 4)
    Target.StopCombat()
    Target.EvaluatePackage()
  EndIf
  If BondTicket > 0 && !PSQAppearance.CheckThrallBond(Self, BondEpoch, BondTicket, False)
    Return False
  EndIf
  Self.ApplySuccubusThrallTattoo(Target)
  If BondTicket > 0 && !PSQAppearance.CheckThrallBond(Self, BondEpoch, BondTicket, False)
    Return False
  EndIf
  Self.InitializeThrallSkillGrowth(Target)
  If BondTicket > 0 && !PSQAppearance.CheckThrallBond(Self, BondEpoch, BondTicket, False)
    Return False
  EndIf
  Self.StartThrallSkillMonitor(Target)
  Self.FinishOwnedThrallOperation(BondEpoch, BondTicket)
  Debug.Notification("$PSQ_ThrallCreated")
  Return True
EndFunction

Bool Function ReleaseSuccubusThrall(Int Slot)
  Int BondEpoch = PSQLoadEpoch
  Int BondTicket = 0
  Actor Target = Self.GetSuccubusThrall(Slot)
  Int Release = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    BondTicket = PSQAppearance.ReserveThrallBond(Self, Self.GetSuccubusThrallQuest(), PlayerRef, Target, None, 0, True, Slot, BondEpoch)
    Release = BondTicket
  ElseIf SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Release = PSQAppearance.BeginThrallRelease(Self,Self.GetSuccubusThrallQuest(),Slot,Target)
  EndIf
  If Release < 0
    Return False
  ElseIf Release == 0
    If Target == None || ThrallConversionBusy
      Return False
    EndIf
    ThrallConversionBusy = True
  EndIf
  Self.SyncThrallSkillGrowth(Target)
  If BondTicket > 0 && !PSQAppearance.CheckThrallBond(Self, BondEpoch, BondTicket, False)
    Return False
  EndIf
  Self.StopThrallSkillMonitor(Target)
  If BondTicket > 0 && !PSQAppearance.CheckThrallBond(Self, BondEpoch, BondTicket, False)
    Return False
  EndIf
  storageutil.FloatListClear(Target as Form, "PSQ_ThrallSkillBaseline")
  If BondTicket > 0 && !PSQAppearance.CheckThrallBond(Self, BondEpoch, BondTicket, False)
    Return False
  EndIf
  Self.RestoreSuccubusThrallTattoo(Target)
  If BondTicket > 0 && !PSQAppearance.CheckThrallBond(Self, BondEpoch, BondTicket, False)
    Return False
  EndIf
  Self.RestoreSuccubusThrallEyes(Target)
  Faction OwnFaction = Self.GetSuccubusThrallFaction()
  Quest BondHolder = Self.GetSuccubusThrallQuest()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Int Previous = StorageUtil.GetIntValue(Target, "PSQ_ThrallPreviousRelationship", 5)
    Int PreviousFaction = StorageUtil.GetIntValue(Target, "PSQ_ThrallPreviousFactionRank", -1)
    Int ApplyRank = PSQAppearance.ThrallBondAction(Self, BondHolder, Target, OwnFaction, BondEpoch, True, Target.GetRelationshipRank(PlayerRef), Previous, PreviousFaction, BondTicket)
    If ApplyRank < -4
      If PSQLoadEpoch == BondEpoch
        Self.FinishOwnedThrallOperation(BondEpoch, BondTicket)
      EndIf
      Return False
    ElseIf ApplyRank <= 4
      Target.SetRelationshipRank(PlayerRef, ApplyRank)
    EndIf
    If !PSQAppearance.ThrallBondFinish(Self, BondHolder, Target, BondEpoch, True, Slot, BondTicket)
      If PSQLoadEpoch == BondEpoch
        Self.FinishOwnedThrallOperation(BondEpoch, BondTicket)
      EndIf
      Return False
    EndIf
    If BondTicket > 0 && !PSQAppearance.CheckThrallBond(Self, BondEpoch, BondTicket, False)
      Return False
    EndIf
    StorageUtil.UnsetIntValue(Target, "PSQ_ThrallPreviousFactionRank")
  Else
    If OwnFaction != None
      Target.RemoveFromFaction(OwnFaction)
    EndIf
    If Target.GetRelationshipRank(PlayerRef) == 4 && storageutil.HasIntValue(Target as Form, "PSQ_ThrallPreviousRelationship")
      Target.SetRelationshipRank(PlayerRef, storageutil.GetIntValue(Target as Form, "PSQ_ThrallPreviousRelationship", 0))
    EndIf
  EndIf
  If BondTicket > 0 && !PSQAppearance.CheckThrallBond(Self, BondEpoch, BondTicket, False)
    Return False
  EndIf
  storageutil.UnsetIntValue(Target as Form, "PSQ_ThrallPreviousRelationship")
  If BondTicket > 0 && !PSQAppearance.CheckThrallBond(Self, BondEpoch, BondTicket, False)
    Return False
  EndIf
  storageutil.UnsetFloatValue(Target as Form, "PSQ_ThrallJoinedDay")
  Quest Holder = Self.GetSuccubusThrallQuest()
  If Holder != None
    ReferenceAlias Seat = Holder.GetAlias(Slot) as ReferenceAlias
    If Seat != None && Seat.GetActorReference() == Target
      If BondTicket > 0 && !PSQAppearance.CheckThrallBond(Self, BondEpoch, BondTicket, False)
        Return False
      EndIf
      Seat.Clear()
      Self.InvalidateNPCEnergyThrallCache()
    EndIf
  EndIf
  Target.EvaluatePackage()
  Self.FinishOwnedThrallOperation(BondEpoch, BondTicket)
  Return True
EndFunction

Function ReleaseAllSuccubusThralls()
  Int i = 0
  While i < 4
    Self.ReleaseSuccubusThrall(i)
    i += 1
  EndWhile
  Quest Holder = Game.GetFormFromFile(41485, "PSQ PlayerSuccubusQuest.esm") as Quest
  If Holder != None
    Holder.Stop()
  EndIf
EndFunction

Bool Function RecallSuccubusThrall(Int Slot)
  Actor Target = Self.GetSuccubusThrall(Slot)
  Int Recalled = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Recalled = PSQAppearance.RecallRosterActor(Self,Self.GetSuccubusThrallQuest(),Target,Slot)
  EndIf
  If Recalled < 0
    Debug.Notification("$PSQ_ThrallRecallBlocked")
    Return False
  ElseIf Recalled == 0
    If Target == None || Target.IsDead() || Target.IsDisabled() || UninstallPrepared || UninstallCleanupBusy || PlayerRef.IsInCombat() || Target.IsInCombat()
      Debug.Notification("$PSQ_ThrallRecallBlocked")
      Return False
    EndIf
    Target.MoveTo(PlayerRef as ObjectReference, 100.0, 0.0, 0.0, True)
    Target.EvaluatePackage()
  EndIf
  Self.ApplySuccubusThrallEyes(Target)
  Self.ApplySuccubusThrallTattoo(Target)
  Return True
EndFunction

Bool Function CanUseSuccubusThrallEyes()
  Return skse.GetPluginVersion("powerofthree's Papyrus Extender") >= 0 || skse.GetPluginVersion("po3_PapyrusExtender") >= 0
EndFunction

Int Function GetSuccubusThrallEyeSelection(Actor Target)
  If Target == None
    Return 0
  EndIf
  Return storageutil.GetIntValue(Target as Form, "PSQ_ThrallEyeSelection", 0)
EndFunction

Bool Function SetSuccubusThrallEyes(Int Slot, Int Choice)
  Actor Target = Self.GetSuccubusThrall(Slot)
  If Target == None || UninstallPrepared || UninstallCleanupBusy || ThrallConversionBusy || Choice < 0 || Choice > Self.GetSuccubusEyeMaterialCount()
    Return False
  EndIf
  If Choice == 0
    Self.RestoreSuccubusThrallEyes(Target)
    Return True
  EndIf
  If !Self.CanUseSuccubusThrallEyes() || Self.GetExternalEyeTexture(Choice, -1, False) == None
    Debug.Notification("$PSQ_ThrallEyeUnavailable")
    Return False
  EndIf
  storageutil.SetIntValue(Target as Form, "PSQ_ThrallEyeSelection", Choice)
  Self.ApplySuccubusThrallEyes(Target)
  Return True
EndFunction

Function ApplySuccubusThrallEyes(Actor Target)
  If Target == None || !Self.IsSuccubusThrall(Target) || !Target.Is3DLoaded() || UninstallPrepared || UninstallCleanupBusy || !Self.CanUseSuccubusThrallEyes()
    Return
  EndIf
  Int Choice = Self.GetSuccubusThrallEyeSelection(Target)
  TextureSet Selected = Self.GetExternalEyeTexture(Choice, -1, False)
  If Choice < 1 || Selected == None
    Return
  EndIf
  If !storageutil.HasFormValue(Target as Form, "PSQ_ThrallOriginalEyeTexture")
    TextureSet Original = po3_sksefunctions.GetHeadPartTextureSet(Target, 2)
    If Original == None
      Debug.Notification("$PSQ_ThrallEyeOriginalMissing")
      Return
    EndIf
    storageutil.SetFormValue(Target as Form, "PSQ_ThrallOriginalEyeTexture", Original as Form)
  EndIf
  Utility.WaitMenuMode(0.100000001)
  If Self.IsSuccubusThrall(Target) && Target.Is3DLoaded() && Self.GetSuccubusThrallEyeSelection(Target) == Choice && !UninstallPrepared && !UninstallCleanupBusy
    Target.SetEyeTexture(Selected)
  EndIf
EndFunction

Function RestoreSuccubusThrallEyes(Actor Target)
  If Target == None
    Return
  EndIf
  storageutil.UnsetIntValue(Target as Form, "PSQ_ThrallEyeSelection")
  TextureSet Original = storageutil.GetFormValue(Target as Form, "PSQ_ThrallOriginalEyeTexture", None) as TextureSet
  If Original != None && Target.Is3DLoaded()
    Target.SetEyeTexture(Original)
  EndIf
  storageutil.UnsetFormValue(Target as Form, "PSQ_ThrallOriginalEyeTexture")
EndFunction

Function RefreshAllSuccubusThrallEyes()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady() && Self.HasNiOverrideRuntime()
    Form[] Released = StorageUtil.FormListToArray(PlayerRef, "PSQ_ThrallPendingTattooRestores")
    Int Index = 0
    While Released && Index < Released.Length
      Actor Pending = Released[Index] as Actor
      If Pending && Pending.Is3DLoaded() && StorageUtil.GetIntValue(Pending, "PSQ_ThrallTattooDeferred", 0) == 2
        Self.RestoreSuccubusThrallTattoo(Pending)
      EndIf
      Index += 1
    EndWhile
  EndIf
  Int i = 0
  While i < 4
    Actor Member = Self.GetSuccubusThrall(i)
    Self.ApplySuccubusThrallEyes(Member)
    Self.ApplySuccubusThrallTattoo(Member)
    Self.SyncThrallSkillGrowth(Member)
    Self.StartThrallSkillMonitor(Member)
    i += 1
  EndWhile
EndFunction

Function SyncRacialTraitDisplay()
  Int LoadEpoch = PSQLoadEpoch
  If PlayerRef == None || UninstallPrepared || UninstallCleanupBusy || RacialUISyncBusy
    Return
  EndIf
  RacialUISyncBusy = True
  RacialUISyncEpoch += 1
  Int SyncEpoch = RacialUISyncEpoch
  Self.SyncRacialTraitDisplayCore(LoadEpoch, SyncEpoch)
  If Self.IsPSQLoadCurrent(LoadEpoch) && RacialUISyncEpoch == SyncEpoch
    RacialUISyncBusy = False
  EndIf
EndFunction

Bool Function IsRacialUISyncCurrent(Int LoadEpoch, Int SyncEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.RacialUICurrent34(Self, LoadEpoch, SyncEpoch)
  EndIf
  Return Self.IsPSQLoadCurrent(LoadEpoch) && RacialUISyncEpoch == SyncEpoch
EndFunction

Function SyncRacialTraitDisplayCore(Int LoadEpoch, Int SyncEpoch)
  If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
    Return
  EndIf
  Debug.Trace("[PSQ] Racial UI v3 start", 0)
  If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
    Return
  EndIf
  Self.RestoreRacialGameplayVisibility()
  If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
    Return
  EndIf
  Self.RestoreRacialDisplayEffectNames()
  If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
    Return
  EndIf
  MagicEffect[] NaturalEffects = Self.GetNaturalRacialEffects()
  If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
    Return
  EndIf
  String Catalog = "PSQ/RacialTraitDisplay"
  Int Count = jsonutil.IntListCount(Catalog, "display")
  If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
    Return
  EndIf
  Int NativeCount = 0
  Int MarkerCount = 0
  Int MultiCount = 0
  Int i = 0
  While i < Count
    If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
      Return
    EndIf
    String Owner = jsonutil.StringListGet(Catalog, "Owner", i)
    If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
      Return
    EndIf
    Spell Source = None
    Spell Grant = None
    Bool Acquired = False
    If Self.IsIntegrationPluginLoaded(Owner)
      Source = Game.GetFormFromFile(jsonutil.IntListGet(Catalog, "Source", i), Owner) as Spell
      If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
        Return
      EndIf
      String GrantOwner = jsonutil.StringListGet(Catalog, "grant_owner", i)
      If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
        Return
      EndIf
      Grant = Game.GetFormFromFile(jsonutil.IntListGet(Catalog, "Grant", i), GrantOwner) as Spell
      If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
        Return
      EndIf
      Acquired = Source != None && Grant != None && PlayerRef.HasSpell(Grant as Form) && storageutil.FormListHas(PlayerRef as Form, "PSQ_RacialDrainAcquiredTraits", Source as Form)
      If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
        Return
      EndIf
    EndIf
    Spell DisplayAbility = Game.GetFormFromFile(jsonutil.IntListGet(Catalog, "display", i), "PSQ PlayerSuccubusQuest.esm") as Spell
    If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
      Return
    EndIf
    If DisplayAbility != None
      If Acquired
        Int Mode = jsonutil.IntListGet(Catalog, "ui_mode", i)
        If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
          Return
        EndIf
        If Mode == 1 && Grant != DisplayAbility
          String EffectOwner = jsonutil.StringListGet(Catalog, "ui_effect_owner", i)
          If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
            Return
          EndIf
          MagicEffect NativeEffect = Game.GetFormFromFile(jsonutil.IntListGet(Catalog, "ui_effect", i), EffectOwner) as MagicEffect
          If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
            Return
          EndIf
          If NativeEffect != None
            NativeEffect.ClearEffectFlag(32768)
            If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
              Return
            EndIf
            Self.PrefixRacialDisplayEffect(NativeEffect, jsonutil.StringListGet(Catalog, "Name", i), jsonutil.StringListGet(Catalog, "ui_original_name", i))
            If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
              Return
            EndIf
            Self.RemoveRacialDisplayAbility(DisplayAbility)
            If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
              Return
            EndIf
            NativeCount += 1
          Else
            Debug.Trace("[PSQ] Racial UI missing real effect at " + i as String, 1)
            If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
              Return
            EndIf
          EndIf
        Else
          If Mode == 2 && Grant != DisplayAbility
            Int ExtraID = jsonutil.IntListGet(Catalog, "Extra", i)
            If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
              Return
            EndIf
            Spell Extra = None
            If ExtraID != 0
              Extra = Game.GetFormFromFile(ExtraID, Owner) as Spell
              If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
                Return
              EndIf
            EndIf
            Self.HideRacialGameplayEffects(Grant, NaturalEffects)
            If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
              Return
            EndIf
            Self.HideRacialGameplayEffects(Extra, NaturalEffects)
            If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
              Return
            EndIf
            Self.RefreshAuditedRacialAbility(Grant)
            If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
              Return
            EndIf
            If Extra != None
              Self.RefreshAuditedRacialAbility(Extra)
              If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
                Return
              EndIf
            EndIf
            MultiCount += 1
          EndIf
          Self.RemoveRacialDisplayAbility(DisplayAbility)
          If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
            Return
          EndIf
          PlayerRef.AddSpell(DisplayAbility, False)
          If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
            Return
          EndIf
          MarkerCount += 1
        EndIf
      Else
        Self.RemoveRacialDisplayAbility(DisplayAbility)
        If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
          Return
        EndIf
      EndIf
    EndIf
    i += 1
  EndWhile
  Debug.Trace(((("[PSQ] Racial UI v3 complete catalog=" + Count as String) + " real=" + NativeCount as String) + " local=" + MarkerCount as String) + " multi=" + MultiCount as String, 0)
  If !Self.IsRacialUISyncCurrent(LoadEpoch, SyncEpoch)
    Return
  EndIf
EndFunction

Function ClearRacialTraitDisplay()
  StorageUtil.FormListClear(PlayerRef as Form, "PSQ_RacialUIv4Refreshed")
  Int i = 0
  While i < jsonutil.IntListCount("PSQ/RacialTraitDisplay", "display")
    Spell DisplayAbility = Game.GetFormFromFile(jsonutil.IntListGet("PSQ/RacialTraitDisplay", "display", i), "PSQ PlayerSuccubusQuest.esm") as Spell
    If DisplayAbility != None
      PlayerRef.DispelSpell(DisplayAbility)
      If PlayerRef.HasSpell(DisplayAbility as Form)
        PlayerRef.RemoveSpell(DisplayAbility)
      EndIf
    EndIf
    i += 1
  EndWhile
EndFunction

Float Function ReadAppliedPSQSpellMagnitude(Spell Ability, Int Index)
  If Ability == None || PlayerRef == None || !PlayerRef.HasSpell(Ability as Form) || Index < 0 || Index >= Ability.GetNumEffects()
    Return 0.0
  EndIf
  Return Ability.GetNthEffectMagnitude(Index)
EndFunction

Float Function ReadAppliedSatiationMagnitude(Int Index)
  If Index == 6
    Return Self.ReadAppliedPSQSpellMagnitude(Self.GetManagedMovementAbility(), 0)
  EndIf
  Return Self.ReadAppliedPSQSpellMagnitude(SuccubusSatiatySpellA, Index) + Self.ReadAppliedPSQSpellMagnitude(SuccubusSatiatySpellB, Index)
EndFunction

Float Function ReadAppliedPSQShoutReduction()
  Return (Self.ReadAppliedPSQSpellMagnitude(RankShoutAbilityA, 0) + Self.ReadAppliedPSQSpellMagnitude(RankShoutAbilityB, 0)) * 100.0
EndFunction

Float Function ReadAppliedPSQMagicCostReduction()
  Float value = 0.0
  Int i = 1
  While i <= 12
    Int Reduction = Self.GetRankMagicCostPercentByIndex(i)
    Spell Ability = Self.GetRankMagicCostSpell(Reduction)
    If Ability != None && PlayerRef.HasSpell(Ability as Form)
      value += Reduction as Float
    EndIf
    i += 1
  EndWhile
  Return value
EndFunction

Spell Function GetEnergySenseSpell()
  Return Game.GetFormFromFile(41598, "PSQ PlayerSuccubusQuest.esm") as Spell
EndFunction

EffectShader Function GetEnergySenseShader(Int Tier)
  If Tier < 1 || Tier > 3
    Return None
  EndIf
  Return Game.GetFormFromFile(41592 + Tier - 1, "PSQ PlayerSuccubusQuest.esm") as EffectShader
EndFunction

Bool Function IsEnergySenseAllowed()
  Return PlayerRef != None && !UninstallPrepared && !UninstallCleanupBusy && !AppearanceEditBusy && !IsHenshinchu && !AppearanceRecoveryPending && PlayerIsSuccubus.GetValueInt() == 1 && SuccubusRank.GetValueInt() >= 4 && PlayerRef.HasSpell(Self.GetEnergySenseSpell() as Form)
EndFunction

Function SyncEnergySenseSpell()
  Spell Sense = Self.GetEnergySenseSpell()
  If PlayerRef != None && Sense != None
    equipslot VoiceSlot = Game.GetFormFromFile(154606, "Skyrim.esm") as equipslot
    If VoiceSlot != None && Sense.GetEquipType() != VoiceSlot
      Sense.SetEquipType(VoiceSlot)
    EndIf
    Bool InLeft = PlayerRef.GetEquippedSpell(0) == Sense
    Bool InRight = PlayerRef.GetEquippedSpell(1) == Sense
    If !EnergySenseVoiceSlotMigrated || InLeft || InRight
      If InLeft
        PlayerRef.UnequipSpell(Sense, 0)
      EndIf
      If InRight
        PlayerRef.UnequipSpell(Sense, 1)
      EndIf
      If PlayerRef.HasSpell(Sense as Form)
        PlayerRef.RemoveSpell(Sense)
      EndIf
      EnergySenseVoiceSlotMigrated = True
    EndIf
  EndIf
  Int Mode = Self.GetAbilityManagementMode()
  Bool Enabled = PlayerIsSuccubus.GetValueInt() == 1 && SuccubusRank.GetValueInt() >= 4 && !UninstallPrepared && !UninstallCleanupBusy && (Mode == 1 || Mode == 2 && EnableEnergySenseSpell)
  Self.SyncManagedSpell(Self.GetEnergySenseSpell(), Enabled)
  If !Enabled && EnergySenseActive
    Self.StopEnergySense()
  EndIf
EndFunction

Function ToggleEnergySense(Int RequestEpoch)
  Int Epoch = storageutil.GetIntValue(PlayerRef as Form, "PSQ_EnergySenseEpoch", 0)
  If RequestEpoch >= 0 && RequestEpoch != Epoch
    psqenergysenseruntime.ReleaseStart(PlayerRef, RequestEpoch)
    Return
  EndIf
  Float Now = Utility.GetCurrentRealTime()
  If EnergySenseLastToggleTime >= 0.0 && Now >= EnergySenseLastToggleTime && Now - EnergySenseLastToggleTime < 0.400000006
    psqenergysenseruntime.ReleaseStart(PlayerRef, Epoch)
    Return
  EndIf
  EnergySenseLastToggleTime = Now
  If storageutil.GetIntValue(PlayerRef as Form, "PSQ_EnergySenseStopRequested", 0) == 1
    EnergySenseActive = False
  EndIf
  If EnergySenseActive
    Self.StopEnergySense()
    Debug.Notification("$PSQ_EnergySenseOff")
    psqenergysenseruntime.ReleaseStart(PlayerRef, Epoch)
    Return
  EndIf
  If !Self.IsEnergySenseAllowed() || PlayerRef.IsDead()
    Debug.Notification("$PSQ_EnergySenseLocked")
    psqenergysenseruntime.ReleaseStart(PlayerRef, Epoch)
    Return
  EndIf
  Self.PublishEnergySenseConfig()
  Spell Controller = Game.GetFormFromFile(41600, "PSQ PlayerSuccubusQuest.esm") as Spell
  If Controller == None || storageutil.GetIntValue(PlayerRef as Form, "PSQ_EnergySenseEpoch", 0) != Epoch
    psqenergysenseruntime.ReleaseStart(PlayerRef, Epoch)
    Return
  EndIf
  EnergySenseGeneration += 1
  EnergySenseActive = True
  storageutil.SetIntValue(PlayerRef as Form, "PSQ_EnergySenseStopRequested", 0)
  storageutil.SetIntValue(PlayerRef as Form, "PSQ_EnergySenseRuntimeActive", 1)
  If storageutil.GetIntValue(PlayerRef as Form, "PSQ_EnergySenseEpoch", 0) != Epoch
    EnergySenseActive = False
    psqenergysenseruntime.Stop(PlayerRef, False, False)
    psqenergysenseruntime.ReleaseStart(PlayerRef, Epoch)
    Return
  EndIf
  Bool Added = PlayerRef.AddSpell(Controller, False)
  If storageutil.GetIntValue(PlayerRef as Form, "PSQ_EnergySenseEpoch", 0) != Epoch
    If storageutil.GetIntValue(PlayerRef as Form, "PSQ_EnergySenseStopRequested", 0) == 1
      PlayerRef.DispelSpell(Controller)
      PlayerRef.RemoveSpell(Controller)
    EndIf
    psqenergysenseruntime.ReleaseStart(PlayerRef, Epoch)
    Return
  EndIf
  If !Added
    Self.StopEnergySense()
    psqenergysenseruntime.ReleaseStart(PlayerRef, Epoch)
    Return
  EndIf
  psqenergysenseruntime.ReleaseStart(PlayerRef, Epoch)
  Debug.Trace("[PSQ-SENSE] enabled; epoch=" + Epoch as String, 0)
  Debug.Notification("$PSQ_EnergySenseOn")
EndFunction

Function StopEnergySenseTarget(Actor Target)
  Return
EndFunction

Bool Function RegisterEnergySenseTarget(Actor Target, Int Generation)
  Return False
EndFunction

Function StopEnergySense()
  EnergySenseActive = False
  EnergySenseGeneration += 1
  EnergySenseRegistrationBusy = False
  psqenergysenseruntime.Stop(PlayerRef, False, False)
EndFunction

Int Function GetEnergySenseTier(Actor Target)
  If storageutil.GetIntValue(PlayerRef as Form, "PSQ_EnergySenseStopRequested", 0) == 1
    Return 0
  EndIf
  Float[] Snapshot = Self.GetNPCEnergySnapshot(Target)
  Float Energy = Snapshot[0]
  Float Capacity = Snapshot[1]
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777229
    Return PSQAppearance.SenseTier(Energy, Capacity)
  EndIf
  If Capacity <= 0.0 || Energy < 200.0 || Energy / Capacity < 0.5
    Return 0
  EndIf
  If Energy / Capacity >= 0.800000012
    If Energy >= 2000.0
      Return 3
    ElseIf Energy >= 640.0
      Return 2
    EndIf
  EndIf
  Return 1
EndFunction

Function RefreshNPCEnergyThrallCache()
  Int Revision = NPCEnergyThrallCacheRevision
  Actor[] Members = new Actor[4]
  Quest Holder = Self.GetSuccubusThrallQuest()
  If Holder != None
    Int i = 0
    While i < 4
      ReferenceAlias Seat = Holder.GetAlias(i) as ReferenceAlias
      If Seat != None
        Members[i] = Seat.GetActorReference()
      EndIf
      i += 1
    EndWhile
  EndIf
  If Revision == NPCEnergyThrallCacheRevision
    NPCEnergyThrallCache = Members
    NPCEnergyThrallCachePublishedRevision = Revision
    NPCEnergyThrallCacheReady = True
  EndIf
EndFunction

Function InvalidateNPCEnergyThrallCache()
  NPCEnergyThrallCacheRevision += 1
  NPCEnergyThrallCacheReady = False
  If PlayerRef != None
    storageutil.AdjustIntValue(PlayerRef as Form, "PSQ_SenseThrallRevision", 1)
  EndIf
EndFunction

Bool Function CanUseAnimatedDragonWings()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    Return PSQAppearance.HasDragonWingAssets33()
  EndIf
  Return miscutil.FileExists("Data/meshes/[Anton] mods/Animated Dragon Wings/AnimatedDragonWings.nif") && miscutil.FileExists("Data/textures/[Anton] mods/Animated Dragon Wings/Dragon.dds")
EndFunction

Bool Function CanUseAnimatedFairyWings()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    Return PSQAppearance.HasFairyWingAssets33()
  EndIf
  Return Self.IsIntegrationPluginLoaded("Animated Fairy Wings.esp") && miscutil.FileExists("Data/meshes/[Anton] mods/Animated Fairy Wings/AnimatedFairyWings.nif")
EndFunction

Function ResolveOptionalWingSelection()
  If AWUWingID > 0
    PSQSuccubusWings = None
    If Self.GetAWUWing(AWUWingID) == None
      AWUWingID = 0
      HenshinWings = False
    EndIf
    Self.SyncAWUWing()
    Return
  EndIf
  If Self.IsWingflightAirborne()
    Return
  EndIf
  If !HenshinWings
    Return
  EndIf
  Armor Selected = PSQSuccubusWings
  Armor Retired = Game.GetFormFromFile(3702, "PSQ PlayerSuccubusQuest.esm") as Armor
  Bool Available = Selected != None && Selected != Retired
  If Selected == SuccubusFairyWings
    Available = Self.CanUseAnimatedFairyWings()
  ElseIf Selected == SuccubusDragonWingsCommon || Selected == SuccubusDragonWingsBoss || Selected == SuccubusDragonWingsForest || Selected == SuccubusDragonWingOdaviing || Selected == SuccubusDragonWingsParthurnax || Selected == SuccubusDragonWingsSnow || Selected == SuccubusDragonWingsTundra || Selected == SuccubusDragonWingsUnderskin || Selected == SuccubusDragonWingsAlduin || Selected == SuccubusDragonWingsBloody
    Available = Self.CanUseAnimatedDragonWings()
  EndIf
  If Available
    Return
  EndIf
  Armor OutfitWing = Self.GetOutfitWings(-1)
  If Selected == OutfitWing
    Return
  EndIf
  PSQSuccubusWings = OutfitWing
  If IsHenshined && PlayerRef != None
    Self.RemoveTransformEquipmentItem(Selected, -1, False)
    Self.EnsurePlayerTransformEquipment(OutfitWing, -1, False)
  EndIf
  If OutfitWing == None
    HenshinWings = False
  EndIf
EndFunction

Int Function GetRankMagicCostPercentByIndex(Int Index)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.Percent34(Index)
  EndIf
  If Index <= 3
    Return Index * 20
  ElseIf Index <= 7
    Return 60 + (Index - 3) * 10
  ElseIf Index == 8
    Return 10
  ElseIf Index == 9
    Return 30
  ElseIf Index == 10
    Return 35
  ElseIf Index == 11
    Return 45
  ElseIf Index == 12
    Return 50
  EndIf
  Return 0
EndFunction

Bool Function CanUseGTSoftbody()
  If !GTSoftbodyCacheReady
    GTSoftbodyCacheAvailable = False
    If Self.IsIntegrationPluginLoaded("HDT SMP Object - Simple.esp")
      GTSoftbodyCacheAvailable = (Game.GetFormFromFile(2053, "HDT SMP Object - Simple.esp") as Armor != None) && (Game.GetFormFromFile(2080, "HDT SMP Object - Simple.esp") as Armor != None)
    EndIf
    GTSoftbodyCacheReady = True
  EndIf
  Return GTSoftbodyCacheAvailable
EndFunction

Bool Function IsGTSoftbodyAuxiliary(Form Item)
  If Item == None || !Self.CanUseGTSoftbody()
    Return False
  EndIf
  Int LocalID = Math.LogicalAnd(Item.GetFormID(), 4095)
  If LocalID == 2053 || LocalID == 2080 || LocalID >= 2058 && LocalID <= 2063
    Return Item == Game.GetFormFromFile(LocalID, "HDT SMP Object - Simple.esp")
  EndIf
  Return False
EndFunction

Bool Function IsGTSoftbodySpecialBody(Form Item)
  If Item == None || !Self.CanUseGTSoftbody()
    Return False
  EndIf
  Int LocalID = Math.LogicalAnd(Item.GetFormID(), 4095)
  If LocalID == 2074 || LocalID == 2103
    Return Item == Game.GetFormFromFile(LocalID, "HDT SMP Object - Simple.esp")
  EndIf
  Return False
EndFunction

Bool Function GTSoftbodyOwnsAppearance()
  If PlayerRef == None || !Self.CanUseGTSoftbody()
    Return False
  EndIf
  Return PlayerRef.HasKeywordString("SexLabActive") || Self.IsGTSoftbodySpecialBody(PlayerRef.GetWornForm(4))
EndFunction

Armor Function GetOutfitWings(Int Selection)
  If Selection == -1
    Selection = SuccubusOutfitSelection
  EndIf
  If Selection == 100
    Return Self.GetCachedOutfitPart(100, 5, -1, False)
  EndIf
  If Selection < 1 || Selection > 8
    Selection = 4
  EndIf
  Return Self.GetCachedOutfitPart(Selection, 5, -1, False)
EndFunction

Bool Function IsOutfitWing(Armor Wing)
  If Wing == None
    Return False
  EndIf
  If Wing == SuccubusStaticWings
    Return True
  EndIf
  If Wing == Self.GetOutfitWings(100)
    Return True
  EndIf
  Int Index = 1
  While Index <= 8
    If Wing == Self.GetOutfitWings(Index)
      Return True
    EndIf
    Index += 1
  EndWhile
  Return False
EndFunction

Bool Function SaveTransformEquipment(Int Owner, Bool RequireBusy)
  Return Self.SaveEntryOutfitSnapshot(Owner, RequireBusy, None)
EndFunction

Bool Function SaveEntryOutfitSnapshot(Int Owner, Bool RequireBusy, Bool[] Refusal)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777238 && PSQAppearance.IsReady()
    If Owner < 0
      Owner = AppearanceOperationId
      RequireBusy = AppearanceEditBusy
    EndIf
    Int Result = Self.RunAppearanceTask(None,Owner,PSQLoadEpoch,RequireBusy || AppearanceEditBusy,1,False,0.0)
    If Result == 0 && Refusal && Refusal.Length > 0
      Refusal[0] = True
    EndIf
    Return Result == 1
  EndIf
  Form[] Worn
  Bool Detailed = EnableEquipmentDiagnostics
  Float Started
  Float AfterTail
  Float AfterLedger
  Float AfterRecovery
  Float BeforeNative
  Float AfterNative
  Float BeforeLegacy
  Float AfterPrimarySlots
  Float BeforeWornRead
  Float AfterWornRead
  Float BeforePlan
  Float Finished
  String Route = "native"
  String Fallback = "none"
  Bool HadWornList = False
  Int SlotReads = 0
  If Detailed
    Started = Utility.GetCurrentRealTime()
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  Int TailLoad = PSQLoadEpoch
  Armor DiscardedTail = Self.CleanOriginalTransformTail(Owner, RequireBusy, TailLoad)
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, TailLoad)
    Return False
  EndIf
  If DiscardedTail != None && PlayerRef.IsEquipped(DiscardedTail)
    If Refusal
      Refusal[0] = True
    EndIf
    Debug.Notification("$PSQ_EquipmentRecoveryPending")
    Return False
  EndIf
  If Detailed
    AfterTail = Utility.GetCurrentRealTime()
  EndIf
  Self.CleanupTransformEquipmentLedger(Owner, RequireBusy)
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  Self.InitializeTransformEquipmentLedger(Owner, RequireBusy)
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  If Detailed
    AfterLedger = Utility.GetCurrentRealTime()
  EndIf
  ; Preserve a prior incomplete exit before taking the next outfit snapshot.
  Form[] PreviousSnapshot = OrgArmorList.ToArray()
  If PreviousSnapshot.Length > 0 || (TransformEquipmentRecoveryItems && TransformEquipmentRecoveryItems.Length > 0)
    If !Self.CommitPendingOriginalEquipment(PreviousSnapshot, PreviousSnapshot.Length, Self.GetTransformProtectedArmor(), Owner, RequireBusy)
      If Refusal
        Refusal[0] = True
      EndIf
      Debug.Notification("$PSQ_EquipmentRecoveryPending")
      Return False
    EndIf
  ElseIf !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, TailLoad)
    Return False
  EndIf
  OrgArmorList.Revert()
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  If Detailed
    AfterRecovery = Utility.GetCurrentRealTime()
  EndIf
  Form[] Protected
  Int HelperVersion = SKSE.GetPluginVersion("PSQ Appearance")
  If HelperVersion >= 16777220
    Protected = Self.GetTransformProtectedArmor()
    If Self.CanUseSuccubusThrallEyes()
      Worn = po3_sksefunctions.AddAllEquippedItemsToArray(PlayerRef)
    EndIf
    If Detailed
      BeforeNative = Utility.GetCurrentRealTime()
    EndIf
    Form[] NativeSnapshot
    If HelperVersion >= 16777225
      NativeSnapshot = PSQAppearance.ReadTransformSnapshot(PlayerRef, Worn, Protected, DiscardedTail)
      If NativeSnapshot && NativeSnapshot.Length >= 7
        ; Actor sentinel is returned only for an ambiguous primary slot.
        Int iSlot = 0
        While iSlot < 7
          If NativeSnapshot[iSlot] == PlayerRef
            Int mask = 128
            If iSlot == 1
              mask = 4
            ElseIf iSlot == 2
              mask = 8
            ElseIf iSlot == 3
              mask = 16384
            ElseIf iSlot == 4
              mask = 32768
            ElseIf iSlot == 5
              mask = 1024
            ElseIf iSlot == 6
              mask = 4194304
            EndIf
            NativeSnapshot[iSlot] = PlayerRef.GetWornForm(mask)
          EndIf
          iSlot += 1
        EndWhile
      EndIf
    Else
      NativeSnapshot = PSQAppearance.ReadOutfitSnapshot(PlayerRef, Worn, Protected, DiscardedTail)
    EndIf
    If Detailed
      AfterNative = Utility.GetCurrentRealTime()
    EndIf
    If NativeSnapshot && NativeSnapshot.Length >= 7
      Armor NativeTail = NativeSnapshot[5] as Armor
      Bool TemporaryTail = Self.IsPSQTransformTail(NativeTail)
      Bool Save52 = HenshinPenis || storageutil.GetIntValue(PlayerRef as Form, "PSQ_HasPenis", 0) == 1
      Form[] Originals = Utility.CreateFormArray(0)
      If NativeSnapshot.Length > 7
        Originals = PapyrusUtil.SliceFormArray(NativeSnapshot, 7)
        If TemporaryTail
          Originals = PapyrusUtil.RemoveForm(Originals, NativeTail)
        EndIf
      EndIf
      If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, TailLoad)
        Return False
      EndIf
      ; Commit the original slot fields together, before publishing the plan.
      OrgBoots = None
      OrgArmor = None
      OrgGloves = None
      OrgHorns = None
      OrgWings = None
      OrgTail = None
      OrgSlot52 = None
      If HenshinBoots
        OrgBoots = NativeSnapshot[0] as Armor
      EndIf
      If HenshinCuirass
        OrgArmor = NativeSnapshot[1] as Armor
      EndIf
      If HenshinGloves
        OrgGloves = NativeSnapshot[2] as Armor
      EndIf
      If HenshinHorn
        OrgHorns = NativeSnapshot[3] as Armor
      EndIf
      If HenshinWings
        OrgWings = NativeSnapshot[4] as Armor
      EndIf
      If HenshinTail && !TemporaryTail
        OrgTail = NativeTail
      EndIf
      If Save52
        OrgSlot52 = NativeSnapshot[6] as Armor
      EndIf
      If Originals.Length > 0
        OrgArmorList.AddForms(Originals)
      EndIf
      If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, TailLoad)
        Return False
      EndIf
      If Detailed
        Debug.Trace("[PSQ-EQUIP] native snapshot; originals=" + Originals.Length + "; seconds=" + (Utility.GetCurrentRealTime() - AfterRecovery))
      EndIf
    Else
      Fallback = "native-returned-no-valid-header"
    EndIf
  Else
    Fallback = "helper-version-unavailable"
  EndIf
  If Fallback != "none"
    If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, TailLoad)
      Return False
    EndIf
    If Detailed
      BeforeLegacy = Utility.GetCurrentRealTime()
    EndIf
    OrgBoots = None
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return False
    EndIf
    OrgArmor = None
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return False
    EndIf
    OrgGloves = None
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return False
    EndIf
    OrgHorns = None
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return False
    EndIf
    OrgWings = None
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return False
    EndIf
    OrgTail = None
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return False
    EndIf
    OrgSlot52 = None
    If HenshinBoots
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      OrgBoots = PlayerRef.GetWornForm(128) as Armor
    EndIf
    If HenshinCuirass
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      OrgArmor = PlayerRef.GetWornForm(4) as Armor
    EndIf
    If HenshinGloves
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      OrgGloves = PlayerRef.GetWornForm(8) as Armor
    EndIf
    If HenshinHorn
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      OrgHorns = PlayerRef.GetWornForm(16384) as Armor
    EndIf
    If HenshinWings
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      OrgWings = PlayerRef.GetWornForm(32768) as Armor
    EndIf
    Armor CapturedTail = PlayerRef.GetWornForm(1024) as Armor
    Bool CapturedTemporaryTail = Self.IsPSQTransformTail(CapturedTail)
    If HenshinTail && !CapturedTemporaryTail
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      OrgTail = CapturedTail
    EndIf
    If HenshinPenis || storageutil.GetIntValue(PlayerRef as Form, "PSQ_HasPenis", 0) == 1
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      OrgSlot52 = PlayerRef.GetWornForm(4194304) as Armor
    EndIf
    If Detailed
      AfterPrimarySlots = Utility.GetCurrentRealTime()
    EndIf
    Protected = Self.GetTransformProtectedArmor()
    ; Reuse the enumeration from this snapshot when native slot resolution declined it.
    If Detailed
      BeforeWornRead = Utility.GetCurrentRealTime()
    EndIf
    HadWornList = Worn && Worn.Length > 0
    If !HadWornList && Self.CanUseSuccubusThrallEyes()
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      Worn = po3_sksefunctions.AddAllEquippedItemsToArray(PlayerRef)
    EndIf
    Route = "extender-list"
    If !Worn || Worn.Length == 0
      Route = "papyrus-slot-scan"
      SlotReads = 32
      Worn = new Form[32]
      Int Slot = 0
      While Slot < 32
        If Owner != AppearanceOperationId
          Return False
        EndIf
        Worn[Slot] = PlayerRef.GetWornForm(Math.LeftShift(1, Slot))
        Slot += 1
      EndWhile
    EndIf
    If Detailed
      AfterWornRead = Utility.GetCurrentRealTime()
    EndIf
    Int Count = 0
    Int Entry = 0
    While Entry < Worn.Length
      Armor Item = Worn[Entry] as Armor
      If Item != None && Item != DiscardedTail && (!CapturedTemporaryTail || Item != CapturedTail) && Protected.find(Item as Form, 0) < 0 && Worn.find(Item as Form, 0) == Entry
        Count += 1
      Else
        Worn[Entry] = None
      EndIf
      Entry += 1
    EndWhile
    If Count > 0
      ; The native list is often already unique and all armor. Use it
      ; directly when the preceding filter accepted every entry.
      Form[] Snapshot = Worn
      If Count != Worn.Length
        Snapshot = Utility.CreateFormArray(Count, None)
        Entry = 0
        Int Destination = 0
        While Entry < Worn.Length
          If Worn[Entry] != None
            Snapshot[Destination] = Worn[Entry]
            Destination += 1
          EndIf
          Entry += 1
        EndWhile
      EndIf
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      OrgArmorList.AddForms(Snapshot)
    EndIf
  EndIf
  If Detailed
    BeforePlan = Utility.GetCurrentRealTime()
  EndIf
  Form[] Recorded = OrgArmorList.ToArray()
  If HelperVersion >= 16777231
    String[] Captured = PSQAppearance.CaptureOriginalCopies(PlayerRef, Self, PlayerAppearanceRace, Owner, TailLoad, RequireBusy, Recorded)
    If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, TailLoad)
      Return False
    EndIf
    If Recorded && Recorded.Length > 0 && (!Captured || Captured.Length != Recorded.Length)
      Return False
    EndIf
    ; Carry forward unresolved receipts even if this outfit uses different forms.
    Int j = 0
    While OriginalCopyForms && j < OriginalCopyForms.Length
      Form Old = OriginalCopyForms[j]
      If Old && OriginalCopyKeys[j] != "" && TransformEquipmentRecoveryItems && TransformEquipmentRecoveryItems.Find(Old) >= 0
        Int Pos = Recorded.Find(Old)
        If Pos < 0
          Recorded = PapyrusUtil.PushForm(Recorded, Old)
          Captured = PapyrusUtil.PushString(Captured, OriginalCopyKeys[j])
        ElseIf Captured[Pos] != "" && Captured[Pos] != OriginalCopyKeys[j]
          If Refusal
            Refusal[0] = True
          EndIf
          Debug.Notification("$PSQ_EquipmentRecoveryPending")
          Return False
        ElseIf Captured[Pos] == ""
          Captured[Pos] = OriginalCopyKeys[j]
        EndIf
      EndIf
      j += 1
    EndWhile
    If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, TailLoad)
      Return False
    EndIf
    OriginalCopyForms = Recorded
    OriginalCopyKeys = Captured
    HasOriginalCopyKeys = False
    j = 0
    While Captured && j < Captured.Length && !HasOriginalCopyKeys
      HasOriginalCopyKeys = Captured[j] != ""
      j += 1
    EndWhile
  EndIf
  Bool Planned = Self.BuildEquipmentSwapPlan28(OrgArmorList.ToArray(), Protected, Owner, RequireBusy)
  If Detailed
    Finished = Utility.GetCurrentRealTime()
    Debug.Trace("[PSQ-PERF] entry.snapshot; owner=" + Owner + "; route=" + Route + "; fallback=" + Fallback + "; fullScanSlots=" + SlotReads + "; reusedWornList=" + HadWornList + "; planned=" + Planned)
    Debug.Trace("[PSQ-PERF] entry.snapshot_times; owner=" + Owner + "; tailAndGuards=" + (AfterTail - Started) + "; ledger=" + (AfterLedger - AfterTail) + "; priorRecovery=" + (AfterRecovery - AfterLedger) + "; readAndRecord=" + (BeforePlan - AfterRecovery) + "; fullPlan=" + (Finished - BeforePlan))
    If HelperVersion >= 16777220
      Debug.Trace("[PSQ-PERF] entry.snapshot_native; owner=" + Owner + "; prepare=" + (BeforeNative - AfterRecovery) + "; query=" + (AfterNative - BeforeNative))
    EndIf
    If Route != "native"
      Debug.Trace("[PSQ-PERF] entry.snapshot_fallback; owner=" + Owner + "; primarySlots=" + (AfterPrimarySlots - BeforeLegacy) + "; protection=" + (BeforeWornRead - AfterPrimarySlots) + "; wornRead=" + (AfterWornRead - BeforeWornRead) + "; filterAndSave=" + (BeforePlan - AfterWornRead))
    EndIf
  EndIf
  Return Planned
EndFunction

Function StripTransformAccessories(Int Owner, Bool RequireBusy)
  Self.SyncPlayerAppearanceRace()
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  If !Self.IsEquipmentSwapPlanCurrent(Owner, RequireBusy)
    If !Self.BuildEquipmentSwapPlan28(OrgArmorList.ToArray(), Self.GetTransformProtectedArmor(), Owner, RequireBusy)
      Return
    EndIf
  EndIf
  Bool HideAccessories = Self.GetOriginalEquipmentHideEnabled() && Self.HasPSQAppearanceAPI()
  ; A setting/API change must rebuild the plan before any removal.
  If storageutil.GetIntValue(Self, "PSQ_EquipPlanHide", -1) != (HideAccessories as Int)
    If !Self.BuildEquipmentSwapPlan28(OrgArmorList.ToArray(), Self.GetTransformProtectedArmor(), Owner, RequireBusy)
      Return
    EndIf
  EndIf
  HideAccessories = storageutil.GetIntValue(Self, "PSQ_EquipPlanHide", 0) == 1
  Float PhaseStarted
  If EnableEquipmentDiagnostics
    PhaseStarted = Utility.GetCurrentRealTime()
  EndIf
  Form[] Strip
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777247 && PSQAppearance.ReadPlanState31(PlayerRef,Self,Owner,PSQLoadEpoch,RequireBusy) >= 0
    Strip = PSQAppearance.ReadPlan31(PlayerRef,Self,Owner,PSQLoadEpoch,RequireBusy,True)
  Else
    Strip = storageutil.FormListToArray(Self, "PSQ_EquipPlanStrip")
  EndIf
  Int i = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777237
    Int Stripped = PSQAppearance.StripBatch(PlayerRef,Self,PlayerAppearanceRace,Owner,PSQLoadEpoch,RequireBusy,HideAccessories,Strip)
    If Stripped < 0
      Return
    ElseIf Stripped > 0
      i = Strip.Length
    EndIf
  EndIf
  While i < Strip.Length
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    Armor Item = Strip[i] as Armor
    If Item != None && PlayerRef.IsEquipped(Item) && (!HideAccessories || Math.LogicalAnd(Item.GetSlotMask(), 6287) != 0)
      Float Started = 0.0
      If EnableEquipmentDiagnostics
        Started = Utility.GetCurrentRealTime()
      EndIf
      PlayerRef.UnequipItem(Item, False, True)
      If EnableEquipmentDiagnostics
        Debug.Trace("[PSQ-EQUIP] strip; item=" + Item + "; seconds=" + (Utility.GetCurrentRealTime() - Started))
      EndIf
    EndIf
    i += 1
  EndWhile
  If Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Self.ApplyOriginalEquipmentVisibility()
    If EnableEquipmentDiagnostics
      Debug.Trace("[PSQ-PERF] entry.strip; candidates=" + Strip.Length + "; seconds=" + (Utility.GetCurrentRealTime() - PhaseStarted))
    EndIf
  EndIf
EndFunction

Function RemoveTransformEquipmentItem(Armor Item, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  If Item == None || OrgArmorList.HasForm(Item as Form)
    Return
  EndIf
  Int Index = -1
  If TransformInventoryLedgerReady
    Index = TransformInventoryItems.find(Item as Form, 0)
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.ReleaseTransformEquipmentEntry(Item, Index, Owner, RequireBusy)
EndFunction

Function RestoreTransformEquipmentItem(Armor Item, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  If Item == None || PlayerRef.IsEquipped(Item as Form)
    Return
  EndIf
  Form[] Protected = Self.GetTransformProtectedArmor()
  If Protected.find(Item as Form, 0) >= 0 || PlayerRef.GetItemCount(Item as Form) <= 0
    Return
  EndIf
  Float Started = 0.0
  If EnableEquipmentDiagnostics
    Started = Utility.GetCurrentRealTime()
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  PlayerRef.EquipItemEx(Item as Form, 0, False, True)
  If EnableEquipmentDiagnostics
    Debug.Trace((("[PSQ-EQUIP] restore; item=" + Item as String) + "; slotMask=" + Item.GetSlotMask() as String) + "; seconds=" + (Utility.GetCurrentRealTime() - Started) as String, 0)
  EndIf
EndFunction

Function RestoreTransformEquipment(Int Owner, Bool RequireBusy)
  Bool Detailed = EnableEquipmentDiagnostics
  Float CleanupStart
  Float Prepared
  Float AfterSelected
  Float AfterLedger
  If Detailed
    CleanupStart = Utility.GetCurrentRealTime()
  EndIf
  Self.SyncPlayerAppearanceRace()
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  Int RecoveryLoad = PSQLoadEpoch
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777240
    Self.RunAppearanceTask(None,Owner,RecoveryLoad,RequireBusy,6,False,0.0)
    Return
  EndIf
  Self.CleanTransformTailForRestore(Owner, RequireBusy, RecoveryLoad, True)
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
    Return
  EndIf
  Float Started
  If EnableEquipmentDiagnostics
    Started = Utility.GetCurrentRealTime()
  EndIf
  If Detailed
    Prepared = Utility.GetCurrentRealTime()
  EndIf
  Form[] Snapshot = OrgArmorList.ToArray()
  Form[] Protected = Self.GetTransformProtectedArmor()
  Armor[] primary = new Armor[6]
  primary[0] = OrgArmor
  primary[1] = OrgGloves
  primary[2] = OrgBoots
  primary[3] = OrgHorns
  primary[4] = OrgWings
  primary[5] = OrgTail
  Form[] Plan
  Form[] LedgerOriginals
  Int Used
  Int MainCount
  Int Index
  Int ExtraCount
  Bool Planned = False
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777226
    Form[] Packed = PSQAppearance.PlanOriginalRestore(primary, Snapshot, Protected)
    If Packed && Packed.Length >= 2
      Used = Packed.Find(None)
      If Used >= 0 && Used + 2 <= Packed.Length
        MainCount = Used
        If Packed[Used+1] != None
          MainCount = Packed.Find(Packed[Used+1])
        EndIf
        If Used > 0
          Plan = PapyrusUtil.SliceFormArray(Packed, 0, Used - 1)
        Else
          Plan = Utility.CreateFormArray(1)
        EndIf
        ExtraCount = Packed.Length - Used - 2
        Planned = Plan && Plan.Length >= Used && MainCount >= 0 && MainCount <= Used
        If Planned && ExtraCount > 0
          Form[] MissingPrimary = PapyrusUtil.SliceFormArray(Packed, Used + 2)
          If !MissingPrimary || MissingPrimary.Length != ExtraCount || !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
            Return
          EndIf
          OrgArmorList.AddForms(MissingPrimary)
        EndIf
        LedgerOriginals = Plan
      EndIf
    EndIf
  EndIf
  If !Planned
    Plan = Utility.CreateFormArray(Snapshot.Length + 6, None)
    If !Plan || Plan.Length != Snapshot.Length + 6
      Return
    EndIf
    LedgerOriginals = Plan
    Used = 0
    MainCount = 0
    Index = 0
    ExtraCount = 0
    While Index < 6
      Armor Item = primary[Index]
      If Item != None && Plan.find(Item as Form, 0) < 0
        ; Partition during the existing build pass. Only body/hands/feet are
        ; main equipment; a stale or absent legacy field cannot hide that fact.
        If Math.LogicalAnd(Item.GetSlotMask(), 140) != 0
          Plan[Used] = Plan[MainCount]
          Plan[MainCount] = Item as Form
          MainCount += 1
        Else
          Plan[Used] = Item as Form
        EndIf
        Used += 1
        If Snapshot.find(Item as Form, 0) < 0
          ExtraCount += 1
        EndIf
      EndIf
      Index += 1
    EndWhile
    Index = 0
    While Index < Snapshot.Length
      Form item = Snapshot[Index]
      If item != None && Plan.find(item, 0) < 0
        Armor SnapshotArmor = item as Armor
        Int Mask = 0
        If SnapshotArmor != None
          ; Keep only body/hands/feet (140) and tail (1024). The mask is
          ; nonnegative even for armor using slot 61.
          Mask = Math.LogicalAnd(SnapshotArmor.GetSlotMask(), 1164)
        EndIf
        Bool TemporaryTail = Mask >= 1024 && Self.IsPSQTransformTail(SnapshotArmor) && Protected.Find(item) < 0
        If TemporaryTail
          LedgerOriginals = None
          Self.RemoveOriginalTransformTail(SnapshotArmor, Protected, Owner, RequireBusy, RecoveryLoad)
        Else
          If Mask % 1024 != 0
            Plan[Used] = Plan[MainCount]
            Plan[MainCount] = item
            MainCount += 1
          Else
            Plan[Used] = item
          EndIf
          Used += 1
        EndIf
      EndIf
      Index += 1
    EndWhile
    If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
      Return
    EndIf
    If ExtraCount > 0
      Form[] Extras = Utility.CreateFormArray(ExtraCount, None)
      If !Extras || Extras.Length != ExtraCount
        Return
      EndIf
      Index = 0
      Int Destination = 0
      While Index < 6
        Armor item = primary[Index]
        If item != None && primary.find(item, 0) == Index && Snapshot.find(item as Form, 0) < 0
          Extras[Destination] = item as Form
          Destination += 1
        EndIf
        Index += 1
      EndWhile
      If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
        Return
      EndIf
      OrgArmorList.AddForms(Extras)
    EndIf
  EndIf
  If Detailed
    Debug.Trace("[PSQ-PERF] recovery.plan_native; native=" + Planned + "; originals=" + Used + "; main=" + MainCount)
  EndIf
  Armor[] Selected = new Armor[6]
  Selected[0] = PSQSuccubusBoots
  Selected[1] = PSQSuccubusCuirass
  Selected[2] = PSQSuccubusGauntlets
  Selected[3] = PSQSuccubusHorns
  Selected[4] = PSQSuccubusWings
  Selected[5] = PSQSuccubusTail
  ; Allocate before releasing temporary equipment. The authoritative original
  ; FormList remains intact until failed originals have been persisted below.
  Bool NativeRetry = SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
  Form[] Retry
  If !NativeRetry
    Retry = Utility.CreateFormArray(Plan.Length, None)
    If !Retry || Retry.Length != Plan.Length
      Return
    EndIf
  EndIf
  Int RetryCount = 0
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
    Return
  EndIf
  ; Release only the same PSQ selected/ledger entries as the former second
  ; phase. Original same-FormID items are excluded through Plan/OrgArmorList.
  If EnableEquipmentDiagnostics
    Started = Utility.GetCurrentRealTime()
  EndIf
  ; The plan covers the saved originals and the primary fields added above.
  ; Releases during plan construction or here can run callbacks; re-read originals then.
  Index = 0
  While Index < 6
    If RecoveryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
      Return
    EndIf
    Armor item = Selected[Index]
    If item != None && Selected.find(item, 0) == Index && Plan.find(item as Form, 0) < 0 && Protected.find(item as Form, 0) < 0
      If !TransformInventoryLedgerReady || TransformInventoryItems.find(item as Form, 0) < 0
        LedgerOriginals = None
        Self.ReleaseLedgerItemForLoad(item, -1, Owner, RequireBusy, RecoveryLoad)
      EndIf
    EndIf
    Index += 1
  EndWhile
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
    Return
  EndIf
  If Detailed
    AfterSelected = Utility.GetCurrentRealTime()
  EndIf
  Self.CleanupTransformLedgerForLoad(Owner, RequireBusy, RecoveryLoad, LedgerOriginals)
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
    Return
  EndIf
  If Detailed
    AfterLedger = Utility.GetCurrentRealTime()
  EndIf
  If EnableEquipmentDiagnostics
    Debug.Trace("[PSQ-PERF] recovery.release; seconds=" + (Utility.GetCurrentRealTime() - Started) as String, 0)
  EndIf
  If Detailed
    Debug.Trace("[PSQ-PERF] recovery.cleanup_times; owner=" + Owner + "; raceTailGuards=" + (Prepared - CleanupStart) + "; buildPlan=" + (Started - Prepared) + "; selectedRelease=" + (AfterSelected - Started) + "; ledgerCleanup=" + (AfterLedger - AfterSelected))
  EndIf
  ; Main equipment is an explicit phase. Its bounded retry must finish
  ; before hidden accessories are revealed or any stripped extra is equipped.
  ; The same plan/retry arrays are reused; already-worn items never equip.
  Int TotalRetryCount = 0
  Bool MainPending = False
  If NativeRetry
    Int Result = Self.RunNativeEquipmentRestore27(Plan, MainCount, Used, Protected, Owner, RequireBusy, RecoveryLoad, False)
    If Result < 0
      Return
    EndIf
    MainPending = Result == 4
  Else
    Int Phase = 0
    Int PhaseStart = 0
    Int PhaseEnd = MainCount
    Armor[] Awaiting
    Form[] Submitted
    Bool BatchMain = MainCount > 0 && MainCount <= 128 && SKSE.GetPluginVersion("PSQ Appearance") >= 16777224
    If BatchMain
      Submitted = Utility.CreateFormArray(MainCount, None)
      BatchMain = Submitted && Submitted.Length == MainCount
    EndIf
    If BatchMain || (MainCount > 1 && SKSE.GetPluginVersion("PSQ Appearance") >= 16777223)
      Awaiting = new Armor[1]
    EndIf
    While Phase < 2
      If EnableEquipmentDiagnostics
        Started = Utility.GetCurrentRealTime()
      EndIf
      Bool HasFailure = False
      Int PhaseStatus = 0
      If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
        PhaseStatus = PSQAppearance.RestoreOutfitPhase(PlayerRef,Self,PlayerAppearanceRace,Owner,RecoveryLoad,RequireBusy,Plan,PhaseStart,PhaseEnd,Protected,OriginalCopyForms,OriginalCopyKeys)
        Int Attempt = 0
        While PhaseStatus == 1 && Attempt < 3
          Utility.Wait(0.1)
          PhaseStatus = PSQAppearance.RestoreOutfitPhase(PlayerRef,Self,PlayerAppearanceRace,Owner,RecoveryLoad,RequireBusy,Plan,PhaseStart,PhaseEnd,Protected,OriginalCopyForms,OriginalCopyKeys)
          Attempt += 1
        EndWhile
        If PhaseStatus < 0 || !Self.IsEquipmentRecoveryCurrent(Owner,RequireBusy,RecoveryLoad)
          Return
        EndIf
        If PhaseStatus > 0
          HasFailure = PhaseStatus == 1
          If EnableEquipmentDiagnostics
            Debug.Trace("[PSQ-PERF] recovery.native_phase; phase=" + Phase + "; pieces=" + (PhaseEnd - PhaseStart) + "; retryPasses=" + Attempt + "; pending=" + HasFailure + "; seconds=" + (Utility.GetCurrentRealTime()-Started))
          EndIf
        EndIf
      EndIf
      If PhaseStatus == 0
        RetryCount = 0
        ; Hidden accessories are usually still worn. Take a fresh native snapshot
        ; for this phase, never a stored inventory cache. Larger/unsupported lists
        ; keep the original per-item path. Each actual restore invalidates it.
        Form[] PhaseWorn
        Form[] SnapshotSkipped
        Int SkippedCount = 0
        Bool PhaseWornDirty = False
        Bool CanBatchWorn = Phase == 1 && PhaseEnd - PhaseStart >= 4 && PhaseEnd - PhaseStart <= 128 && Self.CanUseSuccubusThrallEyes()
        If CanBatchWorn
          PhaseWorn = po3_sksefunctions.AddAllEquippedItemsToArray(PlayerRef)
          If PhaseWorn && PhaseWorn.Length > 0
            SnapshotSkipped = new Form[128]
          Else
            CanBatchWorn = False
          EndIf
        EndIf
        Index = PhaseStart
        While Index < PhaseEnd
          ; Already-worn originals require no actor mutation. The worker checks
          ; the initiating load, owner and live race immediately before equipping.
          If RecoveryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
            Return
          EndIf
          Armor item = Plan[Index] as Armor
          If CanBatchWorn && PhaseWornDirty && item != None && PhaseWorn.find(item as Form, 0) >= 0
            ; An equip callback can displace an item that was present before it.
            ; A dirty snapshot is only a hint to request a fresh read. Items
            ; absent from it take the original live worker without another batch.
            PhaseWorn = po3_sksefunctions.AddAllEquippedItemsToArray(PlayerRef)
            PhaseWornDirty = False
            If !PhaseWorn || PhaseWorn.Length == 0
              CanBatchWorn = False
            EndIf
          EndIf
          Bool Restored
          If CanBatchWorn && !PhaseWornDirty && item != None && PhaseWorn.find(item as Form, 0) >= 0 && Self.GetOriginalCopyKey(item) == ""
            Restored = True
            SnapshotSkipped[SkippedCount] = item as Form
            SkippedCount += 1
          Else
            If Phase == 0 && BatchMain
              Awaiting[0] = None
              Restored = Self.RestoreOriginalWithReceipt(item, Protected, Owner, RequireBusy, True, RecoveryLoad, None, Awaiting)
              If Restored && item != None && Protected.Find(item) < 0
                Submitted[Index] = item
              EndIf
            ElseIf Phase == 0 && Index == 0 && Awaiting
              Restored = Self.RestoreOriginalWithReceipt(item, Protected, Owner, RequireBusy, True, RecoveryLoad, None, Awaiting)
            ElseIf Phase == 0 && EnableEquipmentDiagnostics
              Restored = Self.TraceMainOriginalRestore(item, Protected, Owner, RequireBusy, RecoveryLoad, 1)
            Else
              Restored = Self.TryRestoreOriginalForLoad(item, Protected, Owner, RequireBusy, True, RecoveryLoad)
            EndIf
            PhaseWornDirty = True
          EndIf
          If !Restored
            If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
              Return
            EndIf
            Retry[RetryCount] = item as Form
            RetryCount += 1
          EndIf
          Index += 1
        EndWhile
        If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
          Return
        EndIf
        If Phase == 0 && BatchMain
          Float BatchStart
          If Detailed
            BatchStart = Utility.GetCurrentRealTime()
          EndIf
          Int[] Results = PSQAppearance.ConfirmExitMain(PlayerRef, PlayerAppearanceRace, Submitted)
          If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
            Return
          EndIf
          Index = 0
          Int SubmittedCount = 0
          Int UnresolvedCount = 0
          Int FirstResult = -2
          While Index < MainCount
            If Submitted[Index] != None
              SubmittedCount += 1
              Int Status = -1
              If Results && Results.Length == MainCount
                Status = Results[Index]
              EndIf
              String CopyKey = Self.GetOriginalCopyKey(Submitted[Index])
              If CopyKey != "" && SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
                Status = 0
                If PSQAppearance.OriginalCopyAction(PlayerRef, Submitted[Index] as Armor, CopyKey, Self, PlayerAppearanceRace, Owner, RecoveryLoad, RequireBusy, False, True) == 2
                  Status = 1
                EndIf
              EndIf
              If Index == 0
                FirstResult = Status
              EndIf
              If Status != 1
                Retry[RetryCount] = Submitted[Index]
                RetryCount += 1
                UnresolvedCount += 1
              EndIf
            EndIf
            Index += 1
          EndWhile
          If Detailed
            Debug.Trace("[PSQ-PERF] recovery.main_batch; owner=" + Owner + "; submitted=" + SubmittedCount + "; first=" + FirstResult + "; unresolved=" + UnresolvedCount + "; seconds=" + (Utility.GetCurrentRealTime() - BatchStart))
          EndIf
        ElseIf Phase == 0 && Awaiting && Awaiting[0] != None
          Armor First = Awaiting[0]
          Float VerifyStart
          If Detailed
            VerifyStart = Utility.GetCurrentRealTime()
          EndIf
          Int[] Receipt = PSQAppearance.ReadExitArmorState(PlayerRef, First, PlayerAppearanceRace, False)
          If Owner != AppearanceOperationId || RecoveryLoad != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
            Return
          EndIf
          Bool Confirmed = False
          Int CountAtCheck = -1
          Int WornAtCheck = -1
          If Receipt && Receipt.Length == 2
            CountAtCheck = Receipt[0]
            WornAtCheck = Receipt[1]
            If CountAtCheck < 0
              Return
            EndIf
            Confirmed = CountAtCheck == 0 || WornAtCheck == 1
          EndIf
          String FirstKey = Self.GetOriginalCopyKey(First)
          If FirstKey != "" && SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
            Confirmed = PSQAppearance.OriginalCopyAction(PlayerRef, First, FirstKey, Self, PlayerAppearanceRace, Owner, RecoveryLoad, RequireBusy, False, True) == 2
          EndIf
          If Detailed
            Debug.Trace("[PSQ-PERF] recovery.main_confirm; owner=" + Owner + "; item=" + First + "; count=" + CountAtCheck + "; worn=" + WornAtCheck + "; resolved=" + Confirmed + "; confirmSeconds=" + (Utility.GetCurrentRealTime() - VerifyStart))
          EndIf
          If !Confirmed
            Retry[RetryCount] = First as Form
            RetryCount += 1
          EndIf
        EndIf
        If SkippedCount > 0
          ; Re-read skipped entries after the phase: a foreign callback may have
          ; removed one while the VM yielded. Repair it during this same exit,
          ; with the original bounded retries, rather than only leaving it pending.
          Form[] VerifyWorn = po3_sksefunctions.AddAllEquippedItemsToArray(PlayerRef)
          Index = 0
          While Index < SkippedCount
            If RecoveryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
              Return
            EndIf
            Armor SkippedItem = SnapshotSkipped[Index] as Armor
            If !VerifyWorn || VerifyWorn.find(SkippedItem as Form, 0) < 0
              Bool Rechecked = Self.TryRestoreOriginalForLoad(SkippedItem, Protected, Owner, RequireBusy, True, RecoveryLoad)
              ; From the first repair onward, the remaining skipped entries use
              ; fresh individual reads. No stale snapshot survives an equip call.
              VerifyWorn = None
              If !Rechecked
                If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
                  Return
                EndIf
                Retry[RetryCount] = SkippedItem as Form
                RetryCount += 1
              EndIf
            EndIf
            Index += 1
          EndWhile
          If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
            Return
          EndIf
        EndIf
        If EnableEquipmentDiagnostics
          Debug.Trace("[PSQ-PERF] recovery.swap; phase=" + Phase + "; originals=" + (PhaseEnd - PhaseStart) + "; deferred=" + RetryCount + "; batched=" + SkippedCount + "; seconds=" + (Utility.GetCurrentRealTime() - Started), 0)
          Started = Utility.GetCurrentRealTime()
        EndIf
        Int Pass = 0
        HasFailure = RetryCount > 0
        While Pass < 3 && HasFailure && Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
          Utility.Wait(0.1)
          HasFailure = False
          Index = 0
          Int BatchRetry = 0
          If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231 && !EnableEquipmentDiagnostics
            BatchRetry = PSQAppearance.RetryOriginalBatch(PlayerRef, Self, PlayerAppearanceRace, Owner, RecoveryLoad, RequireBusy, Retry, RetryCount, Protected, OriginalCopyForms, OriginalCopyKeys)
          EndIf
          If BatchRetry < 0
            Return
          ElseIf BatchRetry != 0
            HasFailure = BatchRetry == 1
          Else
            While Index < RetryCount && Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
              Armor Original = Retry[Index] as Armor
              Bool Resolved
              If Phase == 0 && EnableEquipmentDiagnostics
                Resolved = Self.TraceMainOriginalRestore(Original, Protected, Owner, RequireBusy, RecoveryLoad, Pass + 2)
              Else
                Resolved = Self.TryRestoreOriginalForLoad(Original, Protected, Owner, RequireBusy, True, RecoveryLoad)
              EndIf
              If !Resolved
                If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
                  Return
                EndIf
                HasFailure = True
              EndIf
              Index += 1
            EndWhile
          EndIf
          Pass += 1
        EndWhile
        If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
          Return
        EndIf
        TotalRetryCount += RetryCount
        If EnableEquipmentDiagnostics
          Debug.Trace("[PSQ-PERF] recovery.retry; phase=" + Phase + "; entries=" + RetryCount + "; pending=" + HasFailure + "; seconds=" + (Utility.GetCurrentRealTime() - Started), 0)
        EndIf
      EndIf
      If Phase == 0
        MainPending = HasFailure
        If MainPending
          ; Keep all still-unworn extras in the authoritative ledger below.
          ; EndAppearanceEdit/cancellation owns the final visibility failsafe.
          Phase = 2
        Else
          Self.RestoreOriginalEquipmentVisibility()
          If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
            Return
          EndIf
          PhaseStart = MainCount
          PhaseEnd = Used
          Phase = 1
        EndIf
      Else
        Phase = 2
      EndIf
    EndWhile
  EndIf
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
    Return
  EndIf
  If EnableEquipmentDiagnostics
    Started = Utility.GetCurrentRealTime()
  EndIf
  ; Transfer unresolved references first. A failed allocation leaves the
  ; original FormList intact, so the next manual attempt can still recover it.
  if Self.CommitPendingOriginalEquipment(Plan, Used, Protected, Owner, RequireBusy)
    if !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
      return
    endif
    OrgArmorList.Revert()
  endif
  if Self.HasPendingOriginalEquipment()
    Debug.Notification("$PSQ_EquipmentRecoveryPending")
  endif
  If EnableEquipmentDiagnostics
    Debug.Trace("[PSQ-PERF] recovery.commit; retryEntries=" + TotalRetryCount + "; mainPending=" + MainPending + "; seconds=" + (Utility.GetCurrentRealTime() - Started), 0)
  EndIf
EndFunction

Float Function GetSteppedSatiationRatio(Float Ratio)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777228
    Return PSQAppearance.SatiationStep(Ratio)
  EndIf
  If Ratio <= 0.0
    Return 0.0
  ElseIf Ratio >= 1.0
    Return 1.0
  EndIf
  Return Math.Floor(Ratio * 10.0 + 0.00001) as Float / 10.0
EndFunction

Bool Function RequestTransformAppearanceCacheRefresh()
  ; Explicit read-cache invalidation only. Never applies or changes appearance.
  If PlayerRef == None || PSQReloadBusy || UninstallPrepared || UninstallCleanupBusy
    Return False
  EndIf
  If IsHenshinchu || AppearanceEditBusy || BodySelectionRefreshBusy || AppearanceRecoveryPending || AppearanceRecoveryRequested
    Return False
  EndIf
  Self.InvalidateTransformAppearanceCache()
  Return True
EndFunction

Function InvalidateTransformAppearanceCache()
  OptionalHornCatalogReady = False
  GTSoftbodyCacheReady = False
  AppearanceCacheRevision += 1
  TransformOutfitCache = EmptyArmorArray
  TransformHairCache = EmptyHeadPartArray
  TransformHairResolved = EmptyBoolArray
  TransformBodyCatalogReady = False
  BCNGBodyPresetIds = EmptyStringArray
  TransformBodyNames = EmptyStringArray
  TransformBodySliders = EmptyStringArray
  TransformBodyBaseLow = EmptyFloatArray
  TransformBodyBaseHigh = EmptyFloatArray
  TransformCachedBodyPreset = -1
  TransformBodyDataReady = False
  TransformBodyLow = EmptyFloatArray
  TransformBodyHigh = EmptyFloatArray
  TransformEyeCatalogReady = False
  TransformEyeNames = EmptyStringArray
  TransformEyePlugins = EmptyStringArray
  TransformEyeIds = EmptyIntArray
  TransformEyeTextures = EmptyFormArray
  TransformEyeResolved = EmptyBoolArray
  PSQOutfitAddonCache = EmptyArmorAddonArray
  PSQOutfitModelsNormalized = False
EndFunction

Armor Function GetCachedOutfitPart(Int Selection, Int Part, Int Owner, Bool RequireBusy)
  Return Self.GetCachedOutfitPart39(Selection, Part, Owner, RequireBusy)
EndFunction

Function EnsureTransformBodyCatalog(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If Owner < 0
      Owner = AppearanceOperationId
      RequireBusy = AppearanceEditBusy
    ElseIf AppearanceEditBusy
      RequireBusy = True
    EndIf
    Int CatalogEpoch = PSQLoadEpoch
    If PSQAppearance.CatalogState34(Self, Owner, RequireBusy, CatalogEpoch) != -1 || !Self.HasBodyChangeNGAPI() || !BCNGPSQBridge.IsReady() || !PlayerRef
      Return
    EndIf
    String[] ProviderIds = BCNGPSQBridge.GetPresetIds(PlayerRef)
    If ProviderIds
      PSQAppearance.CommitCatalog34(Self, Owner, RequireBusy, CatalogEpoch, ProviderIds)
    EndIf
    Return
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy) || TransformBodyCatalogReady
    Return
  EndIf
  If !Self.HasBodyChangeNGAPI() || !BCNGPSQBridge.IsReady() || PlayerRef == None
    Return
  EndIf
  String[] Ids = BCNGPSQBridge.GetPresetIds(PlayerRef)
  If !Ids
    Return
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  BCNGBodyPresetIds = Ids
  TransformBodyCatalogReady = True
  ; Legacy slider/base arrays stay inert for save compatibility.
  TransformBodySliders = EmptyStringArray
  TransformBodyBaseLow = EmptyFloatArray
  TransformBodyBaseHigh = EmptyFloatArray
EndFunction

Int Function GetTransformBodyPresetCount(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If Owner < 0
      Owner = AppearanceOperationId
      RequireBusy = AppearanceEditBusy
    ElseIf AppearanceEditBusy
      RequireBusy = True
    EndIf
    Int CatalogEpoch = PSQLoadEpoch
    Int Count34 = PSQAppearance.CatalogState34(Self, Owner, RequireBusy, CatalogEpoch)
    If Count34 == -1
      Self.EnsureTransformBodyCatalog(Owner, RequireBusy)
      Count34 = PSQAppearance.CatalogState34(Self, Owner, RequireBusy, CatalogEpoch)
    EndIf
    If Count34 < 0
      Return 0
    EndIf
    Return Count34
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return 0
  EndIf
  Self.EnsureTransformBodyCatalog(Owner, RequireBusy)
  If !TransformBodyCatalogReady
    Return 0
  EndIf
  Return BCNGBodyPresetIds.Length
EndFunction

Int Function GetCachedEyeMaterialCount()
  Return Self.GetSuccubusEyeMaterialCount()
EndFunction

String Function GetTransformBodyPresetName(Int Selection, Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If Owner < 0
      Owner = AppearanceOperationId
      RequireBusy = AppearanceEditBusy
    ElseIf AppearanceEditBusy
      RequireBusy = True
    EndIf
    Int CatalogEpoch = PSQLoadEpoch
    Int Count34 = PSQAppearance.CatalogState34(Self, Owner, RequireBusy, CatalogEpoch)
    If Count34 == -1
      Self.EnsureTransformBodyCatalog(Owner, RequireBusy)
      Count34 = PSQAppearance.CatalogState34(Self, Owner, RequireBusy, CatalogEpoch)
    EndIf
    If Selection < 1 || Selection > Count34 || !Self.HasBodyChangeNGAPI()
      Return ""
    EndIf
    String Key34 = PSQAppearance.PresetID34(Self, Selection, Owner, RequireBusy, CatalogEpoch)
    If Key34 == ""
      Return ""
    EndIf
    String Label34 = BCNGPSQBridge.GetPresetName(Key34)
    If PSQAppearance.PresetID34(Self, Selection, Owner, RequireBusy, CatalogEpoch) != Key34
      Return ""
    EndIf
    Return Label34
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return ""
  EndIf
  Self.EnsureTransformBodyCatalog(Owner, RequireBusy)
  If !TransformBodyCatalogReady
    Return ""
  EndIf
  If Selection < 1 || Selection > BCNGBodyPresetIds.Length || !Self.HasBodyChangeNGAPI()
    Return ""
  EndIf
  Return BCNGPSQBridge.GetPresetName(BCNGBodyPresetIds[Selection - 1])
EndFunction

Bool Function EnsureTransformBodyPresetData(Int Selection, Int Owner, Bool RequireBusy)
  ; Public legacy signature retained; preset values are owned by Body Change NG.
  Return Self.GetTransformBodyPresetName(Selection, Owner, RequireBusy) != ""
EndFunction

Function EnsureTransformEyeCatalog(Int Owner, Bool RequireBusy)
  Self.EnsureTransformEyeCatalog38(Owner, RequireBusy)
EndFunction

; Only an explicit transformation waits. Reload's internal appearance edits
; must be able to run while the caller is waiting. Store no queued direction
; across saves. The existing recovery spell gets priority over a user toggle.
Bool Function BeginTransformAfterLoad()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Int[] Ticket = Self.AcquireTransformAfterLoad()
    Return Ticket && Ticket.Length == 2 && Ticket[0] > 0
  EndIf
  Int Epoch = PSQLoadEpoch
  If QueuedTransformEpoch == Epoch
    Return False
  EndIf
  QueuedTransformEpoch = Epoch
  If TransformLoadInitializing || PSQReloadBusy
    Debug.Notification("PSQ 正在恢复读档状态，完成后会执行变身切换。")
    Debug.Trace("[PSQ-RECOVERY] transform waiting for reload; epoch=" + Epoch)
    Int Checks = 0
    While Epoch == PSQLoadEpoch && (TransformLoadInitializing || PSQReloadBusy) && Checks < 240
      Utility.Wait(0.25)
      Checks += 1
    EndWhile
  EndIf
  If Epoch != PSQLoadEpoch || QueuedTransformEpoch != Epoch
    Return False
  EndIf
  If TransformLoadInitializing || PSQReloadBusy
    QueuedTransformEpoch = -1
    Debug.Notification("PSQ 读档恢复仍在进行，请稍后再使用变身。")
    Return False
  EndIf
  Bool Started = Self.BeginAppearanceEdit()
  If Epoch != PSQLoadEpoch || QueuedTransformEpoch != Epoch
    Return False
  EndIf
  QueuedTransformEpoch = -1
  Return Started
EndFunction

Bool Function BeginAppearanceEdit()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Int[] Ticket = Self.AcquireAppearanceEditTicket()
    Return Ticket && Ticket.Length == 2 && Ticket[0] > 0
  EndIf
  Self.SyncPlayerAppearanceRace()
  If Self.IsWingflightAirborne()
    Debug.Notification("请先着陆，再变身或更换外观与翅膀。")
    Return False
  EndIf
  If PlayerRef == None || psqracecompatibility.IsTemporaryBeastRace(PlayerRef.GetRace())
    Return False
  EndIf
  If Self.ShouldDeferForAlternateStart()
    Debug.Notification("$PSQ_LALAppearanceDeferred")
    Return False
  EndIf
  If AppearanceRecoveryPending && !AppearanceRecoveryInProgress || AppearanceEditBusy || IsHenshinchu || BodySelectionRefreshBusy || StatPoolEditBusy || UninstallPrepared || UninstallCleanupBusy
    Debug.Notification("$PSQ_AppearanceEditBusy")
    Return False
  EndIf
  Self.CancelDeferredTransformRefill()
  AppearanceOperationId += 1
  TransformEntryLoadEpoch = PSQLoadEpoch
  AppearanceEditBusy = True
  Self.ClearEquipmentSwapPlan()
  AppearanceLastProgress = Utility.GetCurrentRealTime()
  AppearanceSlowNotified = False
  AppearanceOperationStage = "menu"
  If Self.GTSoftbodyOwnsAppearance()
    AppearanceEditBusy = False
    Debug.Notification("$PSQ_GTAppearanceBusy")
    Return False
  EndIf
  If Self.IsIntegrationPluginLoaded("SexLab TDF Aggressive Prostitution.esp")
    storageutil.SetIntValue(PlayerRef as Form, "PSQ_TDFAppearanceBusy", 1)
  EndIf
  Self.SyncWingflightPolicy()
  Self.StopEnergySense()
  Return True
EndFunction

Function EndAppearanceEdit(Int Owner)
  Bool WasColorEdit = AppearanceOperationStage == "color"
  If !Self.IsAppearanceOperationCurrent(Owner, True)
    Return
  EndIf
  AppearanceTransformDirection = 0
  AppearanceOperationStage = ""
  If AppearanceRecoveryInProgress
    AppearanceRecoveryInProgress = False
    AppearanceRecoveryPending = False
    AppearanceRecoveryRequested = False
    Debug.Notification("中断的变身恢复流程已结束。")
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, True)
    Return
  EndIf
  storageutil.UnsetIntValue(PlayerRef as Form, "PSQ_TDFAppearanceBusy")
  If !Self.IsAppearanceOperationCurrent(Owner, True)
    Return
  EndIf
  Bool ColorRefreshNeeded = !WasColorEdit && IsHenshined && (HenshinSkin || HenshinHairColor)
  Self.ClearEquipmentSwapPlan()
  AppearanceEditBusy = False
  If !WasColorEdit
    Self.QueueBCNGTransformSkin()
    Self.QueueOriginalEquipmentVisibility()
    Self.SendModEvent("PSQ_EquipmentSwapComplete", Owner as String, PSQLoadEpoch as Float)
  EndIf
  Self.SyncWingflightPolicy()
  If ColorRefreshNeeded
    Self.QueueAppearanceColorRefresh(False)
  EndIf
  If !WasColorEdit && storageutil.GetFormValue(PlayerRef, "PSQ_TRXFutaItem", None) != None
    Self.QueueBCNGFutaSkin(PlayerRef)
    Self.QueueTRXFutaSize(PlayerRef)
  EndIf
  If !UninstallPrepared && !UninstallCleanupBusy && (TransformBuffRefreshPending || ContinuousSyncPending || SatiationRefreshPending)
    Self.RegisterForSingleUpdate(1.0)
  EndIf
EndFunction

Bool Function IsSelectedEyeMaterialApplied()
  Return IsHenshined && HenshinEyes && AppliedTransformEyeTexture != None && AppliedTransformEyeTexture == Self.GetExternalEyeTexture(SuccubusEyeMaterialSelection, -1, False) && Self.GetCurrentPlayerEyes() == PSQSuccubusEyes
EndFunction

headpart Function GetCurrentPlayerEyes()
  ActorBase Base = PlayerRef.GetLeveledActorBase()
  If Base == None
    Return None
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777241 && PSQAppearance.IsReady()
    Return PSQAppearance.ReadTransformHead(Base, False)
  EndIf
  Int Index
  If Base.GetNumOverlayHeadParts() > 0
    Index = Base.GetIndexOfOverlayHeadPartByType(2)
    If Index >= 0
      Return Base.GetNthOverlayHeadPart(Index)
    EndIf
  Else
    Index = Base.GetIndexOfHeadPartByType(2)
    If Index >= 0
      Return Base.GetNthHeadPart(Index)
    EndIf
  EndIf
  Return None
EndFunction

Function ClearAppliedTransformBody(Int Owner, Bool RequireBusy)
  Self.ClearAppliedTransformBody39(Owner, RequireBusy)
EndFunction

Bool Function TransformBodyMatchesApplied(Float Weight, Int Owner, Bool RequireBusy)
  Return Self.TransformBodyMatchesApplied39(Weight, Owner, RequireBusy)
EndFunction

Float[] Function CaptureSatiationInputs(Float Step)
  Float[] Inputs = new Float[26]
  If !Inputs || Inputs.Length != 26
    Return EmptyFloatArray
  EndIf
  Inputs[0] = Step
  Inputs[1] = Self.GetSatiationEffectMode() as Float
  Inputs[2] = SuccubusRank.GetValueInt() as Float
  Inputs[3] = PlayerIsSuccubus.GetValueInt() as Float
  Inputs[4] = (IsHenshined as Int) as Float
  Inputs[5] = (EnableRankSpeedBonus as Int) as Float
  Inputs[6] = PlayerRef.GetBaseAV("Health")
  Inputs[7] = PlayerRef.GetBaseAV("Magicka")
  Inputs[8] = PlayerRef.GetBaseAV("Stamina")
  Inputs[9] = PlayerRef.GetBaseAV("CarryWeight")
  Inputs[10] = HealthBuffInc
  Inputs[11] = HealthBuffDec
  Inputs[12] = MagickaBuffInc
  Inputs[13] = MagickaBuffDec
  Inputs[14] = StaminaBuffInc
  Inputs[15] = StaminaBuffDec
  Inputs[16] = HealthRateBuffInc
  Inputs[17] = HealthRateBuffDec
  Inputs[18] = MagickaRateBuffInc
  Inputs[19] = MagickaRateBuffDec
  Inputs[20] = StaminaRateBuffInc
  Inputs[21] = StaminaRateBuffDec
  Inputs[22] = CarryBuffInc
  Inputs[23] = CarryBuffDec
  Inputs[24] = SpeedBuffInc
  Inputs[25] = SpeedBuffDec
  Return Inputs
EndFunction

Bool Function SatiationInputsUnchanged(Float Step)
  If !StableCachedSatiationInputs || StableCachedSatiationInputs.Length != 26 || StableCachedSatiationInputs[0] != Step
    Return False
  EndIf
  If (StableCachedSatiationInputs[1] != Self.GetSatiationEffectMode() as Float) || (StableCachedSatiationInputs[2] != SuccubusRank.GetValueInt() as Float) || (StableCachedSatiationInputs[3] != PlayerIsSuccubus.GetValueInt() as Float) || StableCachedSatiationInputs[4] != 0.0 != IsHenshined || StableCachedSatiationInputs[5] != 0.0 != EnableRankSpeedBonus
    Return False
  EndIf
  If StableCachedSatiationInputs[6] != PlayerRef.GetBaseAV("Health") || StableCachedSatiationInputs[7] != PlayerRef.GetBaseAV("Magicka") || StableCachedSatiationInputs[8] != PlayerRef.GetBaseAV("Stamina") || StableCachedSatiationInputs[9] != PlayerRef.GetBaseAV("CarryWeight")
    Return False
  EndIf
  If StableCachedSatiationInputs[10] != HealthBuffInc || StableCachedSatiationInputs[11] != HealthBuffDec || StableCachedSatiationInputs[12] != MagickaBuffInc || StableCachedSatiationInputs[13] != MagickaBuffDec || StableCachedSatiationInputs[14] != StaminaBuffInc || StableCachedSatiationInputs[15] != StaminaBuffDec || StableCachedSatiationInputs[16] != HealthRateBuffInc || StableCachedSatiationInputs[17] != HealthRateBuffDec || StableCachedSatiationInputs[18] != MagickaRateBuffInc || StableCachedSatiationInputs[19] != MagickaRateBuffDec || StableCachedSatiationInputs[20] != StaminaRateBuffInc || StableCachedSatiationInputs[21] != StaminaRateBuffDec || StableCachedSatiationInputs[22] != CarryBuffInc || StableCachedSatiationInputs[23] != CarryBuffDec || StableCachedSatiationInputs[24] != SpeedBuffInc || StableCachedSatiationInputs[25] != SpeedBuffDec
    Return False
  EndIf
  Return True
EndFunction

Function PublishSatiationInputs(Float[] Inputs)
  StableCachedSatiationInputs = Inputs
  If !Self.SatiationInputsUnchanged(Inputs[0])
    StableCachedSatiationInputs = EmptyFloatArray
  EndIf
EndFunction

Spell Function GetManagedMovementAbility()
  Return Game.GetFormFromFile(41647, "PSQ PlayerSuccubusQuest.esm") as Spell
EndFunction

Function RefreshManagedMovement(Float Bonus)
  Spell Ability = Self.GetManagedMovementAbility()
  If !PlayerRef || !Ability
    Return
  EndIf
  If UninstallPrepared || UninstallCleanupBusy || PlayerIsSuccubus.GetValueInt() != 1
    Self.ClearManagedMovement()
    Return
  EndIf
  If AppliedMovementValid && AppliedMovementBonus == Bonus && (Bonus == 0.0 && !PlayerRef.HasSpell(Ability as Form) || Bonus != 0.0 && PlayerRef.HasSpell(Ability as Form))
    Return
  EndIf
  If PlayerRef.HasSpell(Ability as Form)
    PlayerRef.RemoveSpell(Ability)
  EndIf
  AppliedMovementValid = False
  If Bonus != 0.0
    Ability.SetNthEffectMagnitude(0, Bonus)
    If !PlayerRef.AddSpell(Ability, False)
      Return
    EndIf
  EndIf
  AppliedMovementBonus = Bonus
  AppliedMovementValid = True
  Debug.Trace(("[PSQ] Movement refreshed; bonus=" + Bonus as String) + "; speedMult=" + PlayerRef.GetAV("SpeedMult") as String, 0)
EndFunction

Function ClearManagedMovement()
  Spell Ability = Self.GetManagedMovementAbility()
  If (PlayerRef as Bool && Ability as Bool) && PlayerRef.HasSpell(Ability as Form)
    PlayerRef.RemoveSpell(Ability)
  EndIf
  AppliedMovementValid = False
  AppliedMovementBonus = 0.0
EndFunction

Bool Function HasAlternateStart()
  If !AlternateStartChecked
    AlternateStartChargen = None
    If Self.IsIntegrationPluginLoaded("alternate start - live another life.esp")
      AlternateStartChargen = Game.GetFormFromFile(3503, "alternate start - live another life.esp") as Quest
    EndIf
    AlternateStartChecked = True
  EndIf
  Return AlternateStartChargen != None
EndFunction

Bool Function ShouldDeferForAlternateStart()
  If AlternateStartReleased || UninstallPrepared || UninstallCleanupBusy || !Self.HasAlternateStart()
    Return False
  EndIf
  If !AlternateStartChargen.IsRunning()
    Return False
  EndIf
  If !PlayerRef || ui.IsMenuOpen("RaceSex Menu")
    Return True
  EndIf
  Cell CurrentCell = PlayerRef.GetParentCell()
  Cell Prison = Game.GetFormFromFile(136596, "Skyrim.esm") as Cell
  If AlternateStartChargen.GetStage() < 20 || !CurrentCell || CurrentCell == Prison
    AlternateStartReleaseAfter = -1.0
    Return True
  EndIf
  Float Now = Utility.GetCurrentRealTime()
  If AlternateStartReleaseAfter < 0.0
    AlternateStartReleaseAfter = Now + 3.0
    Return True
  EndIf
  If Now < AlternateStartReleaseAfter
    Return True
  EndIf
  AlternateStartReleased = True
  Return False
EndFunction

String Function GetAlternateStartProtectionStatus()
  If !Self.HasAlternateStart()
    Return "$PSQ_LALNotInstalled"
  ElseIf Self.ShouldDeferForAlternateStart()
    Return "$PSQ_LALWaiting"
  EndIf
  Return "$PSQ_LALReady"
EndFunction

Function CancelAlternateStartActivation()
  AlternateStartBecomePending = False
  Debug.Notification("$PSQ_LALActivationCancelled")
EndFunction

String Function GetExternalEyeReadFailure(Int Index)
  Int Slot = Index - 1
  String Plugin = jsonutil.StringListGet("PSQ/EyeMaterials", "plugins", Slot)
  Int LocalID = jsonutil.IntListGet("PSQ/EyeMaterials", "ids", Slot)
  String Detail = Plugin + " / FormID " + LocalID as String
  If Plugin == "" || LocalID <= 0
    Debug.Trace(("[PSQ Eyes] Invalid catalog entry: index=" + Index as String) + "; " + Detail, 1)
    Return "$PSQ_EyeCatalogReadFailed"
  EndIf
  If !Self.IsIntegrationPluginLoaded(Plugin)
    Debug.Trace("[PSQ Eyes] Plugin not detected: " + Detail, 1)
    Return "$PSQ_EyePluginNotLoaded"
  EndIf
  Form Record = Game.GetFormFromFile(LocalID, Plugin)
  Int RecordType = -1
  If Record != None
    RecordType = Record.GetType()
  EndIf
  Debug.Trace((("[PSQ Eyes] Resolve failed: index=" + Index as String) + "; " + Detail + "; form=" + Record as String) + "; type=" + RecordType as String, 1)
  Return "$PSQ_EyeRecordReadFailed"
EndFunction

Int Function GetContinuousAbilityMode()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.ContinuousMode34(Self)
  EndIf
  If ContinuousAbilityMode < 0 || ContinuousAbilityMode > 2
    ContinuousAbilityMode = 1
  EndIf
  Return ContinuousAbilityMode
EndFunction

Int Function GetContinuousRank()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.ContinuousRank34(Self)
  EndIf
  Int Rank = SuccubusRank.GetValueInt()
  If Rank < 1
    Return 1
  ElseIf Rank > 10
    Return 10
  EndIf
  Return Rank
EndFunction

Spell Function GetContinuousRankAbility()
  Return Game.GetFormFromFile(41656, "PSQ PlayerSuccubusQuest.esm") as Spell
EndFunction

Perk Function GetContinuousRankPerk()
  Return Game.GetFormFromFile(41657, "PSQ PlayerSuccubusQuest.esm") as Perk
EndFunction

Spell Function GetLegacyContinuousCore(Int Index)
  If Index == 0
    Return FortifyMagickaSpell
  ElseIf Index == 1
    Return FortifyStaminaSpell
  ElseIf Index == 2
    Return FortifyHealthSpell
  ElseIf Index == 3
    Return FortifyCarrySpell
  ElseIf Index == 4
    Return FortifyUnarmedSpell
  ElseIf Index == 5
    Return SuccubusStorageSpell
  ElseIf Index == 6
    Return FortifySneakSpell
  EndIf
  Return None
EndFunction

Spell Function GetLegacyContinuousBarter(Int Rank)
  If Rank == 1
    Return FortifyBartarSpell1
  ElseIf Rank == 2
    Return FortifyBartarSpell2
  ElseIf Rank == 3
    Return FortifyBartarSpell3
  ElseIf Rank == 4
    Return FortifyBartarSpell4
  ElseIf Rank == 5
    Return FortifyBartarSpell5
  ElseIf Rank == 6
    Return FortifyBartarSpell6
  ElseIf Rank == 7
    Return FortifyBartarSpell7
  ElseIf Rank == 8
    Return FortifyBartarSpell8
  EndIf
  Return None
EndFunction

Bool Function GetContinuousManualOption(Int Index)
  If Index >= 0 && Index < 7
    Return PlayerRef.HasSpell(Self.GetLegacyContinuousCore(Index) as Form)
  ElseIf Index == 7
    Return EnableFortifyDestruction
  ElseIf Index == 8
    Return EnableFortifyIllusion
  ElseIf Index == 9
    Return EnableMagicResistance
  ElseIf Index == 10
    Return EnableSuccubusSpellBooster
  ElseIf Index == 11
    Return EnableFortifyBartar
  ElseIf Index == 12
    Return EnableEnergyConsumingBySuccubusSpell
  ElseIf Index == 13
    Return EnableSpellCastingNotification
  EndIf
  Return False
EndFunction

Bool Function GetContinuousOptionEnabled(Int Index)
  If Index == 12
    Return EnableEnergyConsumingBySuccubusSpell
  EndIf
  If Index == 5 && !Self.IsStorageRankUnlocked()
    Return False
  EndIf
  Int Mode = Self.GetContinuousAbilityMode()
  If Mode == 0
    Return False
  ElseIf Mode == 1 && Index < 12
    Return True
  EndIf
  Return Self.GetContinuousManualOption(Index)
EndFunction

Function CaptureManualContinuousChoices()
  Bool[] Choices = new Bool[14]
  Int i = 0
  While i < 14
    If i == 12
      Choices[i] = False
    ElseIf i < 7 && PlayerIsSuccubus.GetValueInt() != 1
      Choices[i] = True
    Else
      Choices[i] = Self.GetContinuousManualOption(i)
    EndIf
    i += 1
  EndWhile
  ManualContinuousChoices = Choices
EndFunction

Function SetContinuousAbilityMode(Int Mode)
  If Mode < 0 || Mode > 2
    Return
  EndIf
  If Self.GetContinuousAbilityMode() == 2 || !ManualContinuousChoices
    Self.CaptureManualContinuousChoices()
  EndIf
  If !(SKSE.GetPluginVersion("PSQ Appearance") >= 16777231) || PSQAppearance.ChangeGameplayMode(Self, 2, Mode) < 0
    ContinuousAbilityMode = Mode
  EndIf
  Self.SyncContinuousAbilities(True)
EndFunction

Function ToggleManualContinuousOption(Int Index)
  If Index == 12
    Return
  EndIf
  If Index == 5 && !Self.IsStorageRankUnlocked()
    Return
  EndIf
  If Self.GetContinuousAbilityMode() != 2 || Index < 0 || Index >= 14
    Return
  EndIf
  If !ManualContinuousChoices || ManualContinuousChoices.Length != 14
    Self.CaptureManualContinuousChoices()
  EndIf
  ManualContinuousChoices[Index] = !ManualContinuousChoices[Index]
  Self.SyncContinuousAbilities(True)
EndFunction

Function SetContinuousOwnedSpell(Spell Ability, Bool Enabled, Int PoolEpoch, Int Owner)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231 && PSQAppearance.ContinuousEntry(Self, PlayerRef, Ability, Enabled, PoolEpoch, Owner)
    Return
  EndIf
  If !Ability
    Return
  EndIf
  If Enabled && !PlayerRef.HasSpell(Ability as Form)
    If PoolEpoch >= 0 && !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    PlayerRef.AddSpell(Ability, False)
  ElseIf !Enabled && PlayerRef.HasSpell(Ability as Form)
    If PoolEpoch >= 0 && !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    PlayerRef.RemoveSpell(Ability)
  EndIf
EndFunction

Function SetContinuousOwnedPerk(Perk Ability, Bool Enabled, Int PoolEpoch, Int Owner)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231 && PSQAppearance.ContinuousEntry(Self, PlayerRef, Ability, Enabled, PoolEpoch, Owner)
    Return
  EndIf
  If !Ability
    Return
  EndIf
  If Enabled && !PlayerRef.HasPerk(Ability)
    If PoolEpoch >= 0 && !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    PlayerRef.AddPerk(Ability)
  ElseIf !Enabled && PlayerRef.HasPerk(Ability)
    If PoolEpoch >= 0 && !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    PlayerRef.RemovePerk(Ability)
  EndIf
EndFunction

Function BufferContinuousHealth(Int PoolEpoch, Int Owner)
  If PoolEpoch >= 0 && !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  If PlayerRef.GetAV("Health") > 0.0 && !PlayerRef.IsDead()
    Float Maximum = PlayerRef.GetAVMax("Health")
    If PoolEpoch >= 0 && !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    PlayerRef.RestoreAV("Health", Maximum)
  EndIf
EndFunction

Function ClearContinuousRankEffects(Int Owner, Int PoolEpoch)
  Self.ClearContinuousRankEffects35(Owner,PoolEpoch)
EndFunction

Function ClearContinuousRankEffectsCore(Int Owner, Int PoolEpoch)
  Self.ClearContinuousRankEffectsCore35(Owner,PoolEpoch)
EndFunction

Function SyncContinuousAbilities(Bool Force)
  If ContinuousSyncBusy && !Force
    Return
  EndIf
  Int Owner = AppearanceOperationId
  Int PoolEpoch = Self.BeginStatPoolEdit(Owner, False)
  If PoolEpoch < 0
    If Force
      ContinuousSyncPending = True
    EndIf
    Return
  EndIf
  Force = Force || ContinuousSyncPending
  ContinuousSyncPending = False
  Self.SyncContinuousAbilitiesCore(Force, Owner, PoolEpoch)
  If PoolEpoch == StatPoolEditEpoch
    ContinuousSyncBusy = False
  EndIf
  Self.EndStatPoolEdit(PoolEpoch)
EndFunction

Function SyncContinuousAbilitiesCore(Bool Force, Int Owner, Int PoolEpoch)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  If ContinuousSyncBusy || !PlayerRef || UninstallPrepared || UninstallCleanupBusy || Self.ShouldDeferForAlternateStart()
    Return
  EndIf
  If PlayerIsSuccubus.GetValueInt() != 1
    Return
  EndIf
  ContinuousSyncBusy = True
  If !ManualContinuousChoices || ManualContinuousChoices.Length != 14
    Self.CaptureManualContinuousChoices()
  EndIf
  Int Mode = Self.GetContinuousAbilityMode()
  Int Rank = Self.GetContinuousRank()
  Bool StorageEnabled = Rank >= 3 && (Mode == 1 || Mode == 2 && ManualContinuousChoices[5])
  Bool Changed = Force || StableAppliedContinuousMode != Mode || PlayerRef.HasSpell(SuccubusStorageSpell as Form) != StorageEnabled
  If Mode != 1 && !Changed && (Mode != 2 || StableAppliedContinuousRank == Rank)
    ContinuousSyncBusy = False
    Return
  EndIf
  Float BH
  Float BM
  Float BS
  Float BC
  Float[] Bases
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777221
    Bases = PSQAppearance.ReadTransformBases(PlayerRef)
  EndIf
  If Bases && Bases.Length == 4
    BH = Bases[0]
    BM = Bases[1]
    BS = Bases[2]
    BC = Bases[3]
  Else
    BH = PlayerRef.GetBaseAV("Health")
    BM = PlayerRef.GetBaseAV("Magicka")
    BS = PlayerRef.GetBaseAV("Stamina")
    BC = PlayerRef.GetBaseAV("CarryWeight")
  EndIf
  Float BU = PlayerRef.GetBaseAV("UnarmedDamage")
  Spell RankAbility = Self.GetContinuousRankAbility()
  Perk RankPerk = Self.GetContinuousRankPerk()
  If Mode == 1
    Changed = Changed || StableAppliedContinuousRank != Rank || BH != StableAppliedContinuousHealth || BM != StableAppliedContinuousMagicka || BS != StableAppliedContinuousStamina || BC != StableAppliedContinuousCarry || BU != StableAppliedContinuousUnarmed || !PlayerRef.HasSpell(RankAbility as Form) || !PlayerRef.HasPerk(RankPerk)
  ElseIf Mode == 2
    Changed = Changed || StableAppliedContinuousRank != Rank
  EndIf
  If ReviewContinuousCarry && Mode == 1 && PlayerRef.Is3DLoaded() && !PlayerRef.IsDead() && !Utility.IsInMenuMode()
    ReviewContinuousCarry = False
    If !Changed
      Changed = Self.NeedsCarryEffectRepair(RankAbility, BC * Rank * 0.1)
    EndIf
  EndIf
  If !Changed
    If ContinuousRecordSyncPending && Mode == 1
      Self.RestoreContinuousRuntimeRecords(Mode, Rank, BH, BM, BS, BC, BU, Owner, PoolEpoch)
    EndIf
    ContinuousSyncBusy = False
    Return
  EndIf
  If !RankAbility || !RankPerk
    ContinuousSyncBusy = False
    Debug.Trace("[PSQ] Continuous rank records are unavailable; retaining existing abilities", 1)
    Return
  EndIf
  Float OldHealth = PlayerRef.GetAV("Health")
  Float OldMagicka = PlayerRef.GetAV("Magicka")
  Float OldStamina = PlayerRef.GetAV("Stamina")
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  Self.BufferContinuousHealth(PoolEpoch, Owner)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  Self.ClearContinuousRankEffects(Owner, PoolEpoch)
  Int i = 0
  Int Loadout = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Loadout = PSQAppearance.ContinuousLoadout(Self,PlayerRef,PoolEpoch,Owner,Mode,StorageEnabled,ManualContinuousChoices)
  EndIf
  If Loadout < 0
    Return
  ElseIf Loadout == 0
    EnableFortifyDestruction = Mode == 2 && ManualContinuousChoices[7]
    EnableFortifyIllusion = Mode == 2 && ManualContinuousChoices[8]
    EnableMagicResistance = Mode == 2 && ManualContinuousChoices[9]
    EnableSuccubusSpellBooster = Mode == 2 && ManualContinuousChoices[10]
    EnableFortifyBartar = Mode == 2 && ManualContinuousChoices[11]
    EnableSpellCastingNotification = Mode != 0 && ManualContinuousChoices[13]
    i = 0
    While i < 7
      Bool Enabled = Mode == 2 && ManualContinuousChoices[i] || Mode == 1 && i == 5
      If i == 5
        Enabled = StorageEnabled
      EndIf
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.SetContinuousOwnedSpell(Self.GetLegacyContinuousCore(i), Enabled, PoolEpoch, Owner)
      i += 1
    EndWhile
    If Mode != 2
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.SetContinuousOwnedSpell(FortifyDestructionSpell, False, PoolEpoch, Owner)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.SetContinuousOwnedSpell(FortifyIllusionSpell, False, PoolEpoch, Owner)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.SetContinuousOwnedSpell(MagicResistanceSpell, False, PoolEpoch, Owner)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.SetContinuousOwnedSpell(FortifyBartarSpell1, False, PoolEpoch, Owner)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.SetContinuousOwnedSpell(FortifyBartarSpell2, False, PoolEpoch, Owner)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.SetContinuousOwnedSpell(FortifyBartarSpell3, False, PoolEpoch, Owner)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.SetContinuousOwnedSpell(FortifyBartarSpell4, False, PoolEpoch, Owner)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.SetContinuousOwnedSpell(FortifyBartarSpell5, False, PoolEpoch, Owner)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.SetContinuousOwnedSpell(FortifyBartarSpell6, False, PoolEpoch, Owner)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.SetContinuousOwnedSpell(FortifyBartarSpell7, False, PoolEpoch, Owner)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.SetContinuousOwnedSpell(FortifyBartarSpell8, False, PoolEpoch, Owner)
    EndIf
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Self.SetContinuousOwnedPerk(FortifyIllusionPerk, Mode == 2 && EnableFortifyIllusion, PoolEpoch, Owner)
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Self.SetContinuousOwnedPerk(FortifySneakPerk, Mode == 2 && ManualContinuousChoices[6], PoolEpoch, Owner)
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Self.SetContinuousOwnedPerk(FortifyBartarPerk, Mode == 2 && EnableFortifyBartar, PoolEpoch, Owner)
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Self.SetContinuousOwnedPerk(SuccubusSpellBoostPerk, Mode == 2 && EnableSuccubusSpellBooster, PoolEpoch, Owner)
  EndIf
  If Mode == 1
    Float StatRatio = Rank as Float * 0.100000001
    Float Power = Rank as Float * 5.0
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Int Wrote = 0
    If SKSE.GetPluginVersion("PSQ Appearance") >= 16777226
      Float[] Values = new Float[8]
      Values[0] = BH * StatRatio
      Values[1] = BM * StatRatio
      Values[2] = BS * StatRatio
      Values[3] = BC * StatRatio
      Values[4] = BU * Power / 100.0
      Values[5] = Power
      Values[6] = Rank * 3.0
      Values[7] = Power
      Wrote = PSQAppearance.SyncTransformRecords(PlayerRef, Self, Owner, PSQLoadEpoch, PoolEpoch, RankAbility, Values, RankPerk, 1.0 + Power / 100.0)
    EndIf
    If Wrote < 0
      Return
    ElseIf Wrote == 0
      RankAbility.SetNthEffectMagnitude(0, BH * StatRatio)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      RankAbility.SetNthEffectMagnitude(1, BM * StatRatio)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      RankAbility.SetNthEffectMagnitude(2, BS * StatRatio)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      RankAbility.SetNthEffectMagnitude(3, BC * StatRatio)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      RankAbility.SetNthEffectMagnitude(4, BU * Power / 100.0)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      RankAbility.SetNthEffectMagnitude(5, Power)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      RankAbility.SetNthEffectMagnitude(6, Rank as Float * 3.0)
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      RankAbility.SetNthEffectMagnitude(7, Rank as Float * 5.0)
      i = 0
      While i < 7
        If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
          Return
        EndIf
        RankPerk.SetNthEntryValue(i, 1, 1.0 + Power / 100.0)
        i += 1
      EndWhile
    EndIf
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    PlayerRef.AddSpell(RankAbility, False)
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    PlayerRef.AddPerk(RankPerk)
  ElseIf Mode == 2
    Int BarterRank = Rank
    If BarterRank > 8
      BarterRank = 8
    EndIf
    i = 1
    While i <= 8
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.SetContinuousOwnedSpell(Self.GetLegacyContinuousBarter(i), EnableFortifyBartar && i == BarterRank, PoolEpoch, Owner)
      i += 1
    EndWhile
    Self.SuccubusLevelUp(0.0)
  EndIf
  TransformBooster.SetValue(((Mode == 2 && IsHenshined && EnableSuccubusSpellBooster) as Int) as Float)
  Int Kept = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777226
    Kept = PSQAppearance.PreserveTransformPools(PlayerRef, Self, Owner, PSQLoadEpoch, PoolEpoch, OldHealth, OldMagicka, OldStamina)
  EndIf
  If Kept < 0
    Return
  ElseIf Kept == 0
    If OldHealth > 0.0 && !PlayerRef.IsDead()
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.PreserveSatiationCurrentValue("Health", OldHealth, PoolEpoch, Owner)
    EndIf
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Self.PreserveSatiationCurrentValue("Magicka", OldMagicka, PoolEpoch, Owner)
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Self.PreserveSatiationCurrentValue("Stamina", OldStamina, PoolEpoch, Owner)
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  StableAppliedContinuousMode = Mode
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  StableAppliedContinuousRank = Rank
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  StableAppliedContinuousHealth = BH
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  StableAppliedContinuousMagicka = BM
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  StableAppliedContinuousStamina = BS
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  StableAppliedContinuousCarry = BC
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  StableAppliedContinuousUnarmed = BU
  StatCachesMigrated = True
  ContinuousRecordSyncPending = False
  Debug.Trace("[PSQ Stats] continuous applied; mode=" + Mode + "; rank=" + Rank, 0)
  ContinuousSyncBusy = False
EndFunction

Function QueueRankUpAnimation(Int PreviousRank, Int NewRank)
  If !Self.IsRankUpAnimationEnabled()
    Return
  EndIf
  If NewRank <= PreviousRank || NewRank <= LastRankAnimation || PlayerIsSuccubus.GetValueInt() != 1 || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  If NewRank > PendingRankAnimation
    PendingRankAnimation = NewRank
    RankAnimationReadyAt = 0.0
  EndIf
  Debug.Trace(("[PSQFX] Rank-up queued; previous=" + PreviousRank as String) + "; new=" + NewRank as String, 0)
  Self.ProcessRankUpAnimation()
  Self.RequestRankAnimationRetry()
EndFunction

Function ProcessRankUpAnimation()
  If !Self.IsRankUpAnimationEnabled()
    PendingRankAnimation = 0
    RankAnimationPreviewPending = False
    Return
  EndIf
  If RankAnimationPlaybackBusy
    Return
  EndIf
  RankAnimationPlaybackBusy = True
  Self.ProcessRankUpAnimationCore()
  RankAnimationPlaybackBusy = False
EndFunction

Function ProcessRankUpAnimationCore()
  If !Self.IsRankUpAnimationEnabled()
    PendingRankAnimation = 0
    RankAnimationPreviewPending = False
    Return
  EndIf
  If PendingRankAnimation <= 0
    Return
  EndIf
  If RankAnimationReadyAt > Utility.GetCurrentRealTime() + 10.0
    RankAnimationReadyAt = Utility.GetCurrentRealTime() + 3.0
  EndIf
  If PlayerIsSuccubus.GetValueInt() != 1 || PlayerRef.IsDead() || UninstallPrepared || UninstallCleanupBusy
    PendingRankAnimation = 0
    Return
  EndIf
  If IsHenshinchu || AppearanceEditBusy || !PlayerRef.Is3DLoaded() || Utility.IsInMenuMode() || PlayerRef.HasKeywordString("SexLabActive") || PlayerRef.IsOnMount() || PlayerRef.IsSwimming()
    RankAnimationReadyAt = Utility.GetCurrentRealTime() + 3.0
    Return
  EndIf
  If SexLab != None
    If SexLab.IsActorActive(PlayerRef)
      RankAnimationReadyAt = Utility.GetCurrentRealTime() + 3.0
      Return
    EndIf
  EndIf
  If Utility.GetCurrentRealTime() < RankAnimationReadyAt
    Return
  EndIf
  Int Rank = PendingRankAnimation
  If Rank < 1
    Return
  EndIf
  If !Game.IsPluginInstalled("PSQ PlayerSuccubusQuest.esm")
    Debug.Trace("[PSQFX] Rank-up unavailable: PSQ PlayerSuccubusQuest.esm is not loaded", 1)
    PendingRankAnimation = 0
    If RankAnimationPreviewPending
      RankAnimationPreviewPending = False
      Debug.Notification("$PSQ_RankAnimationPreviewMissing")
    EndIf
    Return
  EndIf
  Int VisualID = 42012
  If Rank >= 8
    VisualID = 42016
  ElseIf Rank >= 5
    VisualID = 42014
  EndIf
  VisualEffect Motion = Game.GetFormFromFile(VisualID, "PSQ PlayerSuccubusQuest.esm") as VisualEffect
  If Motion != None
    If PendingRankAnimation == Rank
      PendingRankAnimation = 0
    EndIf
    Bool Preview = RankAnimationPreviewPending
    RankAnimationPreviewPending = False
    If !Preview && Rank > LastRankAnimation
      LastRankAnimation = Rank
    EndIf
    Motion.Stop(PlayerRef as ObjectReference)
    Motion.Play(PlayerRef as ObjectReference, 4.0, None)
    If Preview
      Debug.Notification("$PSQ_RankAnimationPreviewPlaying")
    EndIf
    Debug.Trace((("[PSQFX] Rank-up animation requested; rank=" + Rank as String) + "; preview=" + Preview as String) + "; relative-model=v2; visual=" + Motion as String, 0)
  Else
    Debug.Trace("[PSQFX] Rank-up visual cannot resolve; local ID=" + VisualID as String, 1)
    PendingRankAnimation = 0
    If RankAnimationPreviewPending
      RankAnimationPreviewPending = False
      Debug.Notification("$PSQ_RankAnimationPreviewMissing")
    EndIf
  EndIf
EndFunction

Function StopRankUpAnimation()
  RankAnimationPreviewPending = False
  RankAnimationRetryEpoch += 1
  RankAnimationRetryBusy = False
  If !Game.IsPluginInstalled("PSQ PlayerSuccubusQuest.esm")
    Return
  EndIf
  Int VisualID = 42012
  While VisualID <= 42016
    VisualEffect Motion = Game.GetFormFromFile(VisualID, "PSQ PlayerSuccubusQuest.esm") as VisualEffect
    If Motion != None
      Motion.Stop(PlayerRef as ObjectReference)
    EndIf
    VisualID += 2
  EndWhile
EndFunction

Function RequestRankAnimationRetry()
  If !Self.IsRankUpAnimationEnabled()
    Return
  EndIf
  If PendingRankAnimation <= 0
    Return
  EndIf
  Self.RegisterForModEvent("PSQ_RankAnimationRetry", "OnPSQRankAnimationRetry")
  Self.SendModEvent("PSQ_RankAnimationRetry", "", 0.0)
EndFunction

Function OnPSQRankAnimationRetry(String EventName, String Arg, Float NumberArg, Form Sender)
  If (Sender != Self as Form) || RankAnimationRetryBusy
    Return
  EndIf
  RankAnimationRetryBusy = True
  Int Epoch = RankAnimationRetryEpoch
  Int Tries = 0
  If RankAnimationPreviewPending
    Utility.Wait(1.0)
  EndIf
  While PendingRankAnimation > 0 && Tries < 120 && !UninstallPrepared && !UninstallCleanupBusy && Epoch == RankAnimationRetryEpoch
    Utility.Wait(0.5)
    If Epoch == RankAnimationRetryEpoch
      Self.ProcessRankUpAnimation()
    EndIf
    Tries += 1
  EndWhile
  If Epoch == RankAnimationRetryEpoch
    If PendingRankAnimation > 0
      Debug.Trace(((("[PSQFX] Rank-up still deferred: transform=" + IsHenshinchu as String) + "; appearance=" + AppearanceEditBusy as String) + "; menu=" + Utility.IsInMenuMode() as String) + "; SexLab=" + PlayerRef.HasKeywordString("SexLabActive") as String, 0)
      If RankAnimationPreviewPending
        Debug.Notification("$PSQ_RankAnimationPreviewDeferred")
      EndIf
    EndIf
    RankAnimationRetryBusy = False
  EndIf
EndFunction

Bool Function PreviewRankUpAnimation()
  If !Self.IsRankUpAnimationEnabled()
    Debug.Notification("$PSQ_RankAnimationSuspendedInfo")
    Return False
  EndIf
  If PlayerIsSuccubus.GetValueInt() != 1 || UninstallPrepared || UninstallCleanupBusy
    Debug.Notification("$PSQ_RankAnimationPreviewInactive")
    Return False
  EndIf
  If !Game.IsPluginInstalled("PSQ PlayerSuccubusQuest.esm")
    Debug.Notification("$PSQ_RankAnimationPreviewMissing")
    Return False
  EndIf
  Int Rank = SuccubusRank.GetValueInt()
  If Rank < 1
    Rank = 1
  ElseIf Rank > 10
    Rank = 10
  EndIf
  If Rank > PendingRankAnimation
    PendingRankAnimation = Rank
  EndIf
  RankAnimationPreviewPending = True
  RankAnimationReadyAt = 0.0
  Self.RequestRankAnimationRetry()
  Return True
EndFunction

Bool Function IsStorageRankUnlocked()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.StorageUnlocked34(Self)
  EndIf
  Return PlayerIsSuccubus.GetValueInt() == 1 && SuccubusRank.GetValueInt() >= 3
EndFunction

String Function GetFixedSuccubusTattooTexture(Int Choice)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777234
    Return PSQAppearance.TattooTexture(Choice, SuccubusRank.GetValueInt())
  EndIf
  If Choice == 19
    Return Self.GetEvolvingSuccubusTattooTexture(SuccubusRank.GetValueInt())
  EndIf
  If Choice == 9
    Return "PSQ\\Overlays\\RankTattoos\\Rank01.dds"
  EndIf
  If Choice == 10
    Return "PSQ\\Overlays\\RankTattoos\\Rank02.dds"
  EndIf
  If Choice == 11
    Return "PSQ\\Overlays\\RankTattoos\\Rank03.dds"
  EndIf
  If Choice == 12
    Return "PSQ\\Overlays\\RankTattoos\\Rank04.dds"
  EndIf
  If Choice == 13
    Return "PSQ\\Overlays\\RankTattoos\\Rank05.dds"
  EndIf
  If Choice == 14
    Return "PSQ\\Overlays\\RankTattoos\\Rank06.dds"
  EndIf
  If Choice == 15
    Return "PSQ\\Overlays\\RankTattoos\\Rank07.dds"
  EndIf
  If Choice == 16
    Return "PSQ\\Overlays\\RankTattoos\\Rank08.dds"
  EndIf
  If Choice == 17
    Return "PSQ\\Overlays\\RankTattoos\\Rank09.dds"
  EndIf
  If Choice == 18
    Return "PSQ\\Overlays\\RankTattoos\\Rank10.dds"
  EndIf
  If Choice < 1 || Choice > 8
    Return Self.GetEvolvingSuccubusTattooTexture(SuccubusRank.GetValueInt())
  EndIf
  If Choice == 1
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_01.dds"
  EndIf
  If Choice == 2
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_02.dds"
  EndIf
  If Choice == 3
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_03.dds"
  EndIf
  If Choice == 4
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_04.dds"
  EndIf
  If Choice == 5
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_05.dds"
  EndIf
  If Choice == 6
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_06.dds"
  EndIf
  If Choice == 7
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_07.dds"
  EndIf
  If Choice == 8
    Return "PSQ\\Overlays\\LewdMarks\\3BA_LM_08.dds"
  EndIf
  Return Self.GetEvolvingSuccubusTattooTexture(SuccubusRank.GetValueInt())
EndFunction

Bool Function SetSuccubusThrallTattoo(Int Slot, Int Choice)
  Actor Target = Self.GetSuccubusThrall(Slot)
  If Target == None || !Self.IsSuccubusThrall(Target) || Choice < 1 || Choice > 18 || UninstallPrepared || UninstallCleanupBusy || ThrallConversionBusy || !Self.HasNiOverrideRuntime()
    Return False
  EndIf
  If Choice == Self.GetSuccubusThrallTattooSelection(Target)
    Self.ApplySuccubusThrallTattoo(Target)
    Return True
  EndIf
  Self.RestoreSuccubusThrallTattoo(Target)
  storageutil.SetIntValue(Target as Form, "PSQ_ThrallTattooSelection", Choice)
  Self.ApplySuccubusThrallTattoo(Target)
  Return True
EndFunction

Int Function GetSuccubusThrallTattooSelection(Actor Target)
  Return storageutil.GetIntValue(Target as Form, "PSQ_ThrallTattooSelection", 0)
EndFunction

Function SaveThrallTattooProperty(Actor Target, Bool Female, String Node, Int PSQKey, Int Index, Int Kind)
  String Saved = "PSQ_ThrallTattoo_" + PSQKey as String
  Bool Present = nioverride.HasNodeOverride(Target as ObjectReference, Female, Node, PSQKey, Index)
  storageutil.SetIntValue(Target as Form, Saved + "_Present", Present as Int)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Int Action = PSQAppearance.ThrallPropertyAction(True, False, Present as Int, Kind)
    If Action == 1
      StorageUtil.SetStringValue(Target, Saved, NiOverride.GetNodeOverrideString(Target, Female, Node, PSQKey, Index))
    ElseIf Action == 2
      StorageUtil.SetIntValue(Target, Saved, NiOverride.GetNodeOverrideInt(Target, Female, Node, PSQKey, Index))
    ElseIf Action == 3
      StorageUtil.SetFloatValue(Target, Saved, NiOverride.GetNodeOverrideFloat(Target, Female, Node, PSQKey, Index))
    EndIf
    Return
  EndIf
  If Present
    If Kind == 0
      storageutil.SetStringValue(Target as Form, Saved, nioverride.GetNodeOverrideString(Target as ObjectReference, Female, Node, PSQKey, Index))
    ElseIf Kind == 1
      storageutil.SetIntValue(Target as Form, Saved, nioverride.GetNodeOverrideInt(Target as ObjectReference, Female, Node, PSQKey, Index))
    Else
      storageutil.SetFloatValue(Target as Form, Saved, nioverride.GetNodeOverrideFloat(Target as ObjectReference, Female, Node, PSQKey, Index))
    EndIf
  EndIf
EndFunction

Function RestoreThrallTattooProperty(Actor Target, Bool Female, String Node, Int PSQKey, Int Index, Int Kind, Bool Restore)
  String Saved = "PSQ_ThrallTattoo_" + PSQKey as String
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Int Action = PSQAppearance.ThrallPropertyAction(False, Restore, StorageUtil.GetIntValue(Target, Saved + "_Present", -1), Kind)
    If Action == 1
      NiOverride.AddNodeOverrideString(Target, Female, Node, PSQKey, Index, StorageUtil.GetStringValue(Target, Saved, ""), True)
    ElseIf Action == 2
      NiOverride.AddNodeOverrideInt(Target, Female, Node, PSQKey, Index, StorageUtil.GetIntValue(Target, Saved, 0), True)
    ElseIf Action == 3
      NiOverride.AddNodeOverrideFloat(Target, Female, Node, PSQKey, Index, StorageUtil.GetFloatValue(Target, Saved, 0.0), True)
    ElseIf Action == 4
      NiOverride.RemoveNodeOverride(Target, Female, Node, PSQKey, Index)
    EndIf
  Else
    If Restore
      If storageutil.GetIntValue(Target as Form, Saved + "_Present", 0) == 1
        If Kind == 0
          nioverride.AddNodeOverrideString(Target as ObjectReference, Female, Node, PSQKey, Index, storageutil.GetStringValue(Target as Form, Saved, ""), True)
        ElseIf Kind == 1
          nioverride.AddNodeOverrideInt(Target as ObjectReference, Female, Node, PSQKey, Index, storageutil.GetIntValue(Target as Form, Saved, 0), True)
        Else
          nioverride.AddNodeOverrideFloat(Target as ObjectReference, Female, Node, PSQKey, Index, storageutil.GetFloatValue(Target as Form, Saved, 0.0), True)
        EndIf
      Else
        nioverride.RemoveNodeOverride(Target as ObjectReference, Female, Node, PSQKey, Index)
      EndIf
    EndIf
  EndIf
  storageutil.UnsetIntValue(Target as Form, Saved + "_Present")
  storageutil.UnsetStringValue(Target as Form, Saved)
  storageutil.UnsetIntValue(Target as Form, Saved)
  storageutil.UnsetFloatValue(Target as Form, Saved)
EndFunction

Function ApplySuccubusThrallTattoo(Actor Target)
  If Target == None || !Self.IsSuccubusThrall(Target) || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  Int Choice = Self.GetSuccubusThrallTattooSelection(Target)
  If Choice < 1 || Choice > 18
    Choice = Utility.RandomInt(1, 18)
    storageutil.SetIntValue(Target as Form, "PSQ_ThrallTattooSelection", Choice)
  EndIf
  If !Self.HasNiOverrideRuntime()
    Return
  EndIf
  If !Target.Is3DLoaded()
    storageutil.SetIntValue(Target, "PSQ_ThrallTattooDeferred", 1)
    Return
  EndIf
  Bool Female = Target.GetLeveledActorBase().GetSex() == 1
  String OriginalTexture = Self.GetFixedSuccubusTattooTexture(Choice)
  String Texture = OriginalTexture
  Bool UseUBE = psqracecompatibility.IsUBEActor(Target)
  If UseUBE && !Female
    Self.RestoreSuccubusThrallTattoo(Target)
    storageutil.SetIntValue(Target as Form, "PSQ_ThrallTattooSelection", Choice)
    Return
  EndIf
  If UseUBE
    Texture = Self.GetUBEBodyTattooTexture(OriginalTexture)
  EndIf
  If !nioverride.HasOverlays(Target)
    nioverride.AddOverlays(Target)
  EndIf
  String LastTexture = storageutil.GetStringValue(Target as Form, "PSQ_ThrallTattooTexture", OriginalTexture)
  String Node = storageutil.GetStringValue(Target as Form, "PSQ_ThrallTattooNode", "")
  Bool NativeTattoo = SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
  If !NativeTattoo && Node != "" && !netimmerse.HasNode(Target, Node, False)
    storageutil.SetIntValue(Target, "PSQ_ThrallTattooDeferred", 1)
    Return
  EndIf
  Bool SavedFemale = storageutil.GetIntValue(Target, "PSQ_ThrallTattooFemale", Female as Int) == 1
  If NativeTattoo
    String CurrentTexture = ""
    Bool NodeLoaded = False
    If Node != ""
      NodeLoaded = NetImmerse.HasNode(Target, Node, False)
      CurrentTexture = NiOverride.GetNodeOverrideString(Target, SavedFemale, Node, 9, 0)
    EndIf
    Int Decision = PSQAppearance.ThrallOverlayPolicy(False, Node, True, NodeLoaded, SavedFemale == Female, LastTexture, CurrentTexture)
    If Decision == 0
      StorageUtil.SetIntValue(Target, "PSQ_ThrallTattooDeferred", 1)
      Return
    ElseIf Decision == 1 || Decision == 2
      If !Self.BridgeThrallOverlayReceipt(Target, SavedFemale, Node, False, Decision == 2, LastTexture)
        StorageUtil.SetIntValue(Target, "PSQ_ThrallTattooDeferred", 1)
        Return
      EndIf
      StorageUtil.UnsetStringValue(Target, "PSQ_ThrallTattooNode")
      Node = ""
    EndIf
  Else
    If Node != "" && (SavedFemale != Female || nioverride.GetNodeOverrideString(Target as ObjectReference, SavedFemale, Node, 9, 0) != LastTexture)
      Bool Owned = nioverride.GetNodeOverrideString(Target as ObjectReference, SavedFemale, Node, 9, 0) == LastTexture
      Self.RestoreThrallTattooProperty(Target, SavedFemale, Node, 9, 0, 0, Owned)
      Self.RestoreThrallTattooProperty(Target, SavedFemale, Node, 7, -1, 1, Owned)
      Self.RestoreThrallTattooProperty(Target, SavedFemale, Node, 8, -1, 2, Owned)
      Self.RestoreThrallTattooProperty(Target, SavedFemale, Node, 0, -1, 1, Owned)
      Self.RestoreThrallTattooProperty(Target, SavedFemale, Node, 1, -1, 2, Owned)
      storageutil.UnsetStringValue(Target as Form, "PSQ_ThrallTattooNode")
      Node = ""
    EndIf
  EndIf
  If Node == ""
    Int Slot = 0
    Int Limit = nioverride.GetNumBodyOverlays()
    While Slot < Limit && Node == ""
      String Candidate = ("Body [Ovl" + Slot as String) + "]"
      If netimmerse.HasNode(Target, Candidate, False)
        String Existing = nioverride.GetNodeOverrideString(Target as ObjectReference, Female, Candidate, 9, 0)
        String Live = nioverride.GetNodePropertyString(Target as ObjectReference, False, Candidate, 9, 0)
        If (NativeTattoo && PSQAppearance.ThrallOverlayFree(Existing, Live)) || (!NativeTattoo && Self.IsEmptyPlayerTattooTexture(Existing) && Self.IsEmptyPlayerTattooTexture(Live))
          Node = Candidate
        EndIf
      EndIf
      Slot += 1
    EndWhile
    If Node == ""
      If storageutil.GetIntValue(Target, "PSQ_ThrallTattooDeferred", 0) == 0
        Debug.Trace("[PSQ] Thrall tattoo deferred: no free, loaded body overlay for " + Target as String, 0)
      EndIf
      storageutil.SetIntValue(Target, "PSQ_ThrallTattooDeferred", 1)
      Return
    EndIf
    If NativeTattoo
      Self.BridgeThrallOverlayReceipt(Target, Female, Node, True, False, "")
    Else
      Self.SaveThrallTattooProperty(Target, Female, Node, 9, 0, 0)
      Self.SaveThrallTattooProperty(Target, Female, Node, 7, -1, 1)
      Self.SaveThrallTattooProperty(Target, Female, Node, 8, -1, 2)
      Self.SaveThrallTattooProperty(Target, Female, Node, 0, -1, 1)
      Self.SaveThrallTattooProperty(Target, Female, Node, 1, -1, 2)
    EndIf
    storageutil.SetStringValue(Target as Form, "PSQ_ThrallTattooNode", Node)
    storageutil.SetIntValue(Target as Form, "PSQ_ThrallTattooFemale", Female as Int)
  EndIf
  StorageUtil.FormListRemove(PlayerRef, "PSQ_ThrallPendingTattooRestores", Target, True)
  storageutil.UnsetIntValue(Target, "PSQ_ThrallTattooDeferred")
  storageutil.SetStringValue(Target as Form, "PSQ_ThrallTattooTexture", Texture)
  nioverride.AddNodeOverrideString(Target as ObjectReference, Female, Node, 9, 0, Texture, True)
  nioverride.AddNodeOverrideInt(Target as ObjectReference, Female, Node, 7, -1, -1, True)
  nioverride.AddNodeOverrideFloat(Target as ObjectReference, Female, Node, 8, -1, 1.0, True)
  nioverride.AddNodeOverrideInt(Target as ObjectReference, Female, Node, 0, -1, 0, True)
  nioverride.AddNodeOverrideFloat(Target as ObjectReference, Female, Node, 1, -1, 0.0, True)
  nioverride.ApplyNodeOverrides(Target as ObjectReference)
EndFunction

Function RestoreSuccubusThrallTattoo(Actor Target)
  If Target == None
    Return
  EndIf
  String Node = storageutil.GetStringValue(Target as Form, "PSQ_ThrallTattooNode", "")
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Bool HasRuntime = Self.HasNiOverrideRuntime()
    Bool SavedFemale = StorageUtil.GetIntValue(Target, "PSQ_ThrallTattooFemale", 1) == 1
    String Expected = StorageUtil.GetStringValue(Target, "PSQ_ThrallTattooTexture", Self.GetFixedSuccubusTattooTexture(Self.GetSuccubusThrallTattooSelection(Target)))
    String Actual = ""
    Bool NodeQueryable = False
    If HasRuntime && Target.Is3DLoaded() && Node != ""
      NodeQueryable = NetImmerse.HasNode(Target, Node, False)
    EndIf
    If NodeQueryable
      Actual = NiOverride.GetNodeOverrideString(Target, SavedFemale, Node, 9, 0)
    EndIf
    Int Decision = PSQAppearance.ThrallOverlayPolicy(True, Node, HasRuntime, NodeQueryable, True, Expected, Actual)
    If Decision == 0
      StorageUtil.FormListAdd(PlayerRef, "PSQ_ThrallPendingTattooRestores", Target, False)
      StorageUtil.SetIntValue(Target, "PSQ_ThrallTattooDeferred", 2)
      Return
    ElseIf Decision == 1 || Decision == 2
      If !Self.BridgeThrallOverlayReceipt(Target, SavedFemale, Node, False, Decision == 2, Expected)
        StorageUtil.FormListAdd(PlayerRef, "PSQ_ThrallPendingTattooRestores", Target, False)
        StorageUtil.SetIntValue(Target, "PSQ_ThrallTattooDeferred", 2)
        Return
      EndIf
      If Decision == 2 && Target.Is3DLoaded()
        NiOverride.ApplyNodeOverrides(Target)
      EndIf
    EndIf
  Else
    If Node != "" && !Self.HasNiOverrideRuntime()
      Return
    EndIf
    If Node != ""
      Bool Female = storageutil.GetIntValue(Target as Form, "PSQ_ThrallTattooFemale", 1) == 1
      String DefaultTexture = Self.GetFixedSuccubusTattooTexture(Self.GetSuccubusThrallTattooSelection(Target))
      String Texture = storageutil.GetStringValue(Target as Form, "PSQ_ThrallTattooTexture", DefaultTexture)
      Bool Owned = nioverride.GetNodeOverrideString(Target as ObjectReference, Female, Node, 9, 0) == Texture
      Self.RestoreThrallTattooProperty(Target, Female, Node, 9, 0, 0, Owned)
      Self.RestoreThrallTattooProperty(Target, Female, Node, 7, -1, 1, Owned)
      Self.RestoreThrallTattooProperty(Target, Female, Node, 8, -1, 2, Owned)
      Self.RestoreThrallTattooProperty(Target, Female, Node, 0, -1, 1, Owned)
      Self.RestoreThrallTattooProperty(Target, Female, Node, 1, -1, 2, Owned)
      If Owned && Target.Is3DLoaded()
        nioverride.ApplyNodeOverrides(Target as ObjectReference)
      EndIf
    EndIf
  EndIf
  StorageUtil.FormListRemove(PlayerRef, "PSQ_ThrallPendingTattooRestores", Target, True)
  storageutil.UnsetStringValue(Target as Form, "PSQ_ThrallTattooNode")
  storageutil.UnsetStringValue(Target as Form, "PSQ_ThrallTattooTexture")
  storageutil.UnsetIntValue(Target, "PSQ_ThrallTattooDeferred")
  storageutil.UnsetIntValue(Target as Form, "PSQ_ThrallTattooFemale")
  storageutil.UnsetIntValue(Target as Form, "PSQ_ThrallTattooSelection")
EndFunction

Armor Function GetTransformPartArmor(Int Part)
  Return Self.GetTransformPartArmor39(Part)
EndFunction

Bool Function GetTransformPartEnabled(Int Part)
  If !Self.IsTransformPartSelected(Part)
    Return False
  EndIf
  Return Self.CanUseResolvedTransformPart(Part, Self.GetTransformPartArmor(Part))
EndFunction

Bool Function IsTransformPartSelected(Int Part)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.PartSelected34(Self, Part)
  EndIf
  If Part == 0
    Return HenshinCuirass
  ElseIf Part == 1
    Return HenshinBoots
  ElseIf Part == 2
    Return HenshinGloves
  ElseIf Part == 3
    Return HenshinHorn
  ElseIf Part == 4
    Return HenshinTail
  EndIf
  Return False
EndFunction

Bool Function CanUseResolvedTransformPart(Int Part, Armor Item)
  If Item == None
    Return False
  EndIf
  If Part >= 0 && Part <= 2 && psqracecompatibility.ShouldPreserveAppearance(PlayerRef)
    Return PSQDXUBE.SupportsItem(PlayerRef, Item)
  EndIf
  Return True
EndFunction

Function EnsureTransformPartSources()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If PSQAppearance.EnsureSources34(Self)
      Return
    EndIf
  EndIf
  If TransformPartSources as Bool && TransformPartSources.Length == 5
    Return
  EndIf
  Int[] Choices = new Int[5]
  Int Part = 0
  While Part < 5
    Int Fallback = SuccubusOutfitSelection
    If Fallback < 1 || Fallback > 8
      Fallback = 4
    EndIf
    Choices[Part] = Fallback
    Armor Current = Self.GetTransformPartArmor(Part)
    Int set = 1
    While set <= 8
      If Current != None && Current == Self.GetCachedOutfitPart(set, Part, -1, False)
        Choices[Part] = set
        set = 8
      EndIf
      set += 1
    EndWhile
    If Current != None && Current == Self.GetCachedOutfitPart(100, Part, -1, False)
      Choices[Part] = 100
    EndIf
    Part += 1
  EndWhile
  TransformPartSources = Choices
EndFunction

Int Function GetTransformPartSource(Int Part)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Int NativeSource = PSQAppearance.PartSource34(Self, Part)
    If NativeSource != 0x80000000
      Return NativeSource
    EndIf
  EndIf
  Self.EnsureTransformPartSources()
  If Part < 0 || Part > 4
    Return 4
  EndIf
  If Part == 3 && OptionalHornSelectedKey != ""
    Self.EnsureOptionalHornCatalog()
    If OptionalHornCatalogReady
      Int Found = OptionalHornKeys.find(OptionalHornSelectedKey, 0)
      If Found >= 0 && Found < OptionalHornCount
        Return Found + 9
      EndIf
    EndIf
  EndIf
  Return TransformPartSources[Part]
EndFunction

Int Function GetTransformPartSelection(Int Part)
  If !Self.GetTransformPartEnabled(Part)
    Return 0
  EndIf
  Return Self.GetTransformPartSource(Part)
EndFunction

Bool Function SetIndependentTransformPart(Int Part, Int Choice)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.ChangeOutfitPartFromMenu(Part, Choice)
  EndIf
  ; Shinano is now original-only. Reject before acquiring the appearance lock.
  If Choice > 0 && !Self.CanUseTransformOutfitChoice(Part, Choice)
    Return False
  EndIf
  Int Limit = 8
  If Part == 3
    Limit += Self.GetOptionalHornCount()
  EndIf
  If Part < 0 || Part > 4 || Choice < 0 || (Choice > Limit && Choice != 100) || !Self.BeginAppearanceEdit()
    Return False
  EndIf
  Int Owner = AppearanceOperationId
  If IsHenshinchu || IsHenshined && Self.GTSoftbodyOwnsAppearance()
    Self.EndAppearanceEdit(Owner)
    Return False
  EndIf
  Self.EnsureTransformPartSources()
  Armor Previous = Self.GetTransformPartArmor(Part)
  Bool WasEnabled = Self.IsTransformPartSelected(Part) && Self.CanUseResolvedTransformPart(Part, Previous)
  Armor Next = Previous
  If Choice > 0
    Next = Self.GetCachedOutfitPart(Choice, Part, Owner, True)
    If Next == None
      Self.EndAppearanceEdit(Owner)
      Return False
    EndIf
  EndIf
  Bool SameSource = Self.GetTransformPartSource(Part) == Choice
  If WasEnabled == (Choice > 0) && Previous == Next && (Choice == 0 || SameSource)
    Self.EndAppearanceEdit(Owner)
    Return True
  EndIf
  Int SettingResult = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    SettingResult = PSQAppearance.CommitOutfitChoice(PlayerRef, Self, PlayerAppearanceRace, Owner, PSQLoadEpoch, Part, Choice, Next)
    If SettingResult < 0
      Self.EndAppearanceEdit(Owner)
      Return False
    EndIf
  EndIf
  If SettingResult == 0
    If Choice > 0
      If Owner != AppearanceOperationId || (True as Bool && !AppearanceEditBusy)
        Return False
      EndIf
      If Choice <= 8 || Choice == 100
        TransformPartSources[Part] = Choice
      EndIf
    EndIf
    If Part == 0
      If Owner != AppearanceOperationId || (True as Bool && !AppearanceEditBusy)
        Return False
      EndIf
      PSQSuccubusCuirass = Next
      If Owner != AppearanceOperationId || (True as Bool && !AppearanceEditBusy)
        Return False
      EndIf
      HenshinCuirass = Choice > 0
    ElseIf Part == 1
      If Owner != AppearanceOperationId || (True as Bool && !AppearanceEditBusy)
        Return False
      EndIf
      PSQSuccubusBoots = Next
      If Owner != AppearanceOperationId || (True as Bool && !AppearanceEditBusy)
        Return False
      EndIf
      HenshinBoots = Choice > 0
    ElseIf Part == 2
      If Owner != AppearanceOperationId || (True as Bool && !AppearanceEditBusy)
        Return False
      EndIf
      PSQSuccubusGauntlets = Next
      If Owner != AppearanceOperationId || (True as Bool && !AppearanceEditBusy)
        Return False
      EndIf
      HenshinGloves = Choice > 0
    ElseIf Part == 3
      If Owner != AppearanceOperationId || (True as Bool && !AppearanceEditBusy)
        Return False
      EndIf
      If Choice > 8 && Choice != 100
        OptionalHornSelectedKey = OptionalHornKeys[Choice - 9]
      Else
        OptionalHornSelectedKey = ""
      EndIf
      PSQSuccubusHorns = Next
      If Owner != AppearanceOperationId || (True as Bool && !AppearanceEditBusy)
        Return False
      EndIf
      HenshinHorn = Choice > 0
    ElseIf Part == 4
      If Owner != AppearanceOperationId || (True as Bool && !AppearanceEditBusy)
        Return False
      EndIf
      PSQSuccubusTail = Next
      If Owner != AppearanceOperationId || (True as Bool && !AppearanceEditBusy)
        Return False
      EndIf
      HenshinTail = Choice > 0
    EndIf
  EndIf
  If IsHenshined
    Self.ApplyPSQOutfitBodyModels(HenshinBody, Owner, True)
    If WasEnabled && Previous != None && (Choice == 0 || Previous != Next)
      Self.RemoveTransformEquipmentItem(Previous, Owner, True)
    EndIf
    If Choice > 0
      Self.EnsurePlayerTransformEquipment(Next, Owner, True)
    EndIf
    If Owner != AppearanceOperationId || (True as Bool && !AppearanceEditBusy)
      Return False
    EndIf
    PlayerRef.QueueNiNodeUpdate()
    Self.ApplySelectedSuccubusEyes(Owner, True)
  EndIf
  Self.EndAppearanceEdit(Owner)
  Return True
EndFunction

String[] Function GetThrallSkillNames()
  If !DrainSkillNames || DrainSkillNames.Length != 18
    DrainSkillNames = new String[18]
    DrainSkillNames[0] = "OneHanded"
    DrainSkillNames[1] = "TwoHanded"
    DrainSkillNames[2] = "Marksman"
    DrainSkillNames[3] = "Block"
    DrainSkillNames[4] = "Smithing"
    DrainSkillNames[5] = "HeavyArmor"
    DrainSkillNames[6] = "LightArmor"
    DrainSkillNames[7] = "Pickpocket"
    DrainSkillNames[8] = "Lockpicking"
    DrainSkillNames[9] = "Sneak"
    DrainSkillNames[10] = "Alchemy"
    DrainSkillNames[11] = "Speechcraft"
    DrainSkillNames[12] = "Alteration"
    DrainSkillNames[13] = "Conjuration"
    DrainSkillNames[14] = "Destruction"
    DrainSkillNames[15] = "Illusion"
    DrainSkillNames[16] = "Restoration"
    DrainSkillNames[17] = "Enchanting"
  EndIf
  Return DrainSkillNames
EndFunction

Function InitializeThrallSkillGrowth(Actor Target)
  If Target == None || storageutil.FloatListCount(Target as Form, "PSQ_ThrallSkillBaseline") == 18
    Return
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Float[] Baseline = PSQAppearance.ThrallInitialSkills(Target)
    If Baseline && Baseline.Length == 18
      StorageUtil.FloatListCopy(Target, "PSQ_ThrallSkillBaseline", Baseline)
      Return
    EndIf
  EndIf
  String[] Skills = Self.GetThrallSkillNames()
  storageutil.FloatListResize(Target as Form, "PSQ_ThrallSkillBaseline", 18, 0.0)
  Int i = 0
  While i < 18
    storageutil.FloatListSet(Target as Form, "PSQ_ThrallSkillBaseline", i, Target.GetBaseActorValue(Skills[i]))
    i += 1
  EndWhile
EndFunction

Function SyncThrallSkillGrowth(Actor Target)
  If Target == None || !Self.IsSuccubusThrall(Target) || Target.IsDead() || !Target.Is3DLoaded() || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  If ThrallSkillGrowthBusy
    Return
  EndIf
  ThrallSkillGrowthBusy = True
  Int Owner = ThrallSkillGrowthGeneration
  Self.InitializeThrallSkillGrowth(Target)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    Float[] OldLevels = storageutil.FloatListToArray(Target, "PSQ_ThrallSkillBaseline")
    Float[] NewLevels = PSQAppearance.ThrallSkillTick(Self, Self.GetSuccubusThrallQuest(), Target, Owner, OldLevels)
    If NewLevels && NewLevels.Length == 18
      If Owner == ThrallSkillGrowthGeneration
        storageutil.FloatListCopy(Target, "PSQ_ThrallSkillBaseline", NewLevels)
        ThrallSkillGrowthBusy = False
      EndIf
      Return
    EndIf
  EndIf
  String[] Skills = Self.GetThrallSkillNames()
  Int i = 0
  While i < 18
    If Owner != ThrallSkillGrowthGeneration || UninstallPrepared || UninstallCleanupBusy
      Return
    EndIf
    Float Current = Target.GetBaseActorValue(Skills[i])
    Float Previous = storageutil.FloatListGet(Target as Form, "PSQ_ThrallSkillBaseline", i)
    Float Gain = Current - Previous
    If Gain > 0.0001 && Current < 100.0
      Float Bonus = Gain * 0.5
      If SKSE.GetPluginVersion("PSQ Appearance") >= 16777230
        Bonus = PSQAppearance.ThrallSkillBonus(Current, Previous)
      ElseIf Current + Bonus > 100.0
        Bonus = 100.0 - Current
      EndIf
      If Owner != ThrallSkillGrowthGeneration
        Return
      EndIf
      storageutil.FloatListSet(Target as Form, "PSQ_ThrallSkillBaseline", i, Current + Bonus)
      If Owner != ThrallSkillGrowthGeneration
        Return
      EndIf
      Target.ModActorValue(Skills[i], Bonus)
      Current = Target.GetBaseActorValue(Skills[i])
    EndIf
    If Owner != ThrallSkillGrowthGeneration
      Return
    EndIf
    storageutil.FloatListSet(Target as Form, "PSQ_ThrallSkillBaseline", i, Current)
    i += 1
  EndWhile
  If Owner == ThrallSkillGrowthGeneration
    ThrallSkillGrowthBusy = False
  EndIf
EndFunction

Function StartThrallSkillMonitor(Actor Target)
  Int i = 0
  Quest Holder = Self.GetSuccubusThrallQuest()
  If Target == None || Holder == None
    Return
  EndIf
  While i < 4
    ReferenceAlias Seat = Holder.GetAlias(i) as ReferenceAlias
    If Seat != None && Seat.GetActorReference() == Target
      psqthralleyesaliasscript Monitor = Seat as psqthralleyesaliasscript
      If Monitor != None
        Monitor.StartSkillMonitor()
      EndIf
      Return
    EndIf
    i += 1
  EndWhile
EndFunction

Function StopThrallSkillMonitor(Actor Target)
  Int i = 0
  Quest Holder = Self.GetSuccubusThrallQuest()
  If Target == None || Holder == None
    Return
  EndIf
  While i < 4
    ReferenceAlias Seat = Holder.GetAlias(i) as ReferenceAlias
    If Seat != None && Seat.GetActorReference() == Target
      Seat.UnregisterForUpdate()
      Return
    EndIf
    i += 1
  EndWhile
EndFunction

Form[] Function GetTransformProtectedArmor()
  Return Self.GetProtectedArmor42()
EndFunction

Bool Function MissingRequiredTail42(Armor Item)
  Return Item == None && Self.GetTransformPartSource(4) != 2
EndFunction

Form[] Function GetProtectedArmor42()
  Form[] Items
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777258
    Items = PSQAppearance.ReadProtectedArmor42(PlayerRef)
    If Items && Items.Length == 13
      Return Items
    EndIf
  EndIf
  Items = new Form[13]
  If Self.CanUseGTSoftbody()
    String Owner = "HDT SMP Object - Simple.esp"
    Items[0] = Game.GetFormFromFile(2053, Owner)
    Items[1] = Game.GetFormFromFile(2080, Owner)
    Int i = 0
    While i < 6
      Items[i + 2] = Game.GetFormFromFile(2058 + i, Owner)
      i += 1
    EndWhile
    Items[8] = Game.GetFormFromFile(2074, Owner)
    Items[9] = Game.GetFormFromFile(2103, Owner)
  EndIf
  If psqracecompatibility.IsUBEActor(PlayerRef)
    If psqracecompatibility.HasUBE()
      Items[10] = Game.GetFormFromFile(500951, "UBE_AllRace.esp")
    EndIf
    Armor Slot53 = PlayerRef.GetWornForm(8388608) as Armor
    If psqracecompatibility.IsUBEEquipment(Slot53)
      Items[11] = Slot53
    EndIf
    Armor Slot52 = PlayerRef.GetWornForm(4194304) as Armor
    If psqracecompatibility.IsUBEEquipment(Slot52)
      Items[12] = Slot52
    EndIf
  EndIf
  Return Items
EndFunction

Bool Function HasOriginalTransformSkinColor()
  Return TransformSkinOriginalSaved || OrgSkinColor != 0
EndFunction

Int Function ComposeTransformSkinColor(Int Color, Int Alpha)
  If Alpha < 0
    Alpha = 0
  ElseIf Alpha > 255
    Alpha = 255
  EndIf
  Return colorcomponent.SetAlpha(Color, Alpha)
EndFunction

Bool Function ApplyTransformSkinColor(Bool CaptureOriginal, Int Owner, Bool RequireBusy)
  Self.SyncPlayerAppearanceRace()
  If psqracecompatibility.ShouldPreserveAppearance(PlayerRef)
    Return False
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  If !IsHenshined || !HenshinSkin || Game.GetNumTintsByType(6) <= 0
    Return False
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Int Load = PSQLoadEpoch
    Int[] Plan = PSQAppearance.SkinTintRequest(PlayerRef,Self,PlayerAppearanceRace,Owner,Load,RequireBusy,False,CaptureOriginal,Game.GetTintMaskColor(6,0))
    If Plan && Plan.Length == 2 && Plan[0] != 0
      If Plan[0] < 0 || !Self.IsAppearanceOperationCurrent(Owner,RequireBusy)
        Return False
      EndIf
      Game.SetTintMaskColor(Plan[1],6,0)
      If Game.GetTintMaskColor(6,0) != Plan[1]
        Debug.Notification("肤色写入失败，原肤色备份已保留。")
        Return False
      EndIf
      If !Self.IsAppearanceOperationCurrent(Owner,RequireBusy)
        Return False
      EndIf
      Game.UpdateTintMaskColors()
      Return Self.IsEquipmentRecoveryCurrent(Owner,RequireBusy,Load)
    EndIf
  EndIf
  If !TransformSkinOriginalSaved
    If OrgSkinColor != 0
      If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return False
      EndIf
      TransformSkinOriginalSaved = True
    ElseIf CaptureOriginal
      If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return False
      EndIf
      OrgSkinColor = Game.GetTintMaskColor(6, 0)
      If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return False
      EndIf
      TransformSkinOriginalSaved = True
    Else
      Debug.Trace("[PSQ] Skin tint refresh skipped: original tint backup unavailable", 1)
      Return False
    EndIf
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  PSQSkinColor = Self.ComposeTransformSkinColor(PSQSkinColor, PSQSkinColorAlpha)
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  Game.SetTintMaskColor(PSQSkinColor, 6, 0)
  If Game.GetTintMaskColor(6, 0) != PSQSkinColor
    Debug.Notification("肤色写入失败，原肤色备份已保留。")
    Return False
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  Game.UpdateTintMaskColors()
  Return True
EndFunction

Bool Function RestoreTransformSkinColor(Int Owner, Bool RequireBusy)
  Self.SyncPlayerAppearanceRace()
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  If !Self.HasOriginalTransformSkinColor() || Game.GetNumTintsByType(6) <= 0
    Return False
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Int Load = PSQLoadEpoch
    Int[] Plan = PSQAppearance.SkinTintRequest(PlayerRef,Self,PlayerAppearanceRace,Owner,Load,RequireBusy,True,False,Game.GetTintMaskColor(6,0))
    If Plan && Plan.Length == 2 && Plan[0] != 0
      If Plan[0] < 0 || !Self.IsAppearanceOperationCurrent(Owner,RequireBusy)
        Return False
      EndIf
      Game.SetTintMaskColor(Plan[1],6,0)
      If Game.GetTintMaskColor(6,0) != Plan[1]
        Debug.Notification("肤色写入失败，原肤色备份已保留。")
        Return False
      EndIf
      If !Self.IsAppearanceOperationCurrent(Owner,RequireBusy)
        Return False
      EndIf
      Game.UpdateTintMaskColors()
      Return PSQAppearance.FinishSkinRestore(PlayerRef,Self,PlayerAppearanceRace,Owner,Load,RequireBusy,Plan[1],Game.GetTintMaskColor(6,0))
    EndIf
  EndIf
  Game.SetTintMaskColor(OrgSkinColor, 6, 0)
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  Game.UpdateTintMaskColors()
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  TransformSkinOriginalSaved = False
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  OrgSkinColor = 0
  Return True
EndFunction

Function SyncTransformSkinColor(Int Owner, Bool RequireBusy)
  Self.SyncPlayerAppearanceRace()
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  If IsHenshined && HenshinSkin
    If PlayerRef == None || !PlayerRef.Is3DLoaded()
      Debug.Notification("角色模型尚未加载，颜色已保存，请稍后重试。")
      Return
    EndIf
    If psqracecompatibility.ShouldPreserveAppearance(PlayerRef)
      Debug.Notification("肤色已保存；当前种族受外观保护，无法应用变身肤色。")
      Return
    EndIf
    If Game.GetNumTintsByType(6) <= 0
      Debug.Notification("肤色已保存；未找到可用的肤色染色层。")
      Return
    EndIf
    Bool Applied = Self.ApplyTransformSkinColor(True, Owner, RequireBusy)
    If !Applied && Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Debug.Notification("肤色已保存，但本次写入失败，请稍后重试。")
    EndIf
  Else
    Bool HadBackup = Self.HasOriginalTransformSkinColor()
    Bool Restored = Self.RestoreTransformSkinColor(Owner, RequireBusy)
    If HadBackup && !Restored && Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Debug.Notification("原肤色恢复失败，备份已保留，请稍后重试。")
    EndIf
  EndIf
EndFunction

Function InitializeTransformEquipmentLedger(Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  If TransformInventoryLedgerReady
    Return
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  TransformInventoryItems = new Form[128]
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  TransformInventoryBaseline = new Int[128]
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  TransformInventoryAdded = new Int[128]
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  TransformInventoryLedgerReady = True
EndFunction

Function EnsurePlayerTransformEquipment(Armor Item, Int Owner, Bool RequireBusy)
  Self.SyncPlayerAppearanceRace()
  If Self.IsBodyIndependentTransformWing(Item)
    ; Standalone animated wings do not use either body mesh.
  Else
    Item = Self.ResolveTransformEquipmentItem(Item, PSQDXUBE.GetItemPart(Item))
  EndIf
  If Item == None
    Return
  EndIf
  If psqracecompatibility.ShouldPreserveAppearance(PlayerRef) && !PSQDXUBE.SupportsItem(PlayerRef, Item) && (Item == PSQSuccubusCuirass || Item == PSQSuccubusBoots || Item == PSQSuccubusGauntlets)
    Return
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  Self.EnsurePlannedTransformEquipment(Item, Owner, RequireBusy)
EndFunction

Function CleanupTransformEquipmentLedger(Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !TransformInventoryLedgerReady
    Return
  EndIf
  Int RecoveryLoad = PSQLoadEpoch
  Form[] Originals = OrgArmorList.ToArray()
  If !Originals
    ; SKSE returns None for an empty FormList. An allocated list with one
    ; unused slot cannot match any of the non-None armor queried by cleanup.
    Originals = new Form[1]
  EndIf
  Self.CleanupTransformLedgerForLoad(Owner, RequireBusy, RecoveryLoad, Originals)
EndFunction

Function CleanupTransformLedgerForLoad(Int Owner, Bool RequireBusy, Int RecoveryLoad, Form[] Originals)
  If RecoveryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
    Return
  EndIf
  If !TransformInventoryLedgerReady
    Return
  EndIf
  Float BeforeItems
  Float AfterItems
  Float Started
  If EnableEquipmentDiagnostics
    Started = Utility.GetCurrentRealTime()
  EndIf
  Int Used = TransformInventoryItems.find(None, 0)
  If Used < 0
    Used = TransformInventoryItems.Length
  EndIf
  Form[] Protected
  If Used > 0
    If !Originals
      Originals = OrgArmorList.ToArray()
    EndIf
    Protected = Self.GetTransformProtectedArmor()
  EndIf
  If EnableEquipmentDiagnostics
    BeforeItems = Utility.GetCurrentRealTime()
  EndIf
  Bool Fast = Used > 0 && SKSE.GetPluginVersion("PSQ Appearance") >= 16777223
  Int FastCount = 0
  Bool NativeRelease = Fast && SKSE.GetPluginVersion("PSQ Appearance") >= 16777224
  Int NativeCount = 0
  Int BorrowedCount = 0
  Int Index = 0
  While Index < Used
    If RecoveryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
      Return
    EndIf
    Armor Item = TransformInventoryItems[Index] as Armor
    If Item != None && Originals.find(Item as Form, 0) < 0 && Protected.find(Item as Form, 0) < 0
      Bool Settled = False
      Int Observed = -1
      String Reason = "ownership"
      If !Fast
        Reason = "api-unavailable"
      EndIf
      ; Most transformed pieces are one PSQ copy with no personal baseline.
      ; Keep stacks, protected gear and indeterminate reads on the existing path.
      If NativeRelease
        Int Result
        Bool NativeLedger = SKSE.GetPluginVersion("PSQ Appearance") >= 16777229
        If NativeLedger
          Result = PSQAppearance.ReleaseLedgerPart(PlayerRef, Item, PlayerAppearanceRace, Self, Owner, RecoveryLoad, RequireBusy, Index)
        Else
          Result = PSQAppearance.ReleaseExitArmor(PlayerRef, Item, PlayerAppearanceRace, Self, Owner, RecoveryLoad, RequireBusy, TransformInventoryBaseline[Index], TransformInventoryAdded[Index])
        EndIf
        If Result < 0 || Owner != AppearanceOperationId || RecoveryLoad != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
          Return
        EndIf
        If Result == 1
          If !NativeLedger
            TransformInventoryAdded[Index] = 0
          EndIf
          FastCount += 1
          Settled = True
        ElseIf Result == 2
          BorrowedCount += 1
          Settled = True
          If EnableEquipmentDiagnostics
            Debug.Trace("[PSQ-PERF] recovery.borrowed; owner=" + Owner + "; item=" + Item + "; native=True")
          EndIf
        ElseIf Result == 3
          ; One removal was already submitted for the only claimed copy.
          ; A new copy from a callback cannot be distinguished. Retire the claim.
          If !NativeLedger
            TransformInventoryAdded[Index] = 0
          EndIf
          Settled = True
          If EnableEquipmentDiagnostics
            Debug.Trace("[PSQ-PERF] recovery.unconfirmed_removal; item=" + Item)
          EndIf
        Else
          Reason = "native-fallback"
        EndIf
        If Result == 1 || Result == 2
          NativeCount += 1
        EndIf
      EndIf
      If !NativeRelease && Fast && TransformInventoryBaseline[Index] == 0 && TransformInventoryAdded[Index] == 1
        Int[] ArmorRead = PSQAppearance.ReadExitArmorState(PlayerRef, Item, PlayerAppearanceRace, False)
        If RecoveryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
          Return
        EndIf
        Reason = "read-unavailable"
        If ArmorRead && ArmorRead.Length == 2
          Observed = ArmorRead[0]
          Reason = "multiple-copies"
          If ArmorRead[0] < 0
            Return
          ElseIf ArmorRead[0] == 0
            Settled = True
          ElseIf ArmorRead[0] == 1
            PlayerRef.RemoveItem(Item, 1, True, None)
            Settled = PlayerRef.GetItemCount(Item) == 0
            Reason = "removal-unconfirmed"
            If RecoveryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
              Return
            EndIf
          EndIf
        EndIf
        If Settled
          TransformInventoryAdded[Index] = 0
          FastCount += 1
        EndIf
      EndIf
      If !NativeRelease && Fast && TransformInventoryBaseline[Index] > 0 && TransformInventoryAdded[Index] == 0
        Int[] Borrowed = PSQAppearance.ReadExitArmorState(PlayerRef, Item, PlayerAppearanceRace, False)
        If RecoveryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
          Return
        EndIf
        Reason = "borrowed-read-unavailable"
        If Borrowed && Borrowed.Length == 2
          Observed = Borrowed[0]
          If Observed < 0
            Return
          EndIf
          If Borrowed[1] == 1
            PlayerRef.UnequipItem(Item, False, True)
            Settled = !PlayerRef.IsEquipped(Item)
            If RecoveryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
              Return
            EndIf
            Reason = "borrowed-unequip-unconfirmed"
          Else
            Settled = True
          EndIf
          If Settled
            BorrowedCount += 1
            If EnableEquipmentDiagnostics
              Debug.Trace("[PSQ-PERF] recovery.borrowed; owner=" + Owner + "; item=" + Item + "; beforeTransform=" + TransformInventoryBaseline[Index] + "; added=0; wasWorn=" + Borrowed[1])
            EndIf
          EndIf
        EndIf
      EndIf
      If !Settled
        If EnableEquipmentDiagnostics
          Debug.Trace("[PSQ-PERF] recovery.ledger_fallback; owner=" + Owner + "; item=" + Item + "; reason=" + Reason + "; beforeTransform=" + TransformInventoryBaseline[Index] + "; added=" + TransformInventoryAdded[Index] + "; observed=" + Observed)
        EndIf
        Self.ReleaseLedgerItemForLoad(Item, Index, Owner, RequireBusy, RecoveryLoad)
      EndIf
    ElseIf EnableEquipmentDiagnostics && Item != None
      Debug.Trace("[PSQ-PERF] recovery.ledger_preserved; owner=" + Owner + "; item=" + Item + "; original=" + (Originals.Find(Item) >= 0) + "; protected=" + (Protected.Find(Item) >= 0))
    EndIf
    Index += 1
  EndWhile
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
    Return
  EndIf
  If EnableEquipmentDiagnostics
    AfterItems = Utility.GetCurrentRealTime()
  EndIf
  TransformInventoryLedgerReady = False
  If Owner != AppearanceOperationId || RecoveryLoad != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
    Return
  EndIf
  TransformInventoryItems = EmptyFormArray
  If Owner != AppearanceOperationId || RecoveryLoad != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
    Return
  EndIf
  TransformInventoryBaseline = EmptyIntArray
  If Owner != AppearanceOperationId || RecoveryLoad != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
    Return
  EndIf
  TransformInventoryAdded = EmptyIntArray
  If EnableEquipmentDiagnostics
    Float Ended = Utility.GetCurrentRealTime()
    Debug.Trace("[PSQ-PERF] recovery.ledger_times; owner=" + Owner + "; prepare=" + (BeforeItems - Started) + "; fastVerified=" + (FastCount + BorrowedCount) + "; nativeVerified=" + NativeCount + "; temporaryVerified=" + FastCount + "; borrowedVerified=" + BorrowedCount + "; releaseItems=" + (AfterItems - BeforeItems) + "; clearRecords=" + (Ended - AfterItems))
    Debug.Trace(("[PSQ-PERF] recovery.ledger; entries=" + Used as String) + "; seconds=" + (Ended - Started) as String, 0)
  EndIf
EndFunction

Bool Function IsTransformEnergyClockActive()
  Return IsHenshined && AllowHenshinConsumeEnergy && !StopEnergyConsuming && PlayerIsSuccubus.GetValue() == 1.0 && !UninstallPrepared && !UninstallCleanupBusy
EndFunction

Function ResetTransformEnergyClock()
  If TransformClockTimeScale == None
    TransformClockTimeScale = Game.GetFormFromFile(58, "Skyrim.esm") as GlobalVariable
  EndIf
  TransformClockReal = Utility.GetCurrentRealTime()
  TransformClockDays = GameDaysPassed.GetValue()
  TransformClockScale = 0.0
  If TransformClockTimeScale != None
    TransformClockScale = TransformClockTimeScale.GetValue()
  EndIf
  TransformClockActive = Self.IsTransformEnergyClockActive()
  TransformClockReady = True
EndFunction

Float Function TakeTransformEnergySeconds()
  Float PreviousReal = TransformClockReal
  Float PreviousDays = TransformClockDays
  Float PreviousScale = TransformClockScale
  Bool WasReady = TransformClockReady
  Bool WasActive = TransformClockActive
  Self.ResetTransformEnergyClock()
  If !WasReady || !WasActive || !TransformClockActive || PreviousScale <= 0.0 || PreviousScale != TransformClockScale
    Return 0.0
  EndIf
  Float RealSeconds = TransformClockReal - PreviousReal
  Float ActiveSeconds = (TransformClockDays - PreviousDays) * 86400.0 / PreviousScale
  If RealSeconds <= 0.0 || ActiveSeconds <= 0.0 || ActiveSeconds > RealSeconds * 1.5 + 1.0
    Return 0.0
  EndIf
  If ActiveSeconds > RealSeconds
    ActiveSeconds = RealSeconds
  EndIf
  Return ActiveSeconds
EndFunction

Function SettleTransformEnergy()
  Float Seconds = Self.TakeTransformEnergySeconds()
  If Seconds > 0.0 && HenshinConsumeEnergy > 0.0
    Self.ChangeSatiationEnergy(-Seconds * HenshinConsumeEnergy, False)
  EndIf
EndFunction

Bool Function IsRankUpAnimationEnabled()
  Return False
EndFunction

Function SuspendRankUpAnimation()
  PendingRankAnimation = 0
  RankAnimationReadyAt = 0.0
  RankAnimationPreviewPending = False
  RankAnimationPlaybackBusy = False
  Self.StopRankUpAnimation()
EndFunction

Function ReleaseTransformEquipmentEntry(Armor Item, Int Index, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Int RecoveryLoad = PSQLoadEpoch
  Self.ReleaseLedgerItemForLoad(Item, Index, Owner, RequireBusy, RecoveryLoad)
EndFunction

Function QueueTimedSatiationRefresh()
  If SatiationTimedRefreshQueued || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  SatiationTimedRefreshQueued = True
  Self.RegisterForModEvent("PSQ_SatiationRefreshTick", "OnTimedSatiationRefresh")
  Self.SendModEvent("PSQ_SatiationRefreshTick", "", SatiationTimedRefreshEpoch as Float)
EndFunction

Function OnTimedSatiationRefresh(String EventName, String Argument, Float Epoch, Form Sender)
  If (Sender != Self as Form) || (Epoch as Int != SatiationTimedRefreshEpoch)
    Return
  EndIf
  Float Delay = 10.0 - (Utility.GetCurrentRealTime() - SatiationLastAttributeRefresh)
  If Delay > 0.0
    Utility.Wait(Delay)
  EndIf
  If Epoch as Int != SatiationTimedRefreshEpoch
    Return
  EndIf
  SatiationTimedRefreshQueued = False
  If !UninstallPrepared && !UninstallCleanupBusy
    Self.RefreshSatiationAttributes(Self.GetEnergyRatio())
  EndIf
EndFunction

Bool Function IsAproposRepairPatchInstalled()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.AproposMarker34()
  EndIf
  Return MiscUtil.FileExists("Data/SKSE/Plugins/PSQ/AproposRepair.enabled")
EndFunction

Bool Function HasAproposRepairIntegration()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.AproposReady34()
  EndIf
  If !Self.IsAproposRepairPatchInstalled()
    Return False
  EndIf
  If !Self.IsIntegrationPluginLoaded("Apropos2.esp")
    Return False
  EndIf
  Quest Registry = Game.GetFormFromFile(167980, "Apropos2.esp") as Quest
  Return Registry != None && Registry.IsRunning()
EndFunction

Spell Function GetAproposRepairSpell()
  Return Game.GetFormFromFile(41659, "PSQ PlayerSuccubusQuest.esm") as Spell
EndFunction

Function SyncAproposRepairSpell()
  Spell Repair = Self.GetAproposRepairSpell()
  If (!AproposRepairVoiceSlotMigrated && PlayerRef as Bool) && Repair as Bool
    AproposRepairVoiceSlotMigrated = True
    PlayerRef.UnequipSpell(Repair, 0)
    PlayerRef.UnequipSpell(Repair, 1)
    If PlayerRef.HasSpell(Repair as Form)
      PlayerRef.RemoveSpell(Repair)
    EndIf
  EndIf
  Int Mode = Self.GetAbilityManagementMode()
  Bool Enabled = Self.HasAproposRepairIntegration() && PlayerIsSuccubus.GetValueInt() == 1 && !UninstallPrepared && !UninstallCleanupBusy && (Mode == 1 || Mode == 2 && EnableAproposRepairSpell)
  Self.SyncManagedSpell(Self.GetAproposRepairSpell(), Enabled)
EndFunction

Float Function GetAproposRepairCost()
  If MaxEnergy <= 0.0
    Self.RefreshEnergyCapacity()
  EndIf
  Float Cost = MaxEnergy * 0.100000001
  If Cost < 1.0
    Cost = 1.0
  EndIf
  Return Cost
EndFunction

Bool Function BeginAproposRepair()
  If AproposRepairBusy
    Return False
  EndIf
  AproposRepairBusy = True
  If !Self.HasAproposRepairIntegration() || PlayerIsSuccubus.GetValueInt() != 1 || UninstallPrepared || UninstallCleanupBusy || !PlayerRef.HasSpell(Self.GetAproposRepairSpell() as Form)
    AproposRepairBusy = False
    Return False
  EndIf
  Float Cost = Self.GetAproposRepairCost()
  If SuccubusEnergy.GetValue() < Cost
    AproposRepairBusy = False
    Debug.Notification(("魅魔能量不足，损伤修复需要 " + (Cost as Int) as String) + " 点能量。")
    Return False
  EndIf
  AproposRepairTicket += 1
  AproposRepairReserved = Cost
  Self.ChangeSatiationEnergy(-Cost, False)
  Return True
EndFunction

Function FinishAproposRepair(Int Ticket, Bool Success)
  If !AproposRepairBusy || Ticket != AproposRepairTicket
    Return
  EndIf
  Float Refund = AproposRepairReserved
  AproposRepairReserved = 0.0
  AproposRepairBusy = False
  If !Success && Refund > 0.0
    Self.ChangeSatiationEnergy(Refund, False)
  EndIf
  Self.Satiety(0.0)
EndFunction

Int Function GetTattooGlowMode()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.GlowMode34(Self)
  EndIf
  If TattooGlowMode < 0 || TattooGlowMode > 2
    If EnableCustomTattooGlow
      If PreserveTattooGlowColor
        TattooGlowMode = 1
      Else
        TattooGlowMode = 2
      EndIf
    ElseIf EnableBodyPaintGlowTintChangeSatiation || EnableBodyPaintGlowAlphaChangeSatiation
      TattooGlowMode = 2
      CustomTattooGlowColor = BPGTintColorStart
    Else
      TattooGlowMode = 0
    EndIf
    EnableCustomTattooGlow = TattooGlowMode != 0
    PreserveTattooGlowColor = TattooGlowMode == 1
  EndIf
  Return TattooGlowMode
EndFunction

Function SetTattooGlowMode(Int Mode)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236
    Int Result = PSQAppearance.MenuGlowCommit(Self, Mode, 0, False)
    If Result != 0
      If Result > 0
        Self.ChangeBodyPaint(Self.GetEnergyRatio(), True)
      EndIf
      Return
    EndIf
  EndIf
  If Mode < 0 || Mode > 2
    Return
  EndIf
  TattooGlowMode = Mode
  EnableCustomTattooGlow = Mode != 0
  PreserveTattooGlowColor = Mode == 1
  Self.ChangeBodyPaint(Self.GetEnergyRatio(), True)
EndFunction

Bool Function TouchAppearanceOperation(Int Owner, String Stage)
  If Owner != AppearanceOperationId || !AppearanceEditBusy
    Return False
  EndIf
  AppearanceOperationStage = Stage
  AppearanceLastProgress = Utility.GetCurrentRealTime()
  Return True
EndFunction

Function CheckAppearanceProgress()
  If AppearanceEditBusy && !AppearanceSlowNotified && Utility.GetCurrentRealTime() - AppearanceLastProgress > 120.0
    AppearanceSlowNotified = True
    Debug.Notification("$PSQ_AppearanceStalled")
    Debug.Trace(("[PSQ-RECOVERY] Slow appearance operation; owner=" + AppearanceOperationId as String) + "; stage=" + AppearanceOperationStage, 1)
  EndIf
EndFunction

Function InvalidateAppearanceForLoad(Int Epoch)
  Self.InvalidateAppearanceForLoad35(Epoch)
EndFunction

Function CancelInterruptedAppearanceOnLoad()
  Self.CancelInterruptedAppearanceOnLoad35()
EndFunction

Bool Function TryRecoverInterruptedAppearance()
  If !AppearanceRecoveryPending
    Return False
  EndIf
  ; Pending recovery must wait for the current owner or uninstall regardless
  ; of airborne state. Do not probe graph variables for an impossible retry.
  If PlayerRef == None || AppearanceEditBusy || AppearanceRecoveryRequested || UninstallPrepared || UninstallCleanupBusy
    Return True
  EndIf
  Int RecoveryEpoch = PSQLoadEpoch
  Int RecoveryOwner = AppearanceOperationId
  If Self.IsWingflightAirborne() || psqracecompatibility.IsTemporaryBeastRace(PlayerRef.GetRace()) || Self.ShouldDeferForAlternateStart()
    Return True
  EndIf
  If Utility.GetCurrentRealTime() < AppearanceRecoveryAfter
    Return True
  EndIf
  If PlayerRef == None || !PlayerRef.Is3DLoaded() || PlayerRef.IsDead() || Utility.IsInMenuMode() || PlayerRef.HasKeywordString("SexLabActive")
    Return True
  EndIf
  If Self.GTSoftbodyOwnsAppearance()
    Return True
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777229
    Int Claim = PSQAppearance.ClaimAppearanceRecovery(PlayerRef, Self, RecoveryOwner, RecoveryEpoch, OrgArmorList.GetSize())
    If Claim == 2
      If RecoveryEpoch == PSQLoadEpoch && RecoveryOwner == AppearanceOperationId && AppearanceRecoveryRequested && AppearanceRecoveryInProgress
        HenshinSpell.Cast(PlayerRef as ObjectReference, PlayerRef as ObjectReference)
      EndIf
      Return True
    ElseIf Claim != 0
      Return Claim < 0
    EndIf
  EndIf
  If !AppearanceSnapshotReady && !IsHenshined && OrgArmorList.GetSize() == 0 && !TransformInventoryLedgerReady
    AppearanceRecoveryPending = False
    Return False
  EndIf
  If RecoveryEpoch != PSQLoadEpoch || RecoveryOwner != AppearanceOperationId || !AppearanceRecoveryPending || AppearanceRecoveryRequested || AppearanceEditBusy || StatPoolEditBusy || UninstallPrepared || UninstallCleanupBusy
    Return True
  EndIf
  AppearanceRecoveryRequested = True
  AppearanceRecoveryInProgress = True
  IsHenshined = True
  HenshinSpell.Cast(PlayerRef as ObjectReference, PlayerRef as ObjectReference)
  Return True
EndFunction

Bool Function CanRequestAppearanceRecovery()
  If UninstallPrepared || UninstallCleanupBusy || PlayerRef == None
    Return False
  EndIf
  If AppearanceEditBusy || IsHenshinchu
    Return AppearanceTransformDirection != 0 && Utility.GetCurrentRealTime() - AppearanceLastProgress >= 30.0
  EndIf
  Return AppearanceRecoveryPending || (!IsHenshined && Self.HasPendingOriginalEquipment())
EndFunction

Bool Function RetryInterruptedAppearance()
  If !Self.CanRequestAppearanceRecovery()
    Return False
  EndIf
  if !AppearanceRecoveryPending && !IsHenshined && !AppearanceEditBusy && !IsHenshinchu && Self.HasPendingOriginalEquipment()
    return Self.QueuePendingOriginalEquipmentRecovery()
  endif
  AppearanceOperationId += 1
  Self.ResetStatPoolEditsOnLoad()
  AppearanceRecoveryPending = True
  AppearanceRecoveryAfter = Utility.GetCurrentRealTime() + 1.0
  AppearanceEditBusy = False
  IsHenshinchu = False
  BodySelectionRefreshBusy = False
  AppearanceTransformDirection = 0
  AppearanceRecoveryInProgress = False
  AppearanceRecoveryRequested = False
  storageutil.UnsetIntValue(PlayerRef as Form, "PSQ_TDFAppearanceBusy")
  Self.StopEnergySense()
  Self.RegisterForSingleUpdate(1.0)
  Return True
EndFunction

Bool Function TryRestoreTransformOriginal(Armor Item, Form[] Protected, Int Owner, Bool RequireBusy)
  ; Explicit manual retry retains the ability to replace a worn alternative.
  Return Self.TryRestoreTransformOriginalCore(Item, Protected, Owner, RequireBusy, False)
EndFunction

Function ApplyTransformSlot52(Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  Self.EnterTRXTargetFuta(PlayerRef)
EndFunction

Function ReleaseTransformSlot52(Bool RestoreHuman, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  ; Keep recovery, retirement and genuine slot ownership on the full restore path.
  If RestoreHuman && RequireBusy && AppearanceTransformDirection == 2 && !AppearanceRecoveryPending && !AppearanceRecoveryInProgress && !UninstallCleanupBusy && !UninstallPrepared && !HenshinPenis && OrgSlot52 == None
    If !Self.HasTransformSlot52State(PlayerRef)
      If Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
        ; Also remove retired items acquired since entry, including in old saves.
        Self.RemoveLegacyFutaItems(PlayerRef)
        If EnableEquipmentDiagnostics
          Debug.Trace("[PSQ-PERF] exit.slot52 path=unused")
        EndIf
      EndIf
      Return
    EndIf
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  Self.ExitTRXTargetFuta(PlayerRef, RestoreHuman)
  If RestoreHuman && OrgSlot52 != None && !Self.IsRetiredFutaArmor(OrgSlot52) && PlayerRef.GetItemCount(OrgSlot52) > 0 && !PlayerRef.IsEquipped(OrgSlot52) && storageutil.GetIntValue(PlayerRef, "PSQ_HasPenis", 0) != 1
    PlayerRef.EquipItem(OrgSlot52, False, True)
  EndIf
  OrgSlot52 = None
EndFunction

Bool Function HasTransformSlot52State(Actor Target)
  If Target == None || storageutil.GetIntValue(Target, "PSQ_StillEquipPenis", 0) != 0 || storageutil.GetIntValue(Target, "PSQ_HasPenis", 0) != 0
    Return True
  EndIf
  If storageutil.GetFormValue(Target, "PSQ_TRXFutaItem", None) || storageutil.GetFormValue(Target, "PSQ_TRXFutaOriginal52", None)
    Return True
  EndIf
  If storageutil.GetIntValue(Target, "PSQ_TRXFutaAdded", 0) != 0 || storageutil.GetIntValue(Target, "PSQ_TRXFutaClothed", 0) != 0 || storageutil.GetIntValue(Target, "PSQ_TRXFutaSizeOwned", 0) != 0
    Return True
  EndIf
  If storageutil.GetIntValue(Target, "PSQ_TRXFutaGenderOwned", 0) != 0 || storageutil.GetIntValue(Target, "PSQ_BCNGFutaOwned", 0) != 0
    Return True
  EndIf
  Return PowerOfFutanari != None && Target.HasSpell(PowerOfFutanari)
EndFunction

Bool Function IsAppearanceOperationCurrent(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.OwnerCurrent34(Self, Owner, RequireBusy)
  EndIf
  ; Reject obsolete callbacks before querying the actor through the VM.
  If Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  If PlayerRef != None && SKSE.GetPluginVersion("PSQ Appearance") >= 16777228
    Int Status = PSQAppearance.CheckAppearanceOwner(PlayerRef, Self, PlayerAppearanceRace, Owner, PSQLoadEpoch, RequireBusy)
    If Status != 0
      Return Status == 1 && Owner == AppearanceOperationId && (!RequireBusy || AppearanceEditBusy)
    EndIf
  EndIf
  If PlayerRef != None && PlayerAppearanceRace != None && PlayerRef.GetRace() != PlayerAppearanceRace
    Return False
  EndIf
  ; GetRace can yield: retain the final owner check from the original guard.
  Return Owner == AppearanceOperationId && (!RequireBusy || AppearanceEditBusy)
EndFunction

Function SyncPlayerAppearanceRace()
  If PlayerRef == None
    Return
  EndIf
  Race CurrentRace = PlayerRef.GetRace()
  If CurrentRace == None
    Return
  EndIf
  If PlayerAppearanceRace == None
    PlayerAppearanceRace = CurrentRace
    Return
  EndIf
  If PlayerAppearanceRace == CurrentRace
    Return
  EndIf
  Self.RestoreBCNGTransformSkin()
  Self.RestoreOriginalEquipmentVisibility()
  Race PreviousRace = PlayerAppearanceRace
  Bool HadAppearance = IsHenshined || IsHenshinchu || AppearanceTransformDirection != 0 || AppearanceRecoveryPending
  AppearanceOperationId += 1
  PlayerAppearanceRace = CurrentRace
  BCNGBodyClearOnly = True
  BCNGBodyNeedsSync = True
  BCNGBodyRequest = 0
  Self.RequestBCNGBodyChange(False, "", AppearanceOperationId, False, False)
  Self.ResetStatPoolEditsOnLoad()
  AppearanceEditBusy = False
  IsHenshinchu = False
  BodySelectionRefreshBusy = False
  AppearanceTransformDirection = 0
  AppearanceRecoveryInProgress = False
  AppearanceRecoveryRequested = False
  AppearanceRecoveryAfter = Utility.GetCurrentRealTime() + 3.0
  OrgEyes = None
  OrgHair = None
  StorageUtil.UnsetFormValue(PlayerRef, "PSQ_AppliedTransformHair")
  OrgHairColor = None
  OrgSkinColor = 0
  TransformSkinOriginalSaved = False
  TransformOriginalSkin = None
  TransformOriginalHead = None
  TransformBodySaved = False
  AppliedTransformEyeTexture = None
  storageutil.UnsetIntValue(PlayerRef as Form, "PSQ_TDFAppearanceBusy")
  Self.ClearAppliedTransformBody(-1, False)
  Self.InvalidateTransformAppearanceCache()
  Self.InvalidateTattooPresentation()
  If Self.HasNiOverrideRuntime()
    nioverride.ClearBodyMorphKeys(PlayerRef as ObjectReference, "PSQ_TransformPreset")
  EndIf
  Self.ResetTransformEnergyClock()
  If HadAppearance && !UninstallPrepared && !UninstallCleanupBusy
    AppearanceRecoveryPending = True
    Self.RegisterForSingleUpdate(3.0)
  EndIf
  Self.SyncWingflightPolicy()
  Debug.Trace(("[PSQ RaceCompat] Real race changed; old head/tint snapshots revoked: " + PreviousRace as String) + " -> " + CurrentRace as String, 0)
EndFunction

Function RestoreOriginalPlayerEyes(Int Owner, Bool RequireBusy)
  Self.RestoreOriginalPlayerEyes40(Owner, RequireBusy)
EndFunction

Function ApplyTransformHairColor(Bool CaptureOriginal, Int Owner, Bool RequireBusy)
  Self.SyncPlayerAppearanceRace()
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy) || !IsHenshined || !HenshinHairColor || psqracecompatibility.ShouldPreserveHeadAppearance(PlayerRef)
    Return
  EndIf
  If OrgHairColor == None && CaptureOriginal
    OrgHairColor = PlayerRef.GetLeveledActorBase().GetHairColor()
  EndIf
  If OrgHairColor == None || !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  PSQSuccubusHairColor.SetColor(PSQSuccubusHairColorInt)
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  If !(SKSE.GetPluginVersion("PSQ Appearance") >= 16777231) || PSQAppearance.ApplyHairTint(PlayerRef, PlayerRef.GetLeveledActorBase(), PSQSuccubusHairColor, Self, PlayerAppearanceRace, Owner, PSQLoadEpoch, RequireBusy) == 0
    PlayerRef.GetLeveledActorBase().SetHairColor(PSQSuccubusHairColor)
  EndIf
EndFunction

Bool Function RestoreOriginalPlayerHairColor(Int Owner, Bool RequireBusy)
  Self.SyncPlayerAppearanceRace()
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  EndIf
  If OrgHairColor == None || !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  If !(SKSE.GetPluginVersion("PSQ Appearance") >= 16777231) || PSQAppearance.ApplyHairTint(PlayerRef, PlayerRef.GetLeveledActorBase(), OrgHairColor, Self, PlayerAppearanceRace, Owner, PSQLoadEpoch, RequireBusy) == 0
    PlayerRef.GetLeveledActorBase().SetHairColor(OrgHairColor)
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  OrgHairColor = None
  Return True
EndFunction

Bool Function ReturnPersonalStorageItems(Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  If PlayerRef == None
    Return False
  EndIf
  ObjectReference PersonalStorage = Game.GetFormFromFile(3987, "PSQ PlayerSuccubusQuest.esm") as ObjectReference
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  If PersonalStorage == None || (PersonalStorage == PlayerRef as ObjectReference)
    Debug.Trace("[PSQ-STORAGE] Persistent personal storage unavailable; access cleanup aborted", 1)
    Return False
  EndIf
  Int Before = PersonalStorage.GetNumItems()
  If Before < 0
    Return False
  EndIf
  If Before > 0
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return False
    EndIf
    PersonalStorage.RemoveAllItems(PlayerRef as ObjectReference, True, True)
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  Int Remaining = PersonalStorage.GetNumItems()
  If Remaining != 0
    Debug.Trace(("[PSQ-STORAGE] Personal storage still contains " + Remaining as String) + " item types; access cleanup aborted", 1)
    Return False
  EndIf
  If Before > 0
    Debug.Notification("$PSQ_StorageReturned")
  EndIf
  Return True
EndFunction

Function RestoreRetirementPools(Int Owner, Bool RequireBusy)
  Self.RestoreRetirementPools35(Owner,RequireBusy)
EndFunction

Function ReleasePSQJumpHeight()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If PSQAppearance.ReleaseJump34(Self)
      Return
    EndIf
  EndIf
  Float Current = Game.GetGameSettingFloat("fJumpHeightMin")
  If PSQJumpHeightOwned && Math.Abs(Current - PSQAppliedJumpHeight) < 0.001
    Game.SetGameSettingFloat("fJumpHeightMin", PSQSavedJumpHeight)
  EndIf
  PSQJumpHeightOwned = False
EndFunction

Function UpdatePSQWingJumpHeight(Bool ExplicitRequest)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If PSQAppearance.UpdateJump34(Self)
      Return
    EndIf
  EndIf
  Self.ReleasePSQJumpHeight()
  PSQJumpHeightYielded = False
  Self.SyncWingflightPolicy()
EndFunction

Function ApplyPSQDefaultJumpPreference()
  If PSQJumpHeightOwned
    PSQSavedJumpHeight = DefaultJumpHeight
  Else
    Game.SetGameSettingFloat("fJumpHeightMin", DefaultJumpHeight)
  EndIf
  Self.UpdatePSQWingJumpHeight(True)
EndFunction

Function InvalidateTattooPresentation()
  TattooPresentationRevision += 1
  TattooPresentationValid = False
  TattooPresentationKey = ""
  TattooPresentationNeedsApply = True
EndFunction

Function OnNiNodeUpdate(ObjectReference akActor)
  If (akActor == PlayerRef as ObjectReference) && !UninstallPrepared && !UninstallCleanupBusy
    Self.InvalidateTattooPresentation()
  ElseIf akActor && !UninstallPrepared && !UninstallCleanupBusy && StorageUtil.GetIntValue(akActor, "PSQ_ThrallTattooDeferred", 0) == 2 && Self.HasNiOverrideRuntime()
    Self.RestoreSuccubusThrallTattoo(akActor as Actor)
  ElseIf akActor && !UninstallPrepared && !UninstallCleanupBusy && storageutil.GetIntValue(akActor, "PSQ_ThrallTattooDeferred", 0) == 1
    Self.ApplySuccubusThrallTattoo(akActor as Actor)
  EndIf
  Self.QueueTRXFutaClothingIfNeeded(akActor as Actor)
EndFunction

Float Function GetAnimalRaceFamiliarity(String RaceName)
  String PSQKey = "MyUniAnimalExp" + RaceName
  String Alternate = "MyUniAnimalExp_" + RaceName
  Float value = storageutil.GetFloatValue(PlayerRef as Form, PSQKey, 0.0)
  If storageutil.HasFloatValue(PlayerRef as Form, Alternate)
    Float Other = storageutil.GetFloatValue(PlayerRef as Form, Alternate, 0.0)
    If Other > value
      value = Other
      storageutil.SetFloatValue(PlayerRef as Form, PSQKey, value)
    EndIf
    storageutil.UnsetFloatValue(PlayerRef as Form, Alternate)
  EndIf
  Return value
EndFunction

MagicEffect[] Function GetNaturalRacialEffects()
  MagicEffect[] Effects = new MagicEffect[128]
  Race NaturalRace = PlayerRef.GetRace()
  Int Count = 0
  Int i = 0
  While NaturalRace != None && i < NaturalRace.GetSpellCount() && Count < 128
    Spell Ability = NaturalRace.GetNthSpell(i)
    Int j = 0
    If Ability != None
      While j < Ability.GetNumEffects() && Count < 128
        MagicEffect Effect = Ability.GetNthEffectMagicEffect(j)
        If Effect != None && Effects.find(Effect, 0) < 0
          Effects[Count] = Effect
          Count += 1
        EndIf
        j += 1
      EndWhile
    EndIf
    i += 1
  EndWhile
  Return Effects
EndFunction

Function HideRacialGameplayEffects(Spell Ability, MagicEffect[] NaturalEffects)
  If Ability == None
    Return
  EndIf
  Int i = 0
  While i < Ability.GetNumEffects()
    MagicEffect Effect = Ability.GetNthEffectMagicEffect(i)
    If Effect != None && NaturalEffects.find(Effect, 0) < 0 && !Effect.IsEffectFlagSet(32768)
      storageutil.FormListAdd(PlayerRef as Form, "PSQ_RacialUIHiddenEffects", Effect as Form, False)
      Effect.SetEffectFlag(32768)
    EndIf
    i += 1
  EndWhile
EndFunction

Function RestoreRacialGameplayVisibility()
  Int i = storageutil.FormListCount(PlayerRef as Form, "PSQ_RacialUIHiddenEffects") - 1
  While i >= 0
    MagicEffect Effect = storageutil.FormListGet(PlayerRef as Form, "PSQ_RacialUIHiddenEffects", i) as MagicEffect
    If Effect != None
      Effect.ClearEffectFlag(32768)
    EndIf
    i -= 1
  EndWhile
  storageutil.FormListClear(PlayerRef as Form, "PSQ_RacialUIHiddenEffects")
EndFunction

Function RemoveRacialDisplayAbility(Spell Ability)
  If Ability == None
    Return
  EndIf
  PlayerRef.DispelSpell(Ability)
  If PlayerRef.HasSpell(Ability as Form)
    PlayerRef.RemoveSpell(Ability)
  EndIf
EndFunction

Function PrefixRacialDisplayEffect(MagicEffect Effect, String Desired, String CatalogOriginal)
  If Effect == None || Desired == ""
    Return
  EndIf
  String Original = storageutil.GetStringValue(Effect as Form, "PSQ_RacialUIOriginalEffectName", "")
  If Original == ""
    Original = Effect.GetName()
    If stringutil.Find(Original, "魅魔之力：", 0) == 0
      Original = CatalogOriginal
    EndIf
    storageutil.SetStringValue(Effect as Form, "PSQ_RacialUIOriginalEffectName", Original)
  EndIf
  storageutil.SetStringValue(Effect as Form, "PSQ_RacialUIAppliedEffectName", Desired)
  storageutil.FormListAdd(PlayerRef as Form, "PSQ_RacialUIRenamedEffects", Effect as Form, False)
  Effect.SetName(Desired)
EndFunction

Function RestoreRacialDisplayEffectNames()
  Int i = storageutil.FormListCount(PlayerRef as Form, "PSQ_RacialUIRenamedEffects") - 1
  While i >= 0
    MagicEffect Effect = storageutil.FormListGet(PlayerRef as Form, "PSQ_RacialUIRenamedEffects", i) as MagicEffect
    If Effect != None
      String Original = storageutil.GetStringValue(Effect as Form, "PSQ_RacialUIOriginalEffectName", "")
      String Applied = storageutil.GetStringValue(Effect as Form, "PSQ_RacialUIAppliedEffectName", "")
      If Original != "" && Effect.GetName() == Applied
        Effect.SetName(Original)
      EndIf
      storageutil.UnsetStringValue(Effect as Form, "PSQ_RacialUIOriginalEffectName")
      storageutil.UnsetStringValue(Effect as Form, "PSQ_RacialUIAppliedEffectName")
    EndIf
    i -= 1
  EndWhile
  storageutil.FormListClear(PlayerRef as Form, "PSQ_RacialUIRenamedEffects")
EndFunction

Function RefreshAuditedRacialAbility(Spell Ability)
  Int Owner = AppearanceOperationId
  Int PoolEpoch = Self.BeginStatPoolEdit(Owner, False)
  If PoolEpoch < 0
    Return
  EndIf
  Self.RefreshAuditedRacialAbilityCore(Ability, Owner, PoolEpoch)
  Self.EndStatPoolEdit(PoolEpoch)
EndFunction

Function RefreshAuditedRacialAbilityCore(Spell Ability, Int Owner, Int PoolEpoch)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  Bool Allowed = False
  If Self.IsIntegrationPluginLoaded("Mannaz - Integrated Races of Skyrim.esp")
    Allowed = Allowed || (Ability as Form == Game.GetFormFromFile(8389290, "Mannaz - Integrated Races of Skyrim.esp")) || (Ability as Form == Game.GetFormFromFile(8389436, "Mannaz - Integrated Races of Skyrim.esp")) || (Ability as Form == Game.GetFormFromFile(9018305, "Mannaz - Integrated Races of Skyrim.esp")) || (Ability as Form == Game.GetFormFromFile(9131897, "Mannaz - Integrated Races of Skyrim.esp"))
  EndIf
  If Ability == None || !Allowed || !PlayerRef.HasSpell(Ability as Form)
    Return
  EndIf
  If StorageUtil.FormListHas(PlayerRef as Form, "PSQ_RacialUIv4Refreshed", Ability as Form)
    Return
  EndIf
  If Self.RaceContainsTrait(PlayerRef.GetRace(), Ability)
    Debug.Trace("[PSQ] Racial UI natural ability retained: " + Ability as String, 0)
    Return
  EndIf
  Float H = PlayerRef.GetActorValue("Health")
  Float M = PlayerRef.GetActorValue("Magicka")
  Float S = PlayerRef.GetActorValue("Stamina")
  Float RemovedHealth = Self.GetAuditedRacialHealthBonus(Ability)
  If RemovedHealth > 0.0 && H > 0.0 && H <= RemovedHealth && !PlayerRef.IsDead()
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    PlayerRef.RestoreActorValue("Health", RemovedHealth + 1.0 - H)
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  PlayerRef.DispelSpell(Ability)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  PlayerRef.RemoveSpell(Ability)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  PlayerRef.AddSpell(Ability, False)
  If H > 0.0 && !PlayerRef.IsDead()
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Self.PreserveSatiationCurrentValue("Health", H, PoolEpoch, Owner)
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  Self.PreserveSatiationCurrentValue("Magicka", M, PoolEpoch, Owner)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  Self.PreserveSatiationCurrentValue("Stamina", S, PoolEpoch, Owner)
  If Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    StorageUtil.FormListAdd(PlayerRef as Form, "PSQ_RacialUIv4Refreshed", Ability as Form, False)
  EndIf
EndFunction

Function PublishEnergySenseConfig()
  If PlayerRef == None
    Return
  EndIf
  storageutil.SetFloatValue(PlayerRef as Form, "PSQ_SenseHealthFactor", CalcMaxEnergyHealth)
  storageutil.SetFloatValue(PlayerRef as Form, "PSQ_SenseHumanMinimum", MinEnergyOfHuman)
  storageutil.SetFloatValue(PlayerRef as Form, "PSQ_SenseLoverRecovery", LoversRestoreMult)
  storageutil.SetIntValue(PlayerRef as Form, "PSQ_SenseUseMinimum", AdjustMinEnergyOfHuman as Int)
  storageutil.AdjustIntValue(PlayerRef as Form, "PSQ_SenseConfigRevision", 1)
EndFunction

Function EquipSelectedTransformParts(Int Owner, Bool RequireBusy)
  Self.EquipTransformPartsPhase(Owner, RequireBusy, False, 0.0)
EndFunction

Function EquipTransformPartsPhase(Int Owner, Bool RequireBusy, Bool MainOnly, Float EntryStarted)
  Float GuardStart
  Float GuardEnd
  Bool Valid
  Float[] Samples
  Float PhaseStart
  If EnableEquipmentDiagnostics
    PhaseStart = Utility.GetCurrentRealTime()
    Samples = new Float[2]
  EndIf
  Int EntryLoad = PSQLoadEpoch
  Self.SyncPlayerAppearanceRace()
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Samples
    GuardStart = Utility.GetCurrentRealTime()
  EndIf
  Valid = Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, EntryLoad)
  If Samples
    GuardEnd = Utility.GetCurrentRealTime()
    Samples[0] += GuardEnd - GuardStart
    Samples[1] += 1.0
  EndIf
  If !Valid
    Return
  EndIf
  If !Self.IsEquipmentSwapPlanCurrent(Owner, RequireBusy)
    If !Self.BuildEquipmentSwapPlan28(OrgArmorList.ToArray(), Self.GetTransformProtectedArmor(), Owner, RequireBusy)
      Return
    EndIf
  EndIf
  Form[] Parts
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777247 && PSQAppearance.ReadPlanState31(PlayerRef,Self,Owner,PSQLoadEpoch,RequireBusy) >= 0
    Parts = PSQAppearance.ReadPlan31(PlayerRef,Self,Owner,PSQLoadEpoch,RequireBusy,False)
  Else
    Parts = storageutil.FormListToArray(Self, "PSQ_EquipPlanParts")
  EndIf
  ; The planner ABI puts feet before torso. Reorder this private copy only.
  Armor Chest = PSQSuccubusCuirass
  Armor Boots = PSQSuccubusBoots
  If Parts.Length >= 2 && Parts[0] == Boots && Parts[1] == Chest
    Parts[0] = Chest
    Parts[1] = Boots
  EndIf
  ; Recheck dynamic native attachments once: slot 52/53 may change during body switching.
  Form[] Protected = Self.GetTransformProtectedArmor()
  Self.InitializeTransformEquipmentLedger(Owner, RequireBusy)
  ; This immutable snapshot is valid only for this operation. Check the live
  ; owner and current body on every item; a skin switch can change the body
  ; family even when the race stays the same. Unknown results use the complete
  ; single-item resolver below, which also handles older appearance plugins.
  Int ApiVersion = SKSE.GetPluginVersion("PSQ Appearance")
  Bool NativePlan = ApiVersion >= 16777219
  Bool TraceEvents = EnableEquipmentDiagnostics && ApiVersion >= 16777221
  Race PlanRace
  Int PlanBody = -1
  Int BatchResult = 0
  If ApiVersion >= 16777247
    BatchResult = PSQAppearance.EquipPublished31(PlayerRef,Self,Owner,EntryLoad,RequireBusy,MainOnly,TraceEvents,Utility.GetCurrentRealTime()-EntryStarted,Protected)
  EndIf
  If BatchResult == 0 && NativePlan
    PlanRace = storageutil.GetFormValue(Self, "PSQ_EquipPlanRace", None) as Race
    PlanBody = storageutil.GetIntValue(Self, "PSQ_EquipPlanUBE", -1)
    NativePlan = PlanRace != None && (PlanBody == 0 || PlanBody == 1) && storageutil.GetIntValue(Self, "PSQ_EquipPlanLoad", -1) == EntryLoad
  EndIf
  If BatchResult != 0 || (ApiVersion >= 16777237 && NativePlan && storageutil.GetIntValue(Self,"PSQ_EquipPlanOwner",-1) == Owner)
    If BatchResult == 0
      BatchResult = PSQAppearance.EquipBatch(PlayerRef,Self,PlayerAppearanceRace,Owner,EntryLoad,RequireBusy,MainOnly,TraceEvents,Utility.GetCurrentRealTime()-EntryStarted,Parts,Protected,PlanRace,PlanBody)
    EndIf
    If BatchResult != 0
      If EnableEquipmentDiagnostics
        Debug.Trace("[PSQ-PERF] enter.equipment_batch; owner=" + Owner + "; main=" + MainOnly + "; receipt=" + BatchResult + "; seconds=" + (Utility.GetCurrentRealTime()-PhaseStart))
        If !MainOnly
          Float[] Observed = PSQAppearance.TakePrimaryEquipTimes(Owner,EntryLoad)
          If Observed && Observed.Length == 2
            Debug.Trace("[PSQ-PERF] enter.equip_events; owner=" + Owner + "; cuirassSinceEntry=" + Observed[0] + "; bootsSinceEntry=" + Observed[1])
          EndIf
        EndIf
      EndIf
      Return
    EndIf
  EndIf
  Int i = 0
  While i < Parts.Length
    If EntryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
      Return
    EndIf
    Armor Item = Parts[i] as Armor
    Bool Primary = (Item == Chest && HenshinCuirass) || (Item == Boots && HenshinBoots)
    If Item != None && (!MainOnly || Primary) && Protected.find(Item, 0) < 0
      Float Started = 0.0
      If EnableEquipmentDiagnostics
        Started = Utility.GetCurrentRealTime()
      EndIf
      Bool SamePlan = False
      If NativePlan && storageutil.GetIntValue(Self, "PSQ_EquipPlanOwner", -1) == Owner && storageutil.FormListFind(Self, "PSQ_EquipPlanParts", Item) >= 0
        SamePlan = PSQAppearance.CheckEquipmentContext(PlayerRef, PlayerAppearanceRace, PlanRace, PlanBody) == 1
      EndIf
      If EntryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
        Return
      EndIf
      If MainOnly && !SamePlan && !Self.IsEquipmentSwapPlanCurrent(Owner, RequireBusy)
        Return
      EndIf
      If TraceEvents && MainOnly
        Int SlotIndex = 1
        If Item == Chest && HenshinCuirass
          SlotIndex = 0
        EndIf
        PSQAppearance.WatchPrimaryEquip(Owner, EntryLoad, SlotIndex, Item, Utility.GetCurrentRealTime() - EntryStarted)
      EndIf
      If SamePlan
        Self.EquipResolvedEntryPart(Item, Owner, RequireBusy, EntryLoad, Samples)
      Else
        Self.EnsurePlannedEntryPart(Item, Owner, RequireBusy, Samples)
      EndIf
      If EnableEquipmentDiagnostics
        If MainOnly
          String Slot = "boots"
          If Item == Chest && HenshinCuirass
            Slot = "cuirass"
          EndIf
          Bool Worn = PlayerRef.IsEquipped(Item)
          Debug.Trace("[PSQ-PERF] enter.first_equip; slot=" + Slot + "; item=" + Item + "; equipped=" + Worn + "; sinceEntry=" + (Utility.GetCurrentRealTime() - EntryStarted))
        EndIf
        Debug.Trace("[PSQ-EQUIP] transform; item=" + Item + "; seconds=" + (Utility.GetCurrentRealTime() - Started))
      EndIf
    EndIf
    i += 1
  EndWhile
  If TraceEvents && !MainOnly && EntryLoad == PSQLoadEpoch && Owner == AppearanceOperationId
    Float[] Times = PSQAppearance.TakePrimaryEquipTimes(Owner, EntryLoad)
    If Times && Times.Length == 2
      Debug.Trace("[PSQ-PERF] enter.equip_events; owner=" + Owner + "; cuirassSinceEntry=" + Times[0] + "; bootsSinceEntry=" + Times[1] + "; -1=no matching event observed")
    EndIf
  EndIf
  If Samples
    Debug.Trace("[PSQ-PERF] enter.equip_guard_times; owner=" + Owner + "; mainOnly=" + MainOnly + "; calls=" + (Samples[1] as Int) + "; guardSeconds=" + Samples[0] + "; phaseSeconds=" + (Utility.GetCurrentRealTime() - PhaseStart))
  EndIf
EndFunction

Int Function GetTransformBlockingSlotMask(Form[] Originals, Form[] Protected, Armor[] Selected, Int Owner, Bool RequireBusy)
  Int Mask = 0
  Int Used = 0
  If TransformInventoryLedgerReady
    Used = TransformInventoryItems.find(None, 0)
    If Used < 0
      Used = TransformInventoryItems.Length
    EndIf
  EndIf
  Int Index = 0
  While Index < Used
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return 0
    EndIf
    Armor Item = TransformInventoryItems[Index] as Armor
    If Item != None && TransformInventoryItems.find(Item as Form, 0) == Index && Originals.find(Item as Form, 0) < 0 && Protected.find(Item as Form, 0) < 0
      If PlayerRef.IsEquipped(Item as Form)
        Mask = Math.LogicalOr(Mask, Item.GetSlotMask())
      EndIf
    EndIf
    Index += 1
  EndWhile
  Index = 0
  While Index < Selected.Length
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return 0
    EndIf
    Armor item = Selected[Index]
    Bool Tracked = False
    If TransformInventoryLedgerReady
      Tracked = TransformInventoryItems.find(item as Form, 0) >= 0
    EndIf
    If item != None && !Tracked && Selected.find(item, 0) == Index && Originals.find(item as Form, 0) < 0 && Protected.find(item as Form, 0) < 0
      If PlayerRef.IsEquipped(item as Form)
        Mask = Math.LogicalOr(Mask, item.GetSlotMask())
      EndIf
    EndIf
    Index += 1
  EndWhile
  Return Mask
EndFunction

Function RefillTransformAttributes(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777239
    Self.RunEntryStatStage(Owner,PSQLoadEpoch,True)
    Return
  EndIf
  If !Self.IsEntryRefillCurrent(Owner, RequireBusy) || TransformAttributesRefilledOwner == Owner || TransformRefillBusyOwner == Owner || Self.GetTransformBuffMode() == 0
    Return
  EndIf
  TransformRefillBusyOwner = Owner
  Bool Prepared = False
  Int Attempt = 0
  While Attempt < 4 && Self.IsEntryRefillCurrent(Owner, RequireBusy)
    Int PoolEpoch = Self.BeginStatPoolEdit(Owner, True)
    Float[] Caps
    Bool Ready = False
    If PoolEpoch >= 0
      If !Prepared
        Self.FinalizeTransformAttributeRefillCore(Owner, RequireBusy, PoolEpoch)
        Prepared = Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      EndIf
      If Prepared && Self.IsStatPoolEditCurrent(PoolEpoch, Owner) && Self.IsEntryRefillCurrent(Owner, RequireBusy)
        Ready = Self.AreEntryStatEffectsReady()
        If Ready
          ; Synchronization above can change caps. Compare its result with
          ; the verified early sample before doing any further restores.
          If Attempt == 0 && TransformPoolsPrimedOwner == Owner && PrimedTransformPoolLoad == PSQLoadEpoch && PrimedTransformPoolValues
            Float[] FinalValues = Self.CaptureTransformPoolValues()
            If Self.SameEntryPoolValues(PrimedTransformPoolValues, FinalValues) && Self.AreSampledPoolsFull(FinalValues) && Self.IsEntryRefillCurrent(Owner, RequireBusy) && Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
              TransformAttributesRefilledOwner = Owner
              Self.EndStatPoolEdit(PoolEpoch)
              If TransformRefillBusyOwner == Owner
                TransformRefillBusyOwner = -1
              EndIf
              If EnableEquipmentDiagnostics
                Debug.Trace("[PSQ-REFILL] unchanged; owner=" + Owner + "; full refill skipped")
              EndIf
              Self.TraceSampledPools("final", Owner, FinalValues)
              Return
            EndIf
          EndIf
          Float[] Before = Self.RefillAndSampleTransformPools(Owner, RequireBusy, PoolEpoch)
          If Before && Before.Length == 6
            Caps = new Float[3]
            Caps[0] = Before[3]
            Caps[1] = Before[4]
            Caps[2] = Before[5]
          EndIf
        EndIf
      EndIf
      Self.EndStatPoolEdit(PoolEpoch)
    EndIf
    Utility.Wait(0.1)
    If Ready && Self.IsEntryRefillCurrent(Owner, RequireBusy)
      PoolEpoch = Self.BeginStatPoolEdit(Owner, True)
      If PoolEpoch >= 0
        Bool EffectsReady = Self.AreEntryStatEffectsReady()
        Float[] Observed
        If EffectsReady
          Observed = Self.CaptureTransformPoolValues()
        EndIf
        Bool Complete = EffectsReady && Self.SampledCapsMatch(Caps, Observed) && Self.AreSampledPoolsFull(Observed)
        If Complete && Self.IsStatPoolEditCurrent(PoolEpoch, Owner) && Self.IsEntryRefillCurrent(Owner, RequireBusy)
          TransformAttributesRefilledOwner = Owner
          Self.EndStatPoolEdit(PoolEpoch)
          If TransformRefillBusyOwner == Owner
            TransformRefillBusyOwner = -1
          EndIf
          Debug.Trace("[PSQ-REFILL] verified owner=" + Owner + "; attempts=" + (Attempt + 1), 0)
          Self.TraceSampledPools("final", Owner, Observed)
          Return
        EndIf
        Self.EndStatPoolEdit(PoolEpoch)
      EndIf
    EndIf
    Attempt += 1
  EndWhile
  If TransformRefillBusyOwner == Owner
    TransformRefillBusyOwner = -1
  EndIf
  If Self.IsEntryRefillCurrent(Owner, RequireBusy)
    Debug.Trace("[PSQ-REFILL] incomplete owner=" + Owner + "; deferred completion requested", 1)
    Self.TraceTransformPools("incomplete", Owner)
    Self.QueueDeferredTransformRefill(Owner, RequireBusy)
  EndIf
EndFunction

Function RefillTransformAttributesCore(Int Owner, Bool RequireBusy, Int PoolEpoch)
  Self.RefillAndSampleTransformPools(Owner, RequireBusy, PoolEpoch)
EndFunction

Float[] Function RefillAndSampleTransformPools(Int Owner, Bool RequireBusy, Int PoolEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777239
    Return PSQAppearance.FillOwnedEntryPools(PlayerRef,Self,Owner,PSQLoadEpoch,PoolEpoch)
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner) || !Self.IsEntryRefillCurrent(Owner, RequireBusy) || TransformAttributesRefilledOwner == Owner || Self.GetTransformBuffMode() == 0 || !PlayerRef.HasSpell(SuccubusHenshinBonusSpell as Form)
    Return None
  EndIf
  Float[] Values = Self.CaptureTransformPoolValues()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777226
    Float[] Percent = new Float[3]
    Percent[0] = PlayerRef.GetActorValuePercentage("Health")
    Percent[1] = PlayerRef.GetActorValuePercentage("Magicka")
    Percent[2] = PlayerRef.GetActorValuePercentage("Stamina")
    If !Self.IsEntryRefillCurrent(Owner, RequireBusy) || !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return None
    EndIf
    Int Filled = PSQAppearance.FillTransformPools(PlayerRef, Self, PlayerAppearanceRace, Owner, PSQLoadEpoch, PoolEpoch, RequireBusy, Values, Percent)
    If Filled == 1
      Return Values
    ElseIf Filled < 0
      Return None
    EndIf
  EndIf
  Float HMax = Values[3]
  Float MMax = Values[4]
  Float SMax = Values[5]
  Float H = Values[0]
  Float M = Values[1]
  Float S = Values[2]
  HMax = Self.GetPoolRestoreMaximum("Health", H, HMax)
  MMax = Self.GetPoolRestoreMaximum("Magicka", M, MMax)
  SMax = Self.GetPoolRestoreMaximum("Stamina", S, SMax)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner) || !Self.IsEntryRefillCurrent(Owner, RequireBusy)
    Return None
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777225
    Float[] Maxima = new Float[3]
    Maxima[0] = HMax
    Maxima[1] = MMax
    Maxima[2] = SMax
    Int Receipt = PSQAppearance.RestoreTransformPools(PlayerRef, Self, PlayerAppearanceRace, Owner, PSQLoadEpoch, PoolEpoch, RequireBusy, Values, Maxima)
    If Receipt == 1
      Return Values
    ElseIf Receipt < 0
      Return EmptyFloatArray
    EndIf
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner) || !Self.IsEntryRefillCurrent(Owner, RequireBusy)
      Return EmptyFloatArray
    EndIf
  EndIf
  If HMax > H && H > 0.0
    PlayerRef.RestoreAV("Health", HMax - H)
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return None
  EndIf
  If MMax > M
    PlayerRef.RestoreAV("Magicka", MMax - M)
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return None
  EndIf
  If SMax > S
    PlayerRef.RestoreAV("Stamina", SMax - S)
  EndIf
  Return Values
EndFunction

Int Function BeginStatPoolEdit(Int Owner, Bool AllowAppearance)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777239
    Return PSQAppearance.BeginPoolEdit(Self,Owner,AllowAppearance)
  EndIf
  If StatPoolEditBusy || Owner != AppearanceOperationId
    Return -1
  EndIf
  If !AllowAppearance && (AppearanceEditBusy || IsHenshinchu || AppearanceRecoveryPending || AppearanceRecoveryRequested || UninstallPrepared || UninstallCleanupBusy)
    Return -1
  EndIf
  StatPoolEditEpoch += 1
  StatPoolEditBusy = True
  Return StatPoolEditEpoch
EndFunction

Bool Function IsStatPoolEditCurrent(Int PoolEpoch, Int Owner)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.PoolCurrent34(Self, PoolEpoch, Owner)
  EndIf
  Return StatPoolEditBusy && PoolEpoch == StatPoolEditEpoch && (Owner < 0 || Owner == AppearanceOperationId)
EndFunction

Function EndStatPoolEdit(Int PoolEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777239
    PSQAppearance.EndPoolEdit(Self,PoolEpoch)
    Return
  EndIf
  If PoolEpoch == StatPoolEditEpoch
    StatPoolEditBusy = False
  EndIf
EndFunction

Function ResetStatPoolEditsOnLoad()
  Self.ResetStatPoolEditsOnLoad35()
EndFunction

Function BufferTransformEntryHealth(Int Owner)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777239
    Self.RunEntryStatStage(Owner,PSQLoadEpoch,False)
    Return
  EndIf
  If !Self.IsEntryRefillCurrent(Owner, True) || TransformPoolsPrimedOwner == Owner || TransformAttributesRefilledOwner == Owner || Self.GetTransformBuffMode() == 0
    Return
  EndIf
  Int Attempt = 0
  While Attempt < 4 && Self.IsEntryRefillCurrent(Owner, True)
    Int PoolEpoch = Self.BeginStatPoolEdit(Owner, True)
    If PoolEpoch >= 0
      Self.RefillTransformAttributesCore(Owner, True, PoolEpoch)
      Bool Ready = Self.AreStatPoolEffectsReady(SuccubusHenshinBonusSpell)
      Float[] Observed = Self.CaptureTransformPoolValues()
      Bool Full = Self.AreSampledPoolsFull(Observed)
      Bool Current = Self.IsStatPoolEditCurrent(PoolEpoch, Owner) && Self.IsEntryRefillCurrent(Owner, True)
      Self.EndStatPoolEdit(PoolEpoch)
      If Current && Ready && Full
        PrimedTransformPoolValues = Observed
        PrimedTransformPoolLoad = TransformEntryLoadEpoch
        TransformPoolsPrimedOwner = Owner
        Self.TraceSampledPools("early", Owner, Observed)
        Return
      EndIf
    EndIf
    Attempt += 1
    If Attempt < 4
      Utility.Wait(0.05)
    EndIf
  EndWhile
EndFunction

Function FinalizeTransformAttributeRefillCore(Int Owner, Bool RequireBusy, Int PoolEpoch)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner) || !Self.IsAppearanceOperationCurrent(Owner, RequireBusy) || !IsHenshined || AppearanceTransformDirection != 1
    Return
  EndIf
  Float Started
  If EnableEquipmentDiagnostics
    Started = Utility.GetCurrentRealTime()
  EndIf
  Bool ForceContinuous = ContinuousSyncPending
  ContinuousSyncPending = False
  Self.SyncContinuousAbilitiesCore(ForceContinuous, Owner, PoolEpoch)
  If EnableEquipmentDiagnostics
    Debug.Trace("[PSQ-PERF] refill.continuous; seconds=" + (Utility.GetCurrentRealTime() - Started))
    Started = Utility.GetCurrentRealTime()
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  ContinuousSyncBusy = False
  Bool ForceTransform = ForceTransformBuffRefresh
  ForceTransformBuffRefresh = False
  TransformBuffRefreshPending = False
  Self.UpdateTransformBuffCore(True, Owner, PoolEpoch, ForceTransform)
  If EnableEquipmentDiagnostics
    Debug.Trace("[PSQ-PERF] refill.transform; seconds=" + (Utility.GetCurrentRealTime() - Started))
    Started = Utility.GetCurrentRealTime()
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  SatiationTimedRefreshEpoch += 1
  SatiationTimedRefreshQueued = False
  SatiationLastAttributeRefresh = -10.0
  If PlayerRef.HasSpell(SuccubusSatiatySpellA) || PlayerRef.HasSpell(SuccubusSatiatySpellB) || PlayerRef.HasSpell(SuccubusSatiatySpellC)
    Self.RefreshSatiationAttributesCore(0.0, Owner, PoolEpoch)
  Else
    SatiationRefreshPending = False
  EndIf
  If Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Self.RefreshManagedMovement(Self.GetRankSpeedBonus(IsHenshined))
  EndIf
  If EnableEquipmentDiagnostics
    Debug.Trace("[PSQ-PERF] refill.satiation; seconds=" + (Utility.GetCurrentRealTime() - Started))
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  SatiationRefreshBusy = False
EndFunction

Bool Function HasWingflight()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    Return PSQAppearance.ExternalPluginVersion33("Wingflight") >= 0
  EndIf
  Return skse.GetPluginVersion("Wingflight") >= 0
EndFunction

Function SendWingflightCommand(String Command, Float value)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    PSQAppearance.SendFlightCommand33(PlayerRef, Command, value)
    Return
  EndIf
  If PlayerRef != None && Self.HasWingflight()
    PlayerRef.SendModEvent("PSQ_WingflightRequest", Command, value)
  EndIf
EndFunction

Function InitializeWingflightIntegration()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If PSQAppearance.FlightDefinitions34(Self)
      Self.UnregisterForModEvent("PSQ_WingflightReply")
      Self.RegisterForModEvent("PSQ_WingflightReply", "OnWingflightReply")
      PSQAppearance.DisconnectFlight34(Self)
      Self.ReleasePSQJumpHeight()
      Self.CleanupRetiredFlightForms()
      Self.ResetWingflightProbe()
      Self.RefreshWingflightState()
      Return
    EndIf
  EndIf
  String Definitions = ""
  Bool HasBDI = SKSE.GetPluginVersion("BehaviorDataInjector") >= 0
  String Path = "Data/SKSE/Plugins/BehaviorDataInjector/Wingflight_BDI.json"
  If HasBDI && Self.HasWingflight() && MiscUtil.FileExists(Path)
    Definitions = MiscUtil.ReadFromFile(Path)
  EndIf
  WingflightHasFlyingVar = StringUtil.Find(Definitions, "\"Wingflight_IsFlying\"") >= 0
  WingflightHasHoverVar = StringUtil.Find(Definitions, "\"Wingflight_GroundHover\"") >= 0
  WingflightHasTakeoffVar = StringUtil.Find(Definitions, "\"Wingflight_LocalTakeoff\"") >= 0
  WingflightHasLandingVar = StringUtil.Find(Definitions, "\"Wingflight_LocalLanding\"") >= 0
  WingflightHasPSQVar = HasBDI && MiscUtil.FileExists("Data/SKSE/Plugins/BehaviorDataInjector/PSQ_Wingflight_BDI.json")
  Self.UnregisterForModEvent("PSQ_WingflightReply")
  Self.RegisterForModEvent("PSQ_WingflightReply", "OnWingflightReply")
  WingflightBridgeReady = False
  WingflightPublishedPolicy = -1
  WingflightPublishedJump = -1.0
  WingflightPublishedKey = -1
  Self.ReleasePSQJumpHeight()
  Self.CleanupRetiredFlightForms()
  Self.ResetWingflightProbe()
  Self.RefreshWingflightState()
EndFunction

Function RefreshWingflightState()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If UninstallPrepared || UninstallCleanupBusy || PlayerRef == None || !Self.HasWingflight()
      Return
    EndIf
    If PSQAppearance.RefreshFlight34(Self, PSQLoadEpoch, WingflightProbeGeneration, Utility.GetCurrentRealTime())
      Return
    EndIf
  EndIf
  If UninstallPrepared || UninstallCleanupBusy || PlayerRef == None || !Self.HasWingflight()
    Return
  EndIf
  If WingflightProbeLoadEpoch != PSQLoadEpoch
    Self.ResetWingflightProbe()
    WingflightBridgeReady = False
    WingflightPublishedPolicy = -1
    WingflightPublishedJump = -1.0
    WingflightPublishedKey = -1
  EndIf
  Int ProbeLoad = PSQLoadEpoch
  Int ProbeGeneration = WingflightProbeGeneration
  Float Now = Utility.GetCurrentRealTime()
  If ProbeLoad != PSQLoadEpoch || ProbeGeneration != WingflightProbeGeneration
    Return
  EndIf
  If WingflightBridgeReady
    ; Preserve the old bridge's wings reports, coalescing rapid equip events.
    If Now >= WingflightNextQueryAt
      WingflightNextQueryAt = Now + 1.0
      Self.SendWingflightCommand("query", 0.0)
    EndIf
  ElseIf WingflightProbeAttempts < 4 && Now >= WingflightNextQueryAt
    WingflightProbeAttempts += 1
    If WingflightProbeAttempts == 1
      WingflightNextQueryAt = Now + 6.0
    ElseIf WingflightProbeAttempts == 2
      WingflightNextQueryAt = Now + 12.0
    Else
      WingflightNextQueryAt = Now + 24.0
    EndIf
    ; Native OSYRN is still usable without this optional PSQ handshake.
    Self.SendWingflightCommand("query", 0.0)
  EndIf
  Self.SyncWingflightPolicy()
EndFunction

Function SyncWingflightPolicy()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    If PSQAppearance.SyncFlightPolicy33(Self)
      Return
    EndIf
  EndIf
  If !WingflightBridgeReady || PlayerRef == None
    Return
  EndIf
  Int policy = 0
  If !UninstallPrepared
    If AppearanceEditBusy || IsHenshinchu || BodySelectionRefreshBusy || AppearanceRecoveryPending || AppearanceRecoveryRequested || UninstallCleanupBusy
      policy = 1
    ElseIf PlayerIsSuccubus.GetValueInt() == 1
      policy = 1
      If SuccubusRank.GetValueInt() >= CanFlyingLevel && EnableAutoAddFlying
        policy = 2
      EndIf
    EndIf
  EndIf
  If policy != WingflightPublishedPolicy
    Self.SendWingflightCommand("policy", policy as Float)
    WingflightPublishedPolicy = policy
  EndIf
  Float BaseHeight = Game.GetGameSettingFloat("fJumpHeightMin")
  If BaseHeight <= 0.0
    BaseHeight = 76.0
  EndIf
  Float Ratio = WingMaxJumpHeight / BaseHeight
  If Ratio < 0.100000001
    Ratio = 0.100000001
  ElseIf Ratio > 10.0
    Ratio = 10.0
  EndIf
  If Math.Abs(Ratio - WingflightPublishedJump) >= 0.001
    Self.SendWingflightCommand("jump-height", Ratio)
    WingflightPublishedJump = Ratio
  EndIf
  If WingflightPublishedKey != 0
    Self.SendWingflightCommand("hotkey", 0.0)
    WingflightPublishedKey = 0
  EndIf
EndFunction

Bool Function IsWingflightAirborne()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    Int NativeFlight = PSQAppearance.FlightAirborne33(Self)
    If NativeFlight >= 0
      Return NativeFlight == 1
    EndIf
  EndIf
  If !Self.HasWingflight() || !PlayerRef || !PlayerRef.Is3DLoaded()
    Return False
  EndIf
  Return PlayerRef.GetAnimationVariableBool("bInJumpState") || (WingflightHasFlyingVar && PlayerRef.GetAnimationVariableBool("Wingflight_IsFlying")) || (WingflightHasHoverVar && PlayerRef.GetAnimationVariableBool("Wingflight_GroundHover")) || (WingflightHasTakeoffVar && PlayerRef.GetAnimationVariableBool("Wingflight_LocalTakeoff")) || (WingflightHasLandingVar && PlayerRef.GetAnimationVariableBool("Wingflight_LocalLanding")) || (WingflightHasPSQVar && PlayerRef.GetAnimationVariableBool("PSQ_WingflightAirborne"))
EndFunction

Function OnWingflightReply(String EventName, String Status, Float value, Form Sender)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If Sender != PlayerRef
      Return
    EndIf
    Float ReplyTime = 0.0
    Int ReplyLoad = PSQLoadEpoch
    Int ReplyGeneration = WingflightProbeGeneration
    If Status == "Ready" && value < 1.0
      ReplyTime = Utility.GetCurrentRealTime()
    EndIf
    If PSQAppearance.FlightReply34(Self, Status, value, Sender, ReplyLoad, ReplyGeneration, ReplyTime)
      Return
    EndIf
  EndIf
  If Sender != PlayerRef as Form
    Return
  EndIf
  If Status == "Ready"
    Bool WasReady = WingflightBridgeReady
    WingflightBridgeReady = value >= 1.0
    If WasReady && !WingflightBridgeReady
      Int ProbeLoad = PSQLoadEpoch
      Self.ResetWingflightProbe()
      Int ProbeGeneration = WingflightProbeGeneration
      Float Now = Utility.GetCurrentRealTime()
      If ProbeLoad == PSQLoadEpoch && ProbeGeneration == WingflightProbeGeneration
        WingflightNextQueryAt = Now + 6.0
      EndIf
    EndIf
    If !WingflightBridgeReady || !WasReady
      WingflightPublishedPolicy = -1
      WingflightPublishedJump = -1.0
      WingflightPublishedKey = -1
    EndIf
    If WingflightBridgeReady
      Self.SyncWingflightPolicy()
    EndIf
  ElseIf Status == "wings" && HasWing != None
    HasWing.SetValue(value)
    Self.UpdatePSQWingJumpHeight(False)
  ElseIf Status == "blocked"
    If value == 1.0
      Debug.Notification("未发现已注册的翅膀；请检查 Wingflight 翅膀配置。")
    ElseIf value == 2.0
      Debug.Notification("当前 PSQ 飞行能力已暂停，请检查等级或等待外观流程结束。")
    Else
      Debug.Notification("当前状态无法起飞，请确认角色可行动且已正确安装飞行资源。")
    EndIf
  EndIf
EndFunction

String Function GetWingflightStatus()
  If !HasWingflight()
    Return "未安装"
  ElseIf CanControlWingflightPolicy()
    Return "PSQ 接口已连接（等级／跳跃控制）"
  ElseIf IsWingflightNativeReady()
    Return "独立控制已就绪（Wingflight／OSYRN 菜单）"
  EndIf
  Return "已安装但未就绪（检查 Wingflight 设置或日志）"
EndFunction

Bool Function WaitForSatiationHealthEffect(Spell NextSpell, Spell PreviousSpell, Int PoolEpoch, Int Owner)
  MagicEffect NextEffect = NextSpell.GetNthEffectMagicEffect(0)
  MagicEffect PreviousEffect = PreviousSpell.GetNthEffectMagicEffect(0)
  If NextEffect == None || PreviousEffect == None || NextEffect == PreviousEffect
    Return False
  EndIf
  Int Attempts = 0
  While Attempts < 20
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner) || PlayerRef == None || PlayerRef.IsDead()
      Return False
    EndIf
    If Self.AreStatPoolEffectsReady(NextSpell) && !PlayerRef.HasMagicEffect(PreviousEffect)
      Return True
    EndIf
    Attempts += 1
    If Attempts < 20
      Utility.Wait(0.05)
    EndIf
  EndWhile
  Debug.Trace("[PSQ] Satiation health effects did not settle; skipping health trim", 1)
  Return False
EndFunction

Float Function GetSafeSatiationHealthRate(Float Requested)
  If PlayerRef == None
    Return 0.0
  EndIf
  If Requested >= 0.0
    Return Requested
  EndIf
  Float Owned = 0.0
  If (StableAppliedSatiationMagnitudes as Bool && StableAppliedSatiationMagnitudes.Length == 9) && StableAppliedSatiationSpell != None && PlayerRef.HasSpell(StableAppliedSatiationSpell as Form) && !(PlayerRef.HasSpell(SuccubusSatiatySpellA as Form) && PlayerRef.HasSpell(SuccubusSatiatySpellB as Form))
    Owned = StableAppliedSatiationMagnitudes[3]
  EndIf
  Float OtherRate = PlayerRef.GetAV("HealRateMult") - Owned
  If OtherRate < 0.0
    OtherRate = 0.0
  EndIf
  If Requested < -OtherRate
    Return -OtherRate
  EndIf
  Return Requested
EndFunction

Bool Function RefreshEquipmentBodyMorphs()
  If PlayerRef == None || UninstallPrepared || UninstallCleanupBusy || !Self.HasNiOverrideRuntime()
    Return True
  EndIf
  If AppearanceEditBusy || IsHenshinchu || BodySelectionRefreshBusy || AppearanceRecoveryPending || AppearanceRecoveryRequested
    Return False
  EndIf
  If !PlayerRef.Is3DLoaded()
    Return False
  EndIf
  Int Owner = AppearanceOperationId
  If !Self.IsAppearanceOperationCurrent(Owner, False)
    Return False
  EndIf
  PSQEquipmentMorphTicket = 0
  nioverride.UpdateModelWeight(PlayerRef as ObjectReference)
  Return True
EndFunction

Function EnsureOptionalHornCatalog()
  Self.EnsureOptionalHornCatalog38()
EndFunction

Int Function GetOptionalHornCount()
  Self.EnsureOptionalHornCatalog()
  If !OptionalHornCatalogReady
    Return 0
  EndIf
  Return OptionalHornCount
EndFunction

String Function GetIndependentTransformPartName(Int Part, Int Choice)
  Return Self.GetIndependentTransformPartName38(Part, Choice)
EndFunction

Function CleanupRetiredFlightForms()
  If PlayerRef == None
    Return
  EndIf
  Spell RetiredAbility = Game.GetFormFromFile(3704, "PSQ PlayerSuccubusQuest.esm") as Spell
  If RetiredAbility != None
    PlayerRef.RemoveSpell(RetiredAbility)
  EndIf
  Self.ResolveOptionalWingSelection()
  Armor RetiredWing = Game.GetFormFromFile(3702, "PSQ PlayerSuccubusQuest.esm") as Armor
  If RetiredWing != None && !Self.IsWingflightAirborne()
    If PSQSuccubusWings == RetiredWing
      PSQSuccubusWings = Self.GetOutfitWings(-1)
    EndIf
    Int OldCopies = PlayerRef.GetItemCount(RetiredWing as Form)
    If OldCopies > 0
      PlayerRef.RemoveItem(RetiredWing as Form, OldCopies, True, None)
    EndIf
  EndIf
  If !RetiredWingMigrationDone
    Armor Retired = Game.GetFormFromFile(3702, "PSQ PlayerSuccubusQuest.esm") as Armor
    Form[] Owners = storageutil.debug_AllFormObjs()
    Int Index = 0
    While Owners as Bool && Index < Owners.Length
      Actor Target = Owners[Index] as Actor
      If Target != None && Target != PlayerRef && Retired != None && (storageutil.GetFormValue(Target as Form, "PSQ_NPCWings", None) == Retired as Form)
        Bool Worn = Target.IsEquipped(Retired as Form)
        storageutil.SetFormValue(Target as Form, "PSQ_NPCWings", SuccubusStaticWings as Form)
        Int Copies = Target.GetItemCount(Retired as Form)
        If Copies > 0
          Target.RemoveItem(Retired as Form, Copies, True, None)
        EndIf
        If Worn && SuccubusStaticWings != None
          Target.AddItem(SuccubusStaticWings as Form, 1, True)
          Target.EquipItem(SuccubusStaticWings as Form, False, True)
        EndIf
      EndIf
      Index += 1
    EndWhile
    RetiredWingMigrationDone = True
  EndIf
EndFunction

Function BeginDeferredDrain(Actor Target, Int TID)
  Self.BeginDeferredDrain35(Target,TID)
EndFunction

Bool Function EnsureDeferredDrain(Actor Target, Int TID)
  Return Self.EnsureDeferredDrain35(Target,TID)
EndFunction

Function QueueDeferredDrainDamage(Actor Target, Float Amount, Bool PlayerIsVictim, Bool PlayerIsAggressor)
  Self.QueueDeferredDrainDamage35(Target,Amount,PlayerIsVictim,PlayerIsAggressor)
EndFunction

Function FlushDeferredDrain(Actor Target, Int TID)
  Self.FlushDeferredDrain35(Target,TID)
EndFunction


Bool Function CanControlWingflightPolicy()
  Return HasWingflight() && WingflightBridgeReady
EndFunction


Bool Function IsWingflightNativeReady()
  If !HasWingflight()
    Return False
  EndIf
  Return WingflightNative.IsEnabled()
EndFunction

String Function GetSexLabFrameworkStatus()
  if SexLab == None || !Self.IsIntegrationPluginLoaded("SexLab.esm")
    return "未检测到 SexLab"
  endif
  if Self.IsSexLabPPlus()
    return "SexLab P+（独立高潮接口）"
  endif
  if Self.IsLegacySeparateOrgasmMode()
    return "旧 SexLab + SLSO（独立高潮已启用）"
  endif
  return "旧 SexLab（普通高潮接口）"
EndFunction

Int Function GetSLIFBridgeBackend()
Return 0
EndFunction

String Function GetSLIFBridgeStatus()
Return "$PSQ_InflationRemoved"
EndFunction


Function RestoreContinuousRuntimeRecords(Int Mode, Int Rank, Float BH, Float BM, Float BS, Float BC, Float BU, Int Owner, Int PoolEpoch)
  If !ContinuousRecordSyncPending || Mode != 1 || !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  Spell Ability = Self.GetContinuousRankAbility()
  Perk RankPerk = Self.GetContinuousRankPerk()
  If Ability == None || RankPerk == None
    Return
  EndIf
  Float[] Values = new Float[8]
  Values[0] = BH * (Rank as Float * 0.100000001)
  Values[1] = BM * (Rank as Float * 0.100000001)
  Values[2] = BS * (Rank as Float * 0.100000001)
  Values[3] = BC * (Rank as Float * 0.100000001)
  Values[4] = BU * (Rank as Float * 5.0) / 100.0
  Values[5] = Rank as Float * 5.0
  Values[6] = Rank as Float * 3.0
  Values[7] = Rank as Float * 5.0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777226
    Int Applied = PSQAppearance.SyncTransformRecords(PlayerRef, Self, Owner, PSQLoadEpoch, PoolEpoch, Ability, Values, RankPerk, 1.0 + Values[5] / 100.0)
    If Applied != 0
      If Applied > 0 && Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        ContinuousRecordSyncPending = False
      EndIf
      Return
    EndIf
  EndIf
  Int i = 0
  While i < 8
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    If Ability.GetNthEffectMagnitude(i) != Values[i]
      Ability.SetNthEffectMagnitude(i, Values[i])
    EndIf
    i += 1
  EndWhile
  i = 0
  While i < 7
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Float Power = 1.0 + (Rank as Float * 5.0) / 100.0
    If RankPerk.GetNthEntryValue(i, 1) != Power
      RankPerk.SetNthEntryValue(i, 1, Power)
    EndIf
    i += 1
  EndWhile
  If Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    ContinuousRecordSyncPending = False
  EndIf
EndFunction

Function CommitTransformMagnitudes(Float H, Float M, Float S, Float C, Int Owner, Int PoolEpoch)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner) || !PlayerRef.HasSpell(SuccubusHenshinBonusSpell as Form)
    Return
  EndIf
  Float[] Values = new Float[4]
  Values[0] = H
  Values[1] = M
  Values[2] = S
  Values[3] = C
  If Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    StableTransformMagnitudes = Values
    TransformRecordSyncPending = False
  EndIf
EndFunction

Function RestoreTransformRuntimeRecords(Int Owner, Int PoolEpoch)
  If !TransformRecordSyncPending || !StableTransformMagnitudes || StableTransformMagnitudes.Length != 4 || !PlayerRef.HasSpell(SuccubusHenshinBonusSpell as Form)
    Return
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777226
    Int Applied = PSQAppearance.SyncTransformRecords(PlayerRef, Self, Owner, PSQLoadEpoch, PoolEpoch, SuccubusHenshinBonusSpell, StableTransformMagnitudes, None, 0.0)
    If Applied != 0
      If Applied > 0 && Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        TransformRecordSyncPending = False
      EndIf
      Return
    EndIf
  EndIf
  Int i = 0
  While i < 4
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    If SuccubusHenshinBonusSpell.GetNthEffectMagnitude(i) != StableTransformMagnitudes[i]
      SuccubusHenshinBonusSpell.SetNthEffectMagnitude(i, StableTransformMagnitudes[i])
    EndIf
    i += 1
  EndWhile
  If Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    TransformRecordSyncPending = False
  EndIf
EndFunction

Function RestoreSatiationRuntimeRecords(Int Owner, Int PoolEpoch)
  ; Never restore cached pre-migration attribute magnitudes on load.
  SatiationRecordSyncPending = False
EndFunction

Float Function GetAuditedRacialHealthBonus(Spell Ability)
  Float Value = 0.0
  MagicEffect HealthEffect = Game.GetFormFromFile(8389304, "Mannaz - Integrated Races of Skyrim.esp") as MagicEffect
  Int i = 0
  While Ability != None && i < Ability.GetNumEffects()
    MagicEffect Effect = Ability.GetNthEffectMagicEffect(i)
    If HealthEffect != None && Effect == HealthEffect
      Float Magnitude = Ability.GetNthEffectMagnitude(i)
      If Magnitude > 0.0
        Value += Magnitude
      EndIf
    EndIf
    i += 1
  EndWhile
  Return Value
EndFunction


Bool Function IsEntryRefillCurrent(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.RefillCurrent34(Self, Owner, RequireBusy)
  EndIf
  If PlayerRef == None || UninstallPrepared || UninstallCleanupBusy
    Return False
  EndIf
  Return TransformEntryLoadEpoch == PSQLoadEpoch && Self.IsAppearanceOperationCurrent(Owner, RequireBusy) && IsHenshined && AppearanceTransformDirection == 1 && AppearanceSnapshotReady && !PlayerRef.IsDead() && PlayerRef.GetAV("Health") > 0.0
EndFunction


Bool Function AreStatPoolEffectsReady(Spell Ability)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777219
    Float[] Magnitudes = EmptyFloatArray
    If Ability == SuccubusHenshinBonusSpell && StableTransformMagnitudes && StableTransformMagnitudes.Length == 4
      Magnitudes = StableTransformMagnitudes
    ElseIf Ability == StableAppliedSatiationSpell && StableAppliedSatiationMagnitudes && StableAppliedSatiationMagnitudes.Length == 9
      Magnitudes = StableAppliedSatiationMagnitudes
    EndIf
    Int Ready = PSQAppearance.CheckStatEffects(PlayerRef, Ability, Magnitudes)
    If Ready >= 0
      Return Ready == 1
    EndIf
  EndIf
  If PlayerRef == None || Ability == None || !PlayerRef.HasSpell(Ability as Form) || Ability.GetNumEffects() < 3
    Return False
  EndIf
  Int i = 0
  While i < 3
    MagicEffect Effect = Ability.GetNthEffectMagicEffect(i)
    If Effect == None
      Return False
    EndIf
    Float Magnitude = Ability.GetNthEffectMagnitude(i)
    If Ability == SuccubusHenshinBonusSpell && StableTransformMagnitudes && StableTransformMagnitudes.Length == 4
      Magnitude = StableTransformMagnitudes[i]
    ElseIf Ability == StableAppliedSatiationSpell && StableAppliedSatiationMagnitudes && StableAppliedSatiationMagnitudes.Length == 9
      Magnitude = StableAppliedSatiationMagnitudes[i]
    EndIf
    If Magnitude != 0.0 && !PlayerRef.HasMagicEffect(Effect)
      Return False
    EndIf
    i += 1
  EndWhile
  Return True
EndFunction


Bool Function AreEntryStatEffectsReady()
  If !Self.AreStatPoolEffectsReady(SuccubusHenshinBonusSpell)
    Return False
  EndIf
  If Self.GetContinuousAbilityMode() == 1 && !Self.AreStatPoolEffectsReady(Self.GetContinuousRankAbility())
    Return False
  EndIf
  ; The current satiation tiers affect experience only. Wait for a legacy
  ; pool ability only while the player actually owns that migrating spell.
  Spell Legacy = StableAppliedSatiationSpell
  If Legacy && PlayerRef.HasSpell(Legacy) && !Self.AreStatPoolEffectsReady(Legacy)
    Return False
  EndIf
  Return True
EndFunction


Float[] Function CaptureTransformPoolCaps()
  Float[] Values = Self.CaptureTransformPoolValues()
  Float[] Caps = new Float[3]
  Caps[0] = Values[3]
  Caps[1] = Values[4]
  Caps[2] = Values[5]
  Return Caps
EndFunction


Bool Function TransformPoolCapsMatch(Float[] Caps)
  If !Caps || Caps.Length != 3 || PlayerRef == None
    Return False
  EndIf
  Return Self.SampledCapsMatch(Caps, Self.CaptureTransformPoolValues())
EndFunction

Bool Function SampledCapsMatch(Float[] Caps, Float[] Values)
  If !Caps || Caps.Length != 3 || !Values || Values.Length != 6
    Return False
  EndIf
  Return Math.Abs(Values[3] - Caps[0]) < 0.01 && Math.Abs(Values[4] - Caps[1]) < 0.01 && Math.Abs(Values[5] - Caps[2]) < 0.01
EndFunction


Bool Function AreTransformPoolsFull()
  If PlayerRef == None || PlayerRef.IsDead()
    Return False
  EndIf
  Return Self.AreSampledPoolsFull(Self.CaptureTransformPoolValues())
EndFunction

Bool Function AreSampledPoolsFull(Float[] Values)
  If !Values || Values.Length != 6 || PlayerRef == None || PlayerRef.IsDead()
    Return False
  EndIf
  Float H = Values[0]
  Float M = Values[1]
  Float S = Values[2]
  Float HMax = Values[3]
  Float MMax = Values[4]
  Float SMax = Values[5]
  Bool ValuesFull = H >= HMax - 0.01 && M >= MMax - 0.01 && S >= SMax - 0.01
  If !ValuesFull && !EnableEquipmentDiagnostics
    Return False
  EndIf
  Float HPct = PlayerRef.GetActorValuePercentage("Health")
  Float MPct = PlayerRef.GetActorValuePercentage("Magicka")
  Float SPct = PlayerRef.GetActorValuePercentage("Stamina")
  If EnableEquipmentDiagnostics
    Debug.Trace("[PSQ-POOLS] verify owner=" + AppearanceOperationId + "; H=" + H + "/" + HMax + "; M=" + M + "/" + MMax + "; S=" + S + "/" + SMax + "; pct=" + HPct + "," + MPct + "," + SPct, 0)
  EndIf
  Return ValuesFull && HPct >= 0.999 && (MMax <= 0.0 || MPct >= 0.999) && (SMax <= 0.0 || SPct >= 0.999)
EndFunction


Function TraceTransformPools(String Phase, Int Owner)
  If !EnableEquipmentDiagnostics
    Return
  EndIf
  Self.TraceSampledPools(Phase, Owner, Self.CaptureTransformPoolValues())
EndFunction

Function TraceSampledPools(String Phase, Int Owner, Float[] Values)
  If !EnableEquipmentDiagnostics || !Values || Values.Length != 6
    Return
  EndIf
  Debug.Trace("[PSQ-POOLS] " + Phase + "; owner=" + Owner + "; H=" + Values[0] + "/" + Values[3] + "; M=" + Values[1] + "/" + Values[4] + "; S=" + Values[2] + "/" + Values[5], 0)
EndFunction


Float Function GetPoolRestoreMaximum(String ValueName, Float Current, Float NativeMaximum)
  Float Maximum = NativeMaximum
  If Maximum <= 0.0
    Maximum = PlayerRef.GetBaseAV(ValueName)
  EndIf
  If Current >= Maximum - 0.01 && Current > 0.0
    Float Percent = PlayerRef.GetActorValuePercentage(ValueName)
    If Percent > 0.0001 && Percent < 0.999
      Float Inferred = Current / Percent
      If Inferred > Maximum
        Maximum = Inferred
      EndIf
    EndIf
  EndIf
  If Maximum < 0.0
    Maximum = 0.0
  EndIf
  Return Maximum
EndFunction


Function ResetFastModeEndState(Bool NewScene = True)
  Self.ResetFastModeEndState35(NewScene)
EndFunction

Bool Function IsFastModeClosingScene(Int TID)
  Return Self.IsFastModeClosingScene35(TID)
EndFunction

String Function GetFastModeCallbackKey(Int TID, Int Generation, Int Epoch)
  return "PSQ_FastCallbacks_" + Epoch + "_" + Generation + "_" + TID
EndFunction

Int Function GetFastModePendingCallbacks(Int TID)
  Return Self.GetFastModePendingCallbacks35(TID)
EndFunction

Bool Function IsFastModeEndOwnerCurrent(Int TID, Int Serial, Int Epoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.SceneCurrent34(Self, TID, Serial, Epoch)
  EndIf
  return TID >= 0 && Epoch == PSQSexSceneEpoch && Serial == FastModeSceneSerial && PPlusThreadID == TID && !PPlusSceneClosed
EndFunction

Bool Function FastModeTargetsExhausted(Actor[] Actors, Int TID)
  Return Self.FastModeTargetsExhausted35(Actors,TID)
EndFunction

Function TryEndExhaustedFastScene(Int TID, Int Serial, Int Epoch)
  Self.TryEndExhaustedFastScene35(TID,Serial,Epoch)
EndFunction


Function ReleaseFastModeCallback(String CallbackKey, Int Generation, Int Epoch)
  Self.ReleaseFastModeCallback35(CallbackKey,Generation,Epoch)
EndFunction

Function CleanupRetiredFastModeKeys()
  Self.CleanupRetiredFastModeKeys35()
EndFunction


; Failed exit originals have a separate persistent ledger. A later transform
; cannot overwrite these references or automatically force them on the player.
Bool Function IsEquipmentRecoveryCurrent(Int Owner, Bool RequireBusy, Int LoadEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.GearCurrent34(Self, Owner, RequireBusy, LoadEpoch)
  EndIf
  If LoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  If PlayerRef != None && SKSE.GetPluginVersion("PSQ Appearance") >= 16777228
    Int Status = PSQAppearance.CheckAppearanceOwner(PlayerRef, Self, PlayerAppearanceRace, Owner, LoadEpoch, RequireBusy)
    If Status != 0
      Return Status == 1 && Owner == AppearanceOperationId && (!RequireBusy || AppearanceEditBusy) && LoadEpoch == PSQLoadEpoch
    EndIf
  EndIf
  If PlayerRef != None && PlayerAppearanceRace != None && PlayerRef.GetRace() != PlayerAppearanceRace
    Return False
  EndIf
  Return LoadEpoch == PSQLoadEpoch && Owner == AppearanceOperationId && (!RequireBusy || AppearanceEditBusy)
EndFunction

Bool Function HasPendingOriginalEquipment()
  if TransformEquipmentRecoveryItems && TransformEquipmentRecoveryItems.Length > 0
    return True
  endif
  return OrgArmorList != None && !IsHenshined && OrgArmorList.GetSize() > 0
EndFunction

Bool Function IsOriginalEquipmentResolved(Armor Item, Form[] Protected)
  if Item == None || Protected.Find(Item as Form) >= 0
    return True
  endif
  return PlayerRef.IsEquipped(Item as Form) || PlayerRef.GetItemCount(Item as Form) <= 0
EndFunction

Bool Function CanRetryOriginalEquipment(Armor Item)
  If Item == None
    Return False
  EndIf
  Int Remaining = Item.GetSlotMask()
  If Remaining == 0
    Return True
  EndIf
  ; SKSE GetWornForm returns the first worn form overlapping ANY mask bit.
  ; If it returns this same form, other occupied bits may be hidden behind
  ; it: keep the exact per-slot fallback for that unusual case.
  Form Overlap = PlayerRef.GetWornForm(Remaining)
  If Overlap == None
    Return True
  ElseIf Overlap != Item as Form
    Return False
  EndIf
  While Remaining != 0
    Int Rest = 0
    ; Avoid signed subtraction overflow when only slot 61 remains.
    If Remaining != -2147483648
      Rest = Math.LogicalAnd(Remaining, Remaining - 1)
    EndIf
    Int Bit = Math.LogicalXor(Remaining, Rest)
    Form Worn = PlayerRef.GetWornForm(Bit)
    If Worn != None && Worn != (Item as Form)
      ; A live foreign occupant keeps the original pending for manual recovery.
      Return False
    EndIf
    Remaining = Rest
  EndWhile
  Return True
EndFunction

Bool Function CommitPendingOriginalEquipment(Form[] Originals, Int Used, Form[] Protected, Int Owner, Bool RequireBusy)
  Int LoadEpoch = PSQLoadEpoch
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, LoadEpoch)
    Return False
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777234
    Int Published = PSQAppearance.CommitOriginalLedger(PlayerRef, Self, PlayerAppearanceRace, Owner, LoadEpoch, RequireBusy, Originals, Used, Protected, OriginalCopyForms, OriginalCopyKeys)
    If Published != 0
      If EnableEquipmentDiagnostics
        Debug.Trace("[PSQ-PERF] recovery.native_ledger; result=" + Published + "; owner=" + Owner)
      EndIf
      Return Published > 0
    EndIf
  EndIf
  Form[] Previous = TransformEquipmentRecoveryItems
  Int PreviousCount = 0
  If Previous
    PreviousCount = Previous.Length
  EndIf
  If Used < 0
    Return False
  EndIf
  If Used > 0 && (!Originals || Used > Originals.Length)
    Return False
  EndIf
  Int Capacity = PreviousCount + Used
  If Capacity == 0
    Return True
  EndIf
  If !HasOriginalCopyKeys && SKSE.GetPluginVersion("PSQ Appearance") >= 16777226
    Form[] Batch = PSQAppearance.ReadPendingOriginals(PlayerRef, PlayerAppearanceRace, Previous, Originals, Used, Protected)
    If Batch && Batch.Length > 0 && Batch[0] == PlayerRef
      Form[] Remaining = EmptyFormArray
      If Batch.Length > 1
        Remaining = PapyrusUtil.SliceFormArray(Batch, 1)
        If !Remaining || Remaining.Length != Batch.Length - 1
          Return False
        EndIf
      EndIf
      If !PSQAppearance.PendingOriginalsMatch(PlayerRef, PlayerAppearanceRace, Previous, Originals, Used, Protected, Batch) || !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, LoadEpoch)
        Return False
      EndIf
      TransformEquipmentRecoveryItems = Remaining
      If EnableEquipmentDiagnostics
        Debug.Trace("[PSQ-PERF] recovery.native_pending; entries=" + Capacity + "; pending=" + (Batch.Length - 1))
      EndIf
      Return True
    EndIf
  EndIf
  Form[] Pending = Utility.CreateFormArray(Capacity, None)
  If !Pending || Pending.Length != Capacity
    Return False
  EndIf
  Float Started
  If EnableEquipmentDiagnostics
    Started = Utility.GetCurrentRealTime()
  EndIf
  Form[] Worn
  If Self.CanUseSuccubusThrallEyes()
    Worn = po3_sksefunctions.AddAllEquippedItemsToArray(PlayerRef)
  EndIf
  Bool UseSnapshot = Worn && Worn.Length > 0
  If EnableEquipmentDiagnostics
    Debug.Trace("[PSQ-PERF] recovery.final_snapshot; native=" + UseSnapshot + "; seconds=" + (Utility.GetCurrentRealTime() - Started), 0)
  EndIf
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, LoadEpoch)
    Return False
  EndIf
  If EnableEquipmentDiagnostics
    Started = Utility.GetCurrentRealTime()
  EndIf
  Int Count = 0
  Int Index = 0
  ; Validate every previous and current original. Only local ownership checks
  ; are repeated per entry; race is checked after the snapshot and at commit.
  While Index < Capacity && Owner == AppearanceOperationId && LoadEpoch == PSQLoadEpoch && (!RequireBusy || AppearanceEditBusy)
    Armor Item = None
    If Index < PreviousCount
      Item = Previous[Index] as Armor
    Else
      Item = Originals[Index - PreviousCount] as Armor
    EndIf
    Bool Resolved = Item == None || Protected.Find(Item as Form) >= 0
    String ReceiptKey = Self.GetOriginalCopyKey(Item)
    If !Resolved && ReceiptKey != "" && SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
      Resolved = PSQAppearance.OriginalCopyAction(PlayerRef, Item, ReceiptKey, Self, PlayerAppearanceRace, Owner, LoadEpoch, RequireBusy, False, True) == 2
    ElseIf !Resolved
      If UseSnapshot
        Resolved = Worn.Find(Item as Form) >= 0
        If !Resolved
          Resolved = PlayerRef.GetItemCount(Item as Form) <= 0
        EndIf
      Else
        ; An empty/unavailable snapshot is not proof of being unequipped.
        Resolved = Self.IsOriginalEquipmentResolved(Item, Protected)
      EndIf
    EndIf
    If !Resolved && Pending.Find(Item as Form) < 0
      Pending[Count] = Item as Form
      Count += 1
    EndIf
    Index += 1
  EndWhile
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, LoadEpoch)
    Return False
  EndIf
  Form[] Compact = EmptyFormArray
  If Count > 0
    Compact = Utility.CreateFormArray(Count, None)
    If !Compact || Compact.Length != Count
      Return False
    EndIf
    Index = 0
    While Index < Count && Owner == AppearanceOperationId && LoadEpoch == PSQLoadEpoch && (!RequireBusy || AppearanceEditBusy)
      Compact[Index] = Pending[Index]
      Index += 1
    EndWhile
  EndIf
  If UseSnapshot
    ; Inventory callbacks from other mods can run during validation. A second
    ; native read confirms that no original treated as worn has disappeared.
    ; On disagreement keep BOTH authoritative ledgers for the normal recovery
    ; path instead of publishing a stale successful snapshot.
    Form[] Confirmed = po3_sksefunctions.AddAllEquippedItemsToArray(PlayerRef)
    If !Confirmed || Confirmed.Length == 0
      Return False
    EndIf
    Index = 0
    While Index < Worn.Length && Owner == AppearanceOperationId && LoadEpoch == PSQLoadEpoch && (!RequireBusy || AppearanceEditBusy)
      Armor Seen = Worn[Index] as Armor
      If Seen != None && Protected.Find(Seen as Form) < 0 && ((Originals && Originals.Find(Seen as Form) >= 0) || (Previous && Previous.Find(Seen as Form) >= 0)) && Confirmed.Find(Seen as Form) < 0
        Debug.Trace("[PSQ-EQUIP] final snapshot changed; retained original equipment ledger", 1)
        Return False
      EndIf
      Index += 1
    EndWhile
  EndIf
  If EnableEquipmentDiagnostics
    Debug.Trace("[PSQ-PERF] recovery.final_validate; entries=" + Capacity + "; pending=" + Count + "; seconds=" + (Utility.GetCurrentRealTime() - Started), 0)
  EndIf
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, LoadEpoch)
    Return False
  EndIf
  TransformEquipmentRecoveryItems = Compact
  If Count > 0
    Debug.Trace("[PSQ-EQUIP] retained unresolved originals=" + Count, 1)
  EndIf
  Return True
EndFunction

Bool Function RetryPendingOriginalEquipment()
  if IsHenshined || IsHenshinchu || AppearanceRecoveryPending || !Self.HasPendingOriginalEquipment() || Utility.IsInMenuMode() || PlayerRef == None || PlayerRef.IsDead() || !PlayerRef.Is3DLoaded()
    return False
  endif
  if !Self.BeginAppearanceEdit()
    return False
  endif
  Int Owner = AppearanceOperationId
  Int LoadEpoch = PSQLoadEpoch
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777247
    Int RetryJob = PSQAppearance.StartAppearanceTask(PlayerRef,Self,None,Owner,LoadEpoch,True,12,False,0.0)
    Int RetryResult = Self.WaitAppearanceReceipt27(RetryJob,Owner,LoadEpoch)
    If Owner != AppearanceOperationId || LoadEpoch != PSQLoadEpoch
      Return False
    EndIf
    Self.EndAppearanceEdit(Owner)
    If RetryResult == 1
      Debug.Notification("$PSQ_EquipmentRecoveryComplete")
    ElseIf RetryResult == 3
      Debug.Notification("$PSQ_EquipmentRecoveryPending")
    EndIf
    Return RetryResult == 1 || RetryResult == 3 || RetryResult == 4
  EndIf
  Form[] Protected = Self.GetTransformProtectedArmor()
  Form[] Snapshot = OrgArmorList.ToArray()
  if !Self.CommitPendingOriginalEquipment(Snapshot, Snapshot.Length, Protected, Owner, True)
    Self.EndAppearanceEdit(Owner)
    return False
  endif
  if !Self.IsEquipmentRecoveryCurrent(Owner, True, LoadEpoch)
    return False
  endif
  OrgArmorList.Revert()
  Form[] Pending = TransformEquipmentRecoveryItems
  Int NativeVersion = SKSE.GetPluginVersion("PSQ Appearance")
  Bool Confirmed = False
  If NativeVersion >= 16777236 && PSQAppearance.IsReady()
    Int Result = Self.RunNativeEquipmentRestore27(Pending, 0, Pending.Length, Protected, Owner, True, LoadEpoch, True)
    If Result < 0
      If Self.IsEquipmentRecoveryCurrent(Owner, True, LoadEpoch)
        Self.EndAppearanceEdit(Owner)
      EndIf
      Return False
    EndIf
    Confirmed = NativeVersion >= 16777243 && Result == 0
  Else
    Int Index = 0
    while Pending && Index < Pending.Length && Self.IsEquipmentRecoveryCurrent(Owner, True, LoadEpoch)
      ; This path is explicitly requested by the player, so restoring their
      ; original armor may intentionally replace a currently worn alternative.
      Self.TryRestoreTransformOriginal(Pending[Index] as Armor, Protected, Owner, True)
      Index += 1
    endwhile
  EndIf
  if !Self.IsEquipmentRecoveryCurrent(Owner, True, LoadEpoch)
    return False
  endif
  If !Confirmed
    Utility.WaitMenuMode(0.1)
  EndIf
  if !Self.IsEquipmentRecoveryCurrent(Owner, True, LoadEpoch)
    return False
  endif
  if Utility.IsInMenuMode()
    ; A menu reopened after the explicit retry began. Keep the ledger and
    ; release the owner now; do not hold an appearance lock across a pause.
    Self.EndAppearanceEdit(Owner)
    return True
  endif
  Self.CommitPendingOriginalEquipment(EmptyFormArray, 0, Protected, Owner, True)
  if !Self.IsEquipmentRecoveryCurrent(Owner, True, LoadEpoch)
    return False
  endif
  Bool PendingLeft = Self.HasPendingOriginalEquipment()
  Self.EndAppearanceEdit(Owner)
  if PendingLeft
    Debug.Notification("$PSQ_EquipmentRecoveryPending")
  else
    Debug.Notification("$PSQ_EquipmentRecoveryComplete")
  endif
  return True
EndFunction

Bool Function QueuePendingOriginalEquipmentRecovery()
  Int Owner = AppearanceOperationId
  Int LoadEpoch = PSQLoadEpoch
  Int Request = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236
    Request = PSQAppearance.GearRetryRequest(Self,PlayerRef,0,0,Owner,LoadEpoch,False,0.0,0.0)
  EndIf
  If Request < 0
    Return Request == -2
  ElseIf Request == 0
    if PlayerRef == None || PlayerRef.IsDead() || IsHenshined || IsHenshinchu || AppearanceEditBusy || AppearanceRecoveryPending || UninstallPrepared || UninstallCleanupBusy || !Self.HasPendingOriginalEquipment()
      return False
    endif
    if EquipmentRecoveryRequestQueued && EquipmentRecoveryRequestOwner == Owner && EquipmentRecoveryRequestLoad == LoadEpoch
      return True
    endif
    EquipmentRecoveryRequest += 1
    Request = EquipmentRecoveryRequest
    EquipmentRecoveryRequestOwner = Owner
    EquipmentRecoveryRequestLoad = LoadEpoch
    EquipmentRecoveryRequestQueued = True
  EndIf
  Self.RegisterForModEvent("PSQ_RetryOriginalEquipment", "OnPendingOriginalEquipmentRecovery")
  Int Handle = ModEvent.Create("PSQ_RetryOriginalEquipment")
  if Handle == 0
    Self.ReleaseOriginalEquipmentRequest(Request)
    return False
  endif
  ModEvent.PushForm(Handle, Self as Form)
  ModEvent.PushInt(Handle, Request)
  ModEvent.PushInt(Handle, Owner)
  ModEvent.PushInt(Handle, LoadEpoch)
  if !ModEvent.Send(Handle)
    Self.ReleaseOriginalEquipmentRequest(Request)
    return False
  endif
  return True
EndFunction

Bool Function IsOriginalEquipmentRequestCurrent(Int Request, Int Owner, Int LoadEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777229
    Int Status = PSQAppearance.CheckRecoveryRequest(PlayerRef, Self, Request, Owner, LoadEpoch)
    If Status != 0
      Return Status == 1 && Owner == AppearanceOperationId && LoadEpoch == PSQLoadEpoch && Request == EquipmentRecoveryRequest && EquipmentRecoveryRequestQueued
    EndIf
  EndIf
  return EquipmentRecoveryRequestQueued && EquipmentRecoveryRequest == Request && EquipmentRecoveryRequestOwner == Owner && EquipmentRecoveryRequestLoad == LoadEpoch && LoadEpoch == PSQLoadEpoch && Owner == AppearanceOperationId && PlayerRef != None && !PlayerRef.IsDead() && !IsHenshined && !IsHenshinchu && !AppearanceEditBusy && !AppearanceRecoveryPending && !UninstallPrepared && !UninstallCleanupBusy
EndFunction

Function ReleaseOriginalEquipmentRequest(Int Request)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236
    If PSQAppearance.GearRetryRequest(Self,PlayerRef,2,Request,0,0,False,0.0,0.0) == 1
      Return
    EndIf
  EndIf
  if EquipmentRecoveryRequest == Request
    EquipmentRecoveryRequestQueued = False
  endif
EndFunction

Function OnPendingOriginalEquipmentRecovery(Form Sender, Int Request, Int Owner, Int LoadEpoch)
  if Sender != (Self as Form)
    return
  endif
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777247
    Int Job = PSQAppearance.StartMenuRetry31(PlayerRef,Self,Owner,LoadEpoch,Request)
    If Job == -2
      Return
    EndIf
    Int Ready = Self.WaitAppearanceReceipt27(Job,Owner,LoadEpoch)
    If Owner == AppearanceOperationId && LoadEpoch == PSQLoadEpoch && Request == EquipmentRecoveryRequest
      If Ready == 1
        Self.RetryPendingOriginalEquipment()
      Else
        Self.ReleaseOriginalEquipmentRequest(Request)
      EndIf
    EndIf
    Return
  EndIf
  ; MCM is paused. Wait without taking an appearance owner, so OnSelect can
  ; return immediately and show its existing "close the menu" instruction.
  Float Deadline = Utility.GetCurrentRealTime() + 30.0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236
    Int Next = PSQAppearance.GearRetryRequest(Self,PlayerRef,1,Request,Owner,LoadEpoch,Utility.IsInMenuMode(),Utility.GetCurrentRealTime(),Deadline)
    While Next == 2
      Utility.WaitMenuMode(0.25)
      Next = PSQAppearance.GearRetryRequest(Self,PlayerRef,1,Request,Owner,LoadEpoch,Utility.IsInMenuMode(),Utility.GetCurrentRealTime(),Deadline)
    EndWhile
    If Next == 1
      Self.RetryPendingOriginalEquipment()
      Return
    ElseIf Next < 0
      Self.ReleaseOriginalEquipmentRequest(Request)
      Return
    EndIf
  EndIf
  while Self.IsOriginalEquipmentRequestCurrent(Request, Owner, LoadEpoch) && (Utility.IsInMenuMode() || !PlayerRef.Is3DLoaded()) && Utility.GetCurrentRealTime() < Deadline
    Utility.WaitMenuMode(0.25)
  endwhile
  if !Self.IsOriginalEquipmentRequestCurrent(Request, Owner, LoadEpoch) || Utility.IsInMenuMode() || !PlayerRef.Is3DLoaded()
    Self.ReleaseOriginalEquipmentRequest(Request)
    return
  endif
  Self.ReleaseOriginalEquipmentRequest(Request)
  Self.RetryPendingOriginalEquipment()
EndFunction



Function CancelDeferredTransformRefill(Int Request = -1)
  ; A stale worker must never cancel a newer transformation's request.
  if Request >= 0 && Request != DeferredTransformRefillRequest
    return
  endif
  DeferredTransformRefillRequest += 1
  DeferredTransformRefillOwner = -1
  DeferredTransformRefillLoadEpoch = -1
  DeferredTransformRefillUntil = 0.0
  DeferredTransformRefillFloors = EmptyFloatArray
  String PreviousKey = DeferredTransformRefillClaimKey
  DeferredTransformRefillClaimKey = ""
  if PreviousKey != ""
    StorageUtil.UnsetIntValue(Self as Form, PreviousKey)
  endif
  ; Keep the idle event registration. Unregistering after a native cleanup
  ; yield could remove a newer request's registration. No event is emitted
  ; while idle; the normal uninstall cleanup can unregister all mod events.
EndFunction

Function QueueDeferredTransformRefill(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777239
    Return
  EndIf
  if !Self.IsEntryRefillCurrent(Owner, RequireBusy) || TransformAttributesRefilledOwner == Owner
    return
  endif
  if DeferredTransformRefillOwner == Owner && DeferredTransformRefillLoadEpoch == PSQLoadEpoch
    return
  endif
  Int LoadEpoch = PSQLoadEpoch
  Float Deadline = Utility.GetCurrentRealTime() + 5.0
  Float[] Floors = new Float[3]
  Floors[0] = PlayerRef.GetAV("Health")
  Floors[1] = PlayerRef.GetAV("Magicka")
  Floors[2] = PlayerRef.GetAV("Stamina")
  if LoadEpoch != PSQLoadEpoch || !Self.IsEntryRefillCurrent(Owner, RequireBusy)
    return
  endif
  Self.CancelDeferredTransformRefill()
  ; Cancel clears native state and can yield. A newer appearance operation
  ; must not be overwritten by this old request after that cleanup returns.
  if LoadEpoch != PSQLoadEpoch || !Self.IsEntryRefillCurrent(Owner, RequireBusy)
    return
  endif
  DeferredTransformRefillOwner = Owner
  DeferredTransformRefillLoadEpoch = LoadEpoch
  DeferredTransformRefillUntil = Deadline
  DeferredTransformRefillFloors = Floors
  Int Request = DeferredTransformRefillRequest
  DeferredTransformRefillClaimKey = "PSQ_DeferredRefill_" + LoadEpoch + "_" + Owner + "_" + Request
  Self.RegisterForModEvent("PSQ_DeferredTransformRefill", "OnPSQDeferredTransformRefill")
  ; Dispatch independently of the main periodic update. It owns no stat or
  ; appearance lock while waiting for the original entry operation to finish.
  if Self.IsDeferredTransformRefillCurrent(Owner, LoadEpoch, Request)
    Self.SendModEvent("PSQ_DeferredTransformRefill", Request as String, 0.0)
  endif
EndFunction

Bool Function IsDeferredTransformRefillCurrent(Int Owner, Int LoadEpoch, Int Request)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777239
    Return False
  EndIf
  if PlayerRef == None || UninstallPrepared || UninstallCleanupBusy || PlayerIsSuccubus.GetValueInt() != 1
    return False
  endif
  if Request != DeferredTransformRefillRequest || Owner != DeferredTransformRefillOwner || LoadEpoch != DeferredTransformRefillLoadEpoch || LoadEpoch != PSQLoadEpoch || TransformEntryLoadEpoch != LoadEpoch
    return False
  endif
  if !Self.IsAppearanceOperationCurrent(Owner, False) || !IsHenshined || !AppearanceSnapshotReady || AppearanceRecoveryPending || AppearanceRecoveryRequested || AppearanceTransformDirection == 2
    return False
  endif
  return TransformAttributesRefilledOwner != Owner && Self.GetTransformBuffMode() != 0 && !PlayerRef.IsDead() && PlayerRef.GetAV("Health") > 0.0 && Utility.GetCurrentRealTime() <= DeferredTransformRefillUntil
EndFunction

Bool Function DeferredTransformRefillResourcesIntact()
  ; A deferred completion is never an ongoing combat/sprint healing source.
  ; Cancel if resources fell since the failed quick refill; do not replenish
  ; newly spent resources after the original entry transaction has finished.
  if PlayerRef == None || PlayerRef.IsInCombat() || PlayerRef.IsSprinting() || !DeferredTransformRefillFloors || DeferredTransformRefillFloors.Length != 3
    return False
  endif
  return PlayerRef.GetAV("Health") >= DeferredTransformRefillFloors[0] - 0.01 && PlayerRef.GetAV("Magicka") >= DeferredTransformRefillFloors[1] - 0.01 && PlayerRef.GetAV("Stamina") >= DeferredTransformRefillFloors[2] - 0.01
EndFunction

Function OnPSQDeferredTransformRefill(String EventName, String Argument, Float Unused, Form Sender)
  if Sender != Self as Form
    return
  endif
  Int Request = Argument as Int
  Int Owner = DeferredTransformRefillOwner
  Int LoadEpoch = DeferredTransformRefillLoadEpoch
  Float[] StableCaps
  Bool HaveStableCaps = False
  Int Attempt = 0
  while Attempt < 16 && Self.IsDeferredTransformRefillCurrent(Owner, LoadEpoch, Request)
    if !Self.DeferredTransformRefillResourcesIntact()
      Self.CancelDeferredTransformRefill(Request)
      return
    endif
    ; Only observe effects/capacity here. Never reattach abilities, rerun the
    ; transform magnitudes, or call FinalizeTransformAttributeRefillCore.
    if !AppearanceEditBusy && !IsHenshinchu && !Utility.IsInMenuMode() && PlayerRef.Is3DLoaded() && Self.AreEntryStatEffectsReady()
      if HaveStableCaps && Self.TransformPoolCapsMatch(StableCaps)
        Int PoolEpoch = Self.BeginStatPoolEdit(Owner, False)
        if PoolEpoch >= 0
          if Self.IsDeferredTransformRefillCurrent(Owner, LoadEpoch, Request) && Self.DeferredTransformRefillResourcesIntact() && Self.AreEntryStatEffectsReady() && Self.TransformPoolCapsMatch(StableCaps)
            String ClaimKey = "PSQ_DeferredRefill_" + LoadEpoch + "_" + Owner + "_" + Request
            if StorageUtil.AdjustIntValue(Self as Form, ClaimKey, 1) != 1
              Self.EndStatPoolEdit(PoolEpoch)
              return
            endif
            if !Self.IsDeferredTransformRefillCurrent(Owner, LoadEpoch, Request)
              Self.EndStatPoolEdit(PoolEpoch)
              StorageUtil.UnsetIntValue(Self as Form, ClaimKey)
              return
            endif
            ; Exactly one restoration burst for this request. Later verification
            ; never performs another restore, even if an external effect changes.
            Self.ApplyDeferredTransformRefillCore(Owner, LoadEpoch, Request, PoolEpoch)
            Self.EndStatPoolEdit(PoolEpoch)
            Utility.Wait(0.1)
            if Self.IsDeferredTransformRefillCurrent(Owner, LoadEpoch, Request) && Self.TransformPoolCapsMatch(StableCaps) && Self.AreEntryStatEffectsReady() && Self.AreTransformPoolsFull()
              TransformAttributesRefilledOwner = Owner
              Debug.Trace("[PSQ-REFILL] deferred completion verified owner=" + Owner, 0)
            elseif Self.IsDeferredTransformRefillCurrent(Owner, LoadEpoch, Request)
              Debug.Trace("[PSQ-REFILL] deferred one-shot completion not stable; no repeated restore owner=" + Owner, 1)
            endif
            Self.CancelDeferredTransformRefill(Request)
            ; Cancel may belong to a newer request now; clean this worker's
            ; captured key regardless. The key includes load/owner/request.
            StorageUtil.UnsetIntValue(Self as Form, ClaimKey)
            return
          endif
          Self.EndStatPoolEdit(PoolEpoch)
        endif
      endif
      StableCaps = Self.CaptureTransformPoolCaps()
      HaveStableCaps = True
    else
      HaveStableCaps = False
    endif
    Attempt += 1
    Utility.Wait(0.25)
  endwhile
  if Request == DeferredTransformRefillRequest
    Debug.Trace("[PSQ-REFILL] deferred completion cancelled or expired owner=" + Owner, 1)
    Self.CancelDeferredTransformRefill(Request)
  endif
EndFunction

Function ApplyDeferredTransformRefillCore(Int Owner, Int LoadEpoch, Int Request, Int PoolEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777239
    Return
  EndIf
  if !Self.IsStatPoolEditCurrent(PoolEpoch, Owner) || !Self.IsDeferredTransformRefillCurrent(Owner, LoadEpoch, Request) || !Self.DeferredTransformRefillResourcesIntact()
    return
  endif
  Float H = PlayerRef.GetAV("Health")
  Float M = PlayerRef.GetAV("Magicka")
  Float S = PlayerRef.GetAV("Stamina")
  Float HMax = Self.GetPoolRestoreMaximum("Health", H, PlayerRef.GetAVMax("Health"))
  Float MMax = Self.GetPoolRestoreMaximum("Magicka", M, PlayerRef.GetAVMax("Magicka"))
  Float SMax = Self.GetPoolRestoreMaximum("Stamina", S, PlayerRef.GetAVMax("Stamina"))
  if !Self.IsStatPoolEditCurrent(PoolEpoch, Owner) || !Self.IsDeferredTransformRefillCurrent(Owner, LoadEpoch, Request) || !Self.DeferredTransformRefillResourcesIntact()
    return
  endif
  if H > 0.0 && HMax > H
    PlayerRef.RestoreAV("Health", HMax - H)
  endif
  if !Self.IsStatPoolEditCurrent(PoolEpoch, Owner) || !Self.IsDeferredTransformRefillCurrent(Owner, LoadEpoch, Request) || !Self.DeferredTransformRefillResourcesIntact()
    return
  endif
  if MMax > M
    PlayerRef.RestoreAV("Magicka", MMax - M)
  endif
  if !Self.IsStatPoolEditCurrent(PoolEpoch, Owner) || !Self.IsDeferredTransformRefillCurrent(Owner, LoadEpoch, Request) || !Self.DeferredTransformRefillResourcesIntact()
    return
  endif
  if SMax > S
    PlayerRef.RestoreAV("Stamina", SMax - S)
  endif
EndFunction


Function RetirePSQInflation()
  Int Epoch = PSQLoadEpoch
  ; Completed migration is cheap until its own-source recheck is due. If an
  ; old saved stack changes a retired field, normalize it through the old path.
  If PlayerRef != None && RemovedInflationCleanedLoadEpoch == Epoch
    If !EnableSLIFBridge && !EnableBellyGrowthByPregnancy && !EnableBreastGrowthByPregnancy && !EnableBreastGrowthByMilk && !EnableBreastChangeSuccubus && !EnableBodyslideMorph && SuccubusBreast == 1.0 && HotkeyBreastNode == -1
      If Utility.GetCurrentRealTime() < RemovedInflationNextSourceCheck
        Return
      EndIf
    EndIf
  EndIf
  ; Saved bindings remain, but none of these fields can reactivate output.
  EnableSLIFBridge = False
  EnableBellyGrowthByPregnancy = False
  EnableBreastGrowthByPregnancy = False
  EnableBreastGrowthByMilk = False
  EnableBreastChangeSuccubus = False
  EnableBodyslideMorph = False
  SuccubusBreast = 1.0
  HotkeyBreastNode = -1
  if PlayerRef == None
    return
  endif
  if RemovedInflationCleanedLoadEpoch != Epoch
    if !PlayerRef.Is3DLoaded() || Utility.IsInMenuMode() || Self.ShouldDeferForAlternateStart() || Self.GTSoftbodyOwnsAppearance()
      return
    endif
    Self.ClearPSQDirectInflation()
    if Epoch != PSQLoadEpoch
      return
    endif
    Self.ClearPSQSLIFOutput()
    if Epoch != PSQLoadEpoch
      return
    endif
    RemovedInflationCleanedLoadEpoch = Epoch
    RemovedInflationNextSourceCheck = Utility.GetCurrentRealTime() + 60.0
  elseif Utility.GetCurrentRealTime() >= RemovedInflationNextSourceCheck
    ; Manual NG import can restore this retired source. Never clear other mods.
    RemovedInflationNextSourceCheck = Utility.GetCurrentRealTime() + 60.0
    if PSQSLIFNG.IsInstalled()
      if PSQSLIFNG.HasSource(PlayerRef)
        PSQSLIFNG.RemoveSource(PlayerRef)
      endif
    elseif Self.IsIntegrationPluginLoaded("SexLab Inflation Framework.esp")
      if storageutil.HasIntValue(PlayerRef, "PSQ Reburnslif_initialize") || storageutil.HasIntValue(PlayerRef, "PSQ Reburnslif_morph_initialize")
        Self.ClearPSQSLIFOutput()
      endif
    endif
  endif
EndFunction


Function RetirePSQReproduction()
  Int Epoch = PSQLoadEpoch
  If PlayerRef != None && RemovedReproductionCleanedLoadEpoch == Epoch
    If !EnableSoulGemPregnancy && !AllowAnalPregnancy && StopAddMilk && !EnableFertilityBridge && FertilityBridgeRank == -1 && FertilityBridgeProgress == 0.0 && FertilityBridgeDuration == 0.0 && FertilityBridgeRemaining == 0.0
      Return
    EndIf
  EndIf
  ; Bound fields and public calls remain solely for old saves, never as outputs.
  EnableSoulGemPregnancy = False
  AllowAnalPregnancy = False
  StopAddMilk = True
  EnableFertilityBridge = False
  Self.RegisterInflationFertilityEvents()
  Self.RefreshFertilityBridgeStatus()
  If PlayerRef == None || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  If Epoch != PSQLoadEpoch
    Return
  EndIf
  If RemovedReproductionCleanedLoadEpoch == Epoch
    Return
  EndIf
  If Utility.IsInMenuMode() || Self.ShouldDeferForAlternateStart() || IsHenshinchu || AppearanceEditBusy
    Return
  EndIf
  If Self.IsIntegrationPluginLoaded("SexLab.esm") && SexLab != None
    If SexLab.IsActorActive(PlayerRef)
      Return
    EndIf
  EndIf
  ; The retired quest owns PRG_Armor and PRG_* data. It restores its own borrowed
  ; equipment before clearing those records, and retries if another scene owns it.
  psqsoulgemincubatequestscript Incubator = Game.GetFormFromFile(3428, "PSQ PlayerSuccubusQuest.esm") as psqsoulgemincubatequestscript
  If Incubator != None
    If !Incubator.CleanupRetiredGameplay()
      Return
    EndIf
  EndIf
  If Epoch != PSQLoadEpoch
    Return
  EndIf
  If PSQSoulGemBirthingSpell != None
    PlayerRef.RemoveSpell(PSQSoulGemBirthingSpell)
  EndIf
  If PSQSoulGemImpregnateSpell != None
    PlayerRef.RemoveSpell(PSQSoulGemImpregnateSpell)
  EndIf
  If SoulGemPregnantEffectA != None
    PlayerRef.RemoveSpell(SoulGemPregnantEffectA)
  EndIf
  If SoulGemPregnantEffectB != None
    PlayerRef.RemoveSpell(SoulGemPregnantEffectB)
  EndIf
  Spell RetiredMilkingSpell = Game.GetFormFromFile(3551, "PSQ PlayerSuccubusQuest.esm") as Spell
  If RetiredMilkingSpell != None && PlayerRef.HasSpell(RetiredMilkingSpell)
    PlayerRef.RemoveSpell(RetiredMilkingSpell)
  EndIf
  Self.RemoveRetiredMilkIntegrationFood()
  IsMilking = False
  If Epoch == PSQLoadEpoch
    RemovedReproductionCleanedLoadEpoch = Epoch
  EndIf
EndFunction


Function RemoveRetiredMilkIntegrationFood()
  Self.MigrateLegacyPlayerFuta()
  ; Remove only retired PSQ items; semen potions and FHU storage are untouched.
  If PlayerRef != None
    Int[] RetiredItems = new Int[4]
    RetiredItems[0] = 3554
    RetiredItems[1] = 3628
    RetiredItems[2] = 3629
    RetiredItems[3] = 3630
    Int RetiredIndex = 0
    While RetiredIndex < RetiredItems.Length
      Form RetiredItem = Game.GetFormFromFile(RetiredItems[RetiredIndex], "PSQ PlayerSuccubusQuest.esm")
      If RetiredItem != None
        If RetiredIndex == 0 && PlayerRef.IsEquipped(RetiredItem)
          PlayerRef.UnequipItem(RetiredItem, False, True)
        EndIf
        Int RetiredCount = PlayerRef.GetItemCount(RetiredItem)
        If RetiredCount > 0
          PlayerRef.RemoveItem(RetiredItem, RetiredCount, True, None)
        EndIf
      EndIf
      RetiredIndex += 1
    EndWhile
  EndIf
  If !Self.IsIntegrationPluginLoaded("iNeed.esp")
    Return
  EndIf
  Int[] Lists = new Int[3]
  Int[] Foods = new Int[3]
  Lists[0] = 3435
  Lists[1] = 3435
  Lists[2] = 47656
  Foods[0] = 3629
  Foods[1] = 3630
  Foods[2] = 3628
  Int i = 0
  While i < 3
    FormList List = Game.GetFormFromFile(Lists[i], "iNeed.esp") as FormList
    Form Food = Game.GetFormFromFile(Foods[i], "PSQ PlayerSuccubusQuest.esm")
    If List != None && Food != None
      List.RemoveAddedForm(Food)
    EndIf
    i += 1
  EndWhile
EndFunction



Bool Function HasBodyChangeNGAPI()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Int CheckLoad = PSQLoadEpoch
    Int Candidate = PSQAppearance.BodyProbe34(Self, CheckLoad)
    If Candidate < 0
      Return True
    ElseIf Candidate == 0
      Return False
    EndIf
    Return PSQAppearance.BodyVerified34(Self, CheckLoad, Candidate, BCNGPSQBridge.GetVersion())
  EndIf
  ; Loaded DLL capabilities are fixed for the session. Never cache transient readiness or failures.
  Int Epoch = PSQLoadEpoch
  If Epoch > 0 && BCNGBodyAPIVerifiedLoad == Epoch
    Return True
  EndIf
  If !Self.HasExternalBodyChangeNG()
    Return False
  EndIf
  Int Version = skse.GetPluginVersion("Body Change NG")
  Int Expected
  If Version == 16973937
    Expected = 1
  ElseIf Version == 16973938
    Expected = 2
  ElseIf Version == 16973939
    Expected = 3
  ElseIf Version == 16973953
    Expected = 4
  Else
    Return False
  EndIf
  If BCNGPSQBridge.GetVersion() != Expected || Epoch != PSQLoadEpoch
    Return False
  EndIf
  BCNGBodyAPIVerifiedLoad = Epoch
  Return True
EndFunction

String Function GetBodyChangeStatusName()
  If !Self.HasExternalBodyChangeNG()
    Return "$PSQ_BCNGMissing"
  EndIf
  Int Version = skse.GetPluginVersion("Body Change NG")
  If Version < 0
    Return "$PSQ_BCNGMissing"
  EndIf
  If !Self.HasBodyChangeNGAPI()
    Return "$PSQ_BCNGAPIMissing"
  EndIf
  If BCNGBodyStatus == -7
    Return "$PSQ_BCNGNonAdditive"
  EndIf
  If !BCNGPSQBridge.IsReady()
    Return "$PSQ_BCNGBusy"
  EndIf
  If BCNGBodyStatus == -3
    Return "$PSQ_BCNGPresetMissing"
  ElseIf BCNGBodyStatus < 0
    Return "$PSQ_BCNGFailed"
  ElseIf BCNGBodyRequest > 0 || BCNGBodyNeedsSync
    Return "$PSQ_BCNGPending"
  EndIf
  Return "$PSQ_BCNGReady"
EndFunction

Function CleanupLegacyPSQBodyMorphs(Int Owner, Bool RequireBusy)
  If BCNGLegacyMorphCleanupEpoch == PSQLoadEpoch || !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  If BCNGLegacyMorphsRetired
    BCNGLegacyMorphCleanupEpoch = PSQLoadEpoch
    Return
  EndIf
  If !Self.HasNiOverrideRuntime() || PlayerRef == None
    Return
  EndIf
  ; This is exclusively a once-per-save migration clear and rebuild, not an
  ; alternate body-change engine. It also works when BCNG is unavailable.
  If nioverride.HasBodyMorphKey(PlayerRef, "PSQ_TransformPreset")
    nioverride.ClearBodyMorphKeys(PlayerRef, "PSQ_TransformPreset")
    nioverride.UpdateModelWeight(PlayerRef)
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  BCNGLegacyMorphCleanupEpoch = PSQLoadEpoch
  BCNGLegacyMorphsRetired = True
  Self.ClearAppliedTransformBody(Owner, RequireBusy)
EndFunction

Bool Function RequestBCNGBodyChange(Bool WantActive, String PresetId, Int Owner, Bool RequireBusy, Bool WaitForCompletion)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777240
    Int CurrentEpoch = PSQLoadEpoch
    Int Ticket = PSQAppearance.StartBodyRequest24(PlayerRef,Self,Owner,CurrentEpoch,RequireBusy,WantActive,PresetId,WaitForCompletion)
    Int DuplicateAttempts = 0
    While Ticket == -2 && DuplicateAttempts < 100
      DuplicateAttempts += 1
      Utility.WaitMenuMode(0.03)
      Ticket = PSQAppearance.StartBodyRequest24(PlayerRef,Self,Owner,CurrentEpoch,RequireBusy,WantActive,PresetId,WaitForCompletion)
    EndWhile
    Int Outcome = Self.WaitAppearanceReceipt27(Ticket,Owner,CurrentEpoch)
    Return Outcome == 1
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy) || PlayerRef == None
    Return False
  EndIf
  If !Self.HasBodyChangeNGAPI()
    If !WantActive && !BCNGBodyOwned && BCNGBodyRequest <= 0
      BCNGBodyNeedsSync = False
      Return True
    EndIf
    BCNGBodyStatus = -2
    BCNGBodyNeedsSync = True
    Return False
  EndIf
  If WantActive && !BCNGPSQBridge.IsReady()
    BCNGBodyStatus = 0
    BCNGBodyNeedsSync = True
    Return False
  EndIf
  If !WantActive
    PresetId = ""
  EndIf
  Int Epoch = PSQLoadEpoch
  If BCNGBodyRequest > 0 && BCNGBodyRequestOwner == Owner && BCNGBodyRequestLoad == Epoch && BCNGBodyRequestActive == WantActive && BCNGBodyRequestPreset == PresetId
    If WaitForCompletion
      Self.WaitForBCNGBodyRequest(BCNGBodyRequest, Owner, RequireBusy)
    EndIf
    Return BCNGBodyStatus >= 0
  EndIf
  If BCNGBodyRequest <= 0 && BCNGBodyAppliedLoad == Epoch && BCNGBodyAppliedPreset == PresetId && BCNGBodyOwned == WantActive
    BCNGBodyNeedsSync = False
    Return True
  EndIf
  If WantActive
    Self.EnsureTransformBodyCatalog(Owner, RequireBusy)
    If !TransformBodyCatalogReady
      BCNGBodyStatus = -3
      Return False
    EndIf
    If PresetId == "" || BCNGBodyPresetIds.Find(PresetId) < 0 || BCNGPSQBridge.GetPresetName(PresetId) == ""
      BCNGBodyStatus = -3
      Return False
    EndIf
  EndIf
  Int Request = 0
  If WantActive
    Request = BCNGPSQBridge.ApplyTemporaryPreset(PlayerRef, PresetId)
  Else
    Request = BCNGPSQBridge.ClearTemporaryPreset(PlayerRef)
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy) || Epoch != PSQLoadEpoch
    ; A newer operation owns follow-up. Preserve a retry instead of acknowledging
    ; a request that may finish after this caller was revoked.
    BCNGBodyNeedsSync = True
    BCNGBodyAppliedLoad = -1
    If Request > 0 && WantActive
      BCNGBodyOwned = True
    EndIf
    Return False
  EndIf
  Int Recorded = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777235
    Recorded = PSQAppearance.RecordBodyChange(Self, Owner, Epoch, RequireBusy, Request, WantActive, PresetId, Utility.GetCurrentRealTime())
  EndIf
  If Recorded < 0
    Return False
  ElseIf Recorded == 0
    If Request <= 0
      BCNGBodyStatus = Request
      If Request == 0
        BCNGBodyStatus = -4
      EndIf
      BCNGBodyNeedsSync = True
      Return False
    EndIf
    BCNGBodyRequest = Request
    BCNGBodyRequestOwner = Owner
    BCNGBodyRequestLoad = Epoch
    BCNGBodyRequestActive = WantActive
    BCNGBodyRequestPreset = PresetId
    BCNGBodyRequestStarted = Utility.GetCurrentRealTime()
    BCNGBodyNeedsSync = True
    BCNGBodyStatus = 0
    If WantActive
      BCNGBodyOwned = True
    EndIf
  EndIf
  If WaitForCompletion
    Self.WaitForBCNGBodyRequest(Request, Owner, RequireBusy)
  EndIf
  Return BCNGBodyStatus >= 0
EndFunction

Bool Function ReadBCNGBodyRequest(Int Request, Int Owner, Bool RequireBusy)
  If Request <= 0 || Request != BCNGBodyRequest || BCNGBodyRequestLoad != PSQLoadEpoch || Owner != BCNGBodyRequestOwner || !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  If !Self.HasBodyChangeNGAPI()
    Return False
  EndIf
  Int Status = BCNGPSQBridge.GetRequestStatus(PlayerRef, Request)
  If Request != BCNGBodyRequest || BCNGBodyRequestLoad != PSQLoadEpoch || !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return False
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777240
    Return PSQAppearance.SettleBodyRequest24(Self,Owner,BCNGBodyRequestLoad,RequireBusy,Request,Status) > 0
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777235
    Int Settled = PSQAppearance.SettleBodyChange(Self, Owner, BCNGBodyRequestLoad, RequireBusy, Request, Status)
    If Settled != 0
      Return Settled > 0
    EndIf
  EndIf
  If Status == 0
    Return False
  EndIf
  If (BCNGBodyRequestActive && Status == 1) || (!BCNGBodyRequestActive && Status == 2)
    BCNGBodyOwned = BCNGBodyRequestActive
    BCNGBodyAppliedPreset = BCNGBodyRequestPreset
    BCNGBodyAppliedLoad = PSQLoadEpoch
    BCNGBodyRequest = 0
    BCNGBodyStatus = 1
    BCNGBodyNeedsSync = False
    Return True
  EndIf
  BCNGBodyRequest = 0
  BCNGBodyStatus = Status
  If Status >= 0
    BCNGBodyStatus = -4
  EndIf
  BCNGBodyNeedsSync = True
  Return False
EndFunction

Bool Function WaitForBCNGBodyRequest(Int Request, Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777241
    Int LoadId = PSQLoadEpoch
    Int Ticket = PSQAppearance.JoinBodyRequest25(PlayerRef,Self,Owner,LoadId,RequireBusy,Request)
    If Ticket == -2
      ; Another waiter already owns this exact receipt. Observe its saved result.
      Int ChecksLeft = 70
      While ChecksLeft > 0 && BCNGBodyRequest == Request && Self.IsEquipmentRecoveryCurrent(Owner,RequireBusy,LoadId)
        Utility.WaitMenuMode(0.03)
        ChecksLeft -= 1
      EndWhile
      Return Self.IsEquipmentRecoveryCurrent(Owner,RequireBusy,LoadId) && BCNGBodyRequest == 0 && BCNGBodyStatus == 1
    EndIf
    Return Self.WaitAppearanceReceipt27(Ticket,Owner,LoadId) == 1
  EndIf
  Int Epoch = PSQLoadEpoch
  Int Checks = 0
  Float Started = BCNGBodyRequestStarted
  ; A deferred join may already be past the deadline. Read once even then;
  ; the native task often completed while equipment was being changed.
  While Checks < 20
    If Epoch != PSQLoadEpoch || !Self.IsAppearanceOperationCurrent(Owner, RequireBusy) || Request != BCNGBodyRequest
      Return False
    EndIf
    If Self.ReadBCNGBodyRequest(Request, Owner, RequireBusy)
      Return True
    EndIf
    If BCNGBodyRequest <= 0 || BCNGBodyStatus < 0 || Utility.GetCurrentRealTime() - Started >= 2.0
      Return False
    EndIf
    Utility.Wait(0.1)
    Checks += 1
  EndWhile
  ; A timed-out request is retained for the existing OnUpdate recovery path.
  Return False
EndFunction

Function SyncPendingBCNGBody()
  Int Owner = AppearanceOperationId
  If PlayerRef == None || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  If !BCNGBodyNeedsSync && BCNGLegacyMorphCleanupEpoch == PSQLoadEpoch
    Return
  EndIf
  ; These states already forbid background body synchronization. Test them
  ; before actor/GT queries so a foreground transformation does not pay for them.
  If AppearanceEditBusy || IsHenshinchu || AppearanceRecoveryPending
    Return
  EndIf
  If !PlayerRef.Is3DLoaded() || Utility.IsInMenuMode() || Self.ShouldDeferForAlternateStart() || Self.GTSoftbodyOwnsAppearance()
    Return
  EndIf
  Self.CleanupLegacyPSQBodyMorphs(Owner, False)
  If !BCNGBodyNeedsSync
    Return
  EndIf
  If !Self.HasBodyChangeNGAPI()
    Return
  EndIf
  Bool WantActive = IsHenshined && HenshinBody && !BCNGBodyClearOnly
  If BCNGBodyRequest > 0
    If BCNGBodyRequestOwner == Owner && BCNGBodyRequestLoad == PSQLoadEpoch && BCNGBodyRequestActive == WantActive && (!WantActive || BCNGBodyRequestPreset == BCNGSelectedPresetId)
      If Self.ReadBCNGBodyRequest(BCNGBodyRequest, Owner, False)
        Return
      EndIf
      If BCNGBodyRequest > 0 && Utility.GetCurrentRealTime() - BCNGBodyRequestStarted < 10.0
        Return
      EndIf
    EndIf
    ; Replacing a stale/persistently pending native request supersedes that
    ; actor's previous temporary-layer task; do not merely forget it.
    BCNGBodyAppliedLoad = -1
    BCNGBodyRequest = 0
  EndIf
  If WantActive
    Self.MigrateTransformPresetCatalog(Owner, False)
    If BCNGSelectedPresetId == "" || SuccubusBodySelection <= 0 || psqracecompatibility.ShouldPreserveBCNGBody(PlayerRef)
      BCNGBodyStatus = -3
      Return
    EndIf
  EndIf
  Self.RequestBCNGBodyChange(WantActive, BCNGSelectedPresetId, Owner, False, False)
EndFunction


String Function GetSelectedTransformBodyName()
  If TransformPresetName == ""
    Return "$PSQ_BCNGPresetMissing"
  EndIf
  Return TransformPresetName
EndFunction


Bool Function RefreshEquipmentBodyMorphsForEquipment()
  If PlayerRef == None || UninstallPrepared || UninstallCleanupBusy || !Self.HasNiOverrideRuntime()
    Return True
  EndIf
  If AppearanceEditBusy || IsHenshinchu || BodySelectionRefreshBusy || AppearanceRecoveryPending || AppearanceRecoveryRequested
    Return False
  EndIf
  If !PlayerRef.Is3DLoaded()
    Return False
  EndIf
  Int Owner = AppearanceOperationId
  Int Load = PSQLoadEpoch
  If !Self.IsAppearanceOperationCurrent(Owner, False)
    Return False
  EndIf
  ; Only this exact API2 provider registers the new native functions.
  If Self.HasBCNGEquipmentAPI()
    If BCNGPSQBridge.GetVersion() >= 2 && BCNGPSQBridge.IsReady()
      If PSQEquipmentMorphTicket > 0 && PSQEquipmentMorphOwner == Owner && PSQEquipmentMorphLoad == Load
        Int Status = BCNGPSQBridge.GetEquipmentMorphRefreshStatus(PlayerRef, PSQEquipmentMorphTicket)
        If !Self.IsAppearanceOperationCurrent(Owner, False) || PSQLoadEpoch != Load
          PSQEquipmentMorphTicket = 0
          Return False
        EndIf
        If Status == 1
          PSQEquipmentMorphTicket = 0
          Return True
        ElseIf Status == 0
          Return False
        EndIf
        ; Failed/cancelled/expired requests must take the original fallback.
        PSQEquipmentMorphTicket = 0
      Else
        PSQEquipmentMorphTicket = BCNGPSQBridge.RequestEquipmentMorphRefresh(PlayerRef)
        PSQEquipmentMorphOwner = Owner
        PSQEquipmentMorphLoad = Load
        If PSQEquipmentMorphTicket > 0
          Return False
        EndIf
      EndIf
    EndIf
  EndIf
  Return Self.RefreshEquipmentBodyMorphs()
EndFunction


Function ResetWingflightProbe()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If PSQAppearance.ResetFlight34(Self)
      Return
    EndIf
  EndIf
  ; Pure retry-state reset. Do not replay equipment cleanup on manual refresh.
  WingflightProbeGeneration += 1
  WingflightProbeLoadEpoch = PSQLoadEpoch
  WingflightProbeAttempts = 0
  WingflightNextQueryAt = 0.0
EndFunction

String Function GetOSYRNFlightCompatibilityInfo()
  If !Self.HasWingflight()
    Return "未检测到飞行插件"
  EndIf
  If Self.IsIntegrationPluginLoaded("SmoothJumpINISettings.esp")
    Return "检测到跳跃组件，请核对版本"
  EndIf
  Return "已内置动作与后台适配"
EndFunction


; External Shinano uses PSQ's proven six-piece assembly and slots. No foreign records are edited.
Bool Function HasShinanoOutfitSource()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.SourceReady34(6)
  EndIf
  String Plugin = "gui-SucubusSister Shinano.esp"
  If !Self.IsIntegrationPluginLoaded(Plugin)
    Return False
  EndIf
  Int[] Forms = new Int[10]
  Forms[0] = 2055
  Forms[1] = 2053
  Forms[2] = 2049
  Forms[3] = 2051
  Forms[4] = 2057
  Forms[5] = 2059
  Forms[6] = 2061
  Forms[7] = 2063
  Forms[8] = 2065
  Forms[9] = 2067
  Int Index = 0
  While Index < Forms.Length
    If !(Game.GetFormFromFile(Forms[Index], Plugin) as Armor)
      Return False
    EndIf
    Index += 1
  EndWhile
  String[] Parts = new String[6]
  Parts[0] = "cuirass"
  Parts[1] = "boots"
  Parts[2] = "gloves"
  Parts[3] = "horns"
  Parts[4] = "tail"
  Parts[5] = "wings"
  Index = 0
  While Index < Parts.Length
    String Stem = "Data/meshes/PSQ/ExternalOutfits/Shinano/" + Parts[Index]
    If !miscutil.FileExists(Stem + "_0.nif") || !miscutil.FileExists(Stem + "_1.nif") || !miscutil.FileExists(Stem + ".tri")
      Return False
    EndIf
    Index += 1
  EndWhile
  Return miscutil.FileExists("Data/meshes/PSQ/ExternalOutfits/Shinano/physics/Cuirass.xml") && miscutil.FileExists("Data/meshes/PSQ/ExternalOutfits/Shinano/physics/glove.xml") && miscutil.FileExists("Data/meshes/PSQ/ExternalOutfits/Shinano/physics/gloves.xml") && miscutil.FileExists("Data/meshes/PSQ/ExternalOutfits/Shinano/physics/Horns.xml") && miscutil.FileExists("Data/meshes/PSQ/ExternalOutfits/Shinano/physics/Tail.xml") && miscutil.FileExists("Data/meshes/PSQ/ExternalOutfits/Shinano/physics/Wings.xml") && miscutil.FileExists("Data/meshes/SucubusSister Shinano/upper.xml")
EndFunction

String Function GetShinanoOutfitSourceStatus()
  If !Self.IsIntegrationPluginLoaded("gui-SucubusSister Shinano.esp")
    Return "原作未启用：第六套不可选"
  EndIf
  If !Self.HasShinanoOutfitSource()
    Return "原作资源不完整：第六套不可选"
  EndIf
  Return "已接入原作：沿用PSQ搭配与槽位"
EndFunction

; Keep six hidden PSQ equipment records while detecting the standalone sources.
Bool Function HasExternalOutfitSource(Int Outfit)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.SourceReady34(Outfit)
  EndIf
  If Outfit == 6
    Return Self.HasShinanoOutfitSource()
  EndIf
  String Plugin = ""
  String Root = ""
  Int[] Forms
  If Outfit == 1
    Plugin = "DX Succubus Armor.esp"
    Root = "Data/meshes/PSQ/ExternalOutfits/DX/"
    Forms = new Int[10]
    Forms[0] = 2067
    Forms[1] = 2069
    Forms[2] = 2061
    Forms[3] = 2064
    Forms[4] = 2060
    Forms[5] = 2063
    Forms[6] = 2062
    Forms[7] = 2065
    Forms[8] = 2066
    Forms[9] = 2068
  ElseIf Outfit == 2
    Plugin = "Helena Succubus [SE].esp"
    Root = "Data/meshes/PSQ/ExternalOutfits/Helena/"
    Forms = new Int[8]
    Forms[0] = 2052
    Forms[1] = 2053
    Forms[2] = 2058
    Forms[3] = 2061
    Forms[4] = 2066
    Forms[5] = 2069
    Forms[6] = 3430
    Forms[7] = 3431
  ElseIf Outfit == 3
    Plugin = "BBP_Dragon_Princess.esp"
    Root = "Data/meshes/PSQ/ExternalOutfits/DragonPrincess/"
    Forms = new Int[4]
    Forms[0] = 11250948
    Forms[1] = 11250949
    Forms[2] = 11250950
    Forms[3] = 11250964
  ElseIf Outfit == 5
    Plugin = "TR9DmRxSS_HR.esp"
    Root = "Data/meshes/PSQ/ExternalOutfits/TERA9DM/"
    Forms = new Int[6]
    Forms[0] = 3433
    Forms[1] = 3434
    Forms[2] = 3435
    Forms[3] = 4814
    Forms[4] = 10331
    Forms[5] = 11711
  ElseIf Outfit == 4
    Plugin = "C5Kev's Ageha Abyss Armor.esp"
    Root = "Data/meshes/PSQ/ExternalOutfits/Ageha/"
    Forms = new Int[6]
    Forms[0] = 2053
    Forms[1] = 2054
    Forms[2] = 2055
    Forms[3] = 2056
    Forms[4] = 2060
    Forms[5] = 2065
  ElseIf Outfit == 7
    Plugin = "(SSE) SW vampire.esp"
    Root = "Data/meshes/PSQ/ExternalOutfits/Vampire/"
    Forms = new Int[5]
    Forms[0] = 3430
    Forms[1] = 3429
    Forms[2] = 3431
    Forms[3] = 3432
    Forms[4] = 3497
  ElseIf Outfit == 100
    Return Self.HasHarryTeraSource()
  Else
    Return False
  EndIf
  If !Self.IsIntegrationPluginLoaded(Plugin)
    Return False
  EndIf
  Int Index = 0
  While Index < Forms.Length
    If !(Game.GetFormFromFile(Forms[Index], Plugin) as Armor)
      Return False
    EndIf
    Index += 1
  EndWhile
  String[] Parts = new String[6]
  Parts[0] = "cuirass"
  Parts[1] = "boots"
  Parts[2] = "gloves"
  Parts[3] = "horns"
  Parts[4] = "tail"
  Parts[5] = "wings"
  Index = 0
  While Index < Parts.Length
    If !miscutil.FileExists(Root + Parts[Index] + "_0.nif") || !miscutil.FileExists(Root + Parts[Index] + "_1.nif") || !miscutil.FileExists(Root + Parts[Index] + ".tri")
      Return False
    EndIf
    Index += 1
  EndWhile
  If !miscutil.FileExists(Root + "physics/Tail.xml")
    Return False
  EndIf
  If Outfit == 3
    Return miscutil.FileExists(Root + "physics/Wings.xml")
  EndIf
  If Outfit == 1
    Return miscutil.FileExists(Root + "physics/Cuirass1.xml") && miscutil.FileExists(Root + "physics/Wings.xml")
  EndIf
  Return True
EndFunction

String Function GetExternalOutfitSourceStatus(Int Outfit)
  Return Self.GetExternalOutfitSourceStatus38(Outfit)
EndFunction

Bool Function HasHarryTeraSource()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.SourceReady34(100)
  EndIf
  String Plugin = "TeraSuccubusArmor.esp"
  If !Self.IsIntegrationPluginLoaded(Plugin)
    Return False
  EndIf
  Int[] Forms = new Int[8]
  Forms[0] = 2048
  Forms[1] = 2049
  Forms[2] = 2050
  Forms[3] = 2051
  Forms[4] = 2064
  Forms[5] = 2065
  Forms[6] = 2066
  Forms[7] = 2067
  Int i = 0
  While i < Forms.Length
    If !(Game.GetFormFromFile(Forms[i], Plugin) as Armor)
      Return False
    EndIf
    i += 1
  EndWhile
  String[] Parts = new String[8]
  Parts[0] = "Corset"
  Parts[1] = "Collar"
  Parts[2] = "Garter"
  Parts[3] = "Panty"
  Parts[4] = "Boots"
  Parts[5] = "Stockings"
  Parts[6] = "Gauntlets"
  Parts[7] = "Tail"
  i = 0
  While i < Parts.Length
    String Root = "Data/meshes/PSQ/ExternalOutfits/TERAHarry/" + Parts[i]
    If !miscutil.FileExists(Root + "_0.nif") || !miscutil.FileExists(Root + "_1.nif") || !miscutil.FileExists(Root + ".tri")
      Return False
    EndIf
    i += 1
  EndWhile
  i = 0
  While i < 6
    If !(Game.GetFormFromFile(45056 + i, "PSQ PlayerSuccubusQuest.esm") as Armor)
      Return False
    EndIf
    i += 1
  EndWhile
  Return True
EndFunction

Function SetTransformHairColorEnabled(Bool Enabled, Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236
    Int Result = PSQAppearance.MenuColorCommit(Self, 4, Enabled as Int, Owner, PSQLoadEpoch, RequireBusy)
    If Result != 0
      If Result > 0
        Self.SyncTransformHairColor(Owner, RequireBusy)
      EndIf
      Return
    EndIf
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  HenshinHairColor = Enabled
  Self.SyncTransformHairColor(Owner, RequireBusy)
EndFunction

Function SyncTransformHairColor(Int Owner, Bool RequireBusy)
  Self.SyncPlayerAppearanceRace()
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy) || !IsHenshined
    Return
  EndIf
  If PlayerRef == None || !PlayerRef.Is3DLoaded()
    Debug.Notification("角色模型尚未加载，颜色已保存，请稍后重试。")
    Return
  EndIf
  If HenshinHairColor
    If psqracecompatibility.ShouldPreserveHeadAppearance(PlayerRef)
      Debug.Notification("发色已保存；当前种族受外观保护，无法应用变身发色。")
      Return
    EndIf
    If PSQSuccubusHairColor == None
      Debug.Notification("变身发色记录缺失，无法应用。")
      Return
    EndIf
    If OrgHairColor == None && PlayerRef.GetLeveledActorBase().GetHairColor() == PSQSuccubusHairColor
      Debug.Notification("缺少原发色备份，本次应用已停止。")
      Return
    EndIf
    Self.ApplyTransformHairColor(True, Owner, RequireBusy)
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    If OrgHairColor == None
      Debug.Notification("缺少原发色备份，本次应用已停止。")
      Return
    EndIf
    Game.UpdateHairColor()
  Else
    Bool HadBackup = OrgHairColor != None
    Bool Restored = Self.RestoreOriginalPlayerHairColor(Owner, RequireBusy)
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    If Restored
      Game.UpdateHairColor()
    ElseIf HadBackup
      Debug.Notification("原发色恢复失败，备份已保留，请稍后重试。")
    EndIf
  EndIf
EndFunction

Function SaveAppearanceColor(Int Kind, Int Value)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236
    Int Result = PSQAppearance.MenuColorCommit(Self, Kind, Value, -1, PSQLoadEpoch, False)
    If Result != 0
      If Result == 1
        Self.QueueAppearanceColorRefresh(True)
      ElseIf Result == 2
        Debug.Notification("颜色已保存，将在变身后应用。")
      ElseIf Result == 3
        Debug.Notification("肤色已保存；请开启皮肤变色，关闭菜单后应用。")
      ElseIf Result == 4
        Debug.Notification("发色已保存；请开启发色变换，关闭菜单后应用。")
      EndIf
      Return
    EndIf
  EndIf
  If Kind == 0
    PSQSkinColor = Self.ComposeTransformSkinColor(Value, PSQSkinColorAlpha)
  ElseIf Kind == 1
    PSQSuccubusHairColorInt = Value
  ElseIf Kind == 2
    If Value < 0
      Value = 0
    ElseIf Value > 255
      Value = 255
    EndIf
    PSQSkinColorAlpha = Value
    PSQSkinColor = Self.ComposeTransformSkinColor(PSQSkinColor, Value)
  Else
    Return
  EndIf
  If !IsHenshined
    Debug.Notification("颜色已保存，将在变身后应用。")
    Return
  EndIf
  If (Kind == 0 || Kind == 2) && !HenshinSkin
    Debug.Notification("肤色已保存；请开启皮肤变色，关闭菜单后应用。")
    Return
  ElseIf Kind == 1 && !HenshinHairColor
    Debug.Notification("发色已保存；请开启发色变换，关闭菜单后应用。")
    Return
  EndIf
  Self.QueueAppearanceColorRefresh(True)
EndFunction

Function SetAppearanceColorEnabled(Int Kind, Bool Enabled)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && (Kind == 0 || Kind == 1)
    Int Result = PSQAppearance.MenuColorCommit(Self, Kind + 3, Enabled as Int, -1, PSQLoadEpoch, False)
    If Result != 0
      If Result > 0
        Self.QueueAppearanceColorRefresh(True)
      EndIf
      Return
    EndIf
  EndIf
  If Kind == 0
    HenshinSkin = Enabled
  ElseIf Kind == 1
    HenshinHairColor = Enabled
  Else
    Return
  EndIf
  Self.QueueAppearanceColorRefresh(True)
EndFunction

Bool Function BeginAppearanceColorEdit()
  Self.SyncPlayerAppearanceRace()
  If PlayerRef == None || !PlayerRef.Is3DLoaded() || UninstallPrepared || UninstallCleanupBusy
    Return False
  EndIf
  If AppearanceEditBusy || IsHenshinchu || BodySelectionRefreshBusy || StatPoolEditBusy || AppearanceRecoveryPending || AppearanceRecoveryInProgress
    Return False
  EndIf
  If psqracecompatibility.IsTemporaryBeastRace(PlayerRef.GetRace())
    Return False
  EndIf
  ; Colors do not change equipment ownership or cancel the entry pool refill.
  AppearanceEditBusy = True
  AppearanceOperationStage = "color"
  AppearanceLastProgress = Utility.GetCurrentRealTime()
  Return True
EndFunction

Function QueueAppearanceColorRefresh(Bool Notify = False)
  If PlayerRef == None || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  Int Ticket = storageutil.GetIntValue(PlayerRef, "PSQ_ColorRefreshTicket", 0) + 1
  storageutil.SetIntValue(PlayerRef, "PSQ_ColorRefreshTicket", Ticket)
  Self.RegisterForModEvent("PSQ_ReburnColorRefresh", "OnPSQAppearanceColorRefresh")
  Self.SendModEvent("PSQ_ReburnColorRefresh", Ticket as String, PSQLoadEpoch as Float)
  If Notify
    Debug.Notification("颜色设置已保存，关闭菜单后刷新外观。")
  EndIf
EndFunction

Function OnPSQAppearanceColorRefresh(String EventName, String Argument, Float Number, Form Sender)
  If Sender != Self || PlayerRef == None
    Return
  EndIf
  Int Ticket = Argument as Int
  Int Epoch = Number as Int
  ; Utility.Wait pauses in menus: refresh after SkyUI releases its color dialog.
  Utility.Wait(0.1)
  Int Attempt = 0
  While Attempt < 10
    If Epoch != PSQLoadEpoch || Ticket != storageutil.GetIntValue(PlayerRef, "PSQ_ColorRefreshTicket", 0) || UninstallPrepared || UninstallCleanupBusy
      Return
    EndIf
    If !AppearanceEditBusy && !IsHenshinchu && !BodySelectionRefreshBusy && !AppearanceRecoveryPending && !AppearanceRecoveryInProgress && !StatPoolEditBusy && PlayerRef.Is3DLoaded()
      Int Owner = AppearanceOperationId
      If Self.BeginAppearanceColorEdit()
        Owner = AppearanceOperationId
        AppearanceOperationStage = "color"
        Self.SyncTransformSkinColor(Owner, True)
        If Self.IsAppearanceOperationCurrent(Owner, True)
          Self.SyncTransformHairColor(Owner, True)
        EndIf
        If Self.IsAppearanceOperationCurrent(Owner, True)
          Self.EndAppearanceEdit(Owner)
        EndIf
      Else
        Debug.Notification("颜色已保存，但外观被其他功能占用，请稍后重试。")
      EndIf
      Return
    EndIf
    Attempt += 1
    Utility.Wait(0.2)
  EndWhile
  If Epoch == PSQLoadEpoch && Ticket == storageutil.GetIntValue(PlayerRef, "PSQ_ColorRefreshTicket", 0)
    Debug.Notification("颜色已保存；变身或模型刷新尚未结束，请完成后重试。")
  EndIf
EndFunction

Armor Function GetTRXFutaChoice(Int Index)
  String Plugin = "SOS - TRX - Futanari Addon.esp"
  If Index < 0 || Index > 2 || !Self.IsIntegrationPluginLoaded(Plugin)
    Return None
  EndIf
  If !miscutil.FileExists("Data/meshes/[TRX] Futa addon/Regular/trx_schlong_1.nif") && !miscutil.FileExists("Data/meshes/[TRX] Futa addon/trx_schlong_1.nif")
    Return None
  EndIf
  Int ID = 224269
  Int OldID = 2114
  If Index == 1
    ID = 224267
    OldID = 2112
  ElseIf Index == 2
    ID = 224265
    OldID = 2110
  EndIf
  Armor Choice = Game.GetFormFromFile(ID, Plugin) as Armor
  If Choice == None
    Choice = Game.GetFormFromFile(OldID, Plugin) as Armor
  EndIf
  Return Choice
EndFunction

Armor Function GetSelectedTRXFuta(Bool Transformed)
  Armor Selected = PlayerHumanSchlong
  If Transformed
    Selected = PlayerSuccubusSchlong
  EndIf
  Int i = 0
  While i < 3
    Armor Choice = Self.GetTRXFutaChoice(i)
    If Choice != None && Selected == Choice
      Return Choice
    EndIf
    i += 1
  EndWhile
  Return Self.GetTRXFutaChoice(0)
EndFunction

String Function GetTRXFutaLabel(Bool Transformed)
  Armor Selected = Self.GetSelectedTRXFuta(Transformed)
  If Selected == None
    Return "未检测到 TRX 插件或模型"
  EndIf
  If Selected == Self.GetTRXFutaChoice(1)
    Return "TRX 轻甲"
  ElseIf Selected == Self.GetTRXFutaChoice(2)
    Return "TRX 重甲"
  EndIf
  Return "TRX 普通"
EndFunction

Bool Function IsRetiredFutaArmor(Armor Item)
  Return Item != None && (Item == FemaleSchlongA || Item == FemaleSchlongB || Item == FemaleSchlongC || Item == FemaleSchlongD || Item == FemaleSchlongE)
EndFunction

Bool Function RemoveLegacyFutaItems(Actor Target)
  If Target == None || (!FemaleSchlongA && !FemaleSchlongB && !FemaleSchlongC && !FemaleSchlongD && !FemaleSchlongE)
    Return False
  EndIf
  Bool Removed = False
  Armor[] Retired = new Armor[5]
  Retired[0] = FemaleSchlongA
  Retired[1] = FemaleSchlongB
  Retired[2] = FemaleSchlongC
  Retired[3] = FemaleSchlongD
  Retired[4] = FemaleSchlongE
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777225 && PSQAppearance.NoLegacyArmor(Target, Retired)
    Return False
  EndIf
  Int i = 0
  While i < 5
    If Retired[i] != None
      Int Count = Target.GetItemCount(Retired[i])
      If Count > 0
        Target.UnequipItem(Retired[i], False, True)
        Target.RemoveItem(Retired[i], Count, True)
        Removed = True
      EndIf
    EndIf
    i += 1
  EndWhile
  If Removed && storageutil.GetIntValue(Target, "PSQ_HasPenis", 0) == 1 && AutoGenderSwitch && SexLab != None && Self.IsIntegrationPluginLoaded("SexLab.esm") && SexLab.GetGender(Target) == 0
    storageutil.SetIntValue(Target, "PSQ_TRXFutaGenderOwned", 1)
  EndIf
  Return Removed
EndFunction

Bool Function EquipTRXFuta(Actor Target, Bool Transformed)
  If Target == None || Target.GetLeveledActorBase().GetSex() != 1
    Return False
  EndIf
  If psqracecompatibility.IsUBEActor(Target)
    Debug.Notification("UBE 使用自身的身体附件；PSQ 暂不向该身形装备 CBBE版 TRX 部件。")
    Return False
  EndIf
  Armor Item = Self.GetSelectedTRXFuta(Transformed)
  If Item == None
    Debug.Notification("未检测到可用的 TRX 扶她插件或模型，无法启用扶她外观。")
    Return False
  EndIf
  Armor Previous = storageutil.GetFormValue(Target, "PSQ_TRXFutaItem", None) as Armor
  Int PreviousAdded = storageutil.GetIntValue(Target, "PSQ_TRXFutaAdded", 0)
  If Previous == Item && (Target.IsEquipped(Item) || storageutil.GetIntValue(Target, "PSQ_TRXFutaClothed", 0) == 1)
    storageutil.SetIntValue(Target, "PSQ_HasPenis", 1)
    storageutil.SetIntValue(Target, "PSQ_TRXFutaTransformed", Transformed as Int)
    Self.QueueBCNGFutaSkin(Target)
    Self.QueueTRXFutaSize(Target)
    Return True
  EndIf
  Armor Original = storageutil.GetFormValue(Target, "PSQ_TRXFutaOriginal52", None) as Armor
  If Previous == None
    Original = Target.GetWornForm(4194304) as Armor
    If Self.IsRetiredFutaArmor(Original) || Original == Game.GetFormFromFile(45056, "PSQ PlayerSuccubusQuest.esm") as Armor
      Original = None
    EndIf
    storageutil.SetFormValue(Target, "PSQ_TRXFutaOriginal52", Original)
  EndIf
  If Previous != None
    Target.UnequipItem(Previous, False, True)
  EndIf
  Int Added = 0
  If Previous == Item
    Added = PreviousAdded
  EndIf
  If Target.GetItemCount(Item) == 0
    Target.AddItem(Item, 1, True)
    Added = 1
  EndIf
  Bool Covered = Self.IsTRXFutaCovered(Target, Item)
  If !Covered
    Target.EquipItem(Item, False, True)
  EndIf
  If !Covered && !Target.IsEquipped(Item)
    If Added == 1
      Target.RemoveItem(Item, 1, True)
    EndIf
    If Previous != None && Target.GetItemCount(Previous) > 0
      Target.EquipItem(Previous, False, True)
    ElseIf Original != None && Target.GetItemCount(Original) > 0
      Target.EquipItem(Original, False, True)
    EndIf
    Debug.Notification("TRX 装备未能穿戴，已撤回临时物品并尝试恢复原装备。")
    Return False
  EndIf
  If Previous != None && Previous != Item && PreviousAdded == 1 && Target.GetItemCount(Previous) > 0
    Target.RemoveItem(Previous, 1, True)
  EndIf
  storageutil.SetIntValue(Target, "PSQ_TRXFutaClothed", Covered as Int)
  storageutil.SetFormValue(Target, "PSQ_TRXFutaItem", Item)
  storageutil.SetIntValue(Target, "PSQ_TRXFutaAdded", Added)
  storageutil.SetIntValue(Target, "PSQ_HasPenis", 1)
  storageutil.SetIntValue(Target, "PSQ_TRXFutaTransformed", Transformed as Int)
  Self.QueueBCNGFutaSkin(Target)
    Self.QueueTRXFutaSize(Target)
  If EnableFutanariPower
    Target.AddSpell(PowerOfFutanari, False)
  EndIf
  If AutoGenderSwitch && SexLab != None && Self.IsIntegrationPluginLoaded("SexLab.esm") && SexLab.GetGender(Target) == 1
    SexLab.TreatAsMale(Target)
    storageutil.SetIntValue(Target, "PSQ_TRXFutaGenderOwned", 1)
  EndIf
  Return True
EndFunction

Function RemoveTRXFuta(Actor Target, Bool RestoreOriginal = True)
  Self.ClearTRXFutaSize(Target)
  Self.RestoreBCNGFutaSkin(Target)
  If Target == None
    Return
  EndIf
  Armor Item = storageutil.GetFormValue(Target, "PSQ_TRXFutaItem", None) as Armor
  Armor Original = storageutil.GetFormValue(Target, "PSQ_TRXFutaOriginal52", None) as Armor
  Armor Current52 = Target.GetWornForm(4194304) as Armor
  If Item != None
    Target.UnequipItem(Item, False, True)
    If storageutil.GetIntValue(Target, "PSQ_TRXFutaAdded", 0) == 1 && Target.GetItemCount(Item) > 0
      Target.RemoveItem(Item, 1, True)
    EndIf
  EndIf
  If RestoreOriginal && (Current52 == None || Current52 == Item) && Original != None && !Self.IsRetiredFutaArmor(Original) && Target.GetItemCount(Original) > 0
    Target.EquipItem(Original, False, True)
  EndIf
  storageutil.UnsetFormValue(Target, "PSQ_TRXFutaItem")
  storageutil.UnsetFormValue(Target, "PSQ_TRXFutaOriginal52")
  storageutil.UnsetIntValue(Target, "PSQ_TRXFutaAdded")
  storageutil.UnsetIntValue(Target, "PSQ_TRXFutaClothed")
  storageutil.SetIntValue(Target, "PSQ_HasPenis", 0)
  Target.RemoveSpell(PowerOfFutanari)
  If storageutil.GetIntValue(Target, "PSQ_TRXFutaGenderOwned", 0) == 1 && SexLab != None && Self.IsIntegrationPluginLoaded("SexLab.esm")
    SexLab.ClearForcedGender(Target)
  EndIf
  storageutil.UnsetIntValue(Target, "PSQ_TRXFutaGenderOwned")
EndFunction

Function ToggleTRXFuta(Actor Target)
  If Target == None || Target.GetLeveledActorBase().GetSex() != 1
    Return
  EndIf
  If Target == PlayerRef && (AppearanceEditBusy || IsHenshinchu || AppearanceRecoveryPending)
    Debug.Notification("请等待变身或外观恢复完成，再切换扶她外观。")
    Return
  EndIf
  Bool WasOn = storageutil.GetIntValue(Target, "PSQ_HasPenis", 0) == 1
  Self.RemoveLegacyFutaItems(Target)
  If WasOn || storageutil.GetFormValue(Target, "PSQ_TRXFutaItem", None) != None
    Self.RemoveTRXFuta(Target, True)
    If Target == PlayerRef && Target.GetWornForm(4194304) == None && OrgSlot52 != None && !Self.IsRetiredFutaArmor(OrgSlot52) && Target.GetItemCount(OrgSlot52) > 0
      Target.EquipItem(OrgSlot52, False, True)
      OrgSlot52 = None
    EndIf
  Else
    Self.EquipTRXFuta(Target, Target == PlayerRef && IsHenshined)
  EndIf
EndFunction

Function EnterTRXTargetFuta(Actor Target)
  Bool HadPenis = storageutil.GetIntValue(Target, "PSQ_HasPenis", 0) == 1
  storageutil.SetIntValue(Target, "PSQ_StillEquipPenis", HadPenis as Int)
  Self.RemoveLegacyFutaItems(Target)
  Bool Want = HenshinPenis
  If Target != PlayerRef
    Want = storageutil.GetIntValue(Target, "PSQ_NPCTransformPenis", HenshinPenis as Int) == 1
  EndIf
  If Want || HadPenis
    Self.EquipTRXFuta(Target, True)
  EndIf
EndFunction

Function ExitTRXTargetFuta(Actor Target, Bool RestoreHuman)
  Bool Keep = RestoreHuman && storageutil.GetIntValue(Target, "PSQ_StillEquipPenis", 0) == 1
  Self.RemoveTRXFuta(Target, True)
  Self.RemoveLegacyFutaItems(Target)
  If Keep
    Self.EquipTRXFuta(Target, False)
  EndIf
EndFunction

Function MigrateLegacyPlayerFuta()
  If PlayerRef == None
    Return
  EndIf
  Self.QueueBCNGTransformSkin()
  If psqracecompatibility.IsUBEActor(PlayerRef)
    If storageutil.GetFormValue(PlayerRef, "PSQ_TRXFutaItem", None) != None
      Self.RemoveTRXFuta(PlayerRef, False)
    EndIf
    Return
  EndIf
  Bool HadPenis = storageutil.GetIntValue(PlayerRef, "PSQ_HasPenis", 0) == 1
  Bool Removed = Self.RemoveLegacyFutaItems(PlayerRef)
  If Removed && HadPenis
    storageutil.SetIntValue(PlayerRef, "PSQ_HasPenis", 0)
    Bool Equipped = False
    If !UninstallPrepared && !UninstallCleanupBusy
      Equipped = Self.EquipTRXFuta(PlayerRef, IsHenshined)
      If Equipped && OrgSlot52 != None && !Self.IsRetiredFutaArmor(OrgSlot52)
        storageutil.SetFormValue(PlayerRef, "PSQ_TRXFutaOriginal52", OrgSlot52)
      EndIf
    EndIf
    If !Equipped
      ; A human accessory belongs to the normal exit restore, even if
      ; legacy attachment migration fails while loading a transformed save.
      Self.RemoveTRXFuta(PlayerRef, !IsHenshined && !IsHenshinchu && !AppearanceRecoveryPending && !AppearanceEditBusy)
      If OrgSlot52 != None && !Self.IsRetiredFutaArmor(OrgSlot52) && PlayerRef.GetItemCount(OrgSlot52) > 0 && PlayerRef.GetWornForm(4194304) == None && !IsHenshined && !IsHenshinchu && !AppearanceRecoveryPending && !AppearanceEditBusy
        PlayerRef.EquipItem(OrgSlot52, False, True)
      EndIf
    EndIf
  EndIf
  If storageutil.GetFormValue(PlayerRef, "PSQ_TRXFutaItem", None) != None || storageutil.GetIntValue(PlayerRef, "PSQ_BCNGFutaOwned", 0) == 1
    Self.QueueBCNGFutaSkin(PlayerRef)
    Self.QueueTRXFutaSize(PlayerRef)
  EndIf
EndFunction

Bool Function HasBCNGFutaAPI()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    Int BridgeLevel = PSQAppearance.BodyBridgeCandidate33()
    Return BridgeLevel >= 3 && BCNGPSQBridge.GetVersion() == BridgeLevel && BCNGPSQBridge.IsReady()
  EndIf
  If !Self.HasExternalBodyChangeNG()
    Return False
  EndIf
  Int Version = skse.GetPluginVersion("Body Change NG")
  If Version == 16973953
    Return BCNGPSQBridge.GetVersion() == 4 && BCNGPSQBridge.IsReady()
  EndIf
  If Version != 16973939
    Return False
  EndIf
  Return BCNGPSQBridge.GetVersion() == 3 && BCNGPSQBridge.IsReady()
EndFunction

Bool Function HasBCNGEquipmentAPI()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    Int BridgeLevel = PSQAppearance.BodyBridgeCandidate33()
    Return BridgeLevel >= 2 && BCNGPSQBridge.GetVersion() == BridgeLevel
  EndIf
  If !Self.HasExternalBodyChangeNG()
    Return False
  EndIf
  Int Version = skse.GetPluginVersion("Body Change NG")
  If Version == 16973938
    Return BCNGPSQBridge.GetVersion() == 2
  ElseIf Version == 16973939
    Return BCNGPSQBridge.GetVersion() == 3
  ElseIf Version == 16973953
    Return BCNGPSQBridge.GetVersion() == 4
  EndIf
  Return False
EndFunction

String Function GetBCNGFutaSetting(Bool Transformed)
  If Transformed
    Return storageutil.GetStringValue(Self, "PSQ_BCNGFutaSuccubus", "")
  EndIf
  Return storageutil.GetStringValue(Self, "PSQ_BCNGFutaHuman", "")
EndFunction

String Function GetBCNGFutaSkinName(String ID)
  If ID == "" || ID == "@follow"
    Return "跟随 Body Change"
  ElseIf ID == "@default"
    Return "TRX 装备默认贴图"
  ElseIf Self.HasBCNGFutaAPI()
    String Name = BCNGPSQBridge.GetFutanariName(ID)
    If Name != ""
      Return Name
    EndIf
  EndIf
  Return "皮肤包缺失或接口不可用"
EndFunction

String Function GetBCNGFutaStatus()
  If !Self.HasBCNGFutaAPI()
    Return "需要 PSQ 内置 BCNG 接口版（重启生效）"
  EndIf
  If storageutil.GetIntValue(PlayerRef, "PSQ_BCNGFutaManualTakeover", 0) == 1
    Return "保留 BCNG 中的新选择；重选 PSQ 皮肤可接管"
  EndIf
  Return "BCNG 扶她接口就绪"
EndFunction

String[] Function GetBCNGFutaSkinIDs()
  String[] NativeIDs
  If Self.HasBCNGFutaAPI()
    NativeIDs = BCNGPSQBridge.GetFutanariIds(PlayerRef)
  EndIf
  Int Count = 0
  If NativeIDs
    Count = NativeIDs.Length
  EndIf
  String[] IDs = papyrusutil.StringArray(Count + 2, "")
  IDs[0] = "@follow"
  IDs[1] = "@default"
  Int i = 0
  While i < Count
    IDs[i + 2] = NativeIDs[i]
    i += 1
  EndWhile
  Return IDs
EndFunction

Function ForgetBCNGFutaOwnership(Actor Target)
  storageutil.UnsetIntValue(Target, "PSQ_BCNGFutaOwned")
  storageutil.UnsetStringValue(Target, "PSQ_BCNGFutaOriginalID")
  storageutil.UnsetIntValue(Target, "PSQ_BCNGFutaOriginalMode")
  storageutil.UnsetStringValue(Target, "PSQ_BCNGFutaOwnedID")
EndFunction

Function RestoreBCNGFutaSkin(Actor Target)
  If Target == None || storageutil.GetIntValue(Target, "PSQ_BCNGFutaOwned", 0) != 1
    Return
  EndIf
  If !Self.HasBCNGFutaAPI()
    Return
  EndIf
  String Owned = storageutil.GetStringValue(Target, "PSQ_BCNGFutaOwnedID", "")
  Int Result = BCNGPSQBridge.RestoreFutanariSelection(Target, Owned, storageutil.GetStringValue(Target, "PSQ_BCNGFutaOriginalID", ""), storageutil.GetIntValue(Target, "PSQ_BCNGFutaOriginalMode", 0))
  If Result == 1 || Result == 2
    Self.ForgetBCNGFutaOwnership(Target)
    If Result == 2
      storageutil.SetIntValue(Target, "PSQ_BCNGFutaManualTakeover", 1)
    EndIf
  Else
    Debug.Notification("BCNG 扶她皮肤恢复请求失败，原选择备份已保留。")
  EndIf
EndFunction

Function SetBCNGFutaSetting(Bool Transformed, String ID)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Self.SaveBodyChangeSkinChoice(True, Transformed, ID)
    Return
  EndIf
  If ID == "@follow"
    ID = ""
  EndIf
  If ID != "" && !Self.HasBCNGFutaAPI()
    Debug.Notification("扶她皮肤接口尚未就绪，请重启游戏并检查 PSQ 的 BCNG DLL 覆盖。")
    Return
  EndIf
  If ID != "" && ID != "@default" && BCNGPSQBridge.GetFutanariName(ID) == ""
    Debug.Notification("所选扶她皮肤包已失效，请刷新列表后重选。")
    Return
  EndIf
  If Transformed
    storageutil.SetStringValue(Self, "PSQ_BCNGFutaSuccubus", ID)
  Else
    storageutil.SetStringValue(Self, "PSQ_BCNGFutaHuman", ID)
  EndIf
  If PlayerRef != None && Transformed == IsHenshined
    storageutil.UnsetIntValue(PlayerRef, "PSQ_BCNGFutaManualTakeover")
    storageutil.SetIntValue(PlayerRef, "PSQ_BCNGFutaForce", 1)
    Self.QueueBCNGFutaSkin(PlayerRef)
  EndIf
  Debug.Notification("扶她皮肤选择已保存，关闭菜单后应用。")
EndFunction

Function QueueBCNGFutaSkin(Actor Target)
  If Target == None
    Return
  EndIf
  Int Ticket = storageutil.GetIntValue(Target, "PSQ_BCNGFutaTicket", 0) + 1
  storageutil.SetIntValue(Target, "PSQ_BCNGFutaTicket", Ticket)
  Self.RegisterForModEvent("PSQ_BCNGFutaSkin", "OnPSQBCNGFutaSkin")
  Self.RegisterForModEvent("PSQ_BCNGFutaGeometryReady", "OnPSQBCNGFutaGeometryReady")
  Target.SendModEvent("PSQ_BCNGFutaSkin", Ticket as String, PSQLoadEpoch as Float)
EndFunction

Function OnPSQBCNGFutaSkin(String EventName, String Argument, Float Number, Form Sender)
  Actor Target = Sender as Actor
  If Target == None
    Return
  EndIf
  Int Ticket = Argument as Int
  Int Epoch = Number as Int
  Utility.Wait(0.2)
  Int Attempt = 0
  Bool NativePolicy = SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
  While Attempt < 16
    If Epoch != PSQLoadEpoch || Ticket != storageutil.GetIntValue(Target, "PSQ_BCNGFutaTicket", 0)
      Return
    EndIf
    If storageutil.GetFormValue(Target, "PSQ_TRXFutaItem", None) == None || UninstallPrepared || UninstallCleanupBusy
      Self.RestoreBCNGFutaSkin(Target)
      storageutil.UnsetIntValue(Target, "PSQ_BCNGFutaForce")
      Return
    EndIf
    If storageutil.GetIntValue(Target, "PSQ_TRXFutaClothed", 0) == 1
      Return
    EndIf
    Bool ProviderReady = Self.HasBCNGFutaAPI()
    Bool GeometryReady = False
    If ProviderReady
      If NativePolicy
        GeometryReady = PSQAppearance.SkinReady34(Self, Target, True)
      Else
        GeometryReady = Target.Is3DLoaded() && !AppearanceEditBusy && !IsHenshinchu && !AppearanceRecoveryPending && !BodySelectionRefreshBusy
      EndIf
    EndIf
    If GeometryReady
      Bool Transformed = storageutil.GetIntValue(Target, "PSQ_TRXFutaTransformed", 0) == 1
      If Target == PlayerRef
        Transformed = IsHenshined
      EndIf
      String ID = Self.GetBCNGFutaSetting(Transformed)
      If ID == ""
        Self.RestoreBCNGFutaSkin(Target)
        storageutil.UnsetIntValue(Target, "PSQ_BCNGFutaForce")
        Return
      EndIf
      Bool Forced = storageutil.GetIntValue(Target, "PSQ_BCNGFutaForce", 0) == 1
      If storageutil.GetIntValue(Target, "PSQ_BCNGFutaManualTakeover", 0) == 1 && !Forced
        Return
      EndIf
      String Current = BCNGPSQBridge.GetFutanariSelectionId(Target)
      Int CurrentMode = BCNGPSQBridge.GetFutanariSelectionMode(Target)
      Bool Owns = storageutil.GetIntValue(Target, "PSQ_BCNGFutaOwned", 0) == 1
      If Owns
        String OwnedID = storageutil.GetStringValue(Target, "PSQ_BCNGFutaOwnedID", "")
        Bool Matching = False
        If NativePolicy
          Matching = PSQAppearance.SkinMatches34(True, Current, CurrentMode, OwnedID)
        Else
          Int OwnedMode = 2
          If OwnedID == ""
            OwnedMode = 3
          EndIf
          Matching = Current == OwnedID && CurrentMode == OwnedMode
        EndIf
        If !Matching
          Self.ForgetBCNGFutaOwnership(Target)
          Owns = False
          If !Forced
            storageutil.SetIntValue(Target, "PSQ_BCNGFutaManualTakeover", 1)
            Return
          EndIf
        EndIf
      EndIf
      If ID == "@default"
        ID = ""
      EndIf
      If Epoch != PSQLoadEpoch || Ticket != storageutil.GetIntValue(Target, "PSQ_BCNGFutaTicket", 0)
        Return
      EndIf
      Int Result = BCNGPSQBridge.RequestFutanariSkin(Target, ID)
      If Result == 1
        If !Owns
          storageutil.SetStringValue(Target, "PSQ_BCNGFutaOriginalID", Current)
          storageutil.SetIntValue(Target, "PSQ_BCNGFutaOriginalMode", CurrentMode)
        EndIf
        storageutil.SetStringValue(Target, "PSQ_BCNGFutaOwnedID", ID)
        storageutil.SetIntValue(Target, "PSQ_BCNGFutaOwned", 1)
        storageutil.UnsetIntValue(Target, "PSQ_BCNGFutaForce")
        Return
      ElseIf Result == -2
        Debug.Notification("该扶她皮肤与当前身体／种族不匹配，保留 TRX 原贴图。")
        Return
      EndIf
    ElseIf !ProviderReady
      If Self.GetBCNGFutaSetting(Target == PlayerRef && IsHenshined) != ""
        Debug.Notification("BCNG 扶她皮肤接口不可用，继续使用 TRX 原贴图。")
      EndIf
      Return
    EndIf
    Attempt += 1
    Utility.Wait(0.2)
  EndWhile
  If Epoch == PSQLoadEpoch && Ticket == storageutil.GetIntValue(Target, "PSQ_BCNGFutaTicket", 0)
    Debug.Notification("扶她皮肤尚未找到可用的 TRX 模型，请在变身完成后重选皮肤重试。")
  EndIf
EndFunction

Int Function GetBCNGFutaLoadEpoch()
  Return PSQLoadEpoch
EndFunction

Function OnPSQBCNGFutaGeometryReady(String EventName, String Argument, Float Number, Form Sender)
  Actor Target = Sender as Actor
  If Target == None || !Self.HasBCNGFutaAPI() || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  Self.QueueTRXFutaClothingIfNeeded(Target)
  Armor Item = storageutil.GetFormValue(Target, "PSQ_TRXFutaItem", None) as Armor
  If Item == None || !Target.IsEquipped(Item)
    Return
  EndIf
  Self.SyncTRXFutaSize(Target)
  If storageutil.GetIntValue(Target, "PSQ_BCNGFutaManualTakeover", 0) == 1
    Return
  EndIf
  Bool Transformed = storageutil.GetIntValue(Target, "PSQ_TRXFutaTransformed", 0) == 1
  If Target == PlayerRef
    Transformed = IsHenshined
  EndIf
  If Self.GetBCNGFutaSetting(Transformed) == ""
    If storageutil.GetIntValue(Target, "PSQ_BCNGFutaOwned", 0) == 1
      Self.QueueBCNGFutaSkin(Target)
    EndIf
    Return
  EndIf
  If storageutil.GetIntValue(Target, "PSQ_BCNGFutaOwned", 0) == 1
    String Owned = storageutil.GetStringValue(Target, "PSQ_BCNGFutaOwnedID", "")
    Bool Matching = False
    If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
      Matching = PSQAppearance.SkinMatches34(True, BCNGPSQBridge.GetFutanariSelectionId(Target), BCNGPSQBridge.GetFutanariSelectionMode(Target), Owned)
    Else
      Int Mode = 2
      If Owned == ""
        Mode = 3
      EndIf
      Matching = BCNGPSQBridge.GetFutanariSelectionId(Target) == Owned && BCNGPSQBridge.GetFutanariSelectionMode(Target) == Mode
    EndIf
    If Matching
      Return
    EndIf
  EndIf
  Self.QueueBCNGFutaSkin(Target)
EndFunction

Float Function ClampTRXFutaSize(Float Value)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236
    If Value >= 0.25 && Value <= 3.0
      Return Value
    EndIf
    Float Size = PSQAppearance.MenuFutaSize(Self, 0, False, Value)
    If Size > 0.0
      Return Size
    EndIf
  EndIf
  If Value < 0.25
    Return 0.25
  ElseIf Value > 3.0
    Return 3.0
  EndIf
  Return Value
EndFunction

Float Function GetTRXFutaSize(Actor Target, Bool Scrotum, Bool Transformed)
  Float Value = storageutil.GetFloatValue(Self, "PSQ_TRXFutaHumanGenitals", 1.0)
  If Scrotum
    Value = storageutil.GetFloatValue(Self, "PSQ_TRXFutaHumanScrotum", 1.0)
  EndIf
  If Transformed
    If Scrotum && EnableScrotumChangeSuccubus
      Value = SuccubusScrotum
    ElseIf !Scrotum && EnableGenitalsChangeSuccubus
      Value = SuccubusGenitals
    EndIf
    If Target != None && Target != PlayerRef
      String Key = "PSQ_NPCTransformGenitals"
      If Scrotum
        Key = "PSQ_NPCTransformScrotum"
      EndIf
      Float NPCValue = storageutil.GetFloatValue(Target, Key, 0.0)
      If NPCValue > 0.0
        Value = NPCValue
      EndIf
    EndIf
  EndIf
  Return Self.ClampTRXFutaSize(Value)
EndFunction

Function SetTRXFutaSize(Bool Transformed, Bool Scrotum, Float Value)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236
    Float Size = PSQAppearance.MenuFutaSize(Self, Transformed as Int, Scrotum, Value)
    If Size < 0.0
      Return
    ElseIf Size > 0.0
      If !Transformed
        If Scrotum
          StorageUtil.SetFloatValue(Self, "PSQ_TRXFutaHumanScrotum", Size)
        Else
          StorageUtil.SetFloatValue(Self, "PSQ_TRXFutaHumanGenitals", Size)
        EndIf
      EndIf
      Self.QueueTRXFutaSize(PlayerRef)
      Return
    EndIf
  EndIf
  Value = Self.ClampTRXFutaSize(Value)
  If Transformed
    If Scrotum
      SuccubusScrotum = Value
      EnableScrotumChangeSuccubus = True
    Else
      SuccubusGenitals = Value
      EnableGenitalsChangeSuccubus = True
    EndIf
  ElseIf Scrotum
    storageutil.SetFloatValue(Self, "PSQ_TRXFutaHumanScrotum", Value)
  Else
    storageutil.SetFloatValue(Self, "PSQ_TRXFutaHumanGenitals", Value)
  EndIf
  Self.QueueTRXFutaSize(PlayerRef)
EndFunction

Function SetTRXNPCFutaSize(Actor Target, Bool Scrotum, Float Value)
  If Target == None || Target == PlayerRef
    Return
  EndIf
  String Key = "PSQ_NPCTransformGenitals"
  If Scrotum
    Key = "PSQ_NPCTransformScrotum"
  EndIf
  storageutil.SetFloatValue(Target, Key, Self.ClampTRXFutaSize(Value))
  Self.QueueTRXFutaSize(Target)
EndFunction

Bool Function SyncTRXFutaSize(Actor Target)
  If Target == None
    Return False
  EndIf
  Armor Item = storageutil.GetFormValue(Target, "PSQ_TRXFutaItem", None) as Armor
  If Item == None || !Self.HasNiOverrideRuntime() || !Target.Is3DLoaded() || !Target.IsEquipped(Item)
    Return False
  EndIf
  Bool Transformed = storageutil.GetIntValue(Target, "PSQ_TRXFutaTransformed", 0) == 1
  If Target == PlayerRef
    Transformed = IsHenshined
  EndIf
  Bool Found = False
  Int Part = 0
  While Part < 2
    String Node = "NPC Genitals01 [Gen01]"
    If Part == 1
      Node = "NPC GenitalsScrotum [GenScrot]"
    EndIf
    Float Value = Self.GetTRXFutaSize(Target, Part == 1, Transformed)
    Int View = 0
    While View < 2
      Bool FirstPerson = View == 1
      Bool Changed = nioverride.RemoveNodeTransformScale(Target, FirstPerson, True, Node, "PSQ")
      If netimmerse.HasNode(Target, Node, FirstPerson)
        ; Retire only this feature's previous PSQ layer, never SOS or foreign keys.
        If Value == 1.0
          Bool Removed = nioverride.RemoveNodeTransformScale(Target, FirstPerson, True, Node, "PSQ_TRXFuta")
          Changed = Changed || Removed
        ElseIf !nioverride.HasNodeTransformScale(Target, FirstPerson, True, Node, "PSQ_TRXFuta") || nioverride.GetNodeTransformScale(Target, FirstPerson, True, Node, "PSQ_TRXFuta") != Value
          nioverride.AddNodeTransformScale(Target, FirstPerson, True, Node, "PSQ_TRXFuta", Value)
          Changed = True
        EndIf
        If Changed
          nioverride.UpdateNodeTransform(Target, FirstPerson, True, Node)
        EndIf
        Found = True
      EndIf
      View += 1
    EndWhile
    Part += 1
  EndWhile
  If Found
    storageutil.SetIntValue(Target, "PSQ_TRXFutaSizeOwned", 1)
  EndIf
  Return Found
EndFunction

Function ClearTRXFutaSize(Actor Target)
  If Target == None || storageutil.GetIntValue(Target, "PSQ_TRXFutaSizeOwned", 0) != 1 || !Self.HasNiOverrideRuntime()
    Return
  EndIf
  Int Part = 0
  While Part < 2
    String Node = "NPC Genitals01 [Gen01]"
    If Part == 1
      Node = "NPC GenitalsScrotum [GenScrot]"
    EndIf
    Int View = 0
    While View < 2
      Bool FirstPerson = View == 1
      Bool Removed = nioverride.RemoveNodeTransformScale(Target, FirstPerson, True, Node, "PSQ_TRXFuta")
      If Removed && Target.Is3DLoaded() && netimmerse.HasNode(Target, Node, FirstPerson)
        nioverride.UpdateNodeTransform(Target, FirstPerson, True, Node)
      EndIf
      View += 1
    EndWhile
    Part += 1
  EndWhile
  storageutil.UnsetIntValue(Target, "PSQ_TRXFutaSizeOwned")
EndFunction

Function QueueTRXFutaSize(Actor Target)
  If Target == None
    Return
  EndIf
  Int Ticket = storageutil.GetIntValue(Target, "PSQ_TRXFutaSizeTicket", 0) + 1
  storageutil.SetIntValue(Target, "PSQ_TRXFutaSizeTicket", Ticket)
  Self.RegisterForModEvent("PSQ_TRXFutaSize", "OnPSQTRXFutaSize")
  Target.SendModEvent("PSQ_TRXFutaSize", Ticket as String, PSQLoadEpoch as Float)
EndFunction

Function OnPSQTRXFutaSize(String EventName, String Argument, Float Number, Form Sender)
  Actor Target = Sender as Actor
  If Target == None
    Return
  EndIf
  Int Ticket = Argument as Int
  Utility.Wait(0.2)
  Int Attempt = 0
  While Attempt < 12
    If Number as Int != PSQLoadEpoch || Ticket != storageutil.GetIntValue(Target, "PSQ_TRXFutaSizeTicket", 0)
      Return
    EndIf
    If UninstallPrepared || UninstallCleanupBusy || storageutil.GetFormValue(Target, "PSQ_TRXFutaItem", None) == None
      Self.ClearTRXFutaSize(Target)
      Return
    EndIf
    If !AppearanceEditBusy && !IsHenshinchu && !AppearanceRecoveryPending && !BodySelectionRefreshBusy
      If Self.SyncTRXFutaClothing(Target)
        If storageutil.GetIntValue(Target, "PSQ_TRXFutaClothed", 0) == 1 || Self.SyncTRXFutaSize(Target)
          Return
        EndIf
      EndIf
    EndIf
    Attempt += 1
    Utility.Wait(0.2)
  EndWhile
EndFunction

Bool Function IsTRXFutaCovered(Actor Target, Armor Selected = None)
  If Target == None
    Return False
  EndIf
  Armor Item = storageutil.GetFormValue(Target, "PSQ_TRXFutaItem", None) as Armor
  If Item == None
    Item = Selected
  EndIf
  Armor Clothing = Target.GetWornForm(4) as Armor
  If Clothing != None && Clothing != Item
    Return True
  EndIf
  Clothing = Target.GetWornForm(524288) as Armor
  If Clothing != None && Clothing != Item
    Return True
  EndIf
  Clothing = Target.GetWornForm(4194304) as Armor
  Return Clothing != None && Clothing != Item && !Self.IsRetiredFutaArmor(Clothing)
EndFunction

Function QueueTRXFutaClothingForArmor(Actor Target, Armor Item)
  If Target == None || Item == None || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  Armor Managed = storageutil.GetFormValue(Target, "PSQ_TRXFutaItem", None) as Armor
  If Managed == None
    Return
  EndIf
  If Item == Managed
    Self.QueueTRXFutaClothingIfNeeded(Target)
    Return
  EndIf
  If Math.LogicalAnd(Item.GetSlotMask(), 4718596) != 0
    Self.QueueTRXFutaSize(Target)
  EndIf
EndFunction

Function QueueTRXFutaClothingIfNeeded(Actor Target)
  If Target == None || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  If storageutil.GetFormValue(Target, "PSQ_TRXFutaItem", None) == None
    Return
  EndIf
  Bool Covered = Self.IsTRXFutaCovered(Target)
  Bool Hidden = storageutil.GetIntValue(Target, "PSQ_TRXFutaClothed", 0) == 1
  Armor Item = storageutil.GetFormValue(Target, "PSQ_TRXFutaItem", None) as Armor
  If Covered != Hidden || (Covered && Target.IsEquipped(Item))
    Self.QueueTRXFutaSize(Target)
  EndIf
EndFunction

Bool Function SyncTRXFutaClothing(Actor Target)
  If Target == None || !Target.Is3DLoaded() || UninstallPrepared || UninstallCleanupBusy
    Return False
  EndIf
  Armor Item = storageutil.GetFormValue(Target, "PSQ_TRXFutaItem", None) as Armor
  If Item == None
    Return False
  EndIf
  If Self.IsTRXFutaCovered(Target)
    storageutil.SetIntValue(Target, "PSQ_TRXFutaClothed", 1)
    If Target.IsEquipped(Item)
      Target.UnequipItem(Item, False, True)
    EndIf
    Return !Target.IsEquipped(Item)
  EndIf
  If storageutil.GetIntValue(Target, "PSQ_TRXFutaClothed", 0) == 1
    If Target.GetItemCount(Item) == 0
      Target.AddItem(Item, 1, True)
      storageutil.SetIntValue(Target, "PSQ_TRXFutaAdded", 1)
    EndIf
    If !Target.IsEquipped(Item)
      Target.EquipItem(Item, False, True)
    EndIf
    If !Target.IsEquipped(Item)
      Return False
    EndIf
    storageutil.SetIntValue(Target, "PSQ_TRXFutaClothed", 0)
    Self.QueueBCNGFutaSkin(Target)
  EndIf
  Return Target.IsEquipped(Item)
EndFunction

Function ClearBorrowedHarryTeraParts()
  Armor BorrowedHorn = Game.GetFormFromFile(45059, "PSQ PlayerSuccubusQuest.esm") as Armor
  Armor BorrowedWing = Game.GetFormFromFile(45061, "PSQ PlayerSuccubusQuest.esm") as Armor
  If PSQSuccubusHorns == BorrowedHorn && BorrowedHorn != None
    PSQSuccubusHorns = None
    HenshinHorn = False
    OptionalHornSelectedKey = ""
    If TransformPartSources && TransformPartSources.Length == 5
      TransformPartSources[3] = 0
    EndIf
    If PlayerRef != None && PlayerRef.IsEquipped(BorrowedHorn)
      PlayerRef.UnequipItem(BorrowedHorn, False, True)
    EndIf
  EndIf
  If PSQSuccubusWings == BorrowedWing && BorrowedWing != None
    PSQSuccubusWings = None
    HenshinWings = False
    If PlayerRef != None && PlayerRef.IsEquipped(BorrowedWing)
      PlayerRef.UnequipItem(BorrowedWing, False, True)
    EndIf
  EndIf
EndFunction

Bool Function HasExternalBodyChangeNG()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    Return PSQAppearance.BodyProviderInstalled33()
  EndIf
  Return miscutil.FileExists("Data/SKSE/Plugins/BodyChangeNGdistribution-README.txt")
EndFunction

Bool Function HasBCNGSkinAPI()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    Return PSQAppearance.BodyBridgeCandidate33() == 4 && BCNGPSQBridge.GetVersion() == 4 && BCNGPSQBridge.IsReady()
  EndIf
  If !Self.HasExternalBodyChangeNG() || skse.GetPluginVersion("Body Change NG") != 16973953
    Return False
  EndIf
  Return BCNGPSQBridge.GetVersion() == 4 && BCNGPSQBridge.IsReady()
EndFunction

String Function GetBCNGTransformSkinName()
  String ID = storageutil.GetStringValue(Self, "PSQ_BCNGTransformSkin", "")
  If ID == ""
    Return "保留当前皮肤"
  EndIf
  If Self.HasBCNGSkinAPI()
    String Label = BCNGPSQBridge.GetSkinName(ID)
    If Label != ""
      Return Label
    EndIf
  EndIf
  Return "已选皮肤暂不可用"
EndFunction

Bool Function SetBCNGTransformSkin(String ID)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.SaveBodyChangeSkinChoice(False, False, ID)
  EndIf
  If ID != "" && (!Self.HasBCNGSkinAPI() || BCNGPSQBridge.GetSkinName(ID) == "")
    Debug.Notification("请启用 Body Change NG 1.3.8 及对应的 PSQ 接口补丁。")
    Return False
  EndIf
  storageutil.SetStringValue(Self, "PSQ_BCNGTransformSkin", ID)
  storageutil.UnsetIntValue(Self, "PSQ_BCNGSkinManualTakeover")
  Self.QueueBCNGTransformSkin()
  Debug.Notification("变身皮肤已保存，关闭菜单后应用。")
  Return True
EndFunction

Function ForgetBCNGTransformSkin()
  storageutil.UnsetIntValue(Self, "PSQ_BCNGSkinOwned")
  storageutil.UnsetStringValue(Self, "PSQ_BCNGSkinOriginal")
  storageutil.UnsetIntValue(Self, "PSQ_BCNGSkinOriginalMode")
  storageutil.UnsetStringValue(Self, "PSQ_BCNGSkinApplied")
EndFunction

Bool Function RestoreBCNGTransformSkin()
  If storageutil.GetIntValue(Self, "PSQ_BCNGSkinOwned", 0) != 1
    Return True
  EndIf
  If !Self.HasBCNGSkinAPI()
    Return False
  EndIf
  Int Result = BCNGPSQBridge.RestoreSkinSelection(PlayerRef, storageutil.GetStringValue(Self, "PSQ_BCNGSkinApplied", ""), storageutil.GetStringValue(Self, "PSQ_BCNGSkinOriginal", ""), storageutil.GetIntValue(Self, "PSQ_BCNGSkinOriginalMode", 0))
  If Result == 1 || Result == 2
    Self.ForgetBCNGTransformSkin()
    If Result == 2
      storageutil.SetIntValue(Self, "PSQ_BCNGSkinManualTakeover", 1)
    EndIf
    Return True
  EndIf
  Return False
EndFunction

Function QueueBCNGTransformSkin()
  If PlayerRef == None
    Return
  EndIf
  If storageutil.GetStringValue(Self, "PSQ_BCNGTransformSkin", "") == "" && storageutil.GetIntValue(Self, "PSQ_BCNGSkinOwned", 0) != 1
    Return
  EndIf
  Int Ticket = storageutil.GetIntValue(Self, "PSQ_BCNGSkinTicket", 0) + 1
  storageutil.SetIntValue(Self, "PSQ_BCNGSkinTicket", Ticket)
  Self.RegisterForModEvent("PSQ_BCNGTransformSkin", "OnPSQBCNGTransformSkin")
  Self.SendModEvent("PSQ_BCNGTransformSkin", Ticket as String, PSQLoadEpoch as Float)
EndFunction

Function OnPSQBCNGTransformSkin(String EventName, String Argument, Float Number, Form Sender)
  Int Ticket = Argument as Int
  Utility.Wait(0.2)
  Int Attempt = 0
  Bool NativePolicy = SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
  Bool Requested = False
  While Attempt < 12
    If Ticket != storageutil.GetIntValue(Self, "PSQ_BCNGSkinTicket", 0) || Number as Int != PSQLoadEpoch
      Return
    EndIf
    If !Self.HasBCNGSkinAPI()
      Return
    EndIf
    Bool GeometryReady = False
    If NativePolicy
      GeometryReady = PSQAppearance.SkinReady34(Self, PlayerRef, False)
    Else
      GeometryReady = !AppearanceEditBusy && !IsHenshinchu && !BodySelectionRefreshBusy && PlayerRef.Is3DLoaded()
    EndIf
    If GeometryReady
      String Wanted = storageutil.GetStringValue(Self, "PSQ_BCNGTransformSkin", "")
      Bool RestoreSkinNow = False
      If NativePolicy
        RestoreSkinNow = PSQAppearance.SkinRestore34(Self, Wanted, psqracecompatibility.GetMode(PlayerRef))
      Else
        RestoreSkinNow = !IsHenshined || Wanted == "" || UninstallPrepared || UninstallCleanupBusy || psqracecompatibility.GetMode(PlayerRef) == 1
      EndIf
      If RestoreSkinNow
        Bool Restored = Self.RestoreBCNGTransformSkin()
        If Restored && !IsHenshined
          storageutil.UnsetIntValue(Self, "PSQ_BCNGSkinManualTakeover")
        EndIf
        Return
      EndIf
      If storageutil.GetIntValue(Self, "PSQ_BCNGSkinManualTakeover", 0) == 1
        Return
      EndIf
      Bool Owns = storageutil.GetIntValue(Self, "PSQ_BCNGSkinOwned", 0) == 1
      String Current = BCNGPSQBridge.GetSkinSelectionId(PlayerRef)
      Int Mode = BCNGPSQBridge.GetSkinSelectionMode(PlayerRef)
      If Owns
        String Applied = storageutil.GetStringValue(Self, "PSQ_BCNGSkinApplied", "")
        Bool Matching = False
        If NativePolicy
          Matching = PSQAppearance.SkinMatches34(False, Current, Mode, Applied)
        Else
          Matching = Current == Applied && Mode == 2
        EndIf
        If !Matching
          Self.ForgetBCNGTransformSkin()
          storageutil.SetIntValue(Self, "PSQ_BCNGSkinManualTakeover", 1)
          Return
        EndIf
        If Current == Wanted && BCNGPSQBridge.GetSkinApplicationState(PlayerRef, Wanted) == 1
          Return
        EndIf
      Else
        storageutil.SetStringValue(Self, "PSQ_BCNGSkinOriginal", Current)
        storageutil.SetIntValue(Self, "PSQ_BCNGSkinOriginalMode", Mode)
      EndIf
      If !Requested
        If Ticket != storageutil.GetIntValue(Self, "PSQ_BCNGSkinTicket", 0) || Number as Int != PSQLoadEpoch
          Return
        EndIf
        Int Accepted = BCNGPSQBridge.RequestSkin(PlayerRef, Wanted)
        If Accepted != 1
          If !Owns
            Self.ForgetBCNGTransformSkin()
          EndIf
          Debug.Notification("变身皮肤请求未被接受，当前皮肤和恢复记录已保留。")
          Return
        EndIf
        storageutil.SetIntValue(Self, "PSQ_BCNGSkinOwned", 1)
        storageutil.SetStringValue(Self, "PSQ_BCNGSkinApplied", Wanted)
        Requested = True
      EndIf
    EndIf
    Attempt += 1
    Utility.Wait(0.2)
  EndWhile
EndFunction

Function EnsurePlannedTransformEquipment(Armor Item, Int Owner, Bool RequireBusy)
  Self.EnsurePlannedEntryPart(Item, Owner, RequireBusy, None)
EndFunction

Function EnsurePlannedEntryPart(Armor Item, Int Owner, Bool RequireBusy, Float[] Samples)
  Int EntryLoad = PSQLoadEpoch
  If EntryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
    Return
  EndIf
  If Item == None || PlayerRef == None
    Return
  EndIf
  ; Only exact membership in the same load/race/body plan avoids re-resolving
  ; catalog IDs. Other callers retain the original final body-type validation.
  Bool FromPlan = Self.IsEquipmentSwapPlanCurrent(Owner, RequireBusy) && storageutil.FormListFind(Self, "PSQ_EquipPlanParts", Item) >= 0
  If !FromPlan && Self.ResolveTransformEquipmentItem(Item, PSQDXUBE.GetItemPart(Item)) != Item
    Return
  EndIf
  Self.EquipResolvedEntryPart(Item, Owner, RequireBusy, EntryLoad, Samples)
EndFunction
Bool Function IsEquipmentSwapPlanCurrent(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777247 && PSQAppearance.ReadPlanState31(PlayerRef,Self,Owner,PSQLoadEpoch,RequireBusy) >= 0
    Return True
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777219
    Int LoadEpoch = PSQLoadEpoch
    If Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
      Return False
    EndIf
    If storageutil.GetIntValue(Self, "PSQ_EquipPlanOwner", -1) != Owner || storageutil.GetIntValue(Self, "PSQ_EquipPlanLoad", -1) != LoadEpoch
      Return False
    EndIf
    Race PlannedRace = storageutil.GetFormValue(Self, "PSQ_EquipPlanRace", None) as Race
    Int PlannedBody = storageutil.GetIntValue(Self, "PSQ_EquipPlanUBE", -1)
    Int Match = PSQAppearance.CheckEquipmentContext(PlayerRef, PlayerAppearanceRace, PlannedRace, PlannedBody)
    ; The batch can yield. Never use its result after load/cancellation.
    If Owner != AppearanceOperationId || LoadEpoch != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
      Return False
    EndIf
    If Match >= 0
      Return Match == 1
    EndIf
  EndIf
  Return Self.IsAppearanceOperationCurrent(Owner, RequireBusy) && storageutil.GetIntValue(Self, "PSQ_EquipPlanOwner", -1) == Owner && storageutil.GetIntValue(Self, "PSQ_EquipPlanLoad", -1) == PSQLoadEpoch && storageutil.GetFormValue(Self, "PSQ_EquipPlanRace", None) == PlayerRef.GetRace() && storageutil.GetIntValue(Self, "PSQ_EquipPlanUBE", -1) == (psqracecompatibility.IsUBEActor(PlayerRef) as Int)
EndFunction

Function ClearEquipmentSwapPlan()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777247
    PSQAppearance.InvalidatePlan31()
  EndIf
  storageutil.UnsetIntValue(Self, "PSQ_EquipPlanOwner")
  storageutil.UnsetIntValue(Self, "PSQ_EquipPlanHide")
  storageutil.UnsetIntValue(Self, "PSQ_EquipPlanLoad")
  storageutil.UnsetFormValue(Self, "PSQ_EquipPlanRace")
  storageutil.UnsetIntValue(Self, "PSQ_EquipPlanUBE")
  storageutil.FormListClear(Self, "PSQ_EquipPlanParts")
  storageutil.FormListClear(Self, "PSQ_EquipPlanStrip")
EndFunction

Bool Function BuildEquipmentSwapPlan28(Form[] Originals, Form[] Protected, Int Owner, Bool RequireBusy)
  Int ApiVersion = SKSE.GetPluginVersion("PSQ Appearance")
  If ApiVersion < 16777244
    Return Self.BuildEquipmentSwapPlan(Originals, Protected, Owner, RequireBusy)
  EndIf
  Int Epoch = PSQLoadEpoch
  If Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  Bool Detailed = EnableEquipmentDiagnostics
  Float Started
  Float Prepared
  Float PolicyFinished
  If Detailed
    Started = Utility.GetCurrentRealTime()
  EndIf
  Race PlannedRace = PlayerRef.GetRace()
  Int Family
  Bool PreserveBody
  Bool PreserveHead = True
  Bool BatchedPolicy = False
  If ApiVersion >= 16777245
    Int Mode = storageutil.GetIntValue(PlayerRef, "PSQ_RaceAppearanceMode", 0)
    Int[] Policy = PSQAppearance.ReadOutfitPolicy29(PlayerRef, Self, PlayerAppearanceRace, PlannedRace, Owner, Epoch, RequireBusy, Mode)
    If Policy && Policy.Length == 3
      Family = Policy[0]
      PreserveBody = Policy[1] != 0
      PreserveHead = !HenshinHair || Policy[2] != 0
      BatchedPolicy = True
    EndIf
  EndIf
  If !BatchedPolicy
    ; Keep the scripted race classifier for unusual leveled bases, light UBE plugins and earlier DLLs.
    If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, Epoch) || PlayerRef.GetRace() != PlannedRace
      Return False
    EndIf
    Family = psqracecompatibility.IsUBEActor(PlayerRef) as Int
    PreserveBody = psqracecompatibility.ShouldPreserveAppearance(PlayerRef)
    If HenshinHair
      PreserveHead = psqracecompatibility.ShouldPreserveHeadAppearance(PlayerRef)
    EndIf
  EndIf
  If Detailed
    PolicyFinished = Utility.GetCurrentRealTime()
  EndIf
  Bool Hide = Self.GetOriginalEquipmentHideEnabled()
  Form[] Packet = PSQAppearance.PrepareOutfitPlan28(PlayerRef, Self, PlannedRace, Owner, Epoch, RequireBusy, Originals, Protected, PreserveBody, PreserveHead, Hide, Family)
  If Owner != AppearanceOperationId || Epoch != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  If !Packet || Packet.Length == 0
    If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, Epoch) || PlayerRef.GetRace() != PlannedRace || (psqracecompatibility.IsUBEActor(PlayerRef) as Int) != Family
      Return False
    EndIf
    Bool Result = Self.BuildEquipmentSwapPlanLegacy29(Originals, Protected, Owner, RequireBusy, Epoch, PlannedRace, Family)
    If Detailed
      Debug.Trace("[PSQ-PERF] outfit.plan28; owner=" + Owner + "; route=fallback; result=" + Result + "; totalSeconds=" + (Utility.GetCurrentRealTime() - Started))
    EndIf
    Return Result
  EndIf
  If ApiVersion >= 16777247 && BatchedPolicy
    Int Publish = PSQAppearance.PublishPlan31(PlayerRef,Self,PlannedRace,Owner,Epoch,RequireBusy,Family,Hide,Packet)
    Return Self.WaitAppearanceReceipt27(Publish,Owner,Epoch) == 1
  EndIf
  Int Split = Packet.Find(None)
  If Split < 0 || Split > 6
    Return False
  EndIf
  Form[] Selected = PSQAppearance.OutfitPlanSection28(Packet, False)
  Form[] Strip = PSQAppearance.OutfitPlanSection28(Packet, True)
  If Selected.Length != Split || Strip.Length != Packet.Length - Split - 1
    Return False
  EndIf
  If Detailed
    Prepared = Utility.GetCurrentRealTime()
  EndIf
  Int ContextRoute = 28
  If BatchedPolicy
    ContextRoute = 29
  EndIf
  If !Self.PublishOutfitPlan29(Selected, Strip, Owner, RequireBusy, Epoch, PlannedRace, Family, Hide, ContextRoute)
    Return False
  EndIf
  If Detailed
    Float Finished = Utility.GetCurrentRealTime()
    Debug.Trace("[PSQ-PERF] outfit.plan28; owner=" + Owner + "; route=native; family=" + Family + "; originals=" + Originals.Length + "; selected=" + Selected.Length + "; manualStrip=" + Strip.Length + "; batchedPolicy=" + BatchedPolicy + "; policySeconds=" + (PolicyFinished - Started) + "; planAndSplitSeconds=" + (Prepared - PolicyFinished) + "; prepareSeconds=" + (Prepared - Started) + "; publishSeconds=" + (Finished - Prepared) + "; totalSeconds=" + (Finished - Started))
  EndIf
  Return True
EndFunction

Bool Function IsOutfitPublicationCurrent29(Int Owner, Bool RequireBusy, Int Epoch, Race PlannedRace, Int Family, Int ContextRoute)
  If PlayerRef == None || PlannedRace == None || Owner != AppearanceOperationId || Epoch != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  If ContextRoute == 29
    If !PSQAppearance.IsOutfitPlanCurrent29(PlayerRef, Self, PlayerAppearanceRace, PlannedRace, Owner, Epoch, RequireBusy, Family)
      Return False
    EndIf
  ElseIf ContextRoute == 28
    If PSQAppearance.CheckEquipmentContext(PlayerRef, PlayerAppearanceRace, PlannedRace, Family) != 1 || !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, Epoch)
      Return False
    EndIf
  Else
    If PlayerRef.GetRace() != PlannedRace || (psqracecompatibility.IsUBEActor(PlayerRef) as Int) != Family || !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, Epoch)
      Return False
    EndIf
  EndIf
  Return Owner == AppearanceOperationId && Epoch == PSQLoadEpoch && (!RequireBusy || AppearanceEditBusy) && (PlayerAppearanceRace == None || PlayerAppearanceRace == PlannedRace)
EndFunction

Bool Function PublishOutfitPlan29(Form[] Selected, Form[] Strip, Int Owner, Bool RequireBusy, Int Epoch, Race PlannedRace, Int Family, Bool Hide, Int ContextRoute)
  If !Self.IsOutfitPublicationCurrent29(Owner, RequireBusy, Epoch, PlannedRace, Family, ContextRoute) || Owner != AppearanceOperationId || Epoch != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777247
    PSQAppearance.InvalidatePlan31()
  EndIf
  ; StorageUtil is the existing save contract. Invalidate first and publish the
  ; owner last so a failed copy or interrupted build cannot expose a partial plan.
  storageutil.UnsetIntValue(Self, "PSQ_EquipPlanOwner")
  If Owner != AppearanceOperationId || Epoch != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  If Selected && Selected.Length > 0
    If !storageutil.FormListCopy(Self, "PSQ_EquipPlanParts", Selected)
      Return False
    EndIf
  Else
    storageutil.FormListClear(Self, "PSQ_EquipPlanParts")
  EndIf
  If Owner != AppearanceOperationId || Epoch != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  If Strip && Strip.Length > 0
    If !storageutil.FormListCopy(Self, "PSQ_EquipPlanStrip", Strip)
      Return False
    EndIf
  Else
    storageutil.FormListClear(Self, "PSQ_EquipPlanStrip")
  EndIf
  If Owner != AppearanceOperationId || Epoch != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  storageutil.SetIntValue(Self, "PSQ_EquipPlanHide", Hide as Int)
  If Owner != AppearanceOperationId || Epoch != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  storageutil.SetIntValue(Self, "PSQ_EquipPlanLoad", Epoch)
  If Owner != AppearanceOperationId || Epoch != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  storageutil.SetFormValue(Self, "PSQ_EquipPlanRace", PlannedRace)
  If Owner != AppearanceOperationId || Epoch != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  storageutil.SetIntValue(Self, "PSQ_EquipPlanUBE", Family)
  If !Self.IsOutfitPublicationCurrent29(Owner, RequireBusy, Epoch, PlannedRace, Family, ContextRoute) || Owner != AppearanceOperationId || Epoch != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  storageutil.SetIntValue(Self, "PSQ_EquipPlanOwner", Owner)
  Return Owner == AppearanceOperationId && Epoch == PSQLoadEpoch && (!RequireBusy || AppearanceEditBusy)
EndFunction

Bool Function BuildEquipmentSwapPlan(Form[] Originals, Form[] Protected, Int Owner, Bool RequireBusy)
  Int PlanEpoch = PSQLoadEpoch
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, PlanEpoch) || !PlayerRef
    Return False
  EndIf
  Race PlannedRace = PlayerRef.GetRace()
  Int Family = psqracecompatibility.IsUBEActor(PlayerRef) as Int
  Return Self.BuildEquipmentSwapPlanLegacy29(Originals, Protected, Owner, RequireBusy, PlanEpoch, PlannedRace, Family)
EndFunction

Bool Function BuildEquipmentSwapPlanLegacy29(Form[] Originals, Form[] Protected, Int Owner, Bool RequireBusy, Int PlanEpoch, Race PlannedRace, Int Family)
  If !Self.IsOutfitPublicationCurrent29(Owner, RequireBusy, PlanEpoch, PlannedRace, Family, 0)
    Return False
  EndIf
  Armor DXCuirass = Self.ResolveTransformEquipmentItem(PSQSuccubusCuirass, 0)
  Armor DXBoots = Self.ResolveTransformEquipmentItem(PSQSuccubusBoots, 1)
  Armor DXGloves = Self.ResolveTransformEquipmentItem(PSQSuccubusGauntlets, 2)
  Armor DXHorns = Self.ResolveTransformEquipmentItem(PSQSuccubusHorns, 3)
  Armor DXTail = Self.ResolveTransformEquipmentItem(PSQSuccubusTail, 4)
  Armor DXWings = Self.ResolveTransformEquipmentItem(PSQSuccubusWings, 5)
  If !Self.IsOutfitPublicationCurrent29(Owner, RequireBusy, PlanEpoch, PlannedRace, Family, 0) || Owner != AppearanceOperationId || PlanEpoch != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  PSQSuccubusCuirass = DXCuirass
  PSQSuccubusBoots = DXBoots
  PSQSuccubusGauntlets = DXGloves
  PSQSuccubusHorns = DXHorns
  PSQSuccubusTail = DXTail
  PSQSuccubusWings = DXWings
  Armor[] Parts = new Armor[6]
  Parts[0] = PSQSuccubusBoots
  Parts[1] = PSQSuccubusCuirass
  Parts[2] = PSQSuccubusGauntlets
  Parts[3] = PSQSuccubusHorns
  Parts[4] = PSQSuccubusWings
  Parts[5] = PSQSuccubusTail
  Bool PreserveBody = psqracecompatibility.ShouldPreserveAppearance(PlayerRef)
  Bool[] Enabled = new Bool[6]
  Enabled[0] = HenshinBoots && (!PreserveBody || PSQDXUBE.SupportsItem(PlayerRef, Parts[0]))
  Enabled[1] = HenshinCuirass && (!PreserveBody || PSQDXUBE.SupportsItem(PlayerRef, Parts[1]))
  Enabled[2] = HenshinGloves && (!PreserveBody || PSQDXUBE.SupportsItem(PlayerRef, Parts[2]))
  Enabled[3] = HenshinHorn && Parts[3] != None
  Enabled[4] = HenshinWings && Parts[4] != None
  Enabled[5] = HenshinTail && Parts[5] != None
  Bool ReplaceCuirass = Enabled[1]
  Bool ReplaceHeadgear = ReplaceCuirass || Enabled[3] || (HenshinHair && !psqracecompatibility.ShouldPreserveHeadAppearance(PlayerRef))
  Bool HideAccessories = Self.GetOriginalEquipmentHideEnabled() && Self.HasPSQAppearanceAPI()
  Bool CountAutomatic = EnableEquipmentDiagnostics
  Int Count = 0
  Int i = 0
  Int StripCount = 0
  Int Automatic = 0
  Form[] Selected
  Form[] Strip
  Int[] Difference
  Float DifferenceStart
  If CountAutomatic
    DifferenceStart = Utility.GetCurrentRealTime()
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777220
    Difference = PSQAppearance.PlanOutfitDifference(Parts, Enabled, Originals, Protected, ReplaceHeadgear, HideAccessories, CountAutomatic)
  EndIf
  Bool NativePlan = Difference && Difference.Length >= 3
  If NativePlan
    Count = Difference[0]
    StripCount = Difference[1]
    Automatic = Difference[2]
    NativePlan = Count >= 0 && Count <= 6 && StripCount >= 0 && StripCount <= Originals.Length && Difference.Length == 3 + Count + StripCount
  EndIf
  If !NativePlan
    Count = 0
    StripCount = 0
    Automatic = 0
    Selected = new Form[6]
    Strip = Utility.CreateFormArray(Originals.Length, None)
    Int RawMask = 0
    While i < 6
      Armor Item = Parts[i]
      If Enabled[i] && Item != None && Selected.find(Item, 0) < 0 && Protected.find(Item, 0) < 0
        Selected[Count] = Item
        Count += 1
        RawMask = Math.LogicalOr(RawMask, Item.GetSlotMask())
      EndIf
      i += 1
    EndWhile
    Int ConflictMask = Math.LogicalAnd(RawMask, 2142189872)
    i = 0
    While i < Originals.Length
      Armor Item = Originals[i] as Armor
      If Item != None && Originals.find(Item, 0) == i && Selected.find(Item, 0) < 0 && Protected.find(Item, 0) < 0
        Int Mask = Item.GetSlotMask()
        ; With hidden accessories, only head/body/hands/feet can enter the
        ; manual strip list. Other slots stay equipped or displace naturally.
        ; Diagnostics still classify them to report automatic conflicts.
        If !HideAccessories || CountAutomatic || Math.LogicalAnd(Mask, 6287) != 0
          Bool HeadMustStrip = ReplaceHeadgear && Math.LogicalAnd(Mask, 6147) != 0
          Bool NeedsStrip = HeadMustStrip || Math.LogicalAnd(Mask, ConflictMask) != 0
          If !NeedsStrip && ReplaceCuirass && Math.LogicalAnd(Mask, 2142222640) != 0
            Int Kind = Item.GetWeightClass()
            NeedsStrip = Kind == 0 || Kind == 1
          EndIf
          If NeedsStrip
            If !HeadMustStrip && Math.LogicalAnd(Mask, RawMask) != 0
              ; The selected armor displaces this exact slot conflict itself.
              Automatic += 1
            ElseIf !HideAccessories || Math.LogicalAnd(Mask, 6287) != 0
              ; Hidden accessories remain worn: do not revisit them in the strip pass.
              Strip[StripCount] = Item
              StripCount += 1
            EndIf
          EndIf
        EndIf
      EndIf
      i += 1
    EndWhile
  EndIf
  If Owner != AppearanceOperationId || PlanEpoch != PSQLoadEpoch || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  ; Finish both arrays locally before the one owner-gated publication point.
  Form[] Compact
  Form[] CompactStrip
  If Count > 0
    If NativePlan && SKSE.GetPluginVersion("PSQ Appearance") >= 16777226
      Compact = PSQAppearance.ProjectPlanForms(Parts, Originals, Difference, False)
    EndIf
    If !Compact || Compact.Length != Count
      Compact = Utility.CreateFormArray(Count, None)
      i = 0
      While i < Count
        If NativePlan
          Compact[i] = Parts[Difference[3 + i]]
        Else
          Compact[i] = Selected[i]
        EndIf
        i += 1
      EndWhile
    EndIf
    If !Compact || Compact.Length != Count || Compact.Find(None) >= 0
      Return False
    EndIf
  EndIf
  If StripCount > 0
    If NativePlan && SKSE.GetPluginVersion("PSQ Appearance") >= 16777226
      CompactStrip = PSQAppearance.ProjectPlanForms(Parts, Originals, Difference, True)
    EndIf
    If !CompactStrip || CompactStrip.Length != StripCount
      CompactStrip = Utility.CreateFormArray(StripCount, None)
      i = 0
      While i < StripCount
        If NativePlan
          CompactStrip[i] = Originals[Difference[3 + Count + i]]
        Else
          CompactStrip[i] = Strip[i]
        EndIf
        i += 1
      EndWhile
    EndIf
    If !CompactStrip || CompactStrip.Length != StripCount || CompactStrip.Find(None) >= 0
      Return False
    EndIf
  EndIf
  If !Self.PublishOutfitPlan29(Compact, CompactStrip, Owner, RequireBusy, PlanEpoch, PlannedRace, Family, HideAccessories, 0)
    Return False
  EndIf
  If CountAutomatic
    Debug.Trace("[PSQ-EQUIP] plan; originals=" + Originals.Length + "; manualStrip=" + StripCount + "; automaticConflicts=" + Automatic + "; selected=" + Count + "; nativePlan=" + NativePlan + "; planAndPublishSeconds=" + (Utility.GetCurrentRealTime() - DifferenceStart))
  EndIf
  Return True
EndFunction

Bool Function HasPSQAppearanceAPI()
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777217
    Return False
  EndIf
  Return PSQAppearance.GetVersion() >= 1 && PSQAppearance.IsReady()
EndFunction

Bool Function GetOriginalEquipmentHideEnabled()
  Return storageutil.GetIntValue(Self, "PSQ_HideOriginalAccessories", 1) == 1
EndFunction

Function SetOriginalEquipmentHideEnabled(Bool Enabled)
  storageutil.SetIntValue(Self, "PSQ_HideOriginalAccessories", Enabled as Int)
  Self.QueueOriginalEquipmentVisibility()
EndFunction

Bool Function CanHideOriginalAccessory(Armor Item)
  If Item == None || !Self.GetOriginalEquipmentHideEnabled() || !Self.HasPSQAppearanceAPI()
    Return False
  EndIf
  ; Preserve body/hand/foot skin and headgear/hair-suppression rules.
  Return Math.LogicalAnd(Item.GetSlotMask(), 6287) == 0
EndFunction

Function RestoreOriginalEquipmentVisibility()
  If Self.HasPSQAppearanceAPI()
    PSQAppearance.Restore()
  EndIf
EndFunction

Function ResumeLoadedAccessoryVisibility(Int LoadEpoch)
  ; Native scene nodes were discarded on load. Reuse the saved human outfit
  ; after race and interrupted-operation recovery have classified this load.
  If LoadEpoch != PSQLoadEpoch || PlayerRef == None || OrgArmorList == None || !IsHenshined || AppearanceRecoveryPending || IsHenshinchu || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  If !Self.GetOriginalEquipmentHideEnabled() || LoadEpoch != PSQLoadEpoch
    Return
  EndIf
  If PlayerRef.Is3DLoaded() && LoadEpoch == PSQLoadEpoch && IsHenshined && !AppearanceRecoveryPending && !AppearanceEditBusy && !BodySelectionRefreshBusy
    Self.ApplyOriginalEquipmentVisibility()
  EndIf
  ; The body preset or another outfit may replace these nodes later. Restart
  ; the existing visibility worker even if the player had no 3D on this pass.
  If LoadEpoch == PSQLoadEpoch && IsHenshined && !AppearanceRecoveryPending && !IsHenshinchu && !UninstallPrepared && !UninstallCleanupBusy
    Self.QueueOriginalEquipmentVisibility()
  EndIf
EndFunction

Function ApplyOriginalEquipmentVisibility()
  Int Owner = AppearanceOperationId
  Int LoadEpoch = PSQLoadEpoch
  If !Self.HasPSQAppearanceAPI()
    Return
  EndIf
  Bool Enabled = Self.GetOriginalEquipmentHideEnabled()
  If LoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId
    Return
  EndIf
  If !Enabled || UninstallPrepared || UninstallCleanupBusy
    PSQAppearance.Restore()
    Return
  EndIf
  ; Recheck after the yielding setting query. A worker that started before
  ; DisHenshin must not restore accessories in the middle of its exit.
  If !IsHenshined
    If !AppearanceEditBusy && !IsHenshinchu && !BodySelectionRefreshBusy
      PSQAppearance.Restore()
    EndIf
    Return
  EndIf
  If AppearanceRecoveryPending || (AppearanceEditBusy && AppearanceTransformDirection == 2)
    Return
  EndIf
  Form[] Selected = new Form[6]
  Selected[0] = PSQSuccubusCuirass
  Selected[1] = PSQSuccubusBoots
  Selected[2] = PSQSuccubusGauntlets
  Selected[3] = PSQSuccubusHorns
  Selected[4] = PSQSuccubusWings
  Selected[5] = PSQSuccubusTail
  Form[] Existing = Self.GetTransformProtectedArmor()
  Form[] Protected = Utility.CreateFormArray(Existing.Length + 1, None)
  Int i = 0
  While i < Existing.Length
    Protected[i] = Existing[i]
    i += 1
  EndWhile
  Protected[Existing.Length] = storageutil.GetFormValue(PlayerRef, "PSQ_TRXFutaItem", None)
  Form[] Originals = OrgArmorList.ToArray()
  ; A disable/cleanup worker can finish while these arrays are being built.
  ; Never let the older request hide equipment again after that cleanup.
  If !Self.GetOriginalEquipmentHideEnabled()
    Return
  EndIf
  If Owner != AppearanceOperationId || LoadEpoch != PSQLoadEpoch || !IsHenshined || AppearanceRecoveryPending || UninstallPrepared || UninstallCleanupBusy || (AppearanceEditBusy && AppearanceTransformDirection == 2)
    Return
  EndIf
  PSQAppearance.SetHidden(PlayerRef, Originals, Protected, Selected)
EndFunction

Function QueueOriginalEquipmentVisibility()
  Int LoadEpoch = PSQLoadEpoch
  If !Self.HasPSQAppearanceAPI() || LoadEpoch != PSQLoadEpoch
    Return
  EndIf
  Int Ticket = storageutil.GetIntValue(Self, "PSQ_VisibilityTicket", 0) + 1
  If LoadEpoch != PSQLoadEpoch
    Return
  EndIf
  storageutil.SetIntValue(Self, "PSQ_VisibilityTicket", Ticket)
  Self.RegisterForModEvent("PSQ_AccessoryVisibility", "OnPSQAccessoryVisibility")
  If LoadEpoch == PSQLoadEpoch
    Self.SendModEvent("PSQ_AccessoryVisibility", Ticket as String, LoadEpoch as Float)
  EndIf
EndFunction

; Transformed saves can have this legacy frame suspended at Utility.Wait.
; Keep its original bytecode so it can resume and retire on the old epoch.
Function OnPSQOriginalEquipmentVisibility(String EventName, String Argument, Float Number, Form Sender)
  Int Ticket = Argument as Int
  If Sender != Self || Number as Int != PSQLoadEpoch
    Return
  EndIf
  While Ticket == storageutil.GetIntValue(Self, "PSQ_VisibilityTicket", 0) && Number as Int == PSQLoadEpoch
    If !Self.HasPSQAppearanceAPI()
      Return
    EndIf
    ; Forced cleanup and an explicit hide-disable still release immediately.
    If !Self.GetOriginalEquipmentHideEnabled() || UninstallPrepared || UninstallCleanupBusy
      Self.RestoreOriginalEquipmentVisibility()
      Return
    EndIf
    If !AppearanceEditBusy && !IsHenshinchu && !BodySelectionRefreshBusy
      ; DisHenshin changes IsHenshined before restoring the primary outfit.
      ; Its equipment phase owns the release while the operation is busy.
      If !IsHenshined
        Self.RestoreOriginalEquipmentVisibility()
        Return
      EndIf
      Self.ApplyOriginalEquipmentVisibility()
    EndIf
    Utility.Wait(0.75)
  EndWhile
EndFunction

Function OnPSQAccessoryVisibility(String EventName, String Argument, Float Number, Form Sender)
  Int Ticket = Argument as Int
  If Sender != Self || Number as Int != PSQLoadEpoch
    Return
  EndIf
  While Ticket == storageutil.GetIntValue(Self, "PSQ_VisibilityTicket", 0) && Number as Int == PSQLoadEpoch
    If !Self.HasPSQAppearanceAPI()
      Return
    EndIf
    Bool Enabled = Self.GetOriginalEquipmentHideEnabled()
    If Number as Int != PSQLoadEpoch || Ticket != storageutil.GetIntValue(Self, "PSQ_VisibilityTicket", 0)
      Return
    EndIf
    ; Forced cleanup and an explicit hide-disable still release immediately.
    If !Enabled || UninstallPrepared || UninstallCleanupBusy
      Self.RestoreOriginalEquipmentVisibility()
      Return
    EndIf
    If AppearanceRecoveryPending
      Return
    EndIf
    If !AppearanceEditBusy && !IsHenshinchu && !BodySelectionRefreshBusy
      ; DisHenshin changes IsHenshined before restoring the primary outfit.
      ; Its equipment phase owns the release while the operation is busy.
      If !IsHenshined
        Self.RestoreOriginalEquipmentVisibility()
        Return
      EndIf
      Self.ApplyOriginalEquipmentVisibility()
    EndIf
    Utility.Wait(0.75)
  EndWhile
EndFunction


Bool Function CanUseTransformOutfitChoice(Int Part, Int Choice)
  Return Self.CanUseTransformOutfitChoice38(Part, Choice)
EndFunction

Bool Function IsBodyIndependentTransformWing(Armor Item)
  If Item == None
    Return False
  EndIf
  Return Item == SuccubusDragonWingsCommon || Item == SuccubusDragonWingsBoss || Item == SuccubusDragonWingsForest || Item == SuccubusDragonWingOdaviing || Item == SuccubusDragonWingsParthurnax || Item == SuccubusDragonWingsSnow || Item == SuccubusDragonWingsTundra || Item == SuccubusDragonWingsUnderskin || Item == SuccubusDragonWingsAlduin || Item == SuccubusDragonWingsBloody || Item == SuccubusFairyWings
EndFunction

Armor Function ResolveTransformEquipmentItem(Armor Item, Int Part)
  Return Self.ResolveTransformEquipmentItem39(Item, Part)
EndFunction

Float[] Function CaptureTransformPoolValues()
  ; One fresh main-thread read. No cache across frames, loads or actors.
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777219
    Float[] NativeValues = PSQAppearance.ReadPoolValues(PlayerRef)
    If NativeValues && NativeValues.Length == 6
      Return NativeValues
    EndIf
  EndIf
  Float[] Values = new Float[6]
  Values[0] = PlayerRef.GetAV("Health")
  Values[1] = PlayerRef.GetAV("Magicka")
  Values[2] = PlayerRef.GetAV("Stamina")
  Values[3] = PlayerRef.GetAVMax("Health")
  Values[4] = PlayerRef.GetAVMax("Magicka")
  Values[5] = PlayerRef.GetAVMax("Stamina")
  Return Values
EndFunction

Bool Function TryRestoreTransformOriginalCore(Armor Item, Form[] Protected, Int Owner, Bool RequireBusy, Bool CheckSlots)
  Int LoadEpoch = PSQLoadEpoch
  Return Self.TryRestoreOriginalForLoad(Item, Protected, Owner, RequireBusy, CheckSlots, LoadEpoch)
EndFunction

Function CaptureOriginalTransformHair(Int Owner)
  ; Take the snapshot while still human, before clothing or Body Change can
  ; rebuild the head. A previous interrupted exit may already own a snapshot.
  If OrgHair != None || SuccubusHairSelection <= 0 || IsHenshined
    Return
  EndIf
  HeadPart Selected = Self.GetTransformHairChoice(SuccubusHairSelection, Owner, True)
  If Selected == None || psqracecompatibility.ShouldPreserveHeadAppearance(PlayerRef)
    Return
  EndIf
  If !psqracecompatibility.CanUseHeadPart(Selected, PlayerRef.GetRace())
    Return
  EndIf
  HeadPart Original = Self.GetCurrentPlayerHair()
  ; Matching hair needs no change. In an older affected save it may instead
  ; be a transform part left on the actor; never label that as a known original.
  If Original != None && Original != Selected && Self.IsAppearanceOperationCurrent(Owner, True) && OrgHair == None
    OrgHair = Original
  EndIf
EndFunction

Function EquipResolvedPlanItem(Armor Item, Int Owner, Bool RequireBusy, Int EntryLoad)
  Self.EquipResolvedEntryPart(Item, Owner, RequireBusy, EntryLoad, None)
EndFunction

Function EquipResolvedEntryPart(Armor Item, Int Owner, Bool RequireBusy, Int EntryLoad, Float[] Samples)
  Float GuardStart
  Float GuardEnd
  Bool Valid
  If Samples
    GuardStart = Utility.GetCurrentRealTime()
  EndIf
  Valid = Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, EntryLoad)
  If Samples
    GuardEnd = Utility.GetCurrentRealTime()
    Samples[0] += GuardEnd - GuardStart
    Samples[1] += 1.0
  EndIf
  If !Valid
    Return
  EndIf
  If !TransformInventoryLedgerReady
    Self.InitializeTransformEquipmentLedger(Owner, RequireBusy)
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777229
    Int Receipt = PSQAppearance.EquipLedgerPart(PlayerRef, Item, PlayerAppearanceRace, Self, Owner, EntryLoad, RequireBusy)
    If Receipt != 0
      Return
    EndIf
  EndIf
  Int Index = TransformInventoryItems.find(Item as Form, 0)
  Int[] ArmorStatus
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777221
    ArmorStatus = PSQAppearance.ReadArmorState(PlayerRef, Item)
  EndIf
  Bool Batched = ArmorStatus && ArmorStatus.Length == 2
  Bool Worn = False
  Int ExistingCount
  If Batched
    ExistingCount = ArmorStatus[0]
    Worn = ArmorStatus[1] == 1
  Else
    Worn = PlayerRef.IsEquipped(Item as Form)
  EndIf
  If Index >= 0 && Worn
    Return
  EndIf
  If !Batched
    ExistingCount = PlayerRef.GetItemCount(Item as Form)
  EndIf
  If Index < 0
    Index = TransformInventoryItems.find(None, 0)
    If Index < 0
      Debug.Trace("[PSQ-EQUIP] ledger full; skipped untracked equipment", 1)
      Return
    EndIf
    If Samples
      GuardStart = Utility.GetCurrentRealTime()
    EndIf
    Valid = Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, EntryLoad)
    If Samples
      GuardEnd = Utility.GetCurrentRealTime()
      Samples[0] += GuardEnd - GuardStart
      Samples[1] += 1.0
    EndIf
    If !Valid
      Return
    EndIf
    TransformInventoryItems[Index] = Item as Form
    ; Pure ledger write: the preceding full guard validated race; retain
    ; ownership here without another yielding actor query between fields.
    If EntryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
      Return
    EndIf
    TransformInventoryBaseline[Index] = ExistingCount
  EndIf
  If Worn
    Return
  EndIf
  If ExistingCount == 0
    If Samples
      GuardStart = Utility.GetCurrentRealTime()
    EndIf
    Valid = Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, EntryLoad)
    If Samples
      GuardEnd = Utility.GetCurrentRealTime()
      Samples[0] += GuardEnd - GuardStart
      Samples[1] += 1.0
    EndIf
    If !Valid
      Return
    EndIf
    PlayerRef.AddItem(Item as Form, 1, True)
    ExistingCount = PlayerRef.GetItemCount(Item as Form)
    If ExistingCount > 0
      ; AddItem has completed. Record its ownership before the next actor
      ; operation; a race change must not leave the added copy untracked.
      ; A replaced operation/load still owns its own ledger and must be spared.
      If EntryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
        Return
      EndIf
      TransformInventoryAdded[Index] = TransformInventoryAdded[Index] + 1
    EndIf
  EndIf
  If EntryLoad != PSQLoadEpoch || Owner != AppearanceOperationId
    Return
  EndIf
  If ExistingCount > 0
    If Samples
      GuardStart = Utility.GetCurrentRealTime()
    EndIf
    Valid = Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, EntryLoad)
    If Samples
      GuardEnd = Utility.GetCurrentRealTime()
      Samples[0] += GuardEnd - GuardStart
      Samples[1] += 1.0
    EndIf
    If !Valid
      Return
    EndIf
    If SKSE.GetPluginVersion("PSQ Appearance") >= 16777225
      Int Submitted = PSQAppearance.EquipTransformArmor(PlayerRef, Item, Self, PlayerAppearanceRace, Owner, EntryLoad, RequireBusy, False)
      If Submitted != 0
        Return
      EndIf
      If Samples
        GuardStart = Utility.GetCurrentRealTime()
      EndIf
      Valid = Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, EntryLoad)
      If Samples
        GuardEnd = Utility.GetCurrentRealTime()
        Samples[0] += GuardEnd - GuardStart
        Samples[1] += 1.0
      EndIf
      If !Valid
        Return
      EndIf
    EndIf
    PlayerRef.EquipItem(Item as Form, True, True)
  EndIf
EndFunction

Function ReleaseLedgerItemForLoad(Armor Item, Int Index, Int Owner, Bool RequireBusy, Int RecoveryLoad)
  If Index >= 0 && SKSE.GetPluginVersion("PSQ Appearance") >= 16777241
    PSQAppearance.ReleaseLedgerPart(PlayerRef,Item,PlayerAppearanceRace,Self,Owner,RecoveryLoad,RequireBusy,Index)
    Return
  EndIf
  If RecoveryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
    Return
  EndIf
  If Index >= 0 && TransformInventoryAdded[Index] > 0 && TransformInventoryBaseline[Index] == 0
    Int OwnedCount = PlayerRef.GetItemCount(Item as Form)
    If OwnedCount <= 0
      ; The temporary form has already left the inventory. No unequip or removal
      ; is possible, and this ledger must not claim a later independently acquired copy.
      If Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
        TransformInventoryAdded[Index] = 0
      EndIf
      Return
    EndIf
    If OwnedCount <= TransformInventoryAdded[Index]
      If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
        Return
      EndIf
      PlayerRef.RemoveItem(Item as Form, OwnedCount, True, None)
      Int RemovedOwned = OwnedCount - PlayerRef.GetItemCount(Item as Form)
      If RemovedOwned > 0
        ; The actor mutation already passed the full live-race guard.
        ; Record only the observed removal, without another actor read.
        ; A resumed old load/owner must never write to the new ledger.
        If RecoveryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
          Return
        EndIf
        TransformInventoryAdded[Index] = TransformInventoryAdded[Index] - RemovedOwned
      EndIf
      If RemovedOwned == OwnedCount
        Return
      EndIf
    EndIf
  EndIf
  If PlayerRef.IsEquipped(Item as Form)
    If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
      Return
    EndIf
    PlayerRef.UnequipItem(Item as Form, False, True)
  EndIf
  If Index < 0
    Return
  EndIf
  If TransformInventoryAdded[Index] <= 0
    Return
  EndIf
  Int Before = PlayerRef.GetItemCount(Item as Form)
  Int Count = Before - TransformInventoryBaseline[Index]
  If Count > TransformInventoryAdded[Index]
    Count = TransformInventoryAdded[Index]
  EndIf
  If Count > 0
    If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, RecoveryLoad)
      Return
    EndIf
    PlayerRef.RemoveItem(Item as Form, Count, True, None)
    Int Removed = Before - PlayerRef.GetItemCount(Item as Form)
    If Removed > 0
      ; The actor mutation already passed the full live-race guard.
      ; Record only the observed removal, without another actor read.
      ; A resumed old load/owner must never write to the new ledger.
      If RecoveryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
        Return
      EndIf
      TransformInventoryAdded[Index] = TransformInventoryAdded[Index] - Removed
    EndIf
  EndIf
EndFunction

Bool Function TryRestoreOriginalForLoad(Armor Item, Form[] Protected, Int Owner, Bool RequireBusy, Bool CheckSlots, Int LoadEpoch)
  Return Self.RestoreOriginalItemCore(Item, Protected, Owner, RequireBusy, CheckSlots, LoadEpoch, None)
EndFunction

Bool Function RestoreOriginalItemCore(Armor Item, Form[] Protected, Int Owner, Bool RequireBusy, Bool CheckSlots, Int LoadEpoch, Float[] Timing)
  Return Self.RestoreOriginalWithReceipt(Item, Protected, Owner, RequireBusy, CheckSlots, LoadEpoch, Timing, None)
EndFunction

Bool Function RestoreOriginalWithReceipt(Armor Item, Form[] Protected, Int Owner, Bool RequireBusy, Bool CheckSlots, Int LoadEpoch, Float[] Timing, Armor[] Awaiting)
  If LoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  If !CheckSlots && !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, LoadEpoch)
    Return False
  EndIf
  ; Read-only candidates use the operation token. Actor changes below
  ; revalidate the original load, owner and live race.
  ; Keep the already-worn accessory path cheap; it never changes the actor.
  If Item == None || Protected.find(Item as Form, 0) >= 0
    Return True
  EndIf
  String Key = Self.GetOriginalCopyKey(Item)
  If Key != "" && SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    Int CopyState = PSQAppearance.OriginalCopyAction(PlayerRef, Item, Key, Self, PlayerAppearanceRace, Owner, LoadEpoch, RequireBusy, True, CheckSlots)
    If CopyState == 1
      If Awaiting && Awaiting.Length == 1
        Awaiting[0] = Item
        Return True
      EndIf
      CopyState = PSQAppearance.OriginalCopyAction(PlayerRef, Item, Key, Self, PlayerAppearanceRace, Owner, LoadEpoch, RequireBusy, False, CheckSlots)
    EndIf
    Return CopyState == 2
  EndIf
  If CheckSlots && Awaiting && Awaiting.Length == 1 && SKSE.GetPluginVersion("PSQ Appearance") >= 16777226
    Float NativeStart
    If EnableEquipmentDiagnostics
      NativeStart = Utility.GetCurrentRealTime()
    EndIf
    Int Result = PSQAppearance.SubmitOriginalArmor(PlayerRef, Item, Self, PlayerAppearanceRace, Owner, LoadEpoch, RequireBusy)
    If Result < 0 || LoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
      Return False
    ElseIf Result == 2
      Return True
    ElseIf Result == 1
      Awaiting[0] = Item
      If EnableEquipmentDiagnostics
        Debug.Trace("[PSQ-PERF] recovery.main_submit; owner=" + Owner + "; item=" + Item + "; equipSeconds=" + (Utility.GetCurrentRealTime() - NativeStart) + "; native=True")
      EndIf
      Return True
    EndIf
  EndIf
  Bool CanReadNative = CheckSlots && SKSE.GetPluginVersion("PSQ Appearance") >= 16777223
  Int[] ArmorRead
  If CanReadNative
    ArmorRead = PSQAppearance.ReadExitArmorState(PlayerRef, Item, PlayerAppearanceRace, True)
  EndIf
  Bool Valid = ArmorRead && ArmorRead.Length == 2
  If Valid
    If LoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy) || ArmorRead[0] < 0
      Return False
    EndIf
    If ArmorRead[0] == 0 || ArmorRead[1] == 1
      Return True
    EndIf
    If ArmorRead[1] == 2
      Return False
    EndIf
  Else
    If CheckSlots
      If PlayerRef.GetItemCount(Item as Form) <= 0
        Return True
      EndIf
      Int Mask = Item.GetSlotMask()
      If Mask != 0
        Form Worn = PlayerRef.GetWornForm(Mask)
        If Worn == Item as Form
          If PlayerRef.IsEquipped(Item as Form)
            Return True
          EndIf
          ; A transitional same-form result can hide another occupied bit.
          If !Self.CanRetryOriginalEquipment(Item)
            Return False
          EndIf
        ElseIf Worn != None
          ; Multiple worn forms can overlap a multi-slot mask. Never displace a
          ; foreign occupant; the original can still be worn on a different bit.
          Return PlayerRef.IsEquipped(Item as Form)
        EndIf
      ElseIf PlayerRef.IsEquipped(Item as Form)
        Return True
      EndIf
    ElseIf PlayerRef.IsEquipped(Item as Form) || PlayerRef.GetItemCount(Item as Form) <= 0
      Return True
    EndIf
    ; Slot and inventory reads can yield. Always revalidate before equipping.
    If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, LoadEpoch)
      Return False
    EndIf
  EndIf
  Float Started = 0.0
  If Timing || EnableEquipmentDiagnostics
    Started = Utility.GetCurrentRealTime()
  EndIf
  If Timing
    Timing[0] = Started
  EndIf
  If LoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  Int Submitted = 0
  If Valid && SKSE.GetPluginVersion("PSQ Appearance") >= 16777225
    Submitted = PSQAppearance.EquipTransformArmor(PlayerRef, Item, Self, PlayerAppearanceRace, Owner, LoadEpoch, RequireBusy, True)
    If Submitted < 0 || !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, LoadEpoch)
      Return False
    EndIf
  EndIf
  If Submitted == 0
    PlayerRef.EquipItemEx(Item as Form, 0, False, True)
  EndIf
  If Timing
    Timing[1] = Utility.GetCurrentRealTime()
  EndIf
  If Valid && Awaiting && Awaiting.Length == 1
    If LoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
      Return False
    EndIf
    Awaiting[0] = Item
    If EnableEquipmentDiagnostics
      Debug.Trace("[PSQ-PERF] recovery.main_submit; owner=" + Owner + "; item=" + Item + "; equipSeconds=" + (Utility.GetCurrentRealTime() - Started))
    EndIf
    ; Accepted for this phase only. Its caller checks the live result before
    ; it may expose accessories, and routes any failure to bounded retries.
    Return True
  EndIf
  If Valid
    ArmorRead = PSQAppearance.ReadExitArmorState(PlayerRef, Item, PlayerAppearanceRace, False)
  EndIf
  Valid = Valid && ArmorRead && ArmorRead.Length == 2
  Bool Equipped
  If Valid
    If LoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy) || ArmorRead[0] < 0
      Return False
    EndIf
    Equipped = ArmorRead[1] == 1
  Else
    If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, LoadEpoch)
      Return False
    EndIf
    Equipped = PlayerRef.IsEquipped(Item as Form)
  EndIf
  If Timing
    Timing[2] = Utility.GetCurrentRealTime()
  ElseIf EnableEquipmentDiagnostics
    Debug.Trace((("[PSQ-EQUIP] swap-original; item=" + Item as String) + "; equipped=" + Equipped as String) + "; seconds=" + (Utility.GetCurrentRealTime() - Started) as String, 0)
  EndIf
  ; If a foreign callback removed the item during equip, it is no longer
  ; pending. No original is re-created, and final ledger validation remains.
  If Valid
    Return Equipped || ArmorRead[0] == 0
  EndIf
  Return Equipped || (CheckSlots && PlayerRef.GetItemCount(Item as Form) <= 0)
EndFunction

Bool Function IsPSQTransformTail(Armor Item)
  If Item == None
    Return False
  EndIf
  Int ID = PSQDXUBE.GetLocalFormID(Item)
  If ID == 3460
    Return Item == Game.GetFormFromFile(3460, "PSQ PlayerSuccubusQuest.esm") as Armor
  EndIf
  ; Validate the owning plugin as well as the local ID. External outfit tails,
  ; including records with the same ID in another plugin, remain personal gear.
  Return PSQDXUBE.GetVerifiedPartForID(Item, ID) == 4
EndFunction

Armor Function CleanOriginalTransformTail(Int Owner, Bool RequireBusy, Int LoadEpoch)
  Return Self.CleanTransformTailForRestore(Owner, RequireBusy, LoadEpoch, False)
EndFunction

Armor Function CleanTransformTailForRestore(Int Owner, Bool RequireBusy, Int LoadEpoch, Bool UseExitLedger)
  If PlayerRef == None || IsHenshined || !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, LoadEpoch)
    Return None
  EndIf
  Armor WornTail = PlayerRef.GetWornForm(1024) as Armor
  Armor[] Candidates = new Armor[3]
  Candidates[0] = OrgTail
  Candidates[1] = WornTail
  Candidates[2] = PSQSuccubusTail
  Form[] Protected = Self.GetTransformProtectedArmor()
  Armor DiscardedTail = None
  Int i = 0
  While i < Candidates.Length
    Armor Item = Candidates[i]
    If Item != None && Candidates.Find(Item) == i
      Bool Removed = Self.CleanTransformTailItem(Item, Protected, Owner, RequireBusy, LoadEpoch, UseExitLedger)
      If Removed && Item == WornTail
        DiscardedTail = Item
      EndIf
    EndIf
    i += 1
  EndWhile
  ; A previous failed recovery can retain an older selection. Walk only
  ; that small existing recovery list, never the player's inventory.
  Form[] Previous = TransformEquipmentRecoveryItems
  i = 0
  While Previous && i < Previous.Length
    Armor Item = Previous[i] as Armor
    If Item != None && Candidates.Find(Item) < 0
      Self.CleanTransformTailItem(Item, Protected, Owner, RequireBusy, LoadEpoch, UseExitLedger)
    EndIf
    i += 1
  EndWhile
  Return DiscardedTail
EndFunction

Function CleanLoadedTransformTail(Int LoadEpoch)
  If LoadEpoch != PSQLoadEpoch || PlayerRef == None || IsHenshined || IsHenshinchu || AppearanceEditBusy || AppearanceRecoveryPending || BodySelectionRefreshBusy || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  Int Owner = AppearanceOperationId
  If !PlayerRef.Is3DLoaded() || psqracecompatibility.IsTemporaryBeastRace(PlayerRef.GetRace()) || Self.ShouldDeferForAlternateStart() || Self.GTSoftbodyOwnsAppearance()
    Return
  EndIf
  If LoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || IsHenshined || IsHenshinchu || AppearanceEditBusy || AppearanceRecoveryPending
    Return
  EndIf
  Self.CleanOriginalTransformTail(Owner, False, LoadEpoch)
EndFunction

Bool Function RemoveOriginalTransformTail(Armor Item, Form[] Protected, Int Owner, Bool RequireBusy, Int LoadEpoch)
  Return Self.CleanTransformTailItem(Item, Protected, Owner, RequireBusy, LoadEpoch, False)
EndFunction

Bool Function CleanTransformTailItem(Armor Item, Form[] Protected, Int Owner, Bool RequireBusy, Int LoadEpoch, Bool UseExitLedger)
  If Item == None || IsHenshined || Protected.Find(Item as Form) >= 0 || !Self.IsPSQTransformTail(Item)
    Return False
  EndIf
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, LoadEpoch)
    Return False
  EndIf
  ; These nonplayable PSQ wrappers cannot be human outfit originals. Keep
  ; external outfit records and inventory counts governed by the normal ledger.
  If OrgTail == Item
    OrgTail = None
  EndIf
  If OrgArmorList != None && OrgArmorList.HasForm(Item as Form)
    If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, LoadEpoch)
      Return False
    EndIf
    OrgArmorList.RemoveAddedForm(Item as Form)
  EndIf
  If TransformEquipmentRecoveryItems && TransformEquipmentRecoveryItems.Find(Item as Form) >= 0
    Form[] Pending = PapyrusUtil.RemoveForm(TransformEquipmentRecoveryItems, Item as Form)
    If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, LoadEpoch)
      Return False
    EndIf
    TransformEquipmentRecoveryItems = Pending
  EndIf
  Int LedgerIndex = -1
  If TransformInventoryLedgerReady
    LedgerIndex = TransformInventoryItems.Find(Item as Form)
  EndIf
  ; This exit can also unequip a borrowed tail through the ledger, without
  ; removing it from inventory. Keep other primary fields and standalone
  ; recovery on their existing path. The ledger survives interruption.
  If UseExitLedger && LedgerIndex >= 0 && ((TransformInventoryBaseline[LedgerIndex] == 0 && TransformInventoryAdded[LedgerIndex] == 1) || (TransformInventoryBaseline[LedgerIndex] > 0 && TransformInventoryAdded[LedgerIndex] == 0)) && Item != OrgArmor && Item != OrgGloves && Item != OrgBoots && Item != OrgHorns && Item != OrgWings
    If Owner == AppearanceOperationId && LoadEpoch == PSQLoadEpoch && (!RequireBusy || AppearanceEditBusy)
      If EnableEquipmentDiagnostics
        Debug.Trace("[PSQ-PERF] recovery.tail_to_ledger; owner=" + Owner + "; item=" + Item)
      EndIf
      Return True
    EndIf
    Return False
  EndIf
  Self.ReleaseLedgerItemForLoad(Item, LedgerIndex, Owner, RequireBusy, LoadEpoch)
  Return Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, LoadEpoch)
EndFunction

Int Function GetPSQLoadEpoch()
  Return PSQLoadEpoch
EndFunction

Bool Function ClearRestoredEquipmentFields(Int Owner, Bool RequireBusy, Int EntryLoad)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777240
    Return PSQAppearance.ClearReturnedFields24(PlayerRef,Self,PlayerAppearanceRace,Owner,EntryLoad,RequireBusy)
  EndIf
  If !Self.IsEquipmentRecoveryCurrent(Owner, RequireBusy, EntryLoad)
    Return False
  EndIf
  ; This clears obsolete references only, after the restore plan has retained
  ; unresolved equipment in its recovery ledger. Keep hair recovery separate.
  ; Pure field writes need local ownership checks, not repeated actor queries.
  If EntryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  OrgArmor = None
  If EntryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  OrgGloves = None
  If EntryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  OrgBoots = None
  If EntryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  OrgHorns = None
  If EntryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  OrgWings = None
  If EntryLoad != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
    Return False
  EndIf
  OrgTail = None
  Return EntryLoad == PSQLoadEpoch && Owner == AppearanceOperationId && (!RequireBusy || AppearanceEditBusy)
EndFunction


Float Function GetSatiationExperienceMultiplier()
  Return Self.GetSatiationExperienceMultiplier40()
EndFunction

Function RemoveLegacySatiationC(Int Owner, Int PoolEpoch)
  If PlayerRef == None || SuccubusSatiatySpellC == None || !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  If !PlayerRef.HasSpell(SuccubusSatiatySpellC)
    Return
  EndIf
  Float OldHealth = PlayerRef.GetAV("Health")
  Float OldMagicka = PlayerRef.GetAV("Magicka")
  Float OldStamina = PlayerRef.GetAV("Stamina")
  If OldHealth > 0.0 && !PlayerRef.IsDead()
    PlayerRef.RestoreAV("Health", PlayerRef.GetAVMax("Health"))
  EndIf
  PlayerRef.RemoveSpell(SuccubusSatiatySpellC)
  Int Attempt = 0
  Bool Pending = True
  While Pending && Attempt < 20 && Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Pending = False
    Int i = 0
    While i < SuccubusSatiatySpellC.GetNumEffects()
      If PlayerRef.HasMagicEffect(SuccubusSatiatySpellC.GetNthEffectMagicEffect(i))
        Pending = True
      EndIf
      i += 1
    EndWhile
    If Pending
      Utility.Wait(0.05)
    EndIf
    Attempt += 1
  EndWhile
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  ; Some legacy effects are shared. Never trim health if removal is uncertain.
  If !Pending
    Self.PreserveSatiationCurrentValue("Health", OldHealth, PoolEpoch, Owner)
  EndIf
  Self.PreserveSatiationCurrentValue("Magicka", OldMagicka, PoolEpoch, Owner)
  Self.PreserveSatiationCurrentValue("Stamina", OldStamina, PoolEpoch, Owner)
EndFunction

Function SyncSatiationSkillPerks(Int Tier)
  Self.SyncSatiationSkillPerks38(Tier)
EndFunction

Int Function BeginStrongBodyMenu()
  If UninstallPrepared || UninstallCleanupBusy || !PlayerRef || PlayerIsSuccubus.GetValueInt() != 1
    Return -1
  EndIf
  Float Now = Utility.GetCurrentRealTime()
  If StrongBodyMenuTicket > 0 && StrongBodyMenuLoad == PSQLoadEpoch
    ; Reclaim an abandoned effect after its menu closes. Time in a visible menu is unlimited.
    If UI.IsMenuOpen("CustomMenu") || (Now >= StrongBodyMenuLastUse && Now - StrongBodyMenuLastUse < 30.0)
      Return -1
    EndIf
  EndIf
  StrongBodyMenuTicket += 1
  If StrongBodyMenuTicket <= 0
    StrongBodyMenuTicket = 1
  EndIf
  StrongBodyMenuLoad = PSQLoadEpoch
  StrongBodyMenuLastUse = Now
  Return StrongBodyMenuTicket
EndFunction

Bool Function IsStrongBodyMenuCurrent(Int Ticket)
  If Ticket <= 0 || Ticket != StrongBodyMenuTicket || StrongBodyMenuLoad != PSQLoadEpoch || UninstallPrepared || UninstallCleanupBusy || PlayerIsSuccubus.GetValueInt() != 1
    Return False
  EndIf
  StrongBodyMenuLastUse = Utility.GetCurrentRealTime()
  Return True
EndFunction

Function EndStrongBodyMenu(Int Ticket)
  If Ticket == StrongBodyMenuTicket && StrongBodyMenuLoad == PSQLoadEpoch
    StrongBodyMenuLoad = -1
  EndIf
EndFunction

Int Function GetStrongBodyLegacyCarry()
  If !StrongCarryInitialized && PlayerRef
    Int Points = StorageUtil.GetIntValue(PlayerRef, "PSQ_Growth_StrongBody_CarryWeight", 0)
    If !StrongCarryInitialized
      If Points < 0
        Points = 0
      EndIf
      StrongCarryLegacyTotal = Points
      StrongCarryLegacyRetained = -1
      StrongCarryInitialized = True
    EndIf
  EndIf
  Return StrongCarryLegacyTotal
EndFunction

Int Function GetStrongBodyLegacyRetained()
  Return StrongCarryLegacyRetained
EndFunction

Function SetStrongBodyLegacyRetained(Int Retained, Int Ticket)
  Int Legacy = Self.GetStrongBodyLegacyCarry()
  If Legacy <= 0 || Retained < 0 || Retained > Legacy || !Self.IsStrongBodyMenuCurrent(Ticket)
    Return
  EndIf
  StrongCarryLegacyRetained = Retained
  Self.QueueStrongBodyCarrySync()
  Self.SyncStrongBodyCarry()
EndFunction

Function QueueStrongBodyCarrySync()
  StrongCarryRevision += 1
  StrongCarryPending = True
EndFunction

Function SyncStrongBodyCarry()
  If !StrongCarryPending || StrongCarryBusy || !PlayerRef || UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  If !PlayerRef.Is3DLoaded() || PlayerRef.IsDead() || Utility.IsInMenuMode()
    Return
  EndIf
  StrongCarryBusy = True
  Int Load = PSQLoadEpoch
  Int Revision = StrongCarryRevision
  Int Old = StrongCarryApplied
  Int Legacy = Self.GetStrongBodyLegacyCarry()
  Int Retained = StrongCarryLegacyRetained
  If Retained < 0
    Retained = Legacy ; Unconfirmed points may already be in the actor's base.
  EndIf
  Int Wanted = StorageUtil.GetIntValue(PlayerRef, "PSQ_Growth_StrongBody_CarryWeight", 0) - Retained
  If Wanted < 0
    Wanted = 0
  EndIf
  ; On an interrupted save, inspect every private ability on the next pass.
  StrongCarryApplied = -1
  Bool Complete = True
  Int NativeResult = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    NativeResult = PSQAppearance.UpdateCarrySpells(PlayerRef,Self,Load,Revision,Old,Wanted,ReviewStrongCarry)
  EndIf
  If NativeResult != 0
    Complete = NativeResult == 1
  Else
    Int Pass = 0
    While Pass < 2 && Complete
      Int Bit = 0
      Int NewBits = Wanted
      Int OldBits = Old
      ; Add before removing old denominations, avoiding a transient loss of capacity.
      While Bit < 31 && (NewBits > 0 || OldBits > 0 || Old < 0) && Complete
        If Revision != StrongCarryRevision || Load != PSQLoadEpoch || UninstallPrepared || UninstallCleanupBusy
          Complete = False
        Else
          Bool Need = NewBits % 2 == 1
          Bool Inspect = Pass == 0 && Need || Pass == 1 && !Need && (Old < 0 || OldBits % 2 == 1)
          If Inspect
            Spell Bonus = Game.GetFormFromFile(0xB911 + Bit, "PSQ PlayerSuccubusQuest.esm") as Spell
            If !Bonus
              Complete = False
            ElseIf Revision == StrongCarryRevision && Load == PSQLoadEpoch && !UninstallPrepared && !UninstallCleanupBusy
              Bool HasBonus = PlayerRef.HasSpell(Bonus)
              If Need && HasBonus && ReviewStrongCarry
                If Self.NeedsCarryEffectRepair(Bonus, Bonus.GetNthEffectMagnitude(0), 0) && Revision == StrongCarryRevision && Load == PSQLoadEpoch && !UninstallPrepared && !UninstallCleanupBusy
                  PlayerRef.RemoveSpell(Bonus)
                  HasBonus = PlayerRef.HasSpell(Bonus)
                  If HasBonus
                    Complete = False
                  EndIf
                EndIf
              EndIf
              If Revision == StrongCarryRevision && Load == PSQLoadEpoch && !UninstallPrepared && !UninstallCleanupBusy
                If Need && !HasBonus
                  Complete = PlayerRef.AddSpell(Bonus, False) || PlayerRef.HasSpell(Bonus)
                ElseIf !Need && HasBonus
                  Complete = PlayerRef.RemoveSpell(Bonus) || !PlayerRef.HasSpell(Bonus)
                EndIf
              EndIf
            EndIf
          EndIf
        EndIf
        NewBits = NewBits / 2
        OldBits = OldBits / 2
        Bit += 1
      EndWhile
      Pass += 1
    EndWhile
  EndIf
  If Load == PSQLoadEpoch
    If Complete && Revision == StrongCarryRevision && !UninstallPrepared && !UninstallCleanupBusy
      StrongCarryApplied = Wanted
      StrongCarryPending = False
      ReviewStrongCarry = False
    EndIf
    StrongCarryBusy = False
  EndIf
EndFunction

Bool Function NeedsCarryEffectRepair(Spell Ability, Float Expected, Int EffectIndex = 3)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Return PSQAppearance.CarryRepairRequired(PlayerRef,Ability,EffectIndex,Expected)
  EndIf
  If Expected <= 0.0 || !Ability || !PlayerRef.HasSpell(Ability)
    Return False
  EndIf
  MagicEffect Carry = Ability.GetNthEffectMagicEffect(EffectIndex)
  If !Carry
    Return False
  EndIf
  If !PlayerRef.HasMagicEffect(Carry)
    Return True
  EndIf
  ; Supplement the native presence check only on load / big game-time jumps.
  ; A nonzero modifier from another spell is not evidence for this ability.
  Int Version = SKSE.GetPluginVersion("powerofthree's Papyrus Extender")
  If Version < 0
    Version = SKSE.GetPluginVersion("po3_PapyrusExtender")
  EndIf
  ; SSE publishes the major version. AE's plugin data uses a packed REL::Version.
  If (Version >= 6 && Version < 256) || Version >= 0x06000000
    ActiveMagicEffect[] Items = PO3_SKSEFunctions.GetActiveMagicEffects(PlayerRef, Carry)
    Bool FoundSource = False
    Bool FoundOther = False
    Float FormMagnitude = Ability.GetNthEffectMagnitude(EffectIndex)
    Int i = 0
    While i < Items.Length
      ActiveMagicEffect Item = Items[i]
      Form Source = None
      If Item
        Source = PO3_SKSEFunctions.GetActiveEffectSpell(Item)
      EndIf
      If Source == Ability
        FoundSource = True
        Float ActiveAmount = Item.GetMagnitude()
        ; A stale cross-save record can be positive, too. Preserve any
        ; independently scaled nonzero effect that does not match that stale record.
        Bool MatchesWrongForm = Math.Abs(FormMagnitude - Expected) > 0.01 && Math.Abs(ActiveAmount - FormMagnitude) <= 0.01
        If ActiveAmount > 0.0 && !MatchesWrongForm
          Return False
        EndIf
      ElseIf Source
        FoundOther = True
      EndIf
      i += 1
    EndWhile
    Return FoundSource || FoundOther
  EndIf
  Return False
EndFunction


; Called only by the failed entry, while it still owns the outer edit.
Function RecoverFailedNativeEntry(Int Owner, Int Epoch)
  If Owner != AppearanceOperationId || Epoch != PSQLoadEpoch || !AppearanceEditBusy || AppearanceTransformDirection != 1
    Return
  EndIf
  ; Invalidate this owner before the first yielding call. Use the same
  ; persisted snapshot and recovery path as an interrupted load.
  Self.CancelInterruptedAppearanceOnLoad()
  Self.RegisterForSingleUpdate(1.0)
EndFunction


Bool Function SameEntryPoolValues(Float[] Early, Float[] Current)
  If !Early || Early.Length != 6 || !Current || Current.Length != 6
    Return False
  EndIf
  Int i = 0
  While i < 6
    If Early[i] != Current[i]
      Return False
    EndIf
    i += 1
  EndWhile
  Return True
EndFunction


Bool Function TraceMainOriginalRestore(Armor Item, Form[] Protected, Int Owner, Bool RequireBusy, Int LoadEpoch, Int Attempt)
  Float[] Timing = new Float[3]
  Timing[0] = -1.0
  Timing[2] = -1.0
  Float Start = Utility.GetCurrentRealTime()
  Bool Resolved = Self.RestoreOriginalItemCore(Item, Protected, Owner, RequireBusy, True, LoadEpoch, Timing)
  Float Total = Utility.GetCurrentRealTime() - Start
  Float Equip = 0.0
  Float Confirm = 0.0
  Bool Called = Timing[0] >= 0.0
  If Called
    Equip = Timing[1] - Timing[0]
    If Timing[2] >= 0.0
      Confirm = Timing[2] - Timing[1]
    Else
      Confirm = -1.0
    EndIf
  EndIf
  Debug.Trace("[PSQ-PERF] recovery.main_item; owner=" + Owner + "; item=" + Item + "; attempt=" + Attempt + "; equipCalled=" + Called + "; equipSeconds=" + Equip + "; confirmSeconds=" + Confirm + "; totalSeconds=" + Total + "; resolved=" + Resolved)
  Return Resolved
EndFunction

Function RecoverNativeExit(Int Owner, Int Epoch)
  If Epoch == PSQLoadEpoch && Owner == AppearanceOperationId && AppearanceEditBusy && AppearanceTransformDirection == 2
    Self.CancelInterruptedAppearanceOnLoad()
    Self.RegisterForSingleUpdate(1.0)
  EndIf
EndFunction

String Function GetOriginalCopyKey(Form Item)
  If HasOriginalCopyKeys && OriginalCopyForms && OriginalCopyKeys && Item
    Int Entry = OriginalCopyForms.Find(Item)
    If Entry >= 0 && Entry < OriginalCopyKeys.Length
      Return OriginalCopyKeys[Entry]
    EndIf
  EndIf
  Return ""
EndFunction

Int Function RunNativeEquipmentRestore27(Form[] Plan, Int MainCount, Int Used, Form[] Protected, Int Owner, Bool RequireBusy, Int LoadEpoch, Bool Manual)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777243 || !PSQAppearance.IsReady()
    Return Self.RunNativeEquipmentRestore(Plan,MainCount,Used,Protected,Owner,RequireBusy,LoadEpoch,Manual)
  EndIf
  Int[] Batch
  Int PreviousTicket
  While True
    Batch = PSQAppearance.ExecuteRestore(PlayerRef,Self,PlayerAppearanceRace,Owner,LoadEpoch,RequireBusy,Plan,MainCount,Used,Protected,OriginalCopyForms,OriginalCopyKeys,Batch,Manual)
    If !Batch
      Return -1
    ElseIf Batch.Length == 1
      Return Batch[0]
    ElseIf Batch.Length != 5 || Batch[4] <= 0
      Return -1
    EndIf
    Int Ticket = Batch[4]
    Int Decision = PSQAppearance.TransformPumpWait26(Ticket,PreviousTicket,Owner,LoadEpoch)
    PreviousTicket = Ticket
    If Decision == 2
      Utility.WaitMenuMode(0.03)
    EndIf
  EndWhile
  Return -1
EndFunction

Int Function RunNativeEquipmentRestore(Form[] Plan, Int MainCount, Int Used, Form[] Protected, Int Owner, Bool RequireBusy, Int LoadEpoch, Bool Manual)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777237 && PSQAppearance.IsReady()
    Int[] Batch
    While True
      Batch = PSQAppearance.ExecuteRestore(PlayerRef,Self,PlayerAppearanceRace,Owner,LoadEpoch,RequireBusy,Plan,MainCount,Used,Protected,OriginalCopyForms,OriginalCopyKeys,Batch,Manual)
      If !Batch
        Return -1
      ElseIf Batch.Length == 1
        Return Batch[0]
      EndIf
      Utility.WaitMenuMode(0.03)
    EndWhile
  EndIf
  Int[] Cursor
  Float PhaseStarted
  If EnableEquipmentDiagnostics
    PhaseStarted = Utility.GetCurrentRealTime()
  EndIf
  While True
    Cursor = PSQAppearance.RestoreGearStep(PlayerRef,Self,PlayerAppearanceRace,Owner,LoadEpoch,RequireBusy,Plan,MainCount,Used,Protected,OriginalCopyForms,OriginalCopyKeys,Cursor,Manual)
    If !Cursor || Cursor.Length != 4
      Return -1
    EndIf
    Int Command = Cursor[0]
    If Command == 1
      If Manual
        Utility.WaitMenuMode(0.1)
        If Utility.IsInMenuMode()
          Return 4
        EndIf
      Else
        Utility.Wait(0.1)
      EndIf
    ElseIf Command == 3
      Armor Item = Plan[Cursor[3]-1] as Armor
      Self.RestoreOriginalWithReceipt(Item,Protected,Owner,RequireBusy,!Manual,LoadEpoch,None,None)
    ElseIf Command == 2
      If EnableEquipmentDiagnostics
        Debug.Trace("[PSQ-PERF] recovery.main_complete; owner=" + Owner + "; seconds=" + (Utility.GetCurrentRealTime()-PhaseStarted))
        PhaseStarted = Utility.GetCurrentRealTime()
      EndIf
      If !Manual
        If !Self.IsEquipmentRecoveryCurrent(Owner,RequireBusy,LoadEpoch)
          Return -1
        EndIf
        Self.RestoreOriginalEquipmentVisibility()
      EndIf
    Else
      If EnableEquipmentDiagnostics
        Debug.Trace("[PSQ-PERF] recovery.native_phase; phase=" + Cursor[1] + "; retryPasses=" + Cursor[2] + "; outcome=" + Command + "; seconds=" + (Utility.GetCurrentRealTime()-PhaseStarted))
      EndIf
      Return Command
    EndIf
  EndWhile
  Return -1
EndFunction

Int[] Function AcquireAppearanceEditTicket()
  Int[] NoTicket
  Int InitialEpoch = PSQLoadEpoch
  Self.SyncPlayerAppearanceRace()
  If Self.IsWingflightAirborne()
    Debug.Notification("请先着陆，再变身或更换外观与翅膀。")
    Return NoTicket
  EndIf
  If PlayerRef == None || psqracecompatibility.IsTemporaryBeastRace(PlayerRef.GetRace())
    Return NoTicket
  EndIf
  If Self.ShouldDeferForAlternateStart()
    Debug.Notification("$PSQ_LALAppearanceDeferred")
    Return NoTicket
  EndIf
  If AppearanceRecoveryPending && !AppearanceRecoveryInProgress || AppearanceEditBusy || IsHenshinchu || BodySelectionRefreshBusy || StatPoolEditBusy || UninstallPrepared || UninstallCleanupBusy
    Debug.Notification("$PSQ_AppearanceEditBusy")
    Return NoTicket
  EndIf
  Int[] Ticket = PSQAppearance.ClaimEditTicket(PlayerRef,Self,InitialEpoch)
  If !Ticket || Ticket.Length != 2 || Ticket[0] <= 0
    Return NoTicket
  EndIf
  Self.CancelDeferredTransformRefill()
  If !Self.IsEquipmentRecoveryCurrent(Ticket[0],True,Ticket[1])
    Return NoTicket
  EndIf
  Self.ClearEquipmentSwapPlan()
  If !Self.IsEquipmentRecoveryCurrent(Ticket[0],True,Ticket[1])
    Return NoTicket
  EndIf
  AppearanceLastProgress = Utility.GetCurrentRealTime()
  AppearanceSlowNotified = False
  AppearanceOperationStage = "menu"
  If Self.GTSoftbodyOwnsAppearance()
    If Self.IsEquipmentRecoveryCurrent(Ticket[0],True,Ticket[1])
      AppearanceEditBusy = False
    EndIf
    Debug.Notification("$PSQ_GTAppearanceBusy")
    Return NoTicket
  EndIf
  If !Self.IsEquipmentRecoveryCurrent(Ticket[0],True,Ticket[1])
    Return NoTicket
  EndIf
  If Self.IsIntegrationPluginLoaded("SexLab TDF Aggressive Prostitution.esp")
    storageutil.SetIntValue(PlayerRef as Form, "PSQ_TDFAppearanceBusy", 1)
  EndIf
  Self.SyncWingflightPolicy()
  Self.StopEnergySense()
  If Self.IsEquipmentRecoveryCurrent(Ticket[0],True,Ticket[1])
    Return Ticket
  EndIf
  Return NoTicket
EndFunction

Int[] Function AcquireTransformAfterLoad()
  Int[] NoTicket
  Int Epoch = PSQLoadEpoch
  If QueuedTransformEpoch == Epoch
    Return NoTicket
  EndIf
  QueuedTransformEpoch = Epoch
  If TransformLoadInitializing || PSQReloadBusy
    Debug.Notification("PSQ 正在恢复读档状态，完成后会执行变身切换。")
    Debug.Trace("[PSQ-RECOVERY] transform waiting for reload; epoch=" + Epoch)
    Int Checks = 0
    While Epoch == PSQLoadEpoch && (TransformLoadInitializing || PSQReloadBusy) && Checks < 240
      Utility.Wait(0.25)
      Checks += 1
    EndWhile
  EndIf
  If Epoch != PSQLoadEpoch || QueuedTransformEpoch != Epoch
    Return NoTicket
  EndIf
  If TransformLoadInitializing || PSQReloadBusy
    QueuedTransformEpoch = -1
    Debug.Notification("PSQ 读档恢复仍在进行，请稍后再使用变身。")
    Return NoTicket
  EndIf
  Int[] Started = Self.AcquireAppearanceEditTicket()
  If Epoch != PSQLoadEpoch || QueuedTransformEpoch != Epoch
    Return NoTicket
  EndIf
  QueuedTransformEpoch = -1
  Return Started
EndFunction

Bool Function BridgeThrallOverlayReceipt(Actor Target, Bool Female, String Node, Bool Capture, Bool Owned, String Expected)
  Int[] Fields = PSQAppearance.ThrallOverlayFields()
  Int Position = 0
  While Position + 2 < Fields.Length
    If Capture
      Self.SaveThrallTattooProperty(Target, Female, Node, Fields[Position], Fields[Position+1], Fields[Position+2])
    Else
      If Owned
        String LiveTexture = NiOverride.GetNodeOverrideString(Target, Female, Node, 9, 0)
        Int Status = PSQAppearance.ThrallOverlayPolicy(True, Node, True, Target.Is3DLoaded() && NetImmerse.HasNode(Target, Node, False), True, Expected, LiveTexture)
        If Status == 0
          Return False
        EndIf
        Owned = Status == 2
      EndIf
      Self.RestoreThrallTattooProperty(Target, Female, Node, Fields[Position], Fields[Position+1], Fields[Position+2], Owned)
    EndIf
    Position += 3
  EndWhile
  Return True
EndFunction

Function FinishOwnedThrallOperation(Int Epoch, Int Ticket)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    PSQAppearance.CheckThrallBond(Self, Epoch, Ticket, True)
  ElseIf PSQLoadEpoch == Epoch
    ThrallConversionBusy = False
  EndIf
EndFunction

Bool Function ChangeOutfitPartFromMenu(Int Part, Int Choice)
  Return Self.ChangeOutfitPartFromMenu40(Part, Choice)
EndFunction

Bool Function SaveBodyChangeSkinChoice(Bool Futa, Bool Transformed, String ID)
  Bool Available = False
  Bool Named = False
  If ID != "" && !(Futa && ID == "@follow")
    If Futa
      Available = Self.HasBCNGFutaAPI()
      Named = Available && (ID == "@default" || BCNGPSQBridge.GetFutanariName(ID) != "")
    Else
      Available = Self.HasBCNGSkinAPI()
      Named = Available && BCNGPSQBridge.GetSkinName(ID) != ""
    EndIf
  EndIf
  Int Action = PSQAppearance.BodySkinSelection(Futa, Transformed, IsHenshined, PlayerRef != None, ID, Available, Named)
  If Action < 0
    If !Futa
      Debug.Notification("请启用 Body Change NG 1.3.8 及对应的 PSQ 接口补丁。")
    ElseIf Action == -1
      Debug.Notification("扶她皮肤接口尚未就绪，请重启游戏并检查 PSQ 的 BCNG DLL 覆盖。")
    Else
      Debug.Notification("所选扶她皮肤包已失效，请刷新列表后重选。")
    EndIf
    Return False
  EndIf
  If Math.LogicalAnd(Action, 8)
    ID = ""
  EndIf
  Int Column = Math.LogicalAnd(Action, 3)
  If Column == 1
    StorageUtil.SetStringValue(Self, "PSQ_BCNGTransformSkin", ID)
    StorageUtil.UnsetIntValue(Self, "PSQ_BCNGSkinManualTakeover")
    Self.QueueBCNGTransformSkin()
    Debug.Notification("变身皮肤已保存，关闭菜单后应用。")
  Else
    If Column == 2
      StorageUtil.SetStringValue(Self, "PSQ_BCNGFutaHuman", ID)
    Else
      StorageUtil.SetStringValue(Self, "PSQ_BCNGFutaSuccubus", ID)
    EndIf
    If Math.LogicalAnd(Action, 4)
      StorageUtil.UnsetIntValue(PlayerRef, "PSQ_BCNGFutaManualTakeover")
      StorageUtil.SetIntValue(PlayerRef, "PSQ_BCNGFutaForce", 1)
      Self.QueueBCNGFutaSkin(PlayerRef)
    EndIf
    Debug.Notification("扶她皮肤选择已保存，关闭菜单后应用。")
  EndIf
  Return True
EndFunction

; Convert the legacy snapshot output array into one VM return value.
Int Function BridgeEntrySnapshotReceipt(Int Owner)
  Bool[] Refusal = new Bool[1]
  If Self.SaveEntryOutfitSnapshot(Owner,True,Refusal)
    Return 1
  ElseIf Refusal[0]
    Return 0
  EndIf
  Return -1
EndFunction

; Saveable wait for callers which require the result of a native appearance operation.
Int Function RunAppearanceTask(ActiveMagicEffect Effect, Int Owner, Int Epoch, Bool Busy, Int Action, Bool Option, Float Ratio)
  Int Ticket = PSQAppearance.StartAppearanceTask(PlayerRef,Self,Effect,Owner,Epoch,Busy,Action,Option,Ratio)
  Int DuplicateAttempts = 0
  While Ticket == -2 && DuplicateAttempts < 100
    DuplicateAttempts += 1
    Utility.WaitMenuMode(0.03)
    Ticket = PSQAppearance.StartAppearanceTask(PlayerRef,Self,Effect,Owner,Epoch,Busy,Action,Option,Ratio)
  EndWhile
  If Ticket < 2
    Return -1
  EndIf
  Return Self.WaitAppearanceReceipt27(Ticket,Owner,Epoch)
EndFunction

Int Function WaitAppearanceReceipt25(Int Ticket, Int Owner, Int Epoch)
  If Ticket < 2
    Return -1
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777241
    While True
      While PSQAppearance.PeekAppearanceTask25(Ticket,Self,Owner,Epoch)
        Utility.WaitMenuMode(0.03)
      EndWhile
      Int Terminal = PSQAppearance.PollAppearanceTask(Ticket,Self,Owner,Epoch)
      If Terminal != 2
        Return Terminal
      EndIf
    EndWhile
  EndIf
  Int Result = PSQAppearance.PollAppearanceTask(Ticket,Self,Owner,Epoch)
  While Result == 2
    Utility.WaitMenuMode(0.03)
    Result = PSQAppearance.PollAppearanceTask(Ticket,Self,Owner,Epoch)
  EndWhile
  Return Result
EndFunction

Int Function WaitAppearanceReceipt27(Int Ticket, Int Owner, Int Epoch)
  If Ticket < 2
    Return -1
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777243
    Return Self.WaitAppearanceReceipt25(Ticket,Owner,Epoch)
  EndIf
  ; Poll on the synchronized game path before scheduling any timed wait.
  ; Poll consumes a terminal receipt; Peek checks only outstanding work.
  Int Status = PSQAppearance.PollAppearanceTask(Ticket,Self,Owner,Epoch)
  While Status == 2
    While PSQAppearance.PeekAppearanceTask25(Ticket,Self,Owner,Epoch)
      Utility.WaitMenuMode(0.03)
    EndWhile
    Status = PSQAppearance.PollAppearanceTask(Ticket,Self,Owner,Epoch)
  EndWhile
  Return Status
EndFunction

; Save-compatible transport. Only an unfinished engine operation needs a ticket.
Bool Function RunEntryStatStage(Int Owner, Int Epoch, Bool FinalPass)
  Int Status = PSQAppearance.RunEntryStatsNow(PlayerRef,Self,Owner,Epoch,FinalPass)
  If Status == 2
    Status = Self.RunAppearanceTask(None,Owner,Epoch,True,5,FinalPass,0.0)
  EndIf
  Return Status == 1
EndFunction

Function BeginPSQLoadSessionCompat34()
  PSQLoadEpoch += 1
  TransformLoadInitializing = True
  QueuedTransformEpoch = -1
  Int NewEpoch = PSQLoadEpoch
  Self.InvalidateAppearanceForLoad(NewEpoch)
  If NewEpoch != PSQLoadEpoch
    Return
  EndIf
  StrongCarryBusy = False
  Self.QueueStrongBodyCarrySync()
  ReviewStrongCarry = True
  ReviewContinuousCarry = True
  ReviewTransformCarry = True
  AWUControlGeneration += 1
  AWUControlChecks = 0
  BCNGBodyRequest = 0
  BCNGBodyRequestOwner = -1
  BCNGBodyRequestLoad = -1
  BCNGBodyAppliedLoad = -1
  BCNGBodyAppliedPreset = ""
  BCNGBodyNeedsSync = True
  BCNGLegacyMorphCleanupEpoch = -1
  RemovedInflationCleanedLoadEpoch = -1
  RemovedInflationNextSourceCheck = -1.0
  RemovedReproductionCleanedLoadEpoch = -1
  Self.ResetStatPoolEditsOnLoad()
  PSQReloadBusy = False
  PSQReloadBusyEpoch = -1
  PSQReloadCompletedEpoch = -1
  RacialUISyncEpoch = -1
  RacialUISyncBusy = False
  ContinuousRecordSyncPending = True
  TransformRecordSyncPending = True
  SatiationRecordSyncPending = True
  SatiationTimedRefreshEpoch += 1
  SatiationTimedRefreshQueued = False
  SatiationLastAttributeRefresh = -10.0
EndFunction

Function BeginPSQLoadSession35()
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.BeginPSQLoadSessionCompat34()
    Return
  EndIf
  Int[] i35 = new Int[5]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[2]
  Int Action35 = 0
  i35[2] = PSQLoadEpoch
  i35[3] = PSQSexSceneEpoch
  i35[4] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.BeginPSQLoadSessionStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 == 6
      self.InvalidateAppearanceForLoad(i35[1])
    ElseIf Action35 == 13
      self.QueueStrongBodyCarrySync()
    ElseIf Action35 == 24
      BCNGBodyAppliedPreset = ""
    ElseIf Action35 == 30
      self.ResetStatPoolEditsOnLoad()
    Else
      Return
    EndIf
  EndWhile
EndFunction

Function PSQReloadCompat34()
  Int LoadEpoch = PSQLoadEpoch
  If PSQReloadCompletedEpoch == LoadEpoch && !AlternateStartResumePending
    Return
  EndIf
  If PSQReloadBusy && PSQReloadBusyEpoch == LoadEpoch
    Return
  EndIf
  PSQReloadBusy = True
  PSQReloadBusyEpoch = LoadEpoch
  Self.PSQReloadCore(LoadEpoch)
  If Self.IsPSQLoadCurrent(LoadEpoch) && PSQReloadBusyEpoch == LoadEpoch
    PSQReloadBusy = False
    TransformLoadInitializing = False
  EndIf
EndFunction

Function PSQReload35()
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.PSQReloadCompat34()
    Return
  EndIf
  Int[] i35 = new Int[4]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[2]
  Int Action35 = 0
  i35[1] = PSQLoadEpoch
  i35[2] = PSQSexSceneEpoch
  i35[3] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.PSQReloadStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 == 19
      self.PSQReloadCore(i35[0])
    Else
      Return
    EndIf
  EndWhile
EndFunction

Function PSQReloadCoreCompat34(Int LoadEpoch)
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  EnergyModeAlt = False
  MaxEnergyAtAltMode = 0.0
  Self.ResetPSQSexSceneState()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  Self.InitializeWingflightIntegration()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  If SEBU != None
    SEBU.SyncVisibility()
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  EndIf
  Self.StopEnergySense()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  Self.InvalidateAppearanceForLoad(LoadEpoch)
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  Self.SyncPlayerAppearanceRace()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  If IsHenshined && HenshinHairColor && !AppearanceRecoveryPending && !IsHenshinchu && !AppearanceEditBusy && !UninstallPrepared && !UninstallCleanupBusy
    Int ColorOwner = AppearanceOperationId
    Self.ApplyTransformHairColor(False, ColorOwner, False)
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    If ColorOwner == AppearanceOperationId && IsHenshined && OrgHairColor != None && PlayerRef.Is3DLoaded()
      Game.UpdateHairColor()
    EndIf
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  EndIf
  Self.CleanLoadedTransformTail(LoadEpoch)
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  Self.ResumeLoadedAccessoryVisibility(LoadEpoch)
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  Self.InvalidateTattooPresentation()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  If PSQJumpHeightOwned
    Float LoadedJump = Game.GetGameSettingFloat("fJumpHeightMin")
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    If Math.Abs(LoadedJump - PSQAppliedJumpHeight) >= 0.001
      PSQJumpHeightOwned = False
      PSQJumpHeightYielded = Math.Abs(LoadedJump - PSQSavedJumpHeight) >= 0.001
      If !Self.IsPSQLoadCurrent(LoadEpoch)
        Return
      EndIf
    EndIf
  EndIf
  ThrallSkillGrowthGeneration += 1
  ThrallSkillGrowthBusy = False
  Self.RestoreRetirementPools(-1, False)
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  Self.SuspendRankUpAnimation()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  RankAnimationRetryEpoch += 1
  RankAnimationRetryBusy = False
  RankAnimationPlaybackBusy = False
  Self.ResetTransformEnergyClock()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  AlternateStartChecked = False
  AlternateStartReleaseAfter = -1.0
  If !UninstallPrepared && !UninstallCleanupBusy && Self.ShouldDeferForAlternateStart()
    AlternateStartResumePending = True
    LastConsumeTime = GameDaysPassed.GetValue()
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    Self.UnregisterForAllKeys()
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    Self.RegisterForSingleUpdate(3.0)
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    Return
  EndIf

  If !UninstallPrepared && !UninstallCleanupBusy
    RacialTraitDrainBusy = False
    Self.MigrateAcquiredRacialPassives()
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    Self.RefreshAbsorbedRacialTraitNames()
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  EndIf

  Self.SyncContinuousAbilities(False)
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  AppliedMovementValid = False
  ; CancelInterruptedAppearanceOnLoad has already released the saved operation.
  ; Never release a newer operation from late maintenance.
  AppliedTransformEyeTexture = None
  Self.ClearAppliedTransformBody(-1, False)
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  Self.InvalidateTransformAppearanceCache()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  Self.InvalidateNPCEnergyThrallCache()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  NPCEnergyThrallCache = EmptyActorArray
  EnergySenseLastToggleTime = -1.0
  EnergySenseRegistrationBusy = False
  If PlayerRef != None
    storageutil.UnsetIntValue(PlayerRef as Form, "PSQ_MedicalReportBusy")
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  EndIf
  PSQOutfitModelsNormalized = False
  ThrallConversionBusy = False
  EnableCursePaintGradient = False
  If PlayerRef != None && SuccubusCurseCloakSpell != None
    PlayerRef.RemoveSpell(SuccubusCurseCloakSpell)
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  EndIf
  If !UninstallPrepared && !UninstallCleanupBusy
    If storageutil.GetIntValue(PlayerRef as Form, "PSQ_MerchantInitialized", 0) == 1
      Self.PrepareSuccubusMerchantTrade()
      If !Self.IsPSQLoadCurrent(LoadEpoch)
        Return
      EndIf
    EndIf
  EndIf
  If UninstallPrepared || UninstallCleanupBusy
    Self.UnregisterForUpdate()
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    Self.UnregisterForAllKeys()
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    Return
  EndIf
  Bool RefreshLoadedClothes = IsHenshined && !AppearanceRecoveryPending && !IsHenshinchu && !AppearanceEditBusy
  Int ClothesOwner = AppearanceOperationId
  If RefreshLoadedClothes
    Self.ApplyPSQOutfitBodyModels(False, ClothesOwner, False)
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  EndIf
  If SuccubusOutfitSelection == 0
    Self.ApplySuccubusOutfitSelection(4)
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  EndIf
  Self.MigrateTransformPresetCatalog(-1, False)
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  Self.MigrateHeartEyeSelection()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  Self.ResolveOptionalWingSelection()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  Self.RefreshAllSuccubusThrallEyes()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  If IsHenshined && !AppearanceRecoveryPending && !HenshinEyes
    Self.RefreshSuccubusEyeToggle(-1, False)
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  EndIf
  If SuccubusHairSelection < 0 || SuccubusHairSelection > 4
    SuccubusHairSelection = 0
  EndIf
  HenshinHair = Self.GetTransformHairChoice(SuccubusHairSelection, -1, False) != None
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  If IsHenshined && !AppearanceRecoveryPending
    Self.ApplySelectedTransformHair(-1, False)
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  ElseIf !IsHenshined && !AppearanceEditBusy && !AppearanceRecoveryPending && OrgHair != None
    Self.RestoreTransformHair(AppearanceOperationId, False)
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  EndIf
  ActiveDigestionGeneration += 1
  Self.RecoverFHUTransfer(True)
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  storageutil.SetIntValue(PlayerRef as Form, "PSQ_Digestioning", 0)
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  ManagedAbilitiesBusy = False
  If !ManagedAbilitiesInitialized
    Self.CaptureManualManagedAbilities()
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  EndIf
  Bool PSQVisualRuntime = skse.GetPluginVersion("skee") >= 0 || skse.GetPluginVersion("nioverride") >= 0
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  If EFFActive
    Self.RegisterEFF()
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  Else
    XFLMain = None
    FollowerExtension = None
  EndIf
  AppliedBellyScale = -1.0
  ManualDigestionBusy = False
  RankMagicCostBusy = False
  AppliedRankMagicCostTier = -1
  If AproposRepairBusy
    Self.FinishAproposRepair(AproposRepairTicket, False)
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  EndIf
  AproposRepairTicket += 1
  If PlayerRef && !Self.IsAproposRepairPatchInstalled()
    Self.SyncManagedSpell(Self.GetAproposRepairSpell(), False)
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  EndIf
  AttributeDrainBusy = False
  AppliedBreastScale = -1.0
  AppliedEnergyDisplayPercent = -1.0
  Self.ClearEnergyDisplay()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  BodySelectionRefreshBusy = False

  SatiationLastAttributeRefresh = -10.0
  Self.ResetRankShoutCooldownBonus()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  If PlayerIsSuccubus.GetValueInt() == 1
    Self.UnregisterSuccubusEvents()
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    Self.RegisterSuccubusEvents()
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    If Self.UpdateAdvancedSuccubusRank(True)
      Self.SuccubusLevelUp(0.0)
      If !Self.IsPSQLoadCurrent(LoadEpoch)
        Return
      EndIf
    EndIf
    FortifyIllusionPerk.SetNthEntryValue(0, 1, (3.0 * SuccubusRank.GetValue() + Math.Sqrt(SuccubusEXP.GetValue())) / 100.0 + 1.0)
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    Self.RefreshEnergyCapacity()
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    Self.Satiety(0.0)
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    If PSQVisualRuntime
      nioverride.ApplyNodeOverrides(PlayerRef as ObjectReference)
      If !Self.IsPSQLoadCurrent(LoadEpoch)
        Return
      EndIf
    EndIf
    Self.UpdatePSQWingJumpHeight(False)
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    If SuccubusNightEyeEnabled
      SuccubusNightEyeIntroFXImod.Apply(SuccubusNightEyeStrength)
      If !Self.IsPSQLoadCurrent(LoadEpoch)
        Return
      EndIf
      Utility.Wait(0.5)
      If !Self.IsPSQLoadCurrent(LoadEpoch)
        Return
      EndIf
      SuccubusNightEyeIntroFXImod.PopTo(SuccubusNightEyeImod, SuccubusNightEyeStrength)
      If !Self.IsPSQLoadCurrent(LoadEpoch)
        Return
      EndIf
    EndIf
    Fish = new Actor[100]
    Self.ResetSlots()
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    If IsHenshined && !AppearanceRecoveryPending
      If HenshinBody
        Self.ApplyTransformBodyMorphs(False, -1, False)
        If !Self.IsPSQLoadCurrent(LoadEpoch)
          Return
        EndIf
      EndIf
      If HenshinSkin
        Self.ApplyTransformSkinColor(False, -1, False)
        If !Self.IsPSQLoadCurrent(LoadEpoch)
          Return
        EndIf
      EndIf
      Float BoosterRate = Math.Sqrt(Math.Sqrt(SuccubusEXP.GetValue())) / 2.0
      If !Self.IsPSQLoadCurrent(LoadEpoch)
        Return
      EndIf
      If BoosterRate < 1.0
        BoosterRate = 1.0
      EndIf
      Int i = 0
      While i <= 6
        If !Self.IsPSQLoadCurrent(LoadEpoch)
          Return
        EndIf
        SuccubusSpellBoostPerk.SetNthEntryValue(i, 1, BoosterRate)
        If !Self.IsPSQLoadCurrent(LoadEpoch)
          Return
        EndIf
        i += 1
      EndWhile
    EndIf
  EndIf
  If !IsHenshined
    Self.RestoreTransformSkinColor(-1, False)
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  EndIf
  Self.RegisterForNiNodeUpdate()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  Self.ReloadHotkeys()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  Self.RegisterForSingleUpdate(15.0)
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  Self.SyncManagedAbilities()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  Self.RefreshInflationFertilityBridge()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  If IsHenshined && !AppearanceRecoveryPending
    If HenshinBody
      Self.RefreshEquippedTransformBody(-1, False)
      If !Self.IsPSQLoadCurrent(LoadEpoch)
        Return
      EndIf
    EndIf
    If HenshinSkin || HenshinHairColor || (RefreshLoadedClothes && ClothesOwner == AppearanceOperationId && !AppearanceEditBusy && !IsHenshinchu)
      PlayerRef.QueueNiNodeUpdate()
      If !Self.IsPSQLoadCurrent(LoadEpoch)
        Return
      EndIf
    EndIf
    Self.ApplySelectedSuccubusEyes(-1, False)
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
  EndIf
  Self.RequestRankAnimationRetry()
  If !Self.IsPSQLoadCurrent(LoadEpoch)
    Return
  EndIf
  If Self.IsPSQLoadCurrent(LoadEpoch)
    If PlayerRef
      If PlayerIsSuccubus.GetValueInt() == 1 && Self.GetSatiationEffectMode() != 0 && !UninstallPrepared && !UninstallCleanupBusy
        StorageUtil.UnsetFloatValue(PlayerRef, "PSQ_SatiationXPCheck")
        Float CurrentMultiplier = Self.GetSatiationExperienceMultiplier()
      Else
        Self.SyncSatiationSkillPerks(1)
      EndIf
    EndIf
    If !Self.IsPSQLoadCurrent(LoadEpoch)
      Return
    EndIf
    PSQReloadCompletedEpoch = LoadEpoch
  EndIf
EndFunction

Function PSQReloadCore35(Int LoadEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.PSQReloadCoreCompat34(LoadEpoch)
    Return
  EndIf
  Int[] i35 = new Int[8]
  Float[] f35 = new Float[5]
  Int[] b35 = new Int[4]
  Int Action35 = 0
  i35[0] = LoadEpoch
  succubusEnergyBarUpdate Temp35_temp1
  colorForm Temp35_temp2
  textureSet Temp35_temp5
  actor Temp35_temp6
  form Temp35_temp7
  spell Temp35_temp8
  headPart Temp35_temp9
  headPart Temp35_temp10
  effcore Temp35_temp11
  quest Temp35_temp12
  objectReference Temp35_temp14
  actor[] Temp35_temp15
  i35[5] = PSQLoadEpoch
  i35[6] = PSQSexSceneEpoch
  i35[7] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.PSQReloadCoreStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 439
      If Action35 < 217
        If Action35 < 109
          If Action35 < 43
            If Action35 < 24
              If Action35 == 8
                self.ResetPSQSexSceneState()
              ElseIf Action35 == 14
                self.InitializeWingflightIntegration()
              ElseIf Action35 == 21
                Temp35_temp1 = None as succubusenergybarupdate
                b35[0] = (SEBU == Temp35_temp1) as Int
              Else
                Return
              EndIf
            Else
              If Action35 == 24
                SEBU.SyncVisibility()
              ElseIf Action35 == 31
                self.StopEnergySense()
              ElseIf Action35 == 37
                self.InvalidateAppearanceForLoad(i35[0])
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 92
              If Action35 == 43
                self.SyncPlayerAppearanceRace()
              ElseIf Action35 == 74
                self.ApplyTransformHairColor(false, i35[1], false)
              ElseIf Action35 == 87
                Temp35_temp2 = None as colorform
                b35[0] = (OrgHairColor == Temp35_temp2) as Int
              Else
                Return
              EndIf
            Else
              If Action35 == 92
                b35[0] = (PlayerRef.Is3DLoaded()) as Int
              ElseIf Action35 == 95
                game.UpdateHairColor()
              ElseIf Action35 == 103
                self.CleanLoadedTransformTail(i35[0])
              Else
                Return
              EndIf
            EndIf
          EndIf
        Else
          If Action35 < 154
            If Action35 < 130
              If Action35 == 109
                self.ResumeLoadedAccessoryVisibility(i35[0])
              ElseIf Action35 == 115
                self.InvalidateTattooPresentation()
              ElseIf Action35 == 122
                f35[1] = game.GetGameSettingFloat("fJumpHeightMin")
              Else
                Return
              EndIf
            Else
              If Action35 == 130
                f35[1] = math.abs(f35[1])
              ElseIf Action35 == 135
                f35[1] = math.abs(f35[1])
              ElseIf Action35 == 148
                self.RestoreRetirementPools(-1, false)
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 190
              If Action35 == 154
                self.SuspendRankUpAnimation()
              ElseIf Action35 == 164
                self.ResetTransformEnergyClock()
              ElseIf Action35 == 179
                b35[0] = (self.ShouldDeferForAlternateStart()) as Int
              Else
                Return
              EndIf
            Else
              If Action35 == 190
                self.UnregisterForAllKeys()
              ElseIf Action35 == 196
                self.RegisterForSingleUpdate(3.0)
              ElseIf Action35 == 211
                self.MigrateAcquiredRacialPassives()
              Else
                Return
              EndIf
            EndIf
          EndIf
        EndIf
      Else
        If Action35 < 308
          If Action35 < 255
            If Action35 < 239
              If Action35 == 217
                self.RefreshAbsorbedRacialTraitNames()
              ElseIf Action35 == 224
                self.SyncContinuousAbilities(false)
              ElseIf Action35 == 233
                Temp35_temp5 = None as textureset
                AppliedTransformEyeTexture = Temp35_temp5
                self.ClearAppliedTransformBody(-1, false)
              Else
                Return
              EndIf
            Else
              If Action35 == 239
                self.InvalidateTransformAppearanceCache()
              ElseIf Action35 == 245
                self.InvalidateNPCEnergyThrallCache()
              ElseIf Action35 == 251
                NPCEnergyThrallCache = EmptyActorArray
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 275
              If Action35 == 255
                Temp35_temp6 = None as actor
                b35[0] = (PlayerRef == Temp35_temp6) as Int
              ElseIf Action35 == 259
                Temp35_temp7 = PlayerRef as form
                b35[0] = (storageUtil.UnsetIntValue(Temp35_temp7, "PSQ_MedicalReportBusy")) as Int
              ElseIf Action35 == 270
                Temp35_temp6 = None as actor
                b35[0] = (PlayerRef == Temp35_temp6) as Int
              Else
                Return
              EndIf
            Else
              If Action35 == 275
                Temp35_temp8 = None as spell
                b35[0] = (SuccubusCurseCloakSpell == Temp35_temp8) as Int
              ElseIf Action35 == 293
                Temp35_temp7 = PlayerRef as form
                i35[2] = storageUtil.GetIntValue(Temp35_temp7, "PSQ_MerchantInitialized", 0)
              ElseIf Action35 == 296
                self.PrepareSuccubusMerchantTrade()
              Else
                Return
              EndIf
            EndIf
          EndIf
        Else
          If Action35 < 365
            If Action35 < 346
              If Action35 == 308
                self.UnregisterForUpdate()
              ElseIf Action35 == 314
                self.UnregisterForAllKeys()
              ElseIf Action35 == 337
                self.ApplyPSQOutfitBodyModels(false, i35[3], false)
              Else
                Return
              EndIf
            Else
              If Action35 == 346
                b35[0] = (self.ApplySuccubusOutfitSelection(4)) as Int
              ElseIf Action35 == 353
                self.MigrateTransformPresetCatalog(-1, false)
              ElseIf Action35 == 359
                self.MigrateHeartEyeSelection()
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 401
              If Action35 == 365
                self.ResolveOptionalWingSelection()
              ElseIf Action35 == 371
                self.RefreshAllSuccubusThrallEyes()
              ElseIf Action35 == 386
                self.RefreshSuccubusEyeToggle(-1, false)
              Else
                Return
              EndIf
            Else
              If Action35 == 401
                Temp35_temp9 = self.GetTransformHairChoice(SuccubusHairSelection, -1, false)
              ElseIf Action35 == 403
                Temp35_temp10 = None as headpart
                b35[0] = (Temp35_temp9 == Temp35_temp10) as Int
              ElseIf Action35 == 416
                self.ApplySelectedTransformHair(-1, false)
              ElseIf Action35 == 435
                Temp35_temp10 = None as headpart
                b35[0] = (OrgHair == Temp35_temp10) as Int
              Else
                Return
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    Else
      If Action35 < 600
        If Action35 < 518
          If Action35 < 485
            If Action35 < 464
              If Action35 == 439
                self.RestoreTransformHair(AppearanceOperationId, false)
              ElseIf Action35 == 448
                self.RecoverFHUTransfer(true)
              ElseIf Action35 == 455
                Temp35_temp7 = PlayerRef as form
                i35[2] = storageUtil.SetIntValue(Temp35_temp7, "PSQ_Digestioning", 0)
              Else
                Return
              EndIf
            Else
              If Action35 == 464
                self.CaptureManualManagedAbilities()
              ElseIf Action35 == 471
                i35[2] = sKSE.GetPluginVersion("skee")
              ElseIf Action35 == 475
                i35[2] = sKSE.GetPluginVersion("nioverride")
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 510
              If Action35 == 485
                self.RegisterEFF()
              ElseIf Action35 == 495
                Temp35_temp11 = None as effcore
                XFLMain = Temp35_temp11
                Temp35_temp12 = None as quest
                FollowerExtension = Temp35_temp12
              ElseIf Action35 == 501
                self.FinishAproposRepair(AproposRepairTicket, false)
              Else
                Return
              EndIf
            Else
              If Action35 == 510
                b35[0] = (PlayerRef as bool) as Int
              ElseIf Action35 == 513
                b35[0] = (self.IsAproposRepairPatchInstalled()) as Int
              ElseIf Action35 == 517
                Temp35_temp8 = self.GetAproposRepairSpell()
              Else
                Return
              EndIf
            EndIf
          EndIf
        Else
          If Action35 < 559
            If Action35 < 545
              If Action35 == 518
                self.SyncManagedSpell(Temp35_temp8, false)
              ElseIf Action35 == 528
                self.ClearEnergyDisplay()
              ElseIf Action35 == 536
                self.ResetRankShoutCooldownBonus()
              Else
                Return
              EndIf
            Else
              If Action35 == 545
                self.UnregisterSuccubusEvents()
              ElseIf Action35 == 551
                self.RegisterSuccubusEvents()
              ElseIf Action35 == 557
                b35[0] = (self.UpdateAdvancedSuccubusRank(true)) as Int
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 579
              If Action35 == 559
                self.SuccubusLevelUp(0.0)
              ElseIf Action35 == 569
                f35[2] = math.sqrt(f35[2])
              ElseIf Action35 == 573
                b35[0] = (FortifyIllusionPerk.SetNthEntryValue(0, 1, f35[2])) as Int
              Else
                Return
              EndIf
            Else
              If Action35 == 579
                self.RefreshEnergyCapacity()
              ElseIf Action35 == 585
                self.Satiety(0.0)
              ElseIf Action35 == 593
                Temp35_temp14 = PlayerRef as objectreference
                niOverride.ApplyNodeOverrides(Temp35_temp14)
              Else
                Return
              EndIf
            EndIf
          EndIf
        EndIf
      Else
        If Action35 < 703
          If Action35 < 648
            If Action35 < 619
              If Action35 == 600
                self.UpdatePSQWingJumpHeight(false)
              ElseIf Action35 == 607
                SuccubusNightEyeIntroFXImod.Apply(SuccubusNightEyeStrength)
              ElseIf Action35 == 613
                utility.Wait(0.5)
              Else
                Return
              EndIf
            Else
              If Action35 == 619
                SuccubusNightEyeIntroFXImod.PopTo(SuccubusNightEyeImod, SuccubusNightEyeStrength)
              ElseIf Action35 == 628
                Temp35_temp15 = new actor[100]
                Fish = Temp35_temp15
                self.ResetSlots()
              ElseIf Action35 == 640
                self.ApplyTransformBodyMorphs(false, -1, false)
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 677
              If Action35 == 648
                b35[0] = (self.ApplyTransformSkinColor(false, -1, false)) as Int
              ElseIf Action35 == 656
                f35[2] = math.sqrt(f35[2])
              ElseIf Action35 == 657
                f35[2] = math.sqrt(f35[2])
              Else
                Return
              EndIf
            Else
              If Action35 == 677
                b35[0] = (SuccubusSpellBoostPerk.SetNthEntryValue(i35[4], 1, f35[3])) as Int
              ElseIf Action35 == 690
                b35[0] = (self.RestoreTransformSkinColor(-1, false)) as Int
              ElseIf Action35 == 697
                self.RegisterForNiNodeUpdate()
              Else
                Return
              EndIf
            EndIf
          EndIf
        Else
          If Action35 < 766
            If Action35 < 721
              If Action35 == 703
                self.ReloadHotkeys()
              ElseIf Action35 == 709
                self.RegisterForSingleUpdate(15.0)
              ElseIf Action35 == 715
                self.SyncManagedAbilities()
              Else
                Return
              EndIf
            Else
              If Action35 == 721
                self.RefreshInflationFertilityBridge()
              ElseIf Action35 == 733
                self.RefreshEquippedTransformBody(-1, false)
              ElseIf Action35 == 759
                PlayerRef.QueueNiNodeUpdate()
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 787
              If Action35 == 766
                self.ApplySelectedSuccubusEyes(-1, false)
              ElseIf Action35 == 773
                self.RequestRankAnimationRetry()
              ElseIf Action35 == 781
                b35[0] = (PlayerRef as bool) as Int
              Else
                Return
              EndIf
            Else
              If Action35 == 787
                i35[2] = self.GetSatiationEffectMode()
              ElseIf Action35 == 801
                Temp35_temp7 = PlayerRef as form
                b35[0] = (storageUtil.UnsetFloatValue(Temp35_temp7, "PSQ_SatiationXPCheck")) as Int
              ElseIf Action35 == 802
                f35[2] = self.GetSatiationExperienceMultiplier()
              ElseIf Action35 == 805
                self.SyncSatiationSkillPerks(1)
              Else
                Return
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndWhile
EndFunction

Function QuitSuccubusCompat34()
  If Self.IsWingflightAirborne()
    Debug.Notification("请先着陆，再解除魅魔。")
    Return
  EndIf
  If PlayerRef == None || PlayerRef.IsDead()
    Return
  EndIf
  Bool OwnsAppearance = !UninstallCleanupBusy
  If OwnsAppearance && !Self.BeginAppearanceEdit()
    Return
  EndIf
  Int RetirementOwner = AppearanceOperationId
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  If OwnsAppearance && !Self.ReturnPersonalStorageItems(RetirementOwner, OwnsAppearance)
    If OwnsAppearance
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      Self.EndAppearanceEdit(RetirementOwner)
    EndIf
    Debug.MessageBox("$PSQ_StorageReturnQuitFailed")
    Return
  EndIf
  If RetirementOwner != AppearanceOperationId
    Return
  EndIf
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  Float RetirementHealth = PlayerRef.GetActorValue("Health")
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  Float RetirementMagicka = PlayerRef.GetActorValue("Magicka")
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  Float RetirementStamina = PlayerRef.GetActorValue("Stamina")
  If OwnsAppearance || !RetirementPoolsPending
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    RetirementSavedHealth = RetirementHealth
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    RetirementSavedMagicka = RetirementMagicka
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    RetirementSavedStamina = RetirementStamina
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    RetirementPoolsPending = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  PlayerRef.RestoreActorValue("Health", PlayerRef.GetActorValueMax("Health"))
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  Self.SettleTransformEnergy()
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  TransformClockReady = False
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  PendingRankAnimation = 0
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  LastRankAnimation = 0
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  RankAnimationReadyAt = 0.0
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  Self.StopRankUpAnimation()
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  Self.ClearContinuousRankEffects(RetirementOwner, -1)
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  StableAppliedContinuousMode = -1
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  AlternateStartBecomePending = False
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  Self.ClearPSQSLIFOutput()
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  Self.ResetRankMagicCostReduction()
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  Self.ClearEnergyDisplay()
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  AppliedBreastScale = -1.0
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  Self.SetDefaultSuccubusTattoo(False)
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  Self.SetSuccubusTattooOverlay("Body [Ovl5]", "PSQ_BuiltinBody", "", False, True, True)
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  Self.SetSuccubusTattooOverlay("Hands [Ovl2]", "PSQ_BuiltinHands", "", False, True, True)
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  Self.SetSuccubusTattooOverlay("Feet [Ovl2]", "PSQ_BuiltinFeet", "", False, True, True)
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  Self.SetSuccubusTattooOverlay("Face [Ovl2]", "PSQ_BuiltinFace", "", False, True, True)
  If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
    Return
  EndIf
  Self.ReleaseDragonbornTattoo(True)
  If PlayerIsSuccubus.GetValue() == 1.0
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerIsSuccubus.SetValue(0.0)
    Self.SyncSatiationSkillPerks(1)
    Self.SyncWingflightPolicy()
    If SEBU != None
      SEBU.SyncVisibility()
    EndIf
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    SuccubusEnergy.SetValue(0.0)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    SuccubusRank.SetValue(0.0)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    Self.UpdateRankShoutCooldownBonus()
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    storageutil.SetIntValue(PlayerRef as Form, "PSQ_PlayerIsSuccubus", 0)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    HasWing.SetValue(0.0)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    Self.ReleasePSQJumpHeight()
    If !UninstallCleanupBusy
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      Self.DisableEnterSoulCairn()
    EndIf
    If IsHenshined
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      SuccubusTransFXS.Play(PlayerRef as ObjectReference, 0.5)
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      Self.RemoveTransformBuffSafely(RetirementOwner, -1)
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      PlayerRef.RemoveSpell(SuccubusWaterWalking)
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      PlayerRef.RemoveSpell(SuccubusArmorSpell)
      Self.RestoreOriginalPlayerEyes(RetirementOwner, OwnsAppearance)
      Bool RefreshBody = HenshinBody
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      Bool RefreshHead = Self.HasOriginalTransformSkinColor() || OrgHairColor != None
      If HenshinBody
        If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
          Return
        EndIf
        Self.RestoreTransformBodyMorphs(False, RetirementOwner, OwnsAppearance)
      EndIf
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      Self.RestoreTransformSkinColor(RetirementOwner, OwnsAppearance)
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      Self.RestoreTransformHair(RetirementOwner, OwnsAppearance)
      Self.RestoreOriginalPlayerHairColor(RetirementOwner, OwnsAppearance)
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      Self.RestoreTransformEquipment(RetirementOwner, OwnsAppearance)
      If RetirementOwner != AppearanceOperationId
        Return
      EndIf
      If RefreshBody
        If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
          Return
        EndIf
        Self.RefreshEquippedTransformBody(RetirementOwner, OwnsAppearance)
      EndIf
      If RefreshHead
        If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
          Return
        EndIf
        PlayerRef.QueueNiNodeUpdate()
      EndIf
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      PlayerRef.RemoveFromFaction(SuccubusFoeFaction)
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      PlayerRef.SetAttackActorOnSight(False)
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      TransformBooster.SetValue(0.0)
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      IsHenshined = False
      Self.SyncAWUWing()
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      OrgArmor = None
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      OrgGloves = None
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      OrgBoots = None
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      OrgHorns = None
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      OrgWings = None
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      OrgTail = None
    EndIf
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    Self.ReleaseTransformSlot52(False, RetirementOwner, OwnsAppearance)
    If RetirementOwner != AppearanceOperationId
      Return
    EndIf
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    Self.SetScaleHuman(RetirementOwner, OwnsAppearance)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    Self.ApplyBreastScaleIfChanged(1.0, RetirementOwner, OwnsAppearance)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveFromFaction(SuccubusFoeFaction)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.SetAttackActorOnSight(False)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    storageutil.SetIntValue(PlayerRef as Form, "PSQ_SuccubusON", 0)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(HenshinSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyMagickaSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyCarrySpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyHealthSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyStaminaSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyUnarmedSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusStorageSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(ImmunityToSTD)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusSatiatySpellA)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusSatiatySpellB)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    Self.ClearManagedMovement()
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    StableCachedSatiationInputs = EmptyFloatArray
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    StableAppliedSatiationMagnitudes = EmptyFloatArray
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    StableAppliedSatiationSpell = None
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusStarvation)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(StarkRealitySpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusSpellLearningMSGBoxSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuKanashibari)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell01)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell02)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell03)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell04)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell05)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell06)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell07)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell08)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell01)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell02)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell03)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell04)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell05)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell06)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell07)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell08)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainFF01)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainFF02)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainFF03)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainFF04)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainFF05)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainFF06)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainFF07)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainFF08)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyMSGBoxSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(StatsMSGBoxSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(RestoreMagickaSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(CreatePenisSpellSelf)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(CreatePenisSpellOther)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(PSQSoulGemImpregnateSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifySneakSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusCurseSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusSummonMerchantSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusRaiseArousalSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusArousalCloakSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    Self.StopEnergySense()
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(Self.GetEnergySenseSpell())
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(Self.GetAproposRepairSpell())
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(DetectArousalCloakSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyBartarSpell1)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyBartarSpell2)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyBartarSpell3)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyBartarSpell4)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyBartarSpell5)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyBartarSpell6)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyBartarSpell7)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyBartarSpell8)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(MasturbationSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyDestructionSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(FortifyIllusionSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemovePerk(SuccubusFeed)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemovePerk(FortifyIllusionPerk)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemovePerk(FortifySneakPerk)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemovePerk(FortifyBartarPerk)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemovePerk(SuccubusWingPerk)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemovePerk(SuccubusSpellBoostPerk)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuFirebolt)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuIceSpike)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuLightningBolt)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuFireball)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuIceStorm)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuChainLightning)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuIncinerate)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuIcySpear)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuThunderbolt)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuFireStorm)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuBlizzard)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    Spell RoseStorm = Self.GetRoseStormSpell()
    If RoseStorm
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
      PlayerRef.RemoveSpell(RoseStorm)
      If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
        Return
      EndIf
    EndIf
    PlayerRef.RemoveSpell(SuccuCourage)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuCalm)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuFear)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuFury)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuRally)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuPacify)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuRout)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuFrenzy)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuCallToArms)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuHarmony)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuHysteria)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuMayhem)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuOakflesh)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuIronflesh)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuStoneflesh)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuEbonyflesh)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuDragonhide)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuHealOther)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuFastHealing)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuGrandHealing)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuCloseWounds)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccuParalyze)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(PSQSoulGemBirthingSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(SuccubusCharmSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(CumInflationSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    PlayerRef.RemoveSpell(MagicResistanceSpell)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    Self.SetBellyScale()
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    Self.UnregisterSuccubusEvents()
  EndIf
  If RetirementOwner != AppearanceOperationId
    Return
  EndIf
  If OwnsAppearance
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    Self.RestoreRetirementPools(RetirementOwner, OwnsAppearance)
    If !Self.IsAppearanceOperationCurrent(RetirementOwner, OwnsAppearance)
      Return
    EndIf
    Self.EndAppearanceEdit(RetirementOwner)
  EndIf
EndFunction

Function QuitSuccubus35()
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.QuitSuccubusCompat34()
    Return
  EndIf
  Int[] i35 = new Int[5]
  Float[] f35 = new Float[4]
  Int[] b35 = new Int[5]
  Int Action35 = 0
  actor Temp35_temp1
  succubusEnergyBarUpdate Temp35_temp3
  form Temp35_temp4
  objectReference Temp35_temp6
  colorForm Temp35_temp7
  armor Temp35_temp8
  spell Temp35_temp9
  spell RoseStorm
  i35[2] = PSQLoadEpoch
  i35[3] = PSQSexSceneEpoch
  i35[4] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.QuitSuccubusStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 326
      If Action35 < 205
        If Action35 < 77
          If Action35 < 38
            If Action35 < 7
              If Action35 == 1
                b35[0] = (self.IsWingflightAirborne()) as Int
              ElseIf Action35 == 3
                debug.Notification("请先着陆，再解除魅魔。")
              Else
                Return
              EndIf
            Else
              If Action35 == 7
                Temp35_temp1 = None as actor
                b35[0] = (PlayerRef == Temp35_temp1) as Int
              ElseIf Action35 == 10
                b35[0] = (PlayerRef.IsDead()) as Int
              ElseIf Action35 == 19
                b35[0] = (self.BeginAppearanceEdit()) as Int
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 50
              If Action35 == 38
                b35[0] = (self.ReturnPersonalStorageItems(i35[0], (b35[1] as Bool))) as Int
              ElseIf Action35 == 48
                self.EndAppearanceEdit(i35[0])
              Else
                Return
              EndIf
            Else
              If Action35 == 50
                debug.MessageBox("$PSQ_StorageReturnQuitFailed")
              ElseIf Action35 == 63
                f35[1] = PlayerRef.GetActorValue("Health")
              ElseIf Action35 == 70
                f35[1] = PlayerRef.GetActorValue("Magicka")
              Else
                Return
              EndIf
            EndIf
          EndIf
        Else
          If Action35 < 157
            If Action35 < 115
              If Action35 == 77
                f35[1] = PlayerRef.GetActorValue("Stamina")
              ElseIf Action35 == 114
                f35[1] = PlayerRef.GetActorValueMax("Health")
              Else
                Return
              EndIf
            Else
              If Action35 == 115
                PlayerRef.RestoreActorValue("Health", f35[1])
              ElseIf Action35 == 121
                self.SettleTransformEnergy()
              ElseIf Action35 == 151
                self.StopRankUpAnimation()
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 181
              If Action35 == 157
                self.ClearContinuousRankEffects(i35[0], -1)
              ElseIf Action35 == 175
                self.ClearPSQSLIFOutput()
              Else
                Return
              EndIf
            Else
              If Action35 == 181
                self.ResetRankMagicCostReduction()
              ElseIf Action35 == 187
                self.ClearEnergyDisplay()
              ElseIf Action35 == 199
                self.SetDefaultSuccubusTattoo(false)
              Else
                Return
              EndIf
            EndIf
          EndIf
        EndIf
      Else
        If Action35 < 252
          If Action35 < 238
            If Action35 < 217
              If Action35 == 205
                b35[0] = (self.SetSuccubusTattooOverlay("Body [Ovl5]", "PSQ_BuiltinBody", "", false, true, true)) as Int
              ElseIf Action35 == 211
                b35[0] = (self.SetSuccubusTattooOverlay("Hands [Ovl2]", "PSQ_BuiltinHands", "", false, true, true)) as Int
              Else
                Return
              EndIf
            Else
              If Action35 == 217
                b35[0] = (self.SetSuccubusTattooOverlay("Feet [Ovl2]", "PSQ_BuiltinFeet", "", false, true, true)) as Int
              ElseIf Action35 == 223
                b35[0] = (self.SetSuccubusTattooOverlay("Face [Ovl2]", "PSQ_BuiltinFace", "", false, true, true)) as Int
              ElseIf Action35 == 229
                self.ReleaseDragonbornTattoo(true)
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 240
              If Action35 == 238
                PlayerIsSuccubus.SetValue(0.0)
              ElseIf Action35 == 239
                self.SyncSatiationSkillPerks(1)
              Else
                Return
              EndIf
            Else
              If Action35 == 240
                self.SyncWingflightPolicy()
              ElseIf Action35 == 242
                Temp35_temp3 = None as succubusenergybarupdate
                b35[0] = (SEBU == Temp35_temp3) as Int
              ElseIf Action35 == 245
                SEBU.SyncVisibility()
              Else
                Return
              EndIf
            EndIf
          EndIf
        Else
          If Action35 < 283
            If Action35 < 264
              If Action35 == 252
                SuccubusEnergy.SetValue(0.0)
              ElseIf Action35 == 258
                SuccubusRank.SetValue(0.0)
              Else
                Return
              EndIf
            Else
              If Action35 == 264
                self.UpdateRankShoutCooldownBonus()
              ElseIf Action35 == 271
                Temp35_temp4 = PlayerRef as form
                i35[1] = storageUtil.SetIntValue(Temp35_temp4, "PSQ_PlayerIsSuccubus", 0)
              ElseIf Action35 == 277
                HasWing.SetValue(0.0)
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 300
              If Action35 == 283
                self.ReleasePSQJumpHeight()
              ElseIf Action35 == 291
                self.DisableEnterSoulCairn()
              Else
                Return
              EndIf
            Else
              If Action35 == 300
                Temp35_temp6 = PlayerRef as objectreference
                SuccubusTransFXS.Play(Temp35_temp6, 0.5)
              ElseIf Action35 == 306
                self.RemoveTransformBuffSafely(i35[0], -1)
              ElseIf Action35 == 319
                self.RestoreOriginalPlayerEyes(i35[0], (b35[1] as Bool))
              Else
                Return
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    Else
      If Action35 < 466
        If Action35 < 393
          If Action35 < 354
            If Action35 < 340
              If Action35 == 326
                b35[0] = (self.HasOriginalTransformSkinColor()) as Int
              ElseIf Action35 == 330
                Temp35_temp7 = None as colorform
                b35[0] = (OrgHairColor == Temp35_temp7) as Int
              Else
                Return
              EndIf
            Else
              If Action35 == 340
                self.RestoreTransformBodyMorphs(false, i35[0], (b35[1] as Bool))
              ElseIf Action35 == 347
                b35[0] = (self.RestoreTransformSkinColor(i35[0], (b35[1] as Bool))) as Int
              ElseIf Action35 == 353
                self.RestoreTransformHair(i35[0], (b35[1] as Bool))
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 372
              If Action35 == 354
                b35[0] = (self.RestoreOriginalPlayerHairColor(i35[0], (b35[1] as Bool))) as Int
              ElseIf Action35 == 360
                self.RestoreTransformEquipment(i35[0], (b35[1] as Bool))
              Else
                Return
              EndIf
            Else
              If Action35 == 372
                self.RefreshEquippedTransformBody(i35[0], (b35[1] as Bool))
              ElseIf Action35 == 380
                PlayerRef.QueueNiNodeUpdate()
              ElseIf Action35 == 387
                PlayerRef.RemoveFromFaction(SuccubusFoeFaction)
              Else
                Return
              EndIf
            EndIf
          EndIf
        Else
          If Action35 < 427
            If Action35 < 406
              If Action35 == 393
                PlayerRef.SetAttackActorOnSight(false)
              ElseIf Action35 == 399
                TransformBooster.SetValue(0.0)
              Else
                Return
              EndIf
            Else
              If Action35 == 406
                self.SyncAWUWing()
              ElseIf Action35 == 413
                Temp35_temp8 = None as armor
                OrgArmor = Temp35_temp8
              ElseIf Action35 == 420
                Temp35_temp8 = None as armor
                OrgGloves = Temp35_temp8
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 441
              If Action35 == 427
                Temp35_temp8 = None as armor
                OrgBoots = Temp35_temp8
              ElseIf Action35 == 434
                Temp35_temp8 = None as armor
                OrgHorns = Temp35_temp8
              Else
                Return
              EndIf
            Else
              If Action35 == 441
                Temp35_temp8 = None as armor
                OrgWings = Temp35_temp8
              ElseIf Action35 == 448
                Temp35_temp8 = None as armor
                OrgTail = Temp35_temp8
              ElseIf Action35 == 455
                self.ReleaseTransformSlot52(false, i35[0], (b35[1] as Bool))
              Else
                Return
              EndIf
            EndIf
          EndIf
        EndIf
      Else
        If Action35 < 822
          If Action35 < 557
            If Action35 < 478
              If Action35 == 466
                self.SetScaleHuman(i35[0], (b35[1] as Bool))
              ElseIf Action35 == 472
                self.ApplyBreastScaleIfChanged(1.0, i35[0], (b35[1] as Bool))
              Else
                Return
              EndIf
            Else
              If Action35 == 478
                PlayerRef.RemoveFromFaction(SuccubusFoeFaction)
              ElseIf Action35 == 484
                PlayerRef.SetAttackActorOnSight(false)
              ElseIf Action35 == 491
                Temp35_temp4 = PlayerRef as form
                i35[1] = storageUtil.SetIntValue(Temp35_temp4, "PSQ_SuccubusON", 0)
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 569
              If Action35 == 557
                self.ClearManagedMovement()
              ElseIf Action35 == 563
                StableCachedSatiationInputs = EmptyFloatArray
              Else
                Return
              EndIf
            Else
              If Action35 == 569
                StableAppliedSatiationMagnitudes = EmptyFloatArray
              ElseIf Action35 == 576
                Temp35_temp9 = None as spell
                StableAppliedSatiationSpell = Temp35_temp9
              ElseIf Action35 == 816
                self.StopEnergySense()
              Else
                Return
              EndIf
            EndIf
          EndIf
        Else
          If Action35 < 1012
            If Action35 < 829
              If Action35 == 822
                Temp35_temp9 = self.GetEnergySenseSpell()
              ElseIf Action35 == 823
                b35[0] = (PlayerRef.RemoveSpell(Temp35_temp9)) as Int
              Else
                Return
              EndIf
            Else
              If Action35 == 829
                Temp35_temp9 = self.GetAproposRepairSpell()
              ElseIf Action35 == 830
                b35[0] = (PlayerRef.RemoveSpell(Temp35_temp9)) as Int
              ElseIf Action35 == 1010
                Temp35_temp9 = self.GetRoseStormSpell()
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 1188
              If Action35 == 1012
                RoseStorm = Temp35_temp9
                b35[0] = (RoseStorm as bool) as Int
              ElseIf Action35 == 1019
                b35[0] = (PlayerRef.RemoveSpell(RoseStorm)) as Int
              ElseIf Action35 == 1182
                self.SetBellyScale()
              Else
                Return
              EndIf
            Else
              If Action35 == 1188
                self.UnregisterSuccubusEvents()
              ElseIf Action35 == 1201
                self.RestoreRetirementPools(i35[0], (b35[1] as Bool))
              ElseIf Action35 == 1207
                self.EndAppearanceEdit(i35[0])
              Else
                Return
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndWhile
EndFunction

Function PSQStartSexCompat34(Form FormRef, Int TID)
  Int SceneEpoch = PSQSexSceneEpoch
  If UninstallPrepared || UninstallCleanupBusy || SexLab == None
    Return
  EndIf
  If PlayerIsSuccubus.GetValue() == 1.0
    sslthreadcontroller Thread = SexLab.GetController(TID)
    If Thread == None
      Return
    EndIf
    Actor[] actors = Thread.Positions
    Int NumberOfActors = actors.Length
    SexTimer = Utility.GetCurrentRealTime()
    If actors.find(PlayerRef, 0) >= 0
      Bool IsRape
      Self.BeginPPlusScene(actors, TID)
      If Thread.VictimRef != None
        IsRape = True
      EndIf
      If NumberOfActors == 1
        If PSQLureMSGBox.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) == 0
          PlayerRef.AddSpell(PSQLureCastSpell, False)
        EndIf
      EndIf
      Int i = NumberOfActors - 1
      While i >= 0
        Int Aractor = i
        storageutil.SetIntValue(actors[Aractor] as Form, "PSQ_ArousalAtBeginning", Self.GetActorArousal(actors[Aractor]))
        If IsRape
          actors[Aractor].AddSpell(SuccubusRapeVictimDebuffSpell, False)
        EndIf
        If actors[Aractor] != PlayerRef
          If SceneEpoch != PSQSexSceneEpoch
            Return
          EndIf
          Self.BeginDeferredDrain(actors[Aractor], TID)
          Self.SetEnergy(actors[Aractor])
        EndIf
        i -= 1
      EndWhile
    EndIf
  EndIf
EndFunction

Function PSQStartSex35(form FormRef, Int TID)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.PSQStartSexCompat34(FormRef,TID)
    Return
  EndIf
  Int[] i35 = new Int[9]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[3]
  Int Action35 = 0
  i35[0] = TID
  sexLabFramework Temp35_temp1
  sslThreadController Thread
  sslThreadController Temp35_temp3
  actor[] actors
  actor[] Temp35_temp4
  actor Temp35_temp6
  actor Temp35_temp7
  form Temp35_temp8
  i35[6] = PSQLoadEpoch
  i35[7] = PSQSexSceneEpoch
  i35[8] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.PSQStartSexStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 42
      If Action35 < 27
        If Action35 == 8
          Temp35_temp1 = None as sexlabframework
          b35[0] = (SexLab == Temp35_temp1) as Int
        ElseIf Action35 == 16
          Temp35_temp3 = SexLab.GetController(i35[0])
        ElseIf Action35 == 19
          Thread = Temp35_temp3
          Temp35_temp3 = None as sslthreadcontroller
          b35[0] = (Thread == Temp35_temp3) as Int
        ElseIf Action35 == 25
          Temp35_temp4 = Thread.Positions
          actors = Temp35_temp4
          i35[3] = actors.Length
        Else
          Return
        EndIf
      Else
        If Action35 == 27
          f35[0] = utility.GetCurrentRealTime()
        ElseIf Action35 == 29
          i35[3] = actors.Find(PlayerRef, 0)
        ElseIf Action35 == 32
          self.BeginPPlusScene(actors, i35[0], true)
        ElseIf Action35 == 35
          Temp35_temp6 = Thread.VictimRef
          Temp35_temp7 = None as actor
          b35[0] = (Temp35_temp6 == Temp35_temp7) as Int
        Else
          Return
        EndIf
      EndIf
    Else
      If Action35 < 60
        If Action35 == 42
          i35[3] = PSQLureMSGBox.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        ElseIf Action35 == 45
          b35[0] = (PlayerRef.AddSpell(PSQLureCastSpell, false)) as Int
        ElseIf Action35 == 56
          Temp35_temp7 = actors[i35[5]]
          Temp35_temp8 = Temp35_temp7 as form
          Temp35_temp7 = actors[i35[5]]
          i35[3] = self.GetActorArousal(Temp35_temp7)
        ElseIf Action35 == 57
          i35[3] = storageUtil.SetIntValue(Temp35_temp8, "PSQ_ArousalAtBeginning", i35[3])
        Else
          Return
        EndIf
      Else
        If Action35 == 60
          Temp35_temp7 = actors[i35[5]]
          b35[0] = (Temp35_temp7.AddSpell(SuccubusRapeVictimDebuffSpell, false)) as Int
        ElseIf Action35 == 63
          Temp35_temp7 = actors[i35[5]]
          b35[0] = (Temp35_temp7 == PlayerRef) as Int
        ElseIf Action35 == 72
          Temp35_temp7 = actors[i35[5]]
          self.BeginDeferredDrain(Temp35_temp7, i35[0])
        ElseIf Action35 == 74
          Temp35_temp7 = actors[i35[5]]
          self.SetEnergy(Temp35_temp7)
        Else
          Return
        EndIf
      EndIf
    EndIf
  EndWhile
EndFunction

Function PSQOrgasmCompat34(Form FormRef, Int TID)
  if Self.IsFastModeClosingScene(TID)
    return
  endif
  Int Epoch = PSQSexSceneEpoch
  Int Generation = FastModeCallbackGeneration
  String CallbackKey = Self.GetFastModeCallbackKey(TID, Generation, Epoch)
  StorageUtil.AdjustIntValue(Self as Form, CallbackKey, 1)
  ; Recheck after acquiring the count: closing may have started after entry.
  if !Self.IsFastModeClosingScene(TID) && Epoch == PSQSexSceneEpoch && Generation == FastModeCallbackGeneration
    Self.PSQOrgasmCore(FormRef, TID)
  endif
  Self.ReleaseFastModeCallback(CallbackKey, Generation, Epoch)
  if Epoch == PSQSexSceneEpoch && Generation == FastModeCallbackGeneration
    if FastMode
      Self.TryEndExhaustedFastScene(TID, FastModeSceneSerial, Epoch)
    endif
  endif
EndFunction

Function PSQOrgasm35(form FormRef, Int TID)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.PSQOrgasmCompat34(FormRef,TID)
    Return
  EndIf
  Int[] i35 = new Int[7]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[2]
  Int Action35 = 0
  i35[0] = TID
  String CallbackKey
  String Temp35_temp1
  form Temp35_temp2
  i35[4] = PSQLoadEpoch
  i35[5] = PSQSexSceneEpoch
  i35[6] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.PSQOrgasmStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 11
      If Action35 == 1
        b35[0] = (self.IsFastModeClosingScene(i35[0])) as Int
      ElseIf Action35 == 7
        Temp35_temp1 = self.GetFastModeCallbackKey(i35[0], i35[2], i35[1])
      ElseIf Action35 == 10
        CallbackKey = Temp35_temp1
        Temp35_temp2 = self as form
        i35[3] = storageUtil.AdjustIntValue(Temp35_temp2, CallbackKey, 1)
      Else
        Return
      EndIf
    Else
      If Action35 == 11
        b35[0] = (self.IsFastModeClosingScene(i35[0])) as Int
      ElseIf Action35 == 22
        self.PSQOrgasmCore(FormRef, i35[0])
      ElseIf Action35 == 24
        self.ReleaseFastModeCallback(CallbackKey, i35[2], i35[1])
      ElseIf Action35 == 32
        self.TryEndExhaustedFastScene(i35[0], FastModeSceneSerial, i35[1])
      Else
        Return
      EndIf
    EndIf
  EndWhile
EndFunction

Function PSQOrgasmCoreCompat34(Form FormRef, Int TID)
  Int SceneEpoch = PSQSexSceneEpoch
  If Self.IsSexLabPPlus() || Self.IsLegacySeparateOrgasmMode() || UninstallPrepared || UninstallCleanupBusy || SexLab == None
    Return
  EndIf
  If PlayerIsSuccubus.GetValue() == 1.0
    sslthreadcontroller Thread = SexLab.GetController(TID)
    If Thread == None
      Return
    EndIf
    sslbaseanimation animation = Thread.animation
    If animation == None
      Return
    EndIf
    Actor[] actors = Thread.Positions
    Int NumberOfActors = actors.Length
    If actors.find(PlayerRef, 0) >= 0
      If NumberOfActors == 1
        Self.AddSuccubusFluid()
      Else
        Bool PlayerIsFemalePosition
        Bool OralCum
        Bool CanCumInflation
        Bool CanExtractSemenPotion
        Bool CanImpregnant = False
        If Thread.ActorAlias(PlayerRef).MalePosition == False
          PlayerIsFemalePosition = True
        EndIf
        If PlayerIsFemalePosition
          Bool VaginalCum
          Bool AnalCum
          Int PlayerPosition
          Int PP = NumberOfActors - 1
          While PP >= 0
            If actors[PP] == PlayerRef
              PlayerPosition = PP
              PP -= 100
            EndIf
            PP -= 1
          EndWhile
          Int CumID = animation.GetCumID(PlayerPosition, Thread.Stage)
          If CumID == 1 || CumID == 4 || CumID == 5 || CumID == 7
            VaginalCum = True
          EndIf
          If CumID == 3 || CumID == 5 || CumID == 6 || CumID == 7
            AnalCum = True
          EndIf
          If CumID == 2 || CumID == 4 || CumID == 6 || CumID == 7
            OralCum = True
          EndIf
          If CumID > 0
            CanExtractSemenPotion = True
          EndIf
          If EnableCumInflation
            If VaginalCum || CumInflationAnal && AnalCum || CumInflationOral && OralCum
              CanCumInflation = True
            EndIf
          EndIf
        EndIf
        Bool PlayerIsVictim = False
        Bool PlayerIsAggressor = False
        If Thread.IsVictim(PlayerRef)
          PlayerIsVictim = True
        EndIf
        If Thread.IsAggressor(PlayerRef)
          PlayerIsAggressor = True
        EndIf
        CumInflationValue = 0.0
        storageutil.SetFloatValue(PlayerRef as Form, "PSQ_IncreaseEXP", 0.0)
        Float SexTime = Thread.TotalTime
        If FastMode
          SexTime = FastModeTime
        EndIf
        Float DrainValue = SexTime * DrainValueMultipliers * SuccubusRank.GetValue()
        If UseArousalAtDrain
          Float ArousedRank = storageutil.GetIntValue(PlayerRef as Form, "PSQ_ArousalAtBeginning", 0) as Float
          If ArousedRank < 50.0
            ArousedRank = 50.0
          EndIf
          DrainValue *= ArousedRank / 50.0
        EndIf
        If PlayerIsAggressor
          DrainValue *= 2.0
        EndIf
        Int i = NumberOfActors - 1
        While i >= 0
          Int Victim = i
          If actors[Victim] != PlayerRef
            Bool IsMalePosition
            Bool RealPenis
            Bool AllowDrain = Self.IsNotUndead(actors[Victim])
            If !Thread.ActorAlias(actors[Victim]).IsUsingStrapon()
              RealPenis = True
            EndIf
            If Thread.ActorAlias(actors[Victim]).MalePosition || !actors[Victim].HasKeywordString("ActorTypeNPC")
              IsMalePosition = True
            EndIf
            If AllowDrain
              If SceneEpoch != PSQSexSceneEpoch
                Return
              EndIf
              If Self.EnsureDeferredDrain(actors[Victim], TID)
                Self.SuccubusDrain(actors[Victim], DrainValue, PlayerIsVictim, PlayerIsAggressor, CanExtractSemenPotion, CanImpregnant, OralCum, CanCumInflation, IsMalePosition, RealPenis)
              EndIf
            EndIf
            If Self.IsFamiliar(actors[Victim])
              Self.ChargeFamiliar(actors[Victim])
            EndIf
            If EnableCaptive
              Self.Captive(actors[Victim], DrainValue)
            EndIf
          EndIf
          i -= 1
        EndWhile
        If CanCumInflation
          CumInflationSpell.Cast(PlayerRef as ObjectReference, None)
        EndIf
        Self.Satiety(0.0)
        Self.SatietyNotification(0.0, False)
        Self.SuccubusLevelUp(storageutil.GetFloatValue(PlayerRef as Form, "PSQ_IncreaseEXP", 0.0))
      EndIf
      SexTimer = Utility.GetCurrentRealTime()
    EndIf
  EndIf
EndFunction

Function PSQOrgasmCore35(form FormRef, Int TID)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.PSQOrgasmCoreCompat34(FormRef,TID)
    Return
  EndIf
  Int[] i35 = new Int[12]
  Float[] f35 = new Float[5]
  Int[] b35 = new Int[14]
  Int Action35 = 0
  i35[0] = TID
  sexLabFramework Temp35_temp1
  sslThreadController Thread
  sslThreadController Temp35_temp3
  sslBaseAnimation animation
  sslBaseAnimation Temp35_temp4
  actor[] actors
  actor[] Temp35_temp5
  sslActorAlias Temp35_temp7
  actor Temp35_temp8
  form Temp35_temp9
  objectReference Temp35_temp11
  objectReference Temp35_temp12
  i35[9] = PSQLoadEpoch
  i35[10] = PSQSexSceneEpoch
  i35[11] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.PSQOrgasmCoreStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 189
      If Action35 < 50
        If Action35 < 27
          If Action35 == 2
            b35[0] = (self.IsSexLabPPlus()) as Int
          ElseIf Action35 == 5
            b35[0] = (self.IsLegacySeparateOrgasmMode()) as Int
          ElseIf Action35 == 16
            Temp35_temp1 = None as sexlabframework
            b35[0] = (SexLab == Temp35_temp1) as Int
          ElseIf Action35 == 24
            Temp35_temp3 = SexLab.GetController(i35[0])
          Else
            Return
          EndIf
        Else
          If Action35 < 40
            If Action35 == 27
              Thread = Temp35_temp3
              Temp35_temp3 = None as sslthreadcontroller
              b35[0] = (Thread == Temp35_temp3) as Int
            ElseIf Action35 == 34
              Temp35_temp4 = Thread.Animation
              animation = Temp35_temp4
              Temp35_temp4 = None as sslbaseanimation
              b35[0] = (animation == Temp35_temp4) as Int
            Else
              Return
            EndIf
          Else
            If Action35 == 40
              Temp35_temp5 = Thread.Positions
              actors = Temp35_temp5
              i35[3] = actors.Length
            ElseIf Action35 == 42
              i35[3] = actors.Find(PlayerRef, 0)
            ElseIf Action35 == 47
              self.AddSuccubusFluid()
            Else
              Return
            EndIf
          EndIf
        EndIf
      Else
        If Action35 < 146
          If Action35 == 50
            Temp35_temp7 = Thread.ActorAlias(PlayerRef)
          ElseIf Action35 == 51
            b35[0] = (Temp35_temp7.MalePosition) as Int
          ElseIf Action35 == 62
            Temp35_temp8 = actors[i35[5]]
            b35[0] = (Temp35_temp8 == PlayerRef) as Int
          ElseIf Action35 == 72
            i35[3] = Thread.Stage
            i35[3] = animation.GetCumID(i35[4], i35[3])
          Else
            Return
          EndIf
        Else
          If Action35 < 156
            If Action35 == 146
              b35[0] = (Thread.IsVictim(PlayerRef)) as Int
            ElseIf Action35 == 150
              b35[0] = (Thread.IsAggressor(PlayerRef)) as Int
            Else
              Return
            EndIf
          Else
            If Action35 == 156
              Temp35_temp9 = PlayerRef as form
              f35[0] = storageUtil.SetFloatValue(Temp35_temp9, "PSQ_IncreaseEXP", 0.0)
            ElseIf Action35 == 157
              f35[0] = Thread.TotalTime
            ElseIf Action35 == 168
              Temp35_temp9 = PlayerRef as form
              i35[3] = storageUtil.GetIntValue(Temp35_temp9, "PSQ_ArousalAtBeginning", 0)
            Else
              Return
            EndIf
          EndIf
        EndIf
      EndIf
    Else
      If Action35 < 228
        If Action35 < 203
          If Action35 == 189
            Temp35_temp8 = actors[i35[8]]
            b35[0] = (Temp35_temp8 == PlayerRef) as Int
          ElseIf Action35 == 193
            Temp35_temp8 = actors[i35[8]]
            b35[0] = (self.IsNotUndead(Temp35_temp8)) as Int
          ElseIf Action35 == 196
            Temp35_temp8 = actors[i35[8]]
            Temp35_temp7 = Thread.ActorAlias(Temp35_temp8)
          ElseIf Action35 == 197
            b35[0] = (Temp35_temp7.IsUsingStrapon()) as Int
          Else
            Return
          EndIf
        Else
          If Action35 < 208
            If Action35 == 203
              Temp35_temp8 = actors[i35[8]]
              Temp35_temp7 = Thread.ActorAlias(Temp35_temp8)
            ElseIf Action35 == 204
              b35[0] = (Temp35_temp7.MalePosition) as Int
            Else
              Return
            EndIf
          Else
            If Action35 == 208
              Temp35_temp8 = actors[i35[8]]
              b35[0] = (Temp35_temp8.HasKeywordString("ActorTypeNPC")) as Int
            ElseIf Action35 == 221
              Temp35_temp8 = actors[i35[8]]
              b35[0] = (self.EnsureDeferredDrain(Temp35_temp8, i35[0])) as Int
            ElseIf Action35 == 224
              Temp35_temp8 = actors[i35[8]]
              self.SuccubusDrain(Temp35_temp8, f35[2], (b35[8] as Bool), (b35[9] as Bool), (b35[4] as Bool), (b35[5] as Bool), (b35[2] as Bool), (b35[3] as Bool), (b35[10] as Bool), (b35[11] as Bool))
            Else
              Return
            EndIf
          EndIf
        EndIf
      Else
        If Action35 < 246
          If Action35 == 228
            Temp35_temp8 = actors[i35[8]]
            b35[0] = (self.IsFamiliar(Temp35_temp8)) as Int
          ElseIf Action35 == 231
            Temp35_temp8 = actors[i35[8]]
            f35[3] = self.ChargeFamiliar(Temp35_temp8)
          ElseIf Action35 == 235
            Temp35_temp8 = actors[i35[8]]
            self.Captive(Temp35_temp8, f35[2])
          ElseIf Action35 == 244
            Temp35_temp11 = PlayerRef as objectreference
            Temp35_temp12 = None as objectreference
            CumInflationSpell.Cast(Temp35_temp11, Temp35_temp12)
          Else
            Return
          EndIf
        Else
          If Action35 < 249
            If Action35 == 246
              self.Satiety(0.0)
            ElseIf Action35 == 247
              self.SatietyNotification(0.0, false)
            Else
              Return
            EndIf
          Else
            If Action35 == 249
              Temp35_temp9 = PlayerRef as form
              f35[3] = storageUtil.GetFloatValue(Temp35_temp9, "PSQ_IncreaseEXP", 0.0)
            ElseIf Action35 == 250
              self.SuccubusLevelUp(f35[3])
            ElseIf Action35 == 251
              f35[3] = utility.GetCurrentRealTime()
            Else
              Return
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndWhile
EndFunction

Function PSQOrgasmSeparateCompat34(Form FormRef, Int TID)
  if Self.IsFastModeClosingScene(TID)
    return
  endif
  Int Epoch = PSQSexSceneEpoch
  Int Generation = FastModeCallbackGeneration
  String CallbackKey = Self.GetFastModeCallbackKey(TID, Generation, Epoch)
  StorageUtil.AdjustIntValue(Self as Form, CallbackKey, 1)
  ; Recheck after acquiring the count: closing may have started after entry.
  if !Self.IsFastModeClosingScene(TID) && Epoch == PSQSexSceneEpoch && Generation == FastModeCallbackGeneration
    Self.PSQOrgasmSeparateCore(FormRef, TID)
  endif
  Self.ReleaseFastModeCallback(CallbackKey, Generation, Epoch)
  if Epoch == PSQSexSceneEpoch && Generation == FastModeCallbackGeneration
    if FastMode
      Self.TryEndExhaustedFastScene(TID, FastModeSceneSerial, Epoch)
    endif
  endif
EndFunction

Function PSQOrgasmSeparate35(form FormRef, Int TID)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.PSQOrgasmSeparateCompat34(FormRef,TID)
    Return
  EndIf
  Int[] i35 = new Int[7]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[2]
  Int Action35 = 0
  i35[0] = TID
  String CallbackKey
  String Temp35_temp1
  form Temp35_temp2
  i35[4] = PSQLoadEpoch
  i35[5] = PSQSexSceneEpoch
  i35[6] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.PSQOrgasmSeparateStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 11
      If Action35 == 1
        b35[0] = (self.IsFastModeClosingScene(i35[0])) as Int
      ElseIf Action35 == 7
        Temp35_temp1 = self.GetFastModeCallbackKey(i35[0], i35[2], i35[1])
      ElseIf Action35 == 10
        CallbackKey = Temp35_temp1
        Temp35_temp2 = self as form
        i35[3] = storageUtil.AdjustIntValue(Temp35_temp2, CallbackKey, 1)
      Else
        Return
      EndIf
    Else
      If Action35 == 11
        b35[0] = (self.IsFastModeClosingScene(i35[0])) as Int
      ElseIf Action35 == 22
        self.PSQOrgasmSeparateCore(FormRef, i35[0])
      ElseIf Action35 == 24
        self.ReleaseFastModeCallback(CallbackKey, i35[2], i35[1])
      ElseIf Action35 == 32
        self.TryEndExhaustedFastScene(i35[0], FastModeSceneSerial, i35[1])
      Else
        Return
      EndIf
    EndIf
  EndWhile
EndFunction

Function PSQOrgasmSeparateCoreCompat34(Form FormRef, Int TID)
  Int SceneEpoch = PSQSexSceneEpoch
  If UninstallPrepared || UninstallCleanupBusy
    Return
  EndIf
  If Self.IsSexLabPPlus()
    Self.PSQPPlusOrgasm(FormRef, TID)
    Return
  EndIf
  If !Self.IsLegacySeparateOrgasmMode() || SexLab == None
    Return
  EndIf
  If PlayerIsSuccubus.GetValue() == 1.0
    sslthreadcontroller Thread = SexLab.GetController(TID)
    If Thread == None
      Return
    EndIf
    sslbaseanimation animation = Thread.animation
    If animation == None
      Return
    EndIf
    Actor[] actors = Thread.Positions
    Int NumberOfActors = actors.Length
    If actors.find(PlayerRef, 0) >= 0
      If NumberOfActors == 1
        Self.AddSuccubusFluid()
      Else
        Bool PlayerIsFemalePosition
        Bool OralCum
        Bool CanCumInflation
        Bool CanExtractSemenPotion
        Bool CanImpregnant = False
        If Thread.ActorAlias(PlayerRef).MalePosition == False
          PlayerIsFemalePosition = True
        EndIf
        If PlayerIsFemalePosition
          Bool VaginalCum
          Bool AnalCum
          Int PlayerPosition
          Int PP = NumberOfActors - 1
          While PP >= 0
            If actors[PP] == PlayerRef
              PlayerPosition = PP
              PP -= 100
            EndIf
            PP -= 1
          EndWhile
          Int CumID = animation.GetCumID(PlayerPosition, Thread.Stage)
          If CumID == 1 || CumID == 4 || CumID == 5 || CumID == 7
            VaginalCum = True
          EndIf
          If CumID == 3 || CumID == 5 || CumID == 6 || CumID == 7
            AnalCum = True
          EndIf
          If CumID == 2 || CumID == 4 || CumID == 6 || CumID == 7
            OralCum = True
          EndIf
          If CumID > 0
            CanExtractSemenPotion = True
          EndIf
          If EnableCumInflation
            If VaginalCum || CumInflationAnal && AnalCum || CumInflationOral && OralCum
              CanCumInflation = True
            EndIf
          EndIf
        EndIf
        Bool PlayerIsVictim = False
        Bool PlayerIsAggressor = False
        If Thread.IsVictim(PlayerRef)
          PlayerIsVictim = True
        EndIf
        If Thread.IsAggressor(PlayerRef)
          PlayerIsAggressor = True
        EndIf
        CumInflationValue = 0.0
        storageutil.SetFloatValue(PlayerRef as Form, "PSQ_IncreaseEXP", 0.0)
        Float SexTime = Utility.GetCurrentRealTime() - SexTimer
        If FastMode
          SexTime = FastModeTime
        EndIf
        Float DrainValue = SexTime * DrainValueMultipliers * SuccubusRank.GetValue()
        If UseArousalAtDrain
          Float ArousedRank = storageutil.GetIntValue(PlayerRef as Form, "PSQ_ArousalAtBeginning", 0) as Float
          If ArousedRank < 50.0
            ArousedRank = 50.0
          EndIf
          DrainValue *= ArousedRank / 50.0
        EndIf
        If PlayerIsAggressor
          DrainValue *= 2.0
        EndIf
        Int i = NumberOfActors - 1
        While i >= 0
          Int Victim = i
          If actors[Victim] != PlayerRef
            Bool IsMalePosition
            Bool RealPenis
            Bool AllowDrain = Self.IsNotUndead(actors[Victim])
            If !Thread.ActorAlias(actors[Victim]).IsUsingStrapon()
              RealPenis = True
            EndIf
            If Thread.ActorAlias(actors[Victim]).MalePosition || !actors[Victim].HasKeywordString("ActorTypeNPC")
              IsMalePosition = True
            EndIf
            If AllowDrain
              If SceneEpoch != PSQSexSceneEpoch
                Return
              EndIf
              If Self.EnsureDeferredDrain(actors[Victim], TID)
                Self.SuccubusDrain(actors[Victim], DrainValue, PlayerIsVictim, PlayerIsAggressor, CanExtractSemenPotion, CanImpregnant, OralCum, CanCumInflation, IsMalePosition, RealPenis)
              EndIf
            EndIf
            If Self.IsFamiliar(actors[Victim])
              Self.ChargeFamiliar(actors[Victim])
            EndIf
            If EnableCaptive
              Self.Captive(actors[Victim], DrainValue)
            EndIf
          EndIf
          i -= 1
        EndWhile
        If CanCumInflation
          CumInflationSpell.Cast(PlayerRef as ObjectReference, None)
        EndIf
        Self.Satiety(0.0)
        Self.SatietyNotification(0.0, False)
        Self.SuccubusLevelUp(storageutil.GetFloatValue(PlayerRef as Form, "PSQ_IncreaseEXP", 0.0))
      EndIf
      SexTimer = Utility.GetCurrentRealTime()
    EndIf
  EndIf
EndFunction

Function PSQOrgasmSeparateCore35(form FormRef, Int TID)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.PSQOrgasmSeparateCoreCompat34(FormRef,TID)
    Return
  EndIf
  Int[] i35 = new Int[12]
  Float[] f35 = new Float[5]
  Int[] b35 = new Int[14]
  Int Action35 = 0
  i35[0] = TID
  sexLabFramework Temp35_temp1
  sslThreadController Thread
  sslThreadController Temp35_temp3
  sslBaseAnimation animation
  sslBaseAnimation Temp35_temp4
  actor[] actors
  actor[] Temp35_temp5
  sslActorAlias Temp35_temp7
  actor Temp35_temp8
  form Temp35_temp9
  objectReference Temp35_temp11
  objectReference Temp35_temp12
  i35[9] = PSQLoadEpoch
  i35[10] = PSQSexSceneEpoch
  i35[11] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.PSQOrgasmSeparateCoreStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 171
      If Action35 < 49
        If Action35 < 26
          If Action35 == 8
            b35[0] = (self.IsSexLabPPlus()) as Int
          ElseIf Action35 == 10
            self.PSQPPlusOrgasm(FormRef, i35[0])
          ElseIf Action35 == 13
            b35[0] = (self.IsLegacySeparateOrgasmMode()) as Int
          ElseIf Action35 == 18
            Temp35_temp1 = None as sexlabframework
            b35[0] = (SexLab == Temp35_temp1) as Int
          Else
            Return
          EndIf
        Else
          If Action35 < 36
            If Action35 == 26
              Temp35_temp3 = SexLab.GetController(i35[0])
            ElseIf Action35 == 29
              Thread = Temp35_temp3
              Temp35_temp3 = None as sslthreadcontroller
              b35[0] = (Thread == Temp35_temp3) as Int
            Else
              Return
            EndIf
          Else
            If Action35 == 36
              Temp35_temp4 = Thread.Animation
              animation = Temp35_temp4
              Temp35_temp4 = None as sslbaseanimation
              b35[0] = (animation == Temp35_temp4) as Int
            ElseIf Action35 == 42
              Temp35_temp5 = Thread.Positions
              actors = Temp35_temp5
              i35[3] = actors.Length
            ElseIf Action35 == 44
              i35[3] = actors.Find(PlayerRef, 0)
            Else
              Return
            EndIf
          EndIf
        EndIf
      Else
        If Action35 < 74
          If Action35 == 49
            self.AddSuccubusFluid()
          ElseIf Action35 == 52
            Temp35_temp7 = Thread.ActorAlias(PlayerRef)
          ElseIf Action35 == 53
            b35[0] = (Temp35_temp7.MalePosition) as Int
          ElseIf Action35 == 64
            Temp35_temp8 = actors[i35[5]]
            b35[0] = (Temp35_temp8 == PlayerRef) as Int
          Else
            Return
          EndIf
        Else
          If Action35 < 152
            If Action35 == 74
              i35[3] = Thread.Stage
              i35[3] = animation.GetCumID(i35[4], i35[3])
            ElseIf Action35 == 148
              b35[0] = (Thread.IsVictim(PlayerRef)) as Int
            Else
              Return
            EndIf
          Else
            If Action35 == 152
              b35[0] = (Thread.IsAggressor(PlayerRef)) as Int
            ElseIf Action35 == 158
              Temp35_temp9 = PlayerRef as form
              f35[0] = storageUtil.SetFloatValue(Temp35_temp9, "PSQ_IncreaseEXP", 0.0)
            ElseIf Action35 == 159
              f35[0] = utility.GetCurrentRealTime()
            Else
              Return
            EndIf
          EndIf
        EndIf
      EndIf
    Else
      If Action35 < 227
        If Action35 < 200
          If Action35 == 171
            Temp35_temp9 = PlayerRef as form
            i35[3] = storageUtil.GetIntValue(Temp35_temp9, "PSQ_ArousalAtBeginning", 0)
          ElseIf Action35 == 192
            Temp35_temp8 = actors[i35[8]]
            b35[0] = (Temp35_temp8 == PlayerRef) as Int
          ElseIf Action35 == 196
            Temp35_temp8 = actors[i35[8]]
            b35[0] = (self.IsNotUndead(Temp35_temp8)) as Int
          ElseIf Action35 == 199
            Temp35_temp8 = actors[i35[8]]
            Temp35_temp7 = Thread.ActorAlias(Temp35_temp8)
          Else
            Return
          EndIf
        Else
          If Action35 < 207
            If Action35 == 200
              b35[0] = (Temp35_temp7.IsUsingStrapon()) as Int
            ElseIf Action35 == 206
              Temp35_temp8 = actors[i35[8]]
              Temp35_temp7 = Thread.ActorAlias(Temp35_temp8)
            Else
              Return
            EndIf
          Else
            If Action35 == 207
              b35[0] = (Temp35_temp7.MalePosition) as Int
            ElseIf Action35 == 211
              Temp35_temp8 = actors[i35[8]]
              b35[0] = (Temp35_temp8.HasKeywordString("ActorTypeNPC")) as Int
            ElseIf Action35 == 224
              Temp35_temp8 = actors[i35[8]]
              b35[0] = (self.EnsureDeferredDrain(Temp35_temp8, i35[0])) as Int
            Else
              Return
            EndIf
          EndIf
        EndIf
      Else
        If Action35 < 249
          If Action35 < 234
            If Action35 == 227
              Temp35_temp8 = actors[i35[8]]
              self.SuccubusDrain(Temp35_temp8, f35[2], (b35[8] as Bool), (b35[9] as Bool), (b35[4] as Bool), (b35[5] as Bool), (b35[2] as Bool), (b35[3] as Bool), (b35[10] as Bool), (b35[11] as Bool))
            ElseIf Action35 == 231
              Temp35_temp8 = actors[i35[8]]
              b35[0] = (self.IsFamiliar(Temp35_temp8)) as Int
            Else
              Return
            EndIf
          Else
            If Action35 == 234
              Temp35_temp8 = actors[i35[8]]
              f35[3] = self.ChargeFamiliar(Temp35_temp8)
            ElseIf Action35 == 238
              Temp35_temp8 = actors[i35[8]]
              self.Captive(Temp35_temp8, f35[2])
            ElseIf Action35 == 247
              Temp35_temp11 = PlayerRef as objectreference
              Temp35_temp12 = None as objectreference
              CumInflationSpell.Cast(Temp35_temp11, Temp35_temp12)
            Else
              Return
            EndIf
          EndIf
        Else
          If Action35 < 252
            If Action35 == 249
              self.Satiety(0.0)
            ElseIf Action35 == 250
              self.SatietyNotification(0.0, false)
            Else
              Return
            EndIf
          Else
            If Action35 == 252
              Temp35_temp9 = PlayerRef as form
              f35[3] = storageUtil.GetFloatValue(Temp35_temp9, "PSQ_IncreaseEXP", 0.0)
            ElseIf Action35 == 253
              self.SuccubusLevelUp(f35[3])
            ElseIf Action35 == 254
              f35[3] = utility.GetCurrentRealTime()
            Else
              Return
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndWhile
EndFunction

Function PSQEndSexCompat34(Form FormRef, Int TID)
  Int SceneEpoch = PSQSexSceneEpoch
  If UninstallPrepared || UninstallCleanupBusy || SexLab == None
    Return
  EndIf
  If PlayerIsSuccubus.GetValue() == 1.0
    sslthreadcontroller Thread = SexLab.GetController(TID)
    If Thread == None
      Return
    EndIf
    sslbaseanimation animation = Thread.animation
    Actor[] actors = Thread.Positions
    If Self.IsSexLabPPlus()
      Utility.Wait(0.200000003)
      Int EndWaits = 0
      While (PPlusSettlementBusy || PPlusCallbacksPending > 0) && EndWaits < 200
        Utility.Wait(0.100000001)
        EndWaits += 1
      EndWhile
      If PPlusThreadID == TID
        PPlusSceneClosed = True
      EndIf
      If PPlusSettlementBusy || PPlusCallbacksPending > 0
        Debug.Trace("[PSQ SLCompat] P+ end wait expired: tid=" + TID as String, 0)
      EndIf
    EndIf
    If SceneEpoch != PSQSexSceneEpoch
      Return
    EndIf
    Int NumberOfActors = actors.Length
    Int i = actors.Length - 1
    While i >= 0
      actors[i].RemoveSpell(SuccubusRapeVictimDebuffSpell)
      actors[i].RemoveFromFaction(PSQRapeNoAttackFaction)
      If actors[i] != PlayerRef
        If SceneEpoch != PSQSexSceneEpoch
          Return
        EndIf
        Self.FlushDeferredDrain(actors[i], TID)
      EndIf
      i -= 1
    EndWhile
    PlayerRef.RemoveSpell(PSQLureCastSpell)
    If FishCount > 1
      Self.Fishery()
    EndIf
  EndIf
EndFunction

Function PSQEndSex35(form FormRef, Int TID)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.PSQEndSexCompat34(FormRef,TID)
    Return
  EndIf
  Int[] i35 = new Int[9]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[2]
  Int Action35 = 0
  i35[0] = TID
  sexLabFramework Temp35_temp1
  sslThreadController Thread
  sslThreadController Temp35_temp3
  sslBaseAnimation animation
  sslBaseAnimation Temp35_temp4
  actor[] actors
  actor[] Temp35_temp5
  String Temp35_temp7
  actor Temp35_temp8
  i35[6] = PSQLoadEpoch
  i35[7] = PSQSexSceneEpoch
  i35[8] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.PSQEndSexStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 63
      If Action35 < 27
        If Action35 == 8
          Temp35_temp1 = None as sexlabframework
          b35[0] = (SexLab == Temp35_temp1) as Int
        ElseIf Action35 == 16
          Temp35_temp3 = SexLab.GetController(i35[0])
        ElseIf Action35 == 19
          Thread = Temp35_temp3
          Temp35_temp3 = None as sslthreadcontroller
          b35[0] = (Thread == Temp35_temp3) as Int
        Else
          Return
        EndIf
      Else
        If Action35 == 27
          Temp35_temp4 = Thread.Animation
          animation = Temp35_temp4
          Temp35_temp5 = Thread.Positions
          actors = Temp35_temp5
          b35[0] = (self.IsSexLabPPlus()) as Int
        ElseIf Action35 == 29
          utility.Wait(0.2000000029802322)
        ElseIf Action35 == 40
          utility.Wait(0.1000000014901161)
        ElseIf Action35 == 55
          Temp35_temp7 = i35[0] as string
          Temp35_temp7 = "[PSQ SLCompat] P+ end wait expired: tid=" + Temp35_temp7
          debug.Trace(Temp35_temp7, 0)
        Else
          Return
        EndIf
      EndIf
    Else
      If Action35 < 73
        If Action35 == 63
          i35[3] = actors.Length
        ElseIf Action35 == 65
          i35[3] = actors.Length
        ElseIf Action35 == 71
          Temp35_temp8 = actors[i35[5]]
          b35[0] = (Temp35_temp8.RemoveSpell(SuccubusRapeVictimDebuffSpell)) as Int
        Else
          Return
        EndIf
      Else
        If Action35 == 73
          Temp35_temp8 = actors[i35[5]]
          Temp35_temp8.RemoveFromFaction(PSQRapeNoAttackFaction)
        ElseIf Action35 == 75
          Temp35_temp8 = actors[i35[5]]
          b35[0] = (Temp35_temp8 == PlayerRef) as Int
        ElseIf Action35 == 84
          Temp35_temp8 = actors[i35[5]]
          self.FlushDeferredDrain(Temp35_temp8, i35[0])
        ElseIf Action35 == 92
          self.Fishery()
        Else
          Return
        EndIf
      EndIf
    EndIf
  EndWhile
EndFunction

Function ResetPSQSexSceneStateCompat34()
  PSQSexSceneEpoch += 1
  Self.ResetFastModeEndState()
  Self.CleanupRetiredFastModeKeys()
  PPlusSceneClosed = True
  Int i = PPlusSceneActors.Length - 1
  While i >= 0
    Actor Target = PPlusSceneActors[i]
    If Target != None && Target != PlayerRef
      storageutil.UnsetFloatValue(Target as Form, "PSQ_DrainDamageHealth")
      storageutil.UnsetFloatValue(Target as Form, "PSQ_DrainDamageStamina")
      storageutil.UnsetIntValue(Target as Form, "PSQ_DeathMark")
      storageutil.UnsetIntValue(Target as Form, "PSQ_SoulTrapMark")
      storageutil.UnsetIntValue(Target as Form, "PSQ_DrainDamageThread")
      storageutil.UnsetIntValue(Target as Form, "PSQ_DrainClosedThread")
      storageutil.UnsetIntValue(Target as Form, "PSQ_DrainFlushClaims")
    EndIf
    i -= 1
  EndWhile
  PPlusThreadID = -1
  PPlusSettlementBusy = False
  PPlusCallbacksPending = 0
  PPlusSceneActors = EmptyActorArray
  PPlusDrainTimes = EmptyFloatArray
  Int[] EmptyCounts
  PPlusOrgasmCounts = EmptyCounts
  SexTimer = Utility.GetCurrentRealTime()
EndFunction

Function ResetPSQSexSceneState35()
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.ResetPSQSexSceneStateCompat34()
    Return
  EndIf
  Int[] i35 = new Int[5]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[2]
  Int Action35 = 0
  actor Target
  actor Temp35_temp2
  form Temp35_temp3
  Int[] EmptyCounts
  i35[2] = PSQLoadEpoch
  i35[3] = PSQSexSceneEpoch
  i35[4] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.ResetPSQSexSceneStateStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 25
      If Action35 < 14
        If Action35 == 3
          self.ResetFastModeEndState(true)
        ElseIf Action35 == 4
          self.CleanupRetiredFastModeKeys()
        ElseIf Action35 == 6
          i35[0] = PPlusSceneActors.Length
        Else
          Return
        EndIf
      Else
        If Action35 == 14
          Temp35_temp2 = PPlusSceneActors[i35[1]]
          Target = Temp35_temp2
          Temp35_temp2 = None as actor
          b35[0] = (Target == Temp35_temp2) as Int
        ElseIf Action35 == 18
          b35[0] = (Target == PlayerRef) as Int
        ElseIf Action35 == 23
          Temp35_temp3 = Target as form
          b35[0] = (storageUtil.UnsetFloatValue(Temp35_temp3, "PSQ_DrainDamageHealth")) as Int
        Else
          Return
        EndIf
      EndIf
    Else
      If Action35 < 31
        If Action35 == 25
          Temp35_temp3 = Target as form
          b35[0] = (storageUtil.UnsetFloatValue(Temp35_temp3, "PSQ_DrainDamageStamina")) as Int
        ElseIf Action35 == 27
          Temp35_temp3 = Target as form
          b35[0] = (storageUtil.UnsetIntValue(Temp35_temp3, "PSQ_DeathMark")) as Int
        ElseIf Action35 == 29
          Temp35_temp3 = Target as form
          b35[0] = (storageUtil.UnsetIntValue(Temp35_temp3, "PSQ_SoulTrapMark")) as Int
        Else
          Return
        EndIf
      Else
        If Action35 == 31
          Temp35_temp3 = Target as form
          b35[0] = (storageUtil.UnsetIntValue(Temp35_temp3, "PSQ_DrainDamageThread")) as Int
        ElseIf Action35 == 33
          Temp35_temp3 = Target as form
          b35[0] = (storageUtil.UnsetIntValue(Temp35_temp3, "PSQ_DrainClosedThread")) as Int
        ElseIf Action35 == 35
          Temp35_temp3 = Target as form
          b35[0] = (storageUtil.UnsetIntValue(Temp35_temp3, "PSQ_DrainFlushClaims")) as Int
        ElseIf Action35 == 46
          PPlusSceneActors = EmptyActorArray
          PPlusDrainTimes = EmptyFloatArray
          PPlusOrgasmCounts = EmptyCounts
          f35[0] = utility.GetCurrentRealTime()
        Else
          Return
        EndIf
      EndIf
    EndIf
  EndWhile
EndFunction

Function BeginPPlusSceneCompat34(Actor[] actors, Int TID, Bool NewScene = True)
  Self.ResetFastModeEndState(NewScene)
  PPlusThreadID = TID
  PPlusSceneClosed = False
  PPlusSceneActors = actors
  PPlusDrainTimes = Utility.CreateFloatArray(PPlusSceneActors.Length, 0.0)
  PPlusOrgasmCounts = Utility.CreateIntArray(PPlusSceneActors.Length, 0)
EndFunction

Function BeginPPlusScene35(actor[] actors, Int TID, Bool NewScene)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.BeginPPlusSceneCompat34(actors,TID,NewScene)
    Return
  EndIf
  Int[] i35 = new Int[5]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[2]
  Int Action35 = 0
  i35[0] = TID
  b35[0] = (NewScene) as Int
  Float[] Temp35_temp1
  Int[] Temp35_temp2
  i35[2] = PSQLoadEpoch
  i35[3] = PSQSexSceneEpoch
  i35[4] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.BeginPPlusSceneStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 == 1
      self.ResetFastModeEndState((b35[0] as Bool))
    ElseIf Action35 == 6
      PPlusSceneActors = actors
      i35[1] = PPlusSceneActors.Length
      Temp35_temp1 = utility.CreateFloatArray(i35[1], 0.0)
    ElseIf Action35 == 9
      PPlusDrainTimes = Temp35_temp1
      i35[1] = PPlusSceneActors.Length
      Temp35_temp2 = utility.CreateIntArray(i35[1], 0)
    ElseIf Action35 == 10
      PPlusOrgasmCounts = Temp35_temp2
    Else
      Return
    EndIf
  EndWhile
EndFunction

Function PSQPPlusOrgasmCompat34(Form FormRef, Int TID)
  if Self.IsFastModeClosingScene(TID)
    return
  endif
  Int SceneEpoch = PSQSexSceneEpoch
  If !Self.IsSexLabPPlus() || UninstallPrepared || UninstallCleanupBusy || SexLab == None || PlayerIsSuccubus.GetValueInt() != 1
    Return
  EndIf
  Actor Source = FormRef as Actor
  If Source == None
    Return
  EndIf
  Int Generation = FastModeCallbackGeneration
  String CallbackKey = Self.GetFastModeCallbackKey(TID, Generation, SceneEpoch)
  StorageUtil.AdjustIntValue(Self as Form, CallbackKey, 1)
  PPlusCallbacksPending += 1
  if !Self.IsFastModeClosingScene(TID) && SceneEpoch == PSQSexSceneEpoch && Generation == FastModeCallbackGeneration
    Self.ProcessPPlusOrgasm(Source, TID)
  endif
  If SceneEpoch == PSQSexSceneEpoch && PPlusCallbacksPending > 0
    PPlusCallbacksPending -= 1
  EndIf
  Self.ReleaseFastModeCallback(CallbackKey, Generation, SceneEpoch)
  if SceneEpoch == PSQSexSceneEpoch && Generation == FastModeCallbackGeneration
    if FastMode
      Self.TryEndExhaustedFastScene(TID, FastModeSceneSerial, SceneEpoch)
    endif
  endif
EndFunction

Function PSQPPlusOrgasm35(form FormRef, Int TID)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.PSQPPlusOrgasmCompat34(FormRef,TID)
    Return
  EndIf
  Int[] i35 = new Int[7]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[2]
  Int Action35 = 0
  i35[0] = TID
  sexLabFramework Temp35_temp1
  actor Source
  actor Temp35_temp3
  String CallbackKey
  String Temp35_temp4
  form Temp35_temp5
  i35[4] = PSQLoadEpoch
  i35[5] = PSQSexSceneEpoch
  i35[6] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.PSQPPlusOrgasmStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 39
      If Action35 < 17
        If Action35 == 1
          b35[0] = (self.IsFastModeClosingScene(i35[0])) as Int
        ElseIf Action35 == 6
          b35[0] = (self.IsSexLabPPlus()) as Int
        Else
          Return
        EndIf
      Else
        If Action35 == 17
          Temp35_temp1 = None as sexlabframework
          b35[0] = (SexLab == Temp35_temp1) as Int
        ElseIf Action35 == 31
          Temp35_temp3 = FormRef as actor
          Source = Temp35_temp3
          Temp35_temp3 = None as actor
          b35[0] = (Source == Temp35_temp3) as Int
        ElseIf Action35 == 36
          Temp35_temp4 = self.GetFastModeCallbackKey(i35[0], i35[3], i35[1])
        Else
          Return
        EndIf
      EndIf
    Else
      If Action35 < 53
        If Action35 == 39
          CallbackKey = Temp35_temp4
          Temp35_temp5 = self as form
          i35[2] = storageUtil.AdjustIntValue(Temp35_temp5, CallbackKey, 1)
        ElseIf Action35 == 42
          b35[0] = (self.IsFastModeClosingScene(i35[0])) as Int
        Else
          Return
        EndIf
      Else
        If Action35 == 53
          self.ProcessPPlusOrgasm(Source, i35[0])
        ElseIf Action35 == 64
          self.ReleaseFastModeCallback(CallbackKey, i35[3], i35[1])
        ElseIf Action35 == 72
          self.TryEndExhaustedFastScene(i35[0], FastModeSceneSerial, i35[1])
        Else
          Return
        EndIf
      EndIf
    EndIf
  EndWhile
EndFunction

Function ProcessPPlusOrgasmCompat34(Actor Source, Int TID)
  Int Generation = FastModeCallbackGeneration
  if Self.IsFastModeClosingScene(TID)
    return
  endif
  Int SceneEpoch = PSQSexSceneEpoch
  If PPlusThreadID == TID && PPlusSceneClosed
    Return
  EndIf
  sslthreadcontroller Thread = SexLab.GetController(TID)
  If Thread == None
    Return
  EndIf
  Actor[] actors = Thread.Positions
  If actors.find(PlayerRef, 0) < 0 || actors.find(Source, 0) < 0
    Return
  EndIf
  Int Count = psqsexlabpplusbridge.GetOrgasmCount(Thread, Source)
  Float SceneTime = Thread.TotalTime
  Bool RealPenis = psqsexlabpplusbridge.IsSemenSource(Thread, Source)
  Int ContactMask = 0
  If RealPenis
    ContactMask = psqsexlabpplusbridge.GetContactMask(Thread, Source, PlayerRef)
  EndIf
  Bool PlayerIsVictim = Thread.IsVictim(PlayerRef)
  Bool PlayerIsAggressor = Thread.IsAggressor(PlayerRef)
  Int Attempts = 0
  While PPlusSettlementBusy && Attempts < 100
    Utility.Wait(0.100000001)
    Attempts += 1
  EndWhile
  If SceneEpoch != PSQSexSceneEpoch || Generation != FastModeCallbackGeneration || Self.IsFastModeClosingScene(TID) || PPlusSettlementBusy || UninstallPrepared || UninstallCleanupBusy || PPlusThreadID == TID && PPlusSceneClosed
    Debug.Trace("[PSQ SLCompat] Skipped unavailable P+ settlement: tid=" + TID as String, 0)
    Return
  EndIf
  PPlusSettlementBusy = True
  Self.SettlePPlusOrgasm(Source, TID, actors, Count, SceneTime, RealPenis, ContactMask, PlayerIsVictim, PlayerIsAggressor)
  If SceneEpoch == PSQSexSceneEpoch
    PPlusSettlementBusy = False
  EndIf
EndFunction

Function ProcessPPlusOrgasm35(actor Source, Int TID)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.ProcessPPlusOrgasmCompat34(Source,TID)
    Return
  EndIf
  Int[] i35 = new Int[10]
  Float[] f35 = new Float[2]
  Int[] b35 = new Int[5]
  Int Action35 = 0
  i35[0] = TID
  sslThreadController Thread
  sslThreadController Temp35_temp1
  actor[] actors
  actor[] Temp35_temp2
  String Temp35_temp5
  i35[7] = PSQLoadEpoch
  i35[8] = PSQSexSceneEpoch
  i35[9] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.ProcessPPlusOrgasmStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 37
      If Action35 < 23
        If Action35 == 2
          b35[0] = (self.IsFastModeClosingScene(i35[0])) as Int
        ElseIf Action35 == 14
          Temp35_temp1 = SexLab.GetController(i35[0])
        ElseIf Action35 == 17
          Thread = Temp35_temp1
          Temp35_temp1 = None as sslthreadcontroller
          b35[0] = (Thread == Temp35_temp1) as Int
        Else
          Return
        EndIf
      Else
        If Action35 == 23
          Temp35_temp2 = Thread.Positions
          actors = Temp35_temp2
          i35[3] = actors.Find(PlayerRef, 0)
        ElseIf Action35 == 27
          i35[3] = actors.Find(Source, 0)
        ElseIf Action35 == 33
          i35[3] = pSQSexLabPPlusBridge.GetOrgasmCount(Thread, Source)
        ElseIf Action35 == 35
          f35[1] = Thread.TotalTime
        Else
          Return
        EndIf
      EndIf
    Else
      If Action35 < 54
        If Action35 == 37
          b35[0] = (pSQSexLabPPlusBridge.IsSemenSource(Thread, Source)) as Int
        ElseIf Action35 == 41
          i35[3] = pSQSexLabPPlusBridge.GetContactMask(Thread, Source, PlayerRef)
        ElseIf Action35 == 44
          b35[0] = (Thread.IsVictim(PlayerRef)) as Int
        ElseIf Action35 == 46
          b35[0] = (Thread.IsAggressor(PlayerRef)) as Int
        Else
          Return
        EndIf
      Else
        If Action35 == 54
          utility.Wait(0.1000000014901161)
        ElseIf Action35 == 67
          b35[0] = (self.IsFastModeClosingScene(i35[0])) as Int
        ElseIf Action35 == 88
          Temp35_temp5 = i35[0] as string
          Temp35_temp5 = "[PSQ SLCompat] Skipped unavailable P+ settlement: tid=" + Temp35_temp5
          debug.Trace(Temp35_temp5, 0)
        ElseIf Action35 == 92
          self.SettlePPlusOrgasm(Source, i35[0], actors, i35[4], f35[0], (b35[1] as Bool), i35[5], (b35[2] as Bool), (b35[3] as Bool))
        Else
          Return
        EndIf
      EndIf
    EndIf
  EndWhile
EndFunction

Function SettlePPlusOrgasmCompat34(Actor Source, Int TID, Actor[] actors, Int Count, Float SceneTime, Bool RealPenis, Int ContactMask, Bool PlayerIsVictim, Bool PlayerIsAggressor)
  if Self.IsFastModeClosingScene(TID)
    return
  endif
  Int SceneEpoch = PSQSexSceneEpoch
  If PlayerIsSuccubus.GetValueInt() != 1
    Return
  EndIf
  If actors.find(PlayerRef, 0) < 0 || actors.find(Source, 0) < 0
    Return
  EndIf
  If PPlusThreadID != TID || PPlusSceneActors.Length != actors.Length || PPlusSceneActors.find(Source, 0) < 0
    Self.BeginPPlusScene(actors, TID, False)
  EndIf
  Int Slot = PPlusSceneActors.find(Source, 0)
  If Count <= 0 || Count <= PPlusOrgasmCounts[Slot]
    Return
  EndIf
  Float SexTime = SceneTime - PPlusDrainTimes[Slot]
  If SexTime < 0.0
    SexTime = 0.0
  EndIf
  PPlusOrgasmCounts[Slot] = Count
  PPlusDrainTimes[Slot] = SceneTime
  If Source == PlayerRef
    If actors.Length == 1
      Self.AddSuccubusFluid()
    EndIf
    Return
  EndIf
  Bool Vaginal = Math.LogicalAnd(ContactMask, 1) != 0
  Bool Anal = Math.LogicalAnd(ContactMask, 2) != 0
  Bool Oral = Math.LogicalAnd(ContactMask, 4) != 0
  Bool CanExtract = RealPenis && ContactMask != 0
  Bool CanImpregnant = False
  Bool CanInflate = EnableCumInflation && (Vaginal || Anal && CumInflationAnal || Oral && CumInflationOral)
  If FastMode
    SexTime = FastModeTime
  EndIf
  Float DrainValue = SexTime * DrainValueMultipliers * SuccubusRank.GetValue()
  If UseArousalAtDrain
    Float ArousedRank = storageutil.GetIntValue(PlayerRef as Form, "PSQ_ArousalAtBeginning", 0) as Float
    If ArousedRank < 50.0
      ArousedRank = 50.0
    EndIf
    DrainValue *= ArousedRank / 50.0
  EndIf
  If PlayerIsAggressor
    DrainValue *= 2.0
  EndIf
  CumInflationValue = 0.0
  storageutil.SetFloatValue(PlayerRef as Form, "PSQ_IncreaseEXP", 0.0)
  If Self.IsNotUndead(Source)
    If SceneEpoch != PSQSexSceneEpoch
      Return
    EndIf
    If Self.EnsureDeferredDrain(Source, TID)
      Self.SuccubusDrain(Source, DrainValue, PlayerIsVictim, PlayerIsAggressor, CanExtract, CanImpregnant, Oral, CanInflate, RealPenis, RealPenis)
    EndIf
  EndIf
  If Self.IsFamiliar(Source)
    Self.ChargeFamiliar(Source)
  EndIf
  If EnableCaptive
    Self.Captive(Source, DrainValue)
  EndIf
  If CanInflate && CumInflationValue > 0.0
    CumInflationSpell.Cast(PlayerRef as ObjectReference, None)
  EndIf
  Self.Satiety(0.0)
  Self.SatietyNotification(0.0, False)
  Self.SuccubusLevelUp(storageutil.GetFloatValue(PlayerRef as Form, "PSQ_IncreaseEXP", 0.0))
  Debug.Trace((((("[PSQ SLCompat] P+ orgasm: tid=" + TID as String) + "; actor=" + Source as String) + "; count=" + Count as String) + "; routes=" + ContactMask as String) + "; seconds=" + SexTime as String, 0)
EndFunction

Function SettlePPlusOrgasm35(actor Source, Int TID, actor[] actors, Int Count, Float SceneTime, Bool RealPenis, Int ContactMask, Bool PlayerIsVictim, Bool PlayerIsAggressor)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.SettlePPlusOrgasmCompat34(Source,TID,actors,Count,SceneTime,RealPenis,ContactMask,PlayerIsVictim,PlayerIsAggressor)
    Return
  EndIf
  Int[] i35 = new Int[10]
  Float[] f35 = new Float[6]
  Int[] b35 = new Int[11]
  Int Action35 = 0
  i35[0] = TID
  i35[1] = Count
  f35[0] = SceneTime
  b35[0] = (RealPenis) as Int
  i35[2] = ContactMask
  b35[1] = (PlayerIsVictim) as Int
  b35[2] = (PlayerIsAggressor) as Int
  form Temp35_temp5
  objectReference Temp35_temp6
  objectReference Temp35_temp7
  String Temp35_temp8
  String Temp35_temp9
  i35[7] = PSQLoadEpoch
  i35[8] = PSQSexSceneEpoch
  i35[9] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.SettlePPlusOrgasmStep35(Self, Action35, i35, f35, b35, Source)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 130
      If Action35 < 39
        If Action35 < 27
          If Action35 == 1
            b35[3] = (self.IsFastModeClosingScene(i35[0])) as Int
          ElseIf Action35 == 12
            i35[4] = actors.Find(PlayerRef, 0)
          ElseIf Action35 == 16
            i35[4] = actors.Find(Source, 0)
          Else
            Return
          EndIf
        Else
          If Action35 == 27
            i35[4] = PPlusSceneActors.Length
            i35[5] = actors.Length
          ElseIf Action35 == 33
            i35[5] = PPlusSceneActors.Find(Source, 0)
          ElseIf Action35 == 37
            self.BeginPPlusScene(actors, i35[0], false)
          Else
            Return
          EndIf
        EndIf
      Else
        If Action35 < 64
          If Action35 == 39
            i35[5] = PPlusSceneActors.Find(Source, 0)
          ElseIf Action35 == 59
            b35[3] = (Source == PlayerRef) as Int
          ElseIf Action35 == 61
            i35[5] = actors.Length
          Else
            Return
          EndIf
        Else
          If Action35 == 64
            self.AddSuccubusFluid()
          ElseIf Action35 == 112
            Temp35_temp5 = PlayerRef as form
            i35[5] = storageUtil.GetIntValue(Temp35_temp5, "PSQ_ArousalAtBeginning", 0)
          ElseIf Action35 == 129
            Temp35_temp5 = PlayerRef as form
            f35[4] = storageUtil.SetFloatValue(Temp35_temp5, "PSQ_IncreaseEXP", 0.0)
          Else
            Return
          EndIf
        EndIf
      EndIf
    Else
      If Action35 < 156
        If Action35 < 142
          If Action35 == 130
            b35[3] = (self.IsNotUndead(Source)) as Int
          ElseIf Action35 == 137
            b35[3] = (self.EnsureDeferredDrain(Source, i35[0])) as Int
          ElseIf Action35 == 139
            self.SuccubusDrain(Source, f35[3], (b35[1] as Bool), (b35[2] as Bool), (b35[7] as Bool), (b35[8] as Bool), (b35[6] as Bool), (b35[9] as Bool), (b35[0] as Bool), (b35[0] as Bool))
          Else
            Return
          EndIf
        Else
          If Action35 == 142
            b35[3] = (self.IsFamiliar(Source)) as Int
          ElseIf Action35 == 144
            f35[4] = self.ChargeFamiliar(Source)
          ElseIf Action35 == 147
            self.Captive(Source, f35[3])
          Else
            Return
          EndIf
        EndIf
      Else
        If Action35 < 161
          If Action35 == 156
            Temp35_temp6 = PlayerRef as objectreference
            Temp35_temp7 = None as objectreference
            CumInflationSpell.Cast(Temp35_temp6, Temp35_temp7)
          ElseIf Action35 == 158
            self.Satiety(0.0)
          ElseIf Action35 == 159
            self.SatietyNotification(0.0, false)
          Else
            Return
          EndIf
        Else
          If Action35 == 161
            Temp35_temp5 = PlayerRef as form
            f35[4] = storageUtil.GetFloatValue(Temp35_temp5, "PSQ_IncreaseEXP", 0.0)
          ElseIf Action35 == 162
            self.SuccubusLevelUp(f35[4])
          ElseIf Action35 == 177
            Temp35_temp8 = i35[0] as string
            Temp35_temp8 = "[PSQ SLCompat] P+ orgasm: tid=" + Temp35_temp8
            Temp35_temp8 = Temp35_temp8 + "; actor="
            Temp35_temp9 = Source as string
            Temp35_temp9 = Temp35_temp8 + Temp35_temp9
            Temp35_temp9 = Temp35_temp9 + "; count="
            Temp35_temp8 = i35[1] as string
            Temp35_temp8 = Temp35_temp9 + Temp35_temp8
            Temp35_temp8 = Temp35_temp8 + "; routes="
            Temp35_temp9 = i35[2] as string
            Temp35_temp9 = Temp35_temp8 + Temp35_temp9
            Temp35_temp9 = Temp35_temp9 + "; seconds="
            Temp35_temp8 = f35[1] as string
            Temp35_temp8 = Temp35_temp9 + Temp35_temp8
            debug.Trace(Temp35_temp8, 0)
          Else
            Return
          EndIf
        EndIf
      EndIf
    EndIf
  EndWhile
EndFunction

Function ResetFastModeEndStateCompat34(Bool NewScene = True)
  ; End requests also reset for P+ actor-list recovery. Only real starts/load
  ; recovery invalidate callbacks; a fallback must retain its in-flight work.
  if NewScene
    Int PreviousGeneration = FastModeCallbackGeneration
    Int PreviousEpoch = PSQSexSceneEpoch
    ; Retire first. Old callbacks can only decrement/remove their captured key.
    FastModeCallbackGeneration += 1
    StorageUtil.ClearObjIntValuePrefix(Self as Form, "PSQ_FastCallbacks_" + PreviousEpoch + "_" + PreviousGeneration + "_")
  endif
  FastModeSceneSerial += 1
  if FastModeEndClaimKey != ""
    StorageUtil.UnsetIntValue(Self as Form, FastModeEndClaimKey)
    StorageUtil.UnsetIntValue(Self as Form, FastModeEndClaimKey + "_closing")
  endif
  FastModeEndClaimKey = "PSQ_FastEnd_" + PSQSexSceneEpoch + "_" + FastModeSceneSerial
EndFunction

bool Function ResetFastModeEndState35(Bool NewScene)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.ResetFastModeEndStateCompat34(NewScene)
    Return False
  EndIf
  Int[] i35 = new Int[6]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[3]
  Int Action35 = 0
  b35[0] = (NewScene) as Int
  form Temp35_temp1
  String Temp35_temp2
  String Temp35_temp3
  i35[3] = PSQLoadEpoch
  i35[4] = PSQSexSceneEpoch
  i35[5] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.ResetFastModeEndStateStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return False
    EndIf
    If Action35 < 21
      If Action35 == 13
        Temp35_temp1 = self as form
        Temp35_temp2 = i35[1] as string
        Temp35_temp2 = "PSQ_FastCallbacks_" + Temp35_temp2
        Temp35_temp2 = Temp35_temp2 + "_"
        Temp35_temp3 = i35[0] as string
        Temp35_temp3 = Temp35_temp2 + Temp35_temp3
        Temp35_temp3 = Temp35_temp3 + "_"
        i35[2] = storageUtil.ClearObjIntValuePrefix(Temp35_temp1, Temp35_temp3)
      ElseIf Action35 == 17
        b35[1] = (FastModeEndClaimKey == "") as Int
      Else
        Return False
      EndIf
    Else
      If Action35 == 21
        Temp35_temp1 = self as form
        b35[1] = (storageUtil.UnsetIntValue(Temp35_temp1, FastModeEndClaimKey)) as Int
      ElseIf Action35 == 24
        Temp35_temp1 = self as form
        Temp35_temp3 = FastModeEndClaimKey + "_closing"
        b35[1] = (storageUtil.UnsetIntValue(Temp35_temp1, Temp35_temp3)) as Int
      ElseIf Action35 == 31
        Temp35_temp3 = PSQSexSceneEpoch as string
        Temp35_temp3 = "PSQ_FastEnd_" + Temp35_temp3
        Temp35_temp3 = Temp35_temp3 + "_"
        Temp35_temp2 = FastModeSceneSerial as string
        Temp35_temp2 = Temp35_temp3 + Temp35_temp2
        FastModeEndClaimKey = Temp35_temp2
      Else
        Return False
      EndIf
    EndIf
  EndWhile
  Return False
EndFunction

Function TryEndExhaustedFastSceneCompat34(Int TID, Int Serial, Int Epoch)
  if !FastMode || !EnableDrain || UninstallPrepared || UninstallCleanupBusy || SexLab == None || PlayerRef == None
    return
  endif
  if PlayerIsSuccubus.GetValueInt() != 1 || Self.IsFastModeClosingScene(TID) || Self.GetFastModePendingCallbacks(TID) > 0 || PPlusSettlementBusy || PPlusCallbacksPending > 0
    return
  endif
  if !Self.IsFastModeEndOwnerCurrent(TID, Serial, Epoch)
    return
  endif
  sslThreadController Thread = SexLab.GetController(TID)
  if Thread == None || Thread.GetState() != "Animating" || !Thread.HasActor(PlayerRef)
    return
  endif
  if !Self.FastModeTargetsExhausted(Thread.Positions, TID)
    return
  endif
  ; Yield only for an exhausted candidate, after this settlement has released
  ; both callback counters. Never wait while holding the P+ settlement lock.
  Utility.Wait(0.15)
  if !FastMode || !EnableDrain || UninstallPrepared || UninstallCleanupBusy || !Self.IsFastModeEndOwnerCurrent(TID, Serial, Epoch)
    return
  endif
  if Self.IsFastModeClosingScene(TID) || Self.GetFastModePendingCallbacks(TID) > 0 || PPlusSettlementBusy || PPlusCallbacksPending > 0 || PlayerIsSuccubus.GetValueInt() != 1
    return
  endif
  if Thread != SexLab.GetController(TID) || Thread.GetState() != "Animating" || !Thread.HasActor(PlayerRef) || !Self.FastModeTargetsExhausted(Thread.Positions, TID)
    return
  endif
  String ClaimKey = "PSQ_FastEnd_" + Epoch + "_" + Serial
  if StorageUtil.AdjustIntValue(Self as Form, ClaimKey, 1) != 1
    return
  endif
  if !Self.IsFastModeEndOwnerCurrent(TID, Serial, Epoch)
    StorageUtil.UnsetIntValue(Self as Form, ClaimKey)
    return
  endif
  if Self.GetFastModePendingCallbacks(TID) > 0 || PPlusSettlementBusy || PPlusCallbacksPending > 0 || !FastMode || !EnableDrain
    StorageUtil.UnsetIntValue(Self as Form, ClaimKey)
    return
  endif
  if Thread.GetState() != "Animating" || !Thread.HasActor(PlayerRef) || !Self.FastModeTargetsExhausted(Thread.Positions, TID) || !Self.IsFastModeEndOwnerCurrent(TID, Serial, Epoch)
    StorageUtil.UnsetIntValue(Self as Form, ClaimKey)
    return
  endif
  ; Publish closing intent, then check again. Wrappers recheck this marker
  ; after taking their count, so a late entrant cannot start a new settlement.
  String ClosingKey = ClaimKey + "_closing"
  StorageUtil.SetIntValue(Self as Form, ClosingKey, 1)
  ; Already-entered callbacks finish or reject closing after taking their
  ; generation-bound native count. No settlement lock is held while waiting.
  Int ClosingWaits = 0
  while Self.IsFastModeEndOwnerCurrent(TID, Serial, Epoch) && (Self.GetFastModePendingCallbacks(TID) > 0 || PPlusSettlementBusy || PPlusCallbacksPending > 0) && ClosingWaits < 40
    Utility.Wait(0.05)
    ClosingWaits += 1
  endwhile
  if !Self.IsFastModeEndOwnerCurrent(TID, Serial, Epoch)
    StorageUtil.UnsetIntValue(Self as Form, ClosingKey)
    StorageUtil.UnsetIntValue(Self as Form, ClaimKey)
    return
  endif
  if Self.GetFastModePendingCallbacks(TID) > 0 || PPlusSettlementBusy || PPlusCallbacksPending > 0 || !FastMode || !EnableDrain || UninstallPrepared || UninstallCleanupBusy
    StorageUtil.UnsetIntValue(Self as Form, ClosingKey)
    StorageUtil.UnsetIntValue(Self as Form, ClaimKey)
    return
  endif
  if Thread != SexLab.GetController(TID) || Thread.GetState() != "Animating" || !Thread.HasActor(PlayerRef) || !Self.FastModeTargetsExhausted(Thread.Positions, TID) || !Self.IsFastModeEndOwnerCurrent(TID, Serial, Epoch)
    StorageUtil.UnsetIntValue(Self as Form, ClosingKey)
    StorageUtil.UnsetIntValue(Self as Form, ClaimKey)
    return
  endif
  Thread.EndAnimation(True)
  if Epoch == PSQSexSceneEpoch && Serial == FastModeSceneSerial
    Debug.Notification("$PSQ_FastModeDepleted")
    Debug.Trace("[PSQ FastMode] all drainable reserves exhausted; ended tid=" + TID + "; scene=" + Serial, 0)
  endif
  ; Normal PSQEndSex retains responsibility for deferred damage and cleanup.
EndFunction

Function TryEndExhaustedFastScene35(Int TID, Int Serial, Int Epoch)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.TryEndExhaustedFastSceneCompat34(TID,Serial,Epoch)
    Return
  EndIf
  Int[] i35 = new Int[8]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[2]
  Int Action35 = 0
  i35[0] = TID
  i35[1] = Serial
  i35[2] = Epoch
  sexLabFramework Temp35_temp1
  actor Temp35_temp2
  sslThreadController Thread
  sslThreadController Temp35_temp4
  String Temp35_temp5
  actor[] Temp35_temp6
  String ClaimKey
  String Temp35_temp7
  form Temp35_temp8
  String ClosingKey
  i35[5] = PSQLoadEpoch
  i35[6] = PSQSexSceneEpoch
  i35[7] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.TryEndExhaustedFastSceneStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 183
      If Action35 < 96
        If Action35 < 55
          If Action35 < 30
            If Action35 == 15
              Temp35_temp1 = None as sexlabframework
              b35[0] = (SexLab == Temp35_temp1) as Int
            ElseIf Action35 == 20
              Temp35_temp2 = None as actor
              b35[0] = (PlayerRef == Temp35_temp2) as Int
            Else
              Return
            EndIf
          Else
            If Action35 == 30
              b35[0] = (self.IsFastModeClosingScene(i35[0])) as Int
            ElseIf Action35 == 34
              i35[3] = self.GetFastModePendingCallbacks(i35[0])
            ElseIf Action35 == 52
              Temp35_temp4 = SexLab.GetController(i35[0])
            Else
              Return
            EndIf
          EndIf
        Else
          If Action35 < 64
            If Action35 == 55
              Thread = Temp35_temp4
              Temp35_temp4 = None as sslthreadcontroller
              b35[0] = (Thread == Temp35_temp4) as Int
            ElseIf Action35 == 58
              Temp35_temp5 = Thread.GetState()
            ElseIf Action35 == 59
              b35[0] = (Temp35_temp5 == "Animating") as Int
            Else
              Return
            EndIf
          Else
            If Action35 == 64
              b35[0] = (Thread.HasActor(PlayerRef)) as Int
            ElseIf Action35 == 71
              Temp35_temp6 = Thread.Positions
              b35[0] = (self.FastModeTargetsExhausted(Temp35_temp6, i35[0])) as Int
            ElseIf Action35 == 76
              utility.Wait(0.1500000059604645)
            Else
              Return
            EndIf
          EndIf
        EndIf
      Else
        If Action35 < 129
          If Action35 < 119
            If Action35 == 96
              b35[0] = (self.IsFastModeClosingScene(i35[0])) as Int
            ElseIf Action35 == 99
              i35[3] = self.GetFastModePendingCallbacks(i35[0])
            ElseIf Action35 == 118
              Temp35_temp4 = SexLab.GetController(i35[0])
            Else
              Return
            EndIf
          Else
            If Action35 == 119
              b35[0] = (Thread == Temp35_temp4) as Int
            ElseIf Action35 == 123
              Temp35_temp5 = Thread.GetState()
            ElseIf Action35 == 124
              b35[0] = (Temp35_temp5 == "Animating") as Int
            Else
              Return
            EndIf
          EndIf
        Else
          If Action35 < 158
            If Action35 == 129
              b35[0] = (Thread.HasActor(PlayerRef)) as Int
            ElseIf Action35 == 135
              Temp35_temp6 = Thread.Positions
              b35[0] = (self.FastModeTargetsExhausted(Temp35_temp6, i35[0])) as Int
            ElseIf Action35 == 148
              Temp35_temp5 = i35[2] as string
              Temp35_temp5 = "PSQ_FastEnd_" + Temp35_temp5
              Temp35_temp5 = Temp35_temp5 + "_"
              Temp35_temp7 = i35[1] as string
              Temp35_temp7 = Temp35_temp5 + Temp35_temp7
              ClaimKey = Temp35_temp7
              Temp35_temp8 = self as form
              i35[3] = storageUtil.AdjustIntValue(Temp35_temp8, ClaimKey, 1)
            Else
              Return
            EndIf
          Else
            If Action35 == 158
              Temp35_temp8 = self as form
              b35[0] = (storageUtil.UnsetIntValue(Temp35_temp8, ClaimKey)) as Int
            ElseIf Action35 == 161
              i35[3] = self.GetFastModePendingCallbacks(i35[0])
            ElseIf Action35 == 180
              Temp35_temp8 = self as form
              b35[0] = (storageUtil.UnsetIntValue(Temp35_temp8, ClaimKey)) as Int
            Else
              Return
            EndIf
          EndIf
        EndIf
      EndIf
    Else
      If Action35 < 270
        If Action35 < 215
          If Action35 < 194
            If Action35 == 183
              Temp35_temp7 = Thread.GetState()
            ElseIf Action35 == 184
              b35[0] = (Temp35_temp7 == "Animating") as Int
            ElseIf Action35 == 188
              b35[0] = (Thread.HasActor(PlayerRef)) as Int
            Else
              Return
            EndIf
          Else
            If Action35 == 194
              Temp35_temp6 = Thread.Positions
              b35[0] = (self.FastModeTargetsExhausted(Temp35_temp6, i35[0])) as Int
            ElseIf Action35 == 204
              Temp35_temp8 = self as form
              b35[0] = (storageUtil.UnsetIntValue(Temp35_temp8, ClaimKey)) as Int
            ElseIf Action35 == 210
              Temp35_temp7 = ClaimKey + "_closing"
              ClosingKey = Temp35_temp7
              Temp35_temp8 = self as form
              i35[3] = storageUtil.SetIntValue(Temp35_temp8, ClosingKey, 1)
            Else
              Return
            EndIf
          EndIf
        Else
          If Action35 < 240
            If Action35 == 215
              i35[3] = self.GetFastModePendingCallbacks(i35[0])
            ElseIf Action35 == 230
              utility.Wait(0.0500000007450581)
            ElseIf Action35 == 238
              Temp35_temp8 = self as form
              b35[0] = (storageUtil.UnsetIntValue(Temp35_temp8, ClosingKey)) as Int
            Else
              Return
            EndIf
          Else
            If Action35 == 240
              Temp35_temp8 = self as form
              b35[0] = (storageUtil.UnsetIntValue(Temp35_temp8, ClaimKey)) as Int
            ElseIf Action35 == 243
              i35[3] = self.GetFastModePendingCallbacks(i35[0])
            ElseIf Action35 == 268
              Temp35_temp8 = self as form
              b35[0] = (storageUtil.UnsetIntValue(Temp35_temp8, ClosingKey)) as Int
            Else
              Return
            EndIf
          EndIf
        EndIf
      Else
        If Action35 < 290
          If Action35 < 278
            If Action35 == 270
              Temp35_temp8 = self as form
              b35[0] = (storageUtil.UnsetIntValue(Temp35_temp8, ClaimKey)) as Int
            ElseIf Action35 == 273
              Temp35_temp4 = SexLab.GetController(i35[0])
            ElseIf Action35 == 274
              b35[0] = (Thread == Temp35_temp4) as Int
            Else
              Return
            EndIf
          Else
            If Action35 == 278
              Temp35_temp7 = Thread.GetState()
            ElseIf Action35 == 279
              b35[0] = (Temp35_temp7 == "Animating") as Int
            ElseIf Action35 == 284
              b35[0] = (Thread.HasActor(PlayerRef)) as Int
            Else
              Return
            EndIf
          EndIf
        Else
          If Action35 < 305
            If Action35 == 290
              Temp35_temp6 = Thread.Positions
              b35[0] = (self.FastModeTargetsExhausted(Temp35_temp6, i35[0])) as Int
            ElseIf Action35 == 300
              Temp35_temp8 = self as form
              b35[0] = (storageUtil.UnsetIntValue(Temp35_temp8, ClosingKey)) as Int
            ElseIf Action35 == 302
              Temp35_temp8 = self as form
              b35[0] = (storageUtil.UnsetIntValue(Temp35_temp8, ClaimKey)) as Int
            Else
              Return
            EndIf
          Else
            If Action35 == 305
              Thread.EndAnimation(true)
            ElseIf Action35 == 312
              debug.Notification("$PSQ_FastModeDepleted")
            ElseIf Action35 == 318
              Temp35_temp7 = i35[0] as string
              Temp35_temp7 = "[PSQ FastMode] all drainable reserves exhausted; ended tid=" + Temp35_temp7
              Temp35_temp7 = Temp35_temp7 + "; scene="
              Temp35_temp5 = i35[1] as string
              Temp35_temp5 = Temp35_temp7 + Temp35_temp5
              debug.Trace(Temp35_temp5, 0)
            Else
              Return
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndWhile
EndFunction

Function ReleaseFastModeCallbackCompat34(String CallbackKey, Int Generation, Int Epoch)
  if Epoch != PSQSexSceneEpoch || Generation != FastModeCallbackGeneration
    StorageUtil.UnsetIntValue(Self as Form, CallbackKey)
    return
  endif
  StorageUtil.AdjustIntValue(Self as Form, CallbackKey, -1)
  ; Reset may have retired and removed the key while the native call yielded.
  if Epoch != PSQSexSceneEpoch || Generation != FastModeCallbackGeneration
    StorageUtil.UnsetIntValue(Self as Form, CallbackKey)
  endif
  ; Keep current-generation zero: deleting it could erase a concurrent +1.
  ; ResetFastModeEndState removes the whole prefix when this generation ends.
EndFunction

bool Function ReleaseFastModeCallback35(String CallbackKey, Int Generation, Int Epoch)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.ReleaseFastModeCallbackCompat34(CallbackKey,Generation,Epoch)
    Return False
  EndIf
  Int[] i35 = new Int[6]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[2]
  Int Action35 = 0
  i35[0] = Generation
  i35[1] = Epoch
  form Temp35_temp1
  i35[3] = PSQLoadEpoch
  i35[4] = PSQSexSceneEpoch
  i35[5] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.ReleaseFastModeCallbackStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return False
    EndIf
    If Action35 == 10
      Temp35_temp1 = self as form
      b35[0] = (storageUtil.UnsetIntValue(Temp35_temp1, CallbackKey)) as Int
    ElseIf Action35 == 14
      Temp35_temp1 = self as form
      i35[2] = storageUtil.AdjustIntValue(Temp35_temp1, CallbackKey, -1)
    ElseIf Action35 == 24
      Temp35_temp1 = self as form
      b35[0] = (storageUtil.UnsetIntValue(Temp35_temp1, CallbackKey)) as Int
    Else
      Return False
    EndIf
  EndWhile
  Return False
EndFunction

Function BeginDeferredDrainCompat34(Actor Target, Int TID)
  If Target == None || Target == PlayerRef || TID < 0
    Return
  EndIf
  storageutil.UnsetFloatValue(Target as Form, "PSQ_DrainDamageHealth")
  storageutil.UnsetFloatValue(Target as Form, "PSQ_DrainDamageStamina")
  storageutil.UnsetIntValue(Target as Form, "PSQ_DeathMark")
  storageutil.UnsetIntValue(Target as Form, "PSQ_SoulTrapMark")
  storageutil.SetIntValue(Target as Form, "PSQ_DrainDamageThread", TID)
  storageutil.SetIntValue(Target as Form, "PSQ_DrainClosedThread", -1)
  storageutil.SetIntValue(Target as Form, "PSQ_DrainFlushClaims", 0)
EndFunction

bool Function BeginDeferredDrain35(actor Target, Int TID)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.BeginDeferredDrainCompat34(Target,TID)
    Return False
  EndIf
  Int[] i35 = new Int[5]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[2]
  Int Action35 = 0
  i35[0] = TID
  actor Temp35_temp0
  form Temp35_temp2
  i35[2] = PSQLoadEpoch
  i35[3] = PSQSexSceneEpoch
  i35[4] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.BeginDeferredDrainStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return False
    EndIf
    If Action35 < 19
      If Action35 == 2
        Temp35_temp0 = None as actor
        b35[0] = (Target == Temp35_temp0) as Int
      ElseIf Action35 == 5
        b35[0] = (Target == PlayerRef) as Int
      ElseIf Action35 == 15
        Temp35_temp2 = Target as form
        b35[0] = (storageUtil.UnsetFloatValue(Temp35_temp2, "PSQ_DrainDamageHealth")) as Int
      ElseIf Action35 == 17
        Temp35_temp2 = Target as form
        b35[0] = (storageUtil.UnsetFloatValue(Temp35_temp2, "PSQ_DrainDamageStamina")) as Int
      Else
        Return False
      EndIf
    Else
      If Action35 < 23
        If Action35 == 19
          Temp35_temp2 = Target as form
          b35[0] = (storageUtil.UnsetIntValue(Temp35_temp2, "PSQ_DeathMark")) as Int
        ElseIf Action35 == 21
          Temp35_temp2 = Target as form
          b35[0] = (storageUtil.UnsetIntValue(Temp35_temp2, "PSQ_SoulTrapMark")) as Int
        Else
          Return False
        EndIf
      Else
        If Action35 == 23
          Temp35_temp2 = Target as form
          i35[1] = storageUtil.SetIntValue(Temp35_temp2, "PSQ_DrainDamageThread", i35[0])
        ElseIf Action35 == 25
          Temp35_temp2 = Target as form
          i35[1] = storageUtil.SetIntValue(Temp35_temp2, "PSQ_DrainClosedThread", -1)
        ElseIf Action35 == 27
          Temp35_temp2 = Target as form
          i35[1] = storageUtil.SetIntValue(Temp35_temp2, "PSQ_DrainFlushClaims", 0)
        Else
          Return False
        EndIf
      EndIf
    EndIf
  EndWhile
  Return False
EndFunction

Function FlushDeferredDrainCompat34(Actor Target, Int TID)
  If Target == None || TID < 0 || storageutil.GetIntValue(Target as Form, "PSQ_DrainDamageThread", -1) != TID
    Return
  EndIf
  If storageutil.AdjustIntValue(Target as Form, "PSQ_DrainFlushClaims", 1) != 1
    Return
  EndIf
  Float HealthDamage = storageutil.GetFloatValue(Target as Form, "PSQ_DrainDamageHealth", 0.0)
  Float StaminaDamage = storageutil.GetFloatValue(Target as Form, "PSQ_DrainDamageStamina", 0.0)
  Bool Lethal = storageutil.GetIntValue(Target as Form, "PSQ_DeathMark", 0) == 1
  Bool TrapSoul = storageutil.GetIntValue(Target as Form, "PSQ_SoulTrapMark", 0) == 1
  storageutil.SetIntValue(Target as Form, "PSQ_DrainClosedThread", TID)
  storageutil.SetIntValue(Target as Form, "PSQ_DrainDamageThread", -1)
  storageutil.UnsetFloatValue(Target as Form, "PSQ_DrainDamageHealth")
  storageutil.UnsetFloatValue(Target as Form, "PSQ_DrainDamageStamina")
  storageutil.UnsetIntValue(Target as Form, "PSQ_DeathMark")
  storageutil.UnsetIntValue(Target as Form, "PSQ_SoulTrapMark")
  If HealthDamage < 0.0
    HealthDamage = 0.0
  EndIf
  If StaminaDamage < 0.0
    StaminaDamage = 0.0
  EndIf
  If Lethal && TrapSoul
    SuccubusSoulTrap.Cast(PlayerRef as ObjectReference, Target as ObjectReference)
    Utility.Wait(0.100000001)
  EndIf
  If !(SKSE.GetPluginVersion("PSQ Appearance") >= 16777231) || !PSQAppearance.FlushDrainDamage(Target, HealthDamage, StaminaDamage, Lethal)
    If !Lethal
      Float DamageRoom = Target.GetActorValue("Health") - 1.0
      If DamageRoom < 0.0
        DamageRoom = 0.0
      EndIf
      If HealthDamage > DamageRoom
        HealthDamage = DamageRoom
      EndIf
    EndIf
    If HealthDamage > 0.0
      Target.DamageActorValue("Health", HealthDamage)
    EndIf
    If StaminaDamage > 0.0
      Target.DamageActorValue("Stamina", StaminaDamage)
    EndIf
  EndIf
  If Lethal
    Target.Kill(None)
  EndIf
EndFunction

Function FlushDeferredDrain35(actor Target, Int TID)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.FlushDeferredDrainCompat34(Target,TID)
    Return
  EndIf
  Int[] i35 = new Int[5]
  Float[] f35 = new Float[4]
  Int[] b35 = new Int[4]
  Int Action35 = 0
  i35[0] = TID
  actor Temp35_temp0
  form Temp35_temp2
  objectReference Temp35_temp5
  objectReference Temp35_temp6
  i35[2] = PSQLoadEpoch
  i35[3] = PSQSexSceneEpoch
  i35[4] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.FlushDeferredDrainStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 45
      If Action35 < 31
        If Action35 < 18
          If Action35 == 2
            Temp35_temp0 = None as actor
            b35[0] = (Target == Temp35_temp0) as Int
          ElseIf Action35 == 10
            Temp35_temp2 = Target as form
            i35[1] = storageUtil.GetIntValue(Temp35_temp2, "PSQ_DrainDamageThread", -1)
          Else
            Return
          EndIf
        Else
          If Action35 == 18
            Temp35_temp2 = Target as form
            i35[1] = storageUtil.AdjustIntValue(Temp35_temp2, "PSQ_DrainFlushClaims", 1)
          ElseIf Action35 == 25
            Temp35_temp2 = Target as form
            f35[1] = storageUtil.GetFloatValue(Temp35_temp2, "PSQ_DrainDamageHealth", 0.0)
          ElseIf Action35 == 28
            Temp35_temp2 = Target as form
            f35[1] = storageUtil.GetFloatValue(Temp35_temp2, "PSQ_DrainDamageStamina", 0.0)
          Else
            Return
          EndIf
        EndIf
      Else
        If Action35 < 39
          If Action35 == 31
            Temp35_temp2 = Target as form
            i35[1] = storageUtil.GetIntValue(Temp35_temp2, "PSQ_DeathMark", 0)
          ElseIf Action35 == 35
            Temp35_temp2 = Target as form
            i35[1] = storageUtil.GetIntValue(Temp35_temp2, "PSQ_SoulTrapMark", 0)
          Else
            Return
          EndIf
        Else
          If Action35 == 39
            Temp35_temp2 = Target as form
            i35[1] = storageUtil.SetIntValue(Temp35_temp2, "PSQ_DrainClosedThread", i35[0])
          ElseIf Action35 == 41
            Temp35_temp2 = Target as form
            i35[1] = storageUtil.SetIntValue(Temp35_temp2, "PSQ_DrainDamageThread", -1)
          ElseIf Action35 == 43
            Temp35_temp2 = Target as form
            b35[0] = (storageUtil.UnsetFloatValue(Temp35_temp2, "PSQ_DrainDamageHealth")) as Int
          Else
            Return
          EndIf
        EndIf
      EndIf
    Else
      If Action35 < 67
        If Action35 < 49
          If Action35 == 45
            Temp35_temp2 = Target as form
            b35[0] = (storageUtil.UnsetFloatValue(Temp35_temp2, "PSQ_DrainDamageStamina")) as Int
          ElseIf Action35 == 47
            Temp35_temp2 = Target as form
            b35[0] = (storageUtil.UnsetIntValue(Temp35_temp2, "PSQ_DeathMark")) as Int
          Else
            Return
          EndIf
        Else
          If Action35 == 49
            Temp35_temp2 = Target as form
            b35[0] = (storageUtil.UnsetIntValue(Temp35_temp2, "PSQ_SoulTrapMark")) as Int
          ElseIf Action35 == 64
            Temp35_temp5 = PlayerRef as objectreference
            Temp35_temp6 = Target as objectreference
            SuccubusSoulTrap.Cast(Temp35_temp5, Temp35_temp6)
          ElseIf Action35 == 65
            utility.Wait(0.1000000014901161)
          Else
            Return
          EndIf
        EndIf
      Else
        If Action35 < 92
          If Action35 == 67
            i35[1] = sKSE.GetPluginVersion("PSQ Appearance")
          ElseIf Action35 == 72
            b35[0] = (pSQAppearance.FlushDrainDamage(Target, f35[0], f35[2], (b35[1] as Bool))) as Int
          ElseIf Action35 == 78
            f35[1] = Target.GetActorValue("Health")
          Else
            Return
          EndIf
        Else
          If Action35 == 92
            Target.DamageActorValue("Health", f35[0])
          ElseIf Action35 == 96
            Target.DamageActorValue("Stamina", f35[2])
          ElseIf Action35 == 101
            Temp35_temp0 = None as actor
            Target.Kill(Temp35_temp0)
          Else
            Return
          EndIf
        EndIf
      EndIf
    EndIf
  EndWhile
EndFunction

Function QueueDeferredDrainDamageCompat34(Actor Target, Float Amount, Bool PlayerIsVictim, Bool PlayerIsAggressor)
  If Target == None || Amount <= 0.0 || storageutil.GetIntValue(Target as Form, "PSQ_DrainDamageThread", -1) < 0 || storageutil.GetIntValue(Target as Form, "PSQ_DrainFlushClaims", 0) != 0
    Return
  EndIf
  Float TotalHealth = storageutil.AdjustFloatValue(Target as Form, "PSQ_DrainDamageHealth", Amount)
  storageutil.AdjustFloatValue(Target as Form, "PSQ_DrainDamageStamina", Amount)
  If TotalHealth >= Target.GetActorValue("Health") && Self.KillAtDrain(PlayerIsVictim, PlayerIsAggressor)
    storageutil.SetIntValue(Target as Form, "PSQ_DeathMark", 1)
    If Self.SoulTrapWhenKillAtDrain(PlayerIsVictim, PlayerIsAggressor)
      storageutil.SetIntValue(Target as Form, "PSQ_SoulTrapMark", 1)
    EndIf
  EndIf
EndFunction

bool Function QueueDeferredDrainDamage35(actor Target, Float Amount, Bool PlayerIsVictim, Bool PlayerIsAggressor)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.QueueDeferredDrainDamageCompat34(Target,Amount,PlayerIsVictim,PlayerIsAggressor)
    Return False
  EndIf
  Int[] i35 = new Int[4]
  Float[] f35 = new Float[3]
  Int[] b35 = new Int[4]
  Int Action35 = 0
  f35[0] = Amount
  b35[0] = (PlayerIsVictim) as Int
  b35[1] = (PlayerIsAggressor) as Int
  actor Temp35_temp0
  form Temp35_temp2
  i35[1] = PSQLoadEpoch
  i35[2] = PSQSexSceneEpoch
  i35[3] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.QueueDeferredDrainDamageStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return False
    EndIf
    If Action35 < 28
      If Action35 < 16
        If Action35 == 2
          Temp35_temp0 = None as actor
          b35[2] = (Target == Temp35_temp0) as Int
        ElseIf Action35 == 10
          Temp35_temp2 = Target as form
          i35[0] = storageUtil.GetIntValue(Temp35_temp2, "PSQ_DrainDamageThread", -1)
        Else
          Return False
        EndIf
      Else
        If Action35 == 16
          Temp35_temp2 = Target as form
          i35[0] = storageUtil.GetIntValue(Temp35_temp2, "PSQ_DrainFlushClaims", 0)
        ElseIf Action35 == 24
          Temp35_temp2 = Target as form
          f35[2] = storageUtil.AdjustFloatValue(Temp35_temp2, "PSQ_DrainDamageHealth", f35[0])
        ElseIf Action35 == 27
          Temp35_temp2 = Target as form
          f35[2] = storageUtil.AdjustFloatValue(Temp35_temp2, "PSQ_DrainDamageStamina", f35[0])
        Else
          Return False
        EndIf
      EndIf
    Else
      If Action35 < 36
        If Action35 == 28
          f35[2] = Target.GetActorValue("Health")
        ElseIf Action35 == 32
          b35[2] = (self.KillAtDrain((b35[0] as Bool), (b35[1] as Bool))) as Int
        Else
          Return False
        EndIf
      Else
        If Action35 == 36
          Temp35_temp2 = Target as form
          i35[0] = storageUtil.SetIntValue(Temp35_temp2, "PSQ_DeathMark", 1)
        ElseIf Action35 == 37
          b35[2] = (self.SoulTrapWhenKillAtDrain((b35[0] as Bool), (b35[1] as Bool))) as Int
        ElseIf Action35 == 40
          Temp35_temp2 = Target as form
          i35[0] = storageUtil.SetIntValue(Temp35_temp2, "PSQ_SoulTrapMark", 1)
        Else
          Return False
        EndIf
      EndIf
    EndIf
  EndWhile
  Return False
EndFunction

Function SuccubusDrainCompat34(Actor Target, Float DrainValue, Bool PlayerIsVictim, Bool PlayerIsAggressor, Bool CanExtractSemenPotion, Bool CanImpregnant, Bool IsOral, Bool CumInflation, Bool IsMalePosition, Bool RealPenis)
  If EnableDrain
    Float SatiationExperience = Self.GetSatiationExperienceMultiplier()
    If UseArousalAtDrain
      DrainValue = Self.ProcessingArousal(Target, DrainValue)
    EndIf
    If Target.GetRelationshipRank(PlayerRef) == 4
      DrainValue *= LoversDrainMult
    EndIf
    Float DrainEnergy = DrainValue
    Self.QueueDeferredDrainDamage(Target, DrainValue, PlayerIsVictim, PlayerIsAggressor)
    Float[] Settlement
    If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
      Settlement = PSQAppearance.DrainSettlement(DrainValue, storageutil.GetFloatValue(Target as Form, "PSQ_EnergyOfActor", 0.0), SuccubusRank.GetValue(), SatiationExperience)
    EndIf
    If Settlement && Settlement.Length == 2
      DrainEnergy = Settlement[0]
    ElseIf DrainEnergy > storageutil.GetFloatValue(Target as Form, "PSQ_EnergyOfActor", 0.0)
      DrainEnergy = storageutil.GetFloatValue(Target as Form, "PSQ_EnergyOfActor", 0.0)
    EndIf
    If CumInflation && IsMalePosition && RealPenis
      CumInflationValue += DrainEnergy
    EndIf
    If !ManualDigestionMode || !CumInflation || !IsMalePosition || !RealPenis
      storageutil.SetFloatValue(Target as Form, "PSQ_EnergyOfActor", storageutil.GetFloatValue(Target as Form, "PSQ_EnergyOfActor", 0.0) - DrainEnergy)
    EndIf
    If DrainEnergy > 0.0
      Self.DrainHighestNPCSkill(Target)
      Self.DrainNPCAttributes(Target)
      Self.DrainNPCRacialTrait(Target)
    EndIf
    Float ExperienceGain = 0.0
    If Settlement && Settlement.Length == 2
      ExperienceGain = Settlement[1]
    ElseIf SuccubusRank.GetValue() > 0
      ExperienceGain = (DrainEnergy / (SuccubusRank.GetValue() * 100.0)) * SatiationExperience
    EndIf
    Float IncreaseEXP = StorageUtil.AdjustFloatValue(PlayerRef, "PSQ_IncreaseEXP", ExperienceGain)
    Debug.Trace("[PSQ DrainMath] denom=rank*100; drained=" + DrainEnergy + "; rank=" + SuccubusRank.GetValue() + "; pendingEXP=" + IncreaseEXP, 0)
    If !Target.HasKeywordString("ActorTypeNPC")
      String RaceName = Self.GetVictimRace(Target)
      Float Familiarity = Self.GetAnimalRaceFamiliarity(RaceName)
      storageutil.SetFloatValue(PlayerRef as Form, "MyUniAnimalExp" + RaceName, Familiarity + 1.0)
    EndIf
    Bool Extract = Self.SemenPotionChecker()
    Float[] Reward
    If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
      Reward = PSQAppearance.DrainRewardRoute(DrainEnergy, Extract, CanExtractSemenPotion, IsOral)
    EndIf
    If (Reward && Reward.Length == 4 && Reward[0] > 0.0) || (!Reward && Extract && DrainEnergy >= 50.0 && CanExtractSemenPotion)
      Int Quantity
      If Reward && Reward.Length == 4
        Quantity = Reward[0] as Int
      ElseIf SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
        Quantity = PSQAppearance.DrainPotionCount(DrainEnergy)
      Else
        While DrainEnergy >= 50.0
          Quantity += 1
          DrainEnergy -= 50.0
        EndWhile
      EndIf
      PlayerRef.AddItem(SemenPotion as Form, Quantity, True)
      Debug.Notification("从" + Target.GetLeveledActorBase().GetName() + "获得的精液药剂数量:" + Quantity as String)
    Else
      If Reward && Reward.Length == 4
        DrainEnergy = Reward[1]
      EndIf
      SuccubusEnergy.Mod(DrainEnergy)
      PlayerRef.RestoreActorValue("Magicka", DrainEnergy)
      Float Manpukudo = Self.GetEnergyRatio()
      SEBU.UpdateEnergyBar(Manpukudo)
      Debug.Notification("从" + Target.GetLeveledActorBase().GetName() + "吸取能量:" + (DrainEnergy as Int) as String)
      If IsOral
        If Reward && Reward.Length == 4
          FoodPointsSemen.SetValue(Reward[2])
          WaterPointsSemen.SetValue(Reward[3])
        Else
          FoodPointsSemen.SetValue(DrainEnergy / 10.0)
          WaterPointsSemen.SetValue(DrainEnergy / 15.0)
        EndIf
        PSQEatSemenSpell.Cast(PlayerRef as ObjectReference, None)
      EndIf
    EndIf
  EndIf
EndFunction

Function SuccubusDrain35(actor Target, Float DrainValue, Bool PlayerIsVictim, Bool PlayerIsAggressor, Bool CanExtractSemenPotion, Bool CanImpregnant, Bool IsOral, Bool CumInflation, Bool IsMalePosition, Bool RealPenis)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.SuccubusDrainCompat34(Target,DrainValue,PlayerIsVictim,PlayerIsAggressor,CanExtractSemenPotion,CanImpregnant,IsOral,CumInflation,IsMalePosition,RealPenis)
    Return
  EndIf
  Int[] i35 = new Int[5]
  Float[] f35 = new Float[9]
  Int[] b35 = new Int[11]
  Int Action35 = 0
  f35[0] = DrainValue
  b35[0] = (PlayerIsVictim) as Int
  b35[1] = (PlayerIsAggressor) as Int
  b35[2] = (CanExtractSemenPotion) as Int
  b35[3] = (CanImpregnant) as Int
  b35[4] = (IsOral) as Int
  b35[5] = (CumInflation) as Int
  b35[6] = (IsMalePosition) as Int
  b35[7] = (RealPenis) as Int
  Float[] Settlement
  form Temp35_temp3
  Float[] Temp35_temp5
  form Temp35_temp6
  String Temp35_temp7
  String Temp35_temp8
  String RaceName
  Float[] Reward
  actorBase Temp35_temp9
  objectReference Temp35_temp10
  objectReference Temp35_temp11
  i35[2] = PSQLoadEpoch
  i35[3] = PSQSexSceneEpoch
  i35[4] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.SuccubusDrainStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 130
      If Action35 < 76
        If Action35 < 25
          If Action35 < 16
            If Action35 == 2
              f35[2] = self.GetSatiationExperienceMultiplier()
            ElseIf Action35 == 5
              f35[2] = self.ProcessingArousal(Target, f35[0])
            ElseIf Action35 == 8
              i35[0] = Target.GetRelationshipRank(PlayerRef)
            ElseIf Action35 == 15
              self.QueueDeferredDrainDamage(Target, f35[0], (b35[0] as Bool), (b35[1] as Bool))
            Else
              Return
            EndIf
          Else
            If Action35 == 16
              i35[0] = sKSE.GetPluginVersion("PSQ Appearance")
            ElseIf Action35 == 20
              Temp35_temp3 = Target as form
              f35[2] = storageUtil.GetFloatValue(Temp35_temp3, "PSQ_EnergyOfActor", 0.0)
            ElseIf Action35 == 22
              Temp35_temp5 = pSQAppearance.DrainSettlement(f35[0], f35[2], f35[4], f35[1])
            ElseIf Action35 == 23
              Settlement = Temp35_temp5
            Else
              Return
            EndIf
          EndIf
        Else
          If Action35 < 40
            If Action35 == 25
              b35[8] = (Settlement as bool) as Int
            ElseIf Action35 == 28
              i35[0] = Settlement.Length
            ElseIf Action35 == 32
              f35[4] = Settlement[0]
            ElseIf Action35 == 36
              Temp35_temp3 = Target as form
              f35[4] = storageUtil.GetFloatValue(Temp35_temp3, "PSQ_EnergyOfActor", 0.0)
            Else
              Return
            EndIf
          Else
            If Action35 == 40
              Temp35_temp3 = Target as form
              f35[4] = storageUtil.GetFloatValue(Temp35_temp3, "PSQ_EnergyOfActor", 0.0)
            ElseIf Action35 == 69
              Temp35_temp3 = Target as form
              Temp35_temp6 = Target as form
              f35[4] = storageUtil.GetFloatValue(Temp35_temp6, "PSQ_EnergyOfActor", 0.0)
            ElseIf Action35 == 71
              f35[4] = storageUtil.SetFloatValue(Temp35_temp3, "PSQ_EnergyOfActor", f35[4])
            ElseIf Action35 == 75
              self.DrainHighestNPCSkill(Target)
            Else
              Return
            EndIf
          EndIf
        EndIf
      Else
        If Action35 < 112
          If Action35 < 87
            If Action35 == 76
              self.DrainNPCAttributes(Target)
            ElseIf Action35 == 77
              self.DrainNPCRacialTrait(Target)
            ElseIf Action35 == 80
              b35[8] = (Settlement as bool) as Int
            ElseIf Action35 == 83
              i35[0] = Settlement.Length
            Else
              Return
            EndIf
          Else
            If Action35 == 87
              f35[4] = Settlement[1]
            ElseIf Action35 == 100
              Temp35_temp3 = PlayerRef as form
              f35[4] = storageUtil.AdjustFloatValue(Temp35_temp3, "PSQ_IncreaseEXP", f35[5])
            ElseIf Action35 == 104
              Temp35_temp7 = f35[3] as string
              Temp35_temp7 = "[PSQ DrainMath] denom=rank*100; drained=" + Temp35_temp7
              Temp35_temp7 = Temp35_temp7 + "; rank="
            ElseIf Action35 == 111
              Temp35_temp8 = f35[4] as string
              Temp35_temp8 = Temp35_temp7 + Temp35_temp8
              Temp35_temp8 = Temp35_temp8 + "; pendingEXP="
              Temp35_temp7 = f35[6] as string
              Temp35_temp7 = Temp35_temp8 + Temp35_temp7
              debug.Trace(Temp35_temp7, 0)
            Else
              Return
            EndIf
          EndIf
        Else
          If Action35 < 122
            If Action35 == 112
              b35[8] = (Target.HasKeywordString("ActorTypeNPC")) as Int
            ElseIf Action35 == 115
              Temp35_temp7 = self.GetVictimRace(Target)
            ElseIf Action35 == 117
              RaceName = Temp35_temp7
              f35[4] = self.GetAnimalRaceFamiliarity(RaceName)
            ElseIf Action35 == 120
              Temp35_temp3 = PlayerRef as form
              Temp35_temp7 = "MyUniAnimalExp" + RaceName
            Else
              Return
            EndIf
          Else
            If Action35 == 122
              f35[4] = storageUtil.SetFloatValue(Temp35_temp3, Temp35_temp7, f35[4])
            ElseIf Action35 == 124
              b35[8] = (self.SemenPotionChecker()) as Int
            ElseIf Action35 == 126
              i35[0] = sKSE.GetPluginVersion("PSQ Appearance")
            ElseIf Action35 == 129
              Temp35_temp5 = pSQAppearance.DrainRewardRoute(f35[3], (b35[9] as Bool), (b35[2] as Bool), (b35[4] as Bool))
            Else
              Return
            EndIf
          EndIf
        EndIf
      EndIf
    Else
      If Action35 < 199
        If Action35 < 169
          If Action35 < 145
            If Action35 == 130
              Reward = Temp35_temp5
            ElseIf Action35 == 132
              b35[8] = (Reward as bool) as Int
            ElseIf Action35 == 135
              i35[0] = Reward.Length
            ElseIf Action35 == 140
              f35[4] = Reward[0]
            Else
              Return
            EndIf
          Else
            If Action35 == 145
              b35[8] = (!Reward) as Int
            ElseIf Action35 == 158
              b35[8] = (Reward as bool) as Int
            ElseIf Action35 == 161
              i35[0] = Reward.Length
            ElseIf Action35 == 165
              f35[4] = Reward[0]
            Else
              Return
            EndIf
          EndIf
        Else
          If Action35 < 185
            If Action35 == 169
              i35[0] = sKSE.GetPluginVersion("PSQ Appearance")
            ElseIf Action35 == 172
              i35[0] = pSQAppearance.DrainPotionCount(f35[3])
            ElseIf Action35 == 183
              Temp35_temp3 = SemenPotion as form
              PlayerRef.AddItem(Temp35_temp3, i35[1], true)
            ElseIf Action35 == 184
              Temp35_temp9 = Target.GetLeveledActorBase()
            Else
              Return
            EndIf
          Else
            If Action35 == 185
              Temp35_temp7 = Temp35_temp9.GetName()
            ElseIf Action35 == 190
              Temp35_temp7 = "从" + Temp35_temp7
              Temp35_temp7 = Temp35_temp7 + "获得的精液药剂数量:"
              Temp35_temp8 = i35[1] as string
              Temp35_temp8 = Temp35_temp7 + Temp35_temp8
              debug.Notification(Temp35_temp8)
            ElseIf Action35 == 192
              b35[8] = (Reward as bool) as Int
            ElseIf Action35 == 195
              i35[0] = Reward.Length
            Else
              Return
            EndIf
          EndIf
        EndIf
      Else
        If Action35 < 214
          If Action35 < 206
            If Action35 == 199
              f35[4] = Reward[1]
            ElseIf Action35 == 202
              f35[4] = SuccubusEnergy.Mod(f35[3])
            ElseIf Action35 == 203
              PlayerRef.RestoreActorValue("Magicka", f35[3])
            ElseIf Action35 == 204
              f35[4] = self.GetEnergyRatio()
            Else
              Return
            EndIf
          Else
            If Action35 == 206
              SEBU.UpdateEnergyBar(f35[8])
            ElseIf Action35 == 207
              Temp35_temp9 = Target.GetLeveledActorBase()
            ElseIf Action35 == 208
              Temp35_temp8 = Temp35_temp9.GetName()
            ElseIf Action35 == 210
              Temp35_temp8 = "从" + Temp35_temp8
              Temp35_temp8 = Temp35_temp8 + "吸取能量:"
            Else
              Return
            EndIf
          EndIf
        Else
          If Action35 < 226
            If Action35 == 214
              Temp35_temp7 = i35[0] as string
              Temp35_temp7 = Temp35_temp8 + Temp35_temp7
              debug.Notification(Temp35_temp7)
            ElseIf Action35 == 216
              b35[8] = (Reward as bool) as Int
            ElseIf Action35 == 219
              i35[0] = Reward.Length
            ElseIf Action35 == 224
              f35[4] = Reward[2]
              FoodPointsSemen.SetValue(f35[4])
            Else
              Return
            EndIf
          Else
            If Action35 == 226
              f35[4] = Reward[3]
              WaterPointsSemen.SetValue(f35[4])
            ElseIf Action35 == 229
              FoodPointsSemen.SetValue(f35[4])
            ElseIf Action35 == 231
              WaterPointsSemen.SetValue(f35[4])
            ElseIf Action35 == 234
              Temp35_temp10 = PlayerRef as objectreference
              Temp35_temp11 = None as objectreference
              PSQEatSemenSpell.Cast(Temp35_temp10, Temp35_temp11)
            Else
              Return
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndWhile
EndFunction

Function SuccubusLevelUpCompat34(Float value)
  Int AnimationPreviousRank = SuccubusRank.GetValueInt()
  Float EXP = value * EXPGainedMultipliers
  If EXP != 0.0
    SuccubusEXP.Mod(EXP)
    Debug.Notification("魅魔经验值:" + (SuccubusEXP.GetValue() * 100.0) as String)
  EndIf
  Self.RefreshEnergyCapacity()
  Float Rank = SuccubusRank.GetValue()
  Float RootEXP = Math.Sqrt(SuccubusEXP.GetValue() / 6.0)
  Self.SyncScaledAbility(FortifyDestructionSpell, EnableFortifyDestruction, 20.0 + (6.0 * Rank + RootEXP) * FortifyDestructionMult)
  Self.SyncScaledAbility(FortifyIllusionSpell, EnableFortifyIllusion, 20.0 + (6.0 * Rank + RootEXP) * FortifyIllusionMult)
  Self.SyncScaledAbility(MagicResistanceSpell, EnableMagicResistance, 10.0 + (2.0 * Rank + 0.5 * RootEXP + 6.0) * MagicResistanceMult)
  Float IllusionValue = 1.0 + (6.0 * Rank + RootEXP) / 100.0 * FortifyIllusionMult
  If FortifyIllusionPerk.GetNthEntryValue(0, 1) != IllusionValue
    FortifyIllusionPerk.SetNthEntryValue(0, 1, IllusionValue)
  EndIf
  If PlayerRef.HasSpell(FortifySneakSpell as Form)
    FortifySneakSpell.SetNthEffectMagnitude(0, 20.0 + 6.0 * Rank + RootEXP)
  EndIf
  EnergyConsumption = MaxEnergy * EnergyConsumptionPerMax / 100.0
  Int Promotion = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777234
    Promotion = PSQAppearance.ApplyPromotionAbilities(Self, PlayerRef, SuccubusRank, SuccubusEXP)
  EndIf
  If Promotion > 0
    SuccubusRank.SetValue(Promotion as Float)
    Debug.Notification("$PSQ_RankUpTo" + Promotion)
    Debug.Notification("$PSQ_GotTitle" + Promotion)
  ElseIf Promotion == 0
  If SuccubusRank.GetValue() == 1.0 && SuccubusEXP.GetValue() >= 10.0
    SuccubusRank.SetValue(2.0)
    Debug.Notification("$PSQ_RankUpTo2")
    Debug.Notification("$PSQ_GotTitle2")
    If EnableSuccubusDrainFF
      PlayerRef.AddSpell(SuccubusDrainFF02, False)
    EndIf
    If EnableSuccubusDrainHealthSpell
      PlayerRef.AddSpell(SuccubusDrainHealthSpell02, False)
    EndIf
    If EnableSuccubusDrainStaminaSpell
      PlayerRef.AddSpell(SuccubusDrainStaminaSpell02, False)
    EndIf
    If EnableFortifyBartar
      PlayerRef.AddSpell(FortifyBartarSpell2, False)
    EndIf
    PlayerRef.AddSpell(SuccuKanashibari, False)
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell01)
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell01)
    PlayerRef.RemoveSpell(SuccubusDrainFF01)
    PlayerRef.RemoveSpell(FortifyBartarSpell1)
  ElseIf SuccubusRank.GetValue() == 2.0 && SuccubusEXP.GetValue() >= 50.0
    SuccubusRank.SetValue(3.0)
    Debug.Notification("$PSQ_RankUpTo3")
    Debug.Notification("$PSQ_GotTitle3")
    If EnableSuccubusDrainStaminaSpell
      PlayerRef.AddSpell(SuccubusDrainStaminaSpell03, False)
    EndIf
    If EnableSuccubusDrainHealthSpell
      PlayerRef.AddSpell(SuccubusDrainHealthSpell03, False)
    EndIf
    If EnableSuccubusDrainFF
      PlayerRef.AddSpell(SuccubusDrainFF03, False)
    EndIf
    If EnableFortifyBartar
      PlayerRef.AddSpell(FortifyBartarSpell3, False)
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell02)
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell02)
    PlayerRef.RemoveSpell(SuccubusDrainFF02)
    PlayerRef.RemoveSpell(FortifyBartarSpell2)
  ElseIf SuccubusRank.GetValue() == 3.0 && SuccubusEXP.GetValue() >= 100.0
    SuccubusRank.SetValue(4.0)
    Debug.Notification("$PSQ_RankUpTo4")
    Debug.Notification("$PSQ_GotTitle4")
    If EnableSuccubusDrainStaminaSpell
      PlayerRef.AddSpell(SuccubusDrainStaminaSpell04, False)
    EndIf
    If EnableSuccubusDrainHealthSpell
      PlayerRef.AddSpell(SuccubusDrainHealthSpell04, False)
    EndIf
    If EnableSuccubusDrainFF
      PlayerRef.AddSpell(SuccubusDrainFF04, False)
    EndIf
    PlayerRef.AddSpell(FortifyMSGBoxSpell, False)
    If EnableFortifyBartar
      PlayerRef.AddSpell(FortifyBartarSpell4, False)
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell03)
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell03)
    PlayerRef.RemoveSpell(SuccubusDrainFF03)
    PlayerRef.RemoveSpell(FortifyBartarSpell3)
  ElseIf SuccubusRank.GetValue() == 4.0 && SuccubusEXP.GetValue() >= 250.0
    SuccubusRank.SetValue(5.0)
    Debug.Notification("$PSQ_RankUpTo5")
    Debug.Notification("$PSQ_GotTitle5")
    If EnableSuccubusDrainStaminaSpell
      PlayerRef.AddSpell(SuccubusDrainStaminaSpell05, False)
    EndIf
    If EnableSuccubusDrainHealthSpell
      PlayerRef.AddSpell(SuccubusDrainHealthSpell05, False)
    EndIf
    If EnableSuccubusDrainFF
      PlayerRef.AddSpell(SuccubusDrainFF05, False)
    EndIf
    If EnableFortifyBartar
      PlayerRef.AddSpell(FortifyBartarSpell5, False)
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell04)
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell04)
    PlayerRef.RemoveSpell(SuccubusDrainFF04)
    PlayerRef.RemoveSpell(FortifyBartarSpell4)
  ElseIf SuccubusRank.GetValue() == 5.0 && SuccubusEXP.GetValue() >= 500.0
    SuccubusRank.SetValue(6.0)
    Debug.Notification("$PSQ_RankUpTo6")
    Debug.Notification("$PSQ_GotTitle6")
    If EnableSuccubusDrainStaminaSpell
      PlayerRef.AddSpell(SuccubusDrainStaminaSpell06, False)
    EndIf
    If EnableSuccubusDrainHealthSpell
      PlayerRef.AddSpell(SuccubusDrainHealthSpell06, False)
    EndIf
    If EnableSuccubusDrainFF
      PlayerRef.AddSpell(SuccubusDrainFF06, False)
    EndIf
    If EnableFortifyBartar
      PlayerRef.AddSpell(FortifyBartarSpell6, False)
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell05)
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell05)
    PlayerRef.RemoveSpell(SuccubusDrainFF05)
    PlayerRef.RemoveSpell(FortifyBartarSpell5)
  ElseIf SuccubusRank.GetValue() == 6.0 && SuccubusEXP.GetValue() >= 1000.0
    SuccubusRank.SetValue(7.0)
    Debug.Notification("$PSQ_RankUpTo7")
    Debug.Notification("$PSQ_GotTitle7")
    If EnableSuccubusDrainStaminaSpell
      PlayerRef.AddSpell(SuccubusDrainStaminaSpell07, False)
    EndIf
    If EnableSuccubusDrainHealthSpell
      PlayerRef.AddSpell(SuccubusDrainHealthSpell07, False)
    EndIf
    If EnableSuccubusDrainFF
      PlayerRef.AddSpell(SuccubusDrainFF07, False)
    EndIf
    If EnableFortifyBartar
      PlayerRef.AddSpell(FortifyBartarSpell7, False)
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell06)
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell06)
    PlayerRef.RemoveSpell(SuccubusDrainFF06)
    PlayerRef.RemoveSpell(FortifyBartarSpell6)
  ElseIf SuccubusRank.GetValue() == 7.0 && SuccubusEXP.GetValue() >= 2000.0
    SuccubusRank.SetValue(8.0)
    Debug.Notification("$PSQ_RankUpTo8")
    Debug.Notification("$PSQ_GotTitle8")
    If EnableSuccubusDrainStaminaSpell
      PlayerRef.AddSpell(SuccubusDrainStaminaSpell08, False)
    EndIf
    If EnableSuccubusDrainHealthSpell
      PlayerRef.AddSpell(SuccubusDrainHealthSpell08, False)
    EndIf
    If EnableSuccubusDrainFF
      PlayerRef.AddSpell(SuccubusDrainFF08, False)
    EndIf
    If EnableFortifyBartar
      PlayerRef.AddSpell(FortifyBartarSpell8, False)
    EndIf
    PlayerRef.RemoveSpell(SuccubusDrainStaminaSpell07)
    PlayerRef.RemoveSpell(SuccubusDrainHealthSpell07)
    PlayerRef.RemoveSpell(SuccubusDrainFF07)
    PlayerRef.RemoveSpell(FortifyBartarSpell7)
  EndIf
  EndIf
  Bool AdvancedRankChanged = Self.UpdateAdvancedSuccubusRank(True)
  Self.QueueRankUpAnimation(AnimationPreviousRank, SuccubusRank.GetValueInt())
  If AdvancedRankChanged
    Self.SuccubusLevelUp(0.0)
  Else
    Self.Satiety(0.0)
  EndIf
  Self.SyncManagedAbilities()
  Self.SyncContinuousAbilities(False)
EndFunction

Function SuccubusLevelUp35(Float value)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.SuccubusLevelUpCompat34(value)
    Return
  EndIf
  Int[] i35 = new Int[6]
  Float[] f35 = new Float[7]
  Int[] b35 = new Int[3]
  Int Action35 = 0
  f35[0] = value
  String Temp35_temp3
  form Temp35_temp5
  quest Temp35_temp6
  i35[3] = PSQLoadEpoch
  i35[4] = PSQSexSceneEpoch
  i35[5] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.SuccubusLevelUpStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 158
      If Action35 < 93
        If Action35 < 52
          If Action35 < 26
            If Action35 == 8
              f35[2] = SuccubusEXP.Mod(f35[1])
            ElseIf Action35 == 13
              Temp35_temp3 = f35[2] as string
              Temp35_temp3 = "魅魔经验值:" + Temp35_temp3
              debug.Notification(Temp35_temp3)
            ElseIf Action35 == 15
              self.RefreshEnergyCapacity()
            ElseIf Action35 == 20
              f35[2] = math.sqrt(f35[2])
            Else
              Return
            EndIf
          Else
            If Action35 < 38
              If Action35 == 26
                self.SyncScaledAbility(FortifyDestructionSpell, EnableFortifyDestruction, f35[2])
              ElseIf Action35 == 31
                self.SyncScaledAbility(FortifyIllusionSpell, EnableFortifyIllusion, f35[2])
              Else
                Return
              EndIf
            Else
              If Action35 == 38
                self.SyncScaledAbility(MagicResistanceSpell, EnableMagicResistance, f35[5])
              ElseIf Action35 == 45
                f35[5] = FortifyIllusionPerk.GetNthEntryValue(0, 1)
              ElseIf Action35 == 49
                b35[0] = (FortifyIllusionPerk.SetNthEntryValue(0, 1, f35[6])) as Int
              Else
                Return
              EndIf
            EndIf
          EndIf
        Else
          If Action35 < 73
            If Action35 == 52
              Temp35_temp5 = FortifySneakSpell as form
              b35[0] = (PlayerRef.HasSpell(Temp35_temp5)) as Int
            ElseIf Action35 == 57
              FortifySneakSpell.SetNthEffectMagnitude(0, f35[5])
            ElseIf Action35 == 63
              i35[1] = sKSE.GetPluginVersion("PSQ Appearance")
            ElseIf Action35 == 67
              Temp35_temp6 = self as quest
              i35[1] = pSQAppearance.ApplyPromotionAbilities(Temp35_temp6, PlayerRef, SuccubusRank, SuccubusEXP)
            Else
              Return
            EndIf
          Else
            If Action35 < 79
              If Action35 == 73
                SuccubusRank.SetValue(f35[5])
              ElseIf Action35 == 76
                Temp35_temp3 = i35[2] as string
                Temp35_temp3 = "$PSQ_RankUpTo" + Temp35_temp3
                debug.Notification(Temp35_temp3)
              Else
                Return
              EndIf
            Else
              If Action35 == 79
                Temp35_temp3 = i35[2] as string
                Temp35_temp3 = "$PSQ_GotTitle" + Temp35_temp3
                debug.Notification(Temp35_temp3)
              ElseIf Action35 == 91
                SuccubusRank.SetValue(2.0)
              ElseIf Action35 == 92
                debug.Notification("$PSQ_RankUpTo2")
              Else
                Return
              EndIf
            EndIf
          EndIf
        EndIf
      Else
        If Action35 < 124
          If Action35 < 104
            If Action35 == 93
              debug.Notification("$PSQ_GotTitle2")
            ElseIf Action35 == 95
              b35[0] = (PlayerRef.AddSpell(SuccubusDrainFF02, false)) as Int
            ElseIf Action35 == 98
              b35[0] = (PlayerRef.AddSpell(SuccubusDrainHealthSpell02, false)) as Int
            ElseIf Action35 == 101
              b35[0] = (PlayerRef.AddSpell(SuccubusDrainStaminaSpell02, false)) as Int
            Else
              Return
            EndIf
          Else
            If Action35 < 120
              If Action35 == 104
                b35[0] = (PlayerRef.AddSpell(FortifyBartarSpell2, false)) as Int
              ElseIf Action35 == 106
                b35[0] = (PlayerRef.AddSpell(SuccuKanashibari, false)) as Int
              Else
                Return
              EndIf
            Else
              If Action35 == 120
                SuccubusRank.SetValue(3.0)
              ElseIf Action35 == 121
                debug.Notification("$PSQ_RankUpTo3")
              ElseIf Action35 == 122
                debug.Notification("$PSQ_GotTitle3")
              Else
                Return
              EndIf
            EndIf
          EndIf
        Else
          If Action35 < 148
            If Action35 == 124
              b35[0] = (PlayerRef.AddSpell(SuccubusDrainStaminaSpell03, false)) as Int
            ElseIf Action35 == 127
              b35[0] = (PlayerRef.AddSpell(SuccubusDrainHealthSpell03, false)) as Int
            ElseIf Action35 == 130
              b35[0] = (PlayerRef.AddSpell(SuccubusDrainFF03, false)) as Int
            ElseIf Action35 == 133
              b35[0] = (PlayerRef.AddSpell(FortifyBartarSpell3, false)) as Int
            Else
              Return
            EndIf
          Else
            If Action35 < 150
              If Action35 == 148
                SuccubusRank.SetValue(4.0)
              ElseIf Action35 == 149
                debug.Notification("$PSQ_RankUpTo4")
              Else
                Return
              EndIf
            Else
              If Action35 == 150
                debug.Notification("$PSQ_GotTitle4")
              ElseIf Action35 == 152
                b35[0] = (PlayerRef.AddSpell(SuccubusDrainStaminaSpell04, false)) as Int
              ElseIf Action35 == 155
                b35[0] = (PlayerRef.AddSpell(SuccubusDrainHealthSpell04, false)) as Int
              Else
                Return
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    Else
      If Action35 < 234
        If Action35 < 190
          If Action35 < 178
            If Action35 == 158
              b35[0] = (PlayerRef.AddSpell(SuccubusDrainFF04, false)) as Int
            ElseIf Action35 == 160
              b35[0] = (PlayerRef.AddSpell(FortifyMSGBoxSpell, false)) as Int
            ElseIf Action35 == 162
              b35[0] = (PlayerRef.AddSpell(FortifyBartarSpell4, false)) as Int
            ElseIf Action35 == 177
              SuccubusRank.SetValue(5.0)
            Else
              Return
            EndIf
          Else
            If Action35 < 181
              If Action35 == 178
                debug.Notification("$PSQ_RankUpTo5")
              ElseIf Action35 == 179
                debug.Notification("$PSQ_GotTitle5")
              Else
                Return
              EndIf
            Else
              If Action35 == 181
                b35[0] = (PlayerRef.AddSpell(SuccubusDrainStaminaSpell05, false)) as Int
              ElseIf Action35 == 184
                b35[0] = (PlayerRef.AddSpell(SuccubusDrainHealthSpell05, false)) as Int
              ElseIf Action35 == 187
                b35[0] = (PlayerRef.AddSpell(SuccubusDrainFF05, false)) as Int
              Else
                Return
              EndIf
            EndIf
          EndIf
        Else
          If Action35 < 209
            If Action35 == 190
              b35[0] = (PlayerRef.AddSpell(FortifyBartarSpell5, false)) as Int
            ElseIf Action35 == 205
              SuccubusRank.SetValue(6.0)
            ElseIf Action35 == 206
              debug.Notification("$PSQ_RankUpTo6")
            ElseIf Action35 == 207
              debug.Notification("$PSQ_GotTitle6")
            Else
              Return
            EndIf
          Else
            If Action35 < 215
              If Action35 == 209
                b35[0] = (PlayerRef.AddSpell(SuccubusDrainStaminaSpell06, false)) as Int
              ElseIf Action35 == 212
                b35[0] = (PlayerRef.AddSpell(SuccubusDrainHealthSpell06, false)) as Int
              Else
                Return
              EndIf
            Else
              If Action35 == 215
                b35[0] = (PlayerRef.AddSpell(SuccubusDrainFF06, false)) as Int
              ElseIf Action35 == 218
                b35[0] = (PlayerRef.AddSpell(FortifyBartarSpell6, false)) as Int
              ElseIf Action35 == 233
                SuccubusRank.SetValue(7.0)
              Else
                Return
              EndIf
            EndIf
          EndIf
        EndIf
      Else
        If Action35 < 265
          If Action35 < 243
            If Action35 == 234
              debug.Notification("$PSQ_RankUpTo7")
            ElseIf Action35 == 235
              debug.Notification("$PSQ_GotTitle7")
            ElseIf Action35 == 237
              b35[0] = (PlayerRef.AddSpell(SuccubusDrainStaminaSpell07, false)) as Int
            ElseIf Action35 == 240
              b35[0] = (PlayerRef.AddSpell(SuccubusDrainHealthSpell07, false)) as Int
            Else
              Return
            EndIf
          Else
            If Action35 < 261
              If Action35 == 243
                b35[0] = (PlayerRef.AddSpell(SuccubusDrainFF07, false)) as Int
              ElseIf Action35 == 246
                b35[0] = (PlayerRef.AddSpell(FortifyBartarSpell7, false)) as Int
              Else
                Return
              EndIf
            Else
              If Action35 == 261
                SuccubusRank.SetValue(8.0)
              ElseIf Action35 == 262
                debug.Notification("$PSQ_RankUpTo8")
              ElseIf Action35 == 263
                debug.Notification("$PSQ_GotTitle8")
              Else
                Return
              EndIf
            EndIf
          EndIf
        Else
          If Action35 < 285
            If Action35 < 271
              If Action35 == 265
                b35[0] = (PlayerRef.AddSpell(SuccubusDrainStaminaSpell08, false)) as Int
              ElseIf Action35 == 268
                b35[0] = (PlayerRef.AddSpell(SuccubusDrainHealthSpell08, false)) as Int
              Else
                Return
              EndIf
            Else
              If Action35 == 271
                b35[0] = (PlayerRef.AddSpell(SuccubusDrainFF08, false)) as Int
              ElseIf Action35 == 274
                b35[0] = (PlayerRef.AddSpell(FortifyBartarSpell8, false)) as Int
              ElseIf Action35 == 282
                b35[0] = (self.UpdateAdvancedSuccubusRank(true)) as Int
              Else
                Return
              EndIf
            EndIf
          Else
            If Action35 < 289
              If Action35 == 285
                self.QueueRankUpAnimation(i35[0], i35[1])
              ElseIf Action35 == 287
                self.SuccubusLevelUp(0.0)
              Else
                Return
              EndIf
            Else
              If Action35 == 289
                self.Satiety(0.0)
              ElseIf Action35 == 290
                self.SyncManagedAbilities()
              ElseIf Action35 == 291
                self.SyncContinuousAbilities(false)
              Else
                Return
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndWhile
EndFunction

Float Function ProcessingArousalCompat34(Actor Target, Float DrainValue)
  Float ArousedRank = storageutil.GetIntValue(Target as Form, "PSQ_ArousalAtBeginning", 0) as Float
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777232
    Return PSQAppearance.AdjustArousalDrain(DrainValue, ArousedRank)
  EndIf
  If ArousedRank < 0.0
    Return DrainValue
  EndIf
  Float DrainValueMod = ArousedRank * ArousedRank / 10000.0
  If DrainValueMod < 0.100000001
    Return DrainValue * 0.100000001
  Else
    Return DrainValue * DrainValueMod
  EndIf
EndFunction

float Function ProcessingArousal35(actor Target, Float DrainValue)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Return Self.ProcessingArousalCompat34(Target,DrainValue)
  EndIf
  Int[] i35 = new Int[4]
  Float[] f35 = new Float[5]
  Int[] b35 = new Int[2]
  Int Action35 = 0
  f35[0] = DrainValue
  form Temp35_temp0
  i35[1] = PSQLoadEpoch
  i35[2] = PSQSexSceneEpoch
  i35[3] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.ProcessingArousalStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return f35[4]
    EndIf
    If Action35 == 2
      Temp35_temp0 = Target as form
      i35[0] = storageUtil.GetIntValue(Temp35_temp0, "PSQ_ArousalAtBeginning", 0)
    ElseIf Action35 == 5
      i35[0] = sKSE.GetPluginVersion("PSQ Appearance")
    ElseIf Action35 == 8
      f35[2] = pSQAppearance.AdjustArousalDrain(f35[0], f35[1])
    Else
      Return f35[4]
    EndIf
  EndWhile
  Return f35[4]
EndFunction

Function ResetStatPoolEditsOnLoadCompat34()
  PrimedTransformPoolValues = EmptyFloatArray
  PrimedTransformPoolLoad = -1
  Self.CancelDeferredTransformRefill()
  TransformRefillBusyOwner = -1
  Bool Interrupted = StatPoolEditBusy || SatiationRefreshBusy || ContinuousSyncBusy
  If !StatCachesMigrated
    StatCachesMigrated = True
    If !Interrupted
      StableAppliedContinuousMode = AppliedContinuousMode
      StableAppliedContinuousRank = AppliedContinuousRank
      StableAppliedContinuousHealth = AppliedContinuousHealth
      StableAppliedContinuousMagicka = AppliedContinuousMagicka
      StableAppliedContinuousStamina = AppliedContinuousStamina
      StableAppliedContinuousCarry = AppliedContinuousCarry
      StableAppliedContinuousUnarmed = AppliedContinuousUnarmed
      StableCachedSatiationInputs = CachedSatiationInputs
      StableAppliedSatiationMagnitudes = AppliedSatiationMagnitudes
      StableAppliedSatiationSpell = AppliedSatiationSpell
    EndIf
  EndIf
  StatPoolEditEpoch += 1
  StatPoolEditBusy = False
  SatiationRefreshBusy = False
  ContinuousSyncBusy = False
  SatiationRefreshPending = True
  TransformBuffRefreshPending = True
  ContinuousRecordSyncPending = True
  TransformRecordSyncPending = True
  SatiationRecordSyncPending = True
  If Interrupted
    ContinuousSyncPending = True
    ForceTransformBuffRefresh = True
    StableAppliedContinuousMode = -1
    StableCachedSatiationInputs = EmptyFloatArray
    StableAppliedSatiationMagnitudes = EmptyFloatArray
    StableAppliedSatiationSpell = None
    StableTransformMagnitudes = EmptyFloatArray
  EndIf
EndFunction

Function ResetStatPoolEditsOnLoad35()
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.ResetStatPoolEditsOnLoadCompat34()
    Return
  EndIf
  Int[] i35 = new Int[4]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[3]
  Int Action35 = 0
  spell Temp35_temp2
  i35[1] = PSQLoadEpoch
  i35[2] = PSQSexSceneEpoch
  i35[3] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.ResetStatPoolEditsOnLoadStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 == 1
      PrimedTransformPoolValues = EmptyFloatArray
    ElseIf Action35 == 3
      self.CancelDeferredTransformRefill(-1)
    ElseIf Action35 == 26
      StableCachedSatiationInputs = CachedSatiationInputs
      StableAppliedSatiationMagnitudes = AppliedSatiationMagnitudes
      StableAppliedSatiationSpell = AppliedSatiationSpell
    ElseIf Action35 == 47
      StableCachedSatiationInputs = EmptyFloatArray
      StableAppliedSatiationMagnitudes = EmptyFloatArray
      Temp35_temp2 = None as spell
      StableAppliedSatiationSpell = Temp35_temp2
      StableTransformMagnitudes = EmptyFloatArray
    Else
      Return
    EndIf
  EndWhile
EndFunction

Function CancelInterruptedAppearanceOnLoadCompat34()
  ; Entry sets IsHenshinchu before the first charge, bonus or equipment write.
  ; A pre-commit entry leaves any previous unresolved originals in their ledger.
  AppearanceOperationId += 1
  Int NewOwner = AppearanceOperationId
  Int Epoch = PSQLoadEpoch
  Int Route = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777227
    Route = PSQAppearance.ClassifyLoadedAppearance(AppearanceTransformDirection, IsHenshinchu, IsHenshined, AppearanceRecoveryPending)
  ElseIf AppearanceRecoveryPending || IsHenshinchu
    Route = 2
  ElseIf AppearanceTransformDirection == 1 && !IsHenshined
    Route = 1
  ElseIf AppearanceTransformDirection != 0
    Route = 2
  EndIf
  If NewOwner != AppearanceOperationId || Epoch != PSQLoadEpoch
    Return
  EndIf
  If Route == 2
    AppearanceRecoveryPending = True
  EndIf
  Self.ResetStatPoolEditsOnLoad()
  AppearanceRecoveryAfter = Utility.GetCurrentRealTime() + 3.0
  AppearanceEditBusy = False
  IsHenshinchu = False
  BodySelectionRefreshBusy = False
  AppearanceTransformDirection = 0
  AppearanceRecoveryInProgress = False
  AppearanceRecoveryRequested = False
  If Route == 1 && !AppearanceRecoveryPending && PlayerRef != None
    storageutil.SetIntValue(PlayerRef, "PSQ_SuccubusON", 0)
  EndIf
  storageutil.UnsetIntValue(PlayerRef as Form, "PSQ_TDFAppearanceBusy")
EndFunction

Function CancelInterruptedAppearanceOnLoad35()
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.CancelInterruptedAppearanceOnLoadCompat34()
    Return
  EndIf
  Int[] i35 = new Int[7]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[2]
  Int Action35 = 0
  actor Temp35_temp3
  form Temp35_temp4
  i35[4] = PSQLoadEpoch
  i35[5] = PSQSexSceneEpoch
  i35[6] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.CancelInterruptedAppearanceOnLoadStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 46
      If Action35 == 6
        i35[0] = sKSE.GetPluginVersion("PSQ Appearance")
      ElseIf Action35 == 9
        i35[0] = pSQAppearance.ClassifyLoadedAppearance(AppearanceTransformDirection, IsHenshinchu, IsHenshined, AppearanceRecoveryPending)
      ElseIf Action35 == 45
        self.ResetStatPoolEditsOnLoad()
      Else
        Return
      EndIf
    Else
      If Action35 == 46
        f35[0] = utility.GetCurrentRealTime()
      ElseIf Action35 == 63
        Temp35_temp3 = None as actor
        b35[0] = (PlayerRef == Temp35_temp3) as Int
      ElseIf Action35 == 68
        Temp35_temp4 = PlayerRef as form
        i35[0] = storageUtil.SetIntValue(Temp35_temp4, "PSQ_SuccubusON", 0)
      ElseIf Action35 == 71
        Temp35_temp4 = PlayerRef as form
        b35[0] = (storageUtil.UnsetIntValue(Temp35_temp4, "PSQ_TDFAppearanceBusy")) as Int
      Else
        Return
      EndIf
    EndIf
  EndWhile
EndFunction

Function InvalidateAppearanceForLoadCompat34(Int Epoch)
  If Epoch != PSQLoadEpoch || AppearanceInvalidatedLoad == Epoch
    Return
  EndIf
  AppearanceInvalidatedLoad = Epoch
  Self.CancelInterruptedAppearanceOnLoad()
EndFunction

Function InvalidateAppearanceForLoad35(Int Epoch)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.InvalidateAppearanceForLoadCompat34(Epoch)
    Return
  EndIf
  Int[] i35 = new Int[4]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[2]
  Int Action35 = 0
  i35[0] = Epoch
  i35[1] = PSQLoadEpoch
  i35[2] = PSQSexSceneEpoch
  i35[3] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.InvalidateAppearanceForLoadStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 == 11
      self.CancelInterruptedAppearanceOnLoad()
    Else
      Return
    EndIf
  EndWhile
EndFunction

Function RestoreRetirementPoolsCompat34(Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  If !RetirementPoolsPending || PlayerRef == None || PlayerRef.IsDead()
    Return
  EndIf
  Float SavedHealth = RetirementSavedHealth
  Float SavedMagicka = RetirementSavedMagicka
  Float SavedStamina = RetirementSavedStamina
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  RetirementPoolsPending = False
  Self.RestoreCleanupHealth(PlayerRef, SavedHealth)
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  Self.PreserveSatiationCurrentValue("Magicka", SavedMagicka, -1, -1)
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  Self.PreserveSatiationCurrentValue("Stamina", SavedStamina, -1, -1)
EndFunction

Function RestoreRetirementPools35(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.RestoreRetirementPoolsCompat34(Owner,RequireBusy)
    Return
  EndIf
  Int[] i35 = new Int[4]
  Float[] f35 = new Float[3]
  Int[] b35 = new Int[3]
  Int Action35 = 0
  i35[0] = Owner
  b35[0] = (RequireBusy) as Int
  actor Temp35_temp1
  i35[1] = PSQLoadEpoch
  i35[2] = PSQSexSceneEpoch
  i35[3] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.RestoreRetirementPoolsStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 33
      If Action35 == 15
        Temp35_temp1 = None as actor
        b35[1] = (PlayerRef == Temp35_temp1) as Int
      ElseIf Action35 == 19
        b35[1] = (PlayerRef.IsDead()) as Int
      Else
        Return
      EndIf
    Else
      If Action35 == 33
        self.RestoreCleanupHealth(PlayerRef, f35[0])
      ElseIf Action35 == 39
        self.PreserveSatiationCurrentValue("Magicka", f35[1], -1, -1)
      ElseIf Action35 == 45
        self.PreserveSatiationCurrentValue("Stamina", f35[2], -1, -1)
      Else
        Return
      EndIf
    EndIf
  EndWhile
EndFunction

Function ClearContinuousRankEffectsCompat34(Int Owner, Int PoolEpoch)
  Bool OwnsEdit = PoolEpoch < 0
  If Owner < 0
    If AppearanceEditBusy
      ContinuousSyncPending = True
      Return
    EndIf
    Owner = AppearanceOperationId
  EndIf
  If OwnsEdit
    PoolEpoch = Self.BeginStatPoolEdit(Owner, True)
  EndIf
  If PoolEpoch < 0 || !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    ContinuousSyncPending = True
    Return
  EndIf
  Self.ClearContinuousRankEffectsCore(Owner, PoolEpoch)
  If OwnsEdit
    Self.EndStatPoolEdit(PoolEpoch)
  EndIf
EndFunction

Function ClearContinuousRankEffects35(Int Owner, Int PoolEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.ClearContinuousRankEffectsCompat34(Owner,PoolEpoch)
    Return
  EndIf
  Int[] i35 = new Int[6]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[3]
  Int Action35 = 0
  i35[0] = Owner
  i35[1] = PoolEpoch
  i35[3] = PSQLoadEpoch
  i35[4] = PSQSexSceneEpoch
  i35[5] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.ClearContinuousRankEffectsStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 == 12
      i35[2] = self.BeginStatPoolEdit(i35[0], true)
    ElseIf Action35 == 18
      b35[1] = (self.IsStatPoolEditCurrent(i35[1], i35[0])) as Int
    ElseIf Action35 == 25
      self.ClearContinuousRankEffectsCore(i35[0], i35[1])
    ElseIf Action35 == 27
      self.EndStatPoolEdit(i35[1])
    Else
      Return
    EndIf
  EndWhile
EndFunction

Function ClearContinuousRankEffectsCoreCompat34(Int Owner, Int PoolEpoch)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  If !PlayerRef
    Return
  EndIf
  Spell Ability = Self.GetContinuousRankAbility()
  If Ability as Bool && PlayerRef.HasSpell(Ability as Form)
    Float HealthBefore = PlayerRef.GetAV("Health")
    Float MagickaBefore = PlayerRef.GetAV("Magicka")
    Float StaminaBefore = PlayerRef.GetAV("Stamina")
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Self.BufferContinuousHealth(PoolEpoch, Owner)
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    PlayerRef.DispelSpell(Ability)
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    PlayerRef.RemoveSpell(Ability)
    If HealthBefore > 0.0 && !PlayerRef.IsDead()
      If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
        Return
      EndIf
      Self.PreserveSatiationCurrentValue("Health", HealthBefore, PoolEpoch, Owner)
    EndIf
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Self.PreserveSatiationCurrentValue("Magicka", MagickaBefore, PoolEpoch, Owner)
    If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
      Return
    EndIf
    Self.PreserveSatiationCurrentValue("Stamina", StaminaBefore, PoolEpoch, Owner)
  EndIf
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  Self.SetContinuousOwnedPerk(Self.GetContinuousRankPerk(), False, PoolEpoch, Owner)
  If !Self.IsStatPoolEditCurrent(PoolEpoch, Owner)
    Return
  EndIf
  StableAppliedContinuousMode = -1
EndFunction

Function ClearContinuousRankEffectsCore35(Int Owner, Int PoolEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.ClearContinuousRankEffectsCoreCompat34(Owner,PoolEpoch)
    Return
  EndIf
  Int[] i35 = new Int[5]
  Float[] f35 = new Float[4]
  Int[] b35 = new Int[2]
  Int Action35 = 0
  i35[0] = Owner
  i35[1] = PoolEpoch
  spell Ability
  spell Temp35_temp1
  form Temp35_temp2
  perk Temp35_temp4
  i35[2] = PSQLoadEpoch
  i35[3] = PSQSexSceneEpoch
  i35[4] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.ClearContinuousRankEffectsCoreStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return
    EndIf
    If Action35 < 37
      If Action35 < 21
        If Action35 < 12
          If Action35 == 1
            b35[0] = (self.IsStatPoolEditCurrent(i35[1], i35[0])) as Int
          ElseIf Action35 == 6
            b35[0] = (!PlayerRef) as Int
          ElseIf Action35 == 10
            Temp35_temp1 = self.GetContinuousRankAbility()
          Else
            Return
          EndIf
        Else
          If Action35 == 12
            Ability = Temp35_temp1
            b35[0] = (Ability as bool) as Int
          ElseIf Action35 == 16
            Temp35_temp2 = Ability as form
            b35[0] = (PlayerRef.HasSpell(Temp35_temp2)) as Int
          ElseIf Action35 == 19
            f35[1] = PlayerRef.GetAV("Health")
          Else
            Return
          EndIf
        EndIf
      Else
        If Action35 < 30
          If Action35 == 21
            f35[1] = PlayerRef.GetAV("Magicka")
          ElseIf Action35 == 23
            f35[1] = PlayerRef.GetAV("Stamina")
          ElseIf Action35 == 25
            b35[0] = (self.IsStatPoolEditCurrent(i35[1], i35[0])) as Int
          Else
            Return
          EndIf
        Else
          If Action35 == 30
            self.BufferContinuousHealth(i35[1], i35[0])
          ElseIf Action35 == 31
            b35[0] = (self.IsStatPoolEditCurrent(i35[1], i35[0])) as Int
          ElseIf Action35 == 36
            b35[0] = (PlayerRef.DispelSpell(Ability)) as Int
          Else
            Return
          EndIf
        EndIf
      EndIf
    Else
      If Action35 < 62
        If Action35 < 50
          If Action35 == 37
            b35[0] = (self.IsStatPoolEditCurrent(i35[1], i35[0])) as Int
          ElseIf Action35 == 42
            b35[0] = (PlayerRef.RemoveSpell(Ability)) as Int
          ElseIf Action35 == 46
            b35[0] = (PlayerRef.IsDead()) as Int
          Else
            Return
          EndIf
        Else
          If Action35 == 50
            b35[0] = (self.IsStatPoolEditCurrent(i35[1], i35[0])) as Int
          ElseIf Action35 == 55
            self.PreserveSatiationCurrentValue("Health", f35[0], i35[1], i35[0])
          ElseIf Action35 == 57
            b35[0] = (self.IsStatPoolEditCurrent(i35[1], i35[0])) as Int
          Else
            Return
          EndIf
        EndIf
      Else
        If Action35 < 70
          If Action35 == 62
            self.PreserveSatiationCurrentValue("Magicka", f35[2], i35[1], i35[0])
          ElseIf Action35 == 63
            b35[0] = (self.IsStatPoolEditCurrent(i35[1], i35[0])) as Int
          ElseIf Action35 == 68
            self.PreserveSatiationCurrentValue("Stamina", f35[3], i35[1], i35[0])
          Else
            Return
          EndIf
        Else
          If Action35 == 70
            b35[0] = (self.IsStatPoolEditCurrent(i35[1], i35[0])) as Int
          ElseIf Action35 == 75
            Temp35_temp4 = self.GetContinuousRankPerk()
          ElseIf Action35 == 76
            self.SetContinuousOwnedPerk(Temp35_temp4, false, i35[1], i35[0])
          ElseIf Action35 == 77
            b35[0] = (self.IsStatPoolEditCurrent(i35[1], i35[0])) as Int
          Else
            Return
          EndIf
        EndIf
      EndIf
    EndIf
  EndWhile
EndFunction

Function CleanupRetiredFastModeKeysCompat34()
  ; Migration for old zero/negative counters and abandoned end claims, scoped
  ; to THIS PSQ quest. Keep every key in the current load epoch untouched.
  Int Epoch = PSQSexSceneEpoch
  String CallbackPrefix = "PSQ_FastCallbacks_" + Epoch + "_"
  String EndPrefix = "PSQ_FastEnd_" + Epoch + "_"
  String[] Keys = StorageUtil.debug_AllObjIntKeys(Self as Form)
  if !Keys
    return
  endif
  Int i = 0
  while i < Keys.Length && Epoch == PSQSexSceneEpoch
    String Key = Keys[i]
    Bool Retired = StringUtil.Find(Key, "PSQ_FastCallbacks_") == 0 && StringUtil.Find(Key, CallbackPrefix) != 0
    if !Retired
      Retired = StringUtil.Find(Key, "PSQ_FastEnd_") == 0 && StringUtil.Find(Key, EndPrefix) != 0
    endif
    if Retired
      StorageUtil.UnsetIntValue(Self as Form, Key)
    endif
    i += 1
  endwhile
EndFunction

bool Function CleanupRetiredFastModeKeys35()
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.CleanupRetiredFastModeKeysCompat34()
    Return False
  EndIf
  Int[] i35 = new Int[6]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[3]
  Int Action35 = 0
  String CallbackPrefix
  String Temp35_temp0
  String EndPrefix
  String[] Keys
  form Temp35_temp1
  String[] Temp35_temp2
  String Key
  i35[3] = PSQLoadEpoch
  i35[4] = PSQSexSceneEpoch
  i35[5] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.CleanupRetiredFastModeKeysStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return False
    EndIf
    If Action35 < 31
      If Action35 == 11
        Temp35_temp0 = i35[0] as string
        Temp35_temp0 = "PSQ_FastCallbacks_" + Temp35_temp0
        Temp35_temp0 = Temp35_temp0 + "_"
        CallbackPrefix = Temp35_temp0
        Temp35_temp0 = i35[0] as string
        Temp35_temp0 = "PSQ_FastEnd_" + Temp35_temp0
        Temp35_temp0 = Temp35_temp0 + "_"
        EndPrefix = Temp35_temp0
        Temp35_temp1 = self as form
        Temp35_temp2 = storageUtil.debug_AllObjIntKeys(Temp35_temp1)
      ElseIf Action35 == 13
        Keys = Temp35_temp2
        b35[0] = (!Keys) as Int
      ElseIf Action35 == 18
        i35[2] = Keys.Length
      ElseIf Action35 == 27
        Temp35_temp0 = Keys[i35[1]]
        Key = Temp35_temp0
        i35[2] = stringUtil.Find(Key, "PSQ_FastCallbacks_", 0)
      Else
        Return False
      EndIf
    Else
      If Action35 == 31
        i35[2] = stringUtil.Find(Key, CallbackPrefix, 0)
      ElseIf Action35 == 38
        i35[2] = stringUtil.Find(Key, "PSQ_FastEnd_", 0)
      ElseIf Action35 == 42
        i35[2] = stringUtil.Find(Key, EndPrefix, 0)
      ElseIf Action35 == 50
        Temp35_temp1 = self as form
        b35[0] = (storageUtil.UnsetIntValue(Temp35_temp1, Key)) as Int
      Else
        Return False
      EndIf
    EndIf
  EndWhile
  Return False
EndFunction

Function ResetSlotsCompat34()
  Actor[] Emptyslots
  Slots = Emptyslots
EndFunction

actor[] Function ResetSlots35()
  Actor[] Emptyslots
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Self.ResetSlotsCompat34()
    Return Emptyslots
  EndIf
  Int[] i35 = new Int[3]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[1]
  Int Action35 = 0
  i35[0] = PSQLoadEpoch
  i35[1] = PSQSexSceneEpoch
  i35[2] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.ResetSlotsStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return Emptyslots
    EndIf
    If Action35 == 1
      Slots = Emptyslots
    Else
      Return Emptyslots
    EndIf
  EndWhile
  Return Emptyslots
EndFunction

Bool Function EnsureDeferredDrainCompat34(Actor Target, Int TID)
  If Target == None || Target == PlayerRef || TID < 0
    Return False
  EndIf
  If storageutil.GetIntValue(Target as Form, "PSQ_DrainClosedThread", -1) == TID
    Return False
  EndIf
  If storageutil.GetIntValue(Target as Form, "PSQ_DrainDamageThread", -1) != TID
    Self.BeginDeferredDrain(Target, TID)
  EndIf
  Return True
EndFunction

bool Function EnsureDeferredDrain35(actor Target, Int TID)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Return Self.EnsureDeferredDrainCompat34(Target,TID)
  EndIf
  Int[] i35 = new Int[5]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[3]
  Int Action35 = 0
  i35[0] = TID
  actor Temp35_temp0
  form Temp35_temp2
  i35[2] = PSQLoadEpoch
  i35[3] = PSQSexSceneEpoch
  i35[4] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.EnsureDeferredDrainStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return b35[1] as Bool
    EndIf
    If Action35 < 15
      If Action35 == 2
        Temp35_temp0 = None as actor
        b35[0] = (Target == Temp35_temp0) as Int
      ElseIf Action35 == 5
        b35[0] = (Target == PlayerRef) as Int
      Else
        Return b35[1] as Bool
      EndIf
    Else
      If Action35 == 15
        Temp35_temp2 = Target as form
        i35[1] = storageUtil.GetIntValue(Temp35_temp2, "PSQ_DrainClosedThread", -1)
      ElseIf Action35 == 21
        Temp35_temp2 = Target as form
        i35[1] = storageUtil.GetIntValue(Temp35_temp2, "PSQ_DrainDamageThread", -1)
      ElseIf Action35 == 25
        self.BeginDeferredDrain(Target, i35[0])
      Else
        Return b35[1] as Bool
      EndIf
    EndIf
  EndWhile
  Return b35[1] as Bool
EndFunction

Bool Function IsFastModeClosingSceneCompat34(Int TID)
  ; Also reject forced end-climax callbacks if the user toggles FastMode off
  ; after the end request. The marker lives until the next real scene start.
  if PPlusThreadID != TID
    return False
  endif
  String ClosingKey = "PSQ_FastEnd_" + PSQSexSceneEpoch + "_" + FastModeSceneSerial + "_closing"
  return StorageUtil.GetIntValue(Self as Form, ClosingKey, 0) == 1
EndFunction

bool Function IsFastModeClosingScene35(Int TID)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Return Self.IsFastModeClosingSceneCompat34(TID)
  EndIf
  Int[] i35 = new Int[5]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[3]
  Int Action35 = 0
  i35[0] = TID
  String ClosingKey
  String Temp35_temp1
  String Temp35_temp2
  form Temp35_temp3
  i35[2] = PSQLoadEpoch
  i35[3] = PSQSexSceneEpoch
  i35[4] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.IsFastModeClosingSceneStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return b35[1] as Bool
    EndIf
    If Action35 == 14
      Temp35_temp1 = PSQSexSceneEpoch as string
      Temp35_temp1 = "PSQ_FastEnd_" + Temp35_temp1
      Temp35_temp1 = Temp35_temp1 + "_"
      Temp35_temp2 = FastModeSceneSerial as string
      Temp35_temp2 = Temp35_temp1 + Temp35_temp2
      Temp35_temp2 = Temp35_temp2 + "_closing"
      ClosingKey = Temp35_temp2
      Temp35_temp3 = self as form
      i35[1] = storageUtil.GetIntValue(Temp35_temp3, ClosingKey, 0)
    Else
      Return b35[1] as Bool
    EndIf
  EndWhile
  Return b35[1] as Bool
EndFunction

Bool Function FastModeTargetsExhaustedCompat34(Actor[] Actors, Int TID)
  Bool HasTarget = False
  if Actors.Length < 2 || Actors.Find(PlayerRef) < 0 || Actors.Length != PPlusSceneActors.Length
    return False
  endif
  Int i = 0
  while i < Actors.Length
    Actor Target = Actors[i]
    if Target == None || PPlusSceneActors.Find(Target) < 0
      return False
    endif
    if Target != PlayerRef && Self.IsNotUndead(Target)
      HasTarget = True
      ; Unknown or unrelated reserves are never assumed to be empty. Do not
      ; call SetEnergy/GetNPCEnergySnapshot here: they regenerate NPC reserves.
      if !StorageUtil.HasFloatValue(Target as Form, "PSQ_EnergyOfActor")
        return False
      endif
      if StorageUtil.GetIntValue(Target as Form, "PSQ_DrainDamageThread", -1) != TID
        return False
      endif
      Float Remaining = StorageUtil.GetFloatValue(Target as Form, "PSQ_EnergyOfActor", 0.0)
      if Remaining != Remaining || Remaining > 0.001
        return False
      endif
    endif
    i += 1
  endwhile
  return HasTarget
EndFunction

bool Function FastModeTargetsExhausted35(actor[] Actors, Int TID)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Return Self.FastModeTargetsExhaustedCompat34(Actors,TID)
  EndIf
  Int[] i35 = new Int[7]
  Float[] f35 = new Float[2]
  Int[] b35 = new Int[4]
  Int Action35 = 0
  i35[0] = TID
  actor Target
  actor Temp35_temp3
  form Temp35_temp4
  i35[4] = PSQLoadEpoch
  i35[5] = PSQSexSceneEpoch
  i35[6] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.FastModeTargetsExhaustedStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return b35[2] as Bool
    EndIf
    If Action35 < 29
      If Action35 < 12
        If Action35 == 2
          i35[1] = Actors.Length
        ElseIf Action35 == 6
          i35[1] = Actors.Find(PlayerRef, 0)
        Else
          Return b35[2] as Bool
        EndIf
      Else
        If Action35 == 12
          i35[1] = Actors.Length
          i35[2] = PPlusSceneActors.Length
        ElseIf Action35 == 20
          i35[2] = Actors.Length
        ElseIf Action35 == 26
          Temp35_temp3 = Actors[i35[3]]
          Target = Temp35_temp3
          Temp35_temp3 = None as actor
          b35[1] = (Target == Temp35_temp3) as Int
        Else
          Return b35[2] as Bool
        EndIf
      EndIf
    Else
      If Action35 < 44
        If Action35 == 29
          i35[2] = PPlusSceneActors.Find(Target, 0)
        ElseIf Action35 == 35
          b35[1] = (Target == PlayerRef) as Int
        ElseIf Action35 == 39
          b35[1] = (self.IsNotUndead(Target)) as Int
        Else
          Return b35[2] as Bool
        EndIf
      Else
        If Action35 == 44
          Temp35_temp4 = Target as form
          b35[1] = (storageUtil.HasFloatValue(Temp35_temp4, "PSQ_EnergyOfActor")) as Int
        ElseIf Action35 == 50
          Temp35_temp4 = Target as form
          i35[2] = storageUtil.GetIntValue(Temp35_temp4, "PSQ_DrainDamageThread", -1)
        ElseIf Action35 == 57
          Temp35_temp4 = Target as form
          f35[1] = storageUtil.GetFloatValue(Temp35_temp4, "PSQ_EnergyOfActor", 0.0)
        Else
          Return b35[2] as Bool
        EndIf
      EndIf
    EndIf
  EndWhile
  Return b35[2] as Bool
EndFunction

Int Function GetFastModePendingCallbacksCompat34(Int TID)
  return StorageUtil.GetIntValue(Self as Form, Self.GetFastModeCallbackKey(TID, FastModeCallbackGeneration, PSQSexSceneEpoch), 0)
EndFunction

int Function GetFastModePendingCallbacks35(Int TID)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777251
    Return Self.GetFastModePendingCallbacksCompat34(TID)
  EndIf
  Int[] i35 = new Int[6]
  Float[] f35 = new Float[1]
  Int[] b35 = new Int[1]
  Int Action35 = 0
  i35[0] = TID
  form Temp35_temp0
  String Temp35_temp1
  i35[3] = PSQLoadEpoch
  i35[4] = PSQSexSceneEpoch
  i35[5] = FastModeCallbackGeneration
  While True
    Action35 = PSQAppearance.GetFastModePendingCallbacksStep35(Self, Action35, i35, f35, b35, None)
    If Action35 <= 0
      Return i35[2]
    EndIf
    If Action35 == 2
      Temp35_temp0 = self as form
      Temp35_temp1 = self.GetFastModeCallbackKey(i35[0], FastModeCallbackGeneration, PSQSexSceneEpoch)
    ElseIf Action35 == 3
      i35[1] = storageUtil.GetIntValue(Temp35_temp0, Temp35_temp1, 0)
    Else
      Return i35[2]
    EndIf
  EndWhile
  Return i35[2]
EndFunction



Int Function GetSuccubusEyeMaterialCountCompat37()
  Self.MigrateHeartEyeSelection()
  Return jsonutil.StringListCount("PSQ/EyeMaterials", "names")
EndFunction

Int Function GetSuccubusEyeMaterialCount38()
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777254
    Return Self.GetSuccubusEyeMaterialCountCompat37()
  EndIf
Int epoch38 = PSQLoadEpoch
Int revision38 = AppearanceCacheRevision
Self.MigrateHeartEyeSelection()
Int count38 = PSQAppearance.EyeCatalogSize38(Self,AppearanceOperationId,False,epoch38,revision38)
If count38 < 0
  Return 0
ElseIf count38 > 0
  Return count38
EndIf
Return JsonUtil.StringListCount("PSQ/EyeMaterials","names")
EndFunction

String Function GetSuccubusEyeMaterialNameCompat37(Int Index)
  Self.MigrateHeartEyeSelection()
  If Index < 1 || Index > Self.GetSuccubusEyeMaterialCount()
    Return "$PSQ_EyeNoChange"
  EndIf
  If jsonutil.StringListCount("PSQ/EyeMaterials", "displaynames") >= Index
    Return jsonutil.StringListGet("PSQ/EyeMaterials", "displaynames", Index - 1)
  EndIf
  If (TransformEyeCatalogReady && TransformEyeNames as Bool) && TransformEyeNames.Length >= Index
    Return TransformEyeNames[Index - 1]
  EndIf
  Return jsonutil.StringListGet("PSQ/EyeMaterials", "names", Index - 1)
EndFunction

String Function GetSuccubusEyeMaterialName38(Int Index)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777254
    Return Self.GetSuccubusEyeMaterialNameCompat37(Index)
  EndIf
Int epoch38 = PSQLoadEpoch
Int revision38 = AppearanceCacheRevision
Int count38 = Self.GetSuccubusEyeMaterialCount()
Int localized38 = 0
If Index >= 1 && Index <= count38
  localized38 = JsonUtil.StringListCount("PSQ/EyeMaterials","displaynames")
EndIf
Int source38 = PSQAppearance.EyeLabelSource38(Self,epoch38,revision38,Index,count38,localized38)
String value38 = ""
If source38 == 1
  value38 = JsonUtil.StringListGet("PSQ/EyeMaterials","displaynames",Index - 1)
ElseIf source38 == 3
  value38 = JsonUtil.StringListGet("PSQ/EyeMaterials","names",Index - 1)
EndIf
Return PSQAppearance.EyeMaterialLabel38(Self,epoch38,revision38,Index,source38,value38)
EndFunction

Function EnsureTransformEyeCatalogCompat37(Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  If (((TransformEyeCatalogReady && TransformEyeNames as Bool) && TransformEyePlugins as Bool) && TransformEyeIds as Bool) && TransformEyeTextures as Bool
    Int CachedCount = TransformEyeNames.Length
    If CachedCount > 0 && TransformEyePlugins.Length == CachedCount && TransformEyeIds.Length == CachedCount && TransformEyeTextures.Length == CachedCount
      Return
    EndIf
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  TransformEyeCatalogReady = False
  Int Count = jsonutil.StringListCount("PSQ/EyeMaterials", "names")
  If Count < 1 || Count > 127 || jsonutil.StringListCount("PSQ/EyeMaterials", "plugins") != Count || jsonutil.IntListCount("PSQ/EyeMaterials", "ids") != Count
    Return
  EndIf
  Int Revision = AppearanceCacheRevision
  String[] names = Utility.CreateStringArray(Count, "")
  String[] plugins = Utility.CreateStringArray(Count, "")
  Int[] ids = Utility.CreateIntArray(Count, 0)
  Form[] Textures = Utility.CreateFormArray(Count, None)
  If !names || !plugins || !ids || !Textures
    Return
  EndIf
  Int i = 0
  While i < Count
    names[i] = jsonutil.StringListGet("PSQ/EyeMaterials", "names", i)
    plugins[i] = jsonutil.StringListGet("PSQ/EyeMaterials", "plugins", i)
    ids[i] = jsonutil.IntListGet("PSQ/EyeMaterials", "ids", i)
    i += 1
  EndWhile
  If Revision == AppearanceCacheRevision
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return
    EndIf
    TransformEyeNames = names
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return
    EndIf
    TransformEyePlugins = plugins
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return
    EndIf
    TransformEyeIds = ids
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return
    EndIf
    TransformEyeTextures = Textures
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return
    EndIf
    TransformEyeCatalogReady = True
  EndIf
EndFunction

Int Function EnsureTransformEyeCatalog38(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777254
    Self.EnsureTransformEyeCatalogCompat37(Owner, RequireBusy)
    Return 0
  EndIf
If Owner < 0
  Owner = AppearanceOperationId
  RequireBusy = AppearanceEditBusy
ElseIf AppearanceEditBusy
  RequireBusy = True
EndIf

Int epoch38 = PSQLoadEpoch
Int revision38 = AppearanceCacheRevision
If PSQAppearance.EyeCatalogSize38(Self,Owner,RequireBusy,epoch38,revision38) != 0
  Return 0
EndIf
Int count38 = JsonUtil.StringListCount("PSQ/EyeMaterials","names")
If count38 < 1 || count38 > 127 || JsonUtil.StringListCount("PSQ/EyeMaterials","plugins") != count38 || JsonUtil.IntListCount("PSQ/EyeMaterials","ids") != count38
  Return 0
EndIf
String[] names38 = JsonUtil.StringListToArray("PSQ/EyeMaterials","names")
String[] plugins38 = JsonUtil.StringListToArray("PSQ/EyeMaterials","plugins")
Int[] ids38 = JsonUtil.IntListToArray("PSQ/EyeMaterials","ids")
PSQAppearance.PublishEyeCatalog38(Self,Owner,RequireBusy,epoch38,revision38,names38,plugins38,ids38)
  Return 0
EndFunction

TextureSet Function GetExternalEyeTextureCompat37(Int Index, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return None
  EndIf
  Int Count = jsonutil.StringListCount("PSQ/EyeMaterials", "names")
  If Index < 1 || Index > Count
    Return None
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return None
  EndIf
  Self.EnsureTransformEyeCatalog(Owner, RequireBusy)
  Int Slot = Index - 1
  If TransformEyeTextures as Bool && TransformEyeTextures.Length > Slot
    TextureSet Cached = TransformEyeTextures[Slot] as TextureSet
    If Cached != None
      Return Cached
    EndIf
  EndIf
  String Plugin = jsonutil.StringListGet("PSQ/EyeMaterials", "plugins", Slot)
  Int LocalID = jsonutil.IntListGet("PSQ/EyeMaterials", "ids", Slot)
  If Plugin == "" || LocalID <= 0 || !Self.IsIntegrationPluginLoaded(Plugin)
    Return None
  EndIf
  Int Revision = AppearanceCacheRevision
  TextureSet Texture = Game.GetFormFromFile(LocalID, Plugin) as TextureSet
  If (Texture != None && Revision == AppearanceCacheRevision && TransformEyeTextures as Bool) && TransformEyeTextures.Length > Slot
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return None
    EndIf
    TransformEyeTextures[Slot] = Texture as Form
  EndIf
  Return Texture
EndFunction

textureSet Function GetExternalEyeTexture38(Int Index, Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777254
    Return Self.GetExternalEyeTextureCompat37(Index, Owner, RequireBusy)
  EndIf
If Owner < 0
  Owner = AppearanceOperationId
  RequireBusy = AppearanceEditBusy
ElseIf AppearanceEditBusy
  RequireBusy = True
EndIf

Int epoch38 = PSQLoadEpoch
Int revision38 = AppearanceCacheRevision
If Index < 1
  Return None
EndIf
Int size38 = PSQAppearance.EyeCatalogSize38(Self,Owner,RequireBusy,epoch38,revision38)
If size38 < 0
  Return None
ElseIf Index <= size38
  Return PSQAppearance.ResolveEyeTexture38(Self,Owner,RequireBusy,epoch38,revision38,Index,"",0)
ElseIf Index > JsonUtil.StringListCount("PSQ/EyeMaterials","names")
  Return None
EndIf
If size38 == 0
  Self.EnsureTransformEyeCatalog(Owner,RequireBusy)
  size38 = PSQAppearance.EyeCatalogSize38(Self,Owner,RequireBusy,epoch38,revision38)
EndIf
If size38 < 0
  Return None
EndIf
String plugin38 = ""
Int id38 = 0
If Index > size38
  plugin38 = JsonUtil.StringListGet("PSQ/EyeMaterials","plugins",Index - 1)
  id38 = JsonUtil.IntListGet("PSQ/EyeMaterials","ids",Index - 1)
EndIf
Return PSQAppearance.ResolveEyeTexture38(Self,Owner,RequireBusy,epoch38,revision38,Index,plugin38,id38)
EndFunction

Function MigrateHeartEyeSelectionCompat37()
  If HeartEyeCatalogVersion >= 1
    If SuccubusEyeMaterialSelection == 0
      HenshinEyes = False
    EndIf
    Return
  EndIf
  Int Previous = SuccubusEyeMaterialSelection
  SuccubusEyeMaterialSelection = 0
  Int Count = jsonutil.IntListCount("PSQ/EyeMaterials", "previous_indices")
  Int i = 0
  While i < Count
    If jsonutil.IntListGet("PSQ/EyeMaterials", "previous_indices", i) == Previous
      SuccubusEyeMaterialSelection = i + 1
      i = Count
    EndIf
    i += 1
  EndWhile
  HeartEyeCatalogVersion = 1
  If SuccubusEyeMaterialSelection == 0
    HenshinEyes = False
  EndIf
EndFunction

Int Function MigrateHeartEyeSelection38()
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777254
    Self.MigrateHeartEyeSelectionCompat37()
    Return 0
  EndIf
Int epoch38 = PSQLoadEpoch
Int[] previous38
If HeartEyeCatalogVersion < 1
  previous38 = JsonUtil.IntListToArray("PSQ/EyeMaterials","previous_indices")
EndIf
PSQAppearance.MigrateEyeSelection38(Self,epoch38,previous38)
  Return 0
EndFunction

Function ApplySelectedSuccubusEyesCompat37(Int Owner, Bool RequireBusy)
  Self.SyncPlayerAppearanceRace()
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  Self.MigrateHeartEyeSelection()
  If !IsHenshined || !HenshinEyes || psqracecompatibility.ShouldPreserveHeadAppearance(PlayerRef) || !psqracecompatibility.CanUseHeadPart(PSQSuccubusEyes, PlayerRef.GetRace())
    Return
  EndIf
  Int ExpectedSelection = SuccubusEyeMaterialSelection
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  TextureSet SelectedTexture = Self.GetExternalEyeTexture(SuccubusEyeMaterialSelection, Owner, RequireBusy)
  If SelectedTexture == None
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    HenshinEyes = False
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    Self.RefreshSuccubusEyeToggle(Owner, RequireBusy)
    Return
  EndIf
  Utility.WaitMenuMode(0.100000001)
  If IsHenshined && HenshinEyes && SuccubusEyeMaterialSelection == ExpectedSelection
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    If !PlayerRef.Is3DLoaded() || !Self.IsAppearanceOperationCurrent(Owner, RequireBusy) || !IsHenshined || !HenshinEyes || SuccubusEyeMaterialSelection != ExpectedSelection
      Return
    EndIf
    If EnableEquipmentDiagnostics
      Debug.Trace("[PSQ-EYES] texture.begin owner=" + Owner + "; selection=" + ExpectedSelection)
    EndIf
    PlayerRef.SetEyeTexture(SelectedTexture)
    If EnableEquipmentDiagnostics
      Debug.Trace("[PSQ-EYES] texture.return owner=" + Owner)
    EndIf
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    AppliedTransformEyeTexture = SelectedTexture
  EndIf
EndFunction

Function ApplySelectedSuccubusEyes38(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777254
    Self.ApplySelectedSuccubusEyesCompat37(Owner, RequireBusy)
    Return
  EndIf
Int epoch38 = PSQLoadEpoch
Self.SyncPlayerAppearanceRace()
If PSQLoadEpoch != epoch38
  Return
EndIf

If Owner < 0
  Owner = AppearanceOperationId
  RequireBusy = AppearanceEditBusy
ElseIf AppearanceEditBusy
  RequireBusy = True
EndIf

Int revision38 = AppearanceCacheRevision
If !Self.IsAppearanceOperationCurrent(Owner,RequireBusy)
  Return
EndIf
Self.MigrateHeartEyeSelection()
Int expected38 = SuccubusEyeMaterialSelection
If !PSQAppearance.EyeApplyStep38(Self,Owner,RequireBusy,epoch38,revision38,expected38,None,0) || PSQRaceCompatibility.ShouldPreserveHeadAppearance(PlayerRef)
  Return
EndIf
TextureSet selected38 = Self.GetExternalEyeTexture(expected38,Owner,RequireBusy)
If selected38 == None
  If PSQAppearance.EyeApplyStep38(Self,Owner,RequireBusy,epoch38,revision38,expected38,None,1)
    Self.RefreshSuccubusEyeToggle(Owner,RequireBusy)
  EndIf
  Return
EndIf
Utility.WaitMenuMode(0.1)
If PSQRaceCompatibility.ShouldPreserveHeadAppearance(PlayerRef) || !PlayerRef.Is3DLoaded()
  Return
EndIf
If PSQAppearance.EyeApplyStep38(Self,Owner,RequireBusy,epoch38,revision38,expected38,selected38,2)
  PlayerRef.SetEyeTexture(selected38)
  PSQAppearance.EyeApplyStep38(Self,Owner,RequireBusy,epoch38,revision38,expected38,selected38,3)
EndIf
EndFunction



Function ApplyPSQOutfitBodyModelsCompat37(Bool UsePreset, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  If PSQOutfitModelsNormalized
    Return
  EndIf
  Self.ClearBorrowedHarryTeraParts()
  Int ShinanoLoadEpoch = PSQLoadEpoch
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Bool[] EnabledSources = new Bool[9]
    Int SourceIndex = 0
    While SourceIndex < 7
      If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
        Return
      EndIf
      EnabledSources[SourceIndex] = PSQAppearance.SourceReady34(SourceIndex + 1)
      SourceIndex += 1
    EndWhile
    EnabledSources[8] = PSQAppearance.SourceReady34(100)
    If PSQAppearance.NormalizeModels34(Self, Owner, RequireBusy, ShinanoLoadEpoch, EnabledSources)
      Return
    EndIf
  EndIf
  String ShinanoRoot = "PSQ\\Outfits\\Set08\\"
  If Self.HasShinanoOutfitSource()
    ShinanoRoot = "PSQ\\ExternalOutfits\\Shinano\\"
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  String AgehaRoot = "PSQ\\Outfits\\Set08\\"
  If Self.HasExternalOutfitSource(4)
    AgehaRoot = "PSQ\\ExternalOutfits\\Ageha\\"
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  String VampireRoot = "PSQ\\Outfits\\Set08\\"
  If Self.HasExternalOutfitSource(7)
    VampireRoot = "PSQ\\ExternalOutfits\\Vampire\\"
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  String DragonPrincessRoot = "PSQ\\Outfits\\Set08\\"
  If Self.HasExternalOutfitSource(3)
    DragonPrincessRoot = "PSQ\\ExternalOutfits\\DragonPrincess\\"
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  String TERA9DMRoot = "PSQ\\Outfits\\Set08\\"
  If Self.HasExternalOutfitSource(5)
    TERA9DMRoot = "PSQ\\ExternalOutfits\\TERA9DM\\"
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  String DXRoot = "PSQ\\Outfits\\Set08\\"
  If Self.HasExternalOutfitSource(1)
    DXRoot = "PSQ\\ExternalOutfits\\DX\\"
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  String HelenaRoot = "PSQ\\Outfits\\Set08\\"
  If Self.HasExternalOutfitSource(2)
    HelenaRoot = "PSQ\\ExternalOutfits\\Helena\\"
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  UsePreset = False
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(3455, 4, "boots", AgehaRoot + "boots_1.nif", "", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(3456, 4, "cuirass", AgehaRoot + "cuirass_1.nif", AgehaRoot + "cuirass_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(3457, 4, "gloves", AgehaRoot + "gloves_1.nif", AgehaRoot + "gloves_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40834, 1, "cuirass", DXRoot + "cuirass_1.nif", DXRoot + "cuirass_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40836, 1, "boots", DXRoot + "boots_1.nif", "", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40838, 1, "gloves", DXRoot + "gloves_1.nif", DXRoot + "gloves_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40846, 2, "cuirass", HelenaRoot + "cuirass_1.nif", HelenaRoot + "cuirass_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40848, 2, "boots", HelenaRoot + "boots_1.nif", "", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40850, 2, "gloves", HelenaRoot + "gloves_1.nif", HelenaRoot + "gloves_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40858, 3, "cuirass", DragonPrincessRoot + "cuirass_1.nif", DragonPrincessRoot + "cuirass_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40860, 3, "boots", DragonPrincessRoot + "boots_1.nif", "", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40862, 3, "gloves", DragonPrincessRoot + "gloves_1.nif", DragonPrincessRoot + "gloves_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40870, 4, "cuirass", AgehaRoot + "cuirass_1.nif", AgehaRoot + "cuirass_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40872, 4, "boots", AgehaRoot + "boots_1.nif", "", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40874, 4, "gloves", AgehaRoot + "gloves_1.nif", AgehaRoot + "gloves_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40882, 5, "cuirass", TERA9DMRoot + "cuirass_1.nif", TERA9DMRoot + "cuirass_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40884, 5, "boots", TERA9DMRoot + "boots_1.nif", "", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40886, 5, "gloves", TERA9DMRoot + "gloves_1.nif", TERA9DMRoot + "gloves_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40894, 6, "cuirass", ShinanoRoot + "cuirass_1.nif", ShinanoRoot + "cuirass_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40896, 6, "boots", ShinanoRoot + "boots_1.nif", "", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40898, 6, "gloves", ShinanoRoot + "gloves_1.nif", ShinanoRoot + "gloves_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40906, 7, "cuirass", VampireRoot + "cuirass_1.nif", VampireRoot + "cuirass_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40908, 7, "boots", VampireRoot + "boots_1.nif", "", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40910, 7, "gloves", VampireRoot + "gloves_1.nif", VampireRoot + "gloves_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40918, 8, "cuirass", "PSQ\\Outfits\\Set08\\cuirass_1.nif", "PSQ\\Outfits\\Set08\\cuirass_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40920, 8, "boots", "PSQ\\Outfits\\Set08\\boots_1.nif", "", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40922, 8, "gloves", "PSQ\\Outfits\\Set08\\gloves_1.nif", "PSQ\\Outfits\\Set08\\gloves_1.nif", UsePreset, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40900, 6, "horns", ShinanoRoot + "horns_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40902, 6, "tail", ShinanoRoot + "tail_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40904, 6, "wings", ShinanoRoot + "wings_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40840, 1, "horns", DXRoot + "horns_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40842, 1, "tail", DXRoot + "tail_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40844, 1, "wings", DXRoot + "wings_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40852, 2, "horns", HelenaRoot + "horns_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40856, 2, "wings", HelenaRoot + "wings_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40876, 4, "horns", AgehaRoot + "horns_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40878, 4, "tail", AgehaRoot + "tail_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40880, 4, "wings", AgehaRoot + "wings_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40912, 7, "horns", VampireRoot + "horns_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40914, 7, "tail", VampireRoot + "tail_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40916, 7, "wings", VampireRoot + "wings_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Bool HarryReady = Self.HasExternalOutfitSource(100)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  String HarryPath0 = "PSQ\\Outfits\\Set08\\cuirass_1.nif"
  If HarryReady
    HarryPath0 = "PSQ\\ExternalOutfits\\TERAHarry\\Corset_1.nif"
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(45072, 100, "cuirass", HarryPath0, HarryPath0, False, Owner, RequireBusy)
  String HarryPath1 = ""
  If HarryReady
    HarryPath1 = "PSQ\\ExternalOutfits\\TERAHarry\\Collar_1.nif"
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(45073, 100, "cuirass", HarryPath1, HarryPath1, False, Owner, RequireBusy)
  String HarryPath2 = ""
  If HarryReady
    HarryPath2 = "PSQ\\ExternalOutfits\\TERAHarry\\Garter_1.nif"
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(45074, 100, "cuirass", HarryPath2, HarryPath2, False, Owner, RequireBusy)
  String HarryPath3 = ""
  If HarryReady
    HarryPath3 = "PSQ\\ExternalOutfits\\TERAHarry\\Panty_1.nif"
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(45075, 100, "cuirass", HarryPath3, HarryPath3, False, Owner, RequireBusy)
  String HarryPath4 = "PSQ\\Outfits\\Set08\\boots_1.nif"
  If HarryReady
    HarryPath4 = "PSQ\\ExternalOutfits\\TERAHarry\\Boots_1.nif"
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(45076, 100, "boots", HarryPath4, HarryPath4, False, Owner, RequireBusy)
  String HarryPath5 = ""
  If HarryReady
    HarryPath5 = "PSQ\\ExternalOutfits\\TERAHarry\\Stockings_1.nif"
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(45077, 100, "boots", HarryPath5, HarryPath5, False, Owner, RequireBusy)
  String HarryPath6 = "PSQ\\Outfits\\Set08\\gloves_1.nif"
  If HarryReady
    HarryPath6 = "PSQ\\ExternalOutfits\\TERAHarry\\Gauntlets_1.nif"
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(45078, 100, "gloves", HarryPath6, HarryPath6, False, Owner, RequireBusy)
  String HarryPath7 = "PSQ\\Outfits\\Set08\\tail_1.nif"
  If HarryReady
    HarryPath7 = "PSQ\\ExternalOutfits\\TERAHarry\\Tail_1.nif"
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(45079, 100, "tail", HarryPath7, HarryPath7, False, Owner, RequireBusy)
  String HarryPath8 = ""
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(45080, 100, "horns", HarryPath8, HarryPath8, False, Owner, RequireBusy)
  String HarryPath9 = ""
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(45081, 100, "wings", HarryPath9, HarryPath9, False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40864, 3, "horns", DragonPrincessRoot + "horns_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40866, 3, "tail", DragonPrincessRoot + "tail_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40868, 3, "wings", DragonPrincessRoot + "wings_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40888, 5, "horns", TERA9DMRoot + "horns_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40890, 5, "tail", TERA9DMRoot + "tail_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Self.SetPSQOutfitBodyModel(40892, 5, "wings", TERA9DMRoot + "wings_1.nif", "", False, Owner, RequireBusy)
  If ShinanoLoadEpoch != PSQLoadEpoch || Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  PSQOutfitModelsNormalized = True
EndFunction

Function ApplyPSQOutfitBodyModels38(Bool UsePreset, Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777254
    Self.ApplyPSQOutfitBodyModelsCompat37(UsePreset, Owner, RequireBusy)
    Return
  EndIf
  If !PSQAppearance.NormalizeOutfitSources38(Self, Owner, RequireBusy)
    Self.ApplyPSQOutfitBodyModelsCompat37(UsePreset, Owner, RequireBusy)
  EndIf
EndFunction

String Function GetExternalOutfitSourceStatusCompat37(Int Outfit)
  String Plugin = "DX Succubus Armor.esp"
  If Outfit == 2
    Plugin = "Helena Succubus [SE].esp"
  ElseIf Outfit == 3
    Plugin = "BBP_Dragon_Princess.esp"
  ElseIf Outfit == 5
    Plugin = "TR9DmRxSS_HR.esp"
  ElseIf Outfit == 4
    Plugin = "C5Kev's Ageha Abyss Armor.esp"
  ElseIf Outfit == 7
    Plugin = "(SSE) SW vampire.esp"
  ElseIf Outfit == 100
    Plugin = "TeraSuccubusArmor.esp"
  ElseIf Outfit == 6
    Return Self.GetShinanoOutfitSourceStatus()
  ElseIf Outfit != 1
    Return "不属于原作接入套装"
  EndIf
  If !Self.IsIntegrationPluginLoaded(Plugin)
    Return "原作未启用：对应套装不可选"
  EndIf
  If !Self.HasExternalOutfitSource(Outfit)
    Return "原作或适配资源不完整：对应套装不可选"
  EndIf
  Return "已接入原作：六部件独立替换"
EndFunction

String Function GetExternalOutfitSourceStatus38(Int Outfit)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777254
    Return Self.GetExternalOutfitSourceStatusCompat37(Outfit)
  EndIf
  Return PSQAppearance.OutfitSourceStatus38(Outfit)
EndFunction

Bool Function CanUseTransformOutfitChoiceCompat37(Int Part, Int Choice)
  If Choice == 0
    Return True
  EndIf
  If Part < 0 || Part > 5
    Return False
  EndIf
  Bool UBE = psqracecompatibility.IsUBEActor(PlayerRef)
  If UBE
    Armor Item = PSQDXUBE.GetOutfitPart(PlayerRef, Choice, Part)
    If Item == None || Item.GetNumArmorAddons() < 1
      Return False
    EndIf
    ArmorAddon Addon = Item.GetNthArmorAddon(0)
    If Addon == None
      Return False
    EndIf
    String Model = Addon.GetModelPath(False, True)
    Return Model != "" && miscutil.FileExists("Data/meshes/" + Model)
  EndIf
  If Choice >= 1 && Choice <= 7 || Choice == 100
    If !Self.HasExternalOutfitSource(Choice)
      Return False
    EndIf
  ElseIf Choice == 8
    If !miscutil.FileExists("Data/meshes/PSQ/Outfits/Set08/cuirass_1.nif")
      Return False
    EndIf
  ElseIf Part != 3
    Return False
  EndIf
  Return Self.GetCachedOutfitPart(Choice, Part, -1, False) != None
EndFunction

Bool Function CanUseTransformOutfitChoice38(Int Part, Int Choice)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777254
    Return Self.CanUseTransformOutfitChoiceCompat37(Part, Choice)
  EndIf
  Int State38 = PSQAppearance.OutfitChoiceState38(Self, Part, Choice)
  If State38 == 0
    Return Self.CanUseTransformOutfitChoiceCompat37(Part, Choice)
  ElseIf State38 == 3
    Return Self.GetCachedOutfitPart(Choice, Part, -1, False) != None
  EndIf
  Return State38 == 2
EndFunction

Function SyncSatiationSkillPerksCompat37(Int Tier)
  If PlayerRef == None
    Return
  EndIf
  Perk Hungry = Game.GetFormFromFile(45082, "PSQ PlayerSuccubusQuest.esm") as Perk
  Perk Full = Game.GetFormFromFile(45083, "PSQ PlayerSuccubusQuest.esm") as Perk
  If Hungry == None || Full == None
    Return
  EndIf
  If Tier != 0 && PlayerRef.HasPerk(Hungry)
    PlayerRef.RemovePerk(Hungry)
  EndIf
  If Tier != 2 && PlayerRef.HasPerk(Full)
    PlayerRef.RemovePerk(Full)
  EndIf
  If Tier == 1 || PlayerIsSuccubus.GetValueInt() != 1 || Self.GetSatiationEffectMode() == 0 || UninstallPrepared || UninstallCleanupBusy || StorageUtil.GetIntValue(PlayerRef, "PSQ_SatiationXPTier", -1) != Tier
    Return
  EndIf
  If Tier == 0 && !PlayerRef.HasPerk(Hungry)
    PlayerRef.AddPerk(Hungry)
  ElseIf Tier == 2 && !PlayerRef.HasPerk(Full)
    PlayerRef.AddPerk(Full)
  EndIf
EndFunction

Function SyncSatiationSkillPerks38(Int Tier)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777254
    Self.SyncSatiationSkillPerksCompat37(Tier)
    Return
  EndIf
  Int Epoch38 = PSQLoadEpoch
  Actor Subject38 = PlayerRef
  Int Ticket38 = PSQAppearance.BeginSatietySync38(Tier)
  Int Stored38 = -1
  If (Tier == 0 || Tier == 2) && Subject38
    Stored38 = StorageUtil.GetIntValue(Subject38, "PSQ_SatiationXPTier", -1)
  EndIf
  If !PSQAppearance.SyncSatietyPerks38(Self, Subject38, Tier, Stored38, Epoch38, Ticket38)
    Self.SyncSatiationSkillPerksCompat37(Tier)
  EndIf
EndFunction



headpart Function GetTransformHairChoiceCompat37(Int Choice, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return None
  EndIf
  If Choice < 1 || Choice > 4
    Return None
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    Return PSQAppearance.ResolveHairChoice(Choice)
  EndIf
  If !TransformHairCache
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return None
    EndIf
    TransformHairCache = new HeadPart[4]
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return None
    EndIf
    TransformHairResolved = new Bool[4]
  EndIf
  Int Index = Choice - 1
  If TransformHairResolved[Index]
    Return TransformHairCache[Index]
  EndIf
  Int Revision = AppearanceCacheRevision
  If !Self.IsIntegrationPluginLoaded("[Dint999] BDOr_Hairstyles.esp")
    If Revision == AppearanceCacheRevision
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return None
      EndIf
      TransformHairResolved[Index] = True
    EndIf
    Return None
  EndIf
  Int ID = 27426
  If Choice == 2
    ID = 48663
  ElseIf Choice == 3
    ID = 31678
  ElseIf Choice == 4
    ID = 40047
  EndIf
  headpart Hair = Game.GetFormFromFile(ID, "[Dint999] BDOr_Hairstyles.esp") as headpart
  If Hair != None && Hair.GetType() != 3
    Hair = None
  EndIf
  If Revision == AppearanceCacheRevision
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return None
    EndIf
    TransformHairCache[Index] = Hair
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return None
    EndIf
    TransformHairResolved[Index] = True
    Return Hair
  EndIf
  Return None
EndFunction

headPart Function GetTransformHairChoice38(Int Choice, Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777254
    Return Self.GetTransformHairChoiceCompat37(Choice, Owner, RequireBusy)
  EndIf
Return PSQAppearance.HairChoice38(Self, Choice, Owner, RequireBusy)
EndFunction

Function EnsureOptionalHornCatalogCompat37()
  If OptionalHornCatalogReady
    Return
  EndIf
  Int Revision = AppearanceCacheRevision
  String[] names = new String[119]
  String[] Keys = new String[119]
  Armor[] items = new Armor[119]
  Int Count = 0
  String Folder = "PSQ/HornOptions/"
  String[] Files = jsonutil.JsonInFolder(Folder)
  If Files
    PapyrusUtil.SortStringArray(Files, False)
    Int FileIndex = 0
    While FileIndex < Files.Length && FileIndex < 119 && Count < 119
      String File = Files[FileIndex]
      If stringutil.Find(File, Folder, 0) != 0
        File = Folder + File
      EndIf
      If jsonutil.GetIntValue(File, "schema", 0) == 1
        Int Rows = jsonutil.StringListCount(File, "names")
        If Rows > 0 && Rows == jsonutil.StringListCount(File, "plugins") && Rows == jsonutil.IntListCount(File, "forms")
          Int Row = 0
          While Row < Rows && Row < 119 && Count < 119
            String Plugin = jsonutil.StringListGet(File, "plugins", Row)
            Int FormID = jsonutil.IntListGet(File, "forms", Row)
            String Name = jsonutil.StringListGet(File, "names", Row)
            If Plugin != "" && Name != "" && FormID > 0 && FormID <= 16777215 && Game.IsPluginInstalled(Plugin)
              Armor Item = Game.GetFormFromFile(FormID, Plugin) as Armor
              String Identity = Plugin + "|" + FormID as String
              If Item != None && Keys.find(Identity, 0) < 0
                Keys[Count] = Identity
                names[Count] = Name
                items[Count] = Item
                Count += 1
              EndIf
            EndIf
            Row += 1
          EndWhile
        EndIf
      EndIf
      FileIndex += 1
    EndWhile
  EndIf
  If Revision != AppearanceCacheRevision
    Return
  EndIf
  OptionalHornNames = names
  OptionalHornKeys = Keys
  OptionalHornArmors = items
  OptionalHornCount = Count
  OptionalHornCatalogReady = True
EndFunction

Function EnsureOptionalHornCatalog38()
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777254
    Self.EnsureOptionalHornCatalogCompat37()
    Return
  EndIf
If OptionalHornCatalogReady
  Return
EndIf
Int revision38 = AppearanceCacheRevision
Int epoch38 = PSQLoadEpoch
String[] files38 = JsonUtil.JsonInFolder("PSQ/HornOptions/")
If files38
  PapyrusUtil.SortStringArray(files38, False)
EndIf
String[] names38 = new String[119]
String[] keys38 = new String[119]
Int used38 = 0
Int fileIndex38 = 0
String file38 = PSQAppearance.HornFile38(Self,revision38,epoch38,files38,fileIndex38,used38)
While file38 != ""
  If JsonUtil.GetIntValue(file38,"schema",0) == 1
    Int rows38 = PSQAppearance.HornRows38(JsonUtil.StringListCount(file38,"names"), JsonUtil.StringListCount(file38,"plugins"), JsonUtil.IntListCount(file38,"forms"))
    If rows38 > 0
      String[] labels38 = new String[119]
      String[] plugins38 = new String[119]
      Int[] forms38 = new Int[119]
      JsonUtil.StringListSlice(file38,"names",labels38,0)
      JsonUtil.StringListSlice(file38,"plugins",plugins38,0)
      JsonUtil.IntListSlice(file38,"forms",forms38,0)
      used38 = PSQAppearance.CollectHorns38(rows38,labels38,plugins38,forms38,used38,names38,keys38)
    EndIf
  EndIf
  fileIndex38 += 1
  file38 = PSQAppearance.HornFile38(Self,revision38,epoch38,files38,fileIndex38,used38)
EndWhile
PSQAppearance.CommitHorns38(Self,revision38,epoch38,used38,names38,keys38)
EndFunction

String Function GetIndependentTransformPartNameCompat37(Int Part, Int Choice)
  If Choice == 100
    Return "$PSQ_OutfitHarryTERA"
  EndIf
  If Part == 3 && Choice > 8
    Self.EnsureOptionalHornCatalog()
    Int Index = Choice - 9
    If OptionalHornCatalogReady && Index >= 0 && Index < OptionalHornCount
      Return OptionalHornNames[Index]
    EndIf
    Return "$PSQ_OutfitUnavailable"
  EndIf
  Return Self.GetSuccubusOutfitName(Choice)
EndFunction

String Function GetIndependentTransformPartName38(Int Part, Int Choice)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777254
    Return Self.GetIndependentTransformPartNameCompat37(Part, Choice)
  EndIf
If Part == 3 && Choice > 8 && Choice != 100
  Self.EnsureOptionalHornCatalog()
EndIf
Return PSQAppearance.PartName38(Self,Part,Choice)
EndFunction



Armor Function GetTransformPartArmorCompat38(Int Part)
  Armor Item = None
  If Part == 0
    Item = PSQSuccubusCuirass
  ElseIf Part == 1
    Item = PSQSuccubusBoots
  ElseIf Part == 2
    Item = PSQSuccubusGauntlets
  ElseIf Part == 3
    Item = PSQSuccubusHorns
  ElseIf Part == 4
    Item = PSQSuccubusTail
  ElseIf Part == 5
    Item = PSQSuccubusWings
  EndIf
  Return Self.ResolveTransformEquipmentItem(Item, Part)
EndFunction

armor Function GetTransformPartArmor39(Int Part)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777255
    Return Self.GetTransformPartArmorCompat38(Part)
  EndIf
  Form found = PSQAppearance.ResolvePart39(Self, None, Part, True)
  If found == Self
    Return Self.GetTransformPartArmorCompat38(Part)
  EndIf
  Return found as Armor
EndFunction

Armor Function ResolveTransformEquipmentItemCompat38(Armor Item, Int Part)
  If Item == None
    ; Re-resolve a saved DX selection if the old optional plugin's form has disappeared.
    If Part >= 0 && Part <= 4 && TransformPartSources && TransformPartSources.Length == 5 && TransformPartSources[Part] == 1 && Self.IsTransformPartSelected(Part) && PSQRaceCompatibility.IsUBEActor(PlayerRef)
      Return PSQDXUBE.GetRawPart(Part)
    EndIf
    Return None
  EndIf
  If (Part == 5 || Part < 0) && Self.IsBodyIndependentTransformWing(Item)
    Return Item
  EndIf
  If Part < 0
    If psqracecompatibility.IsUBEActor(PlayerRef)
      Return None
    EndIf
    Return Item
  EndIf
  Return PSQDXUBE.ResolvePart(PlayerRef, Item, Part)
EndFunction

armor Function ResolveTransformEquipmentItem39(armor Item, Int Part)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777255
    Return Self.ResolveTransformEquipmentItemCompat38(Item, Part)
  EndIf
  Form found = PSQAppearance.ResolvePart39(Self, Item, Part, False)
  If found == Self
    Return Self.ResolveTransformEquipmentItemCompat38(Item, Part)
  EndIf
  Return found as Armor
EndFunction

Armor Function GetCachedOutfitPartCompat38(Int Selection, Int Part, Int Owner, Bool RequireBusy)
  If Selection == 2 && Part == 4
    Return None
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return None
  EndIf
  If psqracecompatibility.IsUBEActor(PlayerRef)
    If Selection == 0
      Selection = 4
    EndIf
    Return PSQDXUBE.GetOutfitPart(PlayerRef, Selection, Part)
  EndIf
  If Selection == 100
    If Part == 3 || Part == 5
      Return None
    EndIf
    If Part < 0 || Part > 5
      Return None
    EndIf
    Return Game.GetFormFromFile(45056 + Part, "PSQ PlayerSuccubusQuest.esm") as Armor
  EndIf
  If Selection == 0
    Selection = 4
  EndIf
  If Part == 3 && Selection > 8
    Self.EnsureOptionalHornCatalog()
    Int External = Selection - 9
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return None
    EndIf
    If OptionalHornCatalogReady && External >= 0 && External < OptionalHornCount
      Return OptionalHornArmors[External]
    EndIf
    Return None
  EndIf
  If Selection < 1 || Selection > 8 || Part < 0 || Part > 5
    Return None
  EndIf
  If !TransformOutfitCache
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return None
    EndIf
    TransformOutfitCache = new Armor[48]
  EndIf
  Int Index = (Selection - 1) * 6 + Part
  Armor Item = TransformOutfitCache[Index]
  If Item == None
    Int Revision = AppearanceCacheRevision
    Item = Game.GetFormFromFile(40835 + (Selection - 1) * 12 + Part * 2, "PSQ PlayerSuccubusQuest.esm") as Armor
    If Revision == AppearanceCacheRevision
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return None
      EndIf
      TransformOutfitCache[Index] = Item
    EndIf
  EndIf
  Return Item
EndFunction

armor Function GetCachedOutfitPart39(Int Selection, Int Part, Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777255
    Return Self.GetCachedOutfitPartCompat38(Selection, Part, Owner, RequireBusy)
  EndIf
  Form found = PSQAppearance.CachedPart39(Self, Selection, Part, Owner, RequireBusy)
  If found == Self
    Return Self.GetCachedOutfitPartCompat38(Selection, Part, Owner, RequireBusy)
  EndIf
  Return found as Armor
EndFunction

Function ClearAppliedTransformBodyCompat38(Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  AppliedTransformBodyValid = False
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  AppliedTransformBodyName = ""
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  AppliedTransformBodyWeight = -1.0
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  AppliedTransformBodyRevision = -1
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  AppliedTransformBodySliders = EmptyStringArray
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  AppliedTransformBodyLow = EmptyFloatArray
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  AppliedTransformBodyHigh = EmptyFloatArray
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  AppliedTransformBodyBaseLow = EmptyFloatArray
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  AppliedTransformBodyBaseHigh = EmptyFloatArray
EndFunction

Int Function ClearAppliedTransformBody39(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777255
    Self.ClearAppliedTransformBodyCompat38(Owner, RequireBusy)
    Return 0
  EndIf
  If !PSQAppearance.ClearBodyReceipt39(Self, Owner, RequireBusy)
    Self.ClearAppliedTransformBodyCompat38(Owner, RequireBusy)
  EndIf
  Return 0
EndFunction

Bool Function TransformBodyMatchesAppliedCompat38(Float Weight, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  If !AppliedTransformBodyValid || AppliedTransformBodyName != TransformPresetName || AppliedTransformBodyWeight != Weight
    Return False
  EndIf
  If AppliedTransformBodyRevision == AppearanceCacheRevision
    Return True
  EndIf
  Int Count = TransformBodySliders.Length
  If Count == 0 || AppliedTransformBodySliders.Length != Count || AppliedTransformBodyLow.Length != Count || AppliedTransformBodyHigh.Length != Count || AppliedTransformBodyBaseLow.Length != Count || AppliedTransformBodyBaseHigh.Length != Count
    Return False
  EndIf
  Int Index = 0
  While Index < Count
    If AppliedTransformBodySliders[Index] != TransformBodySliders[Index] || AppliedTransformBodyLow[Index] != TransformBodyLow[Index] || AppliedTransformBodyHigh[Index] != TransformBodyHigh[Index] || AppliedTransformBodyBaseLow[Index] != TransformBodyBaseLow[Index] || AppliedTransformBodyBaseHigh[Index] != TransformBodyBaseHigh[Index]
      Return False
    EndIf
    Index += 1
  EndWhile
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  AppliedTransformBodyRevision = AppearanceCacheRevision
  Return True
EndFunction

Bool Function TransformBodyMatchesApplied39(Float Weight, Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777255
    Return Self.TransformBodyMatchesAppliedCompat38(Weight, Owner, RequireBusy)
  EndIf
  Return PSQAppearance.BodyMatches39(Self, Weight, Owner, RequireBusy)
EndFunction

Float Function RefreshSatietyXPProvider40(Actor subject40, Int epoch40, Int id40)
  Int saved40 = StorageUtil.GetIntValue(subject40, "PSQ_SatiationXPTier", -1)
  Float now40 = Utility.GetCurrentRealTime()
  Float last40 = StorageUtil.GetFloatValue(subject40, "PSQ_SatiationXPCheck", -10.0)
  Int[] plan40 = PSQAppearance.PlanSatietyXP40(Self, subject40, epoch40, id40, saved40, now40, last40)
  If !plan40 || plan40.Length != 2
    Return 1.0
  EndIf
  Int tier40 = plan40[0]
  If plan40[1] && PSQAppearance.OwnsSatietyXP40(Self, subject40, epoch40, id40)
    Int written40 = StorageUtil.SetIntValue(subject40, "PSQ_SatiationXPTier", tier40)
    Int persisted40 = StorageUtil.GetIntValue(subject40, "PSQ_SatiationXPTier", -1)
    If PSQAppearance.ApplySatietyXP40(Self, subject40, epoch40, id40, written40, persisted40)
      StorageUtil.SetFloatValue(subject40, "PSQ_SatiationXPCheck", now40)
    EndIf
  EndIf
  Return PSQAppearance.SatietyXPResult40(Self, subject40, epoch40, id40, tier40)
EndFunction

Float Function GetSatiationExperienceMultiplierCompat39()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If !PSQAppearance.XPEnabled34(Self)
      Return 1.0
    EndIf
    Int CachedTier = StorageUtil.GetIntValue(PlayerRef, "PSQ_SatiationXPTier", -1)
    Float CurrentTime = Utility.GetCurrentRealTime()
    Int NewTier = PSQAppearance.RefreshXPTier34(Self, CachedTier, CurrentTime, StorageUtil.GetFloatValue(PlayerRef, "PSQ_SatiationXPCheck", -10.0))
    If NewTier >= 0
      StorageUtil.SetIntValue(PlayerRef, "PSQ_SatiationXPTier", NewTier)
      StorageUtil.SetFloatValue(PlayerRef, "PSQ_SatiationXPCheck", CurrentTime)
      Self.SyncSatiationSkillPerks(NewTier)
      CachedTier = NewTier
    EndIf
    Return PSQAppearance.XPMultiplier34(CachedTier)
  EndIf
  If PlayerRef == None || PlayerIsSuccubus.GetValueInt() != 1 || UninstallPrepared || UninstallCleanupBusy || Self.GetSatiationEffectMode() == 0
    Return 1.0
  EndIf
  Int Tier = StorageUtil.GetIntValue(PlayerRef, "PSQ_SatiationXPTier", -1)
  Float Now = Utility.GetCurrentRealTime()
  Float Last = StorageUtil.GetFloatValue(PlayerRef, "PSQ_SatiationXPCheck", -10.0)
  If Tier < 0 || Tier > 2 || Now < Last || Now - Last >= 10.0
    Float Ratio = Self.GetEnergyRatio()
    If SKSE.GetPluginVersion("PSQ Appearance") >= 16777229
      Tier = PSQAppearance.SatiationTier(Tier, Ratio)
    ElseIf Tier == 0 && Ratio < 0.35
      Tier = 0
    ElseIf Tier == 2 && Ratio >= 0.75
      Tier = 2
    ElseIf Ratio < 0.30
      Tier = 0
    ElseIf Ratio >= 0.80
      Tier = 2
    Else
      Tier = 1
    EndIf
    StorageUtil.SetIntValue(PlayerRef, "PSQ_SatiationXPTier", Tier)
    StorageUtil.SetFloatValue(PlayerRef, "PSQ_SatiationXPCheck", Now)
    Self.SyncSatiationSkillPerks(Tier)
  EndIf
  If Tier == 0
    Return 1.10
  ElseIf Tier == 2
    Return 0.90
  EndIf
  Return 1.0
EndFunction

Float Function GetSatiationExperienceMultiplier40()
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777256
    Return Self.GetSatiationExperienceMultiplierCompat39()
  EndIf
  Actor subject40 = PlayerRef
  Int epoch40 = PSQLoadEpoch
  Int id40 = PSQAppearance.BeginSatietyXP40(Self, subject40, epoch40)
  If id40 == 0
    Return 1.0
  EndIf
  Return Self.RefreshSatietyXPProvider40(subject40, epoch40, id40)
EndFunction

Function SetSatiationEffectModeCompat39(Int Mode)
  If Mode < 0 || Mode > 2
    Return
  EndIf
  Int AppliedMode = -1
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    AppliedMode = PSQAppearance.ChangeGameplayMode(Self, 0, Mode)
  EndIf
  If AppliedMode < 0
    If Mode == 2
      Mode = 1
    EndIf
    SatiationEffectMode = Mode
    EnableSatiationEffect = Mode != 0
  Else
    Mode = AppliedMode
  EndIf
  StorageUtil.UnsetIntValue(PlayerRef, "PSQ_SatiationXPTier")
  StorageUtil.UnsetFloatValue(PlayerRef, "PSQ_SatiationXPCheck")
  If Mode == 0
    Self.SyncSatiationSkillPerks(1)
  EndIf
  SatiationLastAttributeRefresh = -10.0
  Self.Satiety(0.0)
EndFunction

Function SetSatiationEffectMode40(Int Mode)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777256
    Self.SetSatiationEffectModeCompat39(Mode)
    Return
  EndIf
  Int epoch40 = PSQLoadEpoch
  Actor subject40 = PlayerRef
  Int request40 = PSQAppearance.SetSatietyMode40(Self, subject40, epoch40, Mode)
  If !request40
    Return
  EndIf
  If subject40 && PSQAppearance.StepSatietyMode40(Self, subject40, epoch40, request40, False)
    StorageUtil.UnsetIntValue(subject40, "PSQ_SatiationXPTier")
    If PSQAppearance.StepSatietyMode40(Self, subject40, epoch40, request40, False)
      StorageUtil.UnsetFloatValue(subject40, "PSQ_SatiationXPCheck")
    EndIf
  EndIf
  If PSQAppearance.StepSatietyMode40(Self, subject40, epoch40, request40, True)
    Self.Satiety(0.0)
  EndIf
EndFunction



Bool Function ApplySuccubusOutfitSelectionCoreCompat39(Int Selection, Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  If IsHenshined && Self.GTSoftbodyOwnsAppearance()
    Debug.Notification("$PSQ_GTAppearanceBusy")
    Return False
  EndIf
  If Selection == 0
    Selection = 4
  EndIf
  If IsHenshinchu || Selection < 0 || Selection > 8
    Return False
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  Armor Next0 = Self.GetCachedOutfitPart(Self.GetTransformPartSource(0), 0, Owner, RequireBusy)
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  Armor Next1 = Self.GetCachedOutfitPart(Self.GetTransformPartSource(1), 1, Owner, RequireBusy)
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  Armor Next2 = Self.GetCachedOutfitPart(Self.GetTransformPartSource(2), 2, Owner, RequireBusy)
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  Armor Next3 = Self.GetCachedOutfitPart(Self.GetTransformPartSource(3), 3, Owner, RequireBusy)
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  Armor Next4 = Self.GetCachedOutfitPart(Self.GetTransformPartSource(4), 4, Owner, RequireBusy)
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  Armor Next5 = Self.GetCachedOutfitPart(Selection, 5, Owner, RequireBusy)
  If Next0 == None || Next1 == None || Next2 == None || Next3 == None || Self.MissingRequiredTail42(Next4) || Next5 == None
    Return False
  EndIf
  If AWUWingID > 0
    Next5 = None
  ElseIf PSQSuccubusWings != None
    Next5 = PSQSuccubusWings
  EndIf
  If Selection == SuccubusOutfitSelection && PSQSuccubusCuirass == Next0 && PSQSuccubusBoots == Next1 && PSQSuccubusGauntlets == Next2 && PSQSuccubusHorns == Next3 && PSQSuccubusTail == Next4 && PSQSuccubusWings == Next5
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return False
    EndIf
    Self.ApplyPSQOutfitBodyModels(False, Owner, RequireBusy)
    Return True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  Self.ClearAppliedTransformBody(Owner, RequireBusy)
  Armor Old0 = PSQSuccubusCuirass
  Armor Old1 = PSQSuccubusBoots
  Armor Old2 = PSQSuccubusGauntlets
  Armor Old3 = PSQSuccubusHorns
  Armor Old4 = PSQSuccubusTail
  Armor Old5 = PSQSuccubusWings
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  PSQSuccubusCuirass = Next0
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  PSQSuccubusBoots = Next1
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  PSQSuccubusGauntlets = Next2
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  PSQSuccubusHorns = Next3
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  PSQSuccubusTail = Next4
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  PSQSuccubusWings = Next5
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  SuccubusOutfitSelection = Selection
  If IsHenshined
    If HenshinCuirass && Old0 != Next0
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      Self.RemoveTransformEquipmentItem(Old0, Owner, RequireBusy)
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      Self.EnsurePlayerTransformEquipment(Next0, Owner, RequireBusy)
    EndIf
    If HenshinBoots && Old1 != Next1
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      Self.RemoveTransformEquipmentItem(Old1, Owner, RequireBusy)
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      Self.EnsurePlayerTransformEquipment(Next1, Owner, RequireBusy)
    EndIf
    If HenshinGloves && Old2 != Next2
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      Self.RemoveTransformEquipmentItem(Old2, Owner, RequireBusy)
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      Self.EnsurePlayerTransformEquipment(Next2, Owner, RequireBusy)
    EndIf
    If HenshinHorn && Old3 != Next3
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      Self.RemoveTransformEquipmentItem(Old3, Owner, RequireBusy)
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      Self.EnsurePlayerTransformEquipment(Next3, Owner, RequireBusy)
    EndIf
    If HenshinTail && Old4 != Next4
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      Self.RemoveTransformEquipmentItem(Old4, Owner, RequireBusy)
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      Self.EnsurePlayerTransformEquipment(Next4, Owner, RequireBusy)
    EndIf
    If HenshinWings && Old5 != Next5
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      Self.RemoveTransformEquipmentItem(Old5, Owner, RequireBusy)
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return False
      EndIf
      Self.EnsurePlayerTransformEquipment(Next5, Owner, RequireBusy)
    EndIf
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  Self.ApplyPSQOutfitBodyModels(IsHenshined && HenshinBody, Owner, RequireBusy)
  If IsHenshined
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return False
    EndIf
    PlayerRef.QueueNiNodeUpdate()
    If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
      Return False
    EndIf
    Self.ApplySelectedSuccubusEyes(Owner, RequireBusy)
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return False
  EndIf
  OutfitSwitchBusy = False
  Return True
EndFunction

Bool Function ApplySuccubusOutfitSelectionCore40(Int Selection, Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777256
    Return Self.ApplySuccubusOutfitSelectionCoreCompat39(Selection, Owner, RequireBusy)
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  Int epoch = PSQLoadEpoch
  Int job = PSQAppearance.StartWardrobe40(PlayerRef, Self, Owner, epoch, RequireBusy, 6, Selection)
  Return Self.WaitAppearanceReceipt27(job, Owner, epoch) == 1
EndFunction

Bool Function ChangeOutfitPartFromMenuCompat39(Int Part, Int Choice)
  Int HornCount = 0
  If Part == 3 && Choice > 8 && Choice != 100
    HornCount = Self.GetOptionalHornCount()
  EndIf
  If !PSQAppearance.OutfitSelectionAllowed(Part, Choice, HornCount, True)
    Return False
  EndIf
  If Choice > 0 && !Self.CanUseTransformOutfitChoice(Part, Choice)
    Return False
  EndIf
  Int[] Ticket = Self.AcquireAppearanceEditTicket()
  If !Ticket || Ticket.Length != 2 || Ticket[0] <= 0
    Return False
  EndIf
  Int Owner = Ticket[0]
  Int Epoch = Ticket[1]
  Self.EnsureTransformPartSources()
  Armor Previous = Self.GetTransformPartArmor(Part)
  Bool WasEnabled = Self.IsTransformPartSelected(Part) && Self.CanUseResolvedTransformPart(Part, Previous)
  Armor Next = Previous
  If Choice > 0
    Next = Self.GetCachedOutfitPart(Choice, Part, Owner, True)
  EndIf
  Int Source = Self.GetTransformPartSource(Part)
  Bool SoftBody = IsHenshined && Self.GTSoftbodyOwnsAppearance()
  Int Actions = PSQAppearance.SetOutfitSelection(PlayerRef, Self, PlayerAppearanceRace, Owner, Epoch, Part, Choice, Previous, Next, WasEnabled, Source, SoftBody)
  If Actions > 0 && Math.LogicalAnd(Actions,2)
    Self.ApplyPSQOutfitBodyModels(HenshinBody, Owner, True)
    If Math.LogicalAnd(Actions,4)
      Self.RemoveTransformEquipmentItem(Previous, Owner, True)
    EndIf
    If Math.LogicalAnd(Actions,8)
      Self.EnsurePlayerTransformEquipment(Next, Owner, True)
    EndIf
    If !Self.IsEquipmentRecoveryCurrent(Owner, True, Epoch)
      Return False
    EndIf
    PlayerRef.QueueNiNodeUpdate()
    Self.ApplySelectedSuccubusEyes(Owner, True)
  EndIf
  Self.EndAppearanceEdit(Owner)
  Return Actions > 0
EndFunction

Bool Function ChangeOutfitPartFromMenu40(Int Part, Int Choice)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777256
    Return Self.ChangeOutfitPartFromMenuCompat39(Part, Choice)
  EndIf
  Int admission = PSQAppearance.OutfitAdmission40(Self, Part, Choice)
  If admission < 0
    ; An uncached external horn or an unusual race needs the provider's lookup.
    Int horns = 0
    If Part == 3 && Choice > 8 && Choice != 100
      horns = Self.GetOptionalHornCount()
    EndIf
    If !PSQAppearance.OutfitSelectionAllowed(Part, Choice, horns, True) || !Self.CanUseTransformOutfitChoice(Part, Choice)
      Return False
    EndIf
  ElseIf admission == 0
    Return False
  EndIf
  Int[] ticket = Self.AcquireAppearanceEditTicket()
  If !ticket || ticket.Length != 2 || ticket[0] <= 0
    Return False
  EndIf
  Int owner = ticket[0]
  Int epoch = ticket[1]
  Int job = PSQAppearance.StartOutfitEdit40(PlayerRef, Self, owner, epoch, Part, Choice)
  Int result = Self.WaitAppearanceReceipt27(job, owner, epoch)
  If epoch != PSQLoadEpoch || owner != AppearanceOperationId || !AppearanceEditBusy
    Return False
  EndIf
  Self.EndAppearanceEdit(owner)
  Return result == 1
EndFunction



Function RestoreLegacyTransformSkinCompat39(Int Owner, Bool RequireBusy)
  Self.SyncPlayerAppearanceRace()
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  If TransformBodySaved
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    Self.ClearAppliedTransformBody(Owner, RequireBusy)
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    AppliedTransformEyeTexture = None
    If TransformOriginalSkin != None
      If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return
      EndIf
      PlayerRef.GetLeveledActorBase().SetSkin(TransformOriginalSkin)
    EndIf
    If TransformOriginalHead != None
      If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return
      EndIf
      PlayerRef.ChangeHeadPart(TransformOriginalHead)
    EndIf
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    TransformBodySaved = False
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    TransformOriginalSkin = None
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    TransformOriginalHead = None
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    PlayerRef.QueueNiNodeUpdate()
  EndIf
EndFunction

Function RestoreLegacyTransformSkin40(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777256
    Self.RestoreLegacyTransformSkinCompat39(Owner, RequireBusy)
    Return
  EndIf
  Int load40 = PSQLoadEpoch
  Self.SyncPlayerAppearanceRace()
  If load40 != PSQLoadEpoch
    Return
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  Int ticket40 = PSQAppearance.StartLookRecovery40(PlayerRef, Self, Owner, load40, RequireBusy, 0)
  While ticket40 == -2 && load40 == PSQLoadEpoch && Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Utility.WaitMenuMode(0.03)
    ticket40 = PSQAppearance.StartLookRecovery40(PlayerRef, Self, Owner, load40, RequireBusy, 0)
  EndWhile
  If ticket40 >= 2
    Self.WaitAppearanceReceipt27(ticket40, Owner, load40)
  ElseIf ticket40 == -1 && load40 == PSQLoadEpoch && Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Self.RestoreLegacyTransformSkinCompat39(Owner, RequireBusy)
  EndIf
EndFunction

Function RestoreTransformHairCompat39(Int Owner, Bool RequireBusy)
  If OrgHair == None
    Return
  EndIf
  Self.SyncPlayerAppearanceRace()
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  HeadPart Original = OrgHair
  If Original == None
    Return
  EndIf
  HeadPart Applied = StorageUtil.GetFormValue(PlayerRef, "PSQ_AppliedTransformHair", None) as HeadPart
  If Applied == None
    ; Pre-update saves have OrgHair but no stored transform part.
    Applied = Self.GetTransformHairChoice(SuccubusHairSelection, Owner, RequireBusy)
  EndIf
  HeadPart Current = Self.GetCurrentPlayerHair()
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  If Current != Original
    If !(SKSE.GetPluginVersion("PSQ Appearance") >= 16777231) || PSQAppearance.SwitchHead(PlayerRef, PlayerRef.GetLeveledActorBase(), Current, Original, Self, PlayerAppearanceRace, Owner, PSQLoadEpoch, RequireBusy, False) == 0
      PlayerRef.ChangeHeadPart(Original)
    EndIf
  ElseIf Applied != None && Applied != Original && PlayerRef.Is3DLoaded()
    ; A node rebuild can restore base data while the visible head still shows
    ; the other hair. Replace only that mesh without rebuilding the whole actor.
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    If !(SKSE.GetPluginVersion("PSQ Appearance") >= 16777231) || PSQAppearance.SwitchHead(PlayerRef, PlayerRef.GetLeveledActorBase(), Applied, Original, Self, PlayerAppearanceRace, Owner, PSQLoadEpoch, RequireBusy, True) == 0
      PlayerRef.ReplaceHeadPart(Applied, Original)
    EndIf
  EndIf
  If Self.GetCurrentPlayerHair() != Original
    Debug.Trace("[PSQ] Original hair not yet restored; keeping the saved hairstyle.", 0)
    Return
  EndIf
  If Self.IsAppearanceOperationCurrent(Owner, RequireBusy) && OrgHair == Original
    StorageUtil.UnsetFormValue(PlayerRef, "PSQ_AppliedTransformHair")
    If Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      OrgHair = None
    EndIf
  EndIf
EndFunction

Function RestoreTransformHair40(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777256
    Self.RestoreTransformHairCompat39(Owner, RequireBusy)
    Return
  EndIf
  Int load40 = PSQLoadEpoch
  Self.SyncPlayerAppearanceRace()
  If load40 != PSQLoadEpoch
    Return
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  Int ticket40 = PSQAppearance.StartLookRecovery40(PlayerRef, Self, Owner, load40, RequireBusy, 1)
  While ticket40 == -2 && load40 == PSQLoadEpoch && Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Utility.WaitMenuMode(0.03)
    ticket40 = PSQAppearance.StartLookRecovery40(PlayerRef, Self, Owner, load40, RequireBusy, 1)
  EndWhile
  If ticket40 >= 2
    Self.WaitAppearanceReceipt27(ticket40, Owner, load40)
  ElseIf ticket40 == -1 && load40 == PSQLoadEpoch && Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Self.RestoreTransformHairCompat39(Owner, RequireBusy)
  EndIf
EndFunction

Function RestoreOriginalPlayerEyesCompat39(Int Owner, Bool RequireBusy)
  Self.SyncPlayerAppearanceRace()
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  HeadPart Original = OrgEyes
  If Original != None
    HeadPart Current = Self.GetCurrentPlayerEyes()
    If Current != Original
      If Current == None || !PlayerRef.Is3DLoaded() || OrgEyes != Original || !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return
      EndIf
      PlayerRef.ChangeHeadPart(Original)
      If Self.GetCurrentPlayerEyes() != Original
        Return
      EndIf
    EndIf
    If OrgEyes != Original || !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    OrgEyes = None
  EndIf
  AppliedTransformEyeTexture = None
EndFunction

Function RestoreOriginalPlayerEyes40(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777256
    Self.RestoreOriginalPlayerEyesCompat39(Owner, RequireBusy)
    Return
  EndIf
  Int load40 = PSQLoadEpoch
  Self.SyncPlayerAppearanceRace()
  If load40 != PSQLoadEpoch
    Return
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  Int ticket40 = PSQAppearance.StartLookRecovery40(PlayerRef, Self, Owner, load40, RequireBusy, 2)
  While ticket40 == -2 && load40 == PSQLoadEpoch && Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Utility.WaitMenuMode(0.03)
    ticket40 = PSQAppearance.StartLookRecovery40(PlayerRef, Self, Owner, load40, RequireBusy, 2)
  EndWhile
  If ticket40 >= 2
    Self.WaitAppearanceReceipt27(ticket40, Owner, load40)
  ElseIf ticket40 == -1 && load40 == PSQLoadEpoch && Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Self.RestoreOriginalPlayerEyesCompat39(Owner, RequireBusy)
  EndIf
EndFunction

Function RefreshSuccubusEyeToggleCompat39(Int Owner, Bool RequireBusy)
  Self.SyncPlayerAppearanceRace()
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Return
  EndIf
  If !IsHenshined
    Return
  EndIf
  headpart Current = Self.GetCurrentPlayerEyes()
  Bool ApplyEyes = HenshinEyes && !psqracecompatibility.ShouldPreserveHeadAppearance(PlayerRef) && psqracecompatibility.CanUseHeadPart(PSQSuccubusEyes, PlayerRef.GetRace())
  If ApplyEyes
    If OrgEyes == None
      If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return
      EndIf
      OrgEyes = Current
    EndIf
    If PSQSuccubusEyes != None && Current != PSQSuccubusEyes
      If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
        Return
      EndIf
      PlayerRef.ChangeHeadPart(PSQSuccubusEyes)
    EndIf
    If !Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
      Return
    EndIf
    Self.ApplySelectedSuccubusEyes(Owner, RequireBusy)
  Else
    Self.RestoreOriginalPlayerEyes(Owner, RequireBusy)
  EndIf
EndFunction

Function RefreshSuccubusEyeToggle40(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777256
    Self.RefreshSuccubusEyeToggleCompat39(Owner, RequireBusy)
    Return
  EndIf
  Int load40 = PSQLoadEpoch
  Self.SyncPlayerAppearanceRace()
  If load40 != PSQLoadEpoch
    Return
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  Int ticket40 = PSQAppearance.StartLookRecovery40(PlayerRef, Self, Owner, load40, RequireBusy, 3)
  While ticket40 == -2 && load40 == PSQLoadEpoch && Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Utility.WaitMenuMode(0.03)
    ticket40 = PSQAppearance.StartLookRecovery40(PlayerRef, Self, Owner, load40, RequireBusy, 3)
  EndWhile
  If ticket40 >= 2
    Self.WaitAppearanceReceipt27(ticket40, Owner, load40)
  ElseIf ticket40 == -1 && load40 == PSQLoadEpoch && Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Self.RefreshSuccubusEyeToggleCompat39(Owner, RequireBusy)
  EndIf
EndFunction

Function ApplySelectedSuccubusEyesCompat39(Int Owner, Bool RequireBusy)
  Self.ApplySelectedSuccubusEyes38(Owner, RequireBusy)
EndFunction

Function ApplySelectedSuccubusEyes40(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777256
    Self.ApplySelectedSuccubusEyesCompat39(Owner, RequireBusy)
    Return
  EndIf
  Int load40 = PSQLoadEpoch
  Self.SyncPlayerAppearanceRace()
  If load40 != PSQLoadEpoch
    Return
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  Int ticket40 = PSQAppearance.StartLookRecovery40(PlayerRef, Self, Owner, load40, RequireBusy, 4)
  While ticket40 == -2 && load40 == PSQLoadEpoch && Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Utility.WaitMenuMode(0.03)
    ticket40 = PSQAppearance.StartLookRecovery40(PlayerRef, Self, Owner, load40, RequireBusy, 4)
  EndWhile
  If ticket40 >= 2
    Self.WaitAppearanceReceipt27(ticket40, Owner, load40)
  ElseIf ticket40 == -1 && load40 == PSQLoadEpoch && Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Self.ApplySelectedSuccubusEyesCompat39(Owner, RequireBusy)
  EndIf
EndFunction



Function SetScaleSuccubusCompat40(Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
    Return
  EndIf
  Bool PSQVisualRuntime = skse.GetPluginVersion("skee") >= 0 || skse.GetPluginVersion("nioverride") >= 0
  If EnableHeightChangeSuccubus
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.AddNodeTransformScale(PlayerRef as ObjectReference, True, True, "NPC", "PSQ", SuccubusHeight)
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.AddNodeTransformScale(PlayerRef as ObjectReference, False, True, "NPC", "PSQ", SuccubusHeight)
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.UpdateNodeTransform(PlayerRef as ObjectReference, True, True, "NPC")
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.UpdateNodeTransform(PlayerRef as ObjectReference, False, True, "NPC")
    EndIf
  EndIf
  If EnableButtChangeSuccubus
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.AddNodeTransformScale(PlayerRef as ObjectReference, True, True, "NPC L Butt", "PSQ", SuccubusButt)
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.AddNodeTransformScale(PlayerRef as ObjectReference, False, True, "NPC L Butt", "PSQ", SuccubusButt)
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.AddNodeTransformScale(PlayerRef as ObjectReference, True, True, "NPC R Butt", "PSQ", SuccubusButt)
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.AddNodeTransformScale(PlayerRef as ObjectReference, False, True, "NPC R Butt", "PSQ", SuccubusButt)
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.UpdateNodeTransform(PlayerRef as ObjectReference, True, True, "NPC L Butt")
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.UpdateNodeTransform(PlayerRef as ObjectReference, False, True, "NPC L Butt")
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.UpdateNodeTransform(PlayerRef as ObjectReference, True, True, "NPC R Butt")
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.UpdateNodeTransform(PlayerRef as ObjectReference, False, True, "NPC R Butt")
    EndIf
  EndIf
  If EnableGenitalsChangeSuccubus
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.AddNodeTransformScale(PlayerRef as ObjectReference, True, True, "NPC Genitals01 [Gen01]", "PSQ", SuccubusGenitals)
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.AddNodeTransformScale(PlayerRef as ObjectReference, False, True, "NPC Genitals01 [Gen01]", "PSQ", SuccubusGenitals)
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.UpdateNodeTransform(PlayerRef as ObjectReference, True, True, "NPC Genitals01 [Gen01]")
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.UpdateNodeTransform(PlayerRef as ObjectReference, False, True, "NPC Genitals01 [Gen01]")
    EndIf
  EndIf
  If EnableScrotumChangeSuccubus
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.AddNodeTransformScale(PlayerRef as ObjectReference, True, True, "NPC GenitalsScrotum [GenScrot]", "PSQ", SuccubusScrotum)
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.AddNodeTransformScale(PlayerRef as ObjectReference, False, True, "NPC GenitalsScrotum [GenScrot]", "PSQ", SuccubusScrotum)
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.UpdateNodeTransform(PlayerRef as ObjectReference, True, True, "NPC GenitalsScrotum [GenScrot]")
    EndIf
    If PSQVisualRuntime
      If Owner != AppearanceOperationId || RequireBusy && !AppearanceEditBusy
        Return
      EndIf
      nioverride.UpdateNodeTransform(PlayerRef as ObjectReference, False, True, "NPC GenitalsScrotum [GenScrot]")
    EndIf
  EndIf
  If Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Self.SyncTRXFutaSize(PlayerRef)
  EndIf
EndFunction

Function SetScaleSuccubus41(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777257
    Self.SetScaleSuccubusCompat40(Owner, RequireBusy)
    Return
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  Int epoch41 = PSQLoadEpoch
  Int job41 = PSQAppearance.StartScale41(Self,PlayerRef,Owner,epoch41,RequireBusy,True)
  While job41 == -2 && epoch41 == PSQLoadEpoch && Self.IsAppearanceOperationCurrent(Owner,RequireBusy)
    Utility.WaitMenuMode(0.03)
    job41 = PSQAppearance.StartScale41(Self,PlayerRef,Owner,epoch41,RequireBusy,True)
  EndWhile
  If job41 >= 2
    Self.WaitAppearanceReceipt27(job41,Owner,epoch41)
  ElseIf job41 == -1 && epoch41 == PSQLoadEpoch && Self.IsAppearanceOperationCurrent(Owner,RequireBusy)
    Int write41 = PSQAppearance.LegacyScaleWrite41(True,0)
    Self.SetScaleSuccubusCompat40(Owner,RequireBusy)
    PSQAppearance.LegacyScaleWrite41(False,write41)
  EndIf
EndFunction

Function SetScaleHumanCompat40(Int Owner, Bool RequireBusy)
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  If Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
    Return
  EndIf
  If Self.HasNiOverrideRuntime()
    String[] Nodes = new String[5]
    Nodes[0] = "NPC"
    Nodes[1] = "NPC L Butt"
    Nodes[2] = "NPC R Butt"
    Nodes[3] = "NPC Genitals01 [Gen01]"
    Nodes[4] = "NPC GenitalsScrotum [GenScrot]"
    ; Interrupted old stacks can have removed a scale before updating its node.
    Bool RebuildAll = AppearanceRecoveryInProgress || AppearanceRecoveryPending
    Int NodeIndex = 0
    While NodeIndex < Nodes.Length
      String Node = Nodes[NodeIndex]
      Int View = 0
      While View < 2
        If Owner != AppearanceOperationId || (RequireBusy && !AppearanceEditBusy)
          Return
        EndIf
        Bool FirstPerson = View == 0
        Bool Removed = NiOverride.RemoveNodeTransformScale(PlayerRef, FirstPerson, True, Node, "PSQ")
        If Removed || RebuildAll
          ; Finish the removal before honoring a new owner. Refresh uses the
          ; CURRENT transform keys, including any installed by the new owner.
          NiOverride.UpdateNodeTransform(PlayerRef, FirstPerson, True, Node)
        EndIf
        View += 1
      EndWhile
      NodeIndex += 1
    EndWhile
  EndIf
  If Self.IsAppearanceOperationCurrent(Owner, RequireBusy)
    Self.SyncTRXFutaSize(PlayerRef)
  EndIf
EndFunction

Function SetScaleHuman41(Int Owner, Bool RequireBusy)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777257
    Self.SetScaleHumanCompat40(Owner, RequireBusy)
    Return
  EndIf
  If Owner < 0
    Owner = AppearanceOperationId
    RequireBusy = AppearanceEditBusy
  ElseIf AppearanceEditBusy
    RequireBusy = True
  EndIf
  Int epoch41 = PSQLoadEpoch
  Int job41 = PSQAppearance.StartScale41(Self,PlayerRef,Owner,epoch41,RequireBusy,False)
  While job41 == -2 && epoch41 == PSQLoadEpoch && Self.IsAppearanceOperationCurrent(Owner,RequireBusy)
    Utility.WaitMenuMode(0.03)
    job41 = PSQAppearance.StartScale41(Self,PlayerRef,Owner,epoch41,RequireBusy,False)
  EndWhile
  If job41 >= 2
    Self.WaitAppearanceReceipt27(job41,Owner,epoch41)
  ElseIf job41 == -1 && epoch41 == PSQLoadEpoch && Self.IsAppearanceOperationCurrent(Owner,RequireBusy)
    Int write41 = PSQAppearance.LegacyScaleWrite41(True,0)
    Self.SetScaleHumanCompat40(Owner,RequireBusy)
    PSQAppearance.LegacyScaleWrite41(False,write41)
  EndIf
EndFunction
