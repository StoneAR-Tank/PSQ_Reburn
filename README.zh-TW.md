# PSQ Reburn

[简体中文](README.md) | [繁體中文](README.zh-TW.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

PSQ Reburn 是《上古卷軸 V：無界天際特別版》的魅魔系統模組，基於 PSQ PlayerSuccubusQuest 和既有漢化、整合版本繼續製作。

成為魅魔，在普通形態與魅魔形態之間切換，透過吸取能量成長，並搭配自己喜歡的外觀與服裝。

**目前版本：v0.34**

[下載 PSQ Reburn](https://github.com/StoneAR-Tank/PSQ_Reburn/releases/tag/v0.34)

下載頁面提供完整版和 FOMOD 安裝包。一般玩家推薦使用 FOMOD，在安裝時選擇需要的組件；完整版包含可手動選擇的組件。獨立服裝、飛行或其他可選功能仍需另裝對應模組。

**遊戲語言**：安裝時可選擇簡體中文、英文、日文或繁體中文，PSQ 安裝畫面與遊戲內文字會使用所選語言。更換語言時，請在 MO2 重新安裝並重新啟動遊戲。其他模組仍使用各自的語言。

## 功能介紹

- **魅魔成長**：吸取能量、提升等級，解鎖魅魔能力和屬性加成。
- **魅魔面板**：在遊戲中查看成長與狀態、管理部分魅魔設定；安裝時可選擇適合螢幕的配置，包含 4K。
- **變身換裝**：變身時更換服裝，恢復原形後換回原來的裝備。安裝時可選擇開啟換裝加速，預設使用原本的換裝方式。
- **自由變身**：切換普通形態與魅魔形態，自訂身形、膚色、髮色、紋樣和變身特效。
- **服裝搭配**：上衣、靴子、手套、角、尾巴和翅膀可以分別選擇、自由混搭。
- **身形與皮膚切換**：搭配 Body Change NG，為不同形態選擇身形和皮膚。
- **扶她外觀**：搭配 TRX 扶她模組，為不同形態選擇外觀。
- **魅魔法術外觀**：可按需使用元素法術粉色特效，並安裝 Mysticism 和 Strange Runes 相容組件。
- **其他功能**：包含魅魔紋身、法陣、眷屬和使魔等內容，並支援部分其他模組的連動。
- **魅魔商人與飽食模式**：向魅魔商人購買物品，也可以按需開啟飽食模式，讓能量狀態影響成長。

遊戲內可透過 MCM 選單調整設定。可用的外觀和連動功能取決於已安裝的模組。

📖 [查看魅魔等級與能力圖表](docs/succubus-ranks.zh-TW.md)（v0.29）

📖 [查看魅魔法術說明圖表](docs/succubus-spells.zh-TW.md)（v0.32）

## 前置需求

### 必要

- 《上古卷軸 V：無界天際特別版》
- 與遊戲版本相符的 **SKSE64**
- 與遊戲版本相符的 **Address Library for SKSE Plugins**
- **SkyUI**
- **PapyrusUtil**
- **Heels Sound**
- **SexLab SE 1.63** 或 **P+ 2.19.0**：兩者擇一安裝。

使用慾望相關功能還需要相應的慾望模組，例如 SLO Aroused NG 或 OSL Aroused，以及它們各自的前置。

### 按需安裝

- **身體與服裝**：RaceMenu、CBBE 3BA、XPMSSE、BodySlide，以及服裝要求的 CBPC 或 FSMP。使用 UBE 身體時，請選擇與 UBE 相符的服裝和補丁。
- **動作**：Open Animation Replacer（OAR）。部分獨立動作需另行安裝。
- **身形與皮膚切換**：Body Change NG 1.3.8 及其前置。PSQ 提供對應相容檔案，但仍需單獨安裝 Body Change NG 本體。
- **扶她外觀**：SOS - TRX - Futanari Addon 及其前置。不安裝時，此功能不可用。
- **飛行**：Wingflight 或 OSYRN 及其前置，需單獨安裝並使用其選單和按鍵。
- **魅魔法術外觀相容**：按需安裝 Mysticism 2.4.2 或 Strange Runes 3.7.3；部分特效還需要與遊戲版本相符的 Address Library。
- **能量感知、眷屬眼睛等功能**：powerofthree's Papyrus Extender 及其前置。
- **學習魅魔法術**：UIExtensions，用來開啟「學習」法術選單。
- **其他連動**：FHU、SLSO、EFF／NFF、iNeed、Mannaz 等可按需安裝。

所有前置請選擇與自己遊戲版本相符的版本，並查看各自頁面的安裝要求。

## 安裝與升級

1. 結束互動、退出變身和飛行，在安全地點存檔，並備份存檔。
2. 安裝所需前置和 PSQ Reburn v0.34，停用舊版 PSQ 及舊的 PSQ 累積補丁。在 FOMOD 首頁選擇語言，按需開啟換裝加速、選擇相容組件，並依遊戲解析度選擇魅魔面板。
3. 按需安裝服裝、Body Change NG、TRX 或飛行模組，並按下方建議檢查 MO2 排序。
4. 重新啟動遊戲，在 PSQ 的 MCM 選單中檢查設定和相容狀態，然後即可變身。

解除安裝前請先退出變身和互動，取回個人儲物，並在 MCM 開關頁執行解除安裝準備。建議保留清理前的存檔。

## 服裝下載

以下服裝可按喜好選擇，不需要全部安裝。部分頁面可能需要登入或開啟成人內容顯示。

| 服裝 | 下載頁面 | 安裝提示 |
| --- | --- | --- |
| DX Succubus | [SE 原版](https://www.nexusmods.com/skyrimspecialedition/mods/36642) · [CBBE 版](https://www.nexusmods.com/skyrimspecialedition/mods/36619) · [UBE 版](https://www.nexusmods.com/skyrimspecialedition/mods/116652) | 原版提供基礎資源；CBBE 或 UBE 使用者請按頁面要求安裝相應身形版本。 |
| Helena Succubus | [服裝頁面](https://rektas.wixsite.com/website/post/helena-succubus) | 選擇適合自己身體的 SE 版本。 |
| SucubusSister Shinano | [lilyrim 發布頁面](https://www.patreon.com/u11199437/posts/free-shinano-117275572) | 按頁面說明安裝所需身體及物理前置。 |
| TERA Succubus Armor（Harry TERA） | [作者頁面](https://www.patreon.com/posts/tera-succubus-18130754) · [SE 移植頁面](https://www.daymarrworkshop.com/post/tera-succubus-armor-cbbe-tbd-se) | 按頁面要求安裝對應版本及前置。 |

PSQ 本體已包含 Hiroshi／X 魅魔的變身資源。

裝好服裝後，可在 PSQ 的 MCM 相容頁面查看是否識別。使用 BodySlide 時，選擇與身體相同的預設，構建對應的 PSQ 服裝，並勾選 **Build Morphs（建立變形）**。

## MO2 推薦排序

以下是 MO2 **左側模組清單**從上到下的參考順序，只需安裝自己需要的可選內容：

1. 遊戲前置、身體、骨骼和物理模組。
2. SexLab 或 P+，以及需要的慾望模組。
3. Body Change NG、TRX 等可選模組及其前置。
4. 想使用的獨立服裝。
5. **PSQ Reburn 本體**。
6. 適用於目前 PSQ 版本的專用補丁和新建的 BodySlide 服裝輸出。
7. 單獨安裝的 Wingflight 或 OSYRN 飛行模組及其漢化。

讓 PSQ 覆蓋 Body Change NG 和服裝原作的相關檔案；使用獨立飛行模組時，讓飛行模組的 `Wingflight.dll` 生效。請在 MO2 中查看檔案衝突，避免舊版 PSQ 補丁或舊 BodySlide 輸出覆蓋新版檔案。

MO2 **右側插件清單**需要另行檢查：啟用所需服裝插件，並確保沒有缺少前置。不要直接照搬左側順序。

## 更多說明

v0.34 的 C++ 原生組件隨本體安裝，用於魅魔面板、變身和獨立服裝接入。請安裝與遊戲版本相符的 SKSE64 和 Address Library。

## 致謝

- **ojanen** — [PSQ PlayerSuccubusQuest for SexLab](https://www.loverslab.com/files/file/667-psq-playersuccubusquest-for-sexlab/) 原作。
- **PSQ 漢化與整合版本的作者及貢獻者** — 感謝原有漢化與整合工作。
- **[Body Change NG](https://github.com/compilecraftworks/Body-Change-NG) 的作者與貢獻者** — 身形和皮膚管理。
- **TRX Futanari SOS Addon 的作者與貢獻者** — 扶她裝備和貼圖資源。
- **服裝、動作、模型、貼圖、音效、框架和其他相容模組的作者與貢獻者** — 感謝各位的創作。
- **StoneAR-Tank** — PSQ Reburn 的修改、整合與發布。進化紋樣採用 AI 輔助設計。

各資源的權利和許可歸其原作者所有；相關許可檔案可在本體的 [Docs 資料夾](PSQ-Reburn/Docs/)中查看。

## 支持專案

PSQ Reburn 免費發布。如果你喜歡這個專案，歡迎透過 [Patreon](https://www.patreon.com/c/StoneAS) 贊助支持，感謝！
