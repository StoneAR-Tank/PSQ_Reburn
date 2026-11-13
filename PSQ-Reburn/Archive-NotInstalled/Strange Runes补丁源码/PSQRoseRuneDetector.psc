Scriptname PSQRoseRuneDetector extends PO3_RUNEDetectPlayerCasting

; The original detector still owns equip events, MCM choices, dual repositioning
; and tracked LeftRune/RightRune. Only a PSQ element in the relevant hand is redirected.
Int Function PSQElement(Form item)
    If !item
        Return -1
    EndIf
    Int id = Math.LogicalAnd(item.GetFormID(), 0x00FFFFFF)
    If (id < 0xE8D || id > 0xE97) && id != 0xB700
        Return -1
    EndIf
    If Game.GetFormFromFile(id, "PSQ PlayerSuccubusQuest.esm") != item
        Return -1
    EndIf
    If id == 0xB700
        Return 2
    EndIf
    Return (id - 0xE8D) % 3
EndFunction

Int Function GetRuneType(Form akObject)
    Int element = PSQElement(akObject)
    If element >= 0
        Return element
    EndIf
    Return Parent.GetRuneType(akObject)
EndFunction

Int Function GetSpellType(Form akObject)
    If akObject && PSQElement(akObject) >= 0 && po3_RUNE_MasterSpellsToggle.GetValue() != 0.0
        Int id = Math.LogicalAnd(akObject.GetFormID(), 0x00FFFFFF)
        If id == 0xE96 || id == 0xE97 || id == 0xB700
            Return 0 ; Strange Runes' ritual category
        EndIf
    EndIf
    Return Parent.GetSpellType(akObject)
EndFunction

Spell Function CastSimpleRune(Spell NormSpell)
    Int slot = -1
    If NormSpell == po3_RUNE_FireLeft || NormSpell == po3_RUNE_FrostLeft || NormSpell == po3_RUNE_ShockLeft
        slot = 0
    ElseIf NormSpell == po3_RUNE_FireRight || NormSpell == po3_RUNE_FrostRight || NormSpell == po3_RUNE_ShockRight
        slot = 1
    ElseIf NormSpell == po3_RUNE_FireRitual || NormSpell == po3_RUNE_FrostRitual || NormSpell == po3_RUNE_ShockRitual
        slot = 2
    EndIf
    If slot >= 0
        Int hand = slot
        If slot == 2
            hand = 0
        EndIf
        Int element = PSQElement(PlayerRef.GetEquippedObject(hand))
        Int expected = 0
        If NormSpell == po3_RUNE_FrostLeft || NormSpell == po3_RUNE_FrostRight || NormSpell == po3_RUNE_FrostRitual
            expected = 1
        ElseIf NormSpell == po3_RUNE_ShockLeft || NormSpell == po3_RUNE_ShockRight || NormSpell == po3_RUNE_ShockRitual
            expected = 2
        EndIf
        If element == expected
            Spell pink = Game.GetFormFromFile(0x810 + 3 * slot + element, "PSQ - Strange Runes.esp") as Spell
            If pink
                Return Parent.CastSimpleRune(pink)
            EndIf
        EndIf
    EndIf
    Return Parent.CastSimpleRune(NormSpell)
EndFunction

Function RemoveAllRunes()
    Parent.RemoveAllRunes()
    PO3_SKSEFunctions.RemoveAddedSpells(PlayerRef, "PSQ - Strange Runes.esp", HandRuneTypes, false)
EndFunction

Function RemoveAllRunesOnHand(Int handType)
    Parent.RemoveAllRunesOnHand(handType)
    Keyword[] hand = new Keyword[1]
    If handType == 0
        hand[0] = HandRuneTypes[0]
    Else
        hand[0] = HandRuneTypes[1]
    EndIf
    PO3_SKSEFunctions.RemoveAddedSpells(PlayerRef, "PSQ - Strange Runes.esp", hand, false)
EndFunction
