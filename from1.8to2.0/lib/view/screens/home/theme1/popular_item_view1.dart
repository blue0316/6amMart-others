import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/theme_controller.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/discount_tag.dart';
import 'package:sixam_mart/view/base/not_available_widget.dart';
import 'package:sixam_mart/view/base/rating_bar.dart';
import 'package:sixam_mart/view/base/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class PopularItemView1 extends StatelessWidget {
  final bool isPopular;
  PopularItemView1({@required this.isPopular});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item> _itemList = isPopular ? itemController.popularItemList : itemController.reviewedItemList;

      return (_itemList != null && _itemList.length == 0) ? SizedBox() : Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
            child: TitleWidget(
              title: isPopular ? 'popular_items_nearby'.tr : 'best_reviewed_item'.tr,
              onTap: () => Get.toNamed(RouteHelper.getPopularItemRoute(isPopular)),
            ),
          ),

          SizedBox(
            height: 90,
            child: _itemList != null ? ListView.builder(
              controller: ScrollController(),
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
              itemCount: _itemList.length > 10 ? 10 : _itemList.length,
              itemBuilder: (context, index){
                return Padding(
                  padding: EdgeInsets.fromLTRB(2, 2, Dimensions.PADDING_SIZE_SMALL, 2),
                  child: InkWell(
                    onTap: () {
                      Get.find<ItemController>().navigateToItemPage(_itemList[index], context);
                    },
                    child: Container(
                      height: 90, width: 250,
                      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        boxShadow: [BoxShadow(
                          color: Colors.grey[Get.find<ThemeController>().darkTheme ? 800 : 300],
                          blurRadius: 5, spreadRadius: 1,
                        )],
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                        Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                            child: CustomImage(
                              image: '${Get.find<SplashController>().configModel.baseUrls.itemImageUrl}'
                                  '/${_itemList[index].image}',
                              height: 80, width: 80, fit: BoxFit.cover,
                            ),
                          ),
                          DiscountTag(
                            discount: itemController.getDiscount(_itemList[index]),
                            discountType: itemController.getDiscountType(_itemList[index]),
                          ),
                          itemController.isAvailable(_itemList[index]) ? SizedBox() : NotAvailableWidget(),
                        ]),

                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(
                                _itemList[index].name,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                              Text(
                                _itemList[index].storeName,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),

                              RatingBar(
                                rating: _itemList[index].avgRating, size: 12,
                                ratingCount: _itemList[index].ratingCount,
                              ),

                              Row(children: [
                                Expanded(
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    _itemList[index].discount > 0 ? Flexible(child: Text(
                                      PriceConverter.convertPrice(itemController.getStartingPrice(_itemList[index])),
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).colorScheme.error,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    )) : SizedBox(),
                                    SizedBox(width: _itemList[index].discount > 0 ? Dimensions.PADDING_SIZE_EXTRA_SMALL : 0),
                                    Text(
                                      PriceConverter.convertPrice(
                                        itemController.getStartingPrice(_itemList[index]), discount: _itemList[index].discount,
                                        discountType: _itemList[index].discountType,
                                      ),
                                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                                    ),
                                  ]),
                                ),
                                Container(
                                  height: 25, width: 25,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).primaryColor
                                  ),
                                  child: Icon(Icons.add, size: 20, color: Colors.white),
                                ),
                              ]),
                            ]),
                          ),
                        ),

                      ]),
                    ),
                  ),
                );
              },
            ) : PopularItemShimmer(enabled: _itemList == null),
          ),
        ],
      );
    });
  }
}

class PopularItemShimmer extends StatelessWidget {
  final bool enabled;
  PopularItemShimmer({@required this.enabled});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
      itemCount: 10,
      itemBuilder: (context, index){
        return Padding(
          padding: EdgeInsets.fromLTRB(2, 2, Dimensions.PADDING_SIZE_SMALL, 2),
          child: Container(
            height: 90, width: 250,
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
              boxShadow: [BoxShadow(
                color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                blurRadius: 5, spreadRadius: 1,
              )],
            ),
            child: Shimmer(
              duration: Duration(seconds: 1),
              interval: Duration(seconds: 1),
              enabled: enabled,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                Container(
                  height: 80, width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    color: Colors.grey[300],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(height: 15, width: 100, color: Colors.grey[300]),
                      SizedBox(height: 5),

                      Container(height: 10, width: 130, color: Colors.grey[300]),
                      SizedBox(height: 5),

                      RatingBar(rating: 0, size: 12, ratingCount: 0),

                      Row(children: [
                        Expanded(
                          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            Container(height: 10, width: 40, color: Colors.grey[300]),
                            Container(height: 15, width: 40, color: Colors.grey[300]),
                          ]),
                        ),
                        Container(
                          height: 25, width: 25,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor
                          ),
                          child: Icon(Icons.add, size: 20, color: Colors.white),
                        ),
                      ]),
                    ]),
                  ),
                ),

              ]),
            ),
          ),
        );
      },
    );
  }
}

