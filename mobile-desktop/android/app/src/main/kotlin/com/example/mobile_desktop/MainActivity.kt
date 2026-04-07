package com.example.mobile_desktop

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode

class MainActivity : FlutterActivity() {
    // Use TextureView instead of SurfaceView.
    // SurfaceView compositing is unreliable on x86/x86_64 Android emulators
    // and can produce a solid black screen even when Flutter is rendering correctly.
    override fun getRenderMode(): RenderMode {
        android.util.Log.d("MainActivity", "[MainActivity] Using RenderMode.texture to fix black screen on emulator")
        return RenderMode.texture
    }
}
