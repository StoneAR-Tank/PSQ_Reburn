Scriptname PSQRoseImpactAnchor extends ObjectReference
Event OnInit()
    SetAngle(0.0, 0.0, 0.0)
    RegisterForSingleUpdate(1.85)
    Sound thunder = Game.GetFormFromFile(0xB717, "PSQ PlayerSuccubusQuest.esm") as Sound
    If thunder
        thunder.Play(Self)
    EndIf
EndEvent
Event OnUpdate()
    DisableNoWait()
    Delete()
EndEvent



