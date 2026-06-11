# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase and Google Services
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep models and generated classes
-keep class com.example.elite_finance.models.** { *; }

# Hive
-keep class io.hive.** { *; }
-keep class io.isara.** { *; }
-dontwarn io.hive.**
-dontwarn io.isara.**

# Socket.io / Engine.io / OkHttp
-keep class io.socket.** { *; }
-dontwarn io.socket.**
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class okio.** { *; }
-dontwarn okio.**

# General rule to prevent stripping of annotations and synthetic names
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Avoid warning about platform-specific differences
-dontwarn android.net.http.**
-dontwarn org.apache.http.**

# Google Play Core (for deferred components)
-dontwarn com.google.android.play.core.**

