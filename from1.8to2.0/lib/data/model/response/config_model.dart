import 'package:sixam_mart/data/model/response/module_model.dart';

class ConfigModel {
  String businessName;
  String logo;
  String address;
  String phone;
  String email;
  BaseUrls baseUrls;
  String country;
  DefaultLocation defaultLocation;
  String currencySymbol;
  String currencySymbolDirection;
  int appMinimumVersionAndroid;
  String appUrlAndroid;
  int appMinimumVersionIos;
  String appUrlIos;
  bool customerVerification;
  bool scheduleOrder;
  bool orderDeliveryVerification;
  bool cashOnDelivery;
  bool digitalPayment;
  double perKmShippingCharge;
  double minimumShippingCharge;
  double freeDeliveryOver;
  bool demo;
  bool maintenanceMode;
  String orderConfirmationModel;
  bool showDmEarning;
  bool canceledByDeliveryman;
  String timeformat;
  List<Language> language;
  bool toggleVegNonVeg;
  bool toggleDmRegistration;
  bool toggleStoreRegistration;
  int scheduleOrderSlotDuration;
  int digitAfterDecimalPoint;
  double parcelPerKmShippingCharge;
  double parcelMinimumShippingCharge;
  ModuleModel module;
  ModuleConfig moduleConfig;
  LandingPageSettings landingPageSettings;
  List<SocialMedia> socialMedia;
  String footerText;
  LandingPageLinks landingPageLinks;
  int loyaltyPointExchangeRate;
  double loyaltyPointItemPurchasePoint;
  int loyaltyPointStatus;
  int minimumPointToTransfer;
  int customerWalletStatus;
  int dmTipsStatus;
  int refEarningStatus;
  double refEarningExchangeRate;
  List<SocialLogin> socialLogin;
  bool refundActiveStatus;
  int refundPolicyStatus;
  int cancellationPolicyStatus;
  int shippingPolicyStatus;
  bool prescriptionStatus;
  int taxIncluded;

  ConfigModel(
      {this.businessName,
        this.logo,
        this.address,
        this.phone,
        this.email,
        this.baseUrls,
        this.country,
        this.defaultLocation,
        this.currencySymbol,
        this.currencySymbolDirection,
        this.appMinimumVersionAndroid,
        this.appUrlAndroid,
        this.appMinimumVersionIos,
        this.appUrlIos,
        this.customerVerification,
        this.scheduleOrder,
        this.orderDeliveryVerification,
        this.cashOnDelivery,
        this.digitalPayment,
        this.perKmShippingCharge,
        this.minimumShippingCharge,
        this.freeDeliveryOver,
        this.demo,
        this.maintenanceMode,
        this.orderConfirmationModel,
        this.showDmEarning,
        this.canceledByDeliveryman,
        this.timeformat,
        this.language,
        this.toggleVegNonVeg,
        this.toggleDmRegistration,
        this.toggleStoreRegistration,
        this.scheduleOrderSlotDuration,
        this.digitAfterDecimalPoint,
        this.module,
        this.moduleConfig,
        this.parcelPerKmShippingCharge,
        this.parcelMinimumShippingCharge,
        this.landingPageSettings,
        this.socialMedia,
        this.footerText,
        this.landingPageLinks,
        this.loyaltyPointExchangeRate,
        this.loyaltyPointItemPurchasePoint,
        this.loyaltyPointStatus,
        this.minimumPointToTransfer,
        this.customerWalletStatus,
        this.dmTipsStatus,
        this.refEarningStatus,
        this.refEarningExchangeRate,
        this.socialLogin,
        this.refundActiveStatus,
        this.refundPolicyStatus,
        this.cancellationPolicyStatus,
        this.shippingPolicyStatus,
        this.prescriptionStatus,
        this.taxIncluded,
      });

