# PSQ Reburn v0.3 完整版（手动选择组件）

本包包含 PSQ 本体及其 FOMOD 中的全部可选组件。普通用户建议使用同版 FOMOD 安装包，由安装器根据前置推荐选项。

## 基本安装

将本包安装为 MO2 的一个新模组，启用本体及所需前置。原作服装、独立飞行模组、独立动作包及各项前置仍需另行安装。安装前先退出变身和互动，备份存档，停用旧版 PSQ 和旧兼容补丁。

## 可选组件

Optional 文件夹内的内容不会自动生效；需要时只把所选文件夹内的内容合并到 PSQ 模组根目录，选择覆盖，不要直接把整个 Optional 文件夹复制到 Data。各组件需满足自己的前置：

- 10-配件隐藏：需要与游戏版本匹配的 SKSE 和 Address Library。
- 40-BodyChangeNG-1.3.8：仅用于已单独安装 Body Change NG 1.3.8 的环境；让 PSQ 的接口文件覆盖其本体。
- 50-TRX皮肤：需要 Body Change 接口和独立 TRX 扶她模组。
- 60-UBE服装：仅用于已安装 UBE、SexLab 和 Heels Sound 的环境；按身形预设在 BodySlide 构建。
- 80-UBE-DX：仅在已安装 60-UBE 服装且启用 DX Succubus Armor 原作时选择，覆盖 60-UBE 中同名 PSQ UBE Outfits.esp；不要同时启用两个同名版本。添加或移除 DX 后需要重新选择。
- 90-Apropos修复：需要已启用 Apropos 2。

Archive-NotInstalled 为历史资料，不要将它的文件复制到 Data 或覆盖当前身体、物理及飞行模组。详细说明和署名见 Docs。

本包与同版 FOMOD 来自同一份本体文件；现有适配部分经离线检查与部分游戏实测，不代表所有组合均已验证。
