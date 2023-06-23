import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/my_text_field.dart';
import 'package:sixam_mart/view/base/not_logged_in_screen.dart';
import 'package:sixam_mart/view/screens/location/pick_map_screen.dart';
import 'package:sixam_mart/view/screens/location/widget/permission_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

class AddAddressScreen extends StatefulWidget {
  final bool fromCheckout;
  final AddressModel address;
  final int zoneId;
  AddAddressScreen({@required this.fromCheckout, this.address, this.zoneId});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactPersonNameController = TextEditingController();
  final TextEditingController _contactPersonNumberController = TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final FocusNode _addressNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  final FocusNode _streetNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();
  bool _isLoggedIn;
  CameraPosition _cameraPosition;
  LatLng _initialPosition;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if(_isLoggedIn && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
    if(widget.address == null) {
      _initialPosition = LatLng(
        double.parse(Get.find<SplashController>().configModel.defaultLocation.lat ?? '0'),
        double.parse(Get.find<SplashController>().configModel.defaultLocation.lng ?? '0'),
      );
    }else {
      Get.find<LocationController>().setUpdateAddress(widget.address);
      _initialPosition = LatLng(
        double.parse(widget.address.latitude ?? '0'),
        double.parse(widget.address.longitude ?? '0'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.address == null ? 'add_new_address'.tr : 'update_address'.tr),
      body: _isLoggedIn ? GetBuilder<UserController>(builder: (userController) {
        if(widget.address != null) {
          if(_contactPersonNameController.text.isEmpty) {
            _contactPersonNameController.text = widget.address.contactPersonName;
            _contactPersonNumberController.text = widget.address.contactPersonNumber;
            _streetNumberController.text = widget.address.streetNumber;
            _houseController.text = widget.address.house;
            _floorController.text = widget.address.floor;
          }
        }else if(userController.userInfoModel != null && _contactPersonNameController.text.isEmpty) {
          _contactPersonNameController.text = '${userController.userInfoModel.fName} ${userController.userInfoModel.lName}';
          _contactPersonNumberController.text = userController.userInfoModel.phone;
        }

        return GetBuilder<LocationController>(builder: (locationController) {
          _addressController.text = locationController.address;

          return Column(children: [

            Expanded(child: Scrollbar(child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              child: Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Container(
                  height: 140,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    border: Border.all(width: 2, color: Theme.of(context).primaryColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    child: Stack(clipBehavior: Clip.none, children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 16),
                        minMaxZoomPreference: MinMaxZoomPreference(0, 16),
                        onTap: (latLng) {
                          Get.toNamed(
                            RouteHelper.getPickMapRoute('add-address', false),
                            arguments: PickMapScreen(
                              fromAddAddress: true, fromSignUp: false, googleMapController: locationController.mapController,
                              route: null, canRoute: false,
                            ),
                          );
                        },
                        zoomControlsEnabled: false,
                        compassEnabled: false,
                        indoorViewEnabled: true,
                        mapToolbarEnabled: false,
                        onCameraIdle: () {
                          locationController.updatePosition(_cameraPosition, true);
                        },
                        onCameraMove: ((position) => _cameraPosition = position),
                        onMapCreated: (GoogleMapController controller) {
                          locationController.setMapController(controller);
                          if(widget.address == null) {
                            locationController.getCurrentLocation(true, mapController: controller);
                          }
                        },
                      ),
                      locationController.loading ? Center(child: CircularProgressIndicator()) : SizedBox(),
                      Center(child: !locationController.loading ? Image.asset(Images.pick_marker, height: 50, width: 50)
                          : CircularProgressIndicator()),
                      Positioned(
                        bottom: 10, right: 0,
                        child: InkWell(
                          onTap: () => _checkPermission(() {
                            locationController.getCurrentLocation(true, mapController: locationController.mapController);
                          }),
                          child: Container(
                            width: 30, height: 30,
                            margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), color: Colors.white),
                            child: Icon(Icons.my_location, color: Theme.of(context).primaryColor, size: 20),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10, right: 0,
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(
                              RouteHelper.getPickMapRoute('add-address', false),
                              arguments: PickMapScreen(
                                fromAddAddress: true, fromSignUp: false, googleMapController: locationController.mapController,
                                route: null, canRoute: false,
                              ),
                            );
                          },
                          child: Container(
                            width: 30, height: 30,
                            margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), color: Colors.white),
                            child: Icon(Icons.fullscreen, color: Theme.of(context).primaryColor, size: 20),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                Center(child: Text(
                  'add_the_location_correctly'.tr,
                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall),
                )),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                Text(
                  'label_as'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                SizedBox(height: 50, child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: locationController.addressTypeList.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      locationController.setAddressTypeIndex(index);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE, vertical: Dimensions.PADDING_SIZE_SMALL),
                      margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), color: Theme.of(context).cardColor,
                        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 1, blurRadius: 5)],
                      ),
                      child: Row(children: [
                        Icon(
                          index == 0 ? Icons.home_filled : index == 1 ? Icons.work : Icons.location_on,
                          color: locationController.addressTypeIndex == index
                              ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                        ),
                        SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                        Text(
                          locationController.addressTypeList[index].tr,
                          style: robotoRegular.copyWith(color: locationController.addressTypeIndex == index
                              ? Theme.of(context).textTheme.bodyLarge.color : Theme.of(context).disabledColor),
                        ),
                      ]),
                    ),
                  ),
                )),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                Text(
                  'delivery_address'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                MyTextField(
                  hintText: 'delivery_address'.tr,
                  inputType: TextInputType.streetAddress,
                  focusNode: _addressNode,
                  nextFocus: _nameNode,
                  controller: _addressController,
                  onChanged: (text) => locationController.setPlaceMark(text),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                Text(
                  'contact_person_name'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                MyTextField(
                  hintText: 'contact_person_name'.tr,
                  inputType: TextInputType.name,
                  controller: _contactPersonNameController,
                  focusNode: _nameNode,
                  nextFocus: _numberNode,
                  capitalization: TextCapitalization.words,
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                Text(
                  'contact_person_number'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                MyTextField(
                  hintText: 'contact_person_number'.tr,
                  inputType: TextInputType.phone,
                  focusNode: _numberNode,
                  nextFocus: _streetNode,
                  controller: _contactPersonNumberController,
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                Text(
                  "${'street_number'.tr} (${'optional'.tr})",
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                MyTextField(
                  hintText: 'street_number'.tr,
                  inputType: TextInputType.streetAddress,
                  focusNode: _streetNode,
                  nextFocus: _houseNode,
                  controller: _streetNumberController,
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                Text(
                  "${'house'.tr} (${'optional'.tr})",
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                MyTextField(
                  hintText: 'house'.tr,
                  inputType: TextInputType.text,
                  focusNode: _houseNode,
                  nextFocus: _floorNode,
                  controller: _houseController,
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                Text(
                  "${'floor'.tr} (${'optional'.tr})",
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                MyTextField(
                  hintText: 'floor'.tr,
                  inputType: TextInputType.text,
                  focusNode: _floorNode,
                  inputAction: TextInputAction.done,
                  controller: _floorController,
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

              ]))),
            ))),

            Container(
              width: Dimensions.WEB_MAX_WIDTH,
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              child: !locationController.isLoading ? CustomButton(
                buttonText: widget.address == null ? 'save_location'.tr : 'update_address'.tr,
                onPressed: locationController.loading ? null : () {

                    AddressModel _addressModel = AddressModel(
                      id: widget.address != null ? widget.address.id : null,
                      addressType: locationController.addressTypeList[locationController.addressTypeIndex],
                      contactPersonName: _contactPersonNameController.text ?? '',
                      contactPersonNumber: _contactPersonNumberController.text ?? '',
                      address: _addressController.text ?? '',
                      latitude: locationController.position.latitude.toString() ?? '',
                      longitude: locationController.position.longitude.toString() ?? '',
                      zoneId: locationController.zoneID,
                      streetNumber: _streetNumberController.text ?? '',
                      house: _houseController.text ?? '',
                      floor: _floorController.text ?? '',
                    );

                    if(widget.address == null) {
                      locationController.addAddress(_addressModel, widget.fromCheckout, widget.zoneId).then((response) {
                        if(response.isSuccess) {
                          Get.back(result: _addressModel);
                          showCustomSnackBar('new_address_added_successfully'.tr, isError: false);
                        }else {
                          showCustomSnackBar(response.message);
                        }
                      });
                    }else {
                      locationController.updateAddress(_addressModel, widget.address.id).then((response) {
                        if(response.isSuccess) {
                          Get.back();
                          showCustomSnackBar(response.message, isError: false);
                        }else {
                          showCustomSnackBar(response.message);
                        }
                      });
                    }
                  },
              ) : Center(child: CircularProgressIndicator()),
            ),

          ]);
        });
      }) : NotLoggedInScreen(),
    );
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(PermissionDialog());
    }else {
      onTap();
    }
  }
}