  ConfigModel.fromJson(Map<String, dynamic> json) {
    businessName = json['business_name'];
    logo = json['logo'];
    address = json['address'];
    phone = json['phone'];
    email = json['email'];
    baseUrls = json['base_urls'] != null
        ? new BaseUrls.fromJson(json['base_urls'])
        : null;
    country = json['country'];
    defaultLocation = json['default_location'] != null
        ? new DefaultLocation.fromJson(json['default_location'])
        : null;
    currencySymbol = json['currency_symbol'];
    currencySymbolDirection = json['currency_symbol_direction'];
    appMinimumVersionAndroid = json['app_minimum_version_android'];
    appUrlAndroid = json['app_url_android'];
    appMinimumVersionIos = json['app_minimum_version_ios'];
    appUrlIos = json['app_url_ios'];
    customerVerification = json['customer_verification'];
    scheduleOrder = json['schedule_order'];
    orderDeliveryVerification = json['order_delivery_verification'];
    cashOnDelivery = json['cash_on_delivery'];
    digitalPayment = json['digital_payment'];
    perKmShippingCharge = json['per_km_shipping_charge'].toDouble();
    minimumShippingCharge = json['minimum_shipping_charge'].toDouble();
    freeDeliveryOver = json['free_delivery_over'] != null ? json['free_delivery_over'].toDouble() : null;
    demo = json['demo'];
    maintenanceMode = json['maintenance_mode'];
    orderConfirmationModel = json['order_confirmation_model'];
    showDmEarning = json['show_dm_earning'];
    canceledByDeliveryman = json['canceled_by_deliveryman'];
    timeformat = json['timeformat'];
    if (json['language'] != null) {
      language = <Language>[];
      json['language'].forEach((v) {
        language.add(new Language.fromJson(v));
      });
    }
    toggleVegNonVeg = json['toggle_veg_non_veg'];
    toggleDmRegistration = json['toggle_dm_registration'];
    toggleStoreRegistration = json['toggle_store_registration'];
    scheduleOrderSlotDuration = json['schedule_order_slot_duration'] == 0 ? 30 : json['schedule_order_slot_duration'];
    digitAfterDecimalPoint = json['digit_after_decimal_point'];
    module = json['module'] != null
        ? new ModuleModel.fromJson(json['module'])
        : null;
    moduleConfig = json['module_config'] != null
        ? new ModuleConfig.fromJson(json['module_config'])
        : null;
    parcelPerKmShippingCharge = json['parcel_per_km_shipping_charge'].toDouble();
    parcelMinimumShippingCharge = json['parcel_minimum_shipping_charge'].toDouble();
    landingPageSettings = json['landing_page_settings'] != null
        ? LandingPageSettings.fromJson(json['landing_page_settings'])
        : null;
    if (json['social_media'] != null) {
      socialMedia = <SocialMedia>[];
      json['social_media'].forEach((v) {
        socialMedia.add(SocialMedia.fromJson(v));
      });
    }
    footerText = json['footer_text'];
    landingPageLinks = json['landing_page_links'] != null ? LandingPageLinks.fromJson(json['landing_page_links']) : null;
    loyaltyPointExchangeRate = json['loyalty_point_exchange_rate'];
    loyaltyPointItemPurchasePoint = json['loyalty_point_item_purchase_point'].toDouble();
    loyaltyPointStatus = json['loyalty_point_status'] ;
    minimumPointToTransfer = json['loyalty_point_minimum_point'];
    customerWalletStatus = json['customer_wallet_status'];
    dmTipsStatus = json['dm_tips_status'];
    refEarningStatus = json['ref_earning_status'];
    refundActiveStatus = json['refund_active_status'];
    refEarningExchangeRate = json['ref_earning_exchange_rate'].toDouble();
    if (json['social_login'] != null) {
      socialLogin = <SocialLogin>[];
      json['social_login'].forEach((v) {
        socialLogin.add(new SocialLogin.fromJson(v));
      });
    }
    refundPolicyStatus = json['refund_policy'];
    cancellationPolicyStatus = json['cancelation_policy'];
    shippingPolicyStatus = json['shipping_policy'];
    prescriptionStatus = json['prescription_order_status'];
    taxIncluded = json['tax_included'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['business_name'] = this.businessName;
    data['logo'] = this.logo;
    data['address'] = this.address;
    data['phone'] = this.phone;
    data['email'] = this.email;
    if (this.baseUrls != null) {
      data['base_urls'] = this.baseUrls.toJson();
    }
    data['country'] = this.country;
    if (this.defaultLocation != null) {
      data['default_location'] = this.defaultLocation.toJson();
    }
    data['currency_symbol'] = this.currencySymbol;
    data['currency_symbol_direction'] = this.currencySymbolDirection;
    data['app_minimum_version_android'] = this.appMinimumVersionAndroid;
    data['app_url_android'] = this.appUrlAndroid;
    data['app_minimum_version_ios'] = this.appMinimumVersionIos;
    data['app_url_ios'] = this.appUrlIos;
    data['customer_verification'] = this.customerVerification;
    data['schedule_order'] = this.scheduleOrder;
    data['order_delivery_verification'] = this.orderDeliveryVerification;
    data['cash_on_delivery'] = this.cashOnDelivery;
    data['digital_payment'] = this.digitalPayment;
    data['per_km_shipping_charge'] = this.perKmShippingCharge;
    data['minimum_shipping_charge'] = this.minimumShippingCharge;
    data['free_delivery_over'] = this.freeDeliveryOver;
    data['demo'] = this.demo;
    data['maintenance_mode'] = this.maintenanceMode;
    data['order_confirmation_model'] = this.orderConfirmationModel;
    data['show_dm_earning'] = this.showDmEarning;
    data['canceled_by_deliveryman'] = this.canceledByDeliveryman;
    data['timeformat'] = this.timeformat;
    if (this.language != null) {
      data['language'] = this.language.map((v) => v.toJson()).toList();
    }
    data['toggle_veg_non_veg'] = this.toggleVegNonVeg;
    data['toggle_dm_registration'] = this.toggleDmRegistration;
    data['toggle_store_registration'] = this.toggleStoreRegistration;
    data['schedule_order_slot_duration'] = this.scheduleOrderSlotDuration;
    data['digit_after_decimal_point'] = this.digitAfterDecimalPoint;
    if (this.module != null) {
      data['module'] = this.module.toJson();
    }
    if (this.moduleConfig != null) {
      data['module_config'] = this.moduleConfig.toJson();
    }
    data['parcel_per_km_shipping_charge'] = this.parcelPerKmShippingCharge;
    data['parcel_minimum_shipping_charge'] = this.parcelMinimumShippingCharge;
    if (this.landingPageSettings != null) {
      data['landing_page_settings'] = this.landingPageSettings.toJson();
    }
    if (this.socialMedia != null) {
      data['social_media'] = this.socialMedia.map((v) => v.toJson()).toList();
    }
    data['footer_text'] = this.footerText;
    if (this.landingPageLinks != null) {
      data['landing_page_links'] = this.landingPageLinks.toJson();
    }
    data['loyalty_point_exchange_rate'] = this.loyaltyPointExchangeRate;
    data['loyalty_point_item_purchase_point'] = this.loyaltyPointItemPurchasePoint;
    data['loyalty_point_status'] = this.loyaltyPointStatus;
    data['loyalty_point_minimum_point'] = this.minimumPointToTransfer;
    data['customer_wallet_status'] = this.customerWalletStatus;
    data['dm_tips_status'] = this.dmTipsStatus;
    data['ref_earning_status'] = this.refEarningStatus;
    data['ref_earning_exchange_rate'] = this.refEarningExchangeRate;
    data['refund_active_status'] = this.refundActiveStatus;
    if (this.socialLogin != null) {
      data['social_login'] = this.socialLogin.map((v) => v.toJson()).toList();
    }
    data['tax_included'] = this.taxIncluded;
    return data;
  }
}

class BaseUrls {
  String itemImageUrl;
  String customerImageUrl;
  String bannerImageUrl;
  String categoryImageUrl;
  String reviewImageUrl;
  String notificationImageUrl;
  String vendorImageUrl;
  String storeImageUrl;
  String storeCoverPhotoUrl;
  String deliveryManImageUrl;
  String chatImageUrl;
  String campaignImageUrl;
  String moduleImageUrl;
  String orderAttachmentUrl;
  String parcelCategoryImageUrl;
  String landingPageImageUrl;
  String businessLogoUrl;
  String refundImageUrl;

