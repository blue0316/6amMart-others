import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/parcel_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/parcel_category_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/my_text_field.dart';

class ReceiverDetailsBottomSheet extends StatefulWidget {
  final ParcelCategoryModel category;
  const ReceiverDetailsBottomSheet({Key key, @required this.category}) : super(key: key);

  @override
  State<ReceiverDetailsBottomSheet> createState() => _ReceiverDetailsBottomSheetState();
}

class _ReceiverDetailsBottomSheetState extends State<ReceiverDetailsBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();
  final FocusNode _streetNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _streetNumberController.text = Get.find<ParcelController>().destinationAddress.streetNumber;
    _houseController.text = Get.find<ParcelController>().destinationAddress.house;
    _floorController.text = Get.find<ParcelController>().destinationAddress.floor;
  }

  @override
  void dispose() {
    super.dispose();
    _streetNumberController.dispose();
    _houseController.dispose();
    _floorController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: ResponsiveHelper.isDesktop(context) ? BorderRadius.all(Radius.circular(Dimensions.RADIUS_EXTRA_LARGE))
            : BorderRadius.vertical(top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

          Center(child: Text('receiver_details'.tr, style: robotoMedium)),
          SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300], spreadRadius: 1, blurRadius: 5)],
            ),
            child: MyTextField(
              hintText: 'receiver_name'.tr,
              inputType: TextInputType.name,
              controller: _nameController,
              focusNode: _nameNode,
              nextFocus: _phoneNode,
              capitalization: TextCapitalization.words,
            ),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

          MyTextField(
            hintText: 'receiver_phone_number'.tr,
            inputType: TextInputType.phone,
            focusNode: _phoneNode,
            nextFocus: _streetNode,
            controller: _phoneController,
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

          MyTextField(
            hintText: "${'street_number'.tr} (${'optional'.tr})",
            inputType: TextInputType.streetAddress,
            focusNode: _streetNode,
            nextFocus: _houseNode,
            controller: _streetNumberController,
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

          MyTextField(
            hintText: "${'house'.tr} (${'optional'.tr})",
            inputType: TextInputType.text,
            focusNode: _houseNode,
            nextFocus: _floorNode,
            controller: _houseController,
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

          MyTextField(
            hintText: "${'floor'.tr} (${'optional'.tr})",
            inputType: TextInputType.text,
            focusNode: _floorNode,
            inputAction: TextInputAction.done,
            controller: _floorController,
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

          CustomButton(
            buttonText: 'confirm_receiver_details'.tr,
            onPressed: () {
              String _name = _nameController.text.trim();
              String _phone = _phoneController.text.trim();
              String _streetNumber = _streetNumberController.text.trim();
              String _house = _houseController.text.trim();
              String _floor = _floorController.text.trim();

              // String _additional = _additionalController.text.trim();
              if(_name.isEmpty) {
                showCustomSnackBar('enter_receiver_name'.tr);
              }else if(_phone.isEmpty) {
                showCustomSnackBar('enter_receiver_phone_number'.tr);
              }else {
                AddressModel _address = Get.find<ParcelController>().destinationAddress;
                _address.contactPersonName = _name;
                _address.contactPersonNumber = _phone;
                _address.streetNumber = _streetNumber;
                _address.house = _house;
                _address.floor = _floor;

                // _address.additionalAddress = _additional;
                Get.find<ParcelController>().setDestinationAddress(_address);
                AddressModel _pickedAddress = Get.find<ParcelController>().pickupAddress;
                if((_pickedAddress.contactPersonName == null || _pickedAddress.contactPersonName.isEmpty)
                    && Get.find<UserController>().userInfoModel != null) {
                  _pickedAddress.contactPersonName = '${Get.find<UserController>().userInfoModel.fName}'
                      ' ${Get.find<UserController>().userInfoModel.lName}';
                }
                if((_pickedAddress.contactPersonNumber == null || _pickedAddress.contactPersonNumber.isEmpty)
                    && Get.find<UserController>().userInfoModel != null) {
                  _pickedAddress.contactPersonNumber = Get.find<UserController>().userInfoModel.phone;
                }
                Get.toNamed(RouteHelper.getParcelRequestRoute(
                  widget.category,
                  Get.find<ParcelController>().pickupAddress,
                  Get.find<ParcelController>().destinationAddress,
                ));
              }
            },
          ),
        ]),
      ),
    );
  }
}
