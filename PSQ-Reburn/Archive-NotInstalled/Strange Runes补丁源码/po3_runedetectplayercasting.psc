Scriptname PO3_RUNEDetectPlayerCasting extends activemagiceffect  

;======================================================================================;
;  PROPERTIES /
;=============/

import PO3_SKSEFunctions

Actor property PlayerRef auto

Art Heal01HandEffects
Art SoulTrapHandEffects 
Art DLC1_SunCloakSpellHandFX
Art IllusionPosFXHand01
Art IllusionNegFXHand01
Art DetectLifeFXHand01
Art FXLightSpellHandEffects
Art HealsMystFXHand01 
Art DLC2FXWhirlWindHandEffects
Art InvsFXHand01
Art TurnUndeadHandEffects

bool DoOnce = false
bool IsDualCasting = false
bool CurrentlyDualCasting = false
bool CastOnEquip = false

EffectShader property DLC1SunFireImpactFXShader auto
EffectShader property DLC1SunFireFXShader auto

GlobalVariable Property po3_RUNE_FFSpellsTogglePC Auto
GlobalVariable Property po3_RUNE_SelfSpellsTogglePC Auto
GlobalVariable Property po3_RUNE_ConcSpellsTogglePC Auto
GlobalVariable Property po3_RUNE_MasterSpellsToggle Auto
GlobalVariable Property po3_RUNE_ScrollsToggle Auto
GlobalVariable Property po3_RUNE_DualCastRunesToggle Auto
GlobalVariable Property po3_RUNE_CastOnEquipTogglePC Auto

float[] dualTranslate
float[] dualRotate
float dualScale = 3.1

int RightRuneType = -1
int LeftRuneType = -1 

;enum TYPES
int kRITUAL = 0
int kSPELL = 1
int kSCROLL = 2

;enum SPELL_TYPES
int kFIRE = 0
int kFROST = 1
int kSHOCK = 2
int kDRAIN = 3
int kRUNE_FIRE = 4
int kRUNE_FROST = 5
int kRUNE_SHOCK = 6
int kDEF_DESTRUCTION = 7
int kHEAL = 8
int kPOISON = 9
int kMYSTICHEAL = 10
int kTURNUNDEAD = 11
int kSUN = 12
int kWARD = 13
int kRUNE_POISON = 14
int kPARALYSIS = 15
int kARMOUR = 16
int kARMOUR_FIRE = 17
int kARMOUR_FROST = 18
int kARMOUR_POISON = 19
int kARMOUR_SHOCK = 20
int kDETECTLIFE = 21
int kGUIDE = 22
int kLIGHT = 23
int kTELEKINESIS = 24
int kDEF_ALTERATION = 25
int kRUNE_ASH = 26
int kFRENZY =  27
int kCALM = 28
int kDISPEL = 29
int kINVISIBILITY = 30
int kDEF_ILLUSION = 31
int kRUNE_FRENZY = 32
int kCONJURE_FIRE = 33
int kCONJURE_FROST = 34
int kCONJURE_SHOCK = 35
int kCONJURE_FAMILIAR = 36
int kREANIMATE = 37	
int kSOULTRAP = 38
int kBANISH = 39
int kBOUNDWEAPON = 40
int kDEF_CONJURATION = 41
;new
int kWEAK = 42
int kWEAK_FIRE = 43
int kWEAK_FROST = 44
int kWEAK_POISON = 45
int kWEAK_SHOCK = 46
int kWEAK_HEALS = 47
int kAIR = 48
int kWATER = 49
int kRUNE_EARTH = 50
int kCONJURE_WATER = 51
int kCONJURE_EARTH = 52
int kCONJURE_HEALS = 53
int kARMOUR_HEALS = 54

Light property MagicLightFrostHand01 auto
Light property MagicLightFireInHand auto
Light property MagicLightShockInHand auto
Light property MagicLightTelekinesisHand01 auto 

;destruction
Keyword property MagicDamageFire auto
Keyword property MagicDamageFrost auto
Keyword property MagicDamageShock auto
Keyword property MagicVampireDrain auto
;alteration
Keyword property MagicArmorSpell auto
Keyword property MagicParalysis auto
Keyword property MagicTelekinesis auto
;restoration
Keyword property MagicRestoreHealth auto
Keyword property MagicTrapPoison auto
Keyword property MagicAlchHarmful auto
Keyword property MagicTurnUndead auto
Keyword property MagicWard auto
;illusion
Keyword property MagicInfluenceFrenzy auto
Keyword property MagicInfluenceFear auto
Keyword property MagicInfluenceCharm auto
Keyword property MagicInfluence auto
Keyword property MagicInvisibility auto
;conjuration
Keyword property MagicSummonFire auto
Keyword property MagicSummonFrost auto
Keyword property MagicSummonShock auto
Keyword property MagicSummonFamiliar auto
Keyword property MagicSummonUndead auto
Keyword property DLC2MagicAshSpawn auto
;NONE
Keyword property DLC1VampireDrainEffect auto
;
Keyword property RitualSpellEffect auto
Keyword property RitualSpellIllusion auto
Keyword property MagicRune auto

Keyword[] property HandRuneTypes auto

MagicEffect property RestoreHealthFFActor auto
MagicEffect property SoulTrapFFActor auto
MagicEffect property DLC1SunLightFFSelf auto
MagicEffect property InfluenceAggDownFFAimed auto
MagicEffect property InfluenceAggUpFFAimed auto
MagicEffect property DetectLifeFriendInteriorSelfFF auto
MagicEffect property LightFFSelf auto
MagicEffect property po3_RUNE_MysticHealDummyEffect auto
MagicEffect property DLC2WhirlwindCloakFFSelf auto
MagicEffect property testPhilInvisibillityFFSelf auto
MagicEffect property TurnUndeadFFAimed25 auto

Scroll LeftScroll
Scroll RightScroll

Spell LeftSpell
Spell RightSpell
Spell LeftRune
Spell RightRune

Spell LeftWard
Spell RightWard

;destruction
Spell property po3_RUNE_DestructionLeft auto
Spell property po3_RUNE_DestructionRight auto
Spell property po3_RUNE_AirLeft auto
Spell property po3_RUNE_AirRight auto
Spell property po3_RUNE_DrainLeft auto
Spell property po3_RUNE_DrainRight auto
Spell property po3_RUNE_FireLeft auto
Spell property po3_RUNE_FireRight auto
Spell property po3_RUNE_FireRuneLeft auto
Spell property po3_RUNE_FireRuneRight auto
Spell property po3_RUNE_FrostLeft auto
Spell property po3_RUNE_FrostRight auto
Spell property po3_RUNE_FrostRuneLeft auto
Spell property po3_RUNE_FrostRuneRight auto
Spell property po3_RUNE_ShockLeft auto
Spell property po3_RUNE_ShockRight auto
Spell property po3_RUNE_ShockRuneLeft auto
Spell property po3_RUNE_ShockRuneRight auto
Spell property po3_RUNE_WaterLeft auto
Spell property po3_RUNE_WaterRight auto
Spell property po3_RUNE_EarthRuneLeft auto
Spell property po3_RUNE_EarthRuneRight auto

;alteration
Spell property po3_RUNE_AlterationLeft auto
Spell property po3_RUNE_AlterationRight auto
Spell property po3_RUNE_ArmourLeft auto
Spell property po3_RUNE_ArmourRight auto
Spell property po3_RUNE_ArmourFireLeft auto
Spell property po3_RUNE_ArmourFireRight auto
Spell property po3_RUNE_ArmourFrostLeft auto
Spell property po3_RUNE_ArmourFrostRight auto
Spell property po3_RUNE_ArmourHealsLeft auto
Spell property po3_RUNE_ArmourHealsRight auto
Spell property po3_RUNE_ArmourPoisonLeft auto
Spell property po3_RUNE_ArmourPoisonRight auto
Spell property po3_RUNE_ArmourShockLeft auto
Spell property po3_RUNE_ArmourShockRight auto
Spell property po3_RUNE_AshRuneLeft auto
Spell property po3_RUNE_AshRuneRight auto
Spell property po3_RUNE_DetectLifeLeft auto
Spell property po3_RUNE_DetectLifeRight auto
Spell property po3_RUNE_GuideLeft auto
Spell property po3_RUNE_GuideRight auto
Spell property po3_RUNE_LightLeft auto
Spell property po3_RUNE_LightRight auto
Spell property po3_RUNE_ParalyseLeft auto
Spell property po3_RUNE_ParalyseRight auto
Spell property po3_RUNE_TelekinesisLeft auto
Spell property po3_RUNE_TelekinesisRight auto
Spell property po3_RUNE_WeaknessLeft auto
Spell property po3_RUNE_WeaknessRight auto
Spell property po3_RUNE_WeaknessFireLeft auto
Spell property po3_RUNE_WeaknessFireRight auto
Spell property po3_RUNE_WeaknessFrostLeft auto
Spell property po3_RUNE_WeaknessFrostRight auto
Spell property po3_RUNE_WeaknessHealsLeft auto
Spell property po3_RUNE_WeaknessHealsRight auto
Spell property po3_RUNE_WeaknessPoisonLeft auto
Spell property po3_RUNE_WeaknessPoisonRight auto
Spell property po3_RUNE_WeaknessShockLeft auto
Spell property po3_RUNE_WeaknessShockRight auto

