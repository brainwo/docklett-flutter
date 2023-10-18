import 'dart:io';

import 'package:ini/ini.dart' as ini;

class Config {
  ini.Config config;

  Config({required this.config});

  static Future<Config> init() async {
    final file = File('config.ini');
    late ini.Config config;
    if (file.existsSync()) {
      config = await file
          .readAsLines()
          .then((final lines) => ini.Config.fromStrings(lines));
    } else {
      config = await file
          .writeAsString('')
          .then((final file) => file.readAsLines())
          .then((final lines) => ini.Config.fromStrings(lines));
    }

    return Config(config: config);
  }
}
