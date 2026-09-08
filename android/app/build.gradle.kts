plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.gym"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications for scheduled alerts.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.ironlog"
        // Firebase (cloud_firestore) requires 23+; Health Connect needs 26+.
        minSdk = maxOf(26, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        // A fixed, checked-in release key so every CI build (and every in-app
        // auto-update) is signed identically. Without this, GitHub runners sign
        // each build with a fresh ephemeral debug key, so Android rejects the
        // install with "package conflicts with an existing package".
        // Note: this key lives in a public repo, so it is NOT a secret — it only
        // guarantees consistent self-distribution, not Play Store integrity.
        create("release") {
            storeFile = file("ironlog-release.jks")
            storePassword = "ironlog-signing"
            keyAlias = "ironlog"
            keyPassword = "ironlog-signing"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // The friend-notification listener (FriendPushService) talks to Firestore
    // and Auth natively. The FlutterFire plugins pull the same libraries in
    // with `implementation`, which doesn't reach this module, so declare them
    // here on the same BoM version firebase_core pins.
    implementation(platform("com.google.firebase:firebase-bom:34.18.0"))
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-auth")
    implementation("androidx.core:core-ktx:1.13.1")
}
