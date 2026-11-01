import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/input_field.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/agency/controllers/agency_controller.dart';
import 'package:tom_chat/features/agency/models/agency_model.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class AgencySearchScreen extends StatefulWidget {
  const AgencySearchScreen({super.key});

  @override
  State<AgencySearchScreen> createState() => _AgencySearchScreenState();
}

class _AgencySearchScreenState extends State<AgencySearchScreen> {
  final AgencyController controller = Get.put(AgencyController());
  final TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();

  RxList<AgencyModel> agencyResults = <AgencyModel>[].obs;
  int p = 1;

  void clearAll() {
    p = 1;
    agencyResults.clear();
  }

  RxString searchQuery = "".obs;

  @override
  void initState() {
    super.initState();

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
    final data = await controller.fetchAllAgenciesForSearch(query, p);
    agencyResults.value = data;
  }

  Future<void> loadMore() async {
    p++;
    final data = await controller.fetchAllAgenciesForSearch(
      searchQuery.value,
      p,
    );
    agencyResults.addAll(data);
    agencyResults.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.joinAgency,
      child: Padding(
        padding: const EdgeInsets.all(10).r,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              CardWidget(
                colorIndex: 1,
                radius: 15.r,
                child: InputField(
                  withEnterText: false,
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
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    searchQuery.value = value;
                  },
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: Obx(() {
                  if ((agencyResults.isEmpty)) {
                    return Center(
                      child: Text(
                        context.l10n.thereAreNoResult,
                        style: Theme.of(context).textTheme.displayMedium!
                            .copyWith(color: Colors.black),
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
                      itemCount: agencyResults.length,
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
    AgencyModel agency = agencyResults[userIndex];
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      child: Row(
        children: [
          ProfileAvatar(
            borderRadius: BorderRadius.circular(10),
            height: 40.r,
            width: 40.r,
            user: UserModel(userId: 0, name: "", avatar: agency.icon),
            radius: 22.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, c) {
                    return AutoScrollText(
                      width: c.maxWidth,
                      textAlign: TextAlign.start,
                      text: agency.name ?? "",
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                SizedBox(height: 5.h),
                Text(
                  context.l10n.id(agency.id),
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.copyWith(color: Colors.black),
                ),
              ],
            ),
          ),
          GeneralButton3(
            color: AppColors.primaryDark,
            fontColor: Colors.white,
            onPressed: () async {
              controller.joinToAgency(agency);
            },
            title: context.l10n.join,
          ),
        ],
      ),
    );
  }
}
