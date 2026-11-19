# PSQ Reburn v0.33 完整版（手动安装）

本包包含 PSQ 本体和可选组件。推荐一般玩家使用同版 FOMOD 安装包：在安装时选择语言、分辨率和所需组件。

## 基本安装

将本包安装为一个新的 MO2 模组，先安装所需前置。根目录已经包含本体、必装原生组件、简体中文和 2560 × 1600 面板。需要与游戏版本匹配的 SKSE64 和 Address Library。其他分辨率和语言按下方说明选择；不要把整个 Optional、Languages 或 Panel 文件夹复制到 Data。

原作服装、独立飞行模组、独立动作包和各项前置仍需另行安装。升级前先结束互动、退出变身和飞行，备份存档并停用旧版 PSQ。

## 手动选择语言、组件与面板

每次更换语言或组件，建议将此压缩包重新安装到干净的新 MO2 条目，避免旧文件残留。按顺序只复制所选文件夹**里面的内容**到 PSQ 模组根目录，并允许覆盖：

1. 简体中文使用根目录默认文件；英文、日文或繁体中文分别复制 `Languages/en/00-Core`、`Languages/ja/00-Core` 或 `Languages/tw/00-Core` 的内容。
2. 根据需要，从 `Optional` 选择兼容组件并复制内容。UBE 与 UBE-DX 同时需要时，先复制 UBE，再复制 UBE-DX。
3. 对选中的每个可选组件，如果所选语言的 `Languages/<语言代码>/<组件代号>` 文件夹存在，再复制其中内容覆盖对应组件。特别是使用 Mysticism 时，必须最后复制该语言的 `85-PSQ-Lightning-Mysticism` 文件夹内容，让语言匹配的主插件生效；UBE-DX 也须在普通 UBE 语言文件之后覆盖。简体中文不需要复制不存在的语言文件夹。
4. 简体中文面板从 `Panel/<分辨率>` 选择；其他语言从 `Languages/<语言代码>/90-Panel/<分辨率>` 选择。复制该目录内容覆盖本体，支持 2560×1600、2560×1440 和 1920×1080。
5. 在 MO2 检查所需插件已启用，重启游戏。语言切换后也需要重启游戏。

语言代码：`sc` 简体中文、`en` English、`ja` 日本語、`tw` 繁體中文。韩文 README 是文档翻译，游戏内暂不提供韩语选项。

## 可选组件

- `40-BodyChangeNG-1.3.8`：需要单独安装 Body Change NG 1.3.8，并让 PSQ 的接口文件覆盖本体。
- `50-TRX皮肤`：需要 Body Change 接口与独立 TRX 模组。
- `60-UBE服装`：需要 UBE、SexLab、Heels Sound 和相应原作服装；自行使用 BodySlide 构建。
- `80-UBE-DX`：仅在已安装 UBE 组件并启用 DX Succubus Armor 原作时使用，覆盖普通 UBE 的同名插件。添加或移除 DX 后需要重新选择。
- `85-神秘主义`：需要 Mysticism 2.4.2；会替换 PSQ 主插件，注意再覆盖对应语言的 85 文件。
- `86-本机元素特效`：需要匹配的 SKSE64 和 Address Library。
- `87-奇异符文`：需要 Strange Runes 3.7.3 和 powerofthree's Papyrus Extender；启用 `PSQ - Strange Runes.esp`。
- `90-Apropos修复`：需要已启用 Apropos 2。

Archive-NotInstalled 为历史资料，不要把其中的文件复制到 Data。详细说明和署名见 Docs。
