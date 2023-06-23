import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/cart_snackbar.dart';
import 'package:sixam_mart/view/base/confirmation_dialog.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/screens/checkout/checkout_screen.dart';
import 'package:sixam_mart/view/screens/item/widget/details_app_bar.dart';
import 'package:sixam_mart/view/screens/item/widget/details_web_view.dart';
import 'package:sixam_mart/view/screens/item/widget/item_image_view.dart';
import 'package:sixam_mart/view/screens/item/widget/item_title_view.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Item item;
  final bool inStorePage;
  ItemDetailsScreen({@required this.item, @required this.inStorePage});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final Size size = Get.size;
  GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  final GlobalKey<DetailsAppBarState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    Get.find<ItemController>().getProductDetails(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(
      builder: (itemController) {
        int _stock = 0;
        CartModel _cartModel;
        double _priceWithAddons = 0;
        if(itemController.item != null && itemController.variationIndex != null){
          List<String> _variationList = [];
          for (int index = 0; index < itemController.item.choiceOptions.length; index++) {
            _variationList.add(itemController.item.choiceOptions[index].options[itemController.variationIndex[index]].replaceAll(' ', ''));
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

          double price = itemController.item.price;
          Variation _variation;
          _stock = itemController.item.stock ?? 0;
          for (Variation variation in itemController.item.variations) {
            if (variation.type == variationType) {
              price = variation.price;
              _variation = variation;
              _stock = variation.stock;
              break;
            }
          }

          double _discount = (itemController.item.availableDateStarts != null || itemController.item.storeDiscount == 0) ? itemController.item.discount : itemController.item.storeDiscount;
          String _discountType = (itemController.item.availableDateStarts != null || itemController.item.storeDiscount == 0) ? itemController.item.discountType : 'percent';
          double priceWithDiscount = PriceConverter.convertWithDiscount(price, _discount, _discountType);
          double priceWithQuantity = priceWithDiscount * itemController.quantity;
          double addonsCost = 0;
          List<AddOn> _addOnIdList = [];
          List<AddOns> _addOnsList = [];
          for (int index = 0; index < itemController.item.addOns.length; index++) {
            if (itemController.addOnActiveList[index]) {
              addonsCost = addonsCost + (itemController.item.addOns[index].price * itemController.addOnQtyList[index]);
              _addOnIdList.add(AddOn(id: itemController.item.addOns[index].id, quantity: itemController.addOnQtyList[index]));
              _addOnsList.add(itemController.item.addOns[index]);
            }
          }

          _cartModel = CartModel(
            price, priceWithDiscount, _variation != null ? [_variation] : [], [],
            (price - PriceConverter.convertWithDiscount(price, _discount, _discountType)),
            itemController.quantity, _addOnIdList, _addOnsList, itemController.item.availableDateStarts != null, _stock, itemController.item,
          );
          _priceWithAddons = priceWithQuantity + (Get.find<SplashController>().configModel.moduleConfig.module.addOn ? addonsCost : 0);
        }

        return Scaffold(
          key: _globalKey,
          backgroundColor: Theme.of(context).cardColor,

          appBar: ResponsiveHelper.isDesktop(context)? CustomAppBar(title: '')  :  DetailsAppBar(key: _key),

          body: (itemController.item != null) ? ResponsiveHelper.isDesktop(context) ? DetailsWebView(
            cartModel: _cartModel, stock: _stock, priceWithAddOns: _priceWithAddons,
          ) : Column(children: [
            Expanded(child: Scrollbar(child: SingleChildScrollView(
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              physics: BouncingScrollPhysics(),
              child: Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ItemImageView(item: itemController.item),
                  SizedBox(height: 20),

                  ItemTitleView(item: itemController.item, inStorePage: widget.inStorePage, isCampaign: itemController.item.availableDateStarts != null),
                  Divider(height: 20, thickness: 2),

                  // Variation
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: itemController.item.choiceOptions.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(itemController.item.choiceOptions[index].title, style:robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                        SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                        GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 10,
                            childAspectRatio: (1 / 0.25),
                          ),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: itemController.item.choiceOptions[index].options.length,
                          itemBuilder: (context, i) {
                            return InkWell(
                              onTap: () {
                                itemController.setCartVariationIndex(index, i, itemController.item);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                decoration: BoxDecoration(
                                  color: itemController.variationIndex[index] != i ? Theme.of(context).disabledColor : Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                  border: itemController.variationIndex[index] != i ? Border.all(color: Theme.of(context).disabledColor, width: 2) : null,
                                ),
                                child: Text(
                                  itemController.item.choiceOptions[index].options[i].trim(), maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style:robotoRegular.copyWith(
                                    color: itemController.variationIndex[index] != i ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: index != itemController.item.choiceOptions.length-1 ? Dimensions.PADDING_SIZE_LARGE : 0),
                      ]);
                    },
                  ),
                  itemController.item.choiceOptions.length > 0 ? SizedBox(height: Dimensions.PADDING_SIZE_LARGE) : SizedBox(),

                  // Quantity
                  Row(children: [
                    Text('quantity'.tr, style:robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    Expanded(child: SizedBox()),
                    Container(
                      decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(5)),
                      child: Row(children: [
                        InkWell(
                          onTap: () {
                            if(itemController.cartIndex != -1) {
                              if(Get.find<CartController>().cartList[itemController.cartIndex].quantity > 1) {
                                Get.find<CartController>().setQuantity(false, itemController.cartIndex, _stock);
                              }
                            }else {
                              if(itemController.quantity > 1) {
                                itemController.setQuantity(false, _stock);
                              }
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            child: Icon(Icons.remove, size: 20),
                          ),
                        ),
                        GetBuilder<CartController>(builder: (cartController) {
                          return Text(
                            itemController.cartIndex != -1 ? cartController.cartList[itemController.cartIndex].quantity.toString()
                                : itemController.quantity.toString(),
                            style:robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                          );
                        }),
                        InkWell(
                          onTap: () => itemController.cartIndex != -1 ? Get.find<CartController>().setQuantity(true, itemController.cartIndex, _stock) :  itemController.setQuantity(true, _stock),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            child: Icon(Icons.add, size: 20),
                          ),
                        ),
                      ]),
                    ),
                  ]),
                  SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                  GetBuilder<CartController>(builder: (cartController) {
                    return Row(children: [
                      Text('${'total_amount'.tr}:', style:robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      Text(PriceConverter.convertPrice(itemController.cartIndex != -1 ? (cartController.cartList[itemController.cartIndex].discountedPrice * cartController.cartList[itemController.cartIndex].quantity)
                          : _priceWithAddons ?? 0.0), style:robotoBold.copyWith(
                        color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge,
                      )),
                    ]);
                  }),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),

                  (itemController.item.description != null && itemController.item.description.isNotEmpty) ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('description'.tr, style: robotoMedium),
                      SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      Text(itemController.item.description, style: robotoRegular),
                      SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                    ],
                  ) : SizedBox(),
                ],
              )))),
            )),

            Container(
              width: 1170,
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              child: CustomButton(
                buttonText: (Get.find<SplashController>().configModel.moduleConfig.module.stock && _stock <= 0) ? 'out_of_stock'.tr
                    : itemController.item.availableDateStarts != null ? 'order_now'.tr : itemController.cartIndex != -1 ? 'update_in_cart'.tr : 'add_to_cart'.tr,
                onPressed: (!Get.find<SplashController>().configModel.moduleConfig.module.stock || _stock > 0) ?  () {
                  if(!Get.find<SplashController>().configModel.moduleConfig.module.stock || _stock > 0) {
                    if(itemController.item.availableDateStarts != null) {
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
                        if(itemController.cartIndex == -1) {
                          Get.find<CartController>().addToCart(_cartModel, itemController.cartIndex);
                        }
                        _key.currentState.shake();
                        showCartSnackBar(context);
                      }
                    }
                  }
                } : null,
              ),
            ),

          ]) : Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final int quantity;
  final bool isCartWidget;
  final int stock;
  final bool isExistInCart;
  final int cartIndex;
  QuantityButton({
    @required this.isIncrement,
    @required this.quantity,
    @required this.stock,
    @required this.isExistInCart,
    @required this.cartIndex,
    this.isCartWidget = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:  () {
        if(isExistInCart) {
          if (!isIncrement && quantity > 1) {
            Get.find<CartController>().setQuantity(false, cartIndex, stock);
          } else if (isIncrement && quantity > 0) {
            if(quantity < stock || !Get.find<SplashController>().configModel.moduleConfig.module.stock) {
              Get.find<CartController>().setQuantity(true, cartIndex, stock);
            }else {
              showCustomSnackBar('out_of_stock'.tr);
            }
          }
        } else {
          if (!isIncrement && quantity > 1) {
            Get.find<ItemController>().setQuantity(false, stock);
          } else if (isIncrement && quantity > 0) {
            if(quantity < stock || !Get.find<SplashController>().configModel.moduleConfig.module.stock) {
              Get.find<ItemController>().setQuantity(true, stock);
            }else {
              showCustomSnackBar('out_of_stock'.tr);
            }
          }

        }
      },
      child: Container(
        // padding: EdgeInsets.all(3),
        height: 50,width: 50,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),color: Theme.of(context).primaryColor),
        child: Center(
          child: Icon(
            isIncrement ? Icons.add : Icons.remove,
            color: isIncrement ? Colors.white : quantity > 1 ? Colors.white : Colors.white,
            size: isCartWidget ? 26 : 20,
          ),
        ),
      ),
    );
  }
}
