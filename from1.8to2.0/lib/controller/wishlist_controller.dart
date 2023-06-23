import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/api/api_checker.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/data/repository/item_repo.dart';
import 'package:sixam_mart/data/repository/wishlist_repo.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishListController extends GetxController implements GetxService {
  final WishListRepo wishListRepo;
  final ItemRepo itemRepo;
  WishListController({@required this.wishListRepo, @required this.itemRepo});

  List<Item> _wishItemList;
  List<Store> _wishStoreList;
  List<int> _wishItemIdList = [];
  List<int> _wishStoreIdList = [];
  bool _isRemoving = false;

  List<Item> get wishItemList => _wishItemList;
  List<Store> get wishStoreList => _wishStoreList;
  List<int> get wishItemIdList => _wishItemIdList;
  List<int> get wishStoreIdList => _wishStoreIdList;
  bool get isRemoving => _isRemoving;

  void addToWishList(Item product, Store store, bool isStore, {bool getXSnackBar = false}) async {
    if(isStore) {
      _wishStoreIdList.add(store.id);
      _wishStoreList.add(store);
    }else{
      _wishItemList.add(product);
      _wishItemIdList.add(product.id);
    }
    Response response = await wishListRepo.addWishList(isStore ? store.id : product.id, isStore);
    if (response.statusCode == 200) {
      // if(isStore) {
      //   _wishStoreIdList.forEach((storeId) {
      //     if(storeId == store.id){
      //       _wishStoreIdList.removeAt(_wishStoreIdList.indexOf(storeId));
      //     }
      //   });
      //   _wishStoreIdList.add(store.id);
      //   _wishStoreList.add(store);
      // }else {
      //   _wishItemIdList.forEach((productId) {
      //     if(productId == product.id){
      //       _wishItemIdList.removeAt(_wishItemIdList.indexOf(productId));
      //     }
      //   });
      //   _wishItemList.add(product);
      //   _wishItemIdList.add(product.id);
      // }
      showCustomSnackBar(response.body['message'], isError: false, getXSnackBar: getXSnackBar);
    } else {
      if(isStore) {
        _wishStoreIdList.forEach((storeId) {
          if (storeId == store.id) {
            _wishStoreIdList.removeAt(_wishStoreIdList.indexOf(storeId));
          }
        });
      }else{
        _wishItemIdList.forEach((productId) {
          if(productId == product.id){
            _wishItemIdList.removeAt(_wishItemIdList.indexOf(productId));
          }
        });
      }
      ApiChecker.checkApi(response, getXSnackBar: getXSnackBar);
    }
    update();
  }

  void removeFromWishList(int id, bool isStore, {bool getXSnackBar = false}) async {
    _isRemoving = true;
    update();

    int _idIndex = -1;
    int storeId, itemId;
    Store store;
    Item item;
    if(isStore) {
      _idIndex = _wishStoreIdList.indexOf(id);
      if(_idIndex != -1) {
        storeId = id;
        _wishStoreIdList.removeAt(_idIndex);
        store = _wishStoreList[_idIndex];
        _wishStoreList.removeAt(_idIndex);
      }
    }else {
      _idIndex = _wishItemIdList.indexOf(id);
      if(_idIndex != -1) {
        itemId = id;
        _wishItemIdList.removeAt(_idIndex);
        item = _wishItemList[_idIndex];
        _wishItemList.removeAt(_idIndex);
      }
    }
    Response response = await wishListRepo.removeWishList(id, isStore);
    if (response.statusCode == 200) {
      showCustomSnackBar(response.body['message'], isError: false, getXSnackBar: getXSnackBar);
    }
    else {
      ApiChecker.checkApi(response, getXSnackBar: getXSnackBar);
      if(isStore) {
        _wishStoreIdList.add(storeId);
        _wishStoreList.add(store);
      }else {
        _wishItemIdList.add(itemId);
        _wishItemList.add(item);
      }
    }
    _isRemoving = false;
    update();
  }

  Future<void> getWishList() async {
    _wishItemList = null;
    _wishStoreList = null;
    Response response = await wishListRepo.getWishList();
    if (response.statusCode == 200) {
      update();

      _wishItemList = [];
      _wishStoreList = [];
      _wishStoreIdList = [];
      _wishItemIdList = [];

      response.body['item'].forEach((item) async {
        if(item['module_type'] == null || !Get.find<SplashController>().getModuleConfig(item['module_type']).newVariation
            || item['variations'] == null || item['variations'].isEmpty
            || (item['food_variations'] != null && item['food_variations'].isNotEmpty)){

          Item _item = Item.fromJson(item);
          if(Get.find<SplashController>().module == null){
            Get.find<LocationController>().getUserAddress().zoneData.forEach((zone) {
              zone.modules.forEach((module) {
                if(module.id == _item.moduleId){
                  if(module.pivot.zoneId == _item.zoneId){
                    _wishItemList.add(_item);
                    _wishItemIdList.add(_item.id);
                  }
                }
              });
            });
          }else{
            _wishItemList.add(_item);
            _wishItemIdList.add(_item.id);
          }
        }
      });

      response.body['store'].forEach((store) async {
        if(Get.find<SplashController>().module == null){
          Get.find<LocationController>().getUserAddress().zoneData.forEach((zone) {
            zone.modules.forEach((module) {
              if(module.id == Store.fromJson(store).moduleId){
                if(module.pivot.zoneId == Store.fromJson(store).zoneId){
                  _wishStoreList.add(Store.fromJson(store));
                  _wishStoreIdList.add(Store.fromJson(store).id);
                }
              }
            });
          });
        }else{
          Store _store;
          try{
            _store = Store.fromJson(store);
          }catch(e){}
          if(_store != null && Get.find<SplashController>().module.id == _store.moduleId) {
            _wishStoreList.add(_store);
            _wishStoreIdList.add(_store.id);
          }
        }

      });
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void removeWishes() {
    _wishItemIdList = [];
    _wishStoreIdList = [];
  }
}
