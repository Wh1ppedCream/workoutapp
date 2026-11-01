allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // file_picker 11 expects built-in Kotlin on AGP 9, while the other locked
    // plugins still need legacy KGP. Opt this module in using AGP's supported
    // migration plugin until the global built-in Kotlin migration is complete.
    if (project.name == "file_picker" &&
        providers.gradleProperty("android.builtInKotlin").orNull == "false") {
        pluginManager.withPlugin("com.android.library") {
            pluginManager.apply("com.android.built-in-kotlin")
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
