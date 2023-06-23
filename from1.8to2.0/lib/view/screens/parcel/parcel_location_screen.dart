import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/parcel_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/parcel_category_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/screens/parcel/widget/parcel_view.dart';

class ParcelLocationScreen extends StatefulWidget {
  final ParcelCategoryModel category;
  const ParcelLocationScreen({Key key, @required this.category}) : super(key: key);

  @override
  State<ParcelLocationScreen> createState() => _ParcelLocationScreenState();
}

class _ParcelLocationScreenState extends State<ParcelLocationScreen> with TickerProviderStateMixin {
   TextEditingController _senderNameController = TextEditingController();
   TextEditingController _senderPhoneController = TextEditingController();
   TextEditingController _receiverNameController = TextEditingController();
   TextEditingController _receiverPhoneController = TextEditingController();
   TextEditingController _senderStreetNumberController = TextEditingController();
   TextEditingController _senderHouseController = TextEditingController();
   TextEditingController _senderFloorController = TextEditingController();
   TextEditingController _receiverStreetNumberController = TextEditingController();
   TextEditingController _receiverHouseController = TextEditingController();
   TextEditingController _receiverFloorController = TextEditingController();

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);

    Get.find<ParcelController>().setPickupAddress(Get.find<LocationController>().getUserAddress(), false);
    Get.find<ParcelController>().setIsPickedUp(true, false);
    Get.find<ParcelController>().setIsSender(true, false);
    if(Get.find<AuthController>().isLoggedIn() && Get.find<LocationController>().addressList == null) {
      Get.find<LocationController>().getAddressList();
    }
    if (Get.find<AuthController>().isLoggedIn()){
      if(Get.find<UserController>().userInfoModel == null){
        Get.find<UserController>().getUserInfo();
        _senderNameController.text = Get.find<UserController>().userInfoModel != null ? Get.find<UserController>().userInfoModel.fName + ' ' + Get.find<UserController>().userInfoModel.lName : '';
        _senderPhoneController.text = Get.find<UserController>().userInfoModel != null ? Get.find<UserController>().userInfoModel.phone : '';
      }else{
        _senderNameController.text = Get.find<UserController>().userInfoModel.fName + ' ' + Get.find<UserController>().userInfoModel.lName ?? '';
        _senderPhoneController.text = Get.find<UserController>().userInfoModel.phone ?? '';
      }
    }

    _tabController?.addListener((){
      // if(_tabController.index == 1) {
      //   _validateSender(true);
      // }
      Get.find<ParcelController>().setIsPickedUp(_tabController.index == 0, false);
      Get.find<ParcelController>().setIsSender(_tabController.index == 0, true);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _senderStreetNumberController.dispose();
    _senderHouseController.dispose();
    _senderFloorController.dispose();
    _receiverStreetNumberController.dispose();
    _receiverHouseController.dispose();
    _receiverFloorController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'parcel_location'.tr),
      endDrawer: MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<ParcelController>(builder: (parcelController) {
        return Column(children: [

          Expanded(child: Column(children: [

            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                width: Dimensions.WEB_MAX_WIDTH,
                color: Theme.of(context).cardColor,
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorWeight: 0,
                      indicator: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.RADIUS_SMALL), topRight: Radius.circular(Dimensions.RADIUS_SMALL)), color: Theme.of(context).primaryColor,),
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.black,
                      onTap: (int index) {
                        if(index == 1) {
                          _validateSender();
                        }
                      },
                      unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                      labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                      tabs: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Image.asset(Images.sender, color: parcelController.isSender ? Theme.of(context).cardColor : Theme.of(context).disabledColor, width: 40, fit: BoxFit.fitWidth),
                            SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            Text('sender'.tr, style: robotoMedium.copyWith(color: parcelController.isSender ? Theme.of(context).cardColor : Theme.of(context).disabledColor),)
                          ]),
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Image.asset(Images.sender, color: !parcelController.isSender ? Theme.of(context).cardColor : Theme.of(context).disabledColor, width: 40, fit: BoxFit.fitWidth),
                          SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          Text('receiver'.tr, style: robotoMedium.copyWith(color: !parcelController.isSender ? Theme.of(context).cardColor : Theme.of(context).disabledColor),)
                        ]),
                      ],
                    ),
                    Container(height: 3, width: Dimensions.WEB_MAX_WIDTH, decoration: BoxDecoration(color: Theme.of(context).primaryColor))
                  ],
                ),
              ),
            ),

            Expanded(child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ParcelView(
                  isSender: true, nameController: _senderNameController, phoneController: _senderPhoneController, bottomButton: _bottomButton(),
                  streetController: _senderStreetNumberController, floorController: _senderFloorController, houseController: _senderHouseController,
                ),
                ParcelView(
                  isSender: false, nameController: _receiverNameController, phoneController: _receiverPhoneController, bottomButton: _bottomButton(),
                  streetController: _receiverStreetNumberController, floorController: _receiverFloorController, houseController: _receiverHouseController,
                ),
              ],
            )),
          ])),

          ResponsiveHelper.isDesktop(context) ? SizedBox() : _bottomButton(),

        ]);
      }),
    );
  }

  Widget _bottomButton() {
    return GetBuilder<ParcelController>(
      builder: (parcelController) {
        return CustomButton(
          margin: ResponsiveHelper.isDesktop(context) ? null : EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          buttonText: parcelController.isSender ? 'continue'.tr : 'save_and_continue'.tr,
          onPressed: () {
            if( _tabController.index == 0 ) {
              _validateSender();
            }
            else{

              if(parcelController.destinationAddress == null) {
                  showCustomSnackBar('select_destination_address'.tr);
              }
              else if(_receiverNameController.text.isEmpty){
                showCustomSnackBar('enter_receiver_name'.tr);
              }
              else if(_receiverPhoneController.text.isEmpty){
                showCustomSnackBar('enter_receiver_phone_number'.tr);
              }
              else {
                AddressModel _destination = AddressModel(
                  address: parcelController.destinationAddress.address,
                  additionalAddress: parcelController.destinationAddress.additionalAddress,
                  addressType: parcelController.destinationAddress.addressType,
                  contactPersonName: _receiverNameController.text.trim(),
                  contactPersonNumber: _receiverPhoneController.text.trim(),
                  latitude: parcelController.destinationAddress.latitude,
                  longitude: parcelController.destinationAddress.longitude,
                  method: parcelController.destinationAddress.method,
                  zoneId: parcelController.destinationAddress.zoneId,
                  id: parcelController.destinationAddress.id,
                  streetNumber: _receiverStreetNumberController.text.trim(),
                  house: _receiverHouseController.text.trim(),
                  floor: _receiverFloorController.text.trim(),
                );

                parcelController.setDestinationAddress(_destination);

                Get.toNamed(RouteHelper.getParcelRequestRoute(
                  widget.category,
                  Get.find<ParcelController>().pickupAddress,
                  Get.find<ParcelController>().destinationAddress,
                ));
              }
           }
          },
        );
      }
    );
  }

  void _validateSender() {
    if(Get.find<ParcelController>().pickupAddress == null) {
      showCustomSnackBar('select_pickup_address'.tr);
      _tabController.animateTo(0);
    } else if(_senderNameController.text.isEmpty){
      showCustomSnackBar('enter_sender_name'.tr);
      _tabController.animateTo(0);
    } else if(_senderPhoneController.text.isEmpty){
      showCustomSnackBar('enter_sender_phone_number'.tr);
      _tabController.animateTo(0);
    } else{
      AddressModel _pickup = AddressModel(
        address: Get.find<ParcelController>().pickupAddress.address,
        additionalAddress: Get.find<ParcelController>().pickupAddress.additionalAddress,
        addressType: Get.find<ParcelController>().pickupAddress.addressType,
        contactPersonName: _senderNameController.text.trim(),
        contactPersonNumber: _senderPhoneController.text.trim(),
        latitude: Get.find<ParcelController>().pickupAddress.latitude,
        longitude: Get.find<ParcelController>().pickupAddress.longitude,
        method: Get.find<ParcelController>().pickupAddress.method,
        zoneId: Get.find<ParcelController>().pickupAddress.zoneId,
        id: Get.find<ParcelController>().pickupAddress.id,
        streetNumber: _senderStreetNumberController.text.trim(),
        house: _senderHouseController.text.trim(),
        floor: _senderFloorController.text.trim(),
      );
      Get.find<ParcelController>().setPickupAddress(_pickup, true);
      _tabController.animateTo(1);
    }
  }

}
