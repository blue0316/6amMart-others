import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/confirmation_dialog.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/discount_tag.dart';
import 'package:sixam_mart/view/base/quantity_button.dart';
import 'package:sixam_mart/view/base/rating_bar.dart';
import 'package:sixam_mart/view/screens/checkout/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cart_snackbar.dart';

class ItemBottomSheet extends StatefulWidget {
  final Item item;
  final bool isCampaign;
  final CartModel cart;
  final int cartIndex;
  final bool inStorePage;
  ItemBottomSheet({@required this.item, this.isCampaign = false, this.cart, this.cartIndex, this.inStorePage = false});

  @override
  State<ItemBottomSheet> createState() => _ItemBottomSheetState();
}

class _ItemBottomSheetState extends State<ItemBottomSheet> {
  bool _newVariation = false;

  @override
  void initState() {
    super.initState();

    _newVariation = Get.find<SplashController>().getModuleConfig(widget.item.moduleType).newVariation;
    Get.find<ItemController>().initData(widget.item, widget.cart);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_DEFAULT, bottom: Dimensions.PADDING_SIZE_DEFAULT),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ? BorderRadius.vertical(top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE))
            : BorderRadius.all(Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
      ),
      child: GetBuilder<ItemController>(builder: (itemController) {
        double _startingPrice;
        double _endingPrice;
        if (widget.item.choiceOptions.length != 0) {
          List<double> _priceList = [];
          widget.item.variations.forEach((variation) => _priceList.add(variation.price));
          _priceList.sort((a, b) => a.compareTo(b));
          _startingPrice = _priceList[0];
          if (_priceList[0] < _priceList[_priceList.length - 1]) {
            _endingPrice = _priceList[_priceList.length - 1];
          }
        } else {
          _startingPrice = widget.item.price;
        }

        double _price = widget.item.price;
        double _variationPrice = 0;
        Variation _variation;
        double _discount = (widget.isCampaign || widget.item.storeDiscount == 0) ? widget.item.discount : widget.item.storeDiscount;
        String _discountType = (widget.isCampaign || widget.item.storeDiscount == 0) ? widget.item.discountType : 'percent';
        int _stock = widget.item.stock ?? 0;

        if(_newVariation) {
          for(int index = 0; index< widget.item.foodVariations.length; index++) {
            for(int i=0; i<widget.item.foodVariations[index].variationValues.length; i++) {
              if(itemController.selectedVariations[index][i]) {
                _variationPrice += widget.item.foodVariations[index].variationValues[i].optionPrice;
              }
            }
          }
        }else {
          List<String> _variationList = [];
          for (int index = 0; index < widget.item.choiceOptions.length; index++) {
            _variationList.add(widget.item.choiceOptions[index].options[itemController.variationIndex[index]].replaceAll(' ', ''));
          }
          String variationType = '';
          bool isFirst = true;
          _variationList.forEach((variation) {
            if (isFirst) {
              variationType = '$variationType$variation';
              isFirst = false;
            } else {
              variationType = '$variationType-$variation';
            }
          });

          for (Variation variation in widget.item.variations) {
            if (variation.type == variationType) {
              _price = variation.price;
              _variation = variation;
              _stock = variation.stock;
              break;
            }
          }
        }

        _price += _variationPrice;
        double priceWithDiscount = PriceConverter.convertWithDiscount(_price, _discount, _discountType);
        double addonsCost = 0;
        List<AddOn> _addOnIdList = [];
        List<AddOns> _addOnsList = [];
        for (int index = 0; index < widget.item.addOns.length; index++) {
          if (itemController.addOnActiveList[index]) {
            addonsCost = addonsCost + (widget.item.addOns[index].price * itemController.addOnQtyList[index]);
            _addOnIdList.add(AddOn(id: widget.item.addOns[index].id, quantity: itemController.addOnQtyList[index]));
            _addOnsList.add(widget.item.addOns[index]);
          }
        }
        bool _isAvailable = DateConverter.isAvailable(widget.item.availableTimeStarts, widget.item.availableTimeEnds);

        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [

            InkWell(onTap: () => Get.back(), child: Padding(
              padding:  EdgeInsets.only(right: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              child: Icon(Icons.close),
            )),

            Padding(
              padding: EdgeInsets.only(
                right: Dimensions.PADDING_SIZE_DEFAULT, top: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.PADDING_SIZE_DEFAULT,
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [

                //Product
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                  InkWell(
                    onTap: widget.isCampaign ? null : () {
                      if(!widget.isCampaign) {
                        Get.toNamed(RouteHelper.getItemImagesRoute(widget.item));
                      }
                    },
                    child: Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        child: CustomImage(
                          image: '${widget.isCampaign ? Get.find<SplashController>().configModel.baseUrls.campaignImageUrl
                              : Get.find<SplashController>().configModel.baseUrls.itemImageUrl}/${widget.item.image}',
                          width: ResponsiveHelper.isMobile(context) ? 100 : 140,
                          height: ResponsiveHelper.isMobile(context) ? 100 : 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                      DiscountTag(discount: _discount, discountType: _discountType, fromTop: 20),
                    ]),
                  ),
                  SizedBox(width: 10),

                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        widget.item.name, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                      InkWell(
                        onTap: () {
                          if(widget.inStorePage) {
                            Get.back();
                          }else {
                            Get.offNamed(RouteHelper.getStoreRoute(widget.item.storeId, 'item'));
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                          child: Text(
                            widget.item.storeName,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                      !widget.isCampaign ? RatingBar(rating: widget.item.avgRating, size: 15, ratingCount: widget.item.ratingCount) : SizedBox(),
                      Text(
                        '${PriceConverter.convertPrice(_startingPrice, discount: _discount, discountType: _discountType)}'
                            '${_endingPrice != null ? ' - ${PriceConverter.convertPrice(_endingPrice, discount: _discount,
                            discountType: _discountType)}' : ''}',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                      ),
                      _price > priceWithDiscount ? Text(
                        '${PriceConverter.convertPrice(_startingPrice)}'
                            '${_endingPrice != null ? ' - ${PriceConverter.convertPrice(_endingPrice)}' : ''}',
                        style: robotoMedium.copyWith(color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough),
                      ) : SizedBox(),
                    ]),
                  ),

                  Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    ((Get.find<SplashController>().configModel.moduleConfig.module.unit && widget.item.unitType != null)
                    || (Get.find<SplashController>().configModel.moduleConfig.module.vegNonVeg && Get.find<SplashController>().configModel.toggleVegNonVeg)) ? Container(
                      padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Text(
                        Get.find<SplashController>().configModel.moduleConfig.module.unit ? widget.item.unitType ?? ''
                            : widget.item.veg == 0 ? 'non_veg'.tr : 'veg'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white),
                      ),
                    ) : SizedBox(),
                    SizedBox(height: Get.find<SplashController>().configModel.toggleVegNonVeg ? 50 : 0),
                    widget.isCampaign ? SizedBox(height: 25) : GetBuilder<WishListController>(builder: (wishList) {
                      return InkWell(
                        onTap: () {
                          if(Get.find<AuthController>().isLoggedIn()) {
                            wishList.wishItemIdList.contains(widget.item.id) ? wishList.removeFromWishList(widget.item.id, false, getXSnackBar: true)
                                : wishList.addToWishList(widget.item, null, false, getXSnackBar: true);
                          }else {
                            showCustomSnackBar('you_are_not_logged_in'.tr, getXSnackBar: true);
                          }
                        },
                        child: Icon(
                          wishList.wishItemIdList.contains(widget.item.id) ? Icons.favorite : Icons.favorite_border,
                          color: wishList.wishItemIdList.contains(widget.item.id) ? Theme.of(context).primaryColor
                              : Theme.of(context).disabledColor,
                        ),
                      );
                    }),
                  ]),

                ]),

                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                (widget.item.description != null && widget.item.description.isNotEmpty) ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('description'.tr, style: robotoMedium),
                    SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    Text(widget.item.description, style: robotoRegular),
                    SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                  ],
                ) : SizedBox(),

                // Variation
                _newVariation ? NewVariationView(
                  item: widget.item, itemController: itemController,
                ) : VariationView(
                  item: widget.item, itemController: itemController,
                ),

                // Quantity
                Row(children: [
                  Text('quantity'.tr, style: robotoMedium),
                  Expanded(child: SizedBox()),
                  Row(children: [
                    QuantityButton(
                      onTap: () {
                        if (itemController.quantity > 1) {
                          itemController.setQuantity(false, _stock);
                        }
                      },
                      isIncrement: false,
                    ),
                    Text(itemController.quantity.toString(), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    QuantityButton(
                      onTap: () => itemController.setQuantity(true, _stock),
                      isIncrement: true,
                    ),
                  ]),
                ]),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                // Addons
                (Get.find<SplashController>().configModel.moduleConfig.module.addOn && widget.item.addOns.length > 0) ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('addons'.tr, style: robotoMedium),
                    SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 20, mainAxisSpacing: 10, childAspectRatio: (1 / 1.1),
                      ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.item.addOns.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            if (!itemController.addOnActiveList[index]) {
                              itemController.addAddOn(true, index);
                            } else if (itemController.addOnQtyList[index] == 1) {
                              itemController.addAddOn(false, index);
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(bottom: itemController.addOnActiveList[index] ? 2 : 20),
                            decoration: BoxDecoration(
                              color: itemController.addOnActiveList[index] ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.background,
                              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                              border: itemController.addOnActiveList[index] ? null : Border.all(color: Theme.of(context).disabledColor, width: 2),
                              boxShadow: itemController.addOnActiveList[index]
                                  ? [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300], blurRadius: 5, spreadRadius: 1)] : null,
                            ),
                            child: Column(children: [
                              Expanded(
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Text(widget.item.addOns[index].name,
                                    maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                                    style: robotoMedium.copyWith(
                                      color: itemController.addOnActiveList[index] ? Colors.white : Colors.black,
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    widget.item.addOns[index].price > 0 ? PriceConverter.convertPrice(widget.item.addOns[index].price) : 'free'.tr,
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: robotoRegular.copyWith(
                                      color: itemController.addOnActiveList[index] ? Colors.white : Colors.black,
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                    ),
                                  ),
                                ]),
                              ),
                              itemController.addOnActiveList[index] ? Container(
                                height: 25,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), color: Theme.of(context).cardColor),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        if (itemController.addOnQtyList[index] > 1) {
                                          itemController.setAddOnQuantity(false, index);
                                        } else {
                                          itemController.addAddOn(false, index);
                                        }
                                      },
                                      child: Center(child: Icon(Icons.remove, size: 15)),
                                    ),
                                  ),
                                  Text(
                                    itemController.addOnQtyList[index].toString(),
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => itemController.setAddOnQuantity(true, index),
                                      child: Center(child: Icon(Icons.add, size: 15)),
                                    ),
                                  ),
                                ]),
                              )
                                  : SizedBox(),
                            ]),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  ],
                ) : SizedBox(),

                Row(children: [
                  Text('${'total_amount'.tr}:', style: robotoMedium),
                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Text(
                    PriceConverter.convertPrice(
                      (_price * itemController.quantity) + addonsCost,
                      discount: _discount, discountType: _discountType,
                    ),
                    style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
                  ),
                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  _discount > 0 ? Text(
                    PriceConverter.convertPrice(
                      (_price * itemController.quantity) + addonsCost,
                    ),
                    style: robotoMedium.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall, decoration: TextDecoration.lineThrough),
                  ) : SizedBox(),
                ]),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                //Add to cart Button

                _isAvailable ? SizedBox() : Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  margin: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_SMALL),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  child: Column(children: [
                    Text('not_available_now'.tr, style: robotoMedium.copyWith(
                      color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge,
                    )),
                    Text(
                      '${'available_will_be'.tr} ${DateConverter.convertTimeToTime(widget.item.availableTimeStarts)} '
                          '- ${DateConverter.convertTimeToTime(widget.item.availableTimeEnds)}',
                      style: robotoRegular,
                    ),
                  ]),
                ),

                (!widget.item.scheduleOrder && !_isAvailable) ? SizedBox() : Row(children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(50, 50), backgroundColor: Theme.of(context).cardColor, shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                    ),
                    ),
                    onPressed: () {
                      if(widget.inStorePage) {
                        Get.back();
                      }else {
                        Get.offNamed(RouteHelper.getStoreRoute(widget.item.storeId, 'item'));
                      }
                    },
                    child: Image.asset(Images.house, color: Theme.of(context).primaryColor, height: 30, width: 30),
                  ),
                  SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                  Expanded(child: CustomButton(
                    width: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.width / 2.0 : null,
                    /*buttonText: isCampaign ? 'order_now'.tr : isExistInCart ? 'already_added_in_cart'.tr : fromCart
                        ? 'update_in_cart'.tr : 'add_to_cart'.tr,*/
                    buttonText: (Get.find<SplashController>().configModel.moduleConfig.module.stock && _stock <= 0)
                        ? 'out_of_stock'.tr : widget.isCampaign ? 'order_now'.tr
                        : (widget.cart != null || itemController.cartIndex != -1) ? 'update_in_cart'.tr : 'add_to_cart'.tr,
                    onPressed: (Get.find<SplashController>().configModel.moduleConfig.module.stock && _stock <= 0) ? null : () {

                      String _invalid;
                      if(_newVariation) {
                        for(int index=0; index<widget.item.foodVariations.length; index++) {
                          if(!widget.item.foodVariations[index].multiSelect && widget.item.foodVariations[index].required
                              && !itemController.selectedVariations[index].contains(true)) {
                            _invalid = '${'choose_a_variation_from'.tr} ${widget.item.foodVariations[index].name}';
                            break;
                          }else if(widget.item.foodVariations[index].multiSelect && (widget.item.foodVariations[index].required
                              || itemController.selectedVariations[index].contains(true)) && widget.item.foodVariations[index].min
                              > itemController.selectedVariationLength(itemController.selectedVariations, index)) {
                            _invalid = '${'you_need_to_select_minimum'.tr} ${widget.item.foodVariations[index].min} '
                                '${'to_maximum'.tr} ${widget.item.foodVariations[index].max} ${'options_from'.tr}'
                                ' ${widget.item.foodVariations[index].name} ${'variation'.tr}';
                            break;
                          }
                        }
                      }

                      if(_invalid != null) {
                        showCustomSnackBar(_invalid, getXSnackBar: true);
                      }else {
                        Get.back();
                        CartModel _cartModel = CartModel(
                          _price, priceWithDiscount, _variation != null ? [_variation] : [], itemController.selectedVariations,
                          (_price - PriceConverter.convertWithDiscount(_price, _discount, _discountType)),
                          itemController.quantity, _addOnIdList, _addOnsList, widget.isCampaign, _stock, widget.item,
                        );
                        if(widget.isCampaign) {
                          Get.toNamed(RouteHelper.getCheckoutRoute('campaign'), arguments: CheckoutScreen(
                            storeId: null, fromCart: false, cartList: [_cartModel],
                          ));
                        }else {
                          if (Get.find<CartController>().existAnotherStoreItem(_cartModel.item.storeId, Get.find<SplashController>().module.id)) {
                            Get.dialog(ConfirmationDialog(
                              icon: Images.warning,
                              title: 'are_you_sure_to_reset'.tr,
                              description: Get.find<SplashController>().configModel.moduleConfig.module.showRestaurantText
                                  ? 'if_you_continue'.tr : 'if_you_continue_without_another_store'.tr,
                              onYesPressed: () {
                                Get.back();
                                Get.find<CartController>().removeAllAndAddToCart(_cartModel);
                                showCartSnackBar(context);
                              },
                            ), barrierDismissible: false);
                          } else {
                            Get.find<CartController>().addToCart(
                              _cartModel, widget.cartIndex != null ? widget.cartIndex : itemController.cartIndex,
                            );
                            showCartSnackBar(context);
                          }
                        }
                      }
                    },

                  )),
                ]),
              ]),
            ),
          ]),
        )]);
      }),
    );
  }
}

