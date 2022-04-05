import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:passman/support/global_variables.dart' as globals;

class SettingsService {

  final _storage = const FlutterSecureStorage();
  Future<ThemeMode> themeMode() async {
    String? mode = await _storage.read(key: globals.themeMode);
    if (mode == null) {
      return ThemeMode.system;
    }else if(mode == ThemeMode.dark.name) {
      return ThemeMode.dark;
    }else{
      return ThemeMode.light;
    }
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    await _storage.write(key: globals.themeMode, value: theme.name);
  }
}
