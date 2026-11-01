# ML Kit discovers these registrars by reflection. Its pinned Firebase consumer
# rule keeps their classes but omits constructors, which AGP 9's strict R8 mode
# no longer preserves implicitly. Keep only the required no-argument entry points.
# See https://developer.android.com/build/releases/agp-9-0-0-release-notes
# Remove after the native dependencies supply equivalent tested consumer rules.
-keep class com.google.mlkit.** implements com.google.firebase.components.ComponentRegistrar {
    public <init>();
}
