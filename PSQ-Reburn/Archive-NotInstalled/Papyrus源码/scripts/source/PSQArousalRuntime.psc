ScriptName PSQArousalRuntime hidden

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

Int Function GetMode() Global
  Return storageutil.GetIntValue(Game.GetPlayer() as Form, "PSQ_ArousalMode", 0) ; #DEBUG_LINE_NO:8
EndFunction

Function SetMode(Int Mode) Global
  If Mode < 0 || Mode > 5 ; #DEBUG_LINE_NO:12
    Return  ; #DEBUG_LINE_NO:13
  EndIf
  storageutil.SetIntValue(Game.GetPlayer() as Form, "PSQ_ArousalMode", Mode) ; #DEBUG_LINE_NO:15
  Debug.Trace(("[PSQ Arousal] selected mode=" + Mode as String) + "; active=" + PSQArousalRuntime.GetBackendName(), 0) ; #DEBUG_LINE_NO:16
EndFunction

Bool Function HasSLA() Global
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.HasSLA34()
  EndIf
  Return Game.GetModByName("SexLabAroused.esm") != 255 ; #DEBUG_LINE_NO:20
EndFunction

Bool Function HasNG() Global
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.NGCandidate34() && PSQArousalSLA.GetVersion() >= 30200000
  EndIf
  If !PSQArousalRuntime.HasSLA() || skse.GetPluginVersion("SexlabArousedNG") < 0 ; #DEBUG_LINE_NO:26
    Return False ; #DEBUG_LINE_NO:27
  EndIf
  Return psqarousalsla.GetVersion() >= 30200000 ; #DEBUG_LINE_NO:29
EndFunction

Bool Function HasOSL() Global
  ; OSL's native API does not require its optional SexLab Aroused compatibility stub.
  Return PSQArousalOSL.IsAvailable()
EndFunction

PSQArousalProvider Function GetExternalProvider() Global
  Return storageutil.GetFormValue(Game.GetPlayer() as Form, "PSQ_ArousalExternalProvider", None) as PSQArousalProvider ; #DEBUG_LINE_NO:37
EndFunction

Bool Function HasExternalProvider() Global
  PSQArousalProvider Provider = PSQArousalRuntime.GetExternalProvider() ; #DEBUG_LINE_NO:41
  Return Provider != None && Provider.IsAvailable() && Math.LogicalAnd(Provider.GetCapabilities(), 1) != 0 ; #DEBUG_LINE_NO:42
EndFunction

Bool Function RegisterProvider(PSQArousalProvider Provider) Global
  If Provider == None || !Provider.IsAvailable() || Math.LogicalAnd(Provider.GetCapabilities(), 1) == 0 ; #DEBUG_LINE_NO:46
    Return False ; #DEBUG_LINE_NO:47
  EndIf
  storageutil.SetFormValue(Game.GetPlayer() as Form, "PSQ_ArousalExternalProvider", Provider as Form) ; #DEBUG_LINE_NO:49
  Return True ; #DEBUG_LINE_NO:50
EndFunction

Function UnregisterProvider(PSQArousalProvider Provider) Global
  If PSQArousalRuntime.GetExternalProvider() == Provider ; #DEBUG_LINE_NO:54
    storageutil.UnsetFormValue(Game.GetPlayer() as Form, "PSQ_ArousalExternalProvider") ; #DEBUG_LINE_NO:55
  EndIf
EndFunction

Int Function ResolveBackend() Global
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Int[] Options = PSQAppearance.ArousalCandidates34(PSQArousalRuntime.GetMode())
    Int i = 0
    While i < Options.Length
      Int Code = Options[i]
      If Code == 3 || (Code == 2 && PSQArousalSLA.GetVersion() >= 30200000) || (Code == 1 && PSQArousalSLA.IsAvailable()) || (Code == 4 && PSQArousalRuntime.HasExternalProvider())
        Return Code
      EndIf
      i += 1
    EndWhile
    Return 5
  EndIf
  Int Mode = PSQArousalRuntime.GetMode() ; #DEBUG_LINE_NO:60
  If Mode == 5 ; #DEBUG_LINE_NO:61
    Return 5 ; #DEBUG_LINE_NO:62
  ElseIf Mode == 2 ; #DEBUG_LINE_NO:63
    If PSQArousalRuntime.HasNG() ; #DEBUG_LINE_NO:64
      Return 2 ; #DEBUG_LINE_NO:65
    EndIf
  ElseIf Mode == 3 ; #DEBUG_LINE_NO:67
    If PSQArousalRuntime.HasOSL() ; #DEBUG_LINE_NO:68
      Return 3 ; #DEBUG_LINE_NO:69
    EndIf
  ElseIf Mode == 1 ; #DEBUG_LINE_NO:71
    If PSQArousalRuntime.HasSLA() && psqarousalsla.IsAvailable() ; #DEBUG_LINE_NO:72
      Return 1 ; #DEBUG_LINE_NO:73
    EndIf
  ElseIf Mode == 4 ; #DEBUG_LINE_NO:75
    If PSQArousalRuntime.HasExternalProvider() ; #DEBUG_LINE_NO:76
      Return 4 ; #DEBUG_LINE_NO:77
    EndIf
  ElseIf PSQArousalRuntime.HasNG() ; #DEBUG_LINE_NO:80
    Return 2 ; #DEBUG_LINE_NO:81
  ElseIf PSQArousalRuntime.HasOSL() ; #DEBUG_LINE_NO:82
    Return 3 ; #DEBUG_LINE_NO:83
  ElseIf PSQArousalRuntime.HasSLA() && psqarousalsla.IsAvailable() ; #DEBUG_LINE_NO:84
    Return 1 ; #DEBUG_LINE_NO:85
  ElseIf PSQArousalRuntime.HasExternalProvider() ; #DEBUG_LINE_NO:86
    Return 4 ; #DEBUG_LINE_NO:87
  EndIf
  Return 5 ; #DEBUG_LINE_NO:90
