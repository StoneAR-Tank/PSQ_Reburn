ScriptName succubusheshinnscript Extends ActiveMagicEffect

;-- Variables ---------------------------------------
Bool NativeMotionStarted = False
Int OperationOwner = 0
Armor OrgArmorTemp
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
  If akCaster != PSQ.PlayerRef || !PSQ.BeginAppearanceEdit()
    Return 
  EndIf
  OperationOwner = PSQ.AppearanceOperationId
  Float AppearanceStarted = Utility.GetCurrentRealTime()
  TransformStageClock = AppearanceStarted
  If !PSQ.IsHenshined
    PSQ.AppearanceTransformDirection = 1
    PSQ.AppearanceSnapshotReady = False
    storageutil.SetIntValue(PSQ.PlayerRef as Form, "PSQ_SuccubusON", 1)
    Self.Henshin(akCaster)
  Else
    storageutil.SetIntValue(PSQ.PlayerRef as Form, "PSQ_SuccubusON", 0)
    PSQ.AppearanceTransformDirection = 2
    PSQ.AppearanceSnapshotReady = True
    Self.DisHenshin(akCaster)
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  storageutil.SetIntValue(PSQ.PlayerRef as Form, "PSQ_SuccubusON", PSQ.IsHenshined as Int)
  Debug.Trace(("[PSQ] Transform appearance finished; transformed=" + PSQ.IsHenshined as String) + ", scriptSeconds=" + (Utility.GetCurrentRealTime() - AppearanceStarted) as String, 0)
  PSQ.EndAppearanceEdit(OperationOwner)
EndEvent

Function Henshin(Actor Succu)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  Bool RefreshNodes = False
  If !PSQ.ApplySuccubusOutfitSelectionCore(PSQ.SuccubusOutfitSelection, OperationOwner, True)
    Return 
  EndIf
  If !Self.ContinueAppearance("enter.outfit_resolve")
    Return 
  EndIf
  if !PSQ.SaveTransformEquipment(OperationOwner, True)
    return
  endif
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  PSQ.CaptureOriginalTransformHair(OperationOwner)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return
  EndIf
  PSQ.AppearanceSnapshotReady = True
  If !Self.ContinueAppearance("enter.equipment_snapshot")
    Return 
  EndIf
  Int i = 0
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  PSQ.IsHenshinchu = True
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  PSQ.IsHenshined = True
  PSQ.ResetTransformEnergyClock()
  PSQ.SyncRankMagicCostReduction()
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  Int HenshinMoan = PSQ.SoundHenshinMoan.Play(Succu as ObjectReference)
  Self.BeginTransformVisual(Succu, True)
  Bool IdleStarted = False
  If IdleHenshin != None
    IdleStarted = Succu.PlayIdle(IdleHenshin)
  EndIf
  PSQ.Satiety(-20.0)
  If IdleStarted
    Utility.Wait(0.25)
  EndIf
  If !Self.ContinueAppearance("enter.visual_and_energy")
    Return 
  EndIf
  PSQ.UpdateTransformBuff(True, OperationOwner)
  If !Self.ContinueAppearance("enter.attribute_bonus")
    Return
  EndIf
  PSQ.BufferTransformEntryHealth(OperationOwner)
  If !Self.ContinueAppearance("enter.attribute_prime")
    Return
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  PSQ.StripTransformAccessories(OperationOwner, True)
  If !Self.ContinueAppearance("enter.strip_accessories")
    Return 
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  PSQ.OrgHairColor = None
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  PSQ.SetScaleSuccubus(OperationOwner, True)
  If PSQ.CanWalkOnTheWater
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Succu.AddSpell(PSQ.SuccubusWaterWalking, False)
  EndIf
  If PSQ.HenshinEyes && !psqracecompatibility.ShouldPreserveAppearance(Succu) && psqracecompatibility.CanUseHeadPart(PSQ.PSQSuccubusEyes, Succu.GetRace())
    ActorBase EyeBase = Succu.GetLeveledActorBase()
    Int Eye = EyeBase.GetNumHeadParts()
    i = 0
    While i < Eye
      headpart EyePart = EyeBase.GetNthHeadPart(i)
      If EyePart != None && EyePart.GetType() == 2
        If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
          Return 
        EndIf
        PSQ.OrgEyes = EyePart
        i = Eye
      EndIf
      i += 1
    EndWhile
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Succu.ChangeHeadPart(PSQ.PSQSuccubusEyes)
  EndIf
  If PSQ.HenshinBody
    PSQ.ApplyTransformBodyMorphs(False, OperationOwner, True)
  EndIf
  If !Self.ContinueAppearance("enter.body_morphs")
    Return 
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
    Return 
  EndIf
  PSQ.ApplySelectedTransformHair(OperationOwner, True)
  If PSQ.HenshinHairColor
    PSQ.ApplyTransformHairColor(True, OperationOwner, True)
    If PSQ.OrgHairColor != None
      RefreshNodes = True
    EndIf
  EndIf
  If !Self.ContinueAppearance("enter.hair_and_tattoo")
    Return 
  EndIf
  PSQ.ApplyTransformSlot52(OperationOwner, True)
  If !Self.ContinueAppearance("enter.pre_equipment")
    Return 
  EndIf
  PSQ.EquipSelectedTransformParts(OperationOwner, True)
  If !Self.ContinueAppearance("enter.equipment_apply")
    Return 
  EndIf
  If PSQ.HenshinFear
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    PSQ.SuccubusFormFearSpell.Cast(Succu as ObjectReference, None)
  EndIf
  If PSQ.HenshinIsCrime
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Succu.AddToFaction(PSQ.SuccubusFoeFaction)
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Succu.SetAttackActorOnSight(True)
  EndIf
  Float BoosterRate = Math.Sqrt(Math.Sqrt(PSQ.SuccubusEXP.GetValue())) / 2.0
  If BoosterRate < 1.0
    BoosterRate = 1.0
  EndIf
  i = 0
  While i <= 6
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    PSQ.SuccubusSpellBoostPerk.SetNthEntryValue(i, 1, BoosterRate)
    i += 1
  EndWhile
  If PSQ.EnableSuccubusSpellBooster
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    PSQ.TransformBooster.SetValue(1.0)
  EndIf
  If !Self.ContinueAppearance("enter.pre_model_refresh")
    Return 
  EndIf
  If PSQ.HenshinBody
    PSQ.RefreshEquippedTransformBody(OperationOwner, True)
  EndIf
  If RefreshNodes
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Succu.QueueNiNodeUpdate()
  EndIf
  If !Self.ContinueAppearance("enter.model_refresh")
    Return 
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  PSQ.IsHenshinchu = False
  PSQ.Satiety(0.0)
  PSQ.ApplySelectedSuccubusEyes(OperationOwner, True)
  If !Self.ContinueAppearance("enter.final_effects")
    Return 
  EndIf
  Self.CompleteTransformVisual(Succu, True)
  If !Self.ContinueAppearance("enter.visual_complete")
    Return
  EndIf
  PSQ.RefillTransformAttributes(OperationOwner, True)
  If !Self.ContinueAppearance("enter.attribute_refill")
    Return
  EndIf
