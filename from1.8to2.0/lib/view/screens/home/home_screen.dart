import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/banner_controller.dart';
import 'package:sixam_mart/controller/campaign_controller.dart';
import 'package:sixam_mart/controller/category_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/notification_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/parcel_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/item_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/paginated_list_view.dart';
import 'package:sixam_mart/view/base/web_menu_bar.dart';
import 'package:sixam_mart/view/screens/home/theme1/theme1_home_screen.dart';
import 'package:sixam_mart/view/screens/home/web_home_screen.dart';
import 'package:sixam_mart/view/screens/home/widget/filter_view.dart';
import 'package:sixam_mart/view/screens/home/widget/popular_item_view.dart';
import 'package:sixam_mart/view/screens/home/widget/item_campaign_view.dart';
import 'package:sixam_mart/view/screens/home/widget/popular_store_view.dart';
import 'package:sixam_mart/view/screens/home/widget/banner_view.dart';
import 'package:sixam_mart/view/screens/home/widget/category_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/home/widget/module_view.dart';
import 'package:sixam_mart/view/screens/parcel/parcel_category_screen.dart';

class HomeScreen extends StatefulWidget {

  static Future<void> loadData(bool reload) async {
    if(Get.find<SplashController>().module != null && !Get.find<SplashController>().configModel.moduleConfig.module.isParcel) {
      Get.find<LocationController>().syncZoneData();
      Get.find<BannerController>().getBannerList(reload);
      Get.find<CategoryController>().getCategoryList(reload);
      Get.find<StoreController>().getPopularStoreList(reload, 'all', false);
      Get.find<CampaignController>().getItemCampaignList(reload);
      Get.find<ItemController>().getPopularItemList(reload, 'all', false);
      Get.find<StoreController>().getLatestStoreList(reload, 'all', false);
      Get.find<ItemController>().getReviewedItemList(reload, 'all', false);
      Get.find<StoreController>().getStoreList(1, reload);
    }
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<UserController>().getUserInfo();
      Get.find<NotificationController>().getNotificationList(reload);
    }
    Get.find<SplashController>().getModules();
    if(Get.find<SplashController>().module == null && Get.find<SplashController>().configModel.module == null) {
      Get.find<BannerController>().getFeaturedBanner();
      Get.find<StoreController>().getFeaturedStoreList();
      if(Get.find<AuthController>().isLoggedIn()) {
        Get.find<LocationController>().getAddressList();
      }
    }
    if(Get.find<SplashController>().module != null && Get.find<SplashController>().configModel.moduleConfig.module.isParcel) {
      Get.find<ParcelController>().getParcelCategoryList();
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    HomeScreen.loadData(false);
    if(!ResponsiveHelper.isWeb()) {
      Get.find<LocationController>().getZone(
          Get.find<LocationController>().getUserAddress().latitude,
          Get.find<LocationController>().getUserAddress().longitude, false, updateInAddress: true
      );
    }
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      bool _showMobileModule = !ResponsiveHelper.isDesktop(context) && splashController.module == null && splashController.configModel.module == null;
      bool _isParcel = splashController.module != null && splashController.configModel.moduleConfig.module.isParcel;

      return Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? WebMenuBar() : null,
        endDrawer: MenuDrawer(),endDrawerEnableOpenDragGesture: false,
        backgroundColor: ResponsiveHelper.isDesktop(context) ? Theme.of(context).cardColor : splashController.module == null
            ? Theme.of(context).colorScheme.background : null,
        body: _isParcel ? ParcelCategoryScreen() : SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              if(Get.find<SplashController>().module != null) {
                await Get.find<LocationController>().syncZoneData();
                await Get.find<BannerController>().getBannerList(true);
                await Get.find<CategoryController>().getCategoryList(true);
                await Get.find<StoreController>().getPopularStoreList(true, 'all', false);
                await Get.find<CampaignController>().getItemCampaignList(true);
                await Get.find<ItemController>().getPopularItemList(true, 'all', false);
                await Get.find<StoreController>().getLatestStoreList(true, 'all', false);
                await Get.find<ItemController>().getReviewedItemList(true, 'all', false);
                await Get.find<StoreController>().getStoreList(1, true);
                if(Get.find<AuthController>().isLoggedIn()) {
                  await Get.find<UserController>().getUserInfo();
                  await Get.find<NotificationController>().getNotificationList(true);
                }
              }else {
                await Get.find<BannerController>().getFeaturedBanner();
                await Get.find<SplashController>().getModules();
                if(Get.find<AuthController>().isLoggedIn()) {
                  await Get.find<LocationController>().getAddressList();
                }
                await Get.find<StoreController>().getFeaturedStoreList();
              }
            },
            child: ResponsiveHelper.isDesktop(context) ? WebHomeScreen(
              scrollController: _scrollController,
            ) : (Get.find<SplashController>().module != null && Get.find<SplashController>().module.themeId == 2) ? Theme1HomeScreen(
              scrollController: _scrollController, splashController: splashController, showMobileModule: _showMobileModule,
            ) : CustomScrollView(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [

                // App Bar
                SliverAppBar(
                  floating: true, elevation: 0, automaticallyImplyLeading: false,
                  backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).colorScheme.background,
                  title: Center(child: Container(
                    width: Dimensions.WEB_MAX_WIDTH, height: 50, color: Theme.of(context).colorScheme.background,
                    child: Row(children: [
                      (splashController.module != null && splashController.configModel.module == null) ? InkWell(
                        onTap: () => splashController.removeModule(),
                        child: Image.asset(Images.module_icon, height: 22, width: 22, color: Theme.of(context).textTheme.bodyLarge.color),
                      ) : SizedBox(),
                      SizedBox(width: (splashController.module != null && splashController.configModel.module
                          == null) ? Dimensions.PADDING_SIZE_EXTRA_SMALL : 0),
                      Expanded(child: InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.PADDING_SIZE_SMALL,
                            horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.PADDING_SIZE_SMALL : 0,
                          ),
                          child: GetBuilder<LocationController>(builder: (locationController) {
                            return Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  locationController.getUserAddress().addressType == 'home' ? Icons.home_filled
                                      : locationController.getUserAddress().addressType == 'office' ? Icons.work : Icons.location_on,
                                  size: 20, color: Theme.of(context).textTheme.bodyLarge.color,
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    locationController.getUserAddress().address,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).textTheme.bodyLarge.color, fontSize: Dimensions.fontSizeSmall,
                                    ),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down, color: Theme.of(context).textTheme.bodyLarge.color),
                              ],
                            );
                          }),
                        ),
                      )),
                      InkWell(
                        child: GetBuilder<NotificationController>(builder: (notificationController) {
                          return Stack(children: [
                            Icon(Icons.notifications, size: 25, color: Theme.of(context).textTheme.bodyLarge.color),
                            notificationController.hasNotification ? Positioned(top: 0, right: 0, child: Container(
                              height: 10, width: 10, decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor, shape: BoxShape.circle,
                              border: Border.all(width: 1, color: Theme.of(context).cardColor),
                            ),
                            )) : SizedBox(),
                          ]);
                        }),
                        onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                      ),
                    ]),
                  )),
                  actions: [SizedBox()],
                ),

                // Search Button
                !_showMobileModule ? SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverDelegate(child: Center(child: Container(
                    height: 50, width: Dimensions.WEB_MAX_WIDTH,
                    color: Theme.of(context).colorScheme.background,
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                    child: InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 1, blurRadius: 5)],
                        ),
                        child: Row(children: [
                          Icon(
                            Icons.search, size: 25,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          Expanded(child: Text(
                            Get.find<SplashController>().configModel.moduleConfig.module.showRestaurantText
                                ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor,
                            ),
                          )),
                        ]),
                      ),
                    ),
                  ))),
                ) : SliverToBoxAdapter(),

                SliverToBoxAdapter(
                  child: Center(child: SizedBox(
                    width: Dimensions.WEB_MAX_WIDTH,
                    child: !_showMobileModule ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      BannerView(isFeatured: false),
                      CategoryView(),
                      PopularStoreView(isPopular: true, isFeatured: false),
                      ItemCampaignView(),
                      PopularItemView(isPopular: true),
                      PopularStoreView(isPopular: false, isFeatured: false),
                      PopularItemView(isPopular: false),

                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 15, 0, 5),
                        child: Row(children: [
                          Expanded(child: Text(
                            Get.find<SplashController>().configModel.moduleConfig.module.showRestaurantText
                                ? 'all_restaurants'.tr : 'all_stores'.tr,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                          )),
                          FilterView(),
                        ]),
                      ),

                      GetBuilder<StoreController>(builder: (storeController) {
                        return PaginatedListView(
                          scrollController: _scrollController,
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

                    ]) : ModuleView(splashController: splashController),
                  )),
                ),
              ],
            ),
          ),
        ),
      );
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
