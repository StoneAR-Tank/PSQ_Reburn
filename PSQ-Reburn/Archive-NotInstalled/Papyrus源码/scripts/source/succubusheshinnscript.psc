ScriptName succubusheshinnscript Extends ActiveMagicEffect

;-- Variables ---------------------------------------
Form[] TransformArt
Int TransformArtRank = -1
Bool NativeMotionStarted = False
Int OperationOwner = 0
Armor OrgArmorTemp
Bool TraceStageTimings
Float TransformStageClock = 0.0
Int TransformVisualRank = 1

;-- Properties --------------------------------------
Idle Property IdleDisHenshin Auto
Idle Property IdleHenshin Auto
playersuccubusquestscript Property PSQ Auto

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Event OnEffectStart(Actor akTarget, Actor akCaster)
  If akCaster != PSQ.PlayerRef
    Return
  EndIf
  Int Direction = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Int[] Claim = PSQ.AcquireTransformAfterLoad()
    If !Claim || Claim.Length != 2 || Claim[0] <= 0
      Return
    EndIf
    OperationOwner = Claim[0]
    Direction = PSQAppearance.OpenTransformDirection(akCaster,PSQ,OperationOwner,Claim[1])
    If Direction <= 0
      PSQ.EndAppearanceEdit(OperationOwner)
      Return
    EndIf
  Else
    If !PSQ.BeginTransformAfterLoad()
      Return
    EndIf
    OperationOwner = PSQ.AppearanceOperationId
  EndIf
  Float AppearanceStarted
  TraceStageTimings = PSQ.EnableEquipmentDiagnostics
  If TraceStageTimings
    AppearanceStarted = Utility.GetCurrentRealTime()
    TransformStageClock = AppearanceStarted
  EndIf
  If Direction == 1 || (Direction == 0 && !PSQ.IsHenshined)
    If Direction == 0
      PSQ.AppearanceTransformDirection = 1
      PSQ.AppearanceSnapshotReady = False
    EndIf
    storageutil.SetIntValue(PSQ.PlayerRef as Form, "PSQ_SuccubusON", 1)
    If !Self.RunEntryFlow(akCaster)
      Return
    EndIf
  Else
    storageutil.SetIntValue(PSQ.PlayerRef as Form, "PSQ_SuccubusON", 0)
    If Direction == 0
      PSQ.AppearanceTransformDirection = 2
      PSQ.AppearanceSnapshotReady = True
    EndIf
    If !Self.RunExitFlow(akCaster)
      Return
    EndIf
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  storageutil.SetIntValue(PSQ.PlayerRef as Form, "PSQ_SuccubusON", PSQ.IsHenshined as Int)
  If TraceStageTimings
    Debug.Trace(("[PSQ] Transform appearance finished; transformed=" + PSQ.IsHenshined as String) + ", scriptSeconds=" + (Utility.GetCurrentRealTime() - AppearanceStarted) as String, 0)
  EndIf
  PSQ.EndAppearanceEdit(OperationOwner)
EndEvent

Function Henshin(Actor Succu)
  Self.RunEntryFlow(Succu)
EndFunction

Function DisHenshin(Actor Succu)
  Self.RunExitFlow(Succu)
EndFunction

Function EnsureTransformItem(Actor Target, Armor Item)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  If Target == None || Item == None
    Return 
  EndIf
  Bool Detailed = PSQ.EnableEquipmentDiagnostics
  Float Started = 0.0
  If Detailed
    Started = Utility.GetCurrentRealTime()
  EndIf
  PSQ.EnsurePlayerTransformEquipment(Item, OperationOwner, True)
  If Detailed
    Debug.Trace((("[PSQ-EQUIP] transform; item=" + Item as String) + "; slotMask=" + Item.GetSlotMask() as String) + "; seconds=" + (Utility.GetCurrentRealTime() - Started) as String, 0)
  EndIf
EndFunction

EffectShader Function GetTransformVisual(Int Phase)
  If Phase < 0 || Phase > 1
    Return None
  EndIf
  If TransformArt && TransformArt.Length == 8 && TransformArtRank == TransformVisualRank
    Return TransformArt[Phase] as EffectShader
  EndIf
  If TransformVisualRank == 1
    Return Game.GetFormFromFile(41606 + Phase, "PSQ PlayerSuccubusQuest.esm") as EffectShader
  EndIf
  Return Game.GetFormFromFile(41608 + (TransformVisualRank - 2) * 2 + Phase, "PSQ PlayerSuccubusQuest.esm") as EffectShader
EndFunction

Function BeginTransformVisual(Actor Target, Bool Entering)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777238 && PSQAppearance.IsReady()
    If Target == PSQ.PlayerRef
      PSQ.RunAppearanceTask(Self,OperationOwner,PSQ.GetPSQLoadEpoch(),True,2,Entering,0.0)
      Return
    EndIf
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  If PSQ.AppearanceRecoveryInProgress
    Self.StopInterruptedTransformVisuals(Target)
    Return 
  EndIf
  EffectShader BodyGlow = Self.GetTransformBodyPinkShader()
  If BodyGlow != None && Target != None
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Self.StopPhaseShader(Target, BodyGlow)
  EndIf
  NativeMotionStarted = Self.BeginOriginalMotion(Target, Entering)
  TransformVisualRank = PSQ.SuccubusRank.GetValueInt()
  If TransformVisualRank < 1
    TransformVisualRank = 1
  ElseIf TransformVisualRank > 10
    TransformVisualRank = 10
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777225
    TransformArt = PSQAppearance.ReadTransformArt(TransformVisualRank)
    TransformArtRank = TransformVisualRank
  EndIf
  EffectShader Purple = Self.GetTransformVisual(0)
  EffectShader Pink = Self.GetTransformVisual(1)
  If Purple == None || Pink == None || Target == None
    Return 
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777233
    If PSQAppearance.TransformShaderPhase(Target, Purple, Pink, PSQ, OperationOwner, PSQ.GetPSQLoadEpoch(), Entering, True, TransformVisualRank) != 0
      Return
    EndIf
  EndIf
  Self.StopPhaseShader(Target, Purple)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  Self.StopPhaseShader(Target, Pink)
  If Entering
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Self.PlayPhaseShader(Target, Purple, 120.0)
  Else
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Self.PlayPhaseShader(Target, Pink, 0.649999976 + ((TransformVisualRank - 1) as Float * 0.035))
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Self.PlayPhaseShader(Target, Purple, 120.0)
  EndIf
EndFunction

Function CompleteTransformVisual(Actor Target, Bool Entering)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777238 && PSQAppearance.IsReady()
    If Target == PSQ.PlayerRef
      PSQ.RunAppearanceTask(Self,OperationOwner,PSQ.GetPSQLoadEpoch(),True,3,Entering,0.0)
      Return
    EndIf
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  If PSQ.AppearanceRecoveryInProgress
    Return 
  EndIf
  If Target == None || !Target.Is3DLoaded() || Target.IsDead() || PSQ.IsHenshinchu || PSQ.IsHenshined != Entering
    Return 
  EndIf
  Utility.Wait(0.100000001)
  If Target == None || !Target.Is3DLoaded() || Target.IsDead() || PSQ.IsHenshinchu || PSQ.IsHenshined != Entering
    Return 
  EndIf
  EffectShader Purple = Self.GetTransformVisual(0)
  EffectShader Pink = Self.GetTransformVisual(1)
  Int ShaderCleanup = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777233
    ShaderCleanup = PSQAppearance.TransformShaderPhase(Target, Purple, Pink, PSQ, OperationOwner, PSQ.GetPSQLoadEpoch(), Entering, False, TransformVisualRank)
  EndIf
  If ShaderCleanup < 0
    Return
  ElseIf ShaderCleanup == 0
    If Purple != None
      If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
        Return 
      EndIf
      Self.StopPhaseShader(Target, Purple)
    EndIf
    If Pink != None
      If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
        Return 
      EndIf
      Self.StopPhaseShader(Target, Pink)
    EndIf
  EndIf
  Bool BodyGlowPlayed = False
  If Entering
    BodyGlowPlayed = Self.PlayTransformBodyPink(Target)
  EndIf
  If Self.CompleteOriginalMotion(Target, Entering)
    Return 
  EndIf
  If Purple == None || Pink == None
    Return 
  EndIf
  If Entering
    If BodyGlowPlayed
      Return 
    EndIf
    Utility.Wait(0.600000024)
    If PSQ.IsHenshinchu || !PSQ.IsHenshined || Target.IsDead() || !Target.Is3DLoaded()
      Return 
    EndIf
    Spell Pulse
    If TransformArt && TransformArt.Length == 8 && TransformArtRank == TransformVisualRank
      Pulse = TransformArt[3] as Spell
    Else
      Pulse = Game.GetFormFromFile(41636 + TransformVisualRank - 1, "PSQ PlayerSuccubusQuest.esm") as Spell
    EndIf
    If Pulse != None
      If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
        Return 
      EndIf
      Pulse.Cast(Target as ObjectReference, Target as ObjectReference)
    EndIf
  Else
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Self.PlayPhaseShader(Target, Purple, 0.449999988 + ((TransformVisualRank - 1) as Float * 0.025))
  EndIf
