import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tom_chat/l10n/l10n.dart';

class PortalOptionCard extends StatelessWidget {
  final String viewers;
  final int coins;
  final bool isSelected;
  final VoidCallback onTap;
  final int reachingViewersCoins;
  final int treasureBoxCoins;

  const PortalOptionCard({
    super.key,
    required this.viewers,
    required this.coins,
    required this.isSelected,
    required this.onTap,
    required this.reachingViewersCoins,
    required this.treasureBoxCoins,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xffFF2C55) : Colors.grey[300]!,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.reachViewers(viewers),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _buildCoinsRow(
                    l10n.reachingViewers,
                    reachingViewersCoins,
                    context,
                  ),
                  _buildCoinsRow(l10n.treasureBox, treasureBoxCoins, context),
                ],
              ),
              // Right Coin Box
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xffFF2C55)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Image.asset("assets/images/coin.png", height: 18.sp),
                    SizedBox(width: 4.w),
                    Text(
                      coins.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinsRow(String label, int coins, BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Text(
          "$label: ",
          style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
        ),
        Image.asset("assets/images/coin.png", height: 14.sp),
        SizedBox(width: 2.w),
        Text(
          l10n.coinsCount(coins),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
