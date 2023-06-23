import 'dart:convert';

import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/body/notification_body.dart';
import 'package:sixam_mart/data/model/body/social_log_in_body.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/basic_campaign_model.dart';
import 'package:sixam_mart/data/model/response/conversation_model.dart';
import 'package:sixam_mart/data/model/response/order_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/parcel_category_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/html_type.dart';
import 'package:sixam_mart/view/base/image_viewer_screen.dart';
import 'package:sixam_mart/view/base/not_found.dart';
import 'package:sixam_mart/view/screens/address/add_address_screen.dart';
import 'package:sixam_mart/view/screens/address/address_screen.dart';
import 'package:sixam_mart/view/screens/auth/delivery_man_registration_screen.dart';
import 'package:sixam_mart/view/screens/auth/store_registration_screen.dart';
import 'package:sixam_mart/view/screens/auth/sign_in_screen.dart';
import 'package:sixam_mart/view/screens/auth/sign_up_screen.dart';
import 'package:sixam_mart/view/screens/cart/cart_screen.dart';
import 'package:sixam_mart/view/screens/category/category_item_screen.dart';
import 'package:sixam_mart/view/screens/category/category_screen.dart';
import 'package:sixam_mart/view/screens/chat/chat_screen.dart';
import 'package:sixam_mart/view/screens/chat/conversation_screen.dart';
import 'package:sixam_mart/view/screens/checkout/checkout_screen.dart';
import 'package:sixam_mart/view/screens/checkout/order_successful_screen.dart';
import 'package:sixam_mart/view/screens/checkout/payment_screen.dart';
import 'package:sixam_mart/view/screens/coupon/coupon_screen.dart';
import 'package:sixam_mart/view/screens/dashboard/dashboard_screen.dart';
import 'package:sixam_mart/view/screens/item/item_campaign_screen.dart';
import 'package:sixam_mart/view/screens/item/item_details_screen.dart';
import 'package:sixam_mart/view/screens/item/popular_item_screen.dart';
import 'package:sixam_mart/view/screens/forget/forget_pass_screen.dart';
import 'package:sixam_mart/view/screens/forget/new_pass_screen.dart';
import 'package:sixam_mart/view/screens/forget/verification_screen.dart';
import 'package:sixam_mart/view/screens/html/html_viewer_screen.dart';
import 'package:sixam_mart/view/screens/interest/interest_screen.dart';
import 'package:sixam_mart/view/screens/language/language_screen.dart';
import 'package:sixam_mart/view/screens/location/access_location_screen.dart';
import 'package:sixam_mart/view/screens/location/map_screen.dart';
import 'package:sixam_mart/view/screens/location/pick_map_screen.dart';
import 'package:sixam_mart/view/screens/notification/notification_screen.dart';
import 'package:sixam_mart/view/screens/onboard/onboarding_screen.dart';
import 'package:sixam_mart/view/screens/order/order_details_screen.dart';
import 'package:sixam_mart/view/screens/order/order_screen.dart';
import 'package:sixam_mart/view/screens/order/order_tracking_screen.dart';
import 'package:sixam_mart/view/screens/order/refund_request_screen.dart';
import 'package:sixam_mart/view/screens/parcel/parcel_category_screen.dart';
import 'package:sixam_mart/view/screens/parcel/parcel_location_screen.dart';
import 'package:sixam_mart/view/screens/parcel/parcel_request_screen.dart';
import 'package:sixam_mart/view/screens/profile/profile_screen.dart';
import 'package:sixam_mart/view/screens/profile/update_profile_screen.dart';
import 'package:sixam_mart/view/screens/refer_and_earn/refer_and_earn_screen.dart';
import 'package:sixam_mart/view/screens/store/all_store_screen.dart';
import 'package:sixam_mart/view/screens/store/campaign_screen.dart';
import 'package:sixam_mart/view/screens/store/store_item_search_screen.dart';
import 'package:sixam_mart/view/screens/store/store_screen.dart';
import 'package:sixam_mart/view/screens/store/review_screen.dart';
import 'package:sixam_mart/view/screens/search/search_screen.dart';
import 'package:sixam_mart/view/screens/splash/splash_screen.dart';
import 'package:sixam_mart/view/screens/support/support_screen.dart';
import 'package:sixam_mart/view/screens/update/update_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/wallet/wallet_screen.dart';

