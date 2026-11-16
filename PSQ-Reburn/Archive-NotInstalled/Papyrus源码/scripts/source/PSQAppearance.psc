ScriptName PSQAppearance Hidden Native
Int Function GetVersion() Global Native
Bool Function IsReady() Global Native
Bool Function SetHidden(Actor Target, Form[] Originals, Form[] Protected, Form[] Selected) Global Native
Bool Function Restore() Global Native

; API 2: read-only classification; -1 asks the Papyrus caller to fall back.
Int Function IsUBEActor(Actor Target) Global Native
Int Function IsUBEEquipment(Armor Item) Global Native

; API 3: fresh read-only main-thread batches, with fallback on unavailable data.
Float[] Function ReadPoolValues(Actor Target) Global Native
Int Function CheckStatEffects(Actor Target, Spell Ability, Float[] Magnitudes) Global Native
Int Function CheckEquipmentContext(Actor Target, Race ExpectedRace, Race PlannedRace, Int PlannedBody) Global Native

; API 4. Both calls return an empty array when the caller must use the legacy path.
Form[] Function ReadOutfitSnapshot(Actor Target, Form[] Worn, Form[] ProtectedItems, Armor Discarded) Global Native
Int[] Function PlanOutfitDifference(Armor[] Parts, Bool[] Enabled, Form[] Originals, Form[] ProtectedItems, Bool ReplaceHead, Bool HideAccessories, Bool Diagnostics) Global Native

; API 5. No inventory mutation or persistent game state in these queries.
Float[] Function ReadTransformBases(Actor Target) Global Native
Int[] Function ReadArmorState(Actor Target, Armor Item) Global Native
Function WatchPrimaryEquip(Int Owner, Int LoadEpoch, Int Slot, Armor Item, Float Elapsed) Global Native
Float[] Function TakePrimaryEquipTimes(Int Owner, Int LoadEpoch) Global Native

; API 6. Ticket lifetime is bounded by the current game/load and operation.
Int Function BeginEntryFlow(Int Owner, Int Epoch) Global Native
Int Function AdvanceEntryFlow(Int Ticket, Int Owner, Int Epoch, Int Completed) Global Native
Function CancelEntryFlow(Int Ticket) Global Native

; API 7: fresh count and wear state (0 free, 1 equipped, 2 overlapping armor).
; Empty means unavailable. A negative count means the player's race changed.
Int[] Function ReadExitArmorState(Actor Target, Armor Item, Race ExpectedRace, Bool InspectSlots) Global Native

; API 8. Release only a verified ledger entry for the current quest operation.
Int Function ReleaseExitArmor(Actor Target, Armor Item, Race ExpectedRace, Quest SourceQuest, Int Owner, Int Epoch, Bool RequireBusy, Int Baseline, Int Added) Global Native
Int[] Function ConfirmExitMain(Actor Target, Race ExpectedRace, Form[] Submitted) Global Native

; API 9. Same receipts as entry. Exit steps do not share entry tickets.
Int Function BeginExitFlow(Int Owner, Int Epoch) Global Native
Int Function AdvanceExitFlow(Int Ticket, Int Owner, Int Epoch, Int Completed) Global Native
Function CancelExitFlow(Int Ticket) Global Native
Form[] Function ReadTransformSnapshot(Actor Target, Form[] Worn, Form[] ProtectedItems, Armor Discarded) Global Native
HeadPart Function ReadTransformHead(ActorBase Base, Bool Hair) Global Native
Int Function RestoreTransformPools(Actor Target, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch, Int PoolEpoch, Bool Busy, Float[] Sample, Float[] Maxima) Global Native
Int Function EquipTransformArmor(Actor Target, Armor Item, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch, Bool Busy, Bool Original) Global Native

Int Function ApplyTransformBooster(Actor Target, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch, Perk Booster, Float Magnitude) Global Native
Bool Function NoLegacyArmor(Actor Target, Armor[] Retired) Global Native
Form[] Function ReadTransformArt(Int Rank) Global Native

; API 10

Int Function PreserveTransformPools(Actor Target, Quest SourceQuest, Int Owner, Int Epoch, Int PoolEpoch, Float H, Float M, Float S) Global Native
Form[] Function ProjectPlanForms(Armor[] Parts, Form[] Originals, Int[] Difference, Bool Strip) Global Native
Form[] Function PlanOriginalRestore(Armor[] Primary, Form[] Originals, Form[] ProtectedItems) Global Native
Form[] Function ReadProtectedBodySlots(Actor Target) Global Native
Form[] Function ReadPendingOriginals(Actor Target, Race ExpectedRace, Form[] Previous, Form[] Originals, Int Used, Form[] ProtectedItems) Global Native
Bool Function PendingOriginalsMatch(Actor Target, Race ExpectedRace, Form[] Previous, Form[] Originals, Int Used, Form[] ProtectedItems, Form[] Expected) Global Native
Int Function SubmitOriginalArmor(Actor Target, Armor Item, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch, Bool Busy) Global Native
Float[] Function TransformBonuses(Actor Target, Int Mode, Int Rank, Float H, Float M, Float S, Float C) Global Native
Int Function FillTransformPools(Actor Target, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch, Int PoolEpoch, Bool Busy, Float[] Sample, Float[] Percent) Global Native
Int Function SyncTransformRecords(Actor Target, Quest SourceQuest, Int Owner, Int Epoch, Int PoolEpoch, Spell Ability, Float[] Magnitudes, Perk Booster, Float Multiplier) Global Native

