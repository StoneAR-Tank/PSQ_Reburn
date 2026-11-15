# PSQ Reburn

[简体中文](README.md) | [繁體中文](README.zh-TW.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

PSQ Reburn is a succubus gameplay mod for *The Elder Scrolls V: Skyrim Special Edition*. It builds on PSQ PlayerSuccubusQuest and existing Chinese translations and compilations.

Become a succubus, switch between your ordinary and succubus forms, grow by draining energy, and choose the appearance and outfits you like.

**Current version: v0.31**

[Download PSQ Reburn](https://github.com/StoneAR-Tank/PSQ_Reburn/releases/tag/v0.31)

The release page offers a complete ZIP and a FOMOD installer. Most players should use the FOMOD to select the components they need; the complete ZIP contains components for manual selection. Standalone outfits, flight mods, and other optional features still require their respective mods. Some features need further in-game verification. This translation covers the README; the in-game menus may still be in Chinese.

## Features

- **Succubus progression:** Drain energy, gain ranks, and unlock abilities and attribute bonuses.
- **Transformation:** Switch forms and customize your body shape, skin and hair colors, markings, and transformation effects.
- **Outfit customization:** Mix and match tops, boots, gloves, horns, tails, and wings independently.
- **Body and skin switching:** Use Body Change NG to select a body shape and skin for each form.
- **Futanari appearance:** Use the TRX futanari mod to choose appearances for your forms.
- **Succubus spell visuals:** Optionally use pink elemental effects and compatibility components for Mysticism and Strange Runes.
- **More features:** Succubus tattoos, magic circles, thralls, familiars, and integrations with selected mods.
- **Succubus merchant and satiation mode:** Buy items from the merchant and optionally let your energy state affect progression.

Adjust settings in the in-game MCM. Available appearances and integrations depend on the mods you have installed.

📖 [Succubus rank and ability chart](docs/succubus-ranks.en.md)

## Requirements

### Required

- *The Elder Scrolls V: Skyrim Special Edition*
- **SKSE64** matching your game version
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
- **Other integrations:** FHU, SLSO, UIExtensions, EFF/NFF, iNeed, Mannaz, and others may be installed as needed.

Choose requirements compatible with your game version and check each mod's installation instructions.

## Outfit downloads

Choose the outfits you want; you do not need all of them. Some pages require an account or adult content settings.

| Outfit | Download or source lead | Installation note |
| --- | --- | --- |
| DX Succubus | [Original SE](https://www.nexusmods.com/skyrimspecialedition/mods/36642) · [CBBE](https://www.nexusmods.com/skyrimspecialedition/mods/36619) · [UBE](https://www.nexusmods.com/skyrimspecialedition/mods/116652) | Choose the version matching your body. |
| Helena Succubus | [Outfit page](https://rektas.wixsite.com/website/post/helena-succubus) | Choose an SE version matching your body. |
| Dragon Princess | [SE 3BF version lead](https://schaken-mods.com/forums/topic/32100-se-dragon-princess-3bf-bs/) | This is a related port; the original author's page has not been verified. Check PSQ compatibility. |
| Ageha Abyss | Original page not yet verified | Check the version and download source. |
| TERA Succubus 9DM | [Related SE version](https://schaken-mods.com/file/tera-succubus-9dm-se) | Exact compatibility with PSQ's integration is unconfirmed; do not confuse it with Harry TERA below. |
| SucubusSister Shinano | [lilyrim's release page](https://www.patreon.com/u11199437/posts/free-shinano-117275572) | Follow the page's body and physics requirements. |
| SW Vampire | [Related page lead](https://arca.live/b/tullius/96130274) | The page could not be directly verified; check the outfit version. |
| Hirosin X Succubus | [Original post lead](https://arca.live/b/tullius/90058800) · [Outfit information](https://modbooru.com/mods/x-succubus-set.1670) | PSQ includes its Hiroshi/X succubus transformation resources; install standalone outfits as needed. |
| TERA Succubus Armor (Harry TERA) | [Author's page](https://www.patreon.com/posts/tera-succubus-18130754) · [SE port](https://www.daymarrworkshop.com/post/tera-succubus-armor-cbbe-tbd-se) | Follow each page's requirements; do not confuse it with TERA Succubus 9DM. |

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

## Installation and upgrading

1. End any scenes, leave transformation and flight, save in a safe location, and back up your save.
2. Install the requirements and PSQ Reburn v0.31. Disable the old PSQ and its old cumulative patches. The FOMOD recommends some options based on enabled requirements; check versions and adjust as needed.
3. Install outfits, Body Change NG, TRX, or a flight mod as needed, and check your MO2 order as described above.
4. Restart the game, check settings and compatibility in PSQ's MCM, and then try transforming.

Before uninstalling, leave transformation and scenes, retrieve your personal storage, and run the uninstall preparation on the MCM toggle page. Keep a save from before cleanup.

## Credits

- **ojanen** — original [PSQ PlayerSuccubusQuest for SexLab](https://www.loverslab.com/files/file/667-psq-playersuccubusquest-for-sexlab/).
- **Authors and contributors of the Chinese PSQ translations and compilations** — thank you for the earlier work.
- **[Body Change NG](https://github.com/compilecraftworks/Body-Change-NG) authors and contributors** — body and skin management.
- **TRX Futanari SOS Addon authors and contributors** — futanari equipment and textures.
- **Authors and contributors of outfits, animations, models, textures, sounds, frameworks, and other compatible mods** — thank you for your work.
- **StoneAR-Tank** — PSQ Reburn modifications, integration, and release. The evolution markings were designed with AI assistance.

Rights and licenses belong to the respective creators. Relevant license files are in the main package's [Docs folder](PSQ-Reburn/Docs/).

## Support the project

PSQ Reburn is free. If you enjoy the project, support on [Patreon](https://www.patreon.com/c/StoneAS) is welcome. Thank you!
