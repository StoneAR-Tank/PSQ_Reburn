Scriptname PSQPinkChainRouter Extends ActiveMagicEffect

Spell Property DamagePayload Auto
Faction Property ThrallFaction Auto
Faction Property CurrentFollowerFaction Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
  If !akTarget || !akCaster || akTarget.IsDead()
    Return
  EndIf
  If IsFriendlyRecipient(akTarget, akCaster)
    akTarget.RestoreActorValue("Health", 96.0)
  ElseIf DamagePayload
    ; Apply secondary hostile effects to this recipient without launching another chain.
    DamagePayload.Cast(akCaster, akTarget)
  EndIf
EndEvent

Bool Function IsFriendlyRecipient(Actor Recipient, Actor Caster)
  If Recipient == Caster || !Recipient.IsHostileToActor(Caster)
    Return True
  EndIf
  If Caster == Game.GetPlayer()
    Return Recipient.IsPlayerTeammate() || Recipient.IsInFaction(CurrentFollowerFaction) || Recipient.IsInFaction(ThrallFaction)
  EndIf
  Return False
EndFunction