Int Function ClassifyLoadedAppearance(Int Direction, Bool Changing, Bool Transformed, Bool Pending) Global Native

Float Function RankSpeed(Int Rank, Bool Transformed) Global Native

Float Function ShoutReduction(Int Rank) Global Native

Int Function UnlockRank(Int Index) Global Native

Int Function DrainAmount(Int Rank) Global Native

Int Function MagicReduction(Int Rank, Bool Transformed) Global Native

Int Function ThrallCapacity(Int Rank) Global Native

Float Function SatiationStep(Float Ratio) Global Native

Float Function SatiationScale(Int Rank) Global Native

Int Function CheckAppearanceOwner(Actor Player, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch, Bool RequireBusy) Global Native

Int Function EquipLedgerPart(Actor Player, Armor Item, Race ExpectedRace, Quest SourceQuest, Int Owner, Int Epoch, Bool Busy) Global Native

Int Function ReleaseLedgerPart(Actor Player, Armor Item, Race ExpectedRace, Quest SourceQuest, Int Owner, Int Epoch, Bool Busy, Int Index) Global Native

Int Function CheckRecoveryRequest(Actor Player, Quest SourceQuest, Int Request, Int Owner, Int Epoch) Global Native

Float Function EnergyCapacity(Float Experience) Global Native

Int Function SenseTier(Float Energy, Float Capacity) Global Native

Int Function SatiationTier(Int Previous, Float Ratio) Global Native

Int Function ClaimAppearanceRecovery(Actor Player, Quest SourceQuest, Int Owner, Int Epoch, Int OriginalCount) Global Native

Int Function SkillDrainAmount(Int Mode, Int Rank, Float TargetLevel, Float PlayerLevel) Global Native

Float Function DigestionRate(Int Rank, Float Increment) Global Native

Float Function ThrallSkillBonus(Float Current, Float Previous) Global Native

Bool Function ToggleRankSpell(Actor Player, Spell Ability, Int Rank, Int RequiredRank) Global Native

Int Function PlayOwnedShader(Actor Player, EffectShader Shader, Float Duration, Quest OwnerQuest, Race ExpectedRace, Int Owner, Int Epoch) Global Native

Float[] Function NPCEnergyValues(Float Health, Float Factor, Bool UseMinimum, Float Minimum, Float Now, Float Last, Float AnimalScale, Float LoverScale, Bool Thrall, Float Stored) Global Native

String[] Function CaptureOriginalCopies(Actor Player, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch, Bool Busy, Form[] Originals) Global Native
Int Function OriginalCopyAction(Actor Player, Armor Item, String Key, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch, Bool Busy, Bool Submit, Bool ProtectSlots) Global Native
Float Function DigestRemoved(Int Pool, Float Requested, Float Vaginal, Float Anal, Float After, Float CombinedAfter, Float CombinedLimit) Global Native
Float[] Function DrainSettlement(Float Requested, Float Available, Float Rank, Float Experience) Global Native
Int Function InspectThralls(Quest Holder, Actor Target, Int Mode) Global Native
Int Function StopOwnedShader(Actor Player, EffectShader Shader, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch) Global Native
Int Function SettingIndex(String Option, Bool Continuous) Global Native

Int Function ChangeGameplayMode(Quest SourceQuest, Int Group, Int Mode) Global Native
Bool Function SyncAbilityBook(Quest SourceQuest, Actor Player, Int Rank, Int Mode, Bool[] Manual) Global Native
Int Function FHUReceipt(Quest SourceQuest, Int Serial, Int Epoch, Int Action) Global Native
Int Function CommitOutfitChoice(Actor Player, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch, Int Part, Int Choice, Armor Next) Global Native
Int Function ChooseThrall(Quest Holder, Actor Target, Int Capacity) Global Native
Int Function RitualMotion(Actor Player, VisualEffect Effect, Float Duration, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch) Global Native

