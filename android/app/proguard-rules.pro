# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.** { *; }

# Keep generated PluginRegistrant
-keep class io.flutter.plugins.** { *; }

# Keep classes for reflection in JSON serialization libraries
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Firebase / Google Play services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Retrofit / OkHttp / Gson (common networking libraries)
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }
-keep class com.google.gson.** { *; }

# Prevent warnings for missing classes in plugins
-dontwarn io.flutter.embedding.**
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-dontwarn okhttp3.**
-dontwarn retrofit2.**
-dontwarn com.google.gson.**

# Keep all Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep annotations
-keepattributes *Annotation*

# Keep enum values (required for some libraries)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
