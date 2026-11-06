ScriptName PSQDXUBE Hidden

Bool Function HasOutfits() Global
  Return Game.GetModByName("PSQ UBE Outfits.esp") != 255 || Game.GetLightModByName("PSQ UBE Outfits.esp") != 65535
EndFunction

Armor Function GetRawPart(Int Part) Global
  If Part < 0 || Part > 5 || (Game.GetModByName("PSQ UBE DX.esp") == 255 && Game.GetLightModByName("PSQ UBE DX.esp") == 65535)
    Return None
  EndIf
  Return Game.GetFormFromFile(2080 + Part, "PSQ UBE DX.esp") as Armor
EndFunction

Armor Function GetConvertedPart(Int Selection, Int Part) Global
  If Part < 0 || Part > 5
    Return None
  EndIf
  If Selection == 1
    Return PSQDXUBE.GetRawPart(Part)
  EndIf
  If !PSQDXUBE.HasOutfits()
    Return None
  EndIf
  If Selection >= 2 && Selection <= 8
    Return Game.GetFormFromFile(2304 + (Selection - 2) * 6 + Part, "PSQ UBE Outfits.esp") as Armor
  ElseIf Selection == 100 && Part != 3 && Part != 5
    Return Game.GetFormFromFile(2368 + Part, "PSQ UBE Outfits.esp") as Armor
  EndIf
  Return None
EndFunction

Armor Function GetOriginalPart(Int Selection, Int Part) Global
  If Part < 0 || Part > 5
    Return None
  EndIf
  If Selection >= 1 && Selection <= 8
    Return Game.GetFormFromFile(40835 + (Selection - 1) * 12 + Part * 2, "PSQ PlayerSuccubusQuest.esm") as Armor
  ElseIf Selection == 100 && Part != 3 && Part != 5
    Return Game.GetFormFromFile(45056 + Part, "PSQ PlayerSuccubusQuest.esm") as Armor
  EndIf
  Return None
EndFunction

Armor Function GetOutfitPart(Actor Target, Int Selection, Int Part) Global
  If Target == None
    Return None
  EndIf
  If PSQRaceCompatibility.IsUBEActor(Target)
    Return PSQDXUBE.GetConvertedPart(Selection, Part)
  EndIf
  Return PSQDXUBE.GetOriginalPart(Selection, Part)
EndFunction

Armor Function GetPart(Actor Target, Int Part) Global
  If Target == None || !PSQRaceCompatibility.IsUBEActor(Target)
    Return None
  EndIf
  Return PSQDXUBE.GetRawPart(Part)
EndFunction

Int Function GetItemPart(Armor Item) Global
  If Item == None
    Return -1
  EndIf
  Int ID = PSQDXUBE.GetLocalFormID(Item)
  Return PSQDXUBE.GetVerifiedPartForID(Item, ID)
EndFunction

Int Function GetItemSelection(Armor Item) Global
  Int ID = PSQDXUBE.GetLocalFormID(Item)
  If PSQDXUBE.GetVerifiedPartForID(Item, ID) < 0
    Return 0
  EndIf
  Return PSQDXUBE.GetSelectionForVerifiedID(ID)
EndFunction

Int Function GetLocalFormID(Armor Item) Global
  If Item == None
    Return -1
  EndIf
  Int ID = Item.GetFormID()
  If Math.LogicalAnd(Math.RightShift(ID, 24), 255) == 254
    Return Math.LogicalAnd(ID, 4095)
  EndIf
  Return Math.LogicalAnd(ID, 16777215)
EndFunction

Armor Function ResolvePart(Actor Target, Armor Item, Int Part) Global
  If Target == None || Item == None || Part < 0 || Part > 5
    Return None
  EndIf
  Int ID = PSQDXUBE.GetLocalFormID(Item)
  Int FoundPart = PSQDXUBE.GetVerifiedPartForID(Item, ID)
  If FoundPart >= 0 && FoundPart != Part
    Return None
  EndIf
  Bool WantUBE = PSQRaceCompatibility.IsUBEActor(Target)
  If FoundPart < 0
    If WantUBE
      Return None
    EndIf
    Return Item
  EndIf
  ; Of the verified records, the UBE ESP-FEs use 0x820..0x944 while
  ; PSQ's base equipment uses 0x9F83 and up. Same-family lookup is done.
  Bool AlreadyUBE = ID >= 2080 && ID <= 2372
  If WantUBE == AlreadyUBE
    Return Item
  EndIf
  Int Selection = PSQDXUBE.GetSelectionForVerifiedID(ID)
  If WantUBE
    Return PSQDXUBE.GetConvertedPart(Selection, Part)
  EndIf
  Return PSQDXUBE.GetOriginalPart(Selection, Part)
EndFunction

Bool Function SupportsItem(Actor Target, Armor Item) Global
  If Target == None || Item == None || !PSQRaceCompatibility.IsUBEActor(Target)
    Return False
  EndIf
  Int ID = PSQDXUBE.GetLocalFormID(Item)
  Return ID >= 2080 && ID <= 2372 && PSQDXUBE.GetVerifiedPartForID(Item, ID) >= 0
EndFunction

Int Function GetVerifiedPartForID(Armor Item, Int ID) Global
  ; Equal local IDs are common across mods. Each branch below verifies the
  ; actual record from the owning plugin before it accepts a catalogue slot.
  If Item == None
    Return -1
  EndIf
  Int Part = -1
  Int Selection = 0
  If ID >= 40835 && ID <= 40929 && (ID - 40835) % 2 == 0
    Part = ((ID - 40835) % 12) / 2
    Selection = (ID - 40835) / 12 + 1
    If Item == PSQDXUBE.GetOriginalPart(Selection, Part)
      Return Part
    EndIf
  ElseIf ID >= 45056 && ID <= 45060
    Part = ID - 45056
    If Item == PSQDXUBE.GetOriginalPart(100, Part)
      Return Part
    EndIf
  ElseIf ID >= 2080 && ID <= 2085
    Part = ID - 2080
    If Item == PSQDXUBE.GetRawPart(Part)
      Return Part
    EndIf
  ElseIf ID >= 2304 && ID <= 2345
    Part = (ID - 2304) % 6
    Selection = (ID - 2304) / 6 + 2
    If Item == PSQDXUBE.GetConvertedPart(Selection, Part)
      Return Part
    EndIf
  ElseIf ID >= 2368 && ID <= 2372
    Part = ID - 2368
    If Item == PSQDXUBE.GetConvertedPart(100, Part)
      Return Part
    EndIf
  EndIf
  Return -1
EndFunction

Int Function GetSelectionForVerifiedID(Int ID) Global
  If ID >= 40835 && ID <= 40929
    Return (ID - 40835) / 12 + 1
  ElseIf ID >= 2304 && ID <= 2345
    Return (ID - 2304) / 6 + 2
  ElseIf ID >= 2080 && ID <= 2085
    Return 1
  EndIf
  Return 100
EndFunction