Bool Function ProtectedDrainTarget(Actor Target, Quest Holder, Faction Followers) Global Native
Float Function TransferAttribute(Actor Target, Actor Player, Quest Holder, Faction Followers, String Name, Float Requested) Global Native
Float Function DigestStep(Float Rate, Float Reserve, Float Room, Bool Manual) Global Native
Bool Function ContinuousEntry(Quest SourceQuest, Actor Player, Form Ability, Bool Enabled, Int Epoch, Int Owner) Global Native
Bool Function FlushDrainDamage(Actor Target, Float Health, Float Stamina, Bool Lethal) Global Native
Float[] Function ThrallSkillTick(Quest SourceQuest, Quest Holder, Actor Target, Int Generation, Float[] Baseline) Global Native

Bool Function WriteMenuSetting(Quest SourceQuest, Int Index, Int IntValue, Float FloatValue, Bool BoolValue, Bool Toggle) Global Native
Int Function ApplyHairTint(Actor Player, ActorBase Base, ColorForm Color, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch, Bool Busy) Global Native
Int Function DrainPotionCount(Float Amount) Global Native

Int Function RetryOriginalBatch(Actor Player, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch, Bool Busy, Form[] Retry, Int Count, Form[] Protected, Form[] Originals, String[] Keys) Global Native

HeadPart Function ResolveHairChoice(Int Choice) Global Native
Int Function SwitchHead(Actor Player, ActorBase Base, HeadPart OldPart, HeadPart NewPart, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch, Bool Busy, Bool MeshOnly) Global Native
Bool Function TattooGradient(Quest SourceQuest, Float Ratio) Global Native

Int Function RestoreOutfitPhase(Actor Player, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch, Bool Busy, Form[] Plan, Int First, Int Last, Form[] Protected, Form[] Originals, String[] Keys) Global Native
Bool Function RaceHasTrait(Race Source, Spell Trait) Global Native
Form[] Function AcquireRacialTrait(Actor Player, Actor Target, String[] Owners, Int[] Primary, Int[] Secondary, Int[] Grants, Form[] Acquired, Int Seed) Global Native
Int Function FHURecoveryStep(Quest SourceQuest, Bool Loaded, Bool Available, Int Jobs, Float Now) Global Native
Actor Function GetRosterActor(Quest Holder, Int Slot) Global Native
Int Function BeginThrallRelease(Quest SourceQuest, Quest Holder, Int Slot, Actor Expected) Global Native
Int Function RecallRosterActor(Quest SourceQuest, Quest Holder, Actor Target, Int Slot) Global Native

Int Function ContinuousLoadout(Quest SourceQuest, Actor Player, Int Epoch, Int Owner, Int Mode, Bool Storage, Bool[] Choices) Global Native
Float[] Function SelectDrainSkill(Actor Target, Actor Player, Int Mode, Int Rank, Int Seed) Global Native

Int[] Function SkinTintRequest(Actor Player, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch, Bool Busy, Bool Restoring, Bool Capture, Int Current) Global Native
Bool Function FinishSkinRestore(Actor Player, Quest SourceQuest, Race ExpectedRace, Int Owner, Int Epoch, Bool Busy, Int Requested, Int Actual) Global Native

Int[] Function RacialCollectionRows(Actor Player, Race OwnRace, String[] Owners, Int[] Primary, Int[] Grants, Form[] Acquired, Spell[] Existing, Bool AcquiredOnly, Int Capacity) Global Native

Int Function BeginDigestPool(Quest SourceQuest, Int Owner, Int Pool, String Key, Float Amount, Float Vaginal, Float Anal, Float Now) Global Native
Int Function EndDigestPool(Quest SourceQuest, Int Serial, Int Epoch, String Expected, Bool Completed, Bool Receipt) Global Native

Bool Function CarryRepairRequired(Actor Player, Spell Ability, Int Index, Float Expected) Global Native
Int Function UpdateCarrySpells(Actor Player, Quest SourceQuest, Int Load, Int Revision, Int Old, Int Wanted, Bool Review) Global Native

Float[] Function DrainRewardRoute(Float Amount, Bool Extract, Bool CanExtract, Bool Oral) Global Native
Bool Function DrainRoleAllowed(Bool Enabled, Int Mode, Bool Victim, Bool Aggressor) Global Native
Float Function AdjustArousalDrain(Float Amount, Float Arousal) Global Native

Int Function BeginThrallConversion(Quest SourceQuest, Quest Holder, Actor Caster, Actor Target, Spell Curse, Int Capacity) Global Native
Float[] Function ThrallInitialSkills(Actor Target) Global Native

Int Function TransformShaderPhase(Actor Player, EffectShader Purple, EffectShader Pink, Quest SourceQuest, Int Owner, Int Epoch, Bool Entering, Bool Start, Int Rank) Global Native
Int Function SpendDragonSoul(Actor Player, Int Mode, GlobalVariable Succubus, GlobalVariable Energy, GlobalVariable Experience, Float Capacity) Global Native

Float[] Function DrainAttributesBatch(Actor Target, Actor Player, Quest Holder, Faction Followers, Int Rank, Int Seed) Global Native

