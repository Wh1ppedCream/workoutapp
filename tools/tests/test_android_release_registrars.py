import unittest

from tools.verify_android_release_registrars import manifest_registrars, mapping_failures


NAME = 'com.google.mlkit.vision.barcode.internal.BarcodeRegistrar'


class AndroidReleaseRegistrarTest(unittest.TestCase):
    def test_reads_only_mlkit_reflection_metadata(self):
        xml = f'''<manifest xmlns:android="http://schemas.android.com/apk/res/android">
          <application><service android:name="discovery">
            <meta-data android:name="com.google.firebase.components:{NAME}"
              android:value="com.google.firebase.components.ComponentRegistrar"/>
            <meta-data android:name="com.google.firebase.components:other.Registrar"
              android:value="com.google.firebase.components.ComponentRegistrar"/>
            <meta-data android:name="ordinary.setting" android:value="true"/>
          </service></application></manifest>'''
        self.assertEqual(manifest_registrars(xml), {NAME})

    def test_empty_manifest_does_not_invent_registrars(self):
        self.assertEqual(manifest_registrars('<manifest/>'), set())

    def test_accepts_named_class_with_explicit_default_constructor(self):
        lines = [f'{NAME} -> {NAME}:', '    1:4:void <init>():1:1 -> <init>']
        self.assertEqual(mapping_failures(lines, {NAME}), [])

    def test_reproduces_class_kept_but_constructor_stripped(self):
        lines = [f'{NAME} -> {NAME}:', '    1:6:java.util.List getComponents():1:1 -> a']
        self.assertEqual(mapping_failures(lines, {NAME}), [f'{NAME}: no retained no-argument constructor'])

    def test_argument_constructor_is_not_a_default_constructor(self):
        lines = [f'{NAME} -> {NAME}:', '    1:4:void <init>(java.lang.String):1:1 -> <init>']
        self.assertEqual(mapping_failures(lines, {NAME}), [f'{NAME}: no retained no-argument constructor'])

    def test_rejects_missing_or_renamed_reflection_classes(self):
        self.assertEqual(mapping_failures([], {NAME}), [f'{NAME}: class missing from R8 output'])
        lines = [f'{NAME} -> a.b:', '    void <init>() -> <init>']
        self.assertEqual(mapping_failures(lines, {NAME}), [f'{NAME}: reflection name changed to a.b'])

    def test_constructor_from_another_class_cannot_satisfy_the_check(self):
        lines = [f'{NAME} -> {NAME}:', 'other.Class -> a.b:', '    void <init>() -> <init>']
        self.assertEqual(mapping_failures(lines, {NAME}), [f'{NAME}: no retained no-argument constructor'])


if __name__ == '__main__':
    unittest.main()
