import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/data/model/response/order_details_model.dart';
import 'package:sixam_mart/data/model/response/order_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/screens/review/widget/deliver_man_review_widget.dart';
import 'package:sixam_mart/view/screens/review/widget/item_review_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RateReviewScreen extends StatefulWidget {
  final List<OrderDetailsModel> orderDetailsList;
  final DeliveryMan deliveryMan;
  final int orderID;
  RateReviewScreen({@required this.orderDetailsList, @required this.deliveryMan, @required this.orderID});

  @override
  _RateReviewScreenState createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: (widget.deliveryMan == null || widget.orderDetailsList.length == 0) ? 1 : 2, initialIndex: 0, vsync: this);
    Get.find<ItemController>().initRatingData(widget.orderDetailsList);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: 'rate_review'.tr),
      endDrawer: MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: Column(children: [
        Center(
          child: Container(
            width: Dimensions.WEB_MAX_WIDTH,
            color: Theme.of(context).cardColor,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).textTheme.bodyLarge.color,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
              labelStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              tabs: widget.orderDetailsList.length > 0 ? widget.deliveryMan != null ? [
                Tab(text: widget.orderDetailsList.length > 1 ? 'items'.tr : 'item'.tr),
                Tab(text: 'delivery_man'.tr),
              ] : [
                Tab(text: widget.orderDetailsList.length > 1 ? 'items'.tr : 'item'.tr),
              ] : [
                Tab(text: 'delivery_man'.tr),
              ],
            ),
          ),
        ),

        Expanded(child: TabBarView(
          controller: _tabController,
          children: widget.orderDetailsList.length > 0 ? widget.deliveryMan != null ? [
            ItemReviewWidget(orderDetailsList: widget.orderDetailsList),
            DeliveryManReviewWidget(deliveryMan: widget.deliveryMan, orderID: widget.orderID.toString()),
          ] : [
            ItemReviewWidget(orderDetailsList: widget.orderDetailsList),
          ] : [
            DeliveryManReviewWidget(deliveryMan: widget.deliveryMan, orderID: widget.orderID.toString()),
          ],
        )),

      ]),
    );
  }
}
