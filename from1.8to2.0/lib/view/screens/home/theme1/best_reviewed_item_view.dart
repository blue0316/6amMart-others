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
import 'package:sixam_mart/view/base/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class BestReviewedItemView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item> _itemList = itemController.reviewedItemList;

      return (_itemList != null && _itemList.length == 0) ? SizedBox() : Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
            child: TitleWidget(
              title: 'best_reviewed_item'.tr,
              onTap: () => Get.toNamed(RouteHelper.getPopularItemRoute(false)),
            ),
          ),

          SizedBox(
            height: 220,
            child: _itemList != null ? ListView.builder(
              controller: ScrollController(),
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
              itemCount: _itemList.length > 10 ? 10 : _itemList.length,
              itemBuilder: (context, index){

                return Padding(
                  padding: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL, bottom: 5),
                  child: InkWell(
                    onTap: () {
                      Get.find<ItemController>().navigateToItemPage(_itemList[index], context);
                    },
                    child: Container(
                      height: 220,
                      width: 180,
                      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        boxShadow: [BoxShadow(
                          color: Colors.grey[Get.find<ThemeController>().darkTheme ? 800 : 300],
                          blurRadius: 5, spreadRadius: 1,
                        )],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                        Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.RADIUS_SMALL)),
                            child: CustomImage(
                              image: '${Get.find<SplashController>().configModel.baseUrls.itemImageUrl}/${_itemList[index].image}',
                              height: 125, width: 170, fit: BoxFit.cover,
                            ),
                          ),
                          DiscountTag(
                            discount: _itemList[index].discount, discountType: _itemList[index].discountType,
                            inLeft: false,
                          ),
                          itemController.isAvailable(_itemList[index]) ? SizedBox() : NotAvailableWidget(isStore: true),
                          Positioned(
                            top: Dimensions.PADDING_SIZE_EXTRA_SMALL, left: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 2, horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                              ),
                              child: Row(children: [
                                Icon(Icons.star, color: Theme.of(context).primaryColor, size: 15),
                                SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                Text(_itemList[index].avgRating.toStringAsFixed(1), style: robotoRegular),
                              ]),
                            ),
                          ),
                        ]),

                        Expanded(
                          child: Stack(children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                                Text(
                                  _itemList[index].name ?? '', textAlign: TextAlign.center,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2),

                                Text(
                                  _itemList[index].storeName ?? '', textAlign: TextAlign.center,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                                Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  itemController.getDiscount(_itemList[index]) > 0  ? Flexible(child: Text(
                                    PriceConverter.convertPrice(itemController.getStartingPrice(_itemList[index])),
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).colorScheme.error,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  )) : SizedBox(),
                                  SizedBox(width: _itemList[index].discount > 0 ? Dimensions.PADDING_SIZE_EXTRA_SMALL : 0),
                                  Text(
                                    PriceConverter.convertPrice(
                                      itemController.getStartingPrice(_itemList[index]), discount: itemController.getDiscount(_itemList[index]),
                                      discountType: itemController.getDiscountType(_itemList[index]),
                                    ),
                                    style: robotoMedium,
                                  ),
                                ]),
                              ]),
                            ),
                            Positioned(bottom: 0, right: 0, child: Container(
                              height: 25, width: 25,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).primaryColor
                              ),
                              child: Icon(Icons.add, size: 20, color: Colors.white),
                            )),
                          ]),
                        ),

                      ]),
                    ),
                  ),
                );
              },
            ) : BestReviewedItemShimmer(itemController: itemController),
          ),
        ],
      );
    });
  }
}

class BestReviewedItemShimmer extends StatelessWidget {
  final ItemController itemController;
  BestReviewedItemShimmer({@required this.itemController});

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
          padding: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL, bottom: 5),
          child: Container(
            height: 220, width: 180,
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
              duration: Duration(seconds: 2),
              enabled: itemController.reviewedItemList == null,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                Stack(children: [
                  Container(
                    height: 125, width: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.RADIUS_SMALL)),
                      color: Colors.grey[300],
                    ),
                  ),
                  Positioned(
                    top: Dimensions.PADDING_SIZE_EXTRA_SMALL, left: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      ),
                      child: Row(children: [
                        Icon(Icons.star, color: Theme.of(context).primaryColor, size: 15),
                        SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                        Text('0.0', style: robotoRegular),
                      ]),
                    ),
                  ),
                ]),

                Expanded(
                  child: Stack(children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Container(height: 15, width: 100, color: Colors.grey[300]),
                        SizedBox(height: 2),

                        Container(height: 10, width: 70, color: Colors.grey[300]),
                        SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Container(height: 10, width: 40, color: Colors.grey[300]),
                          SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                        Container(height: 15, width: 40, color: Colors.grey[300]),
                        ]),
                      ]),
                    ),
                    Positioned(bottom: 0, right: 0, child: Container(
                      height: 25, width: 25,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor
                      ),
                      child: Icon(Icons.add, size: 20, color: Colors.white),
                    )),
                  ]),
                ),

              ]),
            ),
          ),
        );
      },
    );
  }
}