import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/config_model.dart';
import 'package:sixam_mart/data/model/response/prediction_model.dart';
import 'package:sixam_mart/data/model/response/zone_response_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/custom_loader.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/screens/location/widget/landing_card.dart';
import 'package:sixam_mart/view/screens/location/widget/registration_card.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:intl/intl.dart' as intl;

class WebLandingPage extends StatefulWidget {
  final bool fromSignUp;
  final bool fromHome;
  final String route;
  const WebLandingPage({Key key, @required this.fromSignUp, @required this.fromHome, @required this.route}) : super(key: key);

  @override
  State<WebLandingPage> createState() => _WebLandingPageState();
}

class _WebLandingPageState extends State<WebLandingPage> {
  final TextEditingController _controller = TextEditingController();
  PageController _pageController = PageController();
  AddressModel _address;
  ConfigModel _config = Get.find<SplashController>().configModel;
  Timer _timer;
  bool _isRtl;

  @override
  void initState() {
    super.initState();

    // if(Get.find<SplashController>().moduleList == null) {
    //   Get.find<SplashController>().getModules();
    // }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isRtl = intl.Bidi.isRtlLanguage(Get.locale.languageCode);

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: FooterView(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: Column(children: [

        SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
            color: Theme.of(context).primaryColor.withOpacity(0.05),
          ),
          child: Row(children: [
            SizedBox(width: 40),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(AppConstants.APP_NAME, style: robotoBold.copyWith(fontSize: 35)),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
              Text(
                'more_than_just_a_reliable_ecommerce_platform'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
              ),
            ])),
            Expanded(child: ClipPath(clipper: CustomPath(isRtl: _isRtl), child: ClipRRect(
              borderRadius: BorderRadius.horizontal(
                right: _isRtl ? Radius.circular(0) : Radius.circular(Dimensions.RADIUS_DEFAULT),
                left: _isRtl ? Radius.circular(Dimensions.RADIUS_DEFAULT) : Radius.circular(0),
              ),
              child: CustomImage(
                image: '${_config.baseUrls.landingPageImageUrl}/${_config.landingPageSettings != null
                    ? _config.landingPageSettings.topContentImage : ''}',
                height: 270, fit: BoxFit.cover,
              ),
            ))),
          ]),
        ),
        SizedBox(height: 20),

        Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
            child: Opacity(opacity: 0.05, child: Image.asset(Images.landing_bg, height: 130, width: context.width, fit: BoxFit.fill)),
          ),
          Container(
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
              color: Theme.of(context).primaryColor.withOpacity(0.05),
            ),
            child: Row(children: [
              Expanded(flex: 3, child: Padding(
                padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                child: Column(children: [
                  Image.asset(Images.landing_choose_location, height: 70, width: 70),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE),
                    child: Text(
                      'choose_your_location_to_start_shopping'.tr, textAlign: TextAlign.center,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ),
                  ),
                ]),
              )),
              Expanded(flex: 7, child: Padding(
                padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                child: Row(children: [
                  Expanded(child: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.streetAddress,
                      decoration: InputDecoration(
                        hintText: 'search_location'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1),
                        ),
                        hintStyle: Theme.of(context).textTheme.displayMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor,
                        ),
                        filled: true, fillColor: Theme.of(context).cardColor,
                        suffixIcon: IconButton(
                          onPressed: () async {
                            Get.dialog(CustomLoader(), barrierDismissible: false);
                            _address = await Get.find<LocationController>().getCurrentLocation(true);
                            _controller.text = _address.address;
                            Get.back();
                          },
                          icon: Icon(Icons.my_location, color: Theme.of(context).primaryColor),
                        ),
                      ),
                      style: Theme.of(context).textTheme.displayMedium.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge.color, fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      return await Get.find<LocationController>().searchLocation(context, pattern);
                    },
                    itemBuilder: (context, PredictionModel suggestion) {
                      return Padding(
                        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                        child: Row(children: [
                          Icon(Icons.location_on),
                          Expanded(child: Text(
                            suggestion.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.displayMedium.copyWith(
                              color: Theme.of(context).textTheme.bodyLarge.color, fontSize: Dimensions.fontSizeLarge,
                            ),
                          )),
                        ]),
                      );
                    },
                    onSuggestionSelected: (PredictionModel suggestion) async {
                      _controller.text = suggestion.description;
                      _address = await Get.find<LocationController>().setLocation(suggestion.placeId, suggestion.description, null);
                    },
                  )),
                  SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                  CustomButton(
                    width: 150, height: 60, fontSize: Dimensions.fontSizeDefault,
                    buttonText: 'set_location'.tr,
                    onPressed: () async {
                      if(_address != null && _controller.text.trim().isNotEmpty) {
                        Get.dialog(CustomLoader(), barrierDismissible: false);
                        ZoneResponseModel _response = await Get.find<LocationController>().getZone(
                          _address.latitude, _address.longitude, false,
                        );
                        if(_response.isSuccess) {
                          Get.find<LocationController>().saveAddressAndNavigate(
                            _address, widget.fromSignUp, widget.route, widget.route != null, ResponsiveHelper.isDesktop(context),
                          );
                        }else {
                          Get.back();
                          showCustomSnackBar('service_not_available_in_current_location'.tr);
                        }
                      }else {
                        showCustomSnackBar('pick_an_address'.tr);
                      }
                    },
                  ),
                  SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                  CustomButton(
                    width: 160, height: 60, fontSize: Dimensions.fontSizeDefault,
                    buttonText: 'pick_from_map'.tr,
                    onPressed: () => Get.toNamed(RouteHelper.getPickMapRoute(
                      widget.route == null ? widget.fromSignUp ? RouteHelper.signUp : RouteHelper.accessLocation : widget.route,
                      widget.route != null,
                    )),
                  ),
                ]),
              )),
            ]),
          ),
        ]),
        SizedBox(height: 40),

        Text(
          'your_ecommerce_venture_starts_here'.tr,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
        ),
        Text(
          'enjoy_all_services_in_one_platform'.tr,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
        ),
        SizedBox(height: 40),

        GetBuilder<SplashController>(builder: (splashController) {
          if(splashController.moduleList != null && _timer == null) {
            _timer = Timer.periodic(Duration(seconds: 5), (timer) {
              int _index = splashController.moduleIndex >= splashController.moduleList.length-1 ? 0 : splashController.moduleIndex+1;
              splashController.setModuleIndex(_index);
              _pageController.animateToPage(_index, duration: Duration(seconds: 2), curve: Curves.easeInOut);
            });
          }
          return splashController.moduleList != null ? SizedBox(height: 450, child: Stack(children: [
            PageView.builder(
              controller: _pageController,
              itemCount: splashController.moduleList.length,
              onPageChanged: (int index) => splashController.setModuleIndex(index >= splashController.moduleList.length ? 0 : index),
              itemBuilder: (context, index) {
                index = splashController.moduleIndex >= splashController.moduleList.length ? 0 : splashController.moduleIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(height: 80),
                      Text(
                        splashController.moduleList[index].moduleName,
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault), textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                      Expanded(child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        child: Html(
                          data: splashController.moduleList[index].description ?? '', shrinkWrap: true,
                          onLinkTap: (String url, RenderContext context, Map<String, String> attributes, element) {
                            if(url.startsWith('www.')) {
                              url = 'https://' + url;
                            }
                            print('Redirect to url: $url');
                            html.window.open(url, "_blank");
                          },
                        ),
                      )),
                    ])),
                    CustomImage(
                      image: '${_config.baseUrls.moduleImageUrl}/${splashController.moduleList[index].thumbnail}',
                      height: 450, width: 450,
                    ),
                  ]),
                );
              },
            ),
            Positioned(top: 0, left: 0, child: SizedBox(height: 75, child: Container(
              padding: EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL, left: Dimensions.PADDING_SIZE_SMALL),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: splashController.moduleList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE),
                    child: Column(children: [
                      InkWell(
                        onTap: () {
                          splashController.setModuleIndex(index);
                          _pageController.animateToPage(index, duration: Duration(seconds: 2), curve: Curves.easeInOut);
                        },
                        child: CustomImage(
                          image: '${_config.baseUrls.moduleImageUrl}/${splashController.moduleList[index].icon}',
                          height: 45, width: 45,
                        ),
                      ),
                      SizedBox(width: 45, child: Divider(
                        color: splashController.moduleIndex == index ? Theme.of(context).primaryColor : Colors.transparent,
                        thickness: 2,
                      )),
                    ]),
                  );
                },
              ),
            ))),
          ])) : SizedBox();
        }),
        SizedBox(height: 40),

        Row(children: _generateChooseUsList()),
        SizedBox(height: AppConstants.whyChooseUsList.length > 0 ? 40 : 0),

        _config.toggleStoreRegistration ? RegistrationCard(isStore: true) : SizedBox(),
        SizedBox(height: _config.toggleStoreRegistration ? 40 : 0),

        (_config.landingPageLinks.appUrlAndroidStatus == '1' || _config.landingPageLinks.appUrlIosStatus == '1') ? Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          CustomImage(
            image: '${_config.baseUrls.landingPageImageUrl}/${_config.landingPageSettings != null
                ? _config.landingPageSettings.mobileAppSectionImage : ''}',
            width: 500,
          ),
          Column(children: [
            Text(
              'download_app_to_enjoy_more'.tr, textAlign: TextAlign.center,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
            ),
            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
            Text(
              'download_our_app_from'.tr, textAlign: TextAlign.center,
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
            ),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
            Row(children: [
              _config.landingPageLinks.appUrlAndroidStatus == '1' ? InkWell(
                onTap: () async {
                  if(await canLaunchUrlString(_config.landingPageLinks.appUrlAndroid)) {
                    launchUrlString(_config.landingPageLinks.appUrlAndroid);
                  }
                },
                child: Image.asset(Images.landing_google_play, height: 45),
              ) : SizedBox(),
              SizedBox(width: (_config.landingPageLinks.appUrlAndroidStatus == '1' && _config.landingPageLinks.appUrlIosStatus == '1')
                  ? Dimensions.PADDING_SIZE_LARGE : 0),
              _config.landingPageLinks.appUrlIosStatus == '1' ? InkWell(
                onTap: () async {
                  if(await canLaunchUrlString(_config.landingPageLinks.appUrlIos)) {
                    launchUrlString(_config.landingPageLinks.appUrlIos);
                  }
                },
                child: Image.asset(Images.landing_app_store, height: 45),
              ) : SizedBox(),
            ]),
          ]),
        ]) : SizedBox(),
        SizedBox(height: 40),

        _config.toggleDmRegistration ? RegistrationCard(isStore: false) : SizedBox(),
        SizedBox(height: _config.toggleDmRegistration ? 40 : 0),

      ]))),
    );
  }

  List<Widget> _generateChooseUsList() {
    List<Widget> _chooseUsList = [];
    for(int index=0; index < AppConstants.whyChooseUsList.length; index++) {
      _chooseUsList.add(Expanded(child: Row(children: [
        Expanded(child: LandingCard(icon: AppConstants.whyChooseUsList[index].icon, title: AppConstants.whyChooseUsList[index].title.tr)),
        SizedBox(width: index != AppConstants.whyChooseUsList.length-1 ? 30 : 0),
      ])));
    }
    return _chooseUsList;
  }

}

class CustomPath extends CustomClipper<Path> {
  final bool isRtl;
  CustomPath({@required this.isRtl});

  @override
  Path getClip(Size size) {
    final path = Path();
    if(isRtl) {
      path..moveTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width*0.7, 0)
        ..lineTo(0, 0)
        ..close();
    }else {
      path..moveTo(0, size.height)
        ..lineTo(size.width*0.3, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..close();
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