EndFunction

Function DisHenshin(Actor Succu)
  Int EntryLoad = PSQ.GetPSQLoadEpoch()
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  Bool RefreshNodes = False
  Bool RefreshBody = PSQ.HenshinBody
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  PSQ.IsHenshinchu = True
  If !PSQ.AppearanceRecoveryInProgress
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    PSQ.SettleTransformEnergy()
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  PSQ.IsHenshined = False
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
    Return 
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  PSQ.RemoveTransformBuffSafely(OperationOwner, -1)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  Succu.RemoveSpell(PSQ.SuccubusWaterWalking)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  Succu.RemoveSpell(PSQ.SuccubusArmorSpell)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  PSQ.SetScaleHuman(OperationOwner, True)
  PSQ.RestoreOriginalPlayerEyes(OperationOwner, True)
  If PSQ.HenshinBody
    PSQ.RestoreTransformBodyMorphs(False, OperationOwner, True)
  EndIf
  If PSQ.RestoreTransformSkinColor(OperationOwner, True)
    If PSQ.OrgHairColor == None
      RefreshNodes = True
    EndIf
  EndIf
  If PSQ.RestoreOriginalPlayerHairColor(OperationOwner, True)
    RefreshNodes = True
  EndIf
  PSQ.ReleaseTransformSlot52(True, OperationOwner, True)
  If !Self.ContinueAppearance("exit.body_hair_restore")
    Return 
  EndIf
  PSQ.RestoreTransformEquipment(OperationOwner, True)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  PSQ.TransformBooster.SetValue(0.0)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  Succu.RemoveFromFaction(PSQ.SuccubusFoeFaction)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  Succu.SetAttackActorOnSight(False)
  If !Self.ContinueAppearance("exit.equipment_restore")
    Return 
  EndIf
  If !PSQ.ClearRestoredEquipmentFields(OperationOwner, True, EntryLoad)
    Return
  EndIf
  If RefreshBody
    PSQ.RefreshEquippedTransformBody(OperationOwner, True)
  EndIf
  If RefreshNodes
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Succu.QueueNiNodeUpdate()
  EndIf
  PSQ.RestoreTransformHair(OperationOwner, True)
  If !Self.ContinueAppearance("exit.model_refresh")
    Return 
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  PSQ.IsHenshinchu = False
  PSQ.Satiety(0.0)
  If !Self.ContinueAppearance("exit.final_effects")
    Return 
  EndIf
  Self.CompleteTransformVisual(Succu, False)
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
  If TransformVisualRank == 1
    Return Game.GetFormFromFile(41606 + Phase, "PSQ PlayerSuccubusQuest.esm") as EffectShader
  EndIf
  Return Game.GetFormFromFile(41608 + (TransformVisualRank - 2) * 2 + Phase, "PSQ PlayerSuccubusQuest.esm") as EffectShader
