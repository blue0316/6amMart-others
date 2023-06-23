import 'package:sixam_mart/data/api/api_checker.dart';
import 'package:sixam_mart/data/model/response/category_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/data/repository/category_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController implements GetxService {
  final CategoryRepo categoryRepo;
  CategoryController({@required this.categoryRepo});

  List<CategoryModel> _categoryList;
  List<CategoryModel> _subCategoryList;
  List<Item> _categoryItemList;
  List<Store> _categoryStoreList;
  List<Item> _searchItemList = [];
  List<Store> _searchStoreList = [];
  List<bool> _interestSelectedList;
  bool _isLoading = false;
  int _pageSize;
  int _restPageSize;
  bool _isSearching = false;
  int _subCategoryIndex = 0;
  String _type = 'all';
  bool _isStore = false;
  String _searchText = '';
  String _storeResultText = '';
  String _itemResultText = '';
  int _offset = 1;

  List<CategoryModel> get categoryList => _categoryList;
  List<CategoryModel> get subCategoryList => _subCategoryList;
  List<Item> get categoryItemList => _categoryItemList;
  List<Store> get categoryStoreList => _categoryStoreList;
  List<Item> get searchItemList => _searchItemList;
  List<Store> get searchStoreList => _searchStoreList;
  List<bool> get interestSelectedList => _interestSelectedList;
  bool get isLoading => _isLoading;
  int get pageSize => _pageSize;
  int get restPageSize => _restPageSize;
  bool get isSearching => _isSearching;
  int get subCategoryIndex => _subCategoryIndex;
  String get type => _type;
  bool get isStore => _isStore;
  String get searchText => _searchText;
  int get offset => _offset;

  Future<void> getCategoryList(bool reload, {bool allCategory = false}) async {
    if(_categoryList == null || reload) {
      _categoryList = null;
      Response response = await categoryRepo.getCategoryList(allCategory);
      if (response.statusCode == 200) {
        _categoryList = [];
        _interestSelectedList = [];
        response.body.forEach((category) {
          _categoryList.add(CategoryModel.fromJson(category));
          _interestSelectedList.add(false);
        });
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  void getSubCategoryList(String categoryID) async {
    _subCategoryIndex = 0;
    _subCategoryList = null;
    _categoryItemList = null;
    Response response = await categoryRepo.getSubCategoryList(categoryID);
    if (response.statusCode == 200) {
      _subCategoryList= [];
      _subCategoryList.add(CategoryModel(id: int.parse(categoryID), name: 'all'.tr));
      response.body.forEach((category) => _subCategoryList.add(CategoryModel.fromJson(category)));
      getCategoryItemList(categoryID, 1, 'all', false);
    } else {
      ApiChecker.checkApi(response);
    }
  }

  void setSubCategoryIndex(int index, String categoryID) {
    _subCategoryIndex = index;
    if(_isStore) {
      getCategoryStoreList(_subCategoryIndex == 0 ? categoryID : _subCategoryList[index].id.toString(), 1, _type, true);
    }else {
      getCategoryItemList(_subCategoryIndex == 0 ? categoryID : _subCategoryList[index].id.toString(), 1, _type, true);
    }
  }

  void getCategoryItemList(String categoryID, int offset, String type, bool notify) async {
    _offset = offset;
    if(offset == 1) {
      if(_type == type) {
        _isSearching = false;
      }
      _type = type;
      if(notify) {
        update();
      }
      _categoryItemList = null;
    }
    Response response = await categoryRepo.getCategoryItemList(categoryID, offset, type);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _categoryItemList = [];
      }
      _categoryItemList.addAll(ItemModel.fromJson(response.body).items);
      _pageSize = ItemModel.fromJson(response.body).totalSize;
      _isLoading = false;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void getCategoryStoreList(String categoryID, int offset, String type, bool notify) async {
    _offset = offset;
    if(offset == 1) {
      if(_type == type) {
        _isSearching = false;
      }
      _type = type;
      if(notify) {
        update();
      }
      _categoryStoreList = null;
    }
    Response response = await categoryRepo.getCategoryStoreList(categoryID, offset, type);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _categoryStoreList = [];
      }
      _categoryStoreList.addAll(StoreModel.fromJson(response.body).stores);
      _restPageSize = ItemModel.fromJson(response.body).totalSize;
      _isLoading = false;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void searchData(String query, String categoryID, String type) async {
    if((_isStore && query.isNotEmpty && query != _storeResultText) || (!_isStore && query.isNotEmpty && query != _itemResultText)) {
      _searchText = query;
      _type = type;
      if (_isStore) {
        _searchStoreList = null;
      } else {
        _searchItemList = null;
      }
      _isSearching = true;
      update();

      Response response = await categoryRepo.getSearchData(query, categoryID, _isStore, type);
      if (response.statusCode == 200) {
        if (query.isEmpty) {
          if (_isStore) {
            _searchStoreList = [];
          } else {
            _searchItemList = [];
          }
        } else {
          if (_isStore) {
            _storeResultText = query;
            _searchStoreList = [];
            _searchStoreList.addAll(StoreModel.fromJson(response.body).stores);
            update();
          } else {
            _itemResultText = query;
            _searchItemList = [];
            _searchItemList.addAll(ItemModel.fromJson(response.body).items);
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    _searchItemList = [];
    if(_categoryItemList != null) {
      _searchItemList.addAll(_categoryItemList);
    }
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  Future<bool> saveInterest(List<int> interests) async {
    _isLoading = true;
    update();
    Response response = await categoryRepo.saveUserInterests(interests);
    bool _isSuccess;
    if(response.statusCode == 200) {
      _isSuccess = true;
    }else {
      _isSuccess = false;
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
    return _isSuccess;
  }

  void addInterestSelection(int index) {
    _interestSelectedList[index] = !_interestSelectedList[index];
    update();
  }

  void setRestaurant(bool isRestaurant) {
    _isStore = isRestaurant;
    update();
  }

}
