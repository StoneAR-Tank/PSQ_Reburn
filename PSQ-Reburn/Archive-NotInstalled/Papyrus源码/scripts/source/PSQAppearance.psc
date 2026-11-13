ScriptName PSQAppearance Hidden Native
Int Function GetVersion() Global Native
Bool Function IsReady() Global Native
Bool Function SetHidden(Actor Target, Form[] Originals, Form[] Protected, Form[] Selected) Global Native
Bool Function Restore() Global Native

; API 2: read-only classification; -1 asks the Papyrus caller to fall back.
Int Function IsUBEActor(Actor Target) Global Native
Int Function IsUBEEquipment(Armor Item) Global Native

; API 3: fresh read-only main-thread batches, with fallback on unavailable data.
Float[] Function ReadPoolValues(Actor Target) Global Native
Int Function CheckStatEffects(Actor Target, Spell Ability, Float[] Magnitudes) Global Native
Int Function CheckEquipmentContext(Actor Target, Race ExpectedRace, Race PlannedRace, Int PlannedBody) Global Native

; API 4. Both calls return an empty array when the caller must use the legacy path.
Form[] Function ReadOutfitSnapshot(Actor Target, Form[] Worn, Form[] ProtectedItems, Armor Discarded) Global Native
Int[] Function PlanOutfitDifference(Armor[] Parts, Bool[] Enabled, Form[] Originals, Form[] ProtectedItems, Bool ReplaceHead, Bool HideAccessories, Bool Diagnostics) Global Native

; API 5. No inventory mutation or persistent game state in these queries.
Float[] Function ReadTransformBases(Actor Target) Global Native
Int[] Function ReadArmorState(Actor Target, Armor Item) Global Native
Function WatchPrimaryEquip(Int Owner, Int LoadEpoch, Int Slot, Armor Item, Float Elapsed) Global Native
Float[] Function TakePrimaryEquipTimes(Int Owner, Int LoadEpoch) Global Native

; API 6. Ticket lifetime is bounded by the current game/load and operation.
Int Function BeginEntryFlow(Int Owner, Int Epoch) Global Native
Int Function AdvanceEntryFlow(Int Ticket, Int Owner, Int Epoch, Int Completed) Global Native
Function CancelEntryFlow(Int Ticket) Global Native
