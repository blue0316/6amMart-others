import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/zone_response_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_loader.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/no_data_screen.dart';
import 'package:sixam_mart/view/screens/address/widget/address_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/location/widget/web_landing_page.dart';

class AccessLocationScreen extends StatefulWidget {
  final bool fromSignUp;
  final bool fromHome;
  final String route;
  AccessLocationScreen({@required this.fromSignUp, @required this.fromHome, @required this.route});

  @override
  State<AccessLocationScreen> createState() => _AccessLocationScreenState();
}

class _AccessLocationScreenState extends State<AccessLocationScreen> {
  bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();

  @override
  void initState() {
    super.initState();

    if(!widget.fromHome && Get.find<LocationController>().getUserAddress() != null) {
      Future.delayed(Duration(milliseconds: 500), () {
        Get.dialog(CustomLoader(), barrierDismissible: false);
        Get.find<LocationController>().autoNavigate(
          Get.find<LocationController>().getUserAddress(), widget.fromSignUp, widget.route, widget.route != null, ResponsiveHelper.isDesktop(context),
        );
      });
    }
    if(_isLoggedIn) {
      Get.find<LocationController>().getAddressList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'set_location'.tr, backButton: widget.fromHome),
      endDrawer: MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: SafeArea(child: Padding(
        padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
        child: GetBuilder<LocationController>(builder: (locationController) {
          return (ResponsiveHelper.isDesktop(context) && locationController.getUserAddress() == null) ? WebLandingPage(
            fromSignUp: widget.fromSignUp, fromHome: widget.fromHome, route: widget.route,
          ) : _isLoggedIn ? Column(children: [
            Expanded(child: SingleChildScrollView(
              child: FooterView(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                locationController.addressList != null ? locationController.addressList.length > 0 ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: locationController.addressList.length,
                  itemBuilder: (context, index) {
                    return Center(child: SizedBox(width: 700, child: AddressWidget(
                      address: locationController.addressList[index],
                      fromAddress: false,
                      onTap: () {
                        Get.dialog(CustomLoader(), barrierDismissible: false);
                        AddressModel _address = locationController.addressList[index];
                        locationController.saveAddressAndNavigate(
                          _address, widget.fromSignUp, widget.route, widget.route != null, ResponsiveHelper.isDesktop(context),
                        );
                      },
                    )));
                  },
                ) : NoDataScreen(text: 'no_saved_address_found'.tr) : Center(child: CircularProgressIndicator()),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                ResponsiveHelper.isDesktop(context) ? BottomButton(locationController: locationController, fromSignUp: widget.fromSignUp, route: widget.route) : SizedBox(),

              ])),
            )),
            ResponsiveHelper.isDesktop(context) ? SizedBox() : BottomButton(locationController: locationController, fromSignUp: widget.fromSignUp, route: widget.route),
          ]) : Center(child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: FooterView(child: SizedBox( width: 700,
                child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
                  Image.asset(Images.delivery_location, height: 220),
                  SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                  Text('find_stores_and_items'.tr.toUpperCase(), textAlign: TextAlign.center, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                  Padding(padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                    child: Text('by_allowing_location_access'.tr, textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    ),
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                  BottomButton(locationController: locationController, fromSignUp: widget.fromSignUp, route: widget.route),
            ]))),
          ));
        }),
      )),
    );
  }
}

class BottomButton extends StatelessWidget {
  final LocationController locationController;
  final bool fromSignUp;
  final String route;
  BottomButton({@required this.locationController, @required this.fromSignUp, @required this.route});

  @override
  Widget build(BuildContext context) {
    return Center(child: SizedBox(width: 700, child: Column(children: [

      CustomButton(
        buttonText: 'user_current_location'.tr,
        onPressed: () async {
          // String _color = '0xFFAA6843';
          // String _color1 = '0xFFc7794c';
          // Get.find<ThemeController>().changeTheme(Color(int.parse(_color)), Color(int.parse(_color1)));
          Get.find<LocationController>().checkPermission(() async {
            Get.dialog(CustomLoader(), barrierDismissible: false);
            AddressModel _address = await Get.find<LocationController>().getCurrentLocation(true);
            ZoneResponseModel _response = await locationController.getZone(_address.latitude, _address.longitude, false);
            if(_response.isSuccess) {
              locationController.saveAddressAndNavigate(
                _address, fromSignUp, route, route != null, ResponsiveHelper.isDesktop(context),
              );
            }else {
              Get.back();
              Get.toNamed(RouteHelper.getPickMapRoute(route == null ? RouteHelper.accessLocation : route, route != null));
              showCustomSnackBar('service_not_available_in_current_location'.tr);
            }
          });
        },
        icon: Icons.my_location,
      ),
      SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

      TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
          ),
          minimumSize: Size(Dimensions.WEB_MAX_WIDTH, 50),
          padding: EdgeInsets.zero,
        ),
        onPressed: () => Get.toNamed(RouteHelper.getPickMapRoute(
          route == null ? fromSignUp ? RouteHelper.signUp : RouteHelper.accessLocation : route, route != null,
        )),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: EdgeInsets.only(right: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            child: Icon(Icons.map, color: Theme.of(context).primaryColor),
          ),
          Text('set_from_map'.tr, textAlign: TextAlign.center, style: robotoBold.copyWith(
            color: Theme.of(context).primaryColor,
            fontSize: Dimensions.fontSizeLarge,
          )),
        ]),
      ),

    ])));
  }
}