Int Function CommitOriginalLedger(Actor Player, Quest SourceQuest, Race CurrentRace, Int Owner, Int Epoch, Bool Busy, Form[] Originals, Int Used, Form[] Protected, Form[] Saved, String[] Keys) Global Native

String Function TattooTexture(Int Choice, Int Rank) Global Native
Bool Function OwnsTattooTexture(String Texture) Global Native

Int Function PromotionRank(Int Rank, Float Experience, Bool Advanced) Global Native
Int Function ApplyPromotionAbilities(Quest SourceQuest, Actor Player, GlobalVariable Rank, GlobalVariable Experience) Global Native

Int Function RecordBodyChange(Quest SourceQuest, Int Owner, Int Epoch, Bool Busy, Int Request, Bool Apply, String Preset, Float Now) Global Native
Int Function SettleBodyChange(Quest SourceQuest, Int Owner, Int Epoch, Bool Busy, Int Request, Int Status) Global Native
Int Function CountInflaterJobs(Actor Player, Quest Inflater) Global Native

Int[] Function TransformStage(Actor Player, Quest SourceQuest, Int Owner, Int Epoch, Bool Entering, Int[] Previous, Int Result) Global Native
Int[] Function RestoreGearStep(Actor Player, Quest SourceQuest, Race CurrentRace, Int Owner, Int Epoch, Bool Busy, Form[] Plan, Int MainCount, Int Used, Form[] Protected, Form[] Saved, String[] Keys, Int[] Previous, Bool Manual) Global Native
Int Function GearRetryRequest(Quest SourceQuest, Actor Player, Int Action, Int Request, Int Owner, Int Epoch, Bool Menu, Float Now, Float Deadline) Global Native
Int[] Function ClaimEditTicket(Actor Player, Quest SourceQuest, Int Epoch) Global Native
Int Function OpenTransformDirection(Actor Player, Quest SourceQuest, Int Owner, Int Epoch) Global Native
Int Function GearSubstage(Actor Player, Quest SourceQuest, Int Owner, Int Epoch, Int Group, Int Completed, Int Receipt) Global Native
Int Function ThrallOverlayPolicy(Bool Release, String Node, Bool Runtime, Bool NodeLoaded, Bool SameSex, String Expected, String Current) Global Native
Bool Function ThrallOverlayFree(String Saved, String Live) Global Native
Int[] Function ThrallOverlayFields() Global Native
Int Function ThrallPropertyAction(Bool Capture, Bool Restore, Int Presence, Int Kind) Global Native
Int Function ThrallBondAction(Quest SourceQuest, Quest Holder, Actor Target, Faction OwnFaction, Int Epoch, Bool Release, Int Current, Int Previous, Int PreviousFaction, Int Ticket) Global Native
Bool Function ThrallBondFinish(Quest SourceQuest, Quest Holder, Actor Target, Int Epoch, Bool Release, Int Slot, Int Ticket) Global Native
Int Function ReserveThrallBond(Quest SourceQuest, Quest Holder, Actor Caster, Actor Target, Spell Curse, Int Capacity, Bool Release, Int Slot, Int Epoch) Global Native
Bool Function CheckThrallBond(Quest SourceQuest, Int Epoch, Int Ticket, Bool Finish) Global Native
Int Function MenuChoiceCommit(Quest SourceQuest, Int Owner, Int Epoch, Bool Busy, Int Kind, Int Choice, Int Limit, Form Resource, Bool EyeApplied) Global Native
Int Function MenuWingCommit(Quest SourceQuest, Int Owner, Int Epoch, Bool Busy, Int Choice, Armor NextWing, Spell AWU, Armor Previous, Armor Original) Global Native
Int Function MenuColorCommit(Quest SourceQuest, Int Kind, Int Value, Int Owner, Int Epoch, Bool Busy) Global Native
Int Function MenuGlowCommit(Quest SourceQuest, Int Mode, Int Color, Bool SetColor) Global Native
Int Function MenuBodyStep(Quest SourceQuest, Int Owner, Int Epoch, Bool Busy, Int Selection, String Preset, String Label, Bool Accepted, Bool Finish) Global Native
Float Function MenuFutaSize(Quest SourceQuest, Int TargetKind, Bool Scrotum, Float Value) Global Native
Bool Function MenuAppearanceLock(String Option) Global Native
Int Function MenuNPCWing(Actor Target, Armor Previous, Armor NextWing) Global Native
Int[] Function MenuToggleAppearance(Quest SourceQuest, String Option, Int Owner, Int Epoch, Bool Busy) Global Native
Int Function MenuShapeSlider(Quest SourceQuest, String Option, Float Value, Int Owner, Int Epoch, Bool Busy) Global Native
Int Function MenuListChoice(Actor Player, Race CachedRace, Int CachedUBE, Int UBE, Int CachedEpoch, Int Epoch, Int Index, Int Count) Global Native
String[] Function MenuBodyPageIDs(Quest SourceQuest, Int Offset, Int Count) Global Native
String Function MenuNPCKey(String Option) Global Native
Int Function MenuNPCAction(Quest SourceQuest, Actor Target, String Key, Int Prior, Bool HasWing, Bool VisualRuntime, Int Owner, Int Epoch, Bool Busy) Global Native
Int Function AdvanceAppearanceLook(Actor Player, Quest SourceQuest, Int Owner, Int Epoch, Int Last, Bool PreviousResult, Bool Refresh) Global Native
Bool Function OutfitSelectionAllowed(Int Part, Int Choice, Int HornCount, Bool Available) Global Native
Int Function SetOutfitSelection(Actor Player, Quest SourceQuest, Race PlayerRace, Int Owner, Int Epoch, Int Part, Int Choice, Armor Previous, Armor Next, Bool WasEnabled, Int Source, Bool SoftBody) Global Native
Int Function BodySkinSelection(Bool Futa, Bool Transformed, Bool ActiveForm, Bool PlayerPresent, String ID, Bool Available, Bool Named) Global Native
Int Function AdvanceTransformFinish(Actor Player, Quest SourceQuest, Int Owner, Int Epoch, Int Last, Bool RefreshNodes, Bool RefreshBody) Global Native
Float Function TransformationBoosterRate(Float Experience) Global Native

