Scriptname SuccubusFortifyMSGBoxScript Extends ActiveMagicEffect

PlayerSuccubusQuestScript Property PSQ Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
  If PSQ && akCaster == PSQ.PlayerRef
    MainMenu()
  EndIf
EndEvent

Function MainMenu()
  If !Game.IsPluginInstalled("UIExtensions.esp")
    Return
  EndIf
  Int Ticket = PSQ.BeginStrongBodyMenu()
  If Ticket <= 0
    Return
  EndIf
  PSQ.Satiety(0.0)
  ShowPurchaseMenu(Ticket)
  PSQ.EndStrongBodyMenu(Ticket)
EndFunction

Function ShowPurchaseMenu(Int Ticket)
  UIListMenu ListMenu = UIExtensions.GetMenu("UIListMenu", True) as UIListMenu
  If !ListMenu || !PSQ.IsStrongBodyMenuCurrent(Ticket)
    Return
  EndIf
  String[] Options = New String[4]
  Options[0] = "法力上限 +10（1000 魅魔能量）;;-1;;1;;0;;0"
  Options[1] = "负重上限 +50（1000 魅魔能量）;;-1;;2;;1;;0"
  Options[2] = "天赋点 +1（3000 魅魔能量）;;-1;;3;;2;;0"
  Options[3] = "取消;;-1;;4;;3;;0"
  ListMenu.SetPropertyStringA("appendEntries", Options)
  If ListMenu.OpenMenu(None, None) != 1
    Return
  EndIf
  Int Choice = ListMenu.GetResultInt()
  If Choice < 1 || Choice > 3 || !PSQ.IsStrongBodyMenuCurrent(Ticket)
    Return
  EndIf
  Float Price = 1000.0
  If Choice == 3
    Price = 3000.0
  EndIf
  If Choice == 2 && (!Game.GetFormFromFile(0xB911, "PSQ PlayerSuccubusQuest.esm") || StorageUtil.GetIntValue(PSQ.PlayerRef, "PSQ_Growth_StrongBody_CarryWeight", 0) > 2147483597)
    Debug.Notification("负重强化暂时不可用。")
    Return
  EndIf
  If !EnergyCheck(Price)
    Return
  EndIf
  If Choice == 3
    ; Skyrim holds unspent perk points in a byte. Avoid charging a capped player.
    If Game.GetPerkPoints() >= 255
      Debug.Notification("天赋点已满。")
      Return
    EndIf
  EndIf
  ; Reserve against the latest stored balance, even if another gameplay effect
  ; spent energy after EnergyCheck. Mod() returns the resulting value.
  If PSQ.SuccubusEnergy.Mod(-Price) < 0.0
    PSQ.SuccubusEnergy.Mod(Price)
    Debug.Notification("$PSQ_EnergyShortNotice")
    Return
  EndIf
  If Choice == 1
    PSQ.PlayerRef.SetActorValue("Magicka", PSQ.PlayerRef.GetBaseActorValue("Magicka") + 10.0)
  ElseIf Choice == 3
    Game.AddPerkPoints(1)
  EndIf
  PSQ.RecordStrongBodyPurchase(Choice)
  PSQ.Satiety(0.0)
  PSQ.SatietyNotification(-Price, False)
EndFunction

Bool Function EnergyCheck(Float Value)
  If PSQ.SuccubusEnergy.GetValue() >= Value
    Return True
  EndIf
  Debug.Notification("$PSQ_EnergyShortNotice")
  Return False
EndFunction

; Retain the public method for callers and stacks from an earlier version.
Function EnergySubtract(Float Value)
  PSQ.Satiety(-Value)
  PSQ.SatietyNotification(-Value, False)
EndFunction
