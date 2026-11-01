// // Gift panel overlay
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:tom_chat/features/rooms/controllers/room_controller.dart';

// class GiftPanel extends StatelessWidget {
//   final RoomController c = Get.find();

//   GiftPanel({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (!c.showGiftPanel.value) return const SizedBox.shrink();
//       return Positioned(
//         right: 12,
//         bottom: 120,
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             width: 260,
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text('الهديا', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: c.gifts.map((g) {
//                     return GestureDetector(
//                       onTap: () {
//                         // send to seat 1 as example
//                         c.sendGift(0, g);
//                       },
//                       child: Container(
//                         width: 72,
//                         height: 72,
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(Icons.card_giftcard, color: Colors.white),
//                             const SizedBox(height: 6),
//                             Text(g.name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
//                             Text('${g.price}', style: const TextStyle(color: Colors.amber, fontSize: 12)),
//                           ],
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }
