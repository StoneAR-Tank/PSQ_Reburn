# PSQ v0.29 可选 UBE 变身服装

通过本体 FOMOD 选择安装普通 UBE。无需另装服装适配包；对应原作与前置仍需自行安装。BodySlide 由玩家自行构建。以下来源与资源限制沿用已核验的服装资源包。

## 原作与功能前置

PSQ 根据当前种族使用 3BA 或 UBE 装备。身形切换仍由匹配的 Body Change NG 接口负责，本包只提供服装资源。

支持的九套为 DX、海伦娜、龙之公主、凤蝶深渊、TERA 魅魔2、信浓魅魔姐妹、吸血鬼、Hiroshi、TERA 魅魔。除已随包提供的 Hiroshi 外，选择哪套就需要安装对应原服装及其贴图、物理和前置；不要求为了普通 3BA 选项把八个原作全部安装。

| 服装 | 原作插件名 |
| --- | --- |
| DX 魅魔 | `DX Succubus Armor.esp` |
| 海伦娜魅魔 | `Helena Succubus [SE].esp` |
| 龙之公主 | `BBP_Dragon_Princess.esp` |
| 凤蝶深渊 | `C5Kev's Ageha Abyss Armor.esp` |
| TERA 魅魔2 | `TR9DmRxSS_HR.esp` |
| 信浓魅魔姐妹 | `gui-SucubusSister Shinano.esp` |
| 吸血鬼 | `(SSE) SW vampire.esp` |
| TERA 魅魔 | `TeraSuccubusArmor.esp` |

普通版需要相应 CBBE 3BA 环境。UBE 需要 UBE 本体、对应皮肤及合适的 UBE 预设。衣物 SMP 按各原作要求配置 FSMP。Softbody 兼容层不会安装 GT Softbody、UBE Components、BOINGNATURAL、MuSkeletonEditor 或它们的全局配置。

## BodySlide

预建游戏模型已包含。若重新构建，选择对应的 **PSQ 服装工程**和匹配的 3BA／UBE 预设，勾选“建立变形”。原服装的独立工程与 PSQ 变身工程输出路径不同，只构建原服装不会自动更新 PSQ 的模型。

为避免覆盖其他模组的源数据，本包把工程所需的构建数据放入独立 ShapeData 命名空间；保持 PSQ 游戏输出路径和可用工程名。没有把裸身工程或个人预设加入服装组。UBE 编辑参考项目仍由 UBE 本体提供。


## BodySlide 变身服装

按角色身形选择「PSQ 3BA Outfits」或「PSQ UBE Outfits」，搜索套装名并勾选“建立变形”构建。八套外部服装按需自行安装，Hiroshi 资源随本体提供。普通 UBE 在 FOMOD 中单独勾选。

DX 转换沿用作者发布的 UBE 资源。
