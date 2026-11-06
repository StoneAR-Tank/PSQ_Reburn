ScriptName PSQRaceCompatibility hidden

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

Bool Function IsAvailable() Global
  Return Game.GetModByName("RaceCompatibility.esm") != 255 || Game.GetLightModByName("RaceCompatibility.esm") != 65535 ; #DEBUG_LINE_NO:6
EndFunction

FormList Function GetRaceList(Bool Vampire) Global
  If !PSQRaceCompatibility.IsAvailable() ; #DEBUG_LINE_NO:10
    Return None ; #DEBUG_LINE_NO:11
  EndIf
  Int LocalID = 3426 ; #DEBUG_LINE_NO:13
  If Vampire ; #DEBUG_LINE_NO:14
    LocalID = 3427 ; #DEBUG_LINE_NO:15
  EndIf
  Return Game.GetFormFromFile(LocalID, "RaceCompatibility.esm") as FormList ; #DEBUG_LINE_NO:17
EndFunction

Int Function GetPairIndex(Race Source) Global
  If Source == None ; #DEBUG_LINE_NO:21
    Return -1 ; #DEBUG_LINE_NO:22
  EndIf
  FormList Normal = PSQRaceCompatibility.GetRaceList(False) ; #DEBUG_LINE_NO:24
  FormList Vampire = PSQRaceCompatibility.GetRaceList(True) ; #DEBUG_LINE_NO:25
  If Normal == None || Vampire == None || Normal.GetSize() != Vampire.GetSize() ; #DEBUG_LINE_NO:26
    Return -1 ; #DEBUG_LINE_NO:27
  EndIf
  Int Found = -1 ; #DEBUG_LINE_NO:29
  Int Index = 0 ; #DEBUG_LINE_NO:30
  While Index < Normal.GetSize() ; #DEBUG_LINE_NO:31
    Race NormalRace = Normal.GetAt(Index) as Race ; #DEBUG_LINE_NO:32
    Race VampireRace = Vampire.GetAt(Index) as Race ; #DEBUG_LINE_NO:33
    If Source == NormalRace || Source == VampireRace ; #DEBUG_LINE_NO:34
      If Found >= 0 || NormalRace == None || VampireRace == None || NormalRace == VampireRace ; #DEBUG_LINE_NO:35
        Return -1 ; #DEBUG_LINE_NO:36
      EndIf
      Found = Index ; #DEBUG_LINE_NO:38
    EndIf
    Index += 1 ; #DEBUG_LINE_NO:40
  EndWhile
  If Found < 0 ; #DEBUG_LINE_NO:42
    Return -1 ; #DEBUG_LINE_NO:43
  EndIf
  Race MatchedNormal = Normal.GetAt(Found) as Race ; #DEBUG_LINE_NO:45
  Race MatchedVampire = Vampire.GetAt(Found) as Race ; #DEBUG_LINE_NO:46
  Index = 0 ; #DEBUG_LINE_NO:47
  While Index < Normal.GetSize() ; #DEBUG_LINE_NO:48
    If Index != Found ; #DEBUG_LINE_NO:49
      Form OtherNormal = Normal.GetAt(Index) ; #DEBUG_LINE_NO:50
      Form OtherVampire = Vampire.GetAt(Index) ; #DEBUG_LINE_NO:51
      If (OtherNormal == MatchedNormal as Form) || (OtherVampire == MatchedNormal as Form) || (OtherNormal == MatchedVampire as Form) || (OtherVampire == MatchedVampire as Form) ; #DEBUG_LINE_NO:52
        Return -1 ; #DEBUG_LINE_NO:53
      EndIf
    EndIf
    Index += 1 ; #DEBUG_LINE_NO:56
  EndWhile
  Return Found ; #DEBUG_LINE_NO:58
EndFunction

Race Function GetNormalRace(Race Source) Global
  Int Index = PSQRaceCompatibility.GetPairIndex(Source) ; #DEBUG_LINE_NO:62
  If Index < 0 ; #DEBUG_LINE_NO:63
    Return None ; #DEBUG_LINE_NO:64
  EndIf
  FormList Races = PSQRaceCompatibility.GetRaceList(False) ; #DEBUG_LINE_NO:66
  If Races == None || Index >= Races.GetSize() ; #DEBUG_LINE_NO:67
    Return None ; #DEBUG_LINE_NO:68
  EndIf
  Return Races.GetAt(Index) as Race ; #DEBUG_LINE_NO:70
EndFunction