;restoration
Spell property po3_RUNE_ConjureHealsLeft auto
Spell property po3_RUNE_ConjureHealsRight auto
Spell property po3_RUNE_HealLeft auto
Spell property po3_RUNE_HealRight auto
Spell property po3_RUNE_MysticHealLeft auto
Spell property po3_RUNE_MysticHealRight auto
Spell property po3_RUNE_PoisonLeft auto
Spell property po3_RUNE_PoisonRight auto
Spell property po3_RUNE_PoisonRuneLeft auto
Spell property po3_RUNE_PoisonRuneRight auto
Spell property po3_RUNE_SunLeft auto
Spell property po3_RUNE_SunRight auto
Spell property po3_RUNE_TurnUndeadLeft auto
Spell property po3_RUNE_TurnUndeadRight auto
Spell property po3_RUNE_WardFX auto

;illusion
Spell property po3_RUNE_CalmLeft auto
Spell property po3_RUNE_CalmRight auto
Spell property po3_RUNE_DispelLeft auto
Spell property po3_RUNE_DispelRight auto
Spell property po3_RUNE_FrenzyLeft auto
Spell property po3_RUNE_FrenzyRight auto
Spell property po3_RUNE_FrenzyRuneLeft auto
Spell property po3_RUNE_FrenzyRuneRight auto
Spell property po3_RUNE_IllusionLeft auto
Spell property po3_RUNE_IllusionRight auto
Spell property po3_RUNE_InvisibilityLeft auto
Spell property po3_RUNE_InvisibilityRight auto

;conjuration
Spell property po3_RUNE_BanishLeft auto
Spell property po3_RUNE_BanishRight auto
Spell property po3_RUNE_BoundWeaponLeft auto
Spell property po3_RUNE_BoundWeaponRight auto
Spell property po3_RUNE_ConjureEarthLeft auto
Spell property po3_RUNE_ConjureEarthRight auto
Spell property po3_RUNE_ConjureLeft auto
Spell property po3_RUNE_ConjureRight auto
Spell property po3_RUNE_ConjureFamiliarLeft auto
Spell property po3_RUNE_ConjureFamiliarRight auto
Spell property po3_RUNE_ConjureFireLeft auto
Spell property po3_RUNE_ConjureFireRight auto
Spell property po3_RUNE_ConjureFrostLeft auto
Spell property po3_RUNE_ConjureFrostRight auto
Spell property po3_RUNE_ConjureShockLeft auto
Spell property po3_RUNE_ConjureShockRight auto
Spell property po3_RUNE_ConjureWaterLeft auto
Spell property po3_RUNE_ConjureWaterRight auto
Spell property po3_RUNE_ReanimateLeft auto
Spell property po3_RUNE_ReanimateRight auto
Spell property po3_RUNE_SoulTrapLeft auto
Spell property po3_RUNE_SoulTrapRight auto

;RITUAL SPELLS
;destruction
Spell property po3_RUNE_DestructionRitual auto
Spell property po3_RUNE_AirRitual auto
Spell property po3_RUNE_DrainRitual auto
Spell property po3_RUNE_FireRitual auto
Spell property po3_RUNE_FrostRitual auto
Spell property po3_RUNE_ShockRitual auto
Spell property po3_RUNE_WaterRitual auto

;alteration
Spell property po3_RUNE_AlterationRitual auto
Spell property po3_RUNE_ArmourRitual auto
Spell property po3_RUNE_ArmourFireRitual auto
Spell property po3_RUNE_ArmourFrostRitual auto
Spell property po3_RUNE_ArmourHealsRitual auto
Spell property po3_RUNE_ArmourPoisonRitual auto
Spell property po3_RUNE_ArmourShockRitual auto
Spell property po3_RUNE_WeaknessRitual auto
Spell property po3_RUNE_WeaknessFireRitual auto
Spell property po3_RUNE_WeaknessFrostRitual auto
Spell property po3_RUNE_WeaknessHealsRitual auto
Spell property po3_RUNE_WeaknessPoisonRitual auto
Spell property po3_RUNE_WeaknessShockRitual auto
Spell property po3_RUNE_DetectLifeRitual auto
Spell property po3_RUNE_ParalyseRitual auto
Spell property po3_RUNE_TelekinesisRitual auto

;restoration
Spell property po3_RUNE_ConjureHealsRitual auto
Spell property po3_RUNE_HealRitual auto
Spell property po3_RUNE_MysticHealRitual auto
Spell property po3_RUNE_PoisonRitual auto
Spell property po3_RUNE_SunRitual auto
Spell property po3_RUNE_TurnUndeadRitual auto

;illusion
Spell property po3_RUNE_CalmRitual auto
Spell property po3_RUNE_FrenzyRitual auto
Spell property po3_RUNE_IllusionRitual auto
Spell property po3_RUNE_DispelRitual auto

;conjuration
Spell property po3_RUNE_BanishRitual auto
Spell property po3_RUNE_ConjureEarthRitual auto
Spell property po3_RUNE_ConjureRitual auto
Spell property po3_RUNE_ConjureFamiliarRitual auto
Spell property po3_RUNE_ConjureFireRitual auto
Spell property po3_RUNE_ConjureFrostRitual auto
Spell property po3_RUNE_ConjureShockRitual auto
Spell property po3_RUNE_ConjureWaterRitual auto
Spell property po3_RUNE_ReanimateRitual auto
Spell property po3_RUNE_SoulTrapRitual auto

String nodeName = "MagicEffectsNode"

;======================================================================================;
;  EVENTS  /
;=============/

;=================== EVENT ONEFFECTSTART() ====================

Event OnEffectStart(Actor akTarget, Actor akCaster)

	RegisterForAnimationEvent(PlayerRef, "BeginCastRight")
	RegisterForAnimationEvent(PlayerRef, "BeginCastLeft")
	RegisterForAnimationEvent(PlayerRef, "MRh_SpellFire_Event") 
	RegisterForAnimationEvent(PlayerRef, "MLh_SpellFire_Event") 
	RegisterForAnimationEvent(PlayerRef, "CastStop")
	RegisterForAnimationEvent(PlayerRef, "weaponDraw")
	RegisterForAnimationEvent(PlayerRef, "weaponSheathe")

	;------------------VARIABLES----------------------------	
	Heal01HandEffects = RestoreHealthFFActor.GetCastingArt()
	HealsMystFXHand01 = po3_RUNE_MysticHealDummyEffect.GetCastingArt()
	SoulTrapHandEffects = SoulTrapFFActor.GetCastingArt()
	DLC1_SunCloakSpellHandFX = DLC1SunLightFFSelf.GetCastingArt()
	IllusionPosFXHand01 = InfluenceAggDownFFAimed.GetCastingArt()
	DetectLifeFXHand01 = DetectLifeFriendInteriorSelfFF.GetCastingArt()
	FXLightSpellHandEffects = LightFFSelf.GetCastingArt()
	IllusionNegFXHand01 = InfluenceAggUpFFAimed.GetCastingArt()	
	DLC2FXWhirlWindHandEffects = DLC2WhirlwindCloakFFSelf.GetCastingArt()
	InvsFXHand01 = testPhilInvisibillityFFSelf.GetCastingArt()
	TurnUndeadHandEffects = TurnUndeadFFAimed25.GetCastingArt()
	
	RegisterForModEvent("StrangeRunes_DualCastSettings", "OnDualCastSettingsChanged")
	;-----------------------------------------------------------
	
	dualTranslate = new float[3]
	dualTranslate[0] = 0.0
	dualTranslate[1] = 64.0
	dualTranslate[2] = 24.000000
	
	dualRotate = new float[3]
	dualRotate[0] = 180.0
	dualRotate[1] = 0.0
	dualRotate[2] = 0.0
				
endEvent

;=================== EVENT ONPLAYERLOADGAME() ====================

