---
name: install-release
description: Android 실기기 release 설치(기기 설치/설치해줘/실기기 설치/release 설치/apk 설치/다른 기기 설치). 무선(adb connect)으로 QA 기기를 연결한 뒤 release APK를 빌드해 설치 (flutter run 금지, 항상 connect → build → install 순서). "다른 기기 설치" 명령은 재빌드 없이 기존 APK만 새로 연결된 기기에 설치
---

# 실기기 release 설치 Skill

## 설명
Android 실기기에 release 빌드를 설치한다. QA 기기는 무선(adb connect)으로 연결한 뒤, **반드시 먼저 APK를 빌드한 뒤 install 명령으로 기기에 넣는다.** `flutter run --release`는 사용하지 않는다 (빌드 산출물이 남지 않고, 여러 기기 설치 시 재빌드가 발생한다).

## 명령 구분

- **"설치해줘 / 기기 설치 / 실기기 설치 / release 설치 / apk 설치"**: 아래 절차 1~4 전체 실행 (connect → build → install)
- **"다른 기기 설치"**: 재빌드 건너뛰고 절차 1(무선 연결) → 절차 2(`flutter devices` 재확인) → 절차 4만 실행. 직전에 이미 release 빌드한 `app-release.apk`를 그대로 새로 연결된 기기에 설치하는 용도. 소스 변경 후에는 이 명령을 쓰지 말 것 — 변경이 반영되지 않는다.

## QA 기기 무선 IP 목록

DHCP라 IP가 바뀔 수 있다. 연결 실패가 반복되면 USB로 1회 연결해 `"$HOME/Library/Android/sdk/platform-tools/adb" -s <serial> shell ip addr show wlan0`(Xiaomi는 `wlan1`)로 새 IP를 확인하고 아래 목록을 갱신한다.

| 모델 | 무선 주소 |
| --- | --- |
| SM-A325N (Galaxy A32) | `10.160.142.227:5555` |
| 23021RAA2Y (Redmi) | `10.160.142.125:5555` |

## 절차

1. QA 기기 무선 연결 (Wi-Fi 끊김 대비 재시도 포함)
   ```bash
   ADB="$HOME/Library/Android/sdk/platform-tools/adb"
   DEVICES=(
     "10.160.142.227:5555"   # SM-A325N (Galaxy A32)
     "10.160.142.125:5555"   # 23021RAA2Y (Redmi)
   )
   for IP in "${DEVICES[@]}"; do
     "$ADB" disconnect "$IP" >/dev/null 2>&1   # stale/offline 연결 정리
     STATE=""
     for i in 1 2 3 4 5; do
       "$ADB" connect "$IP" >/dev/null 2>&1
       STATE=$("$ADB" -s "$IP" get-state 2>/dev/null)
       [ "$STATE" = "device" ] && { echo "$IP: connected"; break; }
       sleep 2
     done
     [ "$STATE" != "device" ] && echo "$IP: 연결 실패"
   done
   "$ADB" devices -l
   ```
   - Wi-Fi가 잠깐 끊겼다 복구되는 경우는 위 재시도 루프(5회 × 2초)가 흡수한다. `adb connect`만으로는 stale 연결이 `offline`로 남을 수 있어 매번 `disconnect` 후 재연결하고, `get-state`로 실제 응답까지 확인한다.
   - 일부 기기만 `연결 실패`면 치명적이지 않다 — 그 기기만 빼고 진행하되, 어떤 기기가 빠졌는지 사용자에게 명시한다.
   - 모든 기기가 `연결 실패`면: (a) 기기 Wi-Fi가 실제로 꺼졌거나 다른 네트워크, (b) 재부팅으로 tcpip 모드가 풀린 상태다. USB로 1회 연결해 `"$ADB" -s <serial> tcpip 5555` 후 다시 `connect`해야 한다고 안내하고, IP가 바뀐 경우 위 "QA 기기 무선 IP 목록"의 갱신 방법을 함께 안내한다.
   - 화면 꺼짐(Doze) 상태에서 Wi-Fi가 자주 끊긴다면, 기기 개발자 옵션의 **"충전 중 화면 켜짐 유지"**를 켜두면 빌드/설치 중 끊김이 크게 줄어든다고 사용자에게 한 번 안내해도 좋다.

2. 연결된 기기 확인
   ```bash
   flutter devices
   ```
   - Android 실기기(physical)만 대상. simulator/emulator/desktop/web 제외.
   - 무선 기기는 `<ip>:5555` 형태의 device id로 표시된다.
   - 연결된 Android 실기기가 하나도 없으면 사용자에게 알리고 종료.

3. release APK 빌드 (1회만)
   ```bash
   flutter build apk --release
   ```
   - 산출물: `build/app/outputs/flutter-apk/app-release.apk`
   - 빌드 실패 시 중단하고 에러 원인 보고.

4. 연결된 각 Android 실기기에 설치
   ```bash
   flutter install --release -d <device_id>
   ```
   - 기기가 여러 대면 각각 `-d <device_id>`로 순차 설치한다. 무선 기기는 `-d 10.160.142.227:5555`처럼 ip:port를 그대로 쓴다.
   - `flutter install`은 3단계에서 만든 APK를 재사용하므로 재빌드하지 않는다.
   - 설치 중 Wi-Fi가 끊겨 실패(`device offline` / `closed` / `Lost connection`)하면, 해당 기기에 대해 절차 1의 연결 루프를 1회 다시 수행한 뒤 `flutter install`을 1회 재시도한다. 재시도도 실패하면 그 기기는 실패로 보고하고 나머지 기기는 계속 진행한다 — 재빌드는 하지 않는다.

## 금지
- `flutter run --release -d <device>` 사용 금지 (빌드+실행+로그 스트리밍까지 묶여 있어 설치 용도에 부적합).
- `adb install` 직접 호출 금지 — `flutter install`이 Flutter 앱 설치 메타데이터를 올바르게 처리한다.
- debug 빌드 설치 금지 — 이 skill은 release 전용.

## 출력
설치 완료한 기기 ID와 모델명을 1줄로 보고한다. 예:
> `10.160.142.227:5555 (SM-A325N), 10.160.142.125:5555 (23021RAA2Y)에 release 설치 완료`
