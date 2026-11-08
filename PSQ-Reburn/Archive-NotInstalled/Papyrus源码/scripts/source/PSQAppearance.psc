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
