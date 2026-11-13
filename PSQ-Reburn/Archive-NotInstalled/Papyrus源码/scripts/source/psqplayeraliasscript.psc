ScriptName psqplayeraliasscript Extends ReferenceAlias

;-- Variables ---------------------------------------
Bool BodyMorphRefreshForce = True
Float BodyMorphIgnoreNodeUntil = 0.0
Bool BodyMorphRefreshQueued = False
Int BodyMorphRefreshRetries = 0

;-- Properties --------------------------------------
playersuccubusquestscript Property PSQ Auto

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Event OnSpellCast(Form akSpell)
  If PSQ.EnableEnergyConsumingBySuccubusSpell
    If akSpell.HasKeyword(PSQ.SuccubusSpell) && !akSpell.HasKeyword(PSQ.SuccubusSpellNoConsume)
      Spell UsedSpell = akSpell as Spell
      Float Cost = UsedSpell.GetEffectiveMagickaCost(PSQ.PlayerRef) as Float / 2.0
      If PSQ.SuccubusEnergy.GetValue() < Cost
        PSQ.PlayerRef.DamageActorValue("Health", Cost - PSQ.SuccubusEnergy.GetValue())
        Debug.Notification("$PSQ_EnergyDepletionNotice")
      EndIf
      PSQ.Satiety(-Cost)
      If PSQ.EnableSpellCastingNotification
        PSQ.SatietyNotification(-Cost, True)
      EndIf
    EndIf
  EndIf
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
  If PSQ != None && (akBaseObject as Armor) as Bool ; #DEBUG_LINE_NO:6
    If Self.DeferSwapEquipmentReactions()
      Return
    EndIf
    PSQ.QueueTRXFutaClothingForArmor(PSQ.PlayerRef, akBaseObject as Armor) ; #DEBUG_LINE_NO:7
    PSQ.RefreshWingflightState() ; #DEBUG_LINE_NO:8
    Self.QueueEquipmentBodyMorphRefreshForEquipment() ; #DEBUG_LINE_NO:9
  EndIf
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
  If PSQ != None && (akBaseObject as Armor) as Bool ; #DEBUG_LINE_NO:13
    If Self.DeferSwapEquipmentReactions()
      Return
    EndIf
    PSQ.QueueTRXFutaClothingForArmor(PSQ.PlayerRef, akBaseObject as Armor) ; #DEBUG_LINE_NO:14
    PSQ.RefreshWingflightState() ; #DEBUG_LINE_NO:15
    Self.QueueEquipmentBodyMorphRefreshForEquipment() ; #DEBUG_LINE_NO:16
  EndIf
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSrc, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
  If PSQ.PlayerIsSuccubus.GetValue() == 1.0 && PSQ.EnablePSQRape
    Actor Aggressor = akAggressor as Actor
    If Self.IsRaper(Aggressor) && Self.RapeIncidentOccurrence()
      If !PSQ.PlayerRef.HasKeywordString("SexLabActive")
        Debug.SendAnimationEvent(PSQ.PlayerRef as ObjectReference, "BleedoutStart")
        Aggressor.AddToFaction(PSQ.PSQRapeNoAttackFaction)
        PSQ.PlayerRef.AddToFaction(PSQ.PSQRapeNoAttackFaction)
        Actor[] SexActors = new Actor[2]
        SexActors[0] = PSQ.PlayerRef
        SexActors[1] = Aggressor
        sslbaseanimation[] anims = PSQ.SexLab.GetAnimationsByType(2, -1, -1, -1, True, True)
        PSQ.SexLab.StartSex(SexActors, anims, PSQ.PlayerRef, None, True, "")
      EndIf
    EndIf
  EndIf
EndEvent

Bool Function IsRaper(Actor Target)
  If PSQ.SexLab.ValidateActor(Target) == 1
    If Target.HasMagicEffectWithKeyword(PSQ.MagicInfluence) || PSQ.GetActorArousal(Target) >= PSQ.RapeArousalThreshold
      Return True
    EndIf
  EndIf
  Return False
EndFunction

Bool Function RapeIncidentOccurrence()
  If (Utility.RandomInt(1, 100) as Float <= PSQ.RapeChance) && PSQ.PlayerRef.GetActorValuePercentage("Health") * 100.0 <= PSQ.RapeHealthThreshold
    Return True
  EndIf
  Return False
