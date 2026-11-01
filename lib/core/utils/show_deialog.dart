// import 'package:tom_chat/core/utils/swip_page.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart' hide Trans;
// import 'package:get_storage/get_storage.dart';
// import 'package:localize_and_translate/localize_and_translate.dart';
// import 'package:tom_chat/core/widgets/buttons.dart';

// showMeesgaeBeforeEditAdress({required BuildContext context,required String message,required String buttonText,required String getStorageKey,bool withCancel = false})async{
//   bool agree = false;
//   final v = GetStorage().read(getStorageKey);
//   if(v == true)return;
//   return await opendDialogWithName(name: getStorageKey, context: context, builder: (context){
//     return StatefulBuilder(
//       builder: (context, setState) {
//         return Dialog(
//           backgroundColor: Theme.of(context).cardColor,
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(children: [
//                 Icon(Icons.info_outline,color: Theme.of(context).primaryColor,size: 80,),
//                 const SizedBox(height: 20,),
//                 Text(message,style: Theme.of(context).textTheme.displayMedium,),
//                 const SizedBox(height: 5,),
//                 Row(children: [
//                   Checkbox(
//                     value: agree, onChanged: (v)=>setState((){agree = v!;})),
//                   Text("donnotShowItAgain".tr(),style: Theme.of(context).textTheme.displaySmall,)
//                 ],),
//                 const SizedBox(height: 5,),
//                 SizedBox(
//                   width: double.infinity,
//                   child: GeneralButton(title: buttonText,onPressed: ()async{
//                     await GetStorage().write(getStorageKey,agree);
//                     Get.back(result: "DONE");
//                   },padding: EdgeInsets.all(15),),
//                 ),
//                 const SizedBox(height: 5,),
//                 if(withCancel)
//                 SizedBox(
//                   width: double.infinity,
//                   child: GeneralButton2(
//                     title: "cancel".tr(),onPressed: ()async{
//                     await GetStorage().write(getStorageKey,agree);
//                     Get.back();
//                   },padding: EdgeInsets.all(15),),
//                 ),
//               ],),
//             ),
//           ),
//         );
//       }
//     );
//   });
// }

// showDialogWithWidget({required BuildContext context,required String message,required String buttonText,bool withCancel = false,required Widget child,required Function()? onDone})async{
//   return await showDialog(context: context, builder: (context){
//     return StatefulBuilder(
//       builder: (context, setState) {
//         return Dialog(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(children: [
//                 Icon(Icons.info_outline,color: Theme.of(context).primaryColor,size: 80,),
//                 const SizedBox(height: 20,),
//                 Text(message,style: Theme.of(context).textTheme.displayMedium,),
//                 const SizedBox(height: 5,),
//                 child,
//                 const SizedBox(height: 5,),
//                 SizedBox(
//                   width: double.infinity,
//                   child: GeneralButton(title: buttonText,onPressed: onDone,padding: EdgeInsets.all(15),),
//                 ),
//                 const SizedBox(height: 5,),
//                 if(withCancel)
//                 SizedBox(
//                   width: double.infinity,
//                   child: GeneralButton2(
//                     title: "cancel".tr(),onPressed: ()async{
//                     Get.back();
//                   },padding: EdgeInsets.all(15),),
//                 ),
//               ],),
//             ),
//           ),
//         );
//       }
//     );
//   });
// }