Race Function GetVampireRace(Race Source) Global
  Int Index = PSQRaceCompatibility.GetPairIndex(Source) ; #DEBUG_LINE_NO:74
  If Index < 0 ; #DEBUG_LINE_NO:75
    Return None ; #DEBUG_LINE_NO:76
  EndIf
  FormList Races = PSQRaceCompatibility.GetRaceList(True) ; #DEBUG_LINE_NO:78
  If Races == None || Index >= Races.GetSize() ; #DEBUG_LINE_NO:79
    Return None ; #DEBUG_LINE_NO:80
  EndIf
  Return Races.GetAt(Index) as Race ; #DEBUG_LINE_NO:82
EndFunction

Bool Function IsVanillaRace(Race Source) Global
  If Source == None ; #DEBUG_LINE_NO:86
    Return False ; #DEBUG_LINE_NO:87
  EndIf
  Int ID = Source.GetFormID() ; #DEBUG_LINE_NO:91
  If ID >= 79680 && ID <= 79689 ; #DEBUG_LINE_NO:92
    Return True ; #DEBUG_LINE_NO:93
  EndIf
  Return ID == 559162 || ID == 559164 || ID == 559165 || ID == 559168 || ID == 559172 || ID == 559173 || ID == 558996 || ID == 688825 || ID == 559174 || ID == 559236 ; #DEBUG_LINE_NO:95
EndFunction

Bool Function IsTemporaryBeastRace(Race Source) Global
  If Source == None ; #DEBUG_LINE_NO:99
    Return False ; #DEBUG_LINE_NO:100
  EndIf
  If Source == Game.GetFormFromFile(843140, "Skyrim.esm") as Race ; #DEBUG_LINE_NO:102
    Return True ; #DEBUG_LINE_NO:103
  EndIf
  If Game.GetModByName("Dawnguard.esm") != 255 ; #DEBUG_LINE_NO:105
    Return Source == Game.GetFormFromFile(10298, "Dawnguard.esm") as Race ; #DEBUG_LINE_NO:106
  EndIf
  Return False ; #DEBUG_LINE_NO:108
EndFunction

Int Function GetMode(Actor Target) Global
  Int Mode = storageutil.GetIntValue(Target as Form, "PSQ_RaceAppearanceMode", 0) ; #DEBUG_LINE_NO:112
  If Mode < 0 || Mode > 2 ; #DEBUG_LINE_NO:113
    Return 0 ; #DEBUG_LINE_NO:114
  EndIf
  Return Mode ; #DEBUG_LINE_NO:116
EndFunction

Bool Function SetMode(Actor Target, Int Mode) Global
  If Target == None || Mode < 0 || Mode > 2 ; #DEBUG_LINE_NO:120
    Return False ; #DEBUG_LINE_NO:121
  EndIf
  storageutil.SetIntValue(Target as Form, "PSQ_RaceAppearanceMode", Mode) ; #DEBUG_LINE_NO:123
  Return True ; #DEBUG_LINE_NO:124
EndFunction

Bool Function ShouldPreserveAppearance(Actor Target) Global
  If Target == None ; #DEBUG_LINE_NO:128
    Return True ; #DEBUG_LINE_NO:129
  EndIf
  If PSQRaceCompatibility.IsUBEActor(Target)
    Return True
  EndIf
  Int Mode = PSQRaceCompatibility.GetMode(Target) ; #DEBUG_LINE_NO:131
  If Mode == 1 ; #DEBUG_LINE_NO:132
    Return True ; #DEBUG_LINE_NO:133
  ElseIf Mode == 2 ; #DEBUG_LINE_NO:134
    Return False ; #DEBUG_LINE_NO:135
  EndIf
  Return !PSQRaceCompatibility.IsVanillaRace(Target.GetRace()) ; #DEBUG_LINE_NO:139
EndFunction

Bool Function CanUseHeadPart(HeadPart Part, Race TargetRace) Global
  If Part == None || TargetRace == None ; #DEBUG_LINE_NO:143
    Return False ; #DEBUG_LINE_NO:144
  EndIf
  FormList ValidRaces = Part.GetValidRaces() ; #DEBUG_LINE_NO:146
  Return ValidRaces != None && ValidRaces.HasForm(TargetRace as Form) ; #DEBUG_LINE_NO:147
EndFunction

String Function GetRegistrationStatus(Race Source) Global
  If !PSQRaceCompatibility.IsAvailable() ; #DEBUG_LINE_NO:151
    Return "未安装（可选）" ; #DEBUG_LINE_NO:152
  EndIf
  Int Index = PSQRaceCompatibility.GetPairIndex(Source) ; #DEBUG_LINE_NO:154
  If Index < 0 ; #DEBUG_LINE_NO:155
    Return "未找到完整配对／尚未注册" ; #DEBUG_LINE_NO:156
  EndIf
  Race NormalRace = PSQRaceCompatibility.GetNormalRace(Source) ; #DEBUG_LINE_NO:158
  Race VampireRace = PSQRaceCompatibility.GetVampireRace(Source) ; #DEBUG_LINE_NO:159
  If Source == NormalRace ; #DEBUG_LINE_NO:160
    Return "普通种族已注册" ; #DEBUG_LINE_NO:161
  ElseIf Source == VampireRace ; #DEBUG_LINE_NO:162
    Return "吸血鬼种族已注册" ; #DEBUG_LINE_NO:163
  EndIf
  Return "映射更新中" ; #DEBUG_LINE_NO:165
