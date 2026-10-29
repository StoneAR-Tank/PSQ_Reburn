Scriptname BCNGPSQBridge Hidden Native
; Optional local PSQ adapter, interface version 3. Requires the modified
; Body Change NG 1.3.7.3 provider; stock 1.3.7 has none of these natives.
; PSQ must verify that exact SKSE plugin revision before invoking any function.
Int Function GetVersion() Global Native
Bool Function IsReady() Global Native
String[] Function GetPresetIds(Actor Target) Global Native
String Function GetPresetName(String PresetId) Global Native
String Function FindPresetId(Actor Target, String PresetName) Global Native
Int Function ApplyTemporaryPreset(Actor Target, String PresetId) Global Native
Int Function ClearTemporaryPreset(Actor Target) Global Native
Int Function GetRequestStatus(Actor Target, Int Request) Global Native

; API2 shared real-refresh requests, never a clean-state permission.
Int Function RequestEquipmentMorphRefresh(Actor Target) Global Native
Int Function GetEquipmentMorphRefreshStatus(Actor Target, Int Ticket) Global Native

; API3: optional TRX skin catalogs and ownership-preserving selection restore.
String[] Function GetFutanariIds(Actor Target) Global Native
String Function GetFutanariName(String ProfileId) Global Native
String Function GetFutanariSelectionId(Actor Target) Global Native
Int Function GetFutanariSelectionMode(Actor Target) Global Native
Int Function RequestFutanariSkin(Actor Target, String ProfileId) Global Native
Int Function RestoreFutanariSelection(Actor Target, String ExpectedId, String OriginalId, Int OriginalMode) Global Native