EndFunction

Int Function GetCapabilities() Global
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQArousalRuntime.CapabilitiesForBackend34(PSQArousalRuntime.ResolveBackend())
  EndIf
  Int Backend = PSQArousalRuntime.ResolveBackend() ; #DEBUG_LINE_NO:94
  If Backend == 2 ; #DEBUG_LINE_NO:95
    Return 3 ; #DEBUG_LINE_NO:96
  ElseIf Backend == 3 ; #DEBUG_LINE_NO:97
    Return psqarousalosl.GetCapabilities() ; #DEBUG_LINE_NO:98
  ElseIf Backend == 1 ; #DEBUG_LINE_NO:99
    If skse.GetPluginVersion("SexlabArousedNG") >= 0 ; #DEBUG_LINE_NO:102
      Return 3 ; #DEBUG_LINE_NO:103
    ElseIf PSQArousalRuntime.HasOSL() ; #DEBUG_LINE_NO:104
      Return psqarousalosl.GetCapabilities() ; #DEBUG_LINE_NO:105
    EndIf
    Return 15 ; #DEBUG_LINE_NO:107
  ElseIf Backend == 4 ; #DEBUG_LINE_NO:108
    Return PSQArousalRuntime.GetExternalProvider().GetCapabilities() ; #DEBUG_LINE_NO:109
  EndIf
  Return 0 ; #DEBUG_LINE_NO:111
EndFunction

Float Function GetArousal(Actor Target) Global
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If Target == None
      Return -1.0
    EndIf
    Int ActiveBackend = PSQArousalRuntime.ResolveBackend()
    Float Reading = -1.0
    If ActiveBackend == 2
      Reading = PSQArousalNG.GetArousal(Target)
    ElseIf ActiveBackend == 3
      Reading = PSQArousalOSL.GetArousal(Target)
    ElseIf ActiveBackend == 1
      Reading = PSQArousalSLA.GetArousal(Target)
    ElseIf ActiveBackend == 4
      PSQArousalProvider ActiveProvider = PSQArousalRuntime.GetExternalProvider()
      If ActiveProvider
        Reading = ActiveProvider.GetArousal(Target)
      EndIf
    EndIf
    Return PSQAppearance.ArousalValue34(ActiveBackend, Reading)
  EndIf
  If Target == None ; #DEBUG_LINE_NO:115
    Return -1.0 ; #DEBUG_LINE_NO:116
  EndIf
  Int Backend = PSQArousalRuntime.ResolveBackend() ; #DEBUG_LINE_NO:118
  Float value = -1.0 ; #DEBUG_LINE_NO:119
  If Backend == 2 ; #DEBUG_LINE_NO:120
    value = psqarousalng.GetArousal(Target) ; #DEBUG_LINE_NO:121
  ElseIf Backend == 3 ; #DEBUG_LINE_NO:122
    value = psqarousalosl.GetArousal(Target) ; #DEBUG_LINE_NO:123
  ElseIf Backend == 1 ; #DEBUG_LINE_NO:124
    value = psqarousalsla.GetArousal(Target) ; #DEBUG_LINE_NO:125
    If value < 0.0 ; #DEBUG_LINE_NO:126
      Return -1.0 ; #DEBUG_LINE_NO:127
    EndIf
  ElseIf Backend == 4 ; #DEBUG_LINE_NO:129
    value = PSQArousalRuntime.GetExternalProvider().GetArousal(Target) ; #DEBUG_LINE_NO:130
    If value < 0.0 ; #DEBUG_LINE_NO:131
      Return -1.0 ; #DEBUG_LINE_NO:132
    EndIf
  Else
    Return -1.0 ; #DEBUG_LINE_NO:135
  EndIf
  If value < 0.0 ; #DEBUG_LINE_NO:137
    Return 0.0 ; #DEBUG_LINE_NO:140
  ElseIf value > 100.0 ; #DEBUG_LINE_NO:141
    Return 100.0 ; #DEBUG_LINE_NO:142
  EndIf
  Return value ; #DEBUG_LINE_NO:144