  BaseUrls(
      {this.itemImageUrl,
        this.customerImageUrl,
        this.bannerImageUrl,
        this.categoryImageUrl,
        this.reviewImageUrl,
        this.notificationImageUrl,
        this.vendorImageUrl,
        this.storeImageUrl,
        this.storeCoverPhotoUrl,
        this.deliveryManImageUrl,
        this.chatImageUrl,
        this.campaignImageUrl,
        this.moduleImageUrl,
        this.orderAttachmentUrl,
        this.parcelCategoryImageUrl,
        this.landingPageImageUrl,
        this.businessLogoUrl,
        this.refundImageUrl,
      });

  BaseUrls.fromJson(Map<String, dynamic> json) {
    itemImageUrl = json['item_image_url'];
    customerImageUrl = json['customer_image_url'];
    bannerImageUrl = json['banner_image_url'];
    categoryImageUrl = json['category_image_url'];
    reviewImageUrl = json['review_image_url'];
    notificationImageUrl = json['notification_image_url'];
    vendorImageUrl = json['vendor_image_url'];
    storeImageUrl = json['store_image_url'];
    storeCoverPhotoUrl = json['store_cover_photo_url'];
    deliveryManImageUrl = json['delivery_man_image_url'];
    chatImageUrl = json['chat_image_url'];
    campaignImageUrl = json['campaign_image_url'];
    moduleImageUrl = json['module_image_url'];
    orderAttachmentUrl = json['order_attachment_url'];
    parcelCategoryImageUrl = json['parcel_category_image_url'];
    landingPageImageUrl = json['landing_page_image_url'];
    businessLogoUrl = json['business_logo_url'];
    refundImageUrl = json['refund_image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['item_image_url'] = this.itemImageUrl;
    data['customer_image_url'] = this.customerImageUrl;
    data['banner_image_url'] = this.bannerImageUrl;
    data['category_image_url'] = this.categoryImageUrl;
    data['review_image_url'] = this.reviewImageUrl;
    data['notification_image_url'] = this.notificationImageUrl;
    data['vendor_image_url'] = this.vendorImageUrl;
    data['store_image_url'] = this.storeImageUrl;
    data['store_cover_photo_url'] = this.storeCoverPhotoUrl;
    data['delivery_man_image_url'] = this.deliveryManImageUrl;
    data['chat_image_url'] = this.chatImageUrl;
    data['campaign_image_url'] = this.campaignImageUrl;
    data['module_image_url'] = this.moduleImageUrl;
    data['order_attachment_url'] = this.orderAttachmentUrl;
    data['parcel_category_image_url'] = this.parcelCategoryImageUrl;
    data['landing_page_image_url'] = this.landingPageImageUrl;
    data['business_logo_url'] = this.businessLogoUrl;
    data['refund_image_url'] = this.refundImageUrl;
    return data;
  }
}

class DefaultLocation {
  String lat;
  String lng;

