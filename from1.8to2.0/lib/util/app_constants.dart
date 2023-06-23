import 'package:sixam_mart/data/model/response/choose_us_model.dart';
import 'package:sixam_mart/data/model/response/language_model.dart';
import 'package:sixam_mart/util/images.dart';

class AppConstants {
  static const String APP_NAME = '6amMart';
  static const double APP_VERSION = 2.0;

  static const String BASE_URL = 'https://6ammart-admin.6amtech.com';
  static const String CATEGORY_URI = '/api/v1/categories';
  static const String BANNER_URI = '/api/v1/banners';
  static const String STORE_ITEM_URI = '/api/v1/items/latest';
  static const String POPULAR_ITEM_URI = '/api/v1/items/popular';
  static const String REVIEWED_ITEM_URI = '/api/v1/items/most-reviewed';
  static const String SEARCH_ITEM_URI = '/api/v1/items/details/';
  static const String SUB_CATEGORY_URI = '/api/v1/categories/childes/';
  static const String CATEGORY_ITEM_URI = '/api/v1/categories/items/';
  static const String CATEGORY_STORE_URI = '/api/v1/categories/stores/';
  static const String CONFIG_URI = '/api/v1/config';
  static const String TRACK_URI = '/api/v1/customer/order/track?order_id=';
  static const String MESSAGE_URI = '/api/v1/customer/message/get';
  static const String FORGET_PASSWORD_URI = '/api/v1/auth/forgot-password';
  static const String VERIFY_TOKEN_URI = '/api/v1/auth/verify-token';
  static const String RESET_PASSWORD_URI = '/api/v1/auth/reset-password';
  static const String VERIFY_PHONE_URI = '/api/v1/auth/verify-phone';
  static const String CHECK_EMAIL_URI = '/api/v1/auth/check-email';
  static const String VERIFY_EMAIL_URI = '/api/v1/auth/verify-email';
  static const String REGISTER_URI = '/api/v1/auth/sign-up';
  static const String LOGIN_URI = '/api/v1/auth/login';
  static const String TOKEN_URI = '/api/v1/customer/cm-firebase-token';
  static const String PLACE_ORDER_URI = '/api/v1/customer/order/place';
  static const String PLACE_PRESCRIPTION_ORDER_URI = '/api/v1/customer/order/prescription/place';
  static const String ADDRESS_LIST_URI = '/api/v1/customer/address/list';
  static const String ZONE_URI = '/api/v1/config/get-zone-id';
  static const String REMOVE_ADDRESS_URI = '/api/v1/customer/address/delete?address_id=';
  static const String ADD_ADDRESS_URI = '/api/v1/customer/address/add';
  static const String UPDATE_ADDRESS_URI = '/api/v1/customer/address/update/';
  static const String SET_MENU_URI = '/api/v1/items/set-menu';
  static const String CUSTOMER_INFO_URI = '/api/v1/customer/info';
  static const String COUPON_URI = '/api/v1/coupon/list';
  static const String COUPON_APPLY_URI = '/api/v1/coupon/apply?code=';
  static const String RUNNING_ORDER_LIST_URI = '/api/v1/customer/order/running-orders';
  static const String HISTORY_ORDER_LIST_URI = '/api/v1/customer/order/list';
  static const String ORDER_CANCEL_URI = '/api/v1/customer/order/cancel';
  static const String COD_SWITCH_URL = '/api/v1/customer/order/payment-method';
  static const String ORDER_DETAILS_URI = '/api/v1/customer/order/details?order_id=';
  static const String WISH_LIST_GET_URI = '/api/v1/customer/wish-list';
  static const String ADD_WISH_LIST_URI = '/api/v1/customer/wish-list/add?';
  static const String REMOVE_WISH_LIST_URI = '/api/v1/customer/wish-list/remove?';
  static const String NOTIFICATION_URI = '/api/v1/customer/notifications';
  static const String UPDATE_PROFILE_URI = '/api/v1/customer/update-profile';
  static const String SEARCH_URI = '/api/v1/';
  static const String REVIEW_URI = '/api/v1/items/reviews/submit';
  static const String ITEM_DETAILS_URI = '/api/v1/items/details/';
  static const String LAST_LOCATION_URI = '/api/v1/delivery-man/last-location?order_id=';
  static const String DELIVER_MAN_REVIEW_URI = '/api/v1/delivery-man/reviews/submit';
  static const String STORE_URI = '/api/v1/stores/get-stores';
  static const String POPULAR_STORE_URI = '/api/v1/stores/popular';
  static const String LATEST_STORE_URI = '/api/v1/stores/latest';
  static const String STORE_DETAILS_URI = '/api/v1/stores/details/';
  static const String BASIC_CAMPAIGN_URI = '/api/v1/campaigns/basic';
  static const String ITEM_CAMPAIGN_URI = '/api/v1/campaigns/item';
  static const String BASIC_CAMPAIGN_DETAILS_URI = '/api/v1/campaigns/basic-campaign-details?basic_campaign_id=';
  static const String INTEREST_URI = '/api/v1/customer/update-interest';
  static const String SUGGESTED_ITEM_URI = '/api/v1/customer/suggested-items';
  static const String STORE_REVIEW_URI = '/api/v1/stores/reviews';
  static const String DISTANCE_MATRIX_URI = '/api/v1/config/distance-api';
  static const String SEARCH_LOCATION_URI = '/api/v1/config/place-api-autocomplete';
  static const String PLACE_DETAILS_URI = '/api/v1/config/place-api-details';
  static const String GEOCODE_URI = '/api/v1/config/geocode-api';
  static const String SOCIAL_LOGIN_URL = '/api/v1/auth/social-login';
  static const String SOCIAL_REGISTER_URL = '/api/v1/auth/social-register';
  static const String UPDATE_ZONE_URL = '/api/v1/customer/update-zone';
  static const String MODULES_URI = '/api/v1/module';
  static const String PARCEL_CATEGORY_URI = '/api/v1/parcel-category';
  static const String ABOUT_US_URI = '/about-us';
  static const String PRIVACY_POLICY_URI = '/privacy-policy';
  static const String TERMS_AND_CONDITIONS_URI = '/terms-and-conditions';
  static const String CANCELATION_URI = '/cancelation';
  static const String REFUND_URI = '/refund';
  static const String SHIPPING_POLICY_URI = '/shipping-policy';
  static const String SUBSCRIPTION_URI = '/api/v1/newsletter/subscribe';
  static const String CUSTOMER_REMOVE = '/api/v1/customer/remove-account';
  static const String WALLET_TRANSACTION_URL = '/api/v1/customer/wallet/transactions';
  static const String LOYALTY_TRANSACTION_URL = '/api/v1/customer/loyalty-point/transactions';
  static const String LOYALTY_POINT_TRANSFER_URL = '/api/v1/customer/loyalty-point/point-transfer';
  static const String ZONE_LIST_URI = '/api/v1/zone/list';
  static const String STORE_REGISTER_URI = '/api/v1/auth/vendor/register';
  static const String DM_REGISTER_URI = '/api/v1/auth/delivery-man/store';
  static const String REFUND_REASONS_URI = '/api/v1/customer/order/refund-reasons';
  static const String REFUND_REQUEST_URI = '/api/v1/customer/order/refund-request';

