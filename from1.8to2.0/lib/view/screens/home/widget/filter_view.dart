import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class FilterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      return storeController.storeModel != null ? PopupMenuButton(
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
      ) : SizedBox();
    });
  }
}
