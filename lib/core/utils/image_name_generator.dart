import 'package:intl/intl.dart';
import 'package:tom_chat/statics_values.dart';
import 'package:random_password_generator/random_password_generator.dart';

String generatCodeForImage(String additionalText) {
  return DateFormat(
    "${StaticValue.userData.userId}-yyyy-MM-dd-mm-ss-$additionalText",
  ).format(DateTime.now());
}

String generatePassword() {
  final password = RandomPasswordGenerator();
  String random = password.randomPassword(
    letters: true,
    numbers: false,
    passwordLength: 16,
    uppercase: true,
    specialChar: false,
  );
  final now = DateTime.now();
  final timestamp = now.microsecondsSinceEpoch
      .toString(); // أكثر دقة من milliseconds
  return "${random.substring(0, 4)}-${timestamp.substring(0, 4)}-${random.substring(4, 8)}-${timestamp.substring(4, 8)}-${random.substring(8, 12)}-${timestamp.substring(8, 12)}-${random.substring(12, 16)}-${timestamp.substring(12, 16)}";
}
