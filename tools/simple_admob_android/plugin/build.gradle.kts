plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.depobreapotencia.simpleadmob"
    compileSdk = 35

    defaultConfig {
        minSdk = 23
        consumerProguardFiles("consumer-rules.pro")

        buildConfigField("String", "GODOT_PLUGIN_NAME", "\"SimpleAdMob\"")
        buildConfigField("String", "DEFAULT_ADMOB_APP_ID", "\"ca-app-pub-3940256099942544~3347511713\"")
    }

    buildTypes {
        getByName("debug") {
            isMinifyEnabled = false
        }
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        buildConfig = true
    }
}

dependencies {
    implementation("org.godotengine:godot:4.3.0.stable")
    implementation("com.google.android.gms:play-services-ads:25.1.0")
}
