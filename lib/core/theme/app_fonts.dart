import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract final class AppFonts {
  static const family = 'KonkhmerSleokchher';
  static const displayName = 'Konkhmer Sleokchher';
  static const regularAsset = 'assets/fonts/KonkhmerSleokchher-Regular.ttf';
  static const licenseAsset = 'assets/fonts/OFL.txt';

  static bool _licenseRegistered = false;

  static void registerLicense() {
    if (_licenseRegistered) return;
    _licenseRegistered = true;
    LicenseRegistry.addLicense(() async* {
      final license = await rootBundle.loadString(licenseAsset);
      yield LicenseEntryWithLineBreaks(const [displayName], license);
    });
  }
}