class VariationView extends StatelessWidget {
  final Item item;
  final ItemController itemController;
  const VariationView({Key key, @required this.item, @required this.itemController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: item.choiceOptions.length,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: item.choiceOptions.length > 0 ? Dimensions.PADDING_SIZE_LARGE : 0),
      itemBuilder: (context, index) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.choiceOptions[index].title, style: robotoMedium),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
              color: Theme.of(context).cardColor,
            ),
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: item.choiceOptions[index].options.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  child: InkWell(
                    onTap: () {
                      itemController.setCartVariationIndex(index, i, item);
                    },
                    child: Row(children: [
                      Expanded(child: Text(
                        item.choiceOptions[index].options[i].trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular,
                      )),
                      SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                      Radio<int>(
                        value: i,
                        groupValue: itemController.variationIndex[index],
                        onChanged: (int value) => itemController.setCartVariationIndex(index, i, item),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ]),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: index != item.choiceOptions.length - 1 ? Dimensions.PADDING_SIZE_LARGE : 0),
        ]);
      },
    );
  }
}

class NewVariationView extends StatelessWidget {
  final Item item;
  final ItemController itemController;
  const NewVariationView({Key key, @required this.item, @required this.itemController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return item.foodVariations != null ? ListView.builder(
      shrinkWrap: true,
      itemCount: item.foodVariations.length,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: (item.foodVariations != null && item.foodVariations.length > 0) ? Dimensions.PADDING_SIZE_LARGE : 0),
      itemBuilder: (context, index) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(item.foodVariations[index].name, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),

            Text(
              ' (${item.foodVariations[index].required ? 'required'.tr : 'optional'.tr})',
              style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
            ),
          ]),
          SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

