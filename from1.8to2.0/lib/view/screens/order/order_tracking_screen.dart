import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/body/notification_body.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/conversation_model.dart';
import 'package:sixam_mart/data/model/response/order_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/screens/order/widget/track_details_view.dart';
import 'package:sixam_mart/view/screens/order/widget/tracking_stepper_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderID;
  OrderTrackingScreen({@required this.orderID});

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  GoogleMapController _controller;
  bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  Timer _timer;

  void _loadData() async {
    await Get.find<LocationController>().getCurrentLocation(true, notify: false, defaultLatLng: LatLng(
      double.parse(Get.find<LocationController>().getUserAddress().latitude),
      double.parse(Get.find<LocationController>().getUserAddress().longitude),
    ));
    Get.find<OrderController>().trackOrder(widget.orderID, null, true);
  }

  void _startApiCall(){
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      Get.find<OrderController>().timerTrackOrder(widget.orderID.toString());
    });
  }

  @override
  void initState() {
    super.initState();

    _loadData();
    _startApiCall();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'order_tracking'.tr),
      endDrawer: MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<OrderController>(builder: (orderController) {
        OrderModel _track;
        if(orderController.trackModel != null) {
          _track = orderController.trackModel;

          /*if(_controller != null && GetPlatform.isWeb) {
            if(_track.deliveryAddress != null) {
              _controller.showMarkerInfoWindow(MarkerId('destination'));
            }
            if(_track.store != null) {
              _controller.showMarkerInfoWindow(MarkerId('store'));
            }
            if(_track.deliveryMan != null) {
              _controller.showMarkerInfoWindow(MarkerId('delivery_boy'));
            }
          }*/
        }

        return _track != null ? Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: Stack(children: [

          GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(
              double.parse(_track.deliveryAddress.latitude), double.parse(_track.deliveryAddress.longitude),
            ), zoom: 16),
            minMaxZoomPreference: MinMaxZoomPreference(0, 16),
            zoomControlsEnabled: true,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              _isLoading = false;
              setMarker(
                _track.store, _track.deliveryMan,
                _track.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? _track.deliveryAddress : AddressModel(
                  latitude: Get.find<LocationController>().position.latitude.toString(),
                  longitude: Get.find<LocationController>().position.longitude.toString(),
                  address: Get.find<LocationController>().address,
                ) : _track.deliveryAddress,
                _track.orderType == 'take_away',
              );
            },
          ),

          _isLoading ? Center(child: CircularProgressIndicator()) : SizedBox(),

          Positioned(
            top: Dimensions.PADDING_SIZE_SMALL, left: Dimensions.PADDING_SIZE_SMALL, right: Dimensions.PADDING_SIZE_SMALL,
            child: TrackingStepperWidget(status: _track.orderStatus, takeAway: _track.orderType == 'take_away'),
          ),

          Positioned(
            bottom: Dimensions.PADDING_SIZE_SMALL, left: Dimensions.PADDING_SIZE_SMALL, right: Dimensions.PADDING_SIZE_SMALL,
            child: TrackDetailsView(status: _track.orderStatus, track: _track, callback: () async{
              _timer?.cancel();
              await Get.toNamed(RouteHelper.getChatRoute(
                notificationBody: NotificationBody(deliverymanId: _track.deliveryMan.id, orderId: int.parse(widget.orderID)),
                user: User(id: _track.deliveryMan.id, fName: _track.deliveryMan.fName, lName: _track.deliveryMan.lName, image: _track.deliveryMan.image),
              ));
              _startApiCall();
            }),
          ),

        ]))) : Center(child: CircularProgressIndicator());
      }),
    );
  }

  void setMarker(Store store, DeliveryMan deliveryMan, AddressModel addressModel, bool takeAway) async {
    try {
      Uint8List restaurantImageData = await convertAssetToUnit8List(Images.restaurant_marker, width: 100);
      Uint8List deliveryBoyImageData = await convertAssetToUnit8List(Images.delivery_man_marker, width: 100);
      Uint8List destinationImageData = await convertAssetToUnit8List(
        takeAway ? Images.my_location_marker : Images.user_marker,
        width: takeAway ? 50 : 100,
      );

      // Animate to coordinate
      LatLngBounds bounds;
      double _rotation = 0;
      if(_controller != null) {
        if (double.parse(addressModel.latitude) < double.parse(store.latitude)) {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(addressModel.latitude), double.parse(addressModel.longitude)),
            northeast: LatLng(double.parse(store.latitude), double.parse(store.longitude)),
          );
          _rotation = 0;
        }else {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(store.latitude), double.parse(store.longitude)),
            northeast: LatLng(double.parse(addressModel.latitude), double.parse(addressModel.longitude)),
          );
          _rotation = 180;
        }
      }
      LatLng centerBounds = LatLng(
        (bounds.northeast.latitude + bounds.southwest.latitude)/2,
        (bounds.northeast.longitude + bounds.southwest.longitude)/2,
      );

      _controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: GetPlatform.isWeb ? 10 : 17)));
      if(!ResponsiveHelper.isWeb()) {
        zoomToFit(_controller, bounds, centerBounds, padding: 1.5);
      }

      // Marker
      _markers = HashSet<Marker>();
      addressModel != null ? _markers.add(Marker(
        markerId: MarkerId('destination'),
        position: LatLng(double.parse(addressModel.latitude), double.parse(addressModel.longitude)),
        infoWindow: InfoWindow(
          title: 'Destination',
          snippet: addressModel.address,
        ),
        icon: GetPlatform.isWeb ? BitmapDescriptor.defaultMarker : BitmapDescriptor.fromBytes(destinationImageData),
      )) : SizedBox();

      store != null ? _markers.add(Marker(
        markerId: MarkerId('store'),
        position: LatLng(double.parse(store.latitude), double.parse(store.longitude)),
        infoWindow: InfoWindow(
          title: Get.find<SplashController>().configModel.moduleConfig.module.showRestaurantText ? 'store'.tr : 'store'.tr,
          snippet: store.address,
        ),
        icon: GetPlatform.isWeb ? BitmapDescriptor.defaultMarker : BitmapDescriptor.fromBytes(restaurantImageData),
      )) : SizedBox();

      deliveryMan != null ? _markers.add(Marker(
        markerId: MarkerId('delivery_boy'),
        position: LatLng(double.parse(deliveryMan.lat ?? '0'), double.parse(deliveryMan.lng ?? '0')),
        infoWindow: InfoWindow(
          title: 'delivery_man'.tr,
          snippet: deliveryMan.location,
        ),
        rotation: _rotation,
        icon: GetPlatform.isWeb ? BitmapDescriptor.defaultMarker : BitmapDescriptor.fromBytes(deliveryBoyImageData),
      )) : SizedBox();
    }catch(e) {}
    setState(() {});
  }

  Future<void> zoomToFit(GoogleMapController controller, LatLngBounds bounds, LatLng centerBounds, {double padding = 0.5}) async {
    bool keepZoomingOut = true;

    while(keepZoomingOut) {
      final LatLngBounds screenBounds = await controller.getVisibleRegion();
      if(fits(bounds, screenBounds)){
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png)).buffer.asUint8List();
  }
}
