import 'package:flutter/gestures.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutCondition extends StatelessWidget {
  final OrderController orderController;
  CheckoutCondition({@required this.orderController});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 24.0,
        height: 24.0,
        child: Checkbox(
          activeColor: Theme.of(context).primaryColor,
          value: orderController.acceptTerms,
          onChanged: (bool isChecked) => orderController.toggleTerms(),
        ),
      ),
      SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

      Expanded(
        child: RichText(text: TextSpan(children: [
          TextSpan(
            text: 'i_have_read_and_agreed_with'.tr + ' ',
            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium.color),
          ),
          TextSpan(
            text: 'privacy_policy'.tr, style: robotoMedium.copyWith(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('privacy-policy')),
          ),
          TextSpan(
            text: ', ',
            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium.color),
          ),
          TextSpan(
            text: 'terms_conditions'.tr, style: robotoMedium.copyWith(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
          ),
          TextSpan(text: ' ' + 'and'.tr + ' ', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium.color)),

          TextSpan(
            text: 'refund_policy'.tr, style: robotoMedium.copyWith(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('refund-policy')),
          ),
        ]), textAlign: TextAlign.start, maxLines: 3),
      ),
    ]);
  }
}
