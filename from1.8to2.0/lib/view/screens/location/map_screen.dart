import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'dart:ui';

import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/screens/order/widget/address_details.dart';

class MapScreen extends StatefulWidget {
  final AddressModel address;
  final bool fromStore;
  MapScreen({@required this.address, this.fromStore = false});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _latLng;
  Set<Marker> _markers = Set.of([]);
  GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();

    _latLng = LatLng(double.parse(widget.address.latitude), double.parse(widget.address.longitude));
    _setMarker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'location'.tr),
      endDrawer: MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: Center(
        child: Container(
          width: Dimensions.WEB_MAX_WIDTH,
          child: Stack(children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _latLng, zoom: 16),
              minMaxZoomPreference: MinMaxZoomPreference(0, 16),
              zoomGesturesEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              indoorViewEnabled: true,
              markers:_markers,
              onMapCreated: (controller) => _mapController = controller,
            ),
            Positioned(
              left: Dimensions.PADDING_SIZE_LARGE, right: Dimensions.PADDING_SIZE_LARGE, bottom: Dimensions.PADDING_SIZE_LARGE,
              child: InkWell(
                onTap: () {
                  if(_mapController != null) {
                    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _latLng, zoom: 17)));
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Colors.grey[300], spreadRadius: 3, blurRadius: 10)],
                  ),
                  child: widget.fromStore ? Text(
                    widget.address.address, style: robotoMedium,
                  ) : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(children: [

                        Icon(
                          widget.address.addressType == 'home' ? Icons.home_outlined : widget.address.addressType == 'office'
                              ? Icons.work_outline : Icons.location_on,
                          size: 30, color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                            Text(widget.address.addressType.tr, style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
                            )),
                            SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                            AddressDetails(addressDetails: widget.address),

                          ]),
                        ),
                      ]),
                      SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                      Text('- ${widget.address.contactPersonName}', style: robotoMedium.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeLarge,
                      )),

                      Text('- ${widget.address.contactPersonNumber}', style: robotoRegular),

                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _setMarker() async {
    Uint8List destinationImageData = await convertAssetToUnit8List(
      widget.fromStore ? Images.restaurant_marker : Images.location_marker, width: 120,
    );

    _markers = Set.of([]);
    _markers.add(Marker(
      markerId: MarkerId('marker'),
      position: _latLng,
      icon: BitmapDescriptor.fromBytes(destinationImageData),
    ));

    setState(() {});
  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png)).buffer.asUint8List();
  }

}