class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String language = '/language';
  static const String onBoarding = '/on-boarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String verification = '/verification';
  static const String accessLocation = '/access-location';
  static const String pickMap = '/pick-map';
  static const String interest = '/interest';
  static const String main = '/main';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String search = '/search';
  static const String store = '/store';
  static const String orderDetails = '/order-details';
  static const String profile = '/profile';
  static const String updateProfile = '/update-profile';
  static const String coupon = '/coupon';
  static const String notification = '/notification';
  static const String map = '/map';
  static const String address = '/address';
  static const String orderSuccess = '/order-successful';
  static const String payment = '/payment';
  static const String checkout = '/checkout';
  static const String orderTracking = '/track-order';
  static const String basicCampaign = '/basic-campaign';
  static const String html = '/html';
  static const String categories = '/categories';
  static const String categoryItem = '/category-item';
  static const String popularItems = '/popular-items';
  static const String itemCampaign = '/item-campaign';
  static const String support = '/help-and-support';
  static const String rateReview = '/rate-and-review';
  static const String update = '/update';
  static const String cart = '/cart';
  static const String addAddress = '/add-address';
  static const String editAddress = '/edit-address';
  static const String storeReview = '/store-review';
  static const String allStores = '/stores';
  static const String itemImages = '/item-images';
  static const String parcelCategory = '/parcel-category';
  static const String parcelLocation = '/parcel-location';
  static const String parcelRequest = '/parcel-request';
  static const String searchStoreItem = '/search-store-item';
  static const String order = '/order';
  static const String itemDetails = '/item-details';
  static const String wallet = '/wallet';
  static const String referAndEarn = '/refer-and-earn';
  static const String messages = '/messages';
  static const String conversation = '/conversation';
  static const String restaurantRegistration = '/restaurant-registration';
  static const String deliveryManRegistration = '/delivery-man-registration';
  static const String refund = '/refund';


  static String getInitialRoute() => '$initial';
  static String getSplashRoute(NotificationBody body) {
    String _data = 'null';
    if(body != null) {
      List<int> _encoded = utf8.encode(jsonEncode(body.toJson()));
      _data = base64Encode(_encoded);
    }
    return '$splash?data=$_data';
  }
  static String getLanguageRoute(String page) => '$language?page=$page';
  static String getOnBoardingRoute() => '$onBoarding';
  static String getSignInRoute(String page) => '$signIn?page=$page';
  static String getSignUpRoute() => '$signUp';
  static String getVerificationRoute(String number, String token, String page, String pass) {
    return '$verification?page=$page&number=$number&token=$token&pass=$pass';
  }
  static String getAccessLocationRoute(String page) => '$accessLocation?page=$page';
  static String getPickMapRoute(String page, bool canRoute) => '$pickMap?page=$page&route=${canRoute.toString()}';
  static String getInterestRoute() => '$interest';
  static String getMainRoute(String page) => '$main?page=$page';
  static String getForgotPassRoute(bool fromSocialLogin, SocialLogInBody socialLogInBody) {
    String _data;
    if(fromSocialLogin) {
      _data = base64Encode(utf8.encode(jsonEncode(socialLogInBody.toJson())));
    }
    return '$forgotPassword?page=${fromSocialLogin ? 'social-login' : 'forgot-password'}&data=${fromSocialLogin ? _data : 'null'}';
  }
  static String getResetPasswordRoute(String phone, String token, String page) => '$resetPassword?phone=$phone&token=$token&page=$page';
  static String getSearchRoute({String queryText}) => '$search?query=${queryText ?? ''}';
  static String getStoreRoute(int id, String page) => '$store?id=$id&page=$page';
  static String getOrderDetailsRoute(int orderID, {bool fromNotification}) {
    return '$orderDetails?id=$orderID&from=${fromNotification.toString()}';
  }
  static String getProfileRoute() => '$profile';
  static String getUpdateProfileRoute() => '$updateProfile';
  static String getCouponRoute({bool fromCheckout = false}) => '$coupon?fromCheckout=${fromCheckout ? 'true' : 'false'}';
  static String getNotificationRoute({bool fromNotification}) => '$notification?from=${fromNotification.toString()}';
  static String getMapRoute(AddressModel addressModel, String page) {
    List<int> _encoded = utf8.encode(jsonEncode(addressModel.toJson()));
    String _data = base64Encode(_encoded);
    return '$map?address=$_data&page=$page';
  }
  static String getAddressRoute() => '$address';
  static String getOrderSuccessRoute(String orderID, bool codDelivery) {
    return '$orderSuccess?id=$orderID&cod-delivery=$codDelivery';
  }
  static String getPaymentRoute(String id, int user, String type, double amount, double maximumCodOrderAmount, bool codDelivery) => '$payment?id=$id&user=$user&type=$type&amount=$amount&cod=$maximumCodOrderAmount&cod-delivery=$codDelivery';
  static String getCheckoutRoute(String page,{int storeId}) => '$checkout?page=$page&store-id=$storeId';
  static String getOrderTrackingRoute(int id) => '$orderTracking?id=$id';
  static String getBasicCampaignRoute(BasicCampaignModel basicCampaignModel) {
    String _data = base64Encode(utf8.encode(jsonEncode(basicCampaignModel.toJson())));
    return '$basicCampaign?data=$_data';
  }
  static String getHtmlRoute(String page) => '$html?page=$page';
  static String getCategoryRoute() => '$categories';
  static String getCategoryItemRoute(int id, String name) {
    List<int> _encoded = utf8.encode(name);
    String _data = base64Encode(_encoded);
    return '$categoryItem?id=$id&name=$_data';
  }
  static String getPopularItemRoute(bool isPopular) => '$popularItems?page=${isPopular ? 'popular' : 'reviewed'}';
  static String getItemCampaignRoute() => '$itemCampaign';
  static String getSupportRoute() => '$support';
  static String getReviewRoute() => '$rateReview';
  static String getUpdateRoute(bool isUpdate) => '$update?update=${isUpdate.toString()}';
  static String getCartRoute() => '$cart';
  static String getAddAddressRoute(bool fromCheckout, int zoneId) => '$addAddress?page=${fromCheckout ? 'checkout' : 'address'}&zone_id=$zoneId';
  static String getEditAddressRoute(AddressModel address) {
    String _data = base64Url.encode(utf8.encode(jsonEncode(address.toJson())));
    return '$editAddress?data=$_data';
  }
  static String getStoreReviewRoute(int storeID) => '$storeReview?id=$storeID';
  static String getAllStoreRoute(String page) => '$allStores?page=$page';
  static String getItemImagesRoute(Item item) {
    String _data = base64Url.encode(utf8.encode(jsonEncode(item.toJson())));
    return '$itemImages?item=$_data';
  }
  static String getParcelCategoryRoute() => '$parcelCategory';
  static String getParcelLocationRoute(ParcelCategoryModel category) {
    String _data = base64Url.encode(utf8.encode(jsonEncode(category.toJson())));
    return '$parcelLocation?data=$_data';
  }
  static String getParcelRequestRoute(ParcelCategoryModel category, AddressModel pickupAddress, AddressModel destinationAddress) {
    String _category = base64Url.encode(utf8.encode(jsonEncode(category.toJson())));
    String _pickedUpAddress = base64Url.encode(utf8.encode(jsonEncode(pickupAddress.toJson())));
    String _destinationAddress = base64Url.encode(utf8.encode(jsonEncode(destinationAddress.toJson())));
    return '$parcelRequest?category=$_category&picked=$_pickedUpAddress&destination=$_destinationAddress';
  }
  static String getSearchStoreItemRoute(int storeID) => '$searchStoreItem?id=$storeID';
  static String getOrderRoute() => '$order';
  static String getItemDetailsRoute(int itemID, bool isRestaurant) => '$itemDetails?id=$itemID&page=${isRestaurant ? 'restaurant' : 'item'}';
  static String getWalletRoute(bool fromWallet) => '$wallet?page=${fromWallet ? 'wallet' : 'loyalty_points'}';
  static String getReferAndEarnRoute() => '$referAndEarn';
  static String getChatRoute({@required NotificationBody notificationBody, User user, int conversationID, int index, bool fromNotification}) {
    String _notificationBody = 'null';
    if(notificationBody != null) {
      _notificationBody = base64Encode(utf8.encode(jsonEncode(notificationBody.toJson())));
    }
    String _user = 'null';
    if(user != null) {
      _user = base64Encode(utf8.encode(jsonEncode(user.toJson())));
    }
    return '$messages?notification=$_notificationBody&user=$_user&conversation_id=$conversationID&index=$index&from=${fromNotification.toString()}';
  }
  static String getConversationRoute() => '$conversation';
  static String getRestaurantRegistrationRoute() => '$restaurantRegistration';
  static String getDeliverymanRegistrationRoute() => '$deliveryManRegistration';
  static String getRefundRequestRoute(String orderID) => '$refund?id=$orderID';

  static List<GetPage> routes = [
    GetPage(name: initial, page: () => getRoute(DashboardScreen(pageIndex: 0))),
    GetPage(name: splash, page: () {
      NotificationBody _data;
      if(Get.parameters['data'] != 'null') {
        List<int> _decode = base64Decode(Get.parameters['data'].replaceAll(' ', '+'));
        _data = NotificationBody.fromJson(jsonDecode(utf8.decode(_decode)));
      }
      return SplashScreen(body: _data);
    }),
    GetPage(name: language, page: () => ChooseLanguageScreen(fromMenu: Get.parameters['page'] == 'menu')),
    GetPage(name: onBoarding, page: () => OnBoardingScreen()),
    GetPage(name: signIn, page: () => SignInScreen(
      exitFromApp: Get.parameters['page'] == signUp || Get.parameters['page'] == splash || Get.parameters['page'] == onBoarding,
    )),
    GetPage(name: signUp, page: () => SignUpScreen()),
    GetPage(name: verification, page: () {
      List<int> _decode = base64Decode(Get.parameters['pass'].replaceAll(' ', '+'));
      String _data = utf8.decode(_decode);
      return VerificationScreen(
        number: Get.parameters['number'], fromSignUp: Get.parameters['page'] == signUp, token: Get.parameters['token'],
        password: _data,
      );
    }),
    GetPage(name: accessLocation, page: () => AccessLocationScreen(
      fromSignUp: Get.parameters['page'] == signUp, fromHome: Get.parameters['page'] == 'home', route: null,
    )),
    GetPage(name: pickMap, page: () {
      PickMapScreen _pickMapScreen = Get.arguments;
      bool _fromAddress = Get.parameters['page'] == 'add-address';
      return ((Get.parameters['page'] == 'parcel' && _pickMapScreen == null) || (_fromAddress && _pickMapScreen == null))
          ? NotFound() : _pickMapScreen != null ? _pickMapScreen : PickMapScreen(
        fromSignUp: Get.parameters['page'] == signUp, fromAddAddress: _fromAddress, route: Get.parameters['page'],
        canRoute: Get.parameters['route'] == 'true',
      );
    }),
    GetPage(name: interest, page: () => InterestScreen()),
    GetPage(name: main, page: () => getRoute(DashboardScreen(
      pageIndex: Get.parameters['page'] == 'home' ? 0 : Get.parameters['page'] == 'favourite' ? 1
          : Get.parameters['page'] == 'cart' ? 2 : Get.parameters['page'] == 'order' ? 3 : Get.parameters['page'] == 'menu' ? 4 : 0,
    ))),
    GetPage(name: forgotPassword, page: () {
      SocialLogInBody _data;
      if(Get.parameters['page'] == 'social-login') {
        List<int> _decode = base64Decode(Get.parameters['data'].replaceAll(' ', '+'));
        _data = SocialLogInBody.fromJson(jsonDecode(utf8.decode(_decode)));
      }
      return ForgetPassScreen(fromSocialLogin: Get.parameters['page'] == 'social-login', socialLogInBody: _data);
    }),
    GetPage(name: resetPassword, page: () => NewPassScreen(
      resetToken: Get.parameters['token'], number: Get.parameters['phone'], fromPasswordChange: Get.parameters['page'] == 'password-change',
    )),
    GetPage(name: search, page: () => getRoute(SearchScreen(queryText: Get.parameters['query']))),
    GetPage(name: store, page: () {
      return getRoute(Get.arguments != null ? Get.arguments : StoreScreen(
        store: Store(id: int.parse(Get.parameters['id'])),
        fromModule: Get.parameters['page'] == 'module',
      ));
    }),
    GetPage(name: orderDetails, page: () {
      return getRoute(Get.arguments != null ? Get.arguments : OrderDetailsScreen(orderId: int.parse(Get.parameters['id'] ?? '0'), orderModel: null, fromNotification: Get.parameters['from'] == 'true'));
    }),
    GetPage(name: profile, page: () => getRoute(ProfileScreen())),
    GetPage(name: updateProfile, page: () => getRoute(UpdateProfileScreen())),
    GetPage(name: coupon, page: () => getRoute(CouponScreen(fromCheckout: Get.parameters['fromCheckout'] == 'true'))),
    GetPage(name: notification, page: () => getRoute(NotificationScreen(fromNotification: Get.parameters['from'] == 'true'))),
    GetPage(name: map, page: () {
      List<int> _decode = base64Decode(Get.parameters['address'].replaceAll(' ', '+'));
      AddressModel _data = AddressModel.fromJson(jsonDecode(utf8.decode(_decode)));
      return getRoute(MapScreen(fromStore: Get.parameters['page'] == 'store', address: _data));
    }),
    GetPage(name: address, page: () => getRoute(AddressScreen())),
    GetPage(name: orderSuccess, page: () => getRoute(OrderSuccessfulScreen(orderID: Get.parameters['id'],
        isCashOnDelivery: Get.parameters['cod-delivery'] == 'true' ? true : false),
    )),
    GetPage(name: payment, page: () => getRoute(PaymentScreen(orderModel: OrderModel(
        id: int.parse(Get.parameters['id']), orderType: Get.parameters['type'], userId: int.parse(Get.parameters['user']),
        orderAmount: double.parse(Get.parameters['amount'])), maximumCodOrderAmount: double.parse(Get.parameters['cod'])
        , isCashOnDelivery: Get.parameters['cod-delivery'] == 'true' ? true : false),
    )),
    GetPage(name: checkout, page: () {
      CheckoutScreen _checkoutScreen = Get.arguments;
      bool _fromCart = Get.parameters['page'] == 'cart';
      return getRoute(_checkoutScreen != null ? _checkoutScreen : !_fromCart ? NotFound() : CheckoutScreen(
        cartList: null, fromCart: Get.parameters['page'] == 'cart', storeId: Get.parameters['store-id'] != 'null' ? int.parse(Get.parameters['store-id']) : null,
      ));
    }),
    GetPage(name: orderTracking, page: () => getRoute(OrderTrackingScreen(orderID: Get.parameters['id']))),
    GetPage(name: basicCampaign, page: () {
      BasicCampaignModel _data = BasicCampaignModel.fromJson(jsonDecode(utf8.decode(base64Decode(Get.parameters['data'].replaceAll(' ', '+')))));
      return getRoute(CampaignScreen(campaign: _data));
    }),
    GetPage(name: html, page: () => HtmlViewerScreen(
      htmlType: Get.parameters['page'] == 'terms-and-condition' ? HtmlType.TERMS_AND_CONDITION
          : Get.parameters['page'] == 'privacy-policy' ? HtmlType.PRIVACY_POLICY
          : Get.parameters['page'] == 'shipping-policy' ? HtmlType.SHIPPING_POLICY
          : Get.parameters['page'] == 'cancellation-policy' ? HtmlType.CANCELATION
          : Get.parameters['page'] == 'refund-policy' ? HtmlType.REFUND : HtmlType.ABOUT_US,
    )),
    GetPage(name: categories, page: () => getRoute(CategoryScreen())),
    GetPage(name: categoryItem, page: () {
      List<int> _decode = base64Decode(Get.parameters['name'].replaceAll(' ', '+'));
      String _data = utf8.decode(_decode);
      return getRoute(CategoryItemScreen(categoryID: Get.parameters['id'], categoryName: _data));
    }),
    GetPage(name: popularItems, page: () => getRoute(PopularItemScreen(isPopular: Get.parameters['page'] == 'popular'))),
    GetPage(name: itemCampaign, page: () => getRoute(ItemCampaignScreen())),
    GetPage(name: support, page: () => getRoute(SupportScreen())),
    GetPage(name: update, page: () => UpdateScreen(isUpdate: Get.parameters['update'] == 'true')),
    GetPage(name: cart, page: () => getRoute(CartScreen(fromNav: false))),
    GetPage(name: addAddress, page: () => getRoute(AddAddressScreen(
      fromCheckout: Get.parameters['page'] == 'checkout', zoneId: int.parse(Get.parameters['zone_id']),
    ))),
    GetPage(name: editAddress, page: () => getRoute(AddAddressScreen(
      fromCheckout: false,
      address: AddressModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['data'].replaceAll(' ', '+'))))),
    ))),
    GetPage(name: rateReview, page: () => getRoute(Get.arguments != null ? Get.arguments : NotFound())),
    GetPage(name: storeReview, page: () => getRoute(ReviewScreen(storeID: Get.parameters['id']))),
    GetPage(name: allStores, page: () => getRoute(AllStoreScreen(
      isPopular: Get.parameters['page'] == 'popular', isFeatured: Get.parameters['page'] == 'featured',
    ))),
    GetPage(name: itemImages, page: () => getRoute(ImageViewerScreen(
      item: Item.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['item'].replaceAll(' ', '+'))))),
    ))),
    GetPage(name: parcelCategory, page: () => getRoute(ParcelCategoryScreen())),
    GetPage(name: parcelLocation, page: () => getRoute(ParcelLocationScreen(
      category: ParcelCategoryModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['data'].replaceAll(' ', '+'))))),
    ))),
    GetPage(name: parcelRequest, page: () => getRoute(ParcelRequestScreen(
      parcelCategory: ParcelCategoryModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['category'].replaceAll(' ', '+'))))),
      pickedUpAddress: AddressModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['picked'].replaceAll(' ', '+'))))),
      destinationAddress: AddressModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['destination'].replaceAll(' ', '+'))))),
    ))),
    GetPage(name: searchStoreItem, page: () => getRoute(StoreItemSearchScreen(storeID: Get.parameters['id']))),
    GetPage(name: order, page: () => getRoute(OrderScreen())),
    GetPage(name: itemDetails, page: () => getRoute(Get.arguments != null ? Get.arguments : ItemDetailsScreen(item: Item(id: int.parse(Get.parameters['id'])), inStorePage: Get.parameters['page'] == 'restaurant'))),
    GetPage(name: wallet, page: () => getRoute(WalletScreen(fromWallet: Get.parameters['page'] == 'wallet'))),
    GetPage(name: referAndEarn, page: () => getRoute(ReferAndEarnScreen())),
    GetPage(name: messages, page: () {
      NotificationBody _notificationBody;
      if(Get.parameters['notification'] != 'null') {
        _notificationBody = NotificationBody.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['notification'].replaceAll(' ', '+')))));
      }
      User _user;
      if(Get.parameters['user'] != 'null') {
        _user = User.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['user'].replaceAll(' ', '+')))));
      }
      return getRoute(ChatScreen(
        notificationBody: _notificationBody, user: _user, index: Get.parameters['index'] != 'null' ? int.parse(Get.parameters['index']) : null, fromNotification: Get.parameters['from'] == 'true',
        conversationID: (Get.parameters['conversation_id'] != null && Get.parameters['conversation_id'] != 'null') ? int.parse(Get.parameters['conversation_id']) : null,
      ));
    }),
    GetPage(name: conversation, page: () => ConversationScreen()),
    GetPage(name: restaurantRegistration, page: () => StoreRegistrationScreen()),
    GetPage(name: deliveryManRegistration, page: () => DeliveryManRegistrationScreen()),
    GetPage(name: refund, page: () => RefundRequestScreen(orderId: Get.parameters['id'])),
  ];

  static getRoute(Widget navigateTo) {
    int _minimumVersion = 0;
    if(GetPlatform.isAndroid) {
      _minimumVersion = Get.find<SplashController>().configModel.appMinimumVersionAndroid;
    }else if(GetPlatform.isIOS) {
      _minimumVersion = Get.find<SplashController>().configModel.appMinimumVersionIos;
    }
    return AppConstants.APP_VERSION < _minimumVersion ? UpdateScreen(isUpdate: true)
        : Get.find<SplashController>().configModel.maintenanceMode ? UpdateScreen(isUpdate: false)
        : Get.find<LocationController>().getUserAddress() == null
        ? AccessLocationScreen(fromSignUp: false, fromHome: false, route: Get.currentRoute) : navigateTo;
  }
}