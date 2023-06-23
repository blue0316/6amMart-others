class ZoneResponseModel {
  bool _isSuccess;
  List<int> _zoneIds;
  String _message;
  List<ZoneData> _zoneData;
  ZoneResponseModel(this._isSuccess, this._message, this._zoneIds, this._zoneData);

  String get message => _message;
  List<int> get zoneIds => _zoneIds;
  bool get isSuccess => _isSuccess;
  List<ZoneData> get zoneData => _zoneData;
}

class ZoneData {
  int id;
  int status;
  bool cashOnDelivery;
  bool digitalPayment;
  List<Modules> modules;

  ZoneData(
      {this.id,
        this.status,
        this.cashOnDelivery,
        this.digitalPayment,
        this.modules});

  ZoneData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    cashOnDelivery = json['cash_on_delivery'];
    digitalPayment = json['digital_payment'];
    if (json['modules'] != null) {
      modules = <Modules>[];
      json['modules'].forEach((v) {
        modules.add(new Modules.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['status'] = this.status;
    data['cash_on_delivery'] = this.cashOnDelivery;
    data['digital_payment'] = this.digitalPayment;
    if (this.modules != null) {
      data['modules'] = this.modules.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Modules {
  int id;
  String moduleName;
  String moduleType;
  String thumbnail;
  String status;
  int storesCount;
  String createdAt;
  String updatedAt;
  String icon;
  int themeId;
  String description;
  int allZoneService;
  Pivot pivot;

  Modules({this.id,
        this.moduleName,
        this.moduleType,
        this.thumbnail,
        this.status,
        this.storesCount,
        this.createdAt,
        this.updatedAt,
        this.icon,
        this.themeId,
        this.description,
        this.allZoneService,
        this.pivot,
      });

  Modules.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    moduleName = json['module_name'];
    moduleType = json['module_type'];
    thumbnail = json['thumbnail'];
    status = json['status'];
    storesCount = json['stores_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    icon = json['icon'];
    themeId = json['theme_id'];
    description = json['description'];
    allZoneService = json['all_zone_service'];
    pivot = json['pivot'] != null ? new Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['module_name'] = this.moduleName;
    data['module_type'] = this.moduleType;
    data['thumbnail'] = this.thumbnail;
    data['status'] = this.status;
    data['stores_count'] = this.storesCount;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['icon'] = this.icon;
    data['theme_id'] = this.themeId;
    data['description'] = this.description;
    data['all_zone_service'] = this.allZoneService;
    if (this.pivot != null) {
      data['pivot'] = this.pivot.toJson();
    }
    return data;
  }
}

class Pivot {
  int zoneId;
  int moduleId;
  double perKmShippingCharge;
  double minimumShippingCharge;
  double maximumCodOrderAmount;

  Pivot({
    this.zoneId,
    this.moduleId,
    this.perKmShippingCharge,
    this.minimumShippingCharge,
    this.maximumCodOrderAmount,
  });

  Pivot.fromJson(Map<String, dynamic> json) {
    zoneId = json['zone_id'];
    moduleId = json['module_id'];
    perKmShippingCharge = json['per_km_shipping_charge'] != null ? json['per_km_shipping_charge'].toDouble() : null;
    minimumShippingCharge = json['minimum_shipping_charge'] != null ? json['minimum_shipping_charge'].toDouble() : null;
    maximumCodOrderAmount = json['maximum_cod_order_amount'] != null ? json['maximum_cod_order_amount'].toDouble() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['zone_id'] = this.zoneId;
    data['module_id'] = this.moduleId;
    data['per_km_shipping_charge'] = this.perKmShippingCharge;
    data['minimum_shipping_charge'] = this.minimumShippingCharge;
    data['maximum_cod_order_amount'] = this.maximumCodOrderAmount;
    return data;
  }
}