import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/screens/language/widget/language_widget.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:get/get.dart';

class ChooseLanguageScreen extends StatefulWidget {
  final bool fromMenu;
  ChooseLanguageScreen({this.fromMenu = false});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.fromMenu || ResponsiveHelper.isDesktop(context)) ? CustomAppBar(title: 'language'.tr, backButton: true) : null,
      endDrawer: MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: GetBuilder<LocalizationController>(builder: (localizationController) {
          return Column(children: [

            Expanded(child: Center(
              child: Scrollbar(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  child: Center(child: FooterView(minHeight: 0.615,
                    child: SizedBox(
                      width: Dimensions.WEB_MAX_WIDTH,
                      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Center(child: Image.asset(Images.logo, width: 200)),
                        // Center(child: Text(AppConstants.APP_NAME, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge))),
                        SizedBox(height: 30),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          child: Text('select_language'.tr, style: robotoMedium),
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                        GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : ResponsiveHelper.isTab(context) ? 3 : 2,
                            childAspectRatio: (1/1),
                          ),
                          itemCount: localizationController.languages.length,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) => LanguageWidget(
                            languageModel: localizationController.languages[index],
                            localizationController: localizationController, index: index,
                          ),
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                        Text('you_can_change_language'.tr, style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
                        )),

                        ResponsiveHelper.isDesktop(context) ? Padding(
                          padding: const EdgeInsets.only(top: Dimensions.PADDING_SIZE_LARGE),
                          child: LanguageSaveButton(localizationController: localizationController, fromMenu: widget.fromMenu),
                        ) : SizedBox.shrink() ,

                      ]),
                    ),
                  )),
                ),
              ),
            )),

            ResponsiveHelper.isDesktop(context) ? SizedBox.shrink() : LanguageSaveButton(localizationController: localizationController, fromMenu: widget.fromMenu),
          ]);
        }),
      ),
    );
  }
}

class LanguageSaveButton extends StatelessWidget {
  final LocalizationController localizationController;
  final bool fromMenu;
  const LanguageSaveButton({Key key, @required this.localizationController, this.fromMenu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      buttonText: 'save'.tr,
      margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
      onPressed: () {
        if(localizationController.languages.length > 0 && localizationController.selectedIndex != -1) {
          localizationController.setLanguage(Locale(
            AppConstants.languages[localizationController.selectedIndex].languageCode,
            AppConstants.languages[localizationController.selectedIndex].countryCode,
          ));
          if (fromMenu) {
            Navigator.pop(context);
          } else {
            Get.offNamed(RouteHelper.getOnBoardingRoute());
          }
        }else {
          showCustomSnackBar('select_a_language'.tr);
        }
      },
    );
  }
}