  //MESSAGING
  static const String CONVERSATION_LIST_URI = '/api/v1/customer/message/list';
  static const String SEARCH_CONVERSATION_LIST_URI = '/api/v1/customer/message/search-list';
  static const String MESSAGE_LIST_URI = '/api/v1/customer/message/details';
  static const String SEND_MESSAGE_URI = '/api/v1/customer/message/send';

  // Shared Key
  static const String THEME = '6ammart_theme';
  static const String TOKEN = '6ammart_token';
  static const String COUNTRY_CODE = '6ammart_country_code';
  static const String LANGUAGE_CODE = '6ammart_language_code';
  static const String CART_LIST = '6ammart_cart_list';
  static const String USER_PASSWORD = '6ammart_user_password';
  static const String USER_ADDRESS = '6ammart_user_address';
  static const String USER_NUMBER = '6ammart_user_number';
  static const String USER_COUNTRY_CODE = '6ammart_user_country_code';
  static const String NOTIFICATION = '6ammart_notification';
  static const String SEARCH_HISTORY = '6ammart_search_history';
  static const String INTRO = '6ammart_intro';
  static const String NOTIFICATION_COUNT = '6ammart_notification_count';

  static const String TOPIC = 'all_zone_customer';
  static const String ZONE_ID = 'zoneId';
  static const String MODULE_ID = 'moduleId';
  static const String CACHE_MODULE_ID = 'cacheModuleId';
  static const String LOCALIZATION_KEY = 'X-localization';
  static const String LATITUDE = 'latitude';
  static const String LONGITUDE = 'longitude';


  // Delivery Tips
  static List<int> tips = [0, 5, 10, 15, 20, 30, 50];

  static List<ChooseUsModel> whyChooseUsList = [
    ChooseUsModel(icon: Images.landing_trusted, title: 'trusted_by_customers_and_store_owners'),
    ChooseUsModel(icon: Images.landing_stores, title: 'thousands_of_stores'),
    ChooseUsModel(icon: Images.landing_excellent, title: 'excellent_shopping_experience'),
    ChooseUsModel(icon: Images.landing_checkout, title: 'easy_checkout_and_payment_system'),
  ];

  static List<LanguageModel> languages = [
    LanguageModel(imageUrl: Images.english, languageName: 'English', countryCode: 'US', languageCode: 'en'),
    LanguageModel(imageUrl: Images.arabic, languageName: 'عربى', countryCode: 'SA', languageCode: 'ar'),
    LanguageModel(imageUrl: Images.arabic, languageName: 'Spanish', countryCode: 'ES', languageCode: 'es'),
  ];
}
