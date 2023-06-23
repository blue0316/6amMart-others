import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/banner_controller.dart';
import 'package:sixam_mart/controller/campaign_controller.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/data/api/api_checker.dart';
import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/data/model/response/config_model.dart';
import 'package:sixam_mart/data/model/response/module_model.dart';
import 'package:sixam_mart/data/repository/splash_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/html_type.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/screens/home/home_screen.dart';

class SplashController extends GetxController implements GetxService {
  final SplashRepo splashRepo;
  SplashController({@required this.splashRepo});

  ConfigModel _configModel;
  bool _firstTimeConnectionCheck = true;
  bool _hasConnection = true;
  ModuleModel _module;
  ModuleModel _cacheModule;
  List<ModuleModel> _moduleList;
  int _moduleIndex = 0;
  Map<String, dynamic> _data = Map();
  String _htmlText;
  bool _isLoading = false;
  int _selectedModuleIndex = 0;

  ConfigModel get configModel => _configModel;
  DateTime get currentTime => DateTime.now();
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;
  bool get hasConnection => _hasConnection;
  ModuleModel get module => _module;
  ModuleModel get cacheModule => _cacheModule;
  int get moduleIndex => _moduleIndex;
  List<ModuleModel> get moduleList => _moduleList;
  String get htmlText => _htmlText;
  bool get isLoading => _isLoading;
  int get selectedModuleIndex => _selectedModuleIndex;

  void selectModuleIndex(int index) {
    _selectedModuleIndex = index;
    update();
  }

  Future<bool> getConfigData({bool loadModuleData = false}) async {
    _hasConnection = true;
    _moduleIndex = 0;
    Response response = await splashRepo.getConfigData();
    bool _isSuccess = false;
    if(response.statusCode == 200) {
      _data = response.body;
      _configModel = ConfigModel.fromJson(response.body);
      if(_configModel.module != null) {
        setModule(_configModel.module);
      }else if(GetPlatform.isWeb || (loadModuleData && _module != null)) {
        setModule(GetPlatform.isWeb ? splashRepo.getModule() : _module);
      }
      _isSuccess = true;
    }else {
      ApiChecker.checkApi(response);
      if(response.statusText == ApiClient.noInternetMessage) {
        _hasConnection = false;
      }
      _isSuccess = false;
    }
    update();
    return _isSuccess;
  }

  Future<void> initSharedData() async {
    if(!GetPlatform.isWeb) {
      _module = null;
      _cacheModule = splashRepo.getCacheModule();
      splashRepo.initSharedData();
    }else {
      _module = await splashRepo.initSharedData();
    }
    await setModule(_module, notify: false);
  }

  bool showIntro() {
    return splashRepo.showIntro();
  }

  void disableIntro() {
    splashRepo.disableIntro();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  Future<void> setModule(ModuleModel module, {bool notify = true}) async {
    _module = module;
    splashRepo.setModule(module);
    if(module != null) {
      splashRepo.setCacheModule(module);
      _configModel.moduleConfig.module = Module.fromJson(_data['module_config'][module.moduleType]);
      Get.find<CartController>().getCartData();
    }
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<WishListController>().getWishList();
    }
    if(notify) {
      update();
    }
  }

  Module getModuleConfig(String moduleType) {
    Module _module = Module.fromJson(_data['module_config'][moduleType]);
    if(moduleType == 'food') {
      _module.newVariation = true;
    }else {
      _module.newVariation = false;
    }
    return _module;
  }

  Future<void> getModules({Map<String, String> headers}) async {
    _moduleIndex = 0;
    Response response = await splashRepo.getModules(headers: headers);
    if (response.statusCode == 200) {
      _moduleList = [];
      response.body.forEach((storeCategory) => _moduleList.add(ModuleModel.fromJson(storeCategory)));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void switchModule(int index, bool fromPhone) async {
    if(_module == null || _module.id != _moduleList[index].id) {
        await Get.find<SplashController>().setModule(_moduleList[index]);
        Get.find<CartController>().getCartData();
        HomeScreen.loadData(true);
    }
  }

  void setModuleIndex(int index) {
    _moduleIndex = index;
    update();
  }

  void removeModule() {
    setModule(null);
    Get.find<BannerController>().getFeaturedBanner();
    // Get.find<CartController>().getCartData();
    getModules();
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<LocationController>().getAddressList();
    }
    Get.find<StoreController>().getFeaturedStoreList();
    Get.find<CampaignController>().itemCampaignNull();
  }

  void removeCacheModule() {
    splashRepo.setCacheModule(null);
  }

  Future<void> getHtmlText(HtmlType htmlType) async {
    _htmlText = null;
    Response response = await splashRepo.getHtmlText(htmlType);
    if (response.statusCode == 200) {
      if(htmlType == HtmlType.SHIPPING_POLICY || htmlType == HtmlType.CANCELATION || htmlType == HtmlType.REFUND){
        _htmlText = response.body['value'];
      }else{
        _htmlText = response.body;
      }

      if(_htmlText != null && _htmlText.isNotEmpty) {
        _htmlText = _htmlText.replaceAll('href=', 'target="_blank" href=');
      }else {
        _htmlText = '';
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<bool> subscribeMail(String email) async {
    _isLoading = true;
    bool _isSuccess = false;
    update();
    Response response = await splashRepo.subscribeEmail(email);
    if (response.statusCode == 200) {
      showCustomSnackBar('subscribed_successfully'.tr, isError: false);
      _isSuccess = true;
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
    return _isSuccess;
  }

}