EndFunction

Event OnLoad()
  Self.RegisterForNiNodeUpdate()
  Self.QueueEquipmentBodyMorphRefresh()
  If PSQ != None
    PSQ.InvalidateTattooPresentation()
  EndIf
EndEvent

Event OnCellAttach()
  Self.RegisterForNiNodeUpdate()
  Self.QueueEquipmentBodyMorphRefresh()
  If PSQ != None
    PSQ.InvalidateTattooPresentation()
  EndIf
EndEvent

Event OnRaceSwitchComplete()
  If PSQ != None
    PSQ.SyncPlayerAppearanceRace()
  EndIf
EndEvent

Event OnInit()
  Self.RegisterForNiNodeUpdate()
EndEvent

Event OnPlayerLoadGame()
  If PSQ != None
    PSQ.BeginPSQLoadSession()
  EndIf
  Self.RegisterForNiNodeUpdate()
  BodyMorphRefreshQueued = False
  BodyMorphRefreshRetries = 0
  BodyMorphIgnoreNodeUntil = 0.0
  Self.QueueEquipmentBodyMorphRefresh()
  If PSQ != None
    PSQ.PSQReload()
  EndIf
EndEvent

Function OnNiNodeUpdate(ObjectReference ActorRef)
  If PSQ != None && (ActorRef == PSQ.PlayerRef as ObjectReference) && Utility.GetCurrentRealTime() >= BodyMorphIgnoreNodeUntil ; #DEBUG_LINE_NO:130
    If Self.DeferSwapEquipmentReactions()
      Return
    EndIf
    Self.QueueEquipmentBodyMorphRefresh() ; #DEBUG_LINE_NO:131
  EndIf
EndFunction

Function QueueEquipmentBodyMorphRefresh()
  ; Load/cell/NiNode and all old callers retain the forced legacy refresh.
  BodyMorphRefreshForce = True
  Self.QueueEquipmentBodyMorphRefreshCore()
EndFunction

Function QueueEquipmentBodyMorphRefreshForEquipment()
  ; A force already queued by 3D or foreign changes always wins.
  If !BodyMorphRefreshQueued
    BodyMorphRefreshForce = False
  EndIf
  Self.QueueEquipmentBodyMorphRefreshCore()
EndFunction

Function QueueEquipmentBodyMorphRefreshCore()
  If PSQ == None || BodyMorphRefreshQueued
    Return
  EndIf
  BodyMorphRefreshQueued = True
  BodyMorphRefreshRetries = 0
  Self.RegisterForSingleUpdate(0.25)
EndFunction

Event OnUpdate()
  If !BodyMorphRefreshQueued
    Return 
  EndIf
  BodyMorphRefreshQueued = False
  If PSQ == None
    Return 
  EndIf
  BodyMorphIgnoreNodeUntil = Utility.GetCurrentRealTime() + 1.0
  Bool Complete
  If BodyMorphRefreshForce
    Complete = PSQ.RefreshEquipmentBodyMorphs()
  Else
    Complete = PSQ.RefreshEquipmentBodyMorphsForEquipment()
  EndIf
  If !Complete && BodyMorphRefreshRetries < 5
    BodyMorphRefreshRetries += 1
    BodyMorphRefreshQueued = True
    Self.RegisterForSingleUpdate(0.5)
  Else
    If !Complete && !BodyMorphRefreshForce
      PSQ.RefreshEquipmentBodyMorphs()
    EndIf
    BodyMorphRefreshRetries = 0
    BodyMorphRefreshForce = True
  EndIf
EndEvent

Bool Function DeferSwapEquipmentReactions()
  If PSQ != None && (PSQ.AppearanceEditBusy || PSQ.IsHenshinchu)
    Self.RegisterForModEvent("PSQ_EquipmentSwapComplete", "OnPSQEquipmentSwapComplete")
    Return True
  EndIf
  Return False
EndFunction

Function OnPSQEquipmentSwapComplete(String EventName, String Argument, Float Number, Form Sender)
  If PSQ == None || Sender != PSQ as Form || Number as Int != PSQ.GetBCNGFutaLoadEpoch() || Argument as Int != PSQ.AppearanceOperationId
    Return
  EndIf
  Self.QueueEquipmentBodyMorphRefreshForEquipment()
EndFunction
