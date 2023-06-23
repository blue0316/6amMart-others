import 'package:sixam_mart/controller/category_controller.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/cart_widget.dart';
import 'package:sixam_mart/view/base/item_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/veg_filter_widget.dart';
import 'package:sixam_mart/view/base/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryItemScreen extends StatefulWidget {
  final String categoryID;
  final String categoryName;
  CategoryItemScreen({@required this.categoryID, @required this.categoryName});

  @override
  _CategoryItemScreenState createState() => _CategoryItemScreenState();
}

class _CategoryItemScreenState extends State<CategoryItemScreen> with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final ScrollController storeScrollController = ScrollController();
  final bool _ltr = Get.find<LocalizationController>().isLtr;
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    Get.find<CategoryController>().getSubCategoryList(widget.categoryID);
    scrollController?.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<CategoryController>().categoryItemList != null
          && !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().pageSize / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          print('end of the page');
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryItemList(
            Get.find<CategoryController>().subCategoryIndex == 0 ? widget.categoryID
                : Get.find<CategoryController>().subCategoryList[Get.find<CategoryController>().subCategoryIndex].id.toString(),
            Get.find<CategoryController>().offset+1, Get.find<CategoryController>().type, false,
          );
        }
      }
    });
    storeScrollController?.addListener(() {
      if (storeScrollController.position.pixels == storeScrollController.position.maxScrollExtent
          && Get.find<CategoryController>().categoryStoreList != null
          && !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().restPageSize / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          print('end of the page');
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryStoreList(
            Get.find<CategoryController>().subCategoryIndex == 0 ? widget.categoryID
                : Get.find<CategoryController>().subCategoryList[Get.find<CategoryController>().subCategoryIndex].id.toString(),
            Get.find<CategoryController>().offset+1, Get.find<CategoryController>().type, false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (catController) {
      List<Item> _item;
      List<Store> _stores;
      if(catController.isSearching ? catController.searchItemList != null : catController.categoryItemList != null) {
        _item = [];
        if (catController.isSearching) {
          _item.addAll(catController.searchItemList);
        } else {
          _item.addAll(catController.categoryItemList);
        }
      }
      if(catController.isSearching ? catController.searchStoreList != null : catController.categoryStoreList != null) {
        _stores = [];
        if (catController.isSearching) {
          _stores.addAll(catController.searchStoreList);
        } else {
          _stores.addAll(catController.categoryStoreList);
        }
      }

      return WillPopScope(
        onWillPop: () async {
          if(catController.isSearching) {
            catController.toggleSearch();
            return false;
          }else {
            return true;
          }
        },
        child: Scaffold(
          appBar: ResponsiveHelper.isDesktop(context) ? WebMenuBar() : AppBar(
            title: catController.isSearching ? TextField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
              onSubmitted: (String query) {
                print('searching------------');
                catController.searchData(
                  query, catController.subCategoryIndex == 0 ? widget.categoryID
                    : catController.subCategoryList[catController.subCategoryIndex].id.toString(),
                  catController.type,
                );
              }
            ) : Text(widget.categoryName, style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge.color,
            )),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Theme.of(context).textTheme.bodyLarge.color,
              onPressed: () {
                if(catController.isSearching) {
                  catController.toggleSearch();
                }else {
                  Get.back();
                }
              },
            ),
            backgroundColor: Theme.of(context).cardColor,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () => catController.toggleSearch(),
                icon: Icon(
                  catController.isSearching ? Icons.close_sharp : Icons.search,
                  color: Theme.of(context).textTheme.bodyLarge.color,
                ),
              ),
              IconButton(
                onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                icon: CartWidget(color: Theme.of(context).textTheme.bodyLarge.color, size: 25),
              ),
            ],
          ),
          endDrawer: MenuDrawer(),endDrawerEnableOpenDragGesture: false,
          body: Center(child: SizedBox(
            width: Dimensions.WEB_MAX_WIDTH,
            child: Column(children: [

              (catController.subCategoryList != null && !catController.isSearching) ? Center(child: Container(
                height: 50, width: Dimensions.WEB_MAX_WIDTH, color: Theme.of(context).cardColor,
                padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: catController.subCategoryList.length,
                  padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => catController.setSubCategoryIndex(index, widget.categoryID),
                      child: Container(
                        padding: EdgeInsets.only(
                          left: index == 0 ? Dimensions.PADDING_SIZE_LARGE : Dimensions.PADDING_SIZE_SMALL,
                          right: index == catController.subCategoryList.length-1 ? Dimensions.PADDING_SIZE_LARGE : Dimensions.PADDING_SIZE_SMALL,
                          top: Dimensions.PADDING_SIZE_SMALL,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(
                              _ltr ? index == 0 ? Dimensions.RADIUS_EXTRA_LARGE : 0 : index == catController.subCategoryList.length-1
                                  ? Dimensions.RADIUS_EXTRA_LARGE : 0,
                            ),
                            right: Radius.circular(
                              _ltr ? index == catController.subCategoryList.length-1 ? Dimensions.RADIUS_EXTRA_LARGE : 0 : index == 0
                                  ? Dimensions.RADIUS_EXTRA_LARGE : 0,
                            ),
                          ),
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                        child: Column(children: [
                          SizedBox(height: 3),
                          Text(
                            catController.subCategoryList[index].name,
                            style: index == catController.subCategoryIndex
                                ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          ),
                          index == catController.subCategoryIndex ? Container(
                            height: 5, width: 5,
                            decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                          ) : SizedBox(height: 5, width: 5),
                        ]),
                      ),
                    );
                  },
                ),
              )) : SizedBox(),

              Center(child: Container(
                width: Dimensions.WEB_MAX_WIDTH,
                color: Theme.of(context).cardColor,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorWeight: 3,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context).disabledColor,
                  unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                  labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                  tabs: [
                    Tab(text: 'item'.tr),
                    Tab(text: Get.find<SplashController>().configModel.moduleConfig.module.showRestaurantText
                        ? 'restaurants'.tr : 'stores'.tr),
                  ],
                ),
              )),

              VegFilterWidget(type: catController.type, onSelected: (String type) {
                if(catController.isSearching) {
                  catController.searchData(
                    catController.subCategoryIndex == 0 ? widget.categoryID
                        : catController.subCategoryList[catController.subCategoryIndex].id.toString(), '1', type,
                  );
                }else {
                  if(catController.isStore) {
                    catController.getCategoryStoreList(
                      catController.subCategoryIndex == 0 ? widget.categoryID
                          : catController.subCategoryList[catController.subCategoryIndex].id.toString(), 1, type, true,
                    );
                  }else {
                    catController.getCategoryItemList(
                      catController.subCategoryIndex == 0 ? widget.categoryID
                          : catController.subCategoryList[catController.subCategoryIndex].id.toString(), 1, type, true,
                    );
                  }
                }
              }),

              Expanded(child: NotificationListener(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollEndNotification) {
                    if((_tabController.index == 1 && !catController.isStore) || _tabController.index == 0 && catController.isStore) {
                      catController.setRestaurant(_tabController.index == 1);
                      if(catController.isSearching) {
                        catController.searchData(
                          catController.searchText, catController.subCategoryIndex == 0 ? widget.categoryID
                            : catController.subCategoryList[catController.subCategoryIndex].id.toString(), catController.type,
                        );
                      }else {
                        if(_tabController.index == 1) {
                          catController.getCategoryStoreList(
                            catController.subCategoryIndex == 0 ? widget.categoryID
                                : catController.subCategoryList[catController.subCategoryIndex].id.toString(),
                            1, catController.type, false,
                          );
                        }else {
                          catController.getCategoryItemList(
                            catController.subCategoryIndex == 0 ? widget.categoryID
                                : catController.subCategoryList[catController.subCategoryIndex].id.toString(),
                            1, catController.type, false,
                          );
                        }
                      }
                    }
                  }
                  return false;
                },
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(
                      controller: scrollController,
                      child: ItemsView(
                        isStore: false, items: _item, stores: null, noDataText: 'no_category_item_found'.tr,
                      ),
                    ),
                    SingleChildScrollView(
                      controller: storeScrollController,
                      child: ItemsView(
                        isStore: true, items: null, stores: _stores,
                        noDataText: Get.find<SplashController>().configModel.moduleConfig.module.showRestaurantText
                            ? 'no_category_restaurant_found'.tr : 'no_category_store_found'.tr,
                      ),
                    ),
                  ],
                ),
              )),

              catController.isLoading ? Center(child: Padding(
                padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
              )) : SizedBox(),

            ]),
          )),
        ),
      );
    });
  }
}
