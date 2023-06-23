import 'dart:convert';

import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepo{
  final SharedPreferences sharedPreferences;
  CartRepo({@required this.sharedPreferences});

  List<CartModel> getCartList() {
    List<String> carts = [];
    if(sharedPreferences.containsKey(AppConstants.CART_LIST)) {
      carts = sharedPreferences.getStringList(AppConstants.CART_LIST);
    }
    List<CartModel> cartList = [];
    carts.forEach((cart) => cartList.add(CartModel.fromJson(jsonDecode(cart))) );
    return cartList;
  }

  Future<void> addToCartList(List<CartModel> cartProductList) async {
    List<String> carts = [];
    cartProductList.forEach((cartModel) => carts.add(jsonEncode(cartModel)) );
    await sharedPreferences.setStringList(AppConstants.CART_LIST, carts);
  }

}