EndFunction

Bool Function BeginOriginalMotion(Actor Target, Bool Entering)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  If Target == None || !Target.Is3DLoaded() || Target.IsDead() || !Game.IsPluginInstalled("PSQ PlayerSuccubusQuest.esm")
    Return False
  EndIf
  Int VisualID = 41997
  If !Entering
    VisualID = 41998
  EndIf
  ; BeginTransformVisual already stopped the body glow. Reuse the startup
  ; form we resolved while stopping interrupted PSQ rituals.
  VisualEffect Motion = Self.StopRitualMotions(Target, VisualID)
  If Motion == None || !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  Self.ApplyPhaseMotion(Target, Motion, 120.0)
  Debug.Trace("[PSQFX] Sustained ritual started (completion-controlled, max 120s); entering=" + Entering as String, 0)
  Return True
EndFunction

Bool Function CompleteOriginalMotion(Actor Target, Bool Entering)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  If !NativeMotionStarted
    Return False
  EndIf
  NativeMotionStarted = False
  If Target == None || !Target.Is3DLoaded() || Target.IsDead() || !Game.IsPluginInstalled("PSQ PlayerSuccubusQuest.esm")
    Return True
  EndIf
  Int StartID = 41997
  Int FinishID = 42006
  If !Entering
    StartID = 41998
    FinishID = 42010
  EndIf
  VisualEffect Start
  VisualEffect Finish
  If TransformArt && TransformArt.Length == 8
    If Entering
      Start = TransformArt[4] as VisualEffect
      Finish = TransformArt[6] as VisualEffect
    Else
      Start = TransformArt[5] as VisualEffect
      Finish = TransformArt[7] as VisualEffect
    EndIf
  Else
    Start = Game.GetFormFromFile(StartID, "PSQ PlayerSuccubusQuest.esm") as VisualEffect
    Finish = Game.GetFormFromFile(FinishID, "PSQ PlayerSuccubusQuest.esm") as VisualEffect
  EndIf
  If Start != None
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return False
    EndIf
    Self.ApplyPhaseMotion(Target, Start, -1.0)
  EndIf
  If Finish == None
    Debug.Trace("[PSQFX] Short finish record unavailable; no ritual replay requested", 1)
    Return True
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  Self.ApplyPhaseMotion(Target, Finish, -1.0)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  Self.ApplyPhaseMotion(Target, Finish, 2.0)
  Debug.Trace("[PSQFX] Short finish played once; entering=" + Entering as String, 0)
  Return True
EndFunction

Function TraceTransformStage(String Stage)
  Float Now = Utility.GetCurrentRealTime()
  Debug.Trace("[PSQ-PERF] " + Stage + "; seconds=" + (Now - TransformStageClock) as String, 0)
  TransformStageClock = Now
EndFunction

EffectShader Function GetTransformBodyPinkShader()
  If TransformArt && TransformArt.Length == 8
    Return TransformArt[2] as EffectShader
  EndIf
  If !Game.IsPluginInstalled("PSQ PlayerSuccubusQuest.esm")
    Return None
  EndIf
  Return Game.GetFormFromFile(42017, "PSQ PlayerSuccubusQuest.esm") as EffectShader
EndFunction

Bool Function PlayTransformBodyPink(Actor Target)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  If Target == None || !Target.Is3DLoaded() || Target.IsDead() || PSQ.IsHenshinchu || !PSQ.IsHenshined
    Return False
  EndIf
  EffectShader BodyGlow = Self.GetTransformBodyPinkShader()
  If BodyGlow == None
    Return False
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  Self.StopPhaseShader(Target, BodyGlow)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777230
    Int Result = PSQAppearance.PlayOwnedShader(Target, BodyGlow, 6.0, PSQ, PSQ.PlayerRef.GetRace(), OperationOwner, PSQ.GetPSQLoadEpoch())
    If Result < 0
      Return False
    ElseIf Result == 0
      BodyGlow.Play(Target as ObjectReference, 6.0)
    EndIf
  Else
    BodyGlow.Play(Target as ObjectReference, 6.0)
  EndIf
  Debug.Trace("[PSQFX] Full-body pink glow requested once; seconds=6", 0)
  Return True
EndFunction

Bool Function ContinueAppearance(String Stage)
  If !PSQ.TouchAppearanceOperation(OperationOwner, Stage)
    Return False
  EndIf
  If TraceStageTimings
    Self.TraceTransformStage(Stage)
  EndIf
  Return True
EndFunction

Function StopInterruptedTransformVisuals(Actor Target)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777238 && PSQAppearance.IsReady()
    If Target == PSQ.PlayerRef
      PSQ.RunAppearanceTask(Self,OperationOwner,PSQ.GetPSQLoadEpoch(),True,4,False,0.0)
      Return
    EndIf
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return
  EndIf
  If Target == None || !Game.IsPluginInstalled("PSQ PlayerSuccubusQuest.esm")
    Return
  EndIf
  Self.StopRitualMotions(Target, 0)
  EffectShader Glow = Self.GetTransformBodyPinkShader()
  If Glow != None && PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Self.StopPhaseShader(Target, Glow)
  EndIf
EndFunction

VisualEffect Function StopRitualMotions(Actor Target, Int RequestedID)
  Int[] Records = new Int[4]
  Records[0] = 41997
  Records[1] = 41998
  Records[2] = 42006
  Records[3] = 42010
  VisualEffect Requested
  Int i = 0
  While i < Records.Length
    Int ID = Records[i]
    VisualEffect Motion = Game.GetFormFromFile(ID, "PSQ PlayerSuccubusQuest.esm") as VisualEffect
    If Motion != None
      If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
        Return None
      EndIf
      Self.ApplyPhaseMotion(Target, Motion, -1.0)
      If ID == RequestedID
        Requested = Motion
      EndIf
    EndIf
    i += 1
  EndWhile
  Return Requested
EndFunction


