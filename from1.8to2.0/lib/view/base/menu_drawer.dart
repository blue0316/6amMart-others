import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/confirmation_dialog.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({Key key}) : super(key: key);

  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> with SingleTickerProviderStateMixin {
  List<Menu> _menuList = [
    Menu(icon: Images.profile, title: 'profile'.tr, onTap: () {
      Get.offNamed(RouteHelper.getProfileRoute());
    }),
    Menu(icon: Images.orders, title: 'my_orders'.tr, onTap: () {
      Get.offNamed(RouteHelper.getOrderRoute());
    }),
    Menu(icon: Images.location, title: 'my_address'.tr, onTap: () {
      Get.offNamed(RouteHelper.getAddressRoute());
    }),
    Menu(icon: Images.language, title: 'language'.tr, onTap: () {
      Get.offNamed(RouteHelper.getLanguageRoute('menu'));
    }),
    Menu(icon: Images.coupon, title: 'coupon'.tr, onTap: () {
      Get.offNamed(RouteHelper.getCouponRoute());
    }),
    Menu(icon: Images.support, title: 'help_support'.tr, onTap: () {
      Get.offNamed(RouteHelper.getSupportRoute());
    }),
    Menu(icon: Images.chat, title: 'live_chat'.tr, onTap: () {
      Get.offNamed(RouteHelper.getConversationRoute());
    }),
  ];

  static const _initialDelayTime = Duration(milliseconds: 200);
  static const _itemSlideTime = Duration(milliseconds: 250);
  static const _staggerTime = Duration(milliseconds: 50);
  static const _buttonDelayTime = Duration(milliseconds: 150);
  static const _buttonTime = Duration(milliseconds: 500);
  final _animationDuration = _initialDelayTime + (_staggerTime * 7) + _buttonDelayTime + _buttonTime;

  AnimationController _staggeredController;
  final List<Interval> _itemSlideIntervals = [];

  @override
  void initState() {
    super.initState();

    if(Get.find<SplashController>().configModel.refundPolicyStatus == 1) {
      _menuList.add(Menu(icon: Images.refund, title: 'refund_policy'.tr, onTap: () {
        Get.offNamed(RouteHelper.getHtmlRoute('refund-policy'));
      }));
    }
    if(Get.find<SplashController>().configModel.cancellationPolicyStatus == 1) {
      _menuList.add(Menu(icon: Images.cancelation, title: 'cancellation_policy'.tr, onTap: () {
        Get.offNamed(RouteHelper.getHtmlRoute('cancellation-policy'));
      }));
    }
    if(Get.find<SplashController>().configModel.shippingPolicyStatus == 1) {
      _menuList.add(Menu(icon: Images.shipping_policy, title: 'shipping_policy'.tr, onTap: () {
        Get.offNamed(RouteHelper.getHtmlRoute('shipping-policy'));
      }));
    }

    if(Get.find<SplashController>().configModel.customerWalletStatus == 1) {
      _menuList.add(Menu(icon: Images.wallet, title: 'wallet'.tr, onTap: () {
        Get.offNamed(RouteHelper.getWalletRoute(true));
      }));
    }

    if(Get.find<SplashController>().configModel.loyaltyPointStatus == 1) {
      _menuList.add(Menu(icon: Images.loyal, title: 'loyalty_points'.tr, onTap: () {
        Get.offNamed(RouteHelper.getWalletRoute(false));
      }));
    }
    if(Get.find<SplashController>().configModel.refEarningStatus == 1) {
      _menuList.add(Menu(icon: Images.refer_code, title: 'refer_and_earn'.tr, onTap: () {
        Get.offNamed(RouteHelper.getReferAndEarnRoute());
      }));
    }
    if(Get.find<SplashController>().configModel.toggleDmRegistration) {
      _menuList.add(Menu(
        icon: Images.delivery_man_join, title: 'join_as_a_delivery_man'.tr,onTap: (){
          Get.toNamed(RouteHelper.getDeliverymanRegistrationRoute());
      }));
    }
    if(Get.find<SplashController>().configModel.toggleStoreRegistration) {
      _menuList.add(Menu(
        icon: Images.restaurant_join, title: Get.find<SplashController>().configModel.moduleConfig.module.showRestaurantText
          ? 'join_as_a_restaurant'.tr : 'join_as_a_store'.tr,
        onTap: () => Get.toNamed(RouteHelper.getRestaurantRegistrationRoute()),
      ));
    }
    _menuList.add(Menu(icon: Images.log_out, title: Get.find<AuthController>().isLoggedIn() ? 'logout'.tr : 'sign_in'.tr, onTap: () {
      Get.back();
      if(Get.find<AuthController>().isLoggedIn()) {
        Get.dialog(ConfirmationDialog(icon: Images.support, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: () {
          Get.find<AuthController>().clearSharedData();
          Get.find<CartController>().clearCartList();
          Get.find<AuthController>().socialLogout();
          Get.find<WishListController>().removeWishes();
          Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
        }), useSafeArea: false);
      }else {
        Get.find<WishListController>().removeWishes();
        Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
      }
    }));

    _createAnimationIntervals();

    _staggeredController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..forward();
  }

  void _createAnimationIntervals() {
    for (var i = 0; i < _menuList.length; ++i) {
      final startTime = _initialDelayTime + (_staggerTime * i);
      final endTime = startTime + _itemSlideTime;
      _itemSlideIntervals.add(
        Interval(
          startTime.inMilliseconds / _animationDuration.inMilliseconds,
          endTime.inMilliseconds / _animationDuration.inMilliseconds,
        ),
      );
    }
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context) ? _buildContent() : SizedBox();
  }

  Widget _buildContent() {
    return Align(alignment: Alignment.topRight, child: Container(
      width: 300,
      decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30)), color: Theme.of(context).cardColor),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_LARGE, horizontal: 25),
              margin: EdgeInsets.only(right: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
                color: Theme.of(context).primaryColor,
              ),
              alignment: Alignment.centerLeft,
              child: Text('menu'.tr, style: robotoBold.copyWith(fontSize: 20, color: Colors.white)),
            ),

            ListView.builder(
              itemCount: _menuList.length,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _staggeredController,
                  builder: (context, child) {
                    final animationPercent = Curves.easeOut.transform(
                      _itemSlideIntervals[index].transform(_staggeredController.value),
                    );
                    final opacity = animationPercent;
                    final slideDistance = (1.0 - animationPercent) * 150;

                    return Opacity(
                      opacity: opacity,
                      child: Transform.translate(
                        offset: Offset(slideDistance, 0),
                        child: child,
                      ),
                    );
                  },
                  child: InkWell(
                    onTap: _menuList[index].onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      child: Row(children: [

                        Container(
                          height: 60, width: 60, alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
                            color: index != _menuList.length-1 ? Theme.of(context).primaryColor : Get.find<AuthController>().isLoggedIn() ? Theme.of(context).colorScheme.error : Colors.green,
                          ),
                          child: Image.asset(_menuList[index].icon, color: Colors.white, height: 30, width: 30),
                        ),
                        SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                        Expanded(child: Text(_menuList[index].title, style: robotoMedium, overflow: TextOverflow.ellipsis, maxLines: 1)),

                      ]),
                    ),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    ));
  }
}

class Menu {
  String icon;
  String title;
  Function onTap;

  Menu({@required this.icon, @required this.title, @required this.onTap});
}