import 'dart:async';

import 'package:photo_view/photo_view.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/body/notification_body.dart';
import 'package:sixam_mart/data/model/response/conversation_model.dart';
import 'package:sixam_mart/data/model/response/order_details_model.dart';
import 'package:sixam_mart/data/model/response/order_model.dart';
import 'package:sixam_mart/data/model/response/review_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/confirmation_dialog.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/screens/chat/widget/image_dialog.dart';
import 'package:sixam_mart/view/screens/order/widget/order_item_widget.dart';
import 'package:sixam_mart/view/screens/parcel/widget/card_widget.dart';
import 'package:sixam_mart/view/screens/parcel/widget/details_widget.dart';
import 'package:sixam_mart/view/screens/review/rate_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/store/widget/review_dialog.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel orderModel;
  final int orderId;
  final bool fromNotification;
  OrderDetailsScreen({@required this.orderModel, @required this.orderId, this.fromNotification = false});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Timer _timer;

  void _loadData(BuildContext context, bool reload) async {
    await Get.find<OrderController>().trackOrder(widget.orderId.toString(), reload ? null : widget.orderModel, false);
    Get.find<OrderController>().timerTrackOrder(widget.orderId.toString());
    // if(widget.orderModel == null) {
    //   await Get.find<SplashController>().getConfigData(loadModuleData: true);
    // }
    Get.find<OrderController>().getOrderDetails(widget.orderId.toString());
  }

  void _startApiCall(){
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      Get.find<OrderController>().timerTrackOrder(widget.orderId.toString());
    });
  }

  @override
  void initState() {
    super.initState();

    _loadData(context, false);
    _startApiCall();
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
          return true;
        } else {
          Get.back();
          return true;
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'order_details'.tr, onBackPressed: () {
          if(widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          } else {
            Get.back();
          }
        }),
        endDrawer: MenuDrawer(),endDrawerEnableOpenDragGesture: false,
        body: GetBuilder<OrderController>(builder: (orderController) {
          double _deliveryCharge = 0;
          double _itemsPrice = 0;
          double _discount = 0;
          double _couponDiscount = 0;
          double _tax = 0;
          double _addOns = 0;
          double _dmTips = 0;
          OrderModel _order = orderController.trackModel;
          bool _parcel = false;
          bool _prescriptionOrder = false;
          bool _taxIncluded = false;
          if(orderController.orderDetails != null  && _order != null) {
            _parcel = _order.orderType == 'parcel';
            _prescriptionOrder = _order.prescriptionOrder;
            _deliveryCharge = _order.deliveryCharge;
            _couponDiscount = _order.couponDiscountAmount;
            _discount = _order.storeDiscountAmount;
            _tax = _order.totalTaxAmount;
            _dmTips = _order.dmTips;
            _taxIncluded = _order.taxStatus;
            if(_prescriptionOrder){
              double orderAmount = _order.orderAmount ?? 0;
              _itemsPrice = (orderAmount + _discount) - (_tax + _deliveryCharge );
            } else{
              for(OrderDetailsModel orderDetails in orderController.orderDetails) {
                for(AddOn addOn in orderDetails.addOns) {
                  _addOns = _addOns + (addOn.price * addOn.quantity);
                }
                _itemsPrice = _itemsPrice + (orderDetails.price * orderDetails.quantity);
              }
            }
          }
          double _subTotal = _itemsPrice + _addOns;
          double _total = _itemsPrice + _addOns - _discount + _tax + _deliveryCharge - _couponDiscount + _dmTips;

          return orderController.orderDetails != null ? Column(children: [

            Expanded(child: Scrollbar(child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              child: FooterView(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Row(children: [
                  Text('${_parcel ? 'delivery_id'.tr : 'order_id'.tr}:', style: robotoRegular),
                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Text(_order.id.toString(), style: robotoMedium),
                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Expanded(child: SizedBox()),
                  Icon(Icons.watch_later, size: 17),
                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Text(
                    DateConverter.dateTimeStringToDateTime(_order.createdAt),
                    style: robotoRegular,
                  ),
                ]),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                _order.scheduled == 1 ? Row(children: [
                  Text('${'scheduled_at'.tr}:', style: robotoRegular),
                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Text(DateConverter.dateTimeStringToDateTime(_order.scheduleAt), style: robotoMedium),
                ]) : SizedBox(),
                SizedBox(height: _order.scheduled == 1 ? Dimensions.PADDING_SIZE_SMALL : 0),

                Get.find<SplashController>().configModel.orderDeliveryVerification ? Row(children: [
                  Text('${'delivery_verification_code'.tr}:', style: robotoRegular),
                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Text(_order.otp, style: robotoMedium),
                ]) : SizedBox(),
                SizedBox(height: Get.find<SplashController>().configModel.orderDeliveryVerification ? 10 : 0),

                Row(children: [
                  Text(_order.orderType.tr, style: robotoMedium),
                  Expanded(child: SizedBox()),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    ),
                    child: Text(
                      _order.paymentMethod == 'cash_on_delivery' ? 'cash_on_delivery'.tr : _order.paymentMethod == 'wallet' ? 'wallet_payment'.tr : 'digital_payment'.tr,
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall),
                    ),
                  ),
                ]),
                Divider(height: Dimensions.PADDING_SIZE_LARGE),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  child: Row(children: [
                    Text('${_parcel ? 'charge_pay_by'.tr : 'item'.tr}:', style: robotoRegular),
                    SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    Text(
                      _parcel ? _order.chargePayer.tr : orderController.orderDetails.length.toString(),
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                    ),
                    Expanded(child: SizedBox()),
                    Container(height: 7, width: 7, decoration: BoxDecoration(
                      color: (_order.orderStatus == 'failed' || _order.orderStatus == 'canceled' || _order.orderStatus == 'refund_request_canceled')
                          ? Colors.red : _order.orderStatus == 'refund_requested' ? Colors.yellow : Colors.green,
                      shape: BoxShape.circle,
                    )),
                    SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    Text(
                      _order.orderStatus == 'delivered' ? '${'delivered_at'.tr} ${DateConverter.dateTimeStringToDateTime(_order.delivered)}'
                          : _order.orderStatus.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ),
                  ]),
                ),

                (_order.orderStatus == 'refund_requested' || _order.orderStatus == 'refund_request_canceled') ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Divider(height: Dimensions.PADDING_SIZE_LARGE),

                  _order.orderStatus == 'refund_requested' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    RichText(text: TextSpan(children: [
                      TextSpan(text: '${'refund_note'.tr}:', style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge.color)),
                      TextSpan(text: '(${(_order.refund != null) ? _order.refund.customerReason : ''})', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge.color)),
                    ])),
                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                    (_order.refund != null && _order.refund.customerNote != null) ? InkWell(
                      onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: _order.refund.customerNote), fromOrderDetails: true)),
                      child: Text(
                        '${_order.refund.customerNote}', maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                      ),
                    ) : SizedBox(),
                    SizedBox(height: (_order.refund != null && _order.refund.image != null) ? Dimensions.PADDING_SIZE_SMALL : 0),

                    (_order.refund != null && _order.refund.image != null && _order.refund.image.isNotEmpty) ? InkWell(
                      onTap: () => showDialog(context: context, builder: (context) {
                        return ImageDialog(imageUrl: '${Get.find<SplashController>().configModel.baseUrls.refundImageUrl}/${_order.refund.image.isNotEmpty ? _order.refund.image[0] : ''}');
                      }),
                      child: CustomImage(
                        height: 40, width: 40, fit: BoxFit.cover,
                        image: _order.refund != null ? '${Get.find<SplashController>().configModel.baseUrls.refundImageUrl}/${_order.refund.image.isNotEmpty ? _order.refund.image[0] : ''}' : '',
                      ),
                    ) : SizedBox(),
                  ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${'refund_cancellation_note'.tr}:', style: robotoMedium),
                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                    InkWell(
                      onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: _order.refund.adminNote), fromOrderDetails: true)),
                      child: Text(
                        '${_order.refund != null ? _order.refund.adminNote : ''}', maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                      ),
                    ),

                  ]),
                ]) : SizedBox(),

                Divider(height: Dimensions.PADDING_SIZE_LARGE),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                _parcel ? CardWidget(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  DetailsWidget(title: 'sender_details'.tr, address: _order.deliveryAddress),
                  SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                  DetailsWidget(title: 'receiver_details'.tr, address: _order.receiverDetails),
                ])) : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: orderController.orderDetails.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return OrderItemWidget(order: _order, orderDetails: orderController.orderDetails[index]);
                  },
                ),
                SizedBox(height: _parcel ? Dimensions.PADDING_SIZE_LARGE : 0),

                (Get.find<SplashController>().getModuleConfig(_order.moduleType).orderAttachment && _order.orderAttachment != null
                  && _order.orderAttachment.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('prescription'.tr, style: robotoRegular),
                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                    SizedBox(
                      child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1,
                            crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 5,
                          ),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _order.orderAttachment.length,
                          itemBuilder: (BuildContext context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => openDialog(context, '${Get.find<SplashController>().configModel.baseUrls.orderAttachmentUrl}/${_order.orderAttachment[index]}'),
                                child: Center(child: ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                                  child: CustomImage(
                                    image: '${Get.find<SplashController>().configModel.baseUrls.orderAttachmentUrl}/${_order.orderAttachment[index]}',
                                    width: 100, height: 100,
                                  ),
                                )),
                              ),
                            );
                          }),
                    ),

                    SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                  ]) : SizedBox(),
                  SizedBox(width: (Get.find<SplashController>().getModuleConfig(_order.moduleType).orderAttachment
                      && _order.orderAttachment != null && _order.orderAttachment.isNotEmpty) ? Dimensions.PADDING_SIZE_SMALL : 0),

                  (_order.orderNote  != null && _order.orderNote.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('additional_note'.tr, style: robotoRegular),
                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                    InkWell(
                      onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: _order.orderNote), fromOrderDetails: true)),
                      child: Text(
                        _order.orderNote, overflow: TextOverflow.ellipsis, maxLines: 3,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      ),
                    ),
                    SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                  ]) : SizedBox(),

                CardWidget(showCard: _parcel, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_parcel ? 'parcel_category'.tr : Get.find<SplashController>().getModuleConfig(_order.moduleType).showRestaurantText
                      ? 'restaurant_details'.tr : 'store_details'.tr, style: robotoRegular),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  (_parcel && _order.parcelCategory == null) ? Text(
                    'no_parcel_category_data_found'.tr, style: robotoMedium
                  ) : (!_parcel && _order.store == null) ? Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
                    child: Text('no_restaurant_data_found'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                  )) : Row(children: [

                    ClipOval(child: CustomImage(
                      image: _parcel ? '${Get.find<SplashController>().configModel.baseUrls.parcelCategoryImageUrl}/${_order.parcelCategory.image}'
                          : '${Get.find<SplashController>().configModel.baseUrls.storeImageUrl}/${_order.store.logo}',
                      height: 35, width: 35, fit: BoxFit.cover,
                    )),
                    SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        _parcel ? _order.parcelCategory.name : _order.store.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                      ),
                      Text(
                        _parcel ? _order.parcelCategory.description : _order.store.address, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      ),
                    ])),

                    (!_parcel && _order.orderType == 'take_away' && (_order.orderStatus == 'pending' || _order.orderStatus == 'accepted'
                        || _order.orderStatus == 'confirmed' || _order.orderStatus == 'processing' || _order.orderStatus == 'handover'
                        || _order.orderStatus == 'picked_up')) ? TextButton.icon(onPressed: () async {
                          if(!_parcel) {
                            String url ='https://www.google.com/maps/dir/?api=1&destination=${_order.store.latitude}'
                                ',${_order.store.longitude}&mode=d';
                            if (await canLaunchUrlString(url)) {
                              await launchUrlString(url);
                            }else {
                              showCustomSnackBar('unable_to_launch_google_map'.tr);
                            }
                          }
                          }, icon: Icon(Icons.directions), label: Text('direction'.tr),

                    ) : SizedBox(),

                    (!_parcel && _order.orderStatus != 'delivered' && _order.orderStatus != 'failed' && _order.orderStatus != 'canceled' && _order.orderStatus != 'refunded') ? TextButton.icon(
                      onPressed: () async {
                        await Get.toNamed(RouteHelper.getChatRoute(
                          notificationBody: NotificationBody(orderId: _order.id, restaurantId: _order.store.vendorId),
                          user: User(id: _order.store.vendorId, fName: _order.store.name, lName: '', image: _order.store.logo),
                        ));
                      },
                      icon: Icon(Icons.chat_bubble_outline, color: Theme.of(context).primaryColor, size: 20),
                      label: Text(
                        'chat'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                      ),
                    ) : SizedBox(),

                    (Get.find<SplashController>().configModel.refundActiveStatus && _order.orderStatus == 'delivered' && !_parcel
                    && (_parcel || (orderController.orderDetails.isNotEmpty && orderController.orderDetails[0].itemCampaignId == null))) ? InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getRefundRequestRoute(_order.id.toString())),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL, vertical: Dimensions.PADDING_SIZE_SMALL),
                        child: Text('refund_this_order'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                      ),
                    ) : SizedBox(),

                  ]),
                ])),
                SizedBox(height: _parcel ? 0 : Dimensions.PADDING_SIZE_LARGE),

                // Total
                _parcel ? SizedBox() : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('item_price'.tr, style: robotoRegular),
                    Text(PriceConverter.convertPrice(_itemsPrice), style: robotoRegular),
                  ]),
                  SizedBox(height: 10),

                  Get.find<SplashController>().getModuleConfig(_order.moduleType).addOn ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('addons'.tr, style: robotoRegular),
                      Text('(+) ${PriceConverter.convertPrice(_addOns)}', style: robotoRegular),
                    ],
                  ) : SizedBox(),

                  Get.find<SplashController>().getModuleConfig(_order.moduleType).addOn ? Divider(
                    thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5),
                  ) : SizedBox(),

                  Get.find<SplashController>().getModuleConfig(_order.moduleType).addOn ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('subtotal'.tr+ ' ${_taxIncluded ? 'tax_included'.tr : ''}', style: robotoMedium),
                      Text(PriceConverter.convertPrice(_subTotal), style: robotoMedium),
                    ],
                  ) : SizedBox(),
                  SizedBox(height: Get.find<SplashController>().getModuleConfig(_order.moduleType).addOn ? 10 : 0),

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('discount'.tr, style: robotoRegular),
                    Text('(-) ${PriceConverter.convertPrice(_discount)}', style: robotoRegular),
                  ]),
                  SizedBox(height: 10),

                  _couponDiscount > 0 ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('coupon_discount'.tr, style: robotoRegular),
                    Text(
                      '(-) ${PriceConverter.convertPrice(_couponDiscount)}',
                      style: robotoRegular,
                    ),
                  ]) : SizedBox(),
                  SizedBox(height: _couponDiscount > 0 ? 10 : 0),

                  !_taxIncluded ?  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('vat_tax'.tr, style: robotoRegular),
                    Text('(+) ${PriceConverter.convertPrice(_tax)}', style: robotoRegular),
                  ]) : SizedBox(),
                  SizedBox(height: _taxIncluded ? 0 : 10),

                  (_dmTips > 0) ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('delivery_man_tips'.tr, style: robotoRegular),
                      Text('(+) ${PriceConverter.convertPrice(_dmTips)}', style: robotoRegular),
                    ],
                  ) : SizedBox(),
                  SizedBox(height: _dmTips > 0 ? 10 : 0),

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('delivery_fee'.tr, style: robotoRegular),
                    _deliveryCharge > 0 ? Text(
                      '(+) ${PriceConverter.convertPrice(_deliveryCharge)}', style: robotoRegular,
                    ) : Text('free'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
                  ]),
                ]),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
                  child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                ),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('total_amount'.tr, style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor,
                  )),
                  Text(
                    PriceConverter.convertPrice(_total),
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                  ),
                ]),

                SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.PADDING_SIZE_LARGE : 0),
                ResponsiveHelper.isDesktop(context) ? _bottomView(orderController, _order, _parcel) : SizedBox(),

              ]))),
            ))),

            ResponsiveHelper.isDesktop(context) ? SizedBox() : _bottomView(orderController, _order, _parcel),

          ]) : Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }

  void openDialog(BuildContext context, String imageUrl) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE)),
        child: Stack(children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
            child: PhotoView(
              tightMode: true,
              imageProvider: NetworkImage(imageUrl),
              heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            ),
          ),

          Positioned(top: 0, right: 0, child: IconButton(
            splashRadius: 5,
            onPressed: () => Get.back(),
            icon: Icon(Icons.cancel, color: Colors.red),
          )),

        ]),
      );
    },
  );

  Widget _bottomView(OrderController orderController, OrderModel order, bool parcel) {
    return Column(children: [
      !orderController.showCancelled ? Center(
        child: SizedBox(
          width: Dimensions.WEB_MAX_WIDTH,
          child: Row(children: [
            (order.orderStatus == 'pending' || order.orderStatus == 'accepted' || order.orderStatus == 'confirmed'
                || order.orderStatus == 'processing' || order.orderStatus == 'handover'|| order.orderStatus == 'picked_up') ? Expanded(
              child: CustomButton(
                buttonText: parcel ? 'track_delivery'.tr : 'track_order'.tr,
                margin: ResponsiveHelper.isDesktop(context) ? null : EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                onPressed: () async{
                  _timer?.cancel();
                  await Get.toNamed(RouteHelper.getOrderTrackingRoute(order.id));
                  _startApiCall();
                },
              ),
            ) : SizedBox(),
            order.orderStatus == 'pending' ? Expanded(child: Padding(
              padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: Size(1, 50), shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), side: BorderSide(width: 2, color: Theme.of(context).disabledColor),
                )),
                onPressed: () {
                  Get.dialog(ConfirmationDialog(
                    icon: Images.warning, description: 'are_you_sure_to_cancel'.tr, onYesPressed: () {
                    orderController.cancelOrder(order.id);
                  },
                  ));
                },
                child: Text(parcel ? 'cancel_delivery'.tr : 'cancel_order'.tr, style: robotoBold.copyWith(
                  color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeLarge,
                )),
              ),
            )) : SizedBox(),

          ]),
        ),
      ) : Center(
        child: Container(
          width: Dimensions.WEB_MAX_WIDTH,
          height: 50,
          margin: ResponsiveHelper.isDesktop(context) ? null : EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
          ),
          child: Text('order_cancelled'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
        ),
      ),

      (order.orderStatus == 'delivered' && (parcel ? order.deliveryMan != null : (orderController.orderDetails.isNotEmpty && orderController.orderDetails[0].itemCampaignId == null))) ? Center(
        child: Container(
          width: Dimensions.WEB_MAX_WIDTH,
          padding: ResponsiveHelper.isDesktop(context) ? null : EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          child: CustomButton(
            buttonText: 'review'.tr,
            onPressed: () {
              List<OrderDetailsModel> _orderDetailsList = [];
              List<int> _orderDetailsIdList = [];
              orderController.orderDetails.forEach((orderDetail) {
                if(!_orderDetailsIdList.contains(orderDetail.itemDetails.id)) {
                  _orderDetailsList.add(orderDetail);
                  _orderDetailsIdList.add(orderDetail.itemDetails.id);
                }
              });
              Get.toNamed(RouteHelper.getReviewRoute(), arguments: RateReviewScreen(
                orderDetailsList: _orderDetailsList, deliveryMan: order.deliveryMan, orderID: order.id,
              ));
            },
          ),
        ),
      ) : SizedBox(),

      (order.orderStatus == 'failed' && Get.find<SplashController>().configModel.cashOnDelivery) ? Center(
        child: Container(
          width: Dimensions.WEB_MAX_WIDTH,
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          child: CustomButton(
            buttonText: 'switch_to_cash_on_delivery'.tr,
            onPressed: () {
              Get.dialog(ConfirmationDialog(
                  icon: Images.warning, description: 'are_you_sure_to_switch'.tr,
                  onYesPressed: () {
                    orderController.switchToCOD(order.id.toString()).then((isSuccess) {
                      Get.back();
                      if(isSuccess) {
                        Get.back();
                      }
                    });
                  }
              ));
            },
          ),
        ),
      ) : SizedBox(),
    ]);
  }

}