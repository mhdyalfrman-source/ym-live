// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:tom_chat/core/theme/color.dart';
// import 'package:tom_chat/core/utils/my_math.dart';
// import 'package:tom_chat/core/widgets/buttons.dart';
// import 'package:tom_chat/core/widgets/card_widget.dart';
// import 'package:tom_chat/core/widgets/input_field.dart';
// import 'package:tom_chat/features/charge/controllers/payment_controller.dart';
// import 'package:tom_chat/features/page_templete.dart';
// import 'package:tom_chat/l10n/l10n.dart';

// class ExchangeScreen extends StatefulWidget {
//   const ExchangeScreen({super.key});

//   @override
//   State<ExchangeScreen> createState() => _ExchangeScreenState();
// }

// class _ExchangeScreenState extends State<ExchangeScreen> {
//   TextEditingController textController = TextEditingController();
//   RxDouble textNumber = (0.0).obs;
//   final controller = Get.put(PaymentController());
//   int convertUsdToCoins({
//     required double totalUsd,
//     required double cashRate,
//   }) {
//     if (totalUsd <= 0 || cashRate <= 0) return 0;
//     return (totalUsd * cashRate).round();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PageTemplete(
//       resizeToAvoidBottomInset: false,
//       title: context.l10n.exchange,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(5),
//             topRight: Radius.circular(5),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(10).r,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [

//               CardWidget(
//                 colorIndex: 1,
//                 radius: 15.r,
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20),
//                   child: InputField(
//                     onChanged: (value) {
//                       textNumber.value = MyMath.toDouble(value);
//                       if ((double.tryParse(value) ?? 0) >
//                           (controller.profileData.value?.total ?? 0)) {
//                         return;
//                       }
//                       controller.selectedexchangePlanIndex.value = -1;
//                     },
//                     hint: "المبلغ",
//                     isRequired: false,
//                     controller: textController,
//                     keyboardType: TextInputType.number,
//                   ),
//                 ),
//               ),
//                 SizedBox(height: 20.h),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Obx(() {
//                     final profileData = controller.profileData.value;
//                     final int coins = convertUsdToCoins(
//                       totalUsd: profileData?.total ?? 0.0,
//                       cashRate: profileData?.cashRate ?? 0.0,
//                     );

//                     return Align(
//                       alignment: Alignment.centerLeft,
//                       child: Directionality(
//                         textDirection:
//                             Directionality.of(context), // RTL/LTR support
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               'Avilable: \$${(profileData?.total ?? 0.0).toStringAsFixed(2)} = $coins',
//                               style: TextStyle(
//                                 fontSize: 14.sp,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             SizedBox(width: 4.w),
//                             Image.asset(
//                               'assets/images/coin.png',
//                               width: 20.w,
//                               height: 20.h,
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//               // ],
//               SizedBox(height: 20.h),

//               /// Coin packages grid
//               Expanded(
//                 child: Obx(() {
//                   if (controller.isLoading.value) {
//                     return const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20),
//                       child: Center(
//                         child: CupertinoActivityIndicator(
//                           color: Colors.black,
//                           radius: 20,
//                         ),
//                       ),
//                     );
//                   }

//                   if (controller.exchangePlans.isEmpty) {
//                     return Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20),
//                       child: Center(
//                         child: Text(
//                           context.l10n.thereAreNoDataYet,
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       ),
//                     );
//                   }

//                   return Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20).r,
//                     height: 295.h,
//                     child: Obx(() => GridView.builder(
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 3,
//                             crossAxisSpacing: 10,
//                             mainAxisSpacing: 10,
//                             childAspectRatio: 1.7,
//                           ),
//                           itemCount: controller.exchangePlans.length,
//                           itemBuilder: (context, index) {
//                             final plan = controller.exchangePlans[index];
//                             return InkWell(
//                               onTap: () {
//                                 controller.selectedexchangePlanIndex.value = index;
//                                 controller.exchangePlans.refresh();
//                                 textController.text = "";
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     color: controller
//                                                 .selectedexchangePlanIndex.value ==
//                                             index
//                                         ? AppColors.primary
//                                         : Colors.grey.shade300,
//                                     width: 1,
//                                   ),
//                                   borderRadius: BorderRadius.circular(5),
//                                 ),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         Container(
//                                             width: 15,
//                                             height: 15,
//                                             padding: EdgeInsets.zero,
//                                             constraints: const BoxConstraints(),
//                                             child: Image.asset('assets/images/coin.png')),
//                                         const SizedBox(width: 8),
//                                         Text("${plan.coins}",style: Theme.of(context).textTheme.labelMedium!.copyWith(
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold
//                                         ),)
//                                       ],
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       '\$${plan.money}',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         )),
//                   );
//                 }),
//               ),

//               /// Recharge button
//               Container(
//                 width: double.infinity,
//                 margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//                 child: Obx(() {
//                   int total = convertUsdToCoins(totalUsd: controller.profileData.value?.total ??0, cashRate: controller.profileData.value?.cashRate??0);
//                   return GeneralButton(
//                       begin: Alignment.bottomCenter,
//                       end: Alignment.topCenter,
//                       colorIndex: 3,
//                     onPressed: textNumber.value > (total) ||  controller.isExchangeLoading.value ? null : () async {
//                         if(controller.selectedexchangePlanIndex.value != -1 ||
//                             textController.text.trim().isNotEmpty){
//                               if (controller.isExchangeLoading.value) return;
//                         double number = controller.selectedexchangePlanIndex.value != -1 ?
//                           controller.exchangePlans[controller.selectedexchangePlanIndex.value].coins.toDouble() : (double.tryParse(textController.text)??0);
//                                   await controller
//                                       .exchangeMoney(number);
//                             }
//                         },
//                     title:context.l10n.exchange
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CoinOption {
//   final int coins;
//   final double price;

//   CoinOption({
//     required this.coins,
//     required double coinsPerDollar,
//   }) : price = calculatePriceFromCoins(
//           coins,
//           coinsPerDollar,
//         );
// }

// double calculatePriceFromCoins(
//   int coins,
//   double coinsPerDollar,
// ) {
//   if (coinsPerDollar <= 0) return 0.0;
//   return coins / coinsPerDollar;
// }
