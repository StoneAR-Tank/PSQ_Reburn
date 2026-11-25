# PSQ Reburn

[简体中文](README.md) | [繁體中文](README.zh-TW.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

PSQ Reburn is a succubus gameplay mod for *The Elder Scrolls V: Skyrim Special Edition*. It builds on PSQ PlayerSuccubusQuest and existing Chinese translations and compilations.

Become a succubus, switch between your ordinary and succubus forms, grow by draining energy, and choose the appearance and outfits you like.

**Current version: v0.4**

[Download PSQ Reburn](https://github.com/StoneAR-Tank/PSQ_Reburn/releases/tag/v0.4)

The release page offers a complete ZIP and a FOMOD installer. Most players should use the FOMOD to select the components they need; the complete ZIP contains components for manual selection. Standalone outfits, flight mods, and other optional features still require their respective mods.

**Game languages:** Choose Simplified Chinese, English, Japanese, or Traditional Chinese during installation. Your choice applies to the PSQ installer and in-game text. To change it, reinstall the mod in MO2 and restart the game. Other mods keep their own languages.

## Features

- **Succubus progression:** Drain energy, gain ranks, and unlock abilities and attribute bonuses.
- **Succubus Panel:** View your growth and status and manage selected settings in game. Choose a layout for your screen, including 4K, during installation. Choose the energy bar style directly from the panel.
- **Spell learning:** Browse spells from four schools, check their requirements, and see which spells you already know in the Succubus Panel.
- **Hotkeys:** Assign keys in the panel for Night Vision, Transform / Revert, and Digest Semen.
- **Utility powers:** Use Digest Semen and Night Vision from the game’s Powers menu. Digestion requires the corresponding FHU feature.
- **Transformation outfits:** Change outfits when transforming and restore your equipment when returning to normal. Optional faster outfit changes can be enabled during installation; the original method is the default.
- **Transformation:** Switch forms and customize your body shape, skin and hair colors, markings, and transformation effects.
- **Outfit customization:** Mix and match tops, boots, gloves, horns, tails, and wings independently.
- **Body and skin switching:** Use Body Change NG to select a body shape and skin for each form.
- **Futanari appearance:** Use the TRX futanari mod to choose appearances for your forms.
- **Succubus spell visuals:** Optionally use pink elemental effects and compatibility components for Mysticism and Strange Runes.
- **More features:** Succubus tattoos, magic circles, thralls, familiars, and integrations with selected mods.
- **Succubus merchant and satiation mode:** Buy items from the merchant and optionally let your energy state affect progression.

Adjust settings in the in-game MCM. Available appearances and integrations depend on the mods you have installed.

📖 [Succubus rank and ability chart](docs/succubus-ranks.en.md) (v0.29)

📖 [Succubus spell guide](docs/succubus-spells.en.md) (based on v0.32; some abilities and spell learning changed in later versions)

## Requirements

### Required

- *The Elder Scrolls V: Skyrim Special Edition*
- **SKSE64** matching your game version
- **Address Library for SKSE Plugins** matching your game version
- **SkyUI**
- **PapyrusUtil**
- **Heels Sound**
- Either **SexLab SE 1.63** or **P+ 2.19.0**; choose one.

Arousal features also need a compatible arousal mod, such as SLO Aroused NG or OSL Aroused, and its requirements.

### Install as needed

- **Bodies and outfits:** RaceMenu, CBBE 3BA, XPMSSE, BodySlide, and CBPC or FSMP as required by the outfit. For UBE, choose UBE-compatible outfits and patches.
- **Animations:** Open Animation Replacer (OAR). Some standalone animations must be installed separately.
- **Body and skin switching:** Body Change NG 1.3.8 and its requirements. PSQ provides compatibility files; install Body Change NG separately.
- **Futanari appearance:** SOS - TRX - Futanari Addon and its requirements. The feature is unavailable without them.
- **Flight:** Wingflight or OSYRN and its requirements; install separately and use its own menu and controls.
- **Spell visuals:** Mysticism 2.4.2 or Strange Runes 3.7.3 as needed. Some effects also require Address Library matching your game version.
- **Energy sensing, thrall eyes, and other features:** powerofthree's Papyrus Extender and its requirements.
- **TDF integration:** If you use TDF Enhanced Prostitution, you can select its compatibility option in the installer. Install TDF separately.
- **Other integrations:** FHU, SLSO, EFF/NFF, iNeed, Mannaz, and others may be installed as needed.

Choose requirements compatible with your game version and check each mod's installation instructions.

## Installation and upgrading

1. End any scenes, leave transformation and flight, save in a safe location, and back up your save.
2. Install the requirements and PSQ Reburn v0.4. Disable the old PSQ and its old cumulative patches. On the first FOMOD page choose your language. Enable faster outfit changes if desired, select compatibility options, and choose a panel layout for your resolution. The FOMOD lets you preview outfits and choose the PSQ BodySlide projects you need.
3. Install outfits, Body Change NG, TRX, or a flight mod as needed, and check your MO2 order as described below.
4. Restart the game, check settings and compatibility in PSQ's MCM, and then transform.

Before uninstalling, leave transformation and scenes, retrieve your personal storage, and run the uninstall preparation on the MCM toggle page. Keep a save from before cleanup.

## Outfit downloads

Choose the outfits you want; you do not need all of them. Some pages require an account or adult content settings.

| Outfit | Download page | Installation note |
| --- | --- | --- |
| DX Succubus | [Original SE](https://www.nexusmods.com/skyrimspecialedition/mods/36642) · [CBBE](https://www.nexusmods.com/skyrimspecialedition/mods/36619) · [UBE](https://www.nexusmods.com/skyrimspecialedition/mods/116652) | The original provides the base assets; install the CBBE or UBE version as directed on its page. |
| Helena Succubus | [Outfit page](https://rektas.wixsite.com/website/post/helena-succubus) | Choose an SE version matching your body. |
| SucubusSister Shinano | [lilyrim's release page](https://www.patreon.com/u11199437/posts/free-shinano-117275572) | Follow the page's body and physics requirements. |
| TERA Succubus Armor (Harry TERA) | [Author's page](https://www.patreon.com/posts/tera-succubus-18130754) · [SE port](https://www.daymarrworkshop.com/post/tera-succubus-armor-cbbe-tbd-se) | Follow the page's installation instructions and requirements. |

PSQ includes the Hiroshi/X succubus transformation resources.

After installing an outfit, check the PSQ MCM compatibility page to see whether it is recognized. In BodySlide, select the preset matching your body, build the corresponding PSQ outfit, and enable **Build Morphs**.

## Suggested MO2 order

This is a suggested order for MO2's **left pane**, from top to bottom. Install only the optional content you need:

1. Game requirements, body, skeleton, and physics mods.
2. SexLab or P+, and any arousal mods you use.
3. Optional mods such as Body Change NG and TRX, and their requirements.
4. Standalone outfits you want to use.
5. **PSQ Reburn**.
6. Patches for the current PSQ version and newly built BodySlide output.
7. Separately installed Wingflight or OSYRN and their translations.

Let PSQ overwrite the relevant Body Change NG and original outfit files. When using a standalone flight mod, let its `Wingflight.dll` win. Check MO2 conflicts so old PSQ patches or BodySlide output do not overwrite the new files.

Check MO2's **right-hand plugin list** separately: enable the necessary outfit plugins and make sure no masters are missing. Do not simply copy the left-pane order.

## More information

The required C++ native component is installed with v0.4 and supports the Succubus Panel, transformation, and standalone outfits. Install SKSE64 and Address Library for your game version.

## Credits

- **ojanen** — original [PSQ PlayerSuccubusQuest for SexLab](https://www.loverslab.com/files/file/667-psq-playersuccubusquest-for-sexlab/).
- **Authors and contributors of the Chinese PSQ translations and compilations** — thank you for the earlier work.
- **零式** — the earlier Chinese translation of PSQ.
- **[Body Change NG](https://github.com/compilecraftworks/Body-Change-NG) authors and contributors** — body and skin management.
- **TRX Futanari SOS Addon authors and contributors** — futanari equipment and textures.
- **Authors and contributors of outfits, animations, models, textures, sounds, frameworks, and other compatible mods** — thank you for your work.
- **[yuboge](https://github.com/yuboge) and [DouerGan](https://github.com/DouerGan)** — thank you for reporting issues, sharing analysis, and suggesting fixes. Thanks also to everyone who reports problems and helps improve the mod.
- **StoneAR-Tank** — PSQ Reburn modifications, integration, and release. The evolution markings were designed with AI assistance.

Rights and licenses belong to the respective creators.

## Support the project

PSQ Reburn is free. If you enjoy the project, support on [Patreon](https://www.patreon.com/c/StoneAS) or [Afdian](https://afdian.com/a/stonear?utm_source=copylink&utm_medium=link) is welcome. Thank you!
