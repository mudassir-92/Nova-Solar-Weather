import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------- LOAD KEY.PROPERTIES ----------
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    println("Warning: key.properties file not found! Release build will fail without it.")
}

android {
    namespace = "com.example.nova2"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.nova2"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ---------- SIGNING CONFIGS ----------
    signingConfigs {
    create("release") {
        val storeFilePath = keystoreProperties.getProperty("storeFile")
            ?: error("storeFile missing in key.properties")
        storeFile = file(storeFilePath)  // make sure path is relative to project root
        keyAlias = keystoreProperties.getProperty("keyAlias")
            ?: error("keyAlias missing in key.properties")
        keyPassword = keystoreProperties.getProperty("keyPassword")
            ?: error("keyPassword missing in key.properties")
        storePassword = keystoreProperties.getProperty("storePassword")
            ?: error("storePassword missing in key.properties")
    }
}

    // ---------- BUILD TYPES ----------
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
