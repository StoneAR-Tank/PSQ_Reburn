# PSQ Reburn v0.37 完整版（手动安装）

本包包含 PSQ 本体和可选组件。一般玩家推荐使用同版 FOMOD，在安装时选择语言、换装方式、分辨率和所需组件。

## 基本安装

先安装所需前置，并将本包安装为一个新的 MO2 模组。根目录已经包含本体、必装原生组件、简体中文、默认换装方式和 2560 × 1600 面板。需要与游戏版本匹配的 SKSE64 和 Address Library。

独立服装、飞行、动作包及各项前置仍需另行安装。升级前先结束互动、退出变身和飞行，备份存档并停用旧版 PSQ。

## 手动选择语言、换装方式与组件

每次更换语言或组件，建议重新安装到干净的新 MO2 条目。按以下顺序只复制所选文件夹**里面的内容**到 PSQ 模组根目录，并允许覆盖；`PACKAGE-MANIFEST.json` 无需复制。不要把整个 Optional、Languages、OutfitMode 或 Panel 文件夹复制到 Data。

1. 简体中文使用根目录默认文件；英文、日文或繁体中文分别复制 `Languages/en/00-Core`、`Languages/ja/00-Core` 或 `Languages/tw/00-Core` 的内容。
2. 选择换装方式：原来的换装方式默认启用，复制 `OutfitMode/<语言代码>/standard`；如果需要换装加速，改为复制 `OutfitMode/<语言代码>/faster`。两种方式都能使用魅魔面板。切换方式前请退出游戏，重装本包并选择替换；已有存档建议从变身前的存档继续。
3. 根据需要，从 `Optional` 选择兼容组件并复制内容。Apropos 2 原版与 Patch 1.0023 组件只能选一个。UBE 与 UBE-DX 同时需要时，先复制 UBE，再复制 UBE-DX。
4. 对选中的每个可选组件，如果所选语言的 `Languages/<语言代码>/<组件代号>` 文件夹存在，再复制其中内容覆盖对应组件。使用 Mysticism 时，需要复制该语言的 `85-PSQ-Lightning-Mysticism` 文件夹内容；UBE-DX 语言文件须在普通 UBE 语言文件之后覆盖。
5. 简体中文面板从 `Panel/<分辨率>` 选择；其他语言从 `Languages/<语言代码>/90-Panel/<分辨率>` 选择。复制该目录内容覆盖本体，支持 2560×1600、2560×1440、1920×1080 和 3840×2160（4K）。
6. 在 MO2 检查所需插件已启用，重启游戏。语言切换后也需要重启游戏。

语言代码：`sc` 简体中文、`en` English、`ja` 日本語、`tw` 繁體中文。韩文 README 是文档翻译，游戏内暂不提供韩语选项。

## 可选组件

- `40-BodyChangeNG-1.3.8`：需要单独安装 Body Change NG 1.3.8，并让 PSQ 的接口文件覆盖本体。
- `50-TRX皮肤`：需要 Body Change 接口与独立 TRX 模组。
- `60-UBE服装`：需要 UBE、SexLab、Heels Sound 和相应原作服装；自行使用 BodySlide 构建。
- `80-UBE-DX`：仅在已安装 UBE 组件并启用 DX Succubus Armor 原作时使用，覆盖普通 UBE 的同名插件。添加或移除 DX 后需要重新选择。
- `85-神秘主义`：需要 Mysticism 2.4.2；会替换 PSQ 主插件，注意再覆盖对应语言的 85 文件。
- `86-本机元素特效`：需要匹配的 SKSE64 和 Address Library。
- `87-奇异符文`：需要 Strange Runes 3.7.3 和 powerofthree's Papyrus Extender；启用 `PSQ - Strange Runes.esp`。
- `90-Apropos修复` 和 `93-Apropos-Patch-1.0023`：只能选择一个。前者用于 Apropos 2 原版；后者用于安装了 Patch 1.0023 的版本。先复制所选文件夹，再按步骤 4 覆盖对应语言的同代号文件夹。

详细说明和署名见 Docs。
