# ─────────────────────────────────────────────────────────────
# flutter_local_notifications — R8(release) Gson TypeToken 보존
#
# release 빌드의 R8 코드 셰이커가 Gson 제네릭 시그니처를 제거하면
# FlutterLocalNotificationsPlugin.loadScheduledNotifications()가
# "TypeToken must be created with a type argument" IllegalStateException으로
# 터진다 → LocalAlarmService.cancel/schedule(안부 안전망 로컬 알림)이 release에서
# 통째로 실패. 아래 규칙은 플러그인 공식 example(proguard-rules.pro)과 동일하다.
# (flutter_local_notifications 18.0.1)
# ─────────────────────────────────────────────────────────────

## Gson rules
# Gson uses generic type information stored in a class file when working with fields. Proguard
# removes such information by default, so configure it to keep all of it.
-keepattributes Signature

# For using GSON @Expose annotation
-keepattributes *Annotation*

# Gson specific classes
-dontwarn sun.misc.**
#-keep class com.google.gson.stream.** { *; }

# Prevent proguard from stripping interface information from TypeAdapter, TypeAdapterFactory,
# JsonSerializer, JsonDeserializer instances (so they can be used in @JsonAdapter)
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Prevent R8 from leaving Data object members always null
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Retain generic signatures of TypeToken and its subclasses with R8 version 3.0 and higher.
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# 플러그인이 Gson으로 직렬화하는 예약 알림 모델 클래스 보존 (방어적)
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# ─────────────────────────────────────────────────────────────
# shared_preferences_android — R8가 Pigeon 생성 suspend 메서드 시그니처를 바꿔
# release에서 스플래시가 멈추던 문제 (2026-10-20, Flutter 3.47.7 빌드)
# "NoSuchMethodError: SharedPreferencesApiRegistrar.getAll(String, List, Continuation)"
# ─────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.sharedpreferences.** { *; }
# 위 플러그인은 Dart가 JNI로 메서드를 "이름+시그니처"로 찾는다. R8이 시그니처에 쓰인 타입
# (kotlin.coroutines.Continuation 등)을 난독화하면 NoSuchMethodError가 난다.
-keep class kotlin.coroutines.Continuation { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Unit { *; }
# (2차 보강) JNI(package:jni)로 접근되는 플러그인은 R8이 Kotlin 표준 라이브러리 내부 클래스까지
# 지우거나 이름을 바꾸면 런타임에 ClassNotFoundException이 난다
# (실측: kotlin.coroutines.intrinsics.CoroutineSingletons 누락 → 스플래시 멈춤).
-keep class kotlin.coroutines.** { *; }
-keep class kotlin.jvm.internal.** { *; }
-keep class androidx.datastore.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class com.github.dart_lang.jni.** { *; }
-dontwarn kotlin.**
# (3차) 클래스를 하나씩 막으면 계속 다른 클래스가 나온다(Result$Failure …) → Kotlin 전체 보존.
-keep class kotlin.** { *; }
-keep class kotlinx.coroutines.** { *; }
