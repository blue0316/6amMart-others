import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';

class PaymentFailedDialog extends StatelessWidget {
  final String orderID;
  final String orderType;
  final double orderAmount;
  final double maxCodOrderAmount;
  final bool isCashOnDelivery;
  PaymentFailedDialog({@required this.orderID, @required this.maxCodOrderAmount, @required this.orderAmount, @required this.orderType, @required this.isCashOnDelivery});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
      insetPadding: EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(width: 500, child: Padding(
        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Padding(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
            child: Image.asset(Images.warning, width: 70, height: 70),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE),
            child: Text(
              'are_you_agree_with_this_order_fail'.tr, textAlign: TextAlign.center,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
            child: Text(
              'if_you_do_not_pay'.tr,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

          GetBuilder<OrderController>(builder: (orderController) {
            return !orderController.isLoading ? Column(children: [
              isCashOnDelivery ? CustomButton(
                buttonText: 'switch_to_cash_on_delivery'.tr,
                onPressed: () {
                  print('-------orderAmount : $orderAmount----maxCodOrderAmount : $maxCodOrderAmount----orderType : $orderType');
                  if((orderAmount < maxCodOrderAmount && orderType != 'parcel') || orderType == 'parcel'){
                    orderController.switchToCOD(orderID);
                  }else{
                    if(Get.isDialogOpen) {
                      Get.back();
                    }
                    showCustomSnackBar('you_cant_order_more_then'.tr + ' ${PriceConverter.convertPrice(maxCodOrderAmount)} ' + 'in_cash_on_delivery'.tr);
                  }
                },
                radius: Dimensions.RADIUS_SMALL, height: 40,
              ) : SizedBox(),
              SizedBox(width: Get.find<SplashController>().configModel.cashOnDelivery ? Dimensions.PADDING_SIZE_LARGE : 0),
              TextButton(
                onPressed: () {
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).disabledColor.withOpacity(0.3), minimumSize: Size(Dimensions.WEB_MAX_WIDTH, 40), padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
                ),
                child: Text('continue_with_order_fail'.tr, textAlign: TextAlign.center, style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge.color)),
              ),
            ]) : Center(child: CircularProgressIndicator());
          }),

        ]),
      )),
    );
  }
}
