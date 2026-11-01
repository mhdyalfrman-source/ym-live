// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart' hide Trans;
// import 'package:latlong2/latlong.dart';
// import 'package:localize_and_translate/localize_and_translate.dart';
// import 'package:tom_chat/core/theme/color.dart';
// import 'package:tom_chat/core/utils/snakbar_dialog.dart';
// import 'package:tom_chat/core/utils/wait_message.dart';
// import 'package:tom_chat/core/widgets/buttons.dart';
// import 'package:tom_chat/features/map/pick_address_sceen.dart';

// class GetLocation extends StatelessWidget {
//   const GetLocation({
//     super.key,
//     required this.latLng,
//     required this.initialCenter,
//     this.afterChoose,
//     this.title,
//     this.withOpenMap = true,
//   });

//   final LatLng latLng;
//   final LatLng? initialCenter;
//   final String? title;
//   final bool withOpenMap;
//   final Function(double,double)? afterChoose;

//   openMap() async {
//     var res = await Get.to(()=>PickAddressScreen(
//       latLng: latLng,
//       initialCenter: initialCenter!,
//     ));
//     if (res is LatLng) {
//       await afterChoose?.call(res.latitude,res.longitude);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (title != null)...[
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal:  20).r,
//             child: Text(title!,
//             style: Theme.of(context).textTheme.displaySmall!),
//           ),
//             SizedBox(height: 10.h,)
//         ],
//         if(latLng.latitude == 0 && latLng.longitude == 0)
//           Row(
//             children: [
//               if(withOpenMap)
//               Expanded(
//                 child: GeneralButton(
//                   margin: 5,
//                     padding: EdgeInsets.symmetric(vertical: 15),
//                     onPressed: openMap,
//                     title: "openMap".tr()),
//               ),
//               Expanded(
//                 child: GeneralButton2(
//                   margin: 5,
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                     onPressed: () async {
//                       Position? res = await getCurrentPosition();
//                       if (res != null) {
//                         await afterChoose?.call(res.latitude,res.longitude);
//                       }
//                     },
//                     title: "getCurrentLocation".tr()),
//               ),
//             ],
//           )else
//         Card(
//           color: Theme.of(context).cardColor,
//           child: Row(
//             children: [
//               Text("theLocationHasDetermined".tr(),style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.bold,color: Colors.black),),
//               Spacer(),
//               IconButton(onPressed: openMap, icon: Icon(Icons.edit,color: Theme.of(context).primaryColor,)),
//               SizedBox(width: 3.w,),
//               IconButton(onPressed: ()async{
//                 await afterChoose?.call(0,0);
//               }, icon: Icon(Icons.close,color: AppColors.red,)),
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }

// /// Determine the current position of the device.
// ///
// /// When the location services are not enabled or permissions
// /// are denied the `Future` will return an error.
// Future<Position?> getCurrentPosition() async {
//   waitMessage();
//   bool serviceEnabled;
//   LocationPermission permission;

//   // Test if location services are enabled.
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     // Location services are not enabled don't continue
//     // accessing the position and request users of the
//     // App to enable the location services.
//       Get.back();
//       await snakbarDialog(
//           title: "pleaseTurnOnDeviceLocation".tr(),
//           durationSecound: 5,
//           icon: const Icon(Icons.cancel_rounded, color: Colors.white, size: 30));
//       return null;
//   }

//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       Get.back();
//       // Permissions are denied, next time you could try
//       // requesting permissions again (this is also where
//       // Android's shouldShowRequestPermissionRationale
//       // returned true. According to Android guidelines
//       // your App should show an explanatory UI now.
//       await snakbarDialog(
//           title: "locationError2".tr(),
//           durationSecound: 5,
//           icon: const Icon(Icons.cancel_rounded, color: Colors.white, size: 30));
//       return null;
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     Get.back();
//     await snakbarDialog(
//         title:"locationError".tr(),
//         durationSecound: 10,
//         icon: const Icon(Icons.cancel_rounded, color: Colors.white, size: 30));
//     return null;
//   }

//   // When we reach here, permissions are granted and we can
//   // continue accessing the position of the device.
//   var res = await Geolocator.getCurrentPosition();
//   Get.back();
//   return res;
// }

// Future<bool> justCheckPermission()async{
//   bool serviceEnabled;
//   LocationPermission permission;

//   // Test if location services are enabled.
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     // Location services are not enabled don't continue
//     // accessing the position and request users of the
//     // App to enable the location services.
//       await snakbarDialog(
//           title: "pleaseTurnOnDeviceLocation".tr(),
//           durationSecound: 5,
//           icon: const Icon(Icons.cancel_rounded, color: Colors.white, size: 30));
//       return false;
//   }

//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       // Permissions are denied, next time you could try
//       // requesting permissions again (this is also where
//       // Android's shouldShowRequestPermissionRationale
//       // returned true. According to Android guidelines
//       // your App should show an explanatory UI now.
//       await snakbarDialog(
//           title:"locationError2".tr(),
//           durationSecound: 5,
//           icon: const Icon(Icons.cancel_rounded, color: Colors.white, size: 30));
//       return false;
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//       await snakbarDialog(
//           title: "locationError".tr(),
//           durationSecound: 10,
//           icon: const Icon(Icons.cancel_rounded, color: Colors.white, size: 30));
//       return false;
//   }
//   return true;
// }
