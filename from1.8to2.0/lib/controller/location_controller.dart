import 'dart:convert';

import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/data/api/api_checker.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/place_details_model.dart';
import 'package:sixam_mart/data/model/response/prediction_model.dart';
import 'package:sixam_mart/data/model/response/response_model.dart';
import 'package:sixam_mart/data/model/response/zone_response_model.dart';
import 'package:sixam_mart/data/repository/location_repo.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/view/base/confirmation_dialog.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/screens/home/home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/view/screens/location/widget/module_dialog.dart';
import 'package:sixam_mart/view/screens/location/widget/permission_dialog.dart';

class LocationController extends GetxController implements GetxService {
  final LocationRepo locationRepo;
  LocationController({@required this.locationRepo});

  Position _position = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1);
  Position _pickPosition = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1);
  bool _loading = false;
  String _address = '';
  String _pickAddress = '';
  List<Marker> _markers = <Marker>[];
  List<AddressModel> _addressList;
  List<AddressModel> _allAddressList;
  int _addressTypeIndex = 0;
  List<String> _addressTypeList = ['home', 'office', 'others'];
  bool _isLoading = false;
  bool _inZone = false;
  int _zoneID = 0;
  bool _buttonDisabled = true;
  bool _changeAddress = true;
  GoogleMapController _mapController;
  List<PredictionModel> _predictionList = [];
  bool _updateAddAddressData = true;


  List<PredictionModel> get predictionList => _predictionList;
  bool get isLoading => _isLoading;
  bool get loading => _loading;
  Position get position => _position;
  Position get pickPosition => _pickPosition;
  String get address => _address;
  String get pickAddress => _pickAddress;
  List<Marker> get markers => _markers;
  List<AddressModel> get addressList => _addressList;
  List<String> get addressTypeList => _addressTypeList;
  int get addressTypeIndex => _addressTypeIndex;
  bool get inZone => _inZone;
  int get zoneID => _zoneID;
  bool get buttonDisabled => _buttonDisabled;
  GoogleMapController get mapController => _mapController;

  Future<AddressModel> getCurrentLocation(bool fromAddress, {GoogleMapController mapController, LatLng defaultLatLng, bool notify = true}) async {
    _loading = true;
    if(notify) {
      update();
    }
    AddressModel _addressModel;
    Position _myPosition;
    try {
      Position newLocalData = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _myPosition = newLocalData;
    }catch(e) {
      _myPosition = Position(
        latitude: defaultLatLng != null ? defaultLatLng.latitude : double.parse(Get.find<SplashController>().configModel.defaultLocation.lat ?? '0'),
        longitude: defaultLatLng != null ? defaultLatLng.longitude : double.parse(Get.find<SplashController>().configModel.defaultLocation.lng ?? '0'),
        timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1,
      );
    }
    if(fromAddress) {
      _position = _myPosition;
    }else {
      _pickPosition = _myPosition;
    }
    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(_myPosition.latitude, _myPosition.longitude), zoom: 17),
      ));
    }
    String _addressFromGeocode = await getAddressFromGeocode(LatLng(_myPosition.latitude, _myPosition.longitude));
    fromAddress ? _address = _addressFromGeocode : _pickAddress = _addressFromGeocode;
    ZoneResponseModel _responseModel = await getZone(_myPosition.latitude.toString(), _myPosition.longitude.toString(), true);
    _buttonDisabled = !_responseModel.isSuccess;
    _addressModel = AddressModel(
      latitude: _myPosition.latitude.toString(), longitude: _myPosition.longitude.toString(), addressType: 'others',
      zoneId: _responseModel.isSuccess ? _responseModel.zoneIds[0] : 0, zoneIds: _responseModel.zoneIds,
      address: _addressFromGeocode, zoneData: _responseModel.zoneData,
    );
    _loading = false;
    update();
    return _addressModel;
  }

  Future<ZoneResponseModel> getZone(String lat, String long, bool markerLoad, {bool updateInAddress = false}) async {
    if(markerLoad) {
      _loading = true;
    }else {
      _isLoading = true;
    }
    if(!updateInAddress){
      update();
    }
    ZoneResponseModel _responseModel;
    Response response = await locationRepo.getZone(lat, long);
    if(response.statusCode == 200) {
      _inZone = true;
      _zoneID = int.parse(jsonDecode(response.body['zone_id'])[0].toString());
      List<int> _zoneIds = [];
      jsonDecode(response.body['zone_id']).forEach((zoneId) {
        _zoneIds.add(int.parse(zoneId.toString()));
      });
      List<ZoneData> _zoneData = [];
      response.body['zone_data'].forEach((data) {
        _zoneData.add(ZoneData.fromJson(data));
      });
      _responseModel = ZoneResponseModel(true, '', _zoneIds, _zoneData);
      if(updateInAddress) {
        AddressModel _address = getUserAddress();
        _address.zoneData = _zoneData;
        saveUserAddress(_address);
      }
    }else {
      _inZone = false;
      _responseModel = ZoneResponseModel(false, response.statusText, [], []);
    }
    if(markerLoad) {
      _loading = false;
    }else {
      _isLoading = false;
    }
    update();
    return _responseModel;
  }

  Future<void> syncZoneData() async {
    ZoneResponseModel _response = await getZone(getUserAddress().latitude, getUserAddress().longitude, false, updateInAddress: true);
    AddressModel _address = getUserAddress();
    _address.zoneId = _response.zoneIds[0];
    _address.zoneIds = [];
    _address.zoneIds.addAll(_response.zoneIds);
    _address.zoneData = [];
    _address.zoneData.addAll(_response.zoneData);
    await saveUserAddress(_address);
    update();
  }

  void updatePosition(CameraPosition position, bool fromAddress) async {
    if(_updateAddAddressData) {
      _loading = true;
      update();
      try {
        if (fromAddress) {
          _position = Position(
            latitude: position.target.latitude, longitude: position.target.longitude, timestamp: DateTime.now(),
            heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1,
          );
        } else {
          _pickPosition = Position(
            latitude: position.target.latitude, longitude: position.target.longitude, timestamp: DateTime.now(),
            heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1,
          );
        }
        ZoneResponseModel _responseModel = await getZone(position.target.latitude.toString(), position.target.longitude.toString(), true);
        _buttonDisabled = !_responseModel.isSuccess;
        if (_changeAddress) {
          String _addressFromGeocode = await getAddressFromGeocode(LatLng(position.target.latitude, position.target.longitude));
          fromAddress ? _address = _addressFromGeocode : _pickAddress = _addressFromGeocode;
        } else {
          _changeAddress = true;
        }
      } catch (e) {}
      _loading = false;
      update();
    }else {
      _updateAddAddressData = true;
    }
  }

  Future<ResponseModel> deleteUserAddressByID(int id, int index) async {
    Response response = await locationRepo.removeAddressByID(id);
    ResponseModel _responseModel;
    if (response.statusCode == 200) {
      _addressList.removeAt(index);
      _responseModel = ResponseModel(true, response.body['message']);
    } else {
      _responseModel = ResponseModel(false, response.statusText);
    }
    update();
    return _responseModel;
  }

  Future<void> getAddressList() async {
    Response response = await locationRepo.getAllAddress();
    if (response.statusCode == 200) {
      _addressList = [];
      _allAddressList = [];
      response.body['addresses'].forEach((address) {
        _addressList.add(AddressModel.fromJson(address));
        _allAddressList.add(AddressModel.fromJson(address));
      });
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void filterAddresses(String queryText) {
    if(_addressList != null) {
      _addressList = [];
      if (queryText == null || queryText.isEmpty) {
        _addressList.addAll(_allAddressList);
      } else {
        _allAddressList.forEach((address) {
          if (address.address.toLowerCase().contains(queryText.toLowerCase())) {
            _addressList.add(address);
          }
        });
      }
      update();
    }
  }

  Future<ResponseModel> addAddress(AddressModel addressModel, bool fromCheckout, int storeZoneId) async {
    _isLoading = true;
    update();
    Response response = await locationRepo.addAddress(addressModel);
    _isLoading = false;
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      if(fromCheckout && !response.body['zone_ids'].contains(storeZoneId)) {
        responseModel = ResponseModel(false, Get.find<SplashController>().configModel.moduleConfig.module.showRestaurantText
            ? 'your_selected_location_is_from_different_zone'.tr : 'your_selected_location_is_from_different_zone_store'.tr);
      }else {
        getAddressList();
        Get.find<OrderController>().setAddressIndex(0);
        String message = response.body["message"];
        responseModel = ResponseModel(true, message);
      }
    } else {
      responseModel = ResponseModel(false, response.statusText == 'Out of coverage!' ? 'service_not_available_in_this_area'.tr : response.statusText);
    }
    update();
    return responseModel;
  }

  Future<ResponseModel> updateAddress(AddressModel addressModel, int addressId) async {
    _isLoading = true;
    update();
    Response response = await locationRepo.updateAddress(addressModel, addressId);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      getAddressList();
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<bool> saveUserAddress(AddressModel address) async {
    String userAddress = jsonEncode(address.toJson());
    return await locationRepo.saveUserAddress(userAddress, address.zoneIds, address.latitude, address.longitude);
  }

  AddressModel getUserAddress() {
    AddressModel _addressModel;
    try {
      _addressModel = AddressModel.fromJson(jsonDecode(locationRepo.getUserAddress()));
    }catch(e) {}
    return _addressModel;
  }

  void setAddressTypeIndex(int index) {
    _addressTypeIndex = index;
    update();
  }

  void saveAddressAndNavigate(AddressModel address, bool fromSignUp, String route, bool canRoute, bool isDesktop) {
    if(Get.find<CartController>().cartList.length > 0) {
      Get.dialog(ConfirmationDialog(
        icon: Images.warning, title: 'are_you_sure_to_reset'.tr, description: 'if_you_change_location'.tr,
        onYesPressed: () {
          Get.back();
          _setZoneData(address, fromSignUp, route, canRoute, isDesktop);
        },
        onNoPressed: () {
          Get.back();
          Get.back();
        },
      ));
    }else {
      _setZoneData(address, fromSignUp, route, canRoute, isDesktop);
    }
  }

  void _setZoneData(AddressModel address, bool fromSignUp, String route, bool canRoute, bool isDesktop) {
    Get.find<LocationController>().getZone(address.latitude, address.longitude, false).then((response) async {
      if (response.isSuccess) {
        Get.find<CartController>().clearCartList();
        address.zoneId = response.zoneIds[0];
        address.zoneIds = [];
        address.zoneIds.addAll(response.zoneIds);
        address.zoneData = [];
        address.zoneData.addAll(response.zoneData);
        autoNavigate(address, fromSignUp, route, canRoute, isDesktop);
      } else {
        Get.back();
        showCustomSnackBar(response.message);
      }
    });
  }

  void autoNavigate(AddressModel address, bool fromSignUp, String route, bool canRoute, bool isDesktop) async {
    if (isDesktop && Get.find<SplashController>().configModel.module == null) {
      List<int> _zoneIds = address.zoneIds;
      Map<String, String> _header = {
        'Content-Type': 'application/json; charset=UTF-8',
        AppConstants.ZONE_ID: _zoneIds != null ? jsonEncode(_zoneIds) : null,
      };

      Get.find<SplashController>().getModules(headers: _header);
      if (Get.isDialogOpen) {
        Get.back();
      }
      Get.dialog(ModuleDialog(callback: () {
        saveData(address, fromSignUp, route, canRoute, isDesktop);
      }), barrierDismissible: false, barrierColor: Colors.black.withOpacity(0.7));
    } else {
      saveData(address, fromSignUp, route, canRoute, isDesktop);
    }
  }

  void saveData(AddressModel address, bool fromSignUp, String route, bool canRoute, bool isDesktop) async {
    if(!GetPlatform.isWeb) {
      if (Get.find<LocationController>().getUserAddress() != null) {
        if(Get.find<LocationController>().getUserAddress().zoneIds != null) {
          for(int zoneID in Get.find<LocationController>().getUserAddress().zoneIds) {
            FirebaseMessaging.instance.unsubscribeFromTopic('zone_${zoneID}_customer');
          }
        }else {
          FirebaseMessaging.instance.unsubscribeFromTopic('zone_${Get.find<LocationController>().getUserAddress().zoneId}_customer');
        }
      } else {
        FirebaseMessaging.instance.subscribeToTopic('zone_${address.zoneId}_customer');
      }
      if(address.zoneIds != null) {
        for(int zoneID in address.zoneIds) {
          FirebaseMessaging.instance.subscribeToTopic('zone_${zoneID}_customer');
        }
      }else {
        FirebaseMessaging.instance.subscribeToTopic('zone_${address.zoneId}_customer');
      }
    }
    await Get.find<LocationController>().saveUserAddress(address);
    if(Get.find<AuthController>().isLoggedIn()) {
      await Get.find<WishListController>().getWishList();
      Get.find<AuthController>().updateZone();
    }
    HomeScreen.loadData(true);
    Get.find<OrderController>().clearPrevData(address.zoneId);
    if(fromSignUp) {
      Get.offAllNamed(RouteHelper.getInterestRoute());
    }else {
      if(route != null && canRoute) {
        Get.offAllNamed(route);
      }else {
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }
    }
  }

  Future<AddressModel> setLocation(String placeID, String address, GoogleMapController mapController) async {
    _loading = true;
    update();

    LatLng _latLng = LatLng(0, 0);
    Response response = await locationRepo.getPlaceDetails(placeID);
    if(response.statusCode == 200) {
      PlaceDetailsModel _placeDetails = PlaceDetailsModel.fromJson(response.body);
      if(_placeDetails.status == 'OK') {
        _latLng = LatLng(_placeDetails.result.geometry.location.lat, _placeDetails.result.geometry.location.lng);
      }
    }

    _pickPosition = Position(
      latitude: _latLng.latitude, longitude: _latLng.longitude,
      timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1,
    );

    _pickAddress = address;
    _changeAddress = false;

    if(mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _latLng, zoom: 17)));
    }
    _loading = false;
    update();
    return AddressModel(
      latitude: _pickPosition.latitude.toString(), longitude: _pickPosition.longitude.toString(),
      addressType: 'others', address: _pickAddress,
    );
  }

  void disableButton() {
    _buttonDisabled = true;
    _inZone = true;
    update();
  }

  void setAddAddressData() {
    _position = _pickPosition;
    _address = _pickAddress;
    _updateAddAddressData = false;
    update();
  }

  void setUpdateAddress(AddressModel address){
    _position = Position(
      latitude: double.parse(address.latitude), longitude: double.parse(address.longitude), timestamp: DateTime.now(),
      altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, floor: 1, accuracy: 1,
    );
    _address = address.address;
    _addressTypeIndex = _addressTypeList.indexOf(address.addressType);
  }

  void setPickData() {
    _pickPosition = _position;
    _pickAddress = _address;
  }

  void setMapController(GoogleMapController mapController) {
    _mapController = mapController;
  }

  Future<String> getAddressFromGeocode(LatLng latLng) async {
    Response response = await locationRepo.getAddressFromGeocode(latLng);
    String _address = 'Unknown Location Found';
    if(response.statusCode == 200 && response.body['status'] == 'OK') {
      _address = response.body['results'][0]['formatted_address'].toString();
    }else {
      showCustomSnackBar(response.body['error_message'] ?? response.bodyString);
    }
    return _address;
  }

  Future<List<PredictionModel>> searchLocation(BuildContext context, String text) async {
    if(text != null && text.isNotEmpty) {
      Response response = await locationRepo.searchLocation(text);
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        _predictionList = [];
        response.body['predictions'].forEach((prediction) => _predictionList.add(PredictionModel.fromJson(prediction)));
      } else {
        showCustomSnackBar(response.body['error_message'] ?? response.bodyString);
      }
    }
    return _predictionList;
  }

  void setPlaceMark(String address) {
    _address = address;
  }

  void checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(PermissionDialog());
    }else {
      onTap();
    }
  }

}