Event OnPlayerLoadGame()

	RegisterForAnimationEvent(PlayerRef, "BeginCastRight")
	RegisterForAnimationEvent(PlayerRef, "BeginCastLeft")
	RegisterForAnimationEvent(PlayerRef, "MRh_SpellFire_Event") 
	RegisterForAnimationEvent(PlayerRef, "MLh_SpellFire_Event") 
	RegisterForAnimationEvent(PlayerRef, "CastStop")
	RegisterForAnimationEvent(PlayerRef, "weaponDraw")
	RegisterForAnimationEvent(PlayerRef, "weaponSheathe")

	UnregisterForAllModEvents()
	RegisterForModEvent("StrangeRunes_DualCastSettings", "OnDualCastSettingsChanged")

	;------------------VARIABLES----------------------------
	if !Heal01HandEffects
		Heal01HandEffects = RestoreHealthFFActor.GetCastingArt()
	endif
	if HealsMystFXHand01
		HealsMystFXHand01 = po3_RUNE_MysticHealDummyEffect.GetCastingArt()
	endif
	if !SoulTrapHandEffects
		SoulTrapHandEffects = SoulTrapFFActor.GetCastingArt()
	endif
	if !DLC1_SunCloakSpellHandFX
		DLC1_SunCloakSpellHandFX = DLC1SunLightFFSelf.GetCastingArt()
	endif
	if !IllusionPosFXHand01
		IllusionPosFXHand01 = InfluenceAggDownFFAimed.GetCastingArt()
	endif
	if !DetectLifeFXHand01
		DetectLifeFXHand01 = DetectLifeFriendInteriorSelfFF.GetCastingArt()
	endif
	if !FXLightSpellHandEffects
		FXLightSpellHandEffects = LightFFSelf.GetCastingArt()
	endif
	if !IllusionNegFXHand01
		IllusionNegFXHand01 = InfluenceAggUpFFAimed.GetCastingArt()
	endif
	if !DLC2FXWhirlWindHandEffects
		DLC2FXWhirlWindHandEffects = DLC2WhirlwindCloakFFSelf.GetCastingArt()
	endif
	if !InvsFXHand01
		InvsFXHand01 = testPhilInvisibillityFFSelf.GetCastingArt()
	endif	
	if !TurnUndeadHandEffects
		TurnUndeadHandEffects = TurnUndeadFFAimed25.GetCastingArt()
	endif
	;-----------------------------------------------------------
	
endEvent

;=================== EVENT ONRACESWITCHCOMPLETE() ====================

Event OnRaceSwitchComplete()

	Utility.Wait(1.0)	
	
	RegisterForAnimationEvent(PlayerRef, "BeginCastRight")
	RegisterForAnimationEvent(PlayerRef, "BeginCastLeft")
	RegisterForAnimationEvent(PlayerRef, "MRh_SpellFire_Event") 
	RegisterForAnimationEvent(PlayerRef, "MLh_SpellFire_Event") 
	RegisterForAnimationEvent(PlayerRef, "CastStop")
	RegisterForAnimationEvent(PlayerRef, "weaponDraw")
	RegisterForAnimationEvent(PlayerRef, "weaponSheathe")
		
endEvent

;=================== EVENT ONDUALCASTSETTINGSCHANGED() ====================

Function OnDualCastSettingsChanged(String asNodeName, float tX, float tY, float tZ, float rX, float rY, float rZ, float scale)

	nodeName = asNodeName
	dualTranslate[0] = tX
	dualTranslate[1] = tY
	dualTranslate[2] = tZ
	
	dualRotate[0] = rX
	dualRotate[1] = rY
	dualRotate[2] = rZ
	
	dualScale = scale

EndFunction

;================ EVENT ONOBJECTEQUIPPED() ================================== 

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)

	if (akBaseObject as Spell || akBaseObject as Scroll) && po3_RUNE_CastOnEquipTogglePC.GetValue() == 1.0 && PlayerRef.GetAnimationVariableBool("IsEquipping")
	
		if PlayerRef.GetEquippedObject(0) == akBaseObject 
			CastStrangeRunes(0)
		elseif PlayerRef.GetEquippedObject(1) == akBaseObject 
			CastStrangeRunes(1)
		endif
	
	endif

endEvent

;=================== EVENT ONANIMATIONEVENT() ====================

Event OnAnimationEvent(ObjectReference akSource, string asEventName)

	if akSource == PlayerRef 

		CastOnEquip = po3_RUNE_CastOnEquipTogglePC.GetValue() == 1.0;
		isDualCasting = PlayerRef.GetAnimationVariableBool("IsCastingDual") && po3_RUNE_DualCastRunesToggle.GetValue() == 1.0
		
		if asEventName == "weaponDraw"
		
			if CastOnEquip
			
				;prevents ward spells from casting light on equip
				CastStrangeRunes(0, "weaponDraw")
				CastStrangeRunes(1, "weaponDraw")
			
			endif
		
		elseif asEventName == "BeginCastLeft" ; casting left	
																									
			if isDualCasting && !CurrentlyDualCasting		
				
				CastDualCastRune()				
				CurrentlyDualCasting = true
				
			elseif !CastOnEquip || !LeftRune
			
				CastStrangeRunes(0)
								
			endif
																		
		elseif asEventName == "BeginCastRight"
							
			if isDualCasting && !CurrentlyDualCasting
			
				if !LeftRune
				
					CastDualCastRune()					
					CurrentlyDualCasting = true

				endif
				
				if RightRune
					PlayerRef.RemoveSpell(RightRune)	
					RightRune = None
				endif				
				
			elseif !CastOnEquip || !RightRune
			
				CastStrangeRunes(1)	
				
			endif
						
		elseif asEventName == "MRh_SpellFire_Event" ; right spell fired
		
			if RightSpell && !CastOnEquip
			
				MagicEffect akEffect = RightSpell.GetNthEffectMagicEffect(RightSpell.GetCostliestEffectIndex())			
				if akEffect.GetCastingType() ==  1 
					Utility.Wait(0.1)
					PlayerRef.RemoveSpell(RightRune)
					RightRune = None
				endif
				
			elseif RightScroll
			
				PlayerRef.RemoveSpell(RightRune)	
				RightRune = None
				
			endif
					
		elseif asEventName == "MLh_SpellFire_Event" ; left spell fired
												
			if isDualCasting && !CurrentlyDualCasting

				CastDualCastRune()																				
				CurrentlyDualCasting = true
					
			endif
											
			if LeftSpell && !CastOnEquip
				
				MagicEffect akEffect = LeftSpell.GetNthEffectMagicEffect(LeftSpell.GetCostliestEffectIndex())			
				if akEffect.GetCastingType() ==  1
					Utility.Wait(0.1)
					PlayerRef.RemoveSpell(LeftRune)	
					LeftRune = None
				endif
				
			elseif LeftScroll
			
				PlayerRef.RemoveSpell(LeftRune)	
				LeftRune = None
				
			endif
				
		elseif asEventName == "CastStop" ; only if caster has enough magic
								
			if CurrentlyDualCasting && !IsDualCasting
				PlayerRef.RemoveSpell(LeftRune)
				LeftRune = None					
				CurrentlyDualCasting = false
			endif
													
			if LeftWard 
				PlayerRef.RemoveSpell(po3_RUNE_WardFX)
				LeftRune = None	
				LeftWard = None
			endif
			
			if RightWard
				PlayerRef.RemoveSpell(RightRune)
				RightRune = None
				RightWard = None
			endif
								
			if !CastOnEquip &&PlayerRef.GetActorValuePercentage("Magicka") <= 0.01
							
				LeftRune = None			
				RightRune = None
				
				RemoveAllRunes()
				
			endif
					
		elseif asEventName == "weaponSheathe" ; spell sheathed
									
			PSQRemoveRoseRunes(-1)
            if LeftRune || RightRune
			
				LeftRune = None			
				RightRune = None				
				LeftWard = None
				RightWard = None
				
				RemoveAllRunes()
				
			endif
							
		endif
		
	endif
	
endEvent

;================ EVENT ONOBJECTUNEQUIPPED() ================================== 

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	
	if (akBaseObject as Spell || akBaseObject as Scroll)
	
		Form leftEquip =  PlayerRef.GetEquippedObject(0)
		Form rightEquip =  PlayerRef.GetEquippedObject(1)
		
		if LeftSpell && akBaseObject == LeftSpell || LeftScroll && akBaseObject == LeftScroll
			
			if LeftSpell && leftEquip != LeftSpell || LeftScroll && leftEquip != LeftScroll
			
				RemoveAllRunesOnHand(0)
							
				LeftRune = None
				LeftSpell = None
				LeftScroll = None
				LeftWard = None
				
			endif
			
		endif
			
		if RightSpell && akBaseObject == RightSpell || RightScroll && akBaseObject == RightScroll
		
			if RightSpell && RightEquip != RightSpell || RightScroll && RightEquip != RightScroll
			
				RemoveAllRunesOnHand(1)
						
				RightRune = None
				RightSpell = None
				RightScroll = None
				RightWard = None
				
			endif
			
		endif				
		
	endif
	
