# PSQ Reburn

[简体中文](README.md) | [繁體中文](README.zh-TW.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

PSQ Reburn は『The Elder Scrolls V: Skyrim Special Edition』向けのサキュバスシステム MOD です。PSQ PlayerSuccubusQuest と、既存の中国語翻訳・統合版を基に制作しています。

サキュバスとなり、通常の姿とサキュバスの姿を切り替え、エネルギーを吸収して成長しながら、好みの外見や衣装を組み合わせられます。

**現在のバージョン：v0.32**

[PSQ Reburn をダウンロード](https://github.com/StoneAR-Tank/PSQ_Reburn/releases/tag/v0.32)

ダウンロードページには完全版 ZIP と FOMOD インストーラーがあります。通常は FOMOD を使い、必要な構成要素を選択してください。完全版には手動で選べる構成要素が含まれます。独立した衣装、飛行などのオプションには、それぞれの MOD を別途インストールする必要があります。一部の機能は引き続きゲーム内での検証が必要です。この翻訳は README のみで、ゲーム内メニューは中国語のままの場合があります。

## 機能紹介

- **サキュバスの成長**：エネルギーを吸収してランクを上げ、能力や属性ボーナスを解放します。
- **変身処理の最適化**：v0.32 では着替え、外見の切り替え、装備の復元の一部を C++ のネイティブコンポーネントで処理し、変身の流れを改善します。FOMOD では推奨の PSQ ネイティブ変身・装備処理を選択してください。ゲームに合った SKSE64 と Address Library が必要です。
- **自由な変身**：通常形態とサキュバス形態を切り替え、体型、肌色、髪色、紋様、変身エフェクトを設定できます。
- **衣装の組み合わせ**：上着、ブーツ、手袋、角、尻尾、翼を個別に選んで組み合わせられます。
- **体型と肌の切り替え**：Body Change NG と組み合わせ、形態ごとの体型と肌を選べます。
- **ふたなり外見**：TRX のふたなり MOD と組み合わせ、形態ごとの外見を選べます。
- **サキュバス魔法の外見**：必要に応じてピンク色の元素魔法エフェクトや、Mysticism・Strange Runes 用の互換コンポーネントを使えます。
- **その他**：サキュバスのタトゥー、魔法陣、眷属、使い魔などと、一部の MOD との連携に対応します。
- **サキュバス商人と満腹モード**：商人からアイテムを購入でき、満腹モードを有効にするとエネルギー状態が成長に影響します。

設定はゲーム内の MCM メニューで変更できます。利用できる外見や連携機能は、インストールした MOD によって異なります。

📖 [サキュバスのランクと能力一覧](docs/succubus-ranks.ja.md)

## 必要なもの

### 必須

- 『The Elder Scrolls V: Skyrim Special Edition』
- ゲームバージョンに合った **SKSE64**
- **SkyUI**
- **PapyrusUtil**
- **Heels Sound**
- **SexLab SE 1.63** または **P+ 2.19.0**：どちらか一方を選択。

欲情関連の機能には、SLO Aroused NG や OSL Aroused などの対応 MOD と、その前提 MOD も必要です。

### 必要に応じてインストール

- **体型と衣装**：RaceMenu、CBBE 3BA、XPMSSE、BodySlide、および衣装が要求する CBPC または FSMP。UBE を使用する場合は UBE 対応の衣装とパッチを選んでください。
- **アニメーション**：Open Animation Replacer（OAR）。一部の独立したアニメーションは別途必要です。
- **体型・肌の切り替え**：Body Change NG 1.3.8 とその前提 MOD。PSQ には互換ファイルが含まれますが、Body Change NG 本体は別途必要です。
- **ふたなり外見**：SOS - TRX - Futanari Addon とその前提 MOD。未導入の場合、この機能は利用できません。
- **飛行**：Wingflight または OSYRN とその前提 MOD。別途インストールし、それぞれのメニューとキーを使用します。
- **魔法の外見互換**：必要に応じて Mysticism 2.4.2 または Strange Runes 3.7.3。一部のエフェクトにはゲームバージョンに合った Address Library も必要です。
- **エネルギー感知、眷属の目など**：powerofthree's Papyrus Extender とその前提 MOD。
- **その他の連携**：FHU、SLSO、UIExtensions、EFF／NFF、iNeed、Mannaz などを必要に応じて導入できます。

すべての前提 MOD はゲームバージョンに合ったものを選び、各ページの導入条件を確認してください。

## 衣装のダウンロード

好みの衣装だけを選んでください。すべてを導入する必要はありません。ページによってはログインまたは成人向けコンテンツの表示設定が必要です。

| 衣装 | ダウンロード先または関連情報 | 導入時の注意 |
| --- | --- | --- |
| DX Succubus | [SE 原版](https://www.nexusmods.com/skyrimspecialedition/mods/36642) · [CBBE 版](https://www.nexusmods.com/skyrimspecialedition/mods/36619) · [UBE 版](https://www.nexusmods.com/skyrimspecialedition/mods/116652) | 体型に合う版を選択。 |
| Helena Succubus | [衣装ページ](https://rektas.wixsite.com/website/post/helena-succubus) | 体型に合う SE 版を選択。 |
| Dragon Princess | [SE 3BF 版の情報](https://schaken-mods.com/forums/topic/32100-se-dragon-princess-3bf-bs/) | 関連する移植版の情報です。作者の原本ページは未確認のため、PSQ との互換性を確認してください。 |
| Ageha Abyss | 原本ページ未確認 | バージョンと配布元を確認してください。 |
| TERA Succubus 9DM | [関連する SE 版](https://schaken-mods.com/file/tera-succubus-9dm-se) | PSQ 対応版と完全に一致するかは未確認です。下記 Harry TERA と混同しないでください。 |
| SucubusSister Shinano | [lilyrim の配布ページ](https://www.patreon.com/u11199437/posts/free-shinano-117275572) | ページに記載された体型・物理演算の前提を導入してください。 |
| SW Vampire | [関連ページの情報](https://arca.live/b/tullius/96130274) | ページを直接確認できていないため、衣装の版を確認してください。 |
| Hirosin X Succubus | [元投稿の情報](https://arca.live/b/tullius/90058800) · [衣装情報](https://modbooru.com/mods/x-succubus-set.1670) | PSQ 用 Hiroshi／X サキュバス変身リソースは本体に含まれます。独立衣装は必要に応じて導入。 |
| TERA Succubus Armor（Harry TERA） | [作者ページ](https://www.patreon.com/posts/tera-succubus-18130754) · [SE 移植版](https://www.daymarrworkshop.com/post/tera-succubus-armor-cbbe-tbd-se) | 各ページの条件を確認し、TERA Succubus 9DM と混同しないでください。 |

衣装導入後、PSQ の MCM 互換ページで認識状態を確認できます。BodySlide では使用する体型のプリセットを選び、対応する PSQ 衣装を **Build Morphs** を有効にして構築してください。

## MO2 の推奨順序

MO2 の**左側の MOD 一覧**で、上から下への参考順序です。オプションは必要なものだけ導入してください。

1. ゲームの前提 MOD、体型、スケルトン、物理演算 MOD。
2. SexLab または P+ と、必要な欲情 MOD。
3. Body Change NG、TRX などのオプション MOD と前提。
4. 使用する独立衣装。
5. **PSQ Reburn 本体**。
6. 現在の PSQ 版用パッチと、新しく構築した BodySlide 出力。
7. 別途導入する Wingflight または OSYRN とその翻訳。

Body Change NG と衣装原作の関連ファイルは PSQ で上書きしてください。独立飛行 MOD を使う場合は、その MOD の `Wingflight.dll` を優先します。MO2 の競合を確認し、古い PSQ パッチや BodySlide 出力が新版を上書きしないようにしてください。

MO2 **右側のプラグイン一覧**も別途確認してください。必要な衣装プラグインを有効にし、前提が不足していないことを確認します。左側の順序をそのままコピーしないでください。

## インストールと更新

1. シーンを終了し、変身と飛行を解除して安全な場所でセーブし、セーブデータをバックアップします。
2. 必要な前提と PSQ Reburn v0.32 を導入し、旧 PSQ と旧累積パッチを無効にします。FOMOD は有効な前提に応じて一部を推奨するため、版を確認して必要に応じて調整してください。
3. 必要に応じて衣装、Body Change NG、TRX、飛行 MOD を導入し、上記の MO2 順序を確認します。
4. ゲームを再起動し、PSQ の MCM で設定と互換状態を確認してから変身を試します。

アンインストール前には変身とシーンを終了し、個人収納の中身を回収してから、MCM のスイッチページでアンインストール準備を実行してください。整理前のセーブを残すことを推奨します。

## クレジット

- **ojanen** — [PSQ PlayerSuccubusQuest for SexLab](https://www.loverslab.com/files/file/667-psq-playersuccubusquest-for-sexlab/) 原作。
- **PSQ 中国語翻訳・統合版の作者と貢献者** — 翻訳・統合作業に感謝します。
- **[Body Change NG](https://github.com/compilecraftworks/Body-Change-NG) の作者と貢献者** — 体型・肌の管理。
- **TRX Futanari SOS Addon の作者と貢献者** — ふたなり装備とテクスチャ。
- **衣装、アニメーション、モデル、テクスチャ、音声、フレームワーク、その他の互換 MOD の作者と貢献者** — 制作に感謝します。
- **StoneAR-Tank** — PSQ Reburn の改変、統合、公開。進化紋様には AI を補助的に使用しています。

各リソースの権利とライセンスはそれぞれの作者に帰属します。関連ライセンスは本体の [Docs フォルダー](PSQ-Reburn/Docs/)を参照してください。

## プロジェクトを支援

PSQ Reburn は無料で公開しています。気に入っていただけたら、[Patreon](https://www.patreon.com/c/StoneAS) でのご支援を歓迎します。ありがとうございます！