Int[] Function ExecuteTransform(ActiveMagicEffect Effect, Actor Player, Quest Holder, Int Owner, Int Epoch, Int Group, Int Start, Float Started, Int[] Cursor) Global Native
Int Function EquipBatch(Actor Player, Quest Holder, Race Current, Int Owner, Int Epoch, Bool Busy, Bool Primary, Bool Diagnostics, Float Elapsed, Form[] Parts, Form[] Protected, Race Planned, Int Family) Global Native
Int Function StripBatch(Actor Player, Quest Holder, Race Current, Int Owner, Int Epoch, Bool Busy, Bool Hiding, Form[] Pieces) Global Native
Int[] Function ExecuteRestore(Actor Player, Quest Holder, Race Current, Int Owner, Int Epoch, Bool Busy, Form[] Plan, Int MainCount, Int Used, Form[] Protected, Form[] Saved, String[] Keys, Int[] Cursor, Bool Manual) Global Native

Int Function StartAppearanceTask(Actor Target, Quest Holder, ActiveMagicEffect Effect, Int Owner, Int Epoch, Bool Busy, Int Action, Bool Option, Float Ratio) Global Native
Int Function PollAppearanceTask(Int Ticket, Quest Holder, Int Owner, Int Epoch) Global Native

Int Function RunEntryStatsNow(Actor Player, Quest Holder, Int Owner, Int LoadEpoch, Bool FinalPass) Global Native
Float[] Function FillOwnedEntryPools(Actor Player, Quest Holder, Int Owner, Int LoadEpoch, Int PoolEpoch) Global Native
Int Function SyncTransformBonus(Actor Player, Quest Holder, Int Owner, Int LoadEpoch, Int PoolEpoch, Bool During, Bool Force, Bool Removing) Global Native
Int Function BeginPoolEdit(Quest Holder, Int Owner, Bool AllowAppearance) Global Native
Function EndPoolEdit(Quest Holder, Int PoolEpoch) Global Native

Int Function StartBodyRequest24(Actor Player, Quest Controller, Int Owner, Int Epoch, Bool Busy, Bool Apply, String Preset, Bool WaitForCompletion) Global Native
Int Function SettleBodyRequest24(Quest Controller, Int Owner, Int Epoch, Bool Busy, Int Request, Int Status) Global Native
Bool Function ClearReturnedFields24(Actor Player, Quest Controller, Race Expected, Int Owner, Int Epoch, Bool Busy) Global Native
Bool Function PeekAppearanceTask25(Int Ticket, Quest Controller, Int Owner, Int Epoch) Global Native
Int Function TransformPumpWait26(Int Ticket, Int PreviousTicket, Int Owner, Int Epoch) Global Native
Int Function JoinBodyRequest25(Actor Player, Quest Controller, Int Owner, Int Epoch, Bool Busy, Int Request) Global Native

Armor[] Function ResolveOutfitChoices28(Actor Player, Quest Controller, Race Expected, Int Owner, Int Epoch, Bool Busy, Int Selection) Global Native
Bool Function EnsureEntryPartSources28(Actor Player, Quest Controller, Race Expected, Int Owner, Int Epoch, Bool Busy) Global Native
Bool Function CommitEntryOutfitChoices28(Actor Player, Quest Controller, Race Expected, Int Owner, Int Epoch, Bool Busy, Int Selection, Armor[] Parts, Int Family) Global Native
Form[] Function PrepareOutfitPlan28(Actor Player, Quest Controller, Race Expected, Int Owner, Int Epoch, Bool Busy, Form[] Originals, Form[] Protected, Bool PreserveBody, Bool PreserveHead, Bool Hide, Int Family) Global Native
Form[] Function OutfitPlanSection28(Form[] Packet, Bool Strip) Global Native

