# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Mencegah penghapusan kode plugin Image Picker & Geolocator
-keep class com.baseflow.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.**