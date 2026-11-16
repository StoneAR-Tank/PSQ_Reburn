Scriptname PSQArousalOSL Hidden

; Only the shared OSL API is referenced by this adapter. The optional modern
; SLA-mode API stays in a separate PSQ script and is never called on OSL 2.3.
Bool Function IsAvailable() Global
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    Return PSQAppearance.OSLVersion33() >= 0
  EndIf
    Return Game.GetModByName("OSLAroused.esp") != 255 && SKSE.GetPluginVersion("OSLAroused") >= 0
EndFunction

Bool Function HasModernRateAPI() Global
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777249
    Return PSQAppearance.OSLVersion33() >= 0x02090030
  EndIf
    ; CommonLib REL::Version::pack: 2.9.3.0 = 0x02090030, not 0x02090300.
    ; The upstream 2.9.3 interface explicitly declares both modern functions.
    Return IsAvailable() && SKSE.GetPluginVersion("OSLAroused") >= 0x02090030
EndFunction

Int Function GetCapabilities() Global
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQArousalRuntime.CapabilitiesForBackend34(3)
  EndIf
    If !IsAvailable()
        Return 0
    EndIf
    If HasModernRateAPI()
        Return PSQArousalOSLModern.GetCapabilities()
    EndIf
    ; OSL 2.3 has read, instant changes, and exposure/arousal multiplier (1+2+8).
    ; Its SLA stub explicitly does not implement the old time rate.
    Return 11
EndFunction

Float Function GetArousal(Actor Target) Global
    If Target == None || !IsAvailable()
        Return -1.0
    EndIf
    Return OSLArousedNative.GetArousal(Target)
EndFunction

Bool Function ModifyLegacyRates(Actor Target, Float TimeRateDelta, Float ExposureRateDelta) Global
    If Target == None || !IsAvailable()
        Return False
    EndIf
    Bool Changed = False
    If TimeRateDelta != 0.0 && HasModernRateAPI()
        Changed = PSQArousalOSLModern.ModifyTimeRate(Target, TimeRateDelta)
    EndIf
    If ExposureRateDelta != 0.0
        OSLArousedNative.ModifyArousalMultiplier(Target, ExposureRateDelta)
        Changed = True
    EndIf
    Return Changed
EndFunction

Bool Function ModifyArousal(Actor Target, Float Amount) Global
    If Target == None || !IsAvailable()
        Return False
    EndIf
    OSLArousedNative.ModifyArousal(Target, Amount)
    Return True
EndFunction
