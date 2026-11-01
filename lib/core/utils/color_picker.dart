// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:get/get.dart' hide Trans;
// import 'package:localize_and_translate/localize_and_translate.dart';

// Future<Color> selectColor(
//     {required BuildContext context,
//     required Color currentColor}) async {
//   try {
//     GlobalKey<FormState> formKey = GlobalKey<FormState>();
//     TextEditingController textController = TextEditingController();
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         scrollable: true,
//         titlePadding: const EdgeInsets.all(0),
//         contentPadding: const EdgeInsets.all(0),
//         content: Form(
//           key: formKey,
//           child: Column(
//             children: [
//               ColorPicker(
//                 pickerColor: currentColor,
//                 onColorChanged: (color){
//                   currentColor = color;
//                 },
//                 colorPickerWidth: 300,
//                 pickerAreaHeightPercent: 0.7,
//                 enableAlpha:
//                     true, // hexInputController will respect it too.
//                 displayThumbColor: true,
//                 paletteType: PaletteType.hsvWithHue,
//                 labelTypes: const [],
//                 pickerAreaBorderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(2),
//                   topRight: Radius.circular(2),
//                 ),
//                 hexInputController: textController, // <- here
//                 portraitOnly: true,
//               ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                 /* It can be any text field, for example:

//                         * TextField
//                         * TextFormField
//                         * CupertinoTextField
//                         * EditableText
//                         * any text field from 3-rd party package
//                         * your own text field

//                         so basically anything that supports/uses
//                         a TextEditingController for an editable text.
//                         */
//                 child: CupertinoTextFormFieldRow(
//                   controller: textController,
//                   // Everything below is purely optional.
//                   prefix: const Padding(
//                       padding: EdgeInsets.only(left: 8),
//                       child: Icon(Icons.tag)),
//                   validator: validation,
//                   autofocus: true,
//                   maxLength: 9,
//                   inputFormatters: [
//                     // Any custom input formatter can be passed
//                     // here or use any Form validator you want.
//                     UpperCaseTextFormatter(),
//                     FilteringTextInputFormatter.allow(
//                         RegExp(kValidHexPattern)),
//                   ],
//                 ),
//               ),
//               ElevatedButton(onPressed: (){
//                 if(formKey.currentState!.validate()){
//                   Get.back(result: textController.text);
//                 }
//               }, child: Text("ok".tr(),style: Theme.of(context).textTheme.displayMedium,)),
//               const SizedBox(height: 10,)
//             ],
//           ),
//         ),
//       ));
//       return currentColor;
//   } catch (e) {
//     return Colors.black;
//   }
// }

// void copyToClipboard(String input) {
//   String textToCopy = input.replaceFirst('#', '').toUpperCase();
//   if (textToCopy.startsWith('FF') && textToCopy.length == 8) {
//     textToCopy = textToCopy.replaceFirst('FF', '');
//   }
//   Clipboard.setData(ClipboardData(text: '#$textToCopy'));
// }

// String? validation(String? input) {
//   String textToCopy = input!.replaceFirst('#', '').toUpperCase();
//   if (textToCopy.length == 8 || textToCopy.length == 6) {//textToCopy.startsWith('FF') &&
//     return null;
//   }
//   return "wrongValue".tr();
// }
