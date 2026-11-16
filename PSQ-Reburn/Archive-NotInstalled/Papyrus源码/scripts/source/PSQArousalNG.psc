ScriptName PSQArousalNG hidden

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Event onBeginState()
{ Event received when this state is switched to }
  ; Empty function
EndEvent

Event onEndState()
{ Event received when this state is switched away from }
  ; Empty function
EndEvent

Float Function GetArousal(Actor Target) Global
  If Target == None
    Return -1.0
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    Float[] Reading = PSQAppearance.ReadNGArousal33(Target)
    If Reading && Reading.Length == 1
      Return Reading[0]
    EndIf
  EndIf
  Return sloangnative.GetArousal(Target)
EndFunction

Bool Function ModifyArousal(Actor Target, Float Amount) Global
  If Target == None
    Return False
  EndIf
  sloangnative.ModArousal(Target, Amount)
  Return True
EndFunction
