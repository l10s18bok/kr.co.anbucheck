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
