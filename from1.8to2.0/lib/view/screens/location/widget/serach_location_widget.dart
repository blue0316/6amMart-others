import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/controller/parcel_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/screens/location/widget/location_search_dialog.dart';

class SearchLocationWidget extends StatelessWidget {
  final GoogleMapController mapController;
  final String pickedAddress;
  final bool isEnabled;
  final bool isPickedUp;
  final String hint;
  const SearchLocationWidget({@required this.mapController, @required this.pickedAddress, @required this.isEnabled, this.isPickedUp, this.hint});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.dialog(LocationSearchDialog(mapController: mapController, isPickedUp: isPickedUp));
        if(isEnabled != null) {
          Get.find<ParcelController>().setIsPickedUp(isPickedUp, true);
        }
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
          border: isEnabled != null ? Border.all(
            color: isEnabled ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: isEnabled ? 2 : 1,
          ) : null,
        ),
        child: Row(children: [
          Icon(
            Icons.location_on, size: 25,
            color: (isEnabled == null || isEnabled) ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
          ),
          SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
          Expanded(
            child: (pickedAddress != null && pickedAddress.isNotEmpty) ? Text(
              pickedAddress,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge), maxLines: 1, overflow: TextOverflow.ellipsis,
            ) : Text(
              hint ?? '',
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
          Icon(Icons.search, size: 25, color: Theme.of(context).textTheme.bodyLarge.color),
        ]),
      ),
    );
  }
}
