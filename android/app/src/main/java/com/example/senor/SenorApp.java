package com.example.senor;

import android.content.Context;

import androidx.multidex.MultiDex;
import io.flutter.app.FlutterApplication;

public class SenorApp extends FlutterApplication {
  @Override
  protected void attachBaseContext(Context base) {
    super.attachBaseContext(base);
    MultiDex.install(this);
  }
}
