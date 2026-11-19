# PSQ Reburn

[简体中文](README.md) | [繁體中文](README.zh-TW.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

PSQ Reburn은 《The Elder Scrolls V: Skyrim Special Edition》의 서큐버스 시스템 모드입니다. PSQ PlayerSuccubusQuest와 기존 중국어 번역 및 통합판을 바탕으로 제작했습니다.

서큐버스가 되어 일반 모습과 서큐버스 모습 사이를 전환하고, 에너지를 흡수해 성장하며, 원하는 외형과 의상을 조합할 수 있습니다.

**현재 버전: v0.33**

[PSQ Reburn 다운로드](https://github.com/StoneAR-Tank/PSQ_Reburn/releases/tag/v0.33)

다운로드 페이지에서 완전판 ZIP과 FOMOD 설치 파일을 제공합니다. 일반적으로 FOMOD를 사용하여 필요한 구성 요소를 선택하는 것을 권장합니다. 완전판에는 수동으로 선택할 수 있는 구성 요소가 들어 있습니다. 독립 의상, 비행 및 기타 선택 기능을 사용하려면 해당 모드를 별도로 설치해야 합니다.

**게임 언어:** 설치할 때 중국어 간체, 영어, 일본어, 중국어 번체 중 하나를 선택할 수 있으며 PSQ 설치 화면과 게임 내 텍스트에 적용됩니다. 이 README는 한국어로 제공되지만 게임 내 한국어는 지원하지 않습니다. 언어를 바꾸려면 MO2에서 다시 설치하고 게임을 재시작하세요. 다른 모드의 언어는 바뀌지 않습니다.

## 주요 기능

- **서큐버스 성장**: 에너지를 흡수해 등급을 올리고 능력과 능력치 보너스를 해금합니다.
- **서큐버스 패널**: 게임에서 성장과 상태를 확인하고 일부 설정을 관리합니다. 설치할 때 화면에 맞는 레이아웃을 선택하세요.
- **더 부드러운 변신**: 변신할 때 의상과 외형을 더 빠르게 바꾸고, 원래 모습으로 돌아오면 기존 장비를 다시 착용합니다.
- **자유로운 변신**: 일반 형태와 서큐버스 형태를 전환하고 체형, 피부색, 머리색, 문양, 변신 효과를 설정합니다.
- **의상 조합**: 상의, 부츠, 장갑, 뿔, 꼬리, 날개를 각각 선택하여 조합합니다.
- **체형과 피부 전환**: Body Change NG와 함께 형태별 체형과 피부를 선택합니다.
- **후타나리 외형**: TRX 후타나리 모드와 함께 형태별 외형을 선택합니다.
- **서큐버스 마법 외형**: 필요에 따라 분홍색 원소 마법 효과와 Mysticism 및 Strange Runes 호환 구성 요소를 사용할 수 있습니다.
- **기타 기능**: 서큐버스 문신, 마법진, 권속, 사역마와 일부 다른 모드 연동을 제공합니다.
- **서큐버스 상인과 포만 모드**: 상인에게서 물품을 구입하고, 원하면 포만 모드를 켜 에너지 상태가 성장에 영향을 주도록 설정할 수 있습니다.

게임 내 MCM 메뉴에서 설정을 조정할 수 있습니다. 사용 가능한 외형과 연동 기능은 설치한 모드에 따라 달라집니다.

📖 [서큐버스 등급 및 능력 표](docs/succubus-ranks.ko.md) (v0.29)

📖 [서큐버스 마법 안내](docs/succubus-spells.ko.md) (v0.32)

## 선행 모드

### 필수

- 《The Elder Scrolls V: Skyrim Special Edition》
- 게임 버전에 맞는 **SKSE64**
- 게임 버전에 맞는 **Address Library for SKSE Plugins**
- **SkyUI**
- **PapyrusUtil**
- **Heels Sound**
- **SexLab SE 1.63** 또는 **P+ 2.19.0** 중 하나

흥분도 관련 기능에는 SLO Aroused NG 또는 OSL Aroused 같은 호환 모드와 해당 모드의 선행 조건도 필요합니다.

### 필요에 따라 설치

- **바디와 의상**: RaceMenu, CBBE 3BA, XPMSSE, BodySlide 및 의상에서 요구하는 CBPC 또는 FSMP. UBE 바디를 사용한다면 UBE에 맞는 의상과 패치를 선택하세요.
- **애니메이션**: Open Animation Replacer(OAR). 일부 독립 애니메이션은 별도로 설치해야 합니다.
- **체형과 피부 전환**: Body Change NG 1.3.8 및 그 선행 모드. PSQ가 호환 파일을 제공하지만 Body Change NG 본체는 별도로 설치해야 합니다.
- **후타나리 외형**: SOS - TRX - Futanari Addon 및 그 선행 모드. 설치하지 않으면 해당 기능을 사용할 수 없습니다.
- **비행**: Wingflight 또는 OSYRN 및 그 선행 모드. 별도로 설치하고 해당 모드의 메뉴와 단축키를 사용하세요.
- **마법 외형 호환성**: 필요에 따라 Mysticism 2.4.2 또는 Strange Runes 3.7.3을 설치하세요. 일부 효과에는 게임 버전에 맞는 Address Library도 필요합니다.
- **에너지 감지, 권속의 눈 등**: powerofthree's Papyrus Extender 및 그 선행 모드.
- **서큐버스 마법 배우기**: 학습 메뉴를 열려면 UIExtensions가 필요합니다.
- **기타 연동**: FHU, SLSO, EFF/NFF, iNeed, Mannaz 등을 필요에 따라 설치할 수 있습니다.

모든 선행 모드는 게임 버전에 맞는 것을 선택하고 각 페이지의 설치 조건을 확인하세요.

## 설치 및 업데이트

1. 상호작용을 종료하고 변신 및 비행을 해제한 후 안전한 장소에서 저장하고 세이브를 백업하세요.
2. 필요한 선행 모드와 PSQ Reburn v0.33을 설치하고 이전 PSQ와 누적 패치를 비활성화하세요. FOMOD 첫 페이지에서 언어를 선택한 뒤 해상도에 맞는 패널과 필요한 호환 항목을 선택하세요.
3. 필요에 따라 의상, Body Change NG, TRX 또는 비행 모드를 설치하고 아래 MO2 순서를 확인하세요.
4. 게임을 다시 시작한 뒤 PSQ의 MCM에서 설정과 호환 상태를 확인한 뒤 변신하세요.

삭제하기 전에는 변신과 상호작용을 종료하고 개인 보관함의 물품을 회수한 다음, MCM 스위치 페이지에서 제거 준비를 실행하세요. 정리 전 세이브를 보관하는 것을 권장합니다.

## 의상 다운로드

원하는 의상만 선택하면 되며 전부 설치할 필요는 없습니다. 일부 페이지는 로그인이나 성인 콘텐츠 표시 설정이 필요할 수 있습니다.

| 의상 | 다운로드 페이지 | 설치 안내 |
| --- | --- | --- |
| DX Succubus | [SE 원본](https://www.nexusmods.com/skyrimspecialedition/mods/36642) · [CBBE 버전](https://www.nexusmods.com/skyrimspecialedition/mods/36619) · [UBE 버전](https://www.nexusmods.com/skyrimspecialedition/mods/116652) | 원본은 기본 리소스를 제공합니다. CBBE 또는 UBE 사용자는 각 페이지의 안내에 따라 해당 바디 버전을 설치하세요. |
| Helena Succubus | [의상 페이지](https://rektas.wixsite.com/website/post/helena-succubus) | 사용하는 바디에 맞는 SE 버전을 선택하세요. |
| SucubusSister Shinano | [lilyrim 배포 페이지](https://www.patreon.com/u11199437/posts/free-shinano-117275572) | 페이지에 명시된 바디 및 물리 선행 조건을 설치하세요. |
| TERA Succubus Armor(Harry TERA) | [제작자 페이지](https://www.patreon.com/posts/tera-succubus-18130754) · [SE 이식판](https://www.daymarrworkshop.com/post/tera-succubus-armor-cbbe-tbd-se) | 각 페이지의 설치 조건과 선행 모드를 확인하세요. |

Hiroshi/X 서큐버스 변신 리소스는 PSQ 본체에 포함되어 있습니다.

의상을 설치한 후 PSQ의 MCM 호환성 페이지에서 인식 여부를 확인할 수 있습니다. BodySlide에서 사용하는 바디의 프리셋을 선택하고 해당 PSQ 의상을 빌드할 때 **Build Morphs**를 체크하세요.

## 권장 MO2 순서

다음은 MO2 **왼쪽 모드 목록**의 위에서 아래로 정렬하는 예시입니다. 선택 항목은 필요한 것만 설치하세요.

1. 게임 선행 모드, 바디, 스켈레톤 및 물리 모드.
2. SexLab 또는 P+ 및 필요한 흥분도 모드.
3. Body Change NG, TRX 등 선택 모드와 선행 모드.
4. 사용하려는 독립 의상.
5. **PSQ Reburn 본체**.
6. 현재 PSQ 버전에 맞는 전용 패치와 새로 만든 BodySlide 출력.
7. 별도로 설치한 Wingflight 또는 OSYRN 비행 모드와 번역.

Body Change NG와 의상 원본의 관련 파일은 PSQ가 덮어쓰도록 하세요. 독립 비행 모드를 사용한다면 해당 모드의 `Wingflight.dll`이 적용되도록 하세요. MO2에서 파일 충돌을 확인하여 이전 PSQ 패치나 BodySlide 출력이 새 파일을 덮어쓰지 않게 하세요.

MO2 **오른쪽 플러그인 목록**도 따로 확인하세요. 필요한 의상 플러그인을 활성화하고 누락된 선행 파일이 없는지 확인해야 합니다. 왼쪽 순서를 그대로 복사하지 마세요.

## 추가 정보

v0.33의 필수 C++ 네이티브 구성 요소는 본체와 함께 설치되며 서큐버스 패널, 변신, 독립 의상 연동에 사용됩니다. 게임 버전에 맞는 SKSE64와 Address Library를 설치하세요.

## 크레딧

- **ojanen** — [PSQ PlayerSuccubusQuest for SexLab](https://www.loverslab.com/files/file/667-psq-playersuccubusquest-for-sexlab/) 원작.
- **PSQ 중국어 번역 및 통합판 제작자와 기여자** — 기존 번역과 통합 작업에 감사드립니다.
- **[Body Change NG](https://github.com/compilecraftworks/Body-Change-NG) 제작자와 기여자** — 체형과 피부 관리.
- **TRX Futanari SOS Addon 제작자와 기여자** — 후타나리 장비와 텍스처 리소스.
- **의상, 애니메이션, 모델, 텍스처, 사운드, 프레임워크 및 기타 호환 모드의 제작자와 기여자** — 여러분의 작업에 감사드립니다.
- **StoneAR-Tank** — PSQ Reburn 수정, 통합 및 배포. 진화 문양 디자인에는 AI를 보조적으로 사용했습니다.

각 리소스의 권리와 라이선스는 원작자에게 있습니다. 관련 라이선스 파일은 본체의 [Docs 폴더](PSQ-Reburn/Docs/)에서 확인할 수 있습니다.

## 프로젝트 지원

PSQ Reburn은 무료로 배포됩니다. 프로젝트가 마음에 드셨다면 [Patreon](https://www.patreon.com/c/StoneAS)을 통한 후원을 환영합니다. 감사합니다!
