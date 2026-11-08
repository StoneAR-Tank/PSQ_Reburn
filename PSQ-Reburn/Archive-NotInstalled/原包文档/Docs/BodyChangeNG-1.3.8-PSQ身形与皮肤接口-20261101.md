# Body Change NG 1.3.8：PSQ身形与皮肤切换

本修订以独立 Body Change NG v1.3.8（compilecraftworks，官方源码提交941c034）为基础，加入PSQ接口；修改DLL版本1.3.8.1，Papyrus API4。不是原作者官方发行版。保留原作者的身体、皮肤切换后端及1.3.8修复；PSQ通过接口发请求，不恢复旧PSQ身形算法。

## 使用

1. 独立安装Body Change NG 1.3.8及其所需的RaceMenu、Address Library；安装符合当前身体体系的身形预设和皮肤包。
2. MO2里让PSQ优先于Body Change提供同名DLL；修改文件均在PSQ目录，独立Body Change目录不改动。只加载一个生效的BodyChangeNG.dll，不把备份DLL放在SKSE/Plugins根目录。
3. MCM→变换→身形预设下面新增“变身皮肤”。它读取Body Change皮肤目录，按角色性别、种族、身体图集过滤；超过120项可翻页。默认“保留当前皮肤”，不额外切换。保留现有肤色调节项。
4. 选择皮肤后关闭菜单；已变身时请求应用，普通形态保存为下次变身使用。退出变身恢复之前的Body Change皮肤选择及其自动／手动模式。变身期间在Body Change手动改选另一皮肤，以新的手动选择为准；重新选择PSQ变身皮肤才重新接管。同一个ID被重新选择无法作为独立手动变更识别。
5. UBE只显示Body Change认为兼容的UBE皮肤，不把CBBE贴图转为UBE；身形、服装、TRX和纹身原有保护保留。完整皮肤切换仍取决于皮肤包本身是否完整、当前运行环境与原生后端是否就绪。

## 独立本体、升级与卸载

独立Body Change为可选前置。PSQ不打包独立本体的目录、设置、资源或用于识别完整安装的distribution-README运行文件；未启用本体时DLL仅注册接口后保持不活动，不安装UI/钩子或写入设置。菜单会停用对应项。不要在正在变身时直接禁用本体，先退出变身并恢复皮肤。

PSQ内的接口DLL会覆盖Body Change同名DLL。以后升级Body Change时，MO2不会自动更新PSQ目录内的接口版；需要与新版对应的PSQ兼容修订。将官方DLL改为优先会使PSQ接口不可用，相关菜单停用，其他PSQ功能保留；不可将未知版本当作已兼容。版本识别避免调用未注册的PSQ原生函数。

## 署名与源码

Body Change NG作者compilecraftworks，原址 https://www.nexusmods.com/skyrimspecialedition/mods/189962 ，源码 https://github.com/compilecraftworks/Body-Change-NG 。修改和再分发依据GPL-3.0，保留作者及第三方声明。PSQ增补临时身形、装备刷新、TRX和皮肤接口，不能将此接口版称为作者官方版。

Docs/BCNG-v1.3.8.1-PSQ-Source.zip为本次DLL对应源码（含修改的依赖模板、构建文件、测试、许可证与版本记录）；只是文档归档，不会覆盖独立模组。旧API3源码属于历史版本，不对应当前DLL。Docs/BodyChangeNG-GPL-3.0-LICENSE.txt保留GPL文本。

## 检查范围

旧SexLab和P+2.19均编译通过；最终字节码离线检查276项，覆盖原UBE接口、版本防护、可选前置、皮肤恢复、手动改选、失败保留、分页、旧读档任务丢弃及单次有界请求。7个原生测试程序通过，包含临时身形、选择所有权、身体体系、皮肤会话、变形皮肤和编辑器生命周期。静态检查和离线测试不能代替游戏内验收；需重启游戏后测试。
