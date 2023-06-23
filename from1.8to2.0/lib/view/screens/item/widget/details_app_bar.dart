import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class DetailsAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Key key;
  DetailsAppBar({this.key});

  @override
  DetailsAppBarState createState() => DetailsAppBarState();

  @override
  Size get preferredSize => Size(double.maxFinite, 50);
}

class DetailsAppBarState extends State<DetailsAppBar> with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
  }
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void shake() {
    controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 15.0).chain(CurveTween(curve: Curves.elasticIn)).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        }
      });

    return AppBar(
      leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyLarge.color), onPressed: () => Navigator.pop(context)),
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      title: Text(
        'item_details'.tr,
        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge.color),
      ),
      centerTitle: true,
      actions: [AnimatedBuilder(
        animation: offsetAnimation,
        builder: (buildContext, child) {
          return Container(
            padding: EdgeInsets.only(left: offsetAnimation.value + 15.0, right: 15.0 - offsetAnimation.value),
            child: Stack(children: [
              IconButton(icon: Icon(Icons.shopping_cart, color: Theme.of(context).primaryColor), onPressed: () {
                Navigator.pushNamed(context, RouteHelper.getCartRoute());
              }),
              Positioned(
                top: 5, right: 5,
                child: Container(
                  padding: EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                  child: GetBuilder<CartController>(builder: (cartController) {
                    return Text(
                      cartController.cartList.length.toString(),
                      style: robotoMedium.copyWith(color: Colors.white, fontSize: 8),
                    );
                  }),
                ),
              ),

            ]),
          );
        },
      )],
    );
  }
}
