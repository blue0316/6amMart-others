import 'package:sixam_mart/controller/banner_controller.dart';
import 'package:sixam_mart/controller/campaign_controller.dart';
import 'package:sixam_mart/controller/category_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/item_view.dart';
import 'package:sixam_mart/view/base/paginated_list_view.dart';
import 'package:sixam_mart/view/screens/home/web/module_widget.dart';
import 'package:sixam_mart/view/screens/home/web/web_banner_view.dart';
import 'package:sixam_mart/view/screens/home/web/web_popular_item_view.dart';
import 'package:sixam_mart/view/screens/home/web/web_category_view.dart';
import 'package:sixam_mart/view/screens/home/web/web_campaign_view.dart';
import 'package:sixam_mart/view/screens/home/web/web_popular_store_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebHomeScreen extends StatelessWidget {
  final ScrollController scrollController;
  WebHomeScreen({@required this.scrollController});

  @override
  Widget build(BuildContext context) {
    Get.find<BannerController>().setCurrentIndex(0, false);

    return GetBuilder<SplashController>(builder: (splashController) {
      return Stack(clipBehavior: Clip.none, children: [

        SizedBox(height: context.height),

        SingleChildScrollView(
          controller: scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(children: [

            GetBuilder<BannerController>(builder: (bannerController) {
              return bannerController.bannerImageList == null ? WebBannerView(bannerController: bannerController)
                  : bannerController.bannerImageList.length == 0 ? SizedBox() : WebBannerView(bannerController: bannerController);
            }),

            FooterView(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

              GetBuilder<CategoryController>(builder: (categoryController) {
                return categoryController.categoryList == null ? WebCategoryView(categoryController: categoryController)
                    : categoryController.categoryList.length == 0 ? SizedBox() : WebCategoryView(categoryController: categoryController);
              }),
              SizedBox(width: Dimensions.PADDING_SIZE_LARGE),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  GetBuilder<StoreController>(builder: (storeController) {
                    return storeController.popularStoreList == null ? WebPopularStoreView(storeController: storeController, isPopular: true)
                        : storeController.popularStoreList.length == 0 ? SizedBox() : WebPopularStoreView(storeController: storeController, isPopular: true);
                  }),

                  GetBuilder<CampaignController>(builder: (campaignController) {
                    return campaignController.itemCampaignList == null ? WebCampaignView(campaignController: campaignController)
                        : campaignController.itemCampaignList.length == 0 ? SizedBox() : WebCampaignView(campaignController: campaignController);
                  }),

                  GetBuilder<ItemController>(builder: (itemController) {
                    return itemController.popularItemList == null ? WebPopularItemView(itemController: itemController, isPopular: true)
                        : itemController.popularItemList.length == 0 ? SizedBox() : WebPopularItemView(itemController: itemController, isPopular: true);
                  }),

                  GetBuilder<StoreController>(builder: (storeController) {
                    return storeController.latestStoreList == null ? WebPopularStoreView(storeController: storeController, isPopular: false)
                        : storeController.latestStoreList.length == 0 ? SizedBox() : WebPopularStoreView(storeController: storeController, isPopular: false);
                  }),

                  GetBuilder<ItemController>(builder: (itemController) {
                    return itemController.reviewedItemList == null ? WebPopularItemView(itemController: itemController, isPopular: false)
                        : itemController.reviewedItemList.length == 0 ? SizedBox() : WebPopularItemView(itemController: itemController, isPopular: false);
                  }),

                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 0, 5),
                    child: GetBuilder<StoreController>(builder: (storeController) {
                      return Row(children: [
                        Expanded(child: Text(
                          Get.find<SplashController>().configModel.moduleConfig.module.showRestaurantText
                              ? 'all_restaurants'.tr : 'all_stores'.tr,
                          style: robotoMedium.copyWith(fontSize: 24),
                        )),
                        storeController.storeModel != null ? PopupMenuButton(
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(value: 'all', child: Text('all'.tr), textStyle: robotoMedium.copyWith(
                                color: storeController.storeType == 'all'
                                    ? Theme.of(context).textTheme.bodyLarge.color : Theme.of(context).disabledColor,
                              )),
                              PopupMenuItem(value: 'take_away', child: Text('take_away'.tr), textStyle: robotoMedium.copyWith(
                                color: storeController.storeType == 'take_away'
                                    ? Theme.of(context).textTheme.bodyLarge.color : Theme.of(context).disabledColor,
                              )),
                              PopupMenuItem(value: 'delivery', child: Text('delivery'.tr), textStyle: robotoMedium.copyWith(
                                color: storeController.storeType == 'delivery'
                                    ? Theme.of(context).textTheme.bodyLarge.color : Theme.of(context).disabledColor,
                              )),
                            ];
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                            child: Icon(Icons.filter_list),
                          ),
                          onSelected: (value) => storeController.setStoreType(value),
                        ) : SizedBox(),
                      ]);
                    }),
                  ),

                  GetBuilder<StoreController>(builder: (storeController) {
                    return PaginatedListView(
                      scrollController: scrollController,
                      totalSize: storeController.storeModel != null ? storeController.storeModel.totalSize : null,
                      offset: storeController.storeModel != null ? storeController.storeModel.offset : null,
                      onPaginate: (int offset) async => await storeController.getStoreList(offset, false),
                      itemView: ItemsView(
                        isStore: true, items: null,
                        stores: storeController.storeModel != null ? storeController.storeModel.stores : null,
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.PADDING_SIZE_EXTRA_SMALL : Dimensions.PADDING_SIZE_SMALL,
                          vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.PADDING_SIZE_EXTRA_SMALL : 0,
                        ),
                      ),
                    );
                  }),

                ]),
              ),

            ]))),
          ]),
        ),

        Positioned(right: 0, top: 0, bottom: 0, child: Center(child: ModuleWidget())),

      ]);
    });
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({@required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 50 || oldDelegate.minExtent != 50 || child != oldDelegate.child;
  }
}