EndFunction

Function BeginTransformVisual(Actor Target, Bool Entering)
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
    BodyGlow.Stop(Target as ObjectReference)
  EndIf
  NativeMotionStarted = Self.BeginOriginalMotion(Target, Entering)
  TransformVisualRank = PSQ.SuccubusRank.GetValueInt()
  If TransformVisualRank < 1
    TransformVisualRank = 1
  ElseIf TransformVisualRank > 10
    TransformVisualRank = 10
  EndIf
  EffectShader Purple = Self.GetTransformVisual(0)
  EffectShader Pink = Self.GetTransformVisual(1)
  If Purple == None || Pink == None || Target == None
    Return 
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  Purple.Stop(Target as ObjectReference)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return 
  EndIf
  Pink.Stop(Target as ObjectReference)
  If Entering
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Purple.Play(Target as ObjectReference, 120.0)
  Else
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Pink.Play(Target as ObjectReference, 0.649999976 + ((TransformVisualRank - 1) as Float * 0.035))
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Purple.Play(Target as ObjectReference, 120.0)
  EndIf
EndFunction

Function CompleteTransformVisual(Actor Target, Bool Entering)
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
  If Purple != None
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Purple.Stop(Target as ObjectReference)
  EndIf
  If Pink != None
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return 
    EndIf
    Pink.Stop(Target as ObjectReference)
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
    Spell Pulse = Game.GetFormFromFile(41636 + TransformVisualRank - 1, "PSQ PlayerSuccubusQuest.esm") as Spell
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
    Purple.Play(Target as ObjectReference, 0.449999988 + ((TransformVisualRank - 1) as Float * 0.025))
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
  Motion.Play(Target as ObjectReference, 120.0, None)
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
  VisualEffect Start = Game.GetFormFromFile(StartID, "PSQ PlayerSuccubusQuest.esm") as VisualEffect
  VisualEffect Finish = Game.GetFormFromFile(FinishID, "PSQ PlayerSuccubusQuest.esm") as VisualEffect
  If Start != None
    If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
      Return False
    EndIf
    Start.Stop(Target as ObjectReference)
  EndIf
  If Finish == None
    Debug.Trace("[PSQFX] Short finish record unavailable; no ritual replay requested", 1)
    Return True
  EndIf
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  Finish.Stop(Target as ObjectReference)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  Finish.Play(Target as ObjectReference, 2.0, None)
  Debug.Trace("[PSQFX] Short finish played once; entering=" + Entering as String, 0)
  Return True
EndFunction

Function TraceTransformStage(String Stage)
  Float Now = Utility.GetCurrentRealTime()
  Debug.Trace("[PSQ-PERF] " + Stage + "; seconds=" + (Now - TransformStageClock) as String, 0)
  TransformStageClock = Now
EndFunction

EffectShader Function GetTransformBodyPinkShader()
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
  BodyGlow.Stop(Target as ObjectReference)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return False
  EndIf
  BodyGlow.Play(Target as ObjectReference, 6.0)
  Debug.Trace("[PSQFX] Full-body pink glow requested once; seconds=6", 0)
  Return True
EndFunction

Bool Function ContinueAppearance(String Stage)
  If !PSQ.TouchAppearanceOperation(OperationOwner, Stage)
    Return False
  EndIf
  Self.TraceTransformStage(Stage)
  Return True
EndFunction

Function StopInterruptedTransformVisuals(Actor Target)
  If !PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Return
  EndIf
  If Target == None || !Game.IsPluginInstalled("PSQ PlayerSuccubusQuest.esm")
    Return
  EndIf
  Self.StopRitualMotions(Target, 0)
  EffectShader Glow = Self.GetTransformBodyPinkShader()
  If Glow != None && PSQ.IsAppearanceOperationCurrent(OperationOwner, True)
    Glow.Stop(Target as ObjectReference)
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
      Motion.Stop(Target as ObjectReference)
      If ID == RequestedID
        Requested = Motion
      EndIf
    EndIf
    i += 1
  EndWhile
  Return Requested
EndFunction