  DefaultLocation({this.lat, this.lng});

  DefaultLocation.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }
}

class Language {
  String key;
  String value;

  Language({this.key, this.value});

  Language.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    return data;
  }
}

class ModuleConfig {
  List<String> moduleType;
  Module module;

  ModuleConfig({this.moduleType, this.module});

  ModuleConfig.fromJson(Map<String, dynamic> json) {
    moduleType = json['module_type'].cast<String>();
    module = json[moduleType[0]] != null ? new Module.fromJson(json[moduleType[0]]) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['module_type'] = this.moduleType;
    if (this.module != null) {
      data[this.moduleType[0]] = this.module.toJson();
    }
    return data;
  }
}

class Module {
  bool orderPlaceToScheduleInterval;
  bool addOn;
  bool stock;
  bool vegNonVeg;
  bool unit;
  bool orderAttachment;
  bool showRestaurantText;
  bool isParcel;
  bool newVariation;
  String description;

  Module(
      {
        this.orderPlaceToScheduleInterval,
        this.addOn,
        this.stock,
        this.vegNonVeg,
        this.unit,
        this.orderAttachment,
        this.showRestaurantText,
        this.isParcel,
        this.newVariation,
        this.description,
      });

  Module.fromJson(Map<String, dynamic> json) {
    orderPlaceToScheduleInterval = json['order_place_to_schedule_interval'];
    addOn = json['add_on'];
    stock = json['stock'];
    vegNonVeg = json['veg_non_veg'];
    unit = json['unit'];
    orderAttachment = json['order_attachment'];
    showRestaurantText = json['show_restaurant_text'];
    isParcel = json['is_parcel'];
    newVariation = json['new_variation'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_place_to_schedule_interval'] =
        this.orderPlaceToScheduleInterval;
    data['add_on'] = this.addOn;
    data['stock'] = this.stock;
    data['veg_non_veg'] = this.vegNonVeg;
    data['unit'] = this.unit;
    data['order_attachment'] = this.orderAttachment;
    data['show_restaurant_text'] = this.showRestaurantText;
    data['is_parcel'] = this.isParcel;
    data['new_variation'] = this.newVariation;
    data['description'] = this.description;
    return data;
  }
}

class OrderStatus {
  bool accepted;

