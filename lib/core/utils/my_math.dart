import 'package:intl/intl.dart';

class MyMath {
  static int toInt(dynamic nm, {int defaultVal = 0}) {
    try {
      if (nm.runtimeType == int) {
        return nm;
      } else if (nm.runtimeType == double) {
        return nm.toInt();
      }

      if (nm.runtimeType == String && nm != "") {
        return int.tryParse(nm) ?? defaultVal;
      }
      return defaultVal;
    } on FormatException {
      return defaultVal;
    }
  }

  static double toDouble(dynamic nm, {double defaultVal = 0}) {
    double ret = defaultVal;
    try {
      if (nm.runtimeType == String && nm != "") {
        return double.tryParse(nm) ?? defaultVal;
      } else if (nm.runtimeType == int) {
        ret = nm.toDouble();
      } else if (nm.runtimeType == double) {
        ret = nm;
      }
    } on FormatException {
      return ret;
    }
    return ret;
  }

  static double closestNumber(num nm, {String to = "ceil"}) {
    final newNum = 2 * toDouble(nm.toStringAsFixed(2));
    if (to == "ceil") return newNum.ceilToDouble() / 2;
    return newNum.floorToDouble() / 2;
  }

  static double doubleToMax(
    double n,
    double max, {
    int fix = 2,
    double min = 0,
  }) {
    double a = doubleFixed(n, fix: fix);

    if (a < min) return min;
    if (a > max) return max;
    return a;
  }

  static double doubleFixed(double n, {int fix = 2}) {
    return double.parse(n.toStringAsFixed(fix));
  }

  static String toPersintStr(dynamic n, {bool isfull = false}) {
    return "%${toInt(toDouble(n) * (isfull ? 1 : 100))}";
  }

  static String numberFormatToStr(dynamic n, {int digits = 2}) {
    if (n < 1000) return n.floor().toString();
    return NumberFormat.compactCurrency(
      decimalDigits: digits,
      locale: 'en_US',
      symbol: '',
      name: "",
    ).format(n);
  }

  static String numberFormatToStr2(dynamic n, {String p = "£"}) {
    return "${n.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},")}$p";
    //NumberFormat formatter = NumberFormat('#,##,000','en_US');
    //return formatter.format(n);
  }

  static String fixedNumberToStringLength(int num, int leng, String char) {
    return num.toString().padLeft(leng, char);
  }

  static String doubleReplace(double n, {bool forceReplace = true}) {
    if (forceReplace && n == toInt(n)) {
      return toInt(n).toString();
    }
    return n.toString();
  }

  static String numberToLangStr(num number, {String locale = "ar_EG"}) {
    return NumberFormat('#.##', locale).format(number);
  }

  static String numberToShort(num number, {String locale = "ar_EG"}) {
    if (number >= 1000000000) {
      return "${(number / 1000000000).toStringAsFixed(1).replaceAll(RegExp(r"\.0$"), "")}B";
    } else if (number >= 1000000) {
      return "${(number / 1000000).toStringAsFixed(1).replaceAll(RegExp(r"\.0$"), "")}M";
    } else if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1).replaceAll(RegExp(r"\.0$"), "")}K";
    } else {
      return number.toString();
    }
  }

  static String formatDurationFromSecounds(int seconds) {
    int days = seconds ~/ (24 * 3600);
    seconds %= (24 * 3600);

    int hours = seconds ~/ 3600;
    seconds %= 3600;

    int minutes = seconds ~/ 60;
    seconds %= 60;

    if (days > 0) {
      return "$days day${days > 1 ? 's' : ''}";
    } else if (hours > 0) {
      return "$hours hour${hours > 1 ? 's' : ''}";
    } else if (minutes > 0) {
      return "$minutes minute${minutes > 1 ? 's' : ''}";
    } else {
      return "$seconds second${seconds > 1 ? 's' : ''}";
    }
  }
}
