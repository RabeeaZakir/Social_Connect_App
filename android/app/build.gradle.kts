plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.social_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // .kts file mein 'is' lagana lazmi hai
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // Deprecation warning se bachne ke liye simple "17" use karein
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.social_app"
        // Notifications aur Desugaring ke liye minSdk 21 ya 23 behtar hai
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        multiDexEnabled = true
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
    implementation("androidx.multidex:multidex:2.0.1")
    // Is line ke baghair desugaring error deta hai
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