  OrderStatus({this.accepted});

  OrderStatus.fromJson(Map<String, dynamic> json) {
    accepted = json['accepted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accepted'] = this.accepted;
    return data;
  }
}

class LandingPageSettings {
  String mobileAppSectionImage;
  String topContentImage;

  LandingPageSettings({this.mobileAppSectionImage, this.topContentImage});

  LandingPageSettings.fromJson(Map<String, dynamic> json) {
    mobileAppSectionImage = json['mobile_app_section_image'];
    topContentImage = json['top_content_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mobile_app_section_image'] = this.mobileAppSectionImage;
    data['top_content_image'] = this.topContentImage;
    return data;
  }
}

class SocialMedia {
  int id;
  String name;
  String link;
  int status;

  SocialMedia(
      {this.id,
        this.name,
        this.link,
        this.status,
      });

  SocialMedia.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    link = json['link'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['link'] = this.link;
    data['status'] = this.status;
    return data;
  }
}

class LandingPageLinks {
  String appUrlAndroidStatus;
  String appUrlAndroid;
  String appUrlIosStatus;
  String appUrlIos;

  LandingPageLinks(
      {this.appUrlAndroidStatus,
        this.appUrlAndroid,
        this.appUrlIosStatus,
        this.appUrlIos,
      });

  LandingPageLinks.fromJson(Map<String, dynamic> json) {
    appUrlAndroidStatus = json['app_url_android_status'].toString();
    appUrlAndroid = json['app_url_android'];
    appUrlIosStatus = json['app_url_ios_status'].toString();
    appUrlIos = json['app_url_ios'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['app_url_android_status'] = this.appUrlAndroidStatus;
    data['app_url_android'] = this.appUrlAndroid;
    data['app_url_ios_status'] = this.appUrlIosStatus;
    data['app_url_ios'] = this.appUrlIos;
    return data;
  }
}

class SocialLogin {
  String loginMedium;
  bool status;

  SocialLogin({this.loginMedium, this.status});

  SocialLogin.fromJson(Map<String, dynamic> json) {
    loginMedium = json['login_medium'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['login_medium'] = this.loginMedium;
    data['status'] = this.status;
    return data;
  }
}