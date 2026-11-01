// import 'package:flutter/material.dart';
// import 'package:tom_chat/l10n/l10n.dart';

// class ProfileButtons extends StatelessWidget {
//   const ProfileButtons({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _buildButton(context.l10n.follow, Colors.orange, Icons.add),
//         _buildButton("إضافة صديق", Colors.green, Icons.person_add),
//       ],
//     );
//   }

//   Widget _buildButton(String label, Color color, IconData icon) {
//     return ElevatedButton.icon(
//       onPressed: () {},
//       icon: Icon(icon, color: Colors.white),
//       label: Text(label, style: const TextStyle(fontSize: 16)),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//       ),
//     );
//   }
// }