EndFunction

Int Function GetArousalInt(Actor Target) Global
  Return PSQArousalRuntime.GetArousal(Target) as Int ; #DEBUG_LINE_NO:148
EndFunction

Bool Function ModifyArousal(Actor Target, Float Amount) Global
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If Target == None || Amount == 0.0
      Return False
    EndIf
    Int Chosen = PSQArousalRuntime.ResolveBackend()
    PSQArousalProvider ChosenProvider
    Int Caps
    If Chosen == 4
      ChosenProvider = PSQArousalRuntime.GetExternalProvider()
      If !ChosenProvider
        Return False
      EndIf
      Caps = ChosenProvider.GetCapabilities()
    Else
      Caps = PSQArousalRuntime.CapabilitiesForBackend34(Chosen)
    EndIf
    If Math.LogicalAnd(Caps, 2) == 0
      Return False
    EndIf
    If Chosen == 2
      Return PSQArousalNG.ModifyArousal(Target, Amount)
    EndIf
    If Chosen == 3
      Return PSQArousalOSL.ModifyArousal(Target, Amount)
    EndIf
    If Chosen == 1
      Return PSQArousalSLA.ModifyArousal(Target, Amount)
    EndIf
    If Chosen == 4
      Return ChosenProvider.ModifyArousal(Target, Amount)
    EndIf
    Return False
  EndIf
  If Target == None || Amount == 0.0 || Math.LogicalAnd(PSQArousalRuntime.GetCapabilities(), 2) == 0 ; #DEBUG_LINE_NO:152
    Return False ; #DEBUG_LINE_NO:153
  EndIf
  Int Backend = PSQArousalRuntime.ResolveBackend() ; #DEBUG_LINE_NO:155
  If Backend == 2 ; #DEBUG_LINE_NO:156
    Return psqarousalng.ModifyArousal(Target, Amount) ; #DEBUG_LINE_NO:157
  ElseIf Backend == 3 ; #DEBUG_LINE_NO:158
    Return psqarousalosl.ModifyArousal(Target, Amount) ; #DEBUG_LINE_NO:159
  ElseIf Backend == 1 ; #DEBUG_LINE_NO:160
    Return psqarousalsla.ModifyArousal(Target, Amount) ; #DEBUG_LINE_NO:161
  ElseIf Backend == 4 ; #DEBUG_LINE_NO:162
    Return PSQArousalRuntime.GetExternalProvider().ModifyArousal(Target, Amount) ; #DEBUG_LINE_NO:163
  EndIf
  Return False ; #DEBUG_LINE_NO:165
EndFunction

Bool Function ModifyLegacyRates(Actor Target, Float TimeRateDelta, Float ExposureRateDelta) Global
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    If Target == None
      Return False
    EndIf
    Int Chosen = PSQArousalRuntime.ResolveBackend()
    PSQArousalProvider ChosenProvider
    Int Caps
    If Chosen == 4
      ChosenProvider = PSQArousalRuntime.GetExternalProvider()
      If !ChosenProvider
        Return False
      EndIf
      Caps = ChosenProvider.GetCapabilities()
    Else
      Caps = PSQArousalRuntime.CapabilitiesForBackend34(Chosen)
    EndIf
    Int Mask = PSQAppearance.RateMask34(Chosen, Caps, TimeRateDelta, ExposureRateDelta)
    If Mask == 0
      Return False
    EndIf
    If Mask == 8
      TimeRateDelta = 0.0
    ElseIf Mask == 4
      ExposureRateDelta = 0.0
    EndIf
    If Chosen == 3
      Return PSQArousalOSL.ModifyLegacyRates(Target, TimeRateDelta, ExposureRateDelta)
    EndIf
    If Chosen == 1
      Return PSQArousalSLA.ModifyLegacyRates(Target, TimeRateDelta, ExposureRateDelta)
    EndIf
    If Chosen == 4
      Return ChosenProvider.ModifyLegacyRates(Target, TimeRateDelta, ExposureRateDelta)
    EndIf
    Return False
  EndIf
  If Target == None ; #DEBUG_LINE_NO:169
    Return False ; #DEBUG_LINE_NO:170
  EndIf
  Int Capabilities = PSQArousalRuntime.GetCapabilities() ; #DEBUG_LINE_NO:172
  If Math.LogicalAnd(Capabilities, 4) == 0 ; #DEBUG_LINE_NO:173
    TimeRateDelta = 0.0 ; #DEBUG_LINE_NO:174
  EndIf
  If Math.LogicalAnd(Capabilities, 8) == 0 ; #DEBUG_LINE_NO:176
    ExposureRateDelta = 0.0 ; #DEBUG_LINE_NO:177
  EndIf
  If TimeRateDelta == 0.0 && ExposureRateDelta == 0.0 ; #DEBUG_LINE_NO:179
    Return False ; #DEBUG_LINE_NO:180
  EndIf
  Int Backend = PSQArousalRuntime.ResolveBackend() ; #DEBUG_LINE_NO:182
  If Backend == 3 ; #DEBUG_LINE_NO:183
    Return psqarousalosl.ModifyLegacyRates(Target, TimeRateDelta, ExposureRateDelta) ; #DEBUG_LINE_NO:184
  ElseIf Backend == 1 ; #DEBUG_LINE_NO:185
    Return psqarousalsla.ModifyLegacyRates(Target, TimeRateDelta, ExposureRateDelta) ; #DEBUG_LINE_NO:186
  ElseIf Backend == 4 ; #DEBUG_LINE_NO:187
    Return PSQArousalRuntime.GetExternalProvider().ModifyLegacyRates(Target, TimeRateDelta, ExposureRateDelta) ; #DEBUG_LINE_NO:188
  EndIf
  Return False ; #DEBUG_LINE_NO:190
EndFunction

String Function GetBackendName() Global
  Int Backend = PSQArousalRuntime.ResolveBackend() ; #DEBUG_LINE_NO:194
  If Backend == 2 ; #DEBUG_LINE_NO:195
    Return "SLO / SLA Aroused NG" ; #DEBUG_LINE_NO:196
  ElseIf Backend == 3 ; #DEBUG_LINE_NO:197
    Return "OSL Aroused" ; #DEBUG_LINE_NO:198
  ElseIf Backend == 1 ; #DEBUG_LINE_NO:199
    Return "SLA / Redux / SLAX 兼容接口" ; #DEBUG_LINE_NO:200
  ElseIf Backend == 4 ; #DEBUG_LINE_NO:201
    Return PSQArousalRuntime.GetExternalProvider().GetProviderName() ; #DEBUG_LINE_NO:202
  ElseIf PSQArousalRuntime.GetMode() == 5 ; #DEBUG_LINE_NO:203
    Return "已禁用" ; #DEBUG_LINE_NO:204
  ElseIf PSQArousalRuntime.GetMode() == 0 ; #DEBUG_LINE_NO:205
    Return "未检测到欲望框架" ; #DEBUG_LINE_NO:206
  EndIf
  Return "所选框架未就绪" ; #DEBUG_LINE_NO:208
EndFunction

String Function GetCapabilityText() Global
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.CapabilityName34(PSQArousalRuntime.GetCapabilities())
  EndIf
  Int Capabilities = PSQArousalRuntime.GetCapabilities() ; #DEBUG_LINE_NO:212
  If Capabilities == 0 ; #DEBUG_LINE_NO:213
    Return "未接入；保留基础吸取" ; #DEBUG_LINE_NO:214
  EndIf
  String Text = "读取欲望" ; #DEBUG_LINE_NO:216
  If Math.LogicalAnd(Capabilities, 2) != 0 ; #DEBUG_LINE_NO:217
    Text += " / 即时增减" ; #DEBUG_LINE_NO:218
  EndIf
  If Math.LogicalAnd(Capabilities, 4) != 0 ; #DEBUG_LINE_NO:220
    Text += " / 时间率" ; #DEBUG_LINE_NO:221
  EndIf
  If Math.LogicalAnd(Capabilities, 8) != 0 ; #DEBUG_LINE_NO:223
    Text += " / 暴露率" ; #DEBUG_LINE_NO:224
  EndIf
  Return Text ; #DEBUG_LINE_NO:226
EndFunction

Int Function CapabilitiesForBackend34(Int Backend) Global
  Int Plan = PSQAppearance.CapabilityPlan34(Backend)
  If Plan == -3
    Return PSQArousalOSLModern.GetCapabilities()
  ElseIf Plan == -4
    PSQArousalProvider Provider = PSQArousalRuntime.GetExternalProvider()
    If Provider
      Return Provider.GetCapabilities()
    EndIf
    Return 0
  EndIf
  Return Plan
EndFunction
