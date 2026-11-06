# PSQ Reburn

PSQ Reburn 是《上古卷轴 V：天际特别版》的魅魔系统修改版，基于 **PSQ PlayerSuccubusQuest** 和已有汉化、整合版本继续开发。玩家可以在普通形态和魅魔形态之间切换，通过吸取能量成长，并自定义变身外观、能力和兼容功能。

当前版本：**v0.28** · [下载安装包与更新说明](https://github.com/StoneAR-Tank/PSQ_Reburn/releases/tag/v0.28)

本仓库的 [`PSQ-Reburn/`](PSQ-Reburn/) 是本体文件。Release 只提供本体，独立服装包、动作包和其他模组需自行安装。本版本经过离线检查，尚未完成游戏内验收。

## 功能介绍

- **魅魔成长与能量**：通过互动吸取能量，提升魅魔等级，使用对应的能力、种族特性和属性加成；能量条支持两种显示样式。
- **变身与外观**：设置普通／魅魔形态的外观、身形、肤色、发色、纹样和特效；退出变身后恢复相应外观与装备。
- **六部分变身装备**：上衣、靴子、手套、角、尾巴和翅膀可分别选择。支持检测多套独立服装原作，并由 PSQ 提供对应兼容文件；具体可用部件取决于已安装的原作和资源。
- **Body Change NG 适配**：使用 Body Change NG 管理身形，以及普通形态和魅魔形态各自的扶她皮肤；PSQ 继续管理扶她装备、等级和变身流程。
- **TRX 扶她外观**：可按普通／魅魔形态选择 TRX 普通、轻甲或重甲款式；需另装 TRX 及其前置。
- **框架与可选模组兼容**：支持旧版 SexLab 或 P+，并提供欲望接口、FHU、独立飞行等功能的适配。可用功能取决于所安装的模组及其版本。
- **其他系统**：保留纹身、法阵与特效、眷属和使魔等系统，并提供简体中文菜单。旧乳业与挤奶玩法已移除，FHU 储量转入、消化和精液药剂功能保留。
- **v0.28 变身优化**：调整进入和退出变身时的装备处理、外观恢复及尾巴残留清理；更新 UBE 外观适配与 Body Change NG 接口。实际改善幅度和新修复仍需在游戏内验证。

## 前置需求

### 基础

- 《上古卷轴 V：天际特别版》及与游戏版本匹配的 **SKSE64**。
- **SkyUI**、**PapyrusUtil**、**Heels Sound**。
- **SexLab SE 1.63** 或 **P+ 2.19.0**：二选一，不要同时安装。切换框架时建议使用独立 MO2 配置和存档副本。
- 欲望功能需要安装兼容的欲望后端及其前置，例如 SLA 兼容接口、SLO Aroused NG 或 OSL Aroused；本体没有 `SexLabAroused.esm` 硬依赖。

主插件的硬依赖为 `Skyrim.esm`、`Heels Sound.esm` 和 `SexLab.esm`。SKSE 插件及其前置必须与实际游戏版本匹配。

### 外观与按功能选装

- **RaceMenu、CBBE 3BA、XPMSSE、BodySlide**：用于对应的身体、骨骼和服装；按服装要求安装 **CBPC** 或 **FSMP**。身体和服装应使用一致的身体体系；使用身形切换时，按 Body Change NG 要求以 Zeroed Sliders 构建并勾选 Build Morphs。
- **Open Animation Replacer（OAR）**：用于本体中的 OAR 动作配置；可选的独立动作包需另行安装。
- **Body Change NG 1.3.8 本体及其前置**：使用身形切换或扶她皮肤管理时需要。PSQ 提供适配的 `BodyChangeNG.dll`（1.3.8.1／API4）；在 MO2 中让 PSQ 覆盖 Body Change NG 的同名文件。独立 Body Change NG 本体仍需安装；其他版本需确认对应接口兼容性。
- **SOS - TRX - Futanari Addon 及其前置**：使用 TRX 扶她装备时需要，并需按所用身体预设构建对应模型。未安装时，相关功能不可用，其他 PSQ 功能仍可使用。
- **服装原作**：想使用相应的独立服装时，需安装并启用对应原作及其前置。Hiroshi（Set08／X魅魔）资源包单独提供，本次 GitHub 发布不包含该资源包；缺少相关资源时，回退外观可能无法完整显示。
- **Wingflight 或 OSYRN**：飞行本体及其前置需单独安装。使用独立飞行方案时，让所选飞行核心的 `Wingflight.dll` 覆盖 PSQ 内的旧兼容桥，并使用飞行模组自身的菜单和按键。
- **powerofthree's Papyrus Extender**：能量感知、眷属眼睛等扩展功能需要，安装与游戏匹配的版本及其前置。
- **其他可选兼容**：SLSO、FHU、UIExtensions、EFF／NFF、iNeed、Mannaz、GT_SoftBody、TDF、Apropos2 等按需要安装。各模组仍需满足自己的前置要求。

## 服装原址与下载指路

以下服装按需安装，不是 PSQ 本体的全部必需前置。请选择与游戏版本、身体及所需插件匹配的版本；原作、移植版和身形转换版可能使用不同插件名称。对应适配仍保留上衣、靴子、手套、角、尾巴和翅膀六部分。

| 服装 | 原址或查找线索 | 说明 |
| --- | --- | --- |
| DX Succubus（Set01） | [DX Succubus 原版 SE / UNP](https://www.nexusmods.com/skyrimspecialedition/mods/36642) · [CBBE BodySlide 版](https://www.nexusmods.com/skyrimspecialedition/mods/36619) · [UBE 转换](https://www.nexusmods.com/skyrimspecialedition/mods/116652) | 安装与身体匹配的版本；UBE 转换与 PSQ 适配的搭配方式见包内 DX UBE 文档。 |
| Helena Succubus（Set02） | [Rektas 服装页面](https://rektas.wixsite.com/website/post/helena-succubus) | 选择适用的 SE 与身体版本。 |
| Dragon Princess（Set03） | [SE 3BF BodySlide 版本线索](https://schaken-mods.com/forums/topic/32100-se-dragon-princess-3bf-bs/) | 这是相关移植版本线索，不是已核实的作者原址；PSQ 已接入的版本插件为 `BBP_Dragon_Princess.esp`，下载后请核对。 |
| Ageha Abyss（Set04） | 原址与适配版本待核实 | 已有线索标注为未授权搬运，暂不作为原址；请选择合法来源，并核对实际插件和版本。 |
| TERA Succubus 9DM（Set05） | [TERA Succubus 9DM SE 相关版本](https://schaken-mods.com/file/tera-succubus-9dm-se) | PSQ 已接入的版本插件为 `TR9DmRxSS_HR.esp`；页面所提供文件是否与该插件一致尚待核验。不要与下方 Harry TERA 混淆。 |
| SucubusSister Shinano（Set06） | [lilyrim 发布页面](https://www.patreon.com/u11199437/posts/free-shinano-117275572) | 包含信浓服装；请按作者说明安装匹配版本及物理前置。 |
| SW Vampire（Set07） | [相关页面线索](https://arca.live/b/tullius/96130274) | 页面当前无法验证，具体文件和插件仍需核对。 |
| Hirosin X Succubus（Set08） | [原帖线索](https://arca.live/b/tullius/90058800) · [服装索引](https://modbooru.com/mods/x-succubus-set.1670) | PSQ 使用单独的 Hiroshi／X 魅魔资源包作为回退资源；该资源包不包含在本次 Release 中，原帖目前无法直接核验。 |
| TERA Succubus Armor（Harry TERA，编号 100） | [Harry2135 作者页面](https://www.patreon.com/posts/tera-succubus-18130754) · [Daymarr SE 移植页面](https://www.daymarrworkshop.com/post/tera-succubus-armor-cbbe-tbd-se) | 作者页为原版资料，SE 移植版及插件需另行核对；不要与 Set05 的 9DM 版本混淆。 |

仅链接原作或相关页面，不代表对应版本、转载许可或运行效果已经核验。某些页面可能要求登录、成人内容设置或单独选择 SE 和身体版本。下载并启用原作后，可在 PSQ 的 MCM 兼容页面检查识别状态；按身体预设构建对应的 PSQ BodySlide 适配组并勾选 Build Morphs。

## MO2 推荐排序

以下为 **MO2 左侧模组文件覆盖顺序**，从上到下优先级逐渐升高；只启用自己实际使用的可选项：

```text
基础前置、骨骼、身体、物理和 BodySlide
SexLab 或 P+、对应欲望框架及其前置
Body Change NG、TRX 及各自前置（按功能选装）
独立服装原作及其所需资源（按需要安装）
PSQ Reburn 本体
为当前版本制作的 PSQ 专用兼容补丁／BodySlide 输出（按需）
独立 Wingflight / OSYRN 飞行核心及适用汉化（按需，确认其 Wingflight.dll 生效）
```

- 本体应覆盖 Body Change NG 的同名 `BodyChangeNG.dll` 以及相应独立服装的 PSQ 兼容文件；在 MO2 的冲突信息中核对实际生效来源。升级 Body Change NG 后，应确认 PSQ 接口 DLL 与新版本匹配。
- BodySlide 输出只有在使用正确的 PSQ 适配组、匹配身体与预设并勾选 Build Morphs 后，才应覆盖相应旧模型；不要让过时输出覆盖新版修正。外部补丁若覆盖 PSQ 文件，应确认它明确支持当前 PSQ 版本。
- 使用独立飞行时，让所选飞行核心提供 `Wingflight.dll`；PSQ 的 Body Change DLL 与飞行 DLL 各自检查，覆盖顺序不代表所有文件都应由同一个模组提供。
- **MO2 右侧插件顺序与左侧文件优先级不同。** 启用所需原作插件，并保证各插件主文件存在且排在依赖它的插件之前；根据插件类型、冲突和实际前置检查，不要仅照搬左侧顺序或重命名插件。

## 安装与升级

1. 结束互动，退出变身和飞行，在地面另存并备份 `.ess` 与对应的 `.skse` 存档，然后退出游戏。
2. 安装 v0.28 本体和所需前置，停用旧版 PSQ 及旧的 PSQ 累积补丁，避免旧脚本覆盖本版。
3. 按所用功能安装独立服装、TRX、Body Change NG 或飞行模组，并检查 MO2 文件覆盖顺序。兼容文件由 PSQ 提供，无需修改其他模组目录。
4. 重启游戏，检查 MCM 兼容状态，并使用备份存档测试变身、退出、装备恢复及已启用的功能。

更详细的适配和测试说明见 [`PSQ-Reburn/Docs`](PSQ-Reburn/Docs/)。本体内部分历史文档保留了旧版说明，如有冲突，请以日期较新的适配文档和本页为准。

## Credit

- **ojanen** — [PSQ PlayerSuccubusQuest for SexLab](https://www.loverslab.com/files/file/667-psq-playersuccubusquest-for-sexlab/) 原作。
- **已有 PSQ 中文汉化与整合版本的作者及贡献者** — 本项目沿用已有内容，并在此基础上进行修改和补译。
- **[Body Change NG](https://github.com/compilecraftworks/Body-Change-NG)** 的作者与贡献者 — 身形和皮肤管理；本体包含适配版本，相关许可见 [BodyChangeNG GPL-3.0](PSQ-Reburn/Docs/BodyChangeNG-GPL-3.0-LICENSE.txt)。
- **TRX Futanari SOS Addon** 的作者与贡献者 — 扶她装备及贴图资源；装备本体需单独安装。
- **服装、动作、模型、贴图、音效、框架及其他兼容模组的原作者与贡献者** — 感谢各位的创作。各资源的权利和许可归其原作者所有，请参阅随附文件及原项目页面。
- **StoneAR-Tank** — PSQ Reburn 的修改、整合与发布。进化纹样采用 AI 辅助设计。