endEvent

;================ EVENT ONEFFECTFINISH() ================================== 

Event OnEffectFinish(Actor akTarget, Actor akCaster)

	LeftSpell = None
	LeftRune = None
	LeftWard = None
	RightSpell = None
	RightRune = None
	RightWard = None
	
	RemoveAllRunes()
		
endEvent

;======================================================================================;
;  FUNCTIONS  /
;=============/

Function RemoveAllRunes()
    PSQRemoveRoseRunes(-1)
		
	;function is too fast, this slows down execution just enough for sheathing animation to progress
	Utility.Wait(0.1)
	
	RemoveAddedSpells(PlayerRef, "StrangeRunes.esp", handRuneTypes, false)
	
endFunction

Function RemoveAllRunesOnHand(int handType)
    PSQRemoveRoseRunes(handType)

	Keyword[] singleHand = new Keyword[1]	
	if handType == 0
		singleHand[0] = HandRuneTypes[0]
	else
		singleHand[0] = HandRuneTypes[1]
	endif
	
	Utility.Wait(0.1)
	
	RemoveAddedSpells(PlayerRef, "StrangeRunes.esp", singleHand, false)
	
endFunction

;CAST

Bool Function CastStrangeRunes(int handType, String animationEvent = "")
    Spell equipped = PlayerRef.GetEquippedSpell(handType)
    If equipped
        Int localID = Math.LogicalAnd(equipped.GetFormID(), 0x00FFFFFF)
        If (localID >= 0xE8D && localID <= 0xE97) || localID == 0xB700
            If Game.GetFormFromFile(localID, "PSQ PlayerSuccubusQuest.esm") == equipped
                Int category = GetSpellType(equipped)
                If category == -1
                    Return False
                EndIf
                Int slot = handType
                Int element = (localID - 0xE8D) % 3
                If localID == 0xB700
                    element = 2
                EndIf
                If category == kRITUAL
                    slot = 2
                EndIf
                Spell pink = Game.GetFormFromFile(0x810 + slot * 3 + element, "PSQ - Strange Runes.esp") as Spell
                If pink
                    If handType == 0
                        If LeftRune && LeftRune != pink
                            PlayerRef.RemoveSpell(LeftRune)
                        EndIf
                        LeftSpell = equipped
                        LeftRune = pink
                        LeftRuneType = element
                    Else
                        If RightRune && RightRune != pink
                            PlayerRef.RemoveSpell(RightRune)
                        EndIf
                        RightSpell = equipped
                        RightRune = pink
                        RightRuneType = element
                    EndIf
                    PlayerRef.AddSpell(pink, False)
                    Debug.Trace("[PSQ] RoseRune hand=" + handType + " spell=" + equipped + " rune=" + pink)
                    Return True
                EndIf
            EndIf
        EndIf
    EndIf


	if handType == 0
				
		Form LeftMagicCast = PlayerRef.GetEquippedObject(0)	
		int spellType = GetSpellType(LeftMagicCast)
		
		if spellType == -1
			return false;
		endif
			
		LeftRuneType = GetRuneType(LeftMagicCast)
								
		if spellType == kRITUAL
											
			LeftSpell = LeftMagicCast as Spell				
			
			;===================================================
			;DESTRUCTION				
			;===================================================
			
			if LeftRuneType == kFIRE
				LeftRune = CastSimpleRune(po3_RUNE_FireRitual)
			elseif LeftRuneType == kFROST
				LeftRune = CastSimpleRune(po3_RUNE_FrostRitual)
			elseif LeftRuneType == kSHOCK
				LeftRune = CastSimpleRune(po3_RUNE_ShockRitual)
			elseif LeftRuneType == kDRAIN
				LeftRune = CastSimpleRune(po3_RUNE_DrainRitual)
			elseif LeftRuneType == kAIR
				LeftRune = CastSimpleRune(po3_RUNE_AirRitual)
			elseif LeftRuneType == kWATER
				LeftRune = CastSimpleRune(po3_RUNE_WaterRitual)
			elseif LeftRuneType == kDEF_DESTRUCTION
				LeftRune = CastSimpleRune(po3_RUNE_DestructionRitual)
			
			;===================================================
			;RESTORATION	
			;===================================================
			
			elseif LeftRuneType == kSUN 
				LeftRune = CastSimpleRune(po3_RUNE_SunRitual)
			elseif LeftRuneType == kHEAL
				LeftRune = CastSimpleRune(po3_RUNE_HealRitual)
			elseif LeftRuneType == kPOISON
				LeftRune = CastSimpleRune(po3_RUNE_PoisonRitual)
			elseif LeftRuneType == kMYSTICHEAL
				LeftRune = CastSimpleRune(po3_RUNE_MysticHealRitual)
			elseif LeftRuneType == kTURNUNDEAD
				LeftRune = CastSimpleRune(po3_RUNE_TurnUndeadRitual)
			elseif LeftRuneType == kCONJURE_HEALS 
				LeftRune = CastSimpleRune(po3_RUNE_ConjureHealsRitual)
			;/elseif LeftRuneType == kWARD
				LeftRune = CastSimpleRune(po3_RUNE_WardFX)
				LeftWard = LeftSpell/;
			
			;===================================================
			;ALTERATION
			;===================================================
			
			elseif LeftRuneType == kPARALYSIS
				LeftRune = CastSimpleRune(po3_RUNE_ParalyseRitual)
			elseif LeftRuneType == kARMOUR 
				LeftRune = CastSimpleRune(po3_RUNE_ArmourRitual)
			elseif LeftRuneType == kARMOUR_FIRE
				LeftRune = CastSimpleRune(po3_RUNE_ArmourFireRitual)
			elseif LeftRuneType == kARMOUR_FROST
				LeftRune = CastSimpleRune(po3_RUNE_ArmourFrostRitual)
			elseif LeftRuneType == kARMOUR_HEALS
				LeftRune = CastSimpleRune(po3_RUNE_ArmourHealsRitual)
			elseif LeftRuneType == kARMOUR_POISON
				LeftRune = CastSimpleRune(po3_RUNE_ArmourPoisonRitual)
			elseif LeftRuneType == kARMOUR_SHOCK
				LeftRune = CastSimpleRune(po3_RUNE_ArmourShockRitual)
			elseif LeftRuneType == kWEAK 
				LeftRune = CastSimpleRune(po3_RUNE_WeaknessRitual)
			elseif LeftRuneType == kWEAK_FIRE
				LeftRune = CastSimpleRune(po3_RUNE_WeaknessFireRitual)
			elseif LeftRuneType == kWEAK_FROST
				LeftRune = CastSimpleRune(po3_RUNE_WeaknessFrostRitual)
			elseif LeftRuneType == kWEAK_HEALS
				LeftRune = CastSimpleRune(po3_RUNE_WeaknessHealsRitual)
			elseif LeftRuneType == kWEAK_POISON
				LeftRune = CastSimpleRune(po3_RUNE_WeaknessPoisonRitual)
			elseif LeftRuneType == kWEAK_SHOCK
				LeftRune = CastSimpleRune(po3_RUNE_WeaknessShockRitual)
			elseif LeftRuneType == kDETECTLIFE
				LeftRune = CastSimpleRune(po3_RUNE_DetectLifeRitual)
			elseif LeftRuneType == kTELEKINESIS
				LeftRune = CastSimpleRune(po3_RUNE_TelekinesisRitual)
			elseif LeftRuneType == kDEF_ALTERATION		
				LeftRune = CastSimpleRune(po3_RUNE_AlterationRitual)
			
			;===================================================
			;ILLUSION
			;===================================================
			
			elseif LeftRuneType == kFRENZY		
				LeftRune = CastSimpleRune(po3_RUNE_FrenzyRitual)
			elseif LeftRuneType == kCALM
				LeftRune = CastSimpleRune(po3_RUNE_CalmRitual)
			elseif LeftRuneType == kDISPEL
				LeftRune = CastSimpleRune(po3_RUNE_DispelRitual)
			elseif LeftRuneType == kDEF_ILLUSION
				LeftRune = CastSimpleRune(po3_RUNE_IllusionRitual)
				
			;===================================================
			;CONJURATION
			;===================================================
			
			elseif LeftRuneType == kCONJURE_EARTH
				LeftRune = CastSimpleRune(po3_RUNE_ConjureEarthRitual)
			elseif LeftRuneType == kCONJURE_FIRE
				LeftRune = CastSimpleRune(po3_RUNE_ConjureFireRitual)
			elseif LeftRuneType == kCONJURE_FROST
				LeftRune = CastSimpleRune(po3_RUNE_ConjureFrostRitual)
			elseif LeftRuneType == kCONJURE_SHOCK
				LeftRune = CastSimpleRune(po3_RUNE_ConjureShockRitual)
			elseif LeftRuneType == kCONJURE_FAMILIAR
				LeftRune = CastSimpleRune(po3_RUNE_ConjureFamiliarRitual)
			elseif LeftRuneType == kCONJURE_WATER
				LeftRune = CastSimpleRune(po3_RUNE_ConjureWaterRitual)
			elseif LeftRuneType == kREANIMATE
				LeftRune = CastSimpleRune(po3_RUNE_ReanimateRitual)			
			elseif LeftRuneType == kSOULTRAP
				LeftRune = CastSimpleRune(po3_RUNE_SoulTrapRitual)
			elseif LeftRuneType == kBANISH
				LeftRune = CastSimpleRune(po3_RUNE_BanishRitual)
			elseif LeftRuneType == kDEF_CONJURATION
				LeftRune = CastSimpleRune(po3_RUNE_ConjureRitual)
			endif
				
		else
			
			if spellType == kSPELL 
				LeftSpell = LeftMagicCast as Spell
			elseif spellType == kSCROLL
				LeftScroll = LeftMagicCast as Scroll
			endif
			
			;===================================================
			;DESTRUCTION				
			;===================================================
			
			if LeftRuneType == kFIRE
				LeftRune = CastSimpleRune(po3_RUNE_FireLeft)
			elseif LeftRuneType == kFROST
				LeftRune = CastSimpleRune(po3_RUNE_FrostLeft)
			elseif LeftRuneType == kSHOCK
				LeftRune = CastSimpleRune(po3_RUNE_ShockLeft)
			elseif LeftRuneType == kDRAIN
				LeftRune = CastSimpleRune(po3_RUNE_DrainLeft)
			elseif LeftRuneType == kAIR
				LeftRune = CastSimpleRune(po3_RUNE_AirLeft)
			elseif LeftRuneType == kWATER
				LeftRune = CastSimpleRune(po3_RUNE_WaterLeft)
			elseif LeftRuneType == kDEF_DESTRUCTION
				LeftRune = CastSimpleRune(po3_RUNE_DestructionLeft)
		
			elseif LeftRuneType == kRUNE_FIRE
				LeftRune = CastSimpleRune(po3_RUNE_FireRuneLeft)
			elseif LeftRuneType == kRUNE_FROST
				LeftRune = CastSimpleRune(po3_RUNE_FrostRuneLeft)
			elseif LeftRuneType == kRUNE_SHOCK
				LeftRune = CastSimpleRune(po3_RUNE_ShockRuneLeft)
			elseif LeftRuneType == kRUNE_EARTH
				LeftRune = CastSimpleRune(po3_RUNE_EarthRuneLeft)
			
			;===================================================
			;RESTORATION			
			;===================================================
			
			elseif LeftRuneType == kSUN 
				LeftRune = CastSimpleRune(po3_RUNE_SunLeft)
			elseif LeftRuneType == kHEAL
				LeftRune = CastSimpleRune(po3_RUNE_HealLeft)
			elseif LeftRuneType == kRUNE_POISON
				LeftRune = CastSimpleRune(po3_RUNE_PoisonRuneLeft)
			elseif LeftRuneType == kPOISON
				LeftRune = CastSimpleRune(po3_RUNE_PoisonLeft)
			elseif LeftRuneType == kMYSTICHEAL
				LeftRune = CastSimpleRune(po3_RUNE_MysticHealLeft)
			elseif LeftRuneType == kTURNUNDEAD
				LeftRune = CastSimpleRune(po3_RUNE_TurnUndeadLeft)
			elseif LeftRuneType == kCONJURE_HEALS
				LeftRune = CastSimpleRune(po3_RUNE_ConjureHealsLeft)
			elseif LeftRuneType == kWARD
				if animationEvent != "weaponDraw"
					LeftRune = CastSimpleRune(po3_RUNE_WardFX)
					LeftWard = LeftSpell
				endif
			
			;===================================================
			;ALTERATION				
			;===================================================
			
			elseif LeftRuneType == kRUNE_ASH
				LeftRune = CastSimpleRune(po3_RUNE_AshRuneLeft)
			elseif LeftRuneType == kPARALYSIS
				LeftRune = CastSimpleRune(po3_RUNE_ParalyseLeft)
			elseif LeftRuneType == kARMOUR 
				LeftRune = CastSimpleRune(po3_RUNE_ArmourLeft)
			elseif LeftRuneType == kARMOUR_FIRE
				LeftRune = CastSimpleRune(po3_RUNE_ArmourFireLeft)
			elseif LeftRuneType == kARMOUR_FROST
				LeftRune = CastSimpleRune(po3_RUNE_ArmourFrostLeft)
			elseif LeftRuneType == kARMOUR_HEALS
				LeftRune = CastSimpleRune(po3_RUNE_ArmourHealsLeft)
			elseif LeftRuneType == kARMOUR_POISON
				LeftRune = CastSimpleRune(po3_RUNE_ArmourPoisonLeft)
			elseif LeftRuneType == kARMOUR_SHOCK
				LeftRune = CastSimpleRune(po3_RUNE_ArmourShockLeft)
			elseif LeftRuneType == kDETECTLIFE
				LeftRune = CastSimpleRune(po3_RUNE_DetectLifeLeft)
			elseif LeftRuneType == kGUIDE
				LeftRune = CastSimpleRune(po3_RUNE_GuideLeft)
			elseif LeftRuneType == kLIGHT
				LeftRune = CastSimpleRune(po3_RUNE_LightLeft)
			elseif LeftRuneType == kTELEKINESIS
				LeftRune = CastSimpleRune(po3_RUNE_TelekinesisLeft)
			elseif LeftRuneType == kWEAK 
				LeftRune = CastSimpleRune(po3_RUNE_WeaknessLeft)
			elseif LeftRuneType == kWEAK_FIRE
				LeftRune = CastSimpleRune(po3_RUNE_WeaknessFireLeft)
			elseif LeftRuneType == kWEAK_FROST
				LeftRune = CastSimpleRune(po3_RUNE_WeaknessFrostLeft)
			elseif LeftRuneType == kWEAK_HEALS
				LeftRune = CastSimpleRune(po3_RUNE_WeaknessHealsLeft)
			elseif LeftRuneType == kWEAK_POISON
				LeftRune = CastSimpleRune(po3_RUNE_WeaknessPoisonLeft)
			elseif LeftRuneType == kWEAK_SHOCK
				LeftRune = CastSimpleRune(po3_RUNE_WeaknessShockLeft)
			elseif LeftRuneType == kDEF_ALTERATION		
				LeftRune = CastSimpleRune(po3_RUNE_AlterationLeft)
			
			;===================================================
			;ILLUSION				
			;===================================================
			
			elseif LeftRuneType == kRUNE_FRENZY		
				LeftRune = CastSimpleRune(po3_RUNE_FrenzyRuneLeft)
			elseif LeftRuneType == kFRENZY		
				LeftRune = CastSimpleRune(po3_RUNE_FrenzyLeft)
			elseif LeftRuneType == kCALM
				LeftRune = CastSimpleRune(po3_RUNE_CalmLeft)	
			elseif LeftRuneType == kINVISIBILITY
				LeftRune = CastSimpleRune(po3_RUNE_InvisibilityLeft)
			elseif LeftRuneType == kDISPEL
				LeftRune = CastSimpleRune(po3_RUNE_DispelLeft)
			elseif LeftRuneType == kDEF_ILLUSION
				LeftRune = CastSimpleRune(po3_RUNE_IllusionLeft)	
			
			;===================================================
			;CONJURATION				
			;===================================================
			
			elseif LeftRuneType == kCONJURE_FIRE
				LeftRune = CastSimpleRune(po3_RUNE_ConjureFireLeft)
			elseif LeftRuneType == kCONJURE_FROST
				LeftRune = CastSimpleRune(po3_RUNE_ConjureFrostLeft)
			elseif LeftRuneType == kCONJURE_SHOCK
				LeftRune = CastSimpleRune(po3_RUNE_ConjureShockLeft)
			elseif LeftRuneType == kCONJURE_FAMILIAR
				LeftRune = CastSimpleRune(po3_RUNE_ConjureFamiliarLeft)
			elseif LeftRuneType == kCONJURE_WATER
				LeftRune = CastSimpleRune(po3_RUNE_ConjureWaterLeft)
			elseif LeftRuneType == kCONJURE_EARTH
				LeftRune = CastSimpleRune(po3_RUNE_ConjureEarthLeft)
			elseif LeftRuneType == kREANIMATE
				LeftRune = CastSimpleRune(po3_RUNE_ReanimateLeft)				
			elseif LeftRuneType == kSOULTRAP
				LeftRune = CastSimpleRune(po3_RUNE_SoulTrapLeft)
			elseif LeftRuneType == kBANISH
				LeftRune = CastSimpleRune(po3_RUNE_BanishLeft)
			elseif LeftRuneType == kBOUNDWEAPON
				LeftRune = CastSimpleRune(po3_RUNE_BoundWeaponLeft)
			elseif LeftRuneType == kDEF_CONJURATION
				LeftRune = CastSimpleRune(po3_RUNE_ConjureLeft)
			endif							
			
		endif
			
	else
							
		Form RightMagicCast = PlayerRef.GetEquippedObject(1) 
		int spellType = GetSpellType(RightMagicCast)
		
		if spellType == -1 || spellType == kRITUAL
			return false
		endif
		
		RightRuneType = GetRuneType(RightMagicCast)
									
		if spellType == kSPELL 
			RightSpell = RightMagicCast as Spell
		elseif spellType == kSCROLL
			RightScroll = RightMagicCast as Scroll
		endif
		
		;===================================================
		;DESTRUCTION				
		;===================================================
		
		if RightRuneType == kFIRE
			RightRune = CastSimpleRune(po3_RUNE_FireRight)
		elseif RightRuneType == kFROST
			RightRune = CastSimpleRune(po3_RUNE_FrostRight)
		elseif RightRuneType == kSHOCK
			RightRune = CastSimpleRune(po3_RUNE_ShockRight)
		elseif RightRuneType == kDRAIN
			RightRune = CastSimpleRune(po3_RUNE_DrainRight)
		elseif RightRuneType == kAIR
			RightRune = CastSimpleRune(po3_RUNE_AirRight)
		elseif RightRuneType == kWATER
			RightRune = CastSimpleRune(po3_RUNE_WaterRight)
		elseif RightRuneType == kDEF_DESTRUCTION
			RightRune = CastSimpleRune(po3_RUNE_DestructionRight)
	
		elseif RightRuneType == kRUNE_FIRE
			RightRune = CastSimpleRune(po3_RUNE_FireRuneRight)
		elseif RightRuneType == kRUNE_FROST
			RightRune = CastSimpleRune(po3_RUNE_FrostRuneRight)
		elseif RightRuneType == kRUNE_SHOCK
			RightRune = CastSimpleRune(po3_RUNE_ShockRuneRight)
		elseif RightRuneType == kRUNE_EARTH
			RightRune = CastSimpleRune(po3_RUNE_EarthRuneRight)
		
		;===================================================
		;RESTORATION			
		;===================================================
		
		elseif RightRuneType == kSUN 
			RightRune = CastSimpleRune(po3_RUNE_SunRight)
		elseif RightRuneType == kHEAL
			RightRune = CastSimpleRune(po3_RUNE_HealRight)
		elseif RightRuneType == kRUNE_POISON
			RightRune = CastSimpleRune(po3_RUNE_PoisonRuneRight)
		elseif RightRuneType == kPOISON
			RightRune = CastSimpleRune(po3_RUNE_PoisonRight)
		elseif RightRuneType == kMYSTICHEAL
			RightRune = CastSimpleRune(po3_RUNE_MysticHealRight)
		elseif RightRuneType == kTURNUNDEAD
			RightRune = CastSimpleRune(po3_RUNE_TurnUndeadRight)
		elseif RightRuneType == kCONJURE_HEALS
			RightRune = CastSimpleRune(po3_RUNE_ConjureHealsRight)
		elseif RightRuneType == kWARD && animationEvent != "weaponDraw"
			RightRune = CastSimpleRune(po3_RUNE_WardFX)
			RightWard = RightSpell
		
		;===================================================
		;ALTERATION				
		;===================================================
		
		elseif RightRuneType == kRUNE_ASH
			RightRune = CastSimpleRune(po3_RUNE_AshRuneRight)
		elseif RightRuneType == kPARALYSIS
			RightRune = CastSimpleRune(po3_RUNE_ParalyseRight)
		elseif RightRuneType == kARMOUR 
			RightRune = CastSimpleRune(po3_RUNE_ArmourRight)
		elseif RightRuneType == kARMOUR_FIRE
			RightRune = CastSimpleRune(po3_RUNE_ArmourFireRight)
		elseif RightRuneType == kARMOUR_FROST
			RightRune = CastSimpleRune(po3_RUNE_ArmourFrostRight)
		elseif RightRuneType == kARMOUR_HEALS
			RightRune = CastSimpleRune(po3_RUNE_ArmourHealsRight)
		elseif RightRuneType == kARMOUR_POISON
			RightRune = CastSimpleRune(po3_RUNE_ArmourPoisonRight)
		elseif RightRuneType == kARMOUR_SHOCK
			RightRune = CastSimpleRune(po3_RUNE_ArmourShockRight)
		elseif RightRuneType == kDETECTLIFE
			RightRune = CastSimpleRune(po3_RUNE_DetectLifeRight)
		elseif RightRuneType == kGUIDE
			RightRune = CastSimpleRune(po3_RUNE_GuideRight)
		elseif RightRuneType == kLIGHT
			RightRune = CastSimpleRune(po3_RUNE_LightRight)
		elseif RightRuneType == kTELEKINESIS
			RightRune = CastSimpleRune(po3_RUNE_TelekinesisRight)
		elseif RightRuneType == kWEAK 
			RightRune = CastSimpleRune(po3_RUNE_WeaknessRight)
		elseif RightRuneType == kWEAK_FIRE
			RightRune = CastSimpleRune(po3_RUNE_WeaknessFireRight)
		elseif RightRuneType == kWEAK_FROST
			RightRune = CastSimpleRune(po3_RUNE_WeaknessFrostRight)
		elseif RightRuneType == kWEAK_HEALS
			RightRune = CastSimpleRune(po3_RUNE_WeaknessHealsRight)
		elseif RightRuneType == kWEAK_POISON
			RightRune = CastSimpleRune(po3_RUNE_WeaknessPoisonRight)
		elseif RightRuneType == kWEAK_SHOCK
			RightRune = CastSimpleRune(po3_RUNE_WeaknessShockRight)
		elseif RightRuneType == kDEF_ALTERATION		
			RightRune = CastSimpleRune(po3_RUNE_AlterationRight)
		
		;===================================================
		;ILLUSION				
		;===================================================
		
		elseif RightRuneType == kRUNE_FRENZY		
			RightRune = CastSimpleRune(po3_RUNE_FrenzyRuneRight)
		elseif RightRuneType == kFRENZY		
			RightRune = CastSimpleRune(po3_RUNE_FrenzyRight)
		elseif RightRuneType == kCALM
			RightRune = CastSimpleRune(po3_RUNE_CalmRight)	
		elseif RightRuneType == kINVISIBILITY
			RightRune = CastSimpleRune(po3_RUNE_InvisibilityRight)
		elseif RightRuneType == kDISPEL
			RightRune = CastSimpleRune(po3_RUNE_DispelRight)
		elseif RightRuneType == kDEF_ILLUSION
			RightRune = CastSimpleRune(po3_RUNE_IllusionRight)	
		
		;===================================================
		;CONJURATION				
		;===================================================
		
		elseif RightRuneType == kCONJURE_FIRE
			RightRune = CastSimpleRune(po3_RUNE_ConjureFireRight)
		elseif RightRuneType == kCONJURE_FROST
			RightRune = CastSimpleRune(po3_RUNE_ConjureFrostRight)
		elseif RightRuneType == kCONJURE_SHOCK
			RightRune = CastSimpleRune(po3_RUNE_ConjureShockRight)
		elseif RightRuneType == kCONJURE_FAMILIAR
			RightRune = CastSimpleRune(po3_RUNE_ConjureFamiliarRight)
		elseif RightRuneType == kCONJURE_WATER
			RightRune = CastSimpleRune(po3_RUNE_ConjureWaterRight)
		elseif RightRuneType == kCONJURE_EARTH
			RightRune = CastSimpleRune(po3_RUNE_ConjureEarthRight)
		elseif RightRuneType == kREANIMATE
			RightRune = CastSimpleRune(po3_RUNE_ReanimateRight)				
		elseif RightRuneType == kSOULTRAP
			RightRune = CastSimpleRune(po3_RUNE_SoulTrapRight)
		elseif RightRuneType == kBANISH
			RightRune = CastSimpleRune(po3_RUNE_BanishRight)
		elseif RightRuneType == kBOUNDWEAPON
			RightRune = CastSimpleRune(po3_RUNE_BoundWeaponRight)
		elseif RightRuneType == kDEF_CONJURATION
			RightRune = CastSimpleRune(po3_RUNE_ConjureRight)
		endif													
		
	endif
	
	return true
		
