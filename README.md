# PSQ Reburn

PSQ Reburn 是《上古卷轴 V：天际特别版》的魅魔系统修改版，基于 **PSQ PlayerSuccubusQuest** 和已有汉化、整合版本继续开发。玩家可以在普通形态和魅魔形态之间切换，通过吸取能量成长，并自定义变身外观、能力和兼容功能。

当前版本：**v0.27** · [下载安装包与更新说明](https://github.com/StoneAR-Tank/PSQ_Reburn/releases/tag/v0.27)

本仓库的 [`PSQ-Reburn/`](PSQ-Reburn/) 是本体文件。Release 只提供本体，独立服装包、动作包和其他模组需自行安装。本版本经过离线检查，尚未完成游戏内验收。

## 功能介绍

- **魅魔成长与能量**：通过互动吸取能量，提升魅魔等级，使用对应的能力、种族特性和属性加成；能量条支持两种显示样式。
- **变身与外观**：设置普通／魅魔形态的外观、身形、肤色、发色、纹样和特效；退出变身后恢复相应外观与装备。
- **六部分变身装备**：上衣、靴子、手套、角、尾巴和翅膀可分别选择。支持检测多套独立服装原作，并由 PSQ 提供对应兼容文件；具体可用部件取决于已安装的原作和资源。
- **Body Change NG 适配**：使用 Body Change NG 管理身形，以及普通形态和魅魔形态各自的扶她皮肤；PSQ 继续管理扶她装备、等级和变身流程。
- **TRX 扶她外观**：可按普通／魅魔形态选择 TRX 普通、轻甲或重甲款式；需另装 TRX 及其前置。
- **框架与可选模组兼容**：支持旧版 SexLab 或 P+，并提供欲望接口、FHU、独立飞行等功能的适配。可用功能取决于所安装的模组及其版本。
- **其他系统**：保留纹身、法阵与特效、眷属和使魔等系统，并提供简体中文菜单。旧乳业与挤奶玩法已移除，FHU 储量转入、消化和精液药剂功能保留。

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
- **Body Change NG 1.3.7 本体及其前置**：使用身形切换或扶她皮肤管理时需要。PSQ 提供适配的 `BodyChangeNG.dll`（1.3.7.3／API3）；在 MO2 中让 PSQ 覆盖 Body Change NG 的同名文件。独立 Body Change NG 本体仍需安装。
- **SOS - TRX - Futanari Addon 及其前置**：使用 TRX 扶她装备时需要，并需按所用身体预设构建对应模型。未安装时，相关功能不可用，其他 PSQ 功能仍可使用。
- **服装原作**：想使用相应的独立服装时，需安装并启用对应原作及其前置。Hiroshi（Set08／X魅魔）资源包单独提供，本次 GitHub 发布不包含该资源包；缺少相关资源时，回退外观可能无法完整显示。
- **Wingflight 或 OSYRN**：飞行本体及其前置需单独安装。使用独立飞行方案时，让所选飞行核心的 `Wingflight.dll` 覆盖 PSQ 内的旧兼容桥，并使用飞行模组自身的菜单和按键。
- **powerofthree's Papyrus Extender**：能量感知、眷属眼睛等扩展功能需要，安装与游戏匹配的版本及其前置。
- **其他可选兼容**：SLSO、FHU、UIExtensions、EFF／NFF、iNeed、Mannaz、GT_SoftBody、TDF、Apropos2 等按需要安装。各模组仍需满足自己的前置要求。

## 安装与升级

1. 结束互动，退出变身和飞行，在地面另存并备份 `.ess` 与对应的 `.skse` 存档，然后退出游戏。
2. 安装 v0.27 本体和所需前置，停用旧版 PSQ 及旧的 PSQ 累积补丁，避免旧脚本覆盖本版。
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