EndFunction

String Function GetAppearanceStatus(Actor Target) Global
  If PSQRaceCompatibility.IsUBEActor(Target)
    If PSQRaceCompatibility.GetMode(Target) == 1
      Return "UBE：保留全部外观"
    EndIf
    Return "UBE：独立身形接口，保留身体与皮肤"
  EndIf
  If PSQRaceCompatibility.ShouldPreserveAppearance(Target) ; #DEBUG_LINE_NO:169
    Return "保留当前种族外观" ; #DEBUG_LINE_NO:170
  EndIf
  Return "使用 PSQ 外观（资源需匹配）" ; #DEBUG_LINE_NO:172
EndFunction

Bool Function HasUBE() Global
  Return Game.GetModByName("UBE_AllRace.esp") != 255 || Game.GetLightModByName("UBE_AllRace.esp") != 65535
EndFunction

Bool Function SkinUsesUBE(Armor Skin) Global
  If Skin == None
    Return False
  EndIf
  Int Count = Skin.GetNumArmorAddons()
  If Count > 16
    Count = 16
  EndIf
  Int i = 0
  While i < Count
    ArmorAddon Addon = Skin.GetNthArmorAddon(i)
    If Addon != None
      String Model = Addon.GetModelPath(False, True)
      If StringUtil.Find(Model, "!UBE\\Body\\", 0) == 0 || StringUtil.Find(Model, "!ube\\body\\", 0) == 0 || StringUtil.Find(Model, "!UBE/Body/", 0) == 0
        Return True
      EndIf
    EndIf
    i += 1
  EndWhile
  Return False
EndFunction

Bool Function IsUBEActor(Actor Target) Global
  If Target == None
    Return False
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777218
    Int Kind = PSQAppearance.IsUBEActor(Target)
    If Kind >= 0
      Return Kind == 1
    EndIf
  EndIf
  If Target.GetRace() == None
    Return False
  EndIf
  Armor RaceSkin = Target.GetRace().GetSkin()
  If PSQRaceCompatibility.HasUBE()
    Armor UBESkin = Game.GetFormFromFile(83175, "UBE_AllRace.esp") as Armor
    If UBESkin != None && RaceSkin == UBESkin
      Return True
    EndIf
  EndIf
  If PSQRaceCompatibility.SkinUsesUBE(RaceSkin)
    Return True
  EndIf
  Armor BaseSkin = Target.GetLeveledActorBase().GetSkin()
  Return BaseSkin != RaceSkin && PSQRaceCompatibility.SkinUsesUBE(BaseSkin)
EndFunction

Bool Function ShouldPreserveBCNGBody(Actor Target) Global
  If Target == None || PSQRaceCompatibility.GetMode(Target) == 1 || PSQRaceCompatibility.IsTemporaryBeastRace(Target.GetRace())
    Return True
  EndIf
  If PSQRaceCompatibility.IsUBEActor(Target) && Target.GetLeveledActorBase().GetSex() == 1
    Return False
  EndIf
  Return PSQRaceCompatibility.ShouldPreserveAppearance(Target)
EndFunction

Bool Function ShouldPreserveHeadAppearance(Actor Target) Global
  If Target == None || PSQRaceCompatibility.GetMode(Target) == 1
    Return True
  EndIf
  If PSQRaceCompatibility.IsUBEActor(Target)
    Return False
  EndIf
  Return PSQRaceCompatibility.ShouldPreserveAppearance(Target)
EndFunction
Bool Function IsUBEEquipment(Armor Item) Global
  If Item == None
    Return False
  EndIf
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777218
    Int Kind = PSQAppearance.IsUBEEquipment(Item)
    If Kind >= 0
      Return Kind == 1
    EndIf
  EndIf
  Int i = 0
  Int Count = Item.GetNumArmorAddons()
  If Count > 16
    Count = 16
  EndIf
  While i < Count
    ArmorAddon Addon = Item.GetNthArmorAddon(i)
    If Addon != None
      String Path = Addon.GetModelPath(False, True)
      If StringUtil.Find(Path, "!UBE\\", 0) == 0 || StringUtil.Find(Path, "!ube\\", 0) == 0 || StringUtil.Find(Path, "!UBE/", 0) == 0
        Return True
      EndIf
    EndIf
    i += 1
  EndWhile
  Return False
EndFunction
