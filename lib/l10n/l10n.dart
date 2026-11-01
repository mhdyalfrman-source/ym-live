import 'package:flutter/widgets.dart' show BuildContext;
import 'package:tom_chat/l10n/app_localizations.dart';

extension MyAppLocalizations on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
