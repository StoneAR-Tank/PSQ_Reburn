Scriptname PSQRoseStormRelease extends ActiveMagicEffect
Spell Property Strike Auto
Faction Property Followers Auto
Faction Property Thralls Auto
Form[] Property Bolts Auto
Sound Property ThunderTail Auto

Bool Function CanStrike(Actor enemy, Actor caster)
    Return enemy && enemy != caster && enemy.IsHostileToActor(caster) && !enemy.IsDead() && !enemy.IsPlayerTeammate() && !enemy.IsInFaction(Followers) && !enemy.IsInFaction(Thralls) && caster.HasLOS(enemy)
EndFunction

Event OnEffectStart(Actor target, Actor caster)
    If !caster || target != caster || caster != Game.GetPlayer() || !Strike
        Return
    EndIf
    Float started = Utility.GetCurrentRealTime()
    Float firstDelay = -1.0
    Int hits = 0
    Int startVariant = Utility.RandomInt(0, 2)
    Actor aimed = Game.GetCurrentCrosshairRef() as Actor
    If aimed && aimed.GetDistance(caster) <= 1280.0 && CanStrike(aimed, caster)
        caster.DoCombatSpellApply(Strike, aimed)
        aimed.PlaceAtMe(Bolts[startVariant])
        firstDelay = Utility.GetCurrentRealTime() - started
        hits = 1
    Else
        aimed = None
    EndIf

    Actor[] nearby = MiscUtil.ScanCellActors(caster, 1280.0)
    Int i = 0
    Int queued = 0
    While i < nearby.Length
        Actor enemy = nearby[i]
        If enemy != aimed && CanStrike(enemy, caster) && nearby.Find(enemy) == i
            caster.DoCombatSpellApply(Strike, enemy)
            If hits == 0
                aimed = enemy
                enemy.PlaceAtMe(Bolts[startVariant])
                firstDelay = Utility.GetCurrentRealTime() - started
            Else
                nearby[queued] = enemy
                queued += 1
            EndIf
            hits += 1
        EndIf
        i += 1
    EndWhile
    i = 0
    While i < queued
        nearby[i].PlaceAtMe(Bolts[(startVariant + i + 1) % 3])
        i += 1
    EndWhile
    If hits > 0 && ThunderTail
        Int voice = ThunderTail.Play(caster)
        Sound.SetInstanceVolume(voice, 0.45)
    EndIf
    Debug.Trace("[PSQ] RoseStorm release targets=" + hits + " firstSpawnSeconds=" + firstDelay)
EndEvent