Int[] Function ReadOutfitPolicy29(Actor Target, Quest Controller, Race ExpectedRace, Race PlannedRace, Int Owner, Int Epoch, Bool RequireBusy, Int Mode) Global Native
Bool Function IsOutfitPlanCurrent29(Actor Target, Quest Controller, Race ExpectedRace, Race PlannedRace, Int Owner, Int Epoch, Bool RequireBusy, Int Family) Global Native

Int Function StartStages31(Actor Player, Quest Controller, ActiveMagicEffect Effect, Int Owner, Int Epoch, Bool Entering) Global Native
Int Function StartMenuRetry31(Actor Player, Quest Controller, Int Owner, Int Epoch, Int Request) Global Native
Int Function PublishPlan31(Actor Player, Quest Controller, Race PlannedRace, Int Owner, Int Epoch, Bool Busy, Int Family, Bool Hide, Form[] Packet) Global Native
Form[] Function ReadPlan31(Actor Player, Quest Controller, Int Owner, Int Epoch, Bool Busy, Bool Strip) Global Native
Int Function ReadPlanState31(Actor Player, Quest Controller, Int Owner, Int Epoch, Bool Busy) Global Native
Function InvalidatePlan31() Global Native
Int Function EquipPublished31(Actor Player, Quest Controller, Int Owner, Int Epoch, Bool Busy, Bool Main, Bool Diagnostics, Float Elapsed, Form[] Protect) Global Native

Bool Function ExternalPluginLoaded33(String Plugin) Global Native
Int Function ExternalPluginVersion33(String Plugin) Global Native
Bool Function BodyProviderInstalled33() Global Native
Int Function BodyBridgeCandidate33() Global Native
Int Function OSLVersion33() Global Native
Int Function RacePolicy33(Actor Target, Int Mode, Int Kind) Global Native
Bool Function HeadPartAllowed33(HeadPart Part, Race TargetRace) Global Native
Bool Function SendFlightCommand33(Actor Player, String Command, Float Amount) Global Native
Bool Function SyncFlightPolicy33(Quest Controller) Global Native
Int Function FlightAirborne33(Quest Controller) Global Native

