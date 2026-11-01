// import 'package:tom_chat/core/widgets/input_field.dart';
// import 'package:tom_chat/models/general_model.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart' hide Trans;
// import 'package:localize_and_translate/localize_and_translate.dart';

// Map<int,String> selectedLanguage = {};

// class GetLanguagesAsWidgets extends StatefulWidget {
//   final int id;
//   final GeneralModel name;
//   final FocusNode? node;
//   final Function(String,String)? onChanged;
//   final String? hint;
//   final bool isRequired;
//   final List<String>? languagList;
//   final int? maxLines;
//   final int? maxLength;
//   final FocusNode? nextNode;
//   const GetLanguagesAsWidgets({super.key, required this.id, required this.name, this.node, this.onChanged, this.hint, this.languagList, this.maxLines, this.maxLength, this.nextNode,this.isRequired = true});

//   @override
//   State<GetLanguagesAsWidgets> createState() => GgetLanguagesAsWidgetsState();
// }

// class GgetLanguagesAsWidgetsState extends State<GetLanguagesAsWidgets> {
//   late Map<String,TextEditingController> controllers;
//   @override
//   void initState() {
//     super.initState();
//     if(!selectedLanguage.keys.contains(widget.id)){
//       selectedLanguage[widget.id] = (widget.languagList?.firstOrNull ?? "");
//     }
//     controllers = {
//       "ar":TextEditingController(text: widget.name.arabicTitle!),
//       "en":TextEditingController(text: widget.name.englishTitle!),
//     };
//   }
//   @override
//   Widget build(BuildContext context) {

//     // LanguageController languagController = Get.put(LanguageController(languagList??[], id),tag: id.toString());
//   if (widget.languagList != null && widget.languagList!.isNotEmpty) {
//      return InputField(
//           isRequired: widget.isRequired,
//           node: widget.node,
//           maxLines: widget.maxLines,
//           maxLength: widget.maxLength,
//           keyboardType:
//               widget.maxLines != null ? TextInputType.multiline : TextInputType.text,
//           controller: controllers[selectedLanguage[widget.id]]!,
//           aboveLabel: widget.hint,
//           onChanged: (v)async {
//             await widget.onChanged?.call(v,selectedLanguage[widget.id]!);
//           },
//           onFieldSubmitted: (v) {
//             widget.nextNode?.requestFocus();
//           },
//           hint: widget.hint,
//           suffix: SizedBox(
//             // width: 150,
//             child: DropdownButton(
//               underline: SizedBox(),
//               value: selectedLanguage[widget.id],
//               items: [
//                 ...widget.languagList!.map((v){
//                   return DropdownMenuItem(
//                     value: v,
//                     child: Text(v.tr(),style: Theme.of(context).textTheme.displaySmall,)
//                   );
//                 })
//               ],
//               onChanged: (v){
//                 selectedLanguage[widget.id] = v!;
//                 setState((){});
//               }
//             ),
//           ),
//     );
//   }
//     return
//       InputField(
//         hint: widget.hint,
//         isRequired: widget.isRequired,
//         node: widget.node,
//         maxLines: widget.maxLines,
//         maxLength: widget.maxLength,
//         keyboardType:
//             widget.maxLines != null ? TextInputType.multiline : TextInputType.text,
//         controller: TextEditingController(text: widget.name.arabicTitle!),
//         onChanged: (v)async {
//           await widget.onChanged?.call(v,selectedLanguage[widget.id]!);
//         },
//         aboveLabel: widget.hint,
//         onFieldSubmitted: (v) {
//           widget.nextNode?.requestFocus();
//         },
//       );
//   }
// }

// class LanguageController extends GetxController {
//   List<String>? languagList;
//   int id;
//   LanguageController(
//     this.languagList,
//     this.id,
//   );

//   String selectedLanguage = "";

//   @override
//   void onInit() {
//     super.onInit();
//     selectedLanguage = (languagList?.firstOrNull ?? "");
//   }

//   void onChanged(String? value){
//     selectedLanguage = value??"";
//     update(["language_$id"]);
//   }
// }
