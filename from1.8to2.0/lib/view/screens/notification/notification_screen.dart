import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/notification_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/no_data_screen.dart';
import 'package:sixam_mart/view/base/not_logged_in_screen.dart';
import 'package:sixam_mart/view/screens/notification/widget/notification_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  final bool fromNotification;
  const NotificationScreen({this.fromNotification = false});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  void _loadData() async {
    Get.find<NotificationController>().clearNotification();
    if(Get.find<SplashController>().configModel == null) {
      await Get.find<SplashController>().getConfigData();
    }
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<NotificationController>().getNotificationList(true);
    }
  }

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
          return true;
        } else {
          Get.back();
          return true;
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'notification'.tr, onBackPressed: () {
          if(widget.fromNotification){
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }else{
            Get.back();
          }
        }),
        endDrawer: MenuDrawer(),endDrawerEnableOpenDragGesture: false,
        body: Get.find<AuthController>().isLoggedIn() ? GetBuilder<NotificationController>(builder: (notificationController) {
          if(notificationController.notificationList != null) {
            notificationController.saveSeenNotificationCount(notificationController.notificationList.length);
          }
          List<DateTime> _dateTimeList = [];
          return notificationController.notificationList != null ? notificationController.notificationList.length > 0 ? RefreshIndicator(
            onRefresh: () async {
              await notificationController.getNotificationList(true);
            },
            child: Scrollbar(child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: FooterView(
                child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: ListView.builder(
                  itemCount: notificationController.notificationList.length,
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DateTime _originalDateTime = DateConverter.dateTimeStringToDate(notificationController.notificationList[index].createdAt);
                    DateTime _convertedDate = DateTime(_originalDateTime.year, _originalDateTime.month, _originalDateTime.day);
                    bool _addTitle = false;
                    if(!_dateTimeList.contains(_convertedDate)) {
                      _addTitle = true;
                      _dateTimeList.add(_convertedDate);
                    }
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      _addTitle ? Padding(
                        padding: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                        child: Text(DateConverter.dateTimeStringToDateOnly(notificationController.notificationList[index].createdAt)),
                      ) : SizedBox(),

                      InkWell(
                        onTap: () {
                          showDialog(context: context, builder: (BuildContext context) {
                            return NotificationDialog(notificationModel: notificationController.notificationList[index]);
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          child: Row(children: [

                            ClipOval(child: CustomImage(
                              isNotification: true,
                              height: 40, width: 40, fit: BoxFit.cover,
                              image: '${Get.find<SplashController>().configModel.baseUrls.notificationImageUrl}'
                                  '/${notificationController.notificationList[index].data.image}',
                            )),
                            SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                notificationController.notificationList[index].data.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              ),
                              Text(
                                notificationController.notificationList[index].data.description ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                              ),
                            ])),

                          ]),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 50),
                        child: Divider(color: Theme.of(context).disabledColor, thickness: 1),
                      ),

                    ]);
                  },
                )),
              ),
            )),
          ) : NoDataScreen(text: 'no_notification_found'.tr, showFooter: true) : Center(child: CircularProgressIndicator());
        }) : NotLoggedInScreen(),
      ),
    );
  }
}
