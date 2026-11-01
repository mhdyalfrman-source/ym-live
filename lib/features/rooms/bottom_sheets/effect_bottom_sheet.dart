import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';

class EffectBottomSheet extends StatefulWidget {
  const EffectBottomSheet({super.key});

  @override
  State<EffectBottomSheet> createState() => _EffectBottomSheetState();

  static Future<void> show(
    BuildContext context,
    RoomController controller,
  ) async {
    await AppBottomSheet.show(
      context: context,
      child: EffectBottomSheet(),
      hideHeader: true,
      borderRadius: 0,
      padding: EdgeInsets.zero,
    );
  }
}

class _EffectBottomSheetState extends State<EffectBottomSheet> {
  RoomController controller = Get.put(RoomController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.effect,

      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  buildSection(context, [
                    Obx(
                      () => _buildSwitchTile(
                        context,
                        context.l10n.showSvgaEnteries,
                        controller.showSvgaEntries.value,
                        controller.toggleShowSvgaEntries,
                      ),
                    ),
                    Obx(
                      () => _buildSwitchTile(
                        context,
                        context.l10n.showSvgaGifts,
                        controller.showSvgaGifts.value,
                        controller.toggleShowSvgaGifts,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSection(BuildContext context, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(children: children),
    );
  }

  Widget buildTappableTile(
    BuildContext context,
    String title,
    Function()? onTap, {
    bool hasTrailingWidget = false,
    bool withDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: hasTrailingWidget
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // الدائرة السوداء الصغيرة لـ "Room portrait"
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                )
              : const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
          onTap: onTap,
        ),
        // فاصل بين عناصر القائمة
        if (withDivider)
          const Divider(
            height: 0,
            thickness: 0.5,
            indent: 16.0,
            endIndent: 16.0,
          ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              // activeColor: Colors.orange,
            ),
          ),
          onTap: () => onChanged(!value),
        ),
        if (title != 'Room Password')
          const Divider(
            height: 0,
            thickness: 0.5,
            indent: 16.0,
            endIndent: 16.0,
          ),
      ],
    );
  }
}
