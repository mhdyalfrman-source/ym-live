import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/features/rooms/components/seat_widget.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';

// Grid of seats
class SeatsGrid extends StatelessWidget {
  final RoomController controller;

  const SeatsGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.seatStyles.containsKey(
        controller.room.value.seats.length,
      )) {
        return SizedBox.shrink();
      }
      return Column(
        spacing: 8.h,
        children: controller.seatStyles[controller.room.value.seats.length]!
            .map((s) {
              return Row(
                children: s.asMap().entries.map((ss) {
                  if (s.length > ss.key + 1 &&
                      controller
                              .room
                              .value
                              .seats[s[ss.key + 1]["num"]]
                              .user
                              ?.cpLover !=
                          null) {
                    final a = controller.room.value.seats[ss.value["num"]];
                    final b = controller.room.value.seats[s[ss.key + 1]["num"]];

                    final isPair =
                        a.user?.cpLover != null &&
                        b.user?.cpLover != null &&
                        (a.user!.cpLover?.userId == b.user!.userId ||
                            b.user!.cpLover?.userId == a.user!.userId);
                    if (isPair) {
                      return SizedBox(
                        width:
                            (Get.width * ss.value["size"]) +
                            (Get.width * s[ss.key + 1]["size"]),
                        child: Row(
                          children: [
                            Expanded(
                              child: SeatWidget(
                                seat: controller
                                    .room
                                    .value
                                    .seats[ss.value["num"]],
                                controller: controller,
                              ),
                            ),
                            Image.asset(
                              "assets/images/cp_small_heart.png",
                              width: 20.r,
                              height: 20.r,
                            ),
                            Expanded(
                              child: SeatWidget(
                                seat: controller
                                    .room
                                    .value
                                    .seats[s[ss.key + 1]["num"]],
                                controller: controller,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                  if (ss.key > 0 &&
                      controller
                              .room
                              .value
                              .seats[s[ss.key - 1]["num"]]
                              .user
                              ?.cpLover !=
                          null) {
                    final a = controller.room.value.seats[ss.value["num"]];
                    final b = controller.room.value.seats[s[ss.key - 1]["num"]];

                    final isPair =
                        a.user?.cpLover != null &&
                        b.user?.cpLover != null &&
                        (a.user!.cpLover?.userId == b.user!.userId ||
                            b.user!.cpLover?.userId == a.user!.userId);
                    if (isPair) {
                      return SizedBox();
                    }
                  }
                  return SizedBox(
                    width: Get.width * ss.value["size"],
                    child: SeatWidget(
                      seat: controller.room.value.seats[ss.value["num"]],
                      controller: controller,
                    ),
                  );
                }).toList(),
              );
            })
            .toList(),
      );
    });
  }
}
