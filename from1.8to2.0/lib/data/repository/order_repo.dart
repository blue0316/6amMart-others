import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/data/model/body/place_order_body.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  OrderRepo({@required this.apiClient, @required this.sharedPreferences});

  Future<Response> getRunningOrderList(int offset) async {
    return await apiClient.getData('${AppConstants.RUNNING_ORDER_LIST_URI}?offset=$offset&limit=${50}');
  }

  Future<Response> getHistoryOrderList(int offset) async {
    return await apiClient.getData('${AppConstants.HISTORY_ORDER_LIST_URI}?offset=$offset&limit=10');
  }

  Future<Response> getOrderDetails(String orderID) async {
    return await apiClient.getData('${AppConstants.ORDER_DETAILS_URI}$orderID');
  }

  Future<Response> cancelOrder(String orderID) async {
    return await apiClient.postData(AppConstants.ORDER_CANCEL_URI, {'_method': 'put', 'order_id': orderID});
  }

  Future<Response> trackOrder(String orderID) async {
    return await apiClient.getData('${AppConstants.TRACK_URI}$orderID');
  }

  Future<Response> placeOrder(PlaceOrderBody orderBody, XFile orderAttachment) async {
    return await apiClient.postMultipartData(
      AppConstants.PLACE_ORDER_URI, orderBody.toJson(),
      [MultipartBody('order_attachment', orderAttachment)],
    );
  }

  Future<Response> placePrescriptionOrder(int storeId, double distance, String address, String longitude,
      String latitude, String note, List<MultipartBody> orderAttachment) async {

    Map<String, String> _body = {
      'store_id': storeId.toString(),
      'distance': distance.toString(),
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'order_note': note,
    };
    return await apiClient.postMultipartData(AppConstants.PLACE_PRESCRIPTION_ORDER_URI, _body, orderAttachment);
  }

  Future<Response> getDeliveryManData(String orderID) async {
    return await apiClient.getData('${AppConstants.LAST_LOCATION_URI}$orderID');
  }

  Future<Response> switchToCOD(String orderID) async {
    return await apiClient.postData(AppConstants.COD_SWITCH_URL, {'_method': 'put', 'order_id': orderID});
  }

  Future<Response> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng) async {
    return await apiClient.getData('${AppConstants.DISTANCE_MATRIX_URI}'
        '?origin_lat=${originLatLng.latitude}&origin_lng=${originLatLng.longitude}'
        '&destination_lat=${destinationLatLng.latitude}&destination_lng=${destinationLatLng.longitude}');
  }

  Future<Response> getRefundReasons() async {
    return await apiClient.getData('${AppConstants.REFUND_REASONS_URI}');
  }

  Future<Response> submitRefundRequest(Map<String, String> body, XFile data) async {
    return apiClient.postMultipartData(AppConstants.REFUND_REQUEST_URI, body,  [MultipartBody('image[]', data)]);
  }

}