#!/usr/bin/env python3
"""probe/ios-nse — NSE 프로브용 푸시 발송기 (실기기용).

    python3 tool/probe/send_probe_push.py <FCM_TOKEN> [nonce]

⚠️ 확장(NSE)은 **`mutable-content: 1` + 실제 alert(title/body)** 가 모두 있어야 실행된다.
   둘 중 하나만 빠져도 아무 일도 일어나지 않아 "확장이 안 된다"고 오판하게 된다.
   그래서 APNs 설정 모양을 서버 운영 경로(services/push_service.py:138-147)와 동일하게 맞춘다.

⚠️ Firebase 콘솔의 캠페인/테스트 메시지는 APNs 헤더를 노출하지 않아 mutable-content를
   붙이지 못한다 → 검증에 쓰면 무효다. 반드시 이 스크립트로 보낼 것.
"""
import os
import sys
import time

import firebase_admin
from firebase_admin import credentials, messaging

KEY_PATH = os.path.expanduser("~/anbu-fcm-key.json")

# 대조군 문구 — 확장이 실행되면 반드시 덮어써진다.
# 화면에 이 문구가 그대로 보이면 확장이 아예 안 돈 것이다.
ORIGINAL_TITLE = "PROBE-ORIGINAL"
ORIGINAL_BODY = "PROBE-ORIGINAL — 이 문구가 보이면 확장이 실행되지 않은 것이다."


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 1

    token = sys.argv[1].strip()
    nonce = sys.argv[2] if len(sys.argv) > 2 else f"dev-{int(time.time())}"

    if not os.path.exists(KEY_PATH):
        print(f"서비스 계정 키가 없다: {KEY_PATH}")
        return 1

    firebase_admin.initialize_app(credentials.Certificate(KEY_PATH))

    msg = messaging.Message(
        token=token,
        # data는 APNs userInfo 최상위로 들어간다 → 확장이 request.content.userInfo["probe"]로 읽는다
        data={"probe": nonce, "type": "probe_nse"},
        apns=messaging.APNSConfig(
            headers={
                "apns-priority": "10",
                "apns-push-type": "alert",
            },
            payload=messaging.APNSPayload(
                aps=messaging.Aps(
                    alert=messaging.ApsAlert(title=ORIGINAL_TITLE, body=ORIGINAL_BODY),
                    sound="default",
                    content_available=True,
                    mutable_content=True,  # ← 이게 없으면 확장이 실행되지 않는다
                ),
            ),
        ),
    )

    msg_id = messaging.send(msg)
    print(f"발송 완료  nonce={nonce}  id={msg_id}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
