// android/app/build.gradle.kts
// Phase 6D: Added coreLibraryDesugaring required by flutter_local_notifications.
//
// FIX: Correct Maven coordinate is com.android.tools:desugar_jdk_libs:2.1.4
//      (three colon-separated parts: group:artifact:version)
//      The broken string "com.android.tools.build:desugaring:2.0.4" is a
//      non-existent artifact and causes checkDebugAarMetadata to fail.

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.nazer_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // REQUIRED for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.nazer_app"   // TODO Phase 6H: change to com.nazer.app
        minSdk = 29                                // hardcoded — BLE requires API 29+
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // REQUIRED for flutter_local_notifications
    // group:artifact:version — all three parts are mandatory
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}