endFunction

Int Function GetSpellType(Form akObject)

	if akObject
	
		if akObject as Spell
	
			Spell akSpell = akObject as Spell
				
			if (akSpell.HasKeyword(RitualSpellEffect) || akSpell.HasKeyword(RitualSpellIllusion)) && po3_RUNE_MasterSpellsToggle.GetValue() as bool
		
				return kRITUAL
			
			else
					
				MagicEffect akEffect = akSpell.GetNthEffectMagicEffect(akSpell.GetCostliestEffectIndex())				
				if akEffect
					int castingType = akEffect.GetCastingType()
					int deliveryType = akEffect.GetDeliveryType()

					if castingType == 1 && po3_RUNE_FFSpellsTogglePC.GetValue() as bool || castingType == 2 && po3_RUNE_ConcSpellsTogglePC.GetValue()as bool || \
						deliveryType == 0 && po3_RUNE_SelfSpellsTogglePC.GetValue() as bool || isDualCasting && po3_RUNE_DualCastRunesToggle.GetValue() as bool
				
						return kSPELL
				
					endif
				endif
		
			endif
		
		elseif akObject as Scroll && po3_RUNE_ScrollsToggle.GetValue() as bool
		
			return kSCROLL

		endif
		
	endif
				
	return -1;
	
