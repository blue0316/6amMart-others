import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/controller/wallet_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/no_data_screen.dart';
import 'package:sixam_mart/view/base/not_logged_in_screen.dart';
import 'package:sixam_mart/view/base/title_widget.dart';
import 'package:sixam_mart/view/screens/wallet/widget/history_item.dart';
import 'package:sixam_mart/view/screens/wallet/widget/wallet_bottom_sheet.dart';

class WalletScreen extends StatefulWidget {
  final bool fromWallet;
  WalletScreen({Key key, @required this.fromWallet}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController scrollController = ScrollController();
  final bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();

  @override
  void initState() {
    super.initState();
    if(_isLoggedIn){
      Get.find<UserController>().getUserInfo();
      Get.find<WalletController>().getWalletTransactionList('1', false, widget.fromWallet);

      Get.find<WalletController>().setOffset(1);

      scrollController?.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent
            && Get.find<WalletController>().transactionList != null
            && !Get.find<WalletController>().isLoading) {
          int pageSize = (Get.find<WalletController>().popularPageSize / 10).ceil();
          if (Get.find<WalletController>().offset < pageSize) {
            Get.find<WalletController>().setOffset(Get.find<WalletController>().offset + 1);
            print('end of the page');
            Get.find<WalletController>().showBottomLoader();
            Get.find<WalletController>().getWalletTransactionList(Get.find<WalletController>().offset.toString(), false, widget.fromWallet);
          }
        }
      });
    }

  }
  @override
  void dispose() {
    super.dispose();

    scrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      endDrawer: MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(title: widget.fromWallet ? 'wallet'.tr : 'loyalty_points'.tr, backButton: true),
      body: GetBuilder<UserController>(
          builder: (userController) {
            return _isLoggedIn ? userController.userInfoModel != null ? SafeArea(
              child: RefreshIndicator(
                onRefresh: () async{
                  Get.find<WalletController>().getWalletTransactionList('1', true, widget.fromWallet);
                  Get.find<UserController>().getUserInfo();
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0.0 : Dimensions.PADDING_SIZE_DEFAULT),
                  child: FooterView(
                    child: SizedBox(
                      width: Dimensions.WEB_MAX_WIDTH,
                      child: GetBuilder<WalletController>(
                          builder: (walletController) {
                            return Column(children: [

                              Stack(
                                children: [
                                  Container(
                                    padding: widget.fromWallet ? EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_LARGE)
                                        : EdgeInsets.only(top: 40, left: Dimensions.PADDING_SIZE_EXTRA_LARGE, right: Dimensions.PADDING_SIZE_EXTRA_LARGE),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
                                      color: widget.fromWallet ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                    ),
                                    child:  Row(mainAxisAlignment: widget.fromWallet ? MainAxisAlignment.start : MainAxisAlignment.center, children: [

                                      Image.asset( widget.fromWallet ? Images.wallet : Images.loyal , height: 60, width: 60, color: widget.fromWallet ? Theme.of(context).cardColor : null),
                                      SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_LARGE),

                                      widget.fromWallet ? Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('wallet_amount'.tr,style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor)),
                                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                                            Text(
                                              PriceConverter.convertPrice(userController.userInfoModel.walletBalance),
                                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).cardColor),
                                            ),
                                          ])
                                          : Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.end, children: [

                                            Text(
                                              userController.userInfoModel.loyaltyPoint == null ? '0' : userController.userInfoModel.loyaltyPoint.toString(),
                                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).textTheme.bodyLarge.color),
                                            ),
                                            Text(
                                              'loyalty_points'.tr + ' !',
                                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge.color),
                                            ),
                                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                                      ])
                                    ]),
                                  ),

                                  widget.fromWallet ? SizedBox.shrink() : Positioned(
                                    top: 10,right: 10,
                                    child: InkWell(
                                      onTap: (){
                                        ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                                            WalletBottomSheet(fromWallet: widget.fromWallet)
                                        ) : Get.dialog(
                                          Dialog(child: WalletBottomSheet(fromWallet: widget.fromWallet)),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            'convert_to_currency'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                                              color: widget.fromWallet ? Theme.of(context).cardColor : Theme.of(context).textTheme.bodyLarge.color),
                                          ),
                                          Icon(Icons.keyboard_arrow_down_outlined,size: 16, color: widget.fromWallet ? Theme.of(context).cardColor
                                              : Theme.of(context).textTheme.bodyLarge.color)
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ) ,


                              Column(children: [

                                Padding(
                                  padding: EdgeInsets.only(top: Dimensions.PADDING_SIZE_EXTRA_LARGE),
                                  child: TitleWidget(title: 'transaction_history'.tr),
                                ),
                                walletController.transactionList != null ? walletController.transactionList.length > 0 ? GridView.builder(
                                  key: UniqueKey(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisSpacing: 50,
                                    mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.PADDING_SIZE_LARGE : 0.01,
                                    childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 4.45,
                                    crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                                  ),
                                  physics:  NeverScrollableScrollPhysics(),
                                  shrinkWrap:  true,
                                  itemCount: walletController.transactionList.length ,
                                  padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
                                  itemBuilder: (context, index) {
                                    return HistoryItem(index: index,fromWallet: widget.fromWallet, data: walletController.transactionList );
                                  },
                                ) : NoDataScreen(text: 'no_data_found'.tr) : WalletShimmer(walletController: walletController),

                                walletController.isLoading ? Center(child: Padding(
                                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                  child: CircularProgressIndicator(),
                                )) : SizedBox(),
                              ])
                            ]);
                          }
                      ),
                    ),
                  ),
                ),
              ),
            ) : Center(child: CircularProgressIndicator()) : NotLoggedInScreen();
          }
      ),
    );
  }
}
class WalletShimmer extends StatelessWidget {
  final WalletController walletController;
  WalletShimmer({@required this.walletController});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: UniqueKey(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 50,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.PADDING_SIZE_LARGE : 0.01,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 4.45,
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
      ),
      physics:  NeverScrollableScrollPhysics(),
      shrinkWrap:  true,
      itemCount: 10,
      padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
          child: Shimmer(
            duration: Duration(seconds: 2),
            enabled: walletController.transactionList == null,
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                ],
              ),
              Padding(padding: const EdgeInsets.only(top: Dimensions.PADDING_SIZE_LARGE), child: Divider(color: Theme.of(context).disabledColor)),
            ],
            ),
          ),
        );
      },
    );
  }
}