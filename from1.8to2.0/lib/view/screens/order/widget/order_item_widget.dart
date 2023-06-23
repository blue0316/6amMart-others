import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/order_details_model.dart';
import 'package:sixam_mart/data/model/response/order_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderModel order;
  final OrderDetailsModel orderDetails;
  OrderItemWidget({@required this.order, @required this.orderDetails});
  
  @override
  Widget build(BuildContext context) {
    String _addOnText = '';
    orderDetails.addOns.forEach((addOn) {
      _addOnText = _addOnText + '${(_addOnText.isEmpty) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
    });

    String _variationText = '';
    if(orderDetails.variation.length > 0) {
      if(orderDetails.variation.length > 0) {
        List<String> _variationTypes = orderDetails.variation[0].type.split('-');
        if(_variationTypes.length == orderDetails.itemDetails.choiceOptions.length) {
          int _index = 0;
          orderDetails.itemDetails.choiceOptions.forEach((choice) {
            _variationText = _variationText + '${(_index == 0) ? '' : ',  '}${choice.title} - ${_variationTypes[_index]}';
            _index = _index + 1;
          });
        }else {
          _variationText = orderDetails.itemDetails.variations[0].type;
        }
      }
    }else if(orderDetails.foodVariation.length > 0) {
      for(FoodVariation variation in orderDetails.foodVariation) {
        _variationText += '${_variationText.isNotEmpty ? ', ' : ''}${variation.name} (';
        if(variation.variationValues != null){
          for(VariationValue value in variation.variationValues) {
            _variationText += '${_variationText.endsWith('(') ? '' : ', '}${value.level}';
          }
        }
        _variationText += ')';
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
          child: CustomImage(
            height: 50, width: 50, fit: BoxFit.cover,
            image: '${orderDetails.itemCampaignId != null ? Get.find<SplashController>().configModel.baseUrls.campaignImageUrl
                : Get.find<SplashController>().configModel.baseUrls.itemImageUrl}/'
                '${orderDetails.itemDetails.image}',
          ),
        ),
        SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(
                orderDetails.itemDetails.name,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              )),
              Text('${'quantity'.tr}:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
              Text(
                orderDetails.quantity.toString(),
                style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
              ),
            ]),
            SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            Row(children: [
              Expanded(child: Text(
                PriceConverter.convertPrice(orderDetails.price),
                style: robotoMedium,
              )),
              ((Get.find<SplashController>().configModel.moduleConfig.module.unit && orderDetails.itemDetails.unitType != null)
              || (Get.find<SplashController>().configModel.moduleConfig.module.vegNonVeg && Get.find<SplashController>().configModel.toggleVegNonVeg)) ? Container(
                padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: Text(
                  Get.find<SplashController>().configModel.moduleConfig.module.unit ? orderDetails.itemDetails.unitType ?? ''
                      : orderDetails.itemDetails.veg == 0 ? 'non_veg'.tr : 'veg'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                ),
              ) : SizedBox(),
            ]),

          ]),
        ),
      ]),

      (Get.find<SplashController>().getModuleConfig(order.moduleType).addOn && _addOnText.isNotEmpty) ? Padding(
        padding: EdgeInsets.only(top: Dimensions.PADDING_SIZE_EXTRA_SMALL),
        child: Row(children: [
          SizedBox(width: 60),
          Text('${'addons'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
          Flexible(child: Text(
              _addOnText,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
          ))),
        ]),
      ) : SizedBox(),

      _variationText.isNotEmpty ? Padding(
        padding: EdgeInsets.only(top: Dimensions.PADDING_SIZE_EXTRA_SMALL),
        child: Row(children: [
          SizedBox(width: 60),
          Text('${'variations'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
          Flexible(child: Text(
              _variationText,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
          ))),
        ]),
      ) : SizedBox(),

      Divider(height: Dimensions.PADDING_SIZE_LARGE),
      SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
    ]);
  }
}