Float[] Function ReadNGArousal33(Actor Target) Global Native
Bool Function SexLabPPlus33() Global Native
Bool Function HasNiOverride33() Global Native
Bool Function HasDragonWingAssets33() Global Native
Bool Function HasFairyWingAssets33() Global Native
Int Function ContinuousRank34(Quest Controller) Global Native
Bool Function StorageUnlocked34(Quest Controller) Global Native
Float Function RankScale34(Quest Controller) Global Native
Float Function AutoDigestion34(Quest Controller) Global Native
Float Function RankSpeed34(Quest Controller, Bool Active) Global Native
Float Function TotalSpeed34(Quest Controller) Global Native
Float Function RankShout34(Quest Controller) Global Native
Int Function RankMagic34(Quest Controller) Global Native
Float Function EnergyRatio34(Quest Controller) Global Native
Int Function DigestionMode34(Quest Controller) Global Native
Int Function ContinuousMode34(Quest Controller) Global Native
Int Function AbilityMode34(Quest Controller) Global Native
Int Function SatietyMode34(Quest Controller) Global Native
Int Function BuffMode34(Quest Controller) Global Native
Float Function ArmorPerRank34(Quest Controller) Global Native
Int Function GlowMode34(Quest Controller) Global Native
Bool Function OwnerCurrent34(Quest Controller, Int Owner, Bool Busy) Global Native
Bool Function GearCurrent34(Quest Controller, Int Owner, Bool Busy, Int Epoch) Global Native
Bool Function PoolCurrent34(Quest Controller, Int Epoch, Int Owner) Global Native
Bool Function RefillCurrent34(Quest Controller, Int Owner, Bool Busy) Global Native
Bool Function SceneCurrent34(Quest Controller, Int Tid, Int Serial, Int Epoch) Global Native
Bool Function RacialUICurrent34(Quest Controller, Int LoadId, Int SyncId) Global Native
Spell Function DrainSpell34(Quest Controller, Int Family, Int Rank) Global Native
Spell Function Ability34(Quest Controller, Int Index) Global Native
Bool Function AbilityEnabled34(Quest Controller, Int Index) Global Native
Bool Function CaptureAbilities34(Quest Controller) Global Native
Int Function ManagedBook34(Quest Controller) Global Native
Bool Function SyncCost34(Quest Controller, Bool Reset) Global Native
Armor Function SelectedSkin34(Quest Controller) Global Native
Bool Function FlightDefinitions34(Quest Controller) Global Native
Bool Function ResetFlight34(Quest Controller) Global Native
Bool Function DisconnectFlight34(Quest Controller) Global Native
Bool Function RefreshFlight34(Quest Controller, Int LoadId, Int Generation, Float Time) Global Native
Bool Function ReleaseJump34(Quest Controller) Global Native
Bool Function UpdateJump34(Quest Controller) Global Native
Bool Function FlightReply34(Quest Controller, String Status, Float Value, Form Sender, Int LoadId, Int Generation, Float Time) Global Native
Int Function BodyProbe34(Quest Controller, Int LoadId) Global Native
Bool Function BodyVerified34(Quest Controller, Int LoadId, Int Expected, Int Actual) Global Native
Spell Function CostSpell34(Int Tier) Global Native
Int Function Percent34(Int Index) Global Native
Spell Function AnimatedWing34(Int Id) Global Native
FormList Function RaceList34(Bool Vampire) Global Native
Int Function PairIndex34(Race Source) Global Native
Bool Function Vanilla34(Race Source) Global Native
Bool Function BeastRace34(Race Source) Global Native
Bool Function SkinUBE34(Armor Skin) Global Native
Bool Function HasSLA34() Global Native
Bool Function NGCandidate34() Global Native
Int[] Function ArousalCandidates34(Int Mode) Global Native
Int Function CapabilityPlan34(Int Backend) Global Native
Float Function ArousalValue34(Int Backend, Float Value) Global Native
Int Function RateMask34(Int Backend, Int Caps, Float Time, Float Exposure) Global Native
Bool Function AproposMarker34() Global Native
Bool Function AproposReady34() Global Native
Quest Function Inflater34() Global Native
String Function CapabilityName34(Int Caps) Global Native
String Function GetConditionalString34(Int Value) Global Native
String Function GetSkillDrainModeName34(Int Value) Global Native
String Function GetDragonSoulModeName34(Int Value) Global Native
String Function GetSatiationModeName34(Int Value) Global Native
String Function GetDigestionModeName34(Int Value) Global Native
String Function GetTattooGlowModeName34(Int Value) Global Native
String Function GetEnergyBarDisplayName34(Int Value) Global Native
Float Function NextXP34(GlobalVariable Rank) Global Native
String[] Function FeedEntries34() Global Native
String Function FeedResult34(Int i) Global Native
Int Function LearnCheck34(Quest Controller, Spell Item, Int Rank, Float Cost, Float Skill, String School) Global Native
String Function SchoolName34(String School) Global Native
Bool Function PartSelected34(Quest Controller, Int Part) Global Native
Bool Function EnsureSources34(Quest Controller) Global Native
Int Function PartSource34(Quest Controller, Int Part) Global Native
Int Function CatalogState34(Quest Controller, Int Owner, Bool Busy, Int Epoch) Global Native
Bool Function CommitCatalog34(Quest Controller, Int Owner, Bool Busy, Int Epoch, String[] Ids) Global Native
String Function PresetID34(Quest Controller, Int Selection, Int Owner, Bool Busy, Int Epoch) Global Native
Bool Function SkinReady34(Quest Controller, Actor Target, Bool Futa) Global Native
Bool Function SkinMatches34(Bool Futa, String Current, Int Mode, String Applied) Global Native
Bool Function SkinRestore34(Quest Controller, String Wanted, Int RaceMode) Global Native
Bool Function FHUTaskCurrent34(Quest Controller, Int Request, Int Owner) Global Native
Bool Function XPEnabled34(Quest Controller) Global Native
Int Function RefreshXPTier34(Quest Controller, Int Previous, Float Now, Float Last) Global Native
Float Function XPMultiplier34(Int Tier) Global Native
Bool Function SourceReady34(Int Outfit) Global Native
Bool Function NormalizeModels34(Quest Controller, Int Owner, Bool Busy, Int Epoch, Bool[] Sources) Global Native
Bool Function SetModel34(Quest Controller, Int ID, Int Outfit, String Third, String First, Int Owner, Bool Busy, Int Epoch) Global Native
Int Function BeginPSQLoadSessionStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function PSQReloadStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function PSQReloadCoreStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function QuitSuccubusStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function PSQStartSexStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function PSQOrgasmStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function PSQOrgasmCoreStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function PSQOrgasmSeparateStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function PSQOrgasmSeparateCoreStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function PSQEndSexStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function ResetPSQSexSceneStateStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function BeginPPlusSceneStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function PSQPPlusOrgasmStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function ProcessPPlusOrgasmStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function SettlePPlusOrgasmStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function ResetFastModeEndStateStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function TryEndExhaustedFastSceneStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function ReleaseFastModeCallbackStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function BeginDeferredDrainStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function FlushDeferredDrainStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function QueueDeferredDrainDamageStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function SuccubusDrainStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function SuccubusLevelUpStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function ProcessingArousalStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function ResetStatPoolEditsOnLoadStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function CancelInterruptedAppearanceOnLoadStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function InvalidateAppearanceForLoadStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function RestoreRetirementPoolsStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function ClearContinuousRankEffectsStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function ClearContinuousRankEffectsCoreStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function CleanupRetiredFastModeKeysStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function ResetSlotsStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function EnsureDeferredDrainStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function IsFastModeClosingSceneStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function FastModeTargetsExhaustedStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native
Int Function GetFastModePendingCallbacksStep35(Quest Controller, Int Cursor, Int[] Integers, Float[] Reals, Int[] Flags, Actor Subject) Global Native

