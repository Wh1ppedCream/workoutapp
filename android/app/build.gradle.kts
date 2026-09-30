import java.io.FileInputStream
import java.util.Base64
import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val isReleaseBuild = gradle.startParameter.taskNames.any {
    it.contains("Release", ignoreCase = true)
}

fun keystoreProperty(name: String): String =
    keystoreProperties.getProperty(name)
        ?: throw GradleException("Missing $name in android/key.properties")

val internalBuildSetting = System.getenv("TONOS_ANDROID_INTERNAL_BUILD")
val isInternalBuild = when {
    internalBuildSetting.isNullOrBlank() -> false
    internalBuildSetting.equals("true", ignoreCase = true) -> true
    internalBuildSetting.equals("false", ignoreCase = true) -> false
    else -> throw GradleException(
        "TONOS_ANDROID_INTERNAL_BUILD must be true or false.",
    )
}
val expressivePreviewBuildSetting =
    System.getenv("TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD")
val isExpressivePreviewBuild = when {
    expressivePreviewBuildSetting.isNullOrBlank() -> false
    expressivePreviewBuildSetting.equals("true", ignoreCase = true) -> true
    expressivePreviewBuildSetting.equals("false", ignoreCase = true) -> false
    else -> throw GradleException(
        "TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD must be true or false.",
    )
}
if (isInternalBuild && isExpressivePreviewBuild) {
    throw GradleException(
        "Internal and Expressive preview Android build flags cannot overlap.",
    )
}
val encodedDartDefines = project.findProperty("dart-defines")?.toString()
val decodedDartDefines = encodedDartDefines
    ?.split(',')
    ?.filter(String::isNotBlank)
    ?.map { encoded ->
        try {
            String(Base64.getDecoder().decode(encoded), Charsets.UTF_8)
        } catch (error: IllegalArgumentException) {
            throw GradleException("Flutter supplied an invalid dart-define.", error)
        }
    }
    .orEmpty()
val dartDefineValues = decodedDartDefines
    .mapNotNull { entry ->
        val separator = entry.indexOf('=')
        if (separator < 0) null else entry.substring(0, separator) to
            entry.substring(separator + 1)
    }
    .groupBy({ it.first }, { it.second })
fun dartDefine(name: String): String? =
    dartDefineValues[name]?.distinct()?.singleOrNull()
val expressivePreviewDartFlag = dartDefine("TONOS_EXPRESSIVE_PREVIEW")
if (isExpressivePreviewBuild) {
    if (expressivePreviewDartFlag != "true" ||
        dartDefine("TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD") != "true" ||
        dartDefine("TONOS_ANDROID_INTERNAL_BUILD") != "false" ||
        dartDefine("TONOS_DATABASE_NAME") != "tonos_expressive_preview.db") {
        throw GradleException(
            "Preview APKs require matching preview, isolated database, and non-internal dart-defines.",
        )
    }
} else if (expressivePreviewDartFlag == "true") {
    throw GradleException(
        "TONOS_EXPRESSIVE_PREVIEW=true requires TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD=true.",
    )
}
val candidateApplicationId =
    when {
        isExpressivePreviewBuild -> "com.tonos.expressivepreview"
        isInternalBuild -> "com.tonos.internal"
        else -> "com.tonos"
    }
val applicationLabel =
    when {
        isExpressivePreviewBuild -> "Tonos Expressive Preview"
        isInternalBuild -> "Tonos (Internal)"
        else -> "Tonos - Health and Fitness"
    }

android {
    namespace = "com.tonos"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = candidateApplicationId
        manifestPlaceholders["appLabel"] = applicationLabel
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (isReleaseBuild && !keystorePropertiesFile.exists()) {
        throw GradleException(
            "Missing android/key.properties required to build a signed release.",
        )
    }

    if (keystorePropertiesFile.exists()) {
        signingConfigs {
            create("release") {
                keyAlias = keystoreProperty("keyAlias")
                keyPassword = keystoreProperty("keyPassword")
                storeFile = file(keystoreProperty("storeFile"))
                storePassword = keystoreProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}
