<div align="center">

# 📄 for_selling

### 견적서 · 거래명세서 작성 & PDF 출력 앱

업체 정보를 등록해두고, 품목만 입력하면<br/>
**견적서**와 **거래명세서**를 깔끔한 PDF로 즉시 만들어 인쇄·공유할 수 있는 Android 앱입니다.

<br/>

![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![State](https://img.shields.io/badge/State-Provider-4285F4)
![Storage](https://img.shields.io/badge/Storage-Hive-FFCA28)

</div>

---

## ✨ 주요 기능

| 기능 | 설명 |
|------|------|
| 🧾 **두 가지 문서** | 견적서 / 거래명세서를 탭으로 전환하며 작성 |
| 🏢 **업체 관리** | 내업체 · 거래처 정보를 등록/수정/삭제하고 불러오기 |
| ⭐ **자주 쓰는 품목** | 내업체별 품목 프리셋을 저장해 한 번에 추가 |
| 💰 **세액 자동 계산** | 부가세 10% 자동 분리 — **세액 포함/제외 토글** 지원 |
| 🔤 **한글 금액 변환** | 합계 금액을 한글(예: `오십육만칠천원`)로 자동 표기 |
| 🏦 **계좌정보 표시** | 문서 하단에 입금 계좌 정보 선택 표시 |
| 📤 **PDF 미리보기 · 인쇄 · 공유** | 실시간 미리보기 후 바로 인쇄하거나 파일로 공유 |
| 💾 **로컬 저장** | 업체/품목 데이터를 기기 내부(Hive)에 안전하게 보관 |

---

## 🖼️ 화면

> 스크린샷을 추가하려면 `docs/` 폴더에 이미지를 넣고 아래 경로를 수정하세요.

| 문서 작성 | PDF 미리보기 | 업체 관리 |
|:---:|:---:|:---:|
| _준비 중_ | _준비 중_ | _준비 중_ |

---

## 🛠️ 기술 스택

- **Flutter / Dart** — 크로스플랫폼 UI 프레임워크
- **[provider](https://pub.dev/packages/provider)** — 상태 관리
- **[hive](https://pub.dev/packages/hive) · [hive_flutter](https://pub.dev/packages/hive_flutter)** — 로컬 NoSQL 저장
- **[pdf](https://pub.dev/packages/pdf) · [printing](https://pub.dev/packages/printing)** — PDF 생성 · 미리보기 · 인쇄/공유
- **[intl](https://pub.dev/packages/intl)** — 금액 콤마 · 날짜 포맷
- **[path_provider](https://pub.dev/packages/path_provider)** — 저장 경로 접근

---

## 🚀 시작하기

### 요구 사항
- Flutter SDK **3.41+** (Dart 3.10+)
- Android Studio (Android SDK + 에뮬레이터 또는 실제 기기)
- JDK 17

### 설치 & 실행
```bash
# 1) 의존성 설치
flutter pub get

# 2) 연결된 기기 확인
flutter devices

# 3) 실행 (에뮬레이터 또는 USB 디버깅 기기)
flutter run
```

### 릴리스 APK 빌드
```bash
flutter build apk --release
# 결과물: build/app/outputs/flutter-apk/app-release.apk

# 기기별 용량 최적화가 필요하면
flutter build apk --split-per-abi
```

> ⚠️ 현재 release 빌드는 **디버그 키**로 서명됩니다. 정식 배포(플레이스토어 등) 시
> [`android/app/build.gradle.kts`](android/app/build.gradle.kts)에 별도 서명 키(keystore)를 설정하세요.

---

## 📂 프로젝트 구조

```
lib/
├── app/
│   └── app.dart                 # MaterialApp · 테마 · 로케일 설정
├── core/
│   ├── services/
│   │   └── pdf_service.dart      # 템플릿 위에 좌표 기반으로 PDF 렌더링
│   └── utils/
│       └── formatters.dart       # 금액/사업자번호/전화/한글금액 포맷
├── data/
│   └── models/
│       ├── company.dart          # 업체 · 품목 프리셋 모델 (Hive)
│       └── item.dart             # 품목(단가·수량·공급가액·세액)
├── state/
│   └── providers/
│       └── doc_provider.dart     # 문서 작성 상태 (품목/합계/세액모드 등)
├── ui/
│   └── screens/
│       ├── home_screen.dart      # 문서 작성 + PDF 미리보기
│       └── companies_screen.dart # 업체 · 품목 관리
└── main.dart                     # 앱 진입점 · Hive 초기화

assets/
├── templates/                    # 견적서 · 거래명세서 배경 이미지
├── fonts/                        # NotoSansKR (한글 폰트)
└── icon/                         # 앱 아이콘
```

---

## 📝 사용 방법

1. **업체 등록** — 좌측 메뉴(☰)에서 내업체와 거래처를 등록합니다.
2. **문서 선택** — 상단 탭에서 `견적서` 또는 `거래명세서`를 고릅니다.
3. **정보 입력** — 업체 선택, 날짜, 품목(품명·수량·단가)을 입력합니다.
4. **세액 설정** — 합계 영역의 **세액 포함** 스위치로 부가세 표기 여부를 조절합니다.
5. **PDF 출력** — `PDF 미리보기` → 인쇄 또는 공유 버튼으로 내보냅니다.

---

<div align="center">

Made with ❤️ using **Flutter**

</div>