Bool Function RunEntryFlow(Actor Succu)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.PerformTransformStages(Succu, True)
  EndIf
  Bool NativeFlow = SKSE.GetPluginVersion("PSQ Appearance") >= 16777222 && PSQAppearance.IsReady()
  Int Epoch = PSQ.GetPSQLoadEpoch()
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  Int Ticket = 1
  If NativeFlow
    Ticket = PSQAppearance.BeginEntryFlow(OperationOwner, Epoch)
  EndIf
  If Ticket <= 0
    Return False
  EndIf
  Float EntryStarted = TransformStageClock
  Int Completed = 0
  Int Nodes = 0
  Bool Success = True
  If TraceStageTimings && NativeFlow
    Debug.Trace("[PSQ-PERF] enter.native_flow.begin; api=6; owner=" + OperationOwner)
  EndIf
  While Success
    Int Action = Completed + 1
    If NativeFlow
      Action = PSQAppearance.AdvanceEntryFlow(Ticket, PSQ.AppearanceOperationId, PSQ.GetPSQLoadEpoch(), Completed)
    ElseIf !PSQ.IsEquipmentRecoveryCurrent(OperationOwner, True, Epoch)
      Action = -1
    ElseIf Completed == 6
      Action = 0
    EndIf
    If Action == 0 && Completed == 6
      If TraceStageTimings && NativeFlow
        Debug.Trace("[PSQ-PERF] enter.native_flow.complete; owner=" + OperationOwner)
      EndIf
      Return True
    EndIf
    If Action <= 0 || !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Success = False
    ElseIf Action == 1
      Int Capture = Self.CaptureEntryOutfitResult()
      If Capture == 0 && PSQ.IsEquipmentRecoveryCurrent(OperationOwner, True, Epoch) && !PSQ.IsHenshined && PSQ.AppearanceTransformDirection == 1
        If NativeFlow
          PSQAppearance.CancelEntryFlow(Ticket)
        EndIf
        If TraceStageTimings
          Debug.Trace("[PSQ-PERF] enter.refused; owner=" + OperationOwner)
        EndIf
        ; OnEffectStart clears the external flag and ends this edit normally.
        Return True
      EndIf
      Success = Capture == 1
    ElseIf Action == 2
      Success = Self.CommitEntryCostAndHealth()
    ElseIf Action == 3
      Success = Self.WearEntryPrimary(EntryStarted)
    ElseIf Action == 4
      Nodes = Self.ApplyEntryAppearance(Succu)
      Success = Nodes >= 0
    ElseIf Action == 5
      Success = Self.WearEntryAccessories()
    ElseIf Action == 6
      Success = Self.FinishEntry(Succu, Nodes > 0)
    Else
      Success = False
    EndIf
    If Success
      Completed = Action
    EndIf
  EndWhile
  If NativeFlow
    PSQAppearance.CancelEntryFlow(Ticket)
  EndIf
  Debug.Trace("[PSQ-RECOVERY] Native entry interrupted; owner=" + OperationOwner + "; last completed=" + Completed + "; currentOwner=" + PSQ.AppearanceOperationId + "; busy=" + PSQ.AppearanceEditBusy + "; epoch=" + Epoch + "; currentEpoch=" + PSQ.GetPSQLoadEpoch())
  PSQ.RecoverFailedNativeEntry(OperationOwner, Epoch)
  Return False
EndFunction

Int Function CaptureEntryOutfitResult()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.PerformGearSubstages(1, 0.0)
  EndIf
  If !PSQ.ApplySuccubusOutfitSelectionCore(PSQ.SuccubusOutfitSelection, OperationOwner, True)
    Return 0
  EndIf
  If !Self.ContinueAppearance("enter.outfit_resolve")
    Return -1
  EndIf
  Float SnapshotStart
  Float GearDone
  Float HairDone
  If TraceStageTimings
    SnapshotStart = Utility.GetCurrentRealTime()
  EndIf
  Bool[] Refusal = new Bool[1]
  if !PSQ.SaveEntryOutfitSnapshot(OperationOwner, True, Refusal)
    If Refusal[0]
      Return 0
    EndIf
    Return -1
  endif
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return -1
  EndIf
  If TraceStageTimings
    GearDone = Utility.GetCurrentRealTime()
  EndIf
  PSQ.CaptureOriginalTransformHair(OperationOwner)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return -1
  EndIf
  PSQ.AppearanceSnapshotReady = True
  If TraceStageTimings
    HairDone = Utility.GetCurrentRealTime()
  EndIf
  If !Self.ContinueAppearance("enter.equipment_snapshot")
    Return -1
  EndIf
  If TraceStageTimings
    Debug.Trace("[PSQ-PERF] entry.snapshot_outer; owner=" + OperationOwner + "; equipmentAndGuard=" + (GearDone - SnapshotStart) + "; hairAndGuard=" + (HairDone - GearDone))
  EndIf
  Return 1
EndFunction

Bool Function CommitEntryCostAndHealth()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.DriveTransformFinish(PSQ.PlayerRef,OperationOwner,PSQ.GetPSQLoadEpoch(),0,False,False)
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  PSQ.IsHenshinchu = True
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  PSQ.IsHenshined = True
  PSQ.ResetTransformEnergyClock()
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  ; Commit the cost once. The existing final Satiety(0) refreshes HUD and tier.
  PSQ.ChangeSatiationEnergy(-20.0, False)
  If !Self.ContinueAppearance("enter.energy_charge")
    Return False
  EndIf
  PSQ.UpdateTransformBuff(True, OperationOwner)
  If !Self.ContinueAppearance("enter.attribute_bonus")
    Return False
  EndIf
  PSQ.BufferTransformEntryHealth(OperationOwner)
  If !Self.ContinueAppearance("enter.attribute_prime")
    Return False
  EndIf
  Return True
EndFunction

Bool Function WearEntryPrimary(Float EntryStarted)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.PerformGearSubstages(3, EntryStarted) == 1
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  PSQ.EquipTransformPartsPhase(OperationOwner, True, True, EntryStarted)
  If !Self.ContinueAppearance("enter.primary_equipment")
    Return False
  EndIf
  Return True
EndFunction

Int Function ApplyEntryAppearance(Actor Succu)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.DriveAppearanceLook(Succu, OperationOwner, PSQ.GetPSQLoadEpoch(), 0)
  EndIf
  Int i
  Float BodyStarted
  Bool RefreshNodes = False
  PSQ.SyncRankMagicCostReduction()
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return -1
  EndIf
  Int HenshinMoan = PSQ.SoundHenshinMoan.Play(Succu as ObjectReference)
  Self.BeginTransformVisual(Succu, True)
  Bool IdleStarted = False
  If IdleHenshin != None
    IdleStarted = Succu.PlayIdle(IdleHenshin)
  EndIf
  If IdleStarted
    Utility.Wait(0.25)
  EndIf
  If !Self.ContinueAppearance("enter.visual_after_primary")
    Return -1
  EndIf
  PSQ.StripTransformAccessories(OperationOwner, True)
  If !Self.ContinueAppearance("enter.strip_accessories")
    Return -1
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return -1
  EndIf
  PSQ.OrgHairColor = None
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return -1
  EndIf
  PSQ.SetScaleSuccubus(OperationOwner, True)
  If PSQ.CanWalkOnTheWater
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return -1
    EndIf
    Succu.AddSpell(PSQ.SuccubusWaterWalking, False)
  EndIf
  If PSQ.HenshinEyes && !psqracecompatibility.ShouldPreserveAppearance(Succu) && psqracecompatibility.CanUseHeadPart(PSQ.PSQSuccubusEyes, Succu.GetRace())
    ActorBase EyeBase = Succu.GetLeveledActorBase()
    HeadPart NativeEye
    If SKSE.GetPluginVersion("PSQ Appearance") >= 16777225
      NativeEye = PSQAppearance.ReadTransformHead(EyeBase, False)
    EndIf
    If NativeEye != None
      If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
        Return -1
      EndIf
      PSQ.OrgEyes = NativeEye
    Else
      Int Eye = EyeBase.GetNumHeadParts()
      i = 0
      While i < Eye
        headpart EyePart = EyeBase.GetNthHeadPart(i)
        If EyePart != None && EyePart.GetType() == 2
          If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
            Return -1
          EndIf
          PSQ.OrgEyes = EyePart
          i = Eye
        EndIf
        i += 1
      EndWhile
    EndIf
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return -1
    EndIf
    Succu.ChangeHeadPart(PSQ.PSQSuccubusEyes)
  EndIf
  If PSQ.HenshinBody
    If TraceStageTimings
      BodyStarted = Utility.GetCurrentRealTime()
    EndIf
    PSQ.ApplyTransformBodyMorphs(False, OperationOwner, True)
    If TraceStageTimings
      Debug.Trace("[PSQ-PERF] enter.body_request; seconds=" + (Utility.GetCurrentRealTime() - BodyStarted))
    EndIf
  EndIf
  If !Self.ContinueAppearance("enter.body_morphs")
    Return -1
  EndIf
  If PSQ.HenshinSkin
    PSQ.ApplyTransformSkinColor(True, OperationOwner, True)
    If !PSQ.HenshinHairColor
      RefreshNodes = True
    EndIf
  EndIf
  If PSQ.HenshinTattoo
    Float Manpukudo = PSQ.GetEnergyRatio()
    PSQ.ChangeBodyPaint(Manpukudo, True)
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return -1
  EndIf
  PSQ.ApplySelectedTransformHair(OperationOwner, True)
  If PSQ.HenshinHairColor
    PSQ.ApplyTransformHairColor(True, OperationOwner, True)
    If PSQ.OrgHairColor != None
      RefreshNodes = True
    EndIf
  EndIf
  If !Self.ContinueAppearance("enter.hair_and_tattoo")
    Return -1
  EndIf
  Return RefreshNodes as Int