          Row(children: [
            (item.foodVariations[index].multiSelect) ? Text(
              '${'you_need_to_select_minimum'.tr} ${'${item.foodVariations[index].min}'
                  ' ${'to_maximum'.tr} ${item.foodVariations[index].max} ${'options'.tr}'}',
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
            ) : SizedBox(),
          ]),
          SizedBox(height: (item.foodVariations[index].multiSelect) ? Dimensions.PADDING_SIZE_EXTRA_SMALL : 0),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: item.foodVariations[index].variationValues.length,
            itemBuilder: (context, i) {
              return InkWell(
                onTap: () {
                  itemController.setNewCartVariationIndex(index, i, item);
                },
                child: Row(children: [

                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

                    item.foodVariations[index].multiSelect ? Checkbox(
                      value: itemController.selectedVariations[index][i],
                      activeColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
                      onChanged:(bool newValue) {
                        itemController.setNewCartVariationIndex(index, i, item);
                      },
                      visualDensity: VisualDensity(horizontal: -3, vertical: -3),
                    ) : Radio(
                      value: i,
                      groupValue: itemController.selectedVariations[index].indexOf(true),
                      onChanged: (value) {
                        itemController.setNewCartVariationIndex(index, i, item);
                      },
                      activeColor: Theme.of(context).primaryColor,
                      toggleable: false,
                      visualDensity: VisualDensity(horizontal: -3, vertical: -3),
                    ),

                    Text(
                      item.foodVariations[index].variationValues[i].level.trim(),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: itemController.selectedVariations[index][i] ? robotoMedium : robotoRegular,
                    ),

                  ]),

                  Spacer(),

                  Text(
                    '${item.foodVariations[index].variationValues[i].optionPrice > 0 ? '+'
                        + PriceConverter.convertPrice(item.foodVariations[index].variationValues[i].optionPrice) : 'free'.tr}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: itemController.selectedVariations[index][i] ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall)
                        : robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                  ),

                ]),
              );
            },
          ),

          SizedBox(height: index != item.foodVariations.length - 1 ? Dimensions.PADDING_SIZE_LARGE : 0),
        ]);
      },
    ) : SizedBox();
  }
}

