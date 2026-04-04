# 띠배너 광고(AdMob) 도입 준비 사항


## 1. Google AdMob 계정 설정

- [AdMob 콘솔](https://admob.google.com) 가입/로그인
- **앱 2개 등록**: Android(`kr.co.anbucheck.live`) + iOS(`kr.co.anbucheck.live`)
- **광고 단위(Ad Unit) 생성**: 배너 타입으로 앱별 각각 생성
  - Android 배너 Ad Unit ID (`ca-app-pub-xxxx/yyyy`)
  - iOS 배너 Ad Unit ID (`ca-app-pub-xxxx/zzzz`)
- 테스트용 Ad Unit ID는 Google이 제공 (개발 중 사용)


## 2. Flutter 패키지 추가

```yaml
# pubspec.yaml
dependencies:
  google_mobile_ads: ^5.3.0  # 최신 버전 확인
```


## 3. 플랫폼별 네이티브 설정

### Android — `android/app/src/main/AndroidManifest.xml`

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
```

### iOS — `ios/Runner/Info.plist`

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
  <!-- Google 제공 SKAdNetwork 목록 추가 -->
</array>
```


## 4. 구현 필요 코드

| 파일 | 역할 |
|------|------|
| `lib/app/core/services/ad_service.dart` | AdMob 초기화, 배너 로드/해제 관리 |
| `lib/app/core/widgets/banner_ad_widget.dart` | 공통 배너 광고 위젯 |
| `lib/app/core/config/ad_config.dart` | Ad Unit ID 상수 (플랫폼별 분기) |


## 5. 앱 초기화

- `main.dart`에서 `MobileAds.instance.initialize()` 호출 (앱 시작 시 1회)


## 6. 비즈니스 로직 고려사항

- **유료 구독 보호자는 광고 제거** — 구독 상태 확인 후 배너 표시/숨김 분기
- **대상자 앱은 항상 광고 표시** (무료이므로)
- 배너 높이만큼 하단 여백 확보 (BottomNavigationBar 위 또는 콘텐츠 하단)


## 7. 스토어 심사 대비

- AdMob 개인정보처리방침에 광고 SDK 데이터 수집 내용 추가
- iOS: App Tracking Transparency(ATT) 팝업은 선택 (배너 광고는 ATT 없이도 동작)
- Google Play: 광고 포함 앱 표기 체크


## 8. 우선순위 순서

1. AdMob 계정 + 앱 등록 + Ad Unit ID 발급
2. 패키지 추가 + 네이티브 설정
3. `ad_service.dart` + `banner_ad_widget.dart` 구현
4. 대상자 홈 / 보호자 대시보드에 배너 위젯 배치
5. 구독 상태 기반 광고 표시/숨김 로직