EndFunction

Bool Function WearEntryAccessories()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.PerformGearSubstages(5, 0.0) == 1
  EndIf
  PSQ.ApplyTransformSlot52(OperationOwner, True)
  If !Self.ContinueAppearance("enter.pre_equipment")
    Return False
  EndIf
  PSQ.SyncAWUWing()
  PSQ.EquipSelectedTransformParts(OperationOwner, True)
  If !Self.ContinueAppearance("enter.equipment_apply")
    Return False
  EndIf
  Return True
EndFunction

Bool Function FinishEntry(Actor Succu, Bool RefreshNodes)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.DriveTransformFinish(Succu,OperationOwner,PSQ.GetPSQLoadEpoch(),20,RefreshNodes,False)
  EndIf
  Int i
  Float BodyStarted
  If PSQ.HenshinFear
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return False
    EndIf
    PSQ.SuccubusFormFearSpell.Cast(Succu as ObjectReference, None)
  EndIf
  If PSQ.HenshinIsCrime
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return False
    EndIf
    Succu.AddToFaction(PSQ.SuccubusFoeFaction)
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return False
    EndIf
    Succu.SetAttackActorOnSight(True)
  EndIf
  Float BoosterRate = Math.Sqrt(Math.Sqrt(PSQ.SuccubusEXP.GetValue())) / 2.0
  If BoosterRate < 1.0
    BoosterRate = 1.0
  EndIf
  Int Applied = 0
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777225
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return False
    EndIf
    Applied = PSQAppearance.ApplyTransformBooster(Succu, PSQ, PSQ.PlayerRef.GetRace(), OperationOwner, PSQ.GetPSQLoadEpoch(), PSQ.SuccubusSpellBoostPerk, BoosterRate)
    If Applied < 0 || !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return False
    EndIf
  EndIf
  If Applied == 0
    i = 0
    While i <= 6
      If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
        Return False
      EndIf
      PSQ.SuccubusSpellBoostPerk.SetNthEntryValue(i, 1, BoosterRate)
      i += 1
    EndWhile
  EndIf
  If PSQ.EnableSuccubusSpellBooster
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return False
    EndIf
    PSQ.TransformBooster.SetValue(1.0)
  EndIf
  If !Self.ContinueAppearance("enter.pre_model_refresh")
    Return False
  EndIf
  If PSQ.HenshinBody
    If TraceStageTimings
      BodyStarted = Utility.GetCurrentRealTime()
    EndIf
    PSQ.RefreshEquippedTransformBody(OperationOwner, True)
    If TraceStageTimings
      Debug.Trace("[PSQ-PERF] enter.body_settle; seconds=" + (Utility.GetCurrentRealTime() - BodyStarted))
    EndIf
  EndIf
  If RefreshNodes
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return False
    EndIf
    Succu.QueueNiNodeUpdate()
  EndIf
  If !Self.ContinueAppearance("enter.model_refresh")
    Return False
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  PSQ.IsHenshinchu = False
  PSQ.Satiety(0.0)
  PSQ.ApplySelectedSuccubusEyes(OperationOwner, True)
  If !Self.ContinueAppearance("enter.final_effects")
    Return False
  EndIf
  Self.CompleteTransformVisual(Succu, True)
  If !Self.ContinueAppearance("enter.visual_complete")
    Return False
  EndIf
  PSQ.RefillTransformAttributes(OperationOwner, True)
  If !Self.ContinueAppearance("enter.attribute_refill")
    Return False
  EndIf
  Return True
EndFunction

Bool Function RunExitFlow(Actor Succu)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.PerformTransformStages(Succu, False)
  EndIf
  Bool NativeFlow = SKSE.GetPluginVersion("PSQ Appearance") >= 16777225 && PSQAppearance.IsReady()
  Int Epoch = PSQ.GetPSQLoadEpoch()
  Int Ticket = 1
  If NativeFlow
    Ticket = PSQAppearance.BeginExitFlow(OperationOwner, Epoch)
  EndIf
  Int Completed = 0
  Int Nodes = 0
  Bool Body = PSQ.HenshinBody
  Bool OK = Ticket > 0
  While OK
    Int Action = Completed + 1
    If NativeFlow
      Action = PSQAppearance.AdvanceExitFlow(Ticket, PSQ.AppearanceOperationId, PSQ.GetPSQLoadEpoch(), Completed)
    ElseIf !PSQ.IsEquipmentRecoveryCurrent(OperationOwner, True, Epoch)
      Action = -1
    ElseIf Completed == 6
      Action = 0
    EndIf
    If Action == 0 && Completed == 6
      If TraceStageTimings && NativeFlow
        Debug.Trace("[PSQ-PERF] exit.native_flow.complete; api=9; owner=" + OperationOwner)
      EndIf
      Return True
    ElseIf Action == 1
      OK = Self.BeginExitEffects(Succu, Epoch)
    ElseIf Action == 2
      Nodes = Self.RestoreExitLook(Succu, Epoch)
      OK = Nodes >= 0
    ElseIf Action == 3
      OK = Self.RestoreExitGear(Succu, Epoch)
    ElseIf Action == 4
      OK = Self.SettleExitBody(Succu, Epoch, Body, Nodes > 0)
    ElseIf Action == 5
      OK = Self.RestoreExitHair(Succu, Epoch)
    ElseIf Action == 6
      OK = Self.FinishExit(Succu, Epoch)
    Else
      OK = False
    EndIf
    If OK
      Completed = Action
    EndIf
  EndWhile
  If NativeFlow
    PSQAppearance.CancelExitFlow(Ticket)
  EndIf
  Debug.Trace("[PSQ-RECOVERY] native exit interrupted; owner=" + OperationOwner + "; completed=" + Completed)
  PSQ.RecoverNativeExit(OperationOwner, Epoch)
  Return False
EndFunction

