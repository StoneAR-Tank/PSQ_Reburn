# PSQ Reburn

PSQ Reburn 是《上古卷轴 V：天际特别版》的魅魔系统模组，基于 PSQ PlayerSuccubusQuest 和已有汉化、整合版本继续制作。

成为魅魔，在普通形态与魅魔形态之间切换，通过吸取能量成长，并搭配自己喜欢的外观与服装。

**当前版本：v0.28**  
[下载 PSQ Reburn](https://github.com/StoneAR-Tank/PSQ_Reburn/releases/tag/v0.28)

下载页面提供 PSQ 本体。想使用独立服装、飞行或其他可选功能，请另外安装对应模组。v0.28 的部分改动还需要进一步进行游戏内验证。

## 功能介绍

- **魅魔成长**：吸取能量，提升等级，解锁魅魔能力和属性加成。
- **自由变身**：切换普通形态与魅魔形态，自定义身形、肤色、发色、纹样和变身特效。
- **服装搭配**：上衣、靴子、手套、角、尾巴和翅膀可以分别选择、自由混搭。
- **身形与皮肤切换**：配合 Body Change NG，为不同形态选择身形和皮肤。
- **扶她外观**：配合 TRX 扶她模组，为不同形态选择外观。
- **其他功能**：包含魅魔纹身、法阵、眷属和使魔等内容，并支持部分其他模组的联动。

游戏内可通过 MCM 菜单调整设置。可用的外观和联动功能取决于已安装的模组。

## 前置需求

### 必需

- 《上古卷轴 V：天际特别版》
- 与游戏版本匹配的 **SKSE64**
- **SkyUI**
- **PapyrusUtil**
- **Heels Sound**
- **SexLab SE 1.63** 或 **P+ 2.19.0**：两者选择一个安装。

使用欲望相关功能还需要相应的欲望模组，例如 SLO Aroused NG 或 OSL Aroused，以及它们各自的前置。

### 按需要安装

- **身体与服装**：RaceMenu、CBBE 3BA、XPMSSE、BodySlide，以及服装要求的 CBPC 或 FSMP。使用 UBE 身体时，请选择与 UBE 匹配的服装和补丁。
- **动作**：Open Animation Replacer（OAR）。部分独立动作需另外安装。
- **身形和皮肤切换**：Body Change NG 1.3.8 及其前置。PSQ 提供对应的兼容文件，但仍需单独安装 Body Change NG 本体。
- **扶她外观**：SOS - TRX - Futanari Addon 及其前置。不安装时，扶她外观功能不可用。
- **飞行**：Wingflight 或 OSYRN 及其前置，需单独安装并使用其菜单和按键。
- **能量感知、眷属眼睛等功能**：powerofthree's Papyrus Extender 及其前置。
- **其他联动**：FHU、SLSO、UIExtensions、EFF／NFF、iNeed、Mannaz 等可根据需要安装。

所有前置请选择与自己的游戏版本相匹配的版本，并查看各自页面的安装要求。

## 服装下载

以下服装可以按喜好选择，不需要全部安装。部分页面可能需要登录或开启成人内容显示。

| 服装 | 下载页面或查找线索 | 安装提示 |
| --- | --- | --- |
| DX Succubus | [SE 原版](https://www.nexusmods.com/skyrimspecialedition/mods/36642) · [CBBE 版](https://www.nexusmods.com/skyrimspecialedition/mods/36619) · [UBE 版](https://www.nexusmods.com/skyrimspecialedition/mods/116652) | 选择与身体匹配的版本。 |
| Helena Succubus | [服装页面](https://rektas.wixsite.com/website/post/helena-succubus) | 选择适合自己身体的 SE 版本。 |
| Dragon Princess | [SE 3BF 版本线索](https://schaken-mods.com/forums/topic/32100-se-dragon-princess-3bf-bs/) | 这是相关移植版线索，作者原址尚未核实；请确认下载的版本与 PSQ 兼容。 |
| Ageha Abyss | 原址待核实 | 请留意版本和下载来源。 |
| TERA Succubus 9DM | [相关 SE 版本](https://schaken-mods.com/file/tera-succubus-9dm-se) | 该页面的版本是否与 PSQ 接入版本完全一致尚待确认；请勿与下方 Harry TERA 混淆。 |
| SucubusSister Shinano | [lilyrim 发布页面](https://www.patreon.com/u11199437/posts/free-shinano-117275572) | 按页面说明安装所需身体及物理前置。 |
| SW Vampire | [相关页面线索](https://arca.live/b/tullius/96130274) | 页面目前无法直接核实，请确认服装版本。 |
| Hirosin X Succubus | [原帖线索](https://arca.live/b/tullius/90058800) · [服装资料](https://modbooru.com/mods/x-succubus-set.1670) | PSQ 使用单独的 Hiroshi／X 魅魔资源包作为备用外观；该资源包不包含在本次下载中。 |
| TERA Succubus Armor（Harry TERA） | [作者页面](https://www.patreon.com/posts/tera-succubus-18130754) · [SE 移植页面](https://www.daymarrworkshop.com/post/tera-succubus-armor-cbbe-tbd-se) | 原版与 SE 移植版请按页面要求选择；不要与 TERA Succubus 9DM 混淆。 |

装好服装后，可以在 PSQ 的 MCM 兼容页面查看是否识别。使用 BodySlide 时，选择与身体相同的预设，构建对应的 PSQ 服装，并勾选 **Build Morphs（建立变形）**。

## MO2 推荐排序

下面是 MO2 **左侧模组列表**的参考顺序，从上到下排列。只安装自己需要的可选内容：

1. 游戏前置、身体、骨骼和物理模组。
2. SexLab 或 P+，以及需要的欲望模组。
3. Body Change NG、TRX 等可选模组及其前置。
4. 想使用的独立服装。
5. **PSQ Reburn 本体**。
6. 适用于当前 PSQ 版本的专用补丁和新建的 BodySlide 服装输出。
7. 单独安装的 Wingflight 或 OSYRN 飞行模组及其汉化。

让 PSQ 覆盖 Body Change NG 和服装原作的相关文件；使用单独飞行模组时，让飞行模组的 `Wingflight.dll` 生效。请在 MO2 中查看文件冲突，避免旧版 PSQ 补丁或旧 BodySlide 输出覆盖新版文件。

MO2 **右侧插件列表**需要另外检查：启用所需的服装插件，并确保没有缺少前置。不要直接照搬左侧的顺序。

## 安装与升级

1. 结束互动、退出变身和飞行，在安全地点保存游戏，并备份存档。
2. 安装所需前置和 PSQ Reburn v0.28，停用旧版 PSQ 及旧的 PSQ 累积补丁。
3. 根据需要安装服装、Body Change NG、TRX 或飞行模组，并按上方建议检查 MO2 排序。
4. 重新启动游戏，在 PSQ 的 MCM 菜单中检查设置和兼容状态，再尝试变身。

卸载前请先退出变身和互动，取回个人储物，并在 MCM 开关页执行卸载准备。建议保留清理前的存档。

## Credit

- **ojanen** — [PSQ PlayerSuccubusQuest for SexLab](https://www.loverslab.com/files/file/667-psq-playersuccubusquest-for-sexlab/) 原作。
- **PSQ 汉化与整合版本的作者及贡献者** — 感谢原有汉化与整合工作。
- **[Body Change NG](https://github.com/compilecraftworks/Body-Change-NG) 的作者与贡献者** — 身形和皮肤管理。
- **TRX Futanari SOS Addon 的作者与贡献者** — 扶她装备和贴图资源。
- **服装、动作、模型、贴图、音效、框架和其他兼容模组的作者与贡献者** — 感谢各位的创作。
- **StoneAR-Tank** — PSQ Reburn 的修改、整合与发布。进化纹样采用 AI 辅助设计。

各资源的权利和许可归其原作者所有；相关许可文件可在本体的 [Docs 文件夹](PSQ-Reburn/Docs/)中查看。

## 支持项目

PSQ Reburn 免费发布。如果你喜欢这个项目，欢迎通过 [Patreon](https://www.patreon.com/c/StoneAS) 赞助支持，感谢！
