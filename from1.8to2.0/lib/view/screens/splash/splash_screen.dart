import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/data/model/body/notification_body.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/view/base/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody body;
  SplashScreen({@required this.body});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<ConnectivityResult> _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool _firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(!_firstTime) {
        bool isNotConnected = result != ConnectivityResult.wifi && result != ConnectivityResult.mobile;
        isNotConnected ? SizedBox() : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? 'no_connection'.tr : 'connected'.tr,
            textAlign: TextAlign.center,
          ),
        ));
        if(!isNotConnected) {
          _route();
        }
      }
      _firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    Get.find<CartController>().getCartData();
    _route();

  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged.cancel();
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) {
      if(isSuccess) {
        Timer(Duration(seconds: 1), () async {
          int _minimumVersion = 0;
          if(GetPlatform.isAndroid) {
            _minimumVersion = Get.find<SplashController>().configModel.appMinimumVersionAndroid;
          }else if(GetPlatform.isIOS) {
            _minimumVersion = Get.find<SplashController>().configModel.appMinimumVersionIos;
          }
          if(AppConstants.APP_VERSION < _minimumVersion || Get.find<SplashController>().configModel.maintenanceMode) {
            Get.offNamed(RouteHelper.getUpdateRoute(AppConstants.APP_VERSION < _minimumVersion));
          }else {
            if(widget.body != null) {
              if (widget.body.notificationType == NotificationType.order) {
                Get.offNamed(RouteHelper.getOrderDetailsRoute(widget.body.orderId, fromNotification: true));
              }else if(widget.body.notificationType == NotificationType.general){
                Get.offNamed(RouteHelper.getNotificationRoute(fromNotification: true));
              }else {
                Get.offNamed(RouteHelper.getChatRoute(notificationBody: widget.body, conversationID: widget.body.conversationId, fromNotification: true));
              }
            }else {
              if (Get.find<AuthController>().isLoggedIn()) {
                Get.find<AuthController>().updateToken();
                await Get.find<WishListController>().getWishList();
                if (Get.find<LocationController>().getUserAddress() != null) {
                  Get.offNamed(RouteHelper.getInitialRoute());
                } else {
                  Get.offNamed(RouteHelper.getAccessLocationRoute('splash'));
                }
              } else {
                if (Get.find<SplashController>().showIntro()) {
                  if(AppConstants.languages.length > 1) {
                    Get.offNamed(RouteHelper.getLanguageRoute('splash'));
                  }else {
                    Get.offNamed(RouteHelper.getOnBoardingRoute());
                  }
                } else {
                  Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                }
              }
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Get.find<SplashController>().initSharedData();
    if(Get.find<LocationController>().getUserAddress() != null && Get.find<LocationController>().getUserAddress().zoneIds == null) {
      Get.find<AuthController>().clearSharedAddress();
    }

    return Scaffold(
      key: _globalKey,
      body: GetBuilder<SplashController>(builder: (splashController) {
        return Center(
          child: splashController.hasConnection ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(Images.logo, width: 200),
              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              // Text(AppConstants.APP_NAME, style: robotoMedium.copyWith(fontSize: 25)),
            ],
          ) : NoInternetScreen(child: SplashScreen(body: widget.body)),
        );
      }),
    );
  }
}