Bool Function BeginExitEffects(Actor Succu, Int ExitEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.DriveAppearanceLook(Succu, OperationOwner, ExitEpoch, 30) >= 0
  EndIf
  If !PSQ.IsEquipmentRecoveryCurrent(OperationOwner, True, ExitEpoch)
    Return False
  EndIf
  PSQ.IsHenshinchu = True
  If !PSQ.AppearanceRecoveryInProgress
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return False
    EndIf
    PSQ.SettleTransformEnergy()
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  PSQ.IsHenshined = False
  PSQ.SyncAWUWing()
  PSQ.ResetTransformEnergyClock()
  PSQ.SyncRankMagicCostReduction()
  Self.BeginTransformVisual(Succu, False)
  Bool IdleStarted = False
  If IdleDisHenshin != None && !PSQ.AppearanceRecoveryInProgress
    IdleStarted = Succu.PlayIdle(IdleDisHenshin)
  EndIf
  If IdleStarted
    Utility.Wait(0.25)
  EndIf
  If !Self.ContinueAppearance("exit.visual_and_idle")
    Return False
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  Return True
EndFunction

Int Function RestoreExitLook(Actor Succu, Int ExitEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.DriveAppearanceLook(Succu, OperationOwner, ExitEpoch, 40)
  EndIf
  If !PSQ.IsEquipmentRecoveryCurrent(OperationOwner, True, ExitEpoch)
    Return -1
  EndIf
  Float BodyStarted
  Float BuffStart
  Float ScaleStart
  Float EyesStart
  Float BodyStart
  Float SkinStart
  Float ColorStart
  Float SlotStart
  Float LookDone
  Bool RefreshNodes = False
  If TraceStageTimings
    BuffStart = Utility.GetCurrentRealTime()
  EndIf
  PSQ.RemoveTransformBuffSafely(OperationOwner, -1)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return -1
  EndIf
  Succu.RemoveSpell(PSQ.SuccubusWaterWalking)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return -1
  EndIf
  Succu.RemoveSpell(PSQ.SuccubusArmorSpell)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return -1
  EndIf
  If TraceStageTimings
    ScaleStart = Utility.GetCurrentRealTime()
  EndIf
  PSQ.SetScaleHuman(OperationOwner, True)
  If TraceStageTimings
    EyesStart = Utility.GetCurrentRealTime()
  EndIf
  PSQ.RestoreOriginalPlayerEyes(OperationOwner, True)
  If TraceStageTimings
    BodyStart = Utility.GetCurrentRealTime()
  EndIf
  If PSQ.HenshinBody
    If TraceStageTimings
      BodyStarted = Utility.GetCurrentRealTime()
    EndIf
    PSQ.RestoreTransformBodyMorphs(False, OperationOwner, True)
    If TraceStageTimings
      Debug.Trace("[PSQ-PERF] exit.body_request; seconds=" + (Utility.GetCurrentRealTime() - BodyStarted))
    EndIf
  EndIf
  If TraceStageTimings
    SkinStart = Utility.GetCurrentRealTime()
  EndIf
  If PSQ.RestoreTransformSkinColor(OperationOwner, True)
    If PSQ.OrgHairColor == None
      RefreshNodes = True
    EndIf
  EndIf
  If TraceStageTimings
    ColorStart = Utility.GetCurrentRealTime()
  EndIf
  If PSQ.RestoreOriginalPlayerHairColor(OperationOwner, True)
    RefreshNodes = True
  EndIf
  If TraceStageTimings
    SlotStart = Utility.GetCurrentRealTime()
  EndIf
  PSQ.ReleaseTransformSlot52(True, OperationOwner, True)
  If TraceStageTimings
    LookDone = Utility.GetCurrentRealTime()
  EndIf
  If !Self.ContinueAppearance("exit.body_hair_restore")
    Return -1
  EndIf
  If TraceStageTimings
    Debug.Trace("[PSQ-PERF] exit.appearance_times; owner=" + OperationOwner + "; buffs=" + (ScaleStart - BuffStart) + "; scale=" + (EyesStart - ScaleStart) + "; eyes=" + (BodyStart - EyesStart) + "; body=" + (SkinStart - BodyStart) + "; skin=" + (ColorStart - SkinStart) + "; hairColor=" + (SlotStart - ColorStart) + "; slot52=" + (LookDone - SlotStart))
  EndIf
  Return RefreshNodes as Int
EndFunction

Bool Function RestoreExitGear(Actor Succu, Int ExitEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.DriveTransformFinish(Succu,OperationOwner,ExitEpoch,50,False,False)
  EndIf
  If !PSQ.IsEquipmentRecoveryCurrent(OperationOwner, True, ExitEpoch)
    Return False
  EndIf
  PSQ.RestoreTransformEquipment(OperationOwner, True)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  PSQ.TransformBooster.SetValue(0.0)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  Succu.RemoveFromFaction(PSQ.SuccubusFoeFaction)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  Succu.SetAttackActorOnSight(False)
  If !Self.ContinueAppearance("exit.equipment_restore")
    Return False
  EndIf
  Return True
EndFunction

Bool Function SettleExitBody(Actor Succu, Int ExitEpoch, Bool RefreshBody, Bool RefreshNodes)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.DriveTransformFinish(Succu,OperationOwner,ExitEpoch,60,RefreshNodes,RefreshBody)
  EndIf
  If !PSQ.IsEquipmentRecoveryCurrent(OperationOwner, True, ExitEpoch)
    Return False
  EndIf
  Float BodyStarted
  If !PSQ.ClearRestoredEquipmentFields(OperationOwner, True, ExitEpoch)
    Return False
  EndIf
  If RefreshBody
    If TraceStageTimings
      BodyStarted = Utility.GetCurrentRealTime()
    EndIf
    PSQ.RefreshEquippedTransformBody(OperationOwner, True)
    If TraceStageTimings
      Debug.Trace("[PSQ-PERF] exit.body_settle; seconds=" + (Utility.GetCurrentRealTime() - BodyStarted))
    EndIf
  EndIf
  If RefreshNodes
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return False
    EndIf
    Succu.QueueNiNodeUpdate()
  EndIf
  Return True
EndFunction

Bool Function RestoreExitHair(Actor Succu, Int ExitEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.DriveAppearanceLook(Succu, OperationOwner, ExitEpoch, 60) >= 0
  EndIf
  If !PSQ.IsEquipmentRecoveryCurrent(OperationOwner, True, ExitEpoch)
    Return False
  EndIf
  Float HairStart
  Float HairEnd
  If TraceStageTimings
    HairStart = Utility.GetCurrentRealTime()
  EndIf
  PSQ.RestoreTransformHair(OperationOwner, True)
  If TraceStageTimings
    HairEnd = Utility.GetCurrentRealTime()
  EndIf
  If !Self.ContinueAppearance("exit.model_refresh")
    Return False
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  If TraceStageTimings
    Debug.Trace("[PSQ-PERF] exit.hair_restore; owner=" + OperationOwner + "; seconds=" + (HairEnd - HairStart))
  EndIf
  Return True
EndFunction

Bool Function FinishExit(Actor Succu, Int ExitEpoch)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777236 && PSQAppearance.IsReady()
    Return Self.DriveTransformFinish(Succu,OperationOwner,ExitEpoch,70,False,False)
  EndIf
  If !PSQ.IsEquipmentRecoveryCurrent(OperationOwner, True, ExitEpoch)
    Return False
  EndIf
  PSQ.IsHenshinchu = False
  PSQ.Satiety(0.0)
  If !Self.ContinueAppearance("exit.final_effects")
    Return False
  EndIf
  Self.CompleteTransformVisual(Succu, False)
  Return True
EndFunction


Bool Function CaptureEntryOutfit()
  Return Self.CaptureEntryOutfitResult() == 1
EndFunction

Function StopPhaseShader(Actor Target, EffectShader Shader)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    Int Status = PSQAppearance.StopOwnedShader(Target, Shader, PSQ, PSQ.PlayerRef.GetRace(), OperationOwner, PSQ.GetPSQLoadEpoch())
    If Status != 0
      Return
    EndIf
  EndIf
  If PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Shader.Stop(Target)
  EndIf
EndFunction

Function PlayPhaseShader(Actor Target, EffectShader Shader, Float Duration)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    Int Status = PSQAppearance.PlayOwnedShader(Target, Shader, Duration, PSQ, PSQ.PlayerRef.GetRace(), OperationOwner, PSQ.GetPSQLoadEpoch())
    If Status != 0
      Return
    EndIf
  EndIf
  If PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Shader.Play(Target, Duration)
  EndIf
EndFunction

Function ApplyPhaseMotion(Actor Target, VisualEffect Effect, Float Duration)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777231
    Int Status = PSQAppearance.RitualMotion(Target, Effect, Duration, PSQ, PSQ.PlayerRef.GetRace(), OperationOwner, PSQ.GetPSQLoadEpoch())
    If Status != 0
      Return
    EndIf
  EndIf
  If PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    If Duration < 0.0
      Effect.Stop(Target)
    Else
      Effect.Play(Target, Duration, None)
    EndIf
  EndIf
EndFunction

; Keep suspended native-adapter calls on the normal saveable Papyrus stack.
Bool Function PerformTransformStages(Actor Succu, Bool Entering)
  Int Epoch = PSQ.GetPSQLoadEpoch()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777247
    Int Job = PSQAppearance.StartStages31(Succu,PSQ,Self,OperationOwner,Epoch,Entering)
    If Job == -2
      Return False
    EndIf
    Int Outcome = PSQ.WaitAppearanceReceipt27(Job,OperationOwner,Epoch)
    If Outcome == 1
      Return True
    EndIf
    If Outcome != -2 && OperationOwner == PSQ.AppearanceOperationId && Epoch == PSQ.GetPSQLoadEpoch()
      If Entering
        PSQ.RecoverFailedNativeEntry(OperationOwner,Epoch)
      Else
        PSQ.RecoverNativeExit(OperationOwner,Epoch)
      EndIf
    EndIf
    Return False
  EndIf
  Int[] Cursor
  Int Receipt = 0
  Int LastStage = 0
  While True
    Cursor = PSQAppearance.TransformStage(Succu,PSQ,OperationOwner,Epoch,Entering,Cursor,Receipt)
    If !Cursor || Cursor.Length != 4
      Receipt = -3
    Else
      Receipt = Cursor[1]
    EndIf
    If Receipt == -2
      Return False
    ElseIf Receipt < 0
      Debug.Trace("[PSQ-RECOVERY] transform interrupted; entering=" + Entering + "; owner=" + OperationOwner + "; stage=" + LastStage)
      If Entering
        PSQ.RecoverFailedNativeEntry(OperationOwner, Epoch)
      Else
        PSQ.RecoverNativeExit(OperationOwner, Epoch)
      EndIf
      Return False
    ElseIf Receipt == 0 || Receipt == 7
      If TraceStageTimings
        Debug.Trace("[PSQ-PERF] native_flow.complete; entering=" + Entering + "; owner=" + OperationOwner + "; outcome=" + Receipt)
      EndIf
      Return True
    EndIf
    LastStage = Receipt
    If Entering
      If LastStage == 1
        Receipt = Self.CaptureEntryOutfitResult()
      ElseIf LastStage == 2
        Receipt = Self.CommitEntryCostAndHealth() as Int
      ElseIf LastStage == 3
        Receipt = Self.WearEntryPrimary(TransformStageClock) as Int
      ElseIf LastStage == 4
        Receipt = Self.ApplyEntryAppearance(Succu)
      ElseIf LastStage == 5
        Receipt = Self.WearEntryAccessories() as Int
      ElseIf LastStage == 6
        Receipt = Self.FinishEntry(Succu,Cursor[2] != 0) as Int
      EndIf
    Else
      If LastStage == 1
        Receipt = Self.BeginExitEffects(Succu,Epoch) as Int
      ElseIf LastStage == 2
        Receipt = Self.RestoreExitLook(Succu,Epoch)
      ElseIf LastStage == 3
        Receipt = Self.RestoreExitGear(Succu,Epoch) as Int
      ElseIf LastStage == 4
        Receipt = Self.SettleExitBody(Succu,Epoch,Cursor[3] != 0,Cursor[2] != 0) as Int
      ElseIf LastStage == 5
        Receipt = Self.RestoreExitHair(Succu,Epoch) as Int
      ElseIf LastStage == 6
        Receipt = Self.FinishExit(Succu,Epoch) as Int
      EndIf
    EndIf
  EndWhile
  Return False
EndFunction

Int Function PerformGearSubstages(Int Group, Float Started)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777237 && PSQAppearance.IsReady()
    Return Self.PumpTransformExecution26(PSQ.PlayerRef,OperationOwner,PSQ.GetPSQLoadEpoch(),Group,0,Started)
  EndIf
  Int Epoch = PSQ.GetPSQLoadEpoch()
  Int Completed = 0
  Int Receipt = 1
  Float SnapshotStart
  Float GearDone
  While True
    Int Action = PSQAppearance.GearSubstage(PSQ.PlayerRef,PSQ,OperationOwner,Epoch,Group,Completed,Receipt)
    If Action < 0
      Return -1
    ElseIf Action == 100
      Return 1
    ElseIf Action == 101
      Return 0
    EndIf
    Receipt = 1
    If Action == 1
      Receipt = PSQ.ApplySuccubusOutfitSelectionCore(PSQ.SuccubusOutfitSelection, OperationOwner, True) as Int
    ElseIf Action == 2
      Receipt = Self.ContinueAppearance("enter.outfit_resolve") as Int
    ElseIf Action == 3
      If TraceStageTimings
        SnapshotStart = Utility.GetCurrentRealTime()
      EndIf
      Bool[] Refusal = new Bool[1]
      If !PSQ.SaveEntryOutfitSnapshot(OperationOwner, True, Refusal)
        Receipt = -1
        If Refusal[0]
          Receipt = 0
        EndIf
      EndIf
      If TraceStageTimings
        GearDone = Utility.GetCurrentRealTime()
      EndIf
    ElseIf Action == 4
      PSQ.CaptureOriginalTransformHair(OperationOwner)
    ElseIf Action == 5
      Receipt = Self.ContinueAppearance("enter.equipment_snapshot") as Int
      If TraceStageTimings
        Debug.Trace("[PSQ-PERF] entry.snapshot_outer; owner=" + OperationOwner + "; equipmentAndGuard=" + (GearDone-SnapshotStart) + "; hairAndGuard=" + (Utility.GetCurrentRealTime()-GearDone))
      EndIf
    ElseIf Action == 6
      PSQ.EquipTransformPartsPhase(OperationOwner, True, True, Started)
    ElseIf Action == 7
      Receipt = Self.ContinueAppearance("enter.primary_equipment") as Int
    ElseIf Action == 8
      PSQ.ApplyTransformSlot52(OperationOwner, True)
    ElseIf Action == 9
      Receipt = Self.ContinueAppearance("enter.pre_equipment") as Int
    ElseIf Action == 10
      PSQ.SyncAWUWing()
    ElseIf Action == 11
      PSQ.EquipSelectedTransformParts(OperationOwner, True)
    ElseIf Action == 12
      Receipt = Self.ContinueAppearance("enter.equipment_apply") as Int
    EndIf
    Completed = Action
  EndWhile
  Return -1
EndFunction

; Each action runs one engine or compatibility operation. C++ chooses the next
; action from the current saved settings after the previous operation returns.
Int Function DriveAppearanceLook(Actor Target, Int Owner, Int Epoch, Int Step)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777237 && PSQAppearance.IsReady()
    Return Self.PumpTransformExecution26(Target,Owner,Epoch,0,Step,0.0)
  EndIf
  Bool Refresh = False
  Bool Result = False
  Float BuffStart
  Float ScaleStart
  Float EyesStart
  Float BodyStart
  Float SkinStart
  Float ColorStart
  Float SlotStart
  Float Started
  While True
    Int Next = PSQAppearance.AdvanceAppearanceLook(Target, PSQ, Owner, Epoch, Step, Result, Refresh)
    If Next < 0
      Return -1
    ElseIf Next == 100 || Next == 101
      Return Next - 100
    EndIf
    Refresh = Next >= 256
    If Refresh
      Next -= 256
    EndIf
    Step = Next
    Result = False
    If Step == 1
      PSQ.SyncRankMagicCostReduction()
    ElseIf Step == 2
      PSQ.SoundHenshinMoan.Play(Target)
      Self.BeginTransformVisual(Target, True)
      If IdleHenshin && Target.PlayIdle(IdleHenshin)
        Utility.Wait(0.25)
      EndIf
    ElseIf Step == 3
      If !Self.ContinueAppearance("enter.visual_after_primary")
        Return -1
      EndIf
    ElseIf Step == 4
      PSQ.StripTransformAccessories(Owner, True)
    ElseIf Step == 5
      If !Self.ContinueAppearance("enter.strip_accessories")
        Return -1
      EndIf
    ElseIf Step == 6
      PSQ.SetScaleSuccubus(Owner, True)
    ElseIf Step == 8
      If !psqracecompatibility.ShouldPreserveAppearance(Target) && psqracecompatibility.CanUseHeadPart(PSQ.PSQSuccubusEyes, Target.GetRace())
        ActorBase Base = Target.GetLeveledActorBase()
        HeadPart Eyes = PSQAppearance.ReadTransformHead(Base, False)
        If Eyes && PSQ.IsEquipmentRecoveryCurrent(Owner, True, Epoch)
          PSQ.OrgEyes = Eyes
          If PSQ.IsEquipmentRecoveryCurrent(Owner, True, Epoch)
            Target.ChangeHeadPart(PSQ.PSQSuccubusEyes)
          EndIf
        EndIf
      EndIf
    ElseIf Step == 9
      If TraceStageTimings
        Started = Utility.GetCurrentRealTime()
      EndIf
      PSQ.ApplyTransformBodyMorphs(False, Owner, True)
      If TraceStageTimings
        Debug.Trace("[PSQ-PERF] enter.body_request; seconds=" + (Utility.GetCurrentRealTime() - Started))
      EndIf
    ElseIf Step == 10
      If !Self.ContinueAppearance("enter.body_morphs")
        Return -1
      EndIf
    ElseIf Step == 11
      PSQ.ApplyTransformSkinColor(True, Owner, True)
    ElseIf Step == 12
      PSQ.ChangeBodyPaint(PSQ.GetEnergyRatio(), True)
    ElseIf Step == 13
      PSQ.ApplySelectedTransformHair(Owner, True)
    ElseIf Step == 14
      PSQ.ApplyTransformHairColor(True, Owner, True)
    ElseIf Step == 15
      If !Self.ContinueAppearance("enter.hair_and_tattoo")
        Return -1
      EndIf
    ElseIf Step == 31
      PSQ.SettleTransformEnergy()
    ElseIf Step == 32
      PSQ.SyncAWUWing()
      PSQ.ResetTransformEnergyClock()
      PSQ.SyncRankMagicCostReduction()
      Self.BeginTransformVisual(Target, False)
    ElseIf Step == 33
      If IdleDisHenshin && Target.PlayIdle(IdleDisHenshin)
        Utility.Wait(0.25)
      EndIf
    ElseIf Step == 34
      If !Self.ContinueAppearance("exit.visual_and_idle")
        Return -1
      EndIf
    ElseIf Step == 41
      If TraceStageTimings
        BuffStart = Utility.GetCurrentRealTime()
      EndIf
      PSQ.RemoveTransformBuffSafely(Owner, -1)
    ElseIf Step == 43
      If TraceStageTimings
        ScaleStart = Utility.GetCurrentRealTime()
      EndIf
      PSQ.SetScaleHuman(Owner, True)
    ElseIf Step == 44
      If TraceStageTimings
        EyesStart = Utility.GetCurrentRealTime()
      EndIf
      PSQ.RestoreOriginalPlayerEyes(Owner, True)
    ElseIf Step == 45
      If TraceStageTimings
        BodyStart = Utility.GetCurrentRealTime()
      EndIf
      PSQ.RestoreTransformBodyMorphs(False, Owner, True)
      If TraceStageTimings
        Debug.Trace("[PSQ-PERF] exit.body_request; seconds=" + (Utility.GetCurrentRealTime() - BodyStart))
      EndIf
    ElseIf Step == 46
      If TraceStageTimings
        SkinStart = Utility.GetCurrentRealTime()
        If BodyStart == 0.0
          BodyStart = SkinStart
        EndIf
      EndIf
      Result = PSQ.RestoreTransformSkinColor(Owner, True)
    ElseIf Step == 47
      If TraceStageTimings
        ColorStart = Utility.GetCurrentRealTime()
      EndIf
      Result = PSQ.RestoreOriginalPlayerHairColor(Owner, True)
    ElseIf Step == 48
      If TraceStageTimings
        SlotStart = Utility.GetCurrentRealTime()
      EndIf
      PSQ.ReleaseTransformSlot52(True, Owner, True)
    ElseIf Step == 49
      Float Done = 0.0
      If TraceStageTimings
        Done = Utility.GetCurrentRealTime()
      EndIf
      If !Self.ContinueAppearance("exit.body_hair_restore")
        Return -1
      EndIf
      If TraceStageTimings
        Debug.Trace("[PSQ-PERF] exit.appearance_times; owner=" + Owner + "; buffs=" + (ScaleStart-BuffStart) + "; scale=" + (EyesStart-ScaleStart) + "; eyes=" + (BodyStart-EyesStart) + "; body=" + (SkinStart-BodyStart) + "; skin=" + (ColorStart-SkinStart) + "; hairColor=" + (SlotStart-ColorStart) + "; slot52=" + (Done-SlotStart))
      EndIf
    ElseIf Step == 61
      If TraceStageTimings
        Started = Utility.GetCurrentRealTime()
      EndIf
      PSQ.RestoreTransformHair(Owner, True)
    ElseIf Step == 62
      If !Self.ContinueAppearance("exit.model_refresh")
        Return -1
      EndIf
      If TraceStageTimings
        Debug.Trace("[PSQ-PERF] exit.hair_restore; owner=" + Owner + "; seconds=" + (Utility.GetCurrentRealTime()-Started))
      EndIf
    Else
      Return -1
    EndIf
  EndWhile
  Return -1
EndFunction

Bool Function DriveTransformFinish(Actor Target, Int Owner, Int Epoch, Int Step, Bool RefreshNodes, Bool RefreshBody)
  Float Started
  While True
    Step = PSQAppearance.AdvanceTransformFinish(Target,PSQ,Owner,Epoch,Step,RefreshNodes,RefreshBody)
    If Step == 0
      Return True
    ElseIf Step < 0
      Return False
    ElseIf Step == 1
      PSQ.ResetTransformEnergyClock()
    ElseIf Step == 2
      PSQ.ChangeSatiationEnergy(-20.0,False)
    ElseIf Step == 3
      If !Self.ContinueAppearance("enter.energy_charge")
        Return False
      EndIf
    ElseIf Step == 4
      If SKSE.GetPluginVersion("PSQ Appearance") >= 16777239
        If !PSQ.RunEntryStatStage(Owner,Epoch,False)
          Return False
        EndIf
        Step = 6
      Else
        PSQ.UpdateTransformBuff(True, Owner)
      EndIf
    ElseIf Step == 5
      If !Self.ContinueAppearance("enter.attribute_bonus")
        Return False
      EndIf
    ElseIf Step == 6
      PSQ.BufferTransformEntryHealth(Owner)
    ElseIf Step == 7
      If !Self.ContinueAppearance("enter.attribute_prime")
        Return False
      EndIf
    ElseIf Step == 21
      PSQ.SuccubusFormFearSpell.Cast(Target,None)
    ElseIf Step == 22
      Target.AddToFaction(PSQ.SuccubusFoeFaction)
      If !PSQ.IsEquipmentRecoveryCurrent(Owner,True,Epoch)
        Return False
      EndIf
      Target.SetAttackActorOnSight(True)
    ElseIf Step == 23
      Float Rate = PSQAppearance.TransformationBoosterRate(PSQ.SuccubusEXP.GetValue())
      Int Applied = PSQAppearance.ApplyTransformBooster(Target,PSQ,Target.GetRace(),Owner,Epoch,PSQ.SuccubusSpellBoostPerk,Rate)
      If Applied < 0
        Return False
      ElseIf Applied == 0
        Int Entry = 0
        While Entry <= 6 && PSQ.IsEquipmentRecoveryCurrent(Owner,True,Epoch)
          PSQ.SuccubusSpellBoostPerk.SetNthEntryValue(Entry,1,Rate)
          Entry += 1
        EndWhile
      EndIf
    ElseIf Step == 24
      PSQ.TransformBooster.SetValue(1.0)
    ElseIf Step == 25
      If !Self.ContinueAppearance("enter.pre_model_refresh")
        Return False
      EndIf
    ElseIf Step == 26
      If TraceStageTimings
        Started = Utility.GetCurrentRealTime()
      EndIf
      PSQ.RefreshEquippedTransformBody(Owner,True)
      If TraceStageTimings
        Debug.Trace("[PSQ-PERF] enter.body_settle; seconds=" + (Utility.GetCurrentRealTime()-Started))
      EndIf
    ElseIf Step == 27
      Target.QueueNiNodeUpdate()
    ElseIf Step == 28
      If !Self.ContinueAppearance("enter.model_refresh")
        Return False
      EndIf
    ElseIf Step == 29
      If !PSQ.RefreshTransformSatiety29(Owner,Epoch)
        Return False
      EndIf
    ElseIf Step == 30
      PSQ.ApplySelectedSuccubusEyes(Owner,True)
    ElseIf Step == 31
      If !Self.ContinueAppearance("enter.final_effects")
        Return False
      EndIf
    ElseIf Step == 32
      Self.CompleteTransformVisual(Target,True)
    ElseIf Step == 33
      If !Self.ContinueAppearance("enter.visual_complete")
        Return False
      EndIf
    ElseIf Step == 34
      If SKSE.GetPluginVersion("PSQ Appearance") >= 16777239
        If !PSQ.RunEntryStatStage(Owner,Epoch,True)
          Return False
        EndIf
      Else
        PSQ.RefillTransformAttributes(Owner,True)
      EndIf
    ElseIf Step == 35
      If !Self.ContinueAppearance("enter.attribute_refill")
        Return False
      EndIf
    ElseIf Step == 51
      If SKSE.GetPluginVersion("PSQ Appearance") >= 16777240
        PSQ.SyncPlayerAppearanceRace()
        Float RestoreStarted
        If PSQ.EnableEquipmentDiagnostics
          RestoreStarted = Utility.GetCurrentRealTime()
        EndIf
        Int RestoreResult = PSQ.RunAppearanceTask(None,Owner,Epoch,True,6,False,0.0)
        If PSQ.EnableEquipmentDiagnostics
          Debug.Trace("[PSQ-PERF] exit.return_total owner=" + Owner + "; outcome=" + RestoreResult + "; seconds=" + (Utility.GetCurrentRealTime()-RestoreStarted))
        EndIf
        If RestoreResult != 1 && RestoreResult != 3
          Return False
        EndIf
      Else
        PSQ.RestoreTransformEquipment(Owner,True)
      EndIf
    ElseIf Step == 52
      PSQ.TransformBooster.SetValue(0.0)
    ElseIf Step == 53
      Target.RemoveFromFaction(PSQ.SuccubusFoeFaction)
      If !PSQ.IsEquipmentRecoveryCurrent(Owner,True,Epoch)
        Return False
      EndIf
      Target.SetAttackActorOnSight(False)
    ElseIf Step == 54
      If !Self.ContinueAppearance("exit.equipment_restore")
        Return False
      EndIf
    ElseIf Step == 61
      If !PSQ.ClearRestoredEquipmentFields(Owner,True,Epoch)
        Return False
      EndIf
    ElseIf Step == 62
      If TraceStageTimings
        Started = Utility.GetCurrentRealTime()
      EndIf
      PSQ.RefreshEquippedTransformBody(Owner,True)
      If TraceStageTimings
        Debug.Trace("[PSQ-PERF] exit.body_settle; seconds=" + (Utility.GetCurrentRealTime()-Started))
      EndIf
    ElseIf Step == 63
      Target.QueueNiNodeUpdate()
    ElseIf Step == 71
      If !PSQ.RefreshTransformSatiety29(Owner,Epoch)
        Return False
      EndIf
    ElseIf Step == 72
      If !Self.ContinueAppearance("exit.final_effects")
        Return False
      EndIf
    ElseIf Step == 73
      Self.CompleteTransformVisual(Target,False)
    Else
      Return False
    EndIf
  EndWhile
  Return False
EndFunction

Int Function ApplyFinishAction31(Actor Target, Int Owner, Int Epoch, Int Step)
    If Step == 3
      If !Self.ContinueAppearance("enter.energy_charge")
        Return -1
      EndIf
    ElseIf Step == 5
      If !Self.ContinueAppearance("enter.attribute_bonus")
        Return -1
      EndIf
    ElseIf Step == 6
      PSQ.BufferTransformEntryHealth(Owner)
    ElseIf Step == 7
      If !Self.ContinueAppearance("enter.attribute_prime")
        Return -1
      EndIf
    ElseIf Step == 21
      PSQ.SuccubusFormFearSpell.Cast(Target,None)
    ElseIf Step == 22
      Target.AddToFaction(PSQ.SuccubusFoeFaction)
      If !PSQ.IsEquipmentRecoveryCurrent(Owner,True,Epoch)
        Return -1
      EndIf
      Target.SetAttackActorOnSight(True)
    ElseIf Step == 23
      Float Rate = PSQAppearance.TransformationBoosterRate(PSQ.SuccubusEXP.GetValue())
      Int Applied = PSQAppearance.ApplyTransformBooster(Target,PSQ,Target.GetRace(),Owner,Epoch,PSQ.SuccubusSpellBoostPerk,Rate)
      If Applied < 0
        Return -1
      ElseIf Applied == 0
        Int Entry = 0
        While Entry <= 6 && PSQ.IsEquipmentRecoveryCurrent(Owner,True,Epoch)
          PSQ.SuccubusSpellBoostPerk.SetNthEntryValue(Entry,1,Rate)
          Entry += 1
        EndWhile
      EndIf
    ElseIf Step == 24
      PSQ.TransformBooster.SetValue(1.0)
    ElseIf Step == 25
      If !Self.ContinueAppearance("enter.pre_model_refresh")
        Return -1
      EndIf
    ElseIf Step == 28
      If !Self.ContinueAppearance("enter.model_refresh")
        Return -1
      EndIf
    ElseIf Step == 31
      If !Self.ContinueAppearance("enter.final_effects")
        Return -1
      EndIf
    ElseIf Step == 33
      If !Self.ContinueAppearance("enter.visual_complete")
        Return -1
      EndIf
    ElseIf Step == 35
      If !Self.ContinueAppearance("enter.attribute_refill")
        Return -1
      EndIf
    ElseIf Step == 51
      If SKSE.GetPluginVersion("PSQ Appearance") >= 16777240
        PSQ.SyncPlayerAppearanceRace()
        Float RestoreStarted
        If PSQ.EnableEquipmentDiagnostics
          RestoreStarted = Utility.GetCurrentRealTime()
        EndIf
        Int RestoreResult = PSQ.RunAppearanceTask(None,Owner,Epoch,True,6,False,0.0)
        If PSQ.EnableEquipmentDiagnostics
          Debug.Trace("[PSQ-PERF] exit.return_total owner=" + Owner + "; outcome=" + RestoreResult + "; seconds=" + (Utility.GetCurrentRealTime()-RestoreStarted))
        EndIf
        If RestoreResult != 1 && RestoreResult != 3
          Return -1
        EndIf
      Else
        PSQ.RestoreTransformEquipment(Owner,True)
      EndIf
    ElseIf Step == 52
      PSQ.TransformBooster.SetValue(0.0)
    ElseIf Step == 53
      Target.RemoveFromFaction(PSQ.SuccubusFoeFaction)
      If !PSQ.IsEquipmentRecoveryCurrent(Owner,True,Epoch)
        Return -1
      EndIf
      Target.SetAttackActorOnSight(False)
    ElseIf Step == 54
      If !Self.ContinueAppearance("exit.equipment_restore")
        Return -1
      EndIf
    ElseIf Step == 72
      If !Self.ContinueAppearance("exit.final_effects")
        Return -1
      EndIf
    Else
      Return -1
    EndIf
  Return Step
EndFunction

Int Function PumpTransformExecution(Actor Target, Int Owner, Int Epoch, Int Group, Int Start, Float Started)
  Int[] Cursor
  While True
    Cursor = PSQAppearance.ExecuteTransform(Self,Target,PSQ,Owner,Epoch,Group,Start,Started,Cursor)
    If !Cursor
      Return -1
    ElseIf Cursor.Length == 1
      Return Cursor[0]
    EndIf
    Utility.WaitMenuMode(0.03)
  EndWhile
  Return -1
EndFunction

Int Function PumpTransformExecution26(Actor Target, Int Owner, Int Epoch, Int Group, Int Start, Float Started)
  If SKSE.GetPluginVersion("PSQ Appearance") < 16777242
    Return Self.PumpTransformExecution(Target,Owner,Epoch,Group,Start,Started)
  EndIf
  Int[] Cursor
  Int PreviousTicket
  Int ReadyCount
  Int FirstCount
  Int WaitCount
  While True
    Cursor = PSQAppearance.ExecuteTransform(Self,Target,PSQ,Owner,Epoch,Group,Start,Started,Cursor)
    If !Cursor
      Return -1
    ElseIf Cursor.Length == 1
      If TraceStageTimings
        Debug.Trace("[PSQ-PERF] pump26 owner=" + Owner + " epoch=" + Epoch + " group=" + Group + " start=" + Start + " ready=" + ReadyCount + " first=" + FirstCount + " waits=" + WaitCount + " result=" + Cursor[0])
      EndIf
      Return Cursor[0]
    EndIf
    If Cursor.Length == 7
      Int Ticket = Cursor[4]
      Int Decision = PSQAppearance.TransformPumpWait26(Ticket,PreviousTicket,Owner,Epoch)
      PreviousTicket = Ticket
      If Decision == 2
        WaitCount += 1
        Utility.WaitMenuMode(0.03)
      ElseIf Decision == 1
        FirstCount += 1
      Else
        ReadyCount += 1
      EndIf
    Else
      Utility.WaitMenuMode(0.03)
    EndIf
  EndWhile
  Return -1
EndFunction
