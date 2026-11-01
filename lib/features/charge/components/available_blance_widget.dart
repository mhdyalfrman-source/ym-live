// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:tom_chat/features/charge/exchange_screen.dart';
// import 'package:tom_chat/features/wallet/models/cash_data_model.dart';
// import 'package:tom_chat/l10n/l10n.dart';

// class AvailableBalanceWidget extends StatelessWidget {
//   final CashDataModel? profileData;
//   const AvailableBalanceWidget({
//     super.key,
//     this.profileData,
//   });

//   int convertUsdToCoins({
//     required double totalUsd,
//     required double cashRate,
//   }) {
//     if (totalUsd <= 0 || cashRate <= 0) return 0;
//     return (totalUsd * cashRate).round();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final int coins = convertUsdToCoins(
//       totalUsd: profileData?.total ?? 0.0,
//       cashRate: profileData?.cashRate ?? 0.0,
//     );
//     return GestureDetector(
//       onTap: () async {
//         Get.to(()=>ExchangeScreen());
//       },
//       child: Container(
//         margin: const EdgeInsets.all(8),
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(1),
//             border: Border.all(color: Colors.grey[300]!, width: 1.2)),
//         child: Row(
//           children: [
//             Text(
//               "${context.l10n.exchange} : ",
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black,
//               ),
//             ),
//             Directionality(
//               textDirection:
//                   Directionality.of(context), // adapts RTL/LTR automatically
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     '\$${(profileData?.total ?? 0).toStringAsFixed(2)} = $coins',
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       color: Colors.black,
//                     ),
//                   ),
//                   SizedBox(width: 4.w),
//                   Image.asset(
//                     'assets/images/coin.png',
//                     width: 20.w,
//                     height: 20.h,
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(
//               Icons.chevron_right,
//               color: Colors.black,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
