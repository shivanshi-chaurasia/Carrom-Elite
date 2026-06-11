allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val buildDirFile = file("${project.projectDir}/../build")
rootProject.layout.buildDirectory.set(buildDirFile)

subprojects {
    val newSubprojectBuildDir = file("${buildDirFile.absolutePath}/${project.name}")
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("com.android.application") {
        val android = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        android?.ndkVersion = "28.2.13676358"
    }
    plugins.withId("com.android.library") {
        val android = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        android?.ndkVersion = "28.2.13676358"
    }
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