endFunction

Int Function GetRuneType(Form akObject)
	MagicEffect akEffect = None
	String akSkill = ""
	
	Spell akSpell = akObject as Spell
	if akSpell	
		akEffect = akSpell.GetNthEffectMagicEffect(akSpell.GetCostliestEffectIndex())
		akSkill = akEffect.GetAssociatedSkill()
	else
		Scroll akScroll = akObject as Scroll
		if akScroll
			akEffect = akScroll.GetNthEffectMagicEffect(akScroll.GetCostliestEffectIndex())
			akSkill = akEffect.GetAssociatedSkill()
		endif
	endif
	
	if akSkill == ""
		return -1
	endif
		
	;------------------------------------
	String akName = akObject.GetName()	
	String akResistance = akEffect.GetResistance()
	Art akArt = akEffect.GetCastingArt()
	Light akLight = akEffect.GetLight()
	EffectShader akShader = akEffect.GetHitShader()
	String akArchetype = GetEffectArchetypeAsString(akEffect)
	String primaryAV = GetPrimaryActorValue(akEffect)
	
	bool isDetrimental = akEffect.IsEffectFlagSet(0x00000004) 
	;-------------------------------------
	
	if akSkill == "Destruction"	

		if akEffect.HasKeyword(MagicRune)
			if akEffect.HasKeyword(MagicDamageFrost) || akEffect.HasKeywordString("MagicDamageWind") || akEffect.HasKeywordString("MagicDamageWater")  ;frost
				return kRUNE_FROST
			endif
			if akEffect.HasKeyword(MagicDamageShock) ;shock
				return kRUNE_SHOCK
			endif
			if akEffect.HasKeywordString("MagicDamageEarth")
				return kRUNE_EARTH
			endif
			return kRUNE_FIRE ; generic fire rune
		endif
				
		if akArt == DLC2FXWhirlWindHandEffects || akEffect.HasKeywordString("MagicDamageWind")
			return kAIR
		endif
		if akEffect.HasKeywordString("MagicDamageWater")
			return kWATER
		endif
		if akEffect.HasKeywordString("MagicDamageEarth") || akArchetype == "GrabActor"
			return kTELEKINESIS
		endif
		if akArchetype == "Absorb" || akEffect.HasKeyword(MagicVampireDrain) || akEffect.HasKeyword(DLC1VampireDrainEffect)
			return kDRAIN
		endif
		if akEffect.HasKeywordString("MagicDamageDeath") || akEffect.HasKeywordString("xkLichCurse") 
			return kREANIMATE
		endif
		if akEffect.HasKeywordString("MagicDamageNature")
			return kPOISON
		endif
		if akEffect.HasKeywordString("00SPMagicDamageSun")
			return kSUN
		endif
		if akEffect.HasKeywordString("MagicArmorSpell")
			if akResistance == "FireResist"
				return kARMOUR_FIRE
			endif
			if akResistance == "FrostResist"
				return kARMOUR_FROST
			endif
			if akResistance == "ElectricResist"
				return kARMOUR_SHOCK
			endif
			return kARMOUR
		endif
		if primaryAV == "FireResist"
			if isDetrimental
				return kWEAK_FIRE
			endif
			return kARMOUR_FIRE
		endif
		if primaryAV == "FrostResist"
			if isDetrimental
				return kWEAK_FROST
			endif
			return kARMOUR_FROST
		endif
		if primaryAV == "ElectricResist"
			if isDetrimental
				return kWEAK_SHOCK
			endif
			return kARMOUR_SHOCK
		endif
		if primaryAV == "PoisonResist" || primaryAV == "DiseaseResist"
			if isDetrimental
				return kWEAK_POISON
			endif
			return kARMOUR_POISON
		endif
		if akEffect.HasKeyword(MagicWard)
			return kWARD ; no runes - just spawn lights
		endif
		if akEffect.HasKeyword(MagicDamageFire) && akEffect.HasKeyword(MagicDamageFrost) &&  akEffect.HasKeyword(MagicDamageShock) 
			return kDEF_DESTRUCTION
		endif
		if akEffect.HasKeyword(MagicDamageFire) || akResistance == "FireResist" || akLight == MagicLightFireInHand;fire
			return kFIRE
		endif
		if akEffect.HasKeyword(MagicDamageFrost) || akResistance == "FrostResist" || akLight == MagicLightFrostHand01 ;frost
			return kFROST
		endif
		if akEffect.HasKeyword(MagicDamageShock) || akResistance == "ElectricResist" || akLight == MagicLightShockInHand ;shock
			return kSHOCK
		endif
		
		return kDEF_DESTRUCTION ; generic destruction
		
	elseif akSkill == "Restoration"
	
		if akEffect.HasKeywordString("PO3_MagicDamageSun") || akShader == DLC1SunFireImpactFXShader || akShader == DLC1SunFireFXShader || akArt == DLC1_SunCloakSpellHandFX ;sun 
			return kSUN 	
		endif
		if akArchetype == "TurnUndead" || akEffect.HasKeyword(MagicTurnUndead) || akArt == TurnUndeadHandEffects
			return kTURNUNDEAD
		endif
		if akEffect.HasKeyword(MagicWard)
			return kWARD ; no runes - just spawn lights
		endif
		if akResistance == "DiseaseResist" || akEffect.HasKeywordString("WB_Restoration_Keyword_Damage") || akEffect.HasKeywordString("WB_Restoration_Keyword_IsInstakillSpell") 
			return kDRAIN
		endif
		if akArt == HealsMystFXHand01 || akEffect.HasKeywordString("WB_Restoration_Keyword_IsRestoreManaSpell")
			return kMYSTICHEAL
		endif
		if akEffect.HasKeyword(MagicRune) && akResistance == "PoisonResist" ;poison rune
			return kRUNE_POISON
		endif
		if akResistance == "PoisonResist" || akEffect.HasKeywordString("WB_Restoration_Keyword_LeechSeed_Health") || akEffect.HasKeywordString("WB_Restoration_Keyword_Necroplague") ;poison or damaging restoration
			return kPOISON
		endif
		if primaryAV == "MagicResist" || primaryAV == "DamageResist" || akEffect.HasKeywordString("WB_Restoration_Keyword_IsTapSpell")
			if isDetrimental
				return kWEAK_HEALS
			endif
			return kARMOUR_HEALS
		endif
		if akArchetype == "SummonCreature"
			return kCONJURE_HEALS
		endif
		if StringUtil.Find(akName, "Cleanse", 0) != -1 || StringUtil.Find(akName, "Dispel", 0) != -1 || StringUtil.Find(akName, "Silence", 0) != -1 
			return kDISPEL
		endif
		if akArchetype == "BoundWeapon"
			return kBOUNDWEAPON		
		endif
		if akEffect.HasKeyword(MagicDamageFire)
			return kFIRE
		endif
		if akEffect.HasKeyword(MagicDamageFrost)
			return kFROST
		endif
		if akEffect.HasKeyword(MagicDamageShock)
			return kSHOCK	
		endif
		if akArchetype == "Light"
			return kLIGHT			
		endif
		
		return kHEAL ; generic heal
		
	elseif akSkill == "Alteration"

		if akArchetype == "Paralysis" || akEffect.HasKeyword(MagicParalysis)
			if akEffect.HasKeyword(MagicRune)
				return kRUNE_ASH ;ash rune
			endif
			if StringUtil.Find(akName, "Ash", 0) != -1
				return kSUN
			endif
			return kPARALYSIS ;normal paralysis
		endif
		if akArt == DLC2FXWhirlWindHandEffects
			return kAIR
		endif
		if akArchetype == "DetectLife" || akArt == DetectLifeFXHand01 ;detect life or whatever
			return kDETECTLIFE
		endif
		if akArchetype == "SlowTime" || akEffect.HasKeywordString("MagicSlowTime")
			return kGUIDE
		endif
		if akArchetype == "Telekinesis" || akArchetype == "GrabActor" || akEffect.HasKeywordString("MAG_MagicDamageWeapon") || akEffect.HasKeywordString("MAG_MagicLockSpell") || \
				akEffect.HasKeywordString("MAG_MagicWeightSpell") || akEffect.HasKeywordString("WB_Alteration_Orb")
			return kTELEKINESIS
		endif
		if akEffect.HasKeyword(MagicArmorSpell) || akEffect.HasKeywordString("MAG_MagicShieldSpell") || akEffect.HasKeywordString("WB_Buff") ;armour spells
			if primaryAV == "FireResist"
				return kARMOUR_FIRE
			endif
			if primaryAV == "FrostResist"
				return kARMOUR_FROST
			endif
			if primaryAV == "ElectricResist"
				return kARMOUR_SHOCK
			endif
			if primaryAV == "PoisonResist" || primaryAV == "DiseaseResist"
				return kARMOUR_POISON
			endif		
			return kARMOUR
		endif
		if akEffect.HasKeywordString("MAG_MagicDamageWeakness") || isDetrimental && (primaryAV == "MagicResist" || primaryAV == "DamageResist")
			if primaryAV == "FireResist"
				return kWEAK_FIRE
			endif
			if primaryAV == "FrostResist"
				return kWEAK_FROST
			endif
			if primaryAV == "ElectricResist"
				return kWEAK_SHOCK
			endif
			if primaryAV == "PoisonResist" || primaryAV == "DiseaseResist"
				return kWEAK_POISON
			endif
			return kWEAK
		endif
		if akArchetype == "Light" || akArt == FXLightSpellHandEffects ;light spells
			return kLIGHT
		endif
		
		return kDEF_ALTERATION ; generic alt
		
	elseif akSkill == "Illusion"
	
		if akEffect.HasKeyword(MagicRune) && akEffect.HasKeyword(MagicInfluenceFrenzy)
			return kRUNE_FRENZY
		endif
		if akArchetype == "Paralysis" || akEffect.HasKeyword(MagicParalysis) ;mysticism
			if StringUtil.Find(akName, "Ash", 0) != -1 || StringUtil.Find(akName, "Cinder", 0) != -1
				return kSUN
			endif
			return kPARALYSIS ;normal paralysis
		endif
		if akEffect.HasKeywordString("kDoppelganger") || akEffect.HasKeywordString("00SPIgniteMemoriesKYWD")
			return kFIRE
		endif
		if akArchetype == "Invisibility" || akArt == InvsFXHand01 || akEffect.HasKeywordString("MAG_MagicReflectSpell") || akEffect.HasKeywordString("MagicDamageArcane")  || \
				akEffect.HasKeywordString("WB_Illusion_Keyword_EvilTwin")
			return kINVISIBILITY
		endif
		if akEffect.HasKeywordString("WB_Illusion_Keyword_Damage") || akEffect.HasKeywordString("WB_Illusion_Keyword_AnticasterDuration") || \
				akEffect.HasKeywordString("WB_Illusion_Keyword_AnticasterInstant")
			return kSOULTRAP
		endif
		if akArchetype == "DetectLife" || akArt == DetectLifeFXHand01 ;detect life or whatever
			return kDETECTLIFE
		endif
		if akArchetype == "Dispel" || StringUtil.Find(akName, "Dispel", 0) != -1 ||  StringUtil.Find(akName, "Silence", 0) != -1 || StringUtil.Find(akName, "Mind Twist", 0) != -1 ||akEffect.HasKeywordString("MAG_MagicInfluenceSilence");
			return kDISPEL
		endif
		if akArchetype == "Guide" || primaryAV == "MovementNoiseMult"
			return kGUIDE
		endif
		if primaryAV == "Magicka" || primaryAV == "MagickaRateMult"
			return kMYSTICHEAL
		endif
		if primaryAV == "DamageResist" || primaryAV == "MagicResist"
			if isDetrimental
				return kWEAK
			endif
			return kARMOUR
		endif
		if akResistance == "PoisonResist"
			return kPOISON
		endif
		if akArchetype == "Calm" || akArchetype == "Rally" || akArt == IllusionPosFXHand01  ;calm, charm
			return kCALM
		endif
		if akArchetype == "Frenzy" || akArchetype == "Demoralize" || akArt == IllusionNegFXHand01 ;fear, frenzy
			return kFRENZY
		endif
		
		return kDEF_ILLUSION ;generic illusion
		
	elseif akSkill == "Conjuration"

		if akEffect.HasKeywordString("MagicSummonWind") || akEffect.HasKeywordString("MagicSummonWater")
			return kCONJURE_WATER
		endif
		if akEffect.HasKeywordString("MagicDamageEarth")
			return kCONJURE_EARTH
		endif
		if akEffect.HasKeyword(MagicSummonFire) || akEffect.HasKeywordString("WB_Conjuration_Detonate") || akEffect.HasKeyword(DLC2MagicAshSpawn) ;fire
			return kCONJURE_FIRE
		endif
		if akEffect.HasKeyword(MagicSummonFrost) ;frost
			return kCONJURE_FROST
		endif
		if akEffect.HasKeyword(MagicSummonShock) ;shock
			return kCONJURE_SHOCK
		endif
		if akEffect.HasKeyword(MagicSummonFamiliar) 
			return kCONJURE_FAMILIAR
		endif
		if akArchetype == "Reanimate" || akEffect.HasKeyword(MagicSummonUndead)
			return kREANIMATE
		endif
		if akArchetype == "Banish" || StringUtil.Find(akName, "Banish", 0) != -1
			return kBANISH
		endif
		if akArchetype == "BoundWeapon" ||  akArchetype == "CommandSummoned" || akEffect.HasKeywordString("MAG_MagicInfluenceCommand") || akEffect.HasKeywordString("WB_Conjuration_ControlBuff")
			return kBOUNDWEAPON
		endif
		if akArchetype == "SoulTrap" || akArt == SoulTrapHandEffects 
			return kSOULTRAP
		endif
		if akEffect.HasKeyword(MagicRestoreHealth)
			return kHEAL
		endif
		
		return kDEF_CONJURATION ; generic conjuration 
		
	endif		

	return -1	
	
