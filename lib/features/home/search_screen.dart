import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/input_field.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/badges/components/medals_widget.dart';
import 'package:tom_chat/features/home/components/room_item.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/home/main_screen.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/profile/components/follow_button.dart';
import 'package:tom_chat/features/profile/components/gender_widget.dart';
import 'package:tom_chat/features/profile/components/user_id_widget.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class SearchScreen extends StatefulWidget {
  final int initialIndex;
  final bool withSelect;
  final bool withButton;
  const SearchScreen({
    super.key,
    this.initialIndex = 0,
    this.withSelect = false,
    this.withButton = true,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final HomeController controller = Get.find();
  final TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();

  RxList roomResults = [].obs;
  RxList userResults = [].obs;
  int p = 1;

  void clearAll() {
    p = 1;
    roomResults.clear();
    userResults.clear();
  }

  RxString searchQuery = "".obs;

  RxInt index = 0.obs;

  @override
  void initState() {
    super.initState();

    index.value = widget.initialIndex;

    debounce(searchQuery, (value) {
      search(value);
    }, time: const Duration(seconds: 1));

    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        await loadMore();
      }
    });
  }

  Future<void> search(String query) async {
    p = 1;
    if (index.value == 0) {
      final data = await controller.fetchAllLivesForSearch(query, p);
      roomResults.value = data;
    } else {
      final data = await controller.fetchAllUsersForSearch(query, p);
      userResults.value = data;
    }
  }

  Future<void> loadMore() async {
    p++;
    if (index.value == 0) {
      final data = await controller.fetchAllLivesForSearch(
        searchQuery.value,
        p,
      );
      roomResults.addAll(data);
      roomResults.refresh();
    } else {
      final data = await controller.fetchAllUsersForSearch(
        searchQuery.value,
        p,
      );
      userResults.addAll(data);
      userResults.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: "",
      child: Padding(
        padding: const EdgeInsets.all(10).r,
        child: DefaultTabController(
          initialIndex: widget.initialIndex,
          length: 2,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20.r,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: CardWidget(
                      colorIndex: 1,
                      radius: 15.r,
                      child: InputField(
                        suffix: IconButton(
                          onPressed: () async {
                            await search(searchQuery.value);
                          },
                          icon: Icon(Icons.search),
                        ),
                        controller: searchController,
                        autoFocus: true,
                        hint: context.l10n.search,
                        isRequired: false,
                        keyboardType: TextInputType.number,
                        withEnterText: false,
                        onChanged: (value) {
                          searchQuery.value = value;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              if (!widget.withSelect) ...[
                SizedBox(height: 10.h),
                TabWidget(
                  tabs: [context.l10n.rooms, context.l10n.users],
                  onTap: (index) async {
                    this.index.value = index;
                    if (searchQuery.value.trim().isNotEmpty) {
                      await search(searchQuery.value);
                    }
                  },
                ),
              ],
              SizedBox(height: 10.h),
              Expanded(
                child: Obx(() {
                  if ((roomResults.isEmpty && index.value == 0) ||
                      (userResults.isEmpty && index.value == 1)) {
                    return Center(
                      child: Text(
                        context.l10n.thereAreNoResult,
                        style: Theme.of(context).textTheme.displayMedium!
                            .copyWith(color: Colors.black),
                      ),
                    );
                  }

                  if (index.value == 0) {
                    return Padding(
                      padding: EdgeInsets.all(10).r,
                      child: MasonryGridView.count(
                        controller: scrollController,
                        crossAxisCount: 2,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        itemCount: roomResults.length,
                        itemBuilder: (context, index) {
                          final room = roomResults[index];
                          return RoomItem(room: room);
                        },
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.all(10).r,
                    child: ListView.separated(
                      separatorBuilder: (contetx, index) {
                        return SizedBox(height: 10.h);
                      },
                      controller: scrollController,
                      itemCount: userResults.length,
                      itemBuilder: (context, index) {
                        return userItem(index);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget userItem(int userIndex) {
    UserModel user = userResults[userIndex];
    return InkWell(
      onTap: widget.withSelect
          ? () {
              Get.back(result: user);
            }
          : null,
      child: Container(
        margin: EdgeInsets.only(top: 8.h),
        child: Row(
          children: [
            ProfileAvatar(
              user: user,
              radius: 22.r,
              openProfileType: OpenProfileType.full,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: LayoutBuilder(
                          builder: (context, c) {
                            return UserNameWidget(
                              textAlign: TextAlign.start,
                              width: c.maxWidth,
                              user: user,
                              style: Theme.of(context).textTheme.displaySmall!
                                  .copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 2.w),
                      GenderWidget(user: user),
                      SizedBox(width: 2.w),
                      MedalsWidget(
                        medals: user.medals ?? [],
                        vip: user.vip,
                        width: 0,
                        size: 20.r,
                        scrollable: false,
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  UserIdWidget(
                    user: user,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge!.copyWith(color: Colors.black),
                  ),
                ],
              ),
            ),
            if (widget.withButton) ...[
              if (widget.withSelect)
                GeneralButton3(
                  onPressed: () {
                    Get.back(result: user);
                  },
                  title: context.l10n.invite,
                )
              else
                FollowButton(
                  width: 80.w,
                  showFriendsButton: false,
                  user: user,
                  relation: user.relation,
                  callBack: (r) {
                    if (r != null) {
                      userResults[userIndex].relation = r;
                      userResults.refresh();
                    }
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}