Bool Function RefreshProtectedBodyCache36(Quest ownerQuest, Actor player) Global Native

Int Function EyeCatalogSize38(Quest q, Int owner, Bool busy, Int epoch, Int revision) Global Native
Bool Function PublishEyeCatalog38(Quest q, Int owner, Bool busy, Int epoch, Int revision, String[] names, String[] plugins, Int[] ids) Global Native
TextureSet Function ResolveEyeTexture38(Quest q, Int owner, Bool busy, Int epoch, Int revision, Int index, String plugin, Int localID) Global Native
Bool Function MigrateEyeSelection38(Quest q, Int epoch, Int[] previous) Global Native
Int Function EyeLabelSource38(Quest q, Int epoch, Int revision, Int index, Int count, Int localizedCount) Global Native
String Function EyeMaterialLabel38(Quest q, Int epoch, Int revision, Int index, Int source, String value) Global Native
Bool Function EyeApplyStep38(Quest q, Int owner, Bool busy, Int epoch, Int revision, Int expected, TextureSet texture, Int step) Global Native

Bool Function NormalizeOutfitSources38(Quest Controller, Int Owner, Bool RequireBusy) Global Native
String Function OutfitSourceStatus38(Int Outfit) Global Native
Int Function OutfitChoiceState38(Quest Controller, Int Part, Int Choice) Global Native
Int Function BeginSatietySync38(Int Tier) Global Native
Bool Function SyncSatietyPerks38(Quest Controller, Actor Target, Int Tier, Int StoredTier, Int Epoch, Int Ticket) Global Native

HeadPart Function HairChoice38(Quest q, Int choice, Int owner, Bool busy) Global Native
String Function HornFile38(Quest q, Int revision, Int epoch, String[] files, Int index, Int used) Global Native
Int Function HornRows38(Int names, Int plugins, Int forms) Global Native
Int Function CollectHorns38(Int rows, String[] names, String[] plugins, Int[] ids, Int used, String[] outNames, String[] outKeys) Global Native
Bool Function CommitHorns38(Quest q, Int revision, Int epoch, Int used, String[] names, String[] keys) Global Native
String Function PartName38(Quest q, Int part, Int choice) Global Native

Form Function CachedPart39(Quest q, Int selection, Int part, Int owner, Bool busy) Global Native
Form Function ResolvePart39(Quest q, Armor item, Int part, Bool readSelection) Global Native
Bool Function ClearBodyReceipt39(Quest q, Int owner, Bool busy) Global Native
Bool Function BodyMatches39(Quest q, Float weight, Int owner, Bool busy) Global Native

Int Function BeginSatietyXP40(Quest owner, Actor subject, Int epoch) Global Native
Int[] Function PlanSatietyXP40(Quest owner, Actor subject, Int epoch, Int request, Int saved, Float now, Float last) Global Native
Bool Function OwnsSatietyXP40(Quest owner, Actor subject, Int epoch, Int request) Global Native
Bool Function ApplySatietyXP40(Quest owner, Actor subject, Int epoch, Int request, Int written, Int stored) Global Native
Float Function SatietyXPResult40(Quest owner, Actor subject, Int epoch, Int request, Int tier) Global Native
Int Function SetSatietyMode40(Quest owner, Actor subject, Int epoch, Int mode) Global Native
Bool Function StepSatietyMode40(Quest owner, Actor subject, Int epoch, Int request, Bool finish) Global Native

Int Function OutfitAdmission40(Quest q, Int part, Int choice) Global Native
Int Function StartOutfitEdit40(Actor player, Quest q, Int owner, Int epoch, Int part, Int choice) Global Native
Int Function StartWardrobe40(Actor player, Quest q, Int owner, Int epoch, Bool busy, Int part, Int choice) Global Native

Int Function StartLookRecovery40(Actor Target, Quest Holder, Int Owner, Int Epoch, Bool Busy, Int Operation) Global Native

Int Function LegacyScaleWrite41(Bool begin, Int ticket) Global Native
Int Function StartScale41(Quest holder, Actor target, Int owner, Int epoch, Bool busy, Bool apply) Global Native

Form[] Function ReadProtectedArmor42(Actor Player) Global Native