endFunction

Spell Function CastSimpleRune(Spell NormSpell)

	PlayerRef.AddSpell(NormSpell, false)
	return NormSpell
	
endFunction

Function CastDualCastRune()

	CastStrangeRunes(0)
	
	int i = 0
	while !LeftRune && i < 10 
		Utility.Wait(0.1)
		i += 1
	endWhile
	
	Utility.Wait(0.2)
							
	If LeftRune && LeftRune.GetNthEffectMagicEffect(0) && LeftRune.GetNthEffectMagicEffect(0).GetHitEffectArt()
        UpdateHitEffectArtNode(PlayerRef, LeftRune.GetNthEffectMagicEffect(0).GetHitEffectArt(), nodeName, dualTranslate, dualRotate, dualScale)
    EndIf	

	if RightRune
		PlayerRef.RemoveSpell(RightRune)	
		RightRune = None
	endif
	
endFunction
Function PSQRemoveRoseRunes(Int hand)
    Int i = 9
    While i > 0
        i -= 1
        If hand < 0 || hand == i / 3 || (hand == 0 && i >= 6)
            Spell rune = Game.GetFormFromFile(0x810 + i, "PSQ - Strange Runes.esp") as Spell
            If rune && PlayerRef.HasSpell(rune)
                PlayerRef.RemoveSpell(rune)
            EndIf
        EndIf
    EndWhile
EndFunction
