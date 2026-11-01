import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QrCodeWidget extends StatelessWidget {
  final String data;
  const QrCodeWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return PrettyQrView(
      qrImage: QrImage(QrCode.fromData(data: data, errorCorrectLevel: 3)),
      // decoration:decoration,
      decoration: PrettyQrDecoration(
        shape: PrettyQrRoundedSymbol(
          // color: Theme.of(context).primaryColor
        ),
      ),
    );
  }
}
