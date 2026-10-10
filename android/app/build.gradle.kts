import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.universtree.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.universtree.app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val localProps = Properties()
        val localPropsFile = rootProject.file("local.properties")
        if (localPropsFile.exists()) {
            FileInputStream(localPropsFile).use { stream ->
                localProps.load(stream)
            }
        }

        val mapsApiKey = localProps.getProperty("GOOGLE_MAPS_ANDROID_API_KEY")
            ?: (project.findProperty("GOOGLE_MAPS_ANDROID_API_KEY") as String?)
            ?: System.getenv("GOOGLE_MAPS_ANDROID_API_KEY")
            ?: "YOUR_GOOGLE_MAPS_ANDROID_API_KEY_HERE"

        manifestPlaceholders["GOOGLE_MAPS_ANDROID_API_KEY"] = mapsApiKey
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
