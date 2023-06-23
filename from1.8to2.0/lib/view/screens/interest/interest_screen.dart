import 'package:sixam_mart/controller/category_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/no_data_screen.dart';
import 'package:sixam_mart/view/base/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InterestScreen extends StatefulWidget {
  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {

  @override
  void initState() {
    super.initState();

    Get.find<CategoryController>().getCategoryList(true, allCategory: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? WebMenuBar() : null,
      endDrawer: MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: GetBuilder<CategoryController>(builder: (categoryController) {
          return categoryController.categoryList != null ? categoryController.categoryList.length > 0 ? Center(
            child: Container(
              width: Dimensions.WEB_MAX_WIDTH,
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                Text('choose_your_interests'.tr, style: robotoMedium.copyWith(fontSize: 22)),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                Text('get_personalized_recommendations'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                Expanded(
                  child: GridView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: categoryController.categoryList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : ResponsiveHelper.isTab(context) ? 3 : 2,
                      childAspectRatio: (1/0.35),
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => categoryController.addInterestSelection(index),
                        child: Container(
                          margin: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL,
                          ),
                          decoration: BoxDecoration(
                            color: categoryController.interestSelectedList[index] ? Theme.of(context).primaryColor
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                            boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], blurRadius: 5, spreadRadius: 1)],
                          ),
                          alignment: Alignment.center,
                          child: Row(children: [
                            CustomImage(
                              image: '${Get.find<SplashController>().configModel.baseUrls.categoryImageUrl}'
                                  '/${categoryController.categoryList[index].image}',
                              height: 30, width: 30,
                            ),
                            SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            Flexible(child: Text(
                              categoryController.categoryList[index].name,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: categoryController.interestSelectedList[index] ? Theme.of(context).cardColor
                                    : Theme.of(context).textTheme.bodyLarge.color,
                              ),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            )),
                          ]),
                        ),
                      );
                    },
                  ),
                ),

                !categoryController.isLoading ? CustomButton(
                  buttonText: 'save_and_continue'.tr,
                  onPressed: () {
                    List<int> _interests = [];
                    for(int index=0; index<categoryController.categoryList.length; index++) {
                      if(categoryController.interestSelectedList[index]) {
                        _interests.add(categoryController.categoryList[index].id);
                      }
                    }
                    categoryController.saveInterest(_interests).then((isSuccess) {
                      if(isSuccess) {
                        Get.offAllNamed(RouteHelper.getInitialRoute());
                      }
                    });
                  },
                ) : Center(child: CircularProgressIndicator()),

              ]),
            ),
          ) : NoDataScreen(text: 'no_category_found'.tr) : Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }
}
