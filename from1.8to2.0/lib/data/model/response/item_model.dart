import 'package:get/get.dart';
import 'package:sixam_mart/controller/splash_controller.dart';

class ItemModel {
  int totalSize;
  String limit;
  int offset;
  List<Item> items;

  ItemModel({this.totalSize, this.limit, this.offset, this.items});

  ItemModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if (json['products'] != null) {
      items = [];
      json['products'].forEach((v) {
        if(v['module_type'] == null || !Get.find<SplashController>().getModuleConfig(v['module_type']).newVariation
            || v['variations'] == null || v['variations'].isEmpty
            || (v['food_variations'] != null && v['food_variations'].isNotEmpty)) {
          items.add(new Item.fromJson(v));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_size'] = this.totalSize;
    data['limit'] = this.limit;
    data['offset'] = this.offset;
    if (this.items != null) {
      data['products'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Item {
  int id;
  String name;
  String description;
  String image;
  List<String> images;
  int categoryId;
  List<CategoryIds> categoryIds;
  List<Variation> variations;
  List<FoodVariation> foodVariations;
  List<AddOns> addOns;
  List<ChoiceOptions> choiceOptions;
  double price;
  double tax;
  double discount;
  String discountType;
  String availableTimeStarts;
  String availableTimeEnds;
  int storeId;
  String storeName;
  int zoneId;
  double storeDiscount;
  bool scheduleOrder;
  double avgRating;
  int ratingCount;
  int veg;
  int moduleId;
  String moduleType;
  String unitType;
  int stock;
  String availableDateStarts;

  Item(
      {this.id,
        this.name,
        this.description,
        this.image,
        this.images,
        this.categoryId,
        this.categoryIds,
        this.variations,
        this.foodVariations,
        this.addOns,
        this.choiceOptions,
        this.price,
        this.tax,
        this.discount,
        this.discountType,
        this.availableTimeStarts,
        this.availableTimeEnds,
        this.storeId,
        this.storeName,
        this.zoneId,
        this.storeDiscount,
        this.scheduleOrder,
        this.avgRating,
        this.ratingCount,
        this.veg,
        this.moduleId,
        this.moduleType,
        this.unitType,
        this.stock,
      });

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    images = json['images'] != null ? json['images'].cast<String>() : [];
    categoryId = json['category_id'];
    if (json['category_ids'] != null) {
      categoryIds = [];
      json['category_ids'].forEach((v) {
        categoryIds.add(new CategoryIds.fromJson(v));
      });
    }
    variations = [];
    if (json['variations'] != null) {
      json['variations'].forEach((v) {
        variations.add(new Variation.fromJson(v));
      });
    }
    foodVariations = [];
    if (json['food_variations'] != null && json['food_variations'].isNotEmpty) {
      json['food_variations'].forEach((v) {
        foodVariations.add(new FoodVariation.fromJson(v));
      });
    }
    if (json['add_ons'] != null) {
      addOns = [];
      json['add_ons'].forEach((v) {
        addOns.add(new AddOns.fromJson(v));
      });
    }
    if (json['choice_options'] != null) {
      choiceOptions = [];
      json['choice_options'].forEach((v) {
        choiceOptions.add(new ChoiceOptions.fromJson(v));
      });
    }
    price = json['price'].toDouble();
    tax = json['tax'] != null ? json['tax'].toDouble() : null;
    discount = json['discount'].toDouble();
    discountType = json['discount_type'];
    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];
    storeId = json['store_id'];
    storeName = json['store_name'];
    zoneId = json['zone_id'];
    storeDiscount = json['store_discount'].toDouble();
    scheduleOrder = json['schedule_order'];
    avgRating = json['avg_rating'].toDouble();
    ratingCount = json['rating_count'];
    moduleId = json['module_id'];
    moduleType = json['module_type'];
    veg = json['veg'] != null ? int.parse(json['veg'].toString()) : 0;
    stock = json['stock'];
    unitType = json['unit_type'];
    availableDateStarts = json['available_date_starts'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image'] = this.image;
    data['images'] = this.images;
    data['category_id'] = this.categoryId;
    if (this.categoryIds != null) {
      data['category_ids'] = this.categoryIds.map((v) => v.toJson()).toList();
    }
    if (this.variations != null) {
      data['variations'] = this.variations.map((v) => v.toJson()).toList();
    }
    if (this.foodVariations != null) {
      data['food_variations'] = this.foodVariations.map((v) => v.toJson()).toList();
    }
    if (this.addOns != null) {
      data['add_ons'] = this.addOns.map((v) => v.toJson()).toList();
    }
    if (this.choiceOptions != null) {
      data['choice_options'] =
          this.choiceOptions.map((v) => v.toJson()).toList();
    }
    data['price'] = this.price;
    data['tax'] = this.tax;
    data['discount'] = this.discount;
    data['discount_type'] = this.discountType;
    data['available_time_starts'] = this.availableTimeStarts;
    data['available_time_ends'] = this.availableTimeEnds;
    data['store_id'] = this.storeId;
    data['store_name'] = this.storeName;
    data['zone_id'] = this.zoneId;
    data['store_discount'] = this.storeDiscount;
    data['schedule_order'] = this.scheduleOrder;
    data['avg_rating'] = this.avgRating;
    data['rating_count'] = this.ratingCount;
    data['veg'] = this.veg;
    data['module_id'] = this.moduleId;
    data['module_type'] = this.moduleType;
    data['stock'] = this.stock;
    data['unit_type'] = this.unitType;
    data['available_date_starts'] = this.availableDateStarts;
    return data;
  }
}

class CategoryIds {
  String id;

  CategoryIds({this.id});

  CategoryIds.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    return data;
  }
}

class Variation {
  String type;
  double price;
  int stock;

  Variation({this.type, this.price, this.stock});

  Variation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    price = json['price'].toDouble();
    stock = int.parse(json['stock'] != null ? json['stock'].toString() : '0');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['price'] = this.price;
    data['stock'] = this.stock;
    return data;
  }
}

class AddOns {
  int id;
  String name;
  double price;

  AddOns(
      {this.id,
        this.name,
        this.price});

  AddOns.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    return data;
  }
}

class ChoiceOptions {
  String name;
  String title;
  List<String> options;

  ChoiceOptions({this.name, this.title, this.options});

  ChoiceOptions.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    title = json['title'];
    options = json['options'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['title'] = this.title;
    data['options'] = this.options;
    return data;
  }
}

class FoodVariation {
  String name;
  bool multiSelect;
  int min;
  int max;
  bool required;
  List<VariationValue> variationValues;

  FoodVariation({this.name, this.multiSelect, this.min, this.max, this.required, this.variationValues});

  FoodVariation.fromJson(Map<String, dynamic> json) {
    if(json['max'] != null) {
      name = json['name'];
      multiSelect = json['type'] == 'multi';
      min =  multiSelect ? int.parse(json['min'].toString()) : 0;
      max = multiSelect ? int.parse(json['max'].toString()) : 0;
      required = json['required'] == 'on';
      if (json['values'] != null) {
        variationValues = [];
        json['values'].forEach((v) {
          variationValues.add(new VariationValue.fromJson(v));
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['type'] = this.multiSelect;
    data['min'] = this.min;
    data['max'] = this.max;
    data['required'] = this.required;
    if (this.variationValues != null) {
      data['values'] = this.variationValues.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VariationValue {
  String level;
  double optionPrice;

  VariationValue({this.level, this.optionPrice});

  VariationValue.fromJson(Map<String, dynamic> json) {
    level = json['label'];
    optionPrice = double.parse(json['optionPrice'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.level;
    data['optionPrice'] = this.optionPrice;
    return data;
  }
}
