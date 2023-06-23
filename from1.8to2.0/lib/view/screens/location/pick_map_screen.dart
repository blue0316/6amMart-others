import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/view/screens/location/widget/serach_location_widget.dart';

class PickMapScreen extends StatefulWidget {
  final bool fromSignUp;
  final bool fromAddAddress;
  final bool canRoute;
  final String route;
  final GoogleMapController googleMapController;
  final Function(AddressModel address) onPicked;
  PickMapScreen({
    @required this.fromSignUp, @required this.fromAddAddress, @required this.canRoute,
    @required this.route, this.googleMapController, this.onPicked,
  });

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> {
  GoogleMapController _mapController;
  CameraPosition _cameraPosition;
  LatLng _initialPosition;

  @override
  void initState() {
    super.initState();

    if(widget.fromAddAddress) {
      Get.find<LocationController>().setPickData();
    }
    _initialPosition = LatLng(
      double.parse(Get.find<SplashController>().configModel.defaultLocation.lat ?? '0'),
      double.parse(Get.find<SplashController>().configModel.defaultLocation.lng ?? '0'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? WebMenuBar() : null,
      endDrawer: MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: SafeArea(child: Center(child: SizedBox(
        width: Dimensions.WEB_MAX_WIDTH,
        child: GetBuilder<LocationController>(builder: (locationController) {
          /*print('--------------${'${locationController.pickPlaceMark.name ?? ''} '
              '${locationController.pickPlaceMark.locality ?? ''} '
              '${locationController.pickPlaceMark.postalCode ?? ''} ${locationController.pickPlaceMark.country ?? ''}'}');*/

          return Stack(children: [

            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.fromAddAddress ? LatLng(locationController.position.latitude, locationController.position.longitude)
                    : _initialPosition,
                zoom: 16,
              ),
              minMaxZoomPreference: MinMaxZoomPreference(0, 16),
              myLocationButtonEnabled: false,
              onMapCreated: (GoogleMapController mapController) {
                _mapController = mapController;
                if(!widget.fromAddAddress) {
                  Get.find<LocationController>().getCurrentLocation(false, mapController: mapController);
                }
              },
              scrollGesturesEnabled: !Get.isDialogOpen,
              zoomControlsEnabled: false,
              onCameraMove: (CameraPosition cameraPosition) {
                _cameraPosition = cameraPosition;
              },
              onCameraMoveStarted: () {
                locationController.disableButton();
              },
              onCameraIdle: () {
                Get.find<LocationController>().updatePosition(_cameraPosition, false);
              },
            ),

            Center(child: !locationController.loading ? Image.asset(Images.pick_marker, height: 50, width: 50)
                : CircularProgressIndicator()),

            Positioned(
              top: Dimensions.PADDING_SIZE_LARGE, left: Dimensions.PADDING_SIZE_SMALL, right: Dimensions.PADDING_SIZE_SMALL,
              child: SearchLocationWidget(mapController: _mapController, pickedAddress: locationController.pickAddress, isEnabled: null),
            ),

            Positioned(
              bottom: 80, right: Dimensions.PADDING_SIZE_SMALL,
              child: FloatingActionButton(
                child: Icon(Icons.my_location, color: Theme.of(context).primaryColor),
                mini: true, backgroundColor: Theme.of(context).cardColor,
                onPressed: () => Get.find<LocationController>().checkPermission(() {
                  Get.find<LocationController>().getCurrentLocation(false, mapController: _mapController);
                }),
              ),
            ),

            Positioned(
              bottom: Dimensions.PADDING_SIZE_LARGE, left: Dimensions.PADDING_SIZE_SMALL, right: Dimensions.PADDING_SIZE_SMALL,
              child: !locationController.isLoading ? CustomButton(
                buttonText: locationController.inZone ? widget.fromAddAddress ? 'pick_address'.tr : 'pick_location'.tr
                    : 'service_not_available_in_this_area'.tr,
                onPressed: (locationController.buttonDisabled || locationController.loading) ? null : () {
                  if(locationController.pickPosition.latitude != 0 && locationController.pickAddress.isNotEmpty) {
                    if(widget.onPicked != null) {
                      AddressModel _address = AddressModel(
                        latitude: locationController.pickPosition.latitude.toString(),
                        longitude: locationController.pickPosition.longitude.toString(),
                        addressType: 'others', address: locationController.pickAddress,
                        contactPersonName: locationController.getUserAddress().contactPersonName,
                        contactPersonNumber: locationController.getUserAddress().contactPersonNumber,
                      );
                      widget.onPicked(_address);
                      Get.back();
                    }else if(widget.fromAddAddress) {
                      if(widget.googleMapController != null) {
                        widget.googleMapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
                          locationController.pickPosition.latitude, locationController.pickPosition.longitude,
                        ), zoom: 16)));
                        locationController.setAddAddressData();
                      }
                      Get.back();
                    }else {
                      AddressModel _address = AddressModel(
                        latitude: locationController.pickPosition.latitude.toString(),
                        longitude: locationController.pickPosition.longitude.toString(),
                        addressType: 'others', address: locationController.pickAddress,
                      );
                      locationController.saveAddressAndNavigate(
                        _address, widget.fromSignUp, widget.route, widget.canRoute, ResponsiveHelper.isDesktop(context),
                      );
                    }
                  }else {
                    showCustomSnackBar('pick_an_address'.tr);
                  }
                },
              ) : Center(child: CircularProgressIndicator()),
            ),

          ]);
        }),
      ))),
    );
  }
